# HU-3.6: Artifacts Manifest

> **Purpose:** Comprehensive list of all archivos to be creard, modified, or generated during HU-3.6 implementación.
> **Estado:** 📋 Planificación
> **Last Updated:** 2026-02-10

---

## 📂 Archivo Categories

- [Documentoation](#-documentoation)
- [Python Backend](#-python-backend)
- [Flutter Frontend](#-flutter-frontend)
- [Configuración](#️-configuración)
- [Pruebas](#-pruebas)
- [CI/CD](#-cicd)

---

## 📚 Documentoation

### HU Tracking Documentos
```
doc/03-HU-TRACKING/HU-3.6_TEST_SUITE_I18N/
├── README.md                           ✅ CREATED
├── PROGRESS.md                         ✅ CREATED
├── ARTIFACTS.md                        ✅ CREATED (this file)
├── WORKFLOW_MASTER_DEFINITION.md       🔄 TO CREATE
├── TEST_FAILURE_ANALYSIS.md            🔄 TO CREATE (Phase 1)
├── SQLITE_INVESTIGATION_REPORT.md      🔄 TO CREATE (Phase 1)
├── I18N_ARCHITECTURE_DESIGN.md         🔄 TO CREATE (Phase 1)
├── TEST_RESULTS.md                     🔄 TO CREATE (Phase 5)
├── SQLITE_FIX_REPORT.md                🔄 TO CREATE (Phase 5)
├── I18N_IMPLEMENTATION_GUIDE.en.md     🔄 TO CREATE (Phase 5)
├── I18N_IMPLEMENTATION_GUIDE.es.md     🔄 TO CREATE (Phase 5)
├── METRICS_REPORT.md                   🔄 TO CREATE (Phase 5)
├── SECURITY_AUDIT_REPORT.md            🔄 TO CREATE (Phase 5)
├── PERFORMANCE_BENCHMARKS.md           🔄 TO CREATE (Phase 5)
├── COMPLETION_SUMMARY.en.md            🔄 TO CREATE (Phase 6)
└── COMPLETION_SUMMARY.es.md            🔄 TO CREATE (Phase 6)
```

### Technical Guides
```
doc/02-SETUP_DEV/
├── TESTING_BEST_PRACTICES.en.md        🔄 TO CREATE
├── TESTING_BEST_PRACTICES.es.md        🔄 TO CREATE
├── I18N_WORKFLOW_GUIDE.en.md           🔄 TO CREATE
├── I18N_WORKFLOW_GUIDE.es.md           🔄 TO CREATE
└── SQLITE_TROUBLESHOOTING.en.md        🔄 TO CREATE
```

---

## 🐍 Python Backend

### New Modules
```
src/server/app/infrastructure/persistence/
├── __init__.py                         🔄 TO CREATE
├── sqlite_repository.py                🔄 TO FIX (existing)
├── transaction_manager.py              🔄 TO CREATE
├── connection_pool.py                  🔄 TO CREATE (Phase 4)
└── migrations/
    ├── __init__.py                     🔄 TO VALIDATE
    ├── migration_001_initial.sql       🔄 TO VALIDATE
    └── migration_002_indexes.sql       🔄 TO CREATE (Phase 4)
```

### Updated Modules
```
src/server/app/
├── core/
│   ├── config.py                       🔄 TO UPDATE (SQLite config)
│   └── exceptions.py                   🔄 TO UPDATE (add persistence errors)
│
├── domain/
│   └── repositories/
│       └── base_repository.py          🔄 TO UPDATE (add transaction support)
│
└── services/
    └── persistence/
        ├── __init__.py                 🔄 TO CREATE
        └── sqlite_service.py           🔄 TO CREATE
```

---

## 📱 Flutter Frontend

### i18n Infraestructura
```
src/client/lib/l10n/
├── l10n.yaml                           🔄 TO CREATE
├── app_en.arb                          🔄 TO CREATE
├── app_es.arb                          🔄 TO CREATE
└── README.md                           🔄 TO CREATE (usage guide)
```

### Localization Module
```
src/client/lib/core/localization/
├── locale_provider.dart                🔄 TO CREATE
├── locale_repository.dart              🔄 TO CREATE
├── locale_persistence.dart             🔄 TO CREATE (SharedPreferences)
└── app_localizations.dart              🔄 GENERATED (by flutter gen-l10n)
```

### Settings Feature (Updated)
```
src/client/lib/features/settings/
├── domain/
│   ├── entities/
│   │   └── user_preferences.dart      🔄 TO UPDATE (add locale)
│   └── repositories/
│       └── settings_repository.dart    🔄 TO UPDATE
│
├── data/
│   ├── repositories/
│   │   └── settings_repository_impl.dart 🔄 TO UPDATE
│   └── datasources/
│       └── settings_local_datasource.dart 🔄 TO UPDATE
│
└── presentation/
    ├── screens/
    │   └── settings_screen.dart        🔄 TO UPDATE (add language selector)
    ├── widgets/
    │   └── language_selector_widget.dart 🔄 TO CREATE
    ├── notifiers/
    │   └── settings_notifier.dart      🔄 TO UPDATE
    └── providers/
        └── settings_providers.dart     🔄 TO UPDATE
```

### UI Archivos to Update (Replace Hardcoded Strings)
```
src/client/lib/features/
├── chat/
│   └── presentation/
│       ├── screens/
│       │   └── chat_screen.dart        🔄 TO UPDATE
│       └── widgets/
│           ├── chat_input_widget.dart  🔄 TO UPDATE
│           └── message_bubble.dart     🔄 TO UPDATE
│
├── filesystem/
│   └── presentation/
│       ├── screens/
│       │   └── filesystem_screen.dart  🔄 TO UPDATE
│       └── widgets/
│           └── file_tree_widget.dart   🔄 TO UPDATE
│
└── project_shell/
    └── presentation/
        ├── screens/
        │   └── project_shell_screen.dart 🔄 TO UPDATE
        └── widgets/
            ├── directory_tree_widget.dart 🔄 TO UPDATE
            └── markdown_preview_widget.dart 🔄 TO UPDATE
```

---

## ⚙️ Configuración

### Flutter Configuración
```
src/client/
├── pubspec.yaml                        🔄 TO UPDATE (add intl, flutter_localizations)
├── analysis_options.yaml               🔄 TO UPDATE (if needed)
└── l10n.yaml                           🔄 TO CREATE
```

### Python Configuración
```
pyproject.toml                          🔄 TO UPDATE (if needed)
pyrightconfig.json                      🔄 TO UPDATE (if needed)
```

---

## 🧪 Pruebas

### Python Pruebas - New
```
tests/python/
├── unit/
│   ├── infrastructure/
│   │   └── persistence/
│   │       ├── test_transaction_manager.py      🔄 TO CREATE
│   │       ├── test_sqlite_repository.py        🔄 TO CREATE
│   │       └── test_connection_pool.py          🔄 TO CREATE
│   └── services/
│       └── persistence/
│           └── test_sqlite_service.py           🔄 TO CREATE
│
└── integration/
    ├── test_sqlite_persistence.py               🔄 TO CREATE
    ├── test_sqlite_concurrency.py               🔄 TO CREATE
    └── test_end_to_end_workflow.py              🔄 TO CREATE
```

### Python Pruebas - To Fix
```
tests/python/
├── unit/
│   ├── api/websocket/
│   │   └── test_streaming_handler.py            🔄 TO FIX
│   ├── services/streaming/
│   │   └── test_token_buffer.py                 🔄 TO FIX
│   └── core/performance/
│       └── test_metrics_collector.py            🔄 TO FIX
│
└── integration/
    └── test_streaming_flow.py                   🔄 TO FIX
```

### Flutter Pruebas - New
```
tests/test/
├── unit/
│   ├── core/localization/
│   │   └── locale_provider_test.dart            🔄 TO CREATE
│   └── features/settings/
│       └── presentation/notifiers/
│           └── settings_notifier_test.dart      🔄 TO CREATE
│
├── widget/
│   ├── core/widgets/
│   │   └── language_selector_test.dart          🔄 TO CREATE
│   └── features/settings/
│       └── presentation/screens/
│           └── settings_screen_test.dart        🔄 TO CREATE
│
├── integration/
│   ├── features/settings/
│   │   └── language_switch_flow_test.dart       🔄 TO CREATE
│   └── features/filesystem/
│       └── sqlite_persistence_flow_test.dart    🔄 TO CREATE
│
└── e2e/
    └── features/settings/
        └── settings_e2e_test.dart               🔄 TO CREATE
```

### Flutter Pruebas - To Fix
```
tests/test/
├── unit/
│   ├── core/buffer/
│   │   └── circular_buffer_test.dart            🔄 TO FIX
│   └── features/
│       ├── chat/
│       │   ├── auto_scroll_controller_test.dart 🔄 TO FIX
│       │   └── presentation/providers/
│       │       └── streaming_provider_test.dart 🔄 TO FIX
│       └── project_shell/
│           └── data/
│               ├── project_repository_impl_test.dart 🔄 TO FIX
│               └── sqlite_data_source_test.dart 🔄 TO FIX
│
├── widget/
│   └── features/
│       ├── chat/presentation/widgets/
│       │   └── streaming_message_widget_test.dart 🔄 TO FIX
│       └── project_shell/presentation/
│           ├── directory_tree_widget_test.dart  🔄 TO FIX
│           └── markdown_preview_widget_test.dart 🔄 TO FIX
│
├── integration/
│   └── features/
│       ├── chat/
│       │   ├── chat_flow_test.dart              🔄 TO FIX
│       │   └── streaming_flow_test.dart         🔄 TO FIX
│       └── filesystem/
│           └── filesystem_integration_test.dart 🔄 TO FIX
│
└── e2e/
    └── features/filesystem/
        └── project_creation_e2e_test.dart       🔄 TO FIX
```

### Prueba Helpers
```
tests/
├── python/
│   ├── conftest.py                              🔄 TO UPDATE
│   └── helpers/
│       ├── sqlite_fixtures.py                   🔄 TO CREATE
│       └── test_database.py                     🔄 TO CREATE
│
└── test/helpers/
    ├── locale_test_helpers.dart                 🔄 TO CREATE
    └── sqlite_test_helpers.dart                 🔄 TO CREATE
```

---

## 🔧 CI/CD

### Workflows - To Update
```
.github/workflows/
├── backend-ci.yaml                     🔄 TO UPDATE (add SQLite tests)
├── lint.yml                            🔄 TO UPDATE (if needed)
└── performance-tests.yml               🔄 TO UPDATE (add SQLite benchmarks)
```

### Workflows - New (Optional)
```
.github/workflows/
└── i18n-validation.yml                 🔄 TO CREATE (validate translations)
```

---

## 📊 Reports & Metrics

### Generated Reports
```
doc/03-HU-TRACKING/HU-3.6_TEST_SUITE_I18N/reports/
├── test_coverage_python.html           🔄 GENERATED (Phase 6)
├── test_coverage_flutter.html          🔄 GENERATED (Phase 6)
├── bandit_security_report.txt          🔄 GENERATED (Phase 4)
├── performance_benchmarks.json         🔄 GENERATED (Phase 4)
└── ci_cd_validation.log                🔄 GENERATED (Phase 6)
```

---

## 📈 Summary Statistics

### Archivos to Crear
- **Documentoation:** 17 archivos
- **Python Backend:** 8 archivos
- **Flutter Frontend:** 9 archivos
- **Configuración:** 3 archivos
- **Pruebas (New):** 18 archivos
- **Prueba Helpers:** 4 archivos
- **CI/CD:** 1-2 archivos
- **Reports:** 5 archivos

**Total New Archivos:** ~65 archivos

### Archivos to Modify
- **Python Backend:** 5 archivos
- **Flutter Frontend:** 25+ UI archivos
- **Pruebas (Fix):** 20+ prueba archivos
- **Configuración:** 3 archivos

**Total Modified Archivos:** ~53+ archivos

### Archivos to Generate
- **Flutter l10n:** 1 archivo (app_localizations.dart)
- **Reports:** 5 archivos

**Total Generated Archivos:** 6 archivos

---

## ✅ Checklist by Fase

### Fase 1: RED
- [ ] TEST_FAILURE_ANALYSIS.md
- [ ] SQLITE_INVESTIGATION_REPORT.md
- [ ] I18N_ARCHITECTURE_DESIGN.md

### Fase 2: GREEN
- [ ] All Python backend archivos (new + fixes)
- [ ] All Flutter frontend archivos (new + fixes)
- [ ] All prueba archivos (new + fixes)
- [ ] i18n infrastructure complete

### Fase 3: REFACTOR
- [ ] Code quality improvements applied
- [ ] Documentoation comments added

### Fase 4: OPTIMIZATION
- [ ] Performance optimizations applied
- [ ] Security audit report generated

### Fase 5: DOCUMENTATION
- [ ] All technical guides creard
- [ ] All reports generated
- [ ] Completion summaries creard

### Fase 6: VALIDATION
- [ ] CI/CD logs captured
- [ ] Final metrics documentoed

---

## 🔄 Change Log

| Date | Fase | Archivos Added | Archivos Modified | Notes |
|------|-------|-------------|----------------|-------|
| 2026-02-10 | 1 | 3 | 0 | Initial artifacts manifest creard |

---

## 📝 Notes

- All documentoation must be bilingual (EN/ES)
- All prueba archivos must follow naming conventions
- All generated archivos excluded from version control (add to .gitignore)
- Reports stored in HU tracking carpeta for historical reference
