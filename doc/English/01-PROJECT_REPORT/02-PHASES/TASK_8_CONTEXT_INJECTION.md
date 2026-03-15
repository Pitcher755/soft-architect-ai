# Task 8 Completion Report — LLM Context Injection (Project Documents Pipeline)

> **Date:** 2026-06-17
> **Status:** ✅ **COMPLETE 100%**
> **Branch:** `feature/hu-5.0-full-workflow-refinement`
> **Scope:** Full-stack — Flutter client + FastAPI backend

---

## Table of Contents

1. [Executive Summary](#executive-summary)
2. [Problem Diagnosis](#problem-diagnosis)
3. [Solution Architecture](#solution-architecture)
4. [Files Changed](#files-changed)
5. [Test Coverage](#test-coverage)
6. [Quality Gates](#quality-gates)
7. [Lessons Learned](#lessons-learned)

---

## Executive Summary

Task 8 closes a **critical silent data loss bug** that caused the LLM to "forget"
all documents generated earlier in a session.  The Flutter client was already
gathering project context correctly, but **three layers of the backend silently
dropped the data** before it reached the LLM prompt.

All three gaps have been repaired.  The LLM now receives every already-generated
document as an XML-tagged block (`<project_documents>`) inside each prompt,
providing authoritative ground truth that prevents inconsistent content
(mismatched project names, different tech stacks, wrong language).

**Result:** End-to-end pipeline fully operational.  22 new backend unit tests
added, all quality gates green.

---

## Problem Diagnosis

### The Chain (Flutter → FastAPI → LLM)

```
Flutter ChatNotifier.sendMessage()
  └─ gatherProjectContext()          ← reads all .md / .json files from disk
  └─ ChatRepositoryImpl.sendMessageStream(projectContext: ...)
       └─ POST /api/v1/chat/stream   ← HTTP body includes project_context map
            └─ ChatRequest (Pydantic)    ← ❌ BUG 1: missing field
            └─ /stream endpoint          ← ❌ BUG 2: field not forwarded
            └─ SequentialOrchestrator
                 └─ _build_prompt()      ← ❌ BUG 3: never read from context dict
                 └─ LLM call
```

### The Three Bugs

| # | File | Bug |
|---|------|-----|
| 1 | `chat_schema.py` | `ChatRequest` Pydantic model was missing the `project_context` field entirely — data was silently discarded by Pydantic validation |
| 2 | `chat.py` | The `/stream` endpoint passed only `chat_history`, `project_id`, and `user_name` to the orchestrator context dict — `project_context` was never forwarded |
| 3 | `sequential_orchestrator.py` | `_build_prompt()` never read `project_context` from the context dict, so even if the previous bugs had been fixed the LLM would still not see the documents |

---

## Solution Architecture

### New Data Flow

```
project_context: dict[str, str]
   │
   ├─ ChatRequest.project_context    (Pydantic field, default={})
   │
   ├─ /stream context dict           ("project_context": request.project_context)
   │
   └─ _build_project_documents_block(project_context)
         │
         ├─ Skips empty dicts → returns ""
         ├─ Truncates each doc to _MAX_DOC_CHARS (3 000 chars)
         ├─ Stops adding files after _MAX_TOTAL_CONTEXT_CHARS (12 000 chars)
         └─ Returns <project_documents> XML block
              │
              └─ Injected into _build_prompt() between RAG context and critical_rules
```

### Prompt Injection Order

1. `injection_block`  — Workflow template + example (from WorkflowInjector)
2. `rag_context`      — Knowledge-base RAG chunks
3. `project_documents`— **NEW** Already-generated project documents (Task 8)
4. `critical_rules`   — Output format constraints (rule 8 added: consistency)
5. `conversation_history` — Last 4 messages
6. `user_input`       — Current user request

### Budget Constants

| Constant | Value | Purpose |
|----------|-------|---------|
| `_MAX_DOC_CHARS` | 3 000 | Per-file truncation limit |
| `_MAX_TOTAL_CONTEXT_CHARS` | 12 000 | Total block cap (context-window safety) |

---

## Files Changed

### Backend — Python FastAPI

#### `src/server/app/domain/schemas/chat_schema.py`
```python
# Added field to ChatRequest (was completely absent before)
project_context: dict[str, str] = Field(
    default_factory=dict,
    description=(
        "Complete project context: all .md/.json files already generated "
        "for this specific project (context/ folder + root). Used by the "
        "LLM orchestrator to maintain consistency across all documents."
    ),
)
```

#### `src/server/app/api/v1/chat.py`
```python
# Added to context dict in /stream endpoint  (was missing entirely)
"project_context": request.project_context,  # Task 8: prevent LLM amnesia
```

#### `src/server/app/services/rag/sequential_orchestrator.py`
- Added module-level docstring describing the orchestration contract.
- Added constants `_MAX_DOC_CHARS = 3_000` and `_MAX_TOTAL_CONTEXT_CHARS = 12_000`.
- Added method `_build_project_documents_block(project_context: dict[str, str]) -> str`
  with full PyDoc, per-document truncation, total budget guard, and XML serialization.
- Rewrote `_build_prompt()` to extract `project_context` from the context dict,
  call `_build_project_documents_block()`, and inject the result if non-empty.
- Added critical rule #8: LLM must be 100% consistent with `<project_documents>`.

### New Test Files — Python

#### `tests/server/services/rag/test_sequential_orchestrator.py`
22 unit tests across 4 test classes:

| Class | Tests | Coverage Focus |
|-------|-------|----------------|
| `TestBuildProjectDocumentsBlock` | 9 | XML structure, truncation, budget guard, consistency instruction |
| `TestBuildPromptProjectContext` | 7 | Block presence/absence, ordering, rule 8, non-dict graceful handling |
| `TestGenerateWithProjectContext` | 3 | Streaming with/without context, LLM prompt spy |
| `TestChatRequestSchema` | 2 | Schema accepts field, defaults to empty dict |

#### `tests/server/services/rag/conftest.py`
- Stubs the broken `google.generativeai` / `google.api_core` / `cryptography`
  import chain that causes `ImportError` in the test venv.
- Uses `_make_package()` helper that sets `__path__` so Python allows sub-imports.
- Applied at collection time (executed before any test file is imported).

---

## Test Coverage

```
tests/server/services/rag/test_sequential_orchestrator.py
====================== 22 passed in 0.12s ========================
```

All previous Flutter tests remain green:
- Unit tests: 143 passed
- Integration tests: 4 passed, 2 skipped

---

## Quality Gates

| Gate | Tool | Result |
|------|------|--------|
| Format | `black` | ✅ Reformatted `sequential_orchestrator.py` |
| Lint | `ruff` | ✅ All checks passed |
| Types | `pyright` | ✅ 0 errors, 0 warnings |
| Dart lint | `flutter analyze` | ✅ No issues found |
| Unit tests | `pytest` | ✅ 22/22 passed |

---

## Lessons Learned

1. **Interface contracts must be validated end-to-end.**  The Flutter client sent data
   correctly, but each intermediate layer silently dropped it.  A contract test at
   the HTTP schema boundary would have caught this immediately.

2. **A `default_factory=dict` guard in Pydantic is not sufficient.**  The field must
   first _exist_ in the schema.  Missing fields are dropped by Pydantic without error.

3. **Token-budget guards belong at the injection layer, not the caller.**  The
   `_build_project_documents_block()` method owns the truncation logic so no caller
   can accidentally overflow the context window.

4. **Test assertions must be precise.**  Two tests initially checked
   `"<project_documents>" not in prompt`, but that string also appears literally inside
   the critical_rules text (rule 8).  Fixed by asserting on `"</project_documents>"`
   (closing tag), which only the actual XML block emits.
