# 🧪 Testing Strategy: SoftArchitect AI

> **Versión:** 1.0
> **Fecha:** 30/01/2026
> **Estado:** ✅ Definido
> **Objetivo:** >80% coverage, zero critical issues

---

## 📖 Tabla de Contenidos

1. [Estrategia General](#estrategia-general)
2. [Tipos de Tests](#tipos-de-tests)
3. [Tools & Infrastructure](#tools--infrastructure)
4. [Cobertura Requerida](#cobertura-requerida)
5. [Pipeline de CI/CD](#pipeline-de-cicd)

---

## Estrategia General

```
Testing Pyramid:

         ▲
        /△\         E2E Tests (Few, high value)
       /  △ \       Scenarios, full flow
      /──────\
     /   △   \      Integration Tests (More, specific)
    / △ △ △ △ \     API, DB, Component interactions
   /──────────\
  /  △△△△△△  \     Unit Tests (Many, fast)
 /△△△△△△△△△△△\    Business logic, utilities
/──────────────\

Filosofía: Test pyramid, no ice cream cone
  ✅ Unit tests: 70% (rápido, específico)
  ✅ Integration: 20% (APIs, layers)
  ✅ E2E: 10% (críticos paths)
```

---

## Tipos de Tests

### 1. Unit Tests

**Scope:** Función individual o clase

**Tools:**
- Python: `pytest` + `pytest-cov`
- Dart: `flutter_test`

**Ejemplos:**

```python
# Backend: test_retriever.py
def test_chromadb_retrieve_top_k():
    """ChromaDB retrieves top-k vectors correctly."""
    db = ChromaDB()
    db.add("React architecture patterns", embedding)

    results = db.search("React vs Angular", top_k=5)

    assert len(results) == 5
    assert results[0]['score'] > 0.8

# Frontend: test_decision_matrix_widget.dart
void main() {
  testWidgets('DecisionMatrixCard displays criteria', (WidgetTester tester) async {
    final matrix = DecisionMatrix(
      criteria: ['Performance', 'Learning', 'Ecosystem'],
      options: {'React': [9, 7, 10], 'Angular': [7, 5, 8]},
    );

    await tester.pumpWidget(MaterialApp(home: matrix));

    expect(find.text('Performance'), findsOneWidget);
    expect(find.text('React'), findsOneWidget);
  });
}
```

**Coverage Target:** 80-90% per module

---

### 2. Integration Tests

**Scope:** Múltiples componentes interactuando

**Tools:**
- FastAPI: `httpx` async client
- Flutter: `integration_test`

**Ejemplos:**

```python
# Backend: test_rag_pipeline.py
@pytest.mark.asyncio
async def test_rag_query_end_to_end():
    """Query → Retrieval → Generation → Response"""

    client = AsyncClient(app=app)

    # Setup: add docs to ChromaDB
    setup_test_documents()

    # Execute: full RAG pipeline
    response = await client.post(
        "/query",
        json={"question": "React vs Angular?"}
    )

    # Assert: response format and quality
    assert response.status_code == 200
    assert "decision_matrix" in response.json()
    assert len(response.json()["decision_matrix"]) >= 3
    assert response.elapsed.total_seconds() < 3.0  # Performance SLA

# Frontend: integration_test/app_test.dart
void main() {
  testWidgets('Full user flow: question → response', (driver) async {
    await driver.waitUntilNoTransientCallbacks();

    // 1. Type question
    await driver.enterText('React vs Angular');

    // 2. Submit
    await driver.tap(find.byType(RaisedButton));

    // 3. Wait for response
    await driver.waitFor(find.byType(DecisionMatrix));

    // 4. Verify display
    expect(find.text('React'), findsOneWidget);
  });
}
```

**Coverage Target:** 10-15 critical flows

---

### 3. End-to-End Tests

**Scope:** Aplicación completa (UI → Backend → DB)

**Tools:** Selenium / Testcafe (para web, si aplica futuro)

**Ejemplos:**

```dart
// e2e_test: complete_user_journey.dart
void main() {
  group('E2E: User decides between React and Angular', () {
    setUpAll(() async {
      // Start app fresh
      app = runApp(SoftArchitectApp());
    });

    test('User gets decision matrix in <2 seconds', () async {
      // 1. Open app
      expect(find.text('Ask SoftArchitect'), findsOneWidget);

      // 2. Ask question
      await tester.enterText(find.byType(TextField), 'React vs Angular');
      await tester.tap(find.byType(SubmitButton));

      // 3. Measure response time
      final stopwatch = Stopwatch()..start();
      await tester.pumpAndSettle();
      stopwatch.stop();

      // 4. Verify response
      expect(find.byType(DecisionMatrix), findsOneWidget);
      expect(stopwatch.elapsedMilliseconds, lessThan(2000));
    });
  });
}
```

**Coverage Target:** 3-5 happy paths

---

## Tools & Infrastructure

### Backend (Python)

```yaml
Testing Stack:
  pytest:              ^7.0       # Test framework
  pytest-asyncio:      ^0.20      # Async test support
  pytest-cov:          ^4.0       # Coverage reporting
  httpx:               ^0.24      # Async HTTP client
  faker:               ^18.0      # Fake data generation
  responses:           ^0.23      # HTTP mocking

Commands:
  # Unit tests
  pytest tests/unit --cov=src --cov-report=term-missing

  # Integration tests
  pytest tests/integration -v -s

  # All tests with coverage
  pytest tests/ --cov=src --cov-report=html

  # Coverage report
  open htmlcov/index.html
```

### Frontend (Dart/Flutter)

```yaml
Testing Stack:
  flutter_test:        # Built-in (via Flutter SDK)
  mockito:             ^5.0       # Mocking
  integration_test:    # Built-in
  test:                ^1.21      # Unit test runner

Commands:
  # Unit tests
  flutter test

  # Coverage
  flutter test --coverage
  lcov --list coverage/lcov.info

  # Integration tests
  flutter drive --target=integration_test/app_test.dart

  # Full coverage report
  genhtml coverage/lcov.info -o coverage/html
  open coverage/html/index.html
```

---

## Cobertura Requerida

### Coverage Targets

```
Backend (Python):
  ├─ Core domain logic:     ≥90% coverage
  ├─ API endpoints:         ≥85% coverage
  ├─ Services (RAG):        ≥80% coverage
  ├─ Infrastructure:        ≥70% coverage (less critical)
  └─ TOTAL:                 ≥80% coverage

Frontend (Dart):
  ├─ Business logic:        ≥90% coverage
  ├─ Widgets:               ≥75% coverage
  ├─ Providers (state):     ≥85% coverage
  ├─ Utils:                 ≥80% coverage
  └─ TOTAL:                 ≥80% coverage

Overall Project: ≥80% combined
```

### Coverage Reporting

```bash
# Generate HTML report
pytest tests/ --cov=src --cov-report=html

# Check coverage threshold in CI
pytest tests/ --cov=src --cov-fail-under=80

# View detailed report
cd htmlcov && python -m http.server 8000
```

---

## Pipeline de CI/CD

### GitHub Actions Workflow

```yaml
name: Tests & Quality

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  backend-tests:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v3

      - name: Set up Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.12'

      - name: Install dependencies
        run: |
          cd src/server
          pip install -r requirements.txt

      - name: Lint with flake8
        run: flake8 src/server --count --select=E9,F63,F7,F82 --show-source --statistics

      - name: Run tests with coverage
        run: |
          cd src/server
          pytest tests/ --cov=. --cov-fail-under=80 --cov-report=term

      - name: Upload coverage to Codecov
        uses: codecov/codecov-action@v3
        with:
          files: ./src/server/coverage.xml

  frontend-tests:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v3

      - name: Set up Flutter
        uses: subosito/flutter-action@v2

      - name: Get dependencies
        run: |
          cd src/client
          flutter pub get

      - name: Run tests
        run: |
          cd src/client
          flutter test --coverage

      - name: Check coverage
        run: |
          cd src/client
          lcov --summary coverage/lcov.info

      - name: Upload coverage
        uses: codecov/codecov-action@v3
        with:
          files: ./src/client/coverage/lcov.info

  security:
    runs-on: self-hosted
    steps:
      - uses: actions/checkout@v3

      - name: Run bandit (Python security)
        run: bandit -r src/server -f json -o bandit-report.json

      - name: Check dependencies (pip-audit)
        run: |
          cd src/server
          pip-audit -o json > pip-audit-report.json

      - name: Publish security results
        if: always()
        uses: actions/upload-artifact@v3
        with:
          name: security-reports
          path: |
            bandit-report.json
            pip-audit-report.json
```

### Coverage Thresholds (CI/CD Gate)

```
✅ PASS CI if:
  - Python backend: ≥80% coverage
  - Dart frontend: ≥80% coverage
  - Zero critical security issues
  - All tests green
  - Linting 0 errors

❌ FAIL CI if:
  - Coverage < 80%
  - Security issues found
  - Tests fail
  - Linting errors
```

---

## TDD Workflow (Obligatorio para Features Críticas)

```
RED → GREEN → REFACTOR

Paso 1: RED (Escribe test que falla)
  └─ Test describe comportamiento deseado
  └─ Código no existe aún, test falla

  Example (Python):
    def test_retriever_returns_top_k():
        results = retriever.search("query", k=5)
        assert len(results) == 5

Paso 2: GREEN (Implementa mínimo código)
  └─ Escribes código que PASA el test
  └─ No importa elegancia, solo pasar test

  Example:
    class Retriever:
        def search(self, query, k):
            return [{"id": 1}] * k

Paso 3: REFACTOR (Mejora calidad)
  └─ Code review, optimiza
  └─ Tests siguen pasando

  Example:
    class Retriever:
        def search(self, query, k):
            embeddings = self.embed(query)
            return self.chromadb.search(embeddings, top_k=k)
```

---

## Testing Checklist (Pre-PR)

```
Before submitting PR:

Backend (Python):
  [ ] New features have unit tests
  [ ] Unit tests pass locally
  [ ] Coverage ≥80%
  [ ] No linting errors (flake8)
  [ ] No security issues (bandit)
  [ ] Docstrings updated
  [ ] Type hints added (Pydantic)

Frontend (Dart):
  [ ] New widgets have widget tests
  [ ] Providers have unit tests
  [ ] Coverage ≥80%
  [ ] No lint warnings (flutter analyze)
  [ ] Platform-specific tested
  [ ] Documentation comments added

Integration:
  [ ] API integration tested
  [ ] E2E flow verified
  [ ] Performance acceptable (<2s response)
  [ ] Error cases handled

Documentation:
  [ ] CHANGELOG.md updated
  [ ] README updated (if needed)
  [ ] API docs generated

Git:
  [ ] Commit message descriptive
  [ ] Branch is feature/xxx
  [ ] PRBase is develop
```

---

**Testing Strategy** asegura: confiabilidad, mantenibilidad, y rapidez de deployment. Todos los tests deben ser rápidos (<5 min total). 🧪
