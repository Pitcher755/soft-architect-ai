"""
Test suite for core.exceptions module

Tests exception classes and their methods:
- BaseAppError initialization and methods
- Specialized exception subclasses
- Error serialization (to_dict)
- Error logging
"""

from unittest.mock import patch

import pytest

from core.exceptions import (  # type: ignore
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

    def test_base_app_error_initialization_full(self) -> None:
        """Test BaseAppError with all parameters."""
        error = BaseAppError(
            code="TEST_002",
            message="Test error with details",
            details={"key": "value"},
            status_code=400,
        )
        assert error.code == "TEST_002"
        assert error.message == "Test error with details"
        assert error.details == {"key": "value"}
        assert error.status_code == 400

    def test_base_app_error_to_dict(self) -> None:
        """Test BaseAppError.to_dict() serialization."""
        error = BaseAppError(
            code="SYS_001",
            message="System error",
            details={"request_id": "123"},
        )
        result = error.to_dict()
        assert result["error_code"] == "SYS_001"
        assert result["error_message"] == "System error"
        assert result["details"] == {"request_id": "123"}

    def test_base_app_error_to_dict_empty_details(self) -> None:
        """Test BaseAppError.to_dict() with no details."""
        error = BaseAppError(code="SYS_002", message="Another error")
        result = error.to_dict()
        assert result["error_code"] == "SYS_002"
        assert result["error_message"] == "Another error"
        assert result["details"] == {}

    def test_base_app_error_log_error_500_status(self) -> None:
        """Test BaseAppError.log_error() with status_code >= 500."""
        error = BaseAppError(
            code="SYS_003",
            message="Server error",
            details={"cause": "database"},
            status_code=500,
        )
        with patch("logging.Logger.error") as mock_error:
            error.log_error()
            mock_error.assert_called_once()
            call_args = mock_error.call_args[0][0]
            assert "SYS_003" in call_args
            assert "Server error" in call_args

    def test_base_app_error_log_error_400_status(self) -> None:
        """Test BaseAppError.log_error() with status_code < 500."""
        error = BaseAppError(
            code="VAL_001",
            message="Validation error",
            details={"field": "email"},
            status_code=400,
        )
        with patch("logging.Logger.warning") as mock_warning:
            error.log_error()
            mock_warning.assert_called_once()


class TestVectorStoreError:
    """Test suite for VectorStoreError class."""

    def test_vector_store_error_initialization(self) -> None:
        """Test VectorStoreError with default parameters."""
        error = VectorStoreError()
        assert error.code == "VECTOR_STORE_ERR"
        assert error.message == "Vector store operation failed"
        assert error.details == {}
        assert error.status_code == 500

    def test_vector_store_error_custom_parameters(self) -> None:
        """Test VectorStoreError with custom parameters."""
        error = VectorStoreError(
            code="CUSTOM_ERR",
            message="Custom error",
            details={"custom": "data"},
            status_code=503,
        )
        assert error.code == "CUSTOM_ERR"
        assert error.message == "Custom error"
        assert error.details == {"custom": "data"}
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
            host="chromadb.local", port=8001, reason="Connection timed out"
        )
        assert error.details["host"] == "chromadb.local"
        assert error.details["port"] == 8001
        assert error.details["reason"] == "Connection timed out"

    def test_connection_error_without_reason(self) -> None:
        """Test ConnectionError excludes empty reason from details."""
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
        error = DatabaseWriteError(
            operation="insert",
            reason="Disk full",
        )
        assert error.details["operation"] == "insert"
        assert error.details["reason"] == "Disk full"

    def test_database_write_error_empty_operation_excluded(self) -> None:
        """Test DatabaseWriteError excludes empty operation from details."""
        error = DatabaseWriteError(operation="", reason="Network error")
        assert "operation" not in error.details
        assert error.details["reason"] == "Network error"


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
        error = DatabaseReadError(operation="fetch_embeddings")
        assert error.details["operation"] == "fetch_embeddings"

    def test_database_read_error_with_reason(self) -> None:
        """Test DatabaseReadError with reason."""
        error = DatabaseReadError(
            operation="query", reason="Index corrupted"
        )
        assert error.details["operation"] == "query"
        assert error.details["reason"] == "Index corrupted"


