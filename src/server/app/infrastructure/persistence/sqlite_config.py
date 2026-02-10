"""SQLite configuration and performance optimizations.

Based on: context/30-ARCHITECTURE/PERFORMANCE_STANDARDS.en.md

Optimizations applied:
- WAL (Write-Ahead Logging) for concurrent reads
- Synchronous NORMAL for faster writes
- 64MB page cache for frequently accessed data
- Memory-mapped I/O for large sequential reads
- Temp tables in RAM to avoid disk I/O
"""

import logging
import sqlite3
from typing import Any

logger = logging.getLogger(__name__)


def configure_sqlite(conn: sqlite3.Connection) -> None:
    """Apply performance optimizations to SQLite connection.

    Enables concurrent reads/writes, increases cache, and optimizes
    I/O patterns for typical database workloads.

    Args:
        conn: SQLite connection object

    Raises:
        sqlite3.OperationalError: If PRAGMA statements fail

    Example:
        >>> import sqlite3
        >>> conn = sqlite3.connect(":memory:")
        >>> configure_sqlite(conn)
        >>> # Connection now optimized for performance
    """
    pragmas = [
        ("PRAGMA journal_mode", "WAL", "Concurrent read access"),
        ("PRAGMA synchronous", "NORMAL", "Faster write operations"),
        ("PRAGMA cache_size", "-64000", "64MB page cache"),
        ("PRAGMA mmap_size", "30000000000", "Memory-mapped I/O (30GB)"),
        ("PRAGMA temp_store", "MEMORY", "Temp tables in RAM"),
        ("PRAGMA foreign_keys", "ON", "Enforce foreign keys"),
        ("PRAGMA query_only", "OFF", "Allow write operations"),
    ]

    try:
        for pragma_sql, value, description in pragmas:
            full_pragma = f"{pragma_sql}={value}"
            conn.execute(full_pragma)
            logger.debug(f"✅ {description}: {pragma_sql}={value}")

        # Verify WAL mode enabled
        result = conn.execute("PRAGMA journal_mode").fetchone()
        if result[0].upper() != "WAL":
            logger.warning("⚠️ WAL mode not enabled, connection may be slow")

        logger.info("🔧 SQLite optimizations applied successfully")
    except sqlite3.OperationalError as e:
        logger.error(f"❌ Failed to apply SQLite optimizations: {e}")
        raise


def get_sqlite_stats(conn: sqlite3.Connection) -> dict[str, Any]:
    """Retrieve SQLite performance statistics.

    Returns current connection settings for monitoring and debugging.

    Args:
        conn: SQLite connection object

    Returns:
        Dictionary with current settings:
        - journal_mode: WAL, DELETE, TRUNCATE, etc.
        - synchronous: FULL, NORMAL, OFF
        - cache_size: Megabytes
        - page_size: Bytes per page
        - max_page_count: Maximum number of pages

    Example:
        >>> stats = get_sqlite_stats(conn)
        >>> print(f"Journal mode: {stats['journal_mode']}")
    """
    pragmas = [
        "journal_mode",
        "synchronous",
        "cache_size",
        "page_size",
        "max_page_count",
    ]

    stats = {}
    for pragma in pragmas:
        try:
            result = conn.execute(f"PRAGMA {pragma}").fetchone()
            stats[pragma] = result[0] if result else None
        except sqlite3.OperationalError:
            stats[pragma] = "N/A"

    return stats
