# 🐙 Git Conventions & Workflow

> **Fecha:** 30/01/2026
> **Estado:** ✅ MANDATORY
> **Estándar:** GitFlow Simplificado + Conventional Commits
> **Objetivo:** Historial limpio, trazable, automatizable
> **Enforcement:** Pre-commit hooks + CI/CD validation

Estandarización absoluta de colaboración en Git. Sin esto, el historial es basura.

---

## 📖 Tabla de Contenidos

1. [Estrategia de Ramas (Branching)](#estrategia-de-ramas-branching)
2. [Mensajes de Commit (Conventional Commits)](#mensajes-de-commit-conventional-commits)
3. [Workflow Práctico](#workflow-práctico)
4. [Pull Requests (PRs)](#pull-requests-prs)
5. [Code Review Guidelines](#code-review-guidelines)
6. [Git Hooks & Automation](#git-hooks--automation)
7. [Troubleshooting](#troubleshooting)

---

## Estrategia de Ramas (Branching)

### Ramas Principales

| Rama | Protección | Propósito | Deploy |
|:---|:---|:---|:---|
| **`main`** | ✅ Protected | Código de Producción | Automático en cada merge |
| **`develop`** | ✅ Protected | Integración Continua | Staging en cada merge |
| **`feature/xyz`** | ❌ Efímera | Nueva funcionalidad | Manual (PR → develop) |
| **`fix/xyz`** | ❌ Efímera | Bug fix en develop | Manual (PR → develop) |
| **`hotfix/xyz`** | ❌ Efímera | Error crítico en prod | Manual (PR → main + develop) |

### Reglas de Nombrado

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

## Mensajes de Commit (Conventional Commits)

### Formato Obligatorio

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

### Tipos Permitidos

| Tipo | Propósito | Ejemplo |
|:---|:---|:---|
| **`feat`** | Nueva característica (para usuario final) | `feat(auth): implement JWT login endpoint` |
| **`fix`** | Solución de un bug | `fix(ui): resolve overflow in user card` |
| **`docs`** | Solo cambios en documentación | `docs(arch): update threat model diagram` |
| **`style`** | Formato, comillas, espacios (sin cambiar lógica) | `style: run prettier on all files` |
| **`refactor`** | Reorganizar código sin cambiar comportamiento | `refactor(api): extract auth logic to service` |
| **`test`** | Añadir o mejorar tests | `test(unit): add validation for email schema` |
| **`chore`** | Tareas de build, dependencias, versioning | `chore: upgrade poetry to 1.5.0` |
| **`ci`** | Cambios en CI/CD | `ci: add security scan to pipeline` |
| **`perf`** | Mejora de performance | `perf(db): add index to users table` |

### Scope (Opcional pero Recomendado)

Área del código afectada:

```bash
feat(auth): login
feat(api): user endpoints
feat(flutter): state management
feat(docker): compose configuration
```

### Ejemplos de Commits Correctos

```bash
# ✅ GOOD: Feature con descripción clara
feat(auth): implement JWT authentication with 15min expiration

# ✅ GOOD: Fix con body explicativo
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

# ❌ BAD: Falta tipo
fixed the login bug

# ❌ BAD: Tipo pero sin description clara
feat: changes

# ❌ BAD: Demasiado genérico
fix: update

# ❌ BAD: Mezclar múltiples cambios en un commit
feat: add login, fix navigation, update docs
# → Debería ser 3 commits separados
```

### Convenciones Especiales

#### Breaking Changes

```bash
# ❌ VIEJO (no usar)
feat(api): change user endpoint format

# ✅ NUEVO (si es breaking)
feat(api)!: change user endpoint format from /user to /users

# O en footer:
feat(api): change response format

BREAKING CHANGE: The /user endpoint has been deprecated.
Use /users instead. Old format returned user object directly,
new format wraps in {"data": ...}.
```

#### Revertir Commits

```bash
# ✅ GOOD
revert: feat(auth): implement JWT login

This reverts commit a1b2c3d4e5f6g7h8.
```

---

## Workflow Práctico

### Paso 1: Crear Feature Branch

```bash
# Asegurar estar en develop actualizado
git checkout develop
git pull origin develop

# Crear feature branch
git checkout -b feature/auth-login-jwt

# Verificar rama correcta
git branch -a | grep "*"
# * feature/auth-login-jwt
```

### Paso 2: Hacer Commits

```bash
# Editar archivos
# ...

# Ver cambios
git status
git diff src/services/auth.py

# Stage archivos
git add src/services/auth.py tests/unit/test_auth.py

# Verificar staged
git diff --staged

# Commit con mensaje conventional
git commit -m "feat(auth): implement JWT login with bcrypt hashing

- Create /login endpoint accepting email/password
- Return access_token (15min exp) + refresh_token (7d exp)
- Hash passwords with bcrypt
- Add unit tests for happy path and error cases"
```

### Paso 3: Push a Remoto

```bash
# Primer push (crear upstream)
git push -u origin feature/auth-login-jwt

# Pushes subsecuentes
git push
```

### Paso 4: Crear Pull Request

En GitHub:

1. Click "Create PR" en banner
2. **Base:** `develop` (no `main`)
3. **Title:** Debe ser Conventional Commit
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

### Estructura Obligatoria

```markdown
## 📋 Summary
[Qué hace este PR en 2-3 líneas]

## 🎯 Type of Change
- [x] Feature (new user-facing capability)
- [ ] Bugfix (solves existing issue)
- [ ] Refactor (reorganize without changing behavior)
- [ ] Documentation
- [ ] Performance improvement
- [ ] Security hardening

## ✅ Checklist (Antes de Marcar como "Ready for Review")
- [ ] **Tests Pass:** `pytest` / `flutter test` pasan localmente
- [ ] **Linter Clean:** `ruff check` / `flutter analyze` sin errors
- [ ] **No Secrets:** Verificar NO hay API keys, passwords, tokens
- [ ] **Security:** Cumple con OWASP_TOP_10.md
- [ ] **Docs Updated:** README/CHANGELOG/code comments si aplica
- [ ] **Conventional Commit:** Mensaje de PR sigue formato
- [ ] **Coverage:** Tests cubren lógica nueva (>80%)

## 🔗 Related Issues
Closes #HU-001

Fixes #BUG-042 (si es bugfix)

## 📸 Screenshots/Videos (si aplica)
[Para cambios en UI, adjuntar screenshots]

## 📝 Additional Notes
[Información técnica adicional si necesaria]
```

### Criterios de Aceptación

Un PR puede ser merged SOLO si:

1. ✅ **Tests pasan** en CI/CD
2. ✅ **Linter limpio** (ruff, flutter analyze)
3. ✅ **Al menos 1 aprobación** de code review
4. ✅ **Mensaje de commit es Conventional**
5. ✅ **No conflictos** con rama base
6. ✅ **Cumple con OWASP_TOP_10.md** (si toca código de seguridad)

---

## Code Review Guidelines

### Para el Autor (Crear PR)

```markdown
# 🚀 Self-Checklist

- [ ] He entendido mi propio código
- [ ] Explicaría este cambio a un compañero
- [ ] No hay "hacks" o spaghetti code
- [ ] Tests son claros y cobertura > 80%
- [ ] Documentación está actualizada
- [ ] Sin warnings del linter
```

### Para el Revisor (Code Review)

#### ✅ Positivo: Comentarios Constructivos

```
Great solution! I especially liked the error handling approach.

Suggestion: Could you add a docstring explaining the algorithm?
```

#### ❌ Bloqueante: Rechazar si...

1. **Seguridad:** Violación de OWASP_TOP_10.md
   ```
   BLOCKER: This endpoint is missing authentication.
   Debe usar @app.get(..., dependencies=[Depends(get_current_user)])
   ```

2. **Tests Fallan:** CI/CD Red
   ```
   BLOCKER: 3 test failures in CI/CD. Must pass before merging.
   ```

3. **Secretos Hardcodeados:**
   ```
   BLOCKER: API key detected in code. Remove and add to .env.
   ```

4. **Arquitectura Violada:**
   ```
   BLOCKER: Business logic in Riverpod provider.
   Move to domain/use_cases/, then wire in Riverpod.
   ```

---

## Git Hooks & Automation

### Pre-commit Hooks (Automático en tu máquina)

El archivo `.pre-commit-config.yaml` en raíz ejecuta:

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

### Instalación

```bash
# Primero de cada desarrollador
pre-commit install
pre-commit install --hook-type commit-msg

# Después de cada pull
pre-commit autoupdate
```

### Flujo en CI/CD (GitHub Actions)

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

## Aliases Útiles

Guardar en `~/.gitconfig`:

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

## Conclusión

**El Git Workflow es la Infraestructura de Colaboración:**

1. ✅ Ramas claras = responsabilidad clara
2. ✅ Commits conventionales = historial legible
3. ✅ PRs estructuradas = reviews efectivas
4. ✅ Hooks automáticos = calidad garantizada

**Dogfooding Validation:** SoftArchitect se auto-valida con este workflow en cada commit.
