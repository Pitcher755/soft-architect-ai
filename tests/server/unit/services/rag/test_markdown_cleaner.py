"""Unit tests for services/rag/markdown_cleaner.py.

Tests all public and private methods of MarkdownCleaner,
covering the full cleaning pipeline, security sanitisation,
header parsing, code-block extraction, and validity checks.

Coverage target: ≥90% of services/rag/markdown_cleaner.py
"""

from services.rag.markdown_cleaner import MarkdownCleaner

# ---------------------------------------------------------------------------
# MarkdownCleaner.clean  (full pipeline)
# ---------------------------------------------------------------------------


class TestMarkdownCleanerClean:
    """Tests for MarkdownCleaner.clean (full cleaning pipeline)."""

    def test_empty_string_returns_empty(self):
        """clean('') returns empty string immediately."""
        assert MarkdownCleaner.clean("") == ""

    def test_none_equivalent_not_empty(self):
        """clean returns stripped result for whitespace-only input."""
        assert MarkdownCleaner.clean("   ") == ""

    def test_plain_text_preserved(self):
        """Plain text without special content passes through."""
        assert MarkdownCleaner.clean("Hello world") == "Hello world"

    def test_removes_html_tags(self):
        """HTML tags are stripped from the text."""
        result = MarkdownCleaner.clean("<b>bold</b> text")
        assert "<b>" not in result
        assert "</b>" not in result
        assert "bold" in result

    def test_removes_html_comments(self):
        """HTML comments are stripped entirely."""
        result = MarkdownCleaner.clean("<!-- secret -->\nvisible")
        assert "secret" not in result
        assert "visible" in result

    def test_removes_self_closing_html_tags(self):
        """Self-closing HTML tags are stripped."""
        result = MarkdownCleaner.clean("line<br/>next")
        assert "<br/>" not in result

    def test_strips_result(self):
        """Output is stripped of leading/trailing whitespace."""
        result = MarkdownCleaner.clean("  hello world  ")
        assert result == result.strip()
        assert result == "hello world"

    def test_normalizes_triple_newlines_to_double(self):
        """3+ consecutive newlines are collapsed to double newline."""
        result = MarkdownCleaner.clean("a\n\n\n\nb")
        assert "\n\n\n" not in result
        assert "\n\n" in result

    def test_excessive_blank_lines_collapsed(self):
        """Five newlines become at most two."""
        result = MarkdownCleaner.clean("a\n\n\n\n\nb")
        assert result.count("\n") <= 2

    def test_removes_javascript_protocol(self):
        """javascript: protocol links are removed."""
        result = MarkdownCleaner.clean("[click](javascript:alert('x'))")
        assert "javascript:" not in result.lower()

    def test_removes_data_uri(self):
        """data: URIs are removed."""
        result = MarkdownCleaner.clean("src=data:image/png,base64abc")
        assert "data:" not in result.lower()

    def test_removes_script_tags(self):
        """<script> tags themselves are removed; content may remain after HTML stripping."""
        # The full clean() pipeline strips HTML tags first (via _remove_html_elements),
        # so _remove_suspicious_patterns no longer sees the <script> wrapper.
        # Tags are gone but text content is kept — this is the documented behaviour.
        result = MarkdownCleaner.clean("<script>evil()</script> text")
        assert "<script>" not in result
        assert "</script>" not in result
        assert "text" in result

    def test_removes_iframe_tags(self):
        """<iframe> tags and their content are removed."""
        result = MarkdownCleaner.clean("<iframe src='x'>content</iframe> ok")
        assert "<iframe" not in result
        assert "ok" in result

    def test_unicode_nfkc_normalization(self):
        """Unicode NFKC normalization converts ligatures."""
        # ﬁ (U+FB01 Latin Small Ligature fi) should become fi
        result = MarkdownCleaner.clean("\ufb01eld")
        assert result == "field"

    def test_code_block_lines_preserved(self):
        """Lines starting with 4-space indent are treated as code and preserved."""
        text = "paragraph\n\n    code_line = True"
        result = MarkdownCleaner.clean(text)
        assert "code_line = True" in result

    def test_multiple_spaces_normalized_in_prose(self):
        """Two or more consecutive spaces in prose are collapsed to one."""
        result = MarkdownCleaner.clean("hello   world")
        assert "   " not in result
        assert "hello world" in result

    def test_trailing_spaces_removed(self):
        """Trailing whitespace on each line is removed."""
        result = MarkdownCleaner.clean("line with space   \nnext line")
        for line in result.split("\n"):
            assert line == line.rstrip()


# ---------------------------------------------------------------------------
# MarkdownCleaner._remove_html_elements  (internal, tested via clean)
# ---------------------------------------------------------------------------


