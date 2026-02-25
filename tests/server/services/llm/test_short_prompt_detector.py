"""Unit tests for RULE-01 Short Prompt Detector (HU-5.0).

Tests the "Anti-Manifesto Automatic" feature that detects short prompts
(<50 chars) and triggers clarifying questions.

Coverage target: 100% for short_prompt_detector.py
Expected test count: 5 tests
"""


# NOTE: This test file assumes short_prompt_detector.py will be created in Phase 2.1
# For now, we test the expected interface and behavior


class ShortPromptDetector:
    """Mock implementation for testing purposes."""

    THRESHOLD_CHARS = 50

    KEY_QUESTIONS = [
        "What type of application are you building? (web app, mobile,desktop, API)",
        "What is your preferred tech stack? (React+Node, Flutter+Python, etc.)",
        "What are the 3 main features or goals of your project?",
    ]

    @staticmethod
    def is_short_prompt(user_message: str) -> bool:
        """Check if prompt is too short."""
        clean_message = user_message.strip()
        return len(clean_message) < ShortPromptDetector.THRESHOLD_CHARS

    @staticmethod
    def generate_clarifying_questions() -> list[str]:
        """Generate list of clarifying questions."""
        return ShortPromptDetector.KEY_QUESTIONS

    @staticmethod
    def format_questions_response(user_message: str) -> str:
        """Format the response with clarifying questions."""
        questions = ShortPromptDetector.generate_clarifying_questions()

        response = (
            "I'd love to help you build your project! However, I need a bit more context. "
            "Could you please answer these questions?\n\n"
        )

        for i, question in enumerate(questions, 1):
            response += f"{i}. {question}\n"

        response += (
            "\nOnce I understand your requirements, I'll guide you through creating "
            "professional documentation (24 documents from vision to implementation)."
        )

        return response


class TestShortPromptDetectorBasic:
    """Basic tests for short prompt detection."""

    def test_is_short_prompt_with_very_short_message(self):
        """
        RULE-01: Very short messages should trigger detection.

        Scenario: User sends "Build an app" (13 chars).
        Expected: is_short_prompt() returns True.
        """
        short_message = "Build an app"

        result = ShortPromptDetector.is_short_prompt(short_message)

        assert result is True, "Short message should trigger detection"
        assert len(short_message) < ShortPromptDetector.THRESHOLD_CHARS

    def test_is_short_prompt_with_long_message(self):
        """
        RULE-01: Long messages should NOT trigger detection.

        Scenario: User provides detailed description (>50 chars).
        Expected: is_short_prompt() returns False.
        """
        long_message = (
            "I want to build a project management web application "
            "using React frontend and Node.js backend with PostgreSQL database"
        )

        result = ShortPromptDetector.is_short_prompt(long_message)

        assert result is False, "Long message should NOT trigger detection"
        assert len(long_message) > ShortPromptDetector.THRESHOLD_CHARS

    def test_is_short_prompt_at_boundary(self):
        """
        RULE-01: Test behavior at exactly threshold (50 chars).

        Scenario:
        - 50 chars exactly → Should NOT trigger (inclusive)
        - 49 chars → Should trigger
        """
        # Exactly at threshold
        boundary_message = "x" * ShortPromptDetector.THRESHOLD_CHARS
        assert (
            ShortPromptDetector.is_short_prompt(boundary_message) is False
        ), "Exactly 50 chars should NOT trigger"

        # One char less
        just_under = boundary_message[:-1]
        assert (
            ShortPromptDetector.is_short_prompt(just_under) is True
        ), "49 chars should trigger"


class TestShortPromptDetectorQuestions:
    """Tests for clarifying questions generation."""

    def test_generate_clarifying_questions_returns_three(self):
        """
        RULE-01: Should generate exactly 3 clarifying questions.

        Questions should cover: Type, Stack, Features.
        """
        questions = ShortPromptDetector.generate_clarifying_questions()

        assert len(questions) == 3, "Should return exactly 3 questions"
        assert all(
            isinstance(q, str) for q in questions
        ), "All questions should be strings"

        # Check that questions are meaningful (not empty)
        assert all(len(q) > 10 for q in questions), "Questions should be descriptive"

    def test_format_questions_response_includes_all_questions(self):
        """
        RULE-01: Formatted response should include all questions.

        Response should be numbered (1., 2., 3.) and include context.
        """
        user_message = "Help me"
        response = ShortPromptDetector.format_questions_response(user_message)

        # Check all questions are present
        questions = ShortPromptDetector.generate_clarifying_questions()
        for question in questions:
            # Question text should be in response
            # (Check part of question to handle numbering)
            assert question in response or question.split("(")[0].strip() in response

        # Check format elements
        assert "1." in response, "Should have numbered list (1.)"
        assert "2." in response, "Should have numbered list (2.)"
        assert "3." in response, "Should have numbered list (3.)"

        # Check context message
        assert "I'd love to help" in response or "more context" in response


class TestShortPromptDetectorEdgeCases:
    """Edge case tests for short prompt detection."""

    def test_short_prompt_with_only_whitespace(self):
        """
        RULE-01: Whitespace-only messages should trigger detection.

        Scenario: User sends "   " (spaces only).
        Expected: is_short_prompt() returns True (stripped length = 0).
        """
        whitespace_message = "      "

        result = ShortPromptDetector.is_short_prompt(whitespace_message)

        assert result is True, "Whitespace-only should trigger detection"

    def test_short_prompt_with_leading_trailing_spaces(self):
        """
        RULE-01: Leading/trailing spaces should be stripped before check.

        Scenario: "  Short  " → Stripped to "Short" (5 chars) → Triggers.
        """
        padded_message = "   Short   "  # 5 chars when stripped

        result = ShortPromptDetector.is_short_prompt(padded_message)

        assert result is True, "Should strip whitespace before checking length"
        assert padded_message.strip() == "Short"
        assert len(padded_message.strip()) < ShortPromptDetector.THRESHOLD_CHARS

    def test_short_prompt_empty_string(self):
        """
        RULE-01: Empty string should trigger detection.

        Scenario: User sends "" (empty).
        Expected: is_short_prompt() returns True.
        """
        empty_message = ""

        result = ShortPromptDetector.is_short_prompt(empty_message)

        assert result is True, "Empty string should trigger detection"
