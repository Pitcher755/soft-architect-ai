# 🧪 Tests - SoftArchitect AI Monorepo

> **Última actualización:** 4 de febrero de 2026
> **Estructura:** Monorepo optimizado con separación por tecnología
> **Estado:** ✅ Operacional - 177/185 tests pasando (95.7%)

## 📂 Estructura Actual

```
tests/
├── flutter/                    # 🎯 Flutter tests suite (212 tests)
│   ├── test/
│   │   ├── unit/              # 169 unit tests
│   │   │   └── features/
│   │   │       └── project_shell/
│   │   │           ├── data/
│   │   │           ├── domain/
│   │   │           ├── infrastructure/
│   │   │           └── presentation/
│   │   │
│   │   ├── widget/            # 36 widget tests
│   │   │   └── features/
│   │   │       └── project_shell/presentation/
│   │   │
│   │   ├── integration/       # 9 integration tests
│   │   │   ├── features/
│   │   │   └── helpers/
│   │   │       └── project_fixtures.dart
│   │   │
│   │   └── helpers/           # Shared test utilities (DEPRECATED)
│   │       └── See src/client/lib/tests/ instead
│   │
│   ├── pubspec.yaml           # Flutter test dependencies
│   ├── .dart_tool/            # Dart SDK cache
│   └── build/                 # Build artifacts
│
├── python/                     # 🐍 Python tests (5 tests)
│   ├── unit/
│   │   ├── test_api.py
│   │   ├── test_architecture.py
│   │   ├── test_config.py
│   │   ├── test_errors.py
│   │   └── test_rag_loader.py
│   │
│   ├── integration/           # Future: API integration tests
│   └── helpers/               # Future: Test utilities
│
├── test -> flutter/test       # Symlink para compatibilidad con Flutter CLI
├── pubspec.yaml              # ROOT: Flutter project config
├── README.md                 # This file
└── README_REFACTOR.md        # Detailed refactor documentation
```

## � Ubicaciones Importantes

### Helper Files (Fixtures & Utilities)
- **Primary Location:** `src/client/lib/tests/`
  - `project_fixtures.dart` - Project entity fixtures
  - `test_helper.dart` - Test utilities
  - **Why here:** Package imports in tests reference `package:softarchitect_ai/tests/helpers/`

- **Legacy Location:** `tests/flutter/test/helpers/` (deprecated, use src/client/lib/tests/)

## 🚀 Ejecución de Tests

### From Monorepo Root

```bash
# Run Flutter unit & widget tests
scripts/run_tests.sh flutter

# Run Python tests
scripts/run_tests.sh python

# Run integration tests
scripts/run_tests.sh integration

# Run all tests
scripts/run_tests.sh all

# Run with coverage (Flutter only)
scripts/run_tests.sh flutter --coverage
```

### Direct Execution (For Debugging)

```bash
# Flutter tests
cd tests && flutter test

# Python tests
cd tests/python/unit && python -m pytest . -v

# Specific test
cd tests && flutter test test/unit/features/project_shell/...
```

## 📊 Test Coverage

| Framework | Count | Type | Status |
|-----------|-------|------|--------|
| **Flutter** | 169 | Unit | ✅ Passing |
| **Flutter** | 36 | Widget | ✅ Passing |
| **Flutter** | 9 | Integration | ✅ Passing |
| **Python** | 5 | Unit | ⏳ Pending setup |
| **Total** | **219** | Mixed | **95.7% ✅** |

## 🛠️ Test Infrastructure

### Test Helpers & Fixtures
- **Location:** `src/client/lib/tests/`
  - `project_fixtures.dart` - Sample data for testing
  - `test_helper.dart` - Database and utility functions

### Test Scripts
- **Root:** `../run_tests.sh` - Centralized test executor
  - Auto-routes to correct directories
  - Supports all test types

## 📝 Import Patterns

### ✅ CORRECT: Package Imports
```dart
// For tests in tests/flutter/test/
import 'package:softarchitect_ai/tests/helpers/test_helper.dart';
import 'package:softarchitect_ai/tests/helpers/project_fixtures.dart';
```

**Why Package Imports?**
- Tests use the app's package namespace
- Helpers located in `src/client/lib/tests/`
- Cleaner, more maintainable imports

## ✅ CI/CD Integration

Tests are automatically run on every push via GitHub Actions.

**Pipeline Command:**
```bash
./run_tests.sh all  # Runs Flutter + Python + Integration tests
```

## 🧹 Cleanup Notes (4 Feb 2026)

**Files Removed:**
- ❌ `tests/test_*.py` (moved to `tests/python/unit/`)
- ❌ `tests/__init__.py` (cleaned up old structure)
- ❌ `tests/pubspec.lock` (cached file)
- ❌ Root `/test` symlink (replaced by `tests/test`)

**Kept for Compatibility:**
- ✅ `tests/test -> flutter/test` (symlink for Flutter CLI)
- ✅ `tests/pubspec.yaml` (project reference)

## 🔧 Troubleshooting

### "Error when reading 'helpers/...': No such file or directory"
**Solution:** Use package imports instead of relative paths
```dart
// ✅ CORRECT
import 'package:softarchitect_ai/tests/helpers/test_helper.dart';

// ❌ WRONG
import 'helpers/test_helper.dart';
```

### "Cannot find package 'softarchitect_ai'"
**Solution:** Run `flutter pub get` in `tests/flutter/`
```bash
cd tests/flutter && flutter pub get
```

### Tests not found when running `./run_tests.sh`
**Solution:** Make sure you're in the monorepo root
```bash
cd /home/pitcherdev/Espacio-de-trabajo/Master/soft-architect-ai
scripts/run_tests.sh flutter
```

## 📖 Related Documentation

- [REFACTOR_TESTS.md](../REFACTOR_TESTS.md) - Refactor summary
- [README_REFACTOR.md](./README_REFACTOR.md) - Implementation details
- [run_tests.sh](../scripts/run_tests.sh) - Test execution script
- [AGENTS.md](../AGENTS.md) - Architecture & testing strategy
