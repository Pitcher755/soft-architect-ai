# 🚀 WORKFLOW MAESTRO: HU-3.8 - Lógica real de fases de proyecto (Doc N/25)

> **Fecha:** 12/02/2026
> **Rama:** `feature/project_phase_logic`
> **Epic:** E3 - Core UI & Business Logic
> **Prioridad:** 🔥 **Alta**
> **Metodología:** TDD Estricto (RED → GREEN → REFACTOR)
> **Nivel de Riesgo:** Medio-Alto (impacta progreso real y estado del Project Shell)
> **Fuente de verdad:** `context/40-ROADMAP/USER_STORIES_MASTER.es.json`

---

## 📖 Tabla de Contenidos

1. [Objetivos Estratégicos](#objetivos-estratégicos)
2. [Criterios de Aceptación (Definition of Done)](#criterios-de-aceptación-definition-of-done)
3. [Fases Reales del RAG de Documentación](#fases-reales-del-rag-de-documentación)
4. [Fase 0: Preparación del Terreno](#fase-0-preparación-del-terreno)
5. [Fase 1: TDD - ROJO (Dominio)](#fase-1-tdd---rojo-dominio)
6. [Fase 2: TDD - VERDE (Dominio + Data mínima)](#fase-2-tdd---verde-dominio--data-mínima)
7. [Fase 3: TDD - REFACTOR (Calidad + Seguridad)](#fase-3-tdd---refactor-calidad--seguridad)
8. [Fase 4: Integración de Estado (Riverpod)](#fase-4-integración-de-estado-riverpod)
9. [Fase 5: Integración UI (Dashboard + Badge)](#fase-5-integración-ui-dashboard--badge)
10. [Fase 6: Validación Final CI/CD](#fase-6-validación-final-cicd)
11. [Matriz AC ↔ Tests ↔ Archivos](#matriz-ac--tests--archivos)
12. [Entregables Finales](#entregables-finales)

---

## 🎯 Objetivos Estratégicos

### 1. Detección real de fase (0-6)
- Escanear artefactos reales de proyecto en disco, no mocks.
- Determinar fase actual según completitud secuencial de documentos.
- Soportar estructura canónica de `01-TEMPLATES`.

### 2. Progreso dinámico `Doc N/25`
- Calcular `N` desde documentos detectados realmente.
- Refrescar progreso al abrir proyecto y al actualizar contexto.
- Mantener coherencia entre progreso numérico y fase mostrada.

### 3. Badge de fase en Project Shell
- Mostrar fase real actual en `WorkspaceHeader`/vista principal.
- Evitar desfases entre badge y barra de progreso.

### 4. Robustez de calidad
- Cobertura en módulo HU-3.8 >90% en unit tests de detección de fase.
- Mapeo de errores controlado (sin stack traces en UI).

---

## ✅ Criterios de Aceptación (Definition of Done)

### POSITIVOS (Debe tener)
- ✅ `ProjectPhaseService` detecta fase actual (0-6) desde árbol `context/` y raíz.
- ✅ `Doc N/25` se calcula dinámicamente con archivos reales.
- ✅ Badge de fase refleja estado real del proyecto activo.
- ✅ Tests de detección de fase/progreso con cobertura objetivo >90% en módulo HU.

### NEGATIVOS (No debe)
- ❌ No usar valores mock hardcodeados para progreso.
- ❌ No avanzar fase cuando faltan documentos obligatorios de fase previa.
- ❌ No realizar lógica de negocio directamente en widgets.

---

## 🧭 Fases Reales del RAG de Documentación

Estas son las fases por las que pasa el usuario en SoftArchitect AI (flujo de documentación guiada):

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

---

## 🔧 Fase 0: Preparación del Terreno

### 0.1 Sincronización de rama
```bash
git checkout develop
git pull origin develop
git checkout -b feature/project_phase_logic
```

### 0.2 Definir mapa de verdad
- Crear/validar constantes de estructura de fases y documentos esperados (25 docs).
- Unificar naming para soportar rutas legacy donde aplique.

### 0.3 Preparar pruebas objetivo
- Suite unitaria de dominio HU-3.8.
- Fixtures temporales de filesystem para simular proyectos.

**Checklist Fase 0**
- [x] Rama de trabajo lista
- [x] Mapa de fases documentado
- [x] Plan TDD definido

---

## 🔴 Fase 1: TDD - ROJO (Dominio)

**Objetivo:** tests que fallen por ausencia de lógica real.

### 1.1 Tests de cálculo por lista de archivos
Archivo objetivo:
- `tests/client/unit/features/project_shell/domain/services/project_phase_service_test.dart`

Casos mínimos:
1. Lista vacía → fase 0, `Doc 0/25`.
2. Root + Context completos → fase 1.
3. Documentos dispersos → cálculo exacto `N/25`.
4. Falta obligatorio de fase actual → no avanza de fase.

### 1.2 Tests de escaneo real de disco
- Proyecto temporal con archivos reales creados en runtime.
- Verificar que `analyzeProject(path)` detecta fase esperada.

**Checklist Fase 1**
- [x] Casos RED de fase/progreso escritos
- [x] Casos RED de escaneo real escritos

---

## 🟢 Fase 2: TDD - VERDE (Dominio + Data mínima)

**Objetivo:** implementar código mínimo para pasar tests.

### 2.1 Servicio de fase/progreso
Archivo objetivo:
- `src/client/lib/features/project_shell/domain/services/project_phase_service.dart`

Implementación mínima:
- `calculateProgress(List<String> filePaths)`
- `analyzeProject(String projectPath)`
- Conversión de índice de fase a `ProjectPhase`.

### 2.2 Constantes de estructura
Archivo objetivo:
- `src/client/lib/features/project_shell/core/constants/project_structure_constants.dart`

Implementación mínima:
- Definición de fases, docs obligatorios/opcionales.
- Total esperado de docs = 25.

**Checklist Fase 2**
- [x] Cálculo `Doc N/25` implementado
- [x] Detección de fase secuencial implementada
- [x] Escaneo de archivos implementado

---

## 🔵 Fase 3: TDD - REFACTOR (Calidad + Seguridad)

**Objetivo:** mejorar diseño sin romper tests.

### 3.1 Seguridad de rutas
- Integrar validación con `PathValidator` para proyecto raíz.
- Evitar rutas absolutas maliciosas y traversal.

### 3.2 Limpieza de API
- Mantener compatibilidad de métodos públicos usados por UI existente.
- Centralizar lógica de matching documento/fase.

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
- `src/client/lib/features/project_shell/presentation/notifiers/project_shell_notifier.dart`
- `src/client/lib/features/project_shell/presentation/providers/project_providers.dart`

Tareas:
- Añadir carga de estado de fase/progreso para proyecto activo.
- Manejar estados `loading / data / error`.

### 4.2 Tests de estado
- Crear tests unitarios de notifier para actualización de progreso.

**Checklist Fase 4**
- [ ] Provider de progreso implementado
- [ ] Tests de notifier en verde

---

## 🖥️ Fase 5: Integración UI (Dashboard + Badge)

**Objetivo:** reflejar estado real en interfaz.

### 5.1 Dashboard
Archivos objetivo:
- `src/client/lib/features/project_shell/presentation/widgets/workspace_header.dart`
- `src/client/lib/features/project_shell/presentation/widgets/projects_grid.dart`

Tareas:
- Mostrar `Doc N/25` dinámico.
- Mostrar badge de fase real.

### 5.2 Tests widget
- Añadir pruebas para render de progreso y badge según estado del provider.

**Checklist Fase 5**
- [ ] `Doc N/25` visible y dinámico
- [ ] Badge fase actualizado en tiempo real
- [ ] Tests widget en verde

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
- [ ] Tests unit/widget en verde
- [ ] Gate maestro pre-push en verde
- [ ] Evidencia AC completa

---

## 🔬 Matriz AC ↔ Tests ↔ Archivos

| AC | Test clave | Archivos principales |
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
- Integración notifier/provider/UI para progreso y fase.

### Tests
- `tests/client/unit/features/project_shell/domain/services/project_phase_service_test.dart`
- Tests notifier/provider HU-3.8
- Tests widget de progreso y badge

### Documentación
- `doc/03-HU-TRACKING/HU-3.8-PROJECT-PHASE-LOGIC/PROGRESS.md`
- `doc/03-HU-TRACKING/HU-3.8-PROJECT-PHASE-LOGIC/WORKFLOW_MASTER_DEFINITION.es.md`
- Evidencia final AC y cobertura

---

## 🎉 Estado de completitud del workflow

- **Workflow definido al 100% para ejecución HU-3.8** ✅
- **Fases 0-3 iniciadas en código (TDD dominio + base de escaneo)** ✅
- **Pendiente para cierre HU:** Fases 4-6 (estado/UI + validación final) 🚧
