"""Shared dependencies for API endpoints (Production MVP)."""

import os
from functools import lru_cache
from typing import Annotated, cast
from uuid import UUID

from fastapi import Header, HTTPException, status

from app.core.security import TokenValidator
from app.infrastructure.llm.factory import get_llm_client
from app.services.rag.orchestrator import RAGOrchestrator
from app.services.rag.template_builder_protocol import TemplateBuilderProtocol
from app.services.rag.vector_store import VectorStoreService
from app.services.rag.vector_store_protocol import VectorStoreProtocol


async def verify_api_key(x_api_key: Annotated[str | None, Header()] = None) -> str:
    """Verify API key from request header."""
    if not x_api_key or not TokenValidator.validate_api_key(x_api_key):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or missing API key",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return x_api_key


class MVPTemplateBuilder(TemplateBuilderProtocol):
    """
    Production-ready template builder for MVP.
    Stores prompts in-memory to prevent Docker filesystem errors.
    """

    def select_template(self, project_id: UUID) -> str:
        return "CONTEXT_DRIVEN"

    def build_prompt(self, query: str, context: list[str], template_id: str) -> str:
        if template_id == "FALLBACK" or not context:
            return (
                "System: Eres SoftArchitect AI, un asistente experto en arquitectura de software. "
                "Responde a la pregunta del usuario de forma clara y directa.\n\n"
                f"User: {query}"
            )

        context_str = "\n".join(context)
        return (
            "System: Eres SoftArchitect AI. Utiliza el siguiente contexto del proyecto "
            "para responder a la pregunta del usuario.\n\n"
            f"Contexto del Proyecto:\n{context_str}\n\n"
            f"User: {query}"
        )


@lru_cache
def get_rag_orchestrator() -> RAGOrchestrator:
    """Return a cached RAGOrchestrator instance for dependency injection."""

    # 1. Obtener cliente LLM (Ahora leerá el .env correctamente)
    llm_mode = os.getenv("LLM_PROVIDER", "ollama").lower()
    llm_client = get_llm_client(mode=llm_mode)

    # 2. Base de Datos Vectorial
    vector_store = cast(VectorStoreProtocol, VectorStoreService())

    # 3. Gestor de Prompts robusto (en memoria)
    template_builder = MVPTemplateBuilder()

    return RAGOrchestrator(
        vector_store=vector_store,
        template_builder=template_builder,
        llm_client=llm_client,
    )
