"""Unit tests for ChatRequest schema with user_name field (HU-5.0).

Tests the Pydantic schema validation for the new user_name field
added in HU-5.0 RULE-09.

Coverage Target: 100% of ChatRequest schema validation
"""

import pytest
from pydantic import ValidationError
from uuid import uuid4

from app.domain.schemas.chat import ChatRequest


class TestChatRequestUserNameField:
    """Test user_name field validation in ChatRequest."""

    def test_user_name_defaults_to_developer(self):
        """user_name should default to 'Developer' if not provided."""
        request = ChatRequest(
            conversation_id=uuid4(),
            message="Test message",
            project_id=uuid4(),
            # user_name not provided, should default
        )

        assert request.user_name == "Developer"

    def test_user_name_accepts_custom_value(self):
        """user_name should accept custom string values."""
        request = ChatRequest(
            conversation_id=uuid4(),
            message="Test message",
            project_id=uuid4(),
            user_name="Juan",
        )

        assert request.user_name == "Juan"

    def test_user_name_accepts_empty_string(self):
        """user_name should accept empty string (edge case)."""
        request = ChatRequest(
            conversation_id=uuid4(),
            message="Test message",
            project_id=uuid4(),
            user_name="",
        )

        assert request.user_name == ""

    def test_user_name_with_special_characters(self):
        """user_name should accept special characters."""
        special_names = [
            "José-María",
            "O'Connor",
            "李明",  # Chinese characters
            "Müller",
            "Åsa Öberg",
        ]

        for name in special_names:
            request = ChatRequest(
                conversation_id=uuid4(),
                message="Test",
                project_id=uuid4(),
                user_name=name,
            )
            assert request.user_name == name


class TestChatRequestUserNameMaxLength:
    """Test user_name max_length constraint (100 chars)."""

    def test_user_name_within_max_length(self):
        """user_name under 100 chars should be valid."""
        request = ChatRequest(
            conversation_id=uuid4(),
            message="Test",
            project_id=uuid4(),
            user_name="A" * 99,  # 99 chars
        )

        assert len(request.user_name) == 99

    def test_user_name_at_max_length(self):
        """user_name exactly 100 chars should be valid."""
        request = ChatRequest(
            conversation_id=uuid4(),
            message="Test",
            project_id=uuid4(),
            user_name="A" * 100,  # Exactly 100 chars
        )

        assert len(request.user_name) == 100

    def test_user_name_exceeds_max_length_fails(self):
        """user_name over 100 chars should fail validation."""
        with pytest.raises(ValidationError) as exc_info:
            ChatRequest(
                conversation_id=uuid4(),
                message="Test",
                project_id=uuid4(),
                user_name="A" * 101,  # 101 chars, exceeds limit
            )

        errors = exc_info.value.errors()
        assert any("user_name" in str(error) for error in errors)


class TestChatRequestWithAllFields:
    """Test ChatRequest with all fields including user_name."""

    def test_full_request_with_user_name(self):
        """Complete ChatRequest with user_name and history."""
        conv_id = uuid4()
        proj_id = uuid4()
        history = [
            {"role": "user", "content": "Hello"},
            {"role": "assistant", "content": "Hi!"},
        ]

        request = ChatRequest(
            conversation_id=conv_id,
            message="How are you?",
            project_id=proj_id,
            user_name="TestUser",
            history=history,
        )

        assert request.conversation_id == conv_id
        assert request.message == "How are you?"
        assert request.project_id == proj_id
        assert request.user_name == "TestUser"
        assert len(request.history) == 2

    def test_request_serialization_includes_user_name(self):
        """Serialized request should include user_name field."""
        request = ChatRequest(
            conversation_id=uuid4(),
            message="Test",
            project_id=uuid4(),
            user_name="SerializedUser",
        )

        request_dict = request.model_dump()

        assert "user_name" in request_dict
        assert request_dict["user_name"] == "SerializedUser"


class TestChatRequestBackwardsCompatibility:
    """Test that user_name addition doesn't break existing code."""

    def test_old_code_without_user_name_still_works(self):
        """Existing code that doesn't pass user_name should still work."""
        # Simulating old code that doesn't know about user_name
        request = ChatRequest(
            conversation_id=uuid4(),
            message="Test message",
            project_id=uuid4(),
        )

        # Should work with default value
        assert request.user_name == "Developer"
        assert request.message == "Test message"
