# 📜 Project Manifesto - SoftArchitect AI

> **Document Type:** Vision & Architectural Principles
> **Last Updated:** 2025-01-15
> **Maintainer:** @ArchitectZero
> **Status:** ✅ Adopted
> **Version:** 2.1.0

---

## 📖 Table of Contents

- [Our Vision](#our-vision)
- [Core Mission](#core-mission)
- [Guiding Principles](#guiding-principles)
- [Core Values](#core-values)
- [Architectural Principles](#architectural-principles)
- [Non-Negotiables](#non-negotiables)
- [Design Philosophy](#design-philosophy)
- [User Experience Tenets](#user-experience-tenets)
- [Technical Excellence Standards](#technical-excellence-standards)
- [Security & Privacy Commitment](#security--privacy-commitment)
- [Community Principles](#community-principles)
- [Decision-Making Framework](#decision-making-framework)
- [Anti-Patterns & Prohibitions](#anti-patterns--prohibitions)
- [Manifesto Adherence](#manifesto-adherence)

---

## 📋 Generation Metadata

> **Order:** 6/24 | **Phase:** 1 - Context | **Duration:** ~35 mins
> **Prerequisites:** Phase 0 complete, DOMAIN_LANGUAGE
> **Generates:** USER_JOURNEY_MAP → TECH_STACK_DECISION

**Purpose:** Define project vision and principles before technical decisions.

---

## 🚀 Our Vision

### The North Star

**By 2030, SoftArchitect AI will be the de facto local-first AI assistant that empowers every developer—from solo indie hackers to enterprise teams—to architect production-ready software with confidence, clarity, and speed.**

### What Success Looks Like

- **1 Million Projects Architected** using Master Workflow by 2028
- **Zero Cloud Dependencies** for core functionality (100% offline capability)
- **Sub-2-Second Response Times** for RAG queries on consumer hardware
- **Zero Data Breaches** (privacy-first architecture makes this structurally impossible)
- **Industry Recognition** as the gold standard for AI-assisted software architecture

### The Problem We Solve

**Before SoftArchitect AI:**
- Developers waste **40-60 hours** writing initial documentation (architecture, API contracts, schemas)
- **70% of projects** suffer from "analysis paralysis" (too many design choices, no clear path)
- **Security and privacy are afterthoughts**, bolted on after core implementation
- **Knowledge silos** form (no single source of truth for project decisions)

**After SoftArchitect AI:**
- Comprehensive project documentation **generated in 90-120 minutes**
- **Clear, structured workflow** eliminates decision fatigue
- **Security and privacy baked in** from first document (threat modeling, OWASP compliance)
- **Single knowledge base** accessible via RAG for instant answers

---

## 🎯 Core Mission

**Empower developers to build better software, faster, without compromising on quality, security, or privacy.**

### Mission Breakdown

1. **Accessibility:** Lower the barrier to professional software architecture for all skill levels
2. **Velocity:** Reduce time-to-first-line-of-code from weeks to hours
3. **Quality:** Ensure generated artifacts meet industry best practices (Clean Architecture, SOLID, DDD)
4. **Privacy:** Protect user data as if our lives depend on it (because their business does)
5. **Education:** Teach architectural principles through AI-generated examples (learning by doing)

---

## 🧭 Guiding Principles

### 1. Local-First, Cloud-Optional

**Principle:**
SoftArchitect AI works entirely offline with Ollama. Cloud LLMs (Groq, OpenAI) are opt-in enhancements, not requirements.

**Why:**
- **Privacy:** User data never leaves their machine
- **Reliability:** Internet outages don't block work
- **Cost:** No recurring API fees for core functionality

**Example Decision:**
```
❌ WRONG: "Let's require OpenAI API for RAG queries"
✅ RIGHT: "Use Ollama locally; add OpenAI as optional provider"
```

---

### 2. Documentation as Code

**Principle:**
Documentation is versioned, reviewed, and maintained with the same rigor as source code.

**Implementation:**
- All docs in Git (Markdown format)
- PRs required for documentation changes
- CI/CD checks for broken links, spelling, Markdown lint

**Why:**
- Documentation drift kills projects
- Outdated docs are worse than no docs
- Code + Docs symbiosis ensures accuracy

---

### 3. Security by Design, Not by Audit

**Principle:**
Security is embedded in every architectural decision from day one, not added after implementation.

**Implementation:**
- Threat modeling (STRIDE) before first sprint
- OWASP Top 10 checklist in every API contract
- Security requirements in Definition of Done

**Example:**
```markdown
## User Authentication Feature

### Security Checklist (Before Implementation):
- [ ] Password hashing (Argon2, never MD5/SHA-1)
- [ ] Rate limiting on login endpoint (5 attempts/minute)
- [ ] HTTPS-only (no plain HTTP)
- [ ] JWT token expiration (15 min access, 7 day refresh)
- [ ] Input validation (prevent SQL injection, XSS)
```

---

### 4. Progressive Disclosure of Complexity

**Principle:**
Present complexity gradually. Start simple, reveal advanced features as needed.

**UI Example:**
```
New User View:
┌────────────────────────┐
│ Create New Project     │  ← Simple button
│ [Start Interview]      │
└────────────────────────┘

Power User View (after 5 projects):
┌────────────────────────┐
│ Create New Project     │
│ [Start Interview]      │
│ [Import Existing Docs] │  ← Advanced feature
│ [Clone from Template]  │  ← Advanced feature
└────────────────────────┘
```

---

### 5. Convention over Configuration

**Principle:**
Provide sensible defaults that work for 80% of users. Allow customization for power users.

**Example:**
```yaml
# Default RAG Configuration (zero-config for new users)
rag:
  model: "nomic-embed-text"  # Ollama default
  chunk_size: 1000            # Optimal for most docs
  top_k: 5                    # Balance relevance vs latency

# Power User Override (optional config file)
rag:
  model: "text-embedding-3-small"  # OpenAI upgrade
  chunk_size: 512                  # For code-heavy docs
  top_k: 10                        # More context
```

---

## 💎 Core Values

### 1. Privacy is Sacred 🔒

**Definition:**
User data is theirs, not ours. We collect nothing, track nothing, sell nothing.

**Enforcement:**
- No telemetry whatsoever
- No crash reporting (local logs only)
- No "opt-out" analytics (there's nothing to opt out of)
- No cloud sync (local-only storage)

**Code of Conduct:**
```python
# ❌ PROHIBITED CODE
import analytics
analytics.track_event("project_created")

# ✅ ALLOWED CODE
logger.info("Project created")  # Local log only
```

**Verification:**
```bash
# Run before every release
$ grep -r "analytics\|telemetry\|track" src/
# Expected: 0 results
```

---

### 2. Speed is a Feature ⚡

**Definition:**
Fast software is delightful software. Latency is a bug.

**Performance Budget:**
| Action | Max Latency | Target |
|--------|-------------|--------|
| UI Button Click → Response | 200ms | 100ms |
| RAG Query (Ollama) | 2s | 1s |
| RAG Query (Groq) | 1s | 500ms |
| Document Generation | 10s | 5s |
| Project Creation | 500ms | 200ms |

**Testing:**
```python
def test_rag_query_latency():
    start = time.perf_counter()
    results = rag_service.query("Clean Architecture principles")
    latency = time.perf_counter() - start

    assert latency < 2.0, f"RAG query exceeded 2s budget: {latency:.2f}s"
```

**Optimization Philosophy:**
- Measure before optimizing (no premature optimization)
- Profile in production-like environments
- 80/20 rule: Optimize the 20% of code that takes 80% of time

---

### 3. Simplicity over Cleverness 🧘

**Definition:**
Write code that a junior developer can understand. Avoid "genius" one-liners.

**Good Example:**
```python
# ✅ CLEAR (preferred)
def calculate_relevance_score(query_embedding, document_embedding):
    """Calculate cosine similarity between query and document."""
    dot_product = np.dot(query_embedding, document_embedding)
    query_norm = np.linalg.norm(query_embedding)
    doc_norm = np.linalg.norm(document_embedding)

    similarity = dot_product / (query_norm * doc_norm)
    return similarity
```

**Bad Example:**
```python
# ❌ CLEVER (avoid)
calc_score = lambda q, d: (q @ d) / (np.linalg.norm(q) * np.linalg.norm(d))
```

**Justification:**
- Debugging is harder than writing
- Code is read 10x more than written
- Future contributors thank you

---

### 4. Open by Default 🌐

**Definition:**
Everything is open-source (Apache 2.0 license) unless legally prohibited.

**What's Open:**
- Core application (100% of src/)
- Documentation (100% of doc/)
- Knowledge base templates
- Training data (sanitized examples)

**What's Private:**
- User projects (stored locally, never uploaded)
- API keys (if user configures cloud LLMs)
- Crash reports (if generated, stored locally only)

---

## 🏗️ Architectural Principles

### 1. Clean Architecture (Uncle Bob)

**Principle:**
Organize code in concentric layers: Domain (inner) → Use Cases → Adapters → Frameworks (outer).

**Dependency Rule:** Outer layers depend on inner layers, never reverse.

```
┌─────────────────────────────────────┐
│   Frameworks & Drivers (Flutter)    │  ← Outermost
│  ┌───────────────────────────────┐  │
│  │  Interface Adapters (Riverpod) │  │
│  │  ┌─────────────────────────┐  │  │
│  │  │   Use Cases (Interactors)│  │  │
│  │  │  ┌───────────────────┐  │  │  │
│  │  │  │  Domain (Entities) │  │  │  │  ← Innermost
│  │  │  │                    │  │  │  │
│  │  │  └───────────────────┘  │  │  │
│  │  └─────────────────────────┘  │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

**Example Structure:**
```
src/client/lib/
├── domain/                # Pure business logic (no Flutter imports)
│   ├── entities/          # Project, Document, User
│   └── repositories/      # Abstract interfaces
├── data/                  # Repository implementations
│   ├── repositories/      # Concrete classes (SQLite, JSON)
│   └── models/            # DTOs (Data Transfer Objects)
├── presentation/          # UI layer
│   ├── providers/         # Riverpod state management
│   └── widgets/           # Flutter components
└── core/                  # Shared utilities (DI, error handling)
```

---

### 2. SOLID Principles

#### S - Single Responsibility Principle

**Definition:** A class should have one reason to change.

**Example:**
```python
# ❌ WRONG: Multiple responsibilities
class ProjectService:
    def create_project(self, name: str) -> Project: ...
    def save_to_database(self, project: Project) -> None: ...
    def render_ui(self, project: Project) -> str: ...  # UI logic in service!

# ✅ RIGHT: Separated concerns
class ProjectService:
    def create_project(self, name: str) -> Project: ...

class ProjectRepository:
    def save(self, project: Project) -> None: ...

class ProjectPresenter:
    def render(self, project: Project) -> str: ...
```

#### O - Open/Closed Principle

**Definition:** Open for extension, closed for modification.

**Example:**
```python
# ✅ Strategy pattern for LLM providers
class LlmProvider(ABC):
    @abstractmethod
    def complete(self, prompt: str) -> str: ...

class OllamaProvider(LlmProvider):
    def complete(self, prompt: str) -> str:
        # Ollama API logic
        ...

class GroqProvider(LlmProvider):
    def complete(self, prompt: str) -> str:
        # Groq API logic
        ...

# Adding new provider = new class, no changes to existing code
class OpenAIProvider(LlmProvider):
    def complete(self, prompt: str) -> str:
        # OpenAI API logic
        ...
```

---

### 3. Domain-Driven Design (DDD)

**Principle:**
Align software structure with business domain. Use ubiquitous language everywhere.

**Key Concepts:**
- **Entities:** Objects with unique identity (Project, User)
- **Value Objects:** Immutable objects without identity (ProjectName, TechStack)
- **Aggregates:** Clusters of entities with consistency boundaries (ProjectAggregate)
- **Repositories:** Persistence abstraction (ProjectRepository)
- **Domain Services:** Business logic that doesn't fit in entities (EmbeddingService)

**Example:**
```python
# Domain Entity
class Project:
    id: ProjectId  # Value Object
    name: ProjectName  # Value Object
    documents: List[Document]

    def add_document(self, doc: Document) -> None:
        """Business rule: No duplicate document types."""
        if any(d.type == doc.type for d in self.documents):
            raise DuplicateDocumentError(doc.type)
        self.documents.append(doc)
```

---

## 🚫 Non-Negotiables

These principles are **immutable**. Violating them requires unanimous team vote and documented justification.

### 1. Zero Tolerance for Security Negligence

**Rule:**
All security vulnerabilities are P0 (highest priority). Drop everything to fix.

**Examples:**
- SQL injection vulnerability discovered → Immediate hotfix, same day
- Hardcoded API key in code → Revert commit, rotate key, post-mortem
- Unencrypted sensitive data → Block release, fix before shipping

---

### 2. No User Data in Logs or Telemetry

**Rule:**
Never log PII (Personally Identifiable Information) or sensitive project data.

**Allowed:**
```python
logger.info("Project created successfully")  # ✅ Generic event
logger.debug(f"Document count: {len(documents)}")  # ✅ Aggregate data
```

**Prohibited:**
```python
logger.info(f"User created project: {project.name}")  # ❌ Project name is PII
logger.debug(f"API key: {api_key}")  # ❌ Secrets
```

---

### 3. Local-First Architecture (No Cloud Lock-In)

**Rule:**
Core functionality works 100% offline. Cloud features are enhancements, not dependencies.

**Test:**
```bash
# Unplug ethernet, disable Wi-Fi
# Expected: All core features work (project creation, RAG with Ollama)
```

---

## 🎨 Design Philosophy

### 1. Beauty through Simplicity

**Principle:**
Elegant design emerges from constraints, not ornamentation.

**UI Example:**
```
❌ BAD (Over-designed):
┌─────────────────────────────────────┐
│ ✨ CREATE NEW PROJECT ✨            │
│ [Sparkle Animation]                 │
│ [Gradient Button with Shadow]       │
│ [Tooltip on Hover]                  │
│ [Animated Icon]                     │
└─────────────────────────────────────┘

✅ GOOD (Minimalist):
┌─────────────────────────────────────┐
│ Create Project                      │
│ [Simple Button]                     │
└─────────────────────────────────────┘
```

---

### 2. Function Dictates Form

**Principle:**
Design follows purpose. No feature exists purely for aesthetics.

**Example:**
```
❌ "Let's add a 3D rotating logo because it looks cool"
✅ "Let's add a progress indicator because users need feedback"
```

---

## 🧑‍💻 User Experience Tenets

### 1. Never Block the User

**Principle:**
Long-running operations (RAG queries, document generation) happen asynchronously. UI remains responsive.

**Implementation:**
```dart
// ✅ Non-blocking UI
Future<void> generateDocument(DocumentType type) async {
  setState(() => isGenerating = true);  // Show spinner

  final doc = await documentService.generate(type);  // Async

  setState(() {
    isGenerating = false;
    documents.add(doc);
  });
}
```

---

### 2. Show, Don't Tell

**Principle:**
Visualize concepts (diagrams, progress bars) instead of walls of text.

**Example:**
```
❌ BAD (Text-heavy):
"Your project is currently in the Architecture phase, which is phase 3 of 5 total phases. You have completed 14 out of 24 documents."

✅ GOOD (Visual):
[████████████░░░░░░░░░░░░] 14/24 Documents
Phase 3: Architecture
```

---

### 3. Fail Gracefully

**Principle:**
Errors are inevitable. Handle them elegantly with actionable guidance.

**Good Error Message:**
```
❌ Connection Failed

We couldn't reach ChromaDB (localhost:8000).

Possible fixes:
1. Start ChromaDB: docker-compose up -d
2. Check port 8000 is not in use: lsof -i :8000
3. Restart Docker: docker restart chromadb

[Retry] [View Logs] [Get Help]
```

**Bad Error Message:**
```
Error: ECONNREFUSED 127.0.0.1:8000
```

---

## 🏆 Technical Excellence Standards

### Code Coverage Requirements

| Component | Minimum | Target |
|-----------|---------|--------|
| Domain Logic | 100% | 100% |
| Services | 90% | 95% |
| API Endpoints | 85% | 90% |
| UI Widgets | 80% | 85% |
| Infrastructure | 70% | 80% |

**Enforcement:**
```bash
# CI/CD blocks merge if coverage drops below minimum
pytest --cov=src/server --cov-fail-under=85
```

---

### Code Review Standards

**All PRs require:**
- 1 approval from core team member
- All CI checks passing (tests, lint, type checks)
- No open "Blocking" review comments
- Updated documentation (if applicable)

**Review Checklist:**
- [ ] Code follows SOLID principles
- [ ] Tests added/updated
- [ ] No hardcoded secrets
- [ ] Error handling present
- [ ] Documentation accurate

---

## 🔐 Security & Privacy Commitment

### The Privacy Pledge

**We commit to:**
1. **Never collect** user data (no analytics, no telemetry, no crash reports to cloud)
2. **Never require** cloud accounts (no login, no OAuth, no forced cloud sync)
3. **Never sell** user data (impossible—we don't have it)
4. **Always encrypt** sensitive data at rest (API keys, project settings)
5. **Always disclose** when data leaves the machine (opt-in cloud LLMs only)

### Security Standards

**OWASP Top 10 Compliance:**
- A01: Broken Access Control → Mitigated (local-first, no network attack surface)
- A02: Cryptographic Failures → Mitigated (AES-256 for sensitive data)
- A03: Injection → Mitigated (parameterized queries, input validation)
- A04: Insecure Design → Mitigated (threat modeling before implementation)
- A05: Security Misconfiguration → Mitigated (secure defaults, minimal attack surface)
- A06: Vulnerable Components → Mitigated (automated dependency scanning)
- A07: Authentication Failures → N/A (no authentication)
- A08: Software/Data Integrity → Mitigated (code signing, dependency pinning)
- A09: Logging Failures → Mitigated (local logs, no PII)
- A10: SSRF → Mitigated (no external requests except opt-in LLM APIs)

---

## 🤝 Community Principles

### 1. Respectful Discourse

**We value:**
- Constructive criticism (focus on code, not person)
- Diverse perspectives (no "one true way" dogma)
- Patience with newcomers (everyone was a beginner once)

**We reject:**
- Personal attacks
- Gatekeeping ("you're not a real developer if...")
- Discrimination (race, gender, experience level, etc.)

---

### 2. Recognition & Credit

**We celebrate:**
- All contributors (code, docs, design, bug reports)
- First-time contributors (special recognition in release notes)
- Long-term maintainers (yearly awards)

**Implementation:**
- All Contributors specification in README
- Contributor of the Month program
- Shoutouts in release changelogs

---

## ⚖️ Decision-Making Framework

When facing architectural decisions, evaluate against these criteria:

### Decision Matrix

| Criterion | Weight | How to Evaluate |
|-----------|--------|-----------------|
| **User Privacy** | 30% | Does it protect user data? |
| **Performance** | 20% | Does it meet latency budgets? |
| **Simplicity** | 20% | Is it the simplest viable solution? |
| **Extensibility** | 15% | Can we adapt it later? |
| **Cost** | 10% | Is it sustainable (maintenance, hosting)? |
| **Security** | 5% | Does it introduce vulnerabilities? |

### Example Decision: LLM Provider Selection

**Options:**
1. Ollama only (local)
2. Groq only (cloud, fast)
3. Hybrid (Ollama default, Groq optional)

**Evaluation:**

| Criterion | Ollama | Groq | Hybrid |
|-----------|--------|------|--------|
| Privacy (30%) | 30 | 0 | 30 |
| Performance (20%) | 15 | 20 | 20 |
| Simplicity (20%) | 20 | 20 | 15 |
| Extensibility (15%) | 10 | 10 | 15 |
| Cost (10%) | 10 | 5 | 10 |
| Security (5%) | 5 | 3 | 5 |
| **Total** | **90** | **58** | **95** ✅ |

**Decision:** Hybrid approach (wins by balancing privacy + performance)

---

## 🚫 Anti-Patterns & Prohibitions

### What We Never Do

1. **Premature Optimization**
   - ❌ "Let's cache everything"
   - ✅ "Let's measure first, then optimize the bottleneck"

2. **Resume-Driven Development**
   - ❌ "Let's use Kubernetes because it looks good on my CV"
   - ✅ "Let's use Docker Compose because it solves our problem simply"

3. **Not Invented Here Syndrome**
   - ❌ "Let's build our own vector database"
   - ✅ "Let's use ChromaDB (proven, maintained, fast)"

4. **Feature Creep**
   - ❌ "Let's add blockchain integration!"
   - ✅ "Does this serve the core mission? No? Then no."

5. **Implicit Knowledge**
   - ❌ "Everyone just knows how RAG works"
   - ✅ "Document it in DOMAIN_LANGUAGE.md"

---

## 📊 Manifesto Adherence

### How We Enforce These Principles

**1. Code Reviews:**
- Reviewers cite manifesto principles when blocking PRs
- Example: "This PR violates 'Show, Don't Tell'—add a diagram"

**2. Architecture Decision Records (ADRs):**
- All decisions reference manifesto principles
- Example ADR: "We chose SQLite over PostgreSQL because 'Simplicity over Cleverness' applies (no separate server needed)"

**3. Retrospectives:**
- Quarterly review: "Did we uphold our values this quarter?"
- Identify drift, correct course

**4. Onboarding:**
- New contributors read this manifesto first
- Quiz on core principles before merge access

---

## 🔄 Living Document

**This manifesto evolves as we learn.**

**Update Process:**
1. Propose change via PR
2. Discuss in team meeting
3. Vote (75% approval threshold)
4. Update version number, changelog

**Version History:**

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2024-06-01 | Initial manifesto (vision, values, principles) |
| 2.0.0 | 2024-12-01 | Added architectural principles (Clean Architecture, SOLID, DDD) |
| 2.1.0 | 2025-01-15 | Added decision-making framework, anti-patterns |

---

## 🙏 Acknowledgments

This manifesto was inspired by:
- **Clean Architecture** (Robert C. Martin)
- **Domain-Driven Design** (Eric Evans)
- **The Pragmatic Programmer** (Hunt & Thomas)
- **Build** (Tony Fadell) - Hardware design philosophy
- **Local-First Software** (Kleppmann et al.)

---

> **"Perfection is achieved not when there is nothing more to add, but when there is nothing left to take away."**
> — Antoine de Saint-Exupéry

> **"Make it work, make it right, make it fast—in that order."**
> — Kent Beck

> **"Privacy is not for sale, it is a right."**
> — SoftArchitect AI Team
