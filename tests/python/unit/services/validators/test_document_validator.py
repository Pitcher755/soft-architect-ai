"""Unit tests for DocumentValidator (TDD RED Phase).

This module tests document validation gates for content quality assurance.
All tests are expected to FAIL until implementation is complete (Phase 2).

Test Coverage:
- VAL_001: Minimum length validation
- VAL_002: Markdown structure validation
- VAL_003: UTF-8 encoding validation
- VAL_004: XSS pattern detection
- VAL_005: Maximum size validation
- Positive case: Valid document passes all gates
"""

import json
from pathlib import Path

import pytest

from app.services.validators.document_validator import DocumentValidator
from app.core.exceptions import ValidationError

# Load fixtures
FIXTURES_PATH = (
    Path(__file__).parent.parent.parent / "fixtures" / "document_fixtures.json"
)
with open(FIXTURES_PATH) as f:
    FIXTURES = json.load(f)


class TestDocumentValidator:
    """Test suite for document validation gates."""

    def test_validate_minimum_length_fails_with_short_content(self):
        """VAL_001: Should reject documents shorter than 50 chars."""
        validator = DocumentValidator()
        short_content = "Too short"

        with pytest.raises(ValidationError) as exc_info:
            validator.validate_content(short_content)

        assert exc_info.value.code == "VAL_001"
        assert "50 caracteres" in exc_info.value.message

    def test_validate_markdown_structure_fails_with_unbalanced_brackets(self):
        """VAL_002: Should reject documents with unclosed brackets."""
        validator = DocumentValidator()
        invalid_md = "# Unclosed header [link](broken"

        with pytest.raises(ValidationError) as exc_info:
            validator.validate_markdown(invalid_md)

        assert exc_info.value.code == "VAL_002"
        assert "mal formado" in exc_info.value.message

    def test_validate_markdown_structure_fails_with_unbalanced_parentheses(self):
        """VAL_002: Should reject documents with unclosed parentheses."""
        validator = DocumentValidator()
        invalid_md = "# Header (unclosed parenthesis"

        with pytest.raises(ValidationError) as exc_info:
            validator.validate_markdown(invalid_md)

        assert exc_info.value.code == "VAL_002"

    def test_validate_encoding_fails_with_non_utf8(self):
        """VAL_003: Should reject non-UTF-8 encoded content."""
        validator = DocumentValidator()
        # Simulate Latin-1 encoding error
        invalid_bytes = b"\xff\xfe Invalid UTF-8 content with bad bytes"

        with pytest.raises(ValidationError) as exc_info:
            validator.validate_encoding(invalid_bytes)

        assert exc_info.value.code == "VAL_003"
        assert "UTF-8" in exc_info.value.message

    def test_validate_xss_patterns_fails_with_script_tag(self):
        """VAL_004: Should detect and reject <script> tags."""
        validator = DocumentValidator()
        malicious_content = "<script>alert('XSS')</script>"

        with pytest.raises(ValidationError) as exc_info:
            validator.validate_safety(malicious_content)

        assert exc_info.value.code == "VAL_004"
        assert "malicioso" in exc_info.value.message

    def test_validate_xss_patterns_fails_with_javascript_protocol(self):
        """VAL_004: Should detect javascript: protocol."""
        validator = DocumentValidator()
        malicious_content = "[Click here](javascript:alert('XSS'))"

        with pytest.raises(ValidationError) as exc_info:
            validator.validate_safety(malicious_content)

        assert exc_info.value.code == "VAL_004"

    def test_validate_xss_patterns_fails_with_onerror_handler(self):
        """VAL_004: Should detect onerror event handlers."""
        validator = DocumentValidator()
        malicious_content = "<img src='x' onerror='alert(1)'>"

        with pytest.raises(ValidationError) as exc_info:
            validator.validate_safety(malicious_content)

        assert exc_info.value.code == "VAL_004"

    def test_validate_size_fails_with_oversized_content(self):
        """VAL_005: Should reject documents larger than 5MB."""
        validator = DocumentValidator()
        huge_content = "x" * (5 * 1024 * 1024 + 1)  # 5MB + 1 byte

        with pytest.raises(ValidationError) as exc_info:
            validator.validate_size(huge_content)

        assert exc_info.value.code == "VAL_005"
        assert "5MB" in exc_info.value.message or "5 MB" in exc_info.value.message

    def test_validate_all_passes_with_valid_document(self):
        """Should pass validation with valid content."""
        validator = DocumentValidator()
        valid_content = (
            "# Valid Document\n\n"
            "This is a valid Markdown document with sufficient length "
            "and proper structure for testing purposes."
        )

        result = validator.validate_all(valid_content)

        assert result is True

    def test_validate_all_with_fixtures_invalid_documents(self):
        """Should fail for all invalid fixtures."""
        validator = DocumentValidator()

        for doc in FIXTURES["invalid_documents"]:
            with pytest.raises(ValidationError) as exc_info:
                validator.validate_all(doc["content"])

            assert exc_info.value.code == doc["expected_error"], (
                f"Expected {doc['expected_error']} for {doc['id']}, "
                f"got {exc_info.value.code}"
            )

    def test_validate_all_with_fixtures_valid_documents(self):
        """Should pass for all valid fixtures."""
        validator = DocumentValidator()

        for doc in FIXTURES["valid_documents"]:
            result = validator.validate_all(doc["content"])
            assert result is True, f"Failed for valid document: {doc['id']}"
