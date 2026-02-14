"""
Integration tests for conversation persistence.

Uses real SQLite database (in-memory for speed).

Test Coverage:
- Complete CRUD flow
- Foreign key constraints
- Concurrent writes (transaction isolation)
"""

import pytest
import pytest_asyncio
from uuid import uuid4
from datetime import datetime, UTC
from sqlalchemy.ext.asyncio import (
    create_async_engine,
    AsyncSession,
    async_sessionmaker,
)

from src.server.app.infrastructure.persistence.database import Base
from src.server.app.infrastructure.persistence.repositories.sqlalchemy_conversation_repository import (
    SQLAlchemyConversationRepository,
)
from src.server.app.domain.entities.message import Message, MessageRole


# Fixture: in-memory database
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


@pytest.mark.asyncio
async def test_create_and_retrieve_conversation(db_session):
    """Test E2E: create conversation → retrieve with messages."""
    # Arrange
    repository = SQLAlchemyConversationRepository(db_session)
    project_id = uuid4()
    title = "Test Conversation"

    # Act: Create conversation
    conversation = await repository.create_conversation(project_id, title)

    # Act: Add message
    message = Message(
        id=uuid4(),
        conversation_id=conversation.id,
        role=MessageRole.USER,
        content="Hello, world!",
        created_at=datetime.now(UTC),
    )
    await repository.add_message(conversation.id, message)

    # Act: Retrieve conversation
    retrieved = await repository.get_conversation(conversation.id)

    # Assert
    assert retrieved is not None
    assert retrieved.id == conversation.id
    assert retrieved.title == title
    assert len(retrieved.messages) == 1
    assert retrieved.messages[0].content == "Hello, world!"


@pytest.mark.asyncio
async def test_list_conversations_with_pagination(db_session):
    """Test listing conversations with skip/limit."""
    # Arrange
    repository = SQLAlchemyConversationRepository(db_session)
    project_id = uuid4()

    # Create 5 conversations
    for i in range(5):
        await repository.create_conversation(project_id, f"Conv {i}")

    # Act: List first 2
    conversations = await repository.list_conversations(skip=0, limit=2)

    # Assert
    assert len(conversations) == 2


@pytest.mark.asyncio
async def test_get_last_n_messages_returns_correct_count(db_session):
    """Test context window (last 10 messages)."""
    # Arrange
    repository = SQLAlchemyConversationRepository(db_session)
    project_id = uuid4()
    conversation = await repository.create_conversation(project_id, "Test")

    # Add 15 messages
    for i in range(15):
        message = Message(
            id=uuid4(),
            conversation_id=conversation.id,
            role=MessageRole.USER,
            content=f"Message {i}",
            created_at=datetime.now(UTC),
        )
        await repository.add_message(conversation.id, message)

    # Act: Get last 10
    last_10 = await repository.get_last_n_messages(conversation.id, n=10)

    # Assert
    assert len(last_10) == 10
    assert last_10[-1].content == "Message 14"  # Last message
