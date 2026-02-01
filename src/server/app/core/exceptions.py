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
