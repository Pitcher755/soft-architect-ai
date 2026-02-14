"""
Application-specific exceptions.

Custom exceptions for RAG and business logic errors.
"""

from typing import Any


class BaseAppError(Exception):
    """Base class for all application errors."""

    code: str
    message: str
    status_code: int
    details: dict[str, Any]

    def __init__(
        self,
        code: str,
        message: str,
        status_code: int = 500,
        details: dict[str, Any] | None = None,
    ):
        """
        Initialize base app error.

        Args:
            code: Error code (e.g., "RAG_001", "SYS_001")
            message: Human-readable error message
            status_code: HTTP status code (default: 500)
            details: Optional additional error details
        """
        self.code = code
        self.message = message
        self.status_code = status_code
        self.details = details or {}
        super().__init__(self.message)

    def to_dict(self) -> dict[str, Any]:
        """Convert exception to dictionary for API response."""
        return {
            "error_code": self.code,
            "error_message": self.message,
            "status_code": self.status_code,
            "details": self.details,
        }


class VectorStoreError(BaseAppError):
    """Vector store / ChromaDB operation failed."""

    def __init__(
        self,
        code: str = "RAG_001",
        message: str = "Vector store operation failed",
        status_code: int = 500,
        details: dict[str, Any] | None = None,
    ):
        """
        Initialize vector store error.

        Args:
            code: Error code (default: "RAG_001")
            message: Human-readable error message
            status_code: HTTP status code (default: 500)
            details: Optional additional error details
        """
        super().__init__(code, message, status_code, details)


class QueryError(BaseAppError):
    """Query operation failed."""

    def __init__(
        self,
        code: str = "RAG_002",
        message: str = "Query operation failed",
        status_code: int = 500,
        details: dict[str, Any] | None = None,
    ):
        """
        Initialize query error.

        Args:
            code: Error code (default: "RAG_002")
            message: Human-readable error message
            status_code: HTTP status code (default: 500)
            details: Optional additional error details
        """
        super().__init__(code, message, status_code, details)


class RAGError(BaseAppError):
    """RAG operation failed."""

    def __init__(
        self,
        code: str = "RAG_001",
        message: str = "RAG operation failed",
        status_code: int = 500,
        details: dict[str, Any] | None = None,
    ):
        """
        Initialize RAG error.

        Args:
            code: Error code (default: "RAG_001")
            message: Human-readable error message
            status_code: HTTP status code (default: 500)
            details: Optional additional error details
        """
        super().__init__(code, message, status_code, details)


class LLMError(BaseAppError):
    """LLM operation failed."""

    def __init__(
        self,
        code: str = "LLM_001",
        message: str = "LLM operation failed",
        status_code: int = 500,
        details: dict[str, Any] | None = None,
    ):
        """
        Initialize LLM error.

        Args:
            code: Error code (default: "LLM_001")
            message: Human-readable error message
            status_code: HTTP status code (default: 500)
            details: Optional additional error details
        """
        super().__init__(code, message, status_code, details)


class TemplateNotFoundError(BaseAppError):
    """Template file not found."""

    def __init__(
        self,
        template_name: str,
        code: str = "TEMPLATE_001",
        message: str | None = None,
        status_code: int = 500,
        details: dict[str, Any] | None = None,
    ):
        """
        Initialize template not found error.

        Args:
            template_name: Name of the missing template
            code: Error code (default: "TEMPLATE_001")
            message: Custom message (default: template-based)
            status_code: HTTP status code (default: 500)
            details: Optional additional error details
        """
        final_message = message or f"Template '{template_name}' not found"
        final_details = details or {}
        final_details["template"] = template_name
        super().__init__(code, final_message, status_code, final_details)


class StreamError(BaseAppError):
    """SSE streaming operation failed."""

    def __init__(
        self,
        code: str = "STREAM_001",
        message: str = "Stream operation failed",
        status_code: int = 500,
        details: dict[str, Any] | None = None,
    ):
        """
        Initialize stream error.

        Args:
            code: Error code (default: "STREAM_001")
            message: Human-readable error message
            status_code: HTTP status code (default: 500)
            details: Optional additional error details
        """
        super().__init__(code, message, status_code, details)


class StreamingError(BaseAppError):
    """WebSocket streaming operation failed."""

    operation: str

    def __init__(
        self,
        code: str,
        message: str,
        operation: str,
        status_code: int = 500,
        details: dict[str, Any] | None = None,
    ) -> None:
        """
        Initialize streaming error.

        Args:
            code: Error code (e.g., "WS_STREAM_FAILED")
            message: Human-readable error message
            operation: Name of the streaming operation
            status_code: HTTP status code (default: 500)
            details: Optional additional error details
        """
        self.operation = operation
        final_details = details or {}
        final_details["operation"] = operation
        super().__init__(code, message, status_code, final_details)


class ValidationError(BaseAppError):
    """Raised when document validation fails."""

    operation: str

    def __init__(
        self,
        code: str,
        message: str,
        operation: str,
        status_code: int = 400,
        details: dict[str, Any] | None = None,
    ) -> None:
        """
        Initialize validation error.

        Args:
            code: Error code (VAL_001, VAL_002, etc.)
            message: Human-readable error message in Spanish
            operation: Name of the validation operation that failed
            status_code: HTTP status code (default: 400)
            details: Optional additional error details
        """
        self.operation = operation
        final_details = details or {}
        final_details["operation"] = operation
        super().__init__(code, message, status_code, final_details)


class RetryExhaustedError(BaseAppError):
    """Raised when all retry attempts are exhausted."""

    operation: str
    attempts: int
    last_error: str

    def __init__(
        self,
        operation: str,
        attempts: int,
        last_error: str,
        status_code: int = 503,
    ) -> None:
        """
        Initialize retry exhausted error.

        Args:
            operation: Name of the operation that failed
            attempts: Number of retry attempts made
            last_error: Error message from the last failed attempt
            status_code: HTTP status code (default: 503)
        """
        self.operation = operation
        self.attempts = attempts
        self.last_error = last_error
        super().__init__(
            code="SYS_RETRY_EXHAUSTED",
            message=f"Operación fallida después de {attempts} intentos: {last_error}",
            status_code=status_code,
            details={
                "operation": operation,
                "attempts": attempts,
                "last_error": last_error,
            },
        )


class LLMConnectionError(BaseAppError):
    """LLM engine is unreachable or connection failed."""

    def __init__(
        self,
        message: str = "Unable to connect to AI engine",
        details: dict[str, Any] | None = None,
    ) -> None:
        super().__init__(
            code="LLM_001",
            message=message,
            status_code=503,
            details=details,
        )


class LLMTimeoutError(BaseAppError):
    """LLM request timed out."""

    def __init__(
        self,
        message: str = "AI engine request timed out",
        details: dict[str, Any] | None = None,
    ) -> None:
        super().__init__(
            code="LLM_002",
            message=message,
            status_code=504,
            details=details,
        )


class RAGRetrievalError(BaseAppError):
    """Knowledge base search failed."""

    def __init__(
        self,
        message: str = "Knowledge base search failed",
        details: dict[str, Any] | None = None,
    ) -> None:
        super().__init__(
            code="RAG_001",
            message=message,
            status_code=500,
            details=details,
        )
