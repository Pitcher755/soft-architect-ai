# 📂 Monorepo Test Structure - MANDATORY REFERENCE

> **Status:** 🔴 MANDATORY
> **Aplicable a:** All HU implementations (HU-3.1+)
> **Actualizado:** 2026-02-05

---

## 🎯 Core Principle: CENTRALIZED TESTS AT PROJECT ROOT

```
soft-architect-ai/
├── src/                    ❌ NO TESTS HERE
│   ├── client/             ❌ NO TESTS HERE
│   └── server/             ❌ NO TESTS HERE
│
├── tests/                  ✅ ALL TESTS HERE (Monorepo Root)
│   ├── python/             ✅ Python/FastAPI backend tests
│   ├── test/               ✅ Flutter/Dart client tests
│   └── README.md
│
└── [other directories]
```

---

## ✅ CORRECT Structure

### Python Tests (Backend)

```
tests/python/
│
├── conftest.py             # Global pytest configuration
├── README_MIGRATION.md     # Migration documentation
│
├── unit/
│   ├── app/
│   │   ├── test_main.py
│   │   ├── test_config.py
│   │   └── ... (api, core tests)
│   ├── core/
│   │   └── test_exceptions.py
│   ├── services/
│   │   ├── rag/
│   │   │   ├── test_orchestrator.py              ✅ CORRECT
│   │   │   ├── test_template_loader.py           ✅ CORRECT
│   │   │   └── test_streaming.py                 ✅ CORRECT
│   │   └── vectors/
│   └── domain/
│
├── integration/
│   └── services/rag/
│       └── test_chat_e2e.py                      ✅ CORRECT
│
└── fixtures/
    └── kb_mock/
        └── mock_data.json
```

**Path Pattern:** `tests/python/[unit|integration]/[module]/test_*.py`

**Example:** `tests/python/unit/services/rag/test_orchestrator.py`

### Flutter Tests (Frontend)

```
tests/test/
│
├── unit/
│   └── features/chat/
│       ├── domain/
│       │   └── entities/
│       │       └── chat_message_test.dart        ✅ CORRECT
│       └── data/
│           └── repositories/
│               └── chat_repository_impl_test.dart ✅ CORRECT
│
├── widget/
│   └── features/chat/
│       └── presentation/
│           └── widgets/
│               ├── proposal_card_test.dart       ✅ CORRECT
│               └── streaming_indicator_test.dart ✅ CORRECT
│
├── integration/
│   └── features/chat/
│       └── chat_flow_test.dart                   ✅ CORRECT
│
└── helpers/
    └── test_helpers.dart
```

**Path Pattern:** `tests/test/[unit|widget|integration]/features/[feature]/...test.dart`

**Example:** `tests/test/unit/features/chat/domain/entities/chat_message_test.dart`

---

## ❌ INCORRECT Structure (DO NOT USE)

```
❌ src/server/tests/                   ← WRONG
❌ src/client/tests/                   ← WRONG
❌ src/server/test/                    ← WRONG
❌ src/client/test/                    ← WRONG
❌ app/tests/                          ← WRONG
❌ client/tests/                       ← WRONG
```

---

## 🔄 For Each HU Implementation

### When Creating Tests

**DO:**
```bash
# Backend test
tests/python/unit/services/rag/test_[feature].py

# Frontend test
tests/test/unit/features/[feature]/[layer]/[item]_test.dart
```

**DON'T:**
```bash
# ❌ Wrong
src/server/tests/test_[feature].py
src/client/test/[feature]_test.dart
```

### When Referencing Tests

**In Workflow Documents:**
```markdown
# ✅ Correct
**File:** `tests/python/unit/services/rag/test_orchestrator.py`
**File:** `tests/test/unit/features/chat/domain/entities/chat_message_test.dart`

# ❌ Wrong
**File:** `src/server/tests/unit/services/rag/test_orchestrator.py`
**File:** `src/client/tests/unit/features/chat/chat_message_test.dart`
```

### When Running Tests

```bash
# Python tests (from project root)
pytest tests/python/ -v
pytest tests/python/unit/ -v
pytest tests/python/unit/services/rag/ -v

# Flutter tests (from project root)
cd src/client
flutter test ../../tests/test/ -v
flutter test ../../tests/test/unit/ -v

# Coverage
pytest tests/python/ --cov=app --cov-report=html
```

---

## 📋 Configuration Files

### pyproject.toml

```toml
[tool.pytest.ini_options]
testpaths = ["../../tests/python"]  # Relative from src/server/
python_files = ["test_*.py", "*_test.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]
```

### pyrightconfig.json

```json
{
  "include": ["tests/python"],
  "exclude": ["**/node_modules", "**/__pycache__"]
}
```

### .github/workflows/backend-ci.yaml

```yaml
- name: Run Tests
  run: |
    cd src/server
    pytest ../../tests/python/ --cov=app --cov-fail-under=80 -v
```

---

## 🔗 Migration Reference

### Python Tests Migrated (22 files)

| Old Path | New Path |
|----------|----------|
| `src/server/tests/unit/app/` | `tests/python/unit/app/` |
| `src/server/tests/unit/core/` | `tests/python/unit/core/` |
| `src/server/tests/unit/services/rag/` | `tests/python/unit/services/rag/` |
| `src/server/tests/integration/` | `tests/python/integration/` |

**Status:** ✅ COMPLETED (commit 4efe4c2)

### Flutter Tests (TO BE MIGRATED)

| Old Path | New Path |
|----------|----------|
| `src/client/tests/unit/` | `tests/test/unit/` |
| `src/client/tests/widget/` | `tests/test/widget/` |
| `src/client/tests/integration/` | `tests/test/integration/` |

**Status:** ⏳ PENDING (post HU-3.3)

---

## ✅ Validation Checklist

For every test file creation:

- [ ] Test file located in `tests/python/` (Python) or `tests/test/` (Flutter)
- [ ] Directory structure mirrors source structure
- [ ] Path follows pattern: `tests/[python|test]/[type]/[module]/test_*.py[dart]`
- [ ] No tests exist in `src/` directories
- [ ] Configuration files updated if new test type added
- [ ] Documentation updated with correct path references

---

## 📚 See Also

- [HU-3.3_IMPLEMENTATION_WORKFLOW_MASTER.md](../HU-3.3_CHAT_SEQUENTIAL_DOCS/HU-3.3_IMPLEMENTATION_WORKFLOW_MASTER.md) - References this structure
- [tests/python/README_MIGRATION.md](../../tests/python/README_MIGRATION.md) - Python test setup
- [TESTS_MIGRATION_REPORT.md](../PROJECT_REPORT/TESTS_MIGRATION_REPORT.md) - Migration details

---

> **This is the OFFICIAL reference for all test structure decisions.**
> **All HU workflows and implementations MUST comply with this structure.**
