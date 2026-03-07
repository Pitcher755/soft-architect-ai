# 🎯 SoftArchitect AI - Local-First Development Assistant

> **Privacy-First AI Assistant** | **Offline-Capable** | **RAG-Powered Architecture Guidance**

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Flutter](https://img.shields.io/badge/Flutter-3.x+-02569B?logo=flutter)](https://flutter.dev)
[![Python](https://img.shields.io/badge/Python-3.12.3-3776AB?logo=python)](https://python.org)
[![FastAPI](https://img.shields.io/badge/FastAPI-Latest-009688?logo=fastapi)](https://fastapi.tiangolo.com)
[![Tests](https://img.shields.io/badge/Tests-141%2F141-success)](tests/)

---

## 📖 Table of Contents

- [Overview](#overview)
- [Key Features](#key-features)
- [Architecture](#architecture)
- [Quick Start](#quick-start)
- [Tech Stack](#tech-stack)
- [Project Structure](#project-structure)
- [Development](#development)
- [Testing](#testing)
- [Documentation](#documentation)
- [Contributing](#contributing)
- [License](#license)

---

## 🌟 Overview

**SoftArchitect AI** is a privacy-first, offline-capable AI assistant designed to guide software developers through architectural decisions and the complete 0-100 development workflow. Unlike cloud-based assistants, all processing happens locally, ensuring **100% data sovereignty**.

### The Problem

- **Analysis Paralysis**: Developers spend hours researching architecture patterns, tech stacks, and best practices
- **Privacy Concerns**: Cloud AI assistants upload proprietary code and architectural decisions
- **Context Loss**: Generic assistants lack domain-specific knowledge for software architecture
- **Cost**: Cloud API calls add up quickly for team-wide usage

### Our Solution

- **Local RAG Engine**: Retrieval-Augmented Generation using ChromaDB for semantic search over curated technical knowledge
- **Hybrid AI**: Runs locally with Ollama (Mistral-7B/Llama-2) or optionally Groq Cloud with user consent
- **Master Workflow**: Structured 0-100 guidance from project inception to deployment
- **Desktop-First**: Flutter-based native desktop app (Windows, macOS, Linux) with <200ms UI responses

---

## ✨ Key Features

### 🔒 Privacy & Security
- **Zero Cloud Dependencies**: All processing local by default
- **Data Sovereignty**: Your code never leaves your machine (unless you explicitly opt-in to Groq)
- **OWASP Compliant**: Input sanitization, validation, secure storage
- **Audit Logs**: Local JSON logs for all AI interactions

### 🧠 AI-Powered Guidance
- **RAG Architecture**: 20K+ lines of curated technical documentation (43 files, 8 tech domains)
- **Decision Matrices**: Compare frameworks, cloud services, patterns with weighted criteria
- **Context-Aware**: Learns from your project structure and provides tailored recommendations
- **Streaming Responses**: Real-time token streaming with optimistic UI updates

### 🛠️ Developer Experience
- **Master Workflow**: 24-phase structured approach from ideation to deployment
- **Document Generation**: Automatically creates technical specs, ADRs, API contracts
- **User Validation**: Human-in-the-loop workflow with explicit approval steps
- **Bilingual Docs**: Full documentation in English/Spanish (mirror structure)

### 🚀 Performance
- **<200ms UI Response**: Non-blocking operations, all I/O async
- **Efficient Embeddings**: ChromaDB with HNSW index for sub-second semantic search
- **Low Memory**: <2GB RAM usage (Docker services included)
- **Desktop Native**: Hardware-accelerated Flutter rendering

---

## 🏗️ Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    Flutter Desktop App                       │
│  ┌─────────────────────────────────────────────────────┐   │
│  │         Presentation Layer (Riverpod)                │   │
│  │  ┌────────┐  ┌──────────┐  ┌─────────────────┐     │   │
│  │  │  Chat  │  │ Projects │  │  File Explorer  │     │   │
│  │  │  UI    │  │   List   │  │   (Tree View)   │     │   │
│  │  └────────┘  └──────────┘  └─────────────────┘     │   │
│  └─────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              Domain Layer (Use Cases)                │   │
│  │  • Send Message  • Validate Document                │   │
│  │  • Create Project  • Load Chat History              │   │
│  └─────────────────────────────────────────────────────┘   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │         Data Layer (Repositories)                    │   │
│  │  • HTTP Client (dio)  • SQLite Storage              │   │
│  │  • File System Access  • UUID Generation            │   │
│  └─────────────────────────────────────────────────────┘   │
└──────────────────────┬──────────────────────────────────────┘
                       │ HTTP/REST (dio)
┌──────────────────────┴──────────────────────────────────────┐
│                   Python Backend (FastAPI)                   │
│  ┌─────────────────────────────────────────────────────┐   │
│  │              RAG Orchestrator                        │   │
│  │  1. Validate Input (RULE-06 blocker)                │   │
│  │  2. Query ChromaDB (semantic search)                │   │
│  │  3. Build Prompt (context + history + user_name)    │   │
│  │  4. LLM Generation (Ollama/Groq)                    │   │
│  │  5. Stream Response (SSE)                           │   │
│  └─────────────────────────────────────────────────────┘   │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   ChromaDB   │  │    Ollama    │  │  Groq API    │     │
│  │  (Vectors)   │  │  (Local LLM) │  │  (Optional)  │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
└─────────────────────────────────────────────────────────────┘
```

### Clean Architecture Principles

1. **Domain Layer**: Pure business logic (no framework dependencies)
2. **Data Layer**: Adapters for external systems (HTTP, DB, File I/O)
3. **Presentation Layer**: UI components (Flutter Widgets + Riverpod State)

**Dependency Rule**: Inner layers never depend on outer layers.

---

## 🚀 Quick Start

### Prerequisites

- **Flutter SDK**: 3.10.8+ ([Install](https://flutter.dev/docs/get-started/install))
- **Python**: 3.12.3+ ([Install](https://python.org/downloads))
- **Docker**: Latest ([Install](https://docs.docker.com/get-docker))
- **Git**: Latest ([Install](https://git-scm.com/downloads))

### Installation (5 minutes)

```bash
# 1. Clone repository
git clone https://github.com/Pitcher755/soft-architect-ai.git
cd soft-architect-ai

# 2. Start Docker services (ChromaDB + Ollama)
cd infrastructure
docker-compose up -d
cd ..

# 3. Setup Python backend
cd src/server
python -m venv venv
source venv/bin/activate  # Windows: venv\Scripts\activate
pip install -r requirements.txt
cd ../..

# 4. Setup Flutter client
cd src/client
flutter pub get
cd ../..

# 5. Run backend
cd src/server
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# 6. Run Flutter app (new terminal)
cd src/client
flutter run -d linux  # or: -d windows / -d macos
```

### Verify Setup

```bash
# Check Docker services
docker ps  # Should show: chroma, ollama

# Test ChromaDB
curl http://localhost:8001/api/v1/heartbeat
# Expected: {"nanosecond heartbeat": 1234567890}

# Test Backend
curl http://localhost:8000/api/v1/health
# Expected: {"status": "ok"}

# Test Ollama (downloads model on first run ~4GB)
curl http://localhost:11434/api/generate \
  -d '{"model": "mistral", "prompt": "Hello", "stream": false}'
```

---

## 🛠️ Tech Stack

### Frontend

| Technology | Version | Purpose |
|------------|---------|---------|
| **Flutter** | 3.10.8+ | Cross-platform desktop UI |
| **Dart** | 3.x+ | Programming language |
| **Riverpod** | 2.x+ | State management (Provider pattern) |
| **dio** | 5.x+ | HTTP client for REST API |
| **sqflite** | 2.x+ | Local SQLite database (chat history) |
| **uuid** | 4.x+ | Deterministic UUID generation |
| **flutter_markdown** | 0.6.x+ | Markdown rendering |

### Backend

| Technology | Version | Purpose |
|------------|---------|---------|
| **Python** | 3.12.3 | Programming language |
| **FastAPI** | 0.110+ | Async web framework |
| **LangChain** | 0.1.x+ | LLM orchestration framework |
| **ChromaDB** | 0.4.x+ | Vector database (embeddings) |
| **Ollama** | Latest | Local LLM runtime (Mistral/Llama) |
| **Groq** | SDK 0.4+ | Optional cloud LLM (fast inference) |
| **Pydantic** | 2.x+ | Data validation (schemas) |
| **pytest** | 8.x+ | Testing framework |

### Infrastructure

| Tool | Purpose |
|------|---------|
| **Docker Compose** | Service orchestration (ChromaDB, Ollama) |
| **GitHub Actions** | CI/CD pipeline (tests, linting, formatting) |
| **Black** | Python code formatter |
| **Ruff** | Python linter (fast, Rust-based) |
| **flutter_lints** | Dart/Flutter linter |
| **pre-commit** | Git hooks for code quality |

---

## 📁 Project Structure

```
soft-architect-ai/
├── src/
│   ├── client/                    # Flutter Desktop App
│   │   ├── lib/
│   │   │   ├── core/             # Shared (theme, utils, DI)
│   │   │   ├── features/         # Feature modules
│   │   │   │   ├── chat/         # Chat UI + RAG interaction
│   │   │   │   │   ├── domain/       # Entities, Use Cases
│   │   │   │   │   ├── data/         # Repositories, DTOs
│   │   │   │   │   └── presentation/ # Widgets, Notifiers
│   │   │   │   └── project_shell/   # Project management
│   │   │   └── gen/              # Generated (l10n, assets)
│   │   └── pubspec.yaml          # Flutter dependencies
│   │
│   └── server/                    # Python Backend
│       ├── app/
│       │   ├── api/              # REST endpoints
│       │   │   └── v1/           # API version 1
│       │   ├── services/         # Business logic
│       │   │   ├── llm/          # LLM clients (Ollama, Groq)
│       │   │   └── rag/          # RAG orchestration
│       │   ├── domain/           # Pydantic schemas
│       │   └── main.py           # FastAPI app entry
│       └── requirements.txt      # Python dependencies
│
├── packages/
│   └── knowledge_base/           # RAG Knowledge Base
│       ├── 01-TEMPLATES/         # Document templates
│       ├── 02-TECH-PACKS/        # Tech decision guides
│       └── 03-EXAMPLES/          # Example documents
│
├── context/                       # Agent rules & specs
│   ├── 10-BUSINESS_AND_SCOPE/
│   ├── 20-REQUIREMENTS_AND_SPEC/
│   ├── 30-ARCHITECTURE/
│   └── 40-ROADMAP/
│
├── doc/                           # Living documentation
│   ├── English/                  # 🇬🇧 English docs (460 files)
│   └── Español/                  # 🇪🇸 Spanish docs (mirror)
│
├── tests/                         # Test suites
│   ├── client/                   # Flutter tests (118 tests)
│   │   ├── unit/
│   │   ├── widget/
│   │   └── features/
│   └── server/                   # Python tests (23 tests)
│       ├── unit/
│       ├── integration/
│       ├── e2e/
│       └── smoke/
│
├── infrastructure/                # DevOps
│   ├── docker-compose.yml        # Services (ChromaDB, Ollama)
│   └── scripts/                  # Setup scripts
│
├── scripts/                       # Automation
│   ├── PRE_PUSH_VALIDATION_MASTER.sh  # Local quality gate
│   ├── run_tests.sh                   # Test runner
│   └── LAUNCH_FLUTTER_APP_DEV.sh      # Dev mode launcher
│
├── .github/
│   └── workflows/                # CI/CD pipelines
│       ├── backend-ci.yaml       # Python tests, linting
│       └── frontend-ci.yaml      # Flutter tests, analyze
│
├── AGENTS.md                      # Agent identity & rules (this file)
├── README.md                      # Project overview (this file)
├── CONTRIBUTING.md                # Contribution guidelines
└── LICENSE                        # MIT License
```

---

## 👨‍💻 Development

### Development Workflow

```bash
# Feature development (Gitflow)
git checkout develop
git pull origin develop
git checkout -b feature/my-feature

# Make changes, write tests
vim src/client/lib/features/chat/...
vim tests/client/unit/features/chat/...

# Run quality checks (MANDATORY before push)
./scripts/PRE_PUSH_VALIDATION_MASTER.sh
# ✅ Checks: formatting, linting, type safety, tests, coverage

# Commit (pre-commit hooks run automatically)
git add -A
git commit -m "feat: add new feature"

# Push (GitHub Actions CI/CD runs)
git push origin feature/my-feature

# Open Pull Request to develop
# ✅ CI/CD must pass: 141/141 tests, 0 lint issues, >80% coverage
```

### Code Quality Standards

| Check | Tool | Threshold |
|-------|------|-----------|
| **Python Formatting** | Black | 100% compliance |
| **Python Linting** | Ruff | 0 violations |
| **Python Type Safety** | Pyright | 0 errors |
| **Python Tests** | pytest | All passing |
| **Python Coverage** | pytest-cov | ≥80% |
| **Dart Formatting** | dart format | 100% compliance |
| **Dart Linting** | flutter analyze | 0 issues |
| **Dart Tests** | flutter test | All passing |

### Running Tests

```bash
# Python tests (23 tests)
cd src/server
pytest tests/ -v --cov=app --cov-report=term-missing

# Flutter tests (118 tests)
cd src/client
flutter test --coverage

# All tests (unified script)
./scripts/run_tests.sh all --coverage

# Smoke tests (quick validation)
pytest tests/server/smoke/ -v
```

### Local Development Tips

```bash
# Hot reload (Python backend)
cd src/server
uvicorn app.main:app --reload --port 8000

# Hot reload (Flutter desktop)
cd src/client
flutter run -d linux  # Press 'r' to reload, 'R' to restart

# Watch mode (ChromaDB logs)
docker logs -f chroma

# View Ollama models
ollama list

# Pull new model
ollama pull llama2:7b

# Check Docker resource usage
docker stats
```

---

## 🧪 Testing

### Test Structure

```
tests/
├── client/                    # Flutter Tests (118 total)
│   ├── unit/                  # Pure logic (106 tests)
│   │   ├── features/chat/     # Chat domain tests
│   │   └── features/project_shell/  # Project domain tests
│   ├── widget/                # Widget tests (6 tests)
│   │   └── features/          # UI component tests
│   └── features/              # Integration tests (6 tests)
│       └── chat/              # Feature flow tests
│
└── server/                    # Python Tests (23 total)
    ├── unit/                  # Pure logic (5 tests)
    │   └── infrastructure/    # Persistence layer
    ├── integration/           # API + DB (8 tests)
    │   ├── api/v1/           # REST endpoint tests
    │   └── persistence/      # SQLite CRUD tests
    ├── e2e/                   # End-to-end (5 tests)
    │   └── test_full_workflow_e2e.py
    ├── smoke/                 # Health checks (3 tests)
    │   ├── test_health_check.py
    │   └── test_chromadb_connection.py
    └── services/llm/          # LLM logic (2 tests)
        └── test_validation_blocker.py
```

### Test Coverage Requirements

- **Domain Logic**: 100% coverage (critical business rules)
- **Data Layer**: ≥90% coverage (repositories, adapters)
- **API Endpoints**: ≥85% coverage (REST handlers)
- **Overall**: ≥80% coverage (project-wide minimum)

### Running Specific Test Suites

```bash
# Python: Smoke tests (fast, 0.35s)
pytest tests/server/smoke/ -q

# Python: Unit tests only
pytest tests/server/unit/ -v

# Python: Integration tests (requires Docker)
pytest tests/server/integration/ -v

# Python: E2E tests (full workflow)
pytest tests/server/e2e/ -v

# Flutter: Unit tests only
cd tests && flutter test client/unit/

# Flutter: Widget tests
cd tests && flutter test client/widget/

# Flutter: Integration tests
cd tests && flutter test client/features/
```

---

## 📚 Documentation

### Documentation Structure

- **English Documentation**: `doc/English/` (460+ files, 920+ pages)
- **Spanish Documentation**: `doc/Español/` (mirror structure, 460+ files)
- **Bilingual READMEs**: All READMEs have both languages in single file

### Key Documentation Locations

| Document | Path | Description |
|----------|------|-------------|
| **Agent Identity** | `AGENTS.md` | Agent rules, capabilities, restrictions |
| **Contribution Guide** | `CONTRIBUTING.md` | How to contribute to the project |
| **Architecture Decisions** | `doc/English/01-PROJECT_REPORT/01-ARCHITECTURE/` | ADRs, diagrams |
| **Setup Guides** | `doc/English/02-SETUP_DEV/01-INSTALLATION/` | Installation & configuration |
| **User Stories** | `doc/English/03-HU-TRACKING/` | 24 HU folders with progress |
| **User Manual** | `doc/English/04-USER_GUIDE/` | End-user documentation |
| **Knowledge Base** | `packages/knowledge_base/` | RAG training data |

### Generating Documentation

```bash
# Generate HTML coverage report
./scripts/generate_coverage_html.sh

# View coverage
open coverage/html/index.html

# Validate bilingual mirror structure
diff -r doc/English/ doc/Español/ --brief
# Expected: Content differs, structure identical
```

---

## 🤝 Contributing

We welcome contributions! Please read [CONTRIBUTING.md](CONTRIBUTING.md) for:

- **Code of Conduct**
- **Development Setup**
- **Pull Request Process**
- **Coding Standards**
- **Git Commit Conventions**

### Quick Contribution Checklist

- [ ] Fork the repository
- [ ] Create feature branch from `develop`
- [ ] Write tests for new functionality
- [ ] Ensure all tests pass locally
- [ ] Run `./scripts/PRE_PUSH_VALIDATION_MASTER.sh`
- [ ] Update documentation if needed
- [ ] Follow commit message convention: `feat:|fix:|docs:|style:|refactor:|test:`
- [ ] Open Pull Request against `develop` branch
- [ ] Respond to code review feedback

---

## 📄 License

This project is licensed under the **MIT License** - see [LICENSE](LICENSE) file for details.

```
MIT License

Copyright (c) 2026 SoftArchitect AI Contributors

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

[Full MIT License text...]
```

---

## 🙏 Acknowledgments

- **Ollama Team**: Local LLM runtime ([ollama.ai](https://ollama.ai))
- **ChromaDB Team**: Vector database ([trychroma.com](https://www.trychroma.com))
- **LangChain Team**: LLM orchestration ([langchain.com](https://www.langchain.com))
- **Flutter Team**: Cross-platform framework ([flutter.dev](https://flutter.dev))
- **FastAPI Team**: Modern Python framework ([fastapi.tiangolo.com](https://fastapi.tiangolo.com))
- **Groq**: Fast LLM inference ([groq.com](https://groq.com))

---

## 📞 Support

- **Issues**: [GitHub Issues](https://github.com/Pitcher755/soft-architect-ai/issues)
- **Discussions**: [GitHub Discussions](https://github.com/Pitcher755/soft-architect-ai/discussions)
- **Email**: support@softarchitect.ai
- **Documentation**: [Full Docs](doc/INDEX.md)

---

<div align="center">

**Built with ❤️ by the SoftArchitect AI Team**

[Website](https://softarchitect.ai) • [Documentation](doc/INDEX.md) • [GitHub](https://github.com/Pitcher755/soft-architect-ai)

</div>
