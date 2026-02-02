"""
Test suite for core.exceptions module

Tests exception classes and their methods:
- BaseAppError initialization and methods
- Specialized exception subclasses
- Error serialization (to_dict)
- Error logging
"""

import logging
from unittest.mock import MagicMock, patch

import pytest

from core.exceptions import (
    BaseAppError,
    ConfigurationError,
    ConnectionError,
    DatabaseReadError,
    DatabaseWriteError,
    ValidationError,
    VectorStoreError,
)


class TestBaseAppError:
    """Test suite for BaseAppError class."""

    def test_base_app_error_initialization_minimal(self) -> None:
        """Test BaseAppError with minimal parameters."""
        error = BaseAppError(code="TEST_001", message="Test error")

        assert error.code == "TEST_001"
        assert error.message == "Test error"
        assert error.details == {}
        assert error.status_code == 500
        assert str(error) == "[TEST_001] Test error"

    def test_base_app_error_initialization_full(self) -> None:
        """Test BaseAppError with all parameters."""
        details = {"context": "value"}
        error = BaseAppError(
            code="TEST_002",
            message="Test error with details",
            details=details,
            status_code=400,
        )

        assert error.code == "TEST_002"
        assert error.message == "Test error with details"
        assert error.details == details
        assert error.status_code == 400

    def test_base_app_error_to_dict(self) -> None:
        """Test BaseAppError.to_dict() serialization."""
        details = {"key": "value", "number": 42}
        error = BaseAppError(
            code="TEST_003",
            message="Serialization test",
            details=details,
        )

        result = error.to_dict()

        assert result["error_code"] == "TEST_003"
        assert result["error_message"] == "Serialization test"
        assert result["details"] == details

    def test_base_app_error_to_dict_empty_details(self) -> None:
        """Test to_dict with empty details."""
        error = BaseAppError(code="TEST_004", message="No details")

        result = error.to_dict()

        assert result["details"] == {}

    @patch("core.exceptions.base.logger")
    def test_base_app_error_log_error_500(self, mock_logger: MagicMock) -> None:
        """Test log_error for 500+ status codes."""
        error = BaseAppError(
            code="TEST_005",
            message="Server error",
            details={"reason": "DB down"},
            status_code=500,
        )

        error.log_error()

        mock_logger.error.assert_called_once()
        call_args = mock_logger.error.call_args[0][0]
        assert "TEST_005" in call_args
        assert "Server error" in call_args

    @patch("core.exceptions.base.logger")
    def test_base_app_error_log_error_400(self, mock_logger: MagicMock) -> None:
        """Test log_error for <500 status codes (uses warning)."""
        error = BaseAppError(
            code="TEST_006",
            message="Client error",
            details={"field": "email"},
            status_code=400,
        )

        error.log_error()

        mock_logger.warning.assert_called_once()
        call_args = mock_logger.warning.call_args[0][0]
        assert "TEST_006" in call_args
        assert "Client error" in call_args


class TestVectorStoreError:
    """Test suite for VectorStoreError class."""

    def test_vector_store_error_defaults(self) -> None:
        """Test VectorStoreError with default parameters."""
        error = VectorStoreError()

        assert error.code == "VECTOR_STORE_ERR"
        assert error.message == "Vector store operation failed"
        assert error.details == {}
        assert error.status_code == 500

    def test_vector_store_error_custom_params(self) -> None:
        """Test VectorStoreError with custom parameters."""
        error = VectorStoreError(
            code="CUSTOM_VECTOR_ERR",
            message="Custom vector operation failed",
            details={"collection": "docs"},
            status_code=503,
        )

        assert error.code == "CUSTOM_VECTOR_ERR"
        assert error.message == "Custom vector operation failed"
        assert error.details == {"collection": "docs"}
        assert error.status_code == 503


class TestConnectionError:
    """Test suite for ConnectionError class."""

    def test_connection_error_basic(self) -> None:
        """Test ConnectionError with host and port."""
        error = ConnectionError(host="localhost", port=8000)

        assert error.code == "SYS_001"
        assert "localhost" in error.message
        assert "8000" in error.message
        assert error.details["host"] == "localhost"
        assert error.details["port"] == 8000
        assert error.status_code == 503

    def test_connection_error_with_reason(self) -> None:
        """Test ConnectionError with reason."""
        error = ConnectionError(
            host="chromadb.local", port=8000, reason="Connection timed out"
        )

        assert error.details["host"] == "chromadb.local"
        assert error.details["reason"] == "Connection timed out"

    def test_connection_error_without_reason(self) -> None:
        """Test ConnectionError without reason (should not include in details)."""
        error = ConnectionError(host="localhost", port=8000, reason="")

        assert "reason" not in error.details


class TestDatabaseWriteError:
    """Test suite for DatabaseWriteError class."""

    def test_database_write_error_minimal(self) -> None:
        """Test DatabaseWriteError with no parameters."""
        error = DatabaseWriteError()

        assert error.code == "DB_WRITE_ERR"
        assert error.message == "Database write operation failed"
        assert error.details == {}
        assert error.status_code == 500

    def test_database_write_error_with_operation(self) -> None:
        """Test DatabaseWriteError with operation."""
        error = DatabaseWriteError(operation="insert_vector")

        assert error.details["operation"] == "insert_vector"

    def test_database_write_error_with_reason(self) -> None:
        """Test DatabaseWriteError with reason."""
        error = DatabaseWriteError(reason="Disk full")

        assert error.details["reason"] == "Disk full"

    def test_database_write_error_full(self) -> None:
        """Test DatabaseWriteError with all parameters."""
        error = DatabaseWriteError(operation="batch_insert", reason="Index locked")

        assert error.details["operation"] == "batch_insert"
        assert error.details["reason"] == "Index locked"


