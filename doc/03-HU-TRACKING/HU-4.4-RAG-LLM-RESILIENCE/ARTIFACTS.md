# 📦 HU-4.4: RAG/LLM Resilience Extensions - ARTIFACTS MANIFEST

> **User Story:** HU-4.4 - RAG/LLM Resilience Extensions
> **Branch:** `feature/rag-llm-resilience`
> **Purpose:** Lista completa de archivos a modificar/crear para completar los 4 GAPS críticos

---

## 📋 Tabla de Contenidos

1. [Files to Modify](#-files-to-modify)
2. [Files to Create](#-files-to-create)
3. [LOC Estimates](#-loc-estimates)
4. [Test Files Distribution](#-test-files-distribution)
5. [Coverage Targets](#-coverage-targets)

---

## 📝 Files to Modify

### Backend (3 archivos)

| # | File Path | Purpose | LOC Changed | Tests | Priority |
|---|-----------|---------|-------------|-------|----------|
| 1 | `src/server/app/services/rag/orchestrator.py` | Graceful degradation + timeout | ~40 | 7 | 🔴 Critical |
| 2 | `src/server/app/infrastructure/llm/ollama_client.py` | Apply `@with_retry` decorator | ~10 | 8 | 🟡 High |
| 3 | `src/server/app/core/exceptions.py` | Add DB_ERR_001, RAG_ERR_001 | ~30 | N/A | 🟢 Low |

**Total Backend LOC:** ~80 lines modified

---

### Frontend (1 archivo)

| # | File Path | Purpose | LOC Changed | Tests | Priority |
|---|-----------|---------|-------------|-------|----------|
| 4 | `src/client/lib/core/error_handling/error_mapper.dart` | Add error messages for new codes | ~10 | 1 | 🟢 Low |

**Total Frontend LOC:** ~10 lines modified

---

## 🆕 Files to Create

### Test Files (3 archivos nuevos)

| # | File Path | Purpose | LOC | Tests | Priority |
|---|-----------|---------|-----|-------|----------|
| 1 | `tests/server/unit/services/rag/test_orchestrator_degradation.py` | Test graceful degradation | ~250 | 7 | 🔴 Critical |
| 2 | `tests/server/unit/infrastructure/llm/test_ollama_retry.py` | Test retry logic | ~280 | 8 | 🟡 High |
| 3 | *(Updated existing)* `tests/client/unit/core/error_handling/error_mapper_test.dart` | Test new error codes | ~50 | 1 | 🟢 Low |

**Total Test LOC:** ~580 lines new

---

## 📊 LOC Estimates

### By Language

| Language | Files Modified | Files Created | Total LOC | Tests LOC | Production LOC |
|----------|----------------|---------------|-----------|-----------|----------------|
| **Python** | 3 | 2 | ~620 | ~530 | ~90 |
| **Dart** | 1 | 0 | ~60 | ~50 | ~10 |
| **Total** | **4** | **2** | **~680** | **~580** | **~100** |

### By Priority

| Priority | Files | LOC Production | LOC Tests | Total LOC |
|----------|-------|----------------|-----------|-----------|
| 🔴 **Critical** | 1 | ~40 | ~250 | ~290 |
| 🟡 **High** | 1 | ~10 | ~280 | ~290 |
| 🟢 **Low** | 2 | ~40 | ~50 | ~90 |
| **Total** | **4** | **~90** | **~580** | **~670** |

---

## 🧪 Test Files Distribution

### Backend Tests (15 tests total)

#### File 1: `test_orchestrator_degradation.py` (7 tests)

```python
# tests/server/unit/services/rag/test_orchestrator_degradation.py

# Test Suite: Graceful Degradation in RAG Orchestrator
# Coverage Target: ≥90%

1. test_orchestrator_continues_when_chromadb_fails()
   - Mock vector_store.search() → raise ConnectionError
   - Assert: Response returned with sources=[]
   - Assert: template_used="FALLBACK"
   - LOC: ~30

2. test_orchestrator_logs_warning_not_error_on_degradation()
   - Mock logger
   - Assert: logger.warning() called
   - Assert: logger.error() NOT called
   - LOC: ~25

3. test_orchestrator_handles_chromadb_connection_error()
   - Mock vector_store.search() → ConnectionError
   - Assert: No exception propagates
   - LOC: ~20

4. test_orchestrator_handles_chromadb_timeout_error()
   - Mock vector_store.search() → asyncio.TimeoutError
   - Assert: Degradation triggered
   - LOC: ~25

5. test_orchestrator_handles_generic_vector_store_exception()
   - Mock vector_store.search() → Exception("Unknown")
   - Assert: Degradation handles generic errors
   - LOC: ~20

6. test_orchestrator_applies_30s_timeout_to_rag_search()
   - Mock vector_store.search() with asyncio.sleep(35)
   - Assert: TimeoutError after ~30s
   - LOC: ~30

7. test_orchestrator_stream_degrades_when_chromadb_fails()
   - Test streaming variant degrades gracefully
   - Assert: Stream yields tokens despite RAG failure
   - LOC: ~40

Total LOC: ~250
```

---

#### File 2: `test_ollama_retry.py` (8 tests)

```python
# tests/server/unit/infrastructure/llm/test_ollama_retry.py

# Test Suite: Retry Logic for LLM Calls
# Coverage Target: ≥95%

1. test_ollama_retry_succeeds_third_attempt()
   - Mock httpx.post() → [fail, fail, success]
   - Assert: 3 calls made
   - Assert: Final result returned
   - LOC: ~35

2. test_ollama_retry_exhausts_after_max_retries()
   - Mock httpx.post() → [fail, fail, fail]
   - Assert: RetryExhaustedError raised
   - Assert: 3 attempts made
   - LOC: ~30

3. test_ollama_retry_uses_exponential_backoff()
   - Mock asyncio.sleep()
   - Assert: sleep(0.5), sleep(1.0), sleep(2.0) called
   - LOC: ~35

4. test_ollama_retry_logs_warnings()
   - Mock logger
   - Assert: logger.warning called 2x (attempts 1, 2)
   - LOC: ~25

5. test_ollama_retry_logs_success_after_retry()
   - Mock logger
   - Assert: logger.info called with "Retry successful"
   - LOC: ~25

6. test_ollama_no_retry_on_immediate_success()
   - Mock httpx.post() → [success]
   - Assert: 1 call only, no warnings
   - LOC: ~20

7. test_ollama_retry_only_on_request_error()
   - Mock httpx.post() → raise ValueError
   - Assert: No retries (fail immediately)
   - LOC: ~25

8. test_ollama_stream_generate_also_retries()
   - Test stream_generate() has retry logic
   - Assert: Retries work for streaming
   - LOC: ~40

Total LOC: ~280
```

---

### Frontend Tests (1 test)

#### File 3: `error_mapper_test.dart` (1 test added)

```dart
// tests/client/unit/core/error_handling/error_mapper_test.dart

// Test Suite: Error Mapper (existing file, add 1 test)
// Coverage Target: ≥85%

void test_error_mapper_maps_chromadb_and_rag_errors() {
  test('should map DB_ERR_001 to Spanish message', () {
    // Assert message contains "base de datos"
    // LOC: ~10
  });

  test('should map RAG_ERR_001 to Spanish message', () {
    // Assert message contains "contexto" and "conocimiento"
    // LOC: ~10
  });

  test('should provide suggestions for DB_ERR_001', () {
    // Assert suggestion contains "Docker", "ChromaDB"
    // LOC: ~10
  });

  test('should provide suggestions for RAG_ERR_001', () {
    // Assert suggestion contains "nueva"
    // LOC: ~10
  });
}

Total LOC: ~50 (4 sub-tests)
```

---

## 🎯 Coverage Targets

### Backend

| Module | File | Current | Target | Tests | Priority |
|--------|------|---------|--------|-------|----------|
| RAG Orchestrator | `orchestrator.py` | 85% | ≥90% | 7 | 🔴 Critical |
| LLM Client | `ollama_client.py` | 88% | ≥95% | 8 | 🟡 High |
| Exceptions | `exceptions.py` | 100% | ≥95% | N/A | 🟢 Low |

**Overall Backend Target:** ≥90%

---

### Frontend

| Module | File | Current | Target | Tests | Priority |
|--------|------|---------|--------|-------|----------|
| Error Mapper | `error_mapper.dart` | 92% | ≥85% | 1 | 🟢 Low |

**Overall Frontend Target:** ≥85%

---

## 📂 Directory Structure (After HU-4.4)

```
soft-architect-ai/
├── src/
│   ├── server/
│   │   └── app/
│   │       ├── core/
│   │       │   └── exceptions.py                     # MODIFIED (+30 LOC)
│   │       ├── infrastructure/
│   │       │   └── llm/
│   │       │       └── ollama_client.py              # MODIFIED (+10 LOC)
│   │       └── services/
│   │           └── rag/
│   │               └── orchestrator.py               # MODIFIED (+40 LOC)
│   └── client/
│       └── lib/
│           └── core/
│               └── error_handling/
│                   └── error_mapper.dart             # MODIFIED (+10 LOC)
│
├── tests/
│   ├── server/
│   │   └── unit/
│   │       ├── infrastructure/
│   │       │   └── llm/
│   │       │       └── test_ollama_retry.py          # NEW FILE (~280 LOC)
│   │       └── services/
│   │           └── rag/
│   │               └── test_orchestrator_degradation.py  # NEW FILE (~250 LOC)
│   └── client/
│       └── unit/
│           └── core/
│               └── error_handling/
│                   └── error_mapper_test.dart        # MODIFIED (+50 LOC)
│
└── doc/
    └── 03-HU-TRACKING/
        └── HU-4.4-RAG-LLM-RESILIENCE/
            ├── README.md                              # NEW (1000+ LOC)
            ├── PROGRESS.md                            # NEW (1400+ LOC)
            └── ARTIFACTS.md                           # NEW (this file, 400+ LOC)
```

---

## 🔄 Git Workflow Summary

### Branch Strategy

```bash
# Main branches
main                  # Production-ready code
develop               # Integration branch (base for HU-4.4)
feature/rag-llm-resilience  # HU-4.4 feature branch

# Branch lifecycle
1. Create from develop: git checkout -b feature/rag-llm-resilience develop
2. Implement changes (6 phases)
3. Commit often (conventional commits format)
4. Push to remote: git push origin feature/rag-llm-resilience
5. Create PR: feature/rag-llm-resilience → develop
6. Review, test, merge
7. Delete branch post-merge
```

### Commit Strategy (Conventional Commits)

```bash
# Format: <type>(<scope>): <subject>

# Examples for HU-4.4:
feat(hu-4.4): implement graceful degradation in RAG orchestrator
feat(hu-4.4): apply @with_retry to Ollama LLM calls
feat(hu-4.4): add error messages for DB_ERR_001, RAG_ERR_001
test(hu-4.4): add 7 tests for orchestrator degradation
test(hu-4.4): add 8 tests for Ollama retry logic
docs(hu-4.4): initialize RAG/LLM resilience documentation
chore(hu-4.4): update USER_STORIES_MASTER.es.json with new HU-4.4
```

---

## 📌 Key Deliverables Checklist

### Documentation ✅

- [✅] README.md (bilingual, 1000+ lines)
- [✅] PROGRESS.md (6-phase TDD tracking, 1400+ lines)
- [✅] ARTIFACTS.md (this file, 400+ lines)
- [ ] USER_STORIES_MASTER.es.json updated

### Backend Implementation 🔜

- [ ] `orchestrator.py` modified (graceful degradation + timeout)
- [ ] `ollama_client.py` modified (retry decorator applied)
- [ ] `exceptions.py` modified (DB_ERR_001, RAG_ERR_001 added)

### Frontend Implementation 🔜

- [ ] `error_mapper.dart` modified (messages for new codes)

### Testing 🔜

- [ ] `test_orchestrator_degradation.py` created (7 tests)
- [ ] `test_ollama_retry.py` created (8 tests)
- [ ] `error_mapper_test.dart` modified (1 test added)
- [ ] All 16/16 tests passing
- [ ] Coverage: Backend ≥90%, Frontend ≥85%

### Quality Gates 🔜

- [ ] Black formatting passing
- [ ] Ruff linting passing
- [ ] Pyright type checking passing
- [ ] Bandit security audit passing
- [ ] PRE_PUSH validation 19/19 passing

### Git Operations 🔜

- [ ] All changes committed (conventional commits)
- [ ] Pushed to remote: `feature/rag-llm-resilience`
- [ ] PR created on GitHub
- [ ] PR approved and merged to `develop`
- [ ] Feature branch deleted post-merge

---

## 🎯 Success Metrics

| Metric | Target | Actual | Status |
|--------|--------|--------|--------|
| **Tests Passing** | 16/16 (100%) | 0/16 | 🔜 Pending |
| **Coverage Backend** | ≥90% | TBD | 🔜 Pending |
| **Coverage Frontend** | ≥85% | TBD | 🔜 Pending |
| **Quality Gates** | 19/19 | 0/19 | 🔜 Pending |
| **Manual Tests** | 3/3 | 0/3 | 🔜 Pending |
| **Time Estimate** | ~4.5h | TBD | 🔜 Pending |
| **LOC Production** | ~100 | 0 | 🔜 Pending |
| **LOC Tests** | ~580 | 0 | 🔜 Pending |

---

**Last Updated:** 2026-02-15 (Phase 0 - Documentation Setup)
**Next Step:** Update USER_STORIES_MASTER.es.json and start Phase 1 (TDD RED)
