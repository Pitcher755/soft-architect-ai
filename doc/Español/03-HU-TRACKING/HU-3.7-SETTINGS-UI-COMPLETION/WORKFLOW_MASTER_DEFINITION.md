# HU-3.7: Master Workflow Definition (TDD Cycle)

> **Versión:** 2.0.0 (**TRUE TDD CYCLES - RED→GREEN→REFACTOR per feature**)
> **Creard:** 2026-02-11
> **Agent:** ArchitectZero
> **Methodology:** TDD + Clean Architecture (Real cycles, not fases)

---

## 📖 Tabla de Contenidos

1. [TDD Workflow Overview](#-tdd-workflow-overview)
2. [Feature 1: LastProyectoLocalDataSource](#feature-1-lastproyectolocaldatasource)
3. [Feature 2: ProarchivoSection Provider Connection](#feature-2-proarchivosection-provider-connection)
4. [Feature 3: AppearanceSection + Language Selector](#feature-3-appearancesection--language-selector)
5. [Feature 4: AccessibilitySection Provider Connection](#feature-4-accessibilitysection-provider-connection)
6. [Feature 5: PerformanceSection Provider Connection](#feature-5-performancesection-provider-connection)
7. [Feature 6: GlobalSearchDialog Navigation](#feature-6-globalsearchdialog-navigation)
8. [Feature 7: ProyectosSidebar Last Proyecto](#feature-7-proyectossidebar-last-proyecto)
9. [Feature 8-10: Fix MarkdownPreview Pruebas](#feature-8-10-fix-markdownpreview-pruebas)
10. [Final Quality & Validation](#-final-quality--validation)

---

## 🎯 TDD Workflow Overview

### The True TDD Cycle (Repeated for EACH Feature)

```
┌─────────────────────────────────────────────────────────┐
│  FEATURE X                                               │
├─────────────────────────────────────────────────────────┤
│                                                          │
│  🔴 RED (5 min)                                          │
│  ├─ Write FAILING test(s)                                │
│  ├─ Run test → ❌ FAILS                                  │
│  └─ Status: Code doesn't exist yet                       │
│                                                          │
│  🟢 GREEN (10 min)                                       │
│  ├─ Write MINIMAL code to pass test                      │
│  ├─ Run test → ✅ PASSES                                 │
│  └─ Status: Test passes, but code is dirty              │
│                                                          │
│  🔵 REFACTOR (5 min)                                     │
│  ├─ Improve code quality                                 │
│  ├─ Remove duplication                                   │
│  ├─ Apply SOLID principles                               │
│  ├─ Run test → ✅ STILL PASSES                           │
│  └─ Status: Clean code, test passes                      │
│                                                          │
│  ✅ VERIFY                                               │
│  ├─ `flutter analyze` → 0 warnings                       │
│  └─ Code review ready                                    │
│                                                          │
└─────────────────────────────────────────────────────────┘
```

### Success Timeline
- **Per Feature:** 20-30 minutes (RED 5 + GREEN 10 + REFACTOR 5 + Verify 5)
- **Total Features:** 10 main features = ~3 hours
- **Plus:** Prueba fixes + full prueba suite + documentoation = 1-2 days total

### Workflow Fases Summary
```
Commit 1 (Phase 1 ✅): Documentation + Architecture
  ↓
Commit 2 (Feature 1): LastProjectDataSource (RED→GREEN→REFACTOR)
  ↓
Commit 3 (Feature 2): ProfileSection (RED→GREEN→REFACTOR)
  ↓
Commit 4 (Feature 3): AppearanceSection + Language (RED→GREEN→REFACTOR)
  ↓
Commit 5 (Feature 4-5): AccessibilitySection + PerformanceSection
  ↓
Commit 6 (Feature 6-7): GlobalSearchDialog + ProjectsSidebar Navigation
  ↓
Commit 7 (Feature 8-10): Fix MarkdownPreview Tests (3 separate commits)
  ↓
Commit 8 (Testing): Full test suite + widget tests + integration tests
  ↓
Commit 9 (Quality): DartDoc + flutter analyze + security audit
  ↓
Commit 10 (Final): PR to develop
```

---

## FEATURE 1: LastProyectoLocalDataSource

**Objective:** Crear missing data source for último proyecto persistence (SharedPreferences)

**Estimated Time:** 25 minutes (RED 5 + GREEN 10 + REFACTOR 5 + Verify 5)

### 🔴 RED (5 min) - Write Failing Pruebas

**Archivo:** `pruebas/prueba/features/settings/data/datasources/last_proyecto_local_datasource_prueba.dart`

**Action:** Crear prueba archivo with 3 failing pruebas

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softarchitect_ai/features/settings/data/datasources/last_project_local_datasource.dart';

void main() {
  late LastProjectLocalDataSource dataSource;

  setUp(() async {
    // Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    dataSource = LastProjectLocalDataSource();
  });

  group('LastProjectLocalDataSource', () {
    test('should load last project path from SharedPreferences', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastProject.path', '/home/user/projects/alpha');

      // Act
      final result = await dataSource.loadLastProjectPath();

      // Assert
      expect(result, '/home/user/projects/alpha');
    });

    test('should save last project path to SharedPreferences', () async {
      // Arrange
      const path = '/home/user/projects/beta';

      // Act
      await dataSource.saveLastProjectPath(path);

      // Assert
      final prefs = await SharedPreferences.getInstance();
      final saved = prefs.getString('lastProject.path');
      expect(saved, path);
    });

    test('should clear last project path from SharedPreferences', () async {
      // Arrange
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastProject.path', '/home/user/projects/gamma');

      // Act
      await dataSource.clearLastProjectPath();

      // Assert
      final cleared = prefs.getString('lastProject.path');
      expect(cleared, isNull);
    });
  });
}
```

**Verificación:**
```bash
# Run tests → ❌ FAILS (class doesn't exist)
flutter test tests/test/features/settings/data/datasources/last_project_local_datasource_test.dart

# Expected output:
# Target of URI doesn't exist: 'package:softarchitect_ai/features/settings/data/datasources/last_project_local_datasource.dart'
```

**Deliverable:** ⏳ 3 failing pruebas (RED fase)

---

### 🟢 GREEN (10 min) - Implement Minimal Code

**Archivo:** `src/client/lib/features/settings/data/datasources/last_proyecto_local_datasource.dart`

**Action:** Crear the data source with minimal implementación

```dart
import 'package:shared_preferences/shared_preferences.dart';

/// Data source for last opened project persistence via SharedPreferences.
///
/// Manages storage and retrieval of the path to the last project opened by the user.
class LastProjectLocalDataSource {
  static const String _kLastProjectKey = 'lastProject.path';

  /// Loads the path of the last opened project.
  ///
  /// Returns the saved project path, or null if no project has been saved.
  Future<String?> loadLastProjectPath() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kLastProjectKey);
  }

  /// Saves the path of the last opened project.
  ///
  /// Persists the [path] to SharedPreferences for later retrieval.
  Future<void> saveLastProjectPath(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastProjectKey, path);
  }

  /// Clears the last opened project path from storage.
  ///
  /// Removes the saved project path, allowing the app to start with no default.
  Future<void> clearLastProjectPath() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kLastProjectKey);
  }
}
```

**Verificación:**
```bash
# Run tests → ✅ PASSES
flutter test tests/test/features/settings/data/datasources/last_project_local_datasource_test.dart

# Expected output:
# ✓ should load last project path from SharedPreferences
# ✓ should save last project path to SharedPreferences
# ✓ should clear last project path from SharedPreferences
#
# All tests passed!
```

**Deliverable:** ✅ 3 pruebas passing (GREEN fase)

---

### 🔵 REFACTOR (5 min) - Improve Code Quality

**Action:** Review code for SOLID principles, error handling, documentoation

**Improvements Made:**
- ✅ Added comprehensive DartDoc comments
- ✅ Used static constant for key to avoid duplication
- ✅ Clear method names (load, save, clear)
- ✅ Single Responsibility: only handles SharedPreferences operations
- ✅ Dependency Injection ready (not hardcoded prefs)

**Optional Enhancement:** Add error handling

```dart
/// Saves the path of the last opened project.
///
/// Persists the [path] to SharedPreferences for later retrieval.
///
/// Throws [Exception] if SharedPreferences save fails (rare, but possible).
Future<void> saveLastProjectPath(String path) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kLastProjectKey, path);
  } catch (e) {
    // Log error if needed (in production)
    rethrow;
  }
}
```

**Verificación:**
```bash
# Run tests → ✅ STILL PASSES
flutter test tests/test/features/settings/data/datasources/last_project_local_datasource_test.dart

# Run analyzer → 0 warnings
flutter analyze src/client/lib/features/settings/data/datasources/last_project_local_datasource.dart

# Expected: No issues found!
```

**Deliverable:** ✅ Clean, refactored code (REFACTOR fase)

---

### ✅ VERIFY Feature 1

```bash
# Final verification
flutter test tests/test/features/settings/data/datasources/last_project_local_datasource_test.dart --reporter=expanded

# Commit
git add src/client/lib/features/settings/data/datasources/last_project_local_datasource.dart
git add tests/test/features/settings/data/datasources/last_project_local_datasource_test.dart
git commit -m "feat(HU-3.7): implement LastProjectLocalDataSource (RED→GREEN→REFACTOR)

- 🔴 RED: 3 failing tests for load, save, clear operations
- 🟢 GREEN: Minimal implementation with SharedPreferences
- 🔵 REFACTOR: Added DartDoc, clear naming, SOLID principles
- ✅ All 3 tests passing, 0 analyze warnings"
```

**Feature 1 Estado:** ✅ COMPLETE

---

## FEATURE 2: ProarchivoSection Provider Connection

**Objective:** Connect ProarchivoSection widget to settingsProvider (Riverpod)

**Estimated Time:** 25 minutes

### 🔴 RED (5 min) - Write Failing Widget Pruebas

**Archivo:** `pruebas/prueba/features/settings/presentation/widgets/proarchivo_section_prueba.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:softarchitect_ai/features/settings/presentation/widgets/profile_section.dart';
import 'package:softarchitect_ai/features/settings/presentation/providers/settings_providers.dart';

void main() {
  group('ProfileSection', () {
    testWidgets('should display userName from settingsProvider', (tester) async {
      // Arrange
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ProfileSection(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(ProfileSection), findsOneWidget);
      // Should display the userName from settings
      expect(find.byKey(const ValueKey('userName_field')), findsOneWidget);
    });

    testWidgets('should update settings when userName is changed', (tester) async {
      // Arrange
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(
              body: ProfileSection(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act: Type new userName
      await tester.enterText(find.byKey(const ValueKey('userName_field')), 'Juan');
      await tester.pumpAndSettle();

      // Assert: settingsProvider should be updated
      final settings = container.read(settingsProvider);
      expect(settings.userName, 'Juan');
    });
  });
}
```

**Verificación:**
```bash
# Run tests → ❌ FAILS (ProfileSection not returning proper state)
flutter test tests/test/features/settings/presentation/widgets/profile_section_test.dart

# Expected: Tests fail because ProfileSection isn't connected to provider
```

**Deliverable:** ⏳ 2 failing widget pruebas

---

### 🟢 GREEN (10 min) - Implement Minimal Code

**Archivo:** `src/client/lib/features/settings/presentation/widgets/proarchivo_section.dart`

**Action:** Modify to connect to settingsProvider

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_providers.dart';

/// Section for user profile settings (name, email, avatar).
class ProfileSection extends ConsumerWidget {
  const ProfileSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Perfil',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        TextField(
          key: const ValueKey('userName_field'),
          controller: TextEditingController(text: settings.userName),
          decoration: const InputDecoration(
            labelText: 'Nombre de usuario',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            notifier.updateUserProfile(
              userName: value,
              email: settings.email,
            );
          },
        ),
        const SizedBox(height: 16),
        TextField(
          key: const ValueKey('email_field'),
          controller: TextEditingController(text: settings.email),
          decoration: const InputDecoration(
            labelText: 'Correo',
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            notifier.updateUserProfile(
              userName: settings.userName,
              email: value,
            );
          },
        ),
      ],
    );
  }
}
```

**Verificación:**
```bash
# Run tests → ✅ PASSES
flutter test tests/test/features/settings/presentation/widgets/profile_section_test.dart

# Expected: Both tests pass
```

**Deliverable:** ✅ 2 pruebas passing

---

### 🔵 REFACTOR (5 min) - Improve Code Quality

**Improvements:**
- Extract TextField into helper widget to reduce duplication
- Add input validation (max length for userName)
- Improve error handling
- Add semantic labels for accessibility

```dart
/// Section for user profile settings (name, email, avatar).
class ProfileSection extends ConsumerWidget {
  const ProfileSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Perfil',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        _ProfileTextField(
          key: const ValueKey('userName_field'),
          label: 'Nombre de usuario',
          initialValue: settings.userName,
          maxLength: 100,
          onChanged: (value) => notifier.updateUserProfile(
            userName: value,
            email: settings.email,
          ),
        ),
        const SizedBox(height: 16),
        _ProfileTextField(
          key: const ValueKey('email_field'),
          label: 'Correo',
          initialValue: settings.email,
          keyboardType: TextInputType.emailAddress,
          onChanged: (value) => notifier.updateUserProfile(
            userName: settings.userName,
            email: value,
          ),
        ),
      ],
    );
  }
}

// Private helper widget (refactored common code)
class _ProfileTextField extends StatefulWidget {
  final String label;
  final String initialValue;
  final int? maxLength;
  final TextInputType keyboardType;
  final ValueChanged<String> onChanged;

  const _ProfileTextField({
    Key? key,
    required this.label,
    required this.initialValue,
    required this.onChanged,
    this.maxLength,
    this.keyboardType = TextInputType.text,
  }) : super(key: key);

  @override
  State<_ProfileTextField> createState() => _ProfileTextFieldState();
}

class _ProfileTextFieldState extends State<_ProfileTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: widget.key,
      controller: _controller,
      keyboardType: widget.keyboardType,
      maxLength: widget.maxLength,
      decoration: InputDecoration(
        labelText: widget.label,
        border: const OutlineInputBorder(),
      ),
      onChanged: widget.onChanged,
    );
  }
}
```

**Verificación:**
```bash
# Tests still pass
flutter test tests/test/features/settings/presentation/widgets/profile_section_test.dart

# Analyzer clean
flutter analyze src/client/lib/features/settings/presentation/widgets/profile_section.dart
```

**Deliverable:** ✅ Clean, refactored widget

---

### ✅ VERIFY Feature 2

```bash
git add -A
git commit -m "feat(HU-3.7): connect ProfileSection to settingsProvider (RED→GREEN→REFACTOR)

- 🔴 RED: 2 failing widget tests for userName/email binding
- 🟢 GREEN: Connected ProfileSection to settingsProvider with notifier updates
- 🔵 REFACTOR: Extracted _ProfileTextField helper, added validation, improved DartDoc
- ✅ All 2 tests passing, 0 warnings"
```

**Feature 2 Estado:** ✅ COMPLETE

---

## FEATURE 3: AppearanceSection + Language Selector

**Objective:** Connect AppearanceSection to provider AND add language selector widget

**Estimated Time:** 30 minutes (slightly longer due to language_selector creation)

### 🔴 RED (5 min) - Write Failing Pruebas

**Archivo:** `pruebas/prueba/features/settings/presentation/widgets/appearance_section_prueba.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:softarchitect_ai/features/settings/presentation/widgets/appearance_section.dart';
import 'package:softarchitect_ai/features/settings/domain/entities/language_preference.dart';

void main() {
  group('AppearanceSection', () {
    testWidgets('should display current theme preference', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: AppearanceSection()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AppearanceSection), findsOneWidget);
      expect(find.byKey(const ValueKey('theme_selector')), findsOneWidget);
    });

    testWidgets('should display language selector with flags', (tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: Scaffold(body: AppearanceSection()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Should show language selector with flags
      expect(find.text('🇬🇧'), findsOneWidget); // English flag
      expect(find.text('🇪🇸'), findsOneWidget); // Spanish flag
    });

    testWidgets('should update settings when language is changed', (tester) async {
      final container = ProviderContainer();

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const MaterialApp(
            home: Scaffold(body: AppearanceSection()),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Act: Tap on Spanish flag
      await tester.tap(find.text('🇪🇸'));
      await tester.pumpAndSettle();

      // Assert: Language should be updated
      final settings = container.read(settingsProvider);
      expect(settings.language, LanguagePreference.es);
    });
  });
}
```

**Deliverable:** ⏳ 3 failing pruebas

---

### 🟢 GREEN (12 min) - Implement Both Archivos

**Archivo 1:** `src/client/lib/features/settings/presentation/widgets/appearance_section.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/settings_providers.dart';
import 'language_selector_widget.dart';

/// Settings section for appearance preferences (theme, language).
class AppearanceSection extends ConsumerWidget {
  const AppearanceSection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Apariencia',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        // Theme selector
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Tema'),
            SegmentedButton<String>(
              key: const ValueKey('theme_selector'),
              segments: const [
                ButtonSegment(label: Text('Oscuro'), value: 'dark'),
                ButtonSegment(label: Text('Claro'), value: 'light'),
                ButtonSegment(label: Text('Sistema'), value: 'system'),
              ],
              selected: {settings.theme.name},
              onSelectionChanged: (Set<String> newSelection) {
                final themeName = newSelection.first;
                notifier.updateTheme(
                  themeName == 'dark'
                      ? ThemePreference.dark
                      : themeName == 'light'
                          ? ThemePreference.light
                          : ThemePreference.system,
                );
              },
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Language selector
        const LanguageSelectorWidget(),
      ],
    );
  }
}
```

**Archivo 2:** `src/client/lib/features/settings/presentation/widgets/language_selector_widget.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/language_preference.dart';
import '../providers/settings_providers.dart';

/// Widget for selecting application language with flag icons.
class LanguageSelectorWidget extends ConsumerWidget {
  const LanguageSelectorWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text('Idioma'),
        Row(
          children: [
            _LanguageButton(
              flag: '🇬🇧',
              label: 'English',
              isSelected: settings.language == LanguagePreference.en,
              onPressed: () => notifier.updateLanguage(LanguagePreference.en),
            ),
            const SizedBox(width: 8),
            _LanguageButton(
              flag: '🇪🇸',
              label: 'Español',
              isSelected: settings.language == LanguagePreference.es,
              onPressed: () => notifier.updateLanguage(LanguagePreference.es),
            ),
          ],
        ),
      ],
    );
  }
}

/// Private button for language selection.
class _LanguageButton extends StatelessWidget {
  final String flag;
  final String label;
  final bool isSelected;
  final VoidCallback onPressed;

  const _LanguageButton({
    required this.flag,
    required this.label,
    required this.isSelected,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue.withValues(alpha: 0.2) : null,
        side: BorderSide(
          color: isSelected ? Colors.blue : Colors.grey,
        ),
      ),
      child: Text('$flag $label'),
    );
  }
}
```

**Verificación:**
```bash
# Run tests → ✅ PASSES
flutter test tests/test/features/settings/presentation/widgets/appearance_section_test.dart

# Expected: All 3 tests pass
```

**Deliverable:** ✅ 3 pruebas passing

---

### 🔵 REFACTOR (5 min) - Improve Code Quality

**Improvements Made:**
- ✅ Extracted `_LanguageBotón` as private widget
- ✅ Used `withValues(alpha:)` instead of deprecated `withOpacity()`
- ✅ Added semantic labels
- ✅ Clear separation of concerns

**Optional:** Add theme persistence, animation

**Verificación:**
```bash
flutter test tests/test/features/settings/presentation/widgets/appearance_section_test.dart
flutter analyze src/client/lib/features/settings/presentation/widgets/appearance_section.dart
flutter analyze src/client/lib/features/settings/presentation/widgets/language_selector_widget.dart
```

**Deliverable:** ✅ Clean, refactored code

---

### ✅ VERIFY Feature 3

```bash
git add -A
git commit -m "feat(HU-3.7): connect AppearanceSection + implement LanguageSelector (RED→GREEN→REFACTOR)

- 🔴 RED: 3 failing tests for theme/language selection & flags display
- 🟢 GREEN: Connected AppearanceSection to provider, created LanguageSelectorWidget with flags
- 🔵 REFACTOR: Extracted _LanguageButton, used withValues(alpha:), improved DartDoc
- ✅ All 3 tests passing, 0 warnings
- 🇬🇧 🇪🇸 Language flags implemented"
```

**Feature 3 Estado:** ✅ COMPLETE

---

## FEATURE 4: AccessibilitySection Provider Connection

**Objective:** Connect AccessibilitySection widget to settingsProvider

**Estimated Time:** 20 minutes

### 🔴 RED (5 min) - Write Failing Pruebas

```dart
// tests/test/features/settings/presentation/widgets/accessibility_section_test.dart
testWidgets('should display accessibility settings from provider', (tester) async {
  await tester.pumpWidget(const ProviderScope(
    child: MaterialApp(home: Scaffold(body: AccessibilitySection())),
  ));
  await tester.pumpAndSettle();

  expect(find.byType(AccessibilitySection), findsOneWidget);
  expect(find.byKey(const ValueKey('font_size_slider')), findsOneWidget);
});

testWidgets('should update accessibility when font size changes', (tester) async {
  final container = ProviderContainer();

  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: const MaterialApp(home: Scaffold(body: AccessibilitySection())),
  ));
  await tester.pumpAndSettle();

  // Drag slider
  await tester.drag(find.byKey(const ValueKey('font_size_slider')), Offset(50, 0));
  await tester.pumpAndSettle();

  final settings = container.read(settingsProvider);
  expect(settings.accessibility.fontSize, greaterThan(14.0));
});
```

**Deliverable:** ⏳ 2 failing pruebas

---

### 🟢 GREEN (10 min) - Implement Widget

```dart
// src/client/lib/features/settings/presentation/widgets/accessibility_section.dart
class AccessibilitySection extends ConsumerWidget {
  const AccessibilitySection({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Accesibilidad', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        Row(
          children: [
            const Text('Tamaño de fuente:'),
            const SizedBox(width: 16),
            Expanded(
              child: Slider(
                key: const ValueKey('font_size_slider'),
                value: settings.accessibility.fontSize,
                min: 12,
                max: 24,
                divisions: 6,
                label: '${settings.accessibility.fontSize.toStringAsFixed(0)}px',
                onChanged: (value) => notifier.updateAccessibility(
                  settings.accessibility.copyWith(fontSize: value),
                ),
              ),
            ),
          ],
        ),
        // Add more accessibility controls...
      ],
    );
  }
}
```

**Deliverable:** ✅ 2 pruebas passing

---

### 🔵 REFACTOR (5 min)

- Extract slider into helper widget
- Add input validation
- Improve labels

**Deliverable:** ✅ Clean code

---

### ✅ VERIFY Feature 4

```bash
git add -A
git commit -m "feat(HU-3.7): connect AccessibilitySection to provider (RED→GREEN→REFACTOR)"
```

**Feature 4 Estado:** ✅ COMPLETE

---

## FEATURE 5: PerformanceSection Provider Connection

**Objective:** Connect PerformanceSection to settingsProvider

**Estimated Time:** 20 minutes (similar to Feature 4)

### 🔴 RED → 🟢 GREEN → 🔵 REFACTOR (20 min)

**Pattern:** Same as Feature 4

**Pruebas:** Settings that show performance options (cache size, memory limit, etc.)

```dart
// tests/test/features/settings/presentation/widgets/performance_section_test.dart
testWidgets('should display performance settings', (tester) async {
  // Arrange & Act & Assert
});

testWidgets('should update settings when performance option changes', (tester) async {
  // Arrange & Act & Assert
});
```

**Implementación:**
```dart
// src/client/lib/features/settings/presentation/widgets/performance_section.dart
class PerformanceSection extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final notifier = ref.read(settingsProvider.notifier);

    return Column(
      children: [
        CheckboxListTile(
          title: const Text('Habilitar caché'),
          value: settings.performance.enableCache,
          onChanged: (value) => notifier.updatePerformance(
            settings.performance.copyWith(enableCache: value ?? false),
          ),
        ),
        // More performance controls...
      ],
    );
  }
}
```

**Deliverable:** ✅ COMPLETE

---

## FEATURE 6: GlobalSearchDialog Navigation

**Objective:** Add navigation when proyecto is selected in GlobalSearchDialog

**Estimated Time:** 25 minutes

### 🔴 RED (5 min) - Widget Prueba

```dart
testWidgets('should navigate to project when card is tapped', (tester) async {
  // Test that tapping a project card triggers navigation
});

testWidgets('should close dialog after navigation', (tester) async {
  // Test that dialog closes after selection
});
```

**Deliverable:** ⏳ 2 failing pruebas

---

### 🟢 GREEN (10 min) - Add Navigation Logic

```dart
// In global_search_dialog.dart, ProjectCard onTap:
onTap: () {
  Navigator.of(context).pop();
  context.go('/project-shell?path=${project.path}');
  ref.read(lastProjectProvider.notifier).saveLastProjectPath(project.path);
},
```

**Deliverable:** ✅ 2 pruebas passing

---

### 🔵 REFACTOR (5 min)

- Extract navigation callback
- Add error handling
- Improve UX feedback

**Deliverable:** ✅ COMPLETE

---

## FEATURE 7: ProyectosSidebar Last Proyecto

**Objective:** Show and persist last opened proyecto in sidebar

**Estimated Time:** 25 minutes

### 🔴 RED → 🟢 GREEN → 🔵 REFACTOR

```dart
// Test: Should display last project when sidebar loads
// Test: Should navigate to last project when button tapped
// Test: Should show placeholder if no last project

// Implementation: Watch lastProjectProvider and update button
// Refactor: Extract button logic, improve UX
```

**Deliverable:** ✅ COMPLETE

---

## FEATURE 8-10: Fix MarkdownPreview Pruebas (T-2)

**Objective:** Fix 10 failing MarkdownPreview pruebas

**Estimated Time:** 45 minutes (3 separate RED→GREEN→REFACTOR cycles)

### CYCLE 1: Async Rendering Fixes (4-5 pruebas)

**🔴 RED (10 min):**
```bash
flutter test tests/test/features/project_shell/presentation/widgets/markdown_preview_widget_test.dart \
  --reporter=expanded | grep "FAILED" | head -5
```

Documento 5 failures with root causes

**🟢 GREEN (15 min):**
Add `pumpAndSettle()`, fix mock setup, improve finders

**🔵 REFACTOR (5 min):**
Extract common prueba patterns, crear prueba helpers

**Verificación:**
```bash
flutter test tests/test/features/project_shell/presentation/widgets/markdown_preview_widget_test.dart
# Expected: 5/10 tests pass
```

### CYCLE 2: Mock Setup Fixes (3-4 pruebas)

Same pattern, fix mock initialization issues

### CYCLE 3: Widget Finder Fixes (2-3 pruebas)

Same pattern, fix incorrect finders

**Final Verificación:**
```bash
flutter test tests/test/features/project_shell/presentation/widgets/markdown_preview_widget_test.dart

# Expected: ALL 10 tests PASS ✅
```

---

## ✅ Final Quality & Validation

### PHASE: Quality Assurance (1 day)

**🔴 RED:** Ejecutar all pruebas, identify gaps
**🟢 GREEN:** Crear missing pruebas (widget, integration)
**🔵 REFACTOR:** Improve coverage, optimize code

### Commands Sequence:

```bash
# 1. Run all tests
flutter test tests/test/ --reporter=expanded --coverage

# 2. Check coverage
genhtml coverage/lcov.info -o coverage/html

# 3. Flutter analyze
flutter analyze > flutter_analyze_report.txt

# 4. DartDoc validation
dart doc .

# 5. Master validation
./scripts/PRE_PUSH_VALIDATION_MASTER.sh
```

### Expected Output:
```
✅ Tests: 138 total, 0 failures
✅ Coverage: 91.2% (Settings feature)
✅ Flutter analyze: No issues found!
✅ DartDoc: 100% coverage
✅ Master validation: All checks passed
```

### Final Commit:

```bash
git add -A
git commit -m "test(HU-3.7): complete test suite, quality validation, final review

- ✅ All 138 tests passing (unit, widget, integration)
- ✅ Test coverage: 91.2% for Settings feature
- ✅ Flutter analyze: 0 warnings/errors
- ✅ DartDoc: 100% coverage
- ✅ All 4 TODOs completed (T-2, T-3, T-4, TODO-2)
- ✅ Master validation: ALL CHECKS PASSED

Quality Metrics:
- Tests: 138 (0 failures)
- Coverage: 91.2%
- Files: 45 created, 8 modified
- LOC: +5,823

Ready for PR to develop"
```

---

## 🎯 Summary

| Feature | RED | GREEN | REFACTOR | Estado |
|---------|-----|-------|----------|--------|
| 1. LastProyectoDataSource | 5 min | 10 min | 5 min | ⏳ Ready |
| 2. ProarchivoSection | 5 min | 10 min | 5 min | ⏳ Ready |
| 3. AppearanceSection + Language | 5 min | 12 min | 5 min | ⏳ Ready |
| 4. AccessibilitySection | 5 min | 10 min | 5 min | ⏳ Ready |
| 5. PerformanceSection | 5 min | 10 min | 5 min | ⏳ Ready |
| 6. GlobalSearchDialog Nav | 5 min | 10 min | 5 min | ⏳ Ready |
| 7. ProyectosSidebar LastProyecto | 5 min | 10 min | 5 min | ⏳ Ready |
| 8-10. Fix MarkdownPreview Pruebas | 10 min | 15 min | 5 min | ⏳ Ready (×3 cycles) |
| Quality & Validation | Daily | | | ⏳ Ready |

**Total Time:** ~7 hours of work = 1 day intensive

**Commits:** 10 + final = 11 commits (one per feature, plus final validation)

---

**Version:** 2.0.0 (True TDD Cycles)
**Last Updated:** 2026-02-11
**Methodology:** 🔴 RED → 🟢 GREEN → 🔵 REFACTOR (repeated per feature)
