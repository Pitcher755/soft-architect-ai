# 📦 ARTIFACTS: HU-3.4 - Error Handling & Validation Gates

> **Total Estimated Lines:** ~1,650 lines (backend + frontend + tests + docs)
> **Files to Create:** 19 files
> **Files to Update:** 3 files
> **Last Updated:** 09/02/2026

---

## 📁 Backend Artifacts (Python)

### Production Code

| File | Path | Lines | Phase | Status |
|------|------|-------|-------|--------|
| **document_validator.py** | `src/server/app/services/validators/document_validator.py` | ~150 | Phase 2 | ⏳ Pending |
| **retry.py** | `src/server/app/core/retry.py` | ~100 | Phase 2 | ⏳ Pending |
| **logging_config.py** | `src/server/app/core/logging_config.py` | ~60 | Phase 3 | ⏳ Pending |

**Subtotal Production:** 3 files, ~310 lines

### Test Code

| File | Path | Lines | Phase | Status |
|------|------|-------|-------|--------|
| **test_document_validator.py** | `tests/python/unit/services/validators/test_document_validator.py` | ~200 | Phase 1 | ⏳ Pending |
| **test_retry.py** | `tests/python/unit/core/test_retry.py` | ~150 | Phase 1 | ⏳ Pending |
| **test_error_handling_flow.py** | `tests/python/integration/test_error_handling_flow.py` | ~100 | Phase 4 | ⏳ Pending |

**Subtotal Tests:** 3 files, ~450 lines

### To Update

| File | Path | Changes | Phase | Status |
|------|------|---------|-------|--------|
| **exceptions.py** | `src/server/app/core/exceptions.py` | +80 lines (add ValidationError, RetryExhaustedError) | Phase 2 | ⏳ Pending |

**Backend Total:** 7 files, ~840 lines

---

## 📱 Frontend Artifacts (Flutter/Dart)

### Production Code

| File | Path | Lines | Phase | Status |
|------|------|-------|-------|--------|
| **error_mapper.dart** | `src/client/lib/core/error_handling/error_mapper.dart` | ~120 | Phase 2 | ⏳ Pending |
| **snackbar_service.dart** | `src/client/lib/core/error_handling/snackbar_service.dart` | ~180 | Phase 2 | ⏳ Pending |
| **error_context.dart** | `src/client/lib/core/error_handling/error_context.dart` | ~40 | Phase 3 | ⏳ Pending |

**Subtotal Production:** 3 files, ~340 lines

### Test Code

| File | Path | Lines | Phase | Status |
|------|------|-------|-------|--------|
| **error_mapper_test.dart** | `tests/test/unit/core/error_handling/error_mapper_test.dart` | ~100 | Phase 1 | ⏳ Pending |
| **snackbar_service_test.dart** | `tests/test/unit/core/error_handling/snackbar_service_test.dart` | ~150 | Phase 1 | ⏳ Pending |
| **error_handling_flow_test.dart** | `tests/test/integration/features/chat/error_handling_flow_test.dart` | ~120 | Phase 4 | ⏳ Pending |

**Subtotal Tests:** 3 files, ~370 lines

**Frontend Total:** 6 files, ~710 lines

---

## 📚 Documentation Artifacts

### New Documents

| File | Path | Lines | Phase | Status |
|------|------|-------|-------|--------|
| **WORKFLOW_MASTER_DEFINITION.en.md** | `doc/03-HU-TRACKING/HU-3.4_ERROR_HANDLING_GATES/` | ~650 | Phase 0 | ✅ Complete |
| **WORKFLOW_MASTER_DEFINITION.es.md** | `doc/03-HU-TRACKING/HU-3.4_ERROR_HANDLING_GATES/` | ~650 | Phase 0 | ✅ Complete |
| **VALIDATION_RULES.md** | `doc/03-HU-TRACKING/HU-3.4_ERROR_HANDLING_GATES/` | ~100 | Phase 0 | ⏳ Pending |
| **ERROR_HANDLING_GUIDE.md** | `doc/02-SETUP_DEV/ERROR_HANDLING_GUIDE.md` | ~150 | Phase 5 | ⏳ Pending |
| **COMPLETION_SUMMARY.md** | `doc/03-HU-TRACKING/HU-3.4_ERROR_HANDLING_GATES/` | ~200 | Phase 5 | ⏳ Pending |

**Subtotal New Docs:** 5 files, ~1,750 lines

### To Update

| File | Path | Changes | Phase | Status |
|------|------|---------|-------|--------|
| **ERROR_HANDLING_STANDARD.en.md** | `context/30-ARCHITECTURE/` | Add VAL_001-005 codes | Phase 5 | ⏳ Pending |
| **ERROR_HANDLING_STANDARD.es.md** | `context/30-ARCHITECTURE/` | Add VAL_001-005 codes | Phase 5 | ⏳ Pending |

**Documentation Total:** 7 files, ~1,750 lines (estimated)

---

## 🧪 Test Fixtures

| File | Path | Lines | Phase | Status |
|------|------|-------|-------|--------|
| **invalid_documents.json** | `tests/python/fixtures/` | ~50 | Phase 0 | ⏳ Pending |
| **valid_documents.json** | `tests/python/fixtures/` | ~50 | Phase 0 | ⏳ Pending |

**Fixtures Total:** 2 files, ~100 lines

---

## 📊 Summary

### By Category

