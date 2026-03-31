# HU-5.1-05 — SequentialOrchestrator Integration Tests

> **Date:** 31/03/2026
> **Status:** ✅ Completed
> **Branch:** `feature/hu-5.1-sequential-orchestrator-integration-tests`
> **Linear ticket:** [PIT-142](https://linear.app/pitcherdev/issue/PIT-142)

## 📋 Table of Contents

1. [Overview](#overview)
2. [Motivation](#motivation)
3. [Implementation](#implementation)
4. [Test Suite](#test-suite)
5. [Coverage](#coverage)
6. [Files Changed](#files-changed)

---

## Overview

This User Story reinforces the integration test coverage for the
`SequentialOrchestrator` — the core production service that drives the
sequential generation of 24 architecture documents (the Master Workflow 0→100).

The integration test file fills the gap identified in the audit:
`tests/server/integration/services/rag/` was completely empty (only
`__init__.py`), while `tests/server/e2e/test_full_workflow_e2e.py` was
pointing at the **legacy** `RAGOrchestrator` instead of `SequentialOrchestrator`.

---

## Motivation

**Gap discovered:** No integration tests for `SequentialOrchestrator` existed.

| Risk | Description |
|------|-------------|
| Silent CI failures | `continue-on-error: true` in CI for integration tests |
| Legacy E2E coverage | E2E tests targeted `RAGOrchestrator` (deprecated) |
| No cross-phase validation | Nothing tested the 24-step state machine end-to-end |
| No resilience coverage | Dual RAG channel failure paths were untested at integration level |

---

## Implementation

**New files:**

- `tests/server/integration/services/rag/conftest.py` — Google SDK patches
  (mirrors `tests/server/services/rag/conftest.py` pattern, required because
  pytest does not propagate conftest.py across non-ancestor directories).

- `tests/server/integration/services/rag/test_sequential_orchestrator_integration.py`
  — 19 integration tests covering all PIT-142 acceptance criteria + 6 additional
  edge-case scenarios for full branch coverage.

**Strategy:** Real `SequentialOrchestrator` instantiation + fully mocked
external dependencies (LLM client, vector store, per-project ChromaDB).
The integration layer tests the actual wiring between the orchestrator,
`MASTER_WORKFLOW`, `CONTEXT_DEPENDENCIES`, `WorkflowInjector`, and the
dual RAG channel pipeline.

**Additional scope (Session 3-4):** Beyond the integration tests, all
pre-existing failures, skips, and warnings across both server (Python) and
client (Flutter) test suites were fixed to achieve a fully green CI state.

---

## Test Suite

| # | Test name | Scenario |
|---|-----------|----------|
| 1 | `test_full_24_document_generation_flow` | All 24 doc_types in MASTER_WORKFLOW yield tokens |
| 2 | `test_state_transitions_between_phases` | `get_next_step()` chains all 6 phases correctly |
| 3 | `test_get_step_by_type_returns_correct_step_for_all_24_types` | `get_step_by_type()` resolves all 24 types |
| 4 | `test_llm_error_at_step_14_does_not_corrupt_orchestrator_state` | LLMError at DESIGN_SYSTEM, recovery on next call |
| 5 | `test_llm_timeout_does_not_corrupt_project_history` | TimeoutError mid-stream → LLMError, instance survives |
| 6 | `test_chromadb_connection_failure_graceful_degradation` | ConnectionError → tokens still yielded |
| 7 | `test_rag_retrieval_failure_does_not_block_generation` | VectorStoreError both channels → generation continues |
| 8 | `test_rag_context_accumulates_across_phases` | chat_history injected as `<conversation_history>` |
| 9 | `test_context_dependencies_graph_respected` | CONTEXT_DEPENDENCIES graph: complete, valid, acyclic roots |
| 10 | `test_prompt_hard_cap_not_exceeded` | 4× oversized input silently capped at `_MAX_PROMPT_CHARS` |
| 11 | `test_generate_produces_streaming_tokens` | 10 tokens yielded in exact order, WorkflowInjector called once |
| 12 | `test_dual_rag_channel_injection` | Both `<rag_context>` and `<retrieved_context>` in prompt |
| 13 | `test_concurrent_generate_calls_do_not_interfere` | Parallel `gather()` produces independent token streams |
| 14 | `test_empty_injection_block_falls_back_gracefully` | Empty `WorkflowInjector` → RAG-only fallback |
| 15 | `test_extract_docs_text_empty_result_produces_no_rag_context` | Empty query → no `<rag_context>` block |
| 16 | `test_extract_docs_text_flat_string_docs_included_in_context` | Flat string docs → `flat.append` branch |
| 17 | `test_project_store_empty_chunks_produces_no_retrieved_context` | Empty chunks → no `<retrieved_context>` |
| 18 | `test_build_project_documents_block_budget_and_truncation` | Budget/truncation edge cases (6 sub-assertions) |
| 19 | `test_history_long_user_message_is_truncated_in_prompt` | User message >1000 chars → `[text truncated]` |

**Result:** ✅ 19/19 passed — 98% coverage on `sequential_orchestrator.py`

---

## Coverage

Integration tests now cover:

- ✅ Full 0→24 document generation pipeline
- ✅ MASTER_WORKFLOW phase transitions (all 6 phases)
- ✅ Resilience: LLM failures (RuntimeError, asyncio.TimeoutError)
- ✅ Resilience: Storage failures (ConnectionError, VectorStoreError)
- ✅ Dual RAG channel (global KB + per-project ChromaDB)
- ✅ Prompt hard-cap safety (200K chars)
- ✅ Context dependency graph integrity
- ✅ Concurrency safety

---

## Files Changed

### New files

```
tests/server/integration/services/rag/
├── conftest.py                              [NEW] Google SDK patches
└── test_sequential_orchestrator_integration.py  [NEW] 19 integration tests
```

### Modified files (suite-wide fixes)

| File | Change |
|------|--------|
| `tests/server/conftest.py` | `_patch_google_sdk()` for cryptography/gRPC/OpenTelemetry |
| `tests/server/services/rag/test_sequential_orchestrator.py` | `n_results=5→3` alignment |
| `tests/server/integration/api/v1/test_chat_endpoints.py` | Added `get_rag_orchestrator` dependency override |
| `tests/server/integration/api/v1/test_chat_stream_endpoint.py` | Rewritten with FastAPI `dependency_overrides` |
| `tests/server/integration/api/v1/test_chat_history_integration.py` | MagicMock orchestrator override |
| `tests/server/integration/test_sqlite_persistence.py` | Removed `@pytest.mark.skip`, rewrote assertions |
| `tests/server/e2e/test_validation_blocker_e2e.py` | `AsyncMock→MagicMock` for sync methods |
| `tests/client/.../chat_notifier_test.dart` | Test isolation (unique `/tmp/` paths), epic completion rewrite |
| `tests/client/.../chat_flow_test.dart` | Removed `integration_test` import from placeholder |

### Full suite results

| Suite | Passed | Failed | Skipped | Warnings |
|-------|--------|--------|---------|----------|
| **Server** (pytest) | 791 | 0 | 0 | 0 |
| **Client** (flutter test) | 959 | 0 | 0 | 0 |
| **Total** | **1750** | **0** | **0** | **0** |

### Commits

| Hash | Message |
|------|---------|
| `3629043` | feat(tests): add integration tests for SequentialOrchestrator |
| `bb798b8` | test(coverage): raise integration test coverage to 98% |
| `152806e` | fix: resolve all test failures, skips, and warnings across server and client |
| `14a1cb9` | fix(tests): resolve Pyright type errors in integration tests |
