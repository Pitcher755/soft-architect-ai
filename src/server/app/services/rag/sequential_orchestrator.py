"""Sequential Orchestrator Service.

Optimized for Detail, Density, and Routing. Handles the sequential generation
of architecture documents, injecting dynamic context and maintaining memory efficiency.

Task 8 - Context Injection:
    The orchestrator now accepts ``project_context`` inside the ``context`` dict.
    This is a ``dict[str, str]`` mapping relative file paths to their content
    (e.g. ``{"context/10-BUSINESS/MANIFEST.md": "# Project Manifest\n..."}``).
    These documents are injected into the LLM prompt inside a
    ``<project_documents>`` XML block, placed between the RAG context and the
    critical rules. This ensures the LLM generates each new document consistent
    with everything already produced for the project, eliminating the amnesia
    problem observed from document 4 onwards.
"""

import logging
from collections.abc import AsyncGenerator
from typing import Any

from app.core.exceptions import LLMError
from app.services.rag.template_loader import TemplateLoader
from app.services.rag.workflow_injector import WorkflowInjector

# Maximum characters per individual document included in the context block.
# Prevents a single large file from saturating the LLM context window.
_MAX_DOC_CHARS = 3_000

# Maximum total characters for the entire project_documents block.
# Keeps the prompt within a safe budget (approx. 10 k tokens).
_MAX_TOTAL_CONTEXT_CHARS = 12_000

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

            prompt = self._build_prompt(
                injection_block, user_input, rag_context, context, doc_type
            )

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

    def _build_project_documents_block(self, project_context: dict[str, str]) -> str:
        """Serialize the project context map into a prompt-safe XML block.

        Each file is wrapped with a path separator so the LLM can reference
        individual documents by name.  Large documents are truncated to
        ``_MAX_DOC_CHARS`` characters. The whole block is capped at
        ``_MAX_TOTAL_CONTEXT_CHARS`` characters to avoid context-window overflow.

        Args:
            project_context: Mapping of relative file paths to file content.

        Returns:
            An XML-tagged string ready to be spliced into the LLM prompt,
            or an empty string when ``project_context`` is empty.
        """
        if not project_context:
            return ""

        doc_lines: list[str] = []
        total_chars = 0

        for path, content in project_context.items():
            if total_chars >= _MAX_TOTAL_CONTEXT_CHARS:
                logger.debug(
                    "project_context budget exhausted after %d chars – "
                    "remaining files omitted.",
                    total_chars,
                )
                break

            # Truncate individual documents that are too large.
            if len(content) > _MAX_DOC_CHARS:
                content = content[:_MAX_DOC_CHARS] + "\n... [truncated]"

            entry = f"--- {path} ---\n{content}"
            doc_lines.append(entry)
            total_chars += len(entry)

        if not doc_lines:
            return ""

        joined = "\n\n".join(doc_lines)
        return (
            "<project_documents>\n"
            "The following documents have ALREADY been generated for this specific "
            "project. Your new document MUST be fully consistent with them: "
            "same project name, same tech stack, same domain vocabulary, "
            "same language (Spanish/English) and the same overall vision.\n\n"
            f"{joined}\n"
            "</project_documents>"
        )

    def _build_prompt(
        self,
        injection_block: str,
        user_input: str,
        rag_context: str,
        context: dict[str, Any],
        doc_type: str,
    ) -> str:
        """Construct the final deterministic prompt using XML tags for isolation.

        Prompt structure (ordered to maximise LLM accuracy):

        1. Workflow injection block  – template + example for the target doc type.
        2. RAG context               – relevant knowledge-base chunks.
        3. project_documents         – all docs already generated for this project
                                       (Task 8: prevents LLM amnesia).
        4. Critical rules            – strict output format instructions.
        5. Conversation history      – last 4 messages (truncated).
        6. User input                – the current user request.

        Args:
            injection_block: Pre-rendered template/example block from WorkflowInjector.
            user_input: Raw (sanitized) user message.
            rag_context: Retrieved knowledge-base text wrapped in XML tags.
            context: Runtime context dict provided by the API endpoint.
                Expected keys:
                    - ``chat_history``     – list[dict[str, str]]
                    - ``project_context``  – dict[str, str]  (Task 8)
            doc_type: Identifier of the document being generated.

        Returns:
            The fully assembled prompt string.
        """
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
                    "**Path:**" in content
                    or "Path:" in content
                    or "[document]" in content
                ):
                    content = (
                        "[Previous document generated and saved successfully."
                        " Omitted from memory to save context]"
                    )
                elif len(content) > 1000:
                    content = content[:1000] + "... [text truncated]"

                history_lines.append(f"{role.capitalize()}: {content}")

            history_text = "\n".join(history_lines)

        # ── Task 8: build the project_documents block ────────────────────────
        raw_project_context = context.get("project_context", {})
        project_docs_block = self._build_project_documents_block(
            raw_project_context if isinstance(raw_project_context, dict) else {}
        )
        if project_docs_block:
            logger.debug(
                "Injecting project_context: %d files into prompt.",
                len(raw_project_context),
            )
        # ─────────────────────────────────────────────────────────────────────

        critical_rules = (
            "\n\n<critical_rules>\n"
            f"1. YOUR ONLY TASK is to output the final, populated [{doc_type}]"
            " document for the user's project.\n"
            "2. NEVER output the `<template>` or `<example>` blocks in your"
            " response. They are just reference material for you.\n"
            "3. Start your response EXACTLY with this line:"
            " **Path:** context/YOUR_PATH_HERE\n"
            "4. Immediately after the Path line, output the raw markdown"
            " content of the generated document.\n"
            "5. Replace all {{PLACEHOLDERS}} with specific, realistic data"
            " based on the user's project idea.\n"
            "6. You MUST respond in the same language the user is speaking"
            " (e.g., if the user speaks Spanish, translate all headers and"
            " content to Spanish).\n"
            "7. DO NOT wrap your entire response in ```markdown tags."
            " Just output the text directly.\n"
            "8. CRITICAL: If a <project_documents> block is present, your"
            " document MUST be 100%% consistent with those existing documents."
            " Use the exact same project name, technology stack, domain terms"
            " and writing language as shown there.\n"
            "</critical_rules>\n"
        )

        sections: list[str] = []
        if injection_block:
            sections.append(injection_block)

        if rag_context:
            sections.append(rag_context)

        # Inject project documents BEFORE critical rules so the LLM reads the
        # existing work before receiving output formatting instructions.
        if project_docs_block:
            sections.append(project_docs_block)

        sections.append(critical_rules)

        if history_text:
            sections.append(
                f"<conversation_history>\n{history_text}\n</conversation_history>"
            )

        sections.append(f"<user_input>\n{user_input}\n</user_input>")

        return "\n\n".join(sections)
