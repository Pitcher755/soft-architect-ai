# 🔄 CI/CD Pipeline: SoftArchitect AI

> **Versión:** 1.0
> **Fecha:** 30/01/2026
> **Estado:** ✅ Implementado
> **Platform:** GitHub Actions
> **Languages:** Python 3.12, Dart 3.1

---

## 📖 Tabla de Contenidos

1. [Pipeline Overview](#pipeline-overview)
2. [Workflow Stages](#workflow-stages)
3. [GitHub Actions Configuration](#github-actions-configuration)
4. [Testing Strategy](#testing-strategy)
5. [Deployment Process](#deployment-process)

---

## Pipeline Overview

### Pipeline Architecture

```
┌─────────────────────────────────────────────────┐
│  Git Push (main/develop/feature)                │
└────────────────┬────────────────────────────────┘
                 │
        ┌────────▼────────┐
        │ Trigger Actions │
        └────────┬────────┘
                 │
    ┌────────────┼────────────┐
    │            │            │
    ▼            ▼            ▼
┌────────┐  ┌────────┐  ┌─────────┐
│ Lint   │  │ Type   │  │ Security│
│        │  │ Check  │  │ Scan    │
└─┬──────┘  └┬───────┘  └────┬────┘
  │         │                │
  └─────────┴────────┬───────┘
                     │
                ┌────▼────┐
                │  Test   │
                │ (Python)│
                └────┬────┘
                     │
                ┌────▼──────────┐
                │ Test (Flutter)│
                └────┬──────────┘
                     │
            ┌────────▼────────┐
            │ Build Artifacts │
            │ (Docker image)  │
            └────────┬────────┘
                     │
            ┌────────▼────────┐
            │ Deploy (Staging)│
            └────────┬────────┘
                     │
            ┌────────▼────────┐
            │ E2E Tests       │
            │ (Staging)       │
            └────────┬────────┘
                     │
            ┌────────▼────────┐
            │ Deploy (Prod)   │
            │ (Manual Approval)
            └─────────────────┘
```

---

## Workflow Stages

### Stage 1: Pre-Commit Validation (Local)

**Runs on:** Developer machine (pre-commit hook)

```bash
# .git/hooks/pre-commit
#!/bin/bash

echo "🔍 Running pre-commit checks..."

# Python linting
flake8 api/ core/ domain/ services/ --max-line-length=100
if [ $? -ne 0 ]; then
  echo "❌ Flake8 failed"
  exit 1
fi

# Python formatting
black --check api/ core/ domain/ services/
if [ $? -ne 0 ]; then
  echo "❌ Black formatting issues"
  exit 1
fi

# Python type checking
mypy api/ core/ domain/ services/ --strict
if [ $? -ne 0 ]; then
  echo "❌ MyPy type checking failed"
  exit 1
fi

# Dart formatting
cd src/client
flutter format --set-exit-if-changed lib/
if [ $? -ne 0 ]; then
  echo "❌ Dart formatting issues"
  exit 1
fi

# Dart analysis
flutter analyze
if [ $? -ne 0 ]; then
  echo "❌ Flutter analysis failed"
  exit 1
fi

cd ../..

echo "✅ All pre-commit checks passed"
```

### Stage 2: CI/CD (Automated on Push)

**Runs on:** GitHub Actions

#### 2.1 Code Quality

```yaml
# .github/workflows/lint.yml
name: Code Quality

on: [push, pull_request]

jobs:
  lint:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v3

      - uses: actions/setup-python@v4
        with:
          python-version: '3.12'

      - name: Install Python dependencies
        run: |
          pip install -r requirements.txt
          pip install flake8 black mypy

      - name: Lint with flake8
        run: flake8 api/ core/ domain/ services/ --max-line-length=100

      - name: Format check with black
        run: black --check api/ core/ domain/ services/

      - name: Type check with mypy
        run: mypy api/ core/ domain/ services/ --strict
```

#### 2.2 Security Scanning

```yaml
# .github/workflows/security.yml
name: Security Scan

on: [push, pull_request]

jobs:
  security:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v3

      - uses: actions/setup-python@v4
        with:
          python-version: '3.12'

      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install bandit safety

      - name: Bandit security scan
        run: bandit -r api/ core/ domain/ services/ -ll

      - name: Check for vulnerable dependencies
        run: safety check --json
```

#### 2.3 Unit Tests (Python)

```yaml
# .github/workflows/test-python.yml
name: Python Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: self-hosted
    services:
      sqlite:
        image: sqlite:latest

    steps:
      - uses: actions/checkout@v3

      - uses: actions/setup-python@v4
        with:
          python-version: '3.12'

      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install pytest pytest-cov pytest-asyncio

      - name: Run pytest
        run: |
          pytest tests/ -v --cov=api --cov=core --cov=domain --cov-report=xml

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: ./coverage.xml
          flags: python
          name: python-coverage
```

#### 2.4 Unit Tests (Flutter)

```yaml
# .github/workflows/test-flutter.yml
name: Flutter Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: self-hosted

    steps:
      - uses: actions/checkout@v3

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.10.0'
          channel: 'stable'

      - name: Get dependencies
        working-directory: src/client
        run: flutter pub get

      - name: Run tests
        working-directory: src/client
        run: flutter test --coverage

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          file: src/client/coverage/lcov.info
          flags: flutter
          name: flutter-coverage
```

### Stage 3: Build Artifacts

```yaml
# .github/workflows/build.yml
name: Build

on:
  push:
    branches: [main, develop]

jobs:
  docker:
    runs-on: self-hosted

    steps:
      - uses: actions/checkout@v3

      - uses: docker/setup-buildx-action@v2

      - uses: docker/login-action@v2
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: |
            ghcr.io/${{ github.repository }}:latest
            ghcr.io/${{ github.repository }}:${{ github.sha }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

### Stage 4: Deploy (Manual Gate)

```yaml
# .github/workflows/deploy.yml
name: Deploy

on:
  workflow_run:
    workflows: ["Build"]
    types: [completed]
    branches: [main]

jobs:
  deploy:
    runs-on: self-hosted
    if: ${{ github.event.workflow_run.conclusion == 'success' }}

    environment:
      name: production
      url: https://softarchitect.ai

    steps:
      - name: Deploy to production
        run: |
          # Deploy script here
          echo "Deploying to production..."
```

---

## GitHub Actions Configuration

### Main Workflow File

```yaml
# .github/workflows/main.yml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop, feature/*]
  pull_request:
    branches: [main, develop]

jobs:
  lint:
    runs-on: self-hosted
    name: Lint & Format
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: '3.12'
      - run: pip install flake8 black mypy
      - run: flake8 api/ core/ domain/ services/
      - run: black --check api/ core/ domain/ services/
      - run: mypy api/ core/ domain/ services/ --strict

  security:
    runs-on: self-hosted
    name: Security Scanning
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: '3.12'
      - run: pip install bandit safety
      - run: bandit -r api/ core/ domain/ services/ -ll
      - run: safety check

  test_python:
    runs-on: self-hosted
    name: Python Unit Tests
    needs: [lint, security]
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v4
        with:
          python-version: '3.12'
      - run: pip install -r requirements.txt pytest pytest-cov
      - run: pytest tests/ --cov=api --cov-report=xml
      - uses: codecov/codecov-action@v3

  test_flutter:
    runs-on: self-hosted
    name: Flutter Unit Tests
    needs: [lint]
    steps:
      - uses: actions/checkout@v3
      - uses: subosito/flutter-action@v2
      - working-directory: src/client
        run: flutter pub get
      - working-directory: src/client
        run: flutter test --coverage
      - uses: codecov/codecov-action@v3

  build:
    runs-on: self-hosted
    name: Build Docker Image
    needs: [test_python, test_flutter]
    if: github.event_name == 'push' && github.ref == 'refs/heads/main'
    steps:
      - uses: actions/checkout@v3
      - uses: docker/setup-buildx-action@v2
      - uses: docker/login-action@v2
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - uses: docker/build-push-action@v4
        with:
          context: .
          push: true
          tags: ghcr.io/${{ github.repository }}:${{ github.sha }}
```

---

## Testing Strategy

### Test Pyramid

```
         /\
        /  \
       /    \     E2E Tests
      /______\    (10%)

     /      \
    /        \    Integration Tests
   /          \   (30%)
  /__________\

 /__________\   Unit Tests
            \   (60%)
```

### Coverage Targets

```
Component      Target Coverage   Current
──────────────────────────────────────────
API Endpoints  > 90%             ⏳ 85%
Core Logic     > 95%             ⏳ 88%
Data Layer     > 85%             ⏳ 82%
UI Widgets     > 70%             ⏳ 65%
Overall        > 85%             ⏳ 80%
```

---

## Deployment Process

### Release Checklist

```
┌─ Release Preparation ────────────────────┐
│ [ ] Verify all tests passing             │
│ [ ] Update CHANGELOG.md                  │
│ [ ] Update version in pyproject.toml     │
│ [ ] Tag commit (v0.1.0)                  │
│ [ ] Create GitHub Release                │
│ [ ] Generate Docker image                │
└──────────────────────────────────────────┘
       ↓
┌─ Staging Deployment ─────────────────────┐
│ [ ] Deploy to staging environment        │
│ [ ] Run smoke tests                      │
│ [ ] Verify database migrations           │
│ [ ] Check logs for errors                │
│ [ ] Manual QA sign-off                   │
└──────────────────────────────────────────┘
       ↓
┌─ Production Deployment ──────────────────┐
│ [ ] Manual approval from release manager │
│ [ ] Deploy to production                 │
│ [ ] Monitor metrics (errors, latency)    │
│ [ ] Verify user-facing features          │
│ [ ] Have rollback plan ready             │
└──────────────────────────────────────────┘
```

---

**CI/CD Pipeline** automatiza la calidad, seguridad y despliegue. 🚀
