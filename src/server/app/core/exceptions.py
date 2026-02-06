"""
Application-specific exceptions.

Custom exceptions for RAG and business logic errors.
"""

from typing import Any


class BaseAppError(Exception):
    """Base class for all application errors."""

    def __init__(
        self,
        code: str,
        message: str,
        details: dict[str, Any] | None = None,
    ):
        """
        Initialize base app error.

        Args:
            code: Error code (e.g., "RAG_001", "SYS_001")
            message: Human-readable error message
            details: Optional additional error details
        """
        self.code = code
        self.message = message
        self.details = details or {}
        super().__init__(self.message)


class VectorStoreError(BaseAppError):
    """Vector store / ChromaDB operation failed."""

    def __init__(
        self,
        code: str = "RAG_001",
        message: str = "Vector store operation failed",
        details: dict[str, Any] | None = None,
    ):
        """
        Initialize vector store error.

        Args:
            code: Error code (default: "RAG_001")
            message: Human-readable error message
            details: Optional additional error details
        """
        super().__init__(code, message, details)


class QueryError(BaseAppError):
    """Query operation failed."""

    def __init__(
        self,
        code: str = "RAG_002",
        message: str = "Query operation failed",
        details: dict[str, Any] | None = None,
    ):
        """
        Initialize query error.

        Args:
            code: Error code (default: "RAG_002")
            message: Human-readable error message
            details: Optional additional error details
        """
        super().__init__(code, message, details)


class RAGError(BaseAppError):
    """RAG operation failed."""

    def __init__(
        self,
        code: str = "RAG_001",
        message: str = "RAG operation failed",
        details: dict[str, Any] | None = None,
    ):
        """
        Initialize RAG error.

        Args:
            code: Error code (default: "RAG_001")
            message: Human-readable error message
            details: Optional additional error details
        """
        super().__init__(code, message, details)


class LLMError(BaseAppError):
    """LLM operation failed."""

    def __init__(
        self,
        code: str = "LLM_001",
        message: str = "LLM operation failed",
        details: dict[str, Any] | None = None,
    ):
        """
        Initialize LLM error.

        Args:
            code: Error code (default: "LLM_001")
            message: Human-readable error message
            details: Optional additional error details
        """
        super().__init__(code, message, details)


class TemplateNotFoundError(BaseAppError):
    """Template file not found."""

    def __init__(
        self,
        template_name: str,
        code: str = "TEMPLATE_001",
        message: str | None = None,
        details: dict[str, Any] | None = None,
    ):
        """
        Initialize template not found error.

        Args:
            template_name: Name of the missing template
            code: Error code (default: "TEMPLATE_001")
            message: Custom message (default: template-based)
            details: Optional additional error details
        """
        final_message = message or f"Template '{template_name}' not found"
        super().__init__(code, final_message, details or {"template": template_name})


class StreamError(BaseAppError):
    """SSE streaming operation failed."""

    def __init__(
        self,
        code: str = "STREAM_001",
        message: str = "Stream operation failed",
        details: dict[str, Any] | None = None,
    ):
        """
        Initialize stream error.

        Args:
            code: Error code (default: "STREAM_001")
            message: Human-readable error message
            details: Optional additional error details
        """
        super().__init__(code, message, details)
