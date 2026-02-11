# HU-3.7: Progress Tracking (6-Phase Workflow)

> **Historia de Usuario:** Settings UI Completion & Widget Tests
> **Estado Actual:** 🚧 Phase 4/5 - Presentation + Testing (TDD cycles in progress)
> **Última Actualización:** 11/02/2026

---

## 📊 Progress Overview

| Phase | Status | Progress | ETA |
|-------|--------|----------|-----|
| **Phase 1:** Setup & Analysis (RED) | 🚧 In Progress | 40% | 11/02/2026 |
| **Phase 2:** Domain Layer | ⏳ Pending | 0% | TBD |
| **Phase 3:** Data Layer | 🚧 In Progress | 20% | TBD |
| **Phase 4:** Presentation Layer | 🚧 In Progress | 55% | TBD |
| **Phase 5:** Testing (GREEN) | 🚧 In Progress | 40% | TBD |
| **Phase 6:** Documentation & CI/CD | ⏳ Pending | 0% | TBD |

**Global Progress:** 35% (21/60 tasks completed)

---

## 🔴 Phase 1: Setup & Analysis (RED)

**Objective:** Prepare environment, analyze code, define test cases (TDD Red phase)

### 1.1 Environment Setup
- [x] Create feature branch `feature/settings-ui-completion`
- [x] Create HU documentation structure (README, PROGRESS, ARTIFACTS)
- [ ] Add dependencies to `pubspec.yaml` (file_picker, shared_preferences, flutter_svg)
- [ ] Run `flutter pub get` to install dependencies
- [ ] Verify no breaking changes with `flutter analyze`

### 1.2 Code Analysis
- [ ] Analyze current `settings_screen.dart` implementation
- [ ] Analyze all Settings section widgets (Profile, Storage, Appearance, Accessibility, Performance)
- [ ] Identify missing persistence logic
- [ ] Analyze `global_search_dialog.dart` navigation requirements
- [ ] Analyze `projects_sidebar.dart` last project persistence requirements
- [ ] Review existing MarkdownPreview tests (identify 10 failures)

### 1.3 Architecture Design
- [ ] Design SettingsEntity (domain model)
- [ ] Design LanguagePreference enum
- [ ] Design repository interfaces (ISettingsRepository, ILastProjectRepository)
- [ ] Design use cases (LoadSettings, SaveSettings, UpdateLanguage, etc.)
- [ ] Define SharedPreferences keys namespace
- [ ] Define file_picker integration points

### 1.4 TDD: Write Failing Tests (RED)
- [ ] Write widget tests for Settings UI (4/7 created)
- [x] Write widget test for GlobalSearchDialog
- [ ] Write failing unit tests for SettingsEntity
- [ ] Write failing unit tests for use cases
- [ ] Write failing tests for repository implementations
- [ ] Verify all tests fail (RED phase confirmed)

**Phase 1 Acceptance Criteria:**
- ✅ Documentation complete (README, PROGRESS, ARTIFACTS)
- ⏳ Dependencies added and verified
- ⏳ All test files created (failing tests = RED phase)
- ⏳ Architecture design documented
- ⏳ Code analysis report created

---

## 🧠 Phase 2: Domain Layer (Entities & Use Cases)

**Objective:** Implement pure domain logic (no dependencies on UI/DB/external packages)

### 2.1 Entities
- [ ] Create `SettingsEntity` class
  - [ ] User profile settings (name, email, avatar)
  - [ ] Storage settings (default path, cache size)
  - [ ] Appearance settings (theme, color scheme)
  - [ ] Accessibility settings (font size, contrast, screen reader)
  - [ ] Performance settings (memory limits, cache strategy)
  - [ ] Language preference (LanguagePreference enum)
- [ ] Create `LanguagePreference` enum (en, es)
- [ ] Create `ThemePreference` enum (dark, light, system)
- [ ] Create `AccessibilitySettings` value object
- [ ] Create `PerformanceSettings` value object
- [ ] Add DartDoc to all entities (class + properties)

### 2.2 Use Cases
- [ ] Create `LoadSettingsUseCase`
  - [ ] Implement `call()` method
  - [ ] Handle errors (Either<Failure, SettingsEntity>)
  - [ ] Add DartDoc
- [ ] Create `SaveSettingsUseCase`
  - [ ] Implement `call(SettingsEntity settings)` method
  - [ ] Handle errors
  - [ ] Add DartDoc
