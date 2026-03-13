"""Unit tests for MVPTemplateBuilder (HU-5.0 complete testing).

Tests all RULE implementations in the template builder including
system instruction formatting, history handling, and context integration.

Coverage Target: 100% of template_builder.py
"""

import pytest
from uuid import uuid4

from app.services.rag.template_builder import MVPTemplateBuilder


@pytest.fixture
def builder():
    """Create MVPTemplateBuilder instance."""
    return MVPTemplateBuilder()


class TestTemplateSelection:
    """Test template selection logic."""

    def test_select_template_returns_context_driven(self, builder):
        """select_template should always return 'CONTEXT_DRIVEN' for MVP."""
        project_id = uuid4()
        result = builder.select_template(project_id)

        assert result == "CONTEXT_DRIVEN"

    def test_select_template_with_different_project_ids(self, builder):
        """Template selection should be consistent across project IDs."""
        # In MVP, all projects use same template
        result1 = builder.select_template(uuid4())
        result2 = builder.select_template(uuid4())

        assert result1 == result2 == "CONTEXT_DRIVEN"


class TestBuildPromptSystemInstruction:
    """Test system instruction section of build_prompt."""

    def test_system_instruction_contains_softarchitect_identity(self, builder):
        """System instruction should identify AI as SoftArchitect."""
        prompt = builder.build_prompt(
            query="Test",
            context=[],
            template_id="CONTEXT_DRIVEN",
        )

        assert "SoftArchitect" in prompt
        assert "Arquitecto de Software Senior" in prompt

    def test_system_instruction_contains_24_step_workflow(self, builder):
        """System instruction should mention workflow guidance."""
        prompt = builder.build_prompt(
            query="Test",
            context=[],
            template_id="CONTEXT_DRIVEN",
        )

        assert "DOCTRINA ZERO LAZY WRITING" in prompt
        assert "ESTRICTO" in prompt or "strict" in prompt

    def test_system_instruction_contains_all_rules(self, builder):
        """System instruction should contain all 5 core rules."""
        prompt = builder.build_prompt(
            query="Test",
            context=[],
            template_id="CONTEXT_DRIVEN",
        )

        # Check for rule keywords
        rule_keywords = [
            "DOCTRINA ZERO LAZY WRITING",
            "ENRUTAMIENTO ESTRICTO",
            "ESTILO Y FORMATO OBLIGATORIO",
            "<document>",
            "CONTRATO DE SALIDA",
        ]

        for keyword in rule_keywords:
            assert keyword in prompt, f"Missing rule keyword: {keyword}"

    def test_system_instruction_mentions_phase_structure(self, builder):
        """System instruction should mention Phase 1-6 structure."""
        prompt = builder.build_prompt(
            query="Test",
            context=[],
            template_id="CONTEXT_DRIVEN",
        )

        assert "Fases 1 a 5" in prompt
        assert "Fase 6" in prompt


class TestBuildPromptHistoryFormatting:
    """Test chat history formatting in build_prompt."""

    def test_empty_history_produces_no_history_section(self, builder):
        """Empty history should not add history section."""
        prompt = builder.build_prompt(
            query="Test",
            context=[],
            template_id="CONTEXT_DRIVEN",
            history=[],
        )

        assert "RECENT HISTORY" not in prompt

    def test_none_history_produces_no_history_section(self, builder):
        """None history should not add history section."""
        prompt = builder.build_prompt(
            query="Test",
            context=[],
            template_id="CONTEXT_DRIVEN",
            history=None,
        )

        assert "RECENT HISTORY" not in prompt

    def test_history_section_formats_messages_correctly(self, builder):
        """History section should format user and assistant messages."""
        history = [
            {"role": "user", "content": "Hello"},
            {"role": "assistant", "content": "Hi there!"},
            {"role": "user", "content": "How are you?"},
        ]

        prompt = builder.build_prompt(
            query="Test",
            context=[],
            template_id="CONTEXT_DRIVEN",
            history=history,
        )

        assert "📋 MEMORIA DE DECISIONES:" in prompt
        assert "USUARIO: Hello" in prompt
        assert "SOFTARCHITECT: Hi there!" in prompt
        assert "USUARIO: How are you?" in prompt

    def test_history_limits_to_last_5_messages(self, builder):
        """History should only include last 6 messages."""
        history = [{"role": "user", "content": f"Message {i}"} for i in range(10)]

        prompt = builder.build_prompt(
            query="Test",
            context=[],
            template_id="CONTEXT_DRIVEN",
            history=history,
        )

        # Should have last 6 messages (4-9)
        assert "Message 4" in prompt
        assert "Message 9" in prompt
        # Should NOT have first messages
        assert "Message 0" not in prompt
        assert "Message 3" not in prompt


