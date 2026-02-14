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


def test_conversation_add_message_updates_timestamp():
    """Test that add_message() updates updated_at timestamp."""
    # Arrange
    conv_id = uuid4()
    project_id = uuid4()
    conversation = Conversation(
        id=conv_id,
        project_id=project_id,
        title="Test",
        messages=[],
        created_at=datetime.now(UTC),
        updated_at=datetime.now(UTC),
    )
    initial_updated_at = conversation.updated_at

    # Wait a tiny bit to ensure timestamp difference
    import time

    time.sleep(0.01)

    msg1 = Message(
        id=uuid4(),
        conversation_id=conv_id,
        role=MessageRole.USER,
        content="Hello",
        created_at=datetime.now(UTC),
    )

    # Act
    conversation.add_message(msg1)

    # Assert
    assert len(conversation.messages) == 1
    assert conversation.updated_at > initial_updated_at


def test_conversation_get_last_n_messages_with_less_than_n():
    """Test get_last_n_messages() when conversation has < N messages."""
    # Arrange
    conv_id = uuid4()
    project_id = uuid4()
    conversation = Conversation(
        id=conv_id,
        project_id=project_id,
        title="Test",
        messages=[],
        created_at=datetime.now(UTC),
        updated_at=datetime.now(UTC),
    )

    # Add 5 messages
    for i in range(5):
        msg = Message(
            id=uuid4(),
            conversation_id=conv_id,
            role=MessageRole.USER,
            content=f"Message {i}",
            created_at=datetime.now(UTC),
        )
        conversation.add_message(msg)

    # Act: Request 10 messages (but only have 5)
    last_messages = conversation.get_last_n_messages(n=10)

    # Assert: Should return all 5
    assert len(last_messages) == 5


def test_conversation_get_last_n_messages_with_more_than_n():
    """Test get_last_n_messages() when conversation has > N messages."""
    # Arrange
    conv_id = uuid4()
    project_id = uuid4()
    conversation = Conversation(
        id=conv_id,
        project_id=project_id,
        title="Test",
        messages=[],
        created_at=datetime.now(UTC),
        updated_at=datetime.now(UTC),
    )

    # Add 15 messages
    for i in range(15):
        msg = Message(
            id=uuid4(),
            conversation_id=conv_id,
            role=MessageRole.USER,
            content=f"Message {i}",
            created_at=datetime.now(UTC),
        )
        conversation.add_message(msg)

    # Act: Request last 10 messages
    last_messages = conversation.get_last_n_messages(n=10)

    # Assert: Should return last 10
    assert len(last_messages) == 10
    assert last_messages[0].content == "Message 5"  # 6th message (0-indexed)
    assert last_messages[-1].content == "Message 14"  # Last message
