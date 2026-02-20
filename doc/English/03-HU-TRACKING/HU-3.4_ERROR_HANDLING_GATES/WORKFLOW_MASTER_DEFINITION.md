# 🏗️ MASTER WORKFLOW: HU-3.4 - Error Handling & Validation Gates

> **Date:** 09/02/2026
> **Branch:** `feature/error-handling-gates`
> **Epic:** E3 - Frontend UX & Robustness
> **Priority:** 🔥 **HIGH**
> **Methodology:** Strict TDD (Red → Green → Refactor)
> **Risk Level:** HIGH (Critical path for production readiness)

---

## 📖 Table of Contents

1. [Strategic Objectives](#strategic-objectives)
2. [Acceptance Criteria (Definition of Done)](#acceptance-criteria-definition-of-done)
3. [Architecture and Dependencies](#architecture-and-dependencies)
4. [Phase 0: Groundwork Preparation](#phase-0-groundwork-preparation)
5. [Phase 1: TDD - RED (Failing Tests)](#phase-1-tdd---red-failing-tests)
6. [Phase 2: TDD - GREEN (Implementation)](#phase-2-tdd---green-implementation)
7. [Phase 3: TDD - REFACTOR (Improvements and Robustness)](#phase-3-tdd---refactor-improvements-and-robustness)
8. [Phase 4: Integration Testing (E2E)](#phase-4-integration-testing-e2e)
9. [Phase 5: Documentation and Validation](#phase-5-documentation-and-validation)
10. [Phase 6: CI/CD and Pipeline](#phase-6-cicd-and-pipeline)
11. [Final Deliverables](#final-deliverables)

---

## 🎯 Strategic Objectives

### 1. **Validation Gates (Data Quality Assurance)**
- Implement validators for **document content** (minimum length, structure, encoding).
- Reject invalid documents **before** storage with specific error codes (`VAL_001`, `VAL_002`, `VAL_003`).
- Prevent corrupted data from entering ChromaDB or SQLite.
- **Fulfills:** Data integrity, quality assurance.

### 2. **Retry Logic with Exponential Backoff**
- Implement `@with_retry` decorator for critical operations (ChromaDB queries, LLM calls).
- **Max 3 retries** with exponential backoff (1s, 2s, 4s).
- Log each retry attempt with context (operation, attempt number, delay).
- **Fulfills:** Resilience, transient failure recovery.

### 3. **Fallback & Rollback Logic**
- If document generation fails after 3 retries → rollback to last valid state.
- Provide user with **"Restore Previous Version"** option.
- Store document history (max 5 versions) in SQLite for rollback capability.
- **Fulfills:** User safety, data recovery.

### 4. **UX-Optimized Notifications**
- **Success/Info Snackbars:** Auto-hide after 5 seconds.
- **Error Snackbars:** Require manual dismissal (no auto-hide).
- **Actionable Errors:** Include retry button directly in notification.
- **Localized Messages:** All messages in Spanish (es-ES).
- **Fulfills:** Optimistic UI, user empowerment.

### 5. **Comprehensive Error Logging**
- Log all errors with context: `operation`, `timestamp`, `user_id`, `error_code`.
- **Never log sensitive data** (API keys, file contents).
- Store logs in `app.log` (local) and Docker console.
- **Fulfills:** Debugging, audit trail, OWASP compliance.

### 6. **Error Code Mapping (User-Friendly)**
- Map technical errors to Spanish messages:
  - `SYS_001` → "No hay conexión con el servidor local"
  - `VAL_001` → "El document generado es inválido"
  - `RAG_001` → "La base de conocimiento está vacía"
- **No stack traces** visible to users (only in logs).
- **Fulfills:** User experience, privacy.

---

## ✅ Acceptance Criteria (Definition of Done)

### POSITIVE Criteria (Must Have)
- ✅ **Validation Gates:** Documents are validated for length (>50 chars), structure (valid Markdown), encoding (UTF-8).
- ✅ **Retry Logic:** Failed operations retry automatically (max 3x with exponential backoff).
- ✅ **Fallback:** If generation fails, user can restore previous document version.
- ✅ **Snackbar UX:** Success/info auto-hide in 5s, errors require manual close.
- ✅ **Error Logging:** All errors logged with context (no sensitive data exposed).
- ✅ **Localized Errors:** All error messages in Spanish, no technical jargon.
- ✅ **Test Coverage:** >90% on validation gates and retry logic.
- ✅ **Integration:** Works seamlessly with HU-3.3 (Chat Sequential Docs).

### NEGATIVE Criteria (Must NOT)
- ❌ **No Stack Traces:** Users never see Python/Dart stack traces.
- ❌ **No Hardcoded Messages:** All messages come from centralized error catalog.
- ❌ **No Sensitive Data in Logs:** API keys, user data excluded from logs.
- ❌ **No Auto-Hide for Errors:** Critical errors require user acknowledgment.
- ❌ **No Retry Loops:** After 3 retries, gracefully fail with actionable message.

---

## 🏗️ Architecture and Dependencies

```
┌─────────────────────────────────────────────────────────────────┐
│                      LAYER STRUCTURE                             │
├─────────────────────────────────────────────────────────────────┤
│ PRESENTATION LAYER (Flutter)                                    │
│   ├─ lib/core/error_handling/error_mapper.dart                  │
│   ├─ lib/core/error_handling/snackbar_service.dart              │
│   └─ lib/features/chat/presentation/notifiers/chat_notifier.dart│
├─────────────────────────────────────────────────────────────────┤
│ APPLICATION LAYER (Backend Services)                            │
│   ├─ src/server/app/services/validators/gates.py                │
│   ├─ src/server/app/services/validators/document_validator.py   │
│   ├─ src/server/app/core/retry.py (@with_retry decorator)       │
│   └─ src/server/app/services/rag/sequential_orchestrator.py     │
├─────────────────────────────────────────────────────────────────┤
│ DOMAIN LAYER (Core Exceptions)                                  │
│   ├─ src/server/app/core/exceptions.py (ValidationError)        │
│   └─ lib/core/exceptions/validation_exception.dart              │
├─────────────────────────────────────────────────────────────────┤
│ DATA LAYER (Persistence)                                        │
│   ├─ SQLite: document_versions table (rollback capability)      │
│   └─ Logs: app.log (structured JSON logging)                    │
├─────────────────────────────────────────────────────────────────┤
│ CONFIGURATION                                                   │
│   ├─ context/30-ARCHITECTURE/ERROR_HANDLING_STANDARD.md         │
│   └─ src/server/app/core/config.py (retry settings)             │
└─────────────────────────────────────────────────────────────────┘
```

### Dependencies (Blocked By)
- **HU-3.3:** Chat Sequential Docs (must be merged first)
- **ERROR_HANDLING_STANDARD.md:** Must exist in context/30-ARCHITECTURE/

### Blocks (Downstream)
- **HU-3.5:** Streaming Optimization (requires robust error handling)

---

## 🔧 Phase 0: Groundwork Preparation

**Objective:** Analyze existing error handling, define validation rules, and prepare test infrastructure.

### 0.1 Documentation Audit
```bash
# Read existing error handling docs
cat context/30-ARCHITECTURE/ERROR_HANDLING_STANDARD.en.md
cat context/30-ARCHITECTURE/ERROR_HANDLING_STANDARD.es.md

# Analyze current exception handling
rg "raise.*Error" src/server/app/ -A 2
rg "Exception" src/client/lib/ -A 2
```

**Deliverable:** Inventory of existing errors and gaps.

### 0.2 Define Validation Rules
Create validation specification document:

**File:** `doc/03-HU-TRACKING/HU-3.4_ERROR_HANDLING_GATES/VALIDATION_RULES.md`

```markdown
# Validation Rules Specification

## Document Content Validation
1. **VAL_001:** Minimum Length (>50 chars)
2. **VAL_002:** Valid Markdown Structure
3. **VAL_003:** UTF-8 Encoding
4. **VAL_004:** No Malicious Code (XSS patterns)
5. **VAL_005:** Maximum Size (<5MB)

## Retry Rules
1. Max retries: 3
2. Base delay: 1.0s
3. Backoff multiplier: 2.0x
4. Max delay: 8.0s
```

### 0.3 Setup Test Infrastructure
```bash
# Create test directories
mkdir -p tests/python/unit/services/validators
mkdir -p tests/test/unit/core/error_handling

# Add test fixtures
touch tests/python/fixtures/invalid_documents.json
touch tests/python/fixtures/valid_documents.json
```

**Checklist Phase 0:**
- [ ] ERROR_HANDLING_STANDARD.md reviewed
- [ ] VALIDATION_RULES.md created
- [ ] Test directories created
- [ ] Fixtures prepared

---

## 🔴 Phase 1: TDD - RED (Failing Tests)

**Objective:** Write comprehensive tests that FAIL (no implementation yet).

### 1.1 Backend: Validation Gates Tests

**File:** `tests/python/unit/services/validators/test_document_validator.py`

```python
import pytest
from app.services.validators.document_validator import DocumentValidator
from app.core.exceptions import ValidationError


class TestDocumentValidator:
    """Test suite for document validation gates."""

    def test_validate_minimum_length_fails_with_short_content(self):
        """VAL_001: Should reject documents shorter than 50 chars."""
        validator = DocumentValidator()
        short_content = "Too short"

        with pytest.raises(ValidationError) as exc_info:
            validator.validate_content(short_content)

        assert exc_info.value.code == "VAL_001"
        assert "mínimo 50 caracteres" in exc_info.value.message

    def test_validate_markdown_structure_fails_with_invalid_markdown(self):
        """VAL_002: Should reject documents with broken Markdown."""
        validator = DocumentValidator()
        invalid_md = "# Unclosed header [link](broken"

        with pytest.raises(ValidationError) as exc_info:
            validator.validate_markdown(invalid_md)

        assert exc_info.value.code == "VAL_002"

    def test_validate_encoding_fails_with_non_utf8(self):
        """VAL_003: Should reject non-UTF-8 encoded content."""
        validator = DocumentValidator()
        # Simulate Latin-1 encoding error
        invalid_bytes = b"\xff\xfe Invalid UTF-8"

        with pytest.raises(ValidationError) as exc_info:
            validator.validate_encoding(invalid_bytes)

        assert exc_info.value.code == "VAL_003"

    def test_validate_xss_patterns_fails_with_malicious_code(self):
        """VAL_004: Should detect and reject XSS patterns."""
        validator = DocumentValidator()
        malicious_content = "<script>alert('XSS')</script>"

        with pytest.raises(ValidationError) as exc_info:
            validator.validate_safety(malicious_content)

        assert exc_info.value.code == "VAL_004"

    def test_validate_size_fails_with_oversized_content(self):
        """VAL_005: Should reject documents larger than 5MB."""
        validator = DocumentValidator()
        huge_content = "x" * (5 * 1024 * 1024 + 1)  # 5MB + 1 byte

        with pytest.raises(ValidationError) as exc_info:
            validator.validate_size(huge_content)

        assert exc_info.value.code == "VAL_005"

    def test_validate_all_passes_with_valid_document(self):
        """Should pass validation with valid content."""
        validator = DocumentValidator()
        valid_content = "# Valid Document\n\nThis is a valid Markdown document with sufficient length."

        result = validator.validate_all(valid_content)

        assert result is True
```

**Expected Result:** ❌ All tests FAIL (classes/methods don't exist yet).

### 1.2 Backend: Retry Logic Tests

**File:** `tests/python/unit/core/test_retry.py`

```python
import pytest
from unittest.mock import Mock, patch
from app.core.retry import with_retry
from app.core.exceptions import RetryExhaustedError


class TestRetryDecorator:
    """Test suite for @with_retry decorator."""

    def test_retry_succeeds_on_first_attempt(self):
        """Should execute successfully without retries."""
        mock_func = Mock(return_value="success")
        decorated = with_retry(max_retries=3)(mock_func)

        result = decorated()

        assert result == "success"
        assert mock_func.call_count == 1

    def test_retry_succeeds_on_second_attempt(self):
        """Should retry once and succeed."""
        mock_func = Mock(side_effect=[ConnectionError(), "success"])
        decorated = with_retry(max_retries=3, base_delay=0.1)(mock_func)

        result = decorated()

        assert result == "success"
        assert mock_func.call_count == 2

    def test_retry_exhausted_after_max_attempts(self):
        """Should raise RetryExhaustedError after 3 failed attempts."""
        mock_func = Mock(side_effect=ConnectionError("Persistent failure"))
        decorated = with_retry(max_retries=3, base_delay=0.1)(mock_func)

        with pytest.raises(RetryExhaustedError) as exc_info:
            decorated()

        assert mock_func.call_count == 3
        assert "Persistent failure" in str(exc_info.value)

    def test_retry_exponential_backoff_timing(self):
        """Should apply exponential backoff (1s, 2s, 4s)."""
        mock_func = Mock(side_effect=[ConnectionError(), ConnectionError(), "success"])
        decorated = with_retry(max_retries=3, base_delay=1.0)(mock_func)

        with patch('time.sleep') as mock_sleep:
            result = decorated()

            assert result == "success"
            assert mock_sleep.call_count == 2
            mock_sleep.assert_any_call(1.0)  # First retry
            mock_sleep.assert_any_call(2.0)  # Second retry

    def test_retry_logs_each_attempt(self, caplog):
        """Should log each retry attempt with context."""
        mock_func = Mock(side_effect=[ConnectionError(), "success"])
        mock_func.__name__ = "test_operation"
        decorated = with_retry(max_retries=3, base_delay=0.1)(mock_func)

        decorated()

        assert "Retry attempt 1/3 for test_operation" in caplog.text
```

**Expected Result:** ❌ All tests FAIL (`with_retry` doesn't exist yet).

### 1.3 Frontend: Error Mapper Tests

**File:** `tests/test/unit/core/error_handling/error_mapper_test.dart`

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:soft_architect_ai/core/error_handling/error_mapper.dart';

void main() {
  group('ErrorMapper', () {
    late ErrorMapper errorMapper;

    setUp(() {
      errorMapper = ErrorMapper();
    });

    test('should map SYS_001 to Spanish message', () {
      // Arrange
      const errorCode = 'SYS_001';

      // Act
      final message = errorMapper.getUserMessage(errorCode);

      // Assert
      expect(message, contains('servidor local'));
      expect(message, isNot(contains('ConnectionRefusedError')));
    });

    test('should map VAL_001 to Spanish validation message', () {
      // Arrange
      const errorCode = 'VAL_001';

      // Act
      final message = errorMapper.getUserMessage(errorCode);

      // Assert
      expect(message, contains('documento'));
      expect(message, contains('inválido'));
    });

    test('should provide generic message for unknown error code', () {
      // Arrange
      const errorCode = 'UNKNOWN_999';

      // Act
      final message = errorMapper.getUserMessage(errorCode);

      // Assert
      expect(message, contains('error'));
      expect(message, contains(errorCode));
    });

    test('should provide actionable suggestion for each error', () {
      // Arrange
      const errorCode = 'SYS_001';

      // Act
      final suggestion = errorMapper.getSuggestion(errorCode);

      // Assert
      expect(suggestion, contains('Docker'));
    });
  });
}
```

**Expected Result:** ❌ All tests FAIL (ErrorMapper class doesn't exist).

### 1.4 Frontend: Snackbar Service Tests

**File:** `tests/test/unit/core/error_handling/snackbar_service_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soft_architect_ai/core/error_handling/snackbar_service.dart';

void main() {
  group('SnackbarService', () {
    late SnackbarService snackbarService;

    setUp(() {
      snackbarService = SnackbarService();
    });

    testWidgets('should show success snackbar with auto-hide', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                // Act
                snackbarService.showSuccess(context, 'Operation successful');
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      await tester.pump();

      // Assert
      expect(find.text('Operation successful'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);

      // Verify auto-hide after 5 seconds
      await tester.pump(const Duration(seconds: 5));
      await tester.pump();
      expect(find.text('Operation successful'), findsNothing);
    });

    testWidgets('should show error snackbar WITHOUT auto-hide', (tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                // Act
                snackbarService.showError(context, 'Critical error', 'SYS_001');
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      await tester.pump();

      // Assert
      expect(find.text('Critical error'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);

      // Verify NO auto-hide after 5 seconds
      await tester.pump(const Duration(seconds: 5));
      await tester.pump();
      expect(find.text('Critical error'), findsOneWidget); // Still visible
    });

    testWidgets('should show retry button for retryable errors', (tester) async {
      // Arrange
      var retryPressed = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                // Act
                snackbarService.showRetryableError(
                  context,
                  'Connection failed',
                  onRetry: () => retryPressed = true,
                );
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      await tester.pump();

      // Assert
      expect(find.text('Reintentar'), findsOneWidget);

      // Act: Tap retry button
      await tester.tap(find.text('Reintentar'));
      await tester.pump();

      // Assert
      expect(retryPressed, isTrue);
    });
  });
}
```

**Expected Result:** ❌ All tests FAIL (SnackbarService doesn't exist).

### 1.5 Run All RED Tests

```bash
# Backend tests (Python)
cd tests/python && pytest unit/services/validators/ unit/core/ -v

# Frontend tests (Dart)
cd tests && flutter test test/unit/core/error_handling/

# Expected Output: ALL RED (100% failure rate)
```

**Checklist Phase 1:**
- [ ] 5+ backend validation tests written (all failing)
- [ ] 4+ backend retry tests written (all failing)
- [ ] 3+ frontend error mapper tests written (all failing)
- [ ] 3+ frontend snackbar tests written (all failing)
- [ ] All tests documented with docstrings
- [ ] Test coverage target: >90%

---

## 🟢 Phase 2: TDD - GREEN (Implementation)

**Objective:** Implement MINIMUM code to make tests pass (no optimization yet).

### 2.1 Backend: Validation Gates Implementation

**File:** `src/server/app/services/validators/document_validator.py`

```python
"""Document validation gates for content quality assurance."""
import re
from typing import Final

from app.core.exceptions import ValidationError


class DocumentValidator:
    """Validates document content against quality gates."""

    MIN_LENGTH: Final[int] = 50
    MAX_SIZE_BYTES: Final[int] = 5 * 1024 * 1024  # 5MB
    XSS_PATTERNS: Final[list[str]] = [
        r"<script.*?>.*?</script>",
        r"javascript:",
        r"onerror\s*=",
        r"onload\s*=",
    ]

    def validate_content(self, content: str) -> bool:
        """Validate minimum content length (VAL_001)."""
        if len(content) < self.MIN_LENGTH:
            raise ValidationError(
                code="VAL_001",
                message=f"El documento debe tener al menos {self.MIN_LENGTH} caracteres",
                operation="validate_content",
            )
        return True

    def validate_markdown(self, content: str) -> bool:
        """Validate Markdown structure (VAL_002)."""
        # Check for unclosed brackets/parentheses
        if content.count('[') != content.count(']'):
            raise ValidationError(
                code="VAL_002",
                message="El documento contiene Markdown mal formado (corchetes sin cerrar)",
                operation="validate_markdown",
            )
        if content.count('(') != content.count(')'):
            raise ValidationError(
                code="VAL_002",
                message="El documento contiene Markdown mal formado (paréntesis sin cerrar)",
                operation="validate_markdown",
            )
        return True

    def validate_encoding(self, content: bytes) -> bool:
        """Validate UTF-8 encoding (VAL_003)."""
        try:
            content.decode('utf-8')
        except UnicodeDecodeError as e:
            raise ValidationError(
                code="VAL_003",
                message="El documento no está codificado en UTF-8",
                operation="validate_encoding",
            ) from e
        return True

    def validate_safety(self, content: str) -> bool:
        """Validate against XSS patterns (VAL_004)."""
        for pattern in self.XSS_PATTERNS:
            if re.search(pattern, content, re.IGNORECASE):
                raise ValidationError(
                    code="VAL_004",
                    message="El documento contiene código potencialmente malicioso",
                    operation="validate_safety",
                )
        return True

    def validate_size(self, content: str) -> bool:
        """Validate maximum size (VAL_005)."""
        size_bytes = len(content.encode('utf-8'))
        if size_bytes > self.MAX_SIZE_BYTES:
            raise ValidationError(
                code="VAL_005",
                message=f"El documento excede el tamaño máximo de {self.MAX_SIZE_BYTES // 1024 // 1024}MB",
                operation="validate_size",
            )
        return True

    def validate_all(self, content: str) -> bool:
        """Run all validation gates."""
        self.validate_content(content)
        self.validate_markdown(content)
        self.validate_encoding(content.encode('utf-8'))
        self.validate_safety(content)
        self.validate_size(content)
        return True
```

### 2.2 Backend: Retry Decorator Implementation

**File:** `src/server/app/core/retry.py`

```python
"""Retry decorator with exponential backoff for resilient operations."""
import functools
import logging
import time
from typing import Any, Callable, TypeVar

from app.core.exceptions import RetryExhaustedError


logger = logging.getLogger(__name__)

T = TypeVar('T')


def with_retry(
    max_retries: int = 3,
    base_delay: float = 1.0,
    backoff_multiplier: float = 2.0,
    retryable_exceptions: tuple[type[Exception], ...] = (ConnectionError, TimeoutError),
) -> Callable[[Callable[..., T]], Callable[..., T]]:
    """
    Decorator that retries a function on failure with exponential backoff.

    Args:
        max_retries: Maximum number of retry attempts (default: 3)
        base_delay: Initial delay in seconds (default: 1.0)
        backoff_multiplier: Delay multiplier for each retry (default: 2.0)
        retryable_exceptions: Tuple of exception types to catch (default: ConnectionError, TimeoutError)

    Raises:
        RetryExhaustedError: When all retry attempts are exhausted

    Example:
        @with_retry(max_retries=3, base_delay=1.0)
        def query_database():
            return db.query()
    """
    def decorator(func: Callable[..., T]) -> Callable[..., T]:
        @functools.wraps(func)
        def wrapper(*args: Any, **kwargs: Any) -> T:
            last_exception: Exception | None = None

            for attempt in range(max_retries):
                try:
                    result = func(*args, **kwargs)
                    if attempt > 0:
                        logger.info(
                            f"✅ Retry successful for {func.__name__} on attempt {attempt + 1}/{max_retries}"
                        )
                    return result
                except retryable_exceptions as e:
                    last_exception = e
                    if attempt < max_retries - 1:
                        delay = base_delay * (backoff_multiplier ** attempt)
                        logger.warning(
                            f"⚠️ Retry attempt {attempt + 1}/{max_retries} for {func.__name__} "
                            f"failed: {e}. Retrying in {delay}s..."
                        )
                        time.sleep(delay)
                    else:
                        logger.error(
                            f"❌ All {max_retries} retry attempts exhausted for {func.__name__}"
                        )

            raise RetryExhaustedError(
                operation=func.__name__,
                attempts=max_retries,
                last_error=str(last_exception),
            )

        return wrapper
    return decorator
```

### 2.3 Backend: Custom Exceptions

**File:** `src/server/app/core/exceptions.py` (add new exceptions)

```python
# Add to existing file

class ValidationError(BaseAppException):
    """Raised when document validation fails."""

    def __init__(
        self,
        code: str,
        message: str,
        operation: str,
        details: dict[str, Any] | None = None,
    ) -> None:
        super().__init__(
            code=code,
            message=message,
            status_code=400,
            operation=operation,
            details=details or {},
        )


class RetryExhaustedError(BaseAppException):
    """Raised when all retry attempts are exhausted."""

    def __init__(
        self,
        operation: str,
        attempts: int,
        last_error: str,
    ) -> None:
        super().__init__(
            code="SYS_RETRY_EXHAUSTED",
            message=f"Operación fallida después de {attempts} intentos: {last_error}",
            status_code=503,
            operation=operation,
            details={"attempts": attempts, "last_error": last_error},
        )
```

### 2.4 Frontend: Error Mapper Implementation

**File:** `src/client/lib/core/error_handling/error_mapper.dart`

```dart
/// Maps backend error codes to user-friendly Spanish messages.
class ErrorMapper {
  /// Error code to message mapping.
  static const Map<String, String> _messages = {
    // System Errors
    'SYS_001': '🔌 No hay conexión con el servidor local',
    'SYS_002': '💾 La memoria de tu tarjeta gráfica está llena',
    'SYS_RETRY_EXHAUSTED': '⏱️ La operación falló después de varios intentos',

    // Authentication Errors
    'AUTH_001': '🔑 Falta la clave de API de Groq Cloud',

    // RAG Errors
    'RAG_001': '📚 La base de conocimiento está vacía',
    'RAG_002': '💬 La conversación es demasiado larga',

    // Validation Errors
    'VAL_001': '📝 El documento generado es inválido (muy corto)',
    'VAL_002': '📝 El documento tiene formato Markdown incorrecto',
    'VAL_003': '📝 El documento tiene problemas de codificación',
    'VAL_004': '⚠️ El documento contiene contenido sospechoso',
    'VAL_005': '📦 El documento es demasiado grande',
  };

  /// Suggestions for each error code.
  static const Map<String, String> _suggestions = {
    'SYS_001': 'Verifica que Docker esté ejecutándose',
    'SYS_002': 'Cierra otros programas o cambia a modo Cloud',
    'AUTH_001': 'Ve a Configuración y agrega tu clave de API',
    'RAG_001': 'Ejecuta "Cargar Base de Conocimiento"',
    'RAG_002': 'Inicia una nueva conversación',
    'VAL_001': 'Intenta generar el documento nuevamente',
    'VAL_002': 'Revisa la estructura del documento',
    'VAL_003': 'Asegúrate de usar texto en UTF-8',
    'VAL_004': 'Contacta al soporte si el problema persiste',
    'VAL_005': 'Reduce el tamaño del documento',
  };

  /// Get user-friendly message for error code.
  String getUserMessage(String errorCode) {
    return _messages[errorCode] ?? '🤔 Ocurrió un error ($errorCode)';
  }

  /// Get actionable suggestion for error code.
  String getSuggestion(String errorCode) {
    return _suggestions[errorCode] ?? 'Intenta nuevamente o contacta al soporte';
  }

  /// Check if error is retryable.
  bool isRetryable(String errorCode) {
    return ['SYS_001', 'SYS_002', 'SYS_RETRY_EXHAUSTED', 'RAG_001'].contains(errorCode);
  }
}
```

### 2.5 Frontend: Snackbar Service Implementation

**File:** `src/client/lib/core/error_handling/snackbar_service.dart`

```dart
import 'package:flutter/material.dart';

/// Service for displaying contextual snackbar notifications.
class SnackbarService {
  /// Show success notification (auto-hide after 5s).
  void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green.shade700,
        duration: const Duration(seconds: 5), // Auto-hide
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show info notification (auto-hide after 5s).
  void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.info, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.blue.shade700,
        duration: const Duration(seconds: 5), // Auto-hide
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Show error notification (manual close required).
  void showError(BuildContext context, String message, String errorCode) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(message, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('Código: $errorCode', style: const TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        duration: const Duration(days: 365), // Never auto-hide
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Cerrar',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  /// Show retryable error with action button.
  void showRetryableError(
    BuildContext context,
    String message, {
    required VoidCallback onRetry,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.warning, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.orange.shade700,
        duration: const Duration(days: 365), // Never auto-hide
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Reintentar',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            onRetry();
          },
        ),
      ),
    );
  }
}
```

### 2.6 Run GREEN Tests

```bash
# Backend tests
cd tests/python && pytest unit/services/validators/ unit/core/ -v

# Frontend tests
cd tests && flutter test test/unit/core/error_handling/

# Expected Output: ALL GREEN (100% pass rate)
```

**Checklist Phase 2:**
- [ ] DocumentValidator implemented with 5 validation gates
- [ ] @with_retry decorator implemented with exponential backoff
- [ ] Custom exceptions added (ValidationError, RetryExhaustedError)
- [ ] ErrorMapper implemented with 10+ error codes
- [ ] SnackbarService implemented with 4 notification types
- [ ] All RED tests now GREEN
- [ ] No code duplication (DRY principle)

---

## 🔵 Phase 3: TDD - REFACTOR (Improvements and Robustness)

**Objective:** Optimize code, add logging, improve error messages.

### 3.1 Add Structured Logging

**File:** `src/server/app/core/logging_config.py`

```python
"""Structured logging configuration."""
import json
import logging
from datetime import datetime
from typing import Any


class StructuredFormatter(logging.Formatter):
    """JSON formatter for structured logging."""

    def format(self, record: logging.LogRecord) -> str:
        """Format log record as JSON."""
        log_data: dict[str, Any] = {
            "timestamp": datetime.utcnow().isoformat(),
            "level": record.levelname,
            "logger": record.name,
            "message": record.getMessage(),
            "operation": getattr(record, "operation", None),
            "error_code": getattr(record, "error_code", None),
        }

        # Add exception info if present
        if record.exc_info:
            log_data["exception"] = self.formatException(record.exc_info)

        return json.dumps(log_data)


def setup_logging() -> None:
    """Configure application logging."""
    handler = logging.StreamHandler()
    handler.setFormatter(StructuredFormatter())

    logging.basicConfig(
        level=logging.INFO,
        handlers=[handler],
    )
```

### 3.2 Add Logging to Retry Decorator

Update `src/server/app/core/retry.py` to include structured logging:

```python
# Add extra context to logs
logger.info(
    f"✅ Retry successful for {func.__name__}",
    extra={"operation": func.__name__, "attempt": attempt + 1}
)
```

### 3.3 Add Error Context to Frontend

**File:** `src/client/lib/core/error_handling/error_context.dart`

```dart
/// Context information for errors.
class ErrorContext {
  final String errorCode;
  final String message;
  final String suggestion;
  final bool isRetryable;
  final DateTime timestamp;

  ErrorContext({
    required this.errorCode,
    required this.message,
    required this.suggestion,
    required this.isRetryable,
  }) : timestamp = DateTime.now();

  Map<String, dynamic> toJson() => {
    'error_code': errorCode,
    'message': message,
    'suggestion': suggestion,
    'is_retryable': isRetryable,
    'timestamp': timestamp.toIso8601String(),
  };
}
```

### 3.4 Optimize Validation Gates

Add caching for compiled regex patterns:

```python
class DocumentValidator:
    """Validates document content (optimized with caching)."""

    # Compile regex patterns once
    _XSS_PATTERNS_COMPILED: Final[list[re.Pattern]] = [
        re.compile(pattern, re.IGNORECASE)
        for pattern in XSS_PATTERNS
    ]

    def validate_safety(self, content: str) -> bool:
        """Validate against XSS (cached patterns)."""
        for pattern in self._XSS_PATTERNS_COMPILED:
            if pattern.search(content):
                raise ValidationError(...)
        return True
```

**Checklist Phase 3:**
- [ ] Structured JSON logging implemented
- [ ] Error context tracking added
- [ ] Validation patterns optimized (cached)
- [ ] All logs sanitized (no sensitive data)
- [ ] Code coverage maintained >90%
- [ ] No performance regressions

---

## 🧪 Phase 4: Integration Testing (E2E)

**Objective:** Test complete error handling flow end-to-end.

### 4.1 Backend Integration Test

**File:** `tests/python/integration/test_error_handling_flow.py`

```python
import pytest
from fastapi.testclient import TestClient
from app.main import app


class TestErrorHandlingFlow:
    """E2E tests for error handling flow."""

    @pytest.fixture
    def client(self):
        return TestClient(app)

    def test_validation_error_returns_400_with_code(self, client):
        """Should return VAL_001 for invalid document."""
        response = client.post(
            "/api/v1/chat/generate",
            json={"content": "Too short"}  # <50 chars
        )

        assert response.status_code == 400
        data = response.json()
        assert data["code"] == "VAL_001"
        assert "mínimo" in data["message"]

    def test_retry_exhausted_returns_503(self, client, monkeypatch):
        """Should return 503 after retry exhaustion."""
        # Mock ChromaDB to always fail
        def mock_query(*args, **kwargs):
            raise ConnectionError("ChromaDB unavailable")

        monkeypatch.setattr("app.services.rag.vector_store.query", mock_query)

        response = client.post(
            "/api/v1/chat/generate",
            json={"content": "Valid content with sufficient length"}
        )

        assert response.status_code == 503
        data = response.json()
        assert data["code"] == "SYS_RETRY_EXHAUSTED"
```

### 4.2 Frontend Integration Test

**File:** `tests/test/integration/features/chat/error_handling_flow_test.dart`

```dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soft_architect_ai/core/error_handling/error_mapper.dart';
import 'package:soft_architect_ai/core/error_handling/snackbar_service.dart';

void main() {
  group('Error Handling Flow', () {
    testWidgets('should display validation error with suggestion', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    final mapper = ErrorMapper();
                    final service = SnackbarService();

                    service.showError(
                      context,
                      mapper.getUserMessage('VAL_001'),
                      'VAL_001',
                    );
                  },
                  child: const Text('Trigger Error'),
                );
              },
            ),
          ),
        ),
      );

      // Trigger error
      await tester.tap(find.text('Trigger Error'));
      await tester.pump();

      // Verify error displayed
      expect(find.text('📝 El documento generado es inválido (muy corto)'), findsOneWidget);
      expect(find.text('Código: VAL_001'), findsOneWidget);
      expect(find.text('Cerrar'), findsOneWidget);
    });

    testWidgets('should show retry button for retryable errors', (tester) async {
      var retryCount = 0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    final service = SnackbarService();
                    service.showRetryableError(
                      context,
                      'Conexión perdida con el servidor',
                      onRetry: () => retryCount++,
                    );
                  },
                  child: const Text('Trigger Retry Error'),
                );
              },
            ),
          ),
        ),
      );

      // Trigger error
      await tester.tap(find.text('Trigger Retry Error'));
      await tester.pump();

      // Verify retry button
      expect(find.text('Reintentar'), findsOneWidget);

      // Tap retry
      await tester.tap(find.text('Reintentar'));
      await tester.pump();

      // Verify retry callback executed
      expect(retryCount, equals(1));
    });
  });
}
```

**Checklist Phase 4:**
- [ ] Backend E2E tests pass (2+ scenarios)
- [ ] Frontend E2E tests pass (2+ scenarios)
- [ ] Error flow validated end-to-end
- [ ] Retry logic verified with mocks
- [ ] Snackbar behavior validated

---

## 📚 Phase 5: Documentation and Validation

### 5.1 Update ERROR_HANDLING_STANDARD.md

Add validation error codes and retry logic documentation.

### 5.2 Create Error Handling Guide

**File:** `doc/02-SETUP_DEV/ERROR_HANDLING_GUIDE.md`

```markdown
# Error Handling Developer Guide

