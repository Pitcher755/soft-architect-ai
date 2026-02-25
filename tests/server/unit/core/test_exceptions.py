"""Unit tests for core/exceptions/base.py.

Tests all custom exception classes ensuring correct initialization,
representation, to_dict output and logging behaviour.

Coverage target: ≥90% of core/exceptions/base.py
"""

import logging

import pytest

from core.exceptions.base import (
    BaseAppError,
    ConfigurationError,
    ConnectionError,
    DatabaseReadError,
    DatabaseWriteError,
    ValidationError,
    VectorStoreError,
)


# ---------------------------------------------------------------------------
# BaseAppError
# ---------------------------------------------------------------------------


class TestBaseAppError:
    """Tests for BaseAppError base class."""

    def test_initialization_defaults(self):
        """BaseAppError stores code, message and defaults correctly."""
        err = BaseAppError(code="TEST_001", message="Test error")

        assert err.code == "TEST_001"
        assert err.message == "Test error"
        assert err.details == {}
        assert err.status_code == 500

    def test_initialization_with_all_params(self):
        """BaseAppError accepts all optional parameters."""
        details = {"key": "value", "count": 42}
        err = BaseAppError(
            code="TEST_002",
            message="Full error",
            details=details,
            status_code=400,
        )

        assert err.details == {"key": "value", "count": 42}
        assert err.status_code == 400

    def test_str_representation(self):
        """str(err) includes code and message."""
        err = BaseAppError(code="SYS_001", message="Connection failed")
        assert "[SYS_001]" in str(err)
        assert "Connection failed" in str(err)

    def test_is_exception(self):
        """BaseAppError is an Exception subclass."""
        err = BaseAppError(code="X", message="y")
        assert isinstance(err, Exception)

    def test_to_dict_structure(self):
        """to_dict returns the correct keys and values."""
        err = BaseAppError(
            code="DB_001", message="DB error", details={"table": "users"}
        )
        result = err.to_dict()

        assert result["error_code"] == "DB_001"
        assert result["error_message"] == "DB error"
        assert result["details"] == {"table": "users"}

    def test_to_dict_empty_details(self):
        """to_dict returns empty dict for details when not provided."""
        err = BaseAppError(code="C", message="m")
        assert err.to_dict()["details"] == {}

    def test_log_error_5xx_uses_error_level(self, caplog):
        """status_code >= 500 uses ERROR log level."""
        err = BaseAppError(code="SYS_500", message="Server error", status_code=500)
        with caplog.at_level(logging.ERROR, logger="core.exceptions.base"):
            err.log_error()
        assert any("SYS_500" in r.message for r in caplog.records)
        assert any(r.levelname == "ERROR" for r in caplog.records)

    def test_log_error_4xx_uses_warning_level(self, caplog):
        """status_code < 500 uses WARNING log level."""
        err = BaseAppError(code="VAL_400", message="Bad request", status_code=400)
        with caplog.at_level(logging.WARNING, logger="core.exceptions.base"):
            err.log_error()
        assert any("VAL_400" in r.message for r in caplog.records)
        assert any(r.levelname == "WARNING" for r in caplog.records)

    def test_can_be_raised_and_caught(self):
        """BaseAppError can be raised and caught as Exception."""
        with pytest.raises(BaseAppError) as exc_info:
            raise BaseAppError(code="TEST", message="raised")
        assert exc_info.value.code == "TEST"


# ---------------------------------------------------------------------------
# VectorStoreError
# ---------------------------------------------------------------------------


class TestVectorStoreError:
    """Tests for VectorStoreError."""

    def test_default_initialization(self):
        """VectorStoreError uses sensible defaults."""
        err = VectorStoreError()
        assert err.code == "VECTOR_STORE_ERR"
        assert "Vector store" in err.message
        assert err.status_code == 500

    def test_custom_params(self):
        """VectorStoreError accepts all BaseAppError params."""
        err = VectorStoreError(
            code="CUSTOM_ERR",
            message="Custom",
            details={"x": 1},
            status_code=503,
        )
        assert err.code == "CUSTOM_ERR"
        assert err.status_code == 503

    def test_is_base_app_error(self):
        """VectorStoreError is a BaseAppError subclass."""
        assert isinstance(VectorStoreError(), BaseAppError)


