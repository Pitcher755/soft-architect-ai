# 🎯 {{PROJECT_NAME}}

<!--
════════════════════════════════════════════════════════════════════════════════
📘 TEMPLATE GUIDE: How to Fill Out This README
════════════════════════════════════════════════════════════════════════════════

PURPOSE:
Your README is the FIRST thing developers see. It should answer in <60 seconds:
- What is this project?
- Why does it exist?
- How do I get started in <5 minutes?

BEST PRACTICES:
✅ Keep "Quick Start" under 10 commands
✅ Add real screenshots (not placeholders)
✅ Link to detailed docs (don't make 2000-line README)
✅ Update badges automatically via CI/CD

INSTRUCTIONS:
1. Replace ALL {{PLACEHOLDERS}} with your actual values
2. Test badge URLs before publishing (shields.io validator)
3. Add screenshot to /doc/screenshots/
4. Remove TEMPLATE GUIDE section before committing
5. Keep version updated (semantic versioning)

RELATED DOCS:
- AGENTS.md (team structure)
- CONTRIBUTING.md (collaboration rules)
- TECH_STACK_DECISION.md (why technology chosen)
════════════════════════════════════════════════════════════════════════════════
-->

> **{{TAGLINE}}**  <!-- e.g., "Privacy-First AI Assistant for Software Architecture" -->
> **{{VALUE_PROPOSITION}}**  <!-- e.g., "Build better software faster with RAG-powered guidance" -->

[![License](https://img.shields.io/badge/License-{{LICENSE}}-blue.svg)](LICENSE)
[![Build](https://img.shields.io/github/actions/workflow/status/{{GITHUB_ORG}}/{{REPO_NAME}}/ci.yml?branch=main)](https://github.com/{{GITHUB_ORG}}/{{REPO_NAME}}/actions)
[![Coverage](https://img.shields.io/codecov/c/github/{{GITHUB_ORG}}/{{REPO_NAME}})](https://codecov.io/gh/{{GITHUB_ORG}}/{{REPO_NAME}})
[![Version](https://img.shields.io/github/v/release/{{GITHUB_ORG}}/{{REPO_NAME}})](https://github.com/{{GITHUB_ORG}}/{{REPO_NAME}}/releases)
[![Stars](https://img.shields.io/github/stars/{{GITHUB_ORG}}/{{REPO_NAME}}?style=social)](https://github.com/{{GITHUB_ORG}}/{{REPO_NAME}})

![Demo](doc/screenshots/hero-screenshot.png)  <!-- REPLACE with YOUR screenshot -->

---

## 📖 Table of Contents

- [About](#about)
- [Why This Exists](#why-this-exists)
- [Key Features](#key-features)
- [Architecture](#architecture)
- [Tech Stack](#tech-stack)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Development](#development)
- [Testing](#testing)
- [Deployment](#deployment)
- [Contributing](#contributing)
- [Team](#team)
- [License](#license)

---

## 🌟 About

**{{PROJECT_NAME}}** is {{PROJECT_DESCRIPTION}}.
<!-- e.g., "a local-first AI assistant that helps developers architect software projects" -->

**Problem:** {{PROBLEM_STATEMENT}}
<!-- e.g., "Developers waste 40% of time searching documentation" -->

**Solution:** {{SOLUTION_STATEMENT}}
<!-- e.g., "Generate 24 project documents locally in 1 hour using RAG" -->

---

## 💡 Why This Exists

**Origin Story:**

{{ORIGIN_STORY}}
<!-- e.g., "After the 10th client asked 'Why no docs?' I built this to make documentation instant" -->

**Target Users:**
- {{PERSONA_1}}  <!-- e.g., "Solo developers building side projects" -->
- {{PERSONA_2}}  <!-- e.g., "Startups needing fast MVP documentation" -->
- {{PERSONA_3}}  <!-- e.g., "Enterprise teams enforcing doc standards" -->

**Success Metrics:**

| Metric | Target | Current |
|--------|--------|---------|
| Doc Generation Time | <1 hour | {{CURRENT_TIME}} <!-- e.g., "45 min" --> |
| User Rating | >4.5/5 | {{CURRENT_RATING}} <!-- e.g., "4.7/5" --> |
| Privacy Incidents | 0 | 0 |
| Active Users | {{USER_TARGET}} | {{CURRENT_USERS}} |

---

## ✨ Key Features

| Feature | Description | Status |
|---------|-------------|--------|
| **{{FEATURE_1}}** | {{FEATURE_1_DESC}} | ✅ Live |
| **{{FEATURE_2}}** | {{FEATURE_2_DESC}} | ✅ Live |
| **{{FEATURE_3}}** | {{FEATURE_3_DESC}} | 🚧 Beta |
| **{{FEATURE_4}}** | {{FEATURE_4_DESC}} | 📅 Planned |

<!-- EXAMPLE:
| **24-Doc Workflow** | Generate README, ADRs, API specs in 1 hour | ✅ Live |
-->

**Non-Functional Highlights:**
- **⚡ Fast:** {{LATENCY}}  <!-- e.g., "UI <200ms, RAG <2s" -->
- **🔒 Private:** {{PRIVACY}}  <!-- e.g., "100% local, zero telemetry" -->
- **📴 Offline:** {{OFFLINE}}  <!-- e.g., "Works without internet (Ollama)" -->

---

## 🏗️ Architecture

```mermaid
graph TB
    subgraph "Client ({{FRONTEND_FRAMEWORK}})"
        UI[UI Layer]
        Domain[Domain Layer]
        Data[Data Layer]
    end

    subgraph "Server ({{BACKEND_FRAMEWORK}})"
        API[REST API]
        Services[Service Layer]
        Core[Core Layer]
    end

    subgraph "Infrastructure"
        DB[({{DATABASE}})]
        Cache[({{CACHE}})]
    end

    UI --> Domain
    Domain --> Data
    Data --> API
    API --> Services
    Services --> Core
    Services --> DB
    Services --> Cache
```

**Principles:**
1. **Clean Architecture:** Domain independent of frameworks
2. **Local-First:** No external APIs required
3. **Hexagonal:** External systems isolated
4. **Event-Driven:** Domain events for communication

See [ARCH_DECISION_RECORDS.md](context/ARCH_DECISION_RECORDS.md) for details.

---

## 🛠️ Tech Stack

### Backend

| Tech | Version | Purpose | Why |
|------|---------|---------|-----|
| **{{BACKEND_LANG}}** | {{BACKEND_VER}} | Runtime | {{BACKEND_REASON}} |
| **{{BACKEND_FRAMEWORK}}** | {{FRAMEWORK_VER}} | Web framework | {{FRAMEWORK_REASON}} |
| **{{VECTOR_DB}}** | {{VECTOR_VER}} | Vector search | {{VECTOR_REASON}} |

### Frontend

| Tech | Version | Purpose | Why |
|------|---------|---------|-----|
| **{{FRONTEND_LANG}}** | {{FRONTEND_VER}} | UI language | {{FRONTEND_REASON}} |
| **{{FRONTEND_FRAMEWORK}}** | {{FRONTEND_FRAMEWORK_VER}} | UI framework | {{FRONTEND_FRAMEWORK_REASON}} |

### Infrastructure

- **Docker** 24.0+ - Containerization
- **GitHub Actions** - CI/CD
- **{{DATABASE}}** - Persistence

See [TECH_STACK_DECISION.md](context/TECH_STACK_DECISION.md) for rationale.

---

## 🚀 Quick Start

### Prerequisites

- **Docker Desktop** 24.0+ ([Install](https://docker.com/products/docker-desktop/))
- **{{BACKEND_LANG}}** {{BACKEND_VER}}+ ([Install]({{BACKEND_INSTALL_URL}}))
- **{{FRONTEND_FRAMEWORK}}** {{FRONTEND_VER}}+ ([Install]({{FRONTEND_INSTALL_URL}}))
- **Git** 2.40+

### Installation (5 Minutes)

```bash
# 1. Clone
git clone {{REPO_URL}}
cd {{REPO_NAME}}

# 2. Start infrastructure
cd infrastructure
docker compose up -d

# 3. Backend
cd ../src/server
pip install -r requirements.txt
uvicorn main:app --reload --port 8080

# 4. Frontend
cd ../client
flutter pub get
flutter run -d {{TARGET_PLATFORM}}  # linux, macos, windows
```

**Expected Output:**
- Backend: `Uvicorn running on http://0.0.0.0:8080`
- Frontend: App launches with home screen

**Issues?** See [Troubleshooting](#troubleshooting).

---

## 📂 Project Structure

```
{{REPO_NAME}}/
├── src/
│   ├── client/              # {{FRONTEND_FRAMEWORK}} app (Clean Architecture)
│   │   ├── domain/          # Entities, use cases
│   │   ├── data/            # Repositories, DTOs
│   │   └── presentation/    # UI widgets
│   └── server/              # {{BACKEND_FRAMEWORK}} backend
│       ├── core/            # Entities, events
│       ├── services/        # Business logic
│       └── routers/         # API endpoints
├── packages/                # Shared libraries
├── infrastructure/          # Docker, config
├── doc/                     # Documentation
├── tests/                   # Unit, integration, E2E tests
├── context/                 # Source of truth (RULES, AGENTS)
└── scripts/                 # DevOps automation
```

---

## 🔄 Development

**Branching (Gitflow):**
```
main → develop → feature/xyz
```

**Workflow:**
1. `git checkout -b feature/my-feature develop`
2. Make changes + commit
3. Push + open PR to `develop`
4. Code review + CI checks
5. Merge to `develop`
6. Weekly release to `main`

**PR Requirements:**
- ✅ All tests pass
- ✅ Coverage ≥85%
- ✅ No lint errors
- ✅ 1+ approver

See [CONTRIBUTING.md](CONTRIBUTING.md) for details.

---

## 🧪 Testing

```bash
# Backend
pytest tests/server/ --cov=services --cov-report=term

# Frontend
flutter test --coverage

# Integration
pytest tests/integration/ -v
```

**Coverage Targets:**
- Domain: 100%
- Services: ≥90%
- API: ≥85%
- UI: ≥80%
- **Overall: ≥85%**

See [TESTING_STRATEGY.md](context/TESTING_STRATEGY.md).

---

## 🚢 Deployment

```bash
# Production build
docker compose -f infrastructure/docker-compose.prod.yml build

# Deploy
docker compose -f infrastructure/docker-compose.prod.yml up -d

# Verify
curl http://localhost:8080/health
```

**Automated:** Push to `main` → GitHub Actions builds release

See [CI_CD_PIPELINE.md](context/CI_CD_PIPELINE.md).

---

## 🤝 Contributing

Contributions welcome! Read [CONTRIBUTING.md](CONTRIBUTING.md) for:
- Code of Conduct
- PR process
- Coding standards
- Commit format

**Quick Checklist:**
- [ ] Code formatted
- [ ] Tests added (≥85% coverage)
- [ ] PR description explains WHY
- [ ] Linked to issue

---

## 🐛 Troubleshooting

### Docker Compose Fails
```
ERROR: Service 'chromadb' failed to build
```
**Fix:** Update Docker Desktop to ≥24.0

### Backend Import Error
```
ModuleNotFoundError: No module named 'langchain'
```
**Fix:** `pip install -r requirements.txt --force-reinstall`

### Flutter Build Error
```
Error: Target URI doesn't exist
```
**Fix:** `flutter clean && flutter pub get`

**More?** [Discussions](https://github.com/{{GITHUB_ORG}}/{{REPO_NAME}}/discussions)

---

## 👥 Team

| Role | Name | Contact |
|------|------|---------|
| Lead Architect | {{LEAD_NAME}} | [@{{LEAD_GITHUB}}](https://github.com/{{LEAD_GITHUB}}) |
| Product Owner | {{PO_NAME}} | {{PO_EMAIL}} |
| Backend Dev | {{BACKEND_NAME}} | [@{{BACKEND_GITHUB}}](https://github.com/{{BACKEND_GITHUB}}) |

See [AGENTS.md](AGENTS.md) for full team structure.

---

## 📄 License

**{{LICENSE_TYPE}}** License - See [LICENSE](LICENSE)

---

## 🔗 Links

- [Documentation](doc/INDEX.md)
- [Architecture](context/ARCH_DECISION_RECORDS.md)
- [Roadmap](context/ROADMAP_PHASES.md)
- [Security](SECURITY.md)

---

> **Built with ❤️ by {{TEAM_NAME}}**
> **Questions? [Open Discussion](https://github.com/{{GITHUB_ORG}}/{{REPO_NAME}}/discussions)**
