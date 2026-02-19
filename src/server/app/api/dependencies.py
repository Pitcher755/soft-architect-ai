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
    Production-ready template builder for MVP with strict instruction adherence.
    Designed to prevent hallucinations in small models (3B-8B params).
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
        Build LLM prompt with strict constraints to prevent hallucinations.

        STRATEGY:
        1. Define the Persona (SoftArchitect).
        2. Define the Negative Constraints (What NOT to do).
        3. Inject the RAG Context as the "Source of Truth".
        4. Append the User Query.
        """

        # ✅ 1. SYSTEM INSTRUCTION (STRICT AND ANTI-HALLUCINATION)
        system_instruction = (
            "SYSTEM: You are SoftArchitect AI, the Senior Software Architect for this project. "
            "Your job is to convert ideas into engineering documents, NOT hallucinate or invent.\n\n"
            "GOLDEN RULES (CRITICAL):\n"
            "1. TECHNOLOGICAL FIDELITY: If the user defines a stack (e.g., 'Flutter + Firebase'), use it. "
            "NEVER invent technologies that weren't requested.\n"
            "2. TEMPLATE DICTATE: Your context (RAG) contains master templates (files .template.md). "
            "When you generate a document, you MUST COPY its EXACT STRUCTURE.\n"
            "3. MASTER WORKFLOW IS IMMUTABLE: The project ONLY has these phases: Governance, Specification, Architecture, Planning.\n"
            "4. NO CODE: Do not generate source code until Phase 4.\n\n"
            "RESPONSE MODE:\n"
            "- Professional, directive, and concise tone.\n"
            "- Always ask for validation at the end.\n"
        )

        # ✅ 2. HISTORY FORMATTING
        history_section = ""
        if history and len(history) > 0:
            history_section = "\n\nConversation History:\n"
            for msg in history[-5:]:  # Limit history to keep focus strict
                role_raw = msg["role"]
                content = msg["content"]
                role_prefix = "User:" if role_raw == "user" else "Assistant:"
                history_section += f"{role_prefix} {content}\n"

        # ✅ 3. RAG CONTEXT (THE SOURCE OF TRUTH)
        context_section = ""
        if template_id == "FALLBACK" or not context:
            context_section = (
                "\n\nNo specific project context available. "
                "Use your best judgment but follow the golden rules."
            )
        else:
            # Join context specifically labeled as TEMPLATES/REFERENCE
            context_str = "\n\n".join(context)
            context_section = (
                "\n\nProject Knowledge Base Context:\n"
                "Use this information to structure your response. "
                "If you see text that looks like a template (e.g., contains {{variables}}), use it as a skeleton.\n"
                f"{context_str}"
            )

        # ✅ 4. USER QUERY
        user_query_section = f"\n\nCurrent User Query:\n{query}"

        # ✅ 5. ASSEMBLE (System Prompt FIRST implies higher priority)
        final_prompt = (
            system_instruction
            + context_section  # Contexto antes del historial para priorizar reglas sobre charla previa
            + history_section
            + user_query_section
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
