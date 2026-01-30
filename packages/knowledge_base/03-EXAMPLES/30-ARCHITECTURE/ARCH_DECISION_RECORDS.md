# 📝 Architecture Decision Records: SoftArchitect AI

> **Versión:** 1.0
> **Fecha:** 30/01/2026
> **Estado:** ✅ Documentado
> **Formato:** Markdown ADR (adr-tools compatible)
> **Context:** Critical decisions for SoftArchitect MVP

---

## 📖 Tabla de Contenidos

1. [ADR-001: Flutter for Desktop UI](#adr-001-flutter-for-desktop-ui)
2. [ADR-002: FastAPI for Backend](#adr-002-fastapi-for-backend)
3. [ADR-003: ChromaDB for Vector Store](#adr-003-chromadb-for-vector-store)
4. [ADR-004: Local-First Architecture](#adr-004-local-first-architecture)
5. [ADR-005: Ollama for Local LLM](#adr-005-ollama-for-local-llm)

---

## ADR-001: Flutter for Desktop UI

**Date:** 2026-01-15
**Status:** ACCEPTED
**Deciders:** ArchitectZero, Tech Lead

### Context

Building a desktop application for technical architects and developers. Requirements:
- Cross-platform (Windows, macOS, Linux)
- Native performance
- Responsive design
- Real-time updates
- Offline-first capability

### Decision

**Use Flutter (Desktop Channel) for the client application**

### Rationale

```
Framework      Cross-Plat  Performance  Learning  Community  Offline
──────────────────────────────────────────────────────────────────────
Flutter        ✅ Win/Mac   Excellent    Medium    Growing    ✅
              /Linux
React Desktop  ❌ Limited   Good         High      Large      ⚠️
              (only Win/Mac)
Tauri          ✅ All       Excellent    High      Emerging   ✅
Qt/C++         ✅ All       Excellent    Very High Medium     ✅
Electron       ✅ All       Good         Medium    Large      ⚠️

WINNER: Flutter
├─ Native performance (Skia rendering)
├─ Cross-platform from single codebase
├─ Growing Flutter Desktop community
├─ Hot reload for fast development
└─ Can ship single executable per OS
```

### Consequences

**Positive:**
- Single codebase for Win/Mac/Linux
- Fast development (hot reload)
- Beautiful UI out of the box
- Strong typing (Dart)

**Negative:**
- Smaller ecosystem than Electron
- Flutter Desktop still evolving
- Build sizes larger than native
- Less third-party integrations

### Validation

```
✅ POC completed with success
✅ Team can ramp up on Dart
✅ Licenses compatible (BSD 3-Clause)
```

---

## ADR-002: FastAPI for Backend

**Date:** 2026-01-15
**Status:** ACCEPTED
**Deciders:** ArchitectZero, Backend Lead

### Context

Need a lightweight, fast Python backend for:
- RAG processing pipeline
- LLM integration (Ollama)
- Vector store management
- Data persistence

Requirements:
- Async/await support
- Type safety
- Built-in API documentation
- Easy testing

### Decision

**Use FastAPI for the Python backend**

### Rationale

```
Framework      Async   Types   Docs    Speed    Learning
──────────────────────────────────────────────────────────
FastAPI        ✅      ✅      ✅      Fast     Low
Django         ⚠️      ⚠️      Good    Medium   High
Flask          ❌      ❌      Good    Medium   Low
Starlette      ✅      ✅      Good    Fast     Medium
aiohttp        ✅      ✅      Basic   Fast     High

WINNER: FastAPI
├─ Built-in async/await
├─ Pydantic for type validation
├─ Auto-generated OpenAPI docs
├─ Easy error handling
└─ Great for microservices + monoliths
```

### Consequences

**Positive:**
- Automatic API documentation (Swagger)
- Type hints reduce bugs
- Fast performance (uvicorn ASGI)
- Great ecosystem (Pydantic, SQLAlchemy)

**Negative:**
- Newer framework (< 10 years old)
- Smaller community than Django
- Fewer third-party packages

### Validation

```
✅ ASGI server benchmarks show excellent performance
✅ Pydantic integration tested
✅ Async LLM calls working correctly
```

---

## ADR-003: ChromaDB for Vector Store

**Date:** 2026-01-15
**Status:** ACCEPTED
**Deciders:** ArchitectZero, Data Lead

### Context

Need to store and search semantic embeddings for RAG pipeline. Requirements:
- Local storage (offline capability)
- Fast similarity search
- Automatic embedding generation
- Metadata filtering

### Decision

**Use ChromaDB for the vector store**

### Rationale

```
Option              Local    Speed    Langchain  Learning  Cost
──────────────────────────────────────────────────────────────────
ChromaDB            ✅       Fast     ✅ Native  Low       Free
Weaviate            ⚠️ Cloud  Fast     ✅ Plugin  High      Paid
Pinecone            ❌ Cloud  VFast    ✅ Plugin  Medium    Paid
Milvus              ✅ Local  Fast     ✅ Plugin  High      Free
Qdrant              ✅ Local  VFast    ✅ Plugin  Medium    Free
FAISS               ✅ Local  VFast    ✅ Plugin  High      Free

WINNER: ChromaDB
├─ Pure Python (easy to install)
├─ Embedded mode (no separate server)
├─ LangChain integration out-of-box
├─ SQLite-based persistence
└─ Perfect for local-first architecture
```

### Consequences

**Positive:**
- Zero deployment complexity (embedded)
- Full local control of data
- Works offline perfectly
- Langchain seamless integration

**Negative:**
- Limited to single machine (no clustering)
- Smaller than Weaviate/Pinecone for scale
- API still evolving

### Validation

```
✅ Embedded mode tested with 1000+ documents
✅ Similarity search latency < 100ms
✅ Langchain integration confirmed working
```

---

## ADR-004: Local-First Architecture

**Date:** 2026-01-20
**Status:** ACCEPTED
**Deciders:** ArchitectZero, Security Lead

### Context

Data privacy is critical. Options:
1. **Cloud-First:** Store everything on servers (simple, scales, privacy risk)
2. **Hybrid:** Local + optional cloud sync (flexible, complex)
3. **Local-First:** Everything local, cloud optional (privacy first, UX challenge)

Requirements:
- User data never leaves machine by default
- Optional cloud integration
- Works 100% offline
- User controls data lifecycle

### Decision

**Implement Local-First architecture with opt-in cloud features**

### Rationale

```
SoftArchitect AI is designed for technical architects making critical decisions.
These decisions contain proprietary company knowledge that MUST NOT leave the
user's machine without explicit consent.

Default behavior:
  ✅ ALL processing local
  ✅ ALL storage local
  ✅ NO telemetry
  ✅ NO cloud calls

Optional (User-initiated):
  ✓ Export to cloud storage (S3, Azure Blob)
  ✓ Use Groq API for faster LLM (encrypted)
  ✓ Team collaboration (future)
```

### Consequences

**Positive:**
- Unmatched privacy
- GDPR compliant by design
- Works without internet
- User controls data destiny

**Negative:**
- Cannot leverage cloud for ML insights (intentional)
- Slower scaling (single machine)
- No server-side analytics
- Higher barrier to multi-user (future)

### Validation

```
✅ All POC workflows run offline
✅ Privacy audit passed
✅ GDPR pre-assessment shows compliance
```

---

## ADR-005: Ollama for Local LLM

**Date:** 2026-01-20
**Status:** ACCEPTED
**Deciders:** ArchitectZero, ML Lead

### Context

Need LLM capability without external API dependency. Options:
1. **Ollama:** Local container, easy setup, good models
2. **llama.cpp:** Lightweight, fast, harder to setup
3. **Groq API:** Super fast, requires internet (opt-in)
4. **Hugging Face locally:** More control, complexity

Requirements:
- Works offline
- Easy for non-technical users
- Good model selection
- Reasonable performance

### Decision

**Use Ollama as primary local LLM, Groq as optional accelerator**

### Rationale

```
Solution         Offline  Setup   Perf    Models  Community
────────────────────────────────────────────────────────────
Ollama           ✅       Easy    Good    ✅ Many  Growing
llama.cpp        ✅       Hard    VGood   ✅ Few   Medium
Groq             ❌       Easy    Excellent N/A   Growing
HF Transformers  ✅       Hard    Medium  ✅ Many  Large

WINNER: Ollama (hybrid approach)
├─ Docker container (reproducible)
├─ Easy model management
├─ Good speed/quality tradeoff
├─ Community support growing
└─ Can fall back to Groq if user enables
```

### Consequences

**Positive:**
- Non-technical users can run (docker run command)
- Model selection (Mistral, Llama2, Neural Chat)
- Performance good for most use cases
- Easy debugging/replacement

**Negative:**
- Requires Docker installed
- GPU optional but recommended
- CPU-only slower (5-10 sec responses)
- Memory requirements (8GB+ recommended)

### Validation

```
✅ Ollama setup guide written
✅ Model benchmarks completed
✅ Fallback to Groq tested
```

---

## Decision Impact Timeline

### PHASE 1 (Now - MVP)
```
Dec 2025-Jan 2026
└─ ADR-001: Flutter UI (partial)
└─ ADR-002: FastAPI core
└─ ADR-003: ChromaDB indexing
└─ ADR-004: Local-first (enforced)
└─ ADR-005: Ollama base LLM
```

### PHASE 2 (Feb-Mar 2026)
```
└─ ADR-001: Flutter complete + optimization
└─ ADR-004: Add Groq optional integration
└─ Security audit (all ADRs impact)
```

### PHASE 3+ (Apr+ 2026)
```
└─ Potential: Multi-user support (new ADRs)
└─ Potential: Team collaboration (new decisions)
└─ Potential: Advanced RAG (new framework choice)
```

---

## ADR Modification Process

### Adding New ADRs

```bash
# Create new ADR file
cat > doc/030-ARCHITECTURE/ADR-006-NewDecision.md << 'EOF'
# ADR-006: [Decision Title]

**Date:** YYYY-MM-DD
**Status:** PROPOSED/ACCEPTED/REJECTED/SUPERSEDED
**Deciders:** [Names]

## Context
[Why this decision?]

## Decision
[What decision?]

## Rationale
[Why this option?]

## Consequences
[What changes?]

## Validation
[How verified?]
EOF
```

### Review & Approval

```
1. Author submits ADR
2. Technical review (24h)
3. Team discussion (if needed)
4. Status changed to ACCEPTED
5. Implementation begins
```

---

**Architecture Decision Records** make architectural reasoning explicit and traceable. 📚
