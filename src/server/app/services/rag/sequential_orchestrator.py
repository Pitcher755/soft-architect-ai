"""Sequential Orchestrator Service.

Optimized for Detail, Density, and Routing. Handles the sequential generation
of architecture documents, injecting dynamic context and maintaining memory efficiency.

Context Injection Strategy — Dynamic RAG (Task 7)
-------------------------------------------------
The orchestrator uses two complementary RAG retrieval paths:

1. **Global knowledge-base context** (``_retrieve_user_context``)
   Searches the ``softarchitect_kb`` collection for general software-
   engineering knowledge relevant to the user's input. Result is injected
   inside ``<rag_context>`` tags.

2. **Per-project dynamic context** (``_retrieve_project_context``)
   Searches the project-specific ChromaDB collection (managed by
   ``ChromaProjectStore``) using a semantic query::

       f"Context for {doc_type}: {user_input}"

   Returns the most relevant chunks as a ``<retrieved_context>`` block so
   the LLM is grounded in the actual documents ingested for this project.
   Requires ``project_id`` to be present in the ``context`` dict.

Prompt assembly order:
  1. Workflow injection block  – template + example for the target doc type.
  2. Global RAG context        – ``<rag_context>`` from the knowledge base.
  3. Per-project context       – ``<retrieved_context>`` from ChromaDB.
  4. Critical rules            – strict output format instructions.
  5. Conversation history      – last 4 messages (truncated).
  6. User input                – the current user request.

The ``_build_project_documents_block`` utility is retained for serialising
static document maps when needed (e.g. debugging or migration tooling).
"""

from __future__ import annotations

import logging
from collections.abc import AsyncGenerator
from typing import TYPE_CHECKING, Any

if TYPE_CHECKING:
    # Imported only for static type analysis.  Keeping this under TYPE_CHECKING
    # prevents the chromadb/gRPC chain from loading in test environments that
    # do not need a live ChromaDB connection.
    from app.infrastructure.vector_store.chroma_store import ChromaProjectStore

from app.core.exceptions import LLMError
from app.services.rag.template_loader import TemplateLoader
from app.services.rag.workflow_injector import WorkflowInjector

# Maximum characters per individual document included in the context block.
# Prevents a single large file from saturating the LLM context window.
_MAX_DOC_CHARS = 1_200

# Hard cap for the entire project_documents block when no adaptive budget
# is provided.  Keeps the prompt within a safe baseline budget.
_MAX_TOTAL_CONTEXT_CHARS = 4_800

# Hard ceiling for the full assembled prompt (chars ≈ tokens * 4).
# Gemini 1.5 Flash supports ~1 M tokens, but payloads >600 K chars
# consistently trigger 500 errors on the free / low-quota tier.
# 60 000 chars ≈ 15 000 tokens — well within any quota tier.
_MAX_PROMPT_CHARS = 200_000

logger = logging.getLogger(__name__)


