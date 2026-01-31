# 🐙 GitHub Actions Workflow Patterns

> **Enfoque:** DRY (Don't Repeat Yourself), Secure-First
> **Ubicación:** `.github/workflows/`
> **Paradigma:** Infrastructure as Pipelines
> **Estado:** ✅ Establecido
> **Fecha:** 30/01/2026

---

## 📖 Tabla de Contenidos

1. [Fundamentos](#fundamentos)
2. [Triggers & Concurrency](#triggers--concurrency)
3. [Matrix Testing Pattern](#matrix-testing-pattern)
4. [Reusable Workflows](#reusable-workflows)
5. [Security: OIDC vs Secrets](#security-oidc-vs-secrets)
6. [Artifact Management](#artifact-management)
7. [Advanced Patterns](#advanced-patterns)

---

## Fundamentos

### ¿Qué es GitHub Actions?

```
Push a GitHub → Trigger automático → Build → Test → Deploy

Ejemplo: Cada PR desencadena 100+ tests en paralelo.
```

### Anatomía Básica

```yaml
name: CI Pipeline

# Cuándo ejecutar
on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]
  schedule:
    - cron: '0 2 * * *'  # Diariamente a las 2 AM

# Qué hacer
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run tests
        run: pytest
```

---

## Triggers & Concurrency

### Smart Triggering

```yaml
on:
  # Push a main
  push:
    branches: [main, develop]
    paths:
      - 'src/**'        # Solo si cambios en src/
      - '.github/**'    # O en workflows

  # Pull Request
  pull_request:
    branches: [main]

  # Manual trigger
  workflow_dispatch:
    inputs:
      environment:
        type: choice
        options: [dev, staging, prod]

  # Trigger desde otro workflow
  workflow_run:
    workflows: [other-workflow]
    types: [completed]
```

### Concurrency Control

```yaml
# Si hago 10 pushes en 1 minuto, solo correr el último
concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

# Por ambiente
concurrency:
  group: deployment-${{ github.environment }}
  cancel-in-progress: false  # No cancelar deployments en progreso
```

---

## Matrix Testing Pattern

### Versiones Múltiples en Paralelo

```yaml
name: Multi-Version Testing

on: [push, pull_request]

jobs:
  test:
    runs-on: ${{ matrix.os }}
    strategy:
      matrix:
        python-version: ["3.10", "3.11", "3.12"]
        redis-version: ["6", "7"]
        os: [ubuntu-latest, macos-latest]
        exclude:
          # Evitar combinaciones innecesarias
          - os: macos-latest
            python-version: "3.10"

    steps:
      - uses: actions/checkout@v4

      - name: Set up Python ${{ matrix.python-version }}
        uses: actions/setup-python@v4
        with:
          python-version: ${{ matrix.python-version }}

      - name: Start Redis ${{ matrix.redis-version }}
        uses: supercharge/redis-github-action@1.5.0
        with:
          redis-version: ${{ matrix.redis-version }}

      - name: Run tests
        run: pytest --verbose

# Resultado: 3 × 2 × 2 - 1 excluded = 11 jobs en paralelo
```

---

## Reusable Workflows

### El Problema: Copy-Paste Gigante

```yaml
# ❌ INCORRECTO: Duplicar pipeline en cada microservicio
# .github/workflows/api-ci.yml
# 150 líneas

# .github/workflows/worker-ci.yml
# 150 líneas (idénticas)

# .github/workflows/admin-ci.yml
# 150 líneas (idénticas)
# = 450 líneas redundantes
```

### La Solución: Reusable Workflows

```yaml
# .github/workflows/reusable-python-test.yml
# (Template central)

name: Reusable Python Test

on:
  workflow_call:
    inputs:
      python-version:
        type: string
        default: "3.12"
    secrets:
      CODECOV_TOKEN:
        required: false

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: ${{ inputs.python-version }}

      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install pytest pytest-cov

      - name: Run tests
        run: pytest --cov=./ --cov-report=xml

      - name: Upload to Codecov
        if: ${{ secrets.CODECOV_TOKEN }}
        uses: codecov/codecov-action@v3
        with:
          token: ${{ secrets.CODECOV_TOKEN }}
```

### Caller Workflow

```yaml
# .github/workflows/api-ci.yml
# (Reutilizar)

name: API CI

on: [push, pull_request]

jobs:
  test:
    uses: ./.github/workflows/reusable-python-test.yml
    with:
      python-version: "3.12"
    secrets:
      CODECOV_TOKEN: ${{ secrets.CODECOV_TOKEN }}

  lint:
    uses: ./.github/workflows/reusable-lint.yml

  deploy:
    needs: [test, lint]  # Ejecutar solo después
    if: github.ref == 'refs/heads/main'
    uses: ./.github/workflows/reusable-deploy.yml
    with:
      environment: production
    secrets:
      DOCKER_TOKEN: ${{ secrets.DOCKER_TOKEN }}
```

---

## Security: OIDC vs Secrets

### ❌ Método Viejo: Long-Lived Secrets

```yaml
# secrets/AWS_ACCESS_KEY_ID = "AKIA..."
# secrets/AWS_SECRET_ACCESS_KEY = "wJalr..."
# Problemas:
# - Si se filtra, acceso indefinido
# - Difícil de rotar
# - No auditable

steps:
  - uses: aws-actions/configure-aws-credentials@v4
    with:
      aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
      aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
      aws-region: us-east-1
```

### ✅ Método Moderno: OIDC (OpenID Connect)

```yaml
# No se necesita guardar secrets en GitHub
# AWS confía en tokens OIDC de GitHub

permissions:
  id-token: write  # ← CRÍTICO: Permiso para emitir token OIDC
  contents: read

steps:
  - uses: actions/checkout@v4

  - name: Configure AWS Credentials (OIDC)
    uses: aws-actions/configure-aws-credentials@v4
    with:
      role-to-assume: arn:aws:iam::123456789012:role/GitHubActionRole
      aws-region: us-east-1
      # Sin access keys!

  - name: Deploy to S3
    run: aws s3 cp dist/ s3://my-bucket/ --recursive
```

**Setup en AWS (una sola vez):**

```bash
# Crear role de confianza en AWS IAM
# Especificar: GitHub account ID, repo, branch

# El flujo:
# 1. GitHub Actions pide token a GitHub
# 2. GitHub emite token OIDC
# 3. GitHub Actions intercambia token por AWS credentials temporales
# 4. Credentials expiran automáticamente
```

**Ventajas:**
- ✅ Zero secrets almacenados
- ✅ Credentials temporales (expiran)
- ✅ Auditable (quién/cuándo)
- ✅ Fácil de rotar

---

## Artifact Management

### Guardar Outputs de Build

```yaml
name: Build & Upload

on: [push]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Build Docker image
        run: docker build -t myapp:${{ github.sha }} .

      - name: Save image as artifact
        run: docker save myapp:${{ github.sha }} | gzip > image.tar.gz

      - name: Upload artifact
        uses: actions/upload-artifact@v3
        with:
          name: docker-image
          path: image.tar.gz
          retention-days: 5  # Limpiar después de 5 días

  deploy:
    needs: build
    runs-on: ubuntu-latest
    steps:
      - name: Download artifact
        uses: actions/download-artifact@v3
        with:
          name: docker-image

      - name: Load image
        run: docker load < image.tar.gz
```

---

## Advanced Patterns

### Conditional Steps

```yaml
steps:
  - name: Run tests
    run: pytest
    if: github.event_name == 'pull_request'

  - name: Deploy to prod
    run: kubectl apply -f manifests/
    if: |
      github.event_name == 'push' &&
      github.ref == 'refs/heads/main' &&
      contains(github.event.head_commit.message, '[deploy]')
```

### Output Sharing Between Steps

```yaml
steps:
  - name: Generate version
    id: version  # ← ID para reutilizar
    run: echo "tag=v1.2.3" >> $GITHUB_OUTPUT

  - name: Use version
    run: echo "Deploying ${{ steps.version.outputs.tag }}"

  - name: Push Docker image
    run: docker push myapp:${{ steps.version.outputs.tag }}
```

### Error Handling & Retry

```yaml
steps:
  - name: Deploy with retry
    uses: nick-invision/retry@v2
    with:
      timeout_minutes: 5
      max_attempts: 3
      retry_wait_seconds: 10
      command: kubectl apply -f manifests/

  - name: Continue on error
    run: npm test
    continue-on-error: true  # No fallar el workflow si esto falla

  - name: Notify on failure
    if: failure()  # Solo si un step anterior falla
    run: |
      curl -X POST https://hooks.slack.com/... \
        -d "message=Build failed"
```

### Environment-Specific Workflows

```yaml
name: Multi-Environment Deploy

on:
  push:
    branches: [main, staging, develop]

jobs:
  deploy:
    environment:
      name: ${{ github.ref == 'refs/heads/main' && 'production' || 'staging' }}
      url: https://${{ github.ref == 'refs/heads/main' && 'app.com' || 'staging.app.com' }}

    runs-on: ubuntu-latest
    environment-secrets:
      DEPLOY_KEY: ${{ secrets.DEPLOY_KEY_PROD || secrets.DEPLOY_KEY_STAGING }}

    steps:
      - name: Deploy
        run: ./deploy.sh
        env:
          DEPLOY_KEY: ${{ env.DEPLOY_KEY }}
```

---

## Ejemplo Completo: FastAPI CI/CD

```yaml
name: FastAPI CI/CD

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

permissions:
  id-token: write
  contents: read
  pull-requests: write

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        python-version: ["3.11", "3.12"]

    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: postgres
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

    steps:
      - uses: actions/checkout@v4

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: ${{ matrix.python-version }}
          cache: pip

      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install pytest pytest-cov black flake8

      - name: Lint
        run: flake8 . && black --check .

      - name: Test
        env:
          DATABASE_URL: postgresql://postgres:postgres@localhost/testdb
        run: pytest --cov --cov-report=xml

      - name: Upload coverage
        uses: codecov/codecov-action@v3

  build:
    needs: test
    runs-on: ubuntu-latest
    if: github.event_name == 'push'

    outputs:
      image-tag: ${{ steps.meta.outputs.tags }}

    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v2

      - name: Login to Docker Hub
        uses: docker/login-action@v2
        with:
          username: ${{ secrets.DOCKER_USERNAME }}
          password: ${{ secrets.DOCKER_TOKEN }}

      - name: Build and push
        uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: |
            myregistry/fastapi:latest
            myregistry/fastapi:${{ github.sha }}
          cache-from: type=registry,ref=myregistry/fastapi:buildcache
          cache-to: type=registry,ref=myregistry/fastapi:buildcache,mode=max

  deploy:
    needs: build
    runs-on: ubuntu-latest
    if: github.ref == 'refs/heads/main'

    steps:
      - uses: actions/checkout@v4

      - name: Configure AWS (OIDC)
        uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: arn:aws:iam::123456789012:role/GHActionsDeployRole
          aws-region: us-east-1

      - name: Deploy to ECS
        run: |
          aws ecs update-service \
            --cluster production \
            --service fastapi-api \
            --force-new-deployment
```

---

## Resumen: GitHub Actions Mastery

✅ **Best Practices:**
- Use reusable workflows (DRY)
- Use OIDC for cloud auth (no secrets)
- Use concurrency for efficiency
- Use matrix for multi-version testing
- Use if conditions for conditional runs

✅ **Security Checklist:**
- [ ] Nunca comitear secrets
- [ ] Usar OIDC en lugar de long-lived keys
- [ ] Restricción de permisos (least privilege)
- [ ] Audit logs (quién ejecutó qué)

GitHub Actions es CI/CD profesional. 🐙✨
