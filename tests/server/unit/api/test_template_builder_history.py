"""Unit tests for MVPTemplateBuilder with chat history formatting."""

from uuid import uuid4

from app.api.dependencies import MVPTemplateBuilder


class TestMVPTemplateBuilderWithHistory:
    """Test MVPTemplateBuilder with chat history formatting."""

    def test_build_prompt_includes_history_section(self) -> None:
        """Valid history: Should format history in prompt."""
        builder = MVPTemplateBuilder()

        prompt = builder.build_prompt(
            query="How do I test this?",
            context=["Testing guide snippet 1", "Testing guide snippet 2"],
            template_id="CONTEXT_DRIVEN",
            history=[
                {"role": "user", "content": "What is TDD?"},
                {"role": "assistant", "content": "TDD is Test-Driven Development."},
                {"role": "user", "content": "Show me an example."},
            ],
        )

        # Assertions
        assert "Conversation History:" in prompt
        assert "User: What is TDD?" in prompt
        assert "Assistant: TDD is Test-Driven Development." in prompt
        assert "User: Show me an example." in prompt
        assert "Current User Query:\nHow do I test this?" in prompt

    def test_build_prompt_works_without_history(self) -> None:
        """No history: Should work gracefully without history section."""
        builder = MVPTemplateBuilder()

        prompt = builder.build_prompt(
            query="Test query",
            context=["Context snippet"],
            template_id="CONTEXT_DRIVEN",
            history=None,  # No history
        )

        # Should NOT include history section
        assert "Conversation History:" not in prompt
        assert "Current User Query:\nTest query" in prompt

    def test_build_prompt_with_empty_history_list(self) -> None:
        """Empty history: Should handle empty list gracefully."""
        builder = MVPTemplateBuilder()

        prompt = builder.build_prompt(
            query="Test query",
            context=["Context snippet"],
            template_id="CONTEXT_DRIVEN",
            history=[],  # Empty list
        )

        # Should NOT include history section (no messages)
        assert "Conversation History:" not in prompt

    def test_build_prompt_fallback_template_with_history(self) -> None:
        """FALLBACK template: Should include history even without RAG context."""
        builder = MVPTemplateBuilder()

        prompt = builder.build_prompt(
            query="General question",
            context=[],  # No RAG context (triggers FALLBACK)
            template_id="FALLBACK",
            history=[
                {"role": "user", "content": "Previous question"},
                {"role": "assistant", "content": "Previous answer"},
            ],
        )

        # Assertions
        assert "Conversation History:" in prompt
        assert "User: Previous question" in prompt
        assert "Assistant: Previous answer" in prompt
        assert "No specific project context available" in prompt

    def test_build_prompt_capitalizes_roles(self) -> None:
        """Role formatting: Should capitalize role names in output."""
        builder = MVPTemplateBuilder()

        prompt = builder.build_prompt(
            query="Test",
            context=["Context"],
            template_id="CONTEXT_DRIVEN",
            history=[
                {"role": "user", "content": "Question"},
                {"role": "assistant", "content": "Answer"},
            ],
        )

        # Roles should be capitalized
        assert "User: Question" in prompt
        assert "Assistant: Answer" in prompt

    def test_build_prompt_context_driven_with_history(self) -> None:
        """CONTEXT_DRIVEN: Should include both history and RAG context."""
        builder = MVPTemplateBuilder()

        prompt = builder.build_prompt(
            query="Current query",
            context=["RAG snippet 1", "RAG snippet 2"],
            template_id="CONTEXT_DRIVEN",
            history=[{"role": "user", "content": "Previous query"}],
        )

        # Should include all sections
        assert "Conversation History:" in prompt
        assert "User: Previous query" in prompt
        assert "Project Knowledge Base Context:" in prompt
        assert "RAG snippet 1" in prompt
        assert "RAG snippet 2" in prompt
        assert "Current User Query:\nCurrent query" in prompt

    def test_select_template_returns_context_driven(self) -> None:
        """Template selection: Should return CONTEXT_DRIVEN for any project."""
        builder = MVPTemplateBuilder()
        template_id = builder.select_template(uuid4())
        assert template_id == "CONTEXT_DRIVEN"
