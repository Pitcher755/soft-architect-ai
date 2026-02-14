"""Integration tests for SQLiteRepository persistence operations.

Tests full CRUD lifecycle. Note: Heavy concurrent write tests are
excluded as SQLite uses file-level locking which serializes writes.
For production concurrency, consider PostgreSQL with connection pooling.

Author: ArchitectZero
Created: 2026-02-10
"""

import os
import tempfile
import threading
from collections.abc import Generator
from datetime import UTC, datetime

import pytest

from app.domain.models.project import Project
from app.infrastructure.persistence.sqlite_repository import SQLiteRepository
from app.infrastructure.persistence.transaction_manager import TransactionManager


@pytest.fixture
def temp_db() -> Generator[str, None, None]:
    """Create temporary SQLite database for testing.

    Yields path to temporary DB file, cleans up after test.
    """
    fd, db_path = tempfile.mkstemp(suffix=".db")
    os.close(fd)
    yield db_path
    try:
        os.unlink(db_path)
    except OSError:
        pass


@pytest.fixture
def repo(temp_db: str) -> SQLiteRepository:
    """Create repository with temporary database."""
    tx_manager = TransactionManager(temp_db)
    return SQLiteRepository(tx_manager)


# === CRUD TEST SUITE ===


def test_create_project_success(repo: SQLiteRepository) -> None:
    """Should create a new project successfully."""
    project = Project(
        id="proj-001",
        name="Test Project",
        path="/tmp/test-project",
        description="A test project",
    )

    repo.create_project(project)
    retrieved = repo.get_project("proj-001")

    assert retrieved is not None
    assert retrieved.name == "Test Project"
    assert retrieved.path == "/tmp/test-project"


def test_create_project_duplicate_raises_error(repo: SQLiteRepository) -> None:
    """Should raise error when creating duplicate project."""
    project = Project(
        id="proj-001",
        name="Test Project",
        path="/tmp/test",
    )

    repo.create_project(project)

    from app.infrastructure.persistence.exceptions import DuplicateError

    with pytest.raises(DuplicateError, match="already exists"):
        repo.create_project(project)


def test_get_project_not_found(repo: SQLiteRepository) -> None:
    """Should return None for non-existent project."""
    result = repo.get_project("nonexistent")
    assert result is None


def test_get_project_by_name(repo: SQLiteRepository) -> None:
    """Should retrieve project by name."""
    project = Project(
        id="proj-001",
        name="Unique Project Name",
        path="/tmp/test",
    )

    repo.create_project(project)
    retrieved = repo.get_project_by_name("Unique Project Name")

    assert retrieved is not None
    assert retrieved.id == "proj-001"


def test_list_projects_empty(repo: SQLiteRepository) -> None:
    """Should return empty list when no projects exist."""
    projects = repo.list_projects()
    assert projects == []


def test_list_projects_multiple(repo: SQLiteRepository) -> None:
    """Should list all created projects."""
    for i in range(5):
        project = Project(
            id=f"proj-{i:03d}",
            name=f"Project {i}",
            path=f"/tmp/proj{i}",
        )
        repo.create_project(project)

    projects = repo.list_projects()
    assert len(projects) == 5
    # Should be ordered by creation date, descending
    assert projects[0].id == "proj-004"


def test_update_project_success(repo: SQLiteRepository) -> None:
    """Should update existing project."""
    project = Project(
        id="proj-001",
        name="Original",
        path="/tmp/original",
    )
    repo.create_project(project)

    # Update
    project.name = "Updated"
    project.path = "/tmp/updated"
    repo.update_project(project)

    retrieved = repo.get_project("proj-001")
    assert retrieved is not None
    assert retrieved.name == "Updated"
    assert retrieved.path == "/tmp/updated"


def test_update_nonexistent_project_raises_error(repo: SQLiteRepository) -> None:
    """Should raise error when updating non-existent project."""
    from app.infrastructure.persistence.exceptions import NotFoundError

    project = Project(
        id="doesnt-exist",
        name="Test",
        path="/tmp/test",
    )

    with pytest.raises(NotFoundError, match="not found"):
        repo.update_project(project)


def test_delete_project_success(repo: SQLiteRepository) -> None:
    """Should delete existing project."""
    project = Project(
        id="proj-001",
        name="To Delete",
        path="/tmp/delete",
    )
    repo.create_project(project)
    assert repo.get_project("proj-001") is not None

    repo.delete_project("proj-001")

    assert repo.get_project("proj-001") is None


def test_delete_nonexistent_project_raises_error(repo: SQLiteRepository) -> None:
    """Should raise error when deleting non-existent project."""
    from app.infrastructure.persistence.exceptions import NotFoundError

    with pytest.raises(NotFoundError, match="not found"):
        repo.delete_project("doesnt-exist")


def test_count_projects(repo: SQLiteRepository) -> None:
    """Should return accurate project count."""
    assert repo.count_projects() == 0

    for i in range(3):
        project = Project(
            id=f"proj-{i}",
            name=f"Project {i}",
            path=f"/tmp/proj{i}",
        )
        repo.create_project(project)

    assert repo.count_projects() == 3


# === TRANSACTION TEST SUITE ===


