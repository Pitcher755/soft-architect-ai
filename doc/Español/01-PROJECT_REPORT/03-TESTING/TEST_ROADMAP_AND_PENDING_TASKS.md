# 📋 Prueba Suite Roadmap & Pendiente Tasks

> **Fecha:** 2025-01-31
> **Estado:** In Progress
> **Responsable:** ArchitectZero (Agente)

---

## 🎯 Current Estado

```
✅ COMPLETED (This Session)
├─ Fixed E2E test imports (DatabaseError → VectorStoreError)
├─ Fixed module paths (core.errors → core.exceptions)
├─ Validated 238 tests collect without errors
└─ 233/233 unit tests passing (94.4% coverage)

⏳ IN PROGRESS
├─ Documentation of E2E test requirements
└─ Creation of test verification scripts

❌ PENDING (Next Sprint)
├─ Implement API Endpoint E2E tests (HIGH PRIORITY)
├─ Setup CI/CD integration for selective test runs
└─ Load testing infrastructure
```

---

## 📌 Fase 1: Immediate Actions (This Week)

### Task 1.1: Validate E2E Pruebas Ejecutar Successfully

**Estado:** ⏳ NOT STARTED
**Effort:** 30 min
**Steps:**
```bash
# 1. Start Docker services
docker-compose -f infrastructure/docker-compose.yml up -d chromadb

# 2. Set environment variable
export CHROMA_HOST=localhost

# 3. Run E2E tests
cd src/server
pytest tests/integration/ -v

# 4. Verify all 5 tests PASS
```

**Success Criteria:**
- [ ] All 5 E2E pruebas ejecutar (not skipped)
- [ ] All 5 pruebas PASS without errors
- [ ] Coverage report shows ChromaDB integration working
- [ ] No flaky pruebas detected (ejecutar 2x)

**Owner:** ArchitectZero
**Due:** 2025-02-01

---

### Task 1.2: Documento Docker Setup for E2E Pruebas

**Estado:** ⏳ NOT STARTED
**Effort:** 45 min
**Output:** `doc/DOCKER_SETUP_FOR_TESTING.md`

**Content Scope:**
- [ ] Prerequisites (Docker, docker-compose)
- [ ] Service startup commands
- [ ] Environment variable configuración
- [ ] Health check verificación
- [ ] Troubleshooting guide
- [ ] Cleanup procedures

**Owner:** ArchitectZero
**Due:** 2025-02-01

---

### Task 1.3: Crear Prueba Verificación Script

**Estado:** ✅ COMPLETED
**Archivo:** `scripts/verify-pruebas.sh`

**Usage:**
```bash
bash scripts/verify-tests.sh unit         # Unit tests only
bash scripts/verify-tests.sh integration  # E2E tests (requires Docker)
bash scripts/verify-tests.sh all          # All tests
```

---

## 📌 Fase 2: High Priority (Siguiente Sprint)

### Task 2.1: Crear API Endpoint E2E Prueba Suite

**Estado:** ❌ NOT STARTED
**Effort:** 5-8 hours
**Priority:** 🔴 CRITICAL

**Scope:**
```
File: tests/integration/api/test_api_e2e.py

Tests to Create (20+):
├─ Health Endpoint Tests (5 tests)
│  ├─ GET /api/v1/health → 200 OK
│  ├─ Response schema validation
│  ├─ Error scenarios
│  └─ Rate limiting
│
├─ Chat Endpoint Tests (8 tests)
│  ├─ POST /api/v1/chat with real RAG
│  ├─ Streaming response handling
│  ├─ Invalid input validation
│  ├─ Timeout handling
│  ├─ Concurrent requests
│  ├─ Error recovery
│  └─ Session management
│
├─ Knowledge Search Tests (4 tests)
│  ├─ GET /api/v1/knowledge/search
│  ├─ Vector similarity validation
│  ├─ Pagination
│  └─ Metadata filtering
│
└─ Integration Tests (3+ tests)
   ├─ Full user flow (upload → ingest → chat)
   ├─ Authentication/authorization
   └─ Error handling across layers
```

**Implementación Steps:**
1. [ ] Setup API E2E prueba fixtures (PruebaClient, mock RAG)
2. [ ] Implement health endpoint pruebas
3. [ ] Implement chat endpoint pruebas (with streaming)
4. [ ] Implement knowledge search pruebas
5. [ ] Add integration scenarios
6. [ ] Measure coverage (target: >95% of API surface)
7. [ ] Documento API contract expectations

**Success Criteria:**
- [ ] 20+ pruebas creard
- [ ] All pruebas PASS
- [ ] Coverage >95% of public API endpoints
- [ ] No mocked dependencies (real RAG backend used)
- [ ] Streaming responses validated
- [ ] Error scenarios covered

**Owner:** TBD (ArchitectZero if capacity)
**Sprint:** Siguiente (Feb 3-14)
**Due:** 2025-02-14

---

### Task 2.2: Setup CI/CD Pipeline for Selective Prueba Ejecutars

**Estado:** ❌ NOT STARTED
**Effort:** 3-4 hours
**Priority:** 🟡 IMPORTANT

**Scope:**
```yaml
CI Pipeline Strategy:
├─ Pull Request (Unit tests only)
│  └─ Time: ~15 sec | Docker: NO
│
├─ Main Branch (Unit + E2E + Coverage)
│  └─ Time: ~60 sec | Docker: YES
│
└─ Release Branch (Unit + E2E + Performance)
   └─ Time: ~2 min | Docker: YES | Load tests: YES
```