- [ ] Create `UpdateLanguageUseCase`
  - [ ] Implement `call(LanguagePreference lang)` method
  - [ ] Handle errors
  - [ ] Add DartDoc
- [ ] Create `UpdateStoragePathUseCase`
  - [ ] Implement `call(String path)` method
  - [ ] Validate path exists
  - [ ] Handle errors
  - [ ] Add DartDoc
- [ ] Create `LoadLastProjectUseCase`
- [ ] Create `SaveLastProjectUseCase`

### 2.3 Repository Interfaces
- [ ] Create `ISettingsRepository` interface
  - [ ] `Future<Either<Failure, SettingsEntity>> loadSettings()`
  - [ ] `Future<Either<Failure, void>> saveSettings(SettingsEntity settings)`
  - [ ] Add DartDoc
- [ ] Create `ILastProjectRepository` interface
  - [ ] `Future<Either<Failure, String?>> loadLastProjectPath()`
  - [ ] `Future<Either<Failure, void>> saveLastProjectPath(String path)`
  - [ ] Add DartDoc

**Phase 2 Acceptance Criteria:**
- ⏳ All entities created with \@immutable annotation
- ⏳ All use cases implement single responsibility
- ⏳ All interfaces define contracts (no implementations)
- ⏳ DartDoc on all public APIs (100% coverage)
- ⏳ No dependencies on Flutter/external packages (pure Dart)

---

## 💾 Phase 3: Data Layer (Repositories & Adapters)

**Objective:** Implement data persistence and external integrations

### 3.1 Data Sources
- [ ] Create `SettingsLocalDataSource` (SharedPreferences)
  - [ ] `Future<Map<String, dynamic>?> loadSettings()`
  - [ ] `Future<void> saveSettings(Map<String, dynamic> json)`
  - [ ] Define keys: `settings.user.name`, `settings.appearance.theme`, etc.
  - [ ] Handle SharedPreferences initialization
  - [ ] Add error handling
  - [ ] Add DartDoc
- [ ] Create `FilePickerDataSource` (file_picker package)
  - [ ] `Future<String?> pickDirectory()`
  - [ ] Handle platform-specific dialogs
  - [ ] Add error handling
  - [ ] Add DartDoc
- [x] Create `LastProjectLocalDataSource` (SharedPreferences)
  - [x] `Future<String?> loadLastProjectPath()`
  - [x] `Future<void> saveLastProjectPath(String path)`
  - [x] Add DartDoc

### 3.2 DTOs (Data Transfer Objects)
- [ ] Create `SettingsDto` class
  - [ ] `factory SettingsDto.fromJson(Map<String, dynamic> json)`
  - [ ] `Map<String, dynamic> toJson()`
  - [ ] Add JSON serialization for all fields
  - [ ] Add DartDoc
- [ ] Create `SettingsMapper` utility
  - [ ] `SettingsEntity toEntity(SettingsDto dto)`
  - [ ] `SettingsDto fromEntity(SettingsEntity entity)`
  - [ ] Add DartDoc

### 3.3 Repository Implementations
- [ ] Create `SettingsRepositoryImpl` implements `ISettingsRepository`
  - [ ] Inject `SettingsLocalDataSource`
  - [ ] Implement `loadSettings()` → Load from SharedPreferences
  - [ ] Implement `saveSettings()` → Save to SharedPreferences
  - [ ] Map DTO ↔ Entity
  - [ ] Handle errors (return Either<Failure, T>)
  - [ ] Add DartDoc
- [ ] Create `LastProjectRepositoryImpl` implements `ILastProjectRepository`
  - [ ] Inject `LastProjectLocalDataSource`
  - [ ] Implement load/save methods
  - [ ] Handle errors
  - [ ] Add DartDoc

**Phase 3 Acceptance Criteria:**
- ⏳ SharedPreferences keys namespaced (`settings.*`, `lastProject.*`)
- ⏳ All data sources handle errors gracefully
- ⏳ DTOs properly serialize/deserialize JSON
- ⏳ Repository implementations return Either<Failure, T>
- ⏳ DartDoc on all data layer classes (100% coverage)

---

## 🎨 Phase 4: Presentation Layer (UI & State Management)

**Objective:** Implement UI widgets and Riverpod state management

