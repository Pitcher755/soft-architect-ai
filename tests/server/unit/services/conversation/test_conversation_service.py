"""
Unit tests for ConversationService.

Test Coverage:
- Context window logic (exactly 10 messages)
- Integration with chat endpoint
"""

import pytest
from uuid import uuid4
from unittest.mock import AsyncMock
from datetime import datetime, UTC

from app.services.conversation.conversation_service import (
    ConversationService,
)
from app.domain.entities.conversation import Conversation
from app.domain.entities.message import Message, MessageRole


@pytest.mark.asyncio
async def test_get_context_window_returns_last_10_messages():
    """Test that context window returns exactly 10 messages."""
    # Arrange
    mock_repository = AsyncMock()
    service = ConversationService(mock_repository)
    conv_id = uuid4()

    # Mock 15 messages
    messages = [
        Message(
            id=uuid4(),
            conversation_id=conv_id,
            role=MessageRole.USER,
            content=f"Message {i}",
            created_at=datetime.now(UTC),
        )
        for i in range(15)
    ]

    mock_repository.get_last_n_messages.return_value = messages[-10:]

    # Act
    context = await service.get_context_window(conv_id)

    # Assert
    assert len(context) == 10
    assert context[-1].content == "Message 14"


@pytest.mark.asyncio
async def test_create_conversation_calls_repository():
    """Test creating conversation."""
    # Arrange
    mock_repository = AsyncMock()
    service = ConversationService(mock_repository)
    project_id = uuid4()
    title = "Test"

    mock_conversation = Conversation(
        id=uuid4(),
        project_id=project_id,
        title=title,
        messages=[],
        created_at=datetime.now(UTC),
        updated_at=datetime.now(UTC),
    )
    mock_repository.create_conversation.return_value = mock_conversation

    # Act
    conversation = await service.create_conversation(project_id, title)

    # Assert
    assert conversation.project_id == project_id
    mock_repository.create_conversation.assert_awaited_once_with(project_id, title)


@pytest.mark.asyncio
async def test_get_conversation_calls_repository():
    """Test getting conversation by ID."""
    # Arrange
    mock_repository = AsyncMock()
    service = ConversationService(mock_repository)
    conv_id = uuid4()

    mock_conversation = Conversation(
        id=conv_id,
        project_id=uuid4(),
        title="Test",
        messages=[],
        created_at=datetime.now(UTC),
        updated_at=datetime.now(UTC),
    )
    mock_repository.get_conversation.return_value = mock_conversation

    # Act
    conversation = await service.get_conversation(conv_id)

    # Assert
    assert conversation is not None
    assert conversation.id == conv_id
    mock_repository.get_conversation.assert_awaited_once_with(conv_id)


@pytest.mark.asyncio
async def test_list_conversations_with_pagination():
    """Test listing conversations with pagination."""
    # Arrange
    mock_repository = AsyncMock()
    service = ConversationService(mock_repository)
    project_id = uuid4()

    mock_conversations = [
        Conversation(
            id=uuid4(),
            project_id=project_id,
            title=f"Conversation {i}",
            messages=[],
            created_at=datetime.now(UTC),
            updated_at=datetime.now(UTC),
        )
        for i in range(5)
    ]
    mock_repository.list_conversations.return_value = mock_conversations

    # Act
    conversations = await service.list_conversations(project_id, skip=0, limit=5)

    # Assert
    assert len(conversations) == 5
    mock_repository.list_conversations.assert_awaited_once_with(project_id, 0, 5)


@pytest.mark.asyncio
async def test_add_message_calls_repository():
    """Test adding message to conversation."""
    # Arrange
    mock_repository = AsyncMock()
    service = ConversationService(mock_repository)
    conv_id = uuid4()

    message = Message(
        id=uuid4(),
        conversation_id=conv_id,
        role=MessageRole.USER,
        content="Hello",
        created_at=datetime.now(UTC),
    )
    mock_repository.add_message.return_value = message

    # Act
    result = await service.add_message(conv_id, message)

    # Assert
    assert result.content == "Hello"
    mock_repository.add_message.assert_awaited_once_with(conv_id, message)


@pytest.mark.asyncio
async def test_get_context_window_with_custom_size():
    """Test context window with custom size."""
    # Arrange
    mock_repository = AsyncMock()
    service = ConversationService(mock_repository)
    conv_id = uuid4()

    messages = [
        Message(
            id=uuid4(),
            conversation_id=conv_id,
            role=MessageRole.USER,
            content=f"Message {i}",
            created_at=datetime.now(UTC),
        )
        for i in range(20)
    ]

    mock_repository.get_last_n_messages.return_value = messages[-5:]

    # Act
    context = await service.get_context_window(conv_id, window_size=5)

    # Assert
    assert len(context) == 5
    mock_repository.get_last_n_messages.assert_awaited_once_with(conv_id, 5)
