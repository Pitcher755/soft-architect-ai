# HU-3.6: Test Suite Completion & i18n Implementation

> **Status:** 🟡 In Progress
> **Priority:** 🔴 High
> **Issue:** PIT-80
> **Branch:** `feature/test-suite-sqlite-fix`
> **Assignee:** ArchitectZero (Agent)

---

## 🌐 Language Selector | Selector de Idioma

<table>
<tr>
<td align="center"><strong><a href="#english">🇬🇧 English</a></strong></td>
<td align="center"><strong><a href="#español">🇪🇸 Español</a></strong></td>
</tr>
</table>

---

<div id="english">

# 🇬🇧 English Version

## 📋 Table of Contents

- [Overview](#overview)
- [Objectives](#objectives)
- [Completion Criteria](#completion-criteria)
- [Technical Scope](#technical-scope)
- [Documentation](#documentation)
- [Related Files](#related-files)

---

## 🎯 Overview

Complete the test suite for the entire application, fix SQLite persistence issues, and implement full internationalization (i18n) support for Spanish and English with a language selector in the settings screen.

This HU will NOT be considered complete until:
- ✅ All Python tests pass (unit, integration, E2E)
- ✅ All Flutter tests pass (unit, widget, integration, E2E)
- ✅ SQLite persistence works correctly with full test coverage
- ✅ Entire UI/UX is translated to ES/EN
- ✅ Language selector is functional in settings
- ✅ All CI/CD workflows pass
- ✅ Test coverage >80% for business logic

---

## 🎯 Objectives

### 1. **Test Suite Completion**
- Fix all failing Python tests (unit, integration)
- Fix all failing Flutter tests (unit, widget, integration, E2E)
- Achieve >80% code coverage for domain and data layers
- Ensure all tests are deterministic (no flaky tests)
- Add missing tests for uncovered critical paths

### 2. **SQLite Persistence Fix**
- Debug and fix all SQLite-related test failures
- Ensure proper transaction handling
- Validate CRUD operations in isolation
- Add comprehensive persistence integration tests
- Test concurrent access scenarios

### 3. **i18n Implementation**
- Set up Flutter l10n infrastructure
- Translate all UI strings to English and Spanish
- Implement language selector in settings screen
- Persist user language preference
- Ensure no hardcoded strings remain in UI

### 4. **Quality Assurance**
- All workflows must pass (backend-ci, lint, performance-tests)
- Zero security violations (Ruff, Bandit, OWASP compliance)
- Zero type errors (Pyright, Dart Analyzer)
- Code formatted (Black, Dart format)
- Documentation updated

---

## ✅ Completion Criteria

### **Definition of Done (DoD)**

#### Testing
- [ ] All Python unit tests pass (pytest)
- [ ] All Python integration tests pass
- [ ] All Flutter unit tests pass (flutter test)
- [ ] All Flutter widget tests pass
- [ ] All Flutter integration tests pass
- [ ] All E2E tests pass (both Python and Flutter)
- [ ] Test coverage ≥80% for business logic
- [ ] No flaky tests (all tests deterministic)
- [ ] Performance benchmarks meet targets (<200ms UI latency)

#### SQLite Persistence
- [ ] All SQLite tests pass
- [ ] CRUD operations validated
- [ ] Transaction handling tested
- [ ] Concurrent access tested
- [ ] Migration scripts validated
- [ ] No data integrity issues

#### Internationalization (i18n)
- [ ] Flutter l10n configured (intl, flutter_localizations)
- [ ] All UI strings extracted to .arb files
- [ ] Spanish translation complete (es.arb)
- [ ] English translation complete (en.arb)
- [ ] Language selector implemented in settings
- [ ] User preference persisted (SharedPreferences/SQLite)
- [ ] App restarts with selected language
- [ ] No hardcoded strings in UI widgets

#### CI/CD & Quality Gates
- [ ] backend-ci.yaml passes (Python tests, lint, type check)
- [ ] lint.yml passes (Flutter lint, Dart analysis)
- [ ] performance-tests.yml passes (streaming, SQLite benchmarks)
- [ ] No Ruff violations (S-codes, F-codes)
- [ ] No Pylance/Pyright errors
- [ ] Code formatted (Black, Dart format)
- [ ] Security audit passes (Bandit, OWASP checklist)

#### Documentation
- [ ] README.md updated (bilingual)
- [ ] PROGRESS.md completed (6 phases)
- [ ] ARTIFACTS.md manifest created
- [ ] WORKFLOW_MASTER_DEFINITION.md created
- [ ] TEST_RESULTS.md documented
- [ ] I18N_IMPLEMENTATION_GUIDE created
- [ ] SQLITE_FIX_REPORT created

---

## 🔧 Technical Scope

### **Python (Backend)**

#### Test Files to Fix/Complete:
```
tests/python/unit/
  ├── api/websocket/test_streaming_handler.py
  ├── services/streaming/test_token_buffer.py
  ├── core/performance/test_metrics_collector.py
  └── domain/streaming/test_stream_protocol.py

tests/python/integration/
  ├── test_streaming_flow.py
  ├── test_sqlite_persistence.py  # NEW
  └── test_end_to_end_workflow.py  # NEW
```

#### SQLite Modules:
```
src/server/app/infrastructure/persistence/
  ├── sqlite_repository.py  # FIX
  ├── migrations/  # VALIDATE
  └── transaction_manager.py  # ADD
```

---

### **Flutter (Frontend)**

#### Test Files to Fix/Complete:
```
tests/test/unit/
  ├── core/buffer/circular_buffer_test.dart
  ├── features/chat/auto_scroll_controller_test.dart
  ├── features/chat/presentation/providers/streaming_provider_test.dart
  └── features/settings/presentation/notifiers/settings_notifier_test.dart  # NEW

tests/test/widget/
  ├── features/chat/presentation/widgets/streaming_message_widget_test.dart
  ├── features/settings/presentation/screens/settings_screen_test.dart  # NEW
  └── core/widgets/language_selector_test.dart  # NEW

tests/test/integration/
  ├── features/chat/streaming_flow_test.dart
  ├── features/settings/language_switch_flow_test.dart  # NEW
  └── features/filesystem/sqlite_persistence_flow_test.dart  # NEW

tests/test/e2e/
  └── features/filesystem/project_creation_e2e_test.dart
```

#### i18n Infrastructure:
```
src/client/lib/l10n/
  ├── app_en.arb  # NEW
  ├── app_es.arb  # NEW
  └── l10n.yaml  # NEW

src/client/lib/core/localization/
  ├── app_localizations.dart  # GENERATED
  └── locale_provider.dart  # NEW
```

---

## 📚 Documentation

### **Files to Create:**

1. **WORKFLOW_MASTER_DEFINITION.md** - Complete 6-phase workflow
2. **PROGRESS.md** - Phase tracking checklist
3. **ARTIFACTS.md** - Manifest of all files to generate
4. **TEST_RESULTS.md** - Test execution reports
5. **I18N_IMPLEMENTATION_GUIDE.md** - i18n setup and usage guide
6. **SQLITE_FIX_REPORT.md** - SQLite debugging and fixes log
7. **COMPLETION_SUMMARY.md** - Final report (EN/ES)

---

## 🔗 Related Files

### Configuration
- [`pubspec.yaml`](../../../src/client/pubspec.yaml) - Flutter dependencies
- [`pyproject.toml`](../../../pyproject.toml) - Python project config
- [`pyrightconfig.json`](../../../pyrightconfig.json) - Type checking config

### Workflows
- [`.github/workflows/backend-ci.yaml`](../../../.github/workflows/backend-ci.yaml)
- [`.github/workflows/lint.yml`](../../../.github/workflows/lint.yml)
- [`.github/workflows/performance-tests.yml`](../../../.github/workflows/performance-tests.yml)

### Documentation
- [AGENTS.md](../../../AGENTS.md) - Agent rules and guidelines
- [SECURITY_HARDENING_POLICY](../../../context/SECURITY_HARDENING_POLICY.en.md)

---

## 🚀 Getting Started

```bash
# Checkout branch
git checkout feature/test-suite-sqlite-fix

# Install dependencies
flutter pub get
cd src/client && flutter pub get && cd ../..
pip install -r requirements.txt

# Run tests
pytest tests/python/ --cov=src/server/app -q
flutter test tests/test/

# Check quality gates
black --check src/server/
ruff check src/server/
python -m pyright src/server/
```

---

[⬆ Back to Top](#-english-version) | [🇪🇸 Ver en Español](#español)

</div>

---

<div id="español">

# 🇪🇸 Versión en Español

## 📋 Tabla de Contenidos

- [Resumen](#resumen)
- [Objetivos](#objetivos-1)
- [Criterios de Finalización](#criterios-de-finalización)
- [Alcance Técnico](#alcance-técnico)
- [Documentación](#documentación-1)
- [Archivos Relacionados](#archivos-relacionados)

---

## 🎯 Resumen

Completar la suite de pruebas para toda la aplicación, arreglar problemas de persistencia SQLite e implementar soporte completo de internacionalización (i18n) para español e inglés con selector de idioma en la pantalla de configuración.

Esta HU NO se considerará completa hasta que:
- ✅ Todos los tests de Python pasen (unit, integration, E2E)
- ✅ Todos los tests de Flutter pasen (unit, widget, integration, E2E)
- ✅ La persistencia SQLite funcione correctamente con cobertura completa
- ✅ Toda la UI/UX esté traducida a ES/EN
- ✅ El selector de idioma sea funcional en configuración
- ✅ Todos los workflows CI/CD pasen
- ✅ Cobertura de tests >80% para lógica de negocio

---

## 🎯 Objetivos

### 1. **Completar Suite de Pruebas**
- Arreglar todos los tests de Python que fallan (unit, integration)
- Arreglar todos los tests de Flutter que fallan (unit, widget, integration, E2E)
- Lograr >80% de cobertura de código para capas domain y data
- Asegurar que todos los tests sean determinísticos (sin flaky tests)
- Añadir tests faltantes para rutas críticas sin cobertura

### 2. **Arreglar Persistencia SQLite**
- Depurar y arreglar todos los fallos relacionados con SQLite
- Asegurar manejo correcto de transacciones
- Validar operaciones CRUD en aislamiento
- Añadir tests de integración exhaustivos para persistencia
- Probar escenarios de acceso concurrente

### 3. **Implementar i18n**
- Configurar infraestructura Flutter l10n
- Traducir todos los strings de UI a inglés y español
- Implementar selector de idioma en pantalla de configuración
- Persistir preferencia de idioma del usuario
- Asegurar que no queden strings hardcodeados en UI

### 4. **Aseguramiento de Calidad**
- Todos los workflows deben pasar (backend-ci, lint, performance-tests)
- Cero violaciones de seguridad (Ruff, Bandit, cumplimiento OWASP)
- Cero errores de tipo (Pyright, Dart Analyzer)
- Código formateado (Black, Dart format)
- Documentación actualizada

---

## ✅ Criterios de Finalización

### **Definition of Done (DoD)**

#### Testing
- [ ] Todos los tests unitarios de Python pasan (pytest)
- [ ] Todos los tests de integración de Python pasan
- [ ] Todos los tests unitarios de Flutter pasan (flutter test)
- [ ] Todos los tests de widget de Flutter pasan
- [ ] Todos los tests de integración de Flutter pasan
- [ ] Todos los tests E2E pasan (Python y Flutter)
- [ ] Cobertura de tests ≥80% para lógica de negocio
- [ ] Sin flaky tests (todos los tests determinísticos)
- [ ] Benchmarks de rendimiento cumplen objetivos (<200ms latencia UI)

#### Persistencia SQLite
- [ ] Todos los tests de SQLite pasan
- [ ] Operaciones CRUD validadas
- [ ] Manejo de transacciones probado
- [ ] Acceso concurrente probado
- [ ] Scripts de migración validados
- [ ] Sin problemas de integridad de datos

#### Internacionalización (i18n)
- [ ] Flutter l10n configurado (intl, flutter_localizations)
- [ ] Todos los strings de UI extraídos a archivos .arb
- [ ] Traducción al español completa (es.arb)
- [ ] Traducción al inglés completa (en.arb)
- [ ] Selector de idioma implementado en configuración
- [ ] Preferencia de usuario persistida (SharedPreferences/SQLite)
- [ ] App reinicia con idioma seleccionado
- [ ] Sin strings hardcodeados en widgets de UI

#### CI/CD y Quality Gates
- [ ] backend-ci.yaml pasa (tests Python, lint, type check)
- [ ] lint.yml pasa (Flutter lint, Dart analysis)
- [ ] performance-tests.yml pasa (streaming, benchmarks SQLite)
- [ ] Sin violaciones Ruff (S-codes, F-codes)
- [ ] Sin errores Pylance/Pyright
- [ ] Código formateado (Black, Dart format)
- [ ] Auditoría de seguridad pasa (Bandit, checklist OWASP)

#### Documentación
- [ ] README.md actualizado (bilingüe)
- [ ] PROGRESS.md completado (6 fases)
- [ ] ARTIFACTS.md manifest creado
- [ ] WORKFLOW_MASTER_DEFINITION.md creado
- [ ] TEST_RESULTS.md documentado
- [ ] I18N_IMPLEMENTATION_GUIDE creado
- [ ] SQLITE_FIX_REPORT creado

---

## 🔧 Alcance Técnico

### **Python (Backend)**

#### Archivos de Test a Arreglar/Completar:
```
tests/python/unit/
  ├── api/websocket/test_streaming_handler.py
  ├── services/streaming/test_token_buffer.py
  ├── core/performance/test_metrics_collector.py
  └── domain/streaming/test_stream_protocol.py

tests/python/integration/
  ├── test_streaming_flow.py
  ├── test_sqlite_persistence.py  # NUEVO
  └── test_end_to_end_workflow.py  # NUEVO
```

#### Módulos SQLite:
```
src/server/app/infrastructure/persistence/
  ├── sqlite_repository.py  # ARREGLAR
  ├── migrations/  # VALIDAR
  └── transaction_manager.py  # AÑADIR
```

---

### **Flutter (Frontend)**

#### Archivos de Test a Arreglar/Completar:
```
tests/test/unit/
  ├── core/buffer/circular_buffer_test.dart
  ├── features/chat/auto_scroll_controller_test.dart
  ├── features/chat/presentation/providers/streaming_provider_test.dart
  └── features/settings/presentation/notifiers/settings_notifier_test.dart  # NUEVO

tests/test/widget/
  ├── features/chat/presentation/widgets/streaming_message_widget_test.dart
  ├── features/settings/presentation/screens/settings_screen_test.dart  # NUEVO
  └── core/widgets/language_selector_test.dart  # NUEVO

tests/test/integration/
  ├── features/chat/streaming_flow_test.dart
  ├── features/settings/language_switch_flow_test.dart  # NUEVO
  └── features/filesystem/sqlite_persistence_flow_test.dart  # NUEVO

tests/test/e2e/
  └── features/filesystem/project_creation_e2e_test.dart
```

#### Infraestructura i18n:
```
src/client/lib/l10n/
  ├── app_en.arb  # NUEVO
  ├── app_es.arb  # NUEVO
  └── l10n.yaml  # NUEVO

src/client/lib/core/localization/
  ├── app_localizations.dart  # GENERADO
  └── locale_provider.dart  # NUEVO
```

---

## 📚 Documentación

### **Archivos a Crear:**

1. **WORKFLOW_MASTER_DEFINITION.md** - Workflow completo de 6 fases
2. **PROGRESS.md** - Checklist de seguimiento de fases
3. **ARTIFACTS.md** - Manifest de todos los archivos a generar
4. **TEST_RESULTS.md** - Reportes de ejecución de tests
5. **I18N_IMPLEMENTATION_GUIDE.md** - Guía de configuración y uso de i18n
6. **SQLITE_FIX_REPORT.md** - Log de depuración y arreglos de SQLite
7. **COMPLETION_SUMMARY.md** - Reporte final (EN/ES)

---

## 🔗 Archivos Relacionados

### Configuración
- [`pubspec.yaml`](../../../src/client/pubspec.yaml) - Dependencias Flutter
- [`pyproject.toml`](../../../pyproject.toml) - Configuración proyecto Python
- [`pyrightconfig.json`](../../../pyrightconfig.json) - Configuración type checking

### Workflows
- [`.github/workflows/backend-ci.yaml`](../../../.github/workflows/backend-ci.yaml)
- [`.github/workflows/lint.yml`](../../../.github/workflows/lint.yml)
- [`.github/workflows/performance-tests.yml`](../../../.github/workflows/performance-tests.yml)

### Documentación
- [AGENTS.md](../../../AGENTS.md) - Reglas y guías del agente
- [SECURITY_HARDENING_POLICY](../../../context/SECURITY_HARDENING_POLICY.es.md)

---

## 🚀 Comenzar

```bash
# Cambiar a rama
git checkout feature/test-suite-sqlite-fix

# Instalar dependencias
flutter pub get
cd src/client && flutter pub get && cd ../..
pip install -r requirements.txt

# Ejecutar tests
pytest tests/python/ --cov=src/server/app -q
flutter test tests/test/

# Verificar quality gates
black --check src/server/
ruff check src/server/
python -m pyright src/server/
```

---

[⬆ Volver Arriba](#-versión-en-español) | [🇬🇧 See in English](#english)

</div>
