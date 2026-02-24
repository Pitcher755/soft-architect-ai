"""Sequential Orchestrator - Optimized for Detail and Aesthetics."""

import logging
from collections.abc import AsyncGenerator
from typing import Any

from app.core.exceptions import LLMError
from app.services.rag.template_loader import TemplateLoader

logger = logging.getLogger(__name__)


class SequentialOrchestrator:
    def __init__(
        self,
        vector_store: Any,
        llm_client: Any,
        template_loader: TemplateLoader | None = None,
    ):
        self.vector_store = vector_store
        self.llm_client = llm_client
        self.template_loader = template_loader or TemplateLoader()

    async def generate(
        self, doc_type: str, user_input: str, context: dict[str, Any]
    ) -> AsyncGenerator[str, None]:
        try:
            template = self.template_loader.load(doc_type)
            # Recuperamos el contexto dual (ejemplo maestro + info usuario)
            rag_context = await self._retrieve_context(user_input, doc_type)

            # Construimos el prompt inyectando la orden de 'estética senior'
            prompt = self._build_prompt(template, user_input, rag_context, context)

            token_stream = await self.llm_client.stream_generate(
                prompt, history=context.get("history", [])
            )
            async for token in token_stream:
                yield token
        except Exception as e:
            logger.error(f"Error en generación secuencial: {e}")
            raise LLMError(code="SEQ_GEN_ERR", message=str(e)) from e

    async def _retrieve_context(self, query: str, doc_type: str) -> str:
        """Recuperación doble: prioriza el ejemplo MD entero."""
        master_query = f"Complete Markdown Master Example for {doc_type} with rich tables and emoji"

        try:
            user_results = self.vector_store.query(query_texts=[query], n_results=3)
            master_results = self.vector_store.query(
                query_texts=[master_query], n_results=2
            )

            user_docs = self._extract_docs_text(user_results)
            master_docs = self._extract_docs_text(master_results)

            sections = []
            if master_docs:
                sections.append(
                    f"=== MASTER TEMPLATE EXAMPLE (MANDATORY STYLE GUIDE) ===\n{master_docs}"
                )
            if user_docs:
                sections.append(f"=== USER PROJECT CONTEXT ===\n{user_docs}")

            return "\n\n".join(sections)
        except Exception as e:
            logger.error(f"Error en RAG secuencial: {e}")
            return ""

    def _extract_docs_text(self, results: dict[str, Any]) -> str:
        if not results or "documents" not in results or not results["documents"]:
            return ""
        flat = []
        for group in results["documents"]:
            if isinstance(group, list):
                flat.extend(group)
            else:
                flat.append(group)
        return "\n\n".join(doc for doc in flat if doc)

    def _build_prompt(
        self, template: Any, user_input: str, rag_context: str, context: dict[str, Any]
    ) -> str:
        history = context.get("chat_history", "")

        # El truco final: Añadimos un recordatorio de excelencia visual al final del prompt
        extra_instruction = (
            "\n\n⚡ RECUERDA ARQUITECTO: Debes imitar el estilo visual, el uso intensivo de iconos y la "
            "profundidad técnica del EJEMPLO MAESTRO proporcionado. Crea tablas y usa Markdown avanzado."
        )

        return template.content.format(
            context=rag_context + extra_instruction,
            user_input=user_input,
            chat_history=history,
        )
