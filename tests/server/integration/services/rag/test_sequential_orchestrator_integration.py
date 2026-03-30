"""Integration tests for SequentialOrchestrator — Resilience 0→24 docs.

PIT-142 / HU-5.1-05
---------------------
These tests validate the **integration** between the SequentialOrchestrator
and the MASTER_WORKFLOW registry (24 steps, 6 phases), the CONTEXT_DEPENDENCIES
graph, the dual RAG channel (global KB + per-project ChromaDB), and the
resilience mechanisms that keep generation alive when external services fail.

Scope:
- Full 0→24 document generation flow using the real MASTER_WORKFLOW registry.
- Phase transition correctness via get_next_step / get_step_by_type helpers.
- LLMError mid-flow does NOT corrupt orchestrator state for subsequent calls.
- Timeout mid-stream raises LLMError without leaving the instance broken.
- ChromaDB connection failure → graceful degradation (tokens still yielded).
- VectorStoreError in both RAG channels → empty context, generation continues.
- RAG context accumulation across phases (chat_history injection).
- CONTEXT_DEPENDENCIES graph integrity (no unknown doc_types, acyclic roots).
- Prompt hard-cap (_MAX_PROMPT_CHARS) is honoured under extremely large inputs.
- Async generator produces ordered streaming tokens for a complete generate().
- Dual RAG channel injection: both <rag_context> and <retrieved_context> appear.
- Concurrent generate() calls on the same instance do not interfere.
"""

from __future__ import annotations

import asyncio
from collections.abc import AsyncGenerator
from unittest.mock import MagicMock

import pytest

from app.core.exceptions import LLMError
from app.domain.constants.workflow import (
    CONTEXT_DEPENDENCIES,
    MASTER_WORKFLOW,
    get_next_step,
    get_step_by_type,
)
from app.services.rag.sequential_orchestrator import (
    SequentialOrchestrator,
    _MAX_PROMPT_CHARS,
)

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

_ALL_DOC_TYPES: list[str] = [step.doc_type for step in MASTER_WORKFLOW]


async def _collect_tokens(gen: AsyncGenerator[str, None]) -> list[str]:
    """Drain an async generator and return all yielded strings."""
    return [token async for token in gen]


def _make_orchestrator(
    *,
    llm_tokens: list[str] | None = None,
    vs_docs: list[str] | None = None,
    vs_raises: Exception | None = None,
    project_chunks: list[str] | None = None,
    project_raises: Exception | None = None,
    injected_block: str = "# Template Block\nInstruction: generate {user_input}",
) -> SequentialOrchestrator:
    """Build a SequentialOrchestrator with fully mocked external dependencies.

    Args:
        llm_tokens: Tokens the mock LLM will yield for every stream_generate
                    call.  Defaults to ["token_A", "token_B"].
        vs_docs: Documents returned by the global vector store query.  When
                 None the store returns an empty document list.
        vs_raises: If set, the vector store query() raises this exception
                   instead of returning results.
        project_chunks: Chunks returned by the per-project store.
        project_raises: If set, query_project() raises this exception.
        injected_block: Content returned by WorkflowInjector.get_injected_prompt.

    Returns:
        A fully configured SequentialOrchestrator ready for integration testing.
    """
    if llm_tokens is None:
        llm_tokens = ["token_A", "token_B"]

    # ── LLM mock ─────────────────────────────────────────────────────────────
    async def _stream(prompt: str, history: list) -> AsyncGenerator[str, None]:
        for t in llm_tokens:
            yield t

    llm_client = MagicMock()
    llm_client.stream_generate = _stream

    # ── Global vector store mock ──────────────────────────────────────────────
    vector_store = MagicMock()
    if vs_raises is not None:
        vector_store.query.side_effect = vs_raises
    elif vs_docs is not None:
        vector_store.query.return_value = {"documents": [vs_docs], "metadatas": [[]]}
    else:
        vector_store.query.return_value = {"documents": [[]], "metadatas": [[]]}

    # ── Per-project ChromaDB store mock ───────────────────────────────────────
    project_store: MagicMock | None = None
    if project_chunks is not None or project_raises is not None:
        project_store = MagicMock()
        if project_raises is not None:
            project_store.query_project.side_effect = project_raises
        else:
            project_store.query_project.return_value = project_chunks or []

    # ── WorkflowInjector mock ─────────────────────────────────────────────────
    workflow_injector = MagicMock()
    workflow_injector.get_injected_prompt.return_value = injected_block

    return SequentialOrchestrator(
        vector_store=vector_store,
        llm_client=llm_client,
        template_loader=MagicMock(),
        workflow_injector=workflow_injector,
        project_store=project_store,
    )


