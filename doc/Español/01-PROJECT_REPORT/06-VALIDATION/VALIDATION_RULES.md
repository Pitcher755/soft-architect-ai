# 📋 Validation Rules Specification

> **Fecha:** 09/02/2026
> **HU:** HU-3.4 - Error Handling & Validation Gates
> **Estado:** ✅ ACTIVE

---

## 📖 Tabla de Contenidos

1. [Documento Content Validation](#documento-content-validation)
2. [Retry Rules](#retry-rules)
3. [Error Code Mapping](#error-code-mapping)
4. [Implementación References](#implementación-references)

---

## 🔍 Documento Content Validation

### VAL_001: Minimum Length
- **Rule:** Documento content must be at least 50 characters
- **Rationale:** Prevent incomplete/corrupted generation
- **Error Message (ES):** "El documentoo debe tener al menos 50 caracteres"
- **User Action:** Regenerate documento
- **Implementación:** `DocumentoValidator.validate_content()`

### VAL_002: Valid Markdown Structure
- **Rule:** Markdown syntax must be well-formed
- **Checks:**
  - Brackets balanced: `[` count == `]` count
  - Parentheses balanced: `(` count == `)` count
  - No unclosed code blocks (```)
- **Error Message (ES):** "El documentoo contiene Markdown mal formado"
- **User Action:** Review structure, regenerate
- **Implementación:** `DocumentoValidator.validate_markdown()`

### VAL_003: UTF-8 Encoding
- **Rule:** Content must be valid UTF-8
- **Rationale:** Prevent encoding corruption in ChromaDB
- **Error Message (ES):** "El documentoo no está codificado en UTF-8"
- **User Action:** Internal fix, report if persistent
- **Implementación:** `DocumentoValidator.validate_encoding()`

### VAL_004: No Malicious Code (XSS Prevention)
- **Rule:** Content must not contain XSS patterns
- **Blocked Patterns:**
  - `<script.*?>.*?</script>` (script tags)
  - `javascript:` (javascript protocol)
  - `onerror\s*=` (onerror handlers)
  - `onload\s*=` (onload handlers)
- **Error Message (ES):** "El documentoo contiene código potencialmente malicioso"
- **User Action:** Contact support
- **Implementación:** `DocumentoValidator.validate_safety()`

### VAL_005: Maximum Size
- **Rule:** Documento must be < 5MB
- **Rationale:** Prevent memory issues, ChromaDB limits
- **Error Message (ES):** "El documentoo excede el tamaño máximo de 5MB"
- **User Action:** Reduce documento size
- **Implementación:** `DocumentoValidator.validate_size()`

---

## 🔄 Retry Rules

### Configuración
```python
MAX_RETRIES = 3
BASE_DELAY = 1.0  # seconds
BACKOFF_MULTIPLIER = 2.0
MAX_DELAY = 8.0  # seconds
```

### Retry Schedule
| Attempt | Delay Before Retry | Cumulative Time |
|---------|-------------------|-----------------|
| 1       | 0s (inmediata)    | 0s              |
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
- `PermissionError` (archivo system access)
- `ValueError` (invalid arguments)

### Implementación
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
| **VAL_001** | Length < 50 chars | 📝 El documentoo generado es inválido (muy corto) | ✅ Yes (regenerate) |
| **VAL_002** | Malformed Markdown | 📝 El documentoo tiene formato Markdown incorrecto | ✅ Yes (regenerate) |
| **VAL_003** | Invalid UTF-8 | 📝 El documentoo tiene problemas de codificación | ❌ No (bug) |
| **VAL_004** | XSS Pattern Detected | ⚠️ El documentoo contiene contenido sospechoso | ❌ No (security) |
| **VAL_005** | Size > 5MB | 📦 El documentoo es demasiado grande | ❌ No |

---

## 📚 Implementación References

### Backend Archivos
- `src/server/app/services/validators/documento_validator.py` - Validation gates implementación
- `src/server/app/core/retry.py` - Retry decorator with exponential backoff
- `src/server/app/core/exceptions.py` - Custom exception classes

### Frontend Archivos
- `src/client/lib/core/error_handling/error_mapper.dart` - Error code to Spanish mapping
- `src/client/lib/core/error_handling/snackbar_service.dart` - UX notification service

### Pruebas
- `pruebas/python/unit/services/validators/prueba_documento_validator.py` - Validation pruebas
- `pruebas/python/unit/core/prueba_retry.py` - Retry logic pruebas
- `pruebas/prueba/unit/core/error_handling/error_mapper_prueba.dart` - Frontend mapping pruebas

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
