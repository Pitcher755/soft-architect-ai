# 📋 Test Suite Roadmap & Pending Tasks

> **Fecha:** 2025-01-31
> **Estado:** In Progress
> **Responsable:** ArchitectZero (Agente)

---

## 🎯 Current Status

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

## 📌 Phase 1: Immediate Actions (This Week)

### Task 1.1: Validate E2E Tests Run Successfully

**Status:** ⏳ NOT STARTED
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
- [ ] All 5 E2E tests execute (not skipped)
- [ ] All 5 tests PASS without errors
- [ ] Coverage report shows ChromaDB integration working
- [ ] No flaky tests detected (run 2x)

**Owner:** ArchitectZero
**Due:** 2025-02-01

---

### Task 1.2: Document Docker Setup for E2E Tests

**Status:** ⏳ NOT STARTED
**Effort:** 45 min
**Output:** `doc/DOCKER_SETUP_FOR_TESTING.md`

**Content Scope:**
- [ ] Prerequisites (Docker, docker-compose)
- [ ] Service startup commands
- [ ] Environment variable configuration
- [ ] Health check verification
- [ ] Troubleshooting guide
- [ ] Cleanup procedures

**Owner:** ArchitectZero
**Due:** 2025-02-01

---

### Task 1.3: Create Test Verification Script

**Status:** ✅ COMPLETED
**File:** `scripts/verify-tests.sh`

**Usage:**
```bash
bash scripts/verify-tests.sh unit         # Unit tests only
bash scripts/verify-tests.sh integration  # E2E tests (requires Docker)
bash scripts/verify-tests.sh all          # All tests
```

---

## 📌 Phase 2: High Priority (Next Sprint)

### Task 2.1: Create API Endpoint E2E Test Suite

**Status:** ❌ NOT STARTED
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

**Implementation Steps:**
1. [ ] Setup API E2E test fixtures (TestClient, mock RAG)
2. [ ] Implement health endpoint tests
3. [ ] Implement chat endpoint tests (with streaming)
4. [ ] Implement knowledge search tests
5. [ ] Add integration scenarios
6. [ ] Measure coverage (target: >95% of API surface)
7. [ ] Document API contract expectations

**Success Criteria:**
- [ ] 20+ tests created
- [ ] All tests PASS
- [ ] Coverage >95% of public API endpoints
- [ ] No mocked dependencies (real RAG backend used)
- [ ] Streaming responses validated
- [ ] Error scenarios covered

**Owner:** TBD (ArchitectZero if capacity)
**Sprint:** Next (Feb 3-14)
**Due:** 2025-02-14

---

### Task 2.2: Setup CI/CD Pipeline for Selective Test Runs

**Status:** ❌ NOT STARTED
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

**Implementation:**
1. [ ] Review current GitHub Actions workflow
2. [ ] Add conditional Docker startup (matrix strategy)
3. [ ] Separate unit vs E2E vs integration stages
4. [ ] Setup environment variables for E2E
5. [ ] Add coverage reporting to PR comments
6. [ ] Configure branch protections (min 80% coverage)

**Files to Modify:**
- `.github/workflows/test.yml`
- `pyproject.toml` (pytest config)
- `.env.example` (for CI setup)

**Owner:** TBD
**Sprint:** Next (Feb 3-14)
**Due:** 2025-02-14

---

## 📌 Phase 3: Medium Priority (Q1 2025)

### Task 3.1: Implement Load Testing Infrastructure

**Status:** ❌ NOT STARTED
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

**Implementation:**
- [ ] Choose Locust or JMeter
- [ ] Create test scenarios
- [ ] Setup baseline measurements
- [ ] Integrate with CI/CD (optional)
- [ ] Document performance regression limits

**Owner:** TBD
**Sprint:** TBD (Q1 2025)

---

### Task 3.2: API Contract Testing

**Status:** ❌ NOT STARTED
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

**Implementation:**
- [ ] Generate/validate OpenAPI spec
- [ ] Create consumer-driven contract tests
- [ ] Setup contract validation in CI
- [ ] Document API versioning strategy

**Owner:** TBD
**Sprint:** TBD (Q1 2025)

---

## 📌 Phase 4: Lower Priority (Q2 2025+)

### Task 4.1: Browser/UI E2E Tests (Flutter)

**Status:** ❌ DEFERRED
**Effort:** 15-20 hours
**Priority:** 🟢 LOW (post-MVP)

**Decision Point:** Evaluate need after MVP v1.0 release

**Options:**
1. **Appium + Flutter Driver**
   - Pro: Native Flutter testing
   - Con: Requires app compilation for each test

2. **Integration Testing (API Mock)**
   - Pro: Fast, no UI overhead
   - Con: Doesn't catch UI bugs

**Recommendation:** Choose Appium if UI polish is critical for MVP

---

### Task 4.2: Security Penetration Testing

**Status:** ❌ DEFERRED
**Effort:** 10-15 hours
**Priority:** 🟢 LOW (security hardening phase)

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

## 🔗 Related Documentation

- [TEST_SUITE_STATUS_REPORT.md](TEST_SUITE_STATUS_REPORT.md) - Full status report
- [E2E_TESTS_QUICKSTART.md](E2E_TESTS_QUICKSTART.md) - Quick start guide
- [context/20-REQUIREMENTS_AND_SPEC/TESTING_STRATEGY.en.md](../context/20-REQUIREMENTS_AND_SPEC/TESTING_STRATEGY.en.md) - Testing strategy
- [scripts/verify-tests.sh](../../scripts/verify-tests.sh) - Test verification script

---

**Last Updated:** 2025-01-31
**Next Review:** 2025-02-07
**Owner:** ArchitectZero
