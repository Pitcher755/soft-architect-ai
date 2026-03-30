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
  — 13 integration tests (12 from PIT-142 + 1 bonus for `get_step_by_type`).

**Strategy:** Real `SequentialOrchestrator` instantiation + fully mocked
external dependencies (LLM client, vector store, per-project ChromaDB).
The integration layer tests the actual wiring between the orchestrator,
`MASTER_WORKFLOW`, `CONTEXT_DEPENDENCIES`, `WorkflowInjector`, and the
dual RAG channel pipeline.

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

**Result:** ✅ 13/13 passed in 0.13s

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

```
tests/server/integration/services/rag/
├── conftest.py                              [NEW] Google SDK patches
└── test_sequential_orchestrator_integration.py  [NEW] 13 integration tests
```
