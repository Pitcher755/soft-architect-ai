# 🛠️ Tech Stack Decision Example

> **Save Path**: `packages/knowledge_base/02-TECH-PACKS/MASTER_WORKFLOW_EXAMPLES/03-TECH_STACK_EXAMPLE.md`
> **Status**: ✅ Complete
> **Last Updated**: 2026-02-22
> **Context**: Detailed rationale for Flutter + Python FastAPI + ChromaDB architecture

---

## 📋 Table of Contents

- [Decision Summary](#decision-summary)
- [Evaluation Criteria](#evaluation-criteria)
- [Frontend Selection](#frontend-selection)
- [Backend Selection](#backend-selection)
- [AI Engine Selection](#ai-engine-selection)
- [Storage Layer Selection](#storage-layer-selection)
- [Infrastructure Selection](#infrastructure-selection)
- [Trade-offs and Risks](#trade-offs-and-risks)

---

## Decision Summary

### Final Stack

| Layer | Selected Technology | Alternatives Considered | Decision Date |
|-------|---------------------|-------------------------|---------------|
| **Frontend** | Flutter Desktop (Dart 3.x) | Electron (Node.js), Tauri (Rust), Qt (C++) | 2026-01-10 |
| **Backend** | Python 3.12 + FastAPI | Django, Flask, Node.js + Express | 2026-01-12 |
| **AI Orchestration** | LangChain (Python) | LlamaIndex, Haystack, custom | 2026-01-15 |
| **LLM (Local)** | Ollama + Qwen2.5-Coder-7B | GPT4All, LocalAI, Llama.cpp | 2026-01-16 |
| **LLM (Cloud)** | Groq API (Llama-3-70B) | OpenAI, Anthropic, Cohere | 2026-01-17 |
| **Vector DB** | ChromaDB (local mode) | Qdrant, Weaviate, Pinecone | 2026-01-18 |
| **Relational DB** | SQLite | PostgreSQL, MySQL, DuckDB | 2026-01-19 |
| **State Management** | Riverpod + Code Generation | BLoC, Provider, GetX | 2026-01-20 |
| **Infrastructure** | Docker Compose | Kubernetes, Podman, native install | 2026-01-21 |

---

## Evaluation Criteria

### Priority Matrix (Weighted Scoring)

| Criterion | Weight | Definition |
|-----------|--------|------------|
| **Privacy** | 30% | Can operate fully offline without data leakage |
| **Performance** | 25% | Responsiveness, latency, memory footprint |
| **Developer Experience** | 20% | Ease of development, debugging, testing |
| **Ecosystem Maturity** | 15% | Available libraries, community support, stability |
| **Maintainability** | 10% | Long-term support, update cadence, documentation |

### Scoring System
- ⭐⭐⭐⭐⭐ Excellent (5 points)
- ⭐⭐⭐⭐ Good (4 points)
- ⭐⭐⭐ Acceptable (3 points)
- ⭐⭐ Poor (2 points)
- ⭐ Inadequate (1 point)

---

## Frontend Selection

### Requirements
- Native desktop performance (60+ FPS)
- Cross-platform (Linux, Windows, macOS)
- Responsive UI during streaming (no freezing)
- Low memory footprint (< 500MB idle)
- Strong typing and null safety

### Comparison Table

| Technology | Privacy | Performance | Dev Experience | Ecosystem | Maintainability | **Total** |
|------------|---------|-------------|----------------|-----------|-----------------|-----------|
| **Flutter** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | **4.6** |
| Electron | ⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | **3.8** |
| Tauri | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐ | ⭐⭐⭐⭐ | **3.9** |
| Qt (C++) | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | **3.8** |

### Decision: **Flutter Desktop** ✅

**Rationale:**
1. **Best Performance**: Native compilation (no Chromium overhead like Electron)
2. **Excellent Privacy**: Fully local, no telemetry unless explicitly added
3. **Rapid Development**: Hot reload, Material 3 widgets, strong ecosystem
4. **Team Expertise**: Lead developer has 4+ years Flutter experience
5. **Future-Proof**: Same codebase can target mobile if needed

**Trade-offs Accepted:**
- ❌ Smaller desktop plugin ecosystem vs Electron
- ❌ Occasional platform-specific bugs (less mature than web)

---

## Backend Selection

### Requirements
- Async support (critical for SSE streaming)
- Type validation (Pydantic models)
- Auto-generated API documentation
- Easy integration with LangChain (Python)
- Fast startup time (< 2 seconds)

### Comparison Table

| Technology | Privacy | Performance | Dev Experience | Ecosystem | Maintainability | **Total** |
|------------|---------|-------------|----------------|-----------|-----------------|-----------|
| **FastAPI** | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | **4.7** |
| Django | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | **4.5** |
| Flask | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | **4.3** |
| Express.js | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐ | **4.1** |

### Decision: **Python 3.12 + FastAPI** ✅

**Rationale:**
1. **Native Async/Await**: Perfect for SSE streaming (no callback hell)
2. **Pydantic Integration**: Automatic request/response validation
3. **Auto Swagger UI**: Built-in API documentation at `/docs`
4. **LangChain Compatibility**: Both Python = seamless integration
5. **Modern Python Features**: Type hints, async generators, pattern matching

**Trade-offs Accepted:**
- ❌ Smaller ecosystem than Django (but sufficient for our needs)
- ❌ Less "batteries included" (but we want lightweight)

---

## AI Engine Selection

### Local LLM

#### Requirements
- Runs efficiently on consumer hardware (8GB RAM minimum)
- Code-optimized model (trained on GitHub, Stack Overflow)
- License compatible with commercial use
- Model size < 7B parameters (for speed)

#### Decision: **Ollama + Qwen2.5-Coder-7B** ✅

**Rationale:**
1. **Ollama**: One-command install, GPU acceleration, model management
2. **Qwen2.5-Coder-7B**:
   - Ranked #1 on HumanEval for code generation (7B category)
   - Apache 2.0 license (commercial-friendly)
   - Multilingual (Python, Dart, JavaScript, etc.)
   - Fits in 6GB VRAM (quantized)

**Alternatives Rejected:**
- ❌ **Code Llama 7B**: Lower benchmark scores than Qwen2.5
- ❌ **DeepSeek Coder**: Larger model (33B), slower inference
- ❌ **StarCoder**: Focused on autocomplete, not chat

### Cloud LLM (Optional Fallback)

#### Requirements
- < 1 second latency (99th percentile)
- Free tier for testing
- Good quality-to-price ratio
- API compatible with OpenAI format

#### Decision: **Groq API (Llama-3-70B)** ✅

**Rationale:**
1. **Blazing Fast**: 300+ tokens/second (custom LPU hardware)
2. **Free Tier**: 20 requests/minute, sufficient for testing
3. **High Quality**: Llama-3-70B > GPT-3.5 on many benchmarks
4. **Standard API**: Compatible with LangChain OpenAI integration

**Alternatives Rejected:**
- ❌ **OpenAI GPT-4**: Expensive ($0.03/1K tokens), privacy concerns
- ❌ **Anthropic Claude**: No generous free tier
- ❌ **Together.ai**: Slower inference than Groq

---

## Storage Layer Selection

### Vector Database

#### Requirements
- Runs locally (no cloud dependency)
- Supports cosine similarity search
- Metadata filtering
- Persistent storage (disk)
- Python client library

#### Decision: **ChromaDB (local mode)** ✅

**Rationale:**
1. **Built for Local**: SQLite backend by default (no server required)
2. **LangChain Native**: First-class integration
3. **Simple API**: `client.add()`, `client.query()` - that's it
4. **Metadata Filtering**: Filter by project ID, document type, etc.
5. **Embedding Flexibility**: Works with any embedding model

**Alternatives Rejected:**
- ❌ **Pinecone**: Cloud-only (violates privacy requirement)
- ❌ **Qdrant**: Requires separate server (adds complexity)
- ❌ **Weaviate**: Heavy memory footprint (overkill)

### Relational Database

#### Requirements
- Serverless (no daemon)
- Transactional (ACID)
- Lightweight (< 100MB storage)
- Mature (> 10 years in production)

#### Decision: **SQLite** ✅

**Rationale:**
1. **Zero Configuration**: File-based, no server
2. **Ubiquitous**: Built into Python, supported everywhere
3. **Fast**: Outperforms PostgreSQL for read-heavy workloads
4. **Reliable**: Most deployed database in the world
5. **Perfect Fit**: Chat history, settings (not big data)

**Alternatives Rejected:**
- ❌ **PostgreSQL**: Requires server (overkill for single-user)
- ❌ **MySQL**: Same issue (PostgreSQL alternative)
- ❌ **DuckDB**: Column-oriented (designed for analytics, not OLTP)

---

## Infrastructure Selection

### Containerization

#### Requirements
- Easy setup (< 10 commands)
- GPU passthrough support (NVIDIA)
- Service orchestration (ChromaDB + Ollama + API)
- Reproducible environments

#### Decision: **Docker Compose** ✅

**Rationale:**
1. **Simplicity**: `docker compose up` = full stack running
2. **NVIDIA Support**: `nvidia-container-toolkit` integration
3. **Declarative Config**: YAML file = infrastructure as code
4. **Developer Standard**: Widely known, good documentation

**Alternatives Rejected:**
- ❌ **Kubernetes**: Massive overkill (designed for 100+ services)
- ❌ **Podman**: Less mature GPU support
- ❌ **Native Install**: Platform-specific instructions (nightmare)

---

## Trade-offs and Risks

### Accepted Trade-offs

| Decision | Trade-off | Mitigation |
|----------|-----------|------------|
| **Flutter Desktop** | Smaller plugin ecosystem vs web | Build custom plugins if needed |
| **SQLite** | No multi-user concurrency | Document as single-user system |
| **7B Model (Local)** | Lower quality than 70B cloud | Provide cloud fallback option |
| **Docker Dependency** | Requires Docker install | Provide install script |

### Technical Risks

| Risk | Likelihood | Impact | Mitigation Strategy |
|------|------------|--------|---------------------|
| **Ollama performance on 8GB RAM** | High | High | Benchmark and document min specs (16GB recommended) |
| **ChromaDB retrieval quality** | Medium | High | Implement relevance threshold (0.7+), fallback to generic LLM |
| **Flutter desktop bugs** | Medium | Medium | Lock to stable channel, extensive testing |
| **LangChain breaking changes** | Low | Medium | Pin versions, monitor changelog |

### Vendor Lock-in Analysis

| Component | Lock-in Risk | Mitigation |
|-----------|--------------|------------|
| **Flutter** | Medium | Domain logic in pure Dart (portable) |
| **FastAPI** | Low | Standard REST API (replaceable) |
| **Ollama** | Low | Uses standard GGUF models (portable) |
| **ChromaDB** | Low | Implements standard vector search (portable) |
| **Groq** | Medium | Use OpenAI-compatible API (easy to swap) |

---

## Implementation Timeline

### Phase 1: Foundation (Week 1-2)
```bash
✅ Install Docker + Docker Compose
✅ Create `docker-compose.yml` with ChromaDB + Ollama
✅ Pull Qwen2.5-Coder-7B model
✅ Verify GPU acceleration working
✅ Create Python FastAPI boilerplate
```

### Phase 2: Integration (Week 3-4)
```bash
✅ LangChain + ChromaDB integration
✅ Ollama API client in Python
✅ Basic RAG pipeline (ingest + query)
✅ SSE streaming endpoint
✅ Flutter HTTP client with Dio
```

### Phase 3: Validation (Week 5-6)
```bash
✅ End-to-end latency testing
✅ Memory profiling (Docker stats)
✅ Benchmark on low-end hardware (8GB RAM, no GPU)
✅ Compare local vs cloud response quality
```

---

## Version Matrix

### Dependencies (Locked Versions)

```yaml
Frontend:
  flutter: "3.24.5" # Stable channel
  dart: "3.5.4"
  riverpod: "2.6.1"
  go_router: "14.6.2"
  dio: "5.7.0"

Backend:
  python: "3.12.3"
  fastapi: "0.115.6"
  langchain: "0.3.14"
  chromadb: "0.5.23"
  ollama: "0.4.6"

Infrastructure:
  docker: "27.4.0"
  docker-compose: "2.30.3"
  nvidia-container-toolkit: "1.17.3"
```

---

## 🔗 Related Documents

- [System Diagram](16-SYSTEM_DIAGRAM_EXAMPLE.md)
- [Performance Targets](context/30-ARCHITECTURE/PERFORMANCE_TARGETS.en.md)
- [Deployment Guide](19-DEPLOYMENT_EXAMPLE.md)
- [API Contract](13-API_CONTRACT_EXAMPLE.md)

---

> **Meta Note**: This decision document demonstrates architectural rigor. Every choice is justified with weighted criteria, alternatives considered, and risks acknowledged. Update this document whenever a major technology decision changes.
