"""Shared dependencies for API endpoints (Production MVP)."""

import os
from functools import lru_cache
from typing import Annotated, cast

from fastapi import Header, HTTPException, status

from app.core.security import TokenValidator
from app.infrastructure.llm.factory import get_llm_client

# Sequential RAG components (Operation Rails architecture)
from app.services.rag.sequential_orchestrator import SequentialOrchestrator
from app.services.rag.template_loader import TemplateLoader
from app.services.rag.vector_store import VectorStoreService
from app.services.rag.vector_store_protocol import VectorStoreProtocol
from app.services.rag.workflow_injector import WorkflowInjector


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
def get_rag_orchestrator() -> SequentialOrchestrator:
    """Return a cached SequentialOrchestrator instance for dependency injection."""

    # 1. Get LLM mode from environment
    raw_mode = os.getenv("LLM_PROVIDER", "ollama").lower()

    # Normalize user-friendly config ('local') to technical config ('ollama')
    if raw_mode == "local":
        llm_mode = "ollama"
    elif raw_mode == "cloud":
        llm_mode = "groq"
    else:
        # Keep 'ollama' or 'groq' as-is
        llm_mode = raw_mode

    llm_client = get_llm_client(mode=llm_mode)

    # 2. Vector Store (used for supplementary context, not workflow control)
    vector_store = cast(VectorStoreProtocol, VectorStoreService())

    # 3. 🎯 EL NUEVO INYECTOR: Carga plantillas del disco duro de forma inquebrantable
    workflow_injector = WorkflowInjector()

    # 4. 🎯 EL NUEVO CEREBRO: Orquestador Secuencial con WorkflowInjector cableado
    template_loader = TemplateLoader()
    return SequentialOrchestrator(
        vector_store=vector_store,
        llm_client=llm_client,
        template_loader=template_loader,
        workflow_injector=workflow_injector,
    )