**Implementación:**
1. [ ] Review current GitHub Actions workflow
2. [ ] Add conditional Docker startup (matrix strategy)
3. [ ] Separate unit vs E2E vs integration stages
4. [ ] Setup environment variables for E2E
5. [ ] Add coverage reporting to PR comments
6. [ ] Configure branch protections (min 80% coverage)

**Archivos to Modify:**
- `.github/workflows/prueba.yml`
- `pyproyecto.toml` (pyprueba config)
- `.env.example` (for CI setup)

**Owner:** TBD
**Sprint:** Siguiente (Feb 3-14)
**Due:** 2025-02-14

---

## 📌 Fase 3: Medium Priority (Q1 2025)

### Task 3.1: Implement Load Pruebaing Infraestructura

**Estado:** ❌ NOT STARTED
**Effort:** 6-8 hours
**Priority:** 🟡 MEDIUM

**Scope:**
```
Framework: Locust or Apache JMeter

Load Test Scenarios:
├─ Baseline: 10 concurrent users, 100 requests
├─ Ramp-up: 100 users over 5 minutes
├─ Stress: 1000 concurrent connections
└─ Spike: 500 sudden concurrent requests

Metrics:
├─ Response time (p50, p95, p99)
├─ Throughput (req/sec)
├─ Error rate
└─ Memory/CPU usage
```

**Implementación:**
- [ ] Choose Locust or JMeter
- [ ] Crear prueba scenarios
- [ ] Setup baseline measurements
- [ ] Integrate with CI/CD (optional)
- [ ] Documento performance regression limits

**Owner:** TBD
**Sprint:** TBD (Q1 2025)

---

### Task 3.2: API Contract Pruebaing

**Estado:** ❌ NOT STARTED
**Effort:** 4-6 hours
**Priority:** 🟡 MEDIUM

**Scope:**
```
Tool: Pact or OpenAPI Schema Validation

Validations:
├─ OpenAPI spec matches actual responses
├─ Response schemas consistent
├─ Deprecated endpoints handled
└─ Backward compatibility checks
```

**Implementación:**
- [ ] Generate/validate OpenAPI spec
- [ ] Crear consumer-driven contract pruebas
- [ ] Setup contract validation in CI
- [ ] Documento API versioning strategy

**Owner:** TBD
**Sprint:** TBD (Q1 2025)

---

## 📌 Fase 4: Lower Priority (Q2 2025+)

### Task 4.1: Browser/UI E2E Pruebas (Flutter)

**Estado:** ❌ DEFERRED
**Effort:** 15-20 hours
**Priority:** 🟢 LOW (post-MVP)

**Decision Point:** Evaluate need after MVP v1.0 release

**Options:**
1. **Appium + Flutter Driver**
   - Pro: Native Flutter pruebaing
   - Con: Requires app compilation for each prueba

2. **Integración Pruebaing (API Mock)**
   - Pro: Fast, no UI overhead
   - Con: Doesn't catch UI bugs

**Recommendation:** Choose Appium if UI polish is critical for MVP

---

### Task 4.2: Security Penetration Pruebaing

**Estado:** ❌ DEFERRED
**Effort:** 10-15 hours
**Priority:** 🟢 LOW (security hardening fase)

**Scope:**
```
OWASP Top 10 Coverage:
├─ Injection attacks
├─ XSS validation
├─ CSRF protection
├─ Authentication bypass
├─ Sensitive data exposure
└─ [+5 more OWASP items]
```

---

## 📊 Tracking Dashboard

```
Phase 1 (This Week)
├─ Task 1.1: Validate E2E Tests    ⏳ 0% → Target: 2025-02-01
├─ Task 1.2: Document Docker        ⏳ 0% → Target: 2025-02-01
└─ Task 1.3: Verify Script         ✅ 100% → DONE

Phase 2 (Next Sprint)
├─ Task 2.1: API E2E Tests         ❌ 0% → Target: 2025-02-14
└─ Task 2.2: CI/CD Setup           ❌ 0% → Target: 2025-02-14

Phase 3 (Q1 2025)
├─ Task 3.1: Load Testing          ❌ 0% → Target: Q1
└─ Task 3.2: Contract Testing      ❌ 0% → Target: Q1

Phase 4 (Q2 2025+)
├─ Task 4.1: Browser E2E           ❌ 0% → Target: Q2
└─ Task 4.2: Security Pen Testing  ❌ 0% → Target: Security Phase
```

---

## 🔗 Related Documentoation

- [TEST_SUITE_STATUS_REPORT.md](TEST_SUITE_STATUS_REPORT.md) - Full estado report
- [E2E_TESTS_QUICKSTART.md](E2E_TESTS_QUICKSTART.md) - Quick start guide
- [context/20-REQUIREMENTS_AND_SPEC/TESTING_STRATEGY.en.md](../context/20-REQUIREMENTS_AND_SPEC/TESTING_STRATEGY.en.md) - Pruebaing strategy
- [scripts/verify-pruebas.sh](../../scripts/verify-pruebas.sh) - Prueba verificación script

---

**Last Updated:** 2025-01-31
**Siguiente Review:** 2025-02-07
**Owner:** ArchitectZero