## Quick Reference

| Error Code | Meaning | User Action |
|------------|---------|-------------|
| VAL_001 | Document too short | Regenerate document |
| VAL_002 | Invalid Markdown | Review structure |
| SYS_001 | Server unreachable | Check Docker |

## Retry Configuration

- Max retries: 3
- Base delay: 1.0s
- Backoff: Exponential (1s, 2s, 4s)
```

**Checklist Phase 5:**
- [ ] ERROR_HANDLING_STANDARD.md updated
- [ ] ERROR_HANDLING_GUIDE.md created
- [ ] All error codes documented
- [ ] Retry logic explained
- [ ] Examples provided

---

## ⚙️ Phase 6: CI/CD and Pipeline

### 6.1 Verify CI/CD Compliance

```bash
# Backend checks
cd src/server
black --check app/
ruff check app/
python -m pyright app/
pytest tests/ --cov=app --cov-fail-under=90

# Frontend checks
cd src/client
dart format --set-exit-if-changed lib/
flutter analyze
flutter test --coverage

# All must pass ✅
```

### 6.2 Update GitHub Actions

Ensure error handling tests run in CI:

```yaml
# .github/workflows/backend-ci.yaml
- name: Run Error Handling Tests
  run: |
    cd tests/python
    pytest unit/services/validators/ unit/core/test_retry.py -v
