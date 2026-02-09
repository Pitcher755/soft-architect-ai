# 📋 Validation Rules Specification

> **Date:** 09/02/2026
> **HU:** HU-3.4 - Error Handling & Validation Gates
> **Status:** ✅ ACTIVE

---

## 📖 Table of Contents

1. [Document Content Validation](#document-content-validation)
2. [Retry Rules](#retry-rules)
3. [Error Code Mapping](#error-code-mapping)
4. [Implementation References](#implementation-references)

---

## 🔍 Document Content Validation

### VAL_001: Minimum Length
- **Rule:** Document content must be at least 50 characters
- **Rationale:** Prevent incomplete/corrupted generation
- **Error Message (ES):** "El documento debe tener al menos 50 caracteres"
- **User Action:** Regenerate document
- **Implementation:** `DocumentValidator.validate_content()`

### VAL_002: Valid Markdown Structure
- **Rule:** Markdown syntax must be well-formed
- **Checks:**
  - Brackets balanced: `[` count == `]` count
  - Parentheses balanced: `(` count == `)` count
  - No unclosed code blocks (```)
- **Error Message (ES):** "El documento contiene Markdown mal formado"
- **User Action:** Review structure, regenerate
- **Implementation:** `DocumentValidator.validate_markdown()`

### VAL_003: UTF-8 Encoding
- **Rule:** Content must be valid UTF-8
- **Rationale:** Prevent encoding corruption in ChromaDB
- **Error Message (ES):** "El documento no está codificado en UTF-8"
- **User Action:** Internal fix, report if persistent
- **Implementation:** `DocumentValidator.validate_encoding()`

### VAL_004: No Malicious Code (XSS Prevention)
- **Rule:** Content must not contain XSS patterns
- **Blocked Patterns:**
  - `<script.*?>.*?</script>` (script tags)
  - `javascript:` (javascript protocol)
  - `onerror\s*=` (onerror handlers)
  - `onload\s*=` (onload handlers)
- **Error Message (ES):** "El documento contiene código potencialmente malicioso"
- **User Action:** Contact support
- **Implementation:** `DocumentValidator.validate_safety()`

### VAL_005: Maximum Size
- **Rule:** Document must be < 5MB
- **Rationale:** Prevent memory issues, ChromaDB limits
- **Error Message (ES):** "El documento excede el tamaño máximo de 5MB"
- **User Action:** Reduce document size
- **Implementation:** `DocumentValidator.validate_size()`

---

## 🔄 Retry Rules

### Configuration
```python
MAX_RETRIES = 3
BASE_DELAY = 1.0  # seconds
BACKOFF_MULTIPLIER = 2.0
MAX_DELAY = 8.0  # seconds
```

### Retry Schedule
| Attempt | Delay Before Retry | Cumulative Time |
|---------|-------------------|-----------------|
| 1       | 0s (immediate)    | 0s              |
| 2       | 1.0s              | 1.0s            |
| 3       | 2.0s              | 3.0s            |
| FAIL    | -                 | 3.0s total      |

### Retryable Exceptions (Python)
- `ConnectionError` (ChromaDB, Ollama)
- `TimeoutError` (LLM calls)
- `httpx.ConnectError` (HTTP clients)
- `httpx.ReadTimeout` (HTTP timeouts)

### Non-Retryable Exceptions
- `ValidationError` (data quality issues)
- `AuthenticationError` (invalid API keys)
- `PermissionError` (file system access)
- `ValueError` (invalid arguments)

### Implementation
```python
from app.core.retry import with_retry

@with_retry(max_retries=3, base_delay=1.0)
def critical_operation():
    # Operation that may fail transiently
    pass
```

---

## 🗺️ Error Code Mapping

### System Errors (SYS_*)

| Code | Technical Cause | Spanish Message | Retryable |
|------|----------------|-----------------|-----------|
| **SYS_001** | ConnectionRefusedError | 🔌 No hay conexión con el servidor local | ✅ Yes |
| **SYS_002** | GPU Out of Memory | 💾 La memoria de tu tarjeta gráfica está llena | ✅ Yes |
| **SYS_RETRY_EXHAUSTED** | Max retries exceeded | ⏱️ La operación falló después de varios intentos | ❌ No |

### Authentication Errors (AUTH_*)

| Code | Technical Cause | Spanish Message | Retryable |
|------|----------------|-----------------|-----------|
| **AUTH_001** | Missing Groq API Key | 🔑 Falta la clave de API de Groq Cloud | ❌ No |

### RAG Errors (RAG_*)

| Code | Technical Cause | Spanish Message | Retryable |
|------|----------------|-----------------|-----------|
| **RAG_001** | VectorStore Empty | 📚 La base de conocimiento está vacía | ✅ Yes (after ingestion) |
| **RAG_002** | Context Window Exceeded | 💬 La conversación es demasiado larga | ❌ No |

### Validation Errors (VAL_*)

| Code | Technical Cause | Spanish Message | Retryable |
|------|----------------|-----------------|-----------|
| **VAL_001** | Length < 50 chars | 📝 El documento generado es inválido (muy corto) | ✅ Yes (regenerate) |
| **VAL_002** | Malformed Markdown | 📝 El documento tiene formato Markdown incorrecto | ✅ Yes (regenerate) |
| **VAL_003** | Invalid UTF-8 | 📝 El documento tiene problemas de codificación | ❌ No (bug) |
| **VAL_004** | XSS Pattern Detected | ⚠️ El documento contiene contenido sospechoso | ❌ No (security) |
| **VAL_005** | Size > 5MB | 📦 El documento es demasiado grande | ❌ No |

---

## 📚 Implementation References

### Backend Files
- `src/server/app/services/validators/document_validator.py` - Validation gates implementation
- `src/server/app/core/retry.py` - Retry decorator with exponential backoff
- `src/server/app/core/exceptions.py` - Custom exception classes

### Frontend Files
- `src/client/lib/core/error_handling/error_mapper.dart` - Error code to Spanish mapping
- `src/client/lib/core/error_handling/snackbar_service.dart` - UX notification service

### Tests
- `tests/python/unit/services/validators/test_document_validator.py` - Validation tests
- `tests/python/unit/core/test_retry.py` - Retry logic tests
- `tests/test/unit/core/error_handling/error_mapper_test.dart` - Frontend mapping tests

---

## 🔒 Security Considerations

### OWASP Compliance
1. **No Stack Traces in UI:** Users never see Python/Dart stack traces
2. **No Sensitive Data in Logs:** API keys, tokens, user content excluded
3. **XSS Prevention:** All user-generated content validated before storage
4. **Input Sanitization:** All inputs validated at boundary (API gateway)

### Privacy
- **Local-First:** All validation happens locally, no data sent to cloud
- **Audit Trail:** All validation failures logged with timestamp, no PII
- **Error Context:** Error codes provide enough info for debugging without exposing internals

---

**Last Updated:** 09/02/2026
**Approved By:** ArchitectZero
**Version:** 1.0.0
