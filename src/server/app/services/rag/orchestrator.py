"""RAG Orchestrator - Business logic with Deterministic Workflow Enforcement."""

import asyncio
import logging
from collections.abc import AsyncGenerator
from typing import Any

from app.core.exceptions import LLMConnectionError
from app.domain.schemas.chat_schema import ChatRequest, ChatResponse
from app.infrastructure.llm.base import BaseLLMClient
from app.services.rag.template_builder_protocol import TemplateBuilderProtocol
from app.services.rag.vector_store_protocol import VectorStoreProtocol
from app.services.rag.workflow_injector import WorkflowInjector  # 👈 NUEVA IMPORTACIÓN

logger = logging.getLogger(__name__)


class RAGOrchestrator:
    def __init__(
        self,
        vector_store: VectorStoreProtocol,
        template_builder: TemplateBuilderProtocol,
        llm_client: BaseLLMClient,
    ) -> None:
        self.vector_store = vector_store
        self.template_builder = template_builder
        self.llm_client = llm_client
        self.workflow_injector = WorkflowInjector()  # 👈 NUEVO: Instanciamos el Inyector

    def _check_validation_blocker(
        self, user_message: str, history: list[dict[str, str]]
    ) -> str | None:
        """Bloqueo Amistoso: Permite iterar, pero ordena el workflow."""
        if not history:
            return None

        # 1. ¿El usuario quiere mejorar o descartar? Saltamos bloqueo.
        intent = user_message.lower()
        keywords = [
            "refinar",
            "ajustar",
            "cambia",
            "mejora",
            "amplía",
            "rechazar",
            "descartar",
            "no me gusta",
            "corrige",
        ]
        if any(word in intent for word in keywords):
            return None

        # 2. ¿Hay un documento pendiente de validar?
        last_doc_msg = None
        for msg in reversed(history):
            if msg.get("role") == "assistant" and "<document>" in msg.get("content", ""):
                last_doc_msg = msg
                break

        if not last_doc_msg:
            return None

        # 3. ¿El usuario ha validado desde entonces?
        idx = history.index(last_doc_msg)
        validated = any(
            "He validado y guardado" in m.get("content", "")
            for m in history[idx + 1 :]
            if m.get("role") == "user"
        )

        if not validated:
            return (
                "¡Hola! 👋 He visto que tenemos una propuesta técnica pendiente un poco más arriba.\n\n"
                "Para que el proyecto avance con pies de plomo, es importante cerrar este paso antes de saltar al siguiente:\n\n"
                "- Si la propuesta es buena, dale al botón verde de **'Validar y Guardar'**.\n"
                "- Si crees que le falta algo, pulsa **'Refinar'** y dime qué mejoramos.\n"
                "- Si no te convence el enfoque, pulsa **'Rechazar'** y probamos otra cosa.\n\n"
                "¡Por cierto! Si más adelante quieres retocar el contenido, siempre podrás hacerlo manualmente en el visor de archivos a tu derecha. 🚀"
            )
        return None

    async def _retrieve_dual_context(self, message: str, doc_type: str) -> list[str]:
        """Retrieve context via hybrid RAG: deterministic disk injection + probabilistic ChromaDB.

        The deterministic layer reads physical template and example files for the
        given doc_type (guaranteed structure). The probabilistic layer queries ChromaDB
        for the user's prior project ideas (optional enrichment, degrades gracefully).
        """
        combined = []

        # 1. Deterministic disk injection (template + example from MASTER_WORKFLOW)
        hardcoded_prompt = self.workflow_injector.get_injected_prompt(doc_type)
        if hardcoded_prompt:
            combined.append(hardcoded_prompt)
        else:
            logger.warning("No injection available for %s; LLM will receive no template.", doc_type)

        # 2. Probabilistic ChromaDB search for user's prior project context
        async def _safe_search(query: str, top_k: int) -> list[str]:
            try:
                return await asyncio.wait_for(
                    self.vector_store.search(query, top_k=top_k), timeout=8.0
                )
            except Exception as err:  # noqa: BLE001
                logger.warning("⚠️ RAG channel degraded: %s", str(err))
                return []

        user_results = await _safe_search(message, 3)
        if user_results:
            combined.append("=== USER PROJECT IDEAS (FROM CHROMADB) ===")
            combined.extend(user_results)

        return combined

    async def process_message(self, request: ChatRequest) -> ChatResponse:
        """Process a chat message (non-streaming) via dual-channel RAG."""
        current_doc_type = (request.metadata or {}).get("doc_type", "PROJECT_MANIFESTO")
        sources = await self._retrieve_dual_context(request.message, current_doc_type)
        template_id = "CONTEXT_DRIVEN" if sources else "FALLBACK"

        blocking_message = self._check_validation_blocker(request.message, request.history)
        if blocking_message is not None:
            return ChatResponse(
                ai_response=blocking_message,
                template_used="VALIDATION_BLOCKED",
                sources=[],
                metadata={
                    "blocked": "true",
                    "reason": "unvalidated_document",
                    "rule": "RULE-06",
                },
            )

        # Inyectamos el user_name de la request o caemos a "Developer"
        user_name = getattr(request, "user_name", "Developer")

        prompt = self.template_builder.build_prompt(
            query=request.message,
            context=sources,
            template_id=template_id,
            history=request.history,
            user_name=user_name,
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
        full_response = ""
        current_doc_type = (request.metadata or {}).get("doc_type", "PROJECT_MANIFESTO")

        try:
            blocking_msg = self._check_validation_blocker(request.message, request.history)
            if blocking_msg:
                yield {"type": "token", "data": blocking_msg, "is_final": True}
                yield {
                    "type": "done",
                    "data": {
                        "full_response": blocking_msg,
                        "sources": [],
                        "metadata": {"blocked": True},
                    },
                }
                return

            sources = await self._retrieve_dual_context(request.message, current_doc_type)

            # Inyectamos el user_name para el stream
            user_name = getattr(request, "user_name", "Developer")

            prompt = self.template_builder.build_prompt(
                query=request.message,
                context=sources,
                template_id="CONTEXT_DRIVEN",
                history=request.history,
                user_name=user_name,
            )

            try:
                async for token in self.llm_client.stream_generate(prompt, history=request.history):
                    full_response += token
                    yield {"type": "token", "data": token, "is_final": False}
            except Exception:
                yield {"type": "error", "data": {"error": "Error de conexión con Groq"}}
                return

            yield {
                "type": "done",
                "data": {
                    "full_response": full_response,
                    "sources": sources,
                    "metadata": {
                        "template_used": "CONTEXT_DRIVEN",
                        "doc_type": current_doc_type,
                    },
                },
            }

        except Exception as e:
            yield {"type": "error", "data": {"error": str(e)}}
