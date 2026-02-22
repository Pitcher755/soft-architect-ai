"""Unit tests for RULE-09 userName injection in MVPTemplateBuilder.

Tests the userName personalization feature that replaces {user_name}
placeholder in system prompt.

Coverage Target: 100% of userName injection logic
"""

import pytest

from app.services.rag.template_builder import MVPTemplateBuilder


@pytest.fixture
def template_builder():
    """Create MVPTemplateBuilder instance."""
    return MVPTemplateBuilder()


class TestUserNameInjectionBasic:
    """Test basic userName injection functionality."""

    def test_default_username_is_developer(self, template_builder):
        """Default user_name parameter should be 'Developer'."""
        prompt = template_builder.build_prompt(
            query="Test query",
            context=[],
            template_id="FALLBACK",
            history=None,
            # user_name defaults to "Developer"
        )

        assert "Developer" in prompt
        assert "{user_name}" not in prompt  # Placeholder should be replaced

    def test_custom_username_injection(self, template_builder):
        """Custom user_name should replace {user_name} placeholder."""
        prompt = template_builder.build_prompt(
            query="Test query",
            context=[],
            template_id="FALLBACK",
            history=None,
            user_name="Juan",
        )

        assert "Juan" in prompt
        assert "Developer" not in prompt
        assert "{user_name}" not in prompt

    def test_username_in_system_instruction(self, template_builder):
        """userName should appear in system instruction section."""
        prompt = template_builder.build_prompt(
            query="Test",
            context=[],
            template_id="FALLBACK",
            history=None,
            user_name="María",
        )

        # Check it appears in the expected context
        assert "The user's name is María" in prompt


class TestUserNameEdgeCases:
    """Test edge cases for userName injection."""

    def test_empty_username_still_replaces_placeholder(self, template_builder):
        """Empty string userName should still replace placeholder."""
        prompt = template_builder.build_prompt(
            query="Test",
            context=[],
            template_id="FALLBACK",
            history=None,
            user_name="",
        )

        assert "{user_name}" not in prompt
        # Should have empty string where username goes
        assert "The user's name is ." in prompt

    def test_special_characters_in_username(self, template_builder):
        """Special characters in userName should be preserved."""
        prompt = template_builder.build_prompt(
            query="Test",
            context=[],
            template_id="FALLBACK",
            history=None,
            user_name="José-María O'Connor",
        )

        assert "José-María O'Connor" in prompt
        assert "{user_name}" not in prompt

    def test_very_long_username(self, template_builder):
        """Very long userName should be inserted without truncation."""
        long_name = "A" * 200
        prompt = template_builder.build_prompt(
            query="Test",
            context=[],
            template_id="FALLBACK",
            history=None,
            user_name=long_name,
        )

        assert long_name in prompt
        assert "{user_name}" not in prompt


class TestUserNameWithOtherFeatures:
    """Test userName injection combined with other prompt features."""

    def test_username_with_history(self, template_builder):
        """userName injection should work alongside chat history."""
        history = [
            {"role": "user", "content": "Hello"},
            {"role": "assistant", "content": "Hi there!"},
        ]

        prompt = template_builder.build_prompt(
            query="Test",
            context=[],
            template_id="FALLBACK",
            history=history,
            user_name="Alex",
        )

        # Both userName and history should be present
        assert "Alex" in prompt
        assert "USER: Hello" in prompt
        assert "SOFTARCHITECT: Hi there!" in prompt
        assert "{user_name}" not in prompt

    def test_username_with_context(self, template_builder):
        """userName injection should work alongside RAG context."""
        context = ["Context snippet 1", "Context snippet 2"]

        prompt = template_builder.build_prompt(
            query="Test",
            context=context,
            template_id="CONTEXT_DRIVEN",
            history=None,
            user_name="Carlos",
        )

        # Both userName and context should be present
        assert "Carlos" in prompt
        assert "Context snippet 1" in context
        assert "{user_name}" not in prompt

    def test_username_with_fallback_template(self, template_builder):
        """userName should work correctly with FALLBACK template."""
        prompt = template_builder.build_prompt(
            query="Test query",
            context=[],
            template_id="FALLBACK",
            history=None,
            user_name="TestUser",
        )

        assert "TestUser" in prompt
        assert "No templates found" in prompt  # FALLBACK warning
        assert "{user_name}" not in prompt
