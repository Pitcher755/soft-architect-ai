# 🚀 CI/CD Pipeline Definition

Continuous integration and deployment flow.
**Provider:** {{CI_PROVIDER}} (GitHub Actions / GitLab CI / Jenkins).

## 1. Triggers
* **Push to feature branch:** Run Lint + Unit Tests.
* **Pull Request to develop:** Run Integration Tests + Security Audit.
* **Push to main:** Build Docker Image + Deploy to Production.
* **Manual:** Deploy to Staging for comprehensive testing.

## 2. Stages

### Stage: Quality Gate 🛡️
1. **Lint:** `{{LINT_COMMAND}}` (Ruff/Dart Analyze).
2. **Format:** Verify formatting with `{{FORMAT_TOOL}}`.
3. **Type Check:** `{{TYPE_CHECK_TOOL}}` (mypy / dart analyze).
4. **Security Audit:** `{{SECURITY_TOOL}}` (Bandit / OWASP).

### Stage: Testing 🧪
1. Start services (Docker Compose).
2. Run test suite (Unit + Integration).
3. Upload coverage report to {{COVERAGE_SERVICE}}.
4. Validate minimum {{MIN_COVERAGE}}% coverage.

### Stage: Build & Push 📦
1. Build Docker image: `{{DOCKER_IMAGE_NAME}}:{{TAG}}`.
2. Scan image for vulnerabilities.
3. Push to Registry: `{{REGISTRY_URL}}`.

### Stage: Deploy 🚀
1. Update service definition in {{DEPLOYMENT_TARGET}}.
2. Run DB migrations.
3. Smoke tests on deployed environment.
4. Automatic rollback if something fails.

## 3. Notifications
* **Slack:** Alerts in #deploy channel.
* **Email:** Daily build summary.

## 4. Merge Policies
* **Branch Protection:** Require minimum 1 approval + Green CI.
* **Auto-merge:** Disabled (Manual for maximum security).
