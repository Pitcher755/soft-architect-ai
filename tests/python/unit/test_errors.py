"""
Error handling system tests.

Validates custom error classes and error codes.
"""

from core.errors import (
    API_001_INVALID_INPUT,
    DB_001_CHROMADB_UNAVAILABLE,
    SYS_001_CONNECTION_REFUSED,
    APIError,
    SystemError,
)


def test_system_error():
    """SystemError should have correct properties."""
    error = SystemError(code="TEST_001", message="Test error")
    assert error.code == "TEST_001"
    assert error.message == "Test error"
    assert error.status_code == 500


def test_api_error():
    """APIError should have correct properties."""
    error = APIError(code="API_TEST", message="API test error", status_code=422)
    assert error.code == "API_TEST"
    assert error.message == "API test error"
    assert error.status_code == 422


def test_predefined_errors():
    """Predefined errors should be accessible."""
    assert SYS_001_CONNECTION_REFUSED.code == "SYS_001"
    assert API_001_INVALID_INPUT.code == "API_001"
    assert DB_001_CHROMADB_UNAVAILABLE.code == "DB_001"