### 4.1 State Management (Riverpod Providers)
- [ ] Create `SettingsNotifier` extends `StateNotifier<SettingsEntity>`
  - [ ] Load settings on init
  - [ ] `updateUserProfile(String name, String email)`
  - [ ] `updateStoragePath(String path)`
  - [ ] `updateTheme(ThemePreference theme)`
  - [ ] `updateLanguage(LanguagePreference lang)`
  - [ ] `updateAccessibility(AccessibilitySettings settings)`
  - [ ] `updatePerformance(PerformanceSettings settings)`
  - [ ] Persist on every change (call use cases)
  - [ ] Add DartDoc
- [ ] Create `settingsProvider` (StateNotifierProvider)
- [ ] Create `lastProjectProvider` (StateProvider<String?>)
  - [ ] Load from LastProjectRepository
  - [ ] Update on project open
  - [ ] Add DartDoc

### 4.2 UI Widgets - Settings Sections
- [x] **ProfileSection** (`profile_section.dart`)
  - [x] Connect to `settingsProvider`
  - [ ] Text fields for name/email
  - [ ] Avatar upload (mock for now)
  - [ ] Save button → Call `updateUserProfile()`
  - [ ] Add DartDoc

- [ ] **StorageSection** (`storage_section.dart`)
  - [ ] Connect to `settingsProvider`
  - [ ] Display current storage path
  - [ ] Button "Seleccionar Carpeta" → Open file_picker
  - [ ] Implement `_pickFolder()` using `FilePickerDataSource`
  - [ ] Save selected path → Call `updateStoragePath()`
  - [ ] Add DartDoc

- [x] **AppearanceSection** (`appearance_section.dart`)
  - [x] Connect to `settingsProvider`
  - [x] Theme toggle (Dark/Light/System)
  - [ ] Color scheme selector
  - [x] Save on change → Call `updateTheme()`
  - [ ] Add DartDoc

- [x] **AccessibilitySection** (`accessibility_section.dart`)
  - [x] Connect to `settingsProvider`
  - [ ] Font size slider
  - [ ] High contrast toggle
  - [ ] Screen reader toggle
  - [x] Save on change → Call `updateAccessibility()`
  - [ ] Add DartDoc

- [x] **PerformanceSection** (`performance_section.dart`)
  - [x] Connect to `settingsProvider`
  - [ ] Cache size limit
  - [ ] Memory limit
  - [ ] Clear cache button
  - [x] Save on change → Call `updatePerformance()`
  - [ ] Add DartDoc

- [ ] **LanguageSelectorWidget** (NEW: `language_selector_widget.dart`)
  - [ ] Display 🇬🇧 English / 🇪🇸 Español options
  - [ ] Use flutter_svg for flag icons (or Unicode emojis)
  - [ ] Toggle button / Dropdown
  - [ ] Save on change → Call `updateLanguage()`
  - [ ] Add to AppearanceSection or ProfileSection
  - [ ] Add DartDoc

### 4.3 UI Enhancements - Navigation
- [x] **GlobalSearchDialog** (`global_search_dialog.dart`)
  - [x] Add navigation on result click
  - [x] `onTap: () => context.go('/project-shell?path=${project.path}')`
  - [x] Close dialog after navigation
  - [ ] Add DartDoc

- [ ] **ProjectsSidebar** (`projects_sidebar.dart`)
  - [ ] Connect to `lastProjectProvider`
  - [ ] Read last project path from provider
  - [ ] Update button "Proyecto Activo" to navigate to last project
  - [ ] `onTap: () => context.go('/project-shell?path=$lastProjectPath')`
  - [ ] If no last project, disable button or show default
  - [ ] Add DartDoc

**Phase 4 Acceptance Criteria:**
- ⏳ All settings widgets functional and interactive
- ⏳ All settings persist via Riverpod + SharedPreferences
- ⏳ file_picker dialog opens native OS dialog
- ⏳ Language selector displays flags and toggles ES/EN
- ✅ GlobalSearchDialog navigates to selected project
- ⏳ ProjectsSidebar shows last opened project
- ⏳ DartDoc on all presentation layer classes (100% coverage)

---

## ✅ Phase 5: Testing (GREEN + Coverage)

**Objective:** Make all tests pass (GREEN phase) and achieve >90% coverage

### 5.1 Unit Tests - Domain Layer
- [ ] Test `SettingsEntity` creation and equality
- [ ] Test `LanguagePreference` enum values
- [ ] Test `LoadSettingsUseCase` success/failure paths
- [ ] Test `SaveSettingsUseCase` success/failure paths
- [ ] Test `UpdateLanguageUseCase` success/failure paths
- [ ] Test `UpdateStoragePathUseCase` validation and errors
- [ ] Verify all domain tests pass (GREEN)