| Category | Files | Lines | Status |
|----------|-------|-------|--------|
| Backend Production | 3 | ~310 | ⏳ 0% |
| Backend Tests | 3 | ~450 | ⏳ 0% |
| Frontend Production | 3 | ~340 | ⏳ 0% |
| Frontend Tests | 3 | ~370 | ⏳ 0% |
| Documentation | 5 new + 2 updates | ~1,750 | ⏳ 40% (2/5 new complete) |
| Test Fixtures | 2 | ~100 | ⏳ 0% |

**Grand Total:** 19 new files + 3 updates = 22 artifacts, ~3,320 lines

### By Phase

| Phase | Artifacts | Status |
|-------|-----------|--------|
| Phase 0: Preparation | 4 (2 workflows + 1 validation rules + 2 fixtures) | ⏳ 50% (2/4) |
| Phase 1: TDD RED | 6 (all test files) | ⏳ 0% |
| Phase 2: TDD GREEN | 6 (production code + exceptions update) | ⏳ 0% |
| Phase 3: TDD REFACTOR | 2 (logging_config + error_context) | ⏳ 0% |
| Phase 4: Integration | 2 (E2E tests) | ⏳ 0% |
| Phase 5: Documentation | 4 (guides + standards updates) | ⏳ 0% |
| Phase 6: CI/CD | 0 (validation only) | ⏸️ Not Started |

---

## 📝 Detailed Artifact Descriptions

### Backend

#### `document_validator.py` (~150 lines)
**Purpose:** Implement 5 validation gates for document quality assurance.

**Classes:**
- `DocumentValidator`
  - `validate_content(content: str) -> bool` - VAL_001 (min length)
  - `validate_markdown(content: str) -> bool` - VAL_002 (structure)
  - `validate_encoding(content: bytes) -> bool` - VAL_003 (UTF-8)
  - `validate_safety(content: str) -> bool` - VAL_004 (XSS patterns)
  - `validate_size(content: str) -> bool` - VAL_005 (max size)
  - `validate_all(content: str) -> bool` - Run all gates

**Constants:**
- `MIN_LENGTH = 50`
- `MAX_SIZE_BYTES = 5 * 1024 * 1024`  # 5MB
- `XSS_PATTERNS = [...]`

---

#### `retry.py` (~100 lines)
**Purpose:** Decorator for automatic retry with exponential backoff.

**Functions:**
- `with_retry(max_retries, base_delay, backoff_multiplier, retryable_exceptions) -> Callable`

**Features:**
- Exponential backoff: 1s, 2s, 4s
- Logs each retry attempt with context
- Raises `RetryExhaustedError` after max attempts

---

#### `logging_config.py` (~60 lines)
**Purpose:** Structured JSON logging for error audit trail.

**Classes:**
- `StructuredFormatter(logging.Formatter)`
  - `format(record: LogRecord) -> str` - JSON output

**Functions:**
- `setup_logging() -> None` - Configure application logging

---

### Frontend

#### `error_mapper.dart` (~120 lines)
**Purpose:** Map backend error codes to Spanish messages.

**Class:** `ErrorMapper`
- `getUserMessage(String errorCode) -> String`
- `getSuggestion(String errorCode) -> String`
- `isRetryable(String errorCode) -> bool`

**Error Codes:** 11+ codes (SYS_001, VAL_001-005, AUTH_001, RAG_001-002)

---

#### `snackbar_service.dart` (~180 lines)
**Purpose:** Display contextual snackbar notifications with UX optimization.

**Class:** `SnackbarService`
- `showSuccess(context, message)` - Auto-hide 5s
- `showInfo(context, message)` - Auto-hide 5s
- `showError(context, message, errorCode)` - Manual close
- `showRetryableError(context, message, onRetry)` - With retry button

---

#### `error_context.dart` (~40 lines)
**Purpose:** Data model for error context tracking.

**Class:** `ErrorContext`
- `errorCode: String`
- `message: String`
- `suggestion: String`
- `isRetryable: bool`
- `timestamp: DateTime`
- `toJson() -> Map<String, dynamic>`

---

## 🎯 Deliverable Checklist

### Phase 0 (Preparation)
- [x] WORKFLOW_MASTER_DEFINITION.en.md
- [x] WORKFLOW_MASTER_DEFINITION.es.md
- [ ] VALIDATION_RULES.md
- [ ] invalid_documents.json
- [ ] valid_documents.json

### Phase 1 (TDD RED)
- [ ] test_document_validator.py
- [ ] test_retry.py
- [ ] error_mapper_test.dart
- [ ] snackbar_service_test.dart

### Phase 2 (TDD GREEN)
- [ ] document_validator.py
- [ ] retry.py
- [ ] exceptions.py (update)
- [ ] error_mapper.dart
- [ ] snackbar_service.dart

### Phase 3 (TDD REFACTOR)
- [ ] logging_config.py
- [ ] error_context.dart

### Phase 4 (Integration)
- [ ] test_error_handling_flow.py
- [ ] error_handling_flow_test.dart

### Phase 5 (Documentation)
- [ ] ERROR_HANDLING_GUIDE.md
- [ ] COMPLETION_SUMMARY.md
- [ ] ERROR_HANDLING_STANDARD.en.md (update)
- [ ] ERROR_HANDLING_STANDARD.es.md (update)

**Progress:** 2/22 artifacts complete (9%)

---

**Last Updated:** 09/02/2026
**Next Milestone:** Complete Phase 0 artifacts
