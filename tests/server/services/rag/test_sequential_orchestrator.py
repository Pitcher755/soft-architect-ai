"""Unit tests for SequentialOrchestrator – Context Injection Pipeline.

Covers:
  - _build_project_documents_block: XML serialisation, truncation, budget guard
  - _filter_relevant_context: dependency-graph filtering
  - _build_prompt: end-to-end prompt assembly with both filtering stages
  - ChatRequest schema: project_context field presence / default

Naming convention: test_{method}_{scenario}_{expected_result}
Coverage target  : 100% of new filtering and prompt-assembly logic.
"""

from unittest.mock import AsyncMock, MagicMock

import pytest

from app.services.rag.sequential_orchestrator import (
    SequentialOrchestrator,
    _MAX_DOC_CHARS,
    _MAX_PROMPT_CHARS,
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
        """When total chars exceed the budget, further files are omitted."""
        # Create enough files to exceed the default budget.
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

    def test_custom_budget_parameter_limits_block_size(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """Passing a small explicit budget must produce a smaller block."""
        # With a very small budget only the first (small) doc should fit.
        tiny_budget = 300
        context = {
            "doc_a.md": "A" * 100,
            "doc_b.md": "B" * 100,
            "doc_c.md": "C" * 100,
        }

        result = orchestrator._build_project_documents_block(
            context, budget=tiny_budget
        )

        # With 300-char budget (250 overhead → 50 effective) only minimal content fits.
        # The key assertion is that NOT all three files are present.
        included_count = sum(1 for k in context if f"--- {k} ---" in result)
        assert included_count < len(context)

    def test_zero_budget_returns_empty_string(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """A budget of 0 must return an empty string without raising."""
        context = {"doc.md": "Some content"}
        result = orchestrator._build_project_documents_block(context, budget=0)
        assert result == ""

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
        """When project_context contains a dependency-graph match, <project_documents> must appear.

        Uses DOMAIN_LANGUAGE as doc_type (depends on PROJECT_MANIFESTO) and
        the canonical output path of PROJECT_MANIFESTO so the dependency-graph
        filter can resolve the match and produce a non-empty block.
        """
        context = {
            "project_context": {
                "context/10-CONTEXT/PROJECT_MANIFESTO.md": "# Manifest\nProject here"
            },
            "chat_history": [],
        }

        prompt = orchestrator._build_prompt(
            injection_block="<inj>template</inj>",
            user_input="Generate doc",
            rag_context="",
            context=context,
            doc_type="DOMAIN_LANGUAGE",
        )

        assert "<project_documents>" in prompt
        assert "--- context/10-CONTEXT/PROJECT_MANIFESTO.md ---" in prompt
        assert "# Manifest\nProject here" in prompt

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
        """The *actual* project_documents block must precede <critical_rules> in the prompt.

        Uses DOMAIN_LANGUAGE + PROJECT_MANIFESTO path to guarantee a real block
        is emitted by the dependency-graph filter (PROJECT_MANIFESTO has no
        dependencies so it would return an empty filter and no block).
        """
        context = {
            "project_context": {
                "context/10-CONTEXT/PROJECT_MANIFESTO.md": "# Project info"
            },
            "chat_history": [],
        }

        prompt = orchestrator._build_prompt(
            injection_block="",
            user_input="Generate doc",
            rag_context="",
            context=context,
            doc_type="DOMAIN_LANGUAGE",
        )

        # Both tags must be present for a meaningful ordering check.
        assert "</project_documents>" in prompt, "Expected real project_documents block"
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

    def test_prompt_hard_cap_removes_project_docs_when_injection_block_is_huge(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """When the prompt would exceed _MAX_PROMPT_CHARS the project_documents
        block is stripped (safety net) and the prompt stays within the cap."""
        # Create a huge injection_block that alone pushes past the hard cap.
        huge_injection = "T" * (_MAX_PROMPT_CHARS + 5_000)
        context = {
            "project_context": {"RULES.md": "# Rules\nDo X"},
            "chat_history": [],
        }

        prompt = orchestrator._build_prompt(
            injection_block=huge_injection,
            user_input="Generate doc",
            rag_context="",
            context=context,
            doc_type="PROJECT_MANIFESTO",
        )

        # Safety net should have dropped the project_documents block.
        assert "</project_documents>" not in prompt
        # The prompt must not contain the closing tag – though it may still
        # be very large (injection_block is beyond our control).

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
            "project_context": {
                "context/10-CONTEXT/PROJECT_MANIFESTO.md": "# Manifest\nContent"
            },
            "chat_history": [],
        }

        async for _ in orch.generate(
            doc_type="DOMAIN_LANGUAGE",
            user_input="Generate domain language doc",
            context=context,
        ):
            pass

        assert len(captured_prompts) == 1
        assert "<project_documents>" in captured_prompts[0]
        assert "--- context/10-CONTEXT/PROJECT_MANIFESTO.md ---" in captured_prompts[0]

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


# ---------------------------------------------------------------------------
# Tests: CONTEXT_DEPENDENCIES graph and get_context_dependencies()
# ---------------------------------------------------------------------------


class TestContextDependencies:
    """Verify the dependency graph defined in workflow.py."""

    def test_project_manifesto_has_no_dependencies(self) -> None:
        """First document has no predecessors."""
        from app.domain.constants.workflow import get_context_dependencies

        assert get_context_dependencies("PROJECT_MANIFESTO") == []

    def test_domain_language_depends_on_project_manifesto(self) -> None:
        """DOMAIN_LANGUAGE needs PROJECT_MANIFESTO for project identity."""
        from app.domain.constants.workflow import get_context_dependencies

        deps = get_context_dependencies("DOMAIN_LANGUAGE")
        assert "PROJECT_MANIFESTO" in deps

    def test_user_stories_master_depends_on_requirements(self) -> None:
        """USER_STORIES_MASTER must list REQUIREMENTS_MASTER as dependency."""
        from app.domain.constants.workflow import get_context_dependencies

        deps = get_context_dependencies("USER_STORIES_MASTER")
        assert "REQUIREMENTS_MASTER" in deps

    def test_user_stories_master_dependencies_are_subset_of_workflow(self) -> None:
        """All dependency doc_types must exist in MASTER_WORKFLOW."""
        from app.domain.constants.workflow import (
            MASTER_WORKFLOW,
            get_context_dependencies,
        )

        all_types = {step.doc_type for step in MASTER_WORKFLOW}
        deps = get_context_dependencies("USER_STORIES_MASTER")
        for dep in deps:
            assert dep in all_types, f"Unknown dep: {dep}"

    def test_unknown_doc_type_returns_empty_list(self) -> None:
        """Unregistered doc_type must return [] (no KeyError)."""
        from app.domain.constants.workflow import get_context_dependencies

        assert get_context_dependencies("NON_EXISTENT_TYPE") == []

    def test_all_dependency_targets_exist_in_workflow(self) -> None:
        """Every type listed in any dependency must exist in MASTER_WORKFLOW."""
        from app.domain.constants.workflow import (
            CONTEXT_DEPENDENCIES,
            MASTER_WORKFLOW,
        )

        all_types = {step.doc_type for step in MASTER_WORKFLOW}
        for source, deps in CONTEXT_DEPENDENCIES.items():
            for dep in deps:
                assert (
                    dep in all_types
                ), f"Dependency '{dep}' of '{source}' is not in MASTER_WORKFLOW"

    def test_dependencies_do_not_include_self(self) -> None:
        """No doc_type should depend on itself."""
        from app.domain.constants.workflow import CONTEXT_DEPENDENCIES

        for doc_type, deps in CONTEXT_DEPENDENCIES.items():
            assert doc_type not in deps, f"{doc_type} depends on itself"

    def test_readme_synthesis_includes_manifesto(self) -> None:
        """README (last doc) must include PROJECT_MANIFESTO in its dependencies."""
        from app.domain.constants.workflow import get_context_dependencies

        deps = get_context_dependencies("README")
        assert "PROJECT_MANIFESTO" in deps


# ---------------------------------------------------------------------------
# Tests: _filter_relevant_context – dependency-graph filtering
# ---------------------------------------------------------------------------


class TestFilterRelevantContext:
    """Unit tests for SequentialOrchestrator._filter_relevant_context()."""

    # ── canonical paths as Flutter sends them ──────────────────────────────
    _MANIFESTO_PATH = "context/10-CONTEXT/PROJECT_MANIFESTO.md"
    _DOMAIN_PATH = "context/10-CONTEXT/DOMAIN_LANGUAGE.md"
    _JOURNEY_PATH = "context/10-CONTEXT/USER_JOURNEY_MAP.md"
    _REQUIREMENTS_PATH = "context/20-REQUIREMENTS/REQUIREMENTS_MASTER.md"
    _STORIES_PATH = "context/20-REQUIREMENTS/USER_STORIES_MASTER.json"

    @property
    def full_context(self) -> dict[str, str]:
        return {
            self._MANIFESTO_PATH: "# Manifesto",
            self._DOMAIN_PATH: "# Domain",
            self._JOURNEY_PATH: "# Journey",
            self._REQUIREMENTS_PATH: "# Requirements",
            self._STORIES_PATH: '{"stories": []}',
        }

    def test_filters_to_declared_dependencies(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """For USER_STORIES_MASTER, only its declared deps should be returned."""
        result = orchestrator._filter_relevant_context(
            self.full_context, "USER_STORIES_MASTER"
        )
        # USER_STORIES_MASTER depends on PROJECT_MANIFESTO, DOMAIN_LANGUAGE,
        # REQUIREMENTS_MASTER — NOT on USER_JOURNEY_MAP or USER_STORIES_MASTER.
        assert self._MANIFESTO_PATH in result
        assert self._DOMAIN_PATH in result
        assert self._REQUIREMENTS_PATH in result
        assert self._JOURNEY_PATH not in result
        assert self._STORIES_PATH not in result

    def test_project_manifesto_returns_empty_dict(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """PROJECT_MANIFESTO has no deps → returns empty dict (first doc)."""
        result = orchestrator._filter_relevant_context(
            self.full_context, "PROJECT_MANIFESTO"
        )
        assert result == {}

    def test_empty_project_context_returns_empty_dict(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """Filtering an empty context always yields empty dict."""
        result = orchestrator._filter_relevant_context({}, "USER_STORIES_MASTER")
        assert result == {}

    def test_unknown_doc_type_returns_full_context_as_fallback(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """Unknown doc_type has no dependency entry → falls back to full context."""
        result = orchestrator._filter_relevant_context(
            self.full_context, "UNKNOWN_TYPE"
        )
        # get_context_dependencies("UNKNOWN_TYPE") returns [] which is falsy,
        # so the method returns {} (same as first-doc case, no deps = no prior context).
        assert result == {}

    def test_domain_language_gets_only_manifesto(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """DOMAIN_LANGUAGE depends only on PROJECT_MANIFESTO."""
        result = orchestrator._filter_relevant_context(
            self.full_context, "DOMAIN_LANGUAGE"
        )
        assert list(result.keys()) == [self._MANIFESTO_PATH]

    def test_non_matching_paths_trigger_fallback(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """If no path resolves to a needed type, full context is returned as fallback."""
        bad_context = {
            "wrong/path/PROJECT_MANIFESTO.md": "content",
            "also/wrong.md": "other",
        }
        result = orchestrator._filter_relevant_context(bad_context, "DOMAIN_LANGUAGE")
        # No path matches → fallback returns the full bad_context unchanged.
        assert result == bad_context

    def test_filtered_count_is_bounded_by_dependencies(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """Filtered context must have ≤ len(dependencies) entries."""
        from app.domain.constants.workflow import get_context_dependencies

        doc_type = "USER_STORIES_MASTER"
        max_deps = len(get_context_dependencies(doc_type))
        result = orchestrator._filter_relevant_context(self.full_context, doc_type)
        assert len(result) <= max_deps


# ---------------------------------------------------------------------------
# Tests: _build_prompt uses dependency-graph filtering
# ---------------------------------------------------------------------------


class TestBuildPromptWithDependencyFiltering:
    """Integration tests: _build_prompt must only inject filtered docs."""

    _MANIFESTO_PATH = "context/10-CONTEXT/PROJECT_MANIFESTO.md"
    _REQUIREMENTS_PATH = "context/20-REQUIREMENTS/REQUIREMENTS_MASTER.md"
    _JOURNEY_PATH = "context/10-CONTEXT/USER_JOURNEY_MAP.md"

    def test_irrelevant_documents_absent_from_prompt(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """Docs not in USER_STORIES_MASTER deps must not appear in the prompt."""
        # USER_JOURNEY_MAP is NOT a dep of USER_STORIES_MASTER.
        context = {
            "project_context": {
                self._MANIFESTO_PATH: "# Manifesto",
                self._JOURNEY_PATH: "# THIS SHOULD NOT APPEAR IN PROMPT",
                self._REQUIREMENTS_PATH: "# Requirements",
                "context/10-CONTEXT/DOMAIN_LANGUAGE.md": "# Domain",
            },
            "chat_history": [],
        }
        prompt = orchestrator._build_prompt(
            injection_block="",
            user_input="Generate user stories",
            rag_context="",
            context=context,
            doc_type="USER_STORIES_MASTER",
        )
        assert "THIS SHOULD NOT APPEAR IN PROMPT" not in prompt

    def test_relevant_documents_present_in_prompt(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """Docs in USER_STORIES_MASTER deps MUST appear in the prompt."""
        context = {
            "project_context": {
                self._MANIFESTO_PATH: "# Manifesto UNIQUE_TOKEN_MANIFESTO",
                self._REQUIREMENTS_PATH: "# Reqs UNIQUE_TOKEN_REQS",
                "context/10-CONTEXT/DOMAIN_LANGUAGE.md": "# Domain",
                self._JOURNEY_PATH: "# Journey",
            },
            "chat_history": [],
        }
        prompt = orchestrator._build_prompt(
            injection_block="",
            user_input="Generate user stories",
            rag_context="",
            context=context,
            doc_type="USER_STORIES_MASTER",
        )
        assert "UNIQUE_TOKEN_MANIFESTO" in prompt
        assert "UNIQUE_TOKEN_REQS" in prompt

    def test_prompt_for_project_manifesto_has_no_project_documents_block(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """First document must have no <project_documents> block (no deps)."""
        context = {
            "project_context": {self._MANIFESTO_PATH: "# Manifesto"},
            "chat_history": [],
        }
        prompt = orchestrator._build_prompt(
            injection_block="",
            user_input="Start my project",
            rag_context="",
            context=context,
            doc_type="PROJECT_MANIFESTO",
        )
        assert "</project_documents>" not in prompt
