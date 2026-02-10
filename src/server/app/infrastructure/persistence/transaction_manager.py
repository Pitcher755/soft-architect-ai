"""Transaction manager for SQLite ACID compliance.

This module provides context manager support for database transactions,
ensuring atomicity, consistency, isolation, and durability (ACID).

Author: ArchitectZero
Created: 2026-02-10
"""

import logging
import sqlite3
from contextlib import AbstractContextManager, contextmanager

from app.infrastructure.persistence.sqlite_config import configure_sqlite

logger = logging.getLogger(__name__)


class TransactionManager:
    """Manages database transactions with full ACID guarantees.

    Provides a context manager for safe SQLite transactions that
    automatically commits on success or rolls back on failure.

    Example:
        >>> manager = TransactionManager(":memory:")
        >>> with manager.transaction() as conn:
        ...     conn.execute("CREATE TABLE test (id INTEGER)")
        ...     conn.execute("INSERT INTO test VALUES (1)")
        >>> # Transaction committed automatically
    """

    def __init__(self, db_path: str):
        """Initialize transaction manager.

        Args:
            db_path: Path to SQLite database file or ":memory:" for in-memory DB
        """
        self.db_path = db_path
        self.logger = logger

    @contextmanager
    def transaction(
        self, isolation_level: str = "DEFERRED"
    ) -> AbstractContextManager[sqlite3.Connection]:
        """Provide a context manager for database transactions.

        Acquires a database connection and begins a transaction. On context
        exit, commits all changes if no exception occurred, or rolls back
        if an exception was raised.

        Args:
            isolation_level: Transaction isolation level (DEFERRED, IMMEDIATE, EXCLUSIVE)

        Yields:
            sqlite3.Connection: Active database connection within transaction

        Raises:
            sqlite3.Error: If database operation fails
            sqlite3.IntegrityError: If constraint violation occurs
            sqlite3.OperationalError: If database is locked or corrupted

        Example:
            >>> try:
            ...     with manager.transaction() as conn:
            ...         conn.execute("INSERT INTO projects VALUES (?)", ("proj1",))
            ... except sqlite3.IntegrityError:
            ...     print("Constraint violated")
        """
        conn = sqlite3.connect(self.db_path)

        # Apply performance optimizations
        configure_sqlite(conn)

        conn.isolation_level = None  # Manual transaction control

        try:
            # Begin transaction with specified isolation level
            conn.execute(f"BEGIN {isolation_level}")
            self.logger.debug(f"Transaction started (isolation: {isolation_level})")

            yield conn

            # Commit on success
            conn.execute("COMMIT")
            self.logger.debug("Transaction committed successfully")

        except sqlite3.IntegrityError as e:
            conn.execute("ROLLBACK")
            self.logger.warning(f"Transaction rolled back (integrity error): {e}")
            raise

        except sqlite3.OperationalError as e:
            conn.execute("ROLLBACK")
            self.logger.error(f"Transaction rolled back (operational error): {e}")
            raise

        except Exception as e:
            conn.execute("ROLLBACK")
            self.logger.error(f"Transaction rolled back (unexpected error): {e}")
            raise

        finally:
            conn.close()
            self.logger.debug("Database connection closed")

    def execute_transaction(
        self, operations: list[tuple[str, tuple]]
    ) -> list[tuple | None]:
        """Execute multiple SQL statements within a single transaction.

        All operations succeed together or all fail together (atomicity).

        Args:
            operations: List of (sql_statement, parameters) tuples

        Returns:
            List of query results (for SELECT statements)

        Example:
            >>> operations = [
            ...     ("INSERT INTO projects VALUES (?, ?)", ("proj1", "/tmp")),
            ...     ("INSERT INTO metadata VALUES (?)", (1,)),
            ... ]
            >>> results = manager.execute_transaction(operations)
        """
        results = []

        with self.transaction() as conn:
            for sql, params in operations:
                cursor = conn.execute(sql, params)
                # Store results only for SELECT statements
                if sql.strip().upper().startswith("SELECT"):
                    results.append(cursor.fetchall())
                else:
                    results.append(None)
                self.logger.debug(f"Executed: {sql[:50]}...")

        return results
