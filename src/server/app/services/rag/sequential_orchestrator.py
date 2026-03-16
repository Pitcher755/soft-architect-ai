"""Sequential Orchestrator Service.

Optimized for Detail, Density, and Routing. Handles the sequential generation
of architecture documents, injecting dynamic context and maintaining memory efficiency.

Context Injection Strategy — Dependency-Graph Filtering
-------------------------------------------------------
The orchestrator accepts ``project_context`` inside the ``context`` dict:
a ``dict[str, str]`` mapping relative file paths to their content
(e.g. ``{"context/10-CONTEXT/PROJECT_MANIFESTO.md": "# Project Manifest\n..."}``).

Instead of injecting ALL generated documents into every prompt (which causes
Gemini 500 errors from context-window overflow at document 5+), the orchestrator
uses the ``CONTEXT_DEPENDENCIES`` graph defined in ``workflow.py``.

For each ``doc_type``, the graph declares EXACTLY which prior documents are
necessary for consistency.  For example, ``USER_STORIES_MASTER`` only needs:
  - PROJECT_MANIFESTO  (project identity, vision)
  - DOMAIN_LANGUAGE    (ubiquitous language)
  - REQUIREMENTS_MASTER (consolidated feature list)

not all 4 preceding documents.  This keeps the ``<project_documents>`` block
at 2-4 files regardless of how far along the 24-step workflow the user is.

The flow is:
  1. ``_filter_relevant_context()`` → returns only the 2-4 relevant files
  2. ``_build_project_documents_block()`` → serialises to ``<project_documents>``
  3. ``_build_prompt()`` → assembles the final prompt with adaptive budget guard

Future evolution: once the ``VectorStoreService`` in the ``app/`` layer has a
live ChromaDB connection, replace ``_filter_relevant_context()`` with a semantic
query against a per-project collection (Retrieval-Augmented Context Injection).
"""

import logging
from collections.abc import AsyncGenerator
from typing import Any

