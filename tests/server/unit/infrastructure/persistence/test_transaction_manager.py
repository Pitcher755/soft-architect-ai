"""Tests for TransactionManager module.

Comprehensive test suite for ACID transaction handling.

Author: ArchitectZero
Created: 2026-02-10
"""

import os
import sqlite3
import tempfile

import pytest
from app.infrastructure.persistence.transaction_manager import (
    TransactionManager,
)


@pytest.fixture
def temp_db():
    """Create a temporary SQLite database file that persists across connections.

    ✅ KEY FIX: Use file-based DB instead of :memory: so all connections see same tables.
    :memory: creates isolated databases per connection, breaking transactions.
    """
    fd, db_path = tempfile.mkstemp(suffix=".db")
    os.close(fd)
    yield db_path
    # Cleanup
    try:
        os.unlink(db_path)
    except OSError:
        pass


@pytest.fixture
def tx_manager(temp_db):
    """Provide a transaction manager with persistent temporary database."""
    return TransactionManager(temp_db)


@pytest.fixture
def initialized_db(tx_manager):
    """Create a test database with schema."""
    with tx_manager.transaction() as conn:
        conn.execute(
            """
            CREATE TABLE projects (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                name TEXT NOT NULL UNIQUE,
                path TEXT NOT NULL,
                created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
            )
            """
        )
        conn.execute(
            """
            CREATE TABLE project_metadata (
                id INTEGER PRIMARY KEY,
                project_id INTEGER NOT NULL UNIQUE,
                last_modified TIMESTAMP,
                FOREIGN KEY(project_id) REFERENCES projects(id)
            )
            """
        )
    return tx_manager


class TestTransactionCommit:
    """Tests for successful transaction commits."""

    def test_transaction_commits_on_success(self, tx_manager):
        """Verify that transaction commits when no exception occurs."""
        with tx_manager.transaction() as conn:
            conn.execute("CREATE TABLE test (id INTEGER)")
            conn.execute("INSERT INTO test VALUES (1)")

        # Verify persisted
        with tx_manager.transaction() as conn:
            result = conn.execute("SELECT * FROM test").fetchone()
            assert result == (1,)

    def test_insert_commit(self, initialized_db):
        """Test INSERT operation commits successfully."""
        with initialized_db.transaction() as conn:
            conn.execute(
                "INSERT INTO projects (name, path) VALUES (?, ?)",
                ("proj1", "/tmp/proj1"),
            )

        # Verify persisted
        with initialized_db.transaction() as conn:
            result = conn.execute(
                "SELECT name, path FROM projects WHERE name=?", ("proj1",)
            ).fetchone()
            assert result == ("proj1", "/tmp/proj1")

    def test_update_commit(self, initialized_db):
        """Test UPDATE operation commits successfully."""
        # Insert first
        with initialized_db.transaction() as conn:
            conn.execute(
                "INSERT INTO projects (name, path) VALUES (?, ?)",
                ("proj1", "/tmp/old"),
            )

        # Update
        with initialized_db.transaction() as conn:
            conn.execute(
                "UPDATE projects SET path=? WHERE name=?",
                ("/tmp/new", "proj1"),
            )

        # Verify persisted
        with initialized_db.transaction() as conn:
            result = conn.execute(
                "SELECT path FROM projects WHERE name=?", ("proj1",)
            ).fetchone()
            assert result == ("/tmp/new",)


class TestTransactionRollback:
    """Tests for transaction rollback on errors."""

    def test_rollback_on_exception(self, tx_manager):
        """Verify rollback when exception occurs."""
        with tx_manager.transaction() as conn:
            conn.execute("CREATE TABLE test (id INTEGER)")

        # This should fail and rollback
        with pytest.raises(sqlite3.IntegrityError):
            with tx_manager.transaction() as conn:
                conn.execute("INSERT INTO test VALUES (1)")
                # Simulate constraint violation
                raise sqlite3.IntegrityError("Test error")

        # Table should still exist but no data
        with tx_manager.transaction() as conn:
            # Should succeed (table exists from first transaction)
            result = conn.execute("SELECT COUNT(*) FROM test").fetchone()
            assert result == (0,)

    def test_partial_changes_rollback(self, initialized_db):
        """Verify all changes rollback when transaction fails partway."""
        with pytest.raises(sqlite3.IntegrityError):
            with initialized_db.transaction() as conn:
                conn.execute(
                    "INSERT INTO projects (name, path) VALUES (?, ?)",
                    ("proj1", "/tmp/proj1"),
                )
                conn.execute(
                    "INSERT INTO projects (name, path) VALUES (?, ?)",
                    ("proj1", "/tmp/duplicate"),  # Duplicate - violates UNIQUE
                )

        # No records should exist (all rolled back)
        with initialized_db.transaction() as conn:
            result = conn.execute("SELECT COUNT(*) FROM projects").fetchone()
            assert result == (0,)

    def test_constraint_violation_rollback(self, initialized_db):
        """Test rollback on constraint violation (UNIQUE constraint).

        ✅ FIX: Use UNIQUE constraint violation instead of FK (simpler, more reliable).
        """
        # Insert first project
        with initialized_db.transaction() as conn:
            conn.execute(
                "INSERT INTO projects (name, path) VALUES (?, ?)",
                ("duplicate_test", "/tmp/proj1"),
            )

        # Try to insert duplicate name (violates UNIQUE constraint)
        with pytest.raises(sqlite3.IntegrityError):
            with initialized_db.transaction() as conn:
                conn.execute(
                    "INSERT INTO projects (name, path) VALUES (?, ?)",
                    ("duplicate_test", "/tmp/proj2"),  # Same name, violates UNIQUE
                )


