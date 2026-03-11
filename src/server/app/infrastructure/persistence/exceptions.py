"""Persistence layer exceptions.

Custom exception types for repository and transaction operations.
Provides clear error categorization without exposing internal implementation.

Author: ArchitectZero
Created: 2026-02-10
"""


class PersistenceError(Exception):
    """Base exception for all persistence-related errors.

    This is the parent class for all errors that occur during
    database operations. Use specific subclasses for more granular
    error handling.

    Example:
        >>> try:
        ...     repo.create_project(project)
        ... except PersistenceError as e:
        ...     logger.error(f"Database operation failed: {e}")
    """

    def __init__(self, message: str, code: str | None = None):
        """Initialize persistence error.

        Args:
            message: Human-readable error description
            code: Optional error code for categorization (e.g., "DB_001")
        """
        self.message = message
        self.code = code or "PERSISTENCE_ERROR"
        super().__init__(f"[{self.code}] {message}")


class ValidationError(PersistenceError):
    """Raised when entity validation fails.

    Indicates that an entity violates business rules (e.g., required
    field missing, invalid format, duplicate key).

    Example:
        >>> if not project.name:
        ...     raise ValidationError("Project name required", code="VALIDATION_001")
    """

    def __init__(self, message: str, field_name: str | None = None):
        """Initialize validation error.

        Args:
            message: Description of validation failure
            field_name: Name of field that failed validation
        """
        self.field_name = field_name
        code = (
            f"VALIDATION_001_{field_name.upper()}" if field_name else "VALIDATION_001"
        )
        super().__init__(message, code)


class NotFoundError(PersistenceError):
    """Raised when requested entity does not exist.

    Indicates that a query returned no results when one was expected.

    Example:
        >>> if not result:
        ...     raise NotFoundError("Project with ID 'xyz' not found", code="NOT_FOUND_001")
    """

    def __init__(self, message: str, entity_type: str | None = None):
        """Initialize not found error.

        Args:
            message: Description of what wasn't found
            entity_type: Type of entity (e.g., "Project", "Settings")
        """
        self.entity_type = entity_type
        code = f"NOT_FOUND_{entity_type.upper()}" if entity_type else "NOT_FOUND_001"
        super().__init__(message, code)


class DuplicateError(PersistenceError):
    """Raised when attempting to create duplicate entity.

    Indicates that an entity already exists with the same unique key.

    Example:
        >>> if existing_project:
        ...     raise DuplicateError("Project with name 'MyApp' already exists")
    """

    def __init__(self, message: str):
        """Initialize duplicate error."""
        super().__init__(message, "DUPLICATE_001")


class TransactionError(PersistenceError):
    """Raised when transaction commit or rollback fails.

    Indicates database-level transaction management failure,
    not validation or constraint errors.

    Example:
        >>> try:
        ...     with tx_manager.transaction() as conn:
        ...         # database operations
        ... except sqlite3.Error as e:
        ...     raise TransactionError(f"Transaction failed: {e}") from e
    """

    def __init__(self, message: str):
        """Initialize transaction error."""
        super().__init__(message, "TRANSACTION_ERROR")


class ConnectionError(PersistenceError):
    """Raised when database connection fails.

    Indicates inability to establish or maintain database connection.

    Example:
        >>> if db_unreachable:
        ...     raise ConnectionError("Cannot connect to database at /path/to/db.sqlite3")
    """

    def __init__(self, message: str):
        """Initialize connection error."""
        super().__init__(message, "CONNECTION_ERROR")
