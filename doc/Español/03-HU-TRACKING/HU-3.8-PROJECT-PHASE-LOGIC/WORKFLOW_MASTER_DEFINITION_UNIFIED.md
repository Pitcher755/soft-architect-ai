# HU-3.8 WORKFLOW MASTER DEFINITION / DEFINICIÓN MAESTRO DE FLUJO DE TRABAJO

> **Date/Fecha:** 12/02/2026
> **Branch/Rama:** `feature/proyecto_fase_logic`
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

## 📖 Tabla de Contenidos

1. [Purpose](#purpose)
2. [Mandatory Principles](#mandatory-principles)
3. [Proyecto Fase Map](#proyecto-fase-map)
4. [Fase Completeness Definition](#fase-completeness-definition)
5. [TDD Execution Plan by Fases](#tdd-execution-plan-by-fases)
6. [Quality & Security Gates](#quality--security-gates)
7. [Acceptance Criteria HU-3.8 → Pruebas](#acceptance-criteria-hu-38--pruebas)
8. [Final Deliverables](#final-deliverables)
9. [Implementación Plan by Archivo](#implementación-plan-by-archivo)
10. [First Executable Iteration](#first-executable-iteration)

---

## 1. Purpose

Implement a real fase engine for Proyecto Shell where the `Doc N/25` progress derives from actually generated artifacts, following the structure of `packages/knowledge_base/01-TEMPLATES` and their `03-EXAMPLES`.

---

## 2. Mandatory Principles

1. **Local-first and offline:** no computation depends on cloud services.
2. **Clean Architecture:** business rules in domain; IO/adapters isolated.
3. **No transition without completeness:** a fase does not advance with missing mandatory documentos from anterior fase.
4. **Idempotency:** re-ejecutarning validation does not break state nor duplicates artifacts.
5. **Controlled errors:** friendly messages, no stack traces to user.
6. **Strict TDD:** every new rule enters first with a red prueba.

---

## 3. Proyecto Fase Map

### Fase 0 — `00-ROOT`
- Generated at proyecto root.
- **Mandatory:** `AGENTS.md`, `README.md`
- **Optional:** `RULES.md`, `CONTRIBUTING.md`

### Fase 1 — `10-CONTEXT`
- Complete mandatory directory.
- Mandatory documentos:
  - `DOMAIN_LANGUAGE.md`
  - `PROJECT_MANIFESTO.md`
  - `USER_JOURNEY_MAP.md`

### Fase 2 — `20-REQUIREMENTS`
- Complete mandatory directory.
- Mandatory documentos:
  - `COMPLIANCE_MATRIX.md`
  - `REQUIREMENTS_MASTER.md`
  - `SECURITY_PRIVACY_POLICY.md`
  - `USER_STORIES_MASTER.json`

### Fase 3 — `30-ARCHITECTURE`
- Complete mandatory directory.
- Mandatory documentos:
  - `API_INTERFACE_CONTRACT.md`
  - `ARCH_DECISION_RECORDS.md`
  - `DATA_MODEL_SCHEMA.md`
  - `PROJECT_STRUCTURE_MAP.md`
  - `SECURITY_THREAT_MODEL.md`
  - `TECH_STACK_DECISION.md`

### Fase 4 — `35-UX_UI`
- Complete mandatory directory.
- Mandatory documentos:
  - `ACCESSIBILITY_GUIDE.md`
  - `DESIGN_SYSTEM.md`
  - `UI_WIREFRAMES_FLOW.md`

### Fase 5 — `40-PLANNING`
- Complete mandatory directory.
- Mandatory documentos:
  - `CI_CD_PIPELINE.md`
  - `DEPLOYMENT_INFRASTRUCTURE.md`
  - `ROADMAP_PHASES.md`
  - `TESTING_STRATEGY.md`

### Fase 6 — `99-META`
- Complete mandatory directory.
- Mandatory documento:
  - `CONTEXT_GENERATOR_PROMPT.md`

**Total expected documentos:** 25

---

## 4. Fase Completeness Definition

A fase is considered **COMPLETE** if and only if:

1. The expected container exists (root or fase directory).
2. All mandatory documentos defined for that fase exist.
3. The structure validator detect no missing items.
4. State persistence registers valid transition `fase_k -> fase_k+1`.

Progress rule:
- `N` in `Doc N/25` = total mandatory documentos generated and validated.
- If a mandatory documento from a anterior fase is missing, state degrades to last valid fase.

---

## 5. TDD Execution Plan by Fases

> **Source of truth for HU-3.8:** `context/40-ROADMAP/USER_STORIES_MASTER.es.json`
>
> **HU-3.8 criteria to meet unambiguously:**
> 1) `ProyectoFaseService` detects current fase (0-6) by scanning `context/` carpetas.
> 2) Progress bar `Doc N/25` updates dynamically in Dashboard.
> 3) Fase badge in ProyectoShell reflects real state.
> 4) Unit pruebas for fase detection >90% coverage (HU module).

### Execution Rules for This HU

- Each RED sub-fase must end with pruebas failing for the correct reason.
- Each GREEN sub-fase must introduce minimum code to pass.
- Each REFACTOR sub-fase must keep pruebas green and improve design.
- No UI step can start without validated domain.

### Fase A — RED 1 (Fase Model)

#### Step A1
- Crear pruebas for strict order ROOT→99-META fases.
- Expected: fail due to absence of model.

#### Step A2
- Crear pruebas for cardinality of mandatory documentos per fase.
- Expected: fail with non-existent mapping errors.

#### Step A3
- Crear pruebas for ROOT rules (2 mandatory + optional).
- Expected: fail due to lack of differential validation.

### Fase B — GREEN 1 (Minimal Implementación)

#### Step B1
- Implement `ProyectoFase` model + requirements catalog per fase.

#### Step B2
- Implement minimal validator `isFaseComplete(fase, archivosystemSnapshot)`.

#### Step B3
- Make RED 1 pruebas pass without over-engineering.

### Fase C — RED 2 (Real Progress)

#### Step C1
- Pruebas for `Doc N/25` calculation for nominal and edge cases.

#### Step C2
- Pruebas for degradation when mandatory artifact missing from anterior fase.

#### Step C3
- Pruebas for idempotency (double evaluation does not improperly change result).

### Fase D — GREEN 2 (Progress Calculator)

#### Step D1
- Implement progress computation service from real snapshot.

#### Step D2
- Integrate fase persistence in repository/data source.

#### Step D3
- Make RED 2 pass.

### Fase E — REFACTOR

#### Step E1
- Clean duplication between template mappings and validation.

#### Step E2
- Introduce value objects and typed domain errors.

#### Step E3
- Review naming, cyclomatic complexity and public contracts.

### Fase F — UI Integración

#### Step F1
- Integrate calculation in Proyecto Shell notifier.

#### Step F2
- Display current fase + `Doc N/25` progress in UI.

#### Step F3
- Add widget/integration pruebas for transition flows.

### Fase G — Closure

#### Step G1
- Ejecutar local quality gates per AGENTS.

#### Step G2
- Verify AC-1..AC-8 with traceable evidence.

#### Step G3
- Update HU documentoation and prepare PR.

---

## 6. Quality & Security Gates

1. `flutter analyze` without errors.
2. Domain and data pruebas for fase logic in green.
3. HU module coverage target validated.
4. Secure path validation (no traversal, no hardcoding).
5. No internal errors exposed in UI layer.
6. Compliance with `doc as code` documentoation.

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

- Fase/progress detection module coverage: internal minimum target **90%**.
- No business logic coupled in widgets (only notifier/providers consume services).
- Typed errors and friendly UI messages (no stack trace).
- Maintainability: fase/documento mapping in a single source of truth.

---

## 7. Acceptance Criteria HU-3.8 → Pruebas

- **AC-1/AC-2:** unit pruebas of order and mandatory per fase.
- **AC-3:** pruebas of `Doc N/25` calculation with archivosystem fixtures.
- **AC-4/AC-5:** specific pruebas of ROOT vs non-ROOT fases.
- **AC-6:** idempotency and resumption prueba.
- **AC-7:** pruebas mapping errors to controlled messages.
- **AC-8:** coverage report on fase/progress services.

### Detailed AC ↔ Prueba Case Matrix

| AC | Prueba Type | Minimum Case | Expected Resultado |
|---|---|---|---|
| AC-1 | Unit (domain) | `detect_fase_from_context_tree` with partial/complete structure | Returns correct fase 0-6 |
| AC-2 | Unit (domain/data) | `compute_doc_progress` with growing documentos | `N` advances monotonically valid |
| AC-3 | Widget | Dashboard with mocked provider on snapshot changes | Text `Doc N/25` refreshes in UI |
| AC-4 | Widget/Unit | Fase badge with in-progress/completed/blocked state | Badge reflects real current fase |
| AC-5 | Unit | Comparative `existing vs expected` per fase | Identifies exact missing items |
| AC-6 | Unit | Double execution on same state | Same result without side effects |
| AC-7 | Unit/UI | Invalid path / corrupted structure error | Friendly message and domain code |
| AC-8 | Coverage | Dedicated HU-3.8 suite | Target module coverage ≥90% |

---

## 8. Final Deliverables

- Evidence AC-1..AC-8 in HU report.
- Stable and repeatable HU-3.8 prueba suite.
- Update of HU tracking index.
- PR with technical summary, risks and rollback plan.

---

## 9. Implementación Plan by Archivo

> Following inventory defines recommended work order to fulfill HU-3.8 roadmap technical tasks.

### 9.1 Domain

1. `src/client/lib/features/proyecto_shell/domain/services/proyecto_fase_service.dart`
  - Incorporate real carpeta/documento scanning.
  - Expose pure API for fase detection and progress.
2. `src/client/lib/features/proyecto_shell/domain/repositories/proyecto_repository.dart`
  - Ensure contract for necessary state recovery (paths/context).

### 9.2 Data

1. `src/client/lib/features/proyecto_shell/data/repositories/proyecto_repository_impl.dart`
  - Implement query of existing vs expected artifacts.
2. `src/client/lib/features/proyecto_shell/data/data_sources/sqlite_data_source.dart`
  - Persist current fase state and validation timestamp.
3. `src/client/lib/features/proyecto_shell/data/models/proyecto_model.dart`
  - Add/adjust fase/progress fields if applicable.

### 9.3 Presentación

1. `src/client/lib/features/proyecto_shell/presentation/notifiers/proyecto_shell_notifier.dart`
  - Connect `ProyectoFaseService` and dynamic progress refresh.
2. `src/client/lib/features/proyecto_shell/presentation/widgets/workspace_header.dart`
  - Display `Doc N/25` and current fase badge.
3. `src/client/lib/features/proyecto_shell/presentation/widgets/proyectos_grid.dart`
  - Reflect summarized state per proyecto if applicable.

### 9.4 Target Pruebas

1. `pruebas/client/unit/features/proyecto_shell/domain/services/proyecto_fase_service_prueba.dart`
2. `pruebas/client/unit/features/proyecto_shell/presentation/providers/proyecto_providers_prueba.dart`
3. `pruebas/client/widget/features/proyecto_shell/presentation/proyecto_card_prueba.dart`

---

## 10. First Executable Iteration

### Iteration 1 Objective

Deliver first vertical cut meeting AC-1 + AC-2 + AC-8 in domain/data, leaving UI for iteration 2.

### Iteration 1 Scope

1. RED pruebas for fase detection and `Doc N/25` calculation.
2. Minimal implementación in `ProyectoFaseService`.
3. Repository/data source adjustment to obtain artifact snapshot.
4. HU module coverage ≥90% in domain unit suite.

### Iteration 1 Exit Criteria

- HU-3.8 unit pruebas in green.
- Fase/progress logic coverage reported and documentoed.
- No UI changes yet (avoids prematurely mixing layers).

---

</div>

---

<div id="español">

# 🇪🇸 VERSIÓN EN ESPAÑOL

## 📖 Tabla de Contenidos

1. [Objetivos Estratégicos](#objetivos-estratégicos)
2. [Criterios de Aceptación](#criterios-de-aceptación-definition-of-done)
3. [Fases Reales del RAG](#fases-reales-del-rag-de-documentoación)
4. [Fase 0: Preparación](#fase-0-preparación-del-terreno)
5. [Fase 1: TDD - ROJO](#fase-1-tdd---rojo-dominio)
6. [Fase 2: TDD - VERDE](#fase-2-tdd---verde-dominio--data-mínima)
7. [Fase 3: TDD - REFACTOR](#fase-3-tdd---refactor-calidad--seguridad)
8. [Fase 4: Integración Estado](#fase-4-integración-de-estado-riverpod)
9. [Fase 5: Integración UI](#fase-5-integración-ui-dashboard--badge)
10. [Fase 6: Validación CI/CD](#fase-6-validación-final-cicd)
11. [Matriz AC ↔ Pruebas](#matriz-ac--pruebas--archivos)
12. [Entregables](#entregables-finales)

---

## 🎯 Objetivos Estratégicos

### 1. Detección real de fase (0-6)
- Escanear artefactos reales de proyecto en disco, no mocks.
- Determinar fase actual según completitud secuencial de documentoos.
- Soportar estructura canónica de `01-TEMPLATES`.

### 2. Progreso dinámico `Doc N/25`
- Calcular `N` desde documentoos detectados realmente.
- Refrescar progreso al abrir proyecto y al actualizar contexto.
- Mantener coherencia entre progreso numérico y fase mostrada.

### 3. Badge de fase en Proyecto Shell
- Mostrar fase real actual en `WorkspaceHeader`/vista principal.
- Evitar desfases entre badge y barra de progreso.

### 4. Robustez de calidad
- Cobertura en módulo HU-3.8 >90% en unit pruebas de detección de fase.
- Mapeo de errores controlado (sin stack traces en UI).

---

## ✅ Criterios de Aceptación (Definition of Done)

### POSITIVOS (Debe tener)
- ✅ `ProyectoFaseService` detecta fase actual (0-6) desde árbol `context/` y raíz.
- ✅ `Doc N/25` se calcula dinámicamente con archivos reales.
- ✅ Badge de fase refleja estado real del proyecto activo.
- ✅ Pruebas de detección de fase/progreso con cobertura objetivo >90% en módulo HU.

### NEGATIVOS (No debe)
- ❌ No usar valores mock hardcodeados para progreso.
- ❌ No avanzar fase cuando faltan documentoos obligatorios de fase previa.
- ❌ No realizar lógica de negocio directamente en widgets.

---

## 🧭 Fases Reales del RAG de Documentoación

Estas son las fases por las que pasa el usuario en SoftArchitect AI (flujo de documentoación guiada):

### Fase 0 — `00-ROOT` (raíz del proyecto)
- **Obligatorios:** `AGENTS.md`, `README.md`
- **Opcionales:** `RULES.md`, `CONTRIBUTING.md`

### Fase 1 — `10-CONTEXT`
- `DOMAIN_LANGUAGE.md`
- `PROJECT_MANIFESTO.md`
- `USER_JOURNEY_MAP.md`

### Fase 2 — `20-REQUIREMENTS`
- `COMPLIANCE_MATRIX.md`
- `REQUIREMENTS_MASTER.md`
- `SECURITY_PRIVACY_POLICY.md`
- `USER_STORIES_MASTER.json`

### Fase 3 — `30-ARCHITECTURE`
- `API_INTERFACE_CONTRACT.md`
- `ARCH_DECISION_RECORDS.md`
- `DATA_MODEL_SCHEMA.md`
- `PROJECT_STRUCTURE_MAP.md`
- `SECURITY_THREAT_MODEL.md`
- `TECH_STACK_DECISION.md`

### Fase 4 — `35-UX_UI`
- `ACCESSIBILITY_GUIDE.md`
- `DESIGN_SYSTEM.md`
- `UI_WIREFRAMES_FLOW.md`

### Fase 5 — `40-PLANNING`
- `CI_CD_PIPELINE.md`
- `DEPLOYMENT_INFRASTRUCTURE.md`
- `ROADMAP_PHASES.md`
- `TESTING_STRATEGY.md`

### Fase 6 — `99-META`
- `CONTEXT_GENERATOR_PROMPT.md`

**Regla de completitud:** solo se avanza a la siguiente fase si la fase actual está completa en obligatorios.

**Total de documentoos esperados:** 25

---

## 🔧 Fase 0: Preparación del Terreno

### 0.1 Sincronización de rama
```bash
git checkout develop
git pull origin develop
git checkout -b feature/project_phase_logic
```

### 0.2 Definir mapa de verdad
- Crear/validar constantes de estructura de fases y documentoos esperados (25 docs).
- Unificar naming para soportar rutas legacy donde aplique.

### 0.3 Preparar pruebas objetivo
- Suite unitaria de dominio HU-3.8.
- Fixtures temporales de archivosystem para simular proyectos.

**Checklist Fase 0**
- [x] Rama de trabajo lista
- [x] Mapa de fases documentoado
- [x] Plan TDD definido

---

## 🔴 Fase 1: TDD - ROJO (Dominio)

**Objetivo:** pruebas que fallen por ausencia de lógica real.

### 1.1 Pruebas de cálculo por lista de archivos
Archivo objetivo:
- `pruebas/client/unit/features/proyecto_shell/domain/services/proyecto_fase_service_prueba.dart`

Casos mínimos:
1. Lista vacía → fase 0, `Doc 0/25`.
2. Root + Context completos → fase 1.
3. Documentoos dispersos → cálculo exacto `N/25`.
4. Falta obligatorio de fase actual → no avanza de fase.

### 1.2 Pruebas de escaneo real de disco
- Proyecto temporal con archivos reales creados en ejecutartime.
- Verificar que `analyzeProyecto(path)` detecta fase esperada.

**Checklist Fase 1**
- [x] Casos RED de fase/progreso escritos
- [x] Casos RED de escaneo real escritos

---

## 🟢 Fase 2: TDD - VERDE (Dominio + Data mínima)

**Objetivo:** implementar código mínimo para pasar pruebas.

### 2.1 Servicio de fase/progreso
Archivo objetivo:
- `src/client/lib/features/proyecto_shell/domain/services/proyecto_fase_service.dart`

Implementación mínima:
- `calculateProgress(List<String> archivoPaths)`
- `analyzeProyecto(String proyectoPath)`
- Conversión de índice de fase a `ProyectoFase`.

### 2.2 Constantes de estructura
Archivo objetivo:
- `src/client/lib/features/proyecto_shell/core/constants/proyecto_structure_constants.dart`

Implementación mínima:
- Definición de fases, docs obligatorios/opcionales.
- Total esperado de docs = 25.

**Checklist Fase 2**
- [x] Cálculo `Doc N/25` implementado
- [x] Detección de fase secuencial implementada
- [x] Escaneo de archivos implementado

---

## 🔵 Fase 3: TDD - REFACTOR (Calidad + Seguridad)

**Objetivo:** mejorar diseño sin romper pruebas.

### 3.1 Seguridad de rutas
- Integrar validación con `PathValidator` para proyecto raíz.
- Evitar rutas absolutas maliciosas y traversal.

### 3.2 Limpieza de API
- Mantener compatibilidad de métodos públicos usados por UI existente.
- Centralizar lógica de matching documentoo/fase.

### 3.3 Cobertura y mantenibilidad
- Alcanzar cobertura objetivo de módulo HU.
- Evitar duplicación en mapeos de fases.

**Checklist Fase 3**
- [x] Validación de path integrada
- [x] API compatible mantenida
- [ ] Cobertura HU-3.8 >90% verificada

---

## 🧩 Fase 4: Integración de Estado (Riverpod)

**Objetivo:** exponer progreso real a la capa de presentación.

### 4.1 Notifier/Provider
Archivos objetivo:
- `src/client/lib/features/proyecto_shell/presentation/notifiers/proyecto_shell_notifier.dart`
- `src/client/lib/features/proyecto_shell/presentation/providers/proyecto_providers.dart`

Tareas:
- Añadir carga de estado de fase/progreso para proyecto activo.
- Manejar estados `loading / data / error`.

### 4.2 Pruebas de estado
- Crear pruebas unitarios de notifier para actualización de progreso.

**Checklist Fase 4**
- [ ] Provider de progreso implementado
- [ ] Pruebas de notifier en verde

---

## 🖥️ Fase 5: Integración UI (Dashboard + Badge)

**Objetivo:** reflejar estado real en interfaz.

### 5.1 Dashboard
Archivos objetivo:
- `src/client/lib/features/proyecto_shell/presentation/widgets/workspace_header.dart`
- `src/client/lib/features/proyecto_shell/presentation/widgets/proyectos_grid.dart`

Tareas:
- Mostrar `Doc N/25` dinámico.
- Mostrar badge de fase real.

### 5.2 Pruebas widget
- Añadir pruebas para render de progreso y badge según estado del provider.

**Checklist Fase 5**
- [ ] `Doc N/25` visible y dinámico
- [ ] Badge fase actualizado en tiempo real
- [ ] Pruebas widget en verde

---

## ✅ Fase 6: Validación Final CI/CD

### 6.1 Quality gates locales
```bash
cd src/client && flutter analyze
cd ../../tests && flutter test client/unit/features/project_shell/
flutter test client/widget/features/project_shell/
cd .. && ./scripts/PRE_PUSH_VALIDATION_MASTER.sh
```

### 6.2 Verificación manual
1. Crear proyecto nuevo.
2. Crear `context/10-CONTEXT/DOMAIN_LANGUAGE.md` y resto de fase.
3. Confirmar que progreso y fase suben correctamente.

### 6.3 Evidencia
- Reporte de coverage HU.
- Capturas/logs de estado en UI.

**Checklist Fase 6**
- [ ] Analyze en verde
- [ ] Pruebas unit/widget en verde
- [ ] Gate maestro pre-push en verde
- [ ] Evidencia AC completa

---

## 🔬 Matriz AC ↔ Pruebas ↔ Archivos

| AC | Prueba clave | Archivos principales |
|---|---|---|
| AC-1 | `fase detection from archivosystem` | `proyecto_fase_service.dart`, `proyecto_fase_service_prueba.dart` |
| AC-2 | `Doc N/25 dynamic` | `proyecto_fase_service.dart`, `workspace_header.dart` |
| AC-3 | `badge reflects real fase` | `proyectos_grid.dart`, `workspace_header.dart` |
| AC-4 | `coverage report >90% (HU module)` | pruebas unitarios HU-3.8 + report coverage |

---

## 📦 Entregables Finales

### Código
- `src/client/lib/features/proyecto_shell/core/constants/proyecto_structure_constants.dart`
- `src/client/lib/features/proyecto_shell/domain/services/proyecto_fase_service.dart`
- Integración notifier/provider/UI para progreso y fase.

### Pruebas
- `pruebas/client/unit/features/proyecto_shell/domain/services/proyecto_fase_service_prueba.dart`
- Pruebas notifier/provider HU-3.8
- Pruebas widget de progreso y badge

### Documentoación
- `doc/03-HU-TRACKING/HU-3.8-PROJECT-PHASE-LOGIC/PROGRESS.md`
- `doc/03-HU-TRACKING/HU-3.8-PROJECT-PHASE-LOGIC/WORKFLOW_MASTER_DEFINITION_UNIFIED.md`
- Evidencia final AC y cobertura

---

## 🎉 Estado de Completitud del Workflow

- **Workflow definido al 100% para ejecución HU-3.8** ✅
- **Fases 0-3 completadas** ✅ (TDD dominio + base de escaneo)
- **Fases 4-6 pendientes** 🚧 (estado/UI + validación final)

---

</div>
