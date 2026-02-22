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

    def _check_validation_blocker(self, history: list[dict[str, str]]) -> str | None:
        """
        RULE-06: Validation Blocker - Enforce document validation before next step.

        Checks if LLM generated a <document> tag without subsequent user validation.
        This prevents users from proceeding to the next workflow step without
        validating the current document, saving LLM tokens and enforcing workflow discipline.

        Logic:
        1. Search history for assistant messages containing '<document>' tag
        2. For each document found, check if a subsequent user message contains
           the validation phrase: "He validado y guardado el documento"
        3. If an unvalidated document is found, return blocking message
        4. Otherwise, return None (OK to proceed with LLM call)

        Args:
            history: Chat history with role + content dicts

        Returns:
            str: Blocking message if validation missing
            None: If all documents validated or no documents in history

        Example blocking scenario:
            Assistant: "Here's the document... <document>...</document>"
            User: "Show me the next step"  # Missing validation!
            → Returns blocking message, prevents LLM call
        """
        if not history or len(history) == 0:
            return None  # No history, no blocking

        # Track indices of assistant messages with <document> tags
        document_indices: list[int] = []

        for idx, msg in enumerate(history):
            content = msg.get("content", "")
            # Check for both raw <document> and escaped &lt;document&gt; (sanitized version)
            has_document_tag = ("<document>" in content) or (
                "&lt;document&gt;" in content
            )

            if msg.get("role") == "assistant" and has_document_tag:
                document_indices.append(idx)

        if not document_indices:
            return None  # No documents in history, no blocking

        # Check if the LAST document has been validated
        # (Users must validate sequentially, so we only check the most recent)
        last_doc_index = document_indices[-1]

        # Search for validation message in messages AFTER the last document
        for msg in history[last_doc_index + 1 :]:
            if msg.get(
                "role"
            ) == "user" and "He validado y guardado el documento" in msg.get(
                "content", ""
            ):
                return None  # Validation found, OK to proceed

        # No validation message found after last document
        blocking_message = (
            "⚠️ **Bloqueo de Seguridad Activado (RULE-06)**\n\n"
            "Detecté que generé un documento en un mensaje anterior, pero aún no has "
            "pulsado el botón verde **'Validar y Guardar'**.\n\n"
            "**Por favor:**\n"
            "1. Revisa el documento propuesto en el mensaje anterior\n"
            "2. Haz scroll hacia arriba si no lo ves\n"
            "3. Pulsa el botón verde '✅ Validar y Guardar'\n"
            "4. Una vez guardado, podrás continuar al siguiente paso\n\n"
            "Este bloqueo existe para mantener el orden del Master Workflow y evitar "
            "generar documentos sin validar los anteriores. 🚀"
        )

        logger.info(
            "🚨 RULE-06 BLOCKER TRIGGERED: Unvalidated document found at index %d",
            last_doc_index,
        )

        return blocking_message

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

        blocking_message = self._check_validation_blocker(request.history)
        if blocking_message is not None:
            logger.info("🚨 Validation blocker triggered, returning early")
            return ChatResponse(
                ai_response=blocking_message,
                template_used="VALIDATION_BLOCKED",
                sources=[],
                metadata={
                    "blocked": True,
                    "reason": "unvalidated_document",
                    "rule": "RULE-06",
                },
            )

        if sources:
            template_id = self.template_builder.select_template(request.project_id)
        else:
            template_id = "FALLBACK"
            logger.info(
                "🔄 Using FALLBACK template (RAG degraded)",
                extra={"template": "FALLBACK", "reason": "no_sources_available"},
            )

        prompt = self.template_builder.build_prompt(
            query=request.message,
            context=sources,
            template_id=template_id,
            history=request.history,
            user_name=request.user_name,
        )
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

            # ✅ HU-5.0 RULE-06: Check validation blocker BEFORE prompt construction
            blocking_message = self._check_validation_blocker(request.history)
            if blocking_message is not None:
                # Stream blocking message as single event + done (no LLM call)
                logger.info(
                    "🚨 Validation blocker triggered in streaming, yielding blocking message"
                )
                yield {
                    "type": "token",
                    "data": blocking_message,
                    "is_final": True,
                }
                yield {
                    "type": "done",
                    "data": {
                        "full_response": blocking_message,
                        "sources": [],
                        "metadata": {
                            "blocked": True,
                            "reason": "unvalidated_document",
                            "rule": "RULE-06",
                            "template_used": "VALIDATION_BLOCKED",
                        },
                    },
                }
                return  # Early exit, no LLM call

            # ✅ Phase 3: Prompt construction with history AND user_name (HU-5.0 RULE-09)
            prompt = self.template_builder.build_prompt(
                query=request.message,
                context=sources,
                template_id=template_id,
                history=request.history,  # ✅ NEW: Pass chat history
                user_name=request.user_name,  # ✅ HU-5.0: Personalization
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
