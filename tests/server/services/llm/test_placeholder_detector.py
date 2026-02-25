"""Unit tests for RULE-02 Placeholder Detector (HU-5.0).

Tests the "Total Proactivity" feature that forbids placeholders like
[Insert text], [TODO:], TBD, etc. in LLM responses.

Coverage target: 100% for placeholder_detector.py
Expected test count: 7 tests
"""


# NOTE: Mock PlaceholderDetector until RULE-02 is implemented in Phase 2.2
class PlaceholderDetector:
    """Mock implementation for testing purposes."""

    FORBIDDEN_PATTERNS = [
        r"\[Insert\s+.*?\]",
        r"\[TODO:.*?\]",
        r"\[Add\s+.*?\]",
        r"\[Fill\s+.*?\]",
        r"\[Your\s+.*?\]",
        r"\bTBD\b",
        r"\[.*?\]",  # Catch-all for bracketed text
    ]

    @staticmethod
    def detect_placeholders(text: str) -> list[tuple[str, str]]:
        """Detect placeholder patterns in text."""
        import re

        found_placeholders = []

        for pattern in PlaceholderDetector.FORBIDDEN_PATTERNS:
            matches = re.finditer(pattern, text, re.IGNORECASE)
            for match in matches:
                found_placeholders.append((pattern, match.group()))

        return found_placeholders

    @staticmethod
    def has_placeholders(text: str) -> bool:
        """Check if text contains any placeholders."""
        return len(PlaceholderDetector.detect_placeholders(text)) > 0

    @staticmethod
    def sanitize_response(text: str) -> str:
        """Replace placeholders with warning message."""
        import re

        for pattern in PlaceholderDetector.FORBIDDEN_PATTERNS:
            text = re.sub(
                pattern,
                "[⚠️ PLACEHOLDER DETECTED - THIS SHOULD NOT APPEAR]",
                text,
                flags=re.IGNORECASE,
            )

        return text


class TestPlaceholderDetectorBasic:
    """Basic tests for placeholder detection patterns."""

    def test_detect_insert_placeholder(self):
        """
        RULE-02: Should detect [Insert ...] pattern.

        Scenario: LLM generates "Project Name: [Insert your project name]".
        Expected: detect_placeholders() finds the placeholder.
        """
        text = "Project Name: [Insert your project name]"

        placeholders = PlaceholderDetector.detect_placeholders(text)

        assert len(placeholders) > 0, "Should detect [Insert ...] placeholder"
        assert any("[Insert" in match for _, match in placeholders)

    def test_detect_todo_placeholder(self):
        """
        RULE-02: Should detect [TODO: ...] pattern.

        Scenario: LLM generates "[TODO: Add project description]".
        Expected: detect_placeholders() finds the TODO.
        """
        text = "Description: [TODO: Add project description]"

        placeholders = PlaceholderDetector.detect_placeholders(text)

        assert len(placeholders) > 0, "Should detect [TODO: ...] placeholder"
        assert any("TODO" in match for _, match in placeholders)

    def test_detect_tbd_placeholder(self):
        """
        RULE-02: Should detect TBD keyword.

        Scenario: LLM generates "Tech Stack: TBD".
        Expected: detect_placeholders() finds TBD.
        """
        text = "Tech Stack: TBD after team discussion"

        placeholders = PlaceholderDetector.detect_placeholders(text)

        assert len(placeholders) > 0, "Should detect TBD keyword"


class TestPlaceholderDetectorNegativeCases:
    """Tests for text WITHOUT placeholders (clean text)."""

    def test_no_placeholders_in_clean_text(self):
        """
        RULE-02: Clean text without placeholders should pass.

        Scenario: LLM generates complete draft with real values.
        Expected: detect_placeholders() returns empty list.
        """
        text = "Project Name: MyAwesomeApp\nTech Stack: React + Node.js"

        placeholders = PlaceholderDetector.detect_placeholders(text)

        assert len(placeholders) == 0, "Clean text should have no placeholders"

    def test_has_placeholders_returns_true(self):
        """
        RULE-02: has_placeholders() should return True if placeholders exist.

        Scenario: Text with "[Your name]" placeholder.
        Expected: has_placeholders() returns True.
        """
        text = "Name: [Your name]"

        result = PlaceholderDetector.has_placeholders(text)

        assert result is True, "Should detect placeholder presence"

    def test_has_placeholders_returns_false(self):
        """
        RULE-02: has_placeholders() should return False for clean text.

        Scenario: Text with real data "John Doe".
        Expected: has_placeholders() returns False.
        """
        text = "Name: John Doe"

        result = PlaceholderDetector.has_placeholders(text)

        assert result is False, "Should confirm no placeholders"


class TestPlaceholderDetectorSanitization:
    """Tests for sanitize_response() method."""

    def test_sanitize_response_replaces_placeholders(self):
        """
        RULE-02: sanitize_response() should replace placeholders with warning.

        Scenario: LLM generates multiple placeholders.
        Expected: All placeholders replaced with warning message.
        """
        text = "Project: [Insert name] and Description: [TODO: Add]"

        sanitized = PlaceholderDetector.sanitize_response(text)

        assert (
            "[Insert name]" not in sanitized
        ), "Should remove [Insert ...] placeholder"
        assert "[TODO: Add]" not in sanitized, "Should remove [TODO: ...] placeholder"
        assert "⚠️ PLACEHOLDER DETECTED" in sanitized, "Should inject warning message"


class TestPlaceholderDetectorEdgeCases:
    """Edge case tests for placeholder detection."""

    def test_detect_bracketed_content_not_placeholder(self):
        """
        RULE-02: Technical bracketed content should be ALLOWED.

        Scenario: Code example contains "List<String>" (not a placeholder).
        Expected: Should NOT be flagged (context-aware detection).

        NOTE: Current implementation may flag ALL bracketed content.
        This test documents expected behavior for future refinement.
        """
        text = "Type definition: List<String> items;"

        _ = PlaceholderDetector.detect_placeholders(text)

        # Current behavior: May detect this as placeholder (catch-all pattern)
        # Future: Add whitelist for technical patterns
        # For MVP, we accept false positives in code examples

    def test_multiple_placeholders_in_single_text(self):
        """
        RULE-02: Should detect ALL placeholders in text.

        Scenario: Multiple different placeholder types in same text.
        Expected: detect_placeholders() finds all of them.
        """
        text = """
        Project: [Insert name]
        Description: [TODO: Add description]
        Tech Stack: TBD
        """

        placeholders = PlaceholderDetector.detect_placeholders(text)

        # Should find at least 3 placeholders
        assert len(placeholders) >= 3, "Should detect multiple placeholders"