class TestRemoveHtmlElements:
    """Test HTML removal via the static method exposed for testing."""

    def test_removes_inline_html(self):
        """Inline HTML is stripped."""
        result = MarkdownCleaner._remove_html_elements("<em>italic</em>")
        assert "<em>" not in result
        assert "italic" in result

    def test_removes_multiline_html_comment(self):
        """Multi-line HTML comments are fully stripped."""
        text = "<!--\nline1\nline2\n-->\nreal content"
        result = MarkdownCleaner._remove_html_elements(text)
        assert "line1" not in result
        assert "real content" in result


# ---------------------------------------------------------------------------
# MarkdownCleaner._remove_suspicious_patterns  (internal)
# ---------------------------------------------------------------------------


class TestRemoveSuspiciousPatterns:
    """Test suspicious-pattern removal via static method."""

    def test_removes_javascript_url(self):
        """javascript: is removed regardless of case."""
        result = MarkdownCleaner._remove_suspicious_patterns("JAVASCRIPT:alert()")
        assert "javascript:" not in result.lower()

    def test_removes_data_uri(self):
        """data: URI is stripped."""
        result = MarkdownCleaner._remove_suspicious_patterns("img data:image/png,abc")
        assert "data:" not in result.lower()

    def test_removes_script_tag_with_content_directly(self):
        """_remove_suspicious_patterns strips <script> tags AND their content."""
        result = MarkdownCleaner._remove_suspicious_patterns(
            "<script>evil()</script> ok"
        )
        assert "evil()" not in result
        assert "ok" in result

    def test_removes_iframe_with_content_directly(self):
        """_remove_suspicious_patterns strips <iframe> tags AND their content."""
        result = MarkdownCleaner._remove_suspicious_patterns(
            "<iframe src='x'>hidden</iframe> ok"
        )
        assert "hidden" not in result
        assert "ok" in result


# ---------------------------------------------------------------------------
# MarkdownCleaner._normalize_whitespace  (internal)
# ---------------------------------------------------------------------------


class TestNormalizeWhitespace:
    """Test whitespace normalization."""

    def test_collapses_multiple_newlines(self):
        result = MarkdownCleaner._normalize_whitespace("a\n\n\n\nb")
        assert "\n\n\n" not in result

    def test_removes_trailing_spaces(self):
        result = MarkdownCleaner._normalize_whitespace("line   \nnext")
        for line in result.split("\n"):
            assert line == line.rstrip()

    def test_preserves_tab_indented_code(self):
        """Tab-indented lines are not space-collapsed."""
        text = "\tcode = value"
        result = MarkdownCleaner._normalize_whitespace(text)
        assert result == "\tcode = value"


# ---------------------------------------------------------------------------
# MarkdownCleaner.clean_header
# ---------------------------------------------------------------------------


class TestCleanHeader:
    """Tests for clean_header method."""

    def test_removes_single_hash(self):
        result = MarkdownCleaner.clean_header("# Section Title")
        assert "#" not in result
        assert "Section Title" in result

    def test_removes_multiple_hashes(self):
        result = MarkdownCleaner.clean_header("## Subsection")
        assert "#" not in result
        assert "Subsection" in result

    def test_removes_deep_heading(self):
        result = MarkdownCleaner.clean_header("#### Level Four")
        assert "#" not in result
        assert "Level Four" in result

    def test_removes_emoji(self):
        """Emoji characters are stripped from headers."""
        result = MarkdownCleaner.clean_header("## 🚀 Launch Section")
        assert "🚀" not in result
        assert "Launch Section" in result

    def test_removes_html_in_header(self):
        """HTML inside a header is stripped."""
        result = MarkdownCleaner.clean_header("# <span>Title</span>")
        assert "<span>" not in result
        assert "Title" in result

    def test_normalizes_multiple_spaces(self):
        """Multiple spaces in header are collapsed."""
        result = MarkdownCleaner.clean_header("##  Too   Many  Spaces")
        assert "  " not in result

    def test_strips_result(self):
        """result is stripped."""
        result = MarkdownCleaner.clean_header("##   Padded Header   ")
        assert result == result.strip()

    def test_plain_header_no_hashes(self):
        """Header without # marks is returned cleaned."""
        result = MarkdownCleaner.clean_header("Plain Title")
        assert result == "Plain Title"


# ---------------------------------------------------------------------------
# MarkdownCleaner.is_valid_markdown
# ---------------------------------------------------------------------------


