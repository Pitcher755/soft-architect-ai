# 🧪 Test-Driven Development (TDD) Methodology

> **Date:** 30/01/2026
> **Status:** ✅ MANDATORY
> **Philosophy:** "Don't write production code unless it's to pass a failing test"
> **Cycle:** Red 🔴 → Green 🟢 → Refactor 🔵
> **Goal:** Reliable, maintainable, test-documented code

Test-Driven Development is the backbone of quality in SoftArchitect. This is not a suggestion.

---

## 📖 Table of Contents

1. [The Sacred Cycle (The Red-Green-Refactor Loop)](#the-sacred-cycle-the-red-green-refactor-loop)
2. [AAA Structure (Arrange-Act-Assert)](#aaa-structure-arrange-act-assert)
3. [Practical Examples](#practical-examples)
4. [Testing Pyramid](#testing-pyramid)
5. [Best Practices by Language](#best-practices-by-language)
6. [Coverage Metrics](#coverage-metrics)
7. [Anti-Patterns & Common Mistakes](#anti-patterns--common-mistakes)

---

## The Sacred Cycle (The Red-Green-Refactor Loop)

```
┌──────────────────────────────────────────────────────────┐
│                 RED-GREEN-REFACTOR LOOP                  │
├──────────────────────────────────────────────────────────┤
│                                                          │
│   🔴 RED: Test Fails                                    │
│   ├─ Write test for feature that DOES NOT exist         │
│   ├─ Result: Test MUST fail (compilation or assert)     │
│   └─ Purpose: Define interface and behavior             │
│                                                          │
│        ↓↓↓ [Implement minimum code] ↓↓↓                  │
│                                                          │
│   🟢 GREEN: Test Passes                                 │
│   ├─ Write MINIMUM code to make it pass                 │
│   ├─ Hardcoding OK, ugly code OK                        │
│   ├─ Important: See the green bar                       │
│   └─ Result: Test MUST pass                             │
│                                                          │
│        ↓↓↓ [Improve the code] ↓↓↓                        │
│                                                          │
│   🔵 REFACTOR: Optimize                                 │
│   ├─ Improve code WITHOUT changing behavior             │
│   ├─ Apply SOLID, Clean Code                            │
│   ├─ Safety: Green test = you can refactor              │
│   └─ Test keeps passing                                 │
│                                                          │
│        ↓↓↓ [Return to start] ↓↓↓                         │
│                                                          │
└──────────────────────────────────────────────────────────┘
```

---

## AAA Structure (Arrange-Act-Assert)

Each test has 3 phases:

```
┌───────────────────────────┐
│ 1️⃣  ARRANGE (Setup)       │
│ Configure fixtures,       │
│ create mocks, setup data  │
├───────────────────────────┤
│ 2️⃣  ACT (Execute)         │
│ Execute code under test   │
├───────────────────────────┤
│ 3️⃣  ASSERT (Verify)       │
│ Verify results            │
└───────────────────────────┘
```

### Universal Template

```python
def test_something():
    # 1️⃣ ARRANGE: Setup
    input_data = {"email": "test@test.com"}
    expected_output = User(id=1, email="test@test.com")
    mock_repo = MagicMock()
    service = UserService(mock_repo)

    # 2️⃣ ACT: Execute
    result = service.create_user(input_data)

    # 3️⃣ ASSERT: Verify
    assert result.id == expected_output.id
    assert result.email == expected_output.email
    mock_repo.save.assert_called_once()
```

---

## Practical Examples

### Example 1: Simple Feature (User Creation)

#### 🔴 RED: Write Test First

```python
# tests/unit/domain/services/test_user_service.py

import pytest
from unittest.mock import MagicMock, AsyncMock
from src.domain.services.user_service import UserService
from src.domain.models.user import User
from src.domain.exceptions import UserAlreadyExistsError

@pytest.mark.asyncio
async def test_create_user_with_valid_email():
    """
    GIVEN: Valid email and password
    WHEN: Creating user
    THEN: Should return user with ID
    """
    # 1️⃣ ARRANGE
    email = "john@example.com"
    password = "SecurePass123!"
    expected_user = User(id=1, email=email, is_active=True)

    # Mock repository
    mock_repo = AsyncMock()
    mock_repo.get_user_by_email.return_value = None  # Does not exist
    mock_repo.save.return_value = expected_user

    service = UserService(repo=mock_repo)

    # 2️⃣ ACT
    result = await service.create(email=email, password=password)

    # 3️⃣ ASSERT
    assert result.id == 1
    assert result.email == email
    assert result.is_active is True
    mock_repo.get_user_by_email.assert_called_once_with(email)
    mock_repo.save.assert_called_once()


@pytest.mark.asyncio
async def test_create_user_with_existing_email():
    """
    GIVEN: Email that already exists
    WHEN: Attempting to create user
    THEN: Should raise UserAlreadyExistsError
    """
    # 1️⃣ ARRANGE
    email = "existing@example.com"
    existing_user = User(id=1, email=email)

    mock_repo = AsyncMock()
    mock_repo.get_user_by_email.return_value = existing_user

    service = UserService(repo=mock_repo)

    # 2️⃣ ACT & 3️⃣ ASSERT
    with pytest.raises(UserAlreadyExistsError):
        await service.create(email=email, password="ValidPass123!")
```

**Status:** Test FAILS ❌ (because `UserService` does not exist yet)

#### 🟢 GREEN: Minimum Implementation

```python
# src/domain/services/user_service.py

from typing import Optional
from src.domain.models.user import User
from src.domain.repositories import IUserRepository
from src.domain.exceptions import UserAlreadyExistsError


class UserService:
    def __init__(self, repo: IUserRepository):
        self.repo = repo

    async def create(self, email: str, password: str) -> User:
        """Create new user."""
        # Verify that email does not exist
        existing = await self.repo.get_user_by_email(email)
        if existing:
            raise UserAlreadyExistsError(f"User with {email} already exists")

        # Create user (minimum necessary)
        new_user = User(id=1, email=email, is_active=True)
        return await self.repo.save(new_user)
```

**Status:** Test PASSES ✅

#### 🔵 REFACTOR: Real Implementation

```python
# src/domain/services/user_service.py

import logging
from typing import Optional
from datetime import datetime
from src.domain.models.user import User
from src.domain.repositories import IUserRepository
from src.domain.exceptions import UserAlreadyExistsError
from src.core.security import hash_password

logger = logging.getLogger(__name__)


class UserService:
    def __init__(self, repo: IUserRepository):
        self.repo = repo

    async def create(self, email: str, password: str) -> User:
        """
        Create new user with hashed password.

        Args:
            email: User email (unique)
            password: Plain text password (will be hashed)

        Returns:
            User: Created user with assigned ID

        Raises:
            UserAlreadyExistsError: If email already exists
            ValueError: If email/password not valid
        """
        # Validate email format
        if not self._is_valid_email(email):
            raise ValueError(f"Invalid email format: {email}")

        # Validate password
        if not self._is_valid_password(password):
            raise ValueError("Password must be >= 12 chars with upper/number/symbol")

        # Verify that email does not exist
        existing = await self.repo.get_user_by_email(email)
        if existing:
            logger.warning(f"Attempt to create user with existing email: {email}")
            raise UserAlreadyExistsError(f"User with {email} already exists")

        # Hash password
        hashed_password = hash_password(password)

        # Create user
        new_user = User(
            email=email,
            hashed_password=hashed_password,
            is_active=True,
            created_at=datetime.utcnow(),
        )

        # Persist
        saved_user = await self.repo.save(new_user)
        logger.info(f"User created: {saved_user.id}")

        return saved_user

    @staticmethod
    def _is_valid_email(email: str) -> bool:
        """Validate basic email format."""
        import re
        pattern = r'^[\w\.-]+@[\w\.-]+\.\w+$'
        return re.match(pattern, email) is not None

    @staticmethod
    def _is_valid_password(password: str) -> bool:
        """Validate password requirements."""
        return (
            len(password) >= 12 and
            any(c.isupper() for c in password) and
            any(c.isdigit() for c in password) and
            any(c in "!@#$%^&*" for c in password)
        )
```

**Status:** Test KEEPS PASSING ✅ (behavior unchanged, only internals improved)

---

### Example 2: Error Handling (Flutter)

#### 🔴 RED: Test for Error Handling

```dart
// test/unit/domain/repositories/document_repository_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:riverpod/riverpod.dart';

void main() {
  group('DocumentRepository', () {
    test('getDocuments throws exception when network fails', () async {
      // 1️⃣ ARRANGE
      final mockDatasource = MockRemoteDatasource();
      when(mockDatasource.fetchDocuments()).thenThrow(
        SocketException('Network error'),
      );

      final repository = DocumentRepository(mockDatasource);

      // 2️⃣ ACT & 3️⃣ ASSERT
      expect(
        () => repository.getDocuments(),
        throwsA(isA<SocketException>()),
      );
    });

    test('getDocuments returns cached data on network error', () async {
      // 1️⃣ ARRANGE
      final mockDatasource = MockRemoteDatasource();
      final mockCache = MockLocalCache();

      when(mockDatasource.fetchDocuments()).thenThrow(
        SocketException('Network error'),
      );

      final cachedDocs = [
        Document(id: 1, title: 'Cached Doc'),
      ];
      when(mockCache.getDocuments()).thenAnswer((_) async => cachedDocs);

      final repository = DocumentRepository(
        remoteDatasource: mockDatasource,
        cache: mockCache,
      );

      // 2️⃣ ACT
      final result = await repository.getDocuments();

      // 3️⃣ ASSERT
      expect(result, cachedDocs);
      mockCache.getDocuments.verify().called(1);
    });
  });
}
```

**Status:** Test FAILS ❌

#### 🟢 GREEN: Minimum Implementation

```dart
// lib/domain/repositories/document_repository.dart

class DocumentRepository {
  final RemoteDatasource _remoteDatasource;
  final LocalCache _cache;

  DocumentRepository({
    required RemoteDatasource remoteDatasource,
    required LocalCache cache,
  })  : _remoteDatasource = remoteDatasource,
        _cache = cache;

  Future<List<Document>> getDocuments() async {
    try {
      return await _remoteDatasource.fetchDocuments();
    } on SocketException {
      // If network fails, return cache
      return await _cache.getDocuments();
    }
  }
}
```

**Status:** Test PASSES ✅

#### 🔵 REFACTOR: Logging and Better Handling

```dart
// lib/domain/repositories/document_repository.dart

import 'dart:developer' as developer;

class DocumentRepository {
  final RemoteDatasource _remoteDatasource;
  final LocalCache _cache;
  final Logger _logger;

  DocumentRepository({
    required RemoteDatasource remoteDatasource,
    required LocalCache cache,
    Logger? logger,
  })  : _remoteDatasource = remoteDatasource,
        _cache = cache,
        _logger = logger ?? Logger();

  Future<List<Document>> getDocuments() async {
    try {
      _logger.info('Fetching documents from remote...');
      final documents = await _remoteDatasource.fetchDocuments();
      _logger.info('Successfully fetched ${documents.length} documents');
      return documents;
    } on SocketException catch (e) {
      _logger.warning('Network error, falling back to cache: $e');
      try {
        final cached = await _cache.getDocuments();
        _logger.info('Returning ${cached.length} cached documents');
        return cached;
      } catch (cacheError) {
        _logger.error('Cache also failed: $cacheError');
        rethrow;
      }
    } on Exception catch (e) {
      _logger.error('Unexpected error: $e');
      rethrow;
    }
  }
}
```

**Status:** Test KEEPS PASSING ✅

---

## Testing Pyramid

SoftArchitect's coverage strategy:

```
           /\
          /  \
         / 10%\         E2E / Widget Tests
        /  E2E \       (Verify complete flow)
       /────────\
      /          \
     /    20%     \    Integration Tests
    /  Integration \  (Multiple components)
   /────────────────\
  /                  \
 /        70%         \  Unit Tests
/    Unit Tests        \ (Pure logic)
/──────────────────────\

Total = 100% coverage
```

### Requirements

| Level | Tool | Coverage | Examples |
|:---|:---|:---:|:---|
| **Unit** | pytest / flutter_test | ≥ 70% | Validators, formatters, algorithms |
| **Integration** | pytest + sqlalchemy / flutter test | ≥ 20% | Repository + DB, Riverpod + API mock |
| **E2E** | integration_test / Selenium | ≥ 10% | Login flow, document CRUD end-to-end |

---

## Best Practices by Language

### Python (pytest)

#### ✅ GOOD: Test completo

```python
# tests/unit/domain/validators/test_email_validator.py

import pytest
from src.domain.validators.email_validator import EmailValidator

class TestEmailValidator:
    """Logical group of tests."""

    @pytest.fixture
    def validator(self):
        """Shared setup."""
        return EmailValidator()

    def test_valid_email(self, validator):
        """Valid email should pass."""
        assert validator.validate("user@example.com") is True

    def test_invalid_format(self, validator):
        """Email without @ should fail."""
        assert validator.validate("invalid_email") is False

    @pytest.mark.parametrize("email", [
        "test@domain.com",
        "user.name+tag@example.co.uk",
        "test_email@subdomain.example.com",
    ])
    def test_multiple_valid_emails(self, validator, email):
        """Test multiple cases with parametrization."""
        assert validator.validate(email) is True

    @pytest.mark.asyncio
    async def test_async_validation(self, validator):
        """Test async."""
        result = await validator.async_validate("test@example.com")
        assert result is True
```

#### ❌ BAD: Anti-patterns

```python
# ❌ DO NOT DO THIS

def test_everything():
    """Test that tests everything (unreadable)."""
    validator = EmailValidator()
    assert validator.validate("test@example.com")
    assert validator.validate("another@example.com")
    assert validator.validate("third@example.com")

def test_no_name():
    """Non-descriptive name."""
    assert something()

def test_with_print():
    """Logging with print (do not use)."""
    print("Debug info")
    assert True

def test_logic_in_assertion():
    """Complex logic in assert."""
    assert all([validator.validate(e) for e in emails]) and len(emails) > 0
```

### Flutter (flutter_test)

#### ✅ GOOD: Widget Test

```dart
// test/features/documents/presentation/screens/document_list_screen_test.dart

void main() {
  group('DocumentListScreen', () {
    testWidgets('displays documents from Riverpod provider', (tester) async {
      // 1️⃣ ARRANGE
      const testDocuments = [
        Document(id: 1, title: 'Doc 1'),
        Document(id: 2, title: 'Doc 2'),
      ];

      final container = ProviderContainer(
        overrides: [
          documentsProvider.overrideWith((_) async => testDocuments),
        ],
      );

      // 2️⃣ ACT
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: DocumentListScreen(),
          ),
        ),
      );

      // 3️⃣ ASSERT
      expect(find.byType(ListTile), findsWidgets);
      expect(find.text('Doc 1'), findsOneWidget);
      expect(find.text('Doc 2'), findsOneWidget);
    });

    testWidgets('shows error message on load failure', (tester) async {
      // Similar to above but with failing provider
      final container = ProviderContainer(
        overrides: [
          documentsProvider.overrideWith((_) async {
            throw Exception('Network error');
          }),
        ],
      );

      await tester.pumpWidget(...);
      await tester.pumpAndSettle();  // Wait for async

      expect(find.text('Error loading documents'), findsOneWidget);
    });
  });
}
```

---

## Coverage Metrics

### Measure Coverage

```bash
# Python
pytest --cov=src --cov-report=html tests/
# Open htmlcov/index.html

# Flutter
flutter test --coverage
# Generates coverage/lcov.info
```

### Mandatory Minimums

```
- Backend (Python): ≥ 80% coverage
- Frontend (Flutter): ≥ 75% coverage
- Critical (auth, payment): ≥ 95% coverage
```

### Report in CI/CD

```yaml
# .github/workflows/ci.yml

- name: Upload coverage to Codecov
  uses: codecov/codecov-action@v3
  with:
    files: ./coverage.xml
    fail_ci_if_error: true
    minimum_coverage: 80
```

---

## Anti-Patterns & Common Mistakes

### ❌ Test that Doesn't Test

```python
# ❌ BAD: Empty test
def test_something():
    pass  # No assertions!

# ❌ BAD: Test only with setup, no verifications
def test_user_creation():
    user = User(email="test@test.com")
    # ... nothing more

# ✅ GOOD
def test_user_creation():
    user = User(email="test@test.com")
    assert user.email == "test@test.com"  # Verify
```

### ❌ Non-Isolated Tests

```python
# ❌ BAD: Dependency between tests
test_counter = 0

def test_first():
    global test_counter
    test_counter += 1
    assert test_counter == 1

def test_second():
    global test_counter
    test_counter += 1
    assert test_counter == 2  # Fails if test_first didn't run first

# ✅ GOOD: Each test independent
@pytest.fixture
def counter():
    return 0

def test_first(counter):
    assert counter == 0  # Always
```

### ❌ Unnecessary Mocks

```python
# ❌ BAD: Mocking simple real things
def test_add():
    mock_math = MagicMock()
    mock_math.add = MagicMock(return_value=5)
    assert mock_math.add(2, 3) == 5  # Testing the mock, not the function

# ✅ GOOD: Direct test for simple logic
def test_add():
    result = add(2, 3)
    assert result == 5
```

### ❌ Generic Assertions

```python
# ❌ BAD: Unhelpful error message
assert user is not None

# ✅ GOOD: Descriptive message
assert user is not None, f"User should exist for email {email}"
```

---

## Pre-Development Checklist

Before starting to code:

```bash
# ✅ 1. Understand the requirement (User Story)
[ ] Read the complete HU description
[ ] Understand acceptance criteria
[ ] Identified edge cases

# ✅ 2. Write tests FIRST
[ ] Created test file (test_*.py / *_test.dart)
[ ] Wrote at least 3 tests (happy path + 2 errors)
[ ] Tests fail ❌

# ✅ 3. Implement minimum code
[ ] Tests pass ✅
[ ] Code is ugly/hardcoded (OK in GREEN)

# ✅ 4. Refactor
[ ] Improved code (cleanup, logging, types)
[ ] Tests KEEP passing ✅
[ ] Passed linter (ruff, flutter analyze)

# ✅ 5. Final verification
[ ] Coverage ≥ 80%
[ ] No print() or debugPrint()
[ ] Commit with Conventional message
```

---

## Conclusion

**TDD is the quality guarantee:**

1. ✅ **Tests first:** Define expected behavior
2. ✅ **High coverage:** Bugs detected early
3. ✅ **Safe refactor:** Tests are your safety net
4. ✅ **Living documentation:** Tests are the specification

**Dogfooding Validation:** SoftArchitect develops each feature with TDD. If the test fails, the feature doesn't exist.