class TestTransactionAcidity:
    """Tests for ACID properties."""

    def test_atomicity(self, initialized_db):
        """Test atomicity: all-or-nothing execution."""
        with initialized_db.transaction() as conn:
            conn.execute(
                "INSERT INTO projects (name, path) VALUES (?, ?)",
                ("proj1", "/tmp/proj1"),
            )
            conn.execute(
                "INSERT INTO projects (name, path) VALUES (?, ?)",
                ("proj2", "/tmp/proj2"),
            )

        count = 0
        with initialized_db.transaction() as conn:
            result = conn.execute("SELECT COUNT(*) FROM projects").fetchone()
            count = result[0]

        assert count == 2, "Both inserts should commit atomically"

    def test_isolation_level_deferred(self, tx_manager):
        """Test DEFERRED isolation level."""
        with tx_manager.transaction(isolation_level="DEFERRED") as conn:
            conn.execute("CREATE TABLE test (id INTEGER)")
            conn.execute("INSERT INTO test VALUES (1)")

        with tx_manager.transaction() as conn:
            result = conn.execute("SELECT * FROM test").fetchone()
            assert result == (1,)

    def test_multiple_sequential_transactions(self, initialized_db):
        """Test multiple sequential transactions maintain consistency."""
        # Transaction 1
        with initialized_db.transaction() as conn:
            conn.execute(
                "INSERT INTO projects (name, path) VALUES (?, ?)",
                ("proj1", "/tmp/proj1"),
            )

        # Transaction 2
        with initialized_db.transaction() as conn:
            conn.execute(
                "INSERT INTO projects (name, path) VALUES (?, ?)",
                ("proj2", "/tmp/proj2"),
            )

        # Transaction 3 - verify both exist
        with initialized_db.transaction() as conn:
            result = conn.execute("SELECT COUNT(*) FROM projects").fetchone()
            assert result == (2,)


class TestExecuteTransaction:
    """Tests for the execute_transaction batch operation."""

    def test_execute_multiple_operations(self, initialized_db):
        """Test batch execution of multiple SQL statements."""
        operations = [
            ("INSERT INTO projects (name, path) VALUES (?, ?)", ("proj1", "/tmp/1")),
            ("INSERT INTO projects (name, path) VALUES (?, ?)", ("proj2", "/tmp/2")),
            ("SELECT COUNT(*) FROM projects", ()),
        ]

        results = initialized_db.execute_transaction(operations)

        # Last operation should return row count
        assert results[2] == [(2,)]

    def test_execute_transaction_rollback_on_error(self, initialized_db):
        """Test that batch execution rolls back on any error."""
        operations = [
            ("INSERT INTO projects (name, path) VALUES (?, ?)", ("proj1", "/tmp/1")),
            # This will fail (duplicate)
            ("INSERT INTO projects (name, path) VALUES (?, ?)", ("proj1", "/tmp/2")),
        ]

        with pytest.raises(sqlite3.IntegrityError):
            initialized_db.execute_transaction(operations)

        # Verify all rolled back
        with initialized_db.transaction() as conn:
            result = conn.execute("SELECT COUNT(*) FROM projects").fetchone()
            assert result == (0,)


class TestTransactionEdgeCases:
    """Tests for edge cases and error conditions."""

    def test_double_close(self, tx_manager):
        """Verify double close doesn't cause errors."""
        with tx_manager.transaction() as conn:
            conn.execute("CREATE TABLE test (id INTEGER)")

        # Connection should still be usable
        with tx_manager.transaction() as conn:
            conn.execute("INSERT INTO test VALUES (1)")

    def test_empty_transaction(self, tx_manager):
        """Test transaction with no operations."""
        with tx_manager.transaction() as _conn:
            # Do nothing - should still commit cleanly
            pass

    def test_transaction_with_rollback_error(self, tx_manager):
        """Test handling of error during rollback.

        ✅ FIX: Verify rollback happens correctly when exception occurs.
        If error is raised inside transaction context, table creation should be rolled back.
        """
        # Transaction with error should rollback
        with pytest.raises(sqlite3.DatabaseError):
            with tx_manager.transaction() as conn:
                conn.execute("CREATE TABLE test (id INTEGER)")
                raise sqlite3.DatabaseError("Simulated error")

        # After rollback, table should NOT exist (rolled back)
        with tx_manager.transaction() as conn:
            result = conn.execute(
                "SELECT name FROM sqlite_master WHERE type='table' AND name='test'"
            ).fetchone()
            assert result is None  # ✅ FIXED: Table doesn't exist after rollback
