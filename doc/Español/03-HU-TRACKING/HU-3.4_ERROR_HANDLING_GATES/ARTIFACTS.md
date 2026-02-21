# 📦 ARTIFACTS: HU-3.4 - Error Handling & Validation Gates

> **Total Estimated Lines:** ~1,650 lines (backend + frontend + pruebas + docs)
> **Archivos to Crear:** 19 archivos
> **Archivos to Update:** 3 archivos
> **Last Updated:** 09/02/2026

---

## 📁 Backend Artifacts (Python)

### Production Code

| Archivo | Path | Lines | Fase | Estado |
|------|------|-------|-------|--------|
| **documento_validator.py** | `src/server/app/services/validators/documento_validator.py` | ~150 | Fase 2 | ⏳ Pendiente |
| **retry.py** | `src/server/app/core/retry.py` | ~100 | Fase 2 | ⏳ Pendiente |
| **logging_config.py** | `src/server/app/core/logging_config.py` | ~60 | Fase 3 | ⏳ Pendiente |

**Subtotal Production:** 3 archivos, ~310 lines

### Prueba Code

| Archivo | Path | Lines | Fase | Estado |
|------|------|-------|-------|--------|
| **prueba_documento_validator.py** | `pruebas/python/unit/services/validators/prueba_documento_validator.py` | ~200 | Fase 1 | ⏳ Pendiente |
| **prueba_retry.py** | `pruebas/python/unit/core/prueba_retry.py` | ~150 | Fase 1 | ⏳ Pendiente |
| **prueba_error_handling_flow.py** | `pruebas/python/integration/prueba_error_handling_flow.py` | ~100 | Fase 4 | ⏳ Pendiente |

**Subtotal Pruebas:** 3 archivos, ~450 lines

### To Update

| Archivo | Path | Changes | Fase | Estado |
|------|------|---------|-------|--------|
| **exceptions.py** | `src/server/app/core/exceptions.py` | +80 lines (add ValidationError, RetryExhaustedError) | Fase 2 | ⏳ Pendiente |

**Backend Total:** 7 archivos, ~840 lines

---

## 📱 Frontend Artifacts (Flutter/Dart)

### Production Code

| Archivo | Path | Lines | Fase | Estado |
|------|------|-------|-------|--------|
| **error_mapper.dart** | `src/client/lib/core/error_handling/error_mapper.dart` | ~120 | Fase 2 | ⏳ Pendiente |
| **snackbar_service.dart** | `src/client/lib/core/error_handling/snackbar_service.dart` | ~180 | Fase 2 | ⏳ Pendiente |
| **error_context.dart** | `src/client/lib/core/error_handling/error_context.dart` | ~40 | Fase 3 | ⏳ Pendiente |

**Subtotal Production:** 3 archivos, ~340 lines

### Prueba Code

| Archivo | Path | Lines | Fase | Estado |
|------|------|-------|-------|--------|
| **error_mapper_prueba.dart** | `pruebas/prueba/unit/core/error_handling/error_mapper_prueba.dart` | ~100 | Fase 1 | ⏳ Pendiente |
| **snackbar_service_prueba.dart** | `pruebas/prueba/unit/core/error_handling/snackbar_service_prueba.dart` | ~150 | Fase 1 | ⏳ Pendiente |
| **error_handling_flow_prueba.dart** | `pruebas/prueba/integration/features/chat/error_handling_flow_prueba.dart` | ~120 | Fase 4 | ⏳ Pendiente |

**Subtotal Pruebas:** 3 archivos, ~370 lines

**Frontend Total:** 6 archivos, ~710 lines

---

## 📚 Documentoation Artifacts

### New Documentos

| Archivo | Path | Lines | Fase | Estado |
|------|------|-------|-------|--------|
| **WORKFLOW_MASTER_DEFINITION.en.md** | `doc/03-HU-TRACKING/HU-3.4_ERROR_HANDLING_GATES/` | ~650 | Fase 0 | ✅ Complete |
| **WORKFLOW_MASTER_DEFINITION.es.md** | `doc/03-HU-TRACKING/HU-3.4_ERROR_HANDLING_GATES/` | ~650 | Fase 0 | ✅ Complete |
| **VALIDATION_RULES.md** | `doc/03-HU-TRACKING/HU-3.4_ERROR_HANDLING_GATES/` | ~100 | Fase 0 | ⏳ Pendiente |
| **ERROR_HANDLING_GUIDE.md** | `doc/02-SETUP_DEV/ERROR_HANDLING_GUIDE.md` | ~150 | Fase 5 | ⏳ Pendiente |
| **COMPLETION_SUMMARY.md** | `doc/03-HU-TRACKING/HU-3.4_ERROR_HANDLING_GATES/` | ~200 | Fase 5 | ⏳ Pendiente |

