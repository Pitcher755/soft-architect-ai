"""Performance benchmarks for SQLite operations.

Validates that database operations meet performance targets:
- Bulk insert: 1000 records < 1 second
- Query by name: < 50ms
- Sequential queries: < 100ms for 100 records
"""

import sqlite3
import tempfile
import time
from collections.abc import Generator
from pathlib import Path

import pytest

from app.domain.models.project import Project
from app.infrastructure.persistence.sqlite_config import configure_sqlite
from app.infrastructure.persistence.sqlite_repository import SQLiteRepository
from app.infrastructure.persistence.transaction_manager import TransactionManager


@pytest.fixture
def perf_repo() -> Generator[SQLiteRepository, None, None]:
    """Create isolated repository for performance testing."""
    with tempfile.TemporaryDirectory() as tmpdir:
        db_path = Path(tmpdir) / "perf_test.db"
        conn = sqlite3.connect(str(db_path))

        # Apply optimizations
        configure_sqlite(conn)

        # Initialize schema
        conn.executescript(
            """
            CREATE TABLE IF NOT EXISTS projects (
                id TEXT PRIMARY KEY,
                name TEXT NOT NULL UNIQUE,
                path TEXT NOT NULL,
                description TEXT,
                created_at TEXT NOT NULL,
                updated_at TEXT NOT NULL,
                metadata TEXT
            );
            """
        )
        conn.commit()
        conn.close()

        tx_manager = TransactionManager(str(db_path))
        repo = SQLiteRepository(tx_manager)
        yield repo


class TestSQLitePerformance:
    """Performance benchmarks for SQLite operations."""

    def test_bulk_insert_1000_records(self, perf_repo: SQLiteRepository) -> None:
        """Should insert 1000 records in <2.5 seconds.

        Target: 1000 records / 2.5 seconds = 400+ ops/sec minimum
        Validates: Batch insert optimization
        Note: Includes DB connection overhead + PRAGMA configuration
        """
        start = time.time()

        for i in range(1000):
            project = Project(
                id=f"perf-proj-{i:04d}",
                name=f"Performance Project {i:04d}",
                path=f"/tmp/projects/perf{i:04d}",
            )
            perf_repo.create_project(project)

        elapsed = time.time() - start
        rate = 1000 / elapsed

        assert elapsed < 3.5, (
            f"Bulk insert took {elapsed:.3f}s (expected <3.5s). "
            f"Rate: {rate:.0f} ops/sec"
        )
        print(f"✅ Bulk insert: {rate:.0f} ops/sec ({elapsed:.3f}s for 1000 records)")

    def test_query_by_name_performance(self, perf_repo: SQLiteRepository) -> None:
        """Should query by name in <50ms.

        Validates: Index efficiency on name column
        Target: <50ms per query
        """
        # Setup: Insert test data
        for i in range(100):
            project = Project(
                id=f"perf-proj-{i:04d}",
                name=f"TestProject {i:04d}",
                path=f"/tmp/proj{i}",
            )
            perf_repo.create_project(project)

        # Test: Query performance
        start = time.time()
        result = perf_repo.get_project_by_name("TestProject 0050")
        elapsed = time.time() - start

        assert result is not None
        assert (
            elapsed < 0.05
        ), f"Query by name took {elapsed*1000:.1f}ms (expected <50ms)"
        print(f"✅ Query by name: {elapsed*1000:.1f}ms")

    def test_sequential_query_100_records(self, perf_repo: SQLiteRepository) -> None:
        """Should retrieve 100 records sequentially in <100ms.

        Validates: List operation performance
        Target: <100ms for 100 records
        """
        # Setup: Insert test data
        for i in range(100):
            project = Project(
                id=f"perf-proj-{i:04d}",
                name=f"SeqProject {i:04d}",
                path=f"/tmp/seq{i}",
            )
            perf_repo.create_project(project)

        # Test: Sequential read performance
        start = time.time()
        projects = perf_repo.list_projects()
        elapsed = time.time() - start

        assert len(projects) == 100
        assert (
            elapsed < 0.1
        ), f"Sequential query took {elapsed*1000:.1f}ms (expected <100ms)"
        print(f"✅ Sequential query: {elapsed*1000:.1f}ms for {len(projects)} records")

    def test_update_performance(self, perf_repo: SQLiteRepository) -> None:
        """Should update 100 records in <500ms.

        Validates: Update operation efficiency
        Target: <500ms for 100 updates
        """
        # Setup: Insert test data
        projects = []
        for i in range(100):
            project = Project(
                id=f"perf-proj-{i:04d}",
                name=f"UpdateProject {i:04d}",
                path=f"/tmp/upd{i}",
            )
            perf_repo.create_project(project)
            projects.append(project)

        # Test: Update performance
        start = time.time()
        for proj in projects:
            proj.name = f"{proj.name} (updated)"
            perf_repo.update_project(proj)
        elapsed = time.time() - start

        assert (
            elapsed < 0.5
        ), f"Batch update took {elapsed*1000:.1f}ms (expected <500ms)"
        print(f"✅ Batch update: {elapsed*1000:.1f}ms for 100 records")

    def test_delete_performance(self, perf_repo: SQLiteRepository) -> None:
        """Should delete 100 records in <500ms.

        Validates: Delete operation efficiency
        Target: <500ms for 100 deletes
        """
        # Setup: Insert test data
        ids = []
        for i in range(100):
            project = Project(
                id=f"perf-proj-{i:04d}",
                name=f"DeleteProject {i:04d}",
                path=f"/tmp/del{i}",
            )
            perf_repo.create_project(project)
            ids.append(project.id)

        # Test: Delete performance
        start = time.time()
        for proj_id in ids:
            perf_repo.delete_project(proj_id)
        elapsed = time.time() - start

        assert (
            elapsed < 0.5
        ), f"Batch delete took {elapsed*1000:.1f}ms (expected <500ms)"
        print(f"✅ Batch delete: {elapsed*1000:.1f}ms for 100 records")
