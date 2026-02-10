"""Connection pool for SQLite database access.

Manages a pool of database connections to prevent resource exhaustion
and support concurrent database operations safely.

Author: ArchitectZero
Created: 2026-02-10
"""

import logging
import sqlite3
from queue import Empty, Queue

logger = logging.getLogger(__name__)


class ConnectionPool:
    """Generic connection pooling for SQLite.

    Maintains a pool of pre-created connections and provides thread-safe
    access through get/return semantics.

    Example:
        >>> pool = ConnectionPool(":memory:", pool_size=5)
        >>> conn = pool.get_connection()
        >>> try:
        ...     conn.execute("SELECT 1")
        ... finally:
        ...     pool.return_connection(conn)
    """

    def __init__(self, db_path: str, pool_size: int = 5, timeout: float = 30.0):
        """Initialize connection pool.

        Args:
            db_path: Path to SQLite database file or ":memory:"
            pool_size: Number of connections to maintain in pool (default: 5)
            timeout: Timeout in seconds when waiting for available connection
        """
        self.db_path = db_path
        self.pool_size = pool_size
        self.timeout = timeout
        self.pool: Queue[sqlite3.Connection] = Queue(maxsize=pool_size)

        # Pre-create all connections
        self._initialize_pool()

    def _initialize_pool(self) -> None:
        """Create initial pool of database connections."""
        for i in range(self.pool_size):
            try:
                conn = sqlite3.connect(self.db_path, check_same_thread=False)
                conn.row_factory = sqlite3.Row  # Enable column access by name
                self.pool.put(conn)
                logger.debug(f"Connection {i+1}/{self.pool_size} created")
            except sqlite3.Error as e:
                logger.error(f"Failed to create connection {i+1}: {e}")
                raise

        logger.info(f"Connection pool initialized with {self.pool_size} connections")

    def get_connection(self) -> sqlite3.Connection:
        """Get connection from pool (blocking if none available).

        Returns:
            sqlite3.Connection: Available database connection

        Raises:
            Empty: If no connection available after timeout period

        Example:
            >>> conn = pool.get_connection()
            >>> # Use connection
            >>> pool.return_connection(conn)
        """
        try:
            conn = self.pool.get(timeout=self.timeout)
            logger.debug(f"Connection acquired (pool size: {self.pool.qsize()})")
            return conn
        except Empty as err:
            raise TimeoutError(
                f"No database connection available after {self.timeout}s timeout"
            ) from err

    def return_connection(self, conn: sqlite3.Connection) -> None:
        """Return connection to pool for reuse.

        Must be called in a finally block to ensure return even on errors.

        Args:
            conn: Connection to return

        Example:
            >>> conn = pool.get_connection()
            >>> try:
            ...     conn.execute("...")
            ... finally:
            ...     pool.return_connection(conn)
        """
        try:
            self.pool.put(conn, block=False)
            logger.debug(f"Connection returned (pool size: {self.pool.qsize()})")
        except Exception as e:
            logger.warning(f"Error returning connection to pool: {e}")
            # Try to close the connection
            try:
                conn.close()
            except Exception as close_err:
                logger.debug(f"Error closing connection: {close_err}")

    def execute_with_pool(
        self, sql: str, params: tuple = (), fetch_one: bool = False
    ) -> sqlite3.Row | list[sqlite3.Row] | None:
        """Execute SQL statement using pooled connection.

        Automatically handles connection acquisition and return.

        Args:
            sql: SQL statement to execute
            params: Query parameters (for parameterized queries)
            fetch_one: If True, return single row; else return all rows

        Returns:
            Query result (single row, multiple rows, or None)

        Example:
            >>> result = pool.execute_with_pool(
            ...     "SELECT * FROM projects WHERE name = ?",
            ...     ("proj1",),
            ...     fetch_one=True
            ... )
        """
        conn = self.get_connection()
        try:
            cursor = conn.execute(sql, params)
            if fetch_one:
                return cursor.fetchone()
            else:
                return cursor.fetchall()
        finally:
            self.return_connection(conn)

    def close_all(self) -> None:
        """Close all connections in pool.

        Called during application shutdown or error recovery.

        Example:
            >>> # At application exit
            >>> pool.close_all()
        """
        closed = 0
        while True:
            try:
                conn = self.pool.get_nowait()
                conn.close()
                closed += 1
            except Empty:
                break

        logger.info(f"Closed {closed} connections. Pool size: {self.pool.qsize()}")

    @property
    def available_connections(self) -> int:
        """Get number of currently available connections in pool."""
        return self.pool.qsize()

    @property
    def used_connections(self) -> int:
        """Get number of connections currently in use."""
        return self.pool_size - self.pool.qsize()
