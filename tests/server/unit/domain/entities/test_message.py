"""
Unit tests for Message entity.

Test Coverage:
- Field validation (UUID, role enum, content length)
- Required field enforcement
- Timestamp generation
"""

import pytest
from datetime import datetime, UTC
from uuid import uuid4
from src.server.app.domain.entities.message import Message, MessageRole


def test_message_creation_with_valid_data():
    """Test creating message with all valid fields."""
    # Arrange
    msg_id = uuid4()
    conv_id = uuid4()
    role = MessageRole.USER
    content = "Hello, world!"
    created_at = datetime.now(UTC)

    # Act
    message = Message(
        id=msg_id,
        conversation_id=conv_id,
        role=role,
        content=content,
        created_at=created_at,
    )

    # Assert
    assert message.id == msg_id
    assert message.conversation_id == conv_id
    assert message.role == MessageRole.USER
    assert message.content == content
    assert message.created_at == created_at


def test_message_content_must_not_be_empty():
    """Test that empty content raises validation error."""
    # Arrange
    msg_id = uuid4()
    conv_id = uuid4()

    # Act & Assert
    with pytest.raises(ValueError, match="Content cannot be empty"):
        Message(
            id=msg_id,
            conversation_id=conv_id,
            role=MessageRole.USER,
            content="",
            created_at=datetime.now(UTC),
        )


def test_message_content_max_length_5000_chars():
    """Test that content >5000 chars raises validation error."""
    # Arrange
    msg_id = uuid4()
    conv_id = uuid4()
    long_content = "a" * 5001  # 5001 characters

    # Act & Assert
    with pytest.raises(ValueError, match="Content exceeds maximum length"):
        Message(
            id=msg_id,
            conversation_id=conv_id,
            role=MessageRole.USER,
            content=long_content,
            created_at=datetime.now(UTC),
        )


def test_message_role_must_be_valid_enum():
    """Test that invalid role raises validation error."""
    # Arrange
    msg_id = uuid4()
    conv_id = uuid4()

    # Act & Assert
    with pytest.raises(ValueError, match="Invalid role"):
        Message(
            id=msg_id,
            conversation_id=conv_id,
            role="INVALID_ROLE",  # Not in enum
            content="Hello",
            created_at=datetime.now(UTC),
        )
