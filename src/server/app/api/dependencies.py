"""Shared dependencies for API endpoints (Production MVP)."""

import os
from functools import lru_cache
from typing import Annotated, cast

from fastapi import Header, HTTPException, status

from app.core.security import TokenValidator
from app.infrastructure.llm.factory import get_llm_client
from app.services.rag.orchestrator import RAGOrchestrator
from app.services.rag.template_builder import MVPTemplateBuilder
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


@lru_cache
def get_rag_orchestrator() -> RAGOrchestrator:
    """Return a cached RAGOrchestrator instance for dependency injection."""

    # 1. Obtener modo del .env
    raw_mode = os.getenv("LLM_PROVIDER", "ollama").lower()

    # TRADUCTOR: Convertir config de usuario ('local') a config técnica ('ollama')
    if raw_mode == "local":
        llm_mode = "ollama"
    elif raw_mode == "cloud":
        llm_mode = "groq"
    else:
        # Si ya pone "ollama" o "groq", lo dejamos tal cual
        llm_mode = raw_mode

    # Ahora sí, la factory recibirá "ollama" y funcionará
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
