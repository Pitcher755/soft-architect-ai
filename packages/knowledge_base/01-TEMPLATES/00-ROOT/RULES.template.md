# 📜 Repository Rules & Standards

<!--
════════════════════════════════════════════════════════════════════════════════
📘 TEMPLATE GUIDE: How to Fill Out This Document
════════════════════════════════════════════════════════════════════════════════

PURPOSE:
Rules define "HOW" work gets done (coding standards, testing, reviews). This document acts as the absolute law for both human developers and AI agents, preventing merge conflicts, technical debt, and security vulnerabilities.

WHEN TO CREATE:
- **Generation Order:** 21/24 (FIRST of ROOT/META documents)
- **Phase:** 6 - ROOT / META
- **Prerequisites:** TECH_STACK_DECISION.md and TESTING_STRATEGY.md

BEST PRACTICES & AI INSTRUCTIONS:
✅ **BE EXPLICIT:** Do not use vague terms like "write clean code". Specify EXACT naming conventions (e.g., snake_case, PascalCase) based on the chosen languages.
✅ **NO HALLUCINATIONS:** Ensure the code examples use the exact languages and frameworks defined in Phase 3.
✅ **REPLACE VARIABLES:** Swap all {{PLACEHOLDERS}} with actual data.
✅ **MERMAID DIAGRAMS:** If you generate any Mermaid diagrams, do NOT use curly braces {} inside them. Replace uppercase placeholders directly with text to avoid rendering errors.
✅ **SELF-DESTRUCT:** Remove this entire TEMPLATE GUIDE block before outputting.

⚠️ **CRITICAL ROUTING:**
   This file MUST be saved in the ROOT directory (/) of the project.
   Filename MUST be: RULES.md
   Correct path: /RULES.md
   Incorrect path: /context/RULES.md or /context/00-ROOT/RULES.md

RELATED DOCS:
- /CONTRIBUTING.md (PR workflow)
- /context/40-PLANNING/CI_CD_PIPELINE.md (Auto-enforcement of these rules)
- /AGENTS.md (Who approves rule exceptions)
════════════════════════════════════════════════════════════════════════════════
-->

> **Last Updated:** {{DATE}}
> **Enforced By:** {{ENFORCEMENT_TOOL}} (CI/CD)
> **Authority:** {{LEAD_ARCHITECT}} (exceptions approval)

---

## 📖 Table of Contents

