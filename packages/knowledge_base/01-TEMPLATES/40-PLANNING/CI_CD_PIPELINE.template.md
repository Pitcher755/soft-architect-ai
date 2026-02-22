# 🚀 CI/CD Pipeline

<!-- TEMPLATE GUIDE: This document defines automated testing, building, and deployment.
     - CI = Continuous Integration (merge → test → build)
     - CD = Continuous Deployment (build → deploy to prod)
     Generation Order: 23/24 | Phase: 5-Planning | Duration: ~40 mins
     Remove this guide before committing. -->

> **CI/CD Tool:** {{CI_CD_TOOL}}  <!-- e.g., GitHub Actions, GitLab CI, Jenkins -->
> **Repository:** {{REPO_URL}}
> **Deployment:** {{DEPLOYMENT_STRATEGY}}  <!-- e.g., "Auto-deploy to prod on main merge" -->
> **Last Updated:** {{DATE}}

---

## 📖 Table of Contents

- [Pipeline Overview](#pipeline-overview)
- [Stages](#stages)
- [Quality Gates](#quality-gates)
- [Secrets Management](#secrets-management)

---

## 🏗️ Pipeline Overview

```mermaid
flowchart LR
    A[Push Code] --> B[Lint]
    B --> C[Format Check]
    C --> D[Type Check]
    D --> E[Unit Tests]
    E --> F[Integration Tests]
    F --> G[Build]
    G --> H{Branch?}
    H -->|main| I[Deploy Prod]
    H -->|develop| J[Deploy Staging]
    H -->|feature/*| K[Skip Deploy]

    style I fill:#4caf50
    style J fill:#ff9800
    style K fill:#e0e0e0
```

---

## 🔄 Stages

### Stage 1: Code Quality

**Purpose:** Catch style/formatting issues early

**Jobs:**

| Job | Command | Fail Condition |
|-----|---------|----------------|
| **Lint (Python)** | `ruff check src/server/` | Any violations |
| **Format (Python)** | `black --check src/server/` | Not formatted |
| **Lint (Dart)** | `flutter analyze` | Any warnings |
| **Format (Dart)** | `dart format --set-exit-if-changed .` | Not formatted |

**Example (GitHub Actions):**

```yaml
name: Code Quality
on: [push, pull_request]

jobs:
  lint-backend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Set up Python
        uses: actions/setup-python@v5
        with:
          python-version: '3.12'
      - name: Install Ruff
        run: pip install ruff black
      - name: Lint
        run: ruff check src/server/
      - name: Format Check
        run: black --check src/server/
```

---

### Stage 2: Type Checking

**Purpose:** Catch type errors before runtime

**Jobs:**

| Job | Command | Fail Condition |
|-----|---------|----------------|
| **Pyright (Python)** | `pyright src/server/` | Any type errors |
| **Dart Analyzer** | `flutter analyze --fatal-infos` | Any type warnings |

---

### Stage 3: Testing

**Purpose:** Validate business logic

**Jobs:**

| Job | Command | Coverage Target | Fail Condition |
|-----|---------|-----------------|----------------|
| **Backend Unit Tests** | `pytest tests/server/ --cov=src/server --cov-fail-under=80` | ≥80% | Coverage <80% OR any test fails |
| **Frontend Unit Tests** | `flutter test --coverage` | ≥80% | Coverage <80% OR any test fails |
| **Integration Tests** | `pytest tests/integration/` | N/A | Any test fails |

**Example (Python Tests):**

```yaml
test-backend:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - name: Set up Python
      uses: actions/setup-python@v5
      with:
        python-version: '3.12'
    - name: Install dependencies
      run: pip install -r requirements.txt
    - name: Run tests
      run: pytest tests/server/ --cov=src/server --cov-fail-under=80 --cov-report=xml
    - name: Upload coverage
      uses: codecov/codecov-action@v3
      with:
        file: ./coverage.xml
```

---

### Stage 4: Build

**Purpose:** Compile artifacts (binaries, Docker images)

**Jobs:**

| Job | Command | Artifact | Size Limit |
|-----|---------|----------|------------|
| **Build Flutter** | `flutter build linux --release` | `build/linux/x64/release/bundle/` | <100MB |
| **Build Docker** | `docker build -t {{IMAGE_NAME}}:{{TAG}} .` | Docker image | <500MB |

**Example (Docker Build):**

```yaml
build-docker:
  runs-on: ubuntu-latest
  if: github.ref == 'refs/heads/main'
  steps:
    - uses: actions/checkout@v4
    - name: Build Docker Image
      run: docker build -t softarchitect-ai:${{ github.sha }} .
    - name: Push to Registry
      run: |
        echo "${{ secrets.DOCKER_PASSWORD }}" | docker login -u "${{ secrets.DOCKER_USERNAME }}" --password-stdin
        docker push softarchitect-ai:${{ github.sha }}
```

---

### Stage 5: Deploy

**Purpose:** Ship code to production

**Strategy:** {{DEPLOY_STRATEGY}}
<!-- e.g., "Blue-Green Deployment" OR "Rolling Update" OR "Canary (10% → 100%)" -->

**Environments:**

| Environment | Branch | URL | Auto-Deploy? |
|-------------|--------|-----|--------------|
| **Production** | `main` | {{PROD_URL}} | ✅ Yes |
| **Staging** | `develop` | {{STAGING_URL}} | ✅ Yes |
| **Preview** | `feature/*` | Dynamic (Netlify/Vercel) | ✅ Yes |

**Example (Deploy to Production):**

```yaml
deploy-prod:
  runs-on: ubuntu-latest
  needs: [lint, test, build]
  if: github.ref == 'refs/heads/main'
  steps:
    - name: Deploy to Production
      run: |
        ssh ${{ secrets.PROD_SERVER }} "cd /opt/app && docker-compose pull && docker-compose up -d"
```

---

## 🚦 Quality Gates

**Must Pass Before Merge:**

| Gate | Requirement | Enforcement |
|------|-------------|-------------|
| ✅ All tests pass | 0 failures | GitHub branch protection |
| ✅ Coverage ≥80% | Backend + Frontend | Codecov status check |
| ✅ Type checking | 0 errors | Pyright + Dart analyzer |
| ✅ Linting | 0 violations | Ruff + flutter analyze |
| ✅ Code review | 1+ approval | GitHub required reviewers |
| ✅ No merge conflicts | Clean merge | Git |

**Branch Protection Rules (GitHub):**

```json
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["lint", "test", "build", "type-check"]
  },
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "dismiss_stale_reviews": true
  },
  "enforce_admins": true
}
```

---

## 🔐 Secrets Management

**Where Secrets Live:**

| Environment | Storage | Access |
|-------------|---------|--------|
| **Local Dev** | `.env` file (gitignored) | Developer's machine |
| **CI/CD** | GitHub Secrets | GitHub Actions runners |
| **Production** | AWS Secrets Manager / Vault | Server runtime |

**Required Secrets:**

| Secret | Purpose | Example Value |
|--------|---------|---------------|
| `DATABASE_URL` | Postgres connection | `postgresql://user:pass@host:5432/db` |
| `JWT_SECRET` | Auth token signing | `random-256-bit-key` |
| `DOCKER_USERNAME` | Docker registry login | `myusername` |
| `DOCKER_PASSWORD` | Docker registry password | `mypassword` |

**Setting Secrets (GitHub):**

1. Go to Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Name: `DATABASE_URL`, Value: `postgresql://...`
4. Click "Add secret"

---

## 📊 Pipeline Performance

**Metrics:**

| Metric | Target | Current | Status |
|--------|--------|---------|--------|
| **Pipeline Duration** | <10 minutes | {{CURRENT_DURATION}} | {{STATUS}} |
| **Success Rate** | >95% | {{SUCCESS_RATE}} | {{STATUS}} |
| **Deploy Frequency** | >1/day | {{DEPLOY_FREQ}} | {{STATUS}} |
| **Mean Time to Recovery (MTTR)** | <1 hour | {{MTTR}} | {{STATUS}} |

<!-- EXAMPLE:

| Metric | Target | Current | Status |
|--------|--------|---------|--------|
| **Pipeline Duration** | <10 minutes | 8m 32s | ✅ Good |
| **Success Rate** | >95% | 97.2% | ✅ Good |
| **Deploy Frequency** | >1/day | 3.1/day | ✅ Excellent |
| **MTTR** | <1 hour | 23 minutes | ✅ Excellent |
-->

---

## 🆘 Rollback Strategy

**When to Rollback:**

- Critical bug in production
- Performance degradation >50%
- Security vulnerability discovered

**How to Rollback:**

```bash
# Option 1: Git revert
git revert HEAD
git push origin main  # Triggers CI/CD with reverted code

# Option 2: Redeploy previous version
docker pull softarchitect-ai:{{PREVIOUS_SHA}}
docker-compose up -d

# Option 3: Feature flag disable (if using feature flags)
curl -X POST {{FEATURE_FLAG_API}}/flags/{{FLAG_NAME}}/disable
```

**Rollback Time:** <5 minutes (automated)

---

## 🔗 Related Documents

- [TESTING_STRATEGY.md](TESTING_STRATEGY.md) - Test coverage details
- [DEPLOYMENT_INFRASTRUCTURE.md](DEPLOYMENT_INFRASTRUCTURE.md) - Production architecture
- [RULES.md](../00-ROOT/RULES.md) - Code quality standards
