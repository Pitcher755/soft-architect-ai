# 🚨 Error Handling Standard

> **Philosophy:** "Fail Gracefully". The user should never see a Python Stack Trace in the Flutter UI.

---

## 1. Error Catalog (Error Codes)

The Backend must return these codes in the `error_code` field of the JSON response.

| Code | Technical Description | User Message (Flutter UI) | Suggested Action | Retryable | Status |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **SYS_001** | `ConnectionRefusedError` (DB/Ollama) | "I can't connect to the local brain." | Check Docker. | ✅ Yes | 503 |
| **SYS_002** | `GPU_OOM` (Out of Memory) | "Your graphics card is full." | Close other programs or switch to Cloud mode. | ✅ Yes | 507 |
| **SYS_RETRY_EXHAUSTED** | Max retries exceeded | "Operation failed after multiple attempts." | Try again later. | ✅ Yes | 503 |
| **AUTH_001** | `GroqAPIKeyMissing` | "Groq Cloud key is missing." | Go to Settings and add API Key. | ❌ No | 401 |
| **RAG_001** | `VectorStoreEmpty` | "The knowledge base is empty." | Run "Ingest Knowledge". | ✅ Yes | 404 |
| **RAG_002** | `ContextWindowExceeded` | "Conversation too long." | Start a new chat. | ❌ No | 413 |
| **VAL_001** | Document too short (<50 chars) | "Generated document is invalid (too short)." | Regenerate document. | ✅ Yes | 400 |
| **VAL_002** | Malformed Markdown structure | "Document has incorrect Markdown format." | Review document structure. | ✅ Yes | 400 |
| **VAL_003** | Invalid UTF-8 encoding | "Document has encoding issues." | Ensure UTF-8 text. | ❌ No | 400 |
| **VAL_004** | XSS patterns detected | "Document contains suspicious content." | Contact support. | ❌ No | 400 |
| **VAL_005** | File size exceeds 5MB | "Document is too large." | Reduce document size. | ❌ No | 400 |

---

## 2. Validation Gates (VAL_XXX)

All documents MUST pass these 5 validation gates before storage:

### Gate 1: VAL_001 - Content Length
- **Rule:** Content ≥ 50 characters
- **Purpose:** Prevent empty responses
- **Implementation:** `MIN_CONTENT_LENGTH = 50`

### Gate 2: VAL_002 - Markdown Format
- **Rule:** Valid Markdown structure
- **Purpose:** Ensure proper rendering
- **Checks:** Balanced brackets, valid links, code blocks

### Gate 3: VAL_003 - UTF-8 Encoding
- **Rule:** Valid UTF-8 encoding
- **Purpose:** Prevent database corruption
- **Implementation:** `content.encode("utf-8")`

### Gate 4: VAL_004 - XSS Security
- **Rule:** No malicious patterns
- **Purpose:** Prevent XSS attacks
- **Patterns:** `<script>`, `javascript:`, `<iframe>`, `onerror=`, `onload=`

### Gate 5: VAL_005 - File Size
- **Rule:** Content size < 5MB
- **Purpose:** Prevent database bloat
- **Implementation:** `MAX_SIZE_BYTES = 5 * 1024 * 1024`

---

## 3. Retry Logic

### Configuration
```python
max_retries = 3
base_delay = 1.0  # seconds
backoff_multiplier = 2.0

# Retry delays: 1s, 2s, 4s (total: 7s)
```

### Usage
```python
from app.core.retry import with_retry

@with_retry(max_retries=3, base_delay=1.0)
def risky_operation():
    # Code that may fail transiently
    return result
```

### Retryable Errors
- **System errors** (SYS_XXX) → Infrastructure issues
- **RAG errors** (RAG_001) → Empty knowledge base
- **Validation errors** (VAL_001, VAL_002) → Regeneratable content

### Non-Retryable Errors
- **Authentication** (AUTH_XXX) → User must provide credentials
- **Security** (VAL_004) → Malicious content
- **Size limits** (VAL_005) → Document too large

---

## 4. Backend Implementation (Python)

Use a global `ExceptionHandler` in FastAPI.

```python
# src/server/core/exceptions.py
from fastapi.responses import JSONResponse

async def global_exception_handler(request, exc):
    if isinstance(exc, OutOfMemoryError):
        return JSONResponse(
            status_code=503,
            content={
                "status": "error",
                "code": "SYS_002",
                "message": "VRAM Exhausted"
            }
        )

```

---

## 3. Frontend Implementation (Flutter)

Map codes to user-friendly error widgets.

```dart
// src/client/lib/core/error_mapper.dart
String getUserMessage(String errorCode) {
  switch (errorCode) {
    case 'SYS_001':
      return '🔌 It seems Docker is not running. Check your terminal.';
    case 'AUTH_001':
      return '🔑 You need an API Key to use Cloud mode.';
    default:
      return '🤔 Something went wrong ($errorCode).';
  }
}

```

---

## 5. Structured Logging

All logs MUST use JSON format with context fields for audit trail:

```python
from app.core.logging_config import setup_logging

setup_logging(level=logging.INFO)

logger.info("✅ Operation successful", extra={
    "operation": "validate_document",
    "document_id": doc_id,
    "validation_gates_passed": 5,
})

logger.warning("⚠️ Retry attempt failed", extra={
    "operation": "query_rag",
    "attempt": 2,
    "delay_seconds": 2.0,
    "error": "Connection refused",
})
```

### Log Output Format
```json
{
  "timestamp": "2025-01-15T10:30:45.123Z",
  "level": "WARNING",
  "logger": "app.core.retry",
  "message": "⚠️ Retry attempt failed",
  "operation": "query_rag",
  "attempt": 2,
  "delay_seconds": 2.0,
  "error": "Connection refused"
}
```

### Security Rules
- **NEVER log sensitive data:** API keys, passwords, user data
- **ALWAYS log error codes:** For debugging and analytics
- **Use `extra` fields:** For structured context (not string interpolation)

---

## 6. Logging and Telemetry

* **User Level:** Only show the friendly message and a red/yellow icon.
* **Dev Level (Debug):** Save the full stack trace in `app.log` (local) or Docker console.
