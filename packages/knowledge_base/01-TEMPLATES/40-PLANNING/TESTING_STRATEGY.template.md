# 🧪 Testing Strategy & QA Plan

Quality strategy for **{{PROJECT_NAME}}**.
**Minimum Target Coverage:** {{COVERAGE_TARGET}}%

## 1. Test Pyramid

### Level 1: Unit Testing (Base)
* **Tool:** {{UNIT_TEST_TOOL}} (e.g., Pytest / Flutter Test).
* **Scope:** Pure functions, utilities, domain models.
* **Target:** {{UNIT_TEST_COUNT}} tests.
* **Rule:** Run on every local commit.

### Level 2: Integration Testing (Middle)
* **Tool:** {{INTEGRATION_TEST_TOOL}}.
* **Scope:** API endpoints with real database (in Docker), Component-Store communication.
* **Target:** {{INTEGRATION_TEST_COUNT}} tests.
* **Rule:** Run on PRs.

### Level 3: E2E Testing (Top)
* **Tool:** {{E2E_TEST_TOOL}} (e.g., Playwright / Patrol).
* **Scope:** Critical user flows (Login -> Purchase).
* **Target:** {{E2E_TEST_COUNT}} tests.
* **Rule:** Run in Staging before Deploy.

## 2. Test Data (Fixtures)
* Use `Faker` or `FactoryBoy` to generate deterministic data.
* **NEVER** use real production data in test environments.

## 3. Performance Testing
* **Tool:** {{PERF_TEST_TOOL}} (e.g., k6 / Locust).
* **Objectives:**
    * API Response Time: < {{MAX_RESPONSE_TIME}}ms (p95).
    * Throughput: {{MIN_THROUGHPUT}} req/s.

## 4. Security Testing
* **SAST (Static):** {{SAST_TOOL}} (e.g., SonarQube / Bandit).
* **DAST (Dynamic):** {{DAST_TOOL}} (e.g., ZAP / Burp).
* **Dependency Check:** {{DEPENDENCY_CHECKER}} (pip-audit / npm audit).
