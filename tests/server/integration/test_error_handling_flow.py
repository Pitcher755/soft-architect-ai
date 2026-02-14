"""Integration E2E tests for error handling flow.

This module tests the complete error handling flow from API endpoint
to validation gates, retry logic, and error responses.

Test Coverage:
- Validation error returns 400 with error code
- Retry exhausted returns 503 after max attempts
- Valid content passes all validations
- XSS content triggers security validation
"""

from unittest.mock import Mock

import pytest

# Mock imports for testing without full API setup
# In production, these would import from actual FastAPI app


class MockValidationError(Exception):
    """Mock ValidationError for testing."""

    code: str
    message: str
    operation: str
    status_code: int

    def __init__(self, code: str, message: str, operation: str):
        self.code = code
        self.message = message
        self.operation = operation
        self.status_code = 400
        super().__init__(message)


class MockRetryExhaustedError(Exception):
    """Mock RetryExhaustedError for testing."""

    code: str
    message: str
    operation: str
    attempts: int
    last_error: str
    status_code: int

    def __init__(self, operation: str, attempts: int, last_error: str) -> None:
        self.code: str = "SYS_RETRY_EXHAUSTED"
        self.message: str = (
            f"Operación fallida después de {attempts} intentos: {last_error}"
        )
        self.operation: str = operation
        self.attempts: int = attempts
        self.last_error: str = last_error
        self.status_code: int = 503
        super().__init__(self.message)


class TestErrorHandlingFlow:
    """E2E tests for error handling flow."""

    def test_validation_error_short_content(self):
        """Should raise VAL_001 for documents shorter than 50 chars."""
        from app.core.exceptions import ValidationError
        from app.services.validators.document_validator import DocumentValidator

        validator = DocumentValidator()
        short_content = "Too short"  # <50 chars

        with pytest.raises(ValidationError) as exc_info:
            validator.validate_all(short_content)

        assert exc_info.value.code == "VAL_001"
        assert exc_info.value.status_code == 400
        assert "50 caracteres" in exc_info.value.message

    def test_validation_error_xss_content(self):
        """Should raise VAL_004 for content with XSS patterns."""
        from app.core.exceptions import ValidationError
        from app.services.validators.document_validator import DocumentValidator

        validator = DocumentValidator()
        # Valid length but contains XSS
        malicious_content = (
            "This is a valid length document with sufficient characters. "
            "<script>alert('XSS')</script> But it contains malicious code."
        )

        with pytest.raises(ValidationError) as exc_info:
            validator.validate_all(malicious_content)

        assert exc_info.value.code == "VAL_004"
        assert exc_info.value.status_code == 400
        assert "malicioso" in exc_info.value.message

    def test_validation_passes_with_valid_content(self):
        """Should pass validation with valid content."""
        from app.services.validators.document_validator import DocumentValidator

        validator = DocumentValidator()
        valid_content = """
        # Valid Document

        This is a completely valid Markdown document with:
        - Sufficient length (>50 characters)
        - Proper Markdown structure
        - UTF-8 encoding
        - No malicious code
        - Reasonable size (<5MB)

        ## Additional Section

        More content to ensure we pass all validation gates.
        """

        result = validator.validate_all(valid_content)

        assert result is True

    def test_retry_exhausted_after_failures(self):
        """Should raise RetryExhaustedError after max retry attempts."""
        from app.core.exceptions import RetryExhaustedError
        from app.core.retry import with_retry

        mock_func = Mock(side_effect=ConnectionError("Persistent failure"))
        mock_func.__name__ = "test_operation"

        decorated = with_retry(max_retries=3, base_delay=0.1)(mock_func)

        with pytest.raises(RetryExhaustedError) as exc_info:
            decorated()

        assert exc_info.value.code == "SYS_RETRY_EXHAUSTED"
        assert exc_info.value.status_code == 503
        assert mock_func.call_count == 3
        assert "Persistent failure" in exc_info.value.message

    def test_retry_succeeds_after_transient_failure(self):
        """Should succeed after transient failures with retry."""
        from app.core.retry import with_retry

        mock_func = Mock(side_effect=[ConnectionError(), ConnectionError(), "success"])
        mock_func.__name__ = "test_operation"

        decorated = with_retry(max_retries=3, base_delay=0.1)(mock_func)

        result = decorated()

        assert result == "success"
        assert mock_func.call_count == 3

    def test_complete_validation_pipeline(self):
        """Test complete validation pipeline with all gates."""
        from app.core.exceptions import ValidationError
        from app.services.validators.document_validator import DocumentValidator

        validator = DocumentValidator()

        # Test VAL_001: Too short
        with pytest.raises(ValidationError) as exc:
            validator.validate_content("short")
        assert exc.value.code == "VAL_001"

        # Test VAL_002: Malformed Markdown
        with pytest.raises(ValidationError) as exc:
            validator.validate_markdown("Unclosed [bracket")
        assert exc.value.code == "VAL_002"

        # Test VAL_003: Invalid encoding
        with pytest.raises(ValidationError) as exc:
            validator.validate_encoding(b"\xff\xfe Invalid UTF-8")
        assert exc.value.code == "VAL_003"

        # Test VAL_004: XSS patterns
        with pytest.raises(ValidationError) as exc:
            validator.validate_safety("<script>alert('xss')</script>")
        assert exc.value.code == "VAL_004"

        # Test VAL_005: Oversized content
        with pytest.raises(ValidationError) as exc:
            validator.validate_size("x" * (5 * 1024 * 1024 + 1))
        assert exc.value.code == "VAL_005"
