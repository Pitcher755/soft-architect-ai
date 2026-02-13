"""RAG Orchestrator - Core business logic for chat endpoint."""

import logging

from app.core.exceptions import LLMConnectionError, RAGRetrievalError
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
        """Process a chat message through the RAG pipeline."""
        try:
            sources = await self.vector_store.search(request.message, top_k=5)
        except Exception as error:
            logger.error("Vector search failed: %s", error)
            raise RAGRetrievalError(
                message="Knowledge base search failed",
                details={"error": str(error)},
            ) from error

        if sources:
            template_id = self.template_builder.select_template(request.project_id)
        else:
            template_id = "FALLBACK"
            logger.warning("No vector results - using fallback template")

        prompt = self.template_builder.build_prompt(
            query=request.message,
            context=sources,
            template_id=template_id,
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
