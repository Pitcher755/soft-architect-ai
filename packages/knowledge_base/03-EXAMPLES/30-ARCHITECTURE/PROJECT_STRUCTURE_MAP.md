# 📊 Project Structure Map: SoftArchitect AI

> **Versión:** 1.0
> **Fecha:** 30/01/2026
> **Estado:** ✅ Completo

---

## 📖 Tabla de Contenidos

1. [Árbol de Directorios](#árbol-de-directorios)
2. [Descripción de Capas](#descripción-de-capas)
3. [Convenciones](#convenciones)
4. [Flujo de Datos](#flujo-de-datos)

---

## Árbol de Directorios

```
soft-architect-ai/
│
├── 📁 src/
│   ├── 📁 client/                    # 🎨 Frontend (Flutter Desktop)
│   │   ├── 📁 lib/
│   │   │   ├── 📁 domain/            # Business logic (Use Cases)
│   │   │   │   ├── entities/         # Core models
│   │   │   │   └── repositories.dart # Abstract interfaces
│   │   │   ├── 📁 data/              # Data layer (Repositories impl)
│   │   │   │   ├── datasources/      # Local storage, API calls
│   │   │   │   ├── models/           # DTOs (Data Transfer Objects)
│   │   │   │   └── repositories/     # Repository implementations
│   │   │   ├── 📁 presentation/      # UI Layer
│   │   │   │   ├── pages/            # Screens/Pages
│   │   │   │   ├── widgets/          # Reusable UI components
│   │   │   │   ├── providers/        # Riverpod state management
│   │   │   │   └── viewmodels/       # Business logic for UI
│   │   │   └── 📁 infrastructure/    # Platform-specific (Native channels)
│   │   ├── pubspec.yaml              # Dependencies
│   │   ├── analysis_options.yaml     # Linting rules
│   │   └── test/                     # Unit + widget tests
│   │
│   └── 📁 server/                    # 🚀 Backend (FastAPI + Python)
│       ├── 📁 api/
│       │   ├── 📁 v1/
│       │   │   ├── 📁 endpoints/     # API routes
│       │   │   └── router.py         # Route registration
│       │   └── __init__.py
│       ├── 📁 core/
│       │   ├── config.py             # App configuration
│       │   ├── errors.py             # Custom exceptions
│       │   └── logger.py             # Logging setup
│       ├── 📁 domain/
│       │   ├── 📁 models/            # Pydantic models
│       │   ├── 📁 schemas/           # Request/Response DTOs
│       │   └── 📁 interfaces/        # Abstract base classes
│       ├── 📁 services/              # Business logic
│       │   ├── 📁 rag/               # RAG orchestration
│       │   │   ├── retriever.py      # ChromaDB queries
│       │   │   ├── generator.py      # LLM calls (Ollama)
│       │   │   └── synthesizer.py    # RAG pipeline
│       │   ├── 📁 vectors/           # Vector DB management
│       │   └── document_service.py   # Document indexing
│       ├── 📁 infrastructure/        # External integrations
│       │   ├── 📁 storage/           # DB adapters
│       │   ├── 📁 cache/             # Redis (future)
│       │   └── logger.py             # Logging infrastructure
│       ├── 📁 tests/
│       │   ├── unit/                 # Unit tests
│       │   ├── integration/          # API tests
│       │   └── fixtures/             # Test data
│       ├── main.py                   # Application entry point
│       ├── requirements.txt          # Python dependencies
│       ├── .env.example              # Environment template
│       └── pyproject.toml            # Project metadata
│
├── 📁 packages/                      # Monorepo: Shared packages
│   └── 📁 knowledge_base/            # 🧠 Central knowledge hub
│       ├── 📁 01-TEMPLATES/          # Documentation templates
│       │   ├── 00-ROOT/              # Project root templates
│       │   ├── 10-CONTEXT/           # Context templates
│       │   ├── 20-REQUIREMENTS/      # Reqs templates
│       │   ├── 30-ARCHITECTURE/      # Architecture templates
│       │   ├── 35-UX_UI/             # Design templates
│       │   ├── 40-PLANNING/          # Planning templates
│       │   └── 99-META/              # Meta-documentation
│       │
│       ├── 📁 02-TECH-PACKS/         # Knowledge database (43 files)
│       │   ├── 📁 FRONTEND/          # React, Angular, Vue, Flutter, SwiftUI...
│       │   ├── 📁 BACKEND/           # Django, FastAPI, Go, Java, C#...
│       │   ├── 📁 DATA/              # PostgreSQL, MongoDB, Redis...
│       │   └── 📁 DEVOPS_CLOUD/      # Kubernetes, Docker, AWS, Azure...
│       │
│       └── 📁 03-EXAMPLES/           # Example projects (THIS)
│           ├── 00-ROOT/              # README, RULES, AGENTS
│           ├── 10-CONTEXT/           # Domain language, manifesto, journeys
│           ├── 20-REQUIREMENTS/      # Reqs, security, compliance
│           ├── 30-ARCHITECTURE/      # Tech decisions, API contracts, schemas
│           ├── 35-UX_UI/             # Design system, accessibility
│           ├── 40-PLANNING/          # CI/CD, deployment, roadmap, testing
│           └── TECH_PACKS/           # How SoftArchitect uses all tech-packs
│
├── 📁 context/                       # Project Context (Specifications)
│   ├── 10-BUSINESS_AND_SCOPE/        # Vision, user journeys
│   ├── 20-REQUIREMENTS_AND_SPEC/     # Technical requirements
│   ├── 30-ARCHITECTURE/              # Architecture decisions
│   ├── 40-ROADMAP/                   # Feature roadmap
│   └── SECURITY_HARDENING_POLICY.md  # Security standards
│
├── 📁 doc/                           # Project Documentation (Living)
│   ├── 00-VISION/                    # Vision papers
│   ├── 01-PROJECT_REPORT/            # Reports, analysis
│   ├── 02-SETUP_DEV/                 # Setup guides
│   ├── 03-HU-TRACKING/               # User story tracking
│   └── INDEX.md                      # Doc index
│
├── 📁 infrastructure/                # DevOps & Deployment
│   ├── docker-compose.yml            # Local dev stack
│   ├── Dockerfile                    # Python backend image
│   ├── Dockerfile.flutter            # Flutter build image (optional)
│   ├── nginx.conf                    # Reverse proxy (future)
│   ├── kubernetes/                   # K8s manifests (future)
│   ├── terraform/                    # Infrastructure as Code (future)
│   └── scripts/
│       ├── setup.sh                  # Initial setup
│       ├── start_stack.sh            # Start dev environment
│       └── stop_stack.sh             # Stop dev environment
│
├── 📁 scripts/                       # Utility scripts
│   ├── audit-english-compliance.sh   # Language audit
│   └── [otros scripts de soporte]
│
├── 📁 tests/                         # Integration tests
│   ├── test_api.py                   # API endpoint tests
│   ├── test_architecture.py          # Architecture tests
│   ├── test_config.py                # Configuration tests
│   └── test_errors.py                # Error handling tests
│
├── 📁 utils/                         # Shared utilities
│   ├── logger.py                     # Logging helpers
│   ├── validators.py                 # Input validation
│   └── decorators.py                 # Common decorators
│
├── 📁 .github/
│   └── 📁 workflows/                 # GitHub Actions CI/CD
│       ├── test.yml                  # Run tests
│       ├── lint.yml                  # Code quality checks
│       ├── security.yml              # Security audits
│       └── deploy.yml                # Deployment pipeline
│
├── 📄 README.md                      # Project overview (portada)
├── 📄 AGENTS.md                      # Agent persona (ArchitectZero)
├── 📄 RULES.md                       # Project rules & standards
├── 📄 CONTRIBUTING.md                # Contributing guidelines
├── 📄 LICENSE                        # MIT License
├── 📄 .gitignore                     # Git ignore rules
├── 📄 .env.example                   # Environment variables template
├── 📄 .pre-commit-config.yaml        # Pre-commit hooks
├── 📄 pyrightconfig.json             # Python type checking
│
└── 📄 docker-compose.yml             # Root-level compose (for orchestration)
```

---

## Descripción de Capas

### 🎨 Frontend (Client - Flutter)

**Ubicación:** `src/client/lib/`

**Capas (Clean Architecture):**

```
┌─────────────────────────────────┐
│   PRESENTATION (UI)             │  ← User interacts here
│   ├── pages/                    │  Screens (ChatScreen, ResultsScreen)
│   ├── widgets/                  │  Reusable components (DecisionMatrix)
│   ├── providers/                │  Riverpod state management
│   └── viewmodels/               │  Business logic for UI
├─────────────────────────────────┤
│   DOMAIN (Business Logic)       │  ← Pure business rules
│   ├── entities/                 │  Core models (Question, Decision)
│   └── repositories.dart         │  Abstract interfaces (contracts)
├─────────────────────────────────┤
│   DATA (Adapters)               │  ← Implementation details
│   ├── datasources/              │  Local storage, API calls
│   ├── models/                   │  DTOs (JSON serializable)
│   └── repositories/             │  Concrete implementations
└─────────────────────────────────┘
```

**Responsabilidades:**

- Render UI (responsive desktop)
- Manage user input
- State management (Riverpod)
- Call backend API
- Cache responses locally
- Display Decision Matrices

---

### 🚀 Backend (Server - FastAPI + Python)

**Ubicación:** `src/server/`

**Capas (Hexagonal/Ports-and-Adapters):**

```
┌─────────────────────────────────┐
│   API LAYER (FastAPI Routes)    │  ← HTTP endpoints
│   ├── endpoints/                │  POST /query, GET /search
│   └── router.py                 │  Route registration
├─────────────────────────────────┤
│   APPLICATION LAYER (Services)  │  ← Orchestration
│   ├── rag/                      │  RAG pipeline
│   │   ├── retriever.py          │  ChromaDB queries
│   │   ├── generator.py          │  LLM calls
│   │   └── synthesizer.py        │  Combine + format
│   └── vectors/                  │  Vector DB management
├─────────────────────────────────┤
│   DOMAIN LAYER (Models/Schemas) │  ← Pure business entities
│   ├── models/                   │  Pydantic models
│   └── schemas/                  │  Request/Response DTOs
├─────────────────────────────────┤
│   INFRASTRUCTURE LAYER          │  ← External systems
│   ├── storage/                  │  SQLite, ChromaDB adapters
│   ├── cache/                    │  Redis (future)
│   └── logger/                   │  Observability
└─────────────────────────────────┘
```

**Responsabilidades:**

- RESTful API endpoints
- RAG orchestration (retrieve → contextualize → generate)
- ChromaDB queries (vector search)
- Ollama integration (LLM inference)
- Error handling & validation
- Logging & monitoring

---

### 🧠 Knowledge Base (Packages)

**Ubicación:** `packages/knowledge_base/`

**Estructura:**

```
01-TEMPLATES/          ← Blueprints (empty templates)
  └─ Usados para generar nueva documentación

02-TECH-PACKS/         ← Fuente de verdad (43 files, 20K+ lines)
  ├─ FRONTEND/         (React, Angular, Vue, Flutter, SwiftUI)
  ├─ BACKEND/          (Django, FastAPI, Go, Java, C#)
  ├─ DATA/             (PostgreSQL, MongoDB, Redis)
  └─ DEVOPS_CLOUD/     (Kubernetes, Docker, AWS, Azure)

03-EXAMPLES/           ← Filled templates (THIS PROJECT)
  └─ Ejemplo de cómo usar los templates con SoftArchitect AI data
```

**Uso en RAG Pipeline:**

```
User Question
    ↓
ChromaDB Retrieval (búsqueda en 02-TECH-PACKS + 03-EXAMPLES)
    ↓
Context Augmentation (add proyecto context)
    ↓
LLM Prompt (Ollama)
    ↓
Decision Matrix + Examples
```

---

## Convenciones

### Naming

```
Files:
  ✅ UPPERCASE_SNAKE_CASE para docs: README.md, AGENTS.md
  ✅ lowercase_snake_case para código: my_module.py, my_widget.dart

Directorios:
  ✅ Descriptive names (no abreviaturas): /infrastructure, /services
  ✅ Plurales para colecciones: /pages, /models, /endpoints

Git Branches:
  ✅ feature/descripción (e.g., feature/rag-pipeline)
  ✅ bugfix/descripción
  ✅ hotfix/descripción
```

### Imports

```
Python:
  1. Standard library imports
  2. Third-party imports
  3. Local imports

  Example:
    from typing import Optional
    from fastapi import FastAPI
    from services.rag import RAGPipeline

Dart:
  1. dart: imports
  2. package: imports (external)
  3. relative imports (local)

  Example:
    import 'package:flutter/material.dart';
    import 'package:riverpod/riverpod.dart';
    import '../domain/entities/question.dart';
```

### Code Organization

```
Within files:
  1. Imports
  2. Constants
  3. Type Definitions / Classes
  4. Functions (ordered by usage)
  5. Tests (in separate test/ files)
```

---

## Flujo de Datos

### Query Flow (End-to-End)

```
┌─────────────────────────────────────────────────────────────┐
│ USER (Flutter Desktop)                                      │
│  ├─ Escribe pregunta: "React vs Angular"                   │
│  └─ Presiona Enter                                          │
└────────────────────┬────────────────────────────────────────┘
                     │ HTTP POST /query
                     │ {"question": "React vs Angular?"}
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ FASTAPI BACKEND (src/server/api/v1/endpoints)              │
│  ├─ Route handler recibe request                           │
│  └─ Valida input (Pydantic)                                │
└────────────────────┬────────────────────────────────────────┘
                     │
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ RAG SERVICE (src/server/services/rag)                       │
│                                                             │
│  Step 1: RETRIEVAL                                          │
│  ├─ ChromaDB.search("React vs Angular", top_k=5)          │
│  └─ Retrieves relevant tech-pack excerpts                 │
│                                                             │
│  Step 2: CONTEXTUALIZATION                                │
│  ├─ Add: team size, budget, timeline (from request)       │
│  ├─ Add: project history (from SQLite)                    │
│  └─ Compose LLM prompt                                     │
│                                                             │
│  Step 3: GENERATION                                        │
│  ├─ LLM.call(prompt) via Ollama                           │
│  └─ Ollama (Mistral-7B) genera Decision Matrix            │
│                                                             │
│  Step 4: SYNTHESIS                                         │
│  ├─ Parse LLM response                                     │
│  ├─ Format as JSON (Decision, Examples, Costs)            │
│  └─ Save to SQLite (for history)                          │
└────────────────────┬────────────────────────────────────────┘
                     │ HTTP 200 OK
                     │ {
                     │   "decision_matrix": [...],
                     │   "code_examples": [...],
                     │   "estimated_costs": [...],
                     │   "recommendation": "React because..."
                     │ }
                     ▼
┌─────────────────────────────────────────────────────────────┐
│ USER (Flutter Desktop)                                      │
│  ├─ Lee Decision Matrix                                    │
│  ├─ Ve ejemplos de código                                  │
│  ├─ Entiende costos                                        │
│  └─ Toma decisión informada ✅                             │
└─────────────────────────────────────────────────────────────┘

Timeline: <2 segundos (p95)
```

---

**Estructura de SoftArchitect AI** maximiza: claridad, escalabilidad, testabilidad, y mantenibilidad. Cada capa tiene responsabilidades claras y límites bien definidos. 🎯