class TestBuildPromptContextSection:
    """Test RAG context section formatting."""

    def test_empty_context_with_fallback_shows_warning(self, builder):
        """Empty context with FALLBACK template shows warning."""
        prompt = builder.build_prompt(
            query="Test",
            context=[],
            template_id="FALLBACK",
        )

        assert "⚠️ INFO" in prompt
        assert "Base de conocimientos no disponible" in prompt

    def test_empty_context_with_normal_template_shows_warning(self, builder):
        """Empty context with any template shows warning."""
        prompt = builder.build_prompt(
            query="Test",
            context=[],
            template_id="CONTEXT_DRIVEN",
        )

        # Should still show warning if context is empty
        assert "⚠️ INFO" in prompt

    def test_context_section_includes_all_snippets(self, builder):
        """Context section should include all provided snippets."""
        context = [
            "Context snippet 1",
            "Context snippet 2",
            "Context snippet 3",
        ]

        prompt = builder.build_prompt(
            query="Test",
            context=context,
            template_id="CONTEXT_DRIVEN",
        )

        assert "📚 GUÍA SAGRADA Y CONTEXTO:" in prompt
        for snippet in context:
            assert snippet in prompt

    def test_context_section_has_visual_separators(self, builder):
        """Context section should have visual separator lines."""
        context = ["Test context"]

        prompt = builder.build_prompt(
            query="Test",
            context=context,
            template_id="CONTEXT_DRIVEN",
        )

        # Check for separator lines
        assert "━" in prompt  # Visual separator


class TestBuildPromptQuerySection:
    """Test query section formatting."""

    def test_query_section_includes_user_query(self, builder):
        """Query section should include user's current question."""
        prompt = builder.build_prompt(
            query="What is Clean Architecture?",
            context=[],
            template_id="CONTEXT_DRIVEN",
        )

        assert "❓ SOLICITUD ACTUAL DEL CLIENTE:" in prompt
        assert "What is Clean Architecture?" in prompt

    def test_query_section_handles_multiline_query(self, builder):
        """Query section should handle multiline queries."""
        multiline_query = "Line 1\nLine 2\nLine 3"

        prompt = builder.build_prompt(
            query=multiline_query,
            context=[],
            template_id="CONTEXT_DRIVEN",
        )

        assert "Line 1" in prompt
        assert "Line 2" in prompt
        assert "Line 3" in prompt


class TestBuildPromptCompleteAssembly:
    """Test complete prompt assembly with all sections."""

    def test_prompt_sections_in_correct_order(self, builder):
        """Prompt sections should appear in logical order."""
        history = [{"role": "user", "content": "Previous message"}]
        context = ["Context data"]

        prompt = builder.build_prompt(
            query="Current question",
            context=context,
            template_id="CONTEXT_DRIVEN",
            history=history,
            user_name="TestUser",
        )

        # Find section positions
        system_pos = prompt.find("SYSTEM:")
        context_pos = prompt.find("📚 GUÍA SAGRADA")
        history_pos = prompt.find("📋 MEMORIA DE DECISIONES")
        query_pos = prompt.find("❓ SOLICITUD ACTUAL")

        # System should be first
        assert system_pos < context_pos
        # History should be after context
        assert context_pos < history_pos
        # Query should be last
        assert history_pos < query_pos

    def test_full_prompt_with_all_features(self, builder):
        """Test complete prompt with all features enabled."""
        history = [
            {"role": "user", "content": "Hello"},
            {"role": "assistant", "content": "Hi!"},
        ]
        context = ["Knowledge base snippet"]

        prompt = builder.build_prompt(
            query="Test query",
            context=context,
            template_id="CONTEXT_DRIVEN",
            history=history,
            user_name="FullTestUser",
        )

        # All sections should be present
        assert "SoftArchitect" in prompt  # System instruction
        assert "FullTestUser" in prompt  # userName
        assert "Knowledge base snippet" in prompt  # Context
        assert "USUARIO: Hello" in prompt  # History
        assert "Test query" in prompt  # Query
