"""SQLite repository implementation with transaction support.

Provides CRUD operations for projects with full ACID compliance.
Uses TransactionManager to ensure data consistency and integrity.

Architecture:
- Clean separation between domain (Project entity) and data layer (repository)
- Custom exceptions for precise error handling
- DRY principle: shared validation logic in private helpers
- Comprehensive logging for debugging and monitoring

Author: ArchitectZero
Created: 2026-02-10
"""

import json
import logging
import sqlite3
from datetime import UTC, datetime
from typing import Any

from ...domain.models.project import Project
from .exceptions import DuplicateError, NotFoundError, TransactionError, ValidationError
from .transaction_manager import TransactionManager

logger = logging.getLogger(__name__)


class SQLiteRepository:
    """Repository for persisting and retrieving projects using SQLite.

    Manages all CRUD operations with transaction support and comprehensive
    error handling. All operations are atomic - either fully succeed or
    fully fail via transaction rollback.

    Usage:
        >>> from infrastructure.persistence.transaction_manager import TransactionManager
        >>> from infrastructure.persistence.sqlite_repository import SQLiteRepository
        >>> from domain.models.project import Project
        >>>
        >>> tx_manager = TransactionManager("/path/to/projects.db")
        >>> repo = SQLiteRepository(tx_manager)
        >>>
        >>> project = Project(
        ...     id="proj_001",
        ...     name="MyApp",
        ...     path="/path/to/myapp"
        ... )
        >>> repo.create_project(project)
        >>> retrieved = repo.get_project("proj_001")
        >>> print(retrieved.name)
        MyApp
    """

    def __init__(self, tx_manager: TransactionManager):
        """Initialize repository with transaction manager.

        Args:
            tx_manager: TransactionManager instance for ACID transactions

        Raises:
            TransactionError: If schema initialization fails
        """
        self.tx_manager = tx_manager
        try:
            self._init_schema()
        except sqlite3.Error as e:
            raise TransactionError(f"Failed to initialize schema: {e}") from e

    def _init_schema(self) -> None:
        """Initialize database schema if not exists.

        Creates the projects table with proper indexes and constraints.
        This is an idempotent operation - safe to call multiple times
        without causing errors or data loss.

        Table Schema:
            - id (TEXT PRIMARY KEY): Unique project identifier
            - name (TEXT NOT NULL): Human-readable project name
            - path (TEXT NOT NULL): Filesystem path to project
            - description (TEXT): Optional project description
            - created_at (TEXT NOT NULL): ISO timestamp of creation
            - updated_at (TEXT NOT NULL): ISO timestamp of last update
            - metadata (TEXT): JSON-encoded custom metadata

        Raises:
            sqlite3.Error: If table creation fails
        """
        with self.tx_manager.transaction() as conn:
            conn.execute("""
                CREATE TABLE IF NOT EXISTS projects (
                    id TEXT PRIMARY KEY,
                    name TEXT NOT NULL UNIQUE,
                    path TEXT NOT NULL,
                    description TEXT,
                    created_at TEXT NOT NULL,
                    updated_at TEXT NOT NULL,
                    metadata TEXT
                )
                """)
            logger.debug("✅ Projects table initialized (idempotent)")

    def create_project(self, project: Project) -> None:
        """Create a new project and persist to database.

        Validates project before insertion and ensures uniqueness.
        Operation is atomic - either fully succeeds or rolls back.

        Args:
            project: Project entity to create

        Raises:
            ValidationError: If project data violates business rules
            DuplicateError: If project with same ID or name already exists
            TransactionError: If database write fails

        Example:
            >>> project = Project(id="p1", name="MyApp", path="/tmp")
            >>> try:
            ...     repo.create_project(project)
            ... except DuplicateError:
            ...     print("Project already exists")
        """
        self._validate_project(project)

        try:
            with self.tx_manager.transaction() as conn:
                # Check for duplicates
                self._check_project_exists_by_id(conn, project.id)

                conn.execute(
                    """
                    INSERT INTO projects
                    (id, name, path, description, created_at, updated_at, metadata)
                    VALUES (?, ?, ?, ?, ?, ?, ?)
                    """,
                    (
                        project.id,
                        project.name,
                        project.path,
                        project.description or "",
                        project.created_at or datetime.now(UTC).isoformat(),
                        datetime.now(UTC).isoformat(),
                        json.dumps(project.metadata or {}),
                    ),
                )
                logger.info(f"✅ Created project: {project.name} (ID: {project.id})")
        except sqlite3.IntegrityError as e:
            if "UNIQUE constraint failed" in str(e):
                raise DuplicateError(
                    f"Project with name '{project.name}' already exists"
                ) from e
            raise TransactionError(f"Integrity constraint violated: {e}") from e
        except sqlite3.Error as e:
            raise TransactionError(f"Failed to create project: {e}") from e

    def get_project(self, project_id: str) -> Project:
        """Retrieve project by ID.

        Args:
            project_id: Unique project identifier

        Returns:
            Project entity

        Raises:
            NotFoundError: If project does not exist
            TransactionError: If database read fails

        Example:
            >>> try:
            ...     project = repo.get_project("proj_001")
            ... except NotFoundError:
            ...     print("Project not found")
        """
        try:
            with self.tx_manager.transaction() as conn:
                row = conn.execute(
                    "SELECT * FROM projects WHERE id = ?", (project_id,)
                ).fetchone()

                if not row:
                    raise NotFoundError(
                        f"Project with ID '{project_id}' not found",
                        entity_type="Project",
                    )

                return self._row_to_project(row)
        except sqlite3.Error as e:
            raise TransactionError(f"Failed to retrieve project: {e}") from e

    def get_project_by_name(self, name: str) -> Project | None:
        """Retrieve project by name.

        Returns first matching project or None if not found.

        Args:
            name: Project name to search for

        Returns:
            Project entity if found, None otherwise

        Raises:
            TransactionError: If database read fails
        """
        try:
            with self.tx_manager.transaction() as conn:
                row = conn.execute(
                    "SELECT * FROM projects WHERE name = ?", (name,)
                ).fetchone()

                if not row:
                    return None

                return self._row_to_project(row)
        except sqlite3.Error as e:
            raise TransactionError(f"Failed to retrieve project by name: {e}") from e

    def list_projects(self) -> list[Project]:
        """List all projects ordered by creation time (newest first).

        Returns:
            List of all Project entities, empty list if none exist

        Raises:
            TransactionError: If database query fails
        """
        try:
            with self.tx_manager.transaction() as conn:
                rows = conn.execute(
                    "SELECT * FROM projects ORDER BY created_at DESC"
                ).fetchall()

                return [self._row_to_project(row) for row in rows]
        except sqlite3.Error as e:
            raise TransactionError(f"Failed to list projects: {e}") from e

    def update_project(self, project: Project) -> None:
        """Update an existing project.

        Validates project and checks existence before update.
        Only the provided fields are updated; created_at is preserved.

        Args:
            project: Updated project entity

        Raises:
            ValidationError: If project data violates business rules
            NotFoundError: If project does not exist
            TransactionError: If database write fails

        Example:
            >>> project.name = "Updated Name"
            >>> try:
            ...     repo.update_project(project)
            ... except NotFoundError:
            ...     print("Cannot update non-existent project")
        """
        self._validate_project(project)

        try:
            with self.tx_manager.transaction() as conn:
                # Verify project exists
                if not self._project_exists_by_id(conn, project.id):
                    raise NotFoundError(
                        f"Cannot update: Project '{project.id}' not found",
                        entity_type="Project",
                    )

                conn.execute(
                    """
                    UPDATE projects
                    SET name = ?, path = ?, description = ?,
                        updated_at = ?, metadata = ?
                    WHERE id = ?
                    """,
                    (
                        project.name,
                        project.path,
                        project.description or "",
                        datetime.now(UTC).isoformat(),
                        json.dumps(project.metadata or {}),
                        project.id,
                    ),
                )
                logger.info(f"✅ Updated project: {project.name}")
        except sqlite3.Error as e:
            raise TransactionError(f"Failed to update project: {e}") from e

    def delete_project(self, project_id: str) -> str:
        """Delete a project by ID.

        Returns the name of deleted project for logging/feedback.

        Args:
            project_id: ID of project to delete

        Returns:
            Name of deleted project

        Raises:
            NotFoundError: If project does not exist
            TransactionError: If database operation fails
        """
        try:
            with self.tx_manager.transaction() as conn:
                # Get project name before deletion
                row = conn.execute(
                    "SELECT name FROM projects WHERE id = ?", (project_id,)
                ).fetchone()

                if not row:
                    raise NotFoundError(
                        f"Cannot delete: Project '{project_id}' not found",
                        entity_type="Project",
                    )

                project_name = row[0]
                conn.execute("DELETE FROM projects WHERE id = ?", (project_id,))
                logger.info(f"✅ Deleted project: {project_name} (ID: {project_id})")
                return project_name
        except sqlite3.Error as e:
            raise TransactionError(f"Failed to delete project: {e}") from e

    def delete_all(self) -> int:
        """Delete all projects. WARNING: Destructive operation.

        Returns the count of deleted projects.
        Used primarily for testing. Use with extreme caution in production.

        Returns:
            Number of projects deleted

        Raises:
            TransactionError: If database operation fails
        """
        try:
            with self.tx_manager.transaction() as conn:
                count = conn.execute("SELECT COUNT(*) FROM projects").fetchone()[0]
                conn.execute("DELETE FROM projects")
                logger.warning(f"⚠️ Deleted ALL {count} projects")
                return count
        except sqlite3.Error as e:
            raise TransactionError(f"Failed to delete all projects: {e}") from e

    def count_projects(self) -> int:
        """Count total number of projects.

        Returns:
            Total project count

        Raises:
            TransactionError: If database query fails
        """
        try:
            with self.tx_manager.transaction() as conn:
                count = conn.execute("SELECT COUNT(*) FROM projects").fetchone()[0]
                return count
        except sqlite3.Error as e:
            raise TransactionError(f"Failed to count projects: {e}") from e

    # ===== PRIVATE HELPERS (DRY Principle) =====

    @staticmethod
    def _validate_project(project: Project) -> None:
        """Validate project entity before database operation.

        Checks all required fields are present and valid.

        Args:
            project: Project entity to validate

        Raises:
            ValidationError: If any validation rule is violated
        """
        if not project.id:
            raise ValidationError("Project ID is required", field_name="id")
        if not project.name:
            raise ValidationError("Project name is required", field_name="name")
        if not project.path:
            raise ValidationError("Project path is required", field_name="path")

        # Ensure name is reasonable length
        if len(project.name) > 255:
            raise ValidationError(
                "Project name must be <= 255 characters", field_name="name"
            )

        # Ensure path is reasonable length
        if len(project.path) > 4096:
            raise ValidationError(
                "Project path must be <= 4096 characters", field_name="path"
            )

    @staticmethod
    def _project_exists_by_id(conn: Any, project_id: str) -> bool:
        """Check if project exists by ID (non-throwing version).

        Args:
            conn: Database connection
            project_id: Project ID to check

        Returns:
            True if project exists, False otherwise
        """
        row = conn.execute(
            "SELECT id FROM projects WHERE id = ?", (project_id,)
        ).fetchone()
        return row is not None

    @staticmethod
    def _check_project_exists_by_id(conn: Any, project_id: str) -> None:
        """Check if project exists by ID (throwing version).

        Args:
            conn: Database connection
            project_id: Project ID to check

        Raises:
            DuplicateError: If project already exists
        """
        if SQLiteRepository._project_exists_by_id(conn, project_id):
            raise DuplicateError(f"Project with ID '{project_id}' already exists")

    @staticmethod
    def _row_to_project(row: tuple[Any, ...]) -> Project:
        """Convert database row tuple to Project entity.

        Handles JSON deserialization of metadata field and
        normalizes empty description strings to None.

        Args:
            row: Tuple from database query (unpacked from SELECT *)
            Format: (id, name, path, description, created_at, updated_at, metadata)

        Returns:
            Project entity with data from row
        """
        return Project(
            id=row[0],
            name=row[1],
            path=row[2],
            description=row[3] if row[3] else None,
            created_at=row[4],
            updated_at=row[5],
            metadata=json.loads(row[6]) if row[6] else {},
        )
