"""Unit tests for SequentialOrchestrator – Task 8: Context Injection.

Verifies that project documents already generated are correctly serialised into
the LLM prompt, preventing LLM amnesia from document 4 onwards.

Naming convention: test_{method}_{scenario}_{expected_result}
Coverage target  : 100% of _build_project_documents_block and _build_prompt.
"""

from unittest.mock import AsyncMock, MagicMock

import pytest

from app.services.rag.sequential_orchestrator import (
    SequentialOrchestrator,
    _MAX_DOC_CHARS,
    _MAX_TOTAL_CONTEXT_CHARS,
)


# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------


@pytest.fixture
def mock_vector_store() -> MagicMock:
    """Return a vector store stub that always returns empty results."""
    store = MagicMock()
    store.query.return_value = {"documents": []}
    return store


@pytest.fixture
def mock_llm_client() -> MagicMock:
    """Return an LLM client stub that streams a single token."""
    client = MagicMock()

    async def _fake_stream(prompt: str, history: list) -> AsyncMock:
        yield "token"

    client.stream_generate = _fake_stream
    return client


@pytest.fixture
def mock_workflow_injector() -> MagicMock:
    """Return a WorkflowInjector stub."""
    injector = MagicMock()
    injector.get_injected_prompt.return_value = "<injection>template</injection>"
    return injector


@pytest.fixture
def orchestrator(
    mock_vector_store: MagicMock,
    mock_llm_client: MagicMock,
    mock_workflow_injector: MagicMock,
) -> SequentialOrchestrator:
    """Create a fully mocked SequentialOrchestrator."""
    return SequentialOrchestrator(
        vector_store=mock_vector_store,
        llm_client=mock_llm_client,
        workflow_injector=mock_workflow_injector,
    )


# ---------------------------------------------------------------------------
# Tests: _build_project_documents_block
# ---------------------------------------------------------------------------


