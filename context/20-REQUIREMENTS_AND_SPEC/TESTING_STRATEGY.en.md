# 🧪 Testing Strategy and QA

> **Philosophy:** "If it's not tested, it's broken".
> **Methodology:** TDD (Test Driven Development) strict for critical backend logic.

---

## 1. Testing Levels (The Pyramid)

### Level 1: Unit Tests (70%)
* **Objective:** Verify isolated business logic.
* **Backend (Python/Pytest):**
    * Markdown parsers.
    * LangChain utility functions (without calling the real LLM, using Mocks).
* **Frontend (Flutter Test):**
    * JSON parsers.
    * Form validators.

### Level 2: Integration Tests (20%)
* **Objective:** Verify components talk to each other.
* **Backend:**
    * Test that the `/chat` endpoint receives a JSON and returns a Stream (using FastAPI's `TestClient`).
    * Verify ChromaDB connection (using in-memory DB or ephemeral container).
* **Frontend:**
    * Verify repository calls datasource correctly.

### Level 3: Widget/UI Tests (10%)
* **Objective:** Verify the interface doesn't explode.
* **Flutter:**
    * Verify that pressing "Send" displays the message in the list.
    * Verify that the model selector changes the visual state.

---

## 2. TDD Rules (The Cycle)

For any critical logic (especially in `src/server`), follow the cycle:

1.  🔴 **RED:** Write a failing test (e.g., `test_should_sanitize_api_keys`).
2.  🟢 **GREEN:** Write the minimum code to pass.
3.  🔵 **REFACTOR:** Clean and optimize without breaking the test.

---

## 3. Tools and Commands

| Layer | Type | Tool | Command |
| :--- | :--- | :--- | :--- |
| **Backend** | Unit/Int | `pytest` | `docker compose exec api-server pytest` |
| **Backend** | Async | `pytest-asyncio` | (Included in suite above) |
| **Frontend** | Unit/Widget | `flutter_test` | `cd src/client && flutter test` |
| **E2E** | Full | `flutter_driver` | `cd src/client && flutter drive --target=test_driver/app.dart` |

---

## 4. Test Data and Mocks

* **Backend:** Use `pytest-mock` for LLM responses. Simulate "Hello world" responses instantly to test UI painting.
* **Frontend:** Use `mockito` for repositories. Mock API responses to test error states.

---

## 5. CI/CD Integration

* **GitHub Actions:** Run tests on every PR to `develop`.
* **Coverage:** Enforce >80% coverage with `coverage.py` (Python) and `flutter_test --coverage` (Dart).
* **Mutation Testing:** Use `mutmut` for Python to ensure tests are robust.