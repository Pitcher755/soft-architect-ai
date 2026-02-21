# 🛡️ Error Handling Developer Guide

> **Target Audience:** Developers working on `soft-architect-ai`
> **Last Updated:** 2025-01-XX
> **Version:** 1.0.0
> **Status:** ✅ Production-Ready

---

## 📖 Table of Contents

1. [Quick Reference](#-quick-reference)
2. [Error Codes Catalog](#-error-codes-catalog)
3. [Validation Gates](#-validation-gates)
4. [Retry Configuration](#-retry-configuration)
5. [Structured Logging](#-structured-logging)
6. [Frontend Integration](#-frontend-integration)
7. [Code Examples](#-code-examples)
8. [Testing Strategy](#-testing-strategy)
9. [Troubleshooting](#-troubleshooting)

---

## 🚀 Quick Reference

### Backend (Python)

```python
# Validation
from app.services.validators.document_validator import DocumentValidator

validator = DocumentValidator()
try:
    validator.validate_all(document_content)
except ValidationError as e:
    logger.error(f"Validation failed: {e.code}")
    raise

# Retry Logic
from app.core.retry import with_retry

@with_retry(max_retries=3, base_delay=1.0)
def risky_operation():
    # Code that may fail transiently
    return result
```

### Frontend (Dart/Flutter)

```dart
// Error Handling
import 'package:soft_architect_ai/core/error_handling/error_mapper.dart';
import 'package:soft_architect_ai/core/error_handling/snackbar_service.dart';

final errorMapper = ErrorMapper();
final snackbarService = SnackbarService();

try {
  await apiCall();
} catch (e) {
  final errorCode = extractErrorCode(e);
  final message = errorMapper.getUserMessage(errorCode);
  snackbarService.showError(context, errorCode, message);
}
```

---

## 📋 Error Codes Catalog

### System Errors (SYS_XXX)

| Error Code | Meaning | Spanish Message | User Action | Retryable | Status Code |
|------------|---------|-----------------|-------------|-----------|-------------|
| **SYS_001** | Server unreachable | 🔌 No hay conexión con el servidor local | Verifica que Docker esté ejecutándose | ✅ Yes | 503 |
| **SYS_002** | Out of GPU memory | 💾 La memoria de tu tarjeta gráfica está llena | Cierra otros programas o cambia a modo Cloud | ✅ Yes | 507 |
| **SYS_RETRY_EXHAUSTED** | Max retries exceeded | ⏱️ La operación falló después de varios intentos | Intenta nuevamente en unos momentos | ✅ Yes | 503 |

### Authentication Errors (AUTH_XXX)

| Error Code | Meaning | Spanish Message | User Action | Retryable | Status Code |
|------------|---------|-----------------|-------------|-----------|-------------|
| **AUTH_001** | Missing API key | 🔑 Falta la clave de API de Groq Cloud | Ve a Configuration y agrega tu clave de API | ❌ No | 401 |

### RAG Errors (RAG_XXX)

| Error Code | Meaning | Spanish Message | User Action | Retryable | Status Code |
|------------|---------|-----------------|-------------|-----------|-------------|
| **RAG_001** | Empty knowledge base | 📚 La base de conocimiento está vacía | Ejecuta "Cargar Base de Conocimiento" | ✅ Yes | 404 |
| **RAG_002** | Context too long | 💬 La conversación es demasiado larga | Inicia una nueva conversación | ❌ No | 413 |

### Validation Errors (VAL_XXX)

| Error Code | Gate | Spanish Message | User Action | Retryable | Status Code |
|------------|------|-----------------|-------------|-----------|-------------|
| **VAL_001** | Content Length | 📝 El document generado es inválido (muy corto) | Intenta generar el document nuevamente | ✅ Yes | 400 |
| **VAL_002** | Markdown Format | 📝 El document tiene formato Markdown incorrecto | Revisa la estructura del document | ✅ Yes | 400 |
| **VAL_003** | UTF-8 Encoding | 📝 El document tiene problemas de codificación | Asegúrate de usar texto en UTF-8 | ❌ No | 400 |
| **VAL_004** | XSS Security | ⚠️ El document contiene contenido sospechoso | Contacta al soporte si el problema persiste | ❌ No | 400 |
| **VAL_005** | File Size | 📦 El document es demasiado grande | Reduce el tamaño del document | ❌ No | 400 |

---

## 🔒 Validation Gates

All documents **MUST** pass these 5 validation gates before being stored:

### 1. VAL_001: Content Length Validation

**Rule:** Content must be at least 50 characters
**Why:** Prevents empty or meaningless responses from being stored
**Exception:** User-created placeholder documents (skip validation)

```python
MIN_CONTENT_LENGTH: Final[int] = 50

def validate_content(self, content: str) -> bool:
    if len(content) < MIN_CONTENT_LENGTH:
        raise ValidationError(
            code="VAL_001",
            message=f"Content too short ({len(content)} chars, min {MIN_CONTENT_LENGTH})",
            operation="validate_content",
        )
    return True
```

### 2. VAL_002: Markdown Format Validation

**Rule:** Valid Markdown structure (headings, links, lists)
**Why:** Ensures documents render correctly in UI
**Check:** Detects common errors (unmatched brackets, malformed links)

```python
def validate_markdown(self, content: str) -> bool:
    # Check for unmatched brackets
    if content.count("[") != content.count("]"):
        raise ValidationError(code="VAL_002", ...)
    # Additional checks for links, code blocks, etc.
```

### 3. VAL_003: UTF-8 Encoding Validation

**Rule:** Content must be valid UTF-8
**Why:** Prevents encoding errors in ChromaDB/SQLite
**Check:** Attempts to encode/decode as UTF-8

```python
def validate_encoding(self, content: str | bytes) -> bool:
    try:
        if isinstance(content, bytes):
            content.decode("utf-8")
        else:
            content.encode("utf-8")
    except UnicodeDecodeError:
        raise ValidationError(code="VAL_003", ...)
```

### 4. VAL_004: XSS Security Validation

**Rule:** No malicious patterns (scripts, iframes, `javascript:`)
**Why:** Protects users from XSS attacks in documents
**Patterns:** `<script>`, `<iframe>`, `javascript:`, `onerror=`, `onload=`

```python
XSS_PATTERNS: Final[list[str]] = [
    r"<script[^>]*>.*?</script>",
    r"javascript:",
    r"<iframe[^>]*>",
    r"onerror\s*=",
]

def validate_safety(self, content: str) -> bool:
    for pattern in self._XSS_PATTERNS_COMPILED:
        if pattern.search(content):
            raise ValidationError(code="VAL_004", ...)
```

### 5. VAL_005: File Size Validation

**Rule:** Content size must be < 5MB
**Why:** Prevents database bloat and performance degradation
**Check:** UTF-8 encoded byte size

```python
MAX_SIZE_BYTES: Final[int] = 5 * 1024 * 1024  # 5MB

def validate_size(self, content: str) -> bool:
    size = len(content.encode("utf-8"))
    if size > MAX_SIZE_BYTES:
        raise ValidationError(code="VAL_005", ...)
```

---

## 🔄 Retry Configuration

### Default Configuration

```python
max_retries = 3
base_delay = 1.0  # seconds
backoff_multiplier = 2.0

# Retry delays: 1s, 2s, 4s (total wait: 7s)
```

### Usage

```python
from app.core.retry import with_retry

@with_retry(max_retries=3, base_delay=1.0)
def call_external_service():
    # This function will retry up to 3 times
    # with exponential backoff (1s, 2s, 4s)
    response = requests.get("http://external-api.com")
    return response.json()
```

### Retryable Exceptions

The decorator automatically retries on these exceptions:
- `ConnectionError` (network issues)
- `TimeoutError` (slow responses)
- `Exception` (generic failures, use sparingly)

### When NOT to Retry

- **Validation errors** (VAL_XXX) → User must fix input
- **Authentication errors** (AUTH_XXX) → User must provide credentials
- **Not Found errors** (404) → Resource doesn't exist

---

## 📊 Structured Logging

### Configuration

```python
from app.core.logging_config import setup_logging

setup_logging(level=logging.INFO)
```

### Output Format (JSON)

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

### Context Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `operation` | `str` | Function being retried | `"query_rag"` |
| `attempt` | `int` | Retry attempt number | `2` |
| `max_retries` | `int` | Maximum retries allowed | `3` |
| `delay_seconds` | `float` | Wait time before next retry | `2.0` |
| `error` | `str` | Exception message | `"Connection refused"` |
| `error_code` | `str` | Custom error code | `"VAL_001"` |
| `user_id` | `str` (optional) | User identifier | `"user_12345"` |

### Logging Best Practices

```python
# ✅ CORRECT: Use structured logging with extra fields
logger.warning(
    "⚠️ Retry attempt failed",
    extra={
        "operation": func_name,
        "attempt": attempt + 1,
        "delay_seconds": delay,
        "error": str(e),
    },
)

# ❌ WRONG: Embed context in message
logger.warning(f"Retry {attempt+1} failed for {func_name} with error {e}")
```

---

## 🎨 Frontend Integration

### Error Mapper Usage

```dart
import 'package:soft_architect_ai/core/error_handling/error_mapper.dart';

final errorMapper = ErrorMapper();

// Get user-friendly message
final message = errorMapper.getUserMessage('VAL_001');
// Returns: "📝 El documento generado es inválido (muy corto)"

// Get actionable suggestion
final suggestion = errorMapper.getSuggestion('VAL_001');
// Returns: "Intenta generar el documento nuevamente"

// Check if retryable
final canRetry = errorMapper.isRetryable('VAL_001');
// Returns: true
```

### Snackbar Service

```dart
import 'package:soft_architect_ai/core/error_handling/snackbar_service.dart';

final snackbarService = SnackbarService();

// Success notification (auto-hides in 5s)
snackbarService.showSuccess(context, '✅ Documento guardado');

// Info notification (auto-hides in 5s)
snackbarService.showInfo(context, 'ℹ️ Procesando...');

// Warning notification (auto-hides in 5s)
snackbarService.showWarning(context, '⚠️ Conexión inestable');

// Error notification (manual close only)
snackbarService.showError(context, 'VAL_001', '📝 El documento es inválido');
```

### Error Context Model

```dart
import 'package:soft_architect_ai/core/error_handling/error_context.dart';

// Create error context for logging
final errorContext = ErrorContext.fromErrorCode(
  'VAL_001',
  metadata: {'document_length': 35, 'min_length': 50},
);

// Convert to JSON for analytics
final jsonData = errorContext.toJson();
// {
//   "errorCode": "VAL_001",
//   "message": "📝 El documento generado es inválido...",
//   "suggestion": "Intenta generar el documento nuevamente",
//   "isRetryable": true,
//   "timestamp": "2025-01-15T10:30:45.123Z",
//   "metadata": {"document_length": 35, "min_length": 50}
// }
```

---

## 💻 Code Examples

### Example 1: Validate Document Before Storage

```python
from app.services.validators.document_validator import DocumentValidator
from app.core.exceptions import ValidationError

validator = DocumentValidator()

try:
    # Run all 5 validation gates
    validator.validate_all(document_content)

    # All validations passed, safe to store
    store_in_database(document_content)

    logger.info("✅ Document validated and stored successfully")

except ValidationError as e:
    # Specific validation error
    logger.error(
        f"❌ Validation failed: {e.message}",
        extra={"error_code": e.code, "operation": e.operation},
    )
    raise
except Exception as e:
    # Unexpected error
    logger.error(f"❌ Unexpected error during validation: {e}")
    raise
```

### Example 2: Retry with Fallback

```python
from app.core.retry import with_retry
from app.core.exceptions import RetryExhaustedError

@with_retry(max_retries=3, base_delay=1.0)
def fetch_from_primary():
    return requests.get("http://primary-api.com").json()

try:
    data = fetch_from_primary()
except RetryExhaustedError:
    logger.warning("⚠️ Primary API failed, using fallback")
    data = fetch_from_fallback()
```

### Example 3: Frontend Error Flow

```dart
Future<void> generateDocument(BuildContext context) async {
  final errorMapper = ErrorMapper();
  final snackbarService = SnackbarService();

  try {
    final response = await apiClient.post('/generate');
    snackbarService.showSuccess(context, '✅ Documento generado');

  } on ApiException catch (e) {
    final errorCode = e.code;
    final message = errorMapper.getUserMessage(errorCode);
    final suggestion = errorMapper.getSuggestion(errorCode);

    // Show error in UI
    snackbarService.showError(context, errorCode, message);

    // Log for analytics
    final errorContext = ErrorContext.fromErrorCode(errorCode);
    logger.error('API error', extra: errorContext.toJson());

    // Offer retry button if retryable
    if (errorMapper.isRetryable(errorCode)) {
      showRetryDialog(context, onRetry: () => generateDocument(context));
    }
  }
}
```

---

## 🧪 Testing Strategy

### Backend Tests

```bash
# Run all validation tests
pytest tests/python/unit/services/validators/test_document_validator.py -v

# Run retry tests
pytest tests/python/unit/core/test_retry.py -v

# Run integration tests
pytest tests/python/integration/test_error_handling_flow.py -v
```

### Frontend Tests

```bash
# Run error mapper tests
flutter test tests/test/unit/core/error_handling/error_mapper_test.dart

# Run snackbar tests
flutter test tests/test/unit/core/error_handling/snackbar_service_test.dart

# Run integration tests
flutter test tests/test/integration/features/chat/error_handling_flow_test.dart
```

### Coverage Requirements

- **Domain Logic:** >90% coverage (validation, retry)
- **Data Layer:** >80% coverage (repositories)
- **Presentation Layer:** >70% coverage (UI)
- **Integration Tests:** At least 5 E2E scenarios

---

## 🔧 Troubleshooting

### Issue: ValidationError not caught by API handler

**Symptom:** 500 error instead of 400
**Cause:** Exception not registered in FastAPI error handlers
**Fix:** Add to `api/v1/router.py`:

```python
@app.exception_handler(ValidationError)
async def validation_exception_handler(request, exc: ValidationError):
    return JSONResponse(
        status_code=exc.status_code,
        content={"error_code": exc.code, "message": exc.message},
    )
```

### Issue: Snackbar not appearing in tests

**Symptom:** `expect(find.text(...), findsNothing)`
**Cause:** `showSnackBar()` called during build phase
**Fix:** Use `WidgetsBinding.addPostFrameCallback()`:

```dart
WidgetsBinding.instance.addPostFrameCallback((_) {
  snackbarService.showError(context, errorCode, message);
});
```

### Issue: Retry not logging properly

**Symptom:** Missing context fields in logs
**Cause:** Old logging format used
**Fix:** Use structured logging with `extra`:

```python
logger.warning("Retry failed", extra={
    "operation": func_name,
    "attempt": attempt + 1,
})
```

---

## 📚 Related Documentation

- [ERROR_HANDLING_STANDARD.md](../../context/30-ARCHITECTURE/ERROR_HANDLING_STANDARD.md) - Complete error handling architecture
- [VALIDATION_RULES.md](../03-HU-TRACKING/HU-3.4_ERROR_HANDLING_GATES/VALIDATION_RULES.md) - Detailed validation specifications
- [SECURITY_HARDENING_POLICY.md](../../context/SECURITY_HARDENING_POLICY.en.md) - Security best practices

---

**💡 Pro Tips:**

1. **Always log error codes** → Makes debugging easier
2. **Use retry sparingly** → Only for transient failures
3. **Test error flows** → Don't just test happy paths
4. **Keep messages user-friendly** → Avoid technical jargon
5. **Never expose stack traces** → Users don't need to see Python internals

---

**Last Updated:** 2025-01-XX | **Maintained by:** ArchitectZero | **Version:** 1.0.0
