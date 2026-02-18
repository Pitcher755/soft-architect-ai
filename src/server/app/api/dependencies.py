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
    Production-ready template builder for MVP with chat history support.

    Features:
    - In-memory prompt templates (Docker-friendly)
    - Context-aware prompt construction
    - Chat history formatting for LLM continuity
    - Graceful degradation (works with/without history)
    """

    def select_template(self, project_id: UUID) -> str:
        return "CONTEXT_DRIVEN"

    def build_prompt(
        self,
        query: str,
        context: list[str],
        template_id: str,
        history: list[dict[str, str]] | None = None,
    ) -> str:
        """
        Build LLM prompt with RAG context and chat history.

        Prompt structure:
        1. System instruction
        2. Chat history (if provided)
        3. RAG context (if available)
        4. Current user query

        Args:
            query: Current user message
            context: RAG-retrieved knowledge base snippets
            template_id: Template identifier (FALLBACK, CONTEXT_DRIVEN)
            history: Chat history (list of {"role": str, "content": str})

        Returns:
            Complete formatted prompt for LLM
        """
        # ✅ STEP 1: System Instruction
        system_instruction = (
            "System: Eres SoftArchitect AI, un asistente experto en "
            "arquitectura de software. "
            "Responde de forma clara, directa y profesional. "
            "Utiliza el contexto del proyecto cuando esté disponible."
        )

        # ✅ STEP 2: Format Chat History (if provided)
        history_section = ""
        if history and len(history) > 0:
            history_section = "\n\nConversation History:\n"
            for msg in history:
                role = msg["role"].capitalize()
                content = msg["content"]
                history_section += f"{role}: {content}\n"

        # ✅ STEP 3: Format RAG Context (if available)
        context_section = ""
        if template_id == "FALLBACK" or not context:
            # No context available - use general knowledge
            context_section = (
                "\n\nNote: No specific project context available for this query. "
                "Responding with general software architecture knowledge."
            )
        else:
            # RAG context available
            context_str = "\n".join(context)
            context_section = f"\n\nProject Knowledge Base Context:\n{context_str}\n"

        # ✅ STEP 4: Current User Query
        user_query_section = f"\n\nCurrent User Query:\n{query}"

        # ✅ STEP 5: Assemble Final Prompt
        final_prompt = (
            system_instruction + history_section + context_section + user_query_section
        )

        return final_prompt


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
