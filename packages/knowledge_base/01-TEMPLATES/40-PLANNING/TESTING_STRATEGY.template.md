# 🧪 Testing Strategy

<!-- ════════════════════════════════════════════════════════════════════════════════
📘 TEMPLATE GUIDE: How to Fill Out This Document
════════════════════════════════════════════════════════════════════════════════

PURPOSE:
This document defines the testing strategy, types of tests (Unit, Integration, E2E), coverage targets, and execution methods. It ensures code quality and prevents regressions through an automated validation framework.

WHEN TO CREATE:
- **Generation Order:** 20/24 (Phase 5 - PLANNING)
- **Phase:** 5 - PLANNING
- **Prerequisites:** 20-REQUIREMENTS/REQUIREMENTS_MASTER.md (for acceptance criteria) and 30-ARCHITECTURE/TECH_STACK_DECISION.md MUST be complete.

BEST PRACTICES & AI INSTRUCTIONS:
✅ **NO HALLUCINATIONS:** The testing tools and code examples MUST match the Tech Stack. If using Python, use pytest; if using Flutter, use flutter_test.
✅ **REALISTIC TARGETS:** Aim for a total coverage of ≥80%. While 100% in domain logic is ideal, be realistic about UI coverage.
✅ **USE EXAMPLES AS GUIDES:** Read the hidden HTML comments () for context, but do not copy them verbatim.
✅ **REPLACE VARIABLES:** Swap all {{PLACEHOLDERS}} with actual project data.
✅ **SELF-DESTRUCT:** You MUST remove this entire TEMPLATE GUIDE comment block before outputting the final Markdown.

⚠️ **CRITICAL ROUTING:**
   This file MUST be saved in the 40-PLANNING directory.
   Filename MUST be: TESTING_STRATEGY.md
   Correct path: /context/40-PLANNING/TESTING_STRATEGY.md
════════════════════════════════════════════════════════════════════════════════ -->

> **Project:** {{PROJECT_NAME}}
> **Coverage Target:** {{COVERAGE_TARGET}}  <!-- e.g., "≥80%" -->
> **Test Framework (Backend):** {{BACKEND_TEST_FRAMEWORK}}  <!-- e.g., pytest -->
> **Test Framework (Frontend):** {{FRONTEND_TEST_FRAMEWORK}}  <!-- e.g., flutter_test -->
> **Last Updated:** {{DATE}}

---

## 📖 Table of Contents

