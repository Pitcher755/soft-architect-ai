"""Sequential Orchestrator - Optimized for Detail, Density, and Routing."""

import logging
from collections.abc import AsyncGenerator
from typing import Any

from app.core.exceptions import LLMError
from app.services.rag.template_loader import TemplateLoader
from app.services.rag.workflow_injector import WorkflowInjector

logger = logging.getLogger(__name__)


class SequentialOrchestrator:
    def __init__(
        self,
        vector_store: Any,
        llm_client: Any,
        template_loader: TemplateLoader | None = None,
        workflow_injector: WorkflowInjector | None = None,
    ):
        self.vector_store = vector_store
        self.llm_client = llm_client
        self.template_loader = template_loader or TemplateLoader()
        self.workflow_injector = workflow_injector or WorkflowInjector()

    async def generate(
        self, doc_type: str, user_input: str, context: dict[str, Any]
    ) -> AsyncGenerator[str, None]:
        try:
            # Use WorkflowInjector to get the full template + example injection block
            injection_block = self.workflow_injector.get_injected_prompt(doc_type)
            if not injection_block:
                logger.warning(
                    "WorkflowInjector returned empty block for '%s'. Falling back to RAG context only.",
                    doc_type,
                )

            # Retrieve supplementary RAG context (vector search)
            rag_context = await self._retrieve_context(user_input, doc_type)

            # Build the final deterministic prompt
            prompt = self._build_prompt(
                injection_block, user_input, rag_context, context, doc_type
            )

            # Stream tokens from LLM (history already injected in prompt)
            async for token in self.llm_client.stream_generate(prompt, history=[]):
                yield token
        except Exception as e:
            logger.error("Error in sequential generation: %s", e)
            raise LLMError(code="SEQ_GEN_ERR", message=str(e)) from e

    async def _retrieve_context(self, query: str, doc_type: str) -> str:
        """Dual retrieval: prioritize dense MD examples."""
        master_query = (
            f"Complete detailed Markdown Master Example for {doc_type} "
            f"filled with realistic technical data, deep architectural context, and zero placeholders"
        )

        try:
            user_results = self.vector_store.query(query_text=query, n_results=3)
            master_results = self.vector_store.query(
                query_text=master_query, n_results=2
            )

            user_docs = self._extract_docs_text(user_results)
            master_docs = self._extract_docs_text(master_results)

            sections = []
            if master_docs:
                sections.append(
                    f"=== MASTER TEMPLATE EXAMPLE (MANDATORY STYLE AND DENSITY GUIDE) ===\n{master_docs}"
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
        self,
        injection_block: str,
        user_input: str,
        rag_context: str,
        context: dict[str, Any],
        doc_type: str,
    ) -> str:
        user_name = context.get("user_name", "Developer")
        raw_history = context.get("chat_history", [])

        # Memory optimization: filter history to avoid Error 413 from oversized payloads
        history_text = ""
        if isinstance(raw_history, list) and len(raw_history) > 0:
            history_lines = []
            # Keep only last 4 messages to avoid memory saturation
            for msg in raw_history[-4:]:
                role = msg.get("role", "user")
                content = msg.get("content", "")

                # Truncate oversized assistant documents
                if role == "assistant" and (
                    "**Path:**" in content
                    or "Path:" in content
                    or "[document]" in content
                ):
                    content = "[Previous document generated and saved successfully. Omitted from memory to save context]"
                elif len(content) > 1000:
                    content = content[:1000] + "... [text truncated]"

                history_lines.append(f"{role.capitalize()}: {content}")

            history_text = "\n".join(history_lines)

        strict_rules = (
            f"\n\n⚡ REGLAS ESTRICTAS DE GENERACIÓN (OBLIGADO CUMPLIMIENTO) ⚡\n"
            f"1. Eres SoftArchitect, Arquitecto de Software experto. NO eres un chatbot conversacional.\n"
            f"2. TU ÚNICA TAREA: generar el documento [{doc_type}] para el proyecto de {user_name}.\n"
            f"3. USA la plantilla del bloque MANDATORY STRUCTURE como esqueleto exacto.\n"
            f"4. USA el ejemplo del bloque MASTER EXAMPLE para clonar su densidad técnica y formato.\n"
            f"5. Sustituye TODOS los {{{{PLACEHOLDERS}}}} con datos reales del proyecto del usuario.\n"
            f"6. CERO CONVERSACIÓN: No saludes, no pongas intro, no te despidas. Empieza DIRECTAMENTE con **Path:**.\n"
            f"7. Elimina los bloques de comentarios HTML del template () del output final.\n"
            f"8. TRADUCCIÓN OBLIGATORIA: Traduce TODOS los títulos (##) y textos de la plantilla al idioma en el que te ha escrito el usuario. NUNCA dejes títulos en inglés si el usuario habla en otro idioma.\n"
        )

        sections = []
        if injection_block:
            sections.append(injection_block)
        if rag_context:
            sections.append(
                f"=== ADDITIONAL PROJECT CONTEXT (FROM KNOWLEDGE BASE) ===\n{rag_context}"
            )
        sections.append(strict_rules)

        if history_text:
            sections.append(f"=== RECENT CONVERSATION HISTORY ===\n{history_text}")

        sections.append(
            f"=== USER INPUT (PROJECT DESCRIPTION / CURRENT ACTION) ===\n{user_input}"
        )

        return "\n\n".join(sections)
