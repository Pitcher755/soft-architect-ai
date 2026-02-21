# 🐙 Git Conventions & Workflow

> **Date:** 30/01/2026
> **Status:** ✅ MANDATORY
> **Standard:** Simplified GitFlow + Conventional Commits
> **Objective:** Clean, traceable, automatable history
> **Enforcement:** Pre-commit hooks + CI/CD validation

Absolute standardization of Git collaboration. Without this, history is garbage.

---

## 📖 Table of Contents

1. [Branching Strategy](#branching-strategy)
2. [Commit Messages (Conventional Commits)](#commit-messages-conventional-commits)
3. [Practical Workflow](#practical-workflow)
4. [Pull Requests (PRs)](#pull-requests-prs)
5. [Code Review Guidelines](#code-review-guidelines)
6. [Git Hooks & Automation](#git-hooks--automation)
7. [Troubleshooting](#troubleshooting)

---

## Branching Strategy

### Main Branches

| Branch | Protection | Purpose | Deploy |
|:---|:---|:---|:---|
| **`main`** | ✅ Protected | Production Code | Automatic on each merge |
| **`develop`** | ✅ Protected | Continuous Integration | Staging on each merge |
| **`feature/xyz`** | ❌ Ephemeral | New functionality | Manual (PR → develop) |
| **`fix/xyz`** | ❌ Ephemeral | Bug fix in develop | Manual (PR → develop) |
| **`hotfix/xyz`** | ❌ Ephemeral | Critical production error | Manual (PR → main + develop) |

### Naming Rules

#### Feature Branches

```bash
# ✅ GOOD: Descriptivo y corto
feature/auth-login-jwt
feature/rag-document-search
feature/flutter-riverpod-migration

# ❌ BAD: Demasiado genérico
feature/updates
feature/new-stuff

# ❌ BAD: Demasiado largo
feature/implement-oauth2-authentication-with-google-and-microsoft-providers
```

#### Fix Branches

```bash
# ✅ GOOD: Con ticket ID si aplica
fix/HU-001-auth-crash
fix/SEC-043-sql-injection

# ❌ BAD: Sin contexto
fix/bug
```

#### Hotfix Branches

```bash
# ✅ GOOD: Con versión
hotfix/v1.0.1-payment-processing-error
hotfix/v1.1.0-security-patch

# ❌ BAD: Sin versionado
hotfix/critical-error
```

---

## Commit Messages (Conventional Commits)

### Mandatory Format

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Allowed Types

| Type | Purpose | Example |
|:---|:---|:---|
| **`feat`** | New feature (for end user) | `feat(auth): implement JWT login endpoint` |
| **`fix`** | Bug fix | `fix(ui): resolve overflow in user card` |
| **`docs`** | Documentation changes only | `docs(arch): update threat model diagram` |
| **`style`** | Formatting, quotes, spaces (no logic change) | `style: run prettier on all files` |
| **`refactor`** | Reorganize code without changing behavior | `refactor(api): extract auth logic to service` |
| **`test`** | Add or improve tests | `test(unit): add validation for email schema` |
| **`chore`** | Build tasks, dependencies, versioning | `chore: upgrade poetry to 1.5.0` |
| **`ci`** | CI/CD changes | `ci: add security scan to pipeline` |
| **`perf`** | Performance improvement | `perf(db): add index to users table` |

### Scope (Optional but Recommended)

Affected code area:

```bash
feat(auth): login
feat(api): user endpoints
feat(flutter): state management
feat(docker): compose configuration
```

### Correct Commit Examples

```bash
# ✅ GOOD: Feature with clear description
feat(auth): implement JWT authentication with 15min expiration

# ✅ GOOD: Fix with explanatory body
fix(ui): resolve overflow in document card

Fix was causing layout break on mobile devices.
The issue was overflow hidden not applied to parent container.

# ✅ GOOD: Refactor
refactor(api): extract database connection logic to service layer

# ✅ GOOD: Chore
chore(deps): update pydantic from 2.0.0 to 2.1.0

# ✅ GOOD: Docs
docs(readme): add setup instructions for Flutter development

# ✅ GOOD: Test
test(unit): add validation tests for email schema

# ❌ BAD: Missing type
fixed the login bug

# ❌ BAD: Type but no clear description
feat: changes

# ❌ BAD: Too generic
fix: update

# ❌ BAD: Mixing multiple changes in one commit
feat: add login, fix navigation, update docs
# → Should be 3 separate commits
```

### Special Conventions

#### Breaking Changes

```bash
# ❌ OLD (don't use)
feat(api): change user endpoint format

# ✅ NEW (if breaking)
feat(api)!: change user endpoint format from /user to /users

# Or in footer:
feat(api): change response format

BREAKING CHANGE: The /user endpoint has been deprecated.
Use /users instead. Old format returned user object directly,
new format wraps in {"data": ...}.
```

#### Revert Commits

```bash
# ✅ GOOD
revert: feat(auth): implement JWT login

This reverts commit a1b2c3d4e5f6g7h8.
```

---

## Practical Workflow

### Step 1: Create Feature Branch

```bash
# Ensure being on updated develop
git checkout develop
git pull origin develop

# Create feature branch
git checkout -b feature/auth-login-jwt

# Verify correct branch
git branch -a | grep "*"
# * feature/auth-login-jwt
```

### Step 2: Make Commits

```bash
# Edit files
# ...

# View changes
git status
git diff src/services/auth.py

# Stage files
git add src/services/auth.py tests/unit/test_auth.py

# Verify staged
git diff --staged

# Commit with conventional message
git commit -m "feat(auth): implement JWT login with bcrypt hashing

- Create /login endpoint accepting email/password
- Return access_token (15min exp) + refresh_token (7d exp)
- Hash passwords with bcrypt
- Add unit tests for happy path and error cases"
```

### Step 3: Push to Remote

```bash
# First push (create upstream)
git push -u origin feature/auth-login-jwt

# Subsequent pushes
git push
```

### Step 4: Create Pull Request

On GitHub:

1. Click "Create PR" on banner
2. **Base:** `develop` (not `main`)
3. **Title:** Must be Conventional Commit
   ```
   feat(auth): implement JWT login endpoint
   ```
4. **Description:**
   ```markdown
   ## Summary
   Implements JWT-based authentication with secure password hashing.

   ## Type of Change
   - [x] New feature (non-breaking)
   - [ ] Bug fix
   - [ ] Breaking change

   ## Checklist
   - [x] Tests pass locally: `pytest tests/`
   - [x] Linter clean: `ruff check src/`
   - [x] No hardcoded secrets
   - [x] Documentation updated if needed

   ## Related Issues
   Closes #HU-001
   ```

---

## Pull Requests (PRs)

### Mandatory Structure

```markdown
## 📋 Summary
[What this PR does in 2-3 lines]

## 🎯 Type of Change
- [x] Feature (new user-facing capability)
- [ ] Bugfix (fixes existing issue)
- [ ] Refactor (reorganize without changing behavior)
- [ ] Documentation
- [ ] Performance improvement
- [ ] Security hardening

## ✅ Checklist (Before Marking as "Ready for Review")
- [ ] **Tests Pass:** `pytest` / `flutter test` pass locally
- [ ] **Linter Clean:** `ruff check` / `flutter analyze` without errors
- [ ] **No Secrets:** Verify NO API keys, passwords, tokens
- [ ] **Security:** Complies with OWASP_TOP_10.md
- [ ] **Docs Updated:** README/CHANGELOG/code comments if applicable
- [ ] **Conventional Commit:** PR message follows format
- [ ] **Coverage:** Tests cover new logic (>80%)

## 🔗 Related Issues
Closes #HU-001

Fixes #BUG-042 (if bugfix)

## 📸 Screenshots/Videos (if applicable)
[For UI changes, attach screenshots]

## 📝 Additional Notes
[Additional technical information if needed]
```

### Acceptance Criteria

A PR can be merged ONLY if:

1. ✅ **Tests pass** in CI/CD
2. ✅ **Linter clean** (ruff, flutter analyze)
3. ✅ **At least 1 approval** from code review
4. ✅ **Commit message is Conventional**
5. ✅ **No conflicts** with base branch
6. ✅ **Complies with OWASP_TOP_10.md** (if touches security code)

---

## Code Review Guidelines

### For the Author (Create PR)

```markdown
# 🚀 Self-Checklist

- [ ] I understand my own code
- [ ] Would explain this change to a colleague
- [ ] No "hacks" or spaghetti code
- [ ] Tests are clear and coverage > 80%
- [ ] Documentation is updated
- [ ] No linter warnings
```

### For the Reviewer (Code Review)

#### ✅ Positive: Constructive Comments

```
Great solution! I especially liked the error handling approach.

Suggestion: Could you add a docstring explaining the algorithm?
```

#### ❌ Blocker: Reject if...

1. **Security:** OWASP_TOP_10.md violation
   ```
   BLOCKER: This endpoint is missing authentication.
   Must use @app.get(..., dependencies=[Depends(get_current_user)])
   ```

2. **Tests Fail:** CI/CD Red
   ```
   BLOCKER: 3 test failures in CI/CD. Must pass before merging.
   ```

3. **Hardcoded Secrets:**
   ```
   BLOCKER: API key detected in code. Remove and add to .env.
   ```

4. **Architecture Violated:**
   ```
   BLOCKER: Business logic in Riverpod provider.
   Move to domain/use_cases/, then wire in Riverpod.
   ```

---

## Git Hooks & Automation

### Pre-commit Hooks (Automatic on your machine)

The `.pre-commit-config.yaml` file in root executes:

```yaml
repos:
  - repo: local
    hooks:
      # Verificar conventional commit
      - id: commitlint
        name: commitlint
        entry: npx commitlint --edit
        language: node
        stages: [commit-msg]

      # Linting Python
      - id: ruff
        name: ruff
        entry: ruff check
        language: python
        types: [python]

      # Linting Flutter
      - id: flutter-analyze
        name: flutter analyze
        entry: flutter analyze
        language: system
        types: [dart]

      # Detectar secretos
      - id: detect-secrets
        name: detect-secrets
        entry: detect-secrets scan
        language: python
```

### Installation

```bash
# First time for each developer
pre-commit install
pre-commit install --hook-type commit-msg

# After each pull
pre-commit autoupdate
```

### Flow in CI/CD (GitHub Actions)

```yaml
# .github/workflows/ci.yml
name: CI

on: [push, pull_request]

jobs:
  validate-commits:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
        with:
          fetch-depth: 0

      - name: Validate Conventional Commits
        run: |
          npx commitlint --from origin/develop --to HEAD

  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: pytest tests/
      - run: flutter test

  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - run: ruff check src/
      - run: flutter analyze
```

---

## Troubleshooting

### Problema: Cambié de rama sin hacer commit

```bash
# ❌ Error
$ git checkout develop
error: Your local changes to the following files would be overwritten by checkout:
  src/main.py

# ✅ Solución: Stash cambios
git stash
git checkout develop

# Después, recuperar cambios en rama correcta
git checkout feature/xyz
git stash pop
```

### Problema: Cometí en develop por error

```bash
# ❌ Accidente
$ git log --oneline develop
a1b2c3d feat: login  ← Debería estar en feature/auth-login

# ✅ Solución: Mover commit a rama nueva
git checkout -b feature/auth-login
git checkout develop
git reset --hard HEAD~1  # Deshacer último commit en develop
```

### Problema: Mensaje de commit incorrecto

```bash
# ❌ Cometí mal
git commit -m "fixed login"

# ✅ Solución: Amend (si no se ha pusheado)
git commit --amend -m "fix(auth): correct login validation"

# Si ya se pusheó
git push --force-with-lease origin feature/auth-login
```

### Problema: PR tiene conflictos

```bash
# ✅ Traer cambios de develop
git fetch origin develop
git rebase origin/develop

# Resolver conflictos
# ...

# Continuar rebase
git rebase --continue

# Forzar push
git push --force-with-lease origin feature/auth-login
```

---

## Useful Aliases

Save in `~/.gitconfig`:

```bash
[alias]
  co = checkout
  br = branch
  ci = commit
  st = status
  log-short = log --oneline -20
  log-graph = log --graph --oneline --all
  upstream = push -u origin HEAD
  sync = fetch origin && rebase origin/develop
```

Uso:

```bash
git co feature/xyz
git log-short
git upstream
```

---

## Conclusion

**Git Workflow is the Collaboration Infrastructure:**

1. ✅ Clear branches = clear responsibility
2. ✅ Conventional commits = readable history
3. ✅ Structured PRs = effective reviews
4. ✅ Automatic hooks = guaranteed quality

**Dogfooding Validation:** SoftArchitect self-validates with this workflow on each commit.
