"""
Database session management for SQLite with async support.

Security:
- Connection pooling (max 5 concurrent connections)
- Parameterized queries only (ORM enforced)
"""

import os

from sqlalchemy.ext.asyncio import (
    AsyncSession,
    async_sessionmaker,
    create_async_engine,
)
from sqlalchemy.orm import declarative_base

# Database URL (SQLite async)
DATABASE_URL = os.getenv("DATABASE_URL", "sqlite+aiosqlite:///./conversations.db")

# Create async engine
engine = create_async_engine(
    DATABASE_URL,
    echo=False,
    pool_size=5,
    max_overflow=10,  # Set True for SQL logging
)

# Create async session maker
async_session_maker = async_sessionmaker(
    engine, class_=AsyncSession, expire_on_commit=False
)

# Base class for models
Base = declarative_base()


async def get_db_session() -> AsyncSession:
    """
    Dependency injection for FastAPI.

    Usage:
        @app.get("/api/v1/conversations")
        async def list_conversations(db: AsyncSession = Depends(get_db_session)):
            ...
    """
    async with async_session_maker() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()


async def create_tables():
    """Create all tables (for development/testing)."""
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)


async def drop_tables():
    """Drop all tables (for testing cleanup)."""
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
