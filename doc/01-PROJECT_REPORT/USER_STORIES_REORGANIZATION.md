# 📋 USER STORIES REORGANIZATION - MVP v0.1.0 Extended

> **Fecha:** 09/02/2026
> **Estado:** ✅ COMPLETED
> **Issues Linear:** PIT-80 a PIT-96
> **Total HU Nuevas:** 17

---

## 📖 Tabla de Contenidos

1. [Resumen Ejecutivo](#1-resumen-ejecutivo)
2. [HU Nuevas Creadas](#2-hu-nuevas-creadas)
3. [Mapeo con USER_STORIES_MASTER.es.json](#3-mapeo-con-user_stories_masteresjson)
4. [Linear Issues Creadas](#4-linear-issues-creadas)
5. [Próximos Pasos](#5-próximos-pasos)

---

## 1. Resumen Ejecutivo

### 1.1 Cambios Realizados

Se han reorganizado y creado **17 nuevas HU** que cubren desde el estado actual (Sprint 3 - 60% completo) hasta el MVP v0.1.0 completo.

| Acción | Cantidad |
|--------|----------|
| **HU Creadas** | 17 (HU-3.6 a HU-7.3) |
| **TODOs Integrados** | 13 (3 código + 6 tests + 4 infra) |
| **Story Points Totales** | 85 pts |
| **Estimación Temporal** | 8-10 semanas |
| **Issues Linear** | PIT-80 a PIT-96 |

### 1.2 Distribución por Sprint

| Sprint | HUs | Puntos | Objetivo |
|--------|-----|--------|----------|
| **S3.6-S3.8** | 3 | 13 | Test Suite + Settings UI + Phase Logic |
| **S4.1-S4.3** | 3 | 18 | Backend Chat + RAG + Streaming |
| **S4.4-S4.5** | 2 | 10 | Error Handling + Optimization |
| **S5.1-S5.3** | 3 | 18 | Integration Tests + Security + Performance |
| **S6.1-S6.3** | 3 | 16 | Installer + Onboarding + Docs |
| **S7.1-S7.3** | 3 | 10 | CI/CD + Release Automation + MVP Launch |
| **TOTAL** | **17** | **85** | **MVP v0.1.0 Complete** |

---

## 2. HU Nuevas Creadas

### Sprint 3 Extended - Completar Funcionalidades Base

#### HU-3.6: Test Suite Completion & SQLite Persistence Fix 🔴
- **Issue:** [PIT-80](https://linear.app/pitcherdev/issue/PIT-80)
- **Puntos:** 5 (M)
- **Branch:** `fix/test-suite-completion`
- **TODOs:**
  - T-1: Fix 6 failing SQLite persistence tests
  - TODO-1: Update last opened timestamp
  - I-3: Setup database migrations for tests
- **Objetivo:** Elevar cobertura ProjectShell de 70% a >85%

#### HU-3.7: Settings UI Completion & Widget Tests 🟡
- **Issue:** [PIT-81](https://linear.app/pitcherdev/issue/PIT-81)
- **Puntos:** 5 (M)
- **Branch:** `feature/settings-ui-completion`
- **TODOs:**
  - T-2: Fix 10 failing MarkdownPreview tests
  - T-3: Create 7 Settings UI widget tests
  - T-4: Create GlobalSearchDialog widget test
  - TODO-2: Implement file_picker
- **Objetivo:** Elevar cobertura Settings de 85% a >90%

#### HU-3.8: Project Phase Logic & Progress Tracking 🟡
- **Issue:** [PIT-82](https://linear.app/pitcherdev/issue/PIT-82)
- **Puntos:** 3 (S)
- **Branch:** `feature/project-phase-logic`
- **TODOs:**
  - TODO-3: Implement real phase logic
- **Objetivo:** Progress bar (Doc N/25) dinámico

---

### Sprint 4 - Backend Integration & RAG Orchestration

#### HU-4.1: Backend Chat Endpoint & RAG Orchestration 🔴
- **Issue:** [PIT-83](https://linear.app/pitcherdev/issue/PIT-83)
- **Puntos:** 8 (L)
- **Branch:** `feature/backend-chat-endpoint`
- **Objetivo:** POST /chat/message con RAG integrado

#### HU-4.2: Conversation History & Persistence 🟡
- **Issue:** [PIT-84](https://linear.app/pitcherdev/issue/PIT-84)
- **Puntos:** 5 (M)
- **Branch:** `feature/backend-conversation-history`
- **Objetivo:** SQLite backend storage, context window

#### HU-4.3: Server-Sent Events (SSE) Streaming 🔴
- **Issue:** [PIT-85](https://linear.app/pitcherdev/issue/PIT-85)
- **Puntos:** 5 (M)
- **Branch:** `feature/backend-sse-streaming`
- **Objetivo:** Streaming token-by-token <200ms TTF

---

### Sprint 4 Extended - Error Handling & Optimization

#### HU-4.4: Error Handling & Validation Gates 🟡
- **Issue:** [PIT-89](https://linear.app/pitcherdev/issue/PIT-89)
- **Puntos:** 5 (M)
- **Branch:** `feature/error-handling-gates`
- **Objetivo:** Retry logic, fallbacks, error snackbars

#### HU-4.5: Streaming Optimization & Caching 🟡
- **Issue:** [PIT-88](https://linear.app/pitcherdev/issue/PIT-88)
- **Puntos:** 5 (M)
- **Branch:** `feature/streaming-optimization`
- **Objetivo:** Latencia P95 <200ms, cache embeddings

---

### Sprint 5 - Integration Tests & Cleanup

#### HU-5.1: Integration Tests Suite Rewrite 🟡
- **Issue:** [PIT-86](https://linear.app/pitcherdev/issue/PIT-86)
- **Puntos:** 5 (M)
- **Branch:** `chore/integration-tests-rewrite`
- **TODOs:**
  - T-5: Rewrite 3 .skip integration tests
  - T-6: Remove 5 deprecated widget tests
- **Objetivo:** Integration tests >85%, no .skip files

#### HU-5.2: Security Hardening & OWASP Compliance 🔴
- **Issue:** [PIT-87](https://linear.app/pitcherdev/issue/PIT-87)
- **Puntos:** 8 (L)
- **Branch:** `security/owasp-compliance`
- **Objetivo:** OWASP Top 10 audit, no vulnerabilities críticas

#### HU-5.3: Performance Profiling & Optimization 🟡
- **Issue:** [PIT-90](https://linear.app/pitcherdev/issue/PIT-90)
- **Puntos:** 5 (M)
- **Branch:** `perf/profiling-optimization`
- **Objetivo:** APM setup, latencias P50/P95/P99

---

### Sprint 6 - Packaging & Distribution

#### HU-6.1: Linux Installer (.deb) & Desktop Integration 🔴
- **Issue:** [PIT-92](https://linear.app/pitcherdev/issue/PIT-92)
- **Puntos:** 8 (L)
- **Branch:** `release/linux-installer`
- **Objetivo:** .deb package, desktop entry, icon integration

#### HU-6.2: User Onboarding Flow & First-Run Experience 🟡
- **Issue:** [PIT-95](https://linear.app/pitcherdev/issue/PIT-95)
- **Puntos:** 5 (M)
- **Branch:** `feature/onboarding-wizard`
- **Objetivo:** Wizard 4 pasos (Welcome → LLM → Path → Verify)

#### HU-6.3: Documentation Portal & User Guide 🟡
- **Issue:** [PIT-94](https://linear.app/pitcherdev/issue/PIT-94)
- **Puntos:** 3 (S)
- **Branch:** `docs/user-guide`
- **TODOs:**
  - I-4: Document test execution & coverage
- **Objetivo:** User Guide completo, troubleshooting section

---

### Sprint 7 - CI/CD & Release Management

#### HU-7.1: GitHub Actions Workflows & Automated Testing 🔴
- **Issue:** [PIT-91](https://linear.app/pitcherdev/issue/PIT-91)
- **Puntos:** 5 (M)
- **Branch:** `ci/github-actions-pipeline`
- **TODOs:**
  - I-1: Setup CI/CD GitHub Actions pipeline
  - I-2: Generate coverage reports in CI
- **Objetivo:** Pipeline CI completo (Backend + Frontend)

#### HU-7.2: Release Automation & Versioning 🟡
- **Issue:** [PIT-96](https://linear.app/pitcherdev/issue/PIT-96)
- **Puntos:** 3 (S)
- **Branch:** `ci/release-automation`
- **Objetivo:** Semantic versioning, changelog auto-generado

#### HU-7.3: MVP v0.1.0 Release 🎯
- **Issue:** [PIT-93](https://linear.app/pitcherdev/issue/PIT-93)
- **Puntos:** 2 (XS)
- **Branch:** `release/v0.1.0`
- **Objetivo:** Release oficial al público

---

## 3. Mapeo con USER_STORIES_MASTER.es.json

### HU Originales vs Reorganizadas

| HU Original | Estado | HU Reorganizadas | Justificación |
|-------------|--------|------------------|---------------|
| **HU-3.4** (Error Handling Gates) | ❌ Pendiente | → **HU-4.4** | Mejor contexto post-backend integration |
| **HU-3.5** (Streaming Optimization) | ❌ Pendiente | → **HU-4.5** | Depende de HU-4.3 (SSE Streaming) |
| N/A | N/A | **HU-3.6** ✨ NEW | TODOs T-1, TODO-1, I-3 integrados |
| N/A | N/A | **HU-3.7** ✨ NEW | TODOs T-2, T-3, T-4, TODO-2 integrados |
| N/A | N/A | **HU-3.8** ✨ NEW | TODO-3 integrado |
| **HU-4.1** (Backend Chat) | ❌ Pendiente | ✅ **HU-4.1** | Sin cambios, mantener original |
| **HU-4.2** (Conversation History) | ❌ Pendiente | ✅ **HU-4.2** | Sin cambios, mantener original |
| **HU-4.3** (Backend Streaming) | ❌ Pendiente | → **HU-4.3** | Renombrado a "SSE Streaming" (más claro) |
| **HU-5.1** (Remove Temp Endpoints) | ❌ Pendiente | → **HU-5.1** (NEW) | Reemplazado por "Integration Tests Rewrite" (mayor prioridad) |
| **HU-5.2** (Security Hardening) | ❌ Pendiente | ✅ **HU-5.2** | Sin cambios, mantener original |
| **HU-5.3** (Performance Profiling) | ❌ Pendiente | ✅ **HU-5.3** | Sin cambios, mantener original |
| **HU-6.1** (Linux Installer) | ❌ Pendiente | ✅ **HU-6.1** | Ampliado con desktop integration |
| **HU-6.2** (Onboarding Flow) | ❌ Pendiente | ✅ **HU-6.2** | Sin cambios, mantener original |
| **HU-6.3** (Documentation Portal) | ❌ Pendiente | ✅ **HU-6.3** | TODO I-4 integrado |
| **HU-7.1** (GitHub Actions) | ❌ Pendiente | ✅ **HU-7.1** | TODOs I-1, I-2 integrados |
| **HU-7.2** (Release v0.1.0) | ❌ Pendiente | → **HU-7.2** (Automation) + **HU-7.3** (Release) | Dividido en 2 HU más específicas |

### Cambios Clave

1. **3 HU Nuevas Añadidas (S3.6-S3.8):** Para completar el Sprint 3 con TODOs integrados
2. **HU-3.4/3.5 Movidas a S4:** Mejor contexto después de backend integration
3. **HU-5.1 Reemplazada:** Integration Tests Rewrite tiene mayor prioridad que Remove Temp Endpoints
4. **HU-7.2 Dividida:** Automation (HU-7.2) + Release (HU-7.3) para mayor claridad

---

## 4. Linear Issues Creadas

### Issues Creadas (17 total)

| Issue | HU | Título | Estimación | Prioridad | URL |
|-------|----|--------|------------|-----------|-----|
| **PIT-80** | HU-3.6 | Test Suite Completion & SQLite Fix | 5 pts | 🔴 Urgent | [Ver](https://linear.app/pitcherdev/issue/PIT-80) |
| **PIT-81** | HU-3.7 | Settings UI Completion & Widget Tests | 5 pts | 🟡 High | [Ver](https://linear.app/pitcherdev/issue/PIT-81) |
| **PIT-82** | HU-3.8 | Project Phase Logic & Progress Tracking | 3 pts | 🟡 High | [Ver](https://linear.app/pitcherdev/issue/PIT-82) |
| **PIT-83** | HU-4.1 | Backend Chat Endpoint & RAG Orchestration | 8 pts | 🔴 Urgent | [Ver](https://linear.app/pitcherdev/issue/PIT-83) |
| **PIT-84** | HU-4.2 | Conversation History & Persistence | 5 pts | 🟡 High | [Ver](https://linear.app/pitcherdev/issue/PIT-84) |
| **PIT-85** | HU-4.3 | Server-Sent Events (SSE) Streaming | 5 pts | 🔴 Urgent | [Ver](https://linear.app/pitcherdev/issue/PIT-85) |
| **PIT-89** | HU-4.4 | Error Handling & Validation Gates | 5 pts | 🟡 High | [Ver](https://linear.app/pitcherdev/issue/PIT-89) |
| **PIT-88** | HU-4.5 | Streaming Optimization & Caching | 5 pts | 🟡 High | [Ver](https://linear.app/pitcherdev/issue/PIT-88) |
| **PIT-86** | HU-5.1 | Integration Tests Suite Rewrite | 5 pts | 🟡 High | [Ver](https://linear.app/pitcherdev/issue/PIT-86) |
| **PIT-87** | HU-5.2 | Security Hardening & OWASP Compliance | 8 pts | 🟡 High | [Ver](https://linear.app/pitcherdev/issue/PIT-87) |
| **PIT-90** | HU-5.3 | Performance Profiling & Optimization | 5 pts | 🟡 High | [Ver](https://linear.app/pitcherdev/issue/PIT-90) |
| **PIT-92** | HU-6.1 | Linux Installer (.deb) & Desktop Integration | 8 pts | 🟡 High | [Ver](https://linear.app/pitcherdev/issue/PIT-92) |
| **PIT-95** | HU-6.2 | User Onboarding Flow & First-Run Experience | 5 pts | 🟡 High | [Ver](https://linear.app/pitcherdev/issue/PIT-95) |
| **PIT-94** | HU-6.3 | Documentation Portal & User Guide | 3 pts | 🟡 High | [Ver](https://linear.app/pitcherdev/issue/PIT-94) |
| **PIT-91** | HU-7.1 | GitHub Actions Workflows & Automated Testing | 5 pts | 🔴 Urgent | [Ver](https://linear.app/pitcherdev/issue/PIT-91) |
| **PIT-96** | HU-7.2 | Release Automation & Versioning | 3 pts | 🟡 High | [Ver](https://linear.app/pitcherdev/issue/PIT-96) |
| **PIT-93** | HU-7.3 | MVP v0.1.0 Release | 2 pts | 🔴 Urgent | [Ver](https://linear.app/pitcherdev/issue/PIT-93) |

### Estadísticas

```
Total Issues: 17
Total Story Points: 85
Prioridad Urgent (🔴): 5 issues (29%)
Prioridad High (🟡): 12 issues (71%)

Distribución por Tamaño:
- XS (2 pts): 1 issue
- S (3 pts): 3 issues
- M (5 pts): 9 issues
- L (8 pts): 4 issues
```

---

## 5. Próximos Pasos

### 5.1 Acciones Inmediatas

1. **Semana 1-2 (Actual):** Trabajar en HU-3.6 (PIT-80)
   - Fix 6 SQLite tests
   - Implementar timestamp auto-update
   - Setup database migrations

2. **Revisar Issues en Linear:** Asignar a desarrolladores
   - PIT-80 → Backend/Database specialist
   - PIT-81 → Frontend/Flutter specialist
   - PIT-82 → Frontend/Logic specialist

3. **Actualizar Kanban Board:**
   - Mover PIT-80, PIT-81, PIT-82 a "Ready for Dev"
   - Mantener PIT-83+ en "Backlog"

### 5.2 Roadmap Visual

```
┌──────────────────────────────────────────────────────────┐
│ ROADMAP HACIA MVP v0.1.0                                 │
├──────────────────────────────────────────────────────────┤
│ [====✓====][====✓====][====✓====][====>    ][         ] │
│   S1-S2      HU-3.1     HU-3.2     HU-3.3    HU-3.6+     │
│  100% ✅    100% ✅     100% ✅     100% ✅    0% ⏳       │
│                                                           │
│ ACTUAL: Sprint 3 Extended (60% completo)                 │
│ SIGUIENTE: HU-3.6 Test Suite Completion                  │
│ META: MVP v0.1.0 en 8-10 semanas                         │
└──────────────────────────────────────────────────────────┘
```

### 5.3 Criterios de Éxito

| Milestone | Criterio | Target | Status |
|-----------|----------|--------|--------|
| **Sprint 3 Complete** | Tests >95%, Cobertura >85% | S3.6-S3.8 done | ⏳ In Progress |
| **Sprint 4 Complete** | Backend Chat funcional + RAG + SSE | S4.1-S4.5 done | ⏳ Pending |
| **Sprint 5 Complete** | Tests >95%, Security audit passed | S5.1-S5.3 done | ⏳ Pending |
| **Sprint 6 Complete** | Linux .deb installer tested | S6.1-S6.3 done | ⏳ Pending |
| **Sprint 7 Complete** | CI/CD green, MVP v0.1.0 released | S7.1-S7.3 done | ⏳ Pending |

---

## 📊 Resumen Ejecutivo Final

### ✅ Completado

- ✅ **17 HU** creadas y documentadas en Linear (PIT-80 a PIT-96)
- ✅ **13 TODOs** integrados en las nuevas HU
- ✅ Documento de análisis completo (HU_REORGANIZATION_ANALYSIS.md)
- ✅ Roadmap reorganizado con timeline de 8-10 semanas
- ✅ Prioridades definidas por Sprint

### ⏳ Próximos Pasos

1. **Semana 1:** Comenzar HU-3.6 (PIT-80) - Test Suite Completion
2. **Semana 2:** Completar HU-3.7 y HU-3.8
3. **Semana 3-4:** Sprint 4 Backend (HU-4.1-4.3)
4. **Semana 5-10:** Sprints 5-7 (Security, Packaging, CI/CD, Release)

### 🎯 Meta MVP

**MVP v0.1.0 Release:** Semana 10 (Finales de Abril 2026)

---

**Documento generado:** 09/02/2026
**Última actualización:** 09/02/2026
**Versión:** v1.0
**Estado:** ✅ COMPLETE
