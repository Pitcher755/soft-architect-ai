# 📋 Análisis y Reorganización de Historias de Usuario (HU) - Hacia MVP v0.1.0

> **Fecha:** 09/02/2026
> **Estado:** ✅ ANÁLISIS COMPLETO
> **Branch:** `feature/chat-sequential-docs`
> **Objetivo:** Reorganizar HU desde estado actual hasta alcanzar MVP

---

## 📖 Tabla de Contenidos

1. [Estado Actual del Proyecto](#1-estado-actual-del-proyecto)
2. [HU Completadas](#2-hu-completadas)
3. [HU Pendientes (Originales)](#3-hu-pendientes-originales)
4. [TODOs Identificados](#4-todos-identificados)
5. [Gaps de Cobertura](#5-gaps-de-cobertura)
6. [Nuevas HU Propuestas](#6-nuevas-hu-propuestas)
7. [Roadmap Reorganizado](#7-roadmap-reorganizado)
8. [Criterios de MVP](#8-criterios-de-mvp)

---

## 1. Estado Actual del Proyecto

### 1.1 Métricas Generales

| Métrica | Valor | Target | Estado |
|---------|-------|--------|--------|
| **Pruebas Pasando** | 312/335 (93.1%) | >90% | ✅ |
| **Cobertura Código** | 82-85% | >80% | ✅ |
| **Warnings Críticos** | 0 | 0 | ✅ |
| **Type Safety** | 0 errors | 0 | ✅ |
| **CI/CD Ready** | YES | YES | ✅ |

### 1.2 Funcionalidades Implementadas

| Feature | Estado | Cobertura | Archivos |
|---------|--------|-----------|----------|
| **Proyecto Shell UI** | ✅ Completo | 95% | 25+ |
| **ArchivoSystem Service** | ✅ Completo | 90% | 15+ |
| **Chat UI Components** | ✅ Completo | 100% | 8+ |
| **Chat Sequential Logic** | ✅ Completo | 100% | 5+ |
| **Settings UI** | ⚠️ Parcial | 85% | 8+ |
| **RAG Ingestion** | ✅ Completo | 100% | Python |
| **Vector Store** | ✅ Completo | 100% | Python |

---

## 2. HU Completadas

### Sprint 1: Infraestructura ✅

| HU | Nombre | Estado | Evidencia |
|----|--------|--------|-----------|
| **HU-1.1** | Docker Setup | ✅ COMPLETO | docker-compose.yml, scripts/start_stack.sh |
| **HU-1.2** | Backend Skeleton | ✅ COMPLETO | src/server/, FastAPI estructura |

### Sprint 2: RAG Brain ✅

| HU | Nombre | Estado | Evidencia |
|----|--------|--------|-----------|
| **HU-2.0** | Knowledge Base Population | ✅ COMPLETO | packages/knowledge_base/ (29 archivos, 934 lines) |
| **HU-2.1** | RAG Ingestion Loader | ✅ COMPLETO | services/rag/, pruebas passing 100% |
| **HU-2.2** | RAG Vectorization | ✅ COMPLETO | ChromaDB integration, vector store |

### Sprint 3: Proyecto-First (Parcialmente Completo) ⚠️

| HU | Nombre | Estado | Cobertura | Branch |
|----|--------|--------|-----------|--------|
| **HU-3.1** | Proyecto Shell UI | ✅ COMPLETO | 95% | feature/ui-proyecto-shell (merged) |
| **HU-3.2** | ArchivoSystem Service | ✅ COMPLETO | 90% | feature/client-archivosystem-service (merged) |
| **HU-3.3** | Chat Sequential Docs | ✅ COMPLETO | 100% | feature/chat-sequential-docs (current) |
| **HU-3.4** | Error Handling Gates | ❌ PENDIENTE | 0% | N/A |
| **HU-3.5** | Streaming Optimization | ❌ PENDIENTE | 0% | N/A |

---

## 3. HU Pendientes (Originales)

### Sprint 3 - Restantes

| HU | Nombre | Puntos | Estado | Bloqueantes |
|----|--------|--------|--------|-------------|
| **HU-3.4** | Error Handling & Validation Gates | 5 | ⏳ TODO | Ninguno |
| **HU-3.5** | Streaming & Performance Optimization | 8 | ⏳ TODO | HU-3.4 (opcional) |

### Sprint 4: Backend Chat & RAG Integración

| HU | Nombre | Puntos | Estado | Bloqueantes |
|----|--------|--------|--------|-------------|
| **HU-4.1** | Backend Chat Endpoint | 8 | ⏳ TODO | HU-2.2 ✅ |
| **HU-4.2** | Conversation History | 5 | ⏳ TODO | HU-4.1 |
| **HU-4.3** | Backend Streaming | 5 | ⏳ TODO | HU-4.1 |

### Sprint 5: Cleanup & Polish

| HU | Nombre | Puntos | Estado | Bloqueantes |
|----|--------|--------|--------|-------------|
| **HU-5.1** | Remove Temporary Endpoints | 2 | ⏳ TODO | HU-4.1 |
| **HU-5.2** | Security Hardening | 8 | ⏳ TODO | All anterior |
| **HU-5.3** | Performance Profiling | 5 | ⏳ TODO | HU-3.5 |

### Sprint 6: Packaging & Distribution

| HU | Nombre | Puntos | Estado | Bloqueantes |
|----|--------|--------|--------|-------------|
| **HU-6.1** | Linux Installer (.deb) | 8 | ⏳ TODO | All anterior |
| **HU-6.2** | User Onboarding Flow | 5 | ⏳ TODO | HU-6.1 |
| **HU-6.3** | Documentoation Portal | 3 | ⏳ TODO | None |

### Sprint 7: CI/CD & Release Management

| HU | Nombre | Puntos | Estado | Bloqueantes |
|----|--------|--------|--------|-------------|
| **HU-7.1** | GitHub Actions Workflows | 5 | ⏳ TODO | None |
| **HU-7.2** | Automated Pruebaing Pipeline | 3 | ⏳ TODO | HU-7.1 |
| **HU-7.3** | Release v0.1.0 | 2 | ⏳ TODO | All anterior |

---

## 4. TODOs Identificados

### 4.1 TODOs en Código (3 items)

| ID | Archivo | Línea | Descripción | Prioridad | Sprint |
|----|---------|-------|-------------|-----------|--------|
| **TODO-1** | proyecto_shell_notifier.dart | 70 | Update last opened timestamp | 🔴 HIGH | S3.6 |
| **TODO-2** | storage_section.dart | 68 | Implement archivo_picker | 🟡 MEDIUM | S3.7 |
| **TODO-3** | proyecto_fase_service.dart | 19 | Implement real fase logic | 🟡 MEDIUM | S3.8 |

### 4.2 TODOs de Pruebas (6 items)

| ID | Tipo | Descripción | Prioridad | Sprint |
|----|------|-------------|-----------|--------|
| **T-1** | Fix | Fix 6 failing SQLite persistence pruebas | 🔴 HIGH | S3.6 |
| **T-2** | Fix | Fix 10 failing MarkdownPreview pruebas | 🔴 HIGH | S3.7 |
| **T-3** | Crear | Crear 7 Settings UI widget pruebas | 🟡 MEDIUM | S3.8 |
| **T-4** | Crear | Crear GlobalSearchDialog widget prueba | 🟡 MEDIUM | S3.8 |
| **T-5** | Rewrite | Rewrite 3 .skip integration pruebas | 🟢 LOW | S4.x |
| **T-6** | Cleanup | Remove 5 deprecated widget pruebas (.skip) | 🟢 LOW | S5.x |

### 4.3 TODOs de Infraestructura (4 items)

| ID | Descripción | Prioridad | Sprint |
|----|-------------|-----------|--------|
| **I-1** | Setup CI/CD GitHub Actions pipeline | 🔴 HIGH | S7.1 |
| **I-2** | Generate coverage reports in CI | 🟡 MEDIUM | S7.2 |
| **I-3** | Setup database migrations for pruebas | 🟡 MEDIUM | S3.6 |
| **I-4** | Documento prueba execution & coverage | 🟢 LOW | S6.3 |

---

## 5. Gaps de Cobertura

### 5.1 Cobertura por Módulo (Amber Estado)

| Módulo | Actual | Target | Gap | Acción |
|--------|--------|--------|-----|--------|
| **Settings** | 85% | >90% | -5% | T-3: Crear 7 widget pruebas |
| **Proyecto Shell** | 70% | >85% | -15% | T-1: Fix SQLite pruebas + T-5: Integración pruebas |
| **Infraestructura** | 70% | >80% | -10% | I-3: Database migrations |

### 5.2 Gaps Funcionales

| Feature | Implementado | Faltante | HU Requerida |
|---------|--------------|----------|--------------|
| **Backend Chat Integración** | 0% | POST /chat/message | HU-4.1 ✨ |
| **RAG Orchestration** | 0% | Template selection + context injection | HU-4.1 ✨ |
| **Streaming SSE** | 0% | Token-by-token streaming | HU-4.3 ✨ |
| **Error Handling** | 30% | Retry logic, fallbacks, validation gates | HU-3.4 ✨ |
| **Performance Optimization** | 40% | Caching, lazy loading, profiling | HU-3.5 ✨ |

---

## 6. Nuevas HU Propuestas

### 6.1 Sprint 3 Extended - Completar Funcionalidades Base

#### HU-3.6: Prueba Suite Completion & SQLite Persistence Fix 🔴 HIGH

**Objetivo:** Elevar cobertura de pruebas a >90% y resolver 6 pruebas fallando en SQLite.

| Campo | Valor |
|-------|-------|
| **Prioridad** | Critical |
| **Estimación** | M (5 pts) |
| **Branch** | `fix/prueba-suite-completion` |
| **Dependencias** | HU-3.1 (ProyectoShell) |

**TODOs Incluidos:**
- T-1: Fix 6 failing SQLite persistence pruebas
- TODO-1: Update last opened timestamp
- I-3: Setup database migrations for pruebas

**Criterios de Aceptación:**
- ✅ 6 SQLite pruebas passing (ProyectoShell persistence)
- ✅ Timestamp auto-update en proyectoshell_notifier.dart implementado
- ✅ Database migrations setup para pruebas
- ✅ Cobertura ProyectoShell >85%

---

#### HU-3.7: Settings UI Completion & Widget Pruebas 🟡 MEDIUM

**Objetivo:** Completar UI de Settings y elevar cobertura a >90%.

| Campo | Valor |
|-------|-------|
| **Prioridad** | High |
| **Estimación** | M (5 pts) |
| **Branch** | `feature/settings-ui-completion` |
| **Dependencias** | Ninguna |

**TODOs Incluidos:**
- T-2: Fix 10 failing MarkdownPreview widget/integration pruebas
- T-3: Crear 7 Settings UI widget pruebas
- T-4: Crear GlobalSearchDialog widget prueba
- TODO-2: Implement archivo_picker in storage_section.dart

**Criterios de Aceptación:**
- ✅ archivo_picker package integrado (selector de carpetas nativo)
- ✅ 10 MarkdownPreview pruebas refactorizados y passing
- ✅ 7 Settings UI widget pruebas creados (appearance, storage, about)
- ✅ GlobalSearchDialog widget prueba creado
- ✅ Cobertura Settings >90%

---

#### HU-3.8: Proyecto Fase Logic & Progress Tracking 🟡 MEDIUM

**Objetivo:** Implementar lógica real de fases de proyecto (Doc N/25 progress).

| Campo | Valor |
|-------|-------|
| **Prioridad** | Medium |
| **Estimación** | S (3 pts) |
| **Branch** | `feature/proyecto-fase-logic` |
| **Dependencias** | HU-3.1, HU-3.2 |

**TODOs Incluidos:**
- TODO-3: Implement real fase logic in proyecto_fase_service.dart

**Criterios de Aceptación:**
- ✅ ProyectoFaseService detecta fase actual (0-6) basado en archivos context/
- ✅ Progress bar (Doc N/25) actualiza dinámicamente
- ✅ Pruebas unitarios para fase detection (>90%)
- ✅ Integración con ProyectoShell dashboard

---

### 6.2 Sprint 4 - Backend Integración & RAG Orchestration

#### HU-4.1: Backend Chat Endpoint & RAG Orchestration 🔴 CRITICAL

**Objetivo:** Implementar endpoint POST /api/v1/chat/message con RAG integrado.

| Campo | Valor |
|-------|-------|
| **Prioridad** | Critical |
| **Estimación** | L (8 pts) |
| **Branch** | `feature/backend-chat-endpoint` |
| **Dependencias** | HU-2.2 (RAG Vectorization) ✅ |

**Funcionalidades:**
- Endpoint POST /chat/message acepta {conversation_id, message, proyecto_id}
- RAG Orchestrator selecciona templates basado en fase actual
- Context injection: template + user input + RAG knowledge
- LLM call (Ollama local / Groq cloud)
- Response con {ai_response, template_used, sources}

**Criterios de Aceptación:**
- ✅ POST /chat/message responde <500ms (sin streaming)
- ✅ RAG busca en ChromaDB knowledge base relevante
- ✅ Template selection automático basado en proyecto fase
- ✅ Pruebas unitarios: RAG orchestrator, template loader (>85%)
- ✅ Pruebas integración: Endpoint E2E (>80%)

---

#### HU-4.2: Conversation History & Persistence 🟡 HIGH

**Objetivo:** Almacenar historial de conversaciones para contexto multi-turn.

| Campo | Valor |
|-------|-------|
| **Prioridad** | High |
| **Estimación** | M (5 pts) |
| **Branch** | `feature/backend-conversation-history` |
| **Dependencias** | HU-4.1 |

**Funcionalidades:**
- SQLite backend storage (conversations table)
- GET /conversations/{id} devuelve historial completo
- Contexto anterior se pasa al LLM (últimos 10 mensajes)
- Auto-cleanup de conversaciones >30 días

**Criterios de Aceptación:**
- ✅ SQLite schema: conversations (id, proyecto_id, messages[])
- ✅ GET /conversations/{id} devuelve historial paginado
- ✅ Context window: últimos 10 mensajes para LLM
- ✅ Pruebas: persistence, retrieval, cleanup (>85%)

---

#### HU-4.3: Server-Sent Events (SSE) Streaming 🔴 CRITICAL

**Objetivo:** Implementar streaming token-by-token para latencia <200ms.

| Campo | Valor |
|-------|-------|
| **Prioridad** | Critical |
| **Estimación** | M (5 pts) |
| **Branch** | `feature/backend-sse-streaming` |
| **Dependencias** | HU-4.1 |

**Funcionalidades:**
- Endpoint POST /chat/stream (SSE)
- Generator function conectado a LLM output
- Token buffering (50ms batches)
- Client-side EventSource integration (Flutter)

**Criterios de Aceptación:**
- ✅ SSE streaming funcional <200ms TTF
- ✅ Tokens enviados en batches de 50ms
- ✅ Flutter EventSource listener implementado
- ✅ Manejo de conexión perdida (auto-retry)
- ✅ Pruebas: streaming, timeout, reconnect (>80%)

---

### 6.3 Sprint 4 Extended - Error Handling & Optimization

#### HU-4.4: Error Handling & Validation Gates 🔴 HIGH

**Objetivo:** Implementar retry logic, fallbacks y validation gates robustos.

| Campo | Valor |
|-------|-------|
| **Prioridad** | High |
| **Estimación** | M (5 pts) |
| **Branch** | `feature/error-handling-gates` |
| **Dependencias** | HU-4.1, HU-4.3 |

**Funcionalidades:**
- Decorador @retry_with_backoff (Python) para RAG calls
- Fallback logic: Si RAG falla 3x → template placeholder
- Error snackbar widget (Flutter) con mensajes amigables
- Logging en context/.error.log

**Criterios de Aceptación:**
- ✅ RAG timeout (>30s): retry 3x con backoff (1s, 2s, 4s)
- ✅ Errores mapeados a mensajes en español (NO stack traces)
- ✅ Snackbar crítico: sin autohide, botón 'Cerrar' manual
- ✅ Fallback: template placeholder si RAG falla
- ✅ Pruebas: timeout simulation, retry logic, error mapping (>90%)

---

#### HU-4.5: Streaming Optimization & Caching 🟡 MEDIUM

**Objetivo:** Optimizar latencia P95 <200ms y cache de embeddings.

| Campo | Valor |
|-------|-------|
| **Prioridad** | Medium |
| **Estimación** | M (5 pts) |
| **Branch** | `feature/streaming-optimization` |
| **Dependencias** | HU-4.3 |

**Funcionalidades:**
- Cache de embeddings en ChromaDB (Redis opcional)
- Gzip compression en respuestas HTTP
- Profiling con OpenTelemetry (APM)
- Lazy loading de widgets pesados (Flutter)

**Criterios de Aceptación:**
- ✅ Latencia P95 <200ms (medido con APM)
- ✅ Cache hit rate >70% (embeddings frecuentes)
- ✅ Gzip compression activo en FastAPI
- ✅ UI no se congela durante generación (async rendering)
- ✅ Pruebas: cache logic, compression, latency benchmarks (>80%)

---

### 6.4 Sprint 5 - Integración Pruebas & Cleanup

#### HU-5.1: Integración Pruebas Suite Rewrite 🟡 MEDIUM

**Objetivo:** Reescribir integration pruebas obsoletos y eliminar .skip archivos.

| Campo | Valor |
|-------|-------|
| **Prioridad** | Medium |
| **Estimación** | M (5 pts) |
| **Branch** | `chore/integration-pruebas-rewrite` |
| **Dependencias** | HU-3.8, HU-4.1 |

**TODOs Incluidos:**
- T-5: Rewrite 3 .skip integration pruebas
- T-6: Remove 5 deprecated widget pruebas (.skip)

**Criterios de Aceptación:**
- ✅ 3 integration pruebas reescritos (ProyectoShell flow, Chat E2E, Settings)
- ✅ 5 deprecated widget pruebas eliminados
- ✅ Integración pruebas >85% passing
- ✅ No .skip archivos en prueba/

---

#### HU-5.2: Security Hardening & OWASP Compliance 🔴 HIGH

**Objetivo:** Auditoría de seguridad completa y remediación de vulnerabilidades.

| Campo | Valor |
|-------|-------|
| **Prioridad** | High |
| **Estimación** | L (8 pts) |
| **Branch** | `security/owasp-compliance` |
| **Dependencias** | HU-4.1, HU-4.2 |

**Funcionalidades:**
- OWASP Top 10 audit (SQL injection, XSS, CSRF)
- Secrets management (.env variables, rotation)
- API rate limiting (FastAPI middleware)
- Input sanitization (prompt injection prevention)
- Security headers (CORS, CSP, X-Frame-Options)

**Criterios de Aceptación:**
- ✅ No vulnerabilidades críticas (bandit, safety scan)
- ✅ API rate limiting: 100 req/min per IP
- ✅ Input sanitization: prompts max 5000 chars
- ✅ Security headers configurados
- ✅ Pruebas: injection attacks, rate limit, sanitization (>85%)

---

#### HU-5.3: Performance Profiling & Optimization 🟡 MEDIUM

**Objetivo:** Profiling completo y optimización de cuellos de botella.

| Campo | Valor |
|-------|-------|
| **Prioridad** | Medium |
| **Estimación** | M (5 pts) |
| **Branch** | `perf/profiling-optimization` |
| **Dependencias** | HU-4.5 |

**Funcionalidades:**
- OpenTelemetry APM setup (traces, metrics)
- Flutter DevTools profiling (CPU, memory)
- Database query optimization (indexes, batch queries)
- Widget tree optimization (const constructors, memo)

**Criterios de Aceptación:**
- ✅ APM dashboard con latencias P50/P95/P99
- ✅ Queries SQLite <50ms (indexes añadidos)
- ✅ Widget rebuilds reducidos >30% (profiling)
- ✅ Memory leaks identificados y corregidos
- ✅ Pruebas: performance benchmarks (baseline vs optimized)

---

### 6.5 Sprint 6 - Packaging & Distribution

#### HU-6.1: Linux Installer (.deb) & Desktop Integración 🔴 HIGH

**Objetivo:** Empaquetado .deb para distribución en Ubuntu/Debian.

| Campo | Valor |
|-------|-------|
| **Prioridad** | High |
| **Estimación** | L (8 pts) |
| **Branch** | `release/linux-installer` |
| **Dependencias** | All anterior (MVP complete) |

**Funcionalidades:**
- .deb package con dependencias (Flutter ejecutartime, Python deps)
- Desktop entry (.desktop archivo) para menú de aplicaciones
- Icon integration (XDG standards)
- Auto-start service (systemd optional)

**Criterios de Aceptación:**
- ✅ .deb instalable con `sudo dpkg -i soft-architect-ai.deb`
- ✅ App aparece en menú de aplicaciones
- ✅ Icono visible en launcher
- ✅ Uninstall limpia: `sudo apt remove soft-architect-ai`
- ✅ Pruebas: instalación, ejecución, desinstalación

---

#### HU-6.2: User Onboarding Flow & First-Ejecutar Experience 🟡 MEDIUM

**Objetivo:** Wizard de configuración inicial (Ollama/Groq, proyecto paths).

| Campo | Valor |
|-------|-------|
| **Prioridad** | Medium |
| **Estimación** | M (5 pts) |
| **Branch** | `feature/onboarding-wizard` |
| **Dependencias** | HU-6.1 |

**Funcionalidades:**
- Welcome screen (paso 1/4)
- LLM provider selection (Ollama local / Groq cloud) (paso 2/4)
- Proyecto default path selector (paso 3/4)
- Confirmation & health check (paso 4/4)

**Criterios de Aceptación:**
- ✅ Wizard aparece solo en primera ejecución
- ✅ Configuración guardada en sqflite (settings table)
- ✅ Health check: Ollama/Groq API reachable
- ✅ Skip wizard disponible (use defaults)
- ✅ Pruebas: wizard flow, settings persistence (>85%)

---

#### HU-6.3: Documentoation Portal & User Guide 🟡 MEDIUM

**Objetivo:** Documentoación interactiva para usuarios finales.

| Campo | Valor |
|-------|-------|
| **Prioridad** | Medium |
| **Estimación** | S (3 pts) |
| **Branch** | `docs/user-guide` |
| **Dependencias** | None |

**TODOs Incluidos:**
- I-4: Documento prueba execution & coverage

**Funcionalidades:**
- User Guide (Markdown → HTML) en doc/USER_GUIDE/
- In-app help botón → opens browser with docs
- Troubleshooting section (common errors + solutions)
- Video tutorials (opcional: YouTube links)

**Criterios de Aceptación:**
- ✅ User Guide cubre: Installation, First Proyecto, Chat Usage, Settings
- ✅ Troubleshooting: 10+ common errors documentoados
- ✅ In-app help botón funcional
- ✅ Docs servidas en localhost:8000/docs/guide (FastAPI)

---

### 6.6 Sprint 7 - CI/CD & Release Management

#### HU-7.1: GitHub Actions Workflows & Automated Pruebaing 🔴 CRITICAL

**Objetivo:** Pipeline CI/CD completo con pruebas automáticos.

| Campo | Valor |
|-------|-------|
| **Prioridad** | Critical |
| **Estimación** | M (5 pts) |
| **Branch** | `ci/github-actions-pipeline` |
| **Dependencias** | None |

**TODOs Incluidos:**
- I-1: Setup CI/CD GitHub Actions pipeline
- I-2: Generate coverage reports in CI

**Funcionalidades:**
- Workflow: Backend CI (Pyright, Black, Ruff, pyprueba)
- Workflow: Frontend CI (flutter analyze, flutter prueba)
- Coverage reports (Codecov integration)
- Pre-commit hooks validation

**Criterios de Aceptación:**
- ✅ GitHub Actions: Backend CI (<5 min)
- ✅ GitHub Actions: Frontend CI (<10 min)
- ✅ Coverage reports auto-generated (>80% gate)
- ✅ Pre-commit hooks enforced (Black, Ruff)
- ✅ Pruebas: workflow validation (act tool)

---

#### HU-7.2: Release Automation & Versioning 🟡 HIGH

**Objetivo:** Automatizar creación de releases y changelog.

| Campo | Valor |
|-------|-------|
| **Prioridad** | High |
| **Estimación** | S (3 pts) |
| **Branch** | `ci/release-automation` |
| **Dependencias** | HU-7.1 |

**Funcionalidades:**
- Semantic versioning (v0.1.0 → v0.2.0)
- Changelog auto-generation (conventional commits)
- GitHub Release creation (on tag push)
- .deb artifact upload to Releases

**Criterios de Aceptación:**
- ✅ Tag v0.1.0 trigger release workflow
- ✅ Changelog auto-generado (CHANGELOG.md)
- ✅ GitHub Release creado con artifacts (.deb)
- ✅ Versioning automático (bump version script)

---

#### HU-7.3: MVP v0.1.0 Release 🎯 FINAL

**Objetivo:** Release oficial del MVP v0.1.0 al público.

| Campo | Valor |
|-------|-------|
| **Prioridad** | Critical |
| **Estimación** | XS (2 pts) |
| **Branch** | `release/v0.1.0` |
| **Dependencias** | All anterior |

**Funcionalidades:**
- Merge develop → main
- Tag v0.1.0
- Release notes (GitHub + README)
- Marketing materials (screenshots, demo video)

**Criterios de Aceptación:**
- ✅ Main branch stable (all pruebas passing)
- ✅ Release notes completas (features, known issues)
- ✅ README.md actualizado (badges, screenshots)
- ✅ Demo video publicado (YouTube)
- ✅ Announcement (LinkedIn, Twitter, Reddit)

---

## 7. Roadmap Reorganizado

### 7.1 Timeline General

```
┌─────────────────────────────────────────────────────────────┐
│  ROADMAP HACIA MVP v0.1.0                                   │
├─────────────────────────────────────────────────────────────┤
│  ESTADO ACTUAL: Sprint 3 - 60% completo                    │
│  SPRINT ACTUAL: S3.6 (Test Suite Completion)               │
│  OBJETIVO: Alcanzar MVP en 8-10 semanas                     │
└─────────────────────────────────────────────────────────────┘

SEMANA 1-2 (Actual):
├─ HU-3.6: Test Suite Completion & SQLite Fix (5 pts) 🔴
├─ HU-3.7: Settings UI Completion (5 pts) 🟡
└─ HU-3.8: Project Phase Logic (3 pts) 🟡
   TOTAL: 13 pts

SEMANA 3-4:
├─ HU-4.1: Backend Chat Endpoint & RAG (8 pts) 🔴
├─ HU-4.2: Conversation History (5 pts) 🟡
└─ HU-4.3: SSE Streaming (5 pts) 🔴
   TOTAL: 18 pts

SEMANA 5-6:
├─ HU-4.4: Error Handling & Validation (5 pts) 🔴
├─ HU-4.5: Streaming Optimization (5 pts) 🟡
└─ HU-5.1: Integration Tests Rewrite (5 pts) 🟡
   TOTAL: 15 pts

SEMANA 7-8:
├─ HU-5.2: Security Hardening (8 pts) 🔴
├─ HU-5.3: Performance Profiling (5 pts) 🟡
└─ HU-6.1: Linux Installer (8 pts) 🔴
   TOTAL: 21 pts

SEMANA 9-10:
├─ HU-6.2: Onboarding Wizard (5 pts) 🟡
├─ HU-6.3: Documentation Portal (3 pts) 🟡
├─ HU-7.1: GitHub Actions CI/CD (5 pts) 🔴
├─ HU-7.2: Release Automation (3 pts) 🟡
└─ HU-7.3: MVP v0.1.0 Release (2 pts) 🎯
   TOTAL: 18 pts

TOTAL ESTIMACIÓN: 85 Story Points (~8-10 semanas)
```

### 7.2 Prioridades por Sprint

| Sprint | Prioridad | HUs | Puntos | Objetivo |
|--------|-----------|-----|--------|----------|
| **S3.6-S3.8** | 🔴 CRITICAL | 3 | 13 | Completar funcionalidades base + pruebas >90% |
| **S4.1-S4.3** | 🔴 CRITICAL | 3 | 18 | Backend Chat & RAG integration funcional |
| **S4.4-S5.1** | 🟡 HIGH | 3 | 15 | Error handling, optimization, integration pruebas |
| **S5.2-S6.1** | 🔴 CRITICAL | 3 | 21 | Security, performance, packaging |
| **S6.2-S7.3** | 🟡 MEDIUM | 5 | 18 | Polish, CI/CD, release |

---

## 8. Criterios de MVP

### 8.1 Funcionalidades Mínimas

| Feature | Estado | HU Requerida |
|---------|--------|--------------|
| **Proyecto Management** | ✅ DONE | HU-3.1 |
| **Archivo System I/O** | ✅ DONE | HU-3.2 |
| **Chat UI** | ✅ DONE | HU-3.3 |
| **Backend Chat + RAG** | ⏳ TODO | HU-4.1 |
| **SSE Streaming** | ⏳ TODO | HU-4.3 |
| **Error Handling** | ⏳ TODO | HU-4.4 |
| **Security Hardening** | ⏳ TODO | HU-5.2 |
| **Linux Installer** | ⏳ TODO | HU-6.1 |
| **CI/CD Pipeline** | ⏳ TODO | HU-7.1 |
| **Release v0.1.0** | ⏳ TODO | HU-7.3 |

### 8.2 Quality Gates

| Gate | Requirement | Estado |
|------|-------------|--------|
| **Prueba Coverage** | >80% | ✅ 82-85% |
| **Pruebas Passing** | >95% | ✅ 93.1% (→ target: >95%) |
| **Type Safety** | 0 errors | ✅ 0 |
| **Security Scan** | 0 critical | ⏳ Pendiente HU-5.2 |
| **Performance** | <200ms P95 | ⏳ Pendiente HU-4.5 |
| **Documentoation** | 100% complete | ⏳ Pendiente HU-6.3 |

### 8.3 Release Checklist

- [ ] All HU 3.6-7.3 completed (85 pts)
- [ ] Pruebas >95% passing
- [ ] Coverage >85%
- [ ] Security audit passed (OWASP Top 10)
- [ ] Performance benchmarks met (<200ms P95)
- [ ] Linux .deb installer pruebaed
- [ ] User Guide completed
- [ ] CI/CD pipeline green
- [ ] Changelog generated
- [ ] GitHub Release creard
- [ ] Demo video published

---

## 📊 Resumen Ejecutivo

### Estado Actual
- **Completado:** 60% del MVP (HU 1.1-3.3)
- **Pendiente:** 40% del MVP (HU 3.6-7.3)
- **Calidad:** Pruebas 93.1%, Cobertura 82-85% ✅

### Próximos Pasos
1. **Semana 1-2:** Completar Sprint 3 (HU 3.6-3.8) - Prueba suite + Settings UI
2. **Semana 3-4:** Sprint 4 Backend (HU 4.1-4.3) - Chat API + RAG + Streaming
3. **Semana 5-6:** Sprint 4-5 Polish (HU 4.4-5.1) - Error handling + Pruebas
4. **Semana 7-8:** Sprint 5-6 Security (HU 5.2-6.1) - Hardening + Installer
5. **Semana 9-10:** Sprint 6-7 Release (HU 6.2-7.3) - CI/CD + MVP Launch

### Estimación Total
- **85 Story Points** (~8-10 semanas)
- **17 HUs nuevas** (reorganizadas desde originales + TODOs integrados)
- **MVP Target:** Semana 10 (Finales de Abril 2026)

---

**Generado:** 09/02/2026 | **Última Actualización:** 09/02/2026
**Versión:** v1.0 | **Estado:** ✅ ANALYSIS COMPLETE
