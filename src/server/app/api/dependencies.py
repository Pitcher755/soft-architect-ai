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
    """Build and cache a fully-wired :class:`SequentialOrchestrator` instance.

    Called once per process lifetime by FastAPI's dependency-injection system
    (``Depends(get_rag_orchestrator)``).  All heavy objects – LLM client,
    VectorStoreService, WorkflowInjector, TemplateLoader, and ChromaProjectStore
    – are constructed here so that routers stay thin and stateless.

    The ``ChromaProjectStore`` import is deferred to function-body scope so that
    the gRPC / chromadb initialisation chain does **not** run at module-import
    time, which would otherwise break test-collection on machines without a
    running ChromaDB instance.

    Returns:
        A singleton :class:`SequentialOrchestrator` wired with all required
        adapters, ready to serve streaming generation requests.
    """
    raw_mode = os.getenv("LLM_PROVIDER", "ollama").lower()

    if raw_mode == "local":
        llm_mode = "ollama"
    elif raw_mode == "cloud":
        llm_mode = "groq"
    else:
        llm_mode = raw_mode

    llm_client = get_llm_client(mode=llm_mode)
    vector_store = cast(VectorStoreProtocol, VectorStoreService())
    workflow_injector = WorkflowInjector()
    template_loader = TemplateLoader()

    from app.infrastructure.vector_store.chroma_store import (
        ChromaProjectStore,  # noqa: PLC0415
    )

    project_store = ChromaProjectStore()

    return SequentialOrchestrator(
        vector_store=vector_store,
        llm_client=llm_client,
        template_loader=template_loader,
        workflow_injector=workflow_injector,
        project_store=project_store,
    )
