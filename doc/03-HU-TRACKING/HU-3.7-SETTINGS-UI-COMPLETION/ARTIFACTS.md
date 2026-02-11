# HU-3.7: Artifacts Manifest

> **Historia de Usuario:** Settings UI Completion & Widget Tests
> **Fecha:** 11/02/2026
> **Total de Archivos:** 40+ (23 new, 17 modified)

---

## 📋 Table of Contents
- [Documentation](#documentation)
- [Domain Layer](#domain-layer)
- [Data Layer](#data-layer)
- [Presentation Layer](#presentation-layer)
- [Tests](#tests)
- [Configuration](#configuration)
- [Verification](#verification)

---

## 📚 Documentation

| File | Type | Status | Description |
|------|------|--------|-------------|
| `doc/03-HU-TRACKING/HU-3.7-SETTINGS-UI-COMPLETION/README.md` | NEW | ✅ Created | Bilingual HU overview |
| `doc/03-HU-TRACKING/HU-3.7-SETTINGS-UI-COMPLETION/PROGRESS.md` | NEW | ✅ Created | 6-phase checklist |
| `doc/03-HU-TRACKING/HU-3.7-SETTINGS-UI-COMPLETION/ARTIFACTS.md` | NEW | ✅ Created | This file manifest |
| `doc/INDEX.md` | MODIFIED | ⏳ Pending | Add HU-3.7 reference |

---

## 🧠 Domain Layer

### Entities
| File | Type | Status | Description |
|------|------|--------|-------------|
| `src/client/lib/features/settings/domain/entities/settings_entity.dart` | NEW | ⏳ Pending | Main settings entity (\@immutable) |
| `src/client/lib/features/settings/domain/entities/language_preference.dart` | NEW | ⏳ Pending | Enum: en, es |
| `src/client/lib/features/settings/domain/entities/theme_preference.dart` | NEW | ⏳ Pending | Enum: dark, light, system |
| `src/client/lib/features/settings/domain/entities/accessibility_settings.dart` | NEW | ⏳ Pending | Value object: font size, contrast |
| `src/client/lib/features/settings/domain/entities/performance_settings.dart` | NEW | ⏳ Pending | Value object: cache, memory |

### Use Cases
| File | Type | Status | Description |
|------|------|--------|-------------|
| `src/client/lib/features/settings/domain/usecases/load_settings_usecase.dart` | NEW | ⏳ Pending | Load settings from repository |
| `src/client/lib/features/settings/domain/usecases/save_settings_usecase.dart` | NEW | ⏳ Pending | Save settings to repository |
| `src/client/lib/features/settings/domain/usecases/update_language_usecase.dart` | NEW | ⏳ Pending | Update language preference |
| `src/client/lib/features/settings/domain/usecases/update_storage_path_usecase.dart` | NEW | ⏳ Pending | Update storage path with validation |
| `src/client/lib/features/settings/domain/usecases/load_last_project_usecase.dart` | NEW | ⏳ Pending | Load last opened project path |
| `src/client/lib/features/settings/domain/usecases/save_last_project_usecase.dart` | NEW | ⏳ Pending | Save last opened project path |

### Repositories (Interfaces)
| File | Type | Status | Description |
|------|------|--------|-------------|
| `src/client/lib/features/settings/domain/repositories/i_settings_repository.dart` | NEW | ⏳ Pending | Settings repository contract |
| `src/client/lib/features/settings/domain/repositories/i_last_project_repository.dart` | NEW | ⏳ Pending | Last project repository contract |

---

## 💾 Data Layer

### Data Sources
| File | Type | Status | Description |
|------|------|--------|-------------|
| `src/client/lib/features/settings/data/datasources/settings_local_datasource.dart` | NEW | ⏳ Pending | SharedPreferences wrapper |
| `src/client/lib/features/settings/data/datasources/file_picker_datasource.dart` | NEW | ⏳ Pending | file_picker package wrapper |
| `src/client/lib/features/settings/data/datasources/last_project_local_datasource.dart` | NEW | ⏳ Pending | Last project persistence |

### DTOs (Data Transfer Objects)
| File | Type | Status | Description |
|------|------|--------|-------------|
| `src/client/lib/features/settings/data/models/settings_dto.dart` | NEW | ⏳ Pending | JSON serialization model |
| `src/client/lib/features/settings/data/models/settings_mapper.dart` | NEW | ⏳ Pending | DTO ↔ Entity mapper |

### Repository Implementations
| File | Type | Status | Description |
|------|------|--------|-------------|
| `src/client/lib/features/settings/data/repositories/settings_repository_impl.dart` | NEW | ⏳ Pending | ISettingsRepository implementation |
| `src/client/lib/features/settings/data/repositories/last_project_repository_impl.dart` | NEW | ⏳ Pending | ILastProjectRepository implementation |

---

## 🎨 Presentation Layer

### State Management (Riverpod)
| File | Type | Status | Description |
|------|------|--------|-------------|
| `src/client/lib/features/settings/presentation/providers/settings_provider.dart` | NEW | ⏳ Pending | StateNotifierProvider for settings |
| `src/client/lib/features/settings/presentation/providers/last_project_provider.dart` | NEW | ⏳ Pending | StateProvider for last project |
| `src/client/lib/features/settings/presentation/notifiers/settings_notifier.dart` | NEW | ⏳ Pending | StateNotifier implementation |

### Screens
| File | Type | Status | Description |
|------|------|--------|-------------|
| `src/client/lib/features/settings/presentation/screens/settings_screen.dart` | MODIFIED | ⏳ Pending | Main settings screen (already exists) |

### Widgets - Settings Sections
| File | Type | Status | Description |
|------|------|--------|-------------|
| `src/client/lib/features/settings/presentation/widgets/profile_section.dart` | MODIFIED | ⏳ Pending | Add persistence logic |
| `src/client/lib/features/settings/presentation/widgets/storage_section.dart` | MODIFIED | ⏳ Pending | Implement file_picker (TODO-2) |
| `src/client/lib/features/settings/presentation/widgets/appearance_section.dart` | MODIFIED | ⏳ Pending | Add persistence + language selector |
| `src/client/lib/features/settings/presentation/widgets/accessibility_section.dart` | MODIFIED | ⏳ Pending | Add persistence logic |
| `src/client/lib/features/settings/presentation/widgets/performance_section.dart` | MODIFIED | ⏳ Pending | Add persistence logic |
| `src/client/lib/features/settings/presentation/widgets/language_selector_widget.dart` | NEW | ⏳ Pending | 🇬🇧 / 🇪🇸 toggle widget |

### Widgets - Navigation
| File | Type | Status | Description |
|------|------|--------|-------------|
| `src/client/lib/shared/presentation/widgets/global_search_dialog.dart` | MODIFIED | ⏳ Pending | Add navigation on result click |
| `src/client/lib/shared/presentation/widgets/projects_sidebar.dart` | MODIFIED | ⏳ Pending | Show last opened project |

---

## ✅ Tests

### Unit Tests - Domain Layer
| File | Type | Status | Description |
|------|------|--------|-------------|
| `tests/test/features/settings/domain/entities/settings_entity_test.dart` | NEW | ⏳ Pending | Test entity creation, equality |
| `tests/test/features/settings/domain/usecases/load_settings_usecase_test.dart` | NEW | ⏳ Pending | Test use case success/failure |
| `tests/test/features/settings/domain/usecases/save_settings_usecase_test.dart` | NEW | ⏳ Pending | Test use case success/failure |
| `tests/test/features/settings/domain/usecases/update_language_usecase_test.dart` | NEW | ⏳ Pending | Test language update |
| `tests/test/features/settings/domain/usecases/update_storage_path_usecase_test.dart` | NEW | ⏳ Pending | Test path validation |

### Unit Tests - Data Layer
| File | Type | Status | Description |
|------|------|--------|-------------|
| `tests/test/features/settings/data/models/settings_dto_test.dart` | NEW | ⏳ Pending | Test JSON serialization |
| `tests/test/features/settings/data/models/settings_mapper_test.dart` | NEW | ⏳ Pending | Test DTO ↔ Entity mapping |
| `tests/test/features/settings/data/datasources/settings_local_datasource_test.dart` | NEW | ⏳ Pending | Test SharedPreferences wrapper |
| `tests/test/features/settings/data/datasources/file_picker_datasource_test.dart` | NEW | ⏳ Pending | Test file picker wrapper |
| `tests/test/features/settings/data/repositories/settings_repository_impl_test.dart` | NEW | ⏳ Pending | Test repository implementation |

### Widget Tests - Settings UI (7 tests - T-3)
| File | Type | Status | Description |
|------|------|--------|-------------|
| `tests/test/features/settings/presentation/widgets/profile_section_test.dart` | NEW | ⏳ Pending | Test user profile editing |
| `tests/test/features/settings/presentation/widgets/storage_section_test.dart` | NEW | ⏳ Pending | Test folder picker |
| `tests/test/features/settings/presentation/widgets/appearance_section_test.dart` | NEW | ⏳ Pending | Test theme toggle |
| `tests/test/features/settings/presentation/widgets/accessibility_section_test.dart` | NEW | ⏳ Pending | Test accessibility controls |
| `tests/test/features/settings/presentation/widgets/performance_section_test.dart` | NEW | ⏳ Pending | Test performance controls |
| `tests/test/features/settings/presentation/screens/settings_screen_test.dart` | NEW | ⏳ Pending | Test full screen integration |
| `tests/test/features/settings/presentation/widgets/language_selector_widget_test.dart` | NEW | ⏳ Pending | Test language toggle (ES/EN) |

### Widget Test - GlobalSearchDialog (1 test - T-4)
| File | Type | Status | Description |
|------|------|--------|-------------|
| `tests/test/shared/presentation/widgets/global_search_dialog_test.dart` | NEW | ⏳ Pending | Test search + navigation |

### Widget Tests - MarkdownPreview (Fix 10 failing - T-2)
| File | Type | Status | Description |
|------|------|--------|-------------|
| `tests/test/features/project_shell/presentation/widgets/markdown_preview_widget_test.dart` | MODIFIED | ⏳ Pending | Refactor and fix 10 failing tests |

### Integration Tests
| File | Type | Status | Description |
|------|------|--------|-------------|
| `tests/test/features/settings/integration/settings_persistence_test.dart` | NEW | ⏳ Pending | Test end-to-end persistence flow |
| `tests/test/features/settings/integration/language_change_test.dart` | NEW | ⏳ Pending | Test language change + UI update |
| `tests/test/shared/integration/last_project_navigation_test.dart` | NEW | ⏳ Pending | Test last project persistence + sidebar |

---

## ⚙️ Configuration

| File | Type | Status | Description |
|------|------|--------|-------------|
| `src/client/pubspec.yaml` | MODIFIED | ⏳ Pending | Add dependencies: file_picker, shared_preferences, flutter_svg (optional) |
| `src/client/analysis_options.yaml` | VERIFIED | ✅ No changes | Ensure linter rules active |
| `.gitignore` | VERIFIED | ✅ No changes | Ensure coverage/ ignored |

---

## 🔍 Verification

### Pre-Merge Checklist Files
| File | Type | Status | Description |
|------|------|--------|-------------|
| `doc/03-HU-TRACKING/HU-3.7-SETTINGS-UI-COMPLETION/COVERAGE_REPORT.md` | NEW | ⏳ Pending | Generated after Phase 5 |
| `doc/03-HU-TRACKING/HU-3.7-SETTINGS-UI-COMPLETION/TEST_RESULTS.md` | NEW | ⏳ Pending | Generated after Phase 5 |
| `doc/03-HU-TRACKING/HU-3.7-SETTINGS-UI-COMPLETION/DARTDOC_OUTPUT.md` | NEW | ⏳ Pending | Generated after Phase 6 |

---

## 📊 Summary Statistics

| Category | New Files | Modified Files | Total |
|----------|-----------|----------------|-------|
| **Documentation** | 3 | 1 | 4 |
| **Domain Layer** | 11 | 0 | 11 |
| **Data Layer** | 7 | 0 | 7 |
| **Presentation Layer** | 4 | 8 | 12 |
| **Tests** | 17 | 1 | 18 |
| **Configuration** | 0 | 1 | 1 |
| **Verification** | 3 | 0 | 3 |
| **TOTAL** | **45** | **11** | **56** |

---

## 🗂️ File Tree Structure (Expected Final State)

```
src/client/lib/features/settings/
├── domain/
│   ├── entities/
│   │   ├── settings_entity.dart
│   │   ├── language_preference.dart
│   │   ├── theme_preference.dart
│   │   ├── accessibility_settings.dart
│   │   └── performance_settings.dart
│   ├── usecases/
│   │   ├── load_settings_usecase.dart
│   │   ├── save_settings_usecase.dart
│   │   ├── update_language_usecase.dart
│   │   ├── update_storage_path_usecase.dart
│   │   ├── load_last_project_usecase.dart
│   │   └── save_last_project_usecase.dart
│   └── repositories/
│       ├── i_settings_repository.dart
│       └── i_last_project_repository.dart
├── data/
│   ├── datasources/
│   │   ├── settings_local_datasource.dart
│   │   ├── file_picker_datasource.dart
│   │   └── last_project_local_datasource.dart
│   ├── models/
│   │   ├── settings_dto.dart
│   │   └── settings_mapper.dart
│   └── repositories/
│       ├── settings_repository_impl.dart
│       └── last_project_repository_impl.dart
└── presentation/
    ├── providers/
    │   ├── settings_provider.dart
    │   └── last_project_provider.dart
    ├── notifiers/
    │   └── settings_notifier.dart
    ├── screens/
    │   └── settings_screen.dart (MODIFIED)
    └── widgets/
        ├── profile_section.dart (MODIFIED)
        ├── storage_section.dart (MODIFIED)
        ├── appearance_section.dart (MODIFIED)
        ├── accessibility_section.dart (MODIFIED)
        ├── performance_section.dart (MODIFIED)
        └── language_selector_widget.dart (NEW)

tests/test/features/settings/
├── domain/
│   ├── entities/
│   │   └── settings_entity_test.dart
│   └── usecases/
│       ├── load_settings_usecase_test.dart
│       ├── save_settings_usecase_test.dart
│       ├── update_language_usecase_test.dart
│       └── update_storage_path_usecase_test.dart
├── data/
│   ├── models/
│   │   ├── settings_dto_test.dart
│   │   └── settings_mapper_test.dart
│   ├── datasources/
│   │   ├── settings_local_datasource_test.dart
│   │   └── file_picker_datasource_test.dart
│   └── repositories/
│       └── settings_repository_impl_test.dart
├── presentation/
│   ├── widgets/
│   │   ├── profile_section_test.dart
│   │   ├── storage_section_test.dart
│   │   ├── appearance_section_test.dart
│   │   ├── accessibility_section_test.dart
│   │   ├── performance_section_test.dart
│   │   └── language_selector_widget_test.dart
│   └── screens/
│       └── settings_screen_test.dart
└── integration/
    ├── settings_persistence_test.dart
    ├── language_change_test.dart
    └── last_project_navigation_test.dart

tests/test/shared/
└── presentation/
    └── widgets/
        └── global_search_dialog_test.dart (NEW)
```

---

## 🔐 Security Checklist

- [ ] No hardcoded file paths
- [ ] Input sanitization on file paths
- [ ] SharedPreferences keys namespaced (`settings.*`, `lastProject.*`)
- [ ] No sensitive data logged
- [ ] file_picker validated against directory traversal
- [ ] Error messages don't leak internal paths

---

## 📝 Notes

### File Naming Conventions
- **Entities:** `*_entity.dart` (e.g., `settings_entity.dart`)
- **Use Cases:** `*_usecase.dart` (e.g., `load_settings_usecase.dart`)
- **Repositories:** `i_*_repository.dart` (interface), `*_repository_impl.dart` (implementation)
- **Data Sources:** `*_datasource.dart` (e.g., `settings_local_datasource.dart`)
- **DTOs:** `*_dto.dart` (e.g., `settings_dto.dart`)
- **Providers:** `*_provider.dart` (e.g., `settings_provider.dart`)
- **Notifiers:** `*_notifier.dart` (e.g., `settings_notifier.dart`)
- **Widgets:** `*_widget.dart` or `*_section.dart` (e.g., `language_selector_widget.dart`)
- **Tests:** `*_test.dart` (mirrors source file name)

### DartDoc Requirements
All files MUST include:
- Class-level documentation comment (`///`)
- Method-level documentation comments (public APIs)
- Parameter descriptions (if not obvious)
- Return value descriptions
- Example usage (for complex APIs)

### Test Coverage Targets
- **Domain Layer:** 100% (pure business logic)
- **Data Layer:** >90% (repository implementations)
- **Presentation Layer:** >85% (widgets, state management)
- **Overall Settings Feature:** >90%

---

**Last Updated:** 11/02/2026 by ArchitectZero