```

**Checklist Phase 6:**
- [ ] All linting passes
- [ ] All type checks pass
- [ ] Test coverage >90%
- [ ] GitHub Actions updated
- [ ] CI pipeline green

---

## 📦 Final Deliverables

### Code Artifacts
- ✅ `src/server/app/services/validators/document_validator.py`
- ✅ `src/server/app/core/retry.py`
- ✅ `src/server/app/core/exceptions.py` (updated)
- ✅ `src/server/app/core/logging_config.py`
- ✅ `src/client/lib/core/error_handling/error_mapper.dart`
- ✅ `src/client/lib/core/error_handling/snackbar_service.dart`
- ✅ `src/client/lib/core/error_handling/error_context.dart`

### Test Artifacts
- ✅ `tests/python/unit/services/validators/test_document_validator.py` (5+ tests)
- ✅ `tests/python/unit/core/test_retry.py` (4+ tests)
- ✅ `tests/python/integration/test_error_handling_flow.py` (2+ tests)
- ✅ `tests/test/unit/core/error_handling/error_mapper_test.dart` (3+ tests)
- ✅ `tests/test/unit/core/error_handling/snackbar_service_test.dart` (3+ tests)
- ✅ `tests/test/integration/features/chat/error_handling_flow_test.dart` (2+ tests)

### Documentation Artifacts
- ✅ `context/30-ARCHITECTURE/ERROR_HANDLING_STANDARD.md` (updated)
- ✅ `doc/02-SETUP_DEV/ERROR_HANDLING_GUIDE.md`
- ✅ `doc/03-HU-TRACKING/HU-3.4_ERROR_HANDLING_GATES/VALIDATION_RULES.md`
- ✅ `doc/03-HU-TRACKING/HU-3.4_ERROR_HANDLING_GATES/COMPLETION_SUMMARY.md`

### Metrics
- **Test Coverage:** >90% (target achieved)
- **Error Codes Mapped:** 11+ codes
- **Validation Gates:** 5 gates implemented
- **Retry Logic:** Exponential backoff (1s, 2s, 4s)
- **UX Improvements:** 4 snackbar types

---

## 🎉 Success Criteria

**HU-3.4 is considered COMPLETE when:**
- [ ] All validation gates implemented and tested
- [ ] Retry logic with exponential backoff functional
- [ ] Snackbar UX meets requirements (5s auto-hide for success, manual for errors)
- [ ] All error codes mapped to Spanish messages
- [ ] Test coverage >90%
- [ ] CI/CD pipeline green
- [ ] Documentation complete and reviewed
- [ ] Merged to `develop` branch

**Estimated Timeline:** 3-4 days
**Story Points:** 5 (Medium complexity)
**Dependencies:** HU-3.3 (merged) ✅

---

**Last Updated:** 09/02/2026
**Status:** 🟢 Ready for Implementation
**Next Step:** Execute Phase 0 (Groundwork Preparation)
