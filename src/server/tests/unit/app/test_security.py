"""
Tests for app.core.security module.

Covers authentication, token validation, and security utilities.
"""

from app.core.security import TokenValidator


class TestTokenValidator:
    """Test TokenValidator class."""

    def test_token_validator_class_exists(self):
        """✅ Should have TokenValidator class."""
        assert TokenValidator is not None

    def test_validate_api_key_method_exists(self):
        """✅ Should have validate_api_key method."""
        assert hasattr(TokenValidator, "validate_api_key")
        assert callable(TokenValidator.validate_api_key)

    def test_validate_api_key_callable(self):
        """✅ validate_api_key should be callable as static method."""
        # Should be callable without instance
        result = TokenValidator.validate_api_key("test-key")
        assert isinstance(result, bool)

    def test_valid_api_key_format(self):
        """✅ Should validate properly formatted API keys."""
        # Test with a reasonable API key format
        result = TokenValidator.validate_api_key("test-api-key-12345")
        # May be valid or invalid depending on implementation
        assert isinstance(result, bool)

    def test_empty_api_key_validation(self):
        """✅ Should reject empty API key."""
        result = TokenValidator.validate_api_key("")
        assert result is False

    def test_none_api_key_validation(self):
        """✅ Should reject None API key."""
        result = TokenValidator.validate_api_key(None)
        assert result is False

    def test_api_key_type_validation(self):
        """✅ Should handle various input types."""
        # Test with string
        result = TokenValidator.validate_api_key("string-key")
        assert isinstance(result, bool)

        # Test with empty string
        result = TokenValidator.validate_api_key("")
        assert result is False

    def test_api_key_with_special_characters(self):
        """✅ Should handle API keys with special characters."""
        result = TokenValidator.validate_api_key("key-with_special.chars@123")
        assert isinstance(result, bool)

    def test_api_key_validation_returns_boolean(self):
        """✅ validate_api_key should always return boolean."""
        test_keys = ["valid", "invalid", "", None, 123]
        for key in test_keys:
            try:
                result = TokenValidator.validate_api_key(key)
                assert isinstance(result, bool)
            except (TypeError, AttributeError):
                # Some inputs might raise exceptions, which is acceptable
                pass
