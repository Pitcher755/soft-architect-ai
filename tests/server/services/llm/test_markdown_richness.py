"""Unit tests for RULE-03 Markdown Richness Validator (HU-5.0).

Tests the "WOW Effect" visual excellence requirements:
- Intensive emojis usage
- Code blocks with syntax highlighting
- Tables for structured data
- Directory tree visualization
- Color HEX palettes

Coverage target: Quality checks for generated documents
Expected test count: 4 tests
"""

import re


class MarkdownRichnessValidator:
    """Validates Markdown content for RULE-03 visual excellence."""

    @staticmethod
    def count_emojis(text: str) -> int:
        """
        Count emojis in text using Unicode emoji ranges.

        Returns:
            Number of emojis found
        """
        # Unicode emoji ranges (simplified)
        emoji_pattern = re.compile(
            "["
            "\U0001f600-\U0001f64f"  # Emoticons
            "\U0001f300-\U0001f5ff"  # Symbols & pictographs
            "\U0001f680-\U0001f6ff"  # Transport & map
            "\U0001f700-\U0001f77f"  # Alchemical symbols
            "\U0001f780-\U0001f7ff"  # Geometric shapes
            "\U0001f800-\U0001f8ff"  # Supplemental arrows
            "\U0001f900-\U0001f9ff"  # Supplemental symbols
            "\U0001fa00-\U0001fa6f"  # Chess symbols
            "\U0001fa70-\U0001faff"  # Symbols & pictographs extended
            "\U00002702-\U000027b0"  # Dingbats
            "\U000024c2-\U0001f251"  # Enclosed characters
            "]",
            flags=re.UNICODE,
        )
        return len(emoji_pattern.findall(text))

    @staticmethod
    def has_code_blocks(text: str) -> bool:
        """Check if text contains code blocks (```language)."""
        code_block_pattern = r"```\w+"
        return bool(re.search(code_block_pattern, text))

    @staticmethod
    def count_tables(text: str) -> int:
        """
        Count Markdown tables (rows with | separators).

        Returns:
            Number of table rows found
        """
        # Match lines like: | col1 | col2 | col3 |
        table_pattern = r"^\|(.+)\|$"
        return len(re.findall(table_pattern, text, re.MULTILINE))

    @staticmethod
    def has_directory_tree(text: str) -> bool:
        """Check if text contains directory tree visualization."""
        # Check for common tree characters: ├──, └──, │
        tree_indicators = ["├──", "└──", "│"]
        return any(indicator in text for indicator in tree_indicators)

    @staticmethod
    def has_hex_colors(text: str) -> bool:
        """Check if text contains HEX color codes (#RRGGBB)."""
        hex_color_pattern = r"#[0-9A-Fa-f]{6}\b"
        return bool(re.search(hex_color_pattern, text))


class TestMarkdownRichnessEmojis:
    """Tests for emoji usage in documents."""

    def test_document_contains_emojis(self):
        """
        RULE-03: Generated documents should contain emojis.

        Scenario: LLM generates document with emojis for visual appeal.
        Expected: count_emojis() returns > 0.
        """
        text = "🎯 Project Goal: Build an amazing app 🚀"

        emoji_count = MarkdownRichnessValidator.count_emojis(text)

        assert emoji_count > 0, "Document should contain emojis for WOW effect"
        assert emoji_count >= 2, f"Expected at least 2 emojis, found {emoji_count}"

    def test_document_without_emojis_fails(self):
        """
        RULE-03: Documents without emojis should be flagged.

        Scenario: Plain text document without visual elements.
        Expected: count_emojis() returns 0 (quality issue).
        """
        text = "Project Goal: Build an app"

        emoji_count = MarkdownRichnessValidator.count_emojis(text)

        assert emoji_count == 0, "Plain text should have no emojis"


class TestMarkdownRichnessCodeBlocks:
    """Tests for code block usage."""

    def test_document_contains_code_blocks(self):
        """
        RULE-03: Technical documents should have code blocks with syntax.

        Scenario: LLM generates document with ```python block.
        Expected: has_code_blocks() returns True.
        """
        text = """
        Example implementation:

        ```python
        def hello_world():
            print("Hello, World!")
        ```
        """

        has_code = MarkdownRichnessValidator.has_code_blocks(text)

        assert has_code is True, "Technical documents should have code blocks"

    def test_document_without_code_blocks(self):
        """
        RULE-03: Non-technical documents may not have code blocks.

        Scenario: Business document without code.
        Expected: has_code_blocks() returns False (OK for non-technical docs).
        """
        text = "This is a business document without code."

        has_code = MarkdownRichnessValidator.has_code_blocks(text)

        assert has_code is False, "Non-technical docs may not have code"


class TestMarkdownRichnessTables:
    """Tests for table usage."""

    def test_document_contains_tables(self):
        """
        RULE-03: Structured data should use Markdown tables.

        Scenario: LLM generates comparison table with | separators.
        Expected: count_tables() returns > 0.
        """
        text = """| Feature | Status | Priority |
|---------|--------|----------|
| Auth    | Done   | High     |
| Search  | WIP    | Medium   |"""

        table_count = MarkdownRichnessValidator.count_tables(text)

        assert table_count > 0, "Should detect Markdown table"
        assert table_count >= 3, f"Expected at least 3 table rows, found {table_count}"

    def test_document_without_tables(self):
        """
        RULE-03: Documents without structured data may not have tables.

        Scenario: Narrative document.
        Expected: count_tables() returns 0 (OK for narrative content).
        """
        text = "This is a narrative document without tables."

        table_count = MarkdownRichnessValidator.count_tables(text)

        assert table_count == 0, "Narrative docs may not have tables"


class TestMarkdownRichnessVisualElements:
    """Tests for advanced visual elements."""

    def test_document_contains_directory_tree(self):
        """
        RULE-03: Architecture documents should have directory tree.

        Scenario: LLM generates project structure with tree symbols.
        Expected: has_directory_tree() returns True.
        """
        text = """
        Project Structure:
        ```
        src/
        ├── client/
        │   ├── lib/
        │   └── test/
        └── server/
            └── app/
        ```
        """

        has_tree = MarkdownRichnessValidator.has_directory_tree(text)

        assert has_tree is True, "Architecture docs should have directory tree"

    def test_document_contains_hex_colors(self):
        """
        RULE-03: Design documents should have HEX color palettes.

        Scenario: LLM generates color scheme with #RRGGBB codes.
        Expected: has_hex_colors() returns True.
        """
        text = """
        Color Palette:
        - Primary: #3498db (Blue)
        - Success: #2ecc71 (Green)
        - Danger: #e74c3c (Red)
        """

        has_colors = MarkdownRichnessValidator.has_hex_colors(text)

        assert has_colors is True, "Design docs should have HEX color codes"

    def test_document_without_visual_elements(self):
        """
        RULE-03: Simple documents may lack advanced visuals.

        Scenario: Plain document without tree/colors.
        Expected: has_directory_tree() and has_hex_colors() return False.
        """
        text = "This is a simple document."

        has_tree = MarkdownRichnessValidator.has_directory_tree(text)
        has_colors = MarkdownRichnessValidator.has_hex_colors(text)

        assert has_tree is False, "Simple docs may not have tree"
        assert has_colors is False, "Simple docs may not have colors"
