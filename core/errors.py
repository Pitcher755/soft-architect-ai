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


class ValidationError(APIError):
    """Validation errors for input data (API_VAL_XXX)."""

    def __init__(
        self,
        message: str,
        field_name: str | None = None,
        details: dict[str, Any] | None = None,
    ):
        final_details = details or {}
        if field_name:
            final_details["field"] = field_name
        super().__init__(
            code="API_VAL_001",
            message=message,
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            details=final_details,
        )


class NotFoundError(APIError):
    """Resource not found errors (API_NOT_FOUND_XXX)."""

    def __init__(
        self,
        message: str,
        entity_type: str | None = None,
        details: dict[str, Any] | None = None,
    ):
        final_details = details or {}
        if entity_type:
            final_details["entity_type"] = entity_type
        super().__init__(
            code="API_NOT_FOUND_001",
            message=message,
            status_code=status.HTTP_404_NOT_FOUND,
            details=final_details,
        )


class ConflictError(APIError):
    """Conflict errors (duplicate resources, etc.) (API_CONFLICT_XXX)."""

    def __init__(
        self,
        message: str,
        resource: str | None = None,
        details: dict[str, Any] | None = None,
    ):
        final_details = details or {}
        if resource:
            final_details["resource"] = resource
        super().__init__(
            code="API_CONFLICT_001",
            message=message,
            status_code=status.HTTP_409_CONFLICT,
            details=final_details,
        )


class UnauthorizedError(APIError):
    """Authentication/authorization errors (API_AUTH_XXX)."""

    def __init__(self, message: str, details: dict[str, Any] | None = None):
        super().__init__(
            code="API_AUTH_001",
            message=message,
            status_code=status.HTTP_401_UNAUTHORIZED,
            details=details,
        )


class ForbiddenError(APIError):
    """Permission/access denial errors (API_FORBIDDEN_XXX)."""

    def __init__(self, message: str, details: dict[str, Any] | None = None):
        super().__init__(
            code="API_FORBIDDEN_001",
            message=message,
            status_code=status.HTTP_403_FORBIDDEN,
            details=details,
        )


class TransactionError(DatabaseError):
    """Database transaction errors (DB_TXN_XXX)."""

    def __init__(
        self,
        message: str,
        operation: str | None = None,
        details: dict[str, Any] | None = None,
    ):
        final_details = details or {}
        if operation:
            final_details["operation"] = operation
        super().__init__(
            code="DB_TXN_001",
            message=message,
            details=final_details,
        )


class ConnectionError(DatabaseError):
    """Database connection errors (DB_CONN_XXX)."""

    def __init__(self, message: str, details: dict[str, Any] | None = None):
        super().__init__(
            code="DB_CONN_001",
            message=message,
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
