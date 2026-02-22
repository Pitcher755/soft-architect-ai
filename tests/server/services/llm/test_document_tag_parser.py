"""Unit tests for RULE-04 Document Tag Parser (HU-5.0).

Tests the "Extreme <document> Cleanup" feature that ensures:
- Only pure content inside <document> tags
- All conversation/explanations outside tags
- Properly formatted <document>...</document> structure

Coverage target: 100% for document tag parsing
Expected test count: 5 tests
"""

import re


class DocumentTagParser:
    """Parses and validates <document> tags in LLM responses."""

    @staticmethod
    def extract_document_content(text: str) -> str | None:
        """
        Extract content between <document> tags.

        Args:
            text: LLM response text

        Returns:
            Content inside <document> tags, or None if not found
        """
        pattern = r"<document>(.*?)</document>"
        match = re.search(pattern, text, re.DOTALL)
        if match:
            return match.group(1).strip()
        return None

    @staticmethod
    def has_document_tags(text: str) -> bool:
        """Check if text contains <document> tags."""
        return "<document>" in text and "</document>" in text

    @staticmethod
    def validate_clean_document_content(text: str) -> bool:
        """
        Validate that <document> content is pure (no conversation).

        Checks that content doesn't contain conversational phrases like:
        - "Here's the document..."
        - "I've generated..."
        - "Let me create..."

        Args:
            text: Content inside <document> tags

        Returns:
            True if content is pure, False if contains conversation
        """
        conversational_phrases = [
            r"here'?s? (the|your)",
            r"i'?ve (generated|created)",
            r"let me (create|generate)",
            r"this document",
            r"as requested",
        ]

        for phrase in conversational_phrases:
            if re.search(phrase, text, re.IGNORECASE):
                return False

        return True

    @staticmethod
    def count_document_tags(text: str) -> int:
        """Count number of <document> opening tags."""
        return text.count("<document>")


class TestDocumentTagParserBasic:
    """Basic tests for document tag parsing."""

    def test_extract_document_content_finds_content(self):
        """
        RULE-04: Should extract content between <document> tags.

        Scenario: LLM response with <document>Content</document>.
        Expected: extract_document_content() returns "Content".
        """
        text = """
        I'll create the manifesto for you.

        <document>
        # Project Manifesto
        ## Vision
        Build an amazing app.
        </document>

        Does this look good?
        """

        content = DocumentTagParser.extract_document_content(text)

        assert content is not None, "Should extract document content"
        assert "# Project Manifesto" in content
        assert "Build an amazing app" in content
        assert "I'll create" not in content, "Conversation should be excluded"

    def test_extract_document_content_returns_none_if_missing(self):
        """
        RULE-04: Should return None if no <document> tags.

        Scenario: LLM response without tags.
        Expected: extract_document_content() returns None.
        """
        text = "This is a response without document tags."

        content = DocumentTagParser.extract_document_content(text)

        assert content is None, "Should return None if no document tags"

    def test_has_document_tags_detects_presence(self):
        """
        RULE-04: Should detect presence of <document> tags.

        Scenario: Check if response contains document tags.
        Expected: has_document_tags() returns True.
        """
        text = "<document>Content</document>"

        result = DocumentTagParser.has_document_tags(text)

        assert result is True, "Should detect document tags"


class TestDocumentTagParserValidation:
    """Tests for document content validation."""

    def test_validate_clean_document_content_passes_for_pure_content(self):
        """
        RULE-04: Pure document content should pass validation.

        Scenario: Document contains only Markdown content, no conversation.
        Expected: validate_clean_document_content() returns True.
        """
        clean_content = """
        # Project Manifesto

        ## Vision
        Build a revolutionary task management app.

        ## Mission
        Simplify productivity for teams.
        """

        is_clean = DocumentTagParser.validate_clean_document_content(clean_content)

        assert is_clean is True, "Pure content should pass validation"

    def test_validate_clean_document_content_fails_for_conversation(self):
        """
        RULE-04: Document with conversational phrases should fail.

        Scenario: LLM includes "Here's the document..." inside tags.
        Expected: validate_clean_document_content() returns False.
        """
        dirty_content = """
        Here's the document you requested:

        # Project Manifesto
        ## Vision
        Build an app.
        """

        is_clean = DocumentTagParser.validate_clean_document_content(dirty_content)

        assert is_clean is False, "Content with conversation should fail"


class TestDocumentTagParserEdgeCases:
    """Edge case tests for document tag parsing."""

    def test_count_document_tags_single_document(self):
        """
        RULE-04: Should count number of document tags.

        Scenario: Response with single <document> tag.
        Expected: count_document_tags() returns 1.
        """
        text = "Here's the doc: <document>Content</document>"

        count = DocumentTagParser.count_document_tags(text)

        assert count == 1, "Should count single document tag"

    def test_extract_document_content_multiline(self):
        """
        RULE-04: Should handle multiline content with whitespace.

        Scenario: Document with multiple blank lines and indentation.
        Expected: extract_document_content() preserves structure.
        """
        text = """
        <document>
        # Heading

        Some text.

        ## Subheading
        More text.
        </document>
        """

        content = DocumentTagParser.extract_document_content(text)

        assert content is not None
        assert "# Heading" in content
        assert "## Subheading" in content
        # Check whitespace is preserved (multiline)
        assert "\n\n" in content, "Should preserve blank lines"

    def test_extract_document_content_with_code_blocks(self):
        """
        RULE-04: Should correctly extract content with code blocks.

        Scenario: Document contains ```python code blocks.
        Expected: Code blocks preserved in extracted content.
        """
        text = """
        <document>
        # Example Code

        ```python
        def hello():
            print("Hello")
        ```
        </document>
        """

        content = DocumentTagParser.extract_document_content(text)

        assert content is not None
        assert "```python" in content
        assert 'print("Hello")' in content