# ---------------------------------------------------------------------------
# ConnectionError
# ---------------------------------------------------------------------------


class TestConnectionError:
    """Tests for ConnectionError."""

    def test_basic_initialization(self):
        """ConnectionError sets host, port and correct code."""
        err = ConnectionError(host="localhost", port=8000)
        assert err.code == "SYS_001"
        assert err.status_code == 503
        assert err.details["host"] == "localhost"
        assert err.details["port"] == 8000

    def test_reason_added_to_details(self):
        """ConnectionError with reason includes it in details."""
        err = ConnectionError(host="db", port=6333, reason="timeout")
        assert err.details["reason"] == "timeout"

    def test_no_reason_omits_key(self):
        """ConnectionError without reason omits reason from details."""
        err = ConnectionError(host="db", port=6333)
        assert "reason" not in err.details

    def test_message_contains_host_port(self):
        """ConnectionError message identifies the failing endpoint."""
        err = ConnectionError(host="chromadb", port=6333)
        assert "chromadb" in err.message
        assert "6333" in err.message


# ---------------------------------------------------------------------------
# DatabaseWriteError
# ---------------------------------------------------------------------------


class TestDatabaseWriteError:
    """Tests for DatabaseWriteError."""

    def test_default_initialization(self):
        """DatabaseWriteError has correct default code and status."""
        err = DatabaseWriteError()
        assert err.code == "DB_WRITE_ERR"
        assert err.status_code == 500

    def test_operation_and_reason(self):
        """Details include operation and reason when provided."""
        err = DatabaseWriteError(operation="upsert", reason="disk full")
        assert err.details["operation"] == "upsert"
        assert err.details["reason"] == "disk full"

    def test_empty_params_omit_keys(self):
        """Empty strings don't add keys to details."""
        err = DatabaseWriteError()
        assert err.details == {}


# ---------------------------------------------------------------------------
# DatabaseReadError
# ---------------------------------------------------------------------------


class TestDatabaseReadError:
    """Tests for DatabaseReadError."""

    def test_default_initialization(self):
        """DatabaseReadError has correct default code."""
        err = DatabaseReadError()
        assert err.code == "DB_READ_ERR"
        assert err.status_code == 500

    def test_operation_and_reason(self):
        """Details include operation and reason when provided."""
        err = DatabaseReadError(operation="query", reason="not found")
        assert err.details["operation"] == "query"
        assert err.details["reason"] == "not found"


# ---------------------------------------------------------------------------
# ValidationError
# ---------------------------------------------------------------------------


class TestValidationError:
    """Tests for ValidationError."""

    def test_default_initialization(self):
        """ValidationError has correct default code and status."""
        err = ValidationError()
        assert err.code == "VAL_ERR"
        assert err.status_code == 400

    def test_field_added_to_details(self):
        """Field name is stored in details."""
        err = ValidationError(field="email", message="Invalid format")
        assert err.details["field"] == "email"
        assert err.message == "Invalid format"

    def test_custom_details_merged(self):
        """Custom details dict is preserved."""
        err = ValidationError(details={"min": 1, "max": 100})
        assert err.details["min"] == 1
        assert err.details["max"] == 100

    def test_field_and_details_combined(self):
        """Field and custom details are combined."""
        err = ValidationError(field="age", details={"min": 0})
        assert err.details["field"] == "age"
        assert err.details["min"] == 0


# ---------------------------------------------------------------------------
# ConfigurationError
# ---------------------------------------------------------------------------


class TestConfigurationError:
    """Tests for ConfigurationError."""

    def test_default_initialization(self):
        """ConfigurationError has correct default code and status."""
        err = ConfigurationError()
        assert err.code == "CONFIG_ERR"
        assert err.status_code == 500
        assert "Configuration error" in err.message

    def test_custom_message(self):
        """Custom message is stored."""
        err = ConfigurationError(message="Missing API key")
        assert err.message == "Missing API key"

    def test_custom_details(self):
        """Custom details dict is preserved."""
        err = ConfigurationError(details={"env_var": "GROQ_API_KEY"})
        assert err.details["env_var"] == "GROQ_API_KEY"
