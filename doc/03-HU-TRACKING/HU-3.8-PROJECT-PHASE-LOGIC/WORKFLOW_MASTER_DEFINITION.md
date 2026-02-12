# HU-3.8 WORKFLOW MASTER DEFINITION

> **Fecha:** 12/02/2026
> **Estado:** 🚧 Draft de ejecución
> **Metodología:** TDD estricto (RED → GREEN → REFACTOR)
> **HU:** Lógica real de fases de proyecto (Doc N/25 progress)

## 📖 Tabla de Contenidos
- [1. Propósito](#1-propósito)
- [2. Principios Obligatorios](#2-principios-obligatorios)
- [3. Mapa de Fases del Proyecto](#3-mapa-de-fases-del-proyecto)
- [4. Definición de Completitud por Fase](#4-definición-de-completitud-por-fase)
- [5. Plan de Ejecución TDD por Fases](#5-plan-de-ejecución-tdd-por-fases)
- [6. Quality & Security Gates](#6-quality--security-gates)
- [7. Criterios de Aceptación HU-3.8 → Pruebas](#7-criterios-de-aceptación-hu-38--pruebas)
- [8. Entregables de Cierre](#8-entregables-de-cierre)

---

## 1. Propósito

Implementar un motor de fases real para Project Shell donde el avance `Doc N/25` se derive de artefactos efectivamente generados, siguiendo la estructura de `packages/knowledge_base/01-TEMPLATES` y sus ejemplos de `03-EXAMPLES`.

---

## 2. Principios Obligatorios

1. **Local-first y offline:** ningún cálculo depende de servicios cloud.
2. **Clean Architecture:** reglas en dominio; IO/adaptadores aislados.
3. **No transición sin completitud:** una fase no avanza con documentos obligatorios faltantes.
4. **Idempotencia:** re-ejecutar validación no rompe estado ni duplica artefactos.
5. **Errores controlados:** mensajes amigables, sin stack traces al usuario.
6. **TDD estricto:** cada regla nueva entra primero con test en rojo.

---

## 3. Mapa de Fases del Proyecto

### Fase 1 — `00-ROOT`
- Se generan en raíz del proyecto objetivo.
- **Obligatorios:** `AGENTS.md`, `README.md`
- **Opcionales:** `RULES.md`, `CONTRIBUTING.md`

### Fase 2 — `10-CONTEXT`
- Directorio obligatorio completo.
- Documentos obligatorios:
  - `DOMAIN_LANGUAGE.md`
  - `PROJECT_MANIFESTO.md`
  - `USER_JOURNEY_MAP.md`

### Fase 3 — `20-REQUIREMENTS`
- Directorio obligatorio completo.
- Documentos obligatorios:
  - `COMPLIANCE_MATRIX.md`
  - `REQUIREMENTS_MASTER.md`
  - `SECURITY_PRIVACY_POLICY.md`
  - `USER_STORIES_MASTER.json`

### Fase 4 — `30-ARCHITECTURE`
- Directorio obligatorio completo.
- Documentos obligatorios:
  - `API_INTERFACE_CONTRACT.md`
  - `ARCH_DECISION_RECORDS.md`
  - `DATA_MODEL_SCHEMA.md`
  - `PROJECT_STRUCTURE_MAP.md`
  - `SECURITY_THREAT_MODEL.md`
  - `TECH_STACK_DECISION.md`

### Fase 5 — `35-UX_UI`
- Directorio obligatorio completo.
- Documentos obligatorios:
  - `ACCESSIBILITY_GUIDE.md`
  - `DESIGN_SYSTEM.md`
  - `UI_WIREFRAMES_FLOW.md`

### Fase 6 — `40-PLANNING`
- Directorio obligatorio completo.
- Documentos obligatorios:
  - `CI_CD_PIPELINE.md`
  - `DEPLOYMENT_INFRASTRUCTURE.md`
  - `ROADMAP_PHASES.md`
  - `TESTING_STRATEGY.md`

### Fase 7 — `99-META`
- Directorio obligatorio completo.
- Documento obligatorio:
  - `CONTEXT_GENERATOR_PROMPT.md`

---

## 4. Definición de Completitud por Fase

Una fase se considera **COMPLETA** si y solo si:

1. Existe el contenedor esperado (raíz o directorio de fase).
2. Existen todos los documentos obligatorios definidos para esa fase.
3. El validador de estructura no detecta faltantes.
4. La persistencia de estado registra transición válida `phase_k -> phase_k+1`.

Regla de progreso:
- `N` en `Doc N/25` = total de documentos obligatorios generados y validados.
- Si falta un documento obligatorio de una fase previa, se degrada el estado a la última fase válida.

---

## 5. Plan de Ejecución TDD por Fases

## Fase A — RED 1 (Modelo de fases)

### Paso A1
- Crear tests para orden estricto de fases ROOT→99-META.
- Esperado: fallan por ausencia de modelo.

### Paso A2
- Crear tests de cardinalidad de documentos obligatorios por fase.
- Esperado: fallan con errores de mapeo inexistente.

### Paso A3
- Crear tests de reglas ROOT (2 obligatorios + opcionales).
- Esperado: fallan por falta de validación diferencial.

## Fase B — GREEN 1 (Implementación mínima)

### Paso B1
- Implementar modelo `ProjectPhase` + catálogo de requisitos por fase.

### Paso B2
- Implementar validador mínimo `isPhaseComplete(phase, filesystemSnapshot)`.

### Paso B3
- Hacer pasar tests RED 1 sin sobre-ingeniería.

## Fase C — RED 2 (Progreso real)

### Paso C1
- Tests de cálculo `Doc N/25` para casos nominales y bordes.

### Paso C2
- Tests de degradación cuando falta artefacto obligatorio de fase anterior.

### Paso C3
- Tests de idempotencia (doble evaluación no cambia resultado indebidamente).

## Fase D — GREEN 2 (Calculador de progreso)

### Paso D1
- Implementar servicio de cómputo de progreso desde snapshot real.

### Paso D2
- Integrar persistencia de fase en repositorio/data source.

### Paso D3
- Hacer pasar RED 2.

## Fase E — REFACTOR

### Paso E1
- Limpiar duplicación entre mapeos de plantilla y validación.

### Paso E2
- Introducir value objects y errores tipados de dominio.

### Paso E3
- Revisar naming, complejidad ciclomática y contratos públicos.

## Fase F — Integración UI

### Paso F1
- Integrar cálculo en notifier de Project Shell.

### Paso F2
- Mostrar fase actual + progreso `Doc N/25` en UI.

### Paso F3
- Añadir tests widget/integration para flujos de transición.

## Fase G — Cierre

### Paso G1
- Ejecutar quality gates locales según AGENTS.

### Paso G2
- Verificar AC-1..AC-8 con evidencia trazable.

### Paso G3
- Actualizar documentación de HU y preparar PR.

---

## 6. Quality & Security Gates

1. `flutter analyze` sin errores.
2. Tests de dominio y data para lógica de fases en verde.
3. Cobertura objetivo de módulo HU validada.
4. Validación de rutas segura (sin traversal, sin hardcoding).
5. Sin exponer errores internos en capa UI.
6. Cumplimiento de documentación `doc as code`.

---

## 7. Criterios de Aceptación HU-3.8 → Pruebas

- **AC-1/AC-2:** tests unitarios de orden y obligatoriedad por fase.
- **AC-3:** tests de cálculo `Doc N/25` con fixtures de filesystem.
- **AC-4/AC-5:** tests específicos de ROOT vs fases no-ROOT.
- **AC-6:** test de idempotencia y reanudación.
- **AC-7:** tests de mapeo de errores a mensajes controlados.
- **AC-8:** reporte de cobertura sobre servicios de fase/progreso.

---

## 8. Entregables de Cierre

- Evidencias AC-1..AC-8 en reporte HU.
- Suite de tests HU-3.8 estable y repetible.
- Actualización del índice de HU tracking.
- PR con resumen técnico, riesgos y plan de rollback.
