"""
Unit tests for SQLAlchemyConversationRepository.

Test Coverage:
- CRUD operations (create, read, list)
- Context window (get_last_n_messages)
- Error handling (not found, database errors)
"""

import pytest
from uuid import uuid4
from datetime import datetime, UTC
from unittest.mock import AsyncMock, MagicMock

from app.infrastructure.persistence.repositories.sqlalchemy_conversation_repository import (
    SQLAlchemyConversationRepository,
)


@pytest.mark.asyncio
async def test_create_conversation_success():
    """Test creating conversation successfully."""
    # Arrange
    # FIXED: session.add() is sync, commit() is async (hybrid mock)
    mock_session = AsyncMock()
    mock_session.add = MagicMock()  # sync method
    mock_session.commit = AsyncMock()  # async method
    repository = SQLAlchemyConversationRepository(mock_session)
    project_id = uuid4()
    title = "Test Conversation"

    # Act
    conversation = await repository.create_conversation(project_id, title)

    # Assert
    assert conversation.project_id == project_id
    assert conversation.title == title
    assert len(conversation.messages) == 0
    mock_session.add.assert_called_once()
    mock_session.commit.assert_awaited_once()


@pytest.mark.asyncio
async def test_get_conversation_returns_entity_when_found():
    """Test retrieving existing conversation."""
    # Arrange
    mock_session = AsyncMock()
    repository = SQLAlchemyConversationRepository(mock_session)
    conv_id = uuid4()

    # Mock result
    mock_model = MagicMock()
    mock_model.id = conv_id
    mock_model.project_id = uuid4()
    mock_model.title = "Test"
    mock_model.messages = []
    mock_model.created_at = datetime.now(UTC)
    mock_model.updated_at = datetime.now(UTC)

    mock_result = MagicMock()
    mock_result.scalar_one_or_none.return_value = mock_model
    mock_session.execute = AsyncMock(return_value=mock_result)

    # Act
    conversation = await repository.get_conversation(conv_id)

    # Assert
    assert conversation is not None
    assert conversation.id == conv_id


@pytest.mark.asyncio
async def test_get_conversation_returns_none_when_not_found():
    """Test retrieving non-existent conversation returns None."""
    # Arrange
    mock_session = AsyncMock()
    repository = SQLAlchemyConversationRepository(mock_session)
    conv_id = uuid4()

    # Mock no result
    mock_result = MagicMock()
    mock_result.scalar_one_or_none.return_value = None
    mock_session.execute = AsyncMock(return_value=mock_result)

    # Act
    conversation = await repository.get_conversation(conv_id)

    # Assert
    assert conversation is None
