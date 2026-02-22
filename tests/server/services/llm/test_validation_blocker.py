"""Unit tests for RULE-06 Validation Blocker in RAGOrchestrator.

Tests the _check_validation_blocker() method that enforces document
validation before allowing next workflow step.

Coverage Target: 100% of validation blocker logic
"""

import pytest
from unittest.mock import MagicMock

from app.services.rag.orchestrator import RAGOrchestrator


@pytest.fixture
def orchestrator_instance():
    """Create RAGOrchestrator instance with mock dependencies."""
    # Mock dependencies (we only test _check_validation_blocker, no need for real deps)
    mock_vector_store = MagicMock()
    mock_template_builder = MagicMock()
    mock_llm_client = MagicMock()

    orchestrator = RAGOrchestrator(
        vector_store=mock_vector_store,
        template_builder=mock_template_builder,
        llm_client=mock_llm_client,
    )
    return orchestrator


class TestValidationBlockerEmptyHistory:
    """Test validation blocker with empty or None history."""

    def test_none_history_returns_none(self, orchestrator_instance):
        """Empty history should allow LLM call (no blocking)."""
        result = orchestrator_instance._check_validation_blocker(None)
        assert result is None

    def test_empty_list_returns_none(self, orchestrator_instance):
        """Empty list should allow LLM call (no blocking)."""
        result = orchestrator_instance._check_validation_blocker([])
        assert result is None


class TestValidationBlockerNoDocuments:
    """Test validation blocker when no documents in history."""

    def test_user_messages_only_returns_none(self, orchestrator_instance):
        """History with only user messages should allow LLM call."""
        history = [
            {"role": "user", "content": "Hello"},
            {"role": "user", "content": "How are you?"},
        ]
        result = orchestrator_instance._check_validation_blocker(history)
        assert result is None

    def test_assistant_messages_without_document_tag_returns_none(
        self, orchestrator_instance
    ):
        """Assistant messages without <document> tag should allow LLM call."""
        history = [
            {"role": "user", "content": "Create a document"},
            {"role": "assistant", "content": "Sure, here's the content without tags."},
        ]
        result = orchestrator_instance._check_validation_blocker(history)
        assert result is None


class TestValidationBlockerValidatedDocument:
    """Test validation blocker when document has been validated."""

    def test_document_with_validation_message_returns_none(self, orchestrator_instance):
        """Document followed by validation message should allow LLM call."""
        history = [
            {"role": "user", "content": "Create PROJECT_MANIFESTO"},
            {
                "role": "assistant",
                "content": "Here's your document:\n\n<document>\n# Manifesto\n</document>",
            },
            {
                "role": "user",
                "content": "He validado y guardado el documento en context/10-CONTEXT/PROJECT_MANIFESTO.md",
            },
            {"role": "user", "content": "What's next?"},
        ]
        result = orchestrator_instance._check_validation_blocker(history)
        assert result is None

    def test_multiple_documents_all_validated_returns_none(self, orchestrator_instance):
        """Multiple documents all validated should allow LLM call."""
        history = [
            {"role": "user", "content": "Create doc 1"},
            {"role": "assistant", "content": "Doc 1:\n<document>Content 1</document>"},
            {
                "role": "user",
                "content": "He validado y guardado el documento en path1.md",
            },
            {"role": "user", "content": "Create doc 2"},
            {"role": "assistant", "content": "Doc 2:\n<document>Content 2</document>"},
            {
                "role": "user",
                "content": "He validado y guardado el documento en path2.md",
            },
            {"role": "user", "content": "Next?"},
        ]
        result = orchestrator_instance._check_validation_blocker(history)
        assert result is None


class TestValidationBlockerUnvalidatedDocument:
    """Test validation blocker when document has NOT been validated."""

    def test_document_without_validation_returns_blocking_message(
        self, orchestrator_instance
    ):
        """Document without validation message should block LLM call."""
        history = [
            {"role": "user", "content": "Create a document"},
            {
                "role": "assistant",
                "content": "Here's the doc:\n<document>\nContent\n</document>",
            },
            {"role": "user", "content": "Show me the next step"},
        ]
        result = orchestrator_instance._check_validation_blocker(history)

        assert result is not None
        assert isinstance(result, str)
        assert "Bloqueo de Seguridad" in result
        assert "RULE-06" in result
        assert "Validar y Guardar" in result

    def test_blocking_message_contains_instructions(self, orchestrator_instance):
        """Blocking message should contain clear user instructions."""
        history = [
            {"role": "assistant", "content": "<document>Test</document>"},
            {"role": "user", "content": "Next?"},
        ]
        result = orchestrator_instance._check_validation_blocker(history)

        assert result is not None
        # Check for key instructions
        assert "botón verde" in result
        assert "scroll" in result
        assert "Master Workflow" in result

    def test_multiple_documents_last_unvalidated_blocks(self, orchestrator_instance):
        """If last document is unvalidated, should block even if previous validated."""
        history = [
            {"role": "assistant", "content": "<document>Doc 1</document>"},
            {
                "role": "user",
                "content": "He validado y guardado el documento en path1.md",
            },
            {"role": "user", "content": "Create doc 2"},
            {"role": "assistant", "content": "<document>Doc 2</document>"},
            {"role": "user", "content": "What's next?"},  # Missing validation!
        ]
        result = orchestrator_instance._check_validation_blocker(history)

        assert result is not None
        assert "Bloqueo de Seguridad" in result


class TestValidationBlockerEdgeCases:
    """Test edge cases and malformed input."""

    def test_document_tag_in_user_message_ignored(self, orchestrator_instance):
        """<document> tag in user message should be ignored."""
        history = [
            {"role": "user", "content": "Here's my <document> tag"},
            {"role": "assistant", "content": "OK, got it."},
        ]
        result = orchestrator_instance._check_validation_blocker(history)
        assert result is None

    def test_partial_validation_phrase_does_not_unblock(self, orchestrator_instance):
        """Partial validation message should not unblock."""
        history = [
            {"role": "assistant", "content": "<document>Content</document>"},
            {
                "role": "user",
                "content": "He validado el documento",
            },  # Missing "y guardado"
        ]
        result = orchestrator_instance._check_validation_blocker(history)
        assert result is not None

    def test_case_sensitive_validation_phrase(self, orchestrator_instance):
        """Validation phrase is case-sensitive (current implementation)."""
        history = [
            {"role": "assistant", "content": "<document>Content</document>"},
            {
                "role": "user",
                "content": "HE VALIDADO Y GUARDADO EL DOCUMENTO",
            },  # All caps
        ]
        # Current implementation is case-sensitive, so this SHOULD block
        result = orchestrator_instance._check_validation_blocker(history)
        assert result is not None  # Blocked because exact phrase not found

    def test_malformed_history_missing_role_key(self, orchestrator_instance):
        """Malformed history with missing 'role' key should not crash."""
        history = [
            {"content": "Message without role key"},  # Missing 'role'
            {"role": "assistant", "content": "<document>Doc</document>"},
        ]
        # Should handle gracefully (get() returns None for missing keys)
        result = orchestrator_instance._check_validation_blocker(history)
        assert result is not None  # Should still detect unvalidated document

    def test_malformed_history_missing_content_key(self, orchestrator_instance):
        """Malformed history with missing 'content' key should not crash."""
        history = [
            {"role": "assistant"},  # Missing 'content'
            {"role": "assistant", "content": "<document>Doc</document>"},
        ]
        # Should handle gracefully (get() returns empty string for missing keys)
        result = orchestrator_instance._check_validation_blocker(history)
        assert result is not None  # Should still detect unvalidated document
