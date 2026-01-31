# 🚀 CI/CD Pipeline Definition

Flujo de integración y despliegue continuo.
**Proveedor:** {{CI_PROVIDER}} (GitHub Actions / GitLab CI / Jenkins).

## 1. Triggers (Disparadores)
* **Push a rama feature:** Ejecuta Lint + Unit Tests.
* **Pull Request a develop:** Ejecuta Integration Tests + Security Audit.
* **Push a main:** Build Docker Image + Deploy a Producción.
* **Manual:** Deploy a Staging para testing integral.

## 2. Stages (Etapas)

### Stage: Quality Gate 🛡️
1. **Lint:** `{{LINT_COMMAND}}` (Ruff/Dart Analyze).
2. **Format:** Verificar formato con `{{FORMAT_TOOL}}`.
3. **Type Check:** `{{TYPE_CHECK_TOOL}}` (mypy / dart analyze).
4. **Security Audit:** `{{SECURITY_TOOL}}` (Bandit / OWASP).

### Stage: Testing 🧪
1. Levantar servicios (Docker Compose).
2. Ejecutar suite de tests (Unit + Integration).
3. Subir reporte de coverage a {{COVERAGE_SERVICE}}.
4. Validar mínimo {{MIN_COVERAGE}}% de cobertura.

### Stage: Build & Push 📦
1. Build de imagen Docker: `{{DOCKER_IMAGE_NAME}}:{{TAG}}`.
2. Scan de vulnerabilidades en imagen.
3. Push a Registry: `{{REGISTRY_URL}}`.

### Stage: Deploy 🚀
1. Actualizar definición de servicio en {{DEPLOYMENT_TARGET}}.
2. Ejecutar migraciones de BD.
3. Smoke tests en ambiente desplegado.
4. Rollback automático si algo falla.

## 3. Notificaciones
* **Slack:** Alertas en canal #deploy.
* **Email:** Resumen diario de builds.

## 4. Políticas de Merge
* **Branch Protection:** Requerir mínimo 1 aprobación + Green CI.
* **Auto-merge:** Disabled (Manual para máxima seguridad).
