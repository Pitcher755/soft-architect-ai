# HU-3.8: Lógica real de fases de proyecto (Doc N/25 progress)

> **Estado:** ✅ Implementación técnica MVP completada
> **Fecha:** 12/02/2026
> **Branch:** `feature/project_phase_logic`
> **Objetivo:** Implementar progreso real por fases de documentación basado en plantillas 01-TEMPLATES.

---

<div align="center">

| [🇬🇧 English](#english) | [🇪🇸 Español](#español) |
|:---:|:---:|

</div>

---

<div id="english">

## 📋 Table of Contents
- [Overview](#overview)
- [Business Value](#business-value)
- [Scope](#scope)
- [Acceptance Criteria](#acceptance-criteria)
- [Technical Tasks](#technical-tasks)
- [Dependencies](#dependencies)
- [Definition of Done](#definition-of-done)

---

## 🎯 Overview

**HU ID:** HU-3.8
**Name:** Real project phase logic (Doc N/25 progress)

As a user, I need the project workflow to move through real documentation phases and update progress using generated artifacts, so that the dashboard value `Doc N/25` is accurate and deterministic.

## 💼 Business Value

- Removes fake/simulated progress and replaces it with objective file-based milestones.
- Aligns generated deliverables with knowledge base templates.
- Enables predictable quality gates before moving to the next phase.

## 📦 Scope

This HU introduces a phase engine based on `packages/knowledge_base/01-TEMPLATES`:

1. `00-ROOT` (root files)
2. `10-CONTEXT`
3. `20-REQUIREMENTS`
4. `30-ARCHITECTURE`
5. `35-UX_UI`
6. `40-PLANNING`
7. `99-META`

Progress must advance only when mandatory artifacts for the current phase exist and pass validation.

## ✅ Acceptance Criteria

| ID | Criterion | Expected result |
|---|---|---|
| AC-1 | Phase model equals template folder sequence | Ordered flow ROOT → 99-META |
| AC-2 | Mandatory artifacts are validated per phase | No phase transition with missing required docs |
| AC-3 | `Doc N/25` is computed from real generated artifacts | UI shows deterministic progress |
| AC-4 | ROOT logic enforces required root docs | `AGENTS.md` and `README.md` required; optional extras configurable |
| AC-5 | All non-ROOT phases require full folder completion | 100% mandatory docs before next phase |
| AC-6 | Phase transition is idempotent and resumable | Re-run does not duplicate or corrupt artifacts |
| AC-7 | Errors are explicit and user-friendly | Missing docs and invalid paths map to controlled failures |
| AC-8 | Tests cover phase rules and progress computation | Unit coverage for phase engine ≥90% target for HU module |

## 🛠️ Technical Tasks

- Implement phase definition model and ordered registry.
- Map each phase to required template artifacts.
- Build progress calculator (`generated_docs / 25`) with consistent counting rules.
- Add validation service to verify mandatory files before phase advance.
- Integrate phase status into project shell notifier/UI.
- Persist phase state in local storage/SQLite.
- Add RED→GREEN→REFACTOR tests for:
  - phase ordering,
  - mandatory file checks,
  - transition guards,
  - `Doc N/25` computation,
  - recovery/idempotency.

## 🔗 Dependencies

- `context/40-ROADMAP/USER_STORIES_MASTER.es.json`
- `packages/knowledge_base/01-TEMPLATES/*`
- `packages/knowledge_base/03-EXAMPLES/*`
- `context/20-REQUIREMENTS/*`
- `context/30-ARCHITECTURE/*`
- `AGENTS.md`

## 🏁 Definition of Done

- HU docs created (`README`, `PROGRESS`, `ARTIFACTS`, `WORKFLOW_MASTER_DEFINITION`).
- Workflow master approved as execution source for implementation.
- All phase rules documented with mandatory/optional artifacts.
- TDD plan established with measurable quality gates.

</div>

---

<div id="español">

## 📖 Tabla de Contenidos
- [Resumen](#resumen)
- [Valor de Negocio](#valor-de-negocio)
- [Alcance](#alcance)
- [Criterios de Aceptación](#criterios-de-aceptación)
- [Tareas Técnicas](#tareas-técnicas)
- [Dependencias](#dependencias)
- [Definición de Hecho](#definición-de-hecho)

---

## 🎯 Resumen

**HU ID:** HU-3.8
**Nombre:** Lógica real de fases de proyecto (Doc N/25 progress)

Como usuario, necesito que el workflow del proyecto avance por fases reales de documentación y actualice el progreso usando artefactos generados, para que el valor `Doc N/25` sea exacto y determinista.

## 💼 Valor de Negocio

- Elimina progreso simulado y lo sustituye por hitos objetivos basados en archivos.
- Alinea los entregables con las plantillas de la base de conocimiento.
- Permite quality gates claros antes de avanzar de fase.

## 📦 Alcance

Esta HU introduce un motor de fases basado en `packages/knowledge_base/01-TEMPLATES`:

1. `00-ROOT` (archivos en raíz)
2. `10-CONTEXT`
3. `20-REQUIREMENTS`
4. `30-ARCHITECTURE`
5. `35-UX_UI`
6. `40-PLANNING`
7. `99-META`

El progreso solo avanza cuando existen y validan los artefactos obligatorios de la fase actual.

## ✅ Criterios de Aceptación

| ID | Criterio | Resultado esperado |
|---|---|---|
| AC-1 | El modelo de fases replica la secuencia de plantillas | Flujo ordenado ROOT → 99-META |
| AC-2 | Se validan artefactos obligatorios por fase | No hay transición si faltan docs requeridos |
| AC-3 | `Doc N/25` se calcula desde artefactos reales generados | La UI muestra progreso determinista |
| AC-4 | ROOT aplica reglas de obligatoriedad en raíz | `AGENTS.md` y `README.md` obligatorios; extras configurables |
| AC-5 | Todas las fases no-ROOT exigen completitud del directorio | 100% de docs obligatorios antes de avanzar |
| AC-6 | La transición entre fases es idempotente y reanudable | Re-ejecución sin duplicar ni corromper artefactos |
| AC-7 | Errores explícitos y amigables | Faltantes/rutas inválidas se mapean a fallos controlados |
| AC-8 | Tests cubren reglas de fase y cálculo de progreso | Cobertura de módulo HU objetivo ≥90% |

## 🛠️ Tareas Técnicas

- Implementar modelo de fases y registro ordenado.
- Mapear cada fase a sus artefactos de plantilla obligatorios.
- Construir calculador de progreso (`documentos_generados / 25`) con reglas consistentes.
- Añadir servicio validador para verificar docs obligatorios antes de avanzar.
- Integrar estado de fase en notifier/UI de project shell.
- Persistir estado de fase en almacenamiento local/SQLite.
- Diseñar tests RED→GREEN→REFACTOR para:
  - orden de fases,
  - validación de docs obligatorios,
  - guards de transición,
  - cómputo `Doc N/25`,
  - recuperación/idempotencia.

## 🔗 Dependencias

- `context/40-ROADMAP/USER_STORIES_MASTER.es.json`
- `packages/knowledge_base/01-TEMPLATES/*`
- `packages/knowledge_base/03-EXAMPLES/*`
- `context/20-REQUIREMENTS/*`
- `context/30-ARCHITECTURE/*`
- `AGENTS.md`

## 🏁 Definición de Hecho

- Documentación base de HU creada (`README`, `PROGRESS`, `ARTIFACTS`, `WORKFLOW_MASTER_DEFINITION`).
- Workflow maestro definido como fuente de ejecución.
- Reglas de obligatoriedad por fase documentadas.
- Plan TDD establecido con quality gates medibles.

</div>
