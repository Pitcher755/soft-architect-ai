"""
Unit tests for Conversation entity.

Test Coverage:
- Field validation (UUID, title length)
- Message list relationship
- Timestamp generation
"""

import pytest
from datetime import datetime, UTC
from uuid import uuid4
from src.server.app.domain.entities.conversation import Conversation
from src.server.app.domain.entities.message import Message, MessageRole


def test_conversation_creation_with_valid_data():
    """Test creating conversation with all valid fields."""
    # Arrange
    conv_id = uuid4()
    project_id = uuid4()
    title = "Test Conversation"
    created_at = datetime.now(UTC)
    updated_at = datetime.now(UTC)

    # Act
    conversation = Conversation(
        id=conv_id,
        project_id=project_id,
        title=title,
        messages=[],
        created_at=created_at,
        updated_at=updated_at,
    )

    # Assert
    assert conversation.id == conv_id
    assert conversation.project_id == project_id
    assert conversation.title == title
    assert len(conversation.messages) == 0
    assert conversation.created_at == created_at


def test_conversation_title_optional():
    """Test that title is optional (can be None)."""
    # Arrange
    conv_id = uuid4()
    project_id = uuid4()

    # Act
    conversation = Conversation(
        id=conv_id,
        project_id=project_id,
        title=None,
        messages=[],
        created_at=datetime.now(UTC),
        updated_at=datetime.now(UTC),
    )

    # Assert
    assert conversation.title is None


def test_conversation_title_max_length_255_chars():
    """Test that title >255 chars raises validation error."""
    # Arrange
    conv_id = uuid4()
    project_id = uuid4()
    long_title = "a" * 256  # 256 characters

    # Act & Assert
    with pytest.raises(ValueError, match="Title exceeds maximum length"):
        Conversation(
            id=conv_id,
            project_id=project_id,
            title=long_title,
            messages=[],
            created_at=datetime.now(UTC),
            updated_at=datetime.now(UTC),
        )


def test_conversation_can_have_messages():
    """Test that conversation can store messages."""
    # Arrange
    conv_id = uuid4()
    project_id = uuid4()
    msg1 = Message(
        id=uuid4(),
        conversation_id=conv_id,
        role=MessageRole.USER,
        content="Hello",
        created_at=datetime.now(UTC),
    )

    # Act
    conversation = Conversation(
        id=conv_id,
        project_id=project_id,
        title="Test",
        messages=[msg1],
        created_at=datetime.now(UTC),
        updated_at=datetime.now(UTC),
    )

    # Assert
    assert len(conversation.messages) == 1
    assert conversation.messages[0].content == "Hello"
