# 📋 Architecture Decision Records (ADR) - SoftArchitect AI

> **Document Type:** Technical Decision Log
> **Project:** SoftArchitect AI
> **ADR Format:** MADR (Markdown Architectural Decision Records)
> **Version:** 1.0.0
> **Last Updated:** February 2026

---

## 📖 Table of Contents

1. [ADR-001: Use Hybrid LLM Architecture (Ollama + Groq)](#adr-001-use-hybrid-llm-architecture-ollama--groq)
2. [ADR-002: Choose Flutter Desktop over Electron](#adr-002-choose-flutter-desktop-over-electron)
3. [ADR-003: SQLite for Local Data Storage](#adr-003-sqlite-for-local-data-storage)
4. [ADR-004: ChromaDB for Vector Storage (RAG)](#adr-004-chromadb-for-vector-storage-rag)
5. [ADR-005: Clean Architecture + Hexagonal Pattern](#adr-005-clean-architecture--hexagonal-pattern)
6. [ADR-006: Riverpod for State Management](#adr-006-riverpod-for-state-management)
7. [ADR-007: FastAPI for Backend Services](#adr-007-fastapi-for-backend-services)
8. [ADR-008: Server-Sent Events (SSE) for Streaming](#adr-008-server-sent-events-sse-for-streaming)
9. [ADR-009: Phase-Based Workflow State Machine](#adr-009-phase-based-workflow-state-machine)
10. [ADR-010: No Cloud Telemetry by Default](#adr-010-no-cloud-telemetry-by-default)

---

## ADR-001: Use Hybrid LLM Architecture (Ollama + Groq)

**Status:** ✅ Accepted
**Date:** 2026-01-18
**Decision Makers:** @ArchitectZero
**Context Reviewers:** @PitcherDev

### Context

SoftArchitect AI is a local-first AI assistant for software engineering. Users must be able to:
- Work completely offline (no internet required after initial setup)
- Process sensitive private data (proprietary codebases, internal docs)
- Get low-latency responses (<2s first token)
- Optionally use cloud LLMs when performance is critical (e.g., large document generation)

**Requirements:**
- **Privacy:** Zero data exfiltration by default
- **Performance:** <200ms UI response time, <2s first token (LLM)
- **Flexibility:** User can switch providers without losing data

### Decision

**Adopt a Hybrid LLM Architecture with two modes:**

1. **Local Mode (Default):** Ollama running on localhost
   - Model: `llama3.3:70b` (recommended) or `llama3.2:3b` (low-resource)
   - Endpoint: `http://localhost:11434`
   - Inference: 100% offline, data never leaves user's machine

2. **Cloud Mode (Opt-In):** Groq API
   - Model: `llama-3.3-70b-versatile` (fastest)
   - Endpoint: `https://api.groq.com/openai/v1/chat/completions`
   - Rate Limit: 30 requests/min (free tier), 6000 tokens/min
   - Use Case: Generating large documents (>5000 tokens), complex multi-turn reasoning

**Switching Logic:**
```python
def get_llm_client(user_preference: str) -> BaseLLMClient:
    if user_preference == "ollama":
        return OllamaClient(base_url="http://localhost:11434")
    elif user_preference == "groq":
        api_key = os.getenv("GROQ_API_KEY")
        if not api_key:
            raise ConfigurationError("GROQ_API_KEY not set")
        return GroqClient(api_key=api_key)
    else:
        raise ValueError(f"Unknown LLM provider: {user_preference}")
```

### Consequences

**Positive:**
- ✅ **Privacy Preserved:** Default mode sends zero data to external servers
- ✅ **Offline Capable:** Works on airplanes, secure environments, poor connectivity
- ✅ **Cost Control:** Ollama is free, Groq free tier sufficient for most users
- ✅ **Performance Options:** Users can choose latency vs. quality trade-off
- ✅ **Vendor Independence:** Not locked into single LLM provider

**Negative:**
- ⚠️ **Local Setup Complexity:** Users must install Ollama + download models (~40GB for llama3.3:70b)
- ⚠️ **Hardware Requirements:** Ollama requires 16GB RAM minimum (70B model), 8GB for 3B model
- ⚠️ **Quality Variance:** Local 3B models weaker than cloud 70B models
- ⚠️ **Dual Maintenance:** Must support two different API contracts (Ollama OpenAI-compatible vs. Groq native)

### Alternatives Considered

#### Option A: Cloud-Only (OpenAI/Anthropic)
- **Pros:** Best quality (GPT-4o, Claude 3.5), zero local setup
- **Cons:** ❌ NOT private (data sent to third-party), ❌ requires internet, ❌ recurring costs ($60/month typical)
- **Rejected:** Violates core "privacy-first" principle

#### Option B: Local-Only (Ollama Only)
- **Pros:** Maximum privacy, no API costs
- **Cons:** ❌ Cannot leverage cloud power when needed, ❌ excludes users with weak hardware
- **Rejected:** Too restrictive for power users

#### Option C: Bring Your Own Model (BYOM)
- **Pros:** Ultimate flexibility (vLLM, llama.cpp, TGI)
- **Cons:** ❌ Too complex for average developers, ❌ maintenance nightmare (support all inference engines)
- **Rejected:** Over-engineering for MVP

---

## ADR-002: Choose Flutter Desktop over Electron

**Status:** ✅ Accepted
**Date:** 2026-01-15
**Decision Makers:** @ArchitectZero

### Context

SoftArchitect AI needs a cross-platform desktop UI. Key constraints:
- **Target Platforms:** Linux (primary), macOS, Windows
- **Performance:** Must feel native (no lag on 8GB RAM machines)
- **Build Size:** Installer <100MB
- **Developer Experience:** Strong typing, hot reload, easy testing

### Decision

**Use Flutter Desktop (Dart) over Electron or native frameworks.**

**Tech Stack:**
- **UI Framework:** Flutter 3.27+ (Dart 3.6+)
- **Targets:** Linux (GTK), macOS (Cocoa), Windows (Win32)
- **Architecture:** Clean Architecture (Domain, Data, Presentation layers)

### Consequences

**Positive:**
- ✅ **Native Performance:** Compiled to machine code (C++), GPU-accelerated rendering
- ✅ **Small Binary:** ~40MB (vs. Electron ~200MB with Chromium + Node.js)
- ✅ **Memory Efficient:** ~80MB RAM idle (vs. Electron ~300MB)
- ✅ **Fast Iteration:** Hot reload in <1s, hot restart in <3s
- ✅ **Type Safety:** Dart's sound null safety prevents runtime errors
- ✅ **Widget Ecosystem:** 30,000+ packages on pub.dev

**Negative:**
- ⚠️ **Smaller Community:** Flutter desktop less mature than web (but stable since 2023)
- ⚠️ **Platform Quirks:** File pickers, native dialogs require platform channels
- ⚠️ **Learning Curve:** Team must learn Dart (but similar to TypeScript)

### Alternatives Considered

#### Option A: Electron + React
- **Pros:** Largest ecosystem, familiar to web devs
- **Cons:** ❌ 200MB bundle size, ❌ 300MB RAM usage, ❌ slower startup (~3s)
- **Rejected:** Performance unacceptable for resource-constrained users

#### Option B: Native (Swift/Kotlin/C++)
- **Pros:** Best possible performance, native look-and-feel
- **Cons:** ❌ 3x development effort (separate codebases), ❌ no shared business logic
- **Rejected:** Unsustainable for small team

#### Option C: Tauri (Rust + Web)
- **Pros:** Small bundle (~10MB), fast, Rust safety
- **Cons:** ❌ Still Chromium-based UI (web tech), ❌ Rust learning curve steeper than Dart
- **Rejected:** Hybrid web approach not significantly better than Flutter

---

## ADR-003: SQLite for Local Data Storage

**Status:** ✅ Accepted
**Date:** 2026-01-16
**Decision Makers:** @ArchitectZero

### Context

Need to persist:
- **Project metadata** (name, root path, phase, completion %)
- **Chat history** (500+ messages per project)
- **Generated documents** (24 documents per project)
- **User settings** (LLM provider, theme preferences)

**Requirements:**
- **Embedded:** No separate database server process
- **ACID Compliant:** Reliable writes (no data corruption)
- **Cross-Platform:** Works on Linux/macOS/Windows without changes
- **Backup-Friendly:** Simple file copy for backup/restore

### Decision

**Use SQLite 3.41+ with two-database strategy:**

1. **Application Database** (`~/.soft-architect-ai/projects.db`)
   - Tables: `projects`, `settings`, `telemetry_events`
   - Scope: Global (all projects)

2. **Project Database** (`{project_root}/project_data.db`)
   - Tables: `chat_messages`, `documents`, `workflow_state`
   - Scope: Per-project (isolated data)

**Configuration:**
```python
import sqlite3

conn = sqlite3.connect("projects.db")
conn.execute("PRAGMA journal_mode=WAL")  # Write-Ahead Logging for performance
conn.execute("PRAGMA foreign_keys=ON")   # Enforce referential integrity
conn.execute("PRAGMA synchronous=NORMAL") # Balance safety/speed
```

### Consequences

**Positive:**
- ✅ **Zero Configuration:** No daemon, no ports, no connection pooling
- ✅ **ACID Guarantees:** Writes atomic, consistent, isolated, durable
- ✅ **Fast:** 10,000+ SELECT queries/sec on commodity hardware
- ✅ **Simple Backup:** `cp projects.db backup.db` (with WAL checkpoint)
- ✅ **Cross-Platform:** SQLite identical behavior on all OSes

**Negative:**
- ⚠️ **Concurrency Limits:** Write serialization (okay for single-user desktop app)
- ⚠️ **No Network Access:** Cannot query from remote machines (okay, we don't need this)
- ⚠️ **Manual Migrations:** No built-in schema versioning (we write SQL scripts)

### Alternatives Considered

#### Option A: PostgreSQL
- **Pros:** Best relational features, high concurrency
- **Cons:** ❌ Requires daemon process, ❌ complex setup for users, ❌ overkill for desktop app
- **Rejected:** Over-engineering

#### Option B: JSON Files
- **Pros:** Human-readable, easy Git diffs
- **Cons:** ❌ No ACID, ❌ slow queries (no indexes), ❌ race conditions on concurrent writes
- **Rejected:** Unreliable at scale

#### Option C: Embedded Key-Value (RocksDB/LevelDB)
- **Pros:** Very fast writes, LSM-tree architecture
- **Cons:** ❌ No SQL, ❌ harder to query complex relationships, ❌ no ACID transactions
- **Rejected:** Over-complication, SQL is more familiar

---

## ADR-004: ChromaDB for Vector Storage (RAG)

**Status:** ✅ Accepted
**Date:** 2026-01-20
**Decision Makers:** @ArchitectZero

### Context

Knowledge Base (RAG) must store:
- **Tech Pack Templates** (~24 Markdown files, ~5000 lines total)
- **Workflow Examples** (~24 example documents, ~10,000 lines)
- **User Custom Documents** (optional, user-provided tech docs)

**Requirements:**
- **Semantic Search:** Find relevant docs by meaning (not just keywords)
- **Local-First:** Run locally, no cloud API calls
- **Low Latency:** Query <200ms for top-k=5 results
- **Easy Embedding:** Integrate with sentence-transformers (HuggingFace)

### Decision

**Use ChromaDB (local mode) with `all-MiniLM-L6-v2` embeddings.**

**Architecture:**
```python
import chromadb
from chromadb.config import Settings

client = chromadb.Client(Settings(
    chroma_db_impl="duckdb+parquet",
    persist_directory="./.chroma_data"
))

collection = client.get_or_create_collection(
    name="knowledge_base",
    metadata={"hnsw:space": "cosine"}
)

# Ingest documents
collection.add(
    documents=["# Tech Stack Example...", "# Vision Example..."],
    metadatas=[{"source": "03-TECH_STACK_EXAMPLE.md"}, {...}],
    ids=["doc_001", "doc_002"]
)

# Query
results = collection.query(
    query_texts=["How do I choose a database?"],
    n_results=5
)
```

### Consequences

**Positive:**
- ✅ **Works Offline:** 100% local, no API keys required
- ✅ **Fast:** <200ms for 5-result semantic search
- ✅ **Easy Setup:** `pip install chromadb` (no complex config)
- ✅ **Auto Embeddings:** Built-in embedding function (sentence-transformers)
- ✅ **Python Native:** Integrates seamlessly with FastAPI backend

**Negative:**
- ⚠️ **Embedding Quality:** all-MiniLM-L6-v2 weaker than OpenAI text-embedding-3 (but acceptable)
- ⚠️ **Memory Overhead:** ~500MB RAM for loaded embeddings (manageable on 8GB machines)
- ⚠️ **No Distributed Mode:** Single-node only (okay, we're desktop-first)

### Alternatives Considered

#### Option A: Pinecone/Weaviate (Cloud Vector DBs)
- **Pros:** Best performance, managed service
- **Cons:** ❌ NOT local-first, ❌ requires API keys, ❌ data sent to third-party
- **Rejected:** Violates privacy principle

#### Option B: FAISS (Facebook AI Similarity Search)
- **Pros:** Fastest in-memory search, highly optimized
- **Cons:** ❌ No persistence layer (must write own), ❌ harder to use than ChromaDB
- **Rejected:** Lower-level, more work to integrate

#### Option C: PostgreSQL with pgvector extension
- **Pros:** Unified database (relational + vector)
- **Cons:** ❌ Requires PostgreSQL daemon (breaks embedded principle), ❌ slower than specialized vector DBs
- **Rejected:** Over-complication

---

## ADR-005: Clean Architecture + Hexagonal Pattern

**Status:** ✅ Accepted
**Date:** 2026-01-15
**Decision Makers:** @ArchitectZero

### Context

**Problem:** Codebase must be:
- **Testable:** >80% code coverage, mockable dependencies
- **Maintainable:** Clear separation of concerns, easy to refactor
- **Framework-Independent:** Business logic NOT coupled to Flutter/FastAPI

**Constraints:**
- Team size: 1-2 developers
- Target: 6-month MVP timeline
- Long-term: Easy onboarding for new contributors

### Decision

**Adopt Clean Architecture with Hexagonal (Ports & Adapters) pattern.**

**Flutter Structure:**
```
src/client/lib/
├── core/                   # Shared utilities (error handling, extensions)
├── features/
│   ├── chat/
│   │   ├── domain/         # Entities, Use Cases (pure Dart)
│   │   ├── data/           # Repositories, DTOs, Data Sources
│   │   └── presentation/   # UI (Widgets, Notifiers, Screens)
│   └── project_shell/
│       ├── domain/
│       ├── data/
│       └── presentation/
```

**Python Structure:**
```
src/server/
├── core/                   # Domain entities, base classes
├── services/               # Use case implementations
├── adapters/               # External integrations (ChromaDB, Ollama)
├── api/                    # FastAPI routers (HTTP boundary)
└── config/                 # Settings, environment variables
```

**Dependency Rule:**
```
Presentation → Domain ← Data
     ↓           ↑         ↓
   (UI)     (Logic)   (External)
```

### Consequences

**Positive:**
- ✅ **High Testability:** Business logic 100% unit testable (no mocks needed for domain layer)
- ✅ **Framework Agnostic:** Can swap Flutter → Native or FastAPI → Django without touching domain
- ✅ **Clear Contracts:** Interfaces (abstract classes) define all dependencies
- ✅ **Onboarding:** New developers understand where to add code (feature folders)

**Negative:**
- ⚠️ **Boilerplate:** More files per feature (entity, use case, repository interface, repository impl)
- ⚠️ **Over-Engineering Risk:** Small features can feel over-abstracted
- ⚠️ **Learning Curve:** Team must understand Dependency Inversion Principle

### Alternatives Considered

#### Option A: MVC (Model-View-Controller)
- **Pros:** Simple, familiar to many developers
- **Cons:** ❌ Business logic bleeds into Controllers, ❌ harder to test
- **Rejected:** Not scalable for complex domains

#### Option B: Feature-First (Vertical Slices)
- **Pros:** Colocates all related code (UI + logic + data)
- **Cons:** ❌ Shared logic duplicated across features, ❌ harder to enforce consistency
- **Rejected:** Works for small apps, breaks down at scale

---

## ADR-006: Riverpod for State Management

**Status:** ✅ Accepted
**Date:** 2026-01-17
**Decision Makers:** @ArchitectZero

### Context

Flutter app needs to manage:
- **Global State:** Current project, user settings
- **Async State:** API calls, streaming responses
- **Derived State:** Workflow phase progress (calculated from documents)

**Requirements:**
- **Type-Safe:** Compile-time errors for missing providers
- **Testable:** Easy to mock providers in tests
- **DevTools:** Inspect state changes at runtime
- **Reactive:** UI auto-updates when state changes

### Decision

**Use Riverpod 2.5+ (with code generation) as the state management solution.**

**Example:**
```dart
// Provider definition
@riverpod
class ProjectNotifier extends _$ProjectNotifier {
  @override
  Future<Project?> build() async {
    final projectId = ref.watch(selectedProjectIdProvider);
    if (projectId == null) return null;
    return await ref.read(projectRepositoryProvider).getProject(projectId);
  }

  Future<void> updatePhase(int newPhase) async {
    state = AsyncLoading();
    state = await AsyncValue.guard(() async {
      return await ref.read(projectRepositoryProvider).updatePhase(newPhase);
    });
  }
}

// UI consumption
class ProjectScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final projectAsync = ref.watch(projectNotifierProvider);
    return projectAsync.when(
      data: (project) => ProjectView(project),
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => ErrorWidget(err.toString()),
    );
  }
}
```

### Consequences

**Positive:**
- ✅ **Type-Safe:** Compile errors if provider not found
- ✅ **No Boilerplate:** Code generation reduces manual setup
- ✅ **Easy Testing:** Override providers in tests with `ProviderContainer`
- ✅ **DevTools:** Inspect provider state, rebuild counts, dependencies
- ✅ **Reactive:** Auto-rebuild widgets on state change

**Negative:**
- ⚠️ **Code Generation:** Must run `build_runner` after adding providers
- ⚠️ **Build Time:** Codegen adds ~5s to build times (acceptable)
- ⚠️ **Learning Curve:** Requires understanding provider composition (`.family`, `.autoDispose`)

### Alternatives Considered

#### Option A: Provider (Original)
- **Pros:** Simple, well-documented
- **Cons:** ❌ Not type-safe (runtime errors common), ❌ harder to test
- **Rejected:** Riverpod is Provider 2.0, no reason to stay on old version

#### Option B: BLoC (Business Logic Component)
- **Pros:** Event-driven, popular in enterprise
- **Cons:** ❌ More boilerplate (events + states + bloc classes), ❌ overkill for simple features
- **Rejected:** Too much ceremony for desktop app

#### Option C: GetX
- **Pros:** Minimal boilerplate, all-in-one (routing + state + DI)
- **Cons:** ❌ NOT type-safe, ❌ "magic" global state (hard to reason about), ❌ poor testing story
- **Rejected:** Anti-pattern for large apps

---

## ADR-007: FastAPI for Backend Services

**Status:** ✅ Accepted
**Date:** 2026-01-18
**Decision Makers:** @ArchitectZero

### Context

Backend must:
- **Serve API:** Handle chat requests, document generation, knowledge base queries
- **Stream Responses:** Server-Sent Events (SSE) for token-by-token LLM streaming
- **Validate Input:** Strict schema validation (no malformed requests reach business logic)
- **Auto-Document:** Generate OpenAPI spec automatically

### Decision

**Use FastAPI 0.115+ (Python 3.12) as the backend framework.**

**Example Endpoint:**
```python
from fastapi import FastAPI, HTTPException
from fastapi.responses import StreamingResponse
from pydantic import BaseModel, Field

app = FastAPI(title="SoftArchitect AI API", version="1.0.0")

class ChatRequest(BaseModel):
    message: str = Field(..., min_length=1, max_length=10000)
    project_id: str
    user_name: str = "Developer"

@app.post("/api/v1/chat/stream")
async def stream_chat(request: ChatRequest):
    async def token_generator():
        llm = get_llm_client("ollama")
        async for token in llm.stream(request.message):
            yield f"data: {token}\n\n"

    return StreamingResponse(token_generator(), media_type="text/event-stream")
```

### Consequences

**Positive:**
- ✅ **Auto Validation:** Pydantic validates requests (422 errors on invalid data)
- ✅ **Auto Docs:** Swagger UI at `/docs`, ReDoc at `/redoc`
- ✅ **Async Native:** First-class `async/await` support (efficient I/O)
- ✅ **Type Hints:** Python 3.12 type checking prevents bugs
- ✅ **Fast:** 2-3x faster than Flask (ASGI vs. WSGI)

**Negative:**
- ⚠️ **Python Async Complexity:** Must understand event loops, coroutines
- ⚠️ **ASGI Server Required:** Need Uvicorn/Hypercorn (not built-in)

### Alternatives Considered

#### Option A: Flask
- **Pros:** Simple, mature, huge ecosystem
- **Cons:** ❌ Synchronous (blocks on I/O), ❌ manual validation, ❌ slower
- **Rejected:** Not suitable for streaming LLM responses

#### Option B: Django REST Framework
- **Pros:** Batteries-included, ORM, admin panel
- **Cons:** ❌ Overkill (we don't need ORM/admin), ❌ slower than FastAPI, ❌ more complex
- **Rejected:** Over-engineering

---

## ADR-008: Server-Sent Events (SSE) for Streaming

**Status:** ✅ Accepted
**Date:** 2026-01-19
**Decision Makers:** @ArchitectZero

### Context

**Problem:** Users expect real-time token-by-token streaming (like ChatGPT) rather than waiting 30 seconds for full response.

**Requirements:**
- **Low Latency:** Show first token <2s
- **Standard Protocol:** Use HTTP (no custom WebSocket protocol)
- **Simple Client:** Flutter HTTP client must work without extra libs

### Decision

**Use Server-Sent Events (SSE) for LLM token streaming.**

**Backend (FastAPI):**
```python
from fastapi.responses import StreamingResponse

async def token_generator(prompt: str):
    async for token in llm_client.stream(prompt):
        yield f"data: {json.dumps({'content': token})}\n\n"
    yield "event: done\ndata: {}\n\n"

@app.post("/chat/stream")
async def stream_chat(request: ChatRequest):
    return StreamingResponse(
        token_generator(request.message),
        media_type="text/event-stream",
        headers={"Cache-Control": "no-cache", "X-Accel-Buffering": "no"}
    )
```

**Frontend (Flutter):**
```dart
final response = await http.post(Uri.parse('$baseUrl/chat/stream'), body: jsonEncode(request));
final stream = response.stream.transform(utf8.decoder).transform(LineSplitter());

await for (final line in stream) {
  if (line.startsWith('data: ')) {
    final json = jsonDecode(line.substring(6));
    yield json['content'];  // Emit token to UI
  }
}
```

### Consequences

**Positive:**
- ✅ **Standard Protocol:** SSE is W3C standard, works everywhere
- ✅ **HTTP-Based:** No WebSocket firewall issues
- ✅ **Automatic Reconnect:** Browsers auto-reconnect on disconnect
- ✅ **Simple Client:** Flutter's `http` package handles streaming natively

**Negative:**
- ⚠️ **Unidirectional:** Server → Client only (okay, we don't need bidirectional)
- ⚠️ **No Binary Data:** Text-only (okay, we stream JSON)

### Alternatives Considered

#### Option A: WebSockets
- **Pros:** Bidirectional, binary support
- **Cons:** ❌ More complex (handshake, ping/pong), ❌ firewall issues, ❌ overkill for one-way stream
- **Rejected:** Unnecessary complexity

#### Option B: Long Polling
- **Pros:** Simple, works everywhere
- **Cons:** ❌ High latency (poll every 500ms), ❌ inefficient (many HTTP requests)
- **Rejected:** Poor UX

---

## ADR-009: Phase-Based Workflow State Machine

**Status:** ✅ Accepted
**Date:** 2026-01-21
**Decision Makers:** @ArchitectZero

### Context

**Problem:** Users can get stuck not knowing "what to do next" after creating a project. Need guided progression.

**Solution:** Master Workflow 0-100 divided into 7 phases with clear prerequisites.

### Decision

**Implement a Phase-Based State Machine with prerequisite validation.**

**Phases:**
```
Phase 0: Discovery (INTERVIEW, PROJECT_BRIEF)
Phase 1: Requirements (VISION, PROMISE, JOURNEY_MAP, EXECUTIVE_SUMMARY, GLOSSARY, FUNCTIONAL_REQUIREMENTS, NON_FUNCTIONAL_REQUIREMENTS)
Phase 2: Architecture (TECH_STACK, API_CONTRACT, DATABASE_SCHEMA, SYSTEM_DIAGRAM, ADR)
Phase 3: Planning (USER_STORIES, SPRINT_PLAN, FIRST_SPRINT_GUIDE, DOR_DOD)
Phase 4: Setup (README, CONTRIBUTING, DEPLOYMENT)
```

**State Machine:**
```python
def can_progress_to_phase(project_id: str, target_phase: int) -> Result[bool, str]:
    required_docs = PHASE_PREREQUISITES[target_phase]
    completed_docs = get_completed_documents(project_id)
    missing = set(required_docs) - set(completed_docs)

    if missing:
        return Err(f"Missing: {', '.join(missing)}")
    return Ok(True)
```

### Consequences

**Positive:**
- ✅ **Guided UX:** UI shows "Next: Create Tech Stack" instead of blank screen
- ✅ **Progress Tracking:** Visual indicator "Phase 2 - 66% complete (6/9 docs)"
- ✅ **Validation:** Prevents skipping critical documents

**Negative:**
- ⚠️ **Rigid:** Cannot skip phases (need override mechanism for power users)
- ⚠️ **Maintenance:** Must update prerequisites when adding new document types

---

## ADR-010: No Cloud Telemetry by Default

**Status:** ✅ Accepted
**Date:** 2026-01-22
**Decision Makers:** @ArchitectZero

### Context

**Question:** Should we collect anonymous usage analytics (crash reports, feature usage) to improve the product?

**Privacy Principle:** "Data sovereignty" means users control 100% of their data. No silent data collection.

### Decision

**Telemetry is OPT-IN ONLY with explicit consent.**

**Implementation:**
1. **First Launch:** Show consent dialog:
   ```
   "Help improve SoftArchitect AI?

   We collect anonymous usage data (feature clicks, error logs) to improve the product.
   NO personal data or project content is collected.

   [✅ Yes, send anonymous telemetry]  [❌ No thanks]"
   ```

2. **Storage:** If opted-in, store events locally in SQLite first:
   ```sql
   CREATE TABLE telemetry_events (
       id INTEGER PRIMARY KEY,
       event_type TEXT,  -- "feature_used", "error_occurred"
       event_data TEXT,  -- JSON: {"feature": "chat", "duration_ms": 450}
       timestamp TEXT,
       session_id TEXT   -- Anonymous UUID (no user identification)
   );
   ```

3. **Upload:** Batch send every 24h (if internet available, else discard)

### Consequences

**Positive:**
- ✅ **Respects Privacy:** Users choose (not forced)
- ✅ **Transparent:** Clear explanation of what's collected
- ✅ **Offline-First:** Works without telemetry (no crashes if opt-out)

**Negative:**
- ⚠️ **Lower Adoption:** Most users will opt-out (~80% typically decline)
- ⚠️ **Incomplete Data:** Cannot measure real usage accurately

### Alternatives Considered

#### Option A: Mandatory Telemetry
- **Pros:** Accurate usage data, better product decisions
- **Cons:** ❌ Violates privacy promise, ❌ loses trust
- **Rejected:** Non-negotiable ethical violation

#### Option B: No Telemetry at All
- **Pros:** Maximum privacy
- **Cons:** ❌ Blind to user pain points, ❌ cannot prioritize features
- **Considered:** Acceptable but suboptimal; opt-in is middle ground

---

## 📎 Appendix: ADR Template

Use this template for future decisions:

```markdown
## ADR-XXX: [Title]

**Status:** 🟡 Proposed | ✅ Accepted | ❌ Rejected | 🔵 Superseded
**Date:** YYYY-MM-DD
**Decision Makers:** @username

### Context
[What problem are we solving? What are the constraints?]

### Decision
[What did we decide to do and why?]

### Consequences
**Positive:**
- ✅ [Benefit 1]

**Negative:**
- ⚠️ [Drawback 1]

### Alternatives Considered
#### Option A: [Name]
- **Pros:** [...]
- **Cons:** [...]
- **Rejected:** [Why]
```

---

## 🔗 Related Documents

- **Tech Stack:** [TECH_STACK_EXAMPLE.md](03-TECH_STACK_EXAMPLE.md)
- **API Contract:** [API_CONTRACT_EXAMPLE.md](13-API_CONTRACT_EXAMPLE.md)
- **Deployment:** [DEPLOYMENT_EXAMPLE.md](19-DEPLOYMENT_EXAMPLE.md)

---

> **Document Metadata:**
> **Created:** 2026-01-15
> **Last Updated:** 2026-02-23
> **Status:** ✅ Living Document (continuously updated)
> **Review Frequency:** Before major architectural changes
> **Maintainer:** Architecture Team
