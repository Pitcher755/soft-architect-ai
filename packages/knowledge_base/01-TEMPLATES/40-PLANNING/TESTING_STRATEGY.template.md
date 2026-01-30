# 🧪 Testing Strategy & QA Plan

Estrategia de calidad para **{{PROJECT_NAME}}**.
**Coverage Mínimo Objetivo:** {{COVERAGE_TARGET}}%

## 1. Pirámide de Tests

### Nivel 1: Unit Testing (Base)
* **Herramienta:** {{UNIT_TEST_TOOL}} (Ej: Pytest / Flutter Test).
* **Alcance:** Funciones puras, utilidades, modelos de dominio.
* **Target:** {{UNIT_TEST_COUNT}} tests.
* **Regla:** Se ejecutan en cada commit local.

### Nivel 2: Integration Testing (Medio)
* **Herramienta:** {{INTEGRATION_TEST_TOOL}}.
* **Alcance:** Endpoints API con base de datos real (en Docker), Comunicación Componente-Store.
* **Target:** {{INTEGRATION_TEST_COUNT}} tests.
* **Regla:** Se ejecutan en PRs.

### Nivel 3: E2E Testing (Punta)
* **Herramienta:** {{E2E_TEST_TOOL}} (Ej: Playwright / Patrol).
* **Alcance:** Flujos críticos de usuario (Login -> Compra).
* **Target:** {{E2E_TEST_COUNT}} tests.
* **Regla:** Se ejecutan en Staging antes de Deploy.

## 2. Datos de Prueba (Fixtures)
* Usar `Faker` o `FactoryBoy` para generar datos deterministas.
* **NUNCA** usar datos reales de producción en entornos de test.

## 3. Performance Testing
* **Herramienta:** {{PERF_TEST_TOOL}} (Ej: k6 / Locust).
* **Objetivos:**
    * API Response Time: < {{MAX_RESPONSE_TIME}}ms (p95).
    * Throughput: {{MIN_THROUGHPUT}} req/s.

## 4. Security Testing
* **SAST (Static):** {{SAST_TOOL}} (Ej: SonarQube / Bandit).
* **DAST (Dynamic):** {{DAST_TOOL}} (Ej: ZAP / Burp).
* **Dependency Check:** {{DEPENDENCY_CHECKER}} (pip-audit / npm audit).
