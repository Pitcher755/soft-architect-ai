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
- [9. Plan de Implementación por Archivo](#9-plan-de-implementación-por-archivo)
- [10. Primera Iteración Ejecutable](#10-primera-iteración-ejecutable)

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

> **Fuente de verdad de HU-3.8:** `context/40-ROADMAP/USER_STORIES_MASTER.es.json`
>
> **Criterios HU-3.8 a cumplir sin ambigüedad:**
> 1) `ProjectPhaseService` detecta fase actual (0-6) escaneando carpetas `context/`.
> 2) Barra de progreso `Doc N/25` se actualiza dinámicamente en Dashboard.
> 3) Badge de fase en ProjectShell refleja estado real.
> 4) Tests unitarios de detección de fases >90% cobertura (módulo HU).

### Reglas de ejecución de esta HU

- Cada sub-fase RED debe terminar con tests fallando por la razón correcta.
- Cada sub-fase GREEN debe introducir el mínimo código para pasar.
- Cada sub-fase REFACTOR debe mantener tests verdes y mejorar diseño.
- Ningún paso de UI puede iniciarse sin tener dominio validado.

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

### Comandos obligatorios por iteración

```bash
# 1) Lint/analysis cliente
cd src/client && flutter analyze

# 2) Test unitarios enfocados HU-3.8 (ir ampliando patrón)
cd ../../tests && flutter test client/unit/features/project_shell/

# 3) Test widget/integration de project shell relacionados a progreso
flutter test client/widget/features/project_shell/
flutter test client/integration/features/project_shell/

# 4) Gate maestro antes de push
cd .. && ./scripts/PRE_PUSH_VALIDATION_MASTER.sh
```

### Reglas de calidad HU-3.8

- Cobertura de módulo de detección de fases/progreso: objetivo mínimo interno **90%**.
- Sin acoplar lógica de negocio en widgets (solo notifier/providers consumen servicios).
- Errores tipados y mensajes de UI amigables (sin stack trace).
- Mantenibilidad: mapeo de fases/documentos en un único punto de verdad.

---

## 7. Criterios de Aceptación HU-3.8 → Pruebas

- **AC-1/AC-2:** tests unitarios de orden y obligatoriedad por fase.
- **AC-3:** tests de cálculo `Doc N/25` con fixtures de filesystem.
- **AC-4/AC-5:** tests específicos de ROOT vs fases no-ROOT.
- **AC-6:** test de idempotencia y reanudación.
- **AC-7:** tests de mapeo de errores a mensajes controlados.
- **AC-8:** reporte de cobertura sobre servicios de fase/progreso.

### Matriz detallada AC ↔ Caso de prueba

| AC | Tipo de test | Caso mínimo | Resultado esperado |
|---|---|---|---|
| AC-1 | Unit (domain) | `detect_phase_from_context_tree` con estructura parcial/completa | Devuelve fase correcta 0-6 |
| AC-2 | Unit (domain/data) | `compute_doc_progress` con documentos crecientes | `N` avanza de forma monotónica válida |
| AC-3 | Widget | Dashboard con provider mockeado en cambios de snapshot | Texto `Doc N/25` se refresca en UI |
| AC-4 | Widget/Unit | Badge de fase con estado in-progress/completed/blocked | Badge refleja fase actual real |
| AC-5 | Unit | Comparativa `existing vs expected` por fase | Identifica faltantes exactos |
| AC-6 | Unit | Doble ejecución sobre mismo estado | Mismo resultado sin efectos colaterales |
| AC-7 | Unit/UI | Error de path inválido / estructura corrupta | Mensaje amigable y código de dominio |
| AC-8 | Coverage | Suite HU-3.8 dedicada | Cobertura módulo objetivo ≥90% |

---

## 8. Entregables de Cierre

- Evidencias AC-1..AC-8 en reporte HU.
- Suite de tests HU-3.8 estable y repetible.
- Actualización del índice de HU tracking.
- PR con resumen técnico, riesgos y plan de rollback.

---

## 9. Plan de Implementación por Archivo

> El siguiente inventario define el orden recomendado de trabajo para cumplir las tareas técnicas del roadmap HU-3.8.

### 9.1 Dominio

1. `src/client/lib/features/project_shell/domain/services/project_phase_service.dart`
  - Incorporar escaneo real de carpetas/documentos.
  - Exponer API pura para detección de fase y progreso.
2. `src/client/lib/features/project_shell/domain/repositories/project_repository.dart`
  - Asegurar contrato para recuperación de estado necesario (paths/context).

### 9.2 Data

1. `src/client/lib/features/project_shell/data/repositories/project_repository_impl.dart`
  - Implementar consulta de artefactos existentes vs esperados.
2. `src/client/lib/features/project_shell/data/data_sources/sqlite_data_source.dart`
  - Persistir estado de fase actual y timestamp de validación.
3. `src/client/lib/features/project_shell/data/models/project_model.dart`
  - Añadir/ajustar campos de fase/progreso si aplica.

### 9.3 Presentación

1. `src/client/lib/features/project_shell/presentation/notifiers/project_shell_notifier.dart`
  - Conectar `ProjectPhaseService` y refresco dinámico de progreso.
2. `src/client/lib/features/project_shell/presentation/widgets/workspace_header.dart`
  - Mostrar `Doc N/25` y badge de fase actual.
3. `src/client/lib/features/project_shell/presentation/widgets/projects_grid.dart`
  - Reflejar estado resumido por proyecto si aplica.

### 9.4 Tests objetivo

1. `tests/client/unit/features/project_shell/domain/services/project_phase_service_test.dart`
2. `tests/client/unit/features/project_shell/presentation/providers/project_providers_test.dart`
3. `tests/client/widget/features/project_shell/presentation/project_card_test.dart`
4. `tests/client/widget/features/project_shell/presentation/widgets/global_search_dialog_test.dart` (solo si impacto indirecto)

---

## 10. Primera Iteración Ejecutable

### Objetivo de la iteración 1

Entregar un primer corte vertical que cumpla AC-1 + AC-2 + AC-8 en dominio/data, dejando UI para iteración 2.

### Alcance iteración 1

1. Tests RED de detección de fase y cálculo `Doc N/25`.
2. Implementación mínima en `ProjectPhaseService`.
3. Ajuste de repositorio/data source para obtener snapshot de artefactos.
4. Cobertura de módulo HU ≥90% en suite unitaria de dominio.

### Criterio de salida iteración 1

- Tests unitarios HU-3.8 en verde.
- Cobertura de lógica de fase/progreso reportada y documentada.
- Sin cambios de UI aún (evita mezclar capas prematuramente).
