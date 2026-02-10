"""Document validation gates for content quality assurance.

This module implements validation gates to ensure document quality before storage.
All validation errors are raised as ValidationError with specific error codes (VAL_*).

Validation Gates:
- VAL_001: Minimum length (>50 chars)
- VAL_002: Valid Markdown structure
- VAL_003: UTF-8 encoding
- VAL_004: No XSS patterns
- VAL_005: Maximum size (<5MB)
"""

import re
from typing import Final

from app.core.exceptions import ValidationError


class DocumentValidator:
    """Validates document content against quality gates.

    Optimized with pre-compiled regex patterns for better performance.
    """

    MIN_LENGTH: Final[int] = 50
    MAX_SIZE_BYTES: Final[int] = 5 * 1024 * 1024  # 5MB

    # XSS patterns (raw strings)
    XSS_PATTERNS: Final[list[str]] = [
        r"<script.*?>.*?</script>",
        r"javascript:",
        r"onerror\s*=",
        r"onload\s*=",
    ]

    # Pre-compiled regex patterns for performance (cached at class level)
    _XSS_PATTERNS_COMPILED: Final[list[re.Pattern[str]]] = [
        re.compile(pattern, re.IGNORECASE | re.DOTALL) for pattern in XSS_PATTERNS
    ]

    def validate_content(self, content: str) -> bool:
        """
        Validate minimum content length (VAL_001).

        Args:
            content: Document content to validate

        Returns:
            True if validation passes

        Raises:
            ValidationError: If content is shorter than MIN_LENGTH
        """
        if len(content) < self.MIN_LENGTH:
            raise ValidationError(
                code="VAL_001",
                message=f"El documento debe tener al menos {self.MIN_LENGTH} caracteres",
                operation="validate_content",
            )
        return True

    def validate_markdown(self, content: str) -> bool:
        """
        Validate Markdown structure (VAL_002).

        Checks for balanced brackets and parentheses.

        Args:
            content: Document content to validate

        Returns:
            True if validation passes

        Raises:
            ValidationError: If Markdown structure is invalid
        """
        # Check for unclosed brackets
        if content.count("[") != content.count("]"):
            raise ValidationError(
                code="VAL_002",
                message="El documento contiene Markdown mal formado (corchetes sin cerrar)",
                operation="validate_markdown",
            )

        # Check for unclosed parentheses
        if content.count("(") != content.count(")"):
            raise ValidationError(
                code="VAL_002",
                message="El documento contiene Markdown mal formado (paréntesis sin cerrar)",
                operation="validate_markdown",
            )

        return True

    def validate_encoding(self, content: bytes) -> bool:
        """
        Validate UTF-8 encoding (VAL_003).

        Args:
            content: Document content as bytes

        Returns:
            True if validation passes

        Raises:
            ValidationError: If content is not valid UTF-8
        """
        try:
            content.decode("utf-8")
        except UnicodeDecodeError as e:
            raise ValidationError(
                code="VAL_003",
                message="El documento no está codificado en UTF-8",
                operation="validate_encoding",
            ) from e

        return True

    def validate_safety(self, content: str) -> bool:
        """
        Validate against XSS patterns (VAL_004).

        Uses pre-compiled regex patterns for better performance.

        Args:
            content: Document content to validate

        Returns:
            True if validation passes

        Raises:
            ValidationError: If XSS patterns are detected
        """
        for pattern in self._XSS_PATTERNS_COMPILED:
            if pattern.search(content):
                raise ValidationError(
                    code="VAL_004",
                    message="El documento contiene código potencialmente malicioso",
                    operation="validate_safety",
                )

        return True

    def validate_size(self, content: str) -> bool:
        """
        Validate maximum size (VAL_005).

        Args:
            content: Document content to validate

        Returns:
            True if validation passes

        Raises:
            ValidationError: If content exceeds MAX_SIZE_BYTES
        """
        size_bytes = len(content.encode("utf-8"))
        if size_bytes > self.MAX_SIZE_BYTES:
            max_mb = self.MAX_SIZE_BYTES // 1024 // 1024
            raise ValidationError(
                code="VAL_005",
                message=f"El documento excede el tamaño máximo de {max_mb}MB",
                operation="validate_size",
            )

        return True

    def validate_all(self, content: str) -> bool:
        """
        Run all validation gates.

        Args:
            content: Document content to validate

        Returns:
            True if all validations pass

        Raises:
            ValidationError: If any validation fails
        """
        self.validate_content(content)
        self.validate_markdown(content)
        self.validate_encoding(content.encode("utf-8"))
        self.validate_safety(content)
        self.validate_size(content)
        return True
