# ⚖️ RULES: Project Constitution & Governance

> **Project:** TaskFlow Pro - Enterprise Task Management System
> **Document Type:** Project Rules & Technical Constitution
> **Version:** 2.1.0
> **Last Updated:** February 22, 2026
> **Status:** ✅ Active & Enforced
> **Authority:** Lead Architect + Product Owner

---

## 📋 Table of Contents

- [Document Purpose](#document-purpose)
- [Foundational Principles](#foundational-principles)
- [Language & Communication Standards](#language--communication-standards)
- [Technology Stack Constraints](#technology-stack-constraints)
- [Development Workflow](#development-workflow)
- [Quality Gates](#quality-gates)
- [Security & Privacy Policies](#security--privacy-policies)
- [Code Standards](#code-standards)
- [Testing Requirements](#testing-requirements)
- [Documentation Standards](#documentation-standards)
- [Deployment & Release Rules](#deployment--release-rules)
- [Violation Consequences](#violation-consequences)
- [Amendment Process](#amendment-process)
- [References](#references)

---

## 🎯 Document Purpose

This document constitutes the **immutable laws** governing the TaskFlow Pro project. These rules are **non-negotiable** and apply to all team members, contractors, and AI agents.

### Authority Hierarchy
1. **This Document** (highest priority - overrides any verbal agreement)
2. `AGENTS.md` (role-specific authority)
3. Architecture Decision Records (`ADR-###.md`)
4. Technical specifications (API contracts, schemas)

### Violation Protocol
Violations of Class A rules (security, data privacy) result in **immediate code rejection**. Class B violations (style, documentation) require remediation within 24 hours.

---

## 🧭 Foundational Principles

### PRINCIPLE 1: Documentation as Source of Truth
> "If it's not documented in `context/`, it doesn't exist."

**Enforcement:**
- All architectural decisions MUST be recorded in `ARCH_DECISION_RECORDS.md`
- API changes MUST update `API_INTERFACE_CONTRACT.md` before merge
- New patterns MUST be documented in `PROJECT_STRUCTURE_MAP.md`

**Rationale:** Prevents institutional knowledge loss and ensures new team members can onboard from documentation alone.

---

### PRINCIPLE 2: Security First, Always
> "Security is not negotiable. Privacy is not optional."

**Enforcement:**
- All data inputs MUST be validated (Pydantic models in backend, Zod in frontend)
- PII MUST be encrypted at rest (AES-256) and in transit (TLS 1.3)
- Authentication MUST use OAuth2 + JWT with short-lived tokens (15 min access, 7 day refresh)

**Rationale:** TaskFlow Pro handles sensitive enterprise data. A single breach destroys trust and reputation.

---

### PRINCIPLE 3: Quality Over Speed
> "Fast code that crashes is slower than slow code that works."

**Enforcement:**
- Minimum 85% test coverage (per `TESTING_STRATEGY.md`)
- All PRs MUST pass linting, type checking, and tests before review
- Performance budgets enforced (API endpoints <200ms p95, UI interactions <100ms)

**Rationale:** Technical debt compounds. We pay upfront for quality to avoid paying 10x later in maintenance.

---

### PRINCIPLE 4: Local-First Architecture
> "Users are not internet-dependent hostages."

**Enforcement:**
- Desktop app MUST function offline (sync when online)
- No blocking network calls in UI interaction paths
- State persistence in local SQLite database (encrypted)

**Rationale:** Enterprise users need reliability. Network failures should not halt productivity.

---

### PRINCIPLE 5: Accessibility is Not Optional
> "Software that excludes is software that fails."

**Enforcement:**
- WCAG 2.1 AA compliance required (per `ACCESSIBILITY_GUIDE.md`)
- All UI components MUST support keyboard navigation
- Screen reader compatibility verified in every release

**Rationale:** Legal requirement (ADA, Section 508) and moral imperative.

---

## 🌐 Language & Communication Standards

### Rule 1.1: Primary Human Language
**Language:** English
**Scope:** All documentation, commit messages, PR descriptions, code comments

**Rationale:** English is the lingua franca of software engineering. It ensures global collaboration and third-party integrations understand our codebase.

---

### Rule 1.2: Code Language (ENGLISH ONLY)
**Enforcement:** ALL code identifiers, variables, functions, classes MUST be in English.

```python
# ✅ CORRECT
def calculate_total_price(items: list[Item]) -> Decimal:
    return sum(item.price for item in items)

# ❌ WRONG (Spanish variable names)
def calcular_precio_total(articulos: list[Item]) -> Decimal:
    return sum(articulo.precio for articulo in articulos)
```

**Exception:** User-facing strings and error messages MAY be in target localization languages.

---

### Rule 1.3: Commit Message Format
**Standard:** Conventional Commits 1.0.0

**Format:**
```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Required Types:**
- `feat:` - New feature
- `fix:` - Bug fix
- `docs:` - Documentation only
- `style:` - Formatting, no code change
- `refactor:` - Code restructure, no behavior change
- `perf:` - Performance improvement
- `test:` - Adding/fixing tests
- `chore:` - Build process, dependencies

**Examples:**
```bash
✅ feat(api): add bulk task creation endpoint
✅ fix(ui): resolve keyboard navigation in modal dialogs
✅ docs(architecture): update C4 diagram with new microservice
❌ updated stuff
❌ Fix bug
❌ WIP
```

**Enforcement:** CI pipeline rejects commits that don't match format.

---

### Rule 1.4: Pull Request Titles
**Format:** Same as commit messages (Conventional Commits)

**Required Elements:**
```markdown
## Description
Brief summary of changes

## Type of Change
- [ ] Bug fix
- [x] New feature
- [ ] Breaking change

## Checklist
- [x] Tests added/updated
- [x] Documentation updated
- [x] Breaking changes documented
```

---

### Rule 1.5: Code Review Language
**Language:** English
**Tone:** Constructive, professional, fact-based

**Approved Phrases:**
- "Consider using X instead because Y"
- "This might cause Z problem if A happens"
- "Could you add a test for edge case B?"

**Prohibited Phrases:**
- "This is wrong" (non-specific)
- "Why did you do it like this?" (could be perceived as hostile)
- Personal attacks of any kind

---

## 🛠️ Technology Stack Constraints

### Rule 2.1: Approved Technologies
**Backend:**
- **Language:** Python 3.12.3+
- **Framework:** FastAPI 0.110+
- **Database:** PostgreSQL 16+
- **Cache:** Redis 7+
- **Background Jobs:** Celery 5+ with Redis broker

**Frontend:**
- **Language:** Dart 3.3+ / Flutter 3.19+
- **State Management:** Riverpod 2.5+
- **Local Storage:** Hive 2.2+ (encrypted boxes)
- **HTTP Client:** Dio 5.4+

**Infrastructure:**
- **Containerization:** Docker 24+ / Docker Compose 2.24+
- **CI/CD:** GitHub Actions
- **Monitoring:** Prometheus + Grafana
- **Logging:** Structured JSON logs (python-json-logger)

**Prohibited:**
- ❌ JavaScript/TypeScript in backend (approved stack is Python)
- ❌ React/Vue in frontend (approved framework is Flutter)
- ❌ MySQL/MongoDB (approved DB is PostgreSQL)
- ❌ Self-hosted servers without containerization

**Exception Process:** New technology proposals require an ADR approved by Lead Architect.

---

### Rule 2.2: Dependency Management
**Python:**
- Use `pyproject.toml` (modern standard, not `requirements.txt`)
- Pin major versions, allow minor/patch updates: `fastapi = "^0.110"`
- Review dependencies weekly (Dependabot alerts)

**Dart/Flutter:**
- Pin versions in `pubspec.yaml`: `riverpod: ^2.5.0`
- Avoid deprecated packages (check pub.dev scores)

**Approval Required For:**
- Packages with <1000 GitHub stars
- Packages without active maintenance (last commit >1 year)
- Packages with known security vulnerabilities

---

### Rule 2.3: Environment Variables
**Format:** `.env` files (NEVER commit to Git)

**Required Variables:**
```bash
# Database
DATABASE_URL=postgresql://user:pass@localhost/taskflow_pro
DATABASE_POOL_SIZE=20

# Redis
REDIS_URL=redis://localhost:6379/0

# Security
JWT_SECRET_KEY=<generate with: openssl rand -hex 32>
JWT_ALGORITHM=HS256
JWT_ACCESS_TOKEN_EXPIRE_MINUTES=15

# API Keys (encrypted in production)
GROQ_API_KEY=gsk_***
STRIPE_SECRET_KEY=sk_test_***
```

**Enforcement:**
- `.env` in `.gitignore` (CI checks for violations)
- Secrets stored in GitHub Secrets (production) or AWS Secrets Manager
- Local development: use `.env.example` with placeholder values

---

## 🔄 Development Workflow

### Rule 3.1: Branch Strategy (Gitflow)
**Protected Branches:**
- `main` - Production-ready code only
- `develop` - Integration branch for features

**Feature Development:**
```bash
# Create feature branch from develop
git checkout develop
git pull origin develop
git checkout -b feature/task-bulk-creation

# Work on feature...
git add .
git commit -m "feat(tasks): add bulk creation API endpoint"
git push origin feature/task-bulk-creation

# Create PR to develop
# After approval, squash merge to develop
```

**Release Process:**
```bash
# Create release branch from develop
git checkout -b release/v1.5.0 develop

# Bump version, update CHANGELOG
# Test in staging
# Merge to main + tag
git checkout main
git merge --no-ff release/v1.5.0
git tag -a v1.5.0 -m "Release v1.5.0: Bulk task operations"
git push origin main --tags
```

**Hotfix Process:**
```bash
# Create from main (critical bug in production)
git checkout -b hotfix/task-deletion-bug main

# Fix bug, test immediately
git commit -m "fix(tasks): prevent cascade deletion of shared subtasks"

# Merge to both main AND develop
git checkout main
git merge --no-ff hotfix/task-deletion-bug
git checkout develop
git merge --no-ff hotfix/task-deletion-bug
```

---

### Rule 3.2: Code Review Requirements
**Reviewers Required:**
- **1 reviewer** for minor changes (docs, tests, refactors)
- **2 reviewers** for feature additions (new API endpoints, UI screens)
- **Lead Architect** for architectural changes (database schema, auth patterns)

**Response SLA:**
- P0 (production blocker): 2 hours
- P1 (feature PR): 24 hours
- P2 (refactor/docs): 48 hours

**Auto-Approval Rules:**
- Dependabot security patches (after CI passes)
- Documentation-only changes (if CI passes + 1 approval)

---

### Rule 3.3: Merge Strategy
**Default:** Squash and merge (keeps history clean)

**When to Use:**
- **Squash Merge:** Feature branches (multiple WIP commits)
- **Merge Commit:** Release branches (preserve history)
- **Rebase Merge:** Never (causes confusion with shared branches)

---

## 🚦 Quality Gates

### GATE 1: Pre-Commit Checks (Local)
**Enforced By:** Git pre-commit hooks

**Checks:**
```bash
# Python
black src/server/  # Format
ruff check src/server/  # Lint
pyright src/server/  # Type check

# Flutter
dart format lib/  # Format
flutter analyze  # Lint
```

**Failure Action:** Commit is blocked. Fix issues before committing.

---

### GATE 2: Continuous Integration (GitHub Actions)
**Triggers:** Push to any branch, PR creation

**Pipeline Steps:**
1. **Linting** (must pass)
   - Python: Ruff (all rules enabled)
   - Dart: flutter_lints (pedantic)

2. **Type Checking** (must pass)
   - Python: Pyright strict mode
   - Dart: Strong mode (default)

3. **Unit Tests** (must pass with ≥85% coverage)
   - Python: pytest with coverage plugin
   - Dart: flutter test with coverage

4. **Security Scan** (must pass)
   - Python: bandit (OWASP rules)
   - Dependencies: Snyk (CVE database)

**Failure Action:** PR cannot be merged. Red ❌ status blocks merge button.

---

### GATE 3: Code Review Approval (Human)
**Requirements:**
- At least 1 approval from authorized reviewer
- No "Request Changes" reviews outstanding
- All comments resolved or explicitly deferred

**Blocking Issues:**
- Security vulnerabilities
- Missing tests
- Breaking changes without ADR
- Performance regressions >20%

---

### GATE 4: Pre-Production Validation (Staging)
**Environment:** staging.taskflowpro.io (mirrors production)

**Checks:**
- Smoke tests pass (critical user flows)
- Load tests pass (1000 concurrent users, p95 latency <500ms)
- Database migrations succeed (tested on production snapshot)

**Sign-Off Required:** QA Lead (Maria Santos)

---

### GATE 5: Production Deployment
**Approvers:** Lead Architect + DevOps Engineer

**Pre-Deployment Checklist:**
```markdown
- [ ] CHANGELOG updated
- [ ] Version bumped (semver)
- [ ] Database migrations reviewed
- [ ] Rollback plan documented
- [ ] Monitoring alerts configured
- [ ] On-call schedule confirmed
```

**Deployment Strategy:** Blue-green (zero downtime)

**Rollback Trigger:** Error rate >1% OR p95 latency >1000ms

---

## 🔒 Security & Privacy Policies

### CLASS A VIOLATIONS (Immediate Rejection)

#### Rule 4.1: No Hardcoded Secrets
```python
# ❌ WRONG
DATABASE_URL = "postgresql://admin:Password123@prod-db.internal/app"
API_KEY = "gsk_37f8a2b9c4d1e5f6"

# ✅ CORRECT
import os
DATABASE_URL = os.environ["DATABASE_URL"]
API_KEY = os.environ["GROQ_API_KEY"]
```

**Enforcement:** GitGuardian scans all commits. Violations trigger:
1. Immediate PR block
2. Slack alert to @security channel
3. Secret rotation required before unblocking

---

#### Rule 4.2: Input Validation (ALWAYS)
**Backend (Python):**
```python
from pydantic import BaseModel, validator, Field

class TaskCreate(BaseModel):
    title: str = Field(..., min_length=1, max_length=255)
    description: str | None = Field(None, max_length=10000)
    due_date: datetime | None = None

    @validator('title')
    def sanitize_title(cls, v):
        # Strip HTML tags
        return re.sub(r'<[^>]*>', '', v)
```

**Frontend (Dart):**
```dart
import 'package:flutter/services.dart';

final titleInput = TextFormField(
  maxLength: 255,
  inputFormatters: [
    FilteringTextInputFormatter.deny(RegExp(r'[<>]')), // Block HTML
    LengthLimitingTextInputFormatter(255),
  ],
  validator: (value) {
    if (value == null || value.isEmpty) {
      return 'Title is required';
    }
    return null;
  },
);
```

**Enforcement:** SonarQube scans for raw SQL queries, unvalidated inputs. CI fails if detected.

---

#### Rule 4.3: Authentication Required (No Public Endpoints)
**Exception List:**
- `/health` (monitoring)
- `/docs` (API documentation - dev only)
- `/auth/login` (obviously)

**All Other Routes:**
```python
from fastapi import Depends
from app.auth import get_current_user

@app.get("/api/v1/tasks")
async def list_tasks(current_user: User = Depends(get_current_user)):
    # Verify user has permission
    if not current_user.has_permission("tasks:read"):
        raise HTTPException(status_code=403)
    # ...
```

**Enforcement:** API security audit runs in CI. Unprotected routes trigger build failure.

---

#### Rule 4.4: PII Handling
**Definition:** Personally Identifiable Information
- Email addresses
- Phone numbers
- IP addresses
- Location data
- Payment information

**Requirements:**
1. **Encryption at Rest:** AES-256-GCM
2. **Encryption in Transit:** TLS 1.3 (enforce, no fallback)
3. **Data Minimization:** Only collect what's necessary
4. **Retention Limits:**
   - Active users: retain indefinitely
   - Inactive users (>2 years): anonymize or delete
5. **Right to Deletion:** Automated workflow for GDPR requests

**Enforcement:** Compliance Officer (Jonathan Wright) audits quarterly.

---

### CLASS B VIOLATIONS (24-Hour Remediation)

#### Rule 4.5: No TODO/FIXME in Main
```python
# ❌ WRONG (in main/develop branch)
def process_payment(amount):
    # TODO: Add fraud detection
    charge_card(amount)

# ✅ CORRECT
def process_payment(amount):
    # Full implementation or explicit future work ticket
    if not validate_transaction(amount):
        raise PaymentValidationError("Invalid transaction")
    charge_card(amount)
```

**Enforcement:** Pre-merge hook searches for `TODO|FIXME`. If found in protected branches, PR is blocked.

---

## 📝 Code Standards

### Rule 5.1: Formatting (Non-Negotiable)
**Python:** Black (line length: 100)
**Dart:** dart format (default settings)

**Enforcement:** CI runs formatters in check mode. Fail if diff detected.

---

### Rule 5.2: Linting Rules
**Python:** Ruff (all rules enabled)
```toml
[tool.ruff]
line-length = 100
select = ["ALL"]  # Enable all rules
ignore = [
    "D100",  # Missing docstring in public module (too verbose)
    "ANN101",  # Missing type annotation for self (obvious)
]
```

**Dart:** flutter_lints (pedantic rules)
```yaml
include: package:flutter_lints/flutter.yaml

linter:
  rules:
    - prefer_const_constructors
    - avoid_print
    - use_key_in_widget_constructors
```

---

### Rule 5.3: Naming Conventions
**Python:**
- Classes: `PascalCase` (`TaskService`, `UserRepository`)
- Functions/Methods: `snake_case` (`create_task`, `get_user_by_id`)
- Constants: `UPPER_SNAKE_CASE` (`MAX_RETRIES`, `API_VERSION`)
- Private: `_leading_underscore` (`_internal_method`)

**Dart:**
- Classes: `PascalCase` (`TaskListWidget`, `AuthService`)
- Methods/Variables: `camelCase` (`fetchTasks`, `currentUser`)
- Constants: `lowerCamelCase` (`maxRetries`, `apiEndpoint`)
- Private: `_leadingUnderscore` (`_buildTaskCard`)

---

### Rule 5.4: Documentation Requirements
**Every Public Function MUST Have:**
```python
def calculate_project_completion(project_id: int) -> float:
    """
    Calculate completion percentage for a project based on task states.

    Args:
        project_id: Unique identifier of the project.

    Returns:
        Completion percentage (0.0 to 100.0).

    Raises:
        ProjectNotFoundError: If project doesn't exist.
        DatabaseError: If database query fails.

    Example:
        >>> calculate_project_completion(42)
        67.5
    """
    # Implementation...
```

**Dart:**
```dart
/// Fetches tasks for the specified project.
///
/// Filters tasks based on [status] and [assignee]. Returns an empty list
/// if no tasks match the criteria.
///
/// Throws [NetworkException] if the request fails.
/// Throws [UnauthorizedException] if the user lacks permission.
///
/// Example:
/// ```dart
/// final tasks = await fetchTasks(projectId: 42, status: TaskStatus.open);
/// ```
Future<List<Task>> fetchTasks({
  required int projectId,
  TaskStatus? status,
  int? assignee,
}) async {
  // Implementation...
}
```

---

## 🧪 Testing Requirements

### Rule 6.1: Minimum Coverage
**Target:** 85% overall
**Critical Paths:** 100% (authentication, payment, data persistence)

**Measurement:**
```bash
# Python
pytest --cov=src/server --cov-report=term-missing --cov-fail-under=85

# Dart
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
# Must show ≥85% in report
```

**Enforcement:** CI fails if coverage drops below threshold.

---

### Rule 6.2: Test Naming Convention
**Pattern:** `test_<method>_<scenario>_<expected_result>`

```python
# ✅ CORRECT
def test_create_task_with_valid_data_returns_task_id():
    task = TaskService.create_task(title="Test", user_id=1)
    assert isinstance(task.id, int)

def test_create_task_with_empty_title_raises_validation_error():
    with pytest.raises(ValidationError):
        TaskService.create_task(title="", user_id=1)

# ❌ WRONG
def test_task():  # What about task?
def test_stuff():  # Non-descriptive
```

---

### Rule 6.3: Test Independence
**Rule:** Tests MUST be isolated (no shared state).

```python
# ❌ WRONG (shared database state)
def test_create_user():
    user = User(email="test@example.com")
    db.save(user)

def test_login():
    # Relies on test_create_user running first!
    user = db.get(email="test@example.com")

# ✅ CORRECT (fixtures/factories)
@pytest.fixture
def test_user(db_session):
    user = UserFactory.create(email="test@example.com")
    yield user
    db_session.rollback()  # Clean up

def test_login(test_user):
    # Independent - test_user fixture provides fresh data
    assert authenticate(test_user.email, "password123")
```

---

### Rule 6.4: Mocking External Services
**Rule:** Never call real external APIs in tests (Stripe, Groq, email services).

```python
from unittest.mock import patch, MagicMock

@patch('app.services.email.send_email')
def test_user_registration_sends_welcome_email(mock_send_email):
    # Mock returns success
    mock_send_email.return_value = {"status": "sent"}

    register_user(email="new@example.com")

    # Verify email service was called
    mock_send_email.assert_called_once()
    assert "new@example.com" in str(mock_send_email.call_args)
```

---

## 📚 Documentation Standards

### Rule 7.1: README Structure
**Required Sections:**
```markdown
# Project Name

## What is this?
One-paragraph summary.

## Quick Start
```bash
docker compose up
# Access at http://localhost:8000
```

## Architecture
Link to `context/30-ARCHITECTURE/SYSTEM_DIAGRAM.md`

## Development Setup
Step-by-step instructions with screenshots.

## Testing
How to run tests locally.

## Deployment
Link to `context/40-PLANNING/DEPLOYMENT_INFRASTRUCTURE.md`

## Contributing
Link to `CONTRIBUTING.md`

## License
MIT/Apache/Proprietary
```

---

### Rule 7.2: ADR Format
**Location:** `context/30-ARCHITECTURE/ARCH_DECISION_RECORDS.md`

**Template:**
```markdown
## ADR-007: Use PostgreSQL over MongoDB

**Date:** 2026-02-15
**Status:** Accepted
**Deciders:** Sarah Chen (Lead Architect), DevOps Team

### Context
We need to choose a database for TaskFlow Pro's primary data storage.

### Decision
We will use PostgreSQL 16+.

### Rationale
- **ACID Transactions:** Required for financial data integrity.
- **JSON Support:** `jsonb` type handles flexible schemas.
- **Mature Ecosystem:** pgAdmin, pg_dump, robust backup tools.
- **SQL Expertise:** Team is more familiar with SQL than NoSQL query languages.

### Alternatives Considered
- **MongoDB:** Flexible schema but lacks ACID guarantees.
- **MySQL:** Good but inferior JSON support compared to PostgreSQL.

### Consequences
- **Positive:** Strong data consistency, excellent tooling.
- **Negative:** Schema migrations require careful planning.
```

---

### Rule 7.3: API Documentation
**Standard:** OpenAPI 3.1.0 (auto-generated from FastAPI)

**Access:**
- Development: http://localhost:8000/docs (Swagger UI)
- Staging: https://api-staging.taskflowpro.io/docs
- Production: https://api.taskflowpro.io/docs (requires auth)

**Update Process:** Automatic (FastAPI generates from Pydantic models).

---

## 🚀 Deployment & Release Rules

### Rule 8.1: Semantic Versioning
**Format:** MAJOR.MINOR.PATCH (e.g., `v2.1.3`)

**Increment Rules:**
- **MAJOR:** Breaking changes (API contract changes)
- **MINOR:** New features (backward compatible)
- **PATCH:** Bug fixes (no new features)

**Examples:**
- `v1.0.0` → `v1.0.1` (fixed task deletion bug)
- `v1.0.1` → `v1.1.0` (added bulk task creation)
- `v1.1.0` → `v2.0.0` (changed API response format - breaking)

---

### Rule 8.2: Deployment Schedule
**Staging:** Continuous (on merge to develop)
**Production:** Tuesdays & Thursdays at 10:00 UTC

**Emergency Hotfixes:** Anytime (requires Lead Architect + DevOps approval)

---

### Rule 8.3: Rollback Plan
**Requirement:** Every deployment MUST have a tested rollback procedure.

**Automated Rollback Triggers:**
- Error rate >1% (compared to pre-deployment baseline)
- P95 latency >1000ms (degradation >20%)
- Critical endpoint failure (health check fails)

**Manual Rollback:**
```bash
# DevOps Engineer executes
kubectl rollout undo deployment/taskflow-api
# Or blue-green switch
./scripts/switch-to-blue.sh
```

**Post-Rollback:**
- Incident report within 2 hours
- Root cause analysis (RCA) within 24 hours
- Fix + re-deploy within 48 hours

---

## ⚠️ Violation Consequences

### CLASS A Violations (Security/Privacy)
**Examples:**
- Hardcoded secrets
- Unvalidated user inputs in database queries
- Unencrypted PII storage

**Consequences:**
1. **Immediate:** PR blocked + Slack alert
2. **Within 1 hour:** Developer must fix or revert
3. **Repeat offense:** Code review from Lead Architect required for next 5 PRs

---

### CLASS B Violations (Quality/Style)
**Examples:**
- Missing tests
- TODO comments in main branch
- Undocumented public functions

**Consequences:**
1. **Within 24 hours:** Create remediation ticket
2. **Within 48 hours:** Fix and deploy
3. **Repeat offense:** Warning from Lead Architect

---

### CLASS C Violations (Process)
**Examples:**
- Incorrect commit message format
- Missing PR description
- Skipping code review (emergency bypass)

**Consequences:**
1. Request to amend (friendly reminder)
2. No formal penalty (educational)

---

## 📋 Amendment Process

**Proposer:** Any team member can propose a rule change.

**Process:**
1. **Draft:** Create PR modifying this document.
2. **Justification:** Explain why the current rule is problematic.
3. **Impact Analysis:** Describe who/what is affected.
4. **Approval:** Requires votes from:
   - Lead Architect (mandatory)
   - Product Owner (if affects features/timeline)
   - 2+ additional team members

**Timeline:** 7 days for discussion, then vote.

**Effective Date:** Next sprint start (Monday after approval).

---

## 🔄 Document Maintenance

**Review Frequency:** Quarterly (first week of Q1, Q2, Q3, Q4)
**Owner:** Lead Architect
**Version History:** [GitHub Releases](https://github.com/taskflowpro/repo/releases)

**Change Log (Recent):**

### v2.1.0 (February 2026)
- Added Rule 4.4 (PII Handling) - compliance requirement
- Updated Rule 2.1 (approved Flutter 3.19+)
- Added Rule 8.3 (automated rollback triggers)

### v2.0.0 (January 2026)
- **Breaking:** Changed commit message format to Conventional Commits
- Added Quality Gates section
- Introduced CLASS A/B/C violation severity

### v1.0.0 (December 2025)
- Initial document creation
- Foundational principles established

---

## 📚 References

### Internal Documents
- [AGENTS.md](00-ROOT/AGENTS.md) - Role definitions and authority
- [TECH_STACK_DECISION.md](30-ARCHITECTURE/TECH_STACK_DECISION.md) - Technology choices
- [TESTING_STRATEGY.md](40-PLANNING/TESTING_STRATEGY.md) - Test requirements
- [SECURITY_PRIVACY_POLICY.md](20-REQUIREMENTS/SECURITY_PRIVACY_POLICY.md) - Security policies

### External Standards
- [Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/)
- [Semantic Versioning](https://semver.org/)
- [OWASP Top 10](https://owasp.org/www-project-top-ten/)
- [WCAG 2.1 Guidelines](https://www.w3.org/WAI/WCAG21/quickref/)
- [GDPR Compliance Checklist](https://gdpr.eu/checklist/)

---

**Document Signature:**

```
Ratified by:
- Sarah Chen (Lead Architect) - February 22, 2026
- Marcus Williams (Product Owner) - February 22, 2026
- Jonathan Wright (Compliance Officer) - February 22, 2026

Effective Date: March 1, 2026
```

---

*This document is version-controlled and stored in `context/00-ROOT/RULES.md`. Amendments require formal approval process as defined in Section 11.*
