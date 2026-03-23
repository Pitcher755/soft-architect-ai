# ADR-002: Configurable RAG Limits via Environment Variables

> **Status:** ✅ Accepted
> **Date:** 2026-03-20
> **Deciders:** Development Team + ArchitectZero
> **Related HU:** HU-5.0 (Full Workflow Refinement — Task 16)

---

## 📋 Table of Contents

1. [Context](#context)
2. [Decision](#decision)
3. [Alternatives Considered](#alternatives-considered)
4. [Consequences](#consequences)
5. [Configuration Reference](#configuration-reference)
6. [Files Changed](#files-changed)
7. [References](#references)

---

## 📖 Context

### The Problem: OOM Crashes and Silent Context Loss

The `SequentialOrchestrator` assembles a composite LLM prompt from three layers:

1. **Global Workflow Context** — master instructions and workflow state (injected by `WorkflowInjector`).
2. **Per-Project RAG Context** — retrieved from ChromaDB via `project_store.query_project()`.
3. **Conversation History** — recent chat turns.

Three independent deficiencies were identified:

#### Problem 1 — Hardcoded Prompt Ceiling (Context Drift)

The original safety-net used a single hardcoded constant:

```python
# BEFORE: fixed value, ignores model capabilities entirely
_MAX_PROMPT_CHARS = 200_000
```

This value is appropriate for cloud-hosted large-context models (Gemini 1.5 Flash ≈ 1M tokens,
GPT-4 Turbo ≈ 128K tokens) but causes **Out-Of-Memory (OOM) process crashes** when running
local Ollama models with narrow context windows:

| Model | Context Window | ~Max Safe Chars |
|-------|---------------|-----------------|
| `llama3:8b` | 8,192 tokens | ~32,000 chars |
| `codellama:13b` | 16,384 tokens | ~65,000 chars |
| `mistral:7b` | 32,768 tokens | ~131,000 chars |
| `gemma2:9b` | 8,192 tokens | ~32,000 chars |

Developers running SoftArchitect AI on a standard laptop with Ollama received cryptic OOM errors
with no guidance on how to fix them.

#### Problem 2 — Silent Context Loss (Hallucination Risk)

When the assembled prompt exceeded `_MAX_PROMPT_CHARS`, the previous safety-net silently
discarded the **entire** `<retrieved_context>` block and rebuilt the prompt without RAG:

```python
# BEFORE: drops all RAG context without warning — dangerous
if len(prompt) > _MAX_PROMPT_CHARS:
    prompt = _build_prompt_without_retrieved_context(...)
```

This created a **silent failure mode**: the LLM received no knowledge-base grounding, increasing
the probability of architectural hallucinations and incorrect framework recommendations. The
behavior was invisible to the end user.

#### Problem 3 — Fixed ChromaDB Retrieval Count (Token Waste)

`n_results=5` was hardcoded in every call to `query_project()`. For budget-constrained API setups
or lightweight local models, 5 chunks × ~500 tokens/chunk ≈ 2,500 tokens wasted per query — a
~30% token overhead with no configurability.

---

## 🎯 Decision

**Replace all hardcoded RAG limits with environment-variable-driven configuration, and replace
the "drop-context" safety-net with deterministic prompt truncation.**

### Implementation: New Module-Level Constants

```python
# src/server/app/services/rag/sequential_orchestrator.py
import os

# Hard ceiling for the full assembled LLM prompt (chars ≈ tokens × 4).
# Set to 30000 for local Ollama 8K models, 200000 for Gemini/GPT-4.
_MAX_PROMPT_CHARS: int = int(os.getenv("LLM_MAX_PROMPT_CHARS", "200000"))

# Number of per-project RAG chunks returned from ChromaDB per query.
# Decrease to 2 for budget/local models; increase to 5 for maximum precision.
_RAG_MAX_CHUNKS: int = int(os.getenv("RAG_MAX_CHUNKS", "3"))
```

### Implementation: New Safety-Net (Truncation)

```python
# AFTER: truncates deterministically, RAG context is ALWAYS present up to the cap
if len(prompt) > _MAX_PROMPT_CHARS:
    logger.warning(
        "Prompt exceeded hard cap (%d > %d chars). Truncating.",
        len(prompt),
        _MAX_PROMPT_CHARS,
    )
    prompt = prompt[:_MAX_PROMPT_CHARS]
```

**Key invariant:** The `<retrieved_context>` block is placed early in the prompt assembly order,
so truncation affects the *tail* of the conversation history — not the RAG grounding. This
guarantees that architectural knowledge always reaches the model.

---

## ⚖️ Alternatives Considered

### Alternative A — Auto-Detect Model Context Window at Startup

Query the Ollama REST API (`/api/show`) on boot to retrieve model metadata and set limits
dynamically.

- ❌ **Rejected:** Adds startup latency (~200ms). Not portable to Groq/Gemini. Fails silently
  when Ollama is offline. Increases coupling to Ollama API shape.

### Alternative B — Catch OOM at HTTP Layer and Return Error

Intercept the OOM exception at the FastAPI router level and return a user-friendly HTTP 503.

- ❌ **Rejected:** Does not *prevent* the crash; only handles it after process memory is
  exhausted. On single-process setups, the Ollama subprocess is unrecoverable. User context is
  lost.

### Alternative C — Per-Request Client Header (`X-Max-Prompt-Chars`)

Allow the Flutter frontend to pass a context-window hint in each API request header.

- ❌ **Rejected:** Increases attack surface (users could inject arbitrarily large limits).
  Configuration belongs to the operator (`.env`), not to the end user at request time.

### Alternative D — RAG Chunk Summarization Before Assembly

Summarize each retrieved chunk to a fixed token budget before prompt assembly.

- ❌ **Rejected (deferred to future ADR):** Adds an extra LLM call per request (2× latency).
  Acceptable for v2 but not MVP scope.

---

## ✅ Consequences

### Positive

| Benefit | Detail |
|---------|--------|
| **Hardware-Agnostic** | One binary — tuned by a single `.env` line for any hardware profile |
| **OOM Prevention** | No more process crashes on Ollama local models with narrow context windows |
| **No Silent Failures** | Truncation emits `WARNING` log; RAG grounding always present in prompt |
| **Token Cost Savings** | Reducing `RAG_MAX_CHUNKS` from 5→2 saves ~30% of API token costs |
| **Testability** | Both constants are testable via `importlib.reload()` + `patch.dict(os.environ)` |
| **Operator Control** | Values are documented in `.env.example` with scenario-based guidance |

### Negative / Trade-offs

| Risk | Mitigation |
|------|-----------|
| **Operator Responsibility** | Users must understand their model's window; mitigated by `.env.example` docs |
| **Tail Truncation** | Conversation history may be cut at extreme lengths; `WARNING` is logged |
| **No In-App Notification** | Frontend has no visual indicator of truncation (acceptable for MVP) |
| **Module Reload Pattern** | Tests use `importlib.reload()` which is non-standard; documented in test file |

---

## 📊 Configuration Reference

### Recommended Values by Hardware Profile

| Profile | `LLM_MAX_PROMPT_CHARS` | `RAG_MAX_CHUNKS` | Notes |
|---------|------------------------|-----------------|-------|
| **Laptop — Ollama `llama3:8b`** | `30000` | `2` | Prevents OOM; max ~8K tokens |
| **Laptop — Ollama `mistral:7b`** | `80000` | `3` | Balanced; ~32K context |
| **Desktop — Ollama `llama3:70b`** | `120000` | `4` | High RAM model |
| **Cloud — Groq (free tier)** | `100000` | `3` | Rate-limit aware |
| **Cloud — Gemini 1.5 Flash** | `200000` | `5` | Full precision; 1M context |
| **Cloud — GPT-4 Turbo** | `200000` | `4` | Large window, cost-aware |

### `.env` Snippet

```bash
# ─── LLM & RAG CONFIGURATION (ADVANCED) ─────────────────────────────────────
# Hard ceiling for the full assembled LLM prompt (chars ≈ tokens × 4).
# Default: 200000 (safe for Gemini 1.5 Flash / GPT-4).
# Reduce to 30000 when using local Ollama with 8K context to prevent OOM.
LLM_MAX_PROMPT_CHARS=200000

# Number of per-project RAG chunks returned from ChromaDB per query.
# Default: 3. Increase to 5 for maximum precision, decrease to 2 for cost savings.
RAG_MAX_CHUNKS=3
```

---

## 📁 Files Changed

| File | Change |
|------|--------|
| `src/server/app/services/rag/sequential_orchestrator.py` | Constants → env-driven; safety-net → truncation |
| `src/server/.env.example` | New section: `LLM & RAG CONFIGURATION (ADVANCED)` |
| `src/server/README.md` | New subsection: `LLM & RAG Configuration (Advanced)` |
| `tests/server/unit/services/rag/test_sequential_orchestrator.py` | `TestEnvVarConfiguration` class (2 new tests) |
| `context/30-ARCHITECTURE/ADR/ADR-002-Configurable-RAG-Limits.en.md` | This document |
| `context/30-ARCHITECTURE/ADR/ADR-002-Configurable-RAG-Limits.es.md` | Spanish translation |

---

## 🔗 References

- [RAG Architecture & Flow](../RAG_ARCHITECTURE_AND_FLOW.en.md) — Current RAG pipeline design
- [Server README — LLM & RAG Configuration](../../../src/server/README.md) — Operational config guide
- [ADR-005: LLM Temperature Adjustment](ADR-005-LLM-TEMPERATURE-ADJUSTMENT.en.md) — Related LLM tuning
- [`.env.example`](../../../src/server/.env.example) — All configurable variables
- [OWASP Input Validation](https://owasp.org/www-community/controls/Input_Validation) — Security reference
