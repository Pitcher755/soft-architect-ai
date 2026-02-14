"""Shared dependencies for API endpoints."""

import os
from functools import lru_cache
from uuid import UUID

from fastapi import HTTPException, status

from app.core.security import TokenValidator
from app.infrastructure.llm.factory import get_llm_client
from app.services.rag.orchestrator import RAGOrchestrator
from app.services.rag.template_builder_protocol import TemplateBuilderProtocol
from app.services.rag.vector_store_protocol import VectorStoreProtocol


async def verify_api_key(x_api_key: str | None = None) -> str:
    """
    Verify API key from request header.

    Args:
        x_api_key: API key from X-API-Key header

    Returns:
        Verified API key

    Raises:
        HTTPException: If API key is invalid or missing
    """
    if not x_api_key or not TokenValidator.validate_api_key(x_api_key):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or missing API key",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return x_api_key


class StubVectorStore(VectorStoreProtocol):
    """Stub vector store dependency for HU-4.1 phase 4."""

    async def search(self, query: str, top_k: int = 5) -> list[str]:
        _ = (query, top_k)
        return ["Stub context 1", "Stub context 2"]


class StubTemplateBuilder(TemplateBuilderProtocol):
    """Stub template builder dependency for HU-4.1 phase 4."""

    def select_template(self, project_id: UUID) -> str:
        _ = project_id
        return "10-CONTEXT"

    def build_prompt(
        self,
        query: str,
        context: list[str],
        template_id: str,
    ) -> str:
        _ = template_id
        context_str = "\n".join(context) if context else "No context available"
        return (
            "System: You are a helpful AI assistant.\n\n"
            f"Context:\n{context_str}\n\n"
            f"User: {query}"
        )


@lru_cache
def get_rag_orchestrator() -> RAGOrchestrator:
    """Return a cached RAGOrchestrator instance for dependency injection."""
    llm_mode = os.getenv("LLM_PROVIDER", "groq")
    llm_client = get_llm_client(mode=llm_mode)
    vector_store = StubVectorStore()
    template_builder = StubTemplateBuilder()

    return RAGOrchestrator(
        vector_store=vector_store,
        template_builder=template_builder,
        llm_client=llm_client,
    )