from app.core.exceptions import LLMError
from app.domain.constants.workflow import MASTER_WORKFLOW, get_context_dependencies
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
_MAX_PROMPT_CHARS = 60_000

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

    def _filter_relevant_context(
        self, project_context: dict[str, str], doc_type: str
    ) -> dict[str, str]:
        """Return only the files from ``project_context`` that ``doc_type`` needs.

        Uses the static ``CONTEXT_DEPENDENCIES`` graph from ``workflow.py`` to
        determine which prior documents are necessary for the current
        generation step.  The graph maps each ``doc_type`` to a list of the
        ``doc_type`` values of its direct predecessors.

        The filtering process:
        1. Build a reverse map: ``output_path → doc_type`` from MASTER_WORKFLOW.
        2. Look up the needed ``doc_type`` list for the current step.
        3. Keep only ``project_context`` entries whose path resolves to one of
           the needed types.
        4. Fall back to returning the full ``project_context`` if:
           • the dependency list is empty (e.g. PROJECT_MANIFESTO, first step)
           • no paths matched (paths may differ if Flutter sent non-canonical keys)

        Args:
            project_context: Full map of path → content sent by the client.
            doc_type: The document type currently being generated.

        Returns:
            A filtered subset of ``project_context`` containing only the
            directly relevant prior documents.
        """
        needed_types: list[str] = get_context_dependencies(doc_type)

        # No dependencies defined → first document or unknown type, pass nothing.
        if not needed_types:
            return {}

        # Build path → doc_type lookup once per call (24 entries, negligible cost).
        path_to_type: dict[str, str] = {
            step.output_path: step.doc_type for step in MASTER_WORKFLOW
        }

        filtered: dict[str, str] = {}
        for path, content in project_context.items():
            # Normalise: strip leading slashes Flutter may add.
            normalized_path = path.lstrip("/")
            resolved_type = path_to_type.get(normalized_path)
            if resolved_type in needed_types:
                filtered[normalized_path] = content

        if not filtered:
            # No paths resolved (e.g. Windows-style separators or unknown paths).
            # Safe fallback: pass ALL docs so the LLM is never context-blind.
            logger.warning(
                "Dependency graph filtering produced empty set for '%s'. "
                "Falling back to full project_context (%d files).",
                doc_type,
                len(project_context),
            )
            return project_context

        logger.info(
            "Context filter for '%s': %d/%d files selected (needed types: %s).",
            doc_type,
            len(filtered),
            len(project_context),
            needed_types,
        )
        return filtered

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
    ) -> str:
        """Construct the final deterministic prompt using XML tags for isolation.

        Prompt structure (ordered to maximise LLM accuracy):

        1. Workflow injection block  – template + example for the target doc type.
        2. RAG context               – relevant knowledge-base chunks.
        3. project_documents         – FILTERED docs already generated for this
                                       project (dependency-graph strategy:
                                       only direct predecessors of ``doc_type``).
        4. Critical rules            – strict output format instructions.
        5. Conversation history      – last 4 messages (truncated).
        6. User input                – the current user request.

        The ``project_documents`` block is built in two stages:
          a. ``_filter_relevant_context()`` reduces the full ``project_context``
             map to only the 2-4 files declared as direct dependencies of
             ``doc_type`` in ``CONTEXT_DEPENDENCIES`` (workflow.py).
          b. An adaptive char budget is computed from the remaining headroom
             inside ``_MAX_PROMPT_CHARS`` after other sections are measured.
        This two-stage approach prevents Gemini 500 errors from context-window
        overflow while keeping the LLM consistent with prior project decisions.

        Args:
            injection_block: Pre-rendered template/example block from WorkflowInjector.
            user_input: Raw (sanitized) user message.
            rag_context: Retrieved knowledge-base text wrapped in XML tags.
            context: Runtime context dict provided by the API endpoint.
                Expected keys:
                    - ``chat_history``     – list[dict[str, str]]
                    - ``project_context``  – dict[str, str]
            doc_type: Identifier of the document being generated.

        Returns:
            The fully assembled prompt string.
        """
        history_text = self._build_history_text(context.get("chat_history", []))

        # ── Context injection: filter then budget ───────────────────────────
        # Step 1 – Dependency-graph filtering:
        #   Reduce ``project_context`` to ONLY the files that are declared
        #   as direct predecessors of ``doc_type`` in CONTEXT_DEPENDENCIES.
        #   This limits the block to 2-4 files regardless of how many
        #   documents have been generated so far in the 24-step workflow.
        raw_project_context = context.get("project_context", {})
        relevant_context = self._filter_relevant_context(
            raw_project_context if isinstance(raw_project_context, dict) else {},
            doc_type,
        )

        # Step 2 – Adaptive budget:
        #   Even after filtering, large individual docs can be heavy.
        #   Compute the remaining char allowance from the other sections.
        static_sections_chars = (
            len(injection_block)
            + len(rag_context)
            + len(history_text)
            + len(user_input)
            + 2_000  # overhead: critical_rules + XML envelope padding
        )
        adaptive_budget = max(0, _MAX_PROMPT_CHARS - static_sections_chars)
        # Clamp to the absolute maximum we allow for this block.
        adaptive_budget = min(adaptive_budget, _MAX_TOTAL_CONTEXT_CHARS)

        project_docs_block = self._build_project_documents_block(
            relevant_context,
            budget=adaptive_budget,
        )
        if project_docs_block:
            logger.info(
                "Injecting project_context: %d/%d files after dependency filtering, "
                "adaptive_budget=%d chars.",
                len(relevant_context),
                (
                    len(raw_project_context)
                    if isinstance(raw_project_context, dict)
                    else 0
                ),
                adaptive_budget,
            )
        # ──────────────────────────────────────────────────────────────────────

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

        prompt = "\n\n".join(sections)

        # ── Safety net: hard-cap the final prompt ────────────────────────────
        # If after all adaptive budgeting the prompt still exceeds the ceiling
        # (e.g. because injection_block alone is huge), truncate the least
        # critical section (project_documents) rather than failing at the API.
        if len(prompt) > _MAX_PROMPT_CHARS:
            logger.warning(
                "Prompt exceeded hard cap (%d > %d chars). "
                "Rebuilding without project_documents block.",
                len(prompt),
                _MAX_PROMPT_CHARS,
            )
            sections_no_docs = [
                s for s in sections if not s.startswith("<project_documents>")
            ]
            prompt = "\n\n".join(sections_no_docs)

        logger.debug("Final prompt size: %d chars.", len(prompt))
        return prompt