- [Testing Pyramid](#testing-pyramid)
- [Test Types](#test-types)
- [Coverage Targets](#coverage-targets)
- [Test Execution](#test-execution)

---

## 🏔️ Testing Pyramid

```
         /\
        /E2E\         ← Few (slow, expensive)
       /──────\
      /  Int.  \      ← Some (moderate speed)
     /──────────\
    /   Unit     \    ← Many (fast, cheap)
   /──────────────\
```

**Distribution:**

| Type | Percentage | Count | Example |
|------|------------|-------|---------|
| **Unit** | 70% | {{UNIT_COUNT}} | Test `calculateTotal()` function |
| **Integration** | 20% | {{INT_COUNT}} | Test API endpoint + database |
| **E2E** | 10% | {{E2E_COUNT}} | Test full user workflow (UI → API → DB) |

<!-- EXAMPLE:

| Type | Percentage | Count | Example |
|------|------------|-------|---------|
| **Unit** | 70% | 300 tests | `test_user_validation()` |
| **Integration** | 20% | 80 tests | `test_create_project_api()` |
| **E2E** | 10% | 40 tests | `test_user_creates_project_full_flow()` |
-->

---

## 🧪 Test Types

### 1. Unit Tests

**Purpose:** Test individual functions/classes in isolation

**Scope:**

- Domain logic (entities, use cases)
- Utility functions
- Validators

**Tools:**

- **Backend:** pytest
- **Frontend:** flutter_test

**Example (Backend):**

```python
# test_user_validator.py
from core.validators import UserValidator

def test_email_validation_valid():
    """Test valid email passes validation."""
    validator = UserValidator()
    result = validator.validate_email("john@example.com")
    assert result.is_valid is True

def test_email_validation_invalid():
    """Test invalid email fails validation."""
    validator = UserValidator()
    result = validator.validate_email("not-an-email")
    assert result.is_valid is False
    assert "Invalid email format" in result.errors
```

**Example (Frontend):**

```dart
// test/domain/entities/user_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:soft_architect_ai/domain/entities/user.dart';

void main() {
  group('User Entity', () {
    test('should create user with valid data', () {
      final user = User(
        id: '123',
        email: 'john@example.com',
        name: 'John Doe',
      );

      expect(user.id, '123');
      expect(user.email, 'john@example.com');
    });

    test('should throw exception for invalid email', () {
      expect(
        () => User(id: '123', email: 'invalid', name: 'John'),
        throwsA(isA<ValidationException>()),
      );
    });
  });
}
```

---

### 2. Integration Tests

**Purpose:** Test interaction between components (API + DB, Service + Repository)

**Scope:**

- API endpoints
- Database queries
- Service layer

**Tools:**

- **Backend:** pytest + HTTPX (async)
- **Frontend:** integration_test package

**Example (Backend API Test):**

```python
# test_project_api.py
import pytest
from httpx import AsyncClient
from main import app

@pytest.mark.asyncio
async def test_create_project():
    """Test POST /api/projects creates project in database."""
    async with AsyncClient(app=app, base_url="http://test") as client:
        response = await client.post(
            "/api/projects",
            json={"name": "Test Project", "tech_stack": "Flutter"},
            headers={"Authorization": "Bearer fake-token"}
        )

    assert response.status_code == 201
    data = response.json()
    assert data["name"] == "Test Project"
    assert "id" in data

    # Verify database was updated
    project = await db.get_project(data["id"])
    assert project is not None
```

**Example (Frontend Integration Test):**

```dart
// test/integration/project_creation_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Create project flow', (tester) async {
    await tester.pumpWidget(MyApp());

    // Navigate to new project page
    await tester.tap(find.text('New Project'));
    await tester.pumpAndSettle();

    // Fill form
    await tester.enterText(find.byKey(Key('projectNameInput')), 'My App');
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();

    // Verify project created
    expect(find.text('My App'), findsOneWidget);
  });
}
```

---

### 3. End-to-End (E2E) Tests

**Purpose:** Test full user workflows (UI → API → Database)

**Scope:**

- Critical user journeys
- Happy paths only (not edge cases)

**Tools:**

- **Frontend:** integration_test + flutter_driver

**Example:**

```dart
// test/e2e/user_signup_flow_test.dart
testWidgets('User can sign up and create project', (tester) async {
  await tester.pumpWidget(MyApp());

  // 1. Click Sign Up
  await tester.tap(find.text('Sign Up'));
  await tester.pumpAndSettle();

  // 2. Fill signup form
  await tester.enterText(find.byKey(Key('emailInput')), 'test@example.com');
  await tester.enterText(find.byKey(Key('passwordInput')), 'SecurePass123!');
  await tester.tap(find.text('Create Account'));
  await tester.pumpAndSettle(Duration(seconds: 5));  // Wait for API

  // 3. Create project
  await tester.tap(find.text('New Project'));
  await tester.pumpAndSettle();
  await tester.enterText(find.byKey(Key('projectNameInput')), 'My First Project');
  await tester.tap(find.text('Generate'));
  await tester.pumpAndSettle(Duration(seconds: 60));  // Wait for doc generation

  // 4. Verify success
  expect(find.text('24 documents created'), findsOneWidget);
});
```

---

## 📊 Coverage Targets

| Layer | Target | Current | Status |
|-------|--------|---------|--------|
| **Domain (Business Logic)** | 100% | {{DOMAIN_COVERAGE}} | {{DOMAIN_STATUS}} |
| **Service Layer** | ≥90% | {{SERVICE_COVERAGE}} | {{SERVICE_STATUS}} |
| **API Endpoints** | ≥85% | {{API_COVERAGE}} | {{API_STATUS}} |
| **UI Widgets** | ≥80% | {{UI_COVERAGE}} | {{UI_STATUS}} |
| **Overall** | ≥80% | {{OVERALL_COVERAGE}} | {{OVERALL_STATUS}} |

<!-- EXAMPLE:

| Layer | Target | Current | Status |
|-------|--------|---------|--------|
| **Domain** | 100% | 98% | ✅ Excellent |
| **Service Layer** | ≥90% | 91% | ✅ Good |
| **API** | ≥85% | 87% | ✅ Good |
| **UI** | ≥80% | 76% | ⚠️ Needs work |
| **Overall** | ≥80% | 83% | ✅ Good |
-->

---

## 🏃 Test Execution

### Local Development

**Run All Tests:**

```bash
# Backend
cd tests && pytest server/ --cov=src/server --cov-report=html

# Frontend
cd tests && flutter test client/ --coverage
```

**Run Specific Test:**

```bash
# Backend
pytest tests/server/test_user_validator.py::test_email_validation_valid

# Frontend
flutter test tests/client/domain/user_test.dart
```

---

### CI/CD Pipeline

**Trigger:** Every push, every PR

**Workflow:**

```yaml
# .github/workflows/test.yml
name: Tests
on: [push, pull_request]

jobs:
  test-backend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Run tests
        run: pytest tests/server/ --cov=src/server --cov-fail-under=80
      - name: Upload coverage
        uses: codecov/codecov-action@v3

  test-frontend:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Install Flutter
        uses: subosito/flutter-action@v2
      - name: Run tests
        run: flutter test --coverage
      - name: Check coverage
        run: |
          lcov --summary coverage/lcov.info
          # Fail if coverage < 80%
```

**Quality Gate:** All tests must pass + coverage ≥80% before merge

---

## 🚫 What NOT to Test

- **Third-party libraries** (assume they work)
- **Trivial getters/setters** (e.g., `user.name`)
- **UI layout pixel-perfect** (use visual regression tools instead)

---

## 🐛 Bug Reproduction Test (TDD)

**When a bug is found:**

1. Write a failing test that reproduces the bug
2. Fix the code
3. Verify test passes
4. Commit both test + fix

**Example:**

```python
# Bug report: "User can create project with empty name"

# Step 1: Write failing test
def test_create_project_empty_name_fails():
    """Test project creation fails with empty name."""
    with pytest.raises(ValidationException):
        create_project(name="", tech_stack="Flutter")

# Step 2: Fix code (add validation in create_project())

# Step 3: Test passes ✅
```

---

## 📈 Test Metrics

| Metric | Target | Current | Trend |
|--------|--------|---------|-------|
| **Test Count** | N/A | {{TEST_COUNT}} | {{TEST_TREND}} |
| **Execution Time** | <5 minutes | {{EXEC_TIME}} | {{EXEC_TREND}} |
| **Flaky Tests** | 0 | {{FLAKY_COUNT}} | {{FLAKY_TREND}} |

<!-- EXAMPLE:

| Metric | Target | Current | Trend |
|--------|--------|---------|-------|
| **Test Count** | N/A | 420 tests | ↗️ +15/week |
| **Execution Time** | <5 minutes | 3m 42s | ↘️ Improving |
| **Flaky Tests** | 0 | 2 | ⚠️ Need investigation |
-->

---

## 🔗 Related Documents

- [CI_CD_PIPELINE.md](CI_CD_PIPELINE.md) - Test automation in pipeline
- [REQUIREMENTS_MASTER.md](../20-REQUIREMENTS/REQUIREMENTS_MASTER.md) - Acceptance criteria
- [RULES.md](../00-ROOT/RULES.md) - Code quality standards