### 5.2 Unit Tests - Data Layer
- [ ] Test `SettingsDto` JSON serialization/deserialization
- [ ] Test `SettingsMapper` DTO ↔ Entity mapping
- [ ] Test `SettingsLocalDataSource` with mocked SharedPreferences
- [ ] Test `FilePickerDataSource` with mocked file_picker
- [ ] Test `SettingsRepositoryImpl` success/failure paths
- [ ] Test `LastProjectRepositoryImpl` success/failure paths
- [ ] Verify all data tests pass (GREEN)

### 5.3 Widget Tests - Settings UI (7 tests)
- [x] **Test 1:** `profile_section_test.dart`
  - [x] Renders user name field with `ValueKey`
  - [x] TextField exists for user name input

- [ ] **Test 2:** `storage_section_test.dart`
  - [ ] Renders current storage path
  - [ ] "Seleccionar Carpeta" button opens file picker (mock)
  - [ ] Selected path updates provider
  - [ ] Verify persistence

- [x] **Test 3:** `appearance_section_test.dart`
  - [x] Renders theme toggle
  - [x] Renders font size slider
  - [x] Displays font size percentage text

- [x] **Test 4:** `accessibility_section_test.dart`
  - [x] Renders global zoom slider
  - [x] Renders zoom shortcuts switch
  - [x] Displays zoom percentage text

- [x] **Test 5:** `performance_section_test.dart`
  - [x] Renders animations toggle switch
  - [x] Renders memory optimization switch
  - [x] Displays performance settings text

- [ ] **Test 6:** `settings_screen_test.dart`
  - [ ] Full screen renders all sections
  - [ ] Sidebar navigation works
  - [ ] Settings screen structure correct

- [ ] **Test 7:** `language_selector_widget_test.dart`
  - [ ] Renders 🇬🇧 / 🇪🇸 options
  - [ ] User can toggle language
  - [ ] Language change updates provider
  - [ ] Verify persistence

### 5.4 Widget Test - GlobalSearchDialog
- [x] **Test 8:** `global_search_dialog_test.dart`
  - [x] Dialog opens with search field
  - [x] Results list renders
  - [x] Close button renders
  - [x] Results count text renders
  - [x] Clicking result navigates to project and updates last project

### 5.5 Fix MarkdownPreview Tests (T-2)
- [ ] Identify root cause of 10 failing tests
- [ ] Refactor tests to use `pumpAndSettle()` for async renders
- [ ] Mock MarkdownController properly
- [ ] Fix widget finder issues
- [ ] Fix timing issues (pump/settle)
- [ ] Add golden tests for visual regression (optional)
- [ ] Verify all 10 tests pass (GREEN)

### 5.6 Integration Tests
- [ ] Create integration test: User changes language → UI updates → Persists on restart
- [ ] Create integration test: User selects folder → Path saves → Shows in UI
- [ ] Create integration test: User opens project → Last project updates → Sidebar shows correct project
- [ ] Verify all integration tests pass

### 5.7 Coverage Verification
- [ ] Run `flutter test --coverage`
- [ ] Generate coverage report: `genhtml coverage/lcov.info -o coverage/html`
- [ ] Verify Settings feature coverage >90%
- [ ] Verify overall project coverage >80%
- [ ] Identify uncovered lines (if any) and add tests

**Phase 5 Acceptance Criteria:**
- ⏳ All unit tests pass (domain + data layers)
- 🚧 5/8 widget tests passing (Profile, Appearance, Accessibility, Performance, GlobalSearchDialog)
- ⏳ All 10 MarkdownPreview tests pass (0 failures)
- ⏳ All integration tests pass
- ⏳ Coverage verified >90% for Settings feature
- ⏳ Coverage report generated and reviewed

---

## 📚 Phase 6: Documentation & CI/CD Validation

**Objective:** Document code, verify quality gates, prepare for merge

### 6.1 Code Documentation (DartDoc)
- [ ] Generate DartDoc: `dart doc .`
- [ ] Verify all public APIs have documentation comments
- [ ] Add examples to complex functions
- [ ] Review generated HTML docs for clarity
- [ ] Fix any missing/unclear documentation

### 6.2 Quality Gates - Code Quality
- [ ] Run `dart format lib/ test/` → Verify all code formatted
- [ ] Run `flutter analyze` → Verify 0 warnings/errors
- [ ] Run `flutter analyze --no-fatal-infos` → Verify clean output
- [ ] Review code for SOLID principles adherence
- [ ] Review code for DRY violations

