"""RAG Orchestrator - Core business logic for chat endpoint."""

import asyncio
import logging
from collections.abc import AsyncGenerator
from typing import Any

from app.core.exceptions import LLMConnectionError, LLMStreamError, RAGRetrievalError
from app.domain.schemas.chat import ChatRequest, ChatResponse
from app.infrastructure.llm.base import BaseLLMClient
from app.services.rag.template_builder_protocol import TemplateBuilderProtocol
from app.services.rag.vector_store_protocol import VectorStoreProtocol

logger = logging.getLogger(__name__)


class RAGOrchestrator:
    """Orchestrates vector retrieval, template build, and LLM generation."""

    def __init__(
        self,
        vector_store: VectorStoreProtocol,
        template_builder: TemplateBuilderProtocol,
        llm_client: BaseLLMClient,
    ) -> None:
        self.vector_store = vector_store
        self.template_builder = template_builder
        self.llm_client = llm_client

    async def process_message(self, request: ChatRequest) -> ChatResponse:
        """Process a chat message through the RAG pipeline.

        Graceful Degradation (HU-4.4 GAP 1):
        - If ChromaDB fails or times out, continue with sources=[]
        - Use FALLBACK template for general LLM knowledge
        - Log WARNING (not ERROR) as degradation is expected behavior

        Args:
            request: ChatRequest with user message

        Returns:
            ChatResponse with AI-generated response

        Raises:
            None (gracefully degrades on RAG failures)
        """
        sources = []  # Default empty (graceful degradation)

        # RAG Retrieval with 30s timeout and exception handling
        try:
            sources = await asyncio.wait_for(
                self.vector_store.search(request.message, top_k=5),
                timeout=30.0,  # GAP 3: 30s hard limit
            )
            logger.info(
                "✅ RAG retrieved %d sources",
                len(sources),
                extra={"sources_count": len(sources)},
            )

        except TimeoutError:
            logger.warning(
                "⚠️ RAG degraded: vector search timeout (30s)",
                extra={
                    "operation": "vector_search",
                    "timeout_seconds": 30.0,
                    "degradation_mode": "FALLBACK",
                },
            )

        except ConnectionError:
            logger.warning(
                "⚠️ RAG degraded: ChromaDB connection failed, continuing without context",
                extra={
                    "operation": "vector_search",
                    "error_type": "ConnectionError",
                    "degradation_mode": "FALLBACK",
                },
            )

        except Exception as error:
            # Catch-all for any other vector store exceptions
            logger.warning(
                "⚠️ RAG degraded: vector search failed, continuing without context",
                extra={
                    "operation": "vector_search",
                    "error_type": type(error).__name__,
                    "degradation_mode": "FALLBACK",
                },
            )

        # Template Selection (FALLBACK if sources empty)
        if sources:
            template_id = self.template_builder.select_template(request.project_id)
        else:
            template_id = "FALLBACK"  # Use general LLM knowledge
            logger.info(
                "🔄 Using FALLBACK template (RAG degraded)",
                extra={"template": "FALLBACK", "reason": "no_sources_available"},
            )

        # Build prompt with available sources (may be empty)
        prompt = self.template_builder.build_prompt(
            query=request.message,
            context=sources,
            template_id=template_id,
        )

        # Generate LLM response (GAP 2: retry applied in llm_client)
        try:
            ai_response = await self.llm_client.generate(prompt)
        except LLMConnectionError:
            raise

        return ChatResponse(
            ai_response=ai_response,
            template_used=template_id,
            sources=sources,
        )

    async def process_message_stream(
        self, request: ChatRequest
    ) -> AsyncGenerator[dict[str, Any], None]:
        """Process a chat message with streaming response through the RAG pipeline.

        Graceful Degradation: Same as process_message()

        Yields SSE-compatible events in dict format:
        - token events: {"type": "token", "data": str, "is_final": bool}
        - done events: {"type": "done", "data": {"full_response": str, "sources": list, "metadata": dict}}
        - error events: {"type": "error", "data": {"error": str, "code": str, "retry": bool}}

        Args:
            request: ChatRequest object with message and project_id

        Yields:
            Dict events compatible with SSE format

        Raises:
            LLMStreamError: If LLM streaming fails
        """
        sources = []
        template_id = "FALLBACK"
        full_response = ""

        try:
            # Phase 1: Vector retrieval with timeout and exception handling
            try:
                sources = await asyncio.wait_for(
                    self.vector_store.search(request.message, top_k=5),
                    timeout=30.0,
                )
            except (TimeoutError, ConnectionError, Exception) as error:
                logger.warning(
                    "⚠️ RAG degraded in streaming: %s",
                    type(error).__name__,
                    extra={"operation": "vector_search_stream"},
                )
                # Continue with empty sources (graceful degradation)

            # Phase 2: Template selection
            if sources:
                template_id = self.template_builder.select_template(request.project_id)
            else:
                template_id = "FALLBACK"
                logger.info("🔄 Using FALLBACK template in streaming (RAG degraded)")

            # Phase 3: Prompt construction
            prompt = self.template_builder.build_prompt(
                query=request.message,
                context=sources,
                template_id=template_id,
            )

            # Phase 4: Stream LLM response
            try:
                async for token in self.llm_client.stream_generate(prompt):
                    full_response += token
                    yield {
                        "type": "token",
                        "data": token,
                        "is_final": False,
                    }
            except LLMConnectionError as error:
                logger.error("LLM connection failed during streaming: %s", error)
                yield {
                    "type": "error",
                    "data": {
                        "error": "AI service connection failed",
                        "code": "LLM_CONNECTION_ERROR",
                        "retry": True,
                    },
                }
                raise
            except LLMStreamError as error:
                logger.error("LLM streaming failed: %s", error)
                yield {
                    "type": "error",
                    "data": {
                        "error": "AI streaming failed",
                        "code": "LLM_STREAM_ERROR",
                        "retry": True,
                    },
                }
                raise
            except Exception as error:
                logger.error("Unexpected error during LLM streaming: %s", error)
                yield {
                    "type": "error",
                    "data": {
                        "error": "AI processing failed",
                        "code": "LLM_UNKNOWN_ERROR",
                        "retry": False,
                    },
                }
                raise LLMStreamError(
                    message="LLM streaming failed",
                    details={"error": str(error)},
                ) from error

            # Phase 5: Emit done event with metadata
            yield {
                "type": "done",
                "data": {
                    "full_response": full_response,
                    "sources": sources,
                    "metadata": {
                        "template_used": template_id,
                        "token_count": len(full_response.split()),
                        "source_count": len(sources),
                    },
                },
            }

        except (RAGRetrievalError, LLMConnectionError, LLMStreamError):
            # Re-raise domain exceptions (already logged and yielded error events)
            raise
        except Exception as error:
            # Catch-all for unexpected errors
            logger.error("Unexpected error in process_message_stream: %s", error)
            yield {
                "type": "error",
                "data": {
                    "error": "Unexpected error during message processing",
                    "code": "ORCHESTRATOR_ERROR",
                    "retry": False,
                },
            }
            raise
