"""
Custom error handling system.

Based on: context/30-ARCHITECTURE/ERROR_HANDLING_STANDARD.en.md

Error Code Format: {CATEGORY}_{NUMBER}
Categories:
- SYS: System-level errors (001-099)
- API: API-specific errors (001-099)
- RAG: RAG engine errors (001-099)
- DB: Database errors (001-099)
"""

from typing import Any

from fastapi import status


class AppBaseError(Exception):
    """Base class for all application errors."""

    def __init__(
        self,
        code: str,
        message: str,
        status_code: int = status.HTTP_500_INTERNAL_SERVER_ERROR,
        details: dict[str, Any] | None = None,
    ):
        self.code = code
        self.message = message
        self.status_code = status_code
        self.details = details or {}
        super().__init__(self.message)


class SystemError(AppBaseError):
    """System-level errors (SYS_XXX)."""

    def __init__(self, code: str, message: str, details: dict[str, Any] | None = None):
        super().__init__(
            code=code,
            message=message,
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            details=details,
        )


class APIError(AppBaseError):
    """API-specific errors (API_XXX)."""

    def __init__(
        self,
        code: str,
        message: str,
        status_code: int = status.HTTP_400_BAD_REQUEST,
        details: dict[str, Any] | None = None,
    ):
        super().__init__(
            code=code,
            message=message,
            status_code=status_code,
            details=details,
        )


class RAGError(AppBaseError):
    """RAG engine errors (RAG_XXX)."""

    def __init__(self, code: str, message: str, details: dict[str, Any] | None = None):
        super().__init__(
            code=code,
            message=message,
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            details=details,
        )


class DatabaseError(AppBaseError):
    """Database errors (DB_XXX)."""

    def __init__(self, code: str, message: str, details: dict[str, Any] | None = None):
        super().__init__(
            code=code,
            message=message,
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            details=details,
        )


# Predefined error instances (based on ERROR_HANDLING_STANDARD.md)
SYS_001_CONNECTION_REFUSED = SystemError(
    code="SYS_001",
    message="Cannot connect to external service",
)

API_001_INVALID_INPUT = APIError(
    code="API_001",
    message="Invalid input parameters",
    status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
)

DB_001_CHROMADB_UNAVAILABLE = DatabaseError(
    code="DB_001",
    message="ChromaDB is not available",
)
