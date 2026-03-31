"""Unit tests for SequentialOrchestrator – Dynamic RAG Context Injection Pipeline.

Covers:
  - _build_project_documents_block: XML serialisation, truncation, budget guard
  - _retrieve_project_context: dynamic per-project semantic RAG retrieval (Task 7)
  - _build_prompt: end-to-end prompt assembly with retrieved_context injection
  - generate(): integration with ChromaProjectStore via project_store
  - ChatRequest schema: project_context field presence / default
  - CONTEXT_DEPENDENCIES graph: dependency declarations in workflow.py

Naming convention: test_{method}_{scenario}_{expected_result}
Coverage target  : >90% of orchestrator logic, 100% of new RAG retrieval path.
"""

from collections.abc import AsyncGenerator
from unittest.mock import MagicMock

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

    async def _fake_stream(prompt: str, history: list) -> AsyncGenerator[str, None]:
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
    """Tests for _build_prompt injection of retrieved_context (Task 7)."""

    def test_prompt_contains_retrieved_context_block_when_provided(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """When retrieved_context is supplied, the block must appear in the prompt."""
        prompt = orchestrator._build_prompt(
            injection_block="<inj>template</inj>",
            user_input="Generate doc",
            rag_context="",
            context={"chat_history": []},
            doc_type="DOMAIN_LANGUAGE",
            retrieved_context="<retrieved_context>\nChunk A\n</retrieved_context>",
        )

        assert "<retrieved_context>" in prompt
        assert "</retrieved_context>" in prompt
        assert "Chunk A" in prompt

    def test_prompt_omits_retrieved_context_block_when_empty(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """When retrieved_context is empty, no <retrieved_context> block appears."""
        prompt = orchestrator._build_prompt(
            injection_block="",
            user_input="Generate doc",
            rag_context="",
            context={"chat_history": []},
            doc_type="PROJECT_MANIFESTO",
            retrieved_context="",
        )

        assert "</retrieved_context>" not in prompt

    def test_prompt_omits_retrieved_context_block_when_param_absent(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """When retrieved_context parameter is not passed, no block is emitted."""
        prompt = orchestrator._build_prompt(
            injection_block="",
            user_input="Generate doc",
            rag_context="",
            context={"chat_history": []},
            doc_type="PROJECT_MANIFESTO",
        )

        assert "</retrieved_context>" not in prompt

    def test_retrieved_context_block_appears_before_critical_rules(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """The <retrieved_context> block must precede <critical_rules> in the prompt."""
        prompt = orchestrator._build_prompt(
            injection_block="",
            user_input="Generate doc",
            rag_context="",
            context={"chat_history": []},
            doc_type="DOMAIN_LANGUAGE",
            retrieved_context="<retrieved_context>\nProject data\n</retrieved_context>",
        )

        assert "</retrieved_context>" in prompt
        ctx_pos = prompt.index("<retrieved_context>")
        rules_pos = prompt.index("<critical_rules>")
        assert (
            ctx_pos < rules_pos
        ), "<retrieved_context> must appear before <critical_rules>"

    def test_retrieved_context_block_appears_after_rag_context(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """The <retrieved_context> block must follow the <rag_context> block."""
        prompt = orchestrator._build_prompt(
            injection_block="",
            user_input="Generate doc",
            rag_context="<rag_context>global_kb_data</rag_context>",
            context={"chat_history": []},
            doc_type="PROJECT_MANIFESTO",
            retrieved_context="<retrieved_context>\nProject chunk\n</retrieved_context>",
        )

        rag_pos = prompt.index("<rag_context>")
        ctx_pos = prompt.index("<retrieved_context>")
        assert rag_pos < ctx_pos, "<retrieved_context> must appear after <rag_context>"

    def test_critical_rules_include_consistency_rule_8(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """Critical rules must contain rule 8 referencing retrieved_context."""
        prompt = orchestrator._build_prompt(
            injection_block="",
            user_input="Generate doc",
            rag_context="",
            context={"chat_history": []},
            doc_type="PROJECT_MANIFESTO",
        )

        assert "retrieved_context" in prompt
        assert "consistent" in prompt

    def test_prompt_handles_extra_context_keys_gracefully(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """Unknown keys in context dict must be silently ignored (no exception raised)."""
        context = {
            "legacy_project_context": {"RULES.md": "# Rules"},
            "chat_history": [],
            "unknown_key": "ignored",
        }

        prompt = orchestrator._build_prompt(
            injection_block="",
            user_input="Generate doc",
            rag_context="",
            context=context,
            doc_type="PROJECT_MANIFESTO",
        )

        assert "Generate doc" in prompt
        assert "</retrieved_context>" not in prompt

    def test_prompt_hard_cap_removes_retrieved_context_when_injection_block_is_huge(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """When the prompt exceeds _MAX_PROMPT_CHARS the retrieved_context
        block is stripped by the safety net."""
        huge_injection = "T" * (_MAX_PROMPT_CHARS + 5_000)
        prompt = orchestrator._build_prompt(
            injection_block=huge_injection,
            user_input="Generate doc",
            rag_context="",
            context={"chat_history": []},
            doc_type="PROJECT_MANIFESTO",
            retrieved_context="<retrieved_context>\nShould be stripped\n</retrieved_context>",
        )

        assert "</retrieved_context>" not in prompt

    def test_prompt_contains_user_input(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """User input must always appear in the generated prompt."""
        prompt = orchestrator._build_prompt(
            injection_block="",
            user_input="Build a fintech app",
            rag_context="",
            context={"chat_history": []},
            doc_type="PROJECT_MANIFESTO",
        )

        assert "Build a fintech app" in prompt


# ---------------------------------------------------------------------------
# Tests: generate() – end-to-end integration with context injection
# ---------------------------------------------------------------------------


class TestGenerateWithProjectContext:
    """Integration tests for the generate() entry point with dynamic RAG."""

    @pytest.mark.asyncio
    async def test_generate_streams_tokens_with_project_store(
        self,
        mock_vector_store: MagicMock,
        mock_llm_client: MagicMock,
        mock_workflow_injector: MagicMock,
    ) -> None:
        """generate() must stream tokens when project_store is configured."""
        mock_project_store = MagicMock()
        mock_project_store.query_project.return_value = ["Chunk A", "Chunk B"]

        orch = SequentialOrchestrator(
            vector_store=mock_vector_store,
            llm_client=mock_llm_client,
            workflow_injector=mock_workflow_injector,
            project_store=mock_project_store,
        )

        context = {
            "project_id": "test-project-123",
            "chat_history": [],
        }

        tokens = []
        async for token in orch.generate(
            doc_type="DOMAIN_LANGUAGE",
            user_input="Generate domain language doc",
            context=context,
        ):
            tokens.append(token)

        assert len(tokens) > 0
        mock_project_store.query_project.assert_called_once()

    @pytest.mark.asyncio
    async def test_generate_calls_llm_with_prompt_containing_retrieved_context(
        self,
        mock_vector_store: MagicMock,
        mock_workflow_injector: MagicMock,
    ) -> None:
        """generate() must pass a prompt containing <retrieved_context> to the LLM
        when project_store returns chunks for the given project_id."""
        captured_prompts: list[str] = []

        async def _capture_stream(
            prompt: str, history: list
        ) -> AsyncGenerator[str, None]:
            captured_prompts.append(prompt)
            yield "token"

        llm_spy = MagicMock()
        llm_spy.stream_generate = _capture_stream

        mock_project_store = MagicMock()
        mock_project_store.query_project.return_value = [
            "Project uses Python FastAPI",
            "Clean Architecture pattern selected",
        ]

        orch = SequentialOrchestrator(
            vector_store=mock_vector_store,
            llm_client=llm_spy,
            workflow_injector=mock_workflow_injector,
            project_store=mock_project_store,
        )

        context = {
            "project_id": "abc-123",
            "chat_history": [],
        }

        async for _ in orch.generate(
            doc_type="DOMAIN_LANGUAGE",
            user_input="Generate domain language doc",
            context=context,
        ):
            pass

        assert len(captured_prompts) == 1
        assert "<retrieved_context>" in captured_prompts[0]
        assert "Project uses Python FastAPI" in captured_prompts[0]
        assert "Clean Architecture pattern selected" in captured_prompts[0]

    @pytest.mark.asyncio
    async def test_generate_streams_tokens_without_project_store(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """generate() must still work when project_store is None (no ChromaDB)."""
        context = {"project_id": "any-id", "chat_history": []}

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
# Tests: _retrieve_project_context – dynamic per-project semantic RAG (Task 7)
# ---------------------------------------------------------------------------


class TestRetrieveProjectContext:
    """Unit tests for SequentialOrchestrator._retrieve_project_context()."""

    def test_returns_empty_string_when_project_store_is_none(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """When project_store is None, must return empty string without raising."""
        # The default orchestrator fixture has project_store=None.
        result = orchestrator._retrieve_project_context(
            project_id="abc-123",
            doc_type="DOMAIN_LANGUAGE",
            user_input="Generate domain doc",
        )
        assert result == ""

    def test_returns_empty_string_when_project_id_is_empty(
        self,
        mock_vector_store: MagicMock,
        mock_llm_client: MagicMock,
        mock_workflow_injector: MagicMock,
    ) -> None:
        """Empty project_id must short-circuit and return empty string."""
        mock_store = MagicMock()
        orch = SequentialOrchestrator(
            vector_store=mock_vector_store,
            llm_client=mock_llm_client,
            workflow_injector=mock_workflow_injector,
            project_store=mock_store,
        )
        result = orch._retrieve_project_context(
            project_id="", doc_type="DOMAIN_LANGUAGE", user_input="some input"
        )
        assert result == ""
        mock_store.query_project.assert_not_called()

    def test_returns_empty_string_when_store_returns_no_chunks(
        self,
        mock_vector_store: MagicMock,
        mock_llm_client: MagicMock,
        mock_workflow_injector: MagicMock,
    ) -> None:
        """Empty query results must produce an empty string (no XML block)."""
        mock_store = MagicMock()
        mock_store.query_project.return_value = []
        orch = SequentialOrchestrator(
            vector_store=mock_vector_store,
            llm_client=mock_llm_client,
            workflow_injector=mock_workflow_injector,
            project_store=mock_store,
        )
        result = orch._retrieve_project_context(
            project_id="proj-1", doc_type="DOMAIN_LANGUAGE", user_input="some input"
        )
        assert result == ""

    def test_returns_retrieved_context_block_with_single_chunk(
        self,
        mock_vector_store: MagicMock,
        mock_llm_client: MagicMock,
        mock_workflow_injector: MagicMock,
    ) -> None:
        """A non-empty result must be wrapped in <retrieved_context> tags."""
        mock_store = MagicMock()
        mock_store.query_project.return_value = ["Project uses FastAPI"]
        orch = SequentialOrchestrator(
            vector_store=mock_vector_store,
            llm_client=mock_llm_client,
            workflow_injector=mock_workflow_injector,
            project_store=mock_store,
        )
        result = orch._retrieve_project_context(
            project_id="proj-1", doc_type="DOMAIN_LANGUAGE", user_input="input"
        )
        assert result.startswith("<retrieved_context>")
        assert result.endswith("</retrieved_context>")
        assert "Project uses FastAPI" in result

    def test_query_uses_correct_semantic_format(
        self,
        mock_vector_store: MagicMock,
        mock_llm_client: MagicMock,
        mock_workflow_injector: MagicMock,
    ) -> None:
        """The semantic query must follow the format 'Context for {doc_type}: {user_input}'."""
        mock_store = MagicMock()
        mock_store.query_project.return_value = ["chunk"]
        orch = SequentialOrchestrator(
            vector_store=mock_vector_store,
            llm_client=mock_llm_client,
            workflow_injector=mock_workflow_injector,
            project_store=mock_store,
        )
        orch._retrieve_project_context(
            project_id="p-1",
            doc_type="USER_STORIES_MASTER",
            user_input="Build todo app",
        )
        mock_store.query_project.assert_called_once_with(
            "p-1",
            "Context for USER_STORIES_MASTER: Build todo app",
            n_results=3,
        )

    def test_returns_empty_string_on_store_exception(
        self,
        mock_vector_store: MagicMock,
        mock_llm_client: MagicMock,
        mock_workflow_injector: MagicMock,
    ) -> None:
        """A store exception must be caught and return empty string (no crash)."""
        mock_store = MagicMock()
        mock_store.query_project.side_effect = RuntimeError("ChromaDB unavailable")
        orch = SequentialOrchestrator(
            vector_store=mock_vector_store,
            llm_client=mock_llm_client,
            workflow_injector=mock_workflow_injector,
            project_store=mock_store,
        )
        result = orch._retrieve_project_context(
            project_id="p-1", doc_type="DOMAIN_LANGUAGE", user_input="some input"
        )
        assert result == ""

    def test_joins_multiple_chunks_with_double_newline(
        self,
        mock_vector_store: MagicMock,
        mock_llm_client: MagicMock,
        mock_workflow_injector: MagicMock,
    ) -> None:
        """Multiple chunks must be joined by double newline inside the XML block."""
        mock_store = MagicMock()
        mock_store.query_project.return_value = [
            "Chunk One",
            "Chunk Two",
            "Chunk Three",
        ]
        orch = SequentialOrchestrator(
            vector_store=mock_vector_store,
            llm_client=mock_llm_client,
            workflow_injector=mock_workflow_injector,
            project_store=mock_store,
        )
        result = orch._retrieve_project_context(
            project_id="p-1", doc_type="DOMAIN_LANGUAGE", user_input="input"
        )
        assert "Chunk One\n\nChunk Two\n\nChunk Three" in result


# ---------------------------------------------------------------------------
# Tests: _build_prompt assembles retrieved_context into the prompt
# ---------------------------------------------------------------------------


class TestBuildPromptWithRetrievedContext:
    """Integration tests: _build_prompt must inject retrieved_context correctly."""

    def test_retrieved_context_content_appears_in_prompt(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """Retrieved chunk text must be present in the assembled prompt."""
        retrieved = (
            "<retrieved_context>\n"
            "Tech stack: FastAPI + ChromaDB\n"
            "Pattern: Clean Architecture\n"
            "</retrieved_context>"
        )
        prompt = orchestrator._build_prompt(
            injection_block="",
            user_input="Generate architecture doc",
            rag_context="",
            context={"chat_history": []},
            doc_type="ARCHITECTURE_DESIGN",
            retrieved_context=retrieved,
        )
        assert "Tech stack: FastAPI + ChromaDB" in prompt
        assert "Pattern: Clean Architecture" in prompt

    def test_empty_retrieved_context_produces_no_block(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """When retrieved_context is empty, prompt must not contain the XML block."""
        prompt = orchestrator._build_prompt(
            injection_block="",
            user_input="Generate architecture doc",
            rag_context="",
            context={"chat_history": []},
            doc_type="ARCHITECTURE_DESIGN",
            retrieved_context="",
        )
        assert "</retrieved_context>" not in prompt

    def test_retrieved_context_sandwiched_between_rag_and_rules(
        self, orchestrator: SequentialOrchestrator
    ) -> None:
        """Order must be: <rag_context> … <retrieved_context> … <critical_rules>."""
        prompt = orchestrator._build_prompt(
            injection_block="",
            user_input="some input",
            rag_context="<rag_context>kb data</rag_context>",
            context={"chat_history": []},
            doc_type="DOMAIN_LANGUAGE",
            retrieved_context="<retrieved_context>\nproject info\n</retrieved_context>",
        )
        rag_pos = prompt.index("<rag_context>")
        ctx_pos = prompt.index("<retrieved_context>")
        rules_pos = prompt.index("<critical_rules>")
        assert (
            rag_pos < ctx_pos < rules_pos
        ), "Sections must appear in order: rag_context, retrieved_context, critical_rules"
