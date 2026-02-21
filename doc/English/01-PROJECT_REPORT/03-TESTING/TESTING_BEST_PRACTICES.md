# Testing Best Practices

> **Date:** 10/02/2026
> **Status:** ✅ COMPLETE
> **Responsable:** ArchitectZero (QA Engineering)

---

## 📖 Table of Contents

1. [Testing Philosophy](#testing-philosophy)
2. [Test Structure & Organization](#test-structure--organization)
3. [Test Naming Conventions](#test-naming-conventions)
4. [Mock vs Real Dependencies](#mock-vs-real-dependencies)
5. [Fixture Management](#fixture-management)
6. [CI/CD Integration](#cicd-integration)
7. [Common Patterns](#common-patterns)
8. [Troubleshooting](#troubleshooting)

---

## Testing Philosophy

### TDD Mindset: Red → Green → Refactor

**Step 1: RED - Write failing test**
```python
def test_create_project_with_duplicate_id_fails():
    """Project creation should fail if ID already exists."""
    with pytest.raises(ValidationError):
        repo.create_project(project)  # ← This fails (doesn't exist yet)
```

**Step 2: GREEN - Implement minimum code**
```python
def create_project(self, project: Project) -> None:
    if self._project_exists(project.id):
        raise ValidationError("Project ID already exists")
    # ... rest of implementation
```

**Step 3: REFACTOR - Optimize without changing behavior**
```python
def _validate_unique_id(self, project_id: str) -> None:
    """Separate validation concern."""
    if self._project_exists(project_id):
        raise ValidationError("[VALIDATION_001_ID] Project ID already exists")
```

### Coverage Goals

```
Critical Business Logic: 100%
  ├─ Domain models
  ├─ Use cases
  └─ Validation rules

Data Layer Adapters: >90%
  ├─ Database operations
  ├─ Error handling
  └─ Edge cases

API Endpoints: >85%
  ├─ Happy path
  ├─ Error cases
  └─ Input validation

UI Components: >70% (Flutter)
  ├─ Widget rendering
  ├─ User interactions
  └─ State changes
```

---

## Test Structure & Organization

### File Organization

```
tests/
├── python/
│   ├── unit/                    # Fast, isolated tests
│   │   ├── domain/
│   │   │   └── test_models.py
│   │   ├── data/
│   │   │   └── test_repository.py
│   │   └── services/
│   │       └── test_rag_service.py
│   │
│   ├── integration/             # Test interactions, slower
│   │   ├── test_sqlite_performance.py
│   │   ├── test_security_sql_injection.py
│   │   └── test_api_endpoints.py
│   │
│   ├── e2e/                     # End-to-end, slowest
│   │   └── test_complete_workflow.py
│   │
│   └── conftest.py              # Shared fixtures
│
└── dart/
    ├── unit/
    │   └── domain_test.dart
    ├── integration/
    │   └── provider_test.dart
    └── widget/
        └── layout_test.dart
```

### Test Class Organization

```python
# ✅ GOOD - Clear organization
class TestSQLiteRepository:
    """SQLite repository tests."""

    # Setup & Teardown
    @pytest.fixture
    def repo(self, temp_db):
        """Create repository with temporary database."""
        return SQLiteRepository(TransactionManager(temp_db))

    # CRUD Tests
    class TestCreate:
        def test_create_project_success(self, repo): ...
        def test_create_duplicate_fails(self, repo): ...

    class TestRead:
        def test_get_project_found(self, repo): ...
        def test_get_project_not_found(self, repo): ...

    # Edge Case Tests
    class TestEdgeCases:
        def test_empty_name_validation(self, repo): ...
        def test_special_characters_handled(self, repo): ...
```

---

## Test Naming Conventions

### Format: `test_{method}_{scenario}_{expected_result}`

**Pattern Analysis:**

```
METHOD        → What function/method is being tested
SCENARIO      → Input condition or context
EXPECTED_RESULT → What should happen
```

### Examples (✅ GOOD)

```python
# ✅ Domain layer
def test_project_validate_rejects_empty_name():
def test_project_validate_enforces_max_length():
def test_project_validate_accepts_valid_input():

# ✅ Data layer
def test_repository_create_inserts_record():
def test_repository_get_by_id_returns_none_when_not_found():
def test_repository_update_modifies_existing():

# ✅ Integration
def test_api_list_projects_returns_200_with_data():
def test_api_create_project_rejects_invalid_input():
def test_security_sql_injection_in_name_prevented():

# ✅ Performance
def test_bulk_insert_1000_records_within_target():
def test_query_by_name_sub_millisecond():
```

### Examples (❌ WRONG)

```python
# ❌ Vague
def test_project():
def test_works():
def test_valid():

# ❌ Too specific impl details
def test_sqlite_connection_open_close():
def test_cursor_execute_select():

# ❌ Multiple scenarios
def test_create_and_delete():
def test_validation_and_persistence():
```

---

## Mock vs Real Dependencies

### Decision Tree

```
┌─ Is this dependency external?
│  ├─ YES → Mock it (unless integration test)
│  └─ NO  ↓
└─ Is it slow/non-deterministic?
   ├─ YES → Mock it
   └─ NO  ↓
      └─ Use REAL for integration tests
```

### Example: Unit Test (Mocked)

```python
from unittest.mock import MagicMock, patch

class TestUserService:
    """Unit test with mocked database."""

    def test_get_user_returns_user_dto(self):
        # MOCK the repository (external dependency)
        mock_repo = MagicMock(spec=UserRepository)
        mock_repo.get_user.return_value = User(id="1", name="Alice")

        service = UserService(mock_repo)
        user = service.get_user("1")

        assert user.name == "Alice"
        mock_repo.get_user.assert_called_once_with("1")
```

### Example: Integration Test (Real DB)

```python
class TestUserRepositoryIntegration:
    """Integration test with real SQLite database."""

    @pytest.fixture
    def repo(self, temp_db):
        # REAL database connection (not mocked)
        tx_manager = TransactionManager(temp_db)
        return UserRepository(tx_manager)

    def test_create_and_retrieve_user(self, repo):
        user = User(id="1", name="Bob")

        # Actual database operations
        repo.create_user(user)
        retrieved = repo.get_user("1")

        assert retrieved.name == "Bob"
```

### Mocking Strategy Reference

| Dependency | Unit Test | Integration | E2E |
|-----------|-----------|-------------|-----|
| Database | Mock | Real | Real |
| External API | Mock | Mock | Real* |
| File System | Mock | Real* | Real |
| Logger | Mock | Real | Real |
| Crypto | Real | Real | Real |

*Only when necessary for testing specific behavior

---

## Fixture Management

### Fixture Scope Best Practices

```python
# ✅ FUNCTION SCOPE - Fresh instance per test
@pytest.fixture
def repo():  # ← Default scope
    """Create new repository for each test."""
    return SQLiteRepository(TransactionManager(":memory:"))

# ✅ MODULE SCOPE - Shared across tests in same file
@pytest.fixture(scope="module")
def static_data():
    """Load reference data once per module."""
    return load_test_data()

# ❌ AVOID SESSION SCOPE - Can cause test interactions
@pytest.fixture(scope="session")
def db():  # ← Don't use unless necessary
    """Shared DB across all tests - can cause pollution."""
    pass
```

### Parametrized Fixtures

```python
@pytest.mark.parametrize("input,expected", [
    ("valid-id", True),
    ("", False),
    ("..." * 100, False),
    ("\x00null", False),
])
def test_id_validation(input, expected):
    """Test ID validation with multiple inputs."""
    assert validate_id(input) == expected
```

### Fixture Composition

```python
@pytest.fixture
def temp_db(tmp_path):  # ← Compose fixtures
    """Create temporary SQLite database."""
    db_path = tmp_path / "test.db"
    return str(db_path)

@pytest.fixture
def repo(temp_db):  # ← Depends on temp_db
    """Repository using temporary database."""
    tx_manager = TransactionManager(temp_db)
    return SQLiteRepository(tx_manager)

@pytest.fixture
def populated_repo(repo):  # ← Depends on repo
    """Repository with sample data."""
    repo.create_project(Project(id="1", name="Test"))
    return repo
```

---

## CI/CD Integration

### Pre-commit Hooks (Local Validation)

```bash
#!/bin/bash
# .git/hooks/pre-commit

echo "Running tests before commit..."

# 1. Unit tests
pytest tests/python/unit --cov=services --cov-fail-under=80 -q

# 2. Type checking
pyright services/ core/

# 3. Format check
black --check src/server/

# 4. Lint
ruff check src/server/

echo "✅ All checks passed!"
exit 0
```

### GitHub Actions Pipeline

```yaml
# .github/workflows/python-tests.yaml
name: Python Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest

    steps:
      - name: Run unit tests
        run: pytest tests/python/unit -v --cov=services --cov-fail-under=80

      - name: Run integration tests
        run: pytest tests/python/integration -v

      - name: Upload coverage
        run: codecov --files coverage.xml
```

### Test Failure Handling

```python
# ✅ Good practice: Informative failure messages
def test_bulk_insert_within_target(perf_repo):
    start = time.time()

    for i in range(1000):
        perf_repo.create_project(Project(...))

    elapsed = time.time() - start
    target = 2.5

    assert elapsed < target, (
        f"Bulk insert took {elapsed:.3f}s (expected <{target}s). "
        f"Rate: {1000/elapsed:.0f} ops/sec"
    )
```

---

## Common Patterns

### Pattern 1: AAA (Arrange-Act-Assert)

```python
def test_create_project_success(self, repo):
    # ARRANGE - Setup
    project = Project(id="proj-001", name="Test", path="/tmp")

    # ACT - Execute
    repo.create_project(project)

    # ASSERT - Verify
    retrieved = repo.get_project("proj-001")
    assert retrieved.name == "Test"
```

### Pattern 2: Context Managers for Setup/Teardown

```python
def test_transaction_rollback_on_error(self, temp_db):
    # Setup with context manager
    with TransactionManager(temp_db) as tx_manager:
        # ACT
        with pytest.raises(ValidationError):
            tx_manager.execute_transaction([
                ("INSERT INTO ...", (bad_data,))
            ])

        # ASSERT - Verify rollback
        remaining = tx_manager.execute_transaction([("SELECT COUNT(*) ...",)])
        assert remaining == 0
```

### Pattern 3: Fixtures with Dependencies

```python
@pytest.fixture
def clean_repo(temp_db):
    """Repository guaranteed to be empty."""
    repo = SQLiteRepository(TransactionManager(temp_db))
    # Cleanup after test
    yield repo
    repo.clear_all()  # Optional cleanup
```

---

## Troubleshooting

### Issue 1: "Fixture 'repo' not found"

**Cause:** Fixture defined in different file, not imported

**Solution:**
```python
# Option 1: Move fixture to conftest.py
# tests/conftest.py
@pytest.fixture
def repo(temp_db):
    return SQLiteRepository(TransactionManager(temp_db))

# Option 2: Define locally in test file
@pytest.fixture
def repo(self, temp_db):
    return SQLiteRepository(TransactionManager(temp_db))
```

### Issue 2: "Test passes locally but fails in CI"

**Cause:** Test depends on environment (time, file system, OS)

**Solution:**
```python
# ✅ Use fixtures for environmental dependencies
def test_with_database(self, temp_db):  # ← Temporary DB, not /var/lib/db
    """Test uses isolated database."""
    pass

# ✅ Mock time
@patch('time.time', return_value=1000.0)
def test_with_mocked_time(self, mock_time):
    """Test doesn't depend on actual time."""
    pass
```

### Issue 3: "Tests run fine individually, fail together"

**Cause:** Test interference (shared state)

**Solution:**
```python
# ✅ Use function-scoped fixtures (isolated per test)
@pytest.fixture
def repo():  # ← No scope = function (default)
    """Fresh instance per test."""
    return SQLiteRepository(":memory:")

# ❌ Avoid class variables
# class TestRepository:
#     repo = None  # ← Shared across all tests!
```

---

## Summary Checklist

```markdown
## Pre-submit Test Checklist

- [ ] All tests passing locally
- [ ] Coverage >= 80% for business logic
- [ ] Naming convention followed (test_{method}_{scenario}_{expected})
- [ ] Fixtures properly scoped (function scope default)
- [ ] Mocks used for external dependencies
- [ ] Integration tests use real dependencies
- [ ] Parametrized tests for edge cases
- [ ] Error messages are informative
- [ ] No hardcoded test data (use factories/fixtures)
- [ ] Pre-commit hooks passed
- [ ] Code formatted (Black) and linted (Ruff)
```

---

**Version:** 1.0
**Status:** ✅ COMPLETE
**Last Updated:** 10/02/2025
