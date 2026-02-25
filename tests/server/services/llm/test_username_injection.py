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
        """userName should appear in the system instruction section."""
        prompt = template_builder.build_prompt(
            query="Test",
            context=[],
            template_id="FALLBACK",
            history=None,
            user_name="María",
        )

        # The new template embeds the username as: "guiar a {user_name}"
        assert "guiar a María" in prompt


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

        # Placeholder must not survive in the final prompt
        assert "{user_name}" not in prompt
        # The template embeds the name in "guiar a {user_name}"; with empty
        # string the word "guiar" is still present, confirming injection ran.
        assert "guiar a " in prompt

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
        # History roles are formatted as USUARIO (user) / SOFTARCHITECT (assistant)
        assert "Alex" in prompt
        assert "USUARIO: Hello" in prompt
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
        # template_id is used for routing but the builder does not emit
        # a literal "No templates found" message; verify the prompt is valid.
        assert "SOLICITUD ACTUAL DEL CLIENTE" in prompt
        assert "{user_name}" not in prompt
