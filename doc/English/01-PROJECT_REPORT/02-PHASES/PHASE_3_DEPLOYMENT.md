# 🏛️ PHASE 3: REGLAS TRANSVERSALES (The Constitutional Law)

> **Date:** 30 de Enero de 2026
> **Status:** ✅ COMPLETADA
> **Commits:** 2 (5bca7ee + 1fe12ea)
> **Total Líneas:** 3,742 (5 files constitucionales)
> **Impacto:** Todas las futuras decisiones de SoftArchitect se validarán contra estas reglas universales

---

## 📖 Table of Contents

1. [Visión Generatel](#visión-general)
2. [TRAMA 3.1: La Constitución (Constitutional Law)](#trama-31-la-constitución)
3. [TRAMA 3.2: Los Estándares Web](#trama-32-los-estándares-web)
4. [Matriz de Impacto](#matriz-de-impacto)
5. [validation RAG](#validation-rag)
6. [Next Steps](#próximos-pasos)

---

## Visión Generatel

**PHASE 3** establishes the **Leyes Universales** que rigen TODO desarrollo futuro en SoftArchitect.

> "Estos documents no son sugerencias; son **La Ley Absoluta**."
> El RAG rechazará PRs que las violen. Los desarrolladores deben jurar cumplirlas.

### Objectives Alcanzados

✅ **Seguridad Universal:** OWASP Top 10 traducido a soluciones by stack (Backend/Frontend/DevOps)
✅ **Colaboración Estricta:** GitFlow + Conventional Commits como estándar immutable
✅ **Testing First:** TDD Red-Green-Refactor es el único método permitido
✅ **Web Standards:** HTML5 semántico + CSS Mobile-First for toda web
✅ **Enforcement:** RAG puede validar automáticamente cada commit contra estas leyes

---

## TRAMA 3.1: La Constitución

### 📋 files Created

**Localización:** `packages/knowledge_base/02-TECH-PACKS/general/`
**Total:** 3 files, 2,075 líneas
**Commit:** `5bca7ee` ⚖️🐙🧪

### file 1: OWASP_TOP_10.md (789 líneas)

**Propósito:** Traducir las 10 vulnerabilidades OWASP a soluciones técnicas by stack.

#### Structure

```
├── La Regla de Oro: "No OWASP, No Deploy"
├── Matriz (10 vulnerabilidades × 3 stacks)
│   ├── Backend (Python FastAPI) - Soluciones técnicas específicas
│   ├── Frontend (Flutter) - Protecciones en cliente
│   └── DevOps (Docker) - Hardening de infraestructura
├── Vulnerabilidades Detalladas (A01-A10)
│   ├── A01: Broken Access Control
│   ├── A02: Cryptographic Failures
│   ├── A03: Injection
│   ├── A04: Insecure Design
│   ├── A05: Security Misconfiguration
│   ├── A06: Vulnerable & Outdated Components
│   ├── A07: Authentication Failures
│   ├── A08: Data Integrity Failures
│   ├── A09: Logging & Monitoring Failures
│   └── A10: SSRF
├── Ejemplos de Código: ✅ GOOD vs ❌ BAD para cada vulnerabilidad
├── Reglas Linter Automáticas
└── Pre-production Checklist (10 items)
```

#### Soluciones by Stack

| Vulnerabilidad | Backend (FastAPI) | Frontend (Flutter) | DevOps (Docker) |
|:---|:---|:---|:---|
| **A01** Broken Access | `@app.get("/endpoint", dependencies=[Depends(get_current_user)])` | `GoRouter(redirect: ...)` guards | RBAC en auth gateway |
| **A02** Cryptographic | `passlib.hash(password)` + JWT 15min | `flutter_secure_storage` (Keychain/Keystore) | TLS 1.3 enforced |
| **A03** Injection | SQLAlchemy ORM (NO raw SQL) | Typed parameters en GoRouter | Container scanning |
| **A04-A10** | Pydantic validation, rate limiting, logging | Encrypted storage, permission checks | Non-root user, CORS restrictive |

#### Dogfooding

**SoftArchitect valida su propio código:** Todos los commits en `src/server/` and `src/client/` pasan validation OWASP antes de merge.

### file 2: GIT_CONVENTIONS.md (554 líneas)

**Propósito:** Estandarizar colaboración: branching, commits, PRs, code review.

#### Workflow GitFlow Simplificado

```
main (prod) ← develop (CI) ← feature/xyz, fix/xyz, hotfix/xyz (ephemeral)
```

#### Conventional Commits

**Formato:** `<type>(<scope>): <description>`

```bash
# ✅ GOOD
git commit -m "feat(auth): implement JWT login endpoint"
git commit -m "fix(HU-001): crash when submitting form"
git commit -m "docs(setup): add troubleshooting section"

# ❌ BAD
git commit -m "Update stuff"
git commit -m "fix auth"
git commit -m "aqwerty"
```

**Tipos Permitidos:**
- `feat` - New funcionalidad
- `fix` - Bug fix
- `docs` - Documentación
- `style` - Formato (sin cambio de lógica)
- `refactor` - Reorganización de código
- `test` - Agregación/modificación de tests
- `chore` - Tareas de build/deps
- `ci` - Cambios en CI/CD
- `perf` - Betteras de performance

#### PR Checklist (Blocker Items)

```markdown
## Pre-Merge Validation

- [ ] Tests pass locally: `npm test` / `flutter test` / `pytest`
- [ ] Linter clean: `eslint` / `flutter_format` / `flake8 --strict`
- [ ] No secrets exposed: `git-secrets scan`
- [ ] OWASP compliance: Manual security review for high-risk code
- [ ] Documentation updated: README, inline comments, doc/
- [ ] Commit messages follow Conventional Commits
- [ ] Branch rebased on `develop` (no merge commits)
```

**Regla:** Si alguno falla, el PR se rechaza automáticamente.

### file 3: TDD_METHODOLOGY.md (732 líneas)

**Propósito:** Enforce Test-Driven Development como el único método aceptado.

#### Red-Green-Refactor Cycle

```
🔴 RED Phase
   └─ Escribir test que FALLA (para funcionalidad no existente)
      └─ Ejemplo: test_user_creation_with_invalid_email()

🟢 GREEN Phase
   └─ Implementar código MÍNIMO para que el test pase
      └─ Puede ser hardcoded, puede tener TODOs

🔵 REFACTOR Phase
   └─ Limpiar, optimizar, añadir logging SIN cambiar comportamiento
      └─ Tests deben seguir pasando
```

#### AAA Structure (Arrange-Act-Assert)

```python
# Python Example (pytest)
def test_user_creation_valid():
    # Arrange: Setup
    repo = MockUserRepository()
    service = UserService(repo)

    # Act: Execute
    user = service.create(
        name="Juan",
        email="juan@example.com",
        password="SecurePass123!"
    )

    # Assert: Verify
    assert user.id is not None
    assert user.email == "juan@example.com"
    assert repo.save_called_once()
```

#### Testing Pyramid

```
        △ E2E Tests (10%)
       △ △ Integration Tests (20%)
      △ △ △ Unit Tests (70%)
```

**Métricas Obligatorias:**
- Backend: ≥80% coverage
- Frontend: ≥75% coverage
- Critical paths (auth, payment): ≥95% coverage

#### Pre-Development Checklist

```bash
[ ] Entender requisito completamente
[ ] Diseñar test cases (happy path + edge cases)
[ ] Crear test file con estructura AAA
[ ] Run test (debe fallar - RED)
[ ] Implementar funcionalidad mínima
[ ] Run test (debe pasar - GREEN)
[ ] Refactor y optimize
[ ] Run test (sigue pasando - REFACTOR)
[ ] Coverage ≥80% (backend) o ≥75% (frontend)
```

#### Anti-Patterns (Prohibido)

❌ Escribir test DESPUÉS de código (Post-Hoc Testing)
❌ Tests que pasan but no validan nada (`assert True`)
❌ Ignorar tests fallidos en CI/CD
❌ Burlarse de todo without criterio (over-mocking)

---

## TRAMA 3.2: Los Estándares Web

### 📋 files Created

**Localización:** `packages/knowledge_base/02-TECH-PACKS/FRONTEND/web-general/`
**Total:** 2 files, 1,667 líneas
**Commit:** `1fe12ea` 🌐✨

### file 1: HTML5_SEMANTICS.md (720 líneas)

**Propósito:** Prohibir "Div Soup" and forzar accesibilidad estructural.

#### La Regla de Oro

> "Si un elemento tiene significado semántico, **NO uses `<div>`**."

#### Matriz de Prohibición

| Componente | ❌ MALO | ✅ BUENO | Razón |
|:---|:---|:---|:---|
| Button | `<div onclick>` | `<button>` | Foco, SR, styles nativos |
| Enlace | `<div class="link" onclick>` | `<a href>` | Navegación, SEO |
| Navegación | `<div class="nav">` | `<nav>` | Landmark for SR |
| Artículo | `<div class="post">` | `<article>` | content independiente |
| Sidebar | `<div class="sidebar">` | `<aside>` | content complementario |
| Encabezado | `<div class="header">` | `<header>` | Contexto introductorio |
| Pie | `<div class="footer">` | `<footer>` | Información de cierre |
| Título | `<div class="title">` | `<h1>`, `<h2>`, `<h3>` | Jerarquía, outline |

#### Structure Correcta de document

```html
<!DOCTYPE html>
<html lang="es">
<body>
  <header>
    <!-- Logo, navegación principal -->
  </header>

  <nav>
    <!-- Links de navegación -->
  </nav>

  <main>
    <h1>Único H1 por página</h1>
    <article>
      <h2>Artículo 1</h2>
      <p>Contenido...</p>
    </article>
  </main>

  <aside>
    <!-- Contenido relacionado, sidebar -->
  </aside>

  <footer>
    <!-- Copyright, links legales -->
  </footer>
</body>
```

#### Formularios Accesibles

**Regla:** TODO `<input>` DEBE tener `<label>` ASOCIADO.

```html
<!-- ✅ GOOD: Label explícito con for/id -->
<label for="email">Email:</label>
<input type="email" id="email" name="email" required>

<!-- ❌ BAD: Sin label -->
<input type="email" placeholder="Email">
```

#### ARIA: "No ARIA is better than bad ARIA"

1. Preferir HTML5 nativo antes de ARIA
2. ARIA solo for componentes complejos (tabs, modales)
3. No redefinir semántica: `role="button"` en `<button>` es prohibido

#### Validatetion Accesible

```bash
[ ] HTML válido (W3C Validator)
[ ] Jerarquía de headings correcta (h1 → h2 → h3, sin saltos)
[ ] TODO <img> tiene alt descriptivo
[ ] TODO <input> tiene <label> asociado
[ ] Elementos interactivos accesibles por teclado (Tab)
[ ] Contraste ≥ 4.5:1 (WCAG AA)
[ ] Tested con NVDA/JAWS/VoiceOver
```

### file 2: CSS_ARCHITECTURE.md (947 líneas)

**Propósito:** Definir responsive design strategy and arquitectura CSS.

#### Filosofía Mobile-First

> **Escribe for móvil primero. Usa `@media (min-width: ...)` for expandir a desktop.**

```css
/* ✅ GOOD: Mobile-First */
body {
  font-size: 1rem;    /* Óptimo para móvil */
  padding: 1rem;
}

@media (min-width: 768px) {
  body {
    font-size: 1.25rem;  /* Expande para tablet+ */
    padding: 1.5rem;
  }
}

/* ❌ BAD: Desktop-First (Anti-pattern) */
body {
  font-size: 1.5rem;     /* Grande para desktop */
  padding: 2rem;
}

@media (max-width: 768px) {
  body {
    font-size: 1rem;     /* Reduce para móvil */
    padding: 1rem;
  }
}
```

#### Unidades Relativas (NO Absolutas)

**Regla:** Usa `rem` for tipografía (respeta preferencias de usuario).

```css
:root {
  font-size: 16px;  /* Base: 1rem = 16px */
}

body { font-size: 1rem; }      /* Escalable */
h1 { font-size: 2.5rem; }      /* 40px, escalable */
h2 { font-size: 1.75rem; }     /* 28px, escalable */

/* ❌ BAD: Hardcoded px */
body { font-size: 16px; }      /* Ignora preferencias */
h1 { font-size: 40px; }        /* No escalable */
```

#### Layouts Modernos

**CSS Grid** (2D layouts):
```css
.container {
  display: grid;
  grid-template-columns: 200px 1fr 250px;  /* Sidebar | Main | Aside */
  gap: 1rem;
}
```

**Flexbox** (1D layouts):
```css
.navbar {
  display: flex;
  justify-content: space-between;  /* Logo izquierda, links derecha */
  align-items: center;
}
```

**❌ PROHIBIDO: Floats for layout** (Deprecated)

#### CSS Variables for Theming

```css
:root {
  --color-primary: #6366f1;
  --color-secondary: #f97316;
  --spacing-md: 1rem;
  --font-family-sans: -apple-system, BlinkMacSystemFont, "Segoe UI", sans-serif;
}

/* Dark mode automático */
@media (prefers-color-scheme: dark) {
  :root {
    --bg-primary: #1a1a1a;
    --text-primary: white;
  }
}
```

#### Metodologías: Utility-First vs BEM

**Utility-First (Tailwind):** Fast, predecible
```html
<div class="bg-white rounded-lg shadow-md p-6 mb-4">
  <h2 class="text-2xl font-bold mb-3">Título</h2>
</div>
```

**BEM (Block-Element-Modifier):** Mantenible, explícito
```css
.card { }
.card__title { }
.card--featured { }
```

**SoftArchitect recomienda Híbrido:** Utility-first for basics, BEM for componentes custom.

#### Breakpoints Estándar

```css
--breakpoint-sm: 480px;   /* Móvil pequeño */
--breakpoint-md: 768px;   /* Tablet */
--breakpoint-lg: 1024px;  /* Desktop pequeño */
--breakpoint-xl: 1280px;  /* Desktop grande */
```

#### Validatetion CSS

```bash
[ ] Mobile-first: @media (min-width:), NO max-width
[ ] Tipografía: rem para fonts, NO px
[ ] Layouts: Grid (2D) o Flexbox (1D), NO floats
[ ] Variables CSS: Definidas y usadas consistentemente
[ ] Dark mode: @media (prefers-color-scheme: dark)
[ ] Contraste: ≥ 4.5:1 (WCAG AA)
[ ] Responsive: Testear en 480px, 768px, 1024px, 1280px
[ ] Performance: Minified, PurgeCSS si Tailwind
[ ] Focus visible: outline: 3px solid; en interactive elements
```

---

## Matriz de Impacto

### Por Stakeholder

| Rol | Impacto | Acción |
|:---|:---|:---|
| **Developdor** | Debe seguir OWASP, Git Conventions, TDD, HTML5/CSS | Leer todos 5 files, acatar las leyes |
| **Architect** | Validate que designs cumplan estándares web | Review HTML5_SEMANTICS + CSS_ARCHITECTURE |
| **QA/Testing** | TDD es obligatorio, testing pyramid es métrica | Enforcecer ≥80% coverage en PRs |
| **DevOps** | OWASP A05 (Security Misconfiguration) es crítica | Hardening Docker, RBAC, secrets management |
| **RAG Agent** | Validate cada commit/PR contra estas leyes | Rechaza violaciones de OWASP, Git Conventions, TDD |

### Por Contexto

| Contexto | file Relevante | Regla Clave |
|:---|:---|:---|
| **Backend Feature** | OWASP_TOP_10 + TDD_METHODOLOGY | Depends() injection mandatory, ≥80% test coverage |
| **Frontend Widget** | HTML5_SEMANTICS + CSS_ARCHITECTURE + TDD | Semantic HTML5, mobile-first CSS, tested |
| **PR Review** | GIT_CONVENTIONS + OWASP_TOP_10 | Conventional commit, no OWASP violations, LGTM |
| **Deployment** | OWASP_TOP_10 (DevOps section) | Non-root container, TLS 1.3, CORS restrictive |
| **Web Component** | HTML5_SEMANTICS + CSS_ARCHITECTURE | Semantic, accessible, responsive |

---

## Validatetion RAG

### Cómo el RAG Usa Estas Leyes

1. **Pre-Development Interview:**
   > "¿Estás planeando create un endpoint de autenticación? Recuerda: OWASP A07 (Authentication Failures). Usa Depends(get_current_user). Escribe tests primero (TDD)."

2. **Code Review Validatetion:**
   ```
   ❌ OWASP A03 Violation: Raw SQL detected
   ❌ Git Convention: Commit message must be Conventional (feat/fix/docs)
   ❌ TDD Failure: No tests for new business logic
   ❌ HTML5: Non-semantic <div onclick> instead of <button>
   ```

3. **Automatic Rejection:**
   ```bash
   # Si alguna regla se viola:
   git commit -m "fix: auth endpoint"
   git push origin feature/xyz
   # GitHub Action runs:
   #   1. Check OWASP (if backend) → FAIL
   #   2. Check Conventional Commits → PASS
   #   3. Check TDD Coverage → FAIL
   #   4. Block merge until fixed
   ```

### Pre-Merge Checklist (Automated)

```yaml
---
rule_set: CONSTITUTIONAL_LAW

checks:
  - owasp_validation:
      scope: backend
      severity: BLOCKER
      check: "No raw SQL, use SQLAlchemy ORM"

  - git_conventions:
      scope: all
      severity: BLOCKER
      check: "Commit message must be Conventional Commits"

  - tdd_validation:
      scope: all
      severity: BLOCKER
      check: "Coverage >= 80% (backend), >= 75% (frontend)"

  - html5_validation:
      scope: frontend_web
      severity: BLOCKER
      check: "No div onclick, use semantic HTML5"

  - css_validation:
      scope: frontend_web
      severity: BLOCKER
      check: "Mobile-first, @media min-width only"

auto_reject_on: ["owasp_validation", "tdd_validation", "git_conventions"]
```

---

## Estadísticas

### Accumulated PHASE 3

| Componente | Líneas | files | Commit |
|:---|---:|:---|:---|
| TRAMA 3.1 (Constitutional) | 2,075 | 3 | `5bca7ee` |
| - OWASP_TOP_10 | 789 | 1 | ✅ |
| - GIT_CONVENTIONS | 554 | 1 | ✅ |
| - TDD_METHODOLOGY | 732 | 1 | ✅ |
| TRAMA 3.2 (Web Standards) | 1,667 | 2 | `1fe12ea` |
| - HTML5_SEMANTICS | 720 | 1 | ✅ |
| - CSS_ARCHITECTURE | 947 | 1 | ✅ |
| **PHASE 3 TOTAL** | **3,742** | **5** | Both ✅ |

### Acumulado Todas las Phases

| Phase | Tramas | files | Líneas | Status |
|:---|---:|---:|---:|:---|
| Phase 1 (Foundation) | 1 | 4 | ~1,500 | ✅ |
| Phase 2 (Core Stack) | 3 | 12 | ~8,321 | ✅ |
| Phase 3 (Transversal Rules) | 2 | 5 | 3,742 | ✅ |
| **TOTAL** | **6** | **21** | **~13,563** | ✅ |

---

## Next Steps

### Corto Plazo (Semana 1)

1. ✅ Dogfooding validation: Validate `src/server/` and `src/client/` contra estas leyes
2. ⏳ RAG Integration: Cargar 5 files en ChromaDB for queries
3. ⏳ CI/CD Automation: Implement pre-merge checks en GitHub Actions

### Middleno Plazo (**PHASE 4)

**PHASE 4:** Ecosystem Expansion
- TRAMA 4.1: JavaScript/TypeScript Standards (Node.js, React)
- TRAMA 4.2: Data Layer Standards (SQL, NoSQL, API Design)
- TRAMA 4.3: Enterprise Patterns (Microservices, Event-Driven)

### Long Term (PHASE 5-6)

- PHASE 5: IA Engineering Standards (LLM Integration, RAG Patterns)
- PHASE 6: Production Governance (Incident Response, Monitoring, SLA)

---

## Conclusion

**PHASE 3 es el momento histórico donde SoftArchitect AI deja de ser un asistente "sugeridor" and se convierte en un "guardia de la ley".**

Con OWASP, Git Conventions, TDD, HTML5/CSS como ley constitucional:
- ✅ Cada línea de código que se escriba estará protegida
- ✅ Cada PR que se mergee habrá pasado validation universal
- ✅ Cada developer sabrá exactamente qué es "aceptable"

**Dogfooding:** SoftArchitect ahora sigue sus propias leyes. Si viola OWASP, su PRs se rechaza. Si ignora TDD, no mergea.

> "Ley for todos. Incluyéndote a ti, ArchitectZero."

---

**Fecha:** 30 de Enero de 2026
**Status:** ✅ **PHASE 3 COMPLETADA
**Commits:** `5bca7ee` + `1fe12ea`
**Responsable:** ArchitectZero AI Agent
