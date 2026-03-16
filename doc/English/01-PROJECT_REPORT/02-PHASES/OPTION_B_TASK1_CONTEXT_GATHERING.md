# Option B — Task 1: Context Gathering (Frontend)

> **Category:** 01-PROJECT_REPORT / 02-PHASES
> **Date:** 2026-03-16
> **Status:** ✅ Completed
> **Branch:** `feature/hu-5.0-full-workflow-refinement`
> **Scope:** Static Dependency Graph context injection — Flutter ↔ Python pipeline

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Implemented Changes](#implemented-changes)
   - [2.1 ProjectProgressService.gatherProjectContext()](#21-projectprogressservicegatherprojectcontext)
   - [2.2 ChatNotifier.sendMessageStream()](#22-chatnotifiersendmessagestream)
   - [2.3 ChatRepository Interface](#23-chatrepository-interface)
   - [2.4 ChatRepositoryImpl.sendMessageStream()](#24-chatrepositoryimplsendmessagestream)
   - [2.5 Backend: Adaptive Budget Guard](#25-backend-adaptive-budget-guard)
   - [2.6 Backend: _buildHistoryText() Helper](#26-backend-_buildhistorytext-helper)
3. [Test Coverage](#test-coverage)
4. [Quality Gates](#quality-gates)
5. [Architecture Decision](#architecture-decision)
6. [Data Flow Diagram](#data-flow-diagram)

---

## Overview

This task implements the **Frontend Context Gathering** component of the Static Dependency Graph strategy (Option B, ADR-002).

Before this task, the Flutter frontend sent only the user message to the backend.
After this task, each request also carries `project_context`: a `Map<String, String>` of relative file paths → file contents for all `.md` and `.json` files in the target project directory.

This closes the **LLM amnesia loop**: even though each HTTP request is stateless, the AI now receives the documents it already generated for this specific project and can maintain consistency (project name, tech stack, domain vocabulary, language) across all 24 workflow steps.

---

## Implemented Changes

### 2.1 ProjectProgressService.gatherProjectContext()

**File:** [src/client/lib/features/project_shell/infrastructure/services/project_progress_service.dart](../../../../src/client/lib/features/project_shell/infrastructure/services/project_progress_service.dart)

**Signature:**
```dart
static Future<Map<String, String>> gatherProjectContext(String projectPath)
```

**Behaviour:**
- Returns `{}` immediately for mock projects (`mock://` prefix) — no I/O cost.
- Recursively scans `<projectPath>/context/` for `.md` and `.json` files, excluding `readme` and `untitled` patterns.
- Reads the 4 ROOT-phase documents from the project root: `RULES.md`, `CONTRIBUTING.md`, `AGENTS.md`, `README.md`.
- Uses **relative paths** as keys (e.g. `context/10-CONTEXT/PROJECT_MANIFESTO.md`) so the backend can resolve them against the `MASTER_WORKFLOW` dependency graph.
- Non-fatal: individual `FileSystemException` errors are caught per-file and logged; the map is returned with the successfully-read files.

```dart
final context = await ProjectProgressService.gatherProjectContext(projectPath);
// Returns e.g.:
// {
//   'context/10-CONTEXT/PROJECT_MANIFESTO.md': '# Project Manifest\n...',
//   'context/20-REQUIREMENTS/REQUIREMENTS_MASTER.md': '# Requirements\n...',
//   'RULES.md': '# Development Rules\n...',
// }
```

### 2.2 ChatNotifier.sendMessageStream()

**File:** [src/client/lib/features/chat/presentation/notifiers/chat_notifier.dart](../../../../src/client/lib/features/chat/presentation/notifiers/chat_notifier.dart)

`sendMessageStream` calls `gatherProjectContext` before dispatching the stream request:

```dart
// 🧠 Gather complete project context for AI injection (Option B)
final projectContext = await ProjectProgressService.gatherProjectContext(
  projectPath,
);

final stream = repository.sendMessageStream(
  message,
  projectId,
  docType: currentDocType,
  userName: currentUserName,
  history: compatibleHistory,
  projectContext: projectContext,     // ← injected here
);
```

**Key design decisions:**
- The call is `await`-ed before streaming begins; the minimal I/O delay (reading a few KB files) is preferable to the complexity of a streaming race condition.
- Mock projects return early with `{}` so guide-mode UX is unaffected.

### 2.3 ChatRepository Interface

**File:** [src/client/lib/features/chat/domain/repositories/chat_repository.dart](../../../../src/client/lib/features/chat/domain/repositories/chat_repository.dart)

The interface already declared `projectContext` as an optional named parameter:

```dart
Stream<ChatStreamEvent> sendMessageStream(
  String message,
  String projectId, {
  String? docType,
  String? userName,
  List<ChatMessage>? history,
  Map<String, String>? projectContext,  // ← context injection
});
```

No changes required; the contract was established in Task 8.

### 2.4 ChatRepositoryImpl.sendMessageStream()

**File:** [src/client/lib/features/chat/data/repositories/chat_repository_impl.dart](../../../../src/client/lib/features/chat/data/repositories/chat_repository_impl.dart)

The implementation serializes the map into the request body conditionally (present only when non-null and non-empty), preserving backward compatibility with backends that do not yet consume it:

```dart
final body = {
  'message': message,
  'project_id': projectId,
  // ...
  if (projectContext != null && projectContext.isNotEmpty)
    'project_context': projectContext,
};
```

### 2.5 Backend: Adaptive Budget Guard

**File:** [src/server/app/services/rag/sequential_orchestrator.py](../../../../src/server/app/services/rag/sequential_orchestrator.py)

Resolves the root cause of the HTTP 500 Gemini errors at document 5+.

#### Two-stage context injection:

**Stage 1 — Dependency-graph filtering (`_filter_relevant_context`)**

Reduces the full `project_context` map to ONLY the 2-4 files that are direct predecessors of the current `doc_type` as declared in `CONTEXT_DEPENDENCIES` (workflow.py):

```python
# For DOMAIN_LANGUAGE:  needs ["PROJECT_MANIFESTO"]
# For USER_STORIES:     needs ["PROJECT_MANIFESTO", "DOMAIN_LANGUAGE", "REQUIREMENTS_MASTER"]
needed_types: list[str] = get_context_dependencies(doc_type)
```

This bounds the `<project_documents>` block to a constant size regardless of workflow progress.

**Stage 2 — Adaptive character budget (`_build_prompt`)**

Measures all other sections before computing the remaining allowance for project documents:

```python
static_sections_chars = (
    len(injection_block) + len(rag_context) +
    len(history_text) + len(user_input) + 2_000  # overhead
)
adaptive_budget = min(
    max(0, _MAX_PROMPT_CHARS - static_sections_chars),
    _MAX_TOTAL_CONTEXT_CHARS,
)
```

**Safety net:** if the final assembled prompt still exceeds `_MAX_PROMPT_CHARS`, the `<project_documents>` block is dropped in favour of delivering a valid (if less context-rich) response instead of a Gemini 500 error.

#### Constants introduced:

| Constant | Value | Purpose |
|---|---|---|
| `_MAX_DOC_CHARS` | 1 200 | Per-file truncation limit |
| `_MAX_TOTAL_CONTEXT_CHARS` | 4 800 | Hard cap for entire `<project_documents>` block |
| `_MAX_PROMPT_CHARS` | 60 000 | Hard prompt ceiling (~15 k tokens, Gemini free tier safe) |

### 2.6 Backend: _buildHistoryText() Helper

Extracted the history-serialization logic from `_build_prompt` into a dedicated private method to reduce cyclomatic complexity (previously C901: 11 > 10):

```python
def _build_history_text(self, raw_history: Any) -> str:
    """Serialize chat history to a compact string for LLM injection.
    Keeps the last 4 messages.  Large assistant responses are replaced
    by a short placeholder to avoid saturating the context window.
    """
```

---

## Test Coverage

### Flutter (Dart)

| File | New Tests | Focus |
|---|---|---|
| `project_progress_service_test.dart` | 9 | `gatherProjectContext`: .md scan, .json scan, ROOT files, README exclusion, untitled exclusion, recursive scan, mock skip, missing context/, error handling, relative keys |
| `chat_notifier_test.dart` | 0 new (143 existing pass) | Full notifier lifecycle including `sendMessageStream` with mock repos |

### Python

| File | New Tests | Focus |
|---|---|---|
| `test_sequential_orchestrator.py` | 21 new (43 total) | `_build_project_documents_block` custom budget / zero budget, `_build_prompt` hard cap safety net, `_filter_relevant_context` full suite (7 tests), `TestBuildPromptWithDependencyFiltering` (3 tests), `TestContextDependencies` (8 tests), graph validation tests |

---

## Quality Gates

| Gate | Result |
|---|---|
| `black` | ✅ Reformatted (all done) |
| `ruff check` | ✅ All checks passed |
| `pyright` | ✅ 0 errors, 0 warnings |
| `pytest` (43 tests) | ✅ 43 passed in 0.15s |
| `flutter analyze` | ✅ No issues found |
| Flutter tests (project_shell) | ✅ 264 passed |
| Flutter tests (chat) | ✅ 143 passed |

---

## Architecture Decision

This task implements **Option B (Static Dependency Graph)** as defined in [ADR-002](../01-ARCHITECTURE/ADR_002_LLM_CONTEXT_INJECTION_STRATEGY.md).

The graph is defined in `workflow.py` as `CONTEXT_DEPENDENCIES: dict[str, list[str]]` mapping each `doc_type` to the list of `doc_type` values of its required predecessors.

**Future evolution (Option A):** Once `VectorStoreService` has a live ChromaDB connection, `_filter_relevant_context()` in `sequential_orchestrator.py` will be replaced by a semantic query against a per-project vector collection, delivering richer context with lower token cost.

---

## Data Flow Diagram

```
Flutter (sendMessageStream)
  │
  ├── await gatherProjectContext(projectPath)
  │     ├── scan context/ recursively (.md, .json)
  │     └── read ROOT docs (RULES.md, etc.)
  │         → Map<String, String> { "context/10-CONTEXT/PROJECT_MANIFESTO.md": "..." }
  │
  └── ChatRepositoryImpl.sendMessageStream(projectContext: context)
        │
        └── POST /api/v1/chat/stream
              body: { ..., "project_context": { "context/10-CONTEXT/PROJECT_MANIFESTO.md": "..." } }

FastAPI (/stream endpoint)
  │
  └── SequentialOrchestrator.generate(context={"project_context": {...}})
        │
        ├── _filter_relevant_context(project_context, doc_type)
        │     └── keep only 2-4 files matching CONTEXT_DEPENDENCIES[doc_type]
        │
        ├── _build_prompt(...)
        │     ├── compute adaptive_budget from remaining prompt headroom
        │     ├── _build_project_documents_block(relevant, budget=adaptive_budget)
        │     │     └── serialize to <project_documents>...</project_documents>
        │     └── safety net: drop block if prompt > _MAX_PROMPT_CHARS
        │
        └── llm_client.stream_generate(prompt)
              └── Gemini API → token stream → SSE → Flutter
```
