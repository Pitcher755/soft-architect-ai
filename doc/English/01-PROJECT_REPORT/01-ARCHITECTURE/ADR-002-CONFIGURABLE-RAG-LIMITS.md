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

#### Problem 2 — Silent Context Loss (Hallucination Risk)

When the assembled prompt exceeded `_MAX_PROMPT_CHARS`, the previous safety-net silently
discarded the **entire** `<retrieved_context>` block and rebuilt the prompt without RAG:

```python
# BEFORE: drops all RAG context without warning — dangerous
if len(prompt) > _MAX_PROMPT_CHARS:
    prompt = _build_prompt_without_retrieved_context(...)
```

This created a **silent failure mode**: the LLM received no knowledge-base grounding, increasing
the probability of architectural hallucinations and incorrect framework recommendations.

#### Problem 3 — Fixed ChromaDB Retrieval Count (Token Waste)

`n_results=5` was hardcoded in every call to `query_project()`. For budget-constrained API setups
or lightweight local models, 5 chunks × ~500 tokens/chunk ≈ 2,500 tokens wasted per query —
a ~30% token overhead with no configurability.

---

## 🎯 Decision

**Replace all hardcoded RAG limits with environment-variable-driven configuration, and replace
the "drop-context" safety-net with deterministic prompt truncation.**

### New Module-Level Constants

```python
# src/server/app/services/rag/sequential_orchestrator.py
import os

_MAX_PROMPT_CHARS: int = int(os.getenv("LLM_MAX_PROMPT_CHARS", "200000"))
_RAG_MAX_CHUNKS: int = int(os.getenv("RAG_MAX_CHUNKS", "3"))
```

### New Safety-Net (Truncation)

```python
# AFTER: truncates deterministically; RAG context is ALWAYS present up to the cap
if len(prompt) > _MAX_PROMPT_CHARS:
    logger.warning(
        "Prompt exceeded hard cap (%d > %d chars). Truncating.",
        len(prompt),
        _MAX_PROMPT_CHARS,
    )
    prompt = prompt[:_MAX_PROMPT_CHARS]
```

**Key invariant:** The `<retrieved_context>` block is placed early in the prompt assembly order,
so truncation affects the *tail* of the conversation history — not the RAG grounding.

---

## ⚖️ Alternatives Considered

### Alternative A — Auto-Detect Model Context Window

Query the Ollama REST API on startup for model metadata and set limits dynamically.
❌ **Rejected:** Latency, portability issues, and Ollama offline failure modes.

### Alternative B — Catch OOM at HTTP Layer

Intercept the OOM exception at the FastAPI router and return HTTP 503.
❌ **Rejected:** Does not prevent the crash; process memory is already exhausted.

### Alternative C — Per-Request Client Header

Allow the Flutter frontend to pass `X-Max-Prompt-Chars` in request headers.
❌ **Rejected:** Increases attack surface; configuration belongs to the operator, not the user.

### Alternative D — RAG Chunk Summarization

Summarize each retrieved chunk to a fixed token budget before assembly.
❌ **Rejected (deferred):** Adds an extra LLM call per request (2× latency). Deferred to v2.

---

## ✅ Consequences

### Positive

| Benefit | Detail |
|---------|--------|
| **Hardware-Agnostic** | One binary — tuned by a single `.env` line for any hardware profile |
| **OOM Prevention** | No more process crashes on Ollama local models |
| **No Silent Failures** | Truncation emits `WARNING` log; RAG grounding always present |
| **Token Cost Savings** | `RAG_MAX_CHUNKS` 5→2 saves ~30% of API token costs |
| **Testability** | Constants testable via `importlib.reload()` + `patch.dict(os.environ)` |

### Negative / Trade-offs

| Risk | Mitigation |
|------|-----------|
| **Operator Responsibility** | Must set limits per model; mitigated by `.env.example` documentation |
| **Tail Truncation** | Long conversations may be cut; `WARNING` is logged |
| **No In-App Notification** | No visual indicator of truncation (acceptable for MVP) |

---

## 📊 Configuration Reference

| Profile | `LLM_MAX_PROMPT_CHARS` | `RAG_MAX_CHUNKS` |
|---------|------------------------|-----------------|
| Laptop — Ollama `llama3:8b` | `30000` | `2` |
| Laptop — Ollama `mistral:7b` | `80000` | `3` |
| Desktop — Ollama `llama3:70b` | `120000` | `4` |
| Cloud — Groq (free tier) | `100000` | `3` |
| Cloud — Gemini 1.5 Flash | `200000` | `5` |
| Cloud — GPT-4 Turbo | `200000` | `4` |

---

## 📁 Files Changed

| File | Change |
|------|--------|
| `src/server/app/services/rag/sequential_orchestrator.py` | Constants → env-driven; safety-net → truncation |
| `src/server/.env.example` | New section: `LLM & RAG CONFIGURATION (ADVANCED)` |
| `src/server/README.md` | New subsection: `LLM & RAG Configuration (Advanced)` |
| `tests/server/unit/services/rag/test_sequential_orchestrator.py` | `TestEnvVarConfiguration` class (2 new tests) |

---

## 🔗 References

- [Primary ADR (context/)](../../../../context/30-ARCHITECTURE/ADR/ADR-002-Configurable-RAG-Limits.en.md)
- [RAG Architecture & Flow](../../../../context/30-ARCHITECTURE/RAG_ARCHITECTURE_AND_FLOW.en.md)
- [Server README — LLM & RAG Configuration](../../../../src/server/README.md)
- [ADR-005: LLM Temperature Adjustment](ADR-005-LLM-TEMPERATURE-ADJUSTMENT.md)
- [`.env.example`](../../../../src/server/.env.example)