**Subtotal New Docs:** 5 archivos, ~1,750 lines

### To Update

| Archivo | Path | Changes | Fase | Estado |
|------|------|---------|-------|--------|
| **ERROR_HANDLING_STANDARD.en.md** | `context/30-ARCHITECTURE/` | Add VAL_001-005 codes | Fase 5 | ⏳ Pendiente |
| **ERROR_HANDLING_STANDARD.es.md** | `context/30-ARCHITECTURE/` | Add VAL_001-005 codes | Fase 5 | ⏳ Pendiente |

**Documentoation Total:** 7 archivos, ~1,750 lines (estimated)

---

## 🧪 Prueba Fixtures

| Archivo | Path | Lines | Fase | Estado |
|------|------|-------|-------|--------|
| **invalid_documentos.json** | `pruebas/python/fixtures/` | ~50 | Fase 0 | ⏳ Pendiente |
| **valid_documentos.json** | `pruebas/python/fixtures/` | ~50 | Fase 0 | ⏳ Pendiente |

**Fixtures Total:** 2 archivos, ~100 lines

---

## 📊 Summary

### By Category

| Category | Archivos | Lines | Estado |
|----------|-------|-------|--------|
| Backend Production | 3 | ~310 | ⏳ 0% |
| Backend Pruebas | 3 | ~450 | ⏳ 0% |
| Frontend Production | 3 | ~340 | ⏳ 0% |
| Frontend Pruebas | 3 | ~370 | ⏳ 0% |
| Documentoation | 5 new + 2 updates | ~1,750 | ⏳ 40% (2/5 new complete) |
| Prueba Fixtures | 2 | ~100 | ⏳ 0% |

**Grand Total:** 19 new archivos + 3 updates = 22 artifacts, ~3,320 lines

### By Fase

| Fase | Artifacts | Estado |
|-------|-----------|--------|
| Fase 0: Preparation | 4 (2 workflows + 1 validation rules + 2 fixtures) | ⏳ 50% (2/4) |
| Fase 1: TDD RED | 6 (all prueba archivos) | ⏳ 0% |
| Fase 2: TDD GREEN | 6 (production code + exceptions update) | ⏳ 0% |
| Fase 3: TDD REFACTOR | 2 (logging_config + error_context) | ⏳ 0% |
| Fase 4: Integración | 2 (E2E pruebas) | ⏳ 0% |
| Fase 5: Documentoation | 4 (guides + standards updates) | ⏳ 0% |
| Fase 6: CI/CD | 0 (validation only) | ⏸️ Not Started |

---

## 📝 Detailed Artifact Descripcións

### Backend

#### `documento_validator.py` (~150 lines)
**Purpose:** Implement 5 validation gates for documento quality assurance.

**Classes:**
- `DocumentoValidator`
  - `validate_content(content: str) -> bool` - VAL_001 (min length)
  - `validate_markdown(content: str) -> bool` - VAL_002 (structure)
  - `validate_encoding(content: bytes) -> bool` - VAL_003 (UTF-8)
  - `validate_safety(content: str) -> bool` - VAL_004 (XSS patterns)
  - `validate_size(content: str) -> bool` - VAL_005 (max size)
  - `validate_all(content: str) -> bool` - Ejecutar all gates

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
- `showRetryableError(context, message, onRetry)` - With retry botón

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

### Fase 0 (Preparation)
- [x] WORKFLOW_MASTER_DEFINITION.en.md
- [x] WORKFLOW_MASTER_DEFINITION.es.md
- [ ] VALIDATION_RULES.md
- [ ] invalid_documentos.json
- [ ] valid_documentos.json

### Fase 1 (TDD RED)
- [ ] prueba_documento_validator.py
- [ ] prueba_retry.py
- [ ] error_mapper_prueba.dart
- [ ] snackbar_service_prueba.dart

### Fase 2 (TDD GREEN)
- [ ] documento_validator.py
- [ ] retry.py
- [ ] exceptions.py (update)
- [ ] error_mapper.dart
- [ ] snackbar_service.dart

### Fase 3 (TDD REFACTOR)
- [ ] logging_config.py
- [ ] error_context.dart

### Fase 4 (Integración)
- [ ] prueba_error_handling_flow.py
- [ ] error_handling_flow_prueba.dart

### Fase 5 (Documentoation)
- [ ] ERROR_HANDLING_GUIDE.md
- [ ] COMPLETION_SUMMARY.md
- [ ] ERROR_HANDLING_STANDARD.en.md (update)
- [ ] ERROR_HANDLING_STANDARD.es.md (update)

**Progress:** 2/22 artifacts complete (9%)

---

**Last Updated:** 09/02/2026
**Siguiente Hito:** Complete Fase 0 artifacts
