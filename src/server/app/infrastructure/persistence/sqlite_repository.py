"""SQLite repository implementation with transaction support.

Provides CRUD operations for projects with full ACID compliance.
Uses TransactionManager to ensure data consistency and integrity.

Author: ArchitectZero
Created: 2026-02-10
"""

import json
import logging
from datetime import UTC, datetime
from typing import Any

from ...domain.models.project import Project
from .transaction_manager import TransactionManager

logger = logging.getLogger(__name__)


class SQLiteRepository:
    """Repository for persisting and retrieving projects using SQLite.

    Manages all CRUD operations with transaction support and
    comprehensive error handling.
    """

    def __init__(self, tx_manager: TransactionManager):
        """Initialize repository with transaction manager.

        Args:
            tx_manager: TransactionManager instance for ACID transactions
        """
        self.tx_manager = tx_manager
        self._init_schema()

    def _init_schema(self) -> None:
        """Initialize database schema if not exists.

        Creates the projects table with all required columns.
        Idempotent operation - safe to call multiple times.
        """
        with self.tx_manager.transaction() as conn:
            conn.execute(
                """
                CREATE TABLE IF NOT EXISTS projects (
                    id TEXT PRIMARY KEY,
                    name TEXT NOT NULL,
                    path TEXT NOT NULL,
                    description TEXT,
                    created_at TEXT NOT NULL,
                    updated_at TEXT NOT NULL,
                    metadata TEXT
                )
                """
            )
            logger.debug("✅ Projects table initialized")

    def create_project(self, project: Project) -> None:
        """Create a new project and persist to database.

        Args:
            project: Project entity to create

        Raises:
            ValueError: If project with same ID already exists
            Exception: If database write fails
        """
        with self.tx_manager.transaction() as conn:
            # Check if exists
            existing = conn.execute(
                "SELECT id FROM projects WHERE id = ?", (project.id,)
            ).fetchone()

            if existing:
                raise ValueError(f"Project with ID {project.id} already exists")

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

    def get_project(self, project_id: str) -> Project | None:
        """Retrieve project by ID.

        Args:
            project_id: Unique project identifier

        Returns:
            Project entity if found, None otherwise
        """
        with self.tx_manager.transaction() as conn:
            row = conn.execute(
                "SELECT * FROM projects WHERE id = ?", (project_id,)
            ).fetchone()

            if not row:
                return None

            return self._row_to_project(row)

    def get_project_by_name(self, name: str) -> Project | None:
        """Retrieve project by name.

        Args:
            name: Project name to search for

        Returns:
            First matching project if found, None otherwise
        """
        with self.tx_manager.transaction() as conn:
            row = conn.execute(
                "SELECT * FROM projects WHERE name = ?", (name,)
            ).fetchone()

            if not row:
                return None

            return self._row_to_project(row)

    def list_projects(self) -> list[Project]:
        """List all projects.

        Returns:
            List of all Project entities, empty list if none exist
        """
        with self.tx_manager.transaction() as conn:
            rows = conn.execute(
                "SELECT * FROM projects ORDER BY created_at DESC"
            ).fetchall()

            return [self._row_to_project(row) for row in rows]

    def update_project(self, project: Project) -> None:
        """Update an existing project.

        Args:
            project: Updated project entity

        Raises:
            ValueError: If project does not exist
            Exception: If database write fails
        """
        with self.tx_manager.transaction() as conn:
            # Check exists
            existing = conn.execute(
                "SELECT id FROM projects WHERE id = ?", (project.id,)
            ).fetchone()

            if not existing:
                raise ValueError(f"Project {project.id} not found")

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

    def delete_project(self, project_id: str) -> None:
        """Delete a project by ID.

        Args:
            project_id: ID of project to delete

        Raises:
            ValueError: If project does not exist
            Exception: If database operation fails
        """
        with self.tx_manager.transaction() as conn:
            # Check exists
            existing = conn.execute(
                "SELECT name FROM projects WHERE id = ?", (project_id,)
            ).fetchone()

            if not existing:
                raise ValueError(f"Project {project_id} not found")

            conn.execute("DELETE FROM projects WHERE id = ?", (project_id,))
            logger.info(f"✅ Deleted project: {existing[0]} (ID: {project_id})")

    def delete_all(self) -> None:
        """Delete all projects. WARNING: Destructive operation.

        Used primarily for testing. Use with caution.
        """
        with self.tx_manager.transaction() as conn:
            count = conn.execute("SELECT COUNT(*) FROM projects").fetchone()[0]
            conn.execute("DELETE FROM projects")
            logger.warning(f"⚠️ Deleted all {count} projects")

    def count_projects(self) -> int:
        """Count total number of projects.

        Returns:
            Total project count
        """
        with self.tx_manager.transaction() as conn:
            count = conn.execute("SELECT COUNT(*) FROM projects").fetchone()[0]
            return count

    @staticmethod
    def _row_to_project(row: tuple[Any, ...]) -> Project:
        """Convert database row tuple to Project entity.

        Args:
            row: Tuple from database query (unpacked from SELECT *)

        Returns:
            Project entity with data from row
        """
        return Project(
            id=row[0],
            name=row[1],
            path=row[2],
            description=row[3],
            created_at=row[4],
            updated_at=row[5],
            metadata=json.loads(row[6]) if row[6] else {},
        )