class TestDatabaseReadError:
    """Test suite for DatabaseReadError class."""

    def test_database_read_error_minimal(self) -> None:
        """Test DatabaseReadError with no parameters."""
        error = DatabaseReadError()

        assert error.code == "DB_READ_ERR"
        assert error.message == "Database read operation failed"
        assert error.details == {}
        assert error.status_code == 500

    def test_database_read_error_with_operation(self) -> None:
        """Test DatabaseReadError with operation."""
        error = DatabaseReadError(operation="query_vectors")

        assert error.details["operation"] == "query_vectors"

    def test_database_read_error_with_reason(self) -> None:
        """Test DatabaseReadError with reason."""
        error = DatabaseReadError(reason="Collection not found")

        assert error.details["reason"] == "Collection not found"

    def test_database_read_error_full(self) -> None:
        """Test DatabaseReadError with all parameters."""
        error = DatabaseReadError(operation="fetch_metadata", reason="Timeout")

        assert error.details["operation"] == "fetch_metadata"
        assert error.details["reason"] == "Timeout"


class TestValidationError:
    """Test suite for ValidationError class."""

    def test_validation_error_minimal(self) -> None:
        """Test ValidationError with defaults."""
        error = ValidationError()

        assert error.code == "VAL_ERR"
        assert error.message == "Validation failed"
        assert error.details == {}
        assert error.status_code == 400

    def test_validation_error_with_field(self) -> None:
        """Test ValidationError with field."""
        error = ValidationError(field="email")

        assert error.details["field"] == "email"

    def test_validation_error_with_message(self) -> None:
        """Test ValidationError with custom message."""
        error = ValidationError(message="Email format is invalid")

        assert error.message == "Email format is invalid"

    def test_validation_error_with_custom_details(self) -> None:
        """Test ValidationError with custom details dict."""
        custom_details = {"allowed_formats": ["@gmail.com", "@company.com"]}
        error = ValidationError(details=custom_details)

        assert error.details == custom_details

    def test_validation_error_full(self) -> None:
        """Test ValidationError with all parameters."""
        error = ValidationError(
            field="password",
            message="Password too weak",
            details={"min_length": 8, "requires_special": True},
        )

        assert error.details["field"] == "password"
        assert error.details["min_length"] == 8
        assert error.details["requires_special"] is True


class TestConfigurationError:
    """Test suite for ConfigurationError class."""

    def test_configuration_error_minimal(self) -> None:
        """Test ConfigurationError with defaults."""
        error = ConfigurationError()

        assert error.code == "CONFIG_ERR"
        assert error.message == "Configuration error"
        assert error.details == {}
        assert error.status_code == 500

    def test_configuration_error_with_message(self) -> None:
        """Test ConfigurationError with custom message."""
        error = ConfigurationError(message="Missing OLLAMA_HOST env var")

        assert error.message == "Missing OLLAMA_HOST env var"

    def test_configuration_error_with_details(self) -> None:
        """Test ConfigurationError with details."""
        details = {"env_var": "OLLAMA_HOST", "required": True}
        error = ConfigurationError(
            message="Env var not set", details=details
        )

        assert error.details == details


class TestExceptionInheritance:
    """Test exception inheritance and inheritance chain."""

    def test_vector_store_error_is_app_error(self) -> None:
        """Test that VectorStoreError inherits from BaseAppError."""
        error = VectorStoreError()

        assert isinstance(error, BaseAppError)
        assert isinstance(error, Exception)

    def test_connection_error_is_vector_store_error(self) -> None:
        """Test that ConnectionError inherits from VectorStoreError."""
        error = ConnectionError(host="localhost", port=8000)

        assert isinstance(error, VectorStoreError)
        assert isinstance(error, BaseAppError)
        assert isinstance(error, Exception)

    def test_database_write_error_is_vector_store_error(self) -> None:
        """Test that DatabaseWriteError inherits from VectorStoreError."""
        error = DatabaseWriteError()

        assert isinstance(error, VectorStoreError)
        assert isinstance(error, BaseAppError)

    def test_validation_error_is_app_error(self) -> None:
        """Test that ValidationError inherits from BaseAppError."""
        error = ValidationError()

        assert isinstance(error, BaseAppError)
        assert isinstance(error, Exception)

    def test_configuration_error_is_app_error(self) -> None:
        """Test that ConfigurationError inherits from BaseAppError."""
        error = ConfigurationError()

        assert isinstance(error, BaseAppError)
        assert isinstance(error, Exception)


class TestExceptionRaising:
    """Test that exceptions can be properly raised and caught."""

    def test_raise_base_app_error(self) -> None:
        """Test raising and catching BaseAppError."""
        with pytest.raises(BaseAppError) as exc_info:
            raise BaseAppError(code="TEST", message="Test")

        assert exc_info.value.code == "TEST"

    def test_raise_connection_error(self) -> None:
        """Test raising and catching ConnectionError."""
        with pytest.raises(VectorStoreError) as exc_info:
            raise ConnectionError(host="localhost", port=8000)

        assert exc_info.value.code == "SYS_001"

    def test_raise_validation_error(self) -> None:
        """Test raising and catching ValidationError."""
        with pytest.raises(BaseAppError) as exc_info:
            raise ValidationError(field="email", message="Invalid email")

        assert exc_info.value.code == "VAL_ERR"
        assert exc_info.value.status_code == 400
