"""
Security utilities for input validation and sanitization.
"""

import re


class InputSanitizer:
    """
    Sanitizes user input to prevent injection attacks.
    Follows OWASP guidelines.
    """

    # Patterns for validation
    DANGEROUS_PATTERNS = [
        r"<script",  # Script tags
        r"javascript:",  # JavaScript protocol
        r"on\w+\s*=",  # Event handlers
        r"--",  # SQL comments
        r";[\s]*drop",  # SQL drop statements
        r";[\s]*delete",  # SQL delete statements
    ]

    @staticmethod
    def sanitize_string(value: str, max_length: int = 1000) -> str:
        """
        Sanitize a string value.

        Args:
            value: Input string to sanitize
            max_length: Maximum allowed length

        Returns:
            Sanitized string

        Raises:
            ValueError: If input contains dangerous patterns
        """
        # Check length
        if len(value) > max_length:
            raise ValueError(f"Input exceeds maximum length of {max_length}")

        # Check for dangerous patterns
        for pattern in InputSanitizer.DANGEROUS_PATTERNS:
            if re.search(pattern, value, re.IGNORECASE):
                raise ValueError(f"Input contains dangerous content: {pattern}")

        return value.strip()

    @staticmethod
    def sanitize_prompt(prompt: str) -> str:
        """
        Sanitize an LLM prompt specifically.

        Args:
            prompt: Raw prompt from user

        Returns:
            Sanitized prompt
        """
        return InputSanitizer.sanitize_string(prompt, max_length=5000)


class TokenValidator:
    """
    Validates and processes authentication tokens.
    """

    @staticmethod
    def validate_api_key(api_key: str | None) -> bool:
        """
        Validate API key format.

        Args:
            api_key: API key to validate

        Returns:
            True if valid, False otherwise
        """
        if not api_key:
            return False

        # Simple validation: must be at least 10 characters
        if len(api_key) < 10:
            return False

        return True