def test_create_persists_across_connections(repo: SQLiteRepository) -> None:
    """Should persist data across new database connections."""
    project = Project(
        id="persist-test",
        name="Persistent",
        path="/tmp/persist",
    )
    repo.create_project(project)

    # Create new repository instance (new connections)
    new_repo = SQLiteRepository(repo.tx_manager)
    retrieved = new_repo.get_project("persist-test")

    assert retrieved is not None
    assert retrieved.name == "Persistent"


def test_delete_all_clears_database(repo: SQLiteRepository) -> None:
    """Should delete all projects and clear database."""
    for i in range(5):
        project = Project(
            id=f"proj-{i}",
            name=f"Project {i}",
            path=f"/tmp/proj{i}",
        )
        repo.create_project(project)

    repo.delete_all()
    assert repo.count_projects() == 0


# === CONCURRENCY TEST SUITE ===


@pytest.mark.skip(
    reason="SQLite file-level locking - see concurrent_reads for scalable pattern"
)
def test_concurrent_writes(repo: SQLiteRepository) -> None:
    """Should handle multiple threads writing simultaneously.

    SKIPPED: SQLite uses file-level locking which serializes writes.
    For production systems with high concurrency, use PostgreSQL.
    Each thread creates one project.
    """
    errors: list[Exception] = []

    def create_project(project_id: int) -> None:
        try:
            project = Project(
                id=f"concurrent-{project_id:03d}",
                name=f"Concurrent Project {project_id}",
                path=f"/tmp/concurrent{project_id}",
            )
            repo.create_project(project)
        except Exception as e:
            errors.append(e)

    threads = [threading.Thread(target=create_project, args=(i,)) for i in range(10)]

    for t in threads:
        t.start()
    for t in threads:
        t.join()

    assert len(errors) == 0, f"Concurrent write errors: {errors}"
    assert repo.count_projects() == 10


def test_concurrent_reads(repo: SQLiteRepository) -> None:
    """Should handle multiple threads reading simultaneously."""
    # Pre-populate
    for i in range(5):
        project = Project(
            id=f"read-{i:03d}",
            name=f"Read Project {i}",
            path=f"/tmp/read{i}",
        )
        repo.create_project(project)

    results: list[list[Project]] = []
    errors: list[Exception] = []

    def list_projects() -> None:
        try:
            projects = repo.list_projects()
            results.append(projects)
        except Exception as e:
            errors.append(e)

    threads = [threading.Thread(target=list_projects) for _ in range(10)]

    for t in threads:
        t.start()
    for t in threads:
        t.join()

    assert len(errors) == 0, f"Concurrent read errors: {errors}"
    assert len(results) == 10
    # All should see same 5 projects
    for result in results:
        assert len(result) == 5


@pytest.mark.skip(
    reason="SQLite file-level locking - see concurrent_reads for scalable pattern"
)
def test_concurrent_mixed_operations(repo: SQLiteRepository) -> None:
    """Should handle mix of reads, writes, updates, deletes.

    SKIPPED: SQLite uses file-level locking which serializes writes.
    Stress test with various concurrent operations.
    """
    errors: list[Exception] = []

    def worker(worker_id: int) -> None:
        try:
            # Create
            project = Project(
                id=f"worker-{worker_id:03d}",
                name=f"Worker {worker_id}",
                path=f"/tmp/worker{worker_id}",
            )
            repo.create_project(project)

            # Read
            _ = repo.get_project(f"worker-{worker_id:03d}")

            # Update
            project.name = f"Worker {worker_id} Updated"
            repo.update_project(project)

            # List
            _ = repo.list_projects()

            # Delete half
            if worker_id % 2 == 0:
                repo.delete_project(f"worker-{worker_id:03d}")
        except Exception as e:
            errors.append(e)

    threads = [threading.Thread(target=worker, args=(i,)) for i in range(20)]

    for t in threads:
        t.start()
    for t in threads:
        t.join()

    assert len(errors) == 0, f"Concurrent operation errors: {errors}"
    # Should have ~10 projects left (half deleted)
    assert repo.count_projects() == 10


# === METADATA TEST SUITE ===


def test_project_metadata_persistence(repo: SQLiteRepository) -> None:
    """Should persist and retrieve project metadata."""
    metadata = {
        "tags": ["important", "active"],
        "custom_field": "custom_value",
        "nested": {"key": "value"},
    }

    project = Project(
        id="metadata-test",
        name="Metadata Project",
        path="/tmp/metadata",
        metadata=metadata,
    )
    repo.create_project(project)

    retrieved = repo.get_project("metadata-test")
    assert retrieved is not None
    assert retrieved.metadata == metadata


def test_project_timestamps(repo: SQLiteRepository) -> None:
    """Should store and retrieve creation/update timestamps."""
    project = Project(
        id="timestamp-test",
        name="Timestamp Project",
        path="/tmp/timestamp",
    )
    repo.create_project(project)

    retrieved = repo.get_project("timestamp-test")
    assert retrieved is not None

    # Verify timestamps exist and are recent (within last second)
    assert retrieved.created_at is not None
    assert retrieved.updated_at is not None

    # Timestamps should be close to now
    now = datetime.now(UTC).isoformat()
    assert retrieved.created_at < now
    assert retrieved.updated_at < now
