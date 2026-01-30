# 🏗️ Technology Stack Decisions

Este documento registra las decisiones tecnológicas aprobadas para **{{PROJECT_NAME}}**.
**Estado:** Inmutable para la versión {{VERSION}}.

## 1. Stack Principal (Core)

| Capa | Tecnología Elegida | Versión | ¿Por qué esta y no otra? (Trade-offs) |
| :--- | :--- | :--- | :--- |
| **Backend** | {{BACKEND_FRAMEWORK}} | {{BACKEND_VERSION}} | *Ej: FastAPI por performance async nativo.* |
| **Frontend** | {{FRONTEND_FRAMEWORK}} | {{FRONTEND_VERSION}} | *Ej: Flutter para UI consistente en Desktop/Mobile.* |
| **Base de Datos** | {{DATABASE_ENGINE}} | {{DB_VERSION}} | *Ej: PostgreSQL por integridad relacional robusta.* |
| **IA / ML** | {{AI_ENGINE}} | {{AI_VERSION}} | *Ej: Ollama local para privacidad total.* |

## 2. Herramientas de Desarrollo (DevTools)
* **Linter/Formatter:** {{LINTER_TOOL}} (Ej: Ruff / ESLint).
* **Gestión de Paquetes:** {{PACKAGE_MANAGER}} (Ej: Poetry / Pub).
* **Containerización:** Docker + Docker Compose (v2+).
* **Testing:** {{TESTING_FRAMEWORK}} (Ej: Pytest / Flutter Test).

## 3. Servicios Externos (3rd Party)
* **Auth:** {{AUTH_PROVIDER}} (Ej: Auth0 / Firebase / Custom JWT).
* **Pagos:** {{PAYMENT_PROVIDER}} (Ej: Stripe).
* **Cloud/Hosting:** {{CLOUD_PROVIDER}} (Ej: AWS / DigitalOcean).
