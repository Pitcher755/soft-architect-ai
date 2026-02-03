# 📚 HU-3.1: Project Shell IDE-like UI - Documentación Completa

> **Estado:** 📋 ANÁLISIS COMPLETADO
> **Estimación:** XL (13 pts)
> **Branch:** feature/pit-62-hu-31-como-usuario-quiero-una-interfaz-ide-like
> **Linear:** https://linear.app/pitcherdev/issue/PIT-62

---

## 🎯 Quick Navigation

### Para Entender la HU (5 minutos)
- **[LINEAR ISSUE](https://linear.app/pitcherdev/issue/PIT-62)** - Descripción oficial
- **[HU-3.1_WORKFLOW_ANALYSIS.md](HU-3.1_WORKFLOW_ANALYSIS.md)** - Análisis profundo

### Para Implementar (cuando sea el momento)
1. **[HU-3.1_TEST_PLAN_RED_PHASE.md](HU-3.1_TEST_PLAN_RED_PHASE.md)** - Leer primero para TDD
2. **[HU-3.1_SECURITY_AND_QUALITY_CHECKLIST.md](HU-3.1_SECURITY_AND_QUALITY_CHECKLIST.md)** - Reglas de calidad
3. **WORKFLOW_ANALYSIS.md § Workflow de Implementación** - Paso a paso semanal

---

## 📋 Resumen Ejecutivo

### ¿Qué es HU-3.1?

Interfaz IDE-like para gestionar proyectos con:
- Árbol de directorios expandible (estilo VS Code)
- Preview Markdown en tiempo real
- Búsqueda de archivos
- Creación de proyectos con validación
- Persistencia de estado en SQLite

### Requisitos Críticos

| Categoría | Requisito | Prioridad |
|-----------|-----------|-----------|
| **Funcional** | Árbol de directorios con expand/collapse | 🔴 CRÍTICA |
| **Funcional** | Preview Markdown renderizado | 🔴 CRÍTICA |
| **Funcional** | Crear proyectos con validación | 🔴 CRÍTICA |
| **Funcional** | Búsqueda en tiempo real | 🟡 ALTA |
| **No Funcional** | Tests ≥80% coverage | 🔴 CRÍTICA |
| **Seguridad** | Path traversal prevention | 🔴 CRÍTICA |
| **Performance** | Rendimiento con 100+ archivos | 🟡 ALTA |

### Arquitectura (Clean Architecture)

```
Presentation (Widgets + Riverpod)
    ↓
Application (State Notifiers)
    ↓
Domain (Entities + UseCases)
    ↓
Data (Repositories + DataSources)
```

---

## 🏗️ Estructura de Carpetas (A Crear)

```
src/client/lib/features/project_shell/
├── domain/
│   ├── entities/
│   │   ├── project.dart
│   │   └── file_node.dart
│   ├── repositories/
│   │   └── project_repository.dart
│   └── use_cases/
│       ├── project_validation_use_case.dart
│       ├── directory_tree_use_case.dart
│       └── file_search_use_case.dart
├── data/
│   ├── data_sources/
│   │   ├── sqlite_data_source.dart
│   │   └── file_system_data_source.dart
│   ├── models/
│   │   ├── project_model.dart
│   │   └── file_node_model.dart
│   └── repositories/
│       └── project_repository_impl.dart
└── presentation/
    ├── notifiers/
    │   ├── project_shell_notifier.dart
    │   ├── directory_tree_notifier.dart
    │   └── file_search_notifier.dart
    ├── providers/
    │   └── project_shell_providers.dart
    ├── widgets/
    │   ├── screens/
    │   │   └── project_shell_screen.dart
    │   ├── components/
    │   │   ├── directory_tree.dart
    │   │   ├── markdown_preview.dart
    │   │   ├── project_toolbar.dart
    │   │   └── file_search_bar.dart
    │   └── styles/
    │       └── project_shell_theme.dart
    └── models/
        └── project_shell_state.dart

tests/
├── unit/
│   ├── domain/
│   │   ├── project_validation_use_case_test.dart
│   │   ├── directory_tree_use_case_test.dart
│   │   └── file_search_use_case_test.dart
│   ├── data/
│   │   ├── sqlite_data_source_test.dart
│   │   └── project_repository_impl_test.dart
│   └── presentation/
│       └── project_shell_notifier_test.dart
├── widget/
│   ├── directory_tree_widget_test.dart
│   ├── markdown_preview_widget_test.dart
│   └── project_shell_screen_test.dart
├── mocks/
│   ├── mock_project_repository.dart
│   ├── mock_sqlite_data_source.dart
│   └── mock_file_system_service.dart
└── fixtures/
    ├── project_fixtures.dart
    └── file_node_fixtures.dart
```

---

## 📖 Índice de Documentos

### 1. Análisis Profundo
**[HU-3.1_WORKFLOW_ANALYSIS.md](HU-3.1_WORKFLOW_ANALYSIS.md)**
- Análisis de requisitos (8 RF + 6 RNF)
- Arquitectura Clean Architecture
- Estrategia TDD con ciclo RED → GREEN → REFACTOR
- Plan de seguridad (path traversal, logging)
- Workflow de implementación (4 fases, 8 sprints)
- Checklist de calidad

**📋 Secciones principales:**
- § 1: Análisis de Requisitos (Matriz)
- § 2: Arquitectura (Diagrama + Componentes)
- § 3: Estrategia TDD (Test coverage map)
- § 4: Plan de Seguridad
- § 5: Workflow de Implementación (Semana 1-4)
- § 6: Checklist de Calidad

---

### 2. Plan de Tests RED Phase
**[HU-3.1_TEST_PLAN_RED_PHASE.md](HU-3.1_TEST_PLAN_RED_PHASE.md)**
- 6 tests iniciales que fallan
- Código de tests completo (copypasteable)
- Mocks necesarios
- Fixtures para testing

**📋 Tests incluidos:**
- Test 1: Project Creation & Validation
- Test 2: Directory Tree Expansion Logic
- Test 3: File Search Filtering
- Test 4: SQLite Persistence
- Test 5: Project Repository
- Test 6: Riverpod State Management

**Para copiar y pegar en proyecto:**
```bash
cp HU-3.1_TEST_PLAN_RED_PHASE.md
# Extraer secciones de código
# Crear archivos en tests/
```

---

### 3. Seguridad & Calidad
**[HU-3.1_SECURITY_AND_QUALITY_CHECKLIST.md](HU-3.1_SECURITY_AND_QUALITY_CHECKLIST.md)**
- Type Safety (Pyright, Dart annotations)
- Path Traversal Prevention (código de validación)
- Logging Security (cómo loguear sin exponer paths)
- Error Handling (Exception hierarchy)
- Linting Rules (analysis_options.yaml)
- Coverage Requirements (80%+)
- Pre-commit Checklist

**🔐 Reglas críticas:**
- NO hardcoded paths
- ALL functions con return types
- NO `dynamic` sin justificación
- Path validation obligatorio
- 100% custom exception handling

---

## 🚀 Workflow Implementación (Cuando Confirmes)

### FASE 1: Setup (Semana 1 - 4 días)
- Sprint 1.1: Infrastructure & Test Setup (2 días)
- Sprint 1.2: Entidades & Validación (2 días)

**Deliverable:** Estructura lista + 6 tests RED

---

### FASE 2: Repositories & Data (Semana 2 - 4 días)
- Sprint 2.1: SQLite Persistence (2 días)
- Sprint 2.2: FileSystem Service Bridge (2 días)

**Deliverable:** Data layer con >90% coverage

---

### FASE 3: Presentation (Semana 3 - 7 días)
- Sprint 3.1: Riverpod State (2 días)
- Sprint 3.2: Core Widgets (3 días)
- Sprint 3.3: Search & Integration (2 días)

**Deliverable:** UI funcional + widgets tests

---

### FASE 4: Testing & Polish (Semana 4 - 4 días)
- Sprint 4.1: Unit & Widget Tests (2 días)
- Sprint 4.2: Integration & Docs (2 días)

**Deliverable:** ≥80% coverage + Docs completas

---

## 🧪 Cómo Usar Este Análisis

### Para Tech Lead o Code Review

1. Lee [HU-3.1_WORKFLOW_ANALYSIS.md](HU-3.1_WORKFLOW_ANALYSIS.md) completo (30 min)
2. Verifica checklist de arquitectura
3. Aprueba plan de testing
4. Revisa security rules

### Para Desarrollador (Cuando Inicie)

1. Importa los 6 tests de [HU-3.1_TEST_PLAN_RED_PHASE.md](HU-3.1_TEST_PLAN_RED_PHASE.md)
2. Sigue [HU-3.1_WORKFLOW_ANALYSIS.md § Workflow](HU-3.1_WORKFLOW_ANALYSIS.md#workflow-de-implementación)
3. Valida contra [HU-3.1_SECURITY_AND_QUALITY_CHECKLIST.md](HU-3.1_SECURITY_AND_QUALITY_CHECKLIST.md) antes de cada commit
4. Corre tests: `flutter test --coverage`

### Para DevOps o CI/CD

Pre-commit validation:
```bash
cd src/client

# Type check
flutter analyze lib/features/project_shell/

# Linting
dart fix --apply lib/features/project_shell/

# Tests
flutter test --coverage

# Coverage threshold
lcov --summary coverage/lcov.info | grep "lines" | awk '{print $2}'
# Must be >= 80%
```

---

## 📊 Estado del Análisis

| Documento | Secciones | Status |
|-----------|-----------|--------|
| HU-3.1_WORKFLOW_ANALYSIS.md | 6 | ✅ COMPLETO |
| HU-3.1_TEST_PLAN_RED_PHASE.md | 6 tests | ✅ COMPLETO |
| HU-3.1_SECURITY_AND_QUALITY_CHECKLIST.md | 7 checklist | ✅ COMPLETO |
| README.md (este) | Navigation | ✅ COMPLETO |

**Total:** ~8,000 palabras de análisis + código

---

## 🎯 Próximos Pasos

### Estado Actual: 📋 ANÁLISIS COMPLETADO

**Esperando confirmación:**

```
✅ CONFORME - Proceder a crear estructura
❌ CAMBIOS NECESARIOS - Especifica cuáles
🤔 PREGUNTAS - Formula dudas
```

**Una vez confirmado:**
1. Crearé estructura de carpetas
2. Escribiré 6 tests RED
3. Crearé mocks
4. Prepararé para fase GREEN

---

## 📞 Referencias

- **Linear Issue:** PIT-62
- **AGENTS.md:** Reglas de arquitectura y testing
- **context/30-ARCHITECTURE/:** Especificaciones técnicas
- **Dependencias:** HU-3.2 (Backend FileSystemService)

---

**Documento:** HU-3.1 Implementation Plan
**Versión:** 1.0
**Fecha:** 03/02/2026
**Autor:** ArchitectZero (GitHub Copilot)
