# 🧪 Tests - SoftArchitect AI Monorepo

> **Estructura Centralizada:** All tests for Flutter and Python in one place
> **Organization:** By type (unit/integration) then by app (flutter/python)
> **Execution:** From root using `./run_tests.sh`

## 📂 Estructura

```
tests/
├── unit/
│   ├── flutter/
│   │   ├── domain/         # Domain layer unit tests
│   │   ├── data/           # Data layer unit tests
│   │   └── presentation/   # Presentation layer unit tests (coming soon)
│   │
│   └── python/             # Python unit tests (future)
│
├── integration/
│   ├── flutter/            # Flutter widget/integration tests
│   ├── python/             # Python API integration tests
│   └── e2e/                # End-to-end client ↔ server tests
│
├── fixtures/               # Shared test data
├── mocks/                  # Shared mock generators
│
├── test_helper.dart        # Dart test utilities
├── conftest.py            # Python test utilities (future)
└── README.md              # This file
```

## 🚀 Ejecución de Tests

### From Monorepo Root

```bash
# Run Flutter unit tests
./run_tests.sh flutter

# Run Python tests (when available)
./run_tests.sh python

# Run integration tests
./run_tests.sh integration

# Run all tests
./run_tests.sh all
```

### Manual Execution (for debugging)

#### Flutter Tests
```bash
cd src/client
flutter test ../../tests/unit/flutter/ --verbose
cd ../..
```

#### Python Tests
```bash
cd src/server
pytest ../../tests/unit/python/ -v --cov=services
cd ../..
```

## 📊 Current Test Status

### Unit Tests (Flutter)

| Module | Tests | Status |
|--------|-------|--------|
| `domain/project_validation_use_case_test.dart` | 4 | ✅ Ready |
| `domain/directory_tree_use_case_test.dart` | 3 | ✅ Ready |
| `domain/file_search_use_case_test.dart` | 3 | ✅ Ready |
| `data/sqlite_data_source_test.dart` | 3 | ✅ Ready |
| `data/project_repository_impl_test.dart` | 2 | ✅ Ready |
| **Total** | **15** | **✅ Ready to run** |

### Integration Tests
- 🟡 Not yet implemented
- Planned for Phase 3

### Python Tests
- 🟡 Not yet implemented
- Will mirror Flutter structure

## 🛠️ Test Infrastructure

### Fixtures (`tests/fixtures/`)
Shared test data:
- `project_fixtures.dart` - Sample projects and file structures

### Test Helpers
- `tests/test_helper.dart` - Dart utilities (SQLite in-memory setup)
- `tests/conftest.py` - Python utilities (future)

## 📝 Import Pattern (Relative Imports for Centralized Tests)

Since tests are centralized in `/tests/` but Flutter sources are in `src/client/lib/`, tests use **relative imports**:

```dart
// ✅ CORRECT: Relative import from centralized test location
import '../../../../src/client/lib/features/project_shell/domain/use_cases/my_use_case.dart';

// ❌ WRONG: Package import only works inside src/client/
// import 'package:softarchitect_ai/features/project_shell/domain/use_cases/my_use_case.dart';
```

**Why Relative Imports?**
- Tests are **outside** the Flutter package scope
- Relative imports resolve from the test file location
- Maintains centralized test architecture
- Standard practice in monorepos

**Path Resolution:**
```
tests/unit/flutter/domain/               (test location)
  ↓ (4 levels up: ../../../..)
src/client/lib/features/               (source location)
```

## ✅ CI/CD Integration

Tests are automatically run on every push via GitHub Actions:

```yaml
# .github/workflows/test.yaml
- name: Run All Tests
  run: ./run_tests.sh all
```

## 📚 Why Centralized Tests?

See [MONOREPO_TESTING_ARCHITECTURE.en.md](../02-SETUP_DEV/MONOREPO_TESTING_ARCHITECTURE.en.md) for detailed explanation:

- **Single Source of Truth:** All tests in `/tests`
- **DRY Principle:** Shared fixtures and mocks
- **Simplified CI/CD:** One command runs everything
- **Industry Standard:** Google Monorepo, Nx, Yarn all use centralized testing

## 🔧 Troubleshooting

### Tests not found
Make sure you're running from the monorepo root:
```bash
pwd  # Should be /home/pitcherdev/Espacio-de-trabajo/Master/soft-architect-ai
./run_tests.sh flutter
```

### Import errors in tests
Imports use `package:softarchitect_ai/...` which Flutter resolves automatically. Make sure `.fluttertest` is configured.

### SQLite errors
SQLite is initialized in-memory for testing. See `tests/test_helper.dart` for setup details.

## 📖 Next Steps

1. ✅ Implement centralized test structure
2. ✅ Move Flutter tests to `/tests/unit/flutter/`
3. ⏳ Implement Python tests in `/tests/unit/python/`
4. ⏳ Add integration tests in `/tests/integration/`
5. ⏳ Add E2E tests for client ↔ server