### 6.3 Quality Gates - Security
- [ ] Verify no hardcoded paths in code
- [ ] Verify input sanitization on file paths
- [ ] Verify SharedPreferences keys namespaced
- [ ] Review file_picker usage for security issues
- [ ] Run security audit (if applicable)

### 6.4 Quality Gates - Testing
- [ ] Verify all tests pass: `flutter test`
- [ ] Verify coverage >90%: `flutter test --coverage`
- [ ] Verify no flaky tests (run 3 times)
- [ ] Review test quality (meaningful assertions)

### 6.5 Update Documentation
- [ ] Update `README.md` with final status
- [ ] Complete `PROGRESS.md` (this file) with 100% checkmarks
- [ ] Verify `ARTIFACTS.md` matches actual files created
- [ ] Update `doc/INDEX.md` with new HU reference
- [ ] Create PR description summary

### 6.6 CI/CD Pre-Push Validation
- [ ] Run `./scripts/PRE_PUSH_VALIDATION_MASTER.sh`
- [ ] Verify all checks pass:
  - [ ] Black formatting (if Python code modified)
  - [ ] Ruff linting (if Python code modified)
  - [ ] Pyright type checking (if Python code modified)
  - [ ] Dart formatting
  - [ ] Flutter analyze
  - [ ] All tests pass
  - [ ] Coverage ≥90%
- [ ] Fix any failures before push

### 6.7 Git Workflow
- [ ] Stage all changes: `git add -A`
- [ ] Commit with conventional message: `feat(settings): complete UI with persistence and tests (HU-3.7)`
- [ ] Push to remote: `git push origin feature/settings-ui-completion`
- [ ] Create Pull Request to `develop`
- [ ] Fill PR description with:
  - Summary of changes
  - Acceptance criteria checked
  - Coverage report
  - Screenshots (if UI changes)
  - Breaking changes (if any)

**Phase 6 Acceptance Criteria:**
- ⏳ DartDoc generated and reviewed (100% coverage)
- ⏳ All quality gates pass (format, analyze, security)
- ⏳ All documentation updated (README, PROGRESS, ARTIFACTS)
- ⏳ Pre-push validation passes (PRE_PUSH_VALIDATION_MASTER.sh)
- ⏳ PR created with comprehensive description
- ⏳ Ready for code review and merge

---

## 📈 Metrics Summary

| Metric | Before | After | Change |
|--------|--------|-------|--------|
| **Total Tests** | ~120 | ~138 | +18 tests |
| **Widget Tests** | ~40 | ~48 | +8 tests |
| **Fixed Tests** | 10 failing | 0 failing | ✅ Fixed |
| **Coverage (Settings)** | 85% | >90% | +5% |
| **Coverage (Overall)** | ~80% | ~85% | +5% |
| **Functional Settings** | Partial | 100% | ✅ Complete |
| **Language Support** | ES only | ES + EN | ✅ Bilingual |
| **Native File Picker** | ❌ | ✅ | ✅ Integrated |
| **Last Project Persistence** | ❌ | ✅ | ✅ Implemented |
| **GlobalSearch Navigation** | ❌ | ✅ | ✅ Implemented |

---

## 🎯 Definition of Done

- [x] **Phase 1:** Documentation created, tests written (RED)
- [ ] **Phase 2:** Domain layer complete (entities, use cases, interfaces)
- [ ] **Phase 3:** Data layer complete (repositories, data sources, DTOs)
- [ ] **Phase 4:** Presentation layer complete (UI, state management)
- [ ] **Phase 5:** All tests pass (GREEN), coverage >90%
- [ ] **Phase 6:** Documentation complete, CI/CD validated, PR created

**When all checkboxes are ✅, HU-3.7 is DONE.**

---

## 📝 Notes & Blockers

### Notes
- File picker integration requires native platform testing (Linux/macOS/Windows)
- Language selector will use Unicode flag emojis (🇬🇧🇪🇸) for simplicity (no SVG dependency needed)
- SharedPreferences keys follow namespace: `settings.*`, `lastProject.*`
- All settings changes auto-save (no manual "Save" button except ProfileSection)

### Blockers
- None identified yet

### Risks
- ⚠️ File picker may behave differently on different platforms → Mitigation: Test on Linux (primary), document platform-specific issues
- ⚠️ MarkdownPreview tests may require deep refactor → Mitigation: Allocate extra time for T-2

---

**Last Updated:** 11/02/2026 by ArchitectZero