class TestBuildProjectDocumentsBlock:
    """Tests for _build_project_documents_block serialisation logic."""

    def test_returns_empty_string_when_context_is_empty(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """Empty project_context must produce an empty string (no XML block)."""
        result = orchestrator._build_project_documents_block({})

        assert result == ""

    def test_returns_xml_block_with_correct_header(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """Non-empty context must produce a <project_documents> XML block."""
        context = {"context/10-BUSINESS/MANIFEST.md": "# Manifest\nContent here"}

        result = orchestrator._build_project_documents_block(context)

        assert result.startswith("<project_documents>")
        assert result.endswith("</project_documents>")

    def test_includes_file_path_separator(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """Each document must be preceded by its path as a separator."""
        context = {"context/10-BUSINESS/MANIFEST.md": "# Manifest\nContent"}

        result = orchestrator._build_project_documents_block(context)

        assert "--- context/10-BUSINESS/MANIFEST.md ---" in result

    def test_includes_file_content(self, orchestrator: SequentialOrchestrator) -> None:
        """File content must appear verbatim in the output block."""
        context = {"RULES.md": "# Rules\nRule 1\nRule 2"}

        result = orchestrator._build_project_documents_block(context)

        assert "# Rules\nRule 1\nRule 2" in result

    def test_truncates_individual_document_exceeding_max_chars(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """Documents larger than _MAX_DOC_CHARS must be truncated."""
        long_content = "X" * (_MAX_DOC_CHARS + 500)
        context = {"big_doc.md": long_content}

        result = orchestrator._build_project_documents_block(context)

        assert "... [truncated]" in result
        # More than _MAX_DOC_CHARS consecutive identical chars must not appear.
        # (Checking exactly _MAX_DOC_CHARS + 1 chars ensures truncation cut at the limit.)
        assert "X" * (_MAX_DOC_CHARS + 1) not in result

    def test_does_not_truncate_document_within_limit(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """Documents within _MAX_DOC_CHARS must not be truncated."""
        normal_content = "Y" * (_MAX_DOC_CHARS - 100)
        context = {"normal_doc.md": normal_content}

        result = orchestrator._build_project_documents_block(context)

        assert "... [truncated]" not in result
        assert normal_content in result

    def test_stops_adding_files_when_total_budget_exhausted(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """When total chars exceed _MAX_TOTAL_CONTEXT_CHARS, further files omitted."""
        # Create enough files to exceed the budget
        # Each file is just below _MAX_DOC_CHARS to avoid per-doc truncation.
        per_doc = _MAX_DOC_CHARS - 10
        n_files = (_MAX_TOTAL_CONTEXT_CHARS // per_doc) + 5

        context = {f"file_{i}.md": "Z" * per_doc for i in range(n_files)}

        result = orchestrator._build_project_documents_block(context)

        # The block must be non-empty (first files were added)
        assert result != ""
        # Not all file separators should be present
        included_count = result.count("--- file_")
        assert included_count < n_files

    def test_includes_consistency_instruction(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """The XML block must contain consistency instructions for the LLM."""
        context = {"context/10-BUSINESS/MANIFEST.md": "# Manifest\nContent"}

        result = orchestrator._build_project_documents_block(context)

        assert "MUST be fully consistent" in result

    def test_multiple_files_all_included_within_budget(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """All files within budget must appear in the block."""
        context = {
            "context/10-BUSINESS/MANIFEST.md": "# Manifest content",
            "context/20-DOMAIN/DOMAIN_LANGUAGE.md": "# Domain Language",
            "RULES.md": "# Project Rules",
        }

        result = orchestrator._build_project_documents_block(context)

        for path in context:
            assert f"--- {path} ---" in result


# ---------------------------------------------------------------------------
# Tests: _build_prompt – project_context integration
# ---------------------------------------------------------------------------


class TestBuildPromptProjectContext:
    """Tests for _build_prompt injection of project_context (Task 8)."""

    def test_prompt_contains_project_documents_block_when_context_provided(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """When project_context is non-empty, <project_documents> must appear."""
        context = {
            "project_context": {"RULES.md": "# Rules\nDo X"},
            "chat_history": [],
        }

        prompt = orchestrator._build_prompt(
            injection_block="<inj>template</inj>",
            user_input="Generate doc",
            rag_context="",
            context=context,
            doc_type="PROJECT_MANIFESTO",
        )

        assert "<project_documents>" in prompt
        assert "--- RULES.md ---" in prompt
        assert "# Rules\nDo X" in prompt

    def test_prompt_omits_project_documents_block_when_context_empty(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """When project_context is empty, <project_documents> XML block must not appear.

        Note: the literal string '<project_documents>' may appear inside
        critical_rules text (rule 8).  We therefore check for the *closing*
        tag '</project_documents>' which is only emitted by the real block.
        """
        context = {"project_context": {}, "chat_history": []}

        prompt = orchestrator._build_prompt(
            injection_block="",
            user_input="Generate doc",
            rag_context="",
            context=context,
            doc_type="PROJECT_MANIFESTO",
        )

        assert "</project_documents>" not in prompt

    def test_prompt_omits_project_documents_block_when_key_missing(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """When project_context key is absent from context, no block is emitted.

        Checks the closing tag (see note in sibling test).
        """
        context = {"chat_history": []}

        prompt = orchestrator._build_prompt(
            injection_block="",
            user_input="Generate doc",
            rag_context="",
            context=context,
            doc_type="PROJECT_MANIFESTO",
        )

        assert "</project_documents>" not in prompt

    def test_project_documents_block_appears_before_critical_rules(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """The project_documents block must precede <critical_rules> in the prompt."""
        context = {
            "project_context": {"RULES.md": "# Rules"},
            "chat_history": [],
        }

        prompt = orchestrator._build_prompt(
            injection_block="",
            user_input="Generate doc",
            rag_context="",
            context=context,
            doc_type="PROJECT_MANIFESTO",
        )

        docs_pos = prompt.index("<project_documents>")
        rules_pos = prompt.index("<critical_rules>")
        assert (
            docs_pos < rules_pos
        ), "<project_documents> should appear before <critical_rules>"

    def test_project_documents_block_appears_after_rag_context(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """The project_documents block must follow the RAG context."""
        context = {
            "project_context": {"RULES.md": "# Rules"},
            "chat_history": [],
        }

        prompt = orchestrator._build_prompt(
            injection_block="",
            user_input="Generate doc",
            rag_context="<rag_context>rag_data</rag_context>",
            context=context,
            doc_type="PROJECT_MANIFESTO",
        )

        rag_pos = prompt.index("<rag_context>")
        docs_pos = prompt.index("<project_documents>")
        assert (
            rag_pos < docs_pos
        ), "<project_documents> should appear after <rag_context>"

    def test_critical_rules_include_consistency_rule_8(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """Critical rules must contain rule 8 about project consistency."""
        context = {"project_context": {}, "chat_history": []}

        prompt = orchestrator._build_prompt(
            injection_block="",
            user_input="Generate doc",
            rag_context="",
            context=context,
            doc_type="PROJECT_MANIFESTO",
        )

        assert "project_documents" in prompt
        assert "consistent" in prompt

    def test_prompt_handles_non_dict_project_context_gracefully(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """Non-dict project_context must not raise; treated as empty."""
        context = {
            "project_context": "invalid_string",
            "chat_history": [],
        }

        # Must not raise
        prompt = orchestrator._build_prompt(
            injection_block="",
            user_input="Generate doc",
            rag_context="",
            context=context,
            doc_type="PROJECT_MANIFESTO",
        )

        # Closing tag is only emitted by the real block (see note in empty-context test).
        assert "</project_documents>" not in prompt

    def test_prompt_contains_user_input(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """User input must always appear in the generated prompt."""
        context = {"project_context": {}, "chat_history": []}

        prompt = orchestrator._build_prompt(
            injection_block="",
            user_input="Build a fintech app",
            rag_context="",
            context=context,
            doc_type="PROJECT_MANIFESTO",
        )

        assert "Build a fintech app" in prompt


# ---------------------------------------------------------------------------
# Tests: generate() – end-to-end integration with context injection
# ---------------------------------------------------------------------------


class TestGenerateWithProjectContext:
    """Integration tests for the generate() entry point."""

    @pytest.mark.asyncio
    async def test_generate_streams_tokens_with_project_context(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """generate() must stream tokens when project_context is provided."""
        context = {
            "project_context": {
                "context/10-BUSINESS/MANIFEST.md": "# Project Manifesto\nIdea: ..."
            },
            "chat_history": [],
        }

        tokens = []
        async for token in orchestrator.generate(
            doc_type="DOMAIN_LANGUAGE",
            user_input="Generate domain language doc",
            context=context,
        ):
            tokens.append(token)

        assert len(tokens) > 0

    @pytest.mark.asyncio
    async def test_generate_calls_llm_with_prompt_containing_project_documents(
        self,
        mock_vector_store: MagicMock,
        mock_workflow_injector: MagicMock,
    ) -> None:
        """generate() must pass a prompt containing <project_documents> to the LLM."""
        captured_prompts: list[str] = []

        async def _capture_stream(prompt: str, history: list):
            captured_prompts.append(prompt)
            yield "token"

        llm_spy = MagicMock()
        llm_spy.stream_generate = _capture_stream

        orch = SequentialOrchestrator(
            vector_store=mock_vector_store,
            llm_client=llm_spy,
            workflow_injector=mock_workflow_injector,
        )

        context = {
            "project_context": {"RULES.md": "# Rules\nContent"},
            "chat_history": [],
        }

        async for _ in orch.generate(
            doc_type="PROJECT_MANIFESTO",
            user_input="Generate manifesto",
            context=context,
        ):
            pass

        assert len(captured_prompts) == 1
        assert "<project_documents>" in captured_prompts[0]
        assert "--- RULES.md ---" in captured_prompts[0]

    @pytest.mark.asyncio
    async def test_generate_streams_tokens_without_project_context(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """generate() must still work when project_context is absent."""
        context = {"chat_history": []}

        tokens = []
        async for token in orchestrator.generate(
            doc_type="PROJECT_MANIFESTO",
            user_input="Generate doc for new project",
            context=context,
        ):
            tokens.append(token)

        assert len(tokens) > 0


# ---------------------------------------------------------------------------
# Tests: ChatRequest schema – project_context field
# ---------------------------------------------------------------------------


class TestChatRequestSchema:
    """Verify that ChatRequest accepts and validates project_context."""

    def test_chat_request_accepts_project_context_field(self) -> None:
        """ChatRequest must accept a valid project_context dict."""
        from uuid import uuid4

        from app.domain.schemas.chat_schema import ChatRequest

        request = ChatRequest(
            conversation_id=uuid4(),
            message="Generate my manifesto",
            project_id=uuid4(),
            project_context={"RULES.md": "# Rules\nContent"},
        )

        assert request.project_context == {"RULES.md": "# Rules\nContent"}

    def test_chat_request_defaults_to_empty_project_context(self) -> None:
        """ChatRequest must default project_context to empty dict."""
        from uuid import uuid4

        from app.domain.schemas.chat_schema import ChatRequest

        request = ChatRequest(
            conversation_id=uuid4(),
            message="Generate my manifesto",
            project_id=uuid4(),
        )

        assert request.project_context == {}
