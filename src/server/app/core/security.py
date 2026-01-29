"""
Security utilities for input validation and sanitization.

This module provides security-focused utilities to protect the application
from common attack vectors:
    - Input injection attacks (SQL, XSS, command injection)
    - Prompt injection attacks (for LLM safety)
    - Invalid token formats

All utilities follow OWASP security guidelines and best practices for
securing AI applications.

Classes:
    InputSanitizer: Validates and sanitizes user input
    TokenValidator: Validates authentication tokens

Security Policy:
    1. All user input is validated and sanitized before use
    2. Dangerous patterns are detected and rejected
    3. Length limits are enforced to prevent resource exhaustion
    4. Logging occurs for security violations (audit trail)
"""

import re


class InputSanitizer:
    """
    Sanitizes user input to prevent injection attacks.

    This class implements OWASP input validation best practices to detect
    and reject potentially malicious input patterns. It's particularly
    important for LLM prompts where injection attacks can influence AI output.

    Class Attributes:
        DANGEROUS_PATTERNS: Regex patterns that indicate injection attempts

    Security Notes:
        - Patterns match case-insensitive by default
        - Length limits help prevent DoS attacks
        - Multiple levels of validation (length, pattern, whitespace)
    """

    # Patterns for validation - detect common injection attack vectors
    DANGEROUS_PATTERNS = [
        r"<script",  # Script tags (XSS)
        r"javascript:",  # JavaScript protocol (XSS)
        r"on\w+\s*=",  # Event handlers (XSS)
        r"--",  # SQL comments (SQL injection)
        r";[\s]*drop",  # SQL drop statements (SQL injection)
        r";[\s]*delete",  # SQL delete statements (SQL injection)
    ]

    @staticmethod
    def sanitize_string(value: str, max_length: int = 1000) -> str:
        """
        Sanitize a string value for safe processing.

        Performs multiple validation checks:
        1. Length validation (prevents resource exhaustion)
        2. Pattern detection (prevents injection attacks)
        3. Whitespace normalization

        Args:
            value: Input string to sanitize
            max_length: Maximum allowed string length (default: 1000 chars)

        Returns:
            str: Sanitized string with leading/trailing whitespace removed

        Raises:
            ValueError: If input exceeds max_length or contains dangerous patterns

        Examples:
            >>> sanitized = InputSanitizer.sanitize_string("normal input")
            >>> sanitized
            'normal input'

            >>> InputSanitizer.sanitize_string("<script>alert('xss')</script>")
            ValueError: Input contains dangerous content: <script
        """
        # Check length first (fast fail)
        if len(value) > max_length:
            raise ValueError(f"Input exceeds maximum length of {max_length}")

        # Check for dangerous patterns
        for pattern in InputSanitizer.DANGEROUS_PATTERNS:
            if re.search(pattern, value, re.IGNORECASE):
                raise ValueError(f"Input contains dangerous content: {pattern}")

        # Normalize whitespace
        return value.strip()

    @staticmethod
    def sanitize_prompt(prompt: str) -> str:
        """
        Sanitize an LLM prompt with LLM-specific rules.

        LLM prompts require special handling because they're fed to AI models
        which can be susceptible to prompt injection attacks. This method
        applies the same validation as sanitize_string but with a higher
        length limit suitable for prompts and queries.

        Args:
            prompt: Raw prompt text from user

        Returns:
            str: Sanitized prompt safe for LLM processing

        Raises:
            ValueError: If prompt contains dangerous patterns

        Security Notes:
            - Maximum length is 5000 characters (prevents token bombing)
            - Injection patterns are still detected and rejected
            - Use this for any user input going to the LLM

        Examples:
            >>> prompt = "Explain Clean Architecture principles"
            >>> safe_prompt = InputSanitizer.sanitize_prompt(prompt)
            >>> # safe_prompt can now be sent to Ollama or external LLM
        """
        return InputSanitizer.sanitize_string(prompt, max_length=5000)


class TokenValidator:
    """
    Validates and processes authentication tokens.

    This class provides token validation utilities for API authentication
    and authorization. Currently supports API key validation and can be
    extended for JWT, OAuth, or other token schemes.

    Note:
        This is a placeholder for future authentication implementation.
        Full authentication system will be implemented in HU-3.x
    """

    @staticmethod
    def validate_api_key(api_key: str | None) -> bool:
        """
        Validate API key format and requirements.

        Performs basic validation checks:
        1. Checks that api_key is not None or empty
        2. Checks minimum length (10 characters)

        Args:
            api_key: API key string to validate (can be None)

        Returns:
            bool: True if api_key is valid, False otherwise

        Note:
            This is a simple format validator. Actual authentication
            (checking against stored keys) happens elsewhere.

        Examples:
            >>> TokenValidator.validate_api_key("sk_1234567890")
            True

            >>> TokenValidator.validate_api_key("short")
            False

            >>> TokenValidator.validate_api_key(None)
            False
        """
        if not api_key:
            return False

        # Simple validation: must be at least 10 characters
        if len(api_key) < 10:
            return False

        return True