- [Code Standards](#code-standards)
- [Naming Conventions](#naming-conventions)
- [Git Workflow](#git-workflow)
- [Commit Messages](#commit-messages)
- [Pull Request Rules](#pull-request-rules)
- [Code Review Guidelines](#code-review-guidelines)
- [Testing Requirements](#testing-requirements)
- [Security Rules](#security-rules)
- [Performance Standards](#performance-standards)
- [Documentation Requirements](#documentation-requirements)
- [CI/CD Quality Gates](#cicd-quality-gates)
- [Exceptions Process](#exceptions-process)

---

## 🎨 Code Standards

### {{BACKEND_LANG}} (Backend)

**Formatter:** {{BACKEND_FORMATTER}}  <!-- e.g., Black, Prettier, rustfmt -->

**Rules:**
```{{BACKEND_LANG}}
# ✅ CORRECT
def calculate_total(
    items: list[Item],
    discount: float = 0.0
) -> Decimal:
    """Calculate total with optional discount."""
    return sum(i.price for i in items) * (1 - discount)

# ❌ WRONG
def calc(items,discount=0.0):  # No types, no docstring, bad name
    return sum([i.price for i in items])*(1-discount)
```

**Enforcement:**
```bash
{{BACKEND_FORMATTER}} --check src/  # Runs in CI
```

---

### {{FRONTEND_LANG}} (Frontend)

**Formatter:** {{FRONTEND_FORMATTER}}  <!-- e.g., dart format, Prettier -->

**Rules:**
```{{FRONTEND_LANG}}
// ✅ CORRECT
class UserProfile extends StatelessWidget {
  final String userId;

  const UserProfile({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    return Text('User: $userId');
  }
}

// ❌ WRONG
class userprofile extends StatelessWidget {  // Wrong naming
  String? _userId;  // Mutable in stateless widget
  userprofile(this._userId);  // Non-const
}
```

**Enforcement:**
```bash
{{FRONTEND_FORMATTER}} lib/  # Runs in CI
```

---

## 🏷️ Naming Conventions

| Type | Convention | Example | Anti-Pattern |
|------|------------|---------|--------------|
| **Files** | {{FILE_CONVENTION}} | `user_profile.dart` | `UserProfile.dart` |
| **Classes** | PascalCase | `UserRepository` | `user_repository` |
| **Functions** | snake_case (Python) / camelCase (Dart) | `get_user()` / `getUser()` | `GetUser()` |
| **Constants** | UPPER_SNAKE | `MAX_RETRIES = 3` | `maxRetries` |
| **Private** | _prefix | `_internal_cache` | `internalCache` |
| **Enums** | PascalCase | `enum Status { Active, Inactive }` | `enum status` |

**File Naming:**
```
✅ CORRECT:
- user_profile.dart
- api_client.py
- auth_service_test.dart

❌ WRONG:
- UserProfile.dart (PascalCase disallowed)
- apiClient.py (camelCase disallowed)
- authservice.dart (missing underscore)
```

---

## 🌳 Git Workflow

**Branching Model:** {{GIT_MODEL}}  <!-- e.g., Gitflow, GitHub Flow, Trunk-Based -->

### Branch Naming

| Type | Pattern | Example | Lifespan |
|------|---------|---------|----------|
| **Feature** | `feature/{{TICKET}}-{{DESC}}` | `feature/HU-42-add-login` | 2-7 days |
| **Bugfix** | `bugfix/{{TICKET}}-{{DESC}}` | `bugfix/BUG-101-fix-crash` | 1-3 days |
| **Hotfix** | `hotfix/{{DESC}}` | `hotfix/security-patch` | <4 hours |
| **Release** | `release/v{{VERSION}}` | `release/v1.2.0` | 1-2 days |

**Rules:**
- ✅ All branches FROM `develop` (except hotfixes from `main`)
- ✅ Delete branch after merge
- ✅ Max 1 week lifespan (rebase if stale)
- ❌ NO direct commits to `main` or `develop`
- ❌ NO generic names (`feature/fixes`, `test-branch`)

---

## ✍️ Commit Messages

**Format:** [Conventional Commits](https://www.conventionalcommits.org/)

```
<type>(<scope>): <subject>

<body>

<footer>
```

### Types

| Type | Purpose | Example |
|------|---------|---------|
| `feat` | New feature | `feat(auth): add OAuth login` |
| `fix` | Bug fix | `fix(api): handle null response` |
| `docs` | Documentation | `docs(readme): update install steps` |
| `style` | Formatting | `style: run black formatter` |
| `refactor` | Code reorg | `refactor(user): extract validator` |
| `test` | Tests | `test(auth): add login edge cases` |
| `chore` | Build/config | `chore: update dependencies` |
| `security` | Security fix | `security: upgrade openssl` |

### Examples

```
✅ CORRECT:
feat(rag): add vector search caching

Implements LRU cache for repeated queries:
- Cache size: 100 entries
- TTL: 5 minutes
- Reduces latency by 80%

Closes #42

❌ WRONG:
updated stuff  # No type, no scope, vague
```

---

## 🔀 Pull Request Rules

### Size Limits

| Metric | Limit | Reason |
|--------|-------|--------|
| **Lines Changed** | <500 | Reviewable in <30 min |
| **Files Changed** | <20 | Prevents "mega PRs" |
| **Review Time** | <4 hours | Keeps velocity high |

**Exceptions:** Data migrations, generated code (approved by {{LEAD_ARCHITECT}})

### Required Checks

```
☐ All CI tests pass (0 failures)
☐ Coverage ≥{{COVERAGE_TARGET}}% (no decrease)
☐ No merge conflicts
☐ 1+ approving review
☐ All conversations resolved
☐ Linked to issue/ticket
☐ Branch up-to-date with develop
```

### PR Template

```markdown
## 🎯 Purpose
<!-- WHAT problem does this solve? Link to issue. -->

## 🔨 Changes
<!-- HOW did you solve it? List technical changes. -->

## 🧪 Testing
<!-- Proof it works: manual steps, test coverage. -->

## 📸 Screenshots (if UI)
<!-- Before/after images. -->

## ⚠️ Breaking Changes
<!-- Will this break existing features? How to migrate? -->

## ✅ Checklist
- [ ] Tests added/updated
- [ ] Docs updated
- [ ] No merge conflicts
```

---

## 👀 Code Review Guidelines

### Reviewer Responsibilities

**Approval Criteria:**

| Aspect | Check |
|--------|-------|
| **Correctness** | Logic matches requirements, no off-by-one errors |
| **Test Coverage** | All branches covered, edge cases tested |
| **Security** | No SQL injection, XSS, secrets in code |
| **Performance** | No N+1 queries, excessive memory usage |
| **Style** | Follows naming, formatting rules |
| **Documentation** | Public functions have docstrings |

**Response Time SLA:**
- **Critical PR (hotfix):** <2 hours
- **Normal PR:** <4 hours
- **Large PR (>500 lines):** <8 hours

### Feedback Tone

```
✅ GOOD FEEDBACK:
"Consider extracting `validate_user()` to a separate method for readability.
This would also make it easier to test in isolation."

❌ BAD FEEDBACK:
"This is bad code." (vague, not actionable)
```

**Review Philosophy:** "Critique ideas, not people"

---

## 🧪 Testing Requirements

### Coverage Targets

| Layer | Target | Enforcement |
|-------|--------|-------------|
| **Domain Logic** | 100% | CI fails if <100% |
| **Service Layer** | ≥90% | CI fails if <90% |
| **API Endpoints** | ≥85% | CI fails if <85% |
| **UI Widgets** | ≥80% | CI fails if <80% |
| **Overall** | ≥{{COVERAGE_TARGET}}% | CI fails if <{{COVERAGE_TARGET}}% |

### Test Pyramid

```
      /\      E2E (5%)
     /  \
    /____\    Integration (15%)
   /      \
  /________\  Unit (80%)
```

**Rules:**
- ✅ Write tests BEFORE code (TDD)
- ✅ Tests must be deterministic (no random/time-based)
- ✅ Mock external services (APIs, DB)
- ❌ NO tests talking to production APIs
- ❌ NO tests depending on test order

### Test Naming

```{{BACKEND_LANG}}
# ✅ CORRECT
def test_login_with_invalid_password_returns_401(self):
    """Test that invalid password returns 401 with error message."""
    ...

# ❌ WRONG
def test_login(self):  # Vague, no expected outcome
    ...
```

---

## 🔒 Security Rules

**Mandatory Checks:**

1. **No Secrets in Code**
   ```bash
   # ✅ CORRECT
   API_KEY = os.getenv("API_KEY")

   # ❌ WRONG
   API_KEY = "sk_live_abc123"  # Leaked!
   ```

2. **Input Validation**
   ```{{BACKEND_LANG}}
   # ✅ CORRECT
   def get_user(user_id: int):
       if not (1 <= user_id <= 999999):
           raise ValidationError("Invalid ID")
       return db.query(User).filter_by(id=user_id).first()

   # ❌ WRONG
   def get_user(user_id):
       return db.query(f"SELECT * FROM users WHERE id={user_id}")  # SQL injection!
   ```

3. **Dependency Scanning**
   ```bash
   pip-audit           # Python
   npm audit           # Node.js
   flutter pub audit   # Dart
   ```

**Auto-Enforcement:** CI runs {{SECURITY_TOOL}} (e.g., Bandit, Trivy)

---

## ⚡ Performance Standards

**Latency Targets:**

| Action | Target | Enforcement |
|--------|--------|-------------|
| **UI Interaction** | <200ms | Manual testing |
| **API Response** | <500ms (p95) | CI performance tests |
| **RAG Query** | <2s | CI benchmarks |
| **DB Query** | <100ms | Slow query log |

**Memory:**
- **Desktop App:** <500 MB RAM
- **Backend Service:** <200 MB/container

**Profiling:**
```bash
# Backend
py-spy record --output profile.svg -- python main.py

# Frontend
flutter run --profile
```

---

## 📚 Documentation Requirements

**Mandatory Docs:**

| Code Element | Requirement | Example |
|--------------|-------------|---------|
| **Public Functions** | Docstring | `"""Calculate tax. Args: amount (Decimal). Returns: Decimal"""` |
| **Classes** | Docstring | `"""User entity. Attributes: id (int), name (str)"""` |
| **API Endpoints** | OpenAPI spec | Auto-generated from FastAPI |
| **ADRs** | For architecture decisions | `ADR-001-use-postgresql.md` |

**Generated Docs:**
```bash
# Backend (Python)
pdoc src/server/ --output-dir doc/api

# Frontend (Dart)
dart doc lib/
```

---

## 🚦 CI/CD Quality Gates

**Pre-Merge Checks (GitHub Actions):**

```yaml
✓ Code Formatting ({{BACKEND_FORMATTER}}, {{FRONTEND_FORMATTER}})
✓ Linting ({{LINTER}})
✓ Type Checking (mypy, Dart analyzer)
✓ Unit Tests (pytest, flutter test)
✓ Integration Tests
✓ Security Scan ({{SECURITY_TOOL}})
✓ Coverage ≥{{COVERAGE_TARGET}}%
✓ Build (Docker, Flutter)
```

**Failure = PR BLOCKED until fixed**

---

## 🚨 Exceptions Process

**When Rules Are Violated:**

1. **Document in PR:** "EXCEPTION: Violates rule X because Y"
2. **Tag:** `@{{LEAD_ARCHITECT}}` for approval
3. **Create Issue:** "Tech Debt: Fix exception in PR #123"
4. **Time-Bound:** Must resolve in <30 days

**Example:**
```markdown
## ⚠️ EXCEPTION REQUEST

**Rule Violated:** Coverage <{{COVERAGE_TARGET}}% (currently 75%)
**Reason:** Legacy code refactor, adding tests in follow-up PR #124
**Approved By:** @{{LEAD_ARCHITECT}}
**Due Date:** 2025-03-15
```

---

## 🔄 Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| v1.0 | {{INITIAL_DATE}} | Initial rules | {{AUTHOR}} |

---

> **Rule Changes:** Propose via PR to this file (requires {{LEAD_ARCHITECT}} approval)