class TestValidationError:
    """Test suite for ValidationError class."""

    def test_validation_error_minimal(self) -> None:
        """Test ValidationError with no parameters."""
        error = ValidationError()
        assert error.code == "VAL_ERR"
        assert error.message == "Validation failed"
        assert error.details == {}
        assert error.status_code == 400

    def test_validation_error_with_field(self) -> None:
        """Test ValidationError with field."""
        error = ValidationError(field="email")
        assert error.details["field"] == "email"

    def test_validation_error_with_message_and_field(self) -> None:
        """Test ValidationError with custom message and field."""
        error = ValidationError(
            field="password",
            message="Password too short",
        )
        assert error.message == "Password too short"
        assert error.details["field"] == "password"

    def test_validation_error_with_custom_details(self) -> None:
        """Test ValidationError with additional details."""
        error = ValidationError(
            field="username",
            message="Invalid format",
            details={"pattern": "alphanumeric", "length": 5},
        )
        assert error.details["field"] == "username"
        assert error.details["pattern"] == "alphanumeric"
        assert error.details["length"] == 5


class TestConfigurationError:
    """Test suite for ConfigurationError class."""

    def test_configuration_error_minimal(self) -> None:
        """Test ConfigurationError with no parameters."""
        error = ConfigurationError()
        assert error.code == "CONFIG_ERR"
        assert error.message == "Configuration error"
        assert error.details == {}
        assert error.status_code == 500

    def test_configuration_error_with_message(self) -> None:
        """Test ConfigurationError with custom message."""
        error = ConfigurationError(message="Missing API key")
        assert error.message == "Missing API key"

    def test_configuration_error_with_details(self) -> None:
        """Test ConfigurationError with details."""
        error = ConfigurationError(
            message="Invalid config file",
            details={"file": "config.yaml", "reason": "YAML syntax error"},
        )
        assert error.message == "Invalid config file"
        assert error.details["file"] == "config.yaml"
        assert error.details["reason"] == "YAML syntax error"


class TestExceptionInheritance:
    """Test suite for exception inheritance."""

    def test_connection_error_inherits_from_vector_store_error(self) -> None:
        """Test ConnectionError is an instance of VectorStoreError."""
        error = ConnectionError(host="localhost", port=8000)
        assert isinstance(error, VectorStoreError)
        assert isinstance(error, BaseAppError)
        assert isinstance(error, Exception)

    def test_database_write_error_inherits_from_vector_store_error(self) -> None:
        """Test DatabaseWriteError is an instance of VectorStoreError."""
        error = DatabaseWriteError(operation="insert")
        assert isinstance(error, VectorStoreError)
        assert isinstance(error, BaseAppError)

    def test_database_read_error_inherits_from_vector_store_error(self) -> None:
        """Test DatabaseReadError is an instance of VectorStoreError."""
        error = DatabaseReadError(operation="query")
        assert isinstance(error, VectorStoreError)
        assert isinstance(error, BaseAppError)

    def test_validation_error_inherits_from_base_app_error(self) -> None:
        """Test ValidationError is an instance of BaseAppError."""
        error = ValidationError(field="username")
        assert isinstance(error, BaseAppError)
        assert isinstance(error, Exception)

    def test_configuration_error_inherits_from_base_app_error(self) -> None:
        """Test ConfigurationError is an instance of BaseAppError."""
        error = ConfigurationError(message="Config error")
        assert isinstance(error, BaseAppError)
        assert isinstance(error, Exception)


class TestExceptionRaisingAndCatching:
    """Test suite for raising and catching exceptions."""

    def test_raise_and_catch_base_app_error(self) -> None:
        """Test raising and catching BaseAppError."""
        with pytest.raises(BaseAppError) as exc_info:
            raise BaseAppError(
                code="TEST_001",
                message="Test error",
                status_code=400,
            )
        assert exc_info.value.code == "TEST_001"
        assert exc_info.value.status_code == 400

    def test_raise_and_catch_connection_error(self) -> None:
        """Test raising and catching ConnectionError."""
        with pytest.raises(VectorStoreError):
            raise ConnectionError(host="localhost", port=8000)

    def test_raise_and_catch_validation_error(self) -> None:
        """Test raising and catching ValidationError."""
        with pytest.raises(BaseAppError) as exc_info:
            raise ValidationError(
                field="email",
                message="Invalid email",
                details={"pattern": "RFC 5322"},
            )
        assert exc_info.value.code == "VAL_ERR"
        assert exc_info.value.details["field"] == "email"
        assert exc_info.value.status_code == 400
