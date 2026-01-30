# 📂 Project Structure Map

Mapa oficial de directorios para **{{PROJECT_NAME}}**.
**Regla:** Cualquier archivo fuera de esta estructura será considerado "Deuda Técnica" y eliminado por el linter.

```
{{ROOT_DIR_NAME}}/
├── .github/workflows/     # CI/CD Pipelines
├── context/               # Documentación Viva (Source of Truth)
│   ├── 10-CONTEXT/
│   ├── 20-REQUIREMENTS/
│   └── 30-ARCHITECTURE/
├── infrastructure/        # Docker & Terraform configuration
├── src/
│   ├── server/            # Backend ({{BACKEND_FRAMEWORK}})
│   │   ├── api/           # Controllers / Routers
│   │   │   └── v1/        # Versionado API
│   │   ├── core/          # Config & Security
│   │   ├── domain/        # Business Logic (Clean Arch)
│   │   │   ├── models/    # Entidades
│   │   │   └── schemas/   # DTOs
│   │   └── services/      # External Integrations
│   │
│   └── client/            # Frontend ({{FRONTEND_FRAMEWORK}})
│       ├── assets/        # Images & Fonts
│       ├── lib/           # Source Code
│       │   ├── core/      # Shared logic
│       │   ├── features/  # Vertical Slices (Auth, Chat, etc.)
│       │   └── shared/    # Widgets reutilizables
│       └── test/          # Widget/Unit Tests
└── tests/                 # E2E & Integration Tests
```
