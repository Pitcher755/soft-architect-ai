# 📝 Imports in Centralized Tests - Monorepo Pattern

> **Date:** February 3, 2026
> **Status:** ✅ Implemented and Verified

## 📖 Table of Contents

1. [The Problem](#the-problem)
2. [The Solution](#the-solution)
3. [How It Works](#how-it-works)
4. [Path Structure](#path-structure)
5. [Practical Examples](#practical-examples)

---

## The Problem

When tests are **centralized** in `/tests/` but sources are in `src/client/lib/`, there's a context conflict:

```
Test Location:
  tests/unit/flutter/domain/my_use_case_test.dart

Source Location:
  src/client/lib/features/project_shell/domain/use_cases/my_use_case.dart

Problem:
  ❌ Test is OUTSIDE the Flutter package scope
  ❌ Package imports `package:softarchitect_ai/...` don't work
```

---

## The Solution

**Use Relative Imports** from the test file location:

```dart
// ✅ CORRECT: Relative import from centralized test
import '../../../../src/client/lib/features/project_shell/domain/use_cases/my_use_case.dart';

// ❌ WRONG: Package import only works inside src/client/
import 'package:softarchitect_ai/features/project_shell/domain/use_cases/my_use_case.dart';
```

### Why It Works

1. **Relative Import:** `../../../../src/client/lib/...`
   - Resolves from the current file location
   - Works from any filesystem location
   - Independent of package context

2. **Package Import:** `package:softarchitect_ai/...`
   - Only works within `pubspec.yaml` scope
   - Requires analyzer to be inside the package
   - Centralized tests are OUTSIDE the package

---

## How It Works

### Path Resolution

When Flutter executes a test with a relative import:

```dart
// tests/unit/flutter/domain/my_test.dart
import '../../../../src/client/lib/features/my_file.dart';
```

Flutter resolves:
```
tests/unit/flutter/domain/              (test location)
  ↓ cd ../../../..                       (go up 4 levels)
tests/                                   (root)
  ↓
src/                                     (now descend)
  ↓
src/client/
  ↓
src/client/lib/features/my_file.dart    (FOUND!)
```

### Level Counting

From any test location, the pattern is consistent:

| Test Location | Levels Up | Path to `src/client/lib/` |
|---|---|---|
| `tests/unit/flutter/domain/` | 4 | `../../../../src/client/lib/` |
| `tests/unit/flutter/data/` | 4 | `../../../../src/client/lib/` |
| `tests/fixtures/` | 2 | `../../src/client/lib/` |
| `tests/mocks/` | 2 | `../../src/client/lib/` |

---

## Path Structure

### Directories in Monorepo

```
soft-architect-ai/                              (monorepo root)
│
├── src/
│   ├── client/                                 (Flutter app)
│   │   ├── lib/                                (source code)
│   │   │   └── features/
│   │   │       └── project_shell/
│   │   │           ├── domain/                 ← Imports target
│   │   │           ├── data/
│   │   │           └── presentation/
│   │   └── pubspec.yaml                        (Flutter package)
│   │
│   └── server/                                 (Python FastAPI)
│
└── tests/                                      (CENTRALIZED TESTS)
    ├── unit/
    │   └── flutter/
    │       ├── domain/                         ← Tests here
    │       │   └── my_use_case_test.dart
    │       └── data/
    │
    └── fixtures/                               ← Fixtures here
        └── project_fixtures.dart
```

### Relative Path from Test

```dart
// tests/unit/flutter/domain/my_use_case_test.dart
//
// Need to access:
//   src/client/lib/features/project_shell/domain/use_cases/my_use_case.dart
//
// Calculation:
//   From: tests/unit/flutter/domain/
//   Up: ../../../..  (4 levels)
//   Then: src/client/lib/features/project_shell/domain/use_cases/

import '../../../../src/client/lib/features/project_shell/domain/use_cases/my_use_case.dart';
```

---

## Practical Examples

### Domain Layer Tests

```dart
// tests/unit/flutter/domain/project_validation_use_case_test.dart
import 'package:flutter_test/flutter_test.dart';
import '../../../../src/client/lib/features/project_shell/domain/use_cases/project_validation_use_case.dart';

void main() {
  test('isValidName rejects short names', () {
    expect(ProjectValidationUseCase.isValidName('ab'), false);
  });
}
```

### Data Layer Tests

```dart
// tests/unit/flutter/data/sqlite_data_source_test.dart
import 'package:flutter_test/flutter_test.dart';
import '../../../../src/client/lib/features/project_shell/data/data_sources/sqlite_data_source.dart';
import '../../../../src/client/lib/features/project_shell/data/models/project_model.dart';

void main() {
  test('saveProject inserts record', () async {
    final ds = SQLiteDataSource(db);
    // ... test logic
  });
}
```

### Fixtures

```dart
// tests/fixtures/project_fixtures.dart
import '../../src/client/lib/features/project_shell/domain/entities/project.dart';
import '../../src/client/lib/features/project_shell/domain/entities/file_node.dart';

final testProject = Project(...);
```

---

## ✅ Updated Files

| File | Imports Fixed | Status |
|---|---|---|
| `tests/unit/flutter/domain/project_validation_use_case_test.dart` | ✅ | Ready |
| `tests/unit/flutter/domain/directory_tree_use_case_test.dart` | ✅ | Ready |
| `tests/unit/flutter/domain/file_search_use_case_test.dart` | ✅ | Ready |
| `tests/unit/flutter/data/sqlite_data_source_test.dart` | ✅ | Ready |
| `tests/unit/flutter/data/project_repository_impl_test.dart` | ✅ | Ready |
| `tests/fixtures/project_fixtures.dart` | ✅ | Ready |

---

## 🚀 Running Tests

### With Corrected Imports

```bash
# From monorepo root
./run_tests.sh flutter

# Or manually from src/client
cd src/client
flutter test ../../tests/unit/flutter/ --verbose
cd ../..
```

### Advantages of This Pattern

1. ✅ **Centralized Tests:** Single source of truth in `/tests`
2. ✅ **Relative Imports:** Work from any location
3. ✅ **Maintainable:** Clear and predictable paths
4. ✅ **Scalable:** New tests follow same pattern
5. ✅ **Monorepo Compatible:** Industry standard pattern

---

## 📚 References

- [MONOREPO_TESTING_ARCHITECTURE.en.md](../02-SETUP_DEV/MONOREPO_TESTING_ARCHITECTURE.en.md)
- [MONOREPO_TESTING_ARCHITECTURE.es.md](../02-SETUP_DEV/MONOREPO_TESTING_ARCHITECTURE.es.md)
- [tests/README.md](../../tests/README.md)