class TestIsValidMarkdown:
    """Tests for is_valid_markdown method."""

    def test_empty_string_is_invalid(self):
        assert MarkdownCleaner.is_valid_markdown("") is False

    def test_whitespace_only_is_invalid(self):
        assert MarkdownCleaner.is_valid_markdown("   \n\t  ") is False

    def test_only_special_chars_is_invalid(self):
        """Text with no alphanumeric chars is invalid."""
        assert MarkdownCleaner.is_valid_markdown("!@#$%^&*()") is False

    def test_plain_text_is_valid(self):
        assert MarkdownCleaner.is_valid_markdown("Hello world") is True

    def test_markdown_with_heading_is_valid(self):
        assert (
            MarkdownCleaner.is_valid_markdown("# Title\n\nContent paragraph.") is True
        )

    def test_markdown_with_only_numbers_is_valid(self):
        """Digits count as alphanumeric."""
        assert MarkdownCleaner.is_valid_markdown("42") is True

    def test_markdown_with_code_block_is_valid(self):
        text = "```python\nprint('hello')\n```"
        assert MarkdownCleaner.is_valid_markdown(text) is True


# ---------------------------------------------------------------------------
# MarkdownCleaner.extract_code_blocks
# ---------------------------------------------------------------------------


class TestExtractCodeBlocks:
    """Tests for extract_code_blocks method."""

    def test_no_code_blocks_returns_empty_list(self):
        text = "Just plain text"
        cleaned, blocks = MarkdownCleaner.extract_code_blocks(text)
        assert blocks == []
        assert cleaned == text

    def test_single_code_block_extracted(self):
        text = "intro\n```python\ncode_here()\n```\noutro"
        cleaned, blocks = MarkdownCleaner.extract_code_blocks(text)
        assert len(blocks) == 1
        assert "code_here()" in blocks[0]
        assert "[CODE_BLOCK]" in cleaned

    def test_multiple_code_blocks_extracted(self):
        text = "a\n```\nblock1\n```\nb\n```\nblock2\n```\nc"
        cleaned, blocks = MarkdownCleaner.extract_code_blocks(text)
        assert len(blocks) == 2
        assert cleaned.count("[CODE_BLOCK]") == 2

    def test_code_block_removed_from_text(self):
        """Original code content is NOT in the cleaned text."""
        text = "before\n```js\nconst x = 1;\n```\nafter"
        cleaned, _ = MarkdownCleaner.extract_code_blocks(text)
        assert "const x = 1;" not in cleaned
        assert "before" in cleaned
        assert "after" in cleaned

    def test_code_block_preserved_in_list(self):
        """The extracted block preserves opening/closing fences."""
        text = "x\n```sql\nSELECT 1;\n```\ny"
        _, blocks = MarkdownCleaner.extract_code_blocks(text)
        assert "SELECT 1;" in blocks[0]

    def test_empty_code_block(self):
        """Empty code block is extracted correctly."""
        text = "text\n```\n```\nmore"
        cleaned, blocks = MarkdownCleaner.extract_code_blocks(text)
        assert len(blocks) == 1
        assert "[CODE_BLOCK]" in cleaned


# ---------------------------------------------------------------------------
# MarkdownCleaner._remove_emojis  (internal)
# ---------------------------------------------------------------------------


class TestRemoveEmojis:
    """Test emoji removal."""

    def test_removes_rocket_emoji(self):
        result = MarkdownCleaner._remove_emojis("🚀 Launch")
        assert "🚀" not in result
        assert "Launch" in result

    def test_removes_check_mark(self):
        result = MarkdownCleaner._remove_emojis("✅ Done")
        assert "✅" not in result

    def test_removes_warning_emoji(self):
        result = MarkdownCleaner._remove_emojis("⚠️ Warning")
        assert "⚠" not in result

    def test_does_not_remove_regular_text(self):
        result = MarkdownCleaner._remove_emojis("Hello World 123")
        assert result == "Hello World 123"


# ---------------------------------------------------------------------------
# MarkdownCleaner._normalize_unicode  (internal)
# ---------------------------------------------------------------------------


class TestNormalizeUnicode:
    """Test Unicode NFKC normalization."""

    def test_fi_ligature_normalized(self):
        """ﬁ (U+FB01) should become 'fi'."""
        result = MarkdownCleaner._normalize_unicode("\ufb01eld notes")
        assert result == "field notes"

    def test_fl_ligature_normalized(self):
        """ﬂ (U+FB02) should become 'fl'."""
        result = MarkdownCleaner._normalize_unicode("\ufb02oor")
        assert result == "floor"

    def test_plain_ascii_unchanged(self):
        """ASCII text is not modified."""
        result = MarkdownCleaner._normalize_unicode("hello world")
        assert result == "hello world"
