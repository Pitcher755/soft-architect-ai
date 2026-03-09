"""Sequential Orchestrator Service.

Optimized for Detail, Density, and Routing. Handles the sequential generation 
of architecture documents, injecting dynamic context and maintaining memory efficiency.
"""

import logging
from collections.abc import AsyncGenerator
from typing import Any

from app.core.exceptions import LLMError
from app.services.rag.template_loader import TemplateLoader
from app.services.rag.workflow_injector import WorkflowInjector

logger = logging.getLogger(__name__)


class SequentialOrchestrator:
    """Orchestrates the LLM generation process for workflow documents."""

    def __init__(
        self,
        vector_store: Any,
        llm_client: Any,
        template_loader: TemplateLoader | None = None,
        workflow_injector: WorkflowInjector | None = None,
    ):
        """Initialize the orchestrator with required external services."""
        self.vector_store = vector_store
        self.llm_client = llm_client
        self.template_loader = template_loader or TemplateLoader()
        self.workflow_injector = workflow_injector or WorkflowInjector()

    async def generate(
        self, doc_type: str, user_input: str, context: dict[str, Any]
    ) -> AsyncGenerator[str, None]:
        """Generate a document sequentially based on workflow rules."""
        try:
            injection_block = self.workflow_injector.get_injected_prompt(doc_type)
            if not injection_block:
                logger.warning(
                    "WorkflowInjector returned empty block for '%s'. Falling back to RAG context only.",
                    doc_type,
                )

            rag_context = await self._retrieve_user_context(user_input)

            prompt = self._build_prompt(injection_block, user_input, rag_context, context, doc_type)

            # Stream tokens from LLM (history already injected in prompt)
            async for token in self.llm_client.stream_generate(prompt, history=[]):
                yield token

        except Exception as e:
            logger.error("Error in sequential generation: %s", e)
            raise LLMError(code="SEQ_GEN_ERR", message=str(e)) from e

    async def _retrieve_user_context(self, query: str) -> str:
        """Retrieve pure technical context from the vector store."""
        try:
            user_results = self.vector_store.query(query_text=query, n_results=3)
            user_docs = self._extract_docs_text(user_results)

            if user_docs:
                return f"<rag_context>\n{user_docs}\n</rag_context>"

            return ""
        except Exception as e:
            logger.error("Error in sequential RAG retrieval: %s", e)
            return ""

    def _extract_docs_text(self, results: dict[str, Any]) -> str:
        """Extract and flatten text content from vector store results."""
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
        """Construct the final deterministic prompt using XML tags for isolation."""
        user_name = context.get("user_name", "Developer")
        raw_history = context.get("chat_history", [])

        # Memory optimization: filter history to avoid context window saturation
        history_text = ""
        if isinstance(raw_history, list) and len(raw_history) > 0:
            history_lines = []

            # Keep only the last 4 messages to avoid memory overflow
            for msg in raw_history[-4:]:
                role = msg.get("role", "user")
                content = msg.get("content", "")

                # Truncate oversized assistant documents to save tokens
                if role == "assistant" and (
                    "**Path:**" in content or "Path:" in content or "[document]" in content
                ):
                    content = "[Previous document generated and saved successfully. Omitted from memory to save context]"
                elif len(content) > 1000:
                    content = content[:1000] + "... [text truncated]"

                history_lines.append(f"{role.capitalize()}: {content}")

            history_text = "\n".join(history_lines)

        critical_rules = (
            "\n\n<critical_rules>\n"
            f"1. GENERATE ONLY THE FINAL DOCUMENT [{doc_type}] for user {user_name}.\n"
            "2. DO NOT output `<template>`, `<example>`, or ```markdown blocks wrapping the whole response.\n"
            "3. Start your response EXACTLY with this line: **Path:** context/YOUR_PATH_HERE\n"
            "4. Immediately after the Path line, output the raw markdown content.\n"
            "5. Replace all {{PLACEHOLDERS}} with project data.\n"
            "6. Respond in the same language the user is speaking.\n"
            "</critical_rules>\n"
        )

        sections = []
        if injection_block:
            sections.append(injection_block)

        if rag_context:
            sections.append(rag_context)

        sections.append(critical_rules)

        if history_text:
            sections.append(f"<conversation_history>\n{history_text}\n</conversation_history>")

        sections.append(f"<user_input>\n{user_input}\n</user_input>")

        return "\n\n".join(sections)
