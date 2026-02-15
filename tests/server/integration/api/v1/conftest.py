"""
Fixtures for API integration tests.

Provides:
- In-memory SQLite database
- FastAPI dependency override for database session
"""

import pytest_asyncio
from sqlalchemy.ext.asyncio import (
    create_async_engine,
    AsyncSession,
    async_sessionmaker,
)

# Import models to register with Base BEFORE creating tables
from app.infrastructure.persistence.models import ConversationModel, MessageModel  # noqa: F401
from app.infrastructure.persistence.database import Base, get_db_session
from app.main import app


@pytest_asyncio.fixture
async def db_session():
    """Create in-memory SQLite database for testing."""
    engine = create_async_engine("sqlite+aiosqlite:///:memory:")

    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    async_session = async_sessionmaker(
        engine, class_=AsyncSession, expire_on_commit=False
    )

    async with async_session() as session:
        yield session

    await engine.dispose()


@pytest_asyncio.fixture
async def override_get_db(db_session):
    """Override FastAPI dependency to use test database."""

    async def _override_get_db():
        yield db_session

    app.dependency_overrides[get_db_session] = _override_get_db
    yield
    app.dependency_overrides.clear()
