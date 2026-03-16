# ADR-002: LLM Context Injection Strategy for Sequential Document Generation

> **Date:** 2026-03-16
> **Status:** ✅ Accepted
> **Context:** "Operation Rails" — 24-document sequential generation workflow
> **Decision Makers:** ArchitectZero, Development Team

---

## 📋 Table of Contents

1. [Problem Context](#-problem-context)
2. [Options Considered](#-options-considered)
3. [Decision](#-decision)
4. [Strategic Justification](#-strategic-justification)
5. [Consequences](#-consequences)
6. [Implementation Roadmap](#-implementation-roadmap)

---

## 🔍 Problem Context

During the sequential execution of the 24-document workflow ("Operation Rails"), injecting
the **full project context** into every LLM prompt causes a **context window overflow**:

```
HTTP 500 Internal Server Error (Gemini API)
→ First failure point: Document 5 — USER_STORIES_MASTER
→ Root cause: Linear payload growth — each new request includes all previously
  generated documents as raw text in the prompt.
```

### Growth Profile (chars per request)

| Doc # | Document | Approx. payload growth |
|-------|----------|----------------------|
| 1 | PROJECT_MANIFESTO | ~2 000 |
| 2 | DOMAIN_LANGUAGE | ~4 500 |
| 3 | USER_JOURNEY_MAP | ~8 000 |
| 4 | REQUIREMENTS_MASTER | ~14 000 |
| **5** | **USER_STORIES_MASTER** | **~22 000 → 💥 500 error** |
| … | … | … |
| 24 | RELEASE_NOTES | ~120 000+ (theoretical) |

This growth pattern is **architecturally unsustainable** for the MVP.

### Constraint: Privacy-First (AGENTS.md)

The project's core principle is **Data Sovereignty** — user project data must never leave
the local environment unless explicitly authorised. Any solution must be operable fully
offline.

---

## 🗂️ Options Considered

### Option A — Vector RAG / ChromaDB (Dynamic Semantic Retrieval)

Each generated document is ingested into an isolated ChromaDB collection keyed by
`project_id`. Before generating document N, a semantic query retrieves only the most
relevant chunks from that collection.

**How it works:**
```
Document generated → POST /documents/{project_id}/ingest → ChromaDB (local)
                                                              ↓
Next generation → semantic query("user stories actors flows")
                → retrieve top-K chunks (~1 500 chars)
                → inject only relevant fragments into prompt
```

**Advantages:**
- Constant token footprint regardless of document count (scales to doc 24 with same cost as doc 2).
- Enables intelligent chat Q&A over all project documentation.
- Supports future use cases: "What tech stack did we choose?", document update requests.
- Fully compatible with Privacy-First principle (ChromaDB runs locally in Docker).

**Disadvantages / Risks for MVP:**
- Requires a local embedding model (`sentence-transformers` ~500 MB RAM) or Ollama embedding endpoint.
- `VectorStoreService` is currently a stub — the real ChromaDB adapter is not implemented.
- Introduces async ingestion pipeline with failure modes (partial ingestion, stale chunks).
- Adds architectural complexity (chunking strategy, collection lifecycle, cosine similarity tuning).
- Estimated implementation: 3–5 days + dedicated test suite.

---

### Option B — Static Dependency Graph (Deterministic Filtering)

A static map `doc_type → [required_doc_types]` is defined in the domain constants layer.
The backend filters `project_context` before building the LLM prompt — Flutter continues
sending all documents, but only the 2–4 genuinely needed ones are injected per request.

**How it works:**
```python
DEPENDENCY_GRAPH = {
    "USER_STORIES_MASTER": ["PROJECT_MANIFESTO", "REQUIREMENTS_MASTER"],
    "ARCHITECTURE_OVERVIEW": ["DOMAIN_LANGUAGE", "REQUIREMENTS_MASTER", "USER_STORIES_MASTER"],
    # ... 24 entries
}

# In orchestrator: filter before _build_project_documents_block()
relevant = {k: v for k, v in project_context.items()
            if any(dep in k for dep in DEPENDENCY_GRAPH[doc_type])}
```

**Advantages:**
- < 150 lines of code, zero infrastructure changes.
- 100% deterministic — no similarity thresholds or embedding precision concerns.
- Fully testable with unit tests.
- Immediately solves the HTTP 500 overflow error in production.

**Disadvantages:**
- Static map requires manual updates when workflow evolves.
- Does not enable semantic Q&A over project docs (chat enhancement blocked).
- Knowledge is encoded by the engineer, not derived from document content.

---

## 🎯 Decision

**Two-phase iterative approach:**

```
Phase 1 (MVP — immediate)       →  Option B: Static Dependency Graph
Phase 2 (Post-launch — backlog) →  Option A: Vector RAG / ChromaDB
```

Option B is implemented **now** as a tactical patch.
Option A is formally recorded as a **prioritised technical Epic** for the first
post-MVP development cycle.

---

## 📐 Strategic Justification

### 1. Time-to-Market
Option B is deliverable within one work session with zero infrastructure risk.
It guarantees a **fully deterministic 24-document generation flow** for user validation
before investing in vector infrastructure.

### 2. Risk Management
Adopting Option A immediately introduces three unsolved problems during MVP phase:
- Embedding model selection & hosting (local RAM budget vs. Ollama integration).
- Text chunking strategy (section-level vs. paragraph-level vs. semantic).
- Async ingestion failure handling (partial ingestion, collection corruption).

Deferring these to a dedicated cycle isolates the risk appropriately.

### 3. Tactical Technical Debt (Conscious Decision)
Option B will be discarded when Option A ships — this is **acknowledged double work**.
It is accepted because:
- It validates prompt quality and application UX with real users immediately.
- It isolates the vector infrastructure problem to a focused engineering sprint.
- The code is small enough (~150 lines) that the throw-away cost is negligible.

### 4. Architectural Coherence
Both options respect the **Clean Architecture + Hexagonal** principle:
the filtering logic (B) or the retrieval adapter (A) live in the service/infrastructure
layer — the LLM prompting domain layer remains unaware of the implementation.

---

## 📊 Consequences

### Positive
- Document generation workflow completes all 24 steps without HTTP 500 errors.
- System prompt stays within Gemini free-tier token limits.
- No changes required to Flutter client or Docker infrastructure.

### Negative / Accepted Trade-offs
- Dependency graph requires manual maintenance when the 24-step workflow changes.
- Phase 2 (Option A) must be planned and budgeted before the second development cycle.
- Chat Q&A over project documentation is **not available** until Phase 2 ships.

### Neutral
- `project_context` field remains in `ChatRequest` schema — it will be used by Option A
  as the ingestion source, making the schema forward-compatible.

---

## 🗺️ Implementation Roadmap

### Phase 1 — Option B (Current Sprint)

| Task | File | Effort |
|------|------|--------|
| Define dependency graph constant | `src/server/app/domain/constants/workflow.py` | XS |
| Implement `_filter_relevant_context()` in orchestrator | `src/server/app/services/rag/sequential_orchestrator.py` | S |
| Unit tests for filter logic | `tests/server/services/rag/test_sequential_orchestrator.py` | S |
| Black + Ruff + Pyright pass | All modified files | XS |

### Phase 2 — Option A (Post-MVP Epic)

| Task | Owner | Priority |
|------|-------|----------|
| Implement `ChromaDBDocumentStore` adapter | `infrastructure/vector_store/` | P1 |
| POST `/api/v1/documents/{project_id}/ingest` endpoint | `api/v1/` | P1 |
| Trigger ingestion on document save (post-stream hook) | `chat.py` | P1 |
| Modify orchestrator to query project collection | `sequential_orchestrator.py` | P1 |
| Embedding model selection & Docker integration | `infrastructure/docker-compose.yml` | P2 |
| Remove `project_context` raw injection from prompt | `sequential_orchestrator.py` | P2 |
| Integration tests for full RAG pipeline | `tests/server/` | P2 |
