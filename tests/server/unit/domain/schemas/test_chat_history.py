"""Unit tests for HU-4.2 Chat domain schemas with history support."""

from uuid import uuid4

import pytest
from pydantic import ValidationError

from app.domain.schemas.chat import ChatRequest


class TestChatRequestWithHistory:
    """Test ChatRequest with chat history support."""

    def test_chat_request_accepts_valid_history(self) -> None:
        """Valid history: Should accept list of role/content dicts."""
        request = ChatRequest(
            conversation_id=uuid4(),
            message="How do I implement this?",
            project_id=uuid4(),
            history=[
                {"role": "user", "content": "What is Clean Architecture?"},
                {
                    "role": "assistant",
                    "content": "Clean Architecture is a software design pattern...",
                },
            ],
        )

        assert len(request.history) == 2
        assert request.history[0]["role"] == "user"
        assert request.history[1]["role"] == "assistant"

    def test_chat_request_defaults_to_empty_history(self) -> None:
        """No history: Should default to empty list."""
        request = ChatRequest(
            conversation_id=uuid4(),
            message="Test message",
            project_id=uuid4(),
        )

        assert request.history == []

    def test_chat_request_rejects_history_exceeding_20_messages(self) -> None:
        """Oversized history: Should reject >20 messages."""
        large_history = [
            {"role": "user" if i % 2 == 0 else "assistant", "content": f"Message {i}"}
            for i in range(21)
        ]

        with pytest.raises(ValueError, match="exceeds maximum length"):
            ChatRequest(
                conversation_id=uuid4(),
                message="Test",
                project_id=uuid4(),
                history=large_history,
            )

    def test_chat_request_rejects_invalid_role(self) -> None:
        """Invalid role: Should reject roles other than user/assistant."""
        with pytest.raises(ValueError, match="invalid role"):
            ChatRequest(
                conversation_id=uuid4(),
                message="Test",
                project_id=uuid4(),
                history=[{"role": "hacker", "content": "Malicious content"}],
            )

    def test_chat_request_rejects_missing_content_field(self) -> None:
        """Missing content: Should reject messages without content."""
        with pytest.raises(ValueError, match="must have 'role' and 'content'"):
            ChatRequest(
                conversation_id=uuid4(),
                message="Test",
                project_id=uuid4(),
                history=[{"role": "user"}],  # Missing 'content'
            )

    def test_chat_request_sanitizes_history_content(self) -> None:
        """XSS in history: Should sanitize HTML entities in content."""
        request = ChatRequest(
            conversation_id=uuid4(),
            message="Test",
            project_id=uuid4(),
            history=[
                {
                    "role": "user",
                    "content": "<script>alert('XSS')</script>Normal text",
                }
            ],
        )

        # Should escape HTML entities
        assert "<script>" not in request.history[0]["content"]
        assert "Normal text" in request.history[0]["content"]

    def test_chat_request_rejects_oversized_message_in_history(self) -> None:
        """Oversized message: Should reject history messages >5000 chars."""
        long_content = "A" * 5001

        with pytest.raises(ValueError, match="exceeds 5000 characters"):
            ChatRequest(
                conversation_id=uuid4(),
                message="Test",
                project_id=uuid4(),
                history=[{"role": "user", "content": long_content}],
            )

    def test_chat_request_validates_history_message_type(self) -> None:
        """Invalid message type: Should reject non-dict messages."""
        with pytest.raises(ValidationError, match="Input should be a valid dictionary"):
            ChatRequest(
                conversation_id=uuid4(),
                message="Test",
                project_id=uuid4(),
                history=["invalid"],  # type: ignore
            )

    def test_chat_request_validates_content_is_string(self) -> None:
        """Invalid content type: Should reject non-string content."""
        with pytest.raises(ValidationError, match="Input should be a valid string"):
            ChatRequest(
                conversation_id=uuid4(),
                message="Test",
                project_id=uuid4(),
                history=[{"role": "user", "content": 123}],  # type: ignore
            )
