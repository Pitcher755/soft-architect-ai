"""Database migration 002: Add indexes for query optimization.

Apply with:
    python -m src.server.app.infrastructure.persistence.migrations
"""

import sqlite3


def migrate_002_add_indexes(conn: sqlite3.Connection) -> None:
    """Add database indexes for query performance.

    Indexes created:
    - idx_projects_name: Speed up get_project_by_name()
    - idx_projects_created_at: Speed up sorting by creation date

    Args:
        conn: SQLite connection

    Example:
        >>> conn = sqlite3.connect("app.db")
        >>> migrate_002_add_indexes(conn)
        >>> conn.commit()
    """

    migrations = [
        (
            "idx_projects_name",
            "CREATE INDEX IF NOT EXISTS idx_projects_name ON projects(name)",
            "Speed up project lookups by name",
        ),
        (
            "idx_projects_created_at",
            "CREATE INDEX IF NOT EXISTS idx_projects_created_at ON projects(created_at)",
            "Speed up sorting by creation date",
        ),
        (
            "idx_projects_path",
            "CREATE INDEX IF NOT EXISTS idx_projects_path ON projects(path)",
            "Speed up project lookups by path",
        ),
    ]

    for index_name, sql, description in migrations:
        try:
            conn.execute(sql)
            print(f"✅ Created index {index_name}: {description}")
        except sqlite3.OperationalError as e:
            if "already exists" in str(e):
                print(f"⚠️  Index {index_name} already exists")
            else:
                raise

    conn.commit()
    print("✅ Migration 002 completed: Indexes added")
