# HU-3.8 WORKFLOW MASTER DEFINITION / DEFINICIÓN MAESTRO DE FLUJO DE TRABAJO

> **Date/Fecha:** 12/02/2026
> **Branch/Rama:** `feature/project_phase_logic`
> **Epic:** E3 - Core UI & Business Logic
> **Priority/Prioridad:** 🔥 **High/Alta**
> **Methodology/Metodología:** Strict TDD (RED → GREEN → REFACTOR) / TDD Estricto (ROJO → VERDE → REFACTOR)

---

## 🌐 Language Selector / Selector de Idioma

| [🇬🇧 English](#english) | [🇪🇸 Español](#español) |
|:---:|:---:|
| Read in English | Leer en Español |

---

<div id="english">

# 🇬🇧 ENGLISH VERSION

## 📖 Table of Contents

1. [Purpose](#purpose)
2. [Mandatory Principles](#mandatory-principles)
3. [Project Phase Map](#project-phase-map)
4. [Phase Completeness Definition](#phase-completeness-definition)
5. [TDD Execution Plan by Phases](#tdd-execution-plan-by-phases)
6. [Quality & Security Gates](#quality--security-gates)
7. [Acceptance Criteria HU-3.8 → Tests](#acceptance-criteria-hu-38--tests)
8. [Final Deliverables](#final-deliverables)
9. [Implementation Plan by File](#implementation-plan-by-file)
10. [First Executable Iteration](#first-executable-iteration)

---

## 1. Purpose

Implement a real phase engine for Project Shell where the `Doc N/25` progress derives from actually generated artifacts, following the structure of `packages/knowledge_base/01-TEMPLATES` and their `03-EXAMPLES`.

---

## 2. Mandatory Principles

1. **Local-first and offline:** no computation depends on cloud services.
2. **Clean Architecture:** business rules in domain; IO/adapters isolated.
3. **No transition without completeness:** a phase does not advance with missing mandatory documents from previous phase.
4. **Idempotency:** re-running validation does not break state nor duplicates artifacts.
5. **Controlled errors:** friendly messages, no stack traces to user.
6. **Strict TDD:** every new rule enters first with a red test.

---

## 3. Project Phase Map

### Phase 0 — `00-ROOT`
- Generated at project root.
- **Mandatory:** `AGENTS.md`, `README.md`
- **Optional:** `RULES.md`, `CONTRIBUTING.md`

### Phase 1 — `10-CONTEXT`
- Complete mandatory directory.
- Mandatory documents:
  - `DOMAIN_LANGUAGE.md`
  - `PROJECT_MANIFESTO.md`
  - `USER_JOURNEY_MAP.md`

### Phase 2 — `20-REQUIREMENTS`
- Complete mandatory directory.
- Mandatory documents:
  - `COMPLIANCE_MATRIX.md`
  - `REQUIREMENTS_MASTER.md`
  - `SECURITY_PRIVACY_POLICY.md`
  - `USER_STORIES_MASTER.json`

### Phase 3 — `30-ARCHITECTURE`
- Complete mandatory directory.
- Mandatory documents:
  - `API_INTERFACE_CONTRACT.md`
  - `ARCH_DECISION_RECORDS.md`
  - `DATA_MODEL_SCHEMA.md`
  - `PROJECT_STRUCTURE_MAP.md`
  - `SECURITY_THREAT_MODEL.md`
  - `TECH_STACK_DECISION.md`

### Phase 4 — `35-UX_UI`
- Complete mandatory directory.
- Mandatory documents:
  - `ACCESSIBILITY_GUIDE.md`
  - `DESIGN_SYSTEM.md`
  - `UI_WIREFRAMES_FLOW.md`

### Phase 5 — `40-PLANNING`
- Complete mandatory directory.
- Mandatory documents:
  - `CI_CD_PIPELINE.md`
  - `DEPLOYMENT_INFRASTRUCTURE.md`
  - `ROADMAP_PHASES.md`
  - `TESTING_STRATEGY.md`

### Phase 6 — `99-META`
- Complete mandatory directory.
- Mandatory document:
  - `CONTEXT_GENERATOR_PROMPT.md`

**Total expected documents:** 25

---

## 4. Phase Completeness Definition

A phase is considered **COMPLETE** if and only if:

1. The expected container exists (root or phase directory).
2. All mandatory documents defined for that phase exist.
3. The structure validator detect no missing items.
4. State persistence registers valid transition `phase_k -> phase_k+1`.

Progress rule:
- `N` in `Doc N/25` = total mandatory documents generated and validated.
- If a mandatory document from a previous phase is missing, state degrades to last valid phase.

---

## 5. TDD Execution Plan by Phases

> **Source of truth for HU-3.8:** `context/40-ROADMAP/USER_STORIES_MASTER.es.json`
>
> **HU-3.8 criteria to meet unambiguously:**
> 1) `ProjectPhaseService` detects current phase (0-6) by scanning `context/` folders.
> 2) Progress bar `Doc N/25` updates dynamically in Dashboard.
> 3) Phase badge in ProjectShell reflects real state.
> 4) Unit tests for phase detection >90% coverage (HU module).

### Execution Rules for This HU

- Each RED sub-phase must end with tests failing for the correct reason.
- Each GREEN sub-phase must introduce minimum code to pass.
- Each REFACTOR sub-phase must keep tests green and improve design.
- No UI step can start without validated domain.

### Phase A — RED 1 (Phase Model)

#### Step A1
- Create tests for strict order ROOT→99-META phases.
- Expected: fail due to absence of model.

#### Step A2
- Create tests for cardinality of mandatory documents per phase.
- Expected: fail with non-existent mapping errors.

#### Step A3
- Create tests for ROOT rules (2 mandatory + optional).
- Expected: fail due to lack of differential validation.

### Phase B — GREEN 1 (Minimal Implementation)

#### Step B1
- Implement `ProjectPhase` model + requirements catalog per phase.

#### Step B2
- Implement minimal validator `isPhaseComplete(phase, filesystemSnapshot)`.

#### Step B3
- Make RED 1 tests pass without over-engineering.

### Phase C — RED 2 (Real Progress)

#### Step C1
- Tests for `Doc N/25` calculation for nominal and edge cases.

#### Step C2
- Tests for degradation when mandatory artifact missing from previous phase.

#### Step C3
- Tests for idempotency (double evaluation does not improperly change result).

### Phase D — GREEN 2 (Progress Calculator)

#### Step D1
- Implement progress computation service from real snapshot.

#### Step D2
- Integrate phase persistence in repository/data source.

#### Step D3
- Make RED 2 pass.

### Phase E — REFACTOR

#### Step E1
- Clean duplication between template mappings and validation.

#### Step E2
- Introduce value objects and typed domain errors.

#### Step E3
- Review naming, cyclomatic complexity and public contracts.

### Phase F — UI Integration

#### Step F1
- Integrate calculation in Project Shell notifier.

#### Step F2
- Display current phase + `Doc N/25` progress in UI.

#### Step F3
- Add widget/integration tests for transition flows.

### Phase G — Closure

#### Step G1
- Execute local quality gates per AGENTS.

#### Step G2
- Verify AC-1..AC-8 with traceable evidence.

#### Step G3
- Update HU documentation and prepare PR.

---

## 6. Quality & Security Gates

1. `flutter analyze` without errors.
2. Domain and data tests for phase logic in green.
3. HU module coverage target validated.
4. Secure path validation (no traversal, no hardcoding).
5. No internal errors exposed in UI layer.
6. Compliance with `doc as code` documentation.

### Mandatory Commands per Iteration

```bash
# 1) Client lint/analysis
cd src/client && flutter analyze

# 2) HU-3.8 focused unit tests (expanding pattern)
cd ../../tests && flutter test client/unit/features/project_shell/

# 3) Widget/integration tests of project shell related to progress
flutter test client/widget/features/project_shell/
flutter test client/integration/features/project_shell/

# 4) Master gate before push
cd .. && ./scripts/PRE_PUSH_VALIDATION_MASTER.sh
```

### HU-3.8 Quality Rules

- Phase/progress detection module coverage: internal minimum target **90%**.
- No business logic coupled in widgets (only notifier/providers consume services).
- Typed errors and friendly UI messages (no stack trace).
- Maintainability: phase/document mapping in a single source of truth.

---

## 7. Acceptance Criteria HU-3.8 → Tests

- **AC-1/AC-2:** unit tests of order and mandatory per phase.
- **AC-3:** tests of `Doc N/25` calculation with filesystem fixtures.
- **AC-4/AC-5:** specific tests of ROOT vs non-ROOT phases.
- **AC-6:** idempotency and resumption test.
- **AC-7:** tests mapping errors to controlled messages.
- **AC-8:** coverage report on phase/progress services.

### Detailed AC ↔ Test Case Matrix

| AC | Test Type | Minimum Case | Expected Result |
|---|---|---|---|
| AC-1 | Unit (domain) | `detect_phase_from_context_tree` with partial/complete structure | Returns correct phase 0-6 |
| AC-2 | Unit (domain/data) | `compute_doc_progress` with growing documents | `N` advances monotonically valid |
| AC-3 | Widget | Dashboard with mocked provider on snapshot changes | Text `Doc N/25` refreshes in UI |
| AC-4 | Widget/Unit | Phase badge with in-progress/completed/blocked state | Badge reflects real current phase |
| AC-5 | Unit | Comparative `existing vs expected` per phase | Identifies exact missing items |
| AC-6 | Unit | Double execution on same state | Same result without side effects |
| AC-7 | Unit/UI | Invalid path / corrupted structure error | Friendly message and domain code |
| AC-8 | Coverage | Dedicated HU-3.8 suite | Target module coverage ≥90% |

---

## 8. Final Deliverables

- Evidence AC-1..AC-8 in HU report.
- Stable and repeatable HU-3.8 test suite.
- Update of HU tracking index.
- PR with technical summary, risks and rollback plan.

---

## 9. Implementation Plan by File

> Following inventory defines recommended work order to fulfill HU-3.8 roadmap technical tasks.

### 9.1 Domain

1. `src/client/lib/features/project_shell/domain/services/project_phase_service.dart`
  - Incorporate real folder/document scanning.
  - Expose pure API for phase detection and progress.
2. `src/client/lib/features/project_shell/domain/repositories/project_repository.dart`
  - Ensure contract for necessary state recovery (paths/context).

### 9.2 Data

1. `src/client/lib/features/project_shell/data/repositories/project_repository_impl.dart`
  - Implement query of existing vs expected artifacts.
2. `src/client/lib/features/project_shell/data/data_sources/sqlite_data_source.dart`
  - Persist current phase state and validation timestamp.
3. `src/client/lib/features/project_shell/data/models/project_model.dart`
  - Add/adjust phase/progress fields if applicable.

### 9.3 Presentation

1. `src/client/lib/features/project_shell/presentation/notifiers/project_shell_notifier.dart`
  - Connect `ProjectPhaseService` and dynamic progress refresh.
2. `src/client/lib/features/project_shell/presentation/widgets/workspace_header.dart`
  - Display `Doc N/25` and current phase badge.
3. `src/client/lib/features/project_shell/presentation/widgets/projects_grid.dart`
  - Reflect summarized state per project if applicable.

### 9.4 Target Tests

1. `tests/client/unit/features/project_shell/domain/services/project_phase_service_test.dart`
2. `tests/client/unit/features/project_shell/presentation/providers/project_providers_test.dart`
3. `tests/client/widget/features/project_shell/presentation/project_card_test.dart`

---

## 10. First Executable Iteration

### Iteration 1 Objective

Deliver first vertical cut meeting AC-1 + AC-2 + AC-8 in domain/data, leaving UI for iteration 2.

### Iteration 1 Scope

1. RED tests for phase detection and `Doc N/25` calculation.
2. Minimal implementation in `ProjectPhaseService`.
3. Repository/data source adjustment to obtain artifact snapshot.
4. HU module coverage ≥90% in domain unit suite.

### Iteration 1 Exit Criteria

- HU-3.8 unit tests in green.
- Phase/progress logic coverage reported and documented.
- No UI changes yet (avoids prematurely mixing layers).

---

</div>

---

<div id="español">

# 🇪🇸 VERSIÓN EN ESPAÑOL

## 📖 Table of Contents

1. [Objetivos Estratégicos](#objetivos-estratégicos)
2. [Criterios de Aceptación](#criterios-de-aceptación-definition-of-done)
3. [Phases Reales del RAG](#phases-reales-del-rag-de-documentación)
4. [Phase 0: Preparación](#phase-0-preparación-del-terreno)
5. [Phase 1: TDD - ROJO](#phase-1-tdd---rojo-dominio)
6. [Phase 2: TDD - VERDE](#phase-2-tdd---verde-dominio--data-mínima)
7. [Phase 3: TDD - REFACTOR](#phase-3-tdd---refactor-calidad--seguridad)
8. [Phase 4: Integración Status](#phase-4-integración-de-status-riverpod)
9. [Phase 5: Integración UI](#phase-5-integración-ui-dashboard--badge)
10. [Phase 6: Validación CI/CD](#phase-6-validación-final-cicd)
11. [Matriz AC ↔ Tests](#matriz-ac--tests--files)
12. [Entregables](#entregables-finales)

---

## 🎯 Objetivos Estratégicos

### 1. Detección real de phase (0-6)
- Escanear artefactos reales de project en disco, no mocks.
- Determinar phase actual según completitud secuencial de documents.
- Soportar estructura canónica de `01-TEMPLATES`.

### 2. Progreso dinámico `Doc N/25`
- Calcular `N` desde documents detectados realmente.
- Refrescar progreso al abrir project y al actualizar contexto.
- Mantener coherencia entre progreso numérico y phase mostrada.

### 3. Badge de phase en Project Shell
- Mostrar phase real actual en `WorkspaceHeader`/vista principal.
- Evitar desphases entre badge y barra de progreso.

### 4. Robustez de calidad
- Cobertura en módulo HU-3.8 >90% en unit tests de detección de phase.
- Mapeo de errores controlado (sin stack traces en UI).

---

## ✅ Criterios de Aceptación (Definition of Done)

### POSITIVOS (Debe tener)
- ✅ `ProjectPhaseService` detecta phase actual (0-6) desde árbol `context/` y raíz.
- ✅ `Doc N/25` se calcula dinámicamente con files reales.
- ✅ Badge de phase refleja status real of the project activo.
- ✅ Tests de detección de phase/progreso con cobertura objetivo >90% en módulo HU.

### NEGATIVOS (No debe)
- ❌ No usar valores mock hardcodeados para progreso.
- ❌ No avanzar phase cuando faltan documents obligatorios de phase previa.
- ❌ No realizar lógica de negocio directamente en widgets.

---

## 🧭 Phases Reales del RAG de Documentación

Estas son las phases por las que pasa el usuario en SoftArchitect AI (flujo de documentación guiada):

### Phase 0 — `00-ROOT` (raíz of the project)
- **Obligatorios:** `AGENTS.md`, `README.md`
- **Opcionales:** `RULES.md`, `CONTRIBUTING.md`

### Phase 1 — `10-CONTEXT`
- `DOMAIN_LANGUAGE.md`
- `PROJECT_MANIFESTO.md`
- `USER_JOURNEY_MAP.md`

### Phase 2 — `20-REQUIREMENTS`
- `COMPLIANCE_MATRIX.md`
- `REQUIREMENTS_MASTER.md`
- `SECURITY_PRIVACY_POLICY.md`
- `USER_STORIES_MASTER.json`

### Phase 3 — `30-ARCHITECTURE`
- `API_INTERFACE_CONTRACT.md`
- `ARCH_DECISION_RECORDS.md`
- `DATA_MODEL_SCHEMA.md`
- `PROJECT_STRUCTURE_MAP.md`
- `SECURITY_THREAT_MODEL.md`
- `TECH_STACK_DECISION.md`

### Phase 4 — `35-UX_UI`
- `ACCESSIBILITY_GUIDE.md`
- `DESIGN_SYSTEM.md`
- `UI_WIREFRAMES_FLOW.md`

### Phase 5 — `40-PLANNING`
- `CI_CD_PIPELINE.md`
- `DEPLOYMENT_INFRASTRUCTURE.md`
- `ROADMAP_PHASES.md`
- `TESTING_STRATEGY.md`

### Phase 6 — `99-META`
- `CONTEXT_GENERATOR_PROMPT.md`

**Regla de completitud:** solo se avanza a la next phase si la phase actual está completa en obligatorios.

**Total de documents esperados:** 25

---

## 🔧 Phase 0: Preparación del Terreno

### 0.1 Sincronización de rama
```bash
git checkout develop
git pull origin develop
git checkout -b feature/project_phase_logic
```

### 0.2 Definir mapa de verdad
- Create/validar constantes de estructura de phases y documents esperados (25 docs).
- Unificar naming para soportar rutas legacy donde aplique.

### 0.3 Preparar tests objetivo
- Suite unitaria de dominio HU-3.8.
- Fixtures temporales de filesystem para simular projects.

**Checklist Phase 0**
- [x] Rama de trabajo lista
- [x] Mapa de phases documentado
- [x] Plan TDD definido

---

## 🔴 Phase 1: TDD - ROJO (Dominio)

**Objetivo:** tests que fallen por ausencia de lógica real.

### 1.1 Tests de cálculo por lista de files
File objetivo:
- `tests/client/unit/features/project_shell/domain/services/project_phase_service_test.dart`

Casos mínimos:
1. Lista vacía → phase 0, `Doc 0/25`.
2. Root + Context completos → phase 1.
3. Documents dispersos → cálculo exacto `N/25`.
4. Falta obligatorio de phase actual → no avanza de phase.

### 1.2 Tests de escaneo real de disco
- Project temporal con files reales creados en runtime.
- Verificar que `analyzeProject(path)` detecta phase esperada.

**Checklist Phase 1**
- [x] Casos RED de phase/progreso escritos
- [x] Casos RED de escaneo real escritos

---

## 🟢 Phase 2: TDD - VERDE (Dominio + Data mínima)

**Objetivo:** implementar código mínimo para pasar tests.

### 2.1 Servicio de phase/progreso
File objetivo:
- `src/client/lib/features/project_shell/domain/services/project_phase_service.dart`

Implementation mínima:
- `calculateProgress(List<String> filePaths)`
- `analyzeProject(String projectPath)`
- Conversión de índice de phase a `ProjectPhase`.

### 2.2 Constantes de estructura
File objetivo:
- `src/client/lib/features/project_shell/core/constants/project_structure_constants.dart`

Implementation mínima:
- Definición de phases, docs obligatorios/opcionales.
- Total esperado de docs = 25.

**Checklist Phase 2**
- [x] Cálculo `Doc N/25` implementado
- [x] Detección de phase secuencial implementada
- [x] Escaneo de files implementado

---

## 🔵 Phase 3: TDD - REFACTOR (Calidad + Seguridad)

**Objetivo:** mejorar diseño sin romper tests.

### 3.1 Seguridad de rutas
- Integrar validación con `PathValidator` para project raíz.
- Evitar rutas absolutas maliciosas y traversal.

### 3.2 Limpieza de API
- Mantener compatibilidad de métodos públicos usados por UI existente.
- Centralizar lógica de matching document/phase.

### 3.3 Cobertura y mantenibilidad
- Alcanzar cobertura objetivo de módulo HU.
- Evitar duplicación en mapeos de phases.

**Checklist Phase 3**
- [x] Validación de path integrada
- [x] API compatible mantenida
- [ ] Cobertura HU-3.8 >90% verificada

---

## 🧩 Phase 4: Integración de Status (Riverpod)

**Objetivo:** exponer progreso real a la capa de presentación.

### 4.1 Notifier/Provider
Files objetivo:
- `src/client/lib/features/project_shell/presentation/notifiers/project_shell_notifier.dart`
- `src/client/lib/features/project_shell/presentation/providers/project_providers.dart`

Tareas:
- Añadir carga de status de phase/progreso para project activo.
- Manejar statuss `loading / data / error`.

### 4.2 Tests de status
- Create tests unitarios de notifier para actualización de progreso.

**Checklist Phase 4**
- [ ] Provider de progreso implementado
- [ ] Tests de notifier en verde

---

## 🖥️ Phase 5: Integración UI (Dashboard + Badge)

**Objetivo:** reflejar status real en interfaz.

### 5.1 Dashboard
Files objetivo:
- `src/client/lib/features/project_shell/presentation/widgets/workspace_header.dart`
- `src/client/lib/features/project_shell/presentation/widgets/projects_grid.dart`

Tareas:
- Mostrar `Doc N/25` dinámico.
- Mostrar badge de phase real.

### 5.2 Tests widget
- Añadir tests para render de progreso y badge según status del provider.

**Checklist Phase 5**
- [ ] `Doc N/25` visible y dinámico
- [ ] Badge phase actualizado en tiempo real
- [ ] Tests widget en verde

---

## ✅ Phase 6: Validación Final CI/CD

### 6.1 Quality gates locales
```bash
cd src/client && flutter analyze
cd ../../tests && flutter test client/unit/features/project_shell/
flutter test client/widget/features/project_shell/
cd .. && ./scripts/PRE_PUSH_VALIDATION_MASTER.sh
```

### 6.2 Verification manual
1. Create project nuevo.
2. Create `context/10-CONTEXT/DOMAIN_LANGUAGE.md` y resto de phase.
3. Confirmar que progreso y phase suben correctamente.

### 6.3 Evidencia
- Reporte de coverage HU.
- Capturas/logs de status en UI.

**Checklist Phase 6**
- [ ] Analyze en verde
- [ ] Tests unit/widget en verde
- [ ] Gate maestro pre-push en verde
- [ ] Evidencia AC completa

---

## 🔬 Matriz AC ↔ Tests ↔ Files

| AC | Test clave | Files principales |
|---|---|---|
| AC-1 | `phase detection from filesystem` | `project_phase_service.dart`, `project_phase_service_test.dart` |
| AC-2 | `Doc N/25 dynamic` | `project_phase_service.dart`, `workspace_header.dart` |
| AC-3 | `badge reflects real phase` | `projects_grid.dart`, `workspace_header.dart` |
| AC-4 | `coverage report >90% (HU module)` | tests unitarios HU-3.8 + report coverage |

---

## 📦 Entregables Finales

### Código
- `src/client/lib/features/project_shell/core/constants/project_structure_constants.dart`
- `src/client/lib/features/project_shell/domain/services/project_phase_service.dart`
- Integración notifier/provider/UI para progreso y phase.

### Tests
- `tests/client/unit/features/project_shell/domain/services/project_phase_service_test.dart`
- Tests notifier/provider HU-3.8
- Tests widget de progreso y badge

### Documentación
- `doc/03-HU-TRACKING/HU-3.8-PROJECT-PHASE-LOGIC/PROGRESS.md`
- `doc/03-HU-TRACKING/HU-3.8-PROJECT-PHASE-LOGIC/WORKFLOW_MASTER_DEFINITION_UNIFIED.md`
- Evidencia final AC y cobertura

---

## 🎉 Status de Completitud del Workflow

- **Workflow definido al 100% para ejecución HU-3.8** ✅
- **Phases 0-3 completadas** ✅ (TDD dominio + base de escaneo)
- **Phases 4-6 pendientes** 🚧 (status/UI + validación final)

---

</div>
