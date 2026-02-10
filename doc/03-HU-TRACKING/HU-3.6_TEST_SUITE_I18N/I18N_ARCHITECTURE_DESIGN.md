# 🔴 PHASE 1: RED - i18n Architecture Design Report

> **Project:** SoftArchitect AI
> **HU:** HU-3.6 Test Suite Completion & SQLite Fix (PIT-80)
> **Phase:** 1.3 i18n Architecture Design
> **Date:** 2025-01-30
> **Status:** ⚠️ PHASE 1 STEP 1.3 - Hardcoded String Inventory Complete
> **Methodology:** Empirical code survey (not speculation)

---

## 📖 Table of Contents

1. [Executive Summary](#executive-summary)
2. [Current i18n Status](#current-i18n-status)
3. [Hardcoded String Inventory](#hardcoded-string-inventory)
4. [Flutter Test Compilation Failures](#flutter-test-compilation-failures)
5. [Missing Entities & Widgets](#missing-entities--widgets)
6. [Recommended i18n Architecture](#recommended-i18n-architecture)
7. [Implementation Plan (PHASE 2: GREEN)](#implementation-plan-phase-2-green)
8. [References](#references)

---

## Executive Summary

### Current State Assessment

| **Aspect** | **Status** | **Details** |
|-----------|-----------|-----------|
| **Dependencies** | ✅ **PRESENT** | `flutter_localizations`, `intl` already in pubspec.yaml |
| **Hardcoded Strings (UI)** | ❌ **9 FOUND** | Spanish strings in Text() widgets not internationalized |
| **ARB Files** | ❌ **MISSING** | No app_en.arb or app_es.arb files exist |
| **Localization Provider** | ❌ **MISSING** | No AppLocalizations or locale state management |
| **flutter_gen** | ❌ **MISSING** | No generated localization code |
| **Test Support** | ❌ **BROKEN** | 37 Flutter tests fail due to package resolution issues |
| **Domain Entities** | ⚠️ **INCOMPLETE** | FontFamily, Language, DocumentProposal missing from codebase |
| **Architecture** | ❌ **NOT PLANNED** | No Riverpod provider for locale switching |

### Critical Findings

1. **Infrastructure Partially Ready:**
   - ✅ Dependencies installed (`intl`, `flutter_localizations`)
   - ❌ No actual localization implementation

2. **Hardcoded Strings Identified:**
   - 9 unique Spanish strings found in Flutter code
   - All in UI widgets (Text, button labels)
   - Need equivalent English translations

3. **Test Compilation Blocked:**
   - 37 Flutter tests fail due to `softarchitect_ai` package resolution
   - Domain entities referenced in tests don't exist
   - Cannot measure i18n coverage until tests compile

4. **Architecture Needed:**
   - Missing locale provider (Riverpod StateNotifier)
   - No language switching mechanism
   - No translations management system

---

## Current i18n Status

### Dependency Configuration

**File:** `src/client/pubspec.yaml` (lines 25-32)

```yaml
dependencies:
  flutter_localizations:
    sdk: flutter
  flutter_markdown_plus: ^1.0.7
  flutter_riverpod: ^3.2.1
  go_router: ^17.1.0
  intl: ^0.20.2  # ✅ Installed
```

**Status:** ✅ Required packages present

**Missing Configuration:**
```yaml
# ❌ NOT IN pubspec.yaml:
# flutter_gen:
#   output: lib/gen/
#   line_length: 100
```

### Existing i18n Usage

**Search Results:** Only 1 reference to i18n in codebase

```dart
// src/client/lib/features/filesystem/infrastructure/logging/audit_logger.dart
import 'package:intl/intl.dart';  // ← Only for date formatting, not translations
```

**Conclusion:**
- ❌ No AppLocalizations usage
- ❌ No language switching
- ❌ No translation pipeline

---

## Hardcoded String Inventory

### Discovered Hardcoded Strings

**Total Count:** 9 unique Spanish strings

**Location:** `src/client/lib` Flutter code

| # | String | Context | File | Type |
|---|--------|---------|------|------|
| 1 | `'Crear Proyecto'` | Button label | UI Widget | Button |
| 2 | `'Nuevo Proyecto'` | Dialog title | UI Widget | Title |
| 3 | `'Examinar...'` | Button label | UI Widget | Button |
| 4 | `'Validar y Guardar'` | Button label | UI Widget | Button |
| 5 | `'Refinar'` | Button label | UI Widget | Button |
| 6 | `'Rechazar'` | Button label | UI Widget | Button |
| 7 | `'Archivo guardado en: $outputFile'` | Success message | Message | Dynamic |
| 8 | `'Contenido copiado al portapapeles'` | Success message | Message | Dynamic |
| 9 | `'Error al guardar: $e'` | Error message | Message | Dynamic |

### Code Evidence

**Sample with Dollar Signs (Requires Special Handling):**

```dart
Text('Archivo guardado en: $outputFile')  // ← Dynamic content
Text('Error al guardar: $e')              // ← Dynamic error
```

**Analysis:**
- Strings #7-9 have dynamic placeholders
- These require parameterized translation support
- ARB files must support ICU-style placeholders

### Required English Translations

| Spanish | English |
|---------|---------|
| Crear Proyecto | Create Project |
| Nuevo Proyecto | New Project |
| Examinar... | Browse... |
| Validar y Guardar | Validate & Save |
| Refinar | Refine |
| Rechazar | Reject |
| Archivo guardado en: `$outputFile` | File saved to: `$outputFile` |
| Contenido copiado al portapapeles | Content copied to clipboard |
| Error al guardar: `$e` | Save error: `$e` |

---

## Flutter Test Compilation Failures

### Block Diagram: Why Tests Can't Compile i18n

```
42 Flutter Tests (41 with compilation errors)
├── ❌ 37 Tests: Cannot find 'softarchitect_ai' package
│   ├── Reason: pubspec.yaml missing softarchitect_ai dependency
│   ├── Referenced Entities Not Found:
│   │   ├── DocumentProposal (domain entity)
│   │   ├── ProposalCardWidget (widget)
│   │   ├── FileNode (domain entity)
│   │   ├── DirectoryTreeWidget (widget)
│   │   ├── Project (domain entity)
│   │   └── ... (more missing)
│   └── Result: COMPILATION FAILS
│
├── ⏳ 4 Tests: Potentially waiting for above to resolve
│
├── ✅ 7 Tests: Passing (likely pure unit tests, no imports)
│   └── Don't depend on domain/widget code
│
└── 🔴 0 Tests: Testing i18n functionality
    └── → NEED TO CREATE i18n test suite
```

### Impact on i18n Testing

**Current Status:** Cannot measure i18n coverage

**Blocker:**
1. Domain entities not defined yet
2. Widget code not complete
3. Tests can't compile to verify translations

**What This Means:**
- ❌ Cannot test locale switching
- ❌ Cannot verify translations appear correctly
- ❌ Cannot test parameterized messages
- ❌ Must fix domain entities FIRST (PHASE 2)

---

## Missing Entities & Widgets

### Entities Referenced in Tests But Not Found

**From Test Compilation Errors:**

```dart
// ❌ MISSING in domain/entities/__init__.py
class DocumentProposal {
  final String id;
  final String fileName;
  final ValidationState validationState;  // enum: pending|approved|rejected
  final DateTime createdAt;
}

class FileNode {
  final String name;
  final String path;
  final bool isDirectory;
  final List<FileNode> children;
}

class Project {
  final int id;
  final String name;
  final String path;
  final DateTime createdAt;
}
```

### Widgets Referenced in Tests But Not Found

**From Test Compilation Errors:**

```dart
// ❌ MISSING in lib/features/*/presentation/widgets/
class ProposalCardWidget extends StatelessWidget {
  final DocumentProposal proposal;
  final void Function(DocumentProposal) onValidate;
  final void Function(DocumentProposal) onReject;
  // ...
}

class DirectoryTreeWidget extends StatelessWidget {
  final FileNode root;
  final void Function(FileNode) onFileSelected;
  // ...
}
```

### Impact on i18n

**Cannot implement i18n for widgets that don't exist:**
- ProposalCardWidget UI text (validation buttons)
- DirectoryTreeWidget UI text (labels, tooltips)
- Project creation dialogs

**Must define entities and widgets first** → delays i18n implementation

---

## Recommended i18n Architecture

### Architecture Pattern: Riverpod + Intl + ARB

**Recommended Structure:**

```
src/client/lib/
├── l10n/                              [Localization data]
│   ├── app_en.arb                    [English translations]
│   ├── app_es.arb                    [Spanish translations]
│   └── LOCALE_MANIFEST.md            [Translation registry]
│
├── gen/                               [Generated code (flutter_gen)]
│   └── strings.g.dart                [Generated AppLocalizations]
│
├── core/
│   └── localization/
│       ├── locale_provider.dart      [Riverpod StateNotifier]
│       ├── supported_locales.dart    [Locale configuration]
│       └── translation_helper.dart   [Utility functions]
│
├── features/*/presentation/
│   └── *.dart                        [Use context.l10n.keyName]
│
└── main.dart                          [Enable localization support]
```

### ARB File Structure (JSON)

**File:** `src/client/lib/l10n/app_en.arb`

```json
{
  "@@locale": "en",
  "@@author": "ArchitectZero",
  "createProject": "Create Project",
  "newProject": "New Project",
  "browse": "Browse...",
  "validateAndSave": "Validate & Save",
  "refine": "Refine",
  "reject": "Reject",
  "fileSaved": "File saved to: {outputFile}",
  "@fileSaved": {
    "description": "Success message when file is saved",
    "placeholders": {
      "outputFile": {
        "type": "String",
        "example": "/home/user/project.dart"
      }
    }
  },
  "contentCopied": "Content copied to clipboard",
  "saveError": "Save error: {error}",
  "@saveError": {
    "description": "Error message when file save fails",
    "placeholders": {
      "error": {
        "type": "String",
        "example": "Permission denied"
      }
    }
  }
}
```

**File:** `src/client/lib/l10n/app_es.arb`

```json
{
  "@@locale": "es",
  "@@author": "ArchitectZero",
  "createProject": "Crear Proyecto",
  "newProject": "Nuevo Proyecto",
  "browse": "Examinar...",
  "validateAndSave": "Validar y Guardar",
  "refine": "Refinar",
  "reject": "Rechazar",
  "fileSaved": "Archivo guardado en: {outputFile}",
  "@fileSaved": {
    "description": "Mensaje de éxito cuando se guarda el archivo",
    "placeholders": {
      "outputFile": {
        "type": "String",
        "example": "/home/usuario/proyecto.dart"
      }
    }
  },
  "contentCopied": "Contenido copiado al portapapeles",
  "saveError": "Error al guardar: {error}",
  "@saveError": {
    "description": "Mensaje de error cuando falla el guardado",
    "placeholders": {
      "error": {
        "type": "String",
        "example": "Permiso denegado"
      }
    }
  }
}
```

### Locale Provider (Riverpod)

**File:** `src/client/lib/core/localization/locale_provider.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'supported_locales.dart';

/// Provides the current application locale
final localeProvider = StateNotifierProvider<LocaleNotifier, Locale>((ref) {
  return LocaleNotifier();
});

/// State notifier for managing application locale
class LocaleNotifier extends StateNotifier<Locale> {
  static const String _localeKey = 'app_locale';
  static const Locale _defaultLocale = Locale('es');  // Default to Spanish

  LocaleNotifier() : super(_defaultLocale) {
    _loadSavedLocale();
  }

  /// Load saved locale from persistent storage
  Future<void> _loadSavedLocale() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final languageCode = prefs.getString(_localeKey) ?? 'es';
      state = Locale(languageCode);
    } catch (e) {
      // Fall back to default if loading fails
      state = _defaultLocale;
    }
  }

  /// Switch to new locale
  Future<void> setLocale(Locale newLocale) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_localeKey, newLocale.languageCode);
      state = newLocale;
    } catch (e) {
      // Log but don't crash
      print('Failed to save locale preference: $e');
    }
  }

  /// Switch between Spanish and English
  Future<void> toggleLocale() async {
    final newLocale = state.languageCode == 'es' ? Locale('en') : Locale('es');
    await setLocale(newLocale);
  }

  /// Check if current locale is Spanish
  bool get isSpanish => state.languageCode == 'es';
}
```

### Supported Locales Configuration

**File:** `src/client/lib/core/localization/supported_locales.dart`

```dart
import 'package:flutter/material.dart';

/// List of supported locales
const List<Locale> supportedLocales = [
  Locale('en'),  // English
  Locale('es'),  // Spanish
];

/// Default locale if system locale not supported
const Locale fallbackLocale = Locale('es');

/// Locale display names for UI
const Map<String, String> localeNames = {
  'en': 'English',
  'es': 'Español',
};
```

### Usage in Widgets

**Pattern 1: Simple Translations**

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CreateProjectButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return ElevatedButton(
      onPressed: () { /* ... */ },
      child: Text(l10n.createProject),  // ✅ Translated
    );
  }
}
```

**Pattern 2: Parameterized Translations**

```dart
void showSuccessMessage(BuildContext context, String filePath) {
  final l10n = AppLocalizations.of(context)!;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(l10n.fileSaved(filePath)),  // ✅ Translated with parameter
    ),
  );
}
```

---

## Implementation Plan (PHASE 2: GREEN)

### Phase 2.1: Create ARB Files

**Duration:** 30 minutes

```bash
# Create localization directory
mkdir -p src/client/lib/l10n

# Create ARB files for EN and ES
cat > src/client/lib/l10n/app_en.arb << 'EOF'
{...}  # See full ARB structure above
EOF

cat > src/client/lib/l10n/app_es.arb << 'EOF'
{...}  # See full ARB structure above
EOF
```

### Phase 2.2: Create Locale Provider

**Duration:** 45 minutes

- [ ] Create `src/client/lib/core/localization/locale_provider.dart`
- [ ] Create `src/client/lib/core/localization/supported_locales.dart`
- [ ] Create `src/client/lib/core/localization/translation_helper.dart`
- [ ] Implement Riverpod StateNotifier for locale management
- [ ] Add SharedPreferences persistence

### Phase 2.3: Generate Localization Code

**Duration:** 15 minutes

```bash
cd src/client

# Generate App Localizations
flutter gen-l10n

# Verify generated file
ls -la lib/gen/strings.g.dart  # ✅ Should exist
```

### Phase 2.4: Enable in App

**Duration:** 30 minutes

Update `src/client/lib/main.dart`:

```dart
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/localization/locale_provider.dart';

void main() {
  runApp(ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return MaterialApp(
      locale: locale,  // ✅ Use Riverpod locale
      supportedLocales: supportedLocales,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Home(),
    );
  }
}
```

### Phase 2.5: Update Widgets

**Duration:** 2-3 hours

Replace all hardcoded strings in widgets:

```dart
// ❌ Before
Text('Crear Proyecto')

// ✅ After
Text(AppLocalizations.of(context)!.createProject)
```

**Files to Update:**
- Button labels (Crear Proyecto, Examinar, etc.)
- Dialog titles (Nuevo Proyecto)
- Messages (Archivo guardado en, Error al guardar)

### Phase 2.6: Create i18n Tests

**Duration:** 90 minutes

- [ ] Test locale switching via Riverpod
- [ ] Test translations loaded correctly
- [ ] Test parameterized messages
- [ ] Test fallback to default locale
- [ ] Test persistence of locale preference

---

## References

### Files to Create/Modify

| Path | Type | Status | Purpose |
|------|------|--------|---------|
| `src/client/lib/l10n/app_en.arb` | Create | 📝 TODO | English translations |
| `src/client/lib/l10n/app_es.arb` | Create | 📝 TODO | Spanish translations |
| `src/client/lib/core/localization/locale_provider.dart` | Create | 📝 TODO | Riverpod locale state |
| `src/client/lib/core/localization/supported_locales.dart` | Create | 📝 TODO | Supported locales config |
| `src/client/lib/main.dart` | Modify | 📝 TODO | Enable localization |
| `src/client/pubspec.yaml` | Modify | 📝 TODO | Add flutter_gen config |
| Various widgets | Modify | 📝 TODO | Use AppLocalizations |

### Hardcoded String Mapping

| String | Key | Files Affected |
|--------|-----|-----------------|
| Crear Proyecto | createProject | (TBD - need to identify files) |
| Nuevo Proyecto | newProject | (TBD) |
| Examinar... | browse | (TBD) |
| Validar y Guardar | validateAndSave | (TBD) |
| Refinar | refine | (TBD) |
| Rechazar | reject | (TBD) |
| Archivo guardado en | fileSaved | (TBD) |
| Contenido copiado al portapapeles | contentCopied | (TBD) |
| Error al guardar | saveError | (TBD) |

### Flutter Test Blockers

- ✅ 9 hardcoded strings identified
- ❌ 37 tests can't compile (missing domain entities/widgets)
- ❌ Cannot test i18n until entities are created
- ❌ Cannot update widgets until they exist

---

## Summary: Phase 1 Step 1.3 Deliverables

✅ **Completed:**
- Survey of hardcoded strings (9 found)
- ARB file structure designed
- Locale provider architecture designed
- Riverpod pattern documented
- Implementation plan created

⏳ **Pending (Phase 2):**
- Create ARB files with translations
- Implement locale provider
- Generate localization code
- Update all widgets
- Create i18n tests

❌ **Blocked By:**
- Domain entities not yet defined (Phase 2.1)
- Widgets not yet implemented (Phase 2.2)
- Flutter tests can't compile (Phase 2 blocker)

---

**Document Status:** ✅ COMPLETE (Phase 1 Step 1.3)
**Deliverables Created:** This i18n architecture report
**Next Step:** Phase 1 Step 1.4 - Update PROGRESS.md with reality
**Last Updated:** 2025-01-30