class SequentialOrchestrator:
    """Orchestrates the LLM generation process for workflow documents."""

    def __init__(
        self,
        vector_store: Any,
        llm_client: Any,
        template_loader: TemplateLoader | None = None,
        workflow_injector: WorkflowInjector | None = None,
        project_store: ChromaProjectStore | None = None,
    ) -> None:
        """Initialise the orchestrator with required external services.

        Args:
            vector_store: Global knowledge-base vector store (VectorStoreProtocol).
            llm_client: LLM streaming client (must implement stream_generate).
            template_loader: Loader for prompt templates. Defaults to TemplateLoader().
            workflow_injector: Injector for workflow-step prompt blocks.
                               Defaults to WorkflowInjector().
            project_store: Per-project ChromaDB adapter for dynamic RAG retrieval.
                           Pass ``None`` (default) to disable project-context
                           injection (useful in tests or when ChromaDB is
                           unavailable).
        """
        self.vector_store = vector_store
        self.llm_client = llm_client
        self.template_loader = template_loader or TemplateLoader()
        self.workflow_injector = workflow_injector or WorkflowInjector()
        self.project_store = project_store

    async def generate(
        self, doc_type: str, user_input: str, context: dict[str, Any]
    ) -> AsyncGenerator[str, None]:
        """Generate a document sequentially based on workflow rules.

        Retrieves both global knowledge-base context and per-project
        dynamic context before assembling the final prompt.

        Args:
            doc_type: Identifier of the document type to generate
                      (e.g. ``"DOMAIN_LANGUAGE"``).
            user_input: Sanitised user message / project description.
            context: Runtime context dict. Expected keys:
                - ``project_id``   – str UUID of the current project
                                     (required for per-project RAG).
                - ``chat_history`` – list[dict[str, str]] (optional).

        Yields:
            Incremental token strings from the LLM.

        Raises:
            LLMError: On any unhandled error during generation.
        """
        try:
            injection_block = self.workflow_injector.get_injected_prompt(doc_type)
            if not injection_block:
                logger.warning(
                    "WorkflowInjector returned empty block for '%s'. Falling back to RAG context only.",
                    doc_type,
                )

            rag_context = await self._retrieve_user_context(user_input)

            project_id = str(context.get("project_id", ""))
            retrieved_context = self._retrieve_project_context(
                project_id, doc_type, user_input
            )

            prompt = self._build_prompt(
                injection_block,
                user_input,
                rag_context,
                context,
                doc_type,
                retrieved_context,
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

    def _retrieve_project_context(
        self, project_id: str, doc_type: str, user_input: str
    ) -> str:
        """Retrieve project-specific context via semantic search in ChromaDB.

        Replaces the former static ``_filter_relevant_context`` approach.
        Generates a semantic query and retrieves the most relevant ingested
        chunks from the per-project ChromaDB collection.

        The semantic query has the form::

            f"Context for {doc_type}: {user_input}"

        This anchors the embedding search to the document type being generated
        while incorporating the user's current intent.

        Args:
            project_id: UUID string of the project whose collection to search.
            doc_type: Document type being generated (e.g. ``"DOMAIN_LANGUAGE"``).
            user_input: Raw (sanitised) user message.

        Returns:
            XML-tagged string ``<retrieved_context>...</retrieved_context>``
            containing the top-k most relevant chunks joined by double newlines,
            or an empty string when:
            - ``project_store`` is not configured (``None``),
            - ``project_id`` is empty,
            - the collection contains no matching documents, or
            - the store raises an exception (logged as warning).
        """
        if not self.project_store or not project_id:
            return ""

        query = f"Context for {doc_type}: {user_input}"
        try:
            chunks = self.project_store.query_project(project_id, query, n_results=5)
            if not chunks:
                return ""
            joined = "\n\n".join(chunks)
            logger.info(
                "Retrieved %d project-context chunks for project=%s doc_type=%s.",
                len(chunks),
                project_id,
                doc_type,
            )
            return f"<retrieved_context>\n{joined}\n</retrieved_context>"
        except Exception as exc:
            logger.warning(
                "Failed to retrieve project context for project=%s: %s",
                project_id,
                exc,
            )
            return ""

    def _build_project_documents_block(
        self,
        project_context: dict[str, str],
        budget: int = _MAX_TOTAL_CONTEXT_CHARS,
    ) -> str:
        """Serialize the project context map into a prompt-safe XML block.

        Each file is wrapped with a path separator so the LLM can reference
        individual documents by name.  Large documents are truncated to
        ``_MAX_DOC_CHARS`` characters. The whole block is capped at
        ``budget`` characters to avoid context-window overflow.

        Args:
            project_context: Mapping of relative file paths to file content.
                budget: Maximum total characters allowed for the block.  Callers
                can pass an adaptive value derived from the remaining prompt
                budget.  Defaults to ``_MAX_TOTAL_CONTEXT_CHARS``.

        Returns:
            An XML-tagged string ready to be spliced into the LLM prompt,
            or an empty string when ``project_context`` is empty.
        """
        if not project_context or budget <= 0:
            return ""

        # XML envelope overhead so we account for it in the budget.
        envelope_overhead = 250
        effective_budget = max(0, budget - envelope_overhead)

        doc_lines: list[str] = []
        total_chars = 0

        for path, content in project_context.items():
            if total_chars >= effective_budget:
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
            # Avoid adding an entry that would exceed the remaining budget.
            if total_chars + len(entry) > effective_budget:
                remaining = effective_budget - total_chars
                if remaining > 60:  # only worth adding if meaningful content fits
                    entry = entry[:remaining] + "\n... [truncated]"
                    doc_lines.append(entry)
                break

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

    def _build_history_text(self, raw_history: Any) -> str:
        """Serialize chat history to a compact string for LLM injection.

        Keeps the last 4 messages to bound context size.  Large assistant
        responses (detected by Path: / **Path:** markers) are replaced by a
        short placeholder to avoid saturating the context window.

        Args:
            raw_history: Value of the ``chat_history`` key from the runtime
                context dict.  Expected to be ``list[dict[str, str]]``.

        Returns:
            A newline-joined string with ``Role: content`` entries, or an
            empty string when the history is absent or empty.
        """
        if not isinstance(raw_history, list) or not raw_history:
            return ""

        history_lines: list[str] = []
        for msg in raw_history[-4:]:
            role = msg.get("role", "user")
            content = msg.get("content", "")
            if role == "assistant" and any(
                marker in content for marker in ("**Path:**", "Path:", "[document]")
            ):
                content = (
                    "[Previous document generated and saved successfully."
                    " Omitted from memory to save context]"
                )
            elif len(content) > 1000:
                content = content[:1000] + "... [text truncated]"
            history_lines.append(f"{role.capitalize()}: {content}")

        return "\n".join(history_lines)

    def _build_prompt(
        self,
        injection_block: str,
        user_input: str,
        rag_context: str,
        context: dict[str, Any],
        doc_type: str,
        retrieved_context: str = "",
    ) -> str:
        """Construct the final deterministic prompt using XML tags for isolation.

        Prompt structure (ordered to maximise LLM accuracy):

        1. Workflow injection block  – template + example for the target doc type.
        2. Global RAG context        – relevant knowledge-base chunks from
                                       ``<rag_context>`` tags.
        3. Per-project context       – chunks retrieved via semantic search from
                                       the project's ChromaDB collection, wrapped
                                       in ``<retrieved_context>`` tags.
        4. Critical rules            – strict output format instructions.
        5. Conversation history      – last 4 messages (truncated).
        6. User input                – the current user request.

        The ``retrieved_context`` block replaces the former static
        ``_filter_relevant_context`` + ``_build_project_documents_block``
        pipeline.  It is built asynchronously in ``generate()`` via
        ``_retrieve_project_context()`` before this method is called.

        Args:
            injection_block: Pre-rendered template/example block from WorkflowInjector.
            user_input: Raw (sanitized) user message.
            rag_context: Global knowledge-base text wrapped in ``<rag_context>`` tags.
            context: Runtime context dict. Currently used for ``chat_history``.
            doc_type: Identifier of the document being generated.
            retrieved_context: Pre-built ``<retrieved_context>`` block from the
                               project's ChromaDB collection. Empty string when
                               no project store is configured or collection is empty.

        Returns:
            The fully assembled prompt string.
        """
        history_text = self._build_history_text(context.get("chat_history", []))

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
            "8. CRITICAL: If a <retrieved_context> block is present, your"
            " document MUST be 100%% consistent with the project information"
            " retrieved from it. Use the exact same project name, technology"
            " stack, domain terms and writing language found there.\n"
            "</critical_rules>\n"
        )

        sections: list[str] = []
        if injection_block:
            sections.append(injection_block)

        if rag_context:
            sections.append(rag_context)

        # Inject per-project context BEFORE critical rules so the LLM reads
        # the retrieved project information before receiving output instructions.
        if retrieved_context:
            sections.append(retrieved_context)

        sections.append(critical_rules)

        if history_text:
            sections.append(
                f"<conversation_history>\n{history_text}\n</conversation_history>"
            )

        sections.append(f"<user_input>\n{user_input}\n</user_input>")

        prompt = "\n\n".join(sections)

        # ── Safety net: hard-cap the final prompt ────────────────────────────
        # If the prompt still exceeds the ceiling after assembly, drop the
        # retrieved_context block (least critical) rather than failing at the API.
        if len(prompt) > _MAX_PROMPT_CHARS:
            logger.warning(
                "Prompt exceeded hard cap (%d > %d chars). "
                "Rebuilding without retrieved_context block.",
                len(prompt),
                _MAX_PROMPT_CHARS,
            )
            sections_no_context = [
                s for s in sections if not s.startswith("<retrieved_context>")
            ]
            prompt = "\n\n".join(sections_no_context)

        logger.debug("Final prompt size: %d chars.", len(prompt))
        return prompt
