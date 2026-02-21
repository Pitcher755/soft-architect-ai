# 📂 Project Structure Map

Official directory map for **{{PROJECT_NAME}}**.
**Rule:** Any file outside this structure will be considered "Technical Debt" and removed by the linter.

```
{{ROOT_DIR_NAME}}/
├── .github/workflows/     # CI/CD Pipelines
├── context/               # Living Documentation (Source of Truth)
│   ├── 10-CONTEXT/
│   ├── 20-REQUIREMENTS/
│   └── 30-ARCHITECTURE/
├── infrastructure/        # Docker & Terraform configuration
├── src/
│   ├── server/            # Backend ({{BACKEND_FRAMEWORK}})
│   │   ├── api/           # Controllers / Routers
│   │   │   └── v1/        # API Versioning
│   │   ├── core/          # Config & Security
│   │   ├── domain/        # Business Logic (Clean Arch)
│   │   │   ├── models/    # Entities
│   │   │   └── schemas/   # DTOs
│   │   └── services/      # External Integrations
│   │
│   └── client/            # Frontend ({{FRONTEND_FRAMEWORK}})
│       ├── assets/        # Images & Fonts
│       ├── lib/           # Source Code
│       │   ├── core/      # Shared logic
│       │   ├── features/  # Vertical Slices (Auth, Chat, etc.)
│       │   └── shared/    # Reusable Widgets
│       └── test/          # Widget/Unit Tests
└── tests/                 # E2E & Integration Tests
```
