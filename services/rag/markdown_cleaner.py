"""Markdown text cleaner and normalizer for RAG ingestion.

This module provides utilities to sanitize and normalize Markdown content
before semantic chunking, ensuring consistent quality and security.
"""

from __future__ import annotations

import re
import unicodedata


class MarkdownCleaner:
    """Clean and normalize Markdown text for RAG ingestion.

    Features:
    - Remove HTML tags and comments
    - Normalize whitespace and line breaks
    - Remove or escape suspicious patterns
    - Preserve code blocks and important formatting
    - Handle special characters safely
    """

    # Patterns to remove
    HTML_TAG_PATTERN = re.compile(r"<[^>]+>", re.IGNORECASE | re.MULTILINE)
    HTML_COMMENT_PATTERN = re.compile(r"<!--.*?-->", re.DOTALL | re.MULTILINE)
    MULTIPLE_NEWLINES_PATTERN = re.compile(r"\n{3,}")
    MULTIPLE_SPACES_PATTERN = re.compile(r"  +")
    TRAILING_WHITESPACE_PATTERN = re.compile(r"[ \t]+$", re.MULTILINE)

    @staticmethod
    def clean(text: str) -> str:
        """Apply all cleaning steps to text.

        Args:
            text: Raw Markdown text.

        Returns:
            Cleaned text.
        """
        if not text or not isinstance(text, str):
            return ""

        # Step 1: Remove HTML comments and tags
        text = MarkdownCleaner._remove_html_elements(text)

        # Step 2: Normalize whitespace
        text = MarkdownCleaner._normalize_whitespace(text)

        # Step 3: Remove suspicious patterns
        text = MarkdownCleaner._remove_suspicious_patterns(text)

        # Step 4: Normalize unicode
        text = MarkdownCleaner._normalize_unicode(text)

        # Step 5: Final strip
        text = text.strip()

        return text

    @staticmethod
    def _remove_html_elements(text: str) -> str:
        """Remove HTML comments and tags.

        Args:
            text: Text to clean.

        Returns:
            Text without HTML elements.
        """
        # Remove HTML comments
        text = MarkdownCleaner.HTML_COMMENT_PATTERN.sub("", text)

        # Remove HTML tags (but keep their content if it's text)
        text = MarkdownCleaner.HTML_TAG_PATTERN.sub("", text)

        return text

    @staticmethod
    def _normalize_whitespace(text: str) -> str:
        """Normalize whitespace and line breaks.

        Preserves intentional line breaks in lists and code blocks,
        but normalizes excessive blank lines.

        Args:
            text: Text to normalize.

        Returns:
            Normalized text.
        """
        # Replace multiple newlines with double newline
        text = MarkdownCleaner.MULTIPLE_NEWLINES_PATTERN.sub("\n\n", text)

        # Remove trailing whitespace on each line
        text = MarkdownCleaner.TRAILING_WHITESPACE_PATTERN.sub("", text)

        # Normalize multiple spaces (except in code blocks)
        # Simple approach: replace 2+ spaces with single space
        # This is safe for Markdown since meaningful spacing uses newlines
        lines = text.split("\n")
        normalized_lines = []

        for line in lines:
            # Preserve lines that start with spaces (code blocks)
            if line.startswith("    ") or line.startswith("\t"):
                normalized_lines.append(line)
            else:
                # Normalize spaces in regular content
                normalized_lines.append(
                    MarkdownCleaner.MULTIPLE_SPACES_PATTERN.sub(" ", line)
                )

        text = "\n".join(normalized_lines)

        return text

    @staticmethod
    def _remove_suspicious_patterns(text: str) -> str:
        """Remove or escape potentially dangerous patterns.

        Args:
            text: Text to sanitize.

        Returns:
            Sanitized text.
        """
        # Remove javascript: protocol links
        text = re.sub(r"javascript:\s*", "", text, flags=re.IGNORECASE)

        # Remove data: URIs (can contain scripts)
        text = re.sub(r"data:[^,]*,", "", text, flags=re.IGNORECASE)

        # Remove iframe tags and content
        text = re.sub(
            r"<iframe[^>]*>.*?</iframe>", "", text, flags=re.IGNORECASE | re.DOTALL
        )

        # Remove script tags and content
        text = re.sub(
            r"<script[^>]*>.*?</script>", "", text, flags=re.IGNORECASE | re.DOTALL
        )

        return text

    @staticmethod
    def _normalize_unicode(text: str) -> str:
        """Normalize Unicode characters safely.

        Applies NFKC normalization which decomposes characters
        and recombines them in canonical form.

        Args:
            text: Text to normalize.

        Returns:
            Normalized text.
        """
        # Use NFKC normalization (compatible composition)
        # This converts things like ﬁ (ligature) to fi
        text = unicodedata.normalize("NFKC", text)

        return text

    @staticmethod
    def clean_header(header: str) -> str:
        """Clean and normalize Markdown header.

        Removes special formatting, emojis, and extra spaces.

        Args:
            header: Raw header text (including # marks).

        Returns:
            Cleaned header.
        """
        # Remove leading/trailing # marks
        cleaned = header.strip().lstrip("#").strip()

        # Remove emojis
        cleaned = MarkdownCleaner._remove_emojis(cleaned)

        # Remove HTML elements
        cleaned = MarkdownCleaner.HTML_TAG_PATTERN.sub("", cleaned)

        # Normalize spaces
        cleaned = MarkdownCleaner.MULTIPLE_SPACES_PATTERN.sub(" ", cleaned)

        return cleaned.strip()

    @staticmethod
    def _remove_emojis(text: str) -> str:
        """Remove emoji characters from text.

        Args:
            text: Text potentially containing emojis.

        Returns:
            Text without emojis.
        """
        # Remove emoji ranges (basic approach)
        # Emoji ranges: U+1F600–U+1F64F (emoticons), U+2600–U+27BF (symbols), etc.
        emoji_pattern = re.compile(
            "["
            "\U0001f600-\U0001f64f"  # emoticons
            "\U0001f300-\U0001f5ff"  # symbols & pictographs
            "\U0001f680-\U0001f6ff"  # transport & map symbols
            "\U0001f700-\U0001f77f"  # alchemical symbols
            "\U0001f780-\U0001f7ff"  # Geometric Shapes Extended
            "\U0001f800-\U0001f8ff"  # Supplemental Arrows-C
            "\U0001f900-\U0001f9ff"  # Supplemental Symbols and Pictographs
            "\U0001fa00-\U0001fa6f"  # Chess Symbols
            "\U0001fa70-\U0001faff"  # Symbols and Pictographs Extended-A
            "\U00002702-\U000027b0"
            "\U000024c2-\U0001f251"
            "]",
            flags=re.UNICODE,
        )

        return emoji_pattern.sub("", text)

    @staticmethod
    def extract_code_blocks(text: str) -> tuple[str, list[str]]:
        """Extract and preserve code blocks from Markdown.

        Args:
            text: Markdown text.

        Returns:
            Tuple of (text_without_code, list_of_code_blocks).
        """
        code_block_pattern = re.compile(r"```[\s\S]*?```", re.MULTILINE)
        code_blocks = code_block_pattern.findall(text)
        text_without_code = code_block_pattern.sub("[CODE_BLOCK]", text)

        return text_without_code, code_blocks

    @staticmethod
    def is_valid_markdown(text: str) -> bool:
        """Check if text appears to be valid Markdown.

        Basic heuristics:
        - Not empty
        - Contains some printable characters
        - Not just special characters

        Args:
            text: Text to validate.

        Returns:
            True if text appears valid.
        """
        if not text or len(text.strip()) == 0:
            return False

        # Must have at least some alphanumeric characters
        if not re.search(r"[a-zA-Z0-9]", text):
            return False

        return True
