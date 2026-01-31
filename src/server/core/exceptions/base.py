"""
Core exception definitions following ERROR_HANDLING_STANDARD.md

Error codes format: [MODULE]_[SEVERITY]_[TYPE]
Examples: SYS_001 (System Connection Error), DB_WRITE_ERR (Database Write Error)

All application-specific exceptions inherit from BaseAppError and follow
a consistent error reporting structure for API responses and logging.
"""

import logging
from typing import Any

logger = logging.getLogger(__name__)


class BaseAppError(Exception):
    """
    Base exception class for all application-specific errors.

    Provides consistent error reporting structure for API responses,
    logging, and error tracing throughout the application.

    Attributes:
        code: Machine-readable error code (e.g., "SYS_001")
        message: Human-readable error message
        details: Additional context information (dict)
        status_code: HTTP status code for API responses
    """

    def __init__(
        self,
        code: str,
        message: str,
        details: dict[str, Any] | None = None,
        status_code: int = 500,
    ):
        """
        Initialize a BaseAppError.

        Args:
            code: Error code identifier (e.g., "SYS_001")
            message: Human-readable error message
            details: Optional dict with additional context
            status_code: HTTP status code (default: 500)
        """
        self.code = code
        self.message = message
        self.details = details or {}
        self.status_code = status_code
        super().__init__(f"[{code}] {message}")

    def to_dict(self) -> dict[str, Any]:
        """
        Convert exception to API-friendly JSON response format.

        Returns:
            Dictionary with error_code, error_message, and details
        """
        return {
            "error_code": self.code,
            "error_message": self.message,
            "details": self.details,
        }

    def log_error(self) -> None:
        """Log the error with appropriate severity level."""
        if self.status_code >= 500:
            logger.error(f"[{self.code}] {self.message} | Details: {self.details}")
        else:
            logger.warning(f"[{self.code}] {self.message} | Details: {self.details}")


class VectorStoreError(BaseAppError):
    """
    Exception for vector store (ChromaDB) operations failures.

    Used for:
    - Connection failures (SYS_001)
    - Write/Read operations failures (DB_WRITE_ERR, DB_READ_ERR)
    - Collection operations (COLLECTION_ERR)
    """

    def __init__(
        self,
        code: str = "VECTOR_STORE_ERR",
        message: str = "Vector store operation failed",
        details: dict[str, Any] | None = None,
        status_code: int = 500,
    ):
        """Initialize VectorStoreError with defaults."""
        super().__init__(code, message, details, status_code)


class ConnectionError(VectorStoreError):
    """ChromaDB connection failure (SYS_001)."""

    def __init__(self, host: str, port: int, reason: str = ""):
        """Initialize connection error with host/port context."""
        details = {"host": host, "port": port}
        if reason:
            details["reason"] = reason
        message = f"Failed to connect to ChromaDB at {host}:{port}"
        super().__init__(
            code="SYS_001", message=message, details=details, status_code=503
        )


class DatabaseWriteError(VectorStoreError):
    """ChromaDB write operation failure."""

    def __init__(self, operation: str = "", reason: str = ""):
        """Initialize database write error."""
        details = {}
        if operation:
            details["operation"] = operation
        if reason:
            details["reason"] = reason
        message = "Database write operation failed"
        super().__init__(
            code="DB_WRITE_ERR", message=message, details=details, status_code=500
        )


class DatabaseReadError(VectorStoreError):
    """ChromaDB read operation failure."""

    def __init__(self, operation: str = "", reason: str = ""):
        """Initialize database read error."""
        details = {}
        if operation:
            details["operation"] = operation
        if reason:
            details["reason"] = reason
        message = "Database read operation failed"
        super().__init__(
            code="DB_READ_ERR", message=message, details=details, status_code=500
        )


class ValidationError(BaseAppError):
    """Data validation errors."""

    def __init__(self, field: str = "", message: str = "", details: dict | None = None):
        """Initialize validation error."""
        err_details = details or {}
        if field:
            err_details["field"] = field
        err_msg = message or "Validation failed"
        super().__init__(
            code="VAL_ERR", message=err_msg, details=err_details, status_code=400
        )


class ConfigurationError(BaseAppError):
    """Configuration or environment errors."""

    def __init__(self, message: str = "", details: dict | None = None):
        """Initialize configuration error."""
        super().__init__(
            code="CONFIG_ERR",
            message=message or "Configuration error",
            details=details or {},
            status_code=500,
        )
