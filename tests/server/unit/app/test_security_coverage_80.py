"""
Extended tests for app/core/security.py targeting 80%+ coverage.

Focus on:
- TokenValidator edge cases (lines 83-92, 123)
- InputSanitizer dangerous patterns
- Security validation workflows
"""

import pytest

from app.core.security import InputSanitizer, TokenValidator


class TestInputSanitizerPatterns:
    """Test input sanitizer detects dangerous patterns."""

    def test_sanitizer_detects_script_tags(self):
        """✅ Should detect <script> tags."""
        dangerous_input = "<script>alert('xss')</script>"

        with pytest.raises(ValueError, match="dangerous"):
            InputSanitizer.sanitize_string(dangerous_input)

    def test_sanitizer_detects_sql_injection(self):
        """✅ Should detect SQL injection patterns."""
        sql_injection = "'; DROP TABLE users; --"

        # This should raise ValueError
        with pytest.raises(ValueError):
            InputSanitizer.sanitize_string(sql_injection)

    def test_sanitizer_detects_event_handlers(self):
        """✅ Should detect event handler attributes."""
        event_handler = "<a onclick='alert(1)'>Click</a>"

        with pytest.raises(ValueError):
            InputSanitizer.sanitize_string(event_handler)

    def test_sanitizer_detects_javascript_protocol(self):
        """✅ Should detect javascript: protocol."""
        js_protocol = "<a href='javascript:alert(1)'>Click</a>"

        with pytest.raises(ValueError):
            InputSanitizer.sanitize_string(js_protocol)

    def test_sanitizer_rejects_excessive_length(self):
        """✅ Should reject input exceeding max_length."""
        long_input = "a" * 1001  # default max_length is 1000

        with pytest.raises(ValueError, match="exceeds maximum length"):
            InputSanitizer.sanitize_string(long_input)

    def test_sanitizer_allows_custom_max_length(self):
        """✅ Should respect custom max_length parameter."""
        # 500 chars is ok with default 1000
        input_500 = "a" * 500
        result = InputSanitizer.sanitize_string(input_500, max_length=1000)
        assert result == input_500

    def test_sanitizer_trims_whitespace(self):
        """✅ Should trim leading/trailing whitespace."""
        input_with_spaces = "  hello world  "

        result = InputSanitizer.sanitize_string(input_with_spaces)

        assert result == "hello world"

    def test_sanitizer_allows_normal_text(self):
        """✅ Should allow normal, safe text."""
        normal_text = "Explain Clean Architecture principles"

        result = InputSanitizer.sanitize_string(normal_text)

        assert result == normal_text

    def test_sanitizer_allows_punctuation(self):
        """✅ Should allow normal punctuation."""
        text_with_punct = "What are best practices? I'd like to know!"

        result = InputSanitizer.sanitize_string(text_with_punct)

        assert result == text_with_punct

    def test_sanitizer_case_insensitive_pattern_matching(self):
        """✅ Pattern matching should be case-insensitive."""
        uppercase_script = "<SCRIPT>alert('xss')</SCRIPT>"

        with pytest.raises(ValueError):
            InputSanitizer.sanitize_string(uppercase_script)

    def test_sanitizer_mixed_case_sql(self):
        """✅ Should detect SQL patterns in mixed case."""
        mixed_sql = "'; DrOp TaBlE users; --"

        with pytest.raises(ValueError):
            InputSanitizer.sanitize_string(mixed_sql)


class TestSanitizePrompt:
    """Test sanitize_prompt method."""

    def test_sanitize_prompt_has_higher_limit(self):
        """✅ Prompts should have higher character limit."""
        # 5000 chars is the limit for prompts
        long_prompt = "a" * 4999  # Just under 5000

        result = InputSanitizer.sanitize_prompt(long_prompt)

        assert len(result) == 4999

    def test_sanitize_prompt_rejects_over_limit(self):
        """✅ Prompts over 5000 chars should be rejected."""
        too_long_prompt = "a" * 5001

        with pytest.raises(ValueError, match="exceeds maximum length"):
            InputSanitizer.sanitize_prompt(too_long_prompt)

    def test_sanitize_prompt_detects_xss(self):
        """✅ Prompts should still detect XSS."""
        xss_prompt = "How to do <script>alert('xss')</script>?"

        with pytest.raises(ValueError):
            InputSanitizer.sanitize_prompt(xss_prompt)

    def test_sanitize_prompt_allows_normal_prompts(self):
        """✅ Normal prompts should be allowed."""
        normal_prompt = "What is Clean Architecture and why is it important?"

        result = InputSanitizer.sanitize_prompt(normal_prompt)

        assert result == normal_prompt


class TestTokenValidatorEdgeCases:
    """Test TokenValidator with edge cases (lines 83-92, 123)."""

    def test_validate_api_key_with_exact_length_10(self):
        """✅ API key with exactly 10 characters should be valid."""
        api_key = "1234567890"  # Exactly 10

        result = TokenValidator.validate_api_key(api_key)

        assert result is True

    def test_validate_api_key_with_length_9(self):
        """✅ API key with 9 characters should be invalid."""
        api_key = "123456789"  # Only 9

        result = TokenValidator.validate_api_key(api_key)

        assert result is False

    def test_validate_api_key_with_length_11(self):
        """✅ API key with 11 characters should be valid."""
        api_key = "12345678901"  # 11 chars

        result = TokenValidator.validate_api_key(api_key)

        assert result is True

    def test_validate_api_key_with_none(self):
        """✅ None should be invalid."""
        result = TokenValidator.validate_api_key(None)

        assert result is False

    def test_validate_api_key_with_empty_string(self):
        """✅ Empty string should be invalid."""
        result = TokenValidator.validate_api_key("")

        assert result is False

    def test_validate_api_key_with_spaces_only(self):
        """✅ Whitespace-only string should be invalid."""
        result = TokenValidator.validate_api_key("     ")

        # Spaces don't make a valid 10-char key... actually they do
        # Length is 5, so it should be False
        assert result is False

    def test_validate_api_key_with_long_key(self):
        """✅ Very long API key should be valid."""
        long_key = "a" * 1000

        result = TokenValidator.validate_api_key(long_key)

        assert result is True

    def test_validate_api_key_with_special_characters(self):
        """✅ Special characters in API key should be allowed."""
        api_key = "sk-_.-12345"  # 10 chars with special chars

        result = TokenValidator.validate_api_key(api_key)

        assert result is True

    def test_validate_api_key_with_unicode_characters(self):
        """✅ Unicode characters should be counted correctly."""
        api_key = "sk_café1234"  # accented char + 9 regular = 10

        result = TokenValidator.validate_api_key(api_key)

        # Should be True if it's at least 10 chars total
        assert result is True


class TestTokenValidatorIntegration:
    """Integration tests for TokenValidator."""

    def test_validate_real_api_key_format(self):
        """✅ Should validate realistic API key formats."""
        # Simulate real OpenAI-like format
        api_key = "sk_test_1234567890abcdef"

        result = TokenValidator.validate_api_key(api_key)

        assert result is True

    def test_validate_uuid_as_api_key(self):
        """✅ UUID format should be valid."""
        uuid_key = "550e8400-e29b-41d4-a716-446655440000"

        result = TokenValidator.validate_api_key(uuid_key)

        assert result is True

    def test_validate_base64_like_key(self):
        """✅ Base64-like strings should be valid."""
        base64_key = "YWJjZGVmZ2hpamtsbW4="

        result = TokenValidator.validate_api_key(base64_key)

        assert result is True