# ---------------------------------------------------------------------------
# Test Suite
# ---------------------------------------------------------------------------


class TestSequentialOrchestratorIntegration:
    """Integration tests for SequentialOrchestrator — PIT-142 / HU-5.1-05."""

    # -----------------------------------------------------------------------
    # 1. Full 0→24 document generation flow
    # -----------------------------------------------------------------------

    @pytest.mark.asyncio
    async def test_full_24_document_generation_flow(self) -> None:
        """Each of the 24 MASTER_WORKFLOW doc_types must yield at least one token.

        Validates that the orchestrator, when driven through the complete
        registry in order, successfully produces streaming output for every
        step — from PROJECT_MANIFESTO (step 1) to README (step 24).
        """
        orchestrator = _make_orchestrator(llm_tokens=["chunk_1", "chunk_2"])

        for step in MASTER_WORKFLOW:
            tokens = await _collect_tokens(
                orchestrator.generate(
                    doc_type=step.doc_type,
                    user_input=f"Build project for step {step.step_number}",
                    context={"project_id": "test-proj-123"},
                )
            )
            assert (
                len(tokens) >= 1
            ), f"Step {step.step_number} ({step.doc_type}) produced no tokens"
            assert tokens == [
                "chunk_1",
                "chunk_2",
            ], f"Unexpected token stream for {step.doc_type}: {tokens}"

    # -----------------------------------------------------------------------
    # 2. Phase & step transitions
    # -----------------------------------------------------------------------

    def test_state_transitions_between_phases(self) -> None:
        """get_next_step() must correctly chain all 24→None transitions.

        Verifies the complete transition path across all 6 phases:
          Phase-1 (1-3) → Phase-2 (4-7) → Phase-3 (8-13) →
          Phase-4 (14-16) → Phase-5 (17-20) → Phase-6 (21-24) → None
        """
        for idx, step in enumerate(MASTER_WORKFLOW[:-1]):
            expected_next = MASTER_WORKFLOW[idx + 1]
            actual_next = get_next_step(step.doc_type)
            assert actual_next is not None, (
                f"get_next_step({step.doc_type!r}) returned None but "
                f"{expected_next.doc_type!r} is expected"
            )
            assert actual_next.doc_type == expected_next.doc_type, (
                f"Wrong next step after {step.doc_type!r}: "
                f"got {actual_next.doc_type!r}, expected {expected_next.doc_type!r}"
            )

        # Last step (README) must return None.
        assert get_next_step("README") is None, "get_next_step(README) must be None"

    def test_get_step_by_type_returns_correct_step_for_all_24_types(self) -> None:
        """Every doc_type in MASTER_WORKFLOW must be resolvable via get_step_by_type."""
        for step in MASTER_WORKFLOW:
            resolved = get_step_by_type(step.doc_type)
            assert (
                resolved is not None
            ), f"get_step_by_type({step.doc_type!r}) returned None"
            assert resolved.step_number == step.step_number
            assert resolved.doc_type == step.doc_type

    # -----------------------------------------------------------------------
    # 3. LLMError mid-flow does NOT corrupt state
    # -----------------------------------------------------------------------

    @pytest.mark.asyncio
    async def test_llm_error_at_step_14_does_not_corrupt_orchestrator_state(
        self,
    ) -> None:
        """LLMError at DESIGN_SYSTEM (step 14) must not break subsequent calls.

        After absorbing the error the caller can safely invoke generate() again
        for a different step and receive a valid token stream.
        """
        call_count = 0

        async def _failing_then_ok(
            prompt: str, history: list
        ) -> AsyncGenerator[str, None]:
            nonlocal call_count
            call_count += 1
            if call_count == 1:
                raise RuntimeError("simulated LLM API failure at step 14")
            yield "recovery_token"

        orchestrator = _make_orchestrator()
        orchestrator.llm_client.stream_generate = _failing_then_ok

        # Step 14: DESIGN_SYSTEM — first call raises
        with pytest.raises(LLMError) as exc_info:
            await _collect_tokens(
                orchestrator.generate(
                    doc_type="DESIGN_SYSTEM",
                    user_input="app design",
                    context={"project_id": "proj-001"},
                )
            )
        assert exc_info.value.code == "SEQ_GEN_ERR"

        # Step 15: UI_WIREFRAMES_FLOW — second call must succeed
        tokens = await _collect_tokens(
            orchestrator.generate(
                doc_type="UI_WIREFRAMES_FLOW",
                user_input="app design",
                context={"project_id": "proj-001"},
            )
        )
        assert tokens == [
            "recovery_token"
        ], "Orchestrator state corrupted after LLMError at step 14"

    # -----------------------------------------------------------------------
    # 4. Timeout mid-stream does NOT corrupt state
    # -----------------------------------------------------------------------

    @pytest.mark.asyncio
    async def test_llm_timeout_does_not_corrupt_project_history(self) -> None:
        """asyncio.TimeoutError mid-stream must raise LLMError, not break instance.

        Simulates a network timeout that fires after the first token is yielded.
        The orchestrator should expose this as LLMError(code=SEQ_GEN_ERR) and
        the instance must remain operational for subsequent calls.
        """

        async def _timeout_after_first(
            prompt: str, history: list
        ) -> AsyncGenerator[str, None]:
            yield "first_token"
            raise asyncio.TimeoutError("LLM response timed out")

        orchestrator = _make_orchestrator()
        orchestrator.llm_client.stream_generate = _timeout_after_first

        with pytest.raises(LLMError) as exc_info:
            await _collect_tokens(
                orchestrator.generate(
                    doc_type="REQUIREMENTS_MASTER",
                    user_input="build app",
                    context={"project_id": "proj-timeout"},
                )
            )
        assert exc_info.value.code == "SEQ_GEN_ERR"

        # Subsequent call with normal LLM must succeed
        orchestrator.llm_client.stream_generate = (
            lambda p, history=None: _async_gen_from(["ok_token"])
        )
        tokens = await _collect_tokens(
            orchestrator.generate(
                doc_type="REQUIREMENTS_MASTER",
                user_input="build app",
                context={"project_id": "proj-timeout"},
            )
        )
        assert tokens == ["ok_token"]

    # -----------------------------------------------------------------------
    # 5. ChromaDB connection failure → graceful degradation
    # -----------------------------------------------------------------------

    @pytest.mark.asyncio
    async def test_chromadb_connection_failure_graceful_degradation(self) -> None:
        """Global vector store ConnectionError must NOT raise LLMError.

        Graceful degradation: the orchestrator continues with an empty
        <rag_context> block and yields LLM tokens normally.
        """
        orchestrator = _make_orchestrator(
            vs_raises=ConnectionError("ChromaDB unreachable — TCP refused on :8000"),
            llm_tokens=["degraded_token_1", "degraded_token_2"],
        )

        tokens = await _collect_tokens(
            orchestrator.generate(
                doc_type="TECH_STACK_DECISION",
                user_input="tech stack selection",
                context={"project_id": "proj-degraded"},
            )
        )

        assert tokens == [
            "degraded_token_1",
            "degraded_token_2",
        ], "Graceful degradation failed: expected tokens despite ChromaDB failure"

    # -----------------------------------------------------------------------
    # 6. VectorStoreError in both RAG channels does not block generation
    # -----------------------------------------------------------------------

    @pytest.mark.asyncio
    async def test_rag_retrieval_failure_does_not_block_generation(self) -> None:
        """VectorStoreError in global KB AND per-project store must not raise.

        Both RAG channels fail. The orchestrator falls back to empty context
        strings and the LLM receives the bare prompt — tokens still yielded.
        """
        from app.core.exceptions import VectorStoreError

        orchestrator = _make_orchestrator(
            vs_raises=VectorStoreError(
                code="RAG_001", message="index corrupted", status_code=500
            ),
            project_chunks=None,
            project_raises=VectorStoreError(
                code="RAG_001", message="project collection missing", status_code=500
            ),
            llm_tokens=["bare_token"],
        )

        tokens = await _collect_tokens(
            orchestrator.generate(
                doc_type="DATA_MODEL_SCHEMA",
                user_input="define data model",
                context={"project_id": "proj-rag-fail"},
            )
        )

        assert tokens == ["bare_token"]

    # -----------------------------------------------------------------------
    # 7. RAG context accumulates across phases via chat_history
    # -----------------------------------------------------------------------

    @pytest.mark.asyncio
    async def test_rag_context_accumulates_across_phases(self) -> None:
        """Chat history injection carries previous phase output into the prompt.

        A context dict containing a non-empty chat_history list must result in
        a prompt that includes the <conversation_history> section with the
        provided messages, enabling cross-phase context accumulation.
        """
        captured_prompts: list[str] = []

        async def _capture_prompt(
            prompt: str, history: list
        ) -> AsyncGenerator[str, None]:
            captured_prompts.append(prompt)
            yield "ok"

        orchestrator = _make_orchestrator()
        orchestrator.llm_client.stream_generate = _capture_prompt

        history = [
            {"role": "user", "content": "Build a Flutter app"},
            {
                "role": "assistant",
                "content": "**Path:** context/10-CONTEXT/PROJECT_MANIFESTO.md\n# Manifesto...",
            },
        ]

        await _collect_tokens(
            orchestrator.generate(
                doc_type="DOMAIN_LANGUAGE",
                user_input="Define domain terms",
                context={
                    "project_id": "proj-history",
                    "chat_history": history,
                },
            )
        )

        assert len(captured_prompts) == 1
        prompt = captured_prompts[0]
        assert (
            "<conversation_history>" in prompt
        ), "chat_history not injected as <conversation_history> block"
        # Large assistant documents should be replaced by the placeholder
        assert "[Previous document generated and saved successfully." in prompt

    # -----------------------------------------------------------------------
    # 8. CONTEXT_DEPENDENCIES graph integrity
    # -----------------------------------------------------------------------

    def test_context_dependencies_graph_respected(self) -> None:
        """CONTEXT_DEPENDENCIES must be a valid graph over the 24 MASTER_WORKFLOW types.

        Invariants checked:
        - Every doc_type in MASTER_WORKFLOW appears as a key in CONTEXT_DEPENDENCIES.
        - Every dependency value references a doc_type that also exists in the workflow.
        - PROJECT_MANIFESTO has no dependencies (root node).
        - README has non-empty dependencies (leaf node always has parents).
        """
        all_types = set(_ALL_DOC_TYPES)

        # All 24 workflow types must be keys in the dependency map.
        for doc_type in _ALL_DOC_TYPES:
            assert (
                doc_type in CONTEXT_DEPENDENCIES
            ), f"{doc_type!r} not found in CONTEXT_DEPENDENCIES"

        # Every listed dependency must itself be a registered workflow type.
        for doc_type, deps in CONTEXT_DEPENDENCIES.items():
            for dep in deps:
                assert (
                    dep in all_types
                ), f"Unknown dependency {dep!r} listed for {doc_type!r}"

        # Root node: PROJECT_MANIFESTO needs no prior documents.
        assert (
            CONTEXT_DEPENDENCIES["PROJECT_MANIFESTO"] == []
        ), "PROJECT_MANIFESTO must have no dependencies (root of the graph)"

        # Leaf node: README synthesises the whole project — must have parents.
        assert (
            len(CONTEXT_DEPENDENCIES["README"]) > 0
        ), "README must declare at least one dependency"

    # -----------------------------------------------------------------------
    # 9. Prompt hard-cap is never exceeded
    # -----------------------------------------------------------------------

    @pytest.mark.asyncio
    async def test_prompt_hard_cap_not_exceeded(self) -> None:
        """A massive injection block must be silently truncated to _MAX_PROMPT_CHARS.

        Injects an injected_block that is 4× the allowed cap so that the
        assembled prompt would exceed _MAX_PROMPT_CHARS. After generation the
        prompt received by the LLM client must be ≤ _MAX_PROMPT_CHARS chars.
        """
        huge_block = "X" * (_MAX_PROMPT_CHARS * 4)
        captured_prompts: list[str] = []

        async def _capture(prompt: str, history: list) -> AsyncGenerator[str, None]:
            captured_prompts.append(prompt)
            yield "cap_token"

        orchestrator = _make_orchestrator(
            injected_block=huge_block,
            vs_docs=["some rag context"],
        )
        orchestrator.llm_client.stream_generate = _capture

        await _collect_tokens(
            orchestrator.generate(
                doc_type="PROJECT_MANIFESTO",
                user_input="huge project",
                context={"project_id": "proj-cap"},
            )
        )

        assert len(captured_prompts) == 1
        assert (
            len(captured_prompts[0]) <= _MAX_PROMPT_CHARS
        ), f"Prompt exceeded hard cap: {len(captured_prompts[0])} > {_MAX_PROMPT_CHARS}"

    # -----------------------------------------------------------------------
    # 10. Streaming tokens are produced and ordered
    # -----------------------------------------------------------------------

    @pytest.mark.asyncio
    async def test_generate_produces_streaming_tokens(self) -> None:
        """generate() must yield every token in the exact order the LLM emits them.

        Validates that the async generator pass-through from stream_generate
        does not reorder, drop, or duplicate tokens.
        """
        expected = [f"word_{i}" for i in range(10)]
        orchestrator = _make_orchestrator(llm_tokens=expected)

        tokens = await _collect_tokens(
            orchestrator.generate(
                doc_type="PROJECT_MANIFESTO",
                user_input="streaming test",
                context={"project_id": "proj-stream"},
            )
        )

        assert (
            tokens == expected
        ), f"Token order/content mismatch. Expected {expected}, got {tokens}"
        # WorkflowInjector must have been called exactly once per generate()
        orchestrator.workflow_injector.get_injected_prompt.assert_called_once_with(
            "PROJECT_MANIFESTO"
        )

    # -----------------------------------------------------------------------
    # 11. Dual RAG channel injection — both XML tags present in prompt
    # -----------------------------------------------------------------------

    @pytest.mark.asyncio
    async def test_dual_rag_channel_injection(self) -> None:
        """Both <rag_context> and <retrieved_context> tags must appear in the prompt.

        Configures:
        - Global KB (vector_store) to return a real document.
        - Per-project store (project_store) to return two semantic chunks.

        The assembled prompt captured from stream_generate must contain both
        XML blocks, proving that the dual-channel RAG strategy is active.
        """
        captured_prompts: list[str] = []

        async def _capture(prompt: str, history: list) -> AsyncGenerator[str, None]:
            captured_prompts.append(prompt)
            yield "dual_token"

        orchestrator = _make_orchestrator(
            vs_docs=["Global KB: Flutter best practices for clean architecture"],
            project_chunks=[
                "Project context: The app is called SoftArchitect AI",
                "Stack: Flutter 3.19, Python 3.12, ChromaDB, Ollama",
            ],
        )
        orchestrator.llm_client.stream_generate = _capture

        await _collect_tokens(
            orchestrator.generate(
                doc_type="DOMAIN_LANGUAGE",
                user_input="define domain language",
                context={"project_id": "proj-dual-rag"},
            )
        )

        assert len(captured_prompts) == 1
        prompt = captured_prompts[0]
        assert (
            "<rag_context>" in prompt
        ), "Global KB context block <rag_context> missing from prompt"
        assert (
            "<retrieved_context>" in prompt
        ), "Per-project context block <retrieved_context> missing from prompt"
        assert "Flutter best practices" in prompt
        assert "SoftArchitect AI" in prompt

    # -----------------------------------------------------------------------
    # 12. Concurrent generate() calls do not interfere
    # -----------------------------------------------------------------------

    @pytest.mark.asyncio
    async def test_concurrent_generate_calls_do_not_interfere(self) -> None:
        """Two simultaneous generate() coroutines must produce independent streams.

        Runs PROJECT_MANIFESTO and README in parallel on the same orchestrator
        instance.  Each task must receive its own distinct set of tokens with
        no cross-contamination.
        """
        tokens_by_doc: dict[str, list[str]] = {}

        async def _doc_specific(
            prompt: str, history: list
        ) -> AsyncGenerator[str, None]:
            # Identify which doc_type triggered this call from prompt content
            if "PROJECT_MANIFESTO" in prompt:
                for t in ["manifesto_1", "manifesto_2"]:
                    yield t
            else:
                for t in ["readme_1", "readme_2"]:
                    yield t

        orchestrator = _make_orchestrator(
            injected_block="# Template\n{user_input}",
        )
        orchestrator.workflow_injector.get_injected_prompt.side_effect = (
            lambda dt: f"[DocType: {dt}]"
        )
        orchestrator.llm_client.stream_generate = _doc_specific

        async def _run(doc_type: str, user_input: str) -> None:
            tokens = await _collect_tokens(
                orchestrator.generate(
                    doc_type=doc_type,
                    user_input=user_input,
                    context={"project_id": "proj-concurrent"},
                )
            )
            tokens_by_doc[doc_type] = tokens

        await asyncio.gather(
            _run("PROJECT_MANIFESTO", "concurrent manifesto"),
            _run("README", "concurrent readme"),
        )

        assert "PROJECT_MANIFESTO" in tokens_by_doc
        assert "README" in tokens_by_doc
        assert tokens_by_doc["PROJECT_MANIFESTO"] == ["manifesto_1", "manifesto_2"]
        assert tokens_by_doc["README"] == ["readme_1", "readme_2"]


# ---------------------------------------------------------------------------
# Private helper
# ---------------------------------------------------------------------------


async def _async_gen_from(items: list[str]) -> AsyncGenerator[str, None]:
    """Create an async generator from a list of strings (test helper)."""
    for item in items:
        yield item
