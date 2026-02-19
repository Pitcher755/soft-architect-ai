# 🏗️ Technology Stack Decisions

This document records the approved technology decisions for **{{PROJECT_NAME}}**.
**Status:** Immutable for version {{VERSION}}.

## 1. Core Stack

| Layer | Chosen Technology | Version | Why this and not another? (Trade-offs) |
| :--- | :--- | :--- | :--- |
| **Backend** | {{BACKEND_FRAMEWORK}} | {{BACKEND_VERSION}} | *E.g.: FastAPI for native async performance.* |
| **Frontend** | {{FRONTEND_FRAMEWORK}} | {{FRONTEND_VERSION}} | *E.g.: Flutter for consistent UI on Desktop/Mobile.* |
| **Database** | {{DATABASE_ENGINE}} | {{DB_VERSION}} | *E.g.: PostgreSQL for robust relational integrity.* |
| **AI / ML** | {{AI_ENGINE}} | {{AI_VERSION}} | *E.g.: Ollama local for total privacy.* |

## 2. Development Tools (DevTools)
* **Linter/Formatter:** {{LINTER_TOOL}} (e.g., Ruff / ESLint).
* **Package Management:** {{PACKAGE_MANAGER}} (e.g., Poetry / Pub).
* **Containerization:** Docker + Docker Compose (v2+).
* **Testing:** {{TESTING_FRAMEWORK}} (e.g., Pytest / Flutter Test).

## 3. External Services (3rd Party)
* **Auth:** {{AUTH_PROVIDER}} (e.g., Auth0 / Firebase / Custom JWT).
* **Payments:** {{PAYMENT_PROVIDER}} (e.g., Stripe).
* **Cloud/Hosting:** {{CLOUD_PROVIDER}} (e.g., AWS / DigitalOcean).
