# 🗺️ Project Structure Map (Monorepo)

> **Golden Rule:** "A place for everything, and everything in its place". The structure is immutable without prior architectural discussion.

---

## 1. Root Level (The Root)

```text
soft-architect-ai/
├── .env.example             # Environment variables template (NO secrets)
├── docker-compose.yml       # Service orchestration
├── README.md                # Project cover
├── context/                 # 🧠 METADATA: Rules and Context for Agents
├── doc/                     # 📘 HUMANOS: Logbook, ADRs and Guides
├── infrastructure/          # ⚙️ DEVOPS: Docker configs, Nginx, Scripts
├── packages/
│   └── knowledge_base/      # 🤖 RAG ASSETS: Injectable brain
└── src/                     # 💻 CODE: The real implementation

```

---

## 2. Detail: `src/client` (Flutter App)

We follow **Clean Architecture** oriented to Features ("Feature-First").

```text
src/client/lib/
├── main.dart                # Entry Point
├── core/                    # Shared components and configuration
│   ├── config/              # Env vars, Theme config
│   ├── router/              # GoRouter configuration
│   └── utils/               # Pure helpers
├── features/                # Functional modules
│   ├── chat/                # Main feature
│   │   ├── data/            # Repositories (Impl) and Datasources (API)
│   │   ├── domain/          # Entities and Contracts (Interfaces)
│   │   └── presentation/    # Widgets, Screens and Providers (Riverpod)
│   ├── settings/            # Model configuration (Local/Cloud)
│   └── knowledge/           # Knowledge base management
└── shared/                  # Reusable UI Widgets (Buttons, Inputs)

```

---

## 3. Detail: `src/server` (Python Backend)

Architecture of **Modular Monolith** based on domains.

```text
src/server/app/
├── main.py                  # Entry Point FastAPI
├── core/                    # Global configuration
│   ├── config.py            # Settings and environment
│   ├── database.py          # ChromaDB connection
│   └── security.py          # Sanitizers and validators
├── api/                     # API routes
│   ├── v1/                  # Versioned endpoints
│   │   ├── chat.py          # Chat and streaming
│   │   ├── knowledge.py     # Ingestion and retrieval
│   │   └── health.py        # Health checks
│   └── dependencies.py      # Shared dependencies
├── domain/                  # Business logic
│   ├── entities/            # Core entities (Message, Session)
│   ├── services/            # Use cases and business rules
│   └── repositories/        # Abstract data interfaces
├── infrastructure/          # External integrations
│   ├── llm/                 # LLM providers (Ollama, Groq)
│   ├── vector_store/        # ChromaDB implementation
│   └── external/            # Third-party APIs
└── tests/                   # Test suite
    ├── unit/                # Unit tests
    ├── integration/         # Integration tests
    └── fixtures/            # Test data

```

---

## 4. Detail: `packages/knowledge_base/` (RAG Brain)

Modular knowledge structure for AI consumption.

```text
packages/knowledge_base/
├── 00-META-CONTEXT/         # System personality and vision
├── 01-TEMPLATES/            # Reusable templates (ADRs, Security)
├── 02-TECH-PACKS/           # Technology-specific rules
│   ├── flutter/             # Flutter best practices
│   ├── python/              # Python patterns
│   └── general/             # Cross-cutting concerns
└── 03-EXAMPLES/             # Reference projects

```

---

## 5. Detail: `context/` (Agent Context)

Structured documentation for AI agents.

```text
context/
├── 10-BUSINESS_AND_SCOPE/   # Vision, MVP, Requirements
├── 20-REQUIREMENTS_AND_SPEC/ # Specs, Security, Testing
├── 30-ARCHITECTURE/         # Stack, Maps, Design System
└── 40-ROADMAP/              # GitFlow, Phases, Backlog

```

---

## 6. Detail: `doc/` (Human Documentation)

Living documentation for the project.

```text
doc/
├── 00-VISION/               # White Paper, Concept
├── 01-PROJECT_REPORT/       # Methodology, POC
├── 02-SETUP_DEV/            # Guides, Stack, Automation
└── private/                 # Internal notes (not for AI)

```

---

## 7. Detail: `infrastructure/` (DevOps)

Deployment and orchestration configs.

```text
infrastructure/
├── docker-compose.yml       # Local development
├── nginx.conf               # Reverse proxy (future)
└── scripts/                 # Build and deploy scripts

```

---

## 8. Naming Conventions

* **Directories:** `snake_case` for technical, `PascalCase` for features.
* **Files:** `PascalCase.md` for docs, `snake_case.py` for code.
* **Variables:** `camelCase` in Dart, `snake_case` in Python.
* **Commits:** Conventional commits (`feat:`, `fix:`, `docs:`).