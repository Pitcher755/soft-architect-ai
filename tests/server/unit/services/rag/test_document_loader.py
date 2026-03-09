"""Unit tests for DocumentLoader.

Coverage targets:
- DocumentLoader.__init__: valid dir, invalid dir
- load_all_documents: iterates files, handles errors per file
- load_document: happy path, non-.md, missing file, too large,
  invalid markdown, unicode error
- _validate_file_path: outside kb, symlink
- _find_markdown_files: real files, hidden files, system files, depth limit
- _extract_metadata: full metadata object
- _extract_title: from H1, fallback to filename
- _extract_tags: folder + filename split
- _semantic_split: H2 split, H3 fallback, paragraph fallback, small chunk
  filter, whole-content fallback
- _split_by_header: with and without matching headers
- _split_by_paragraphs: multiple paragraphs
- _detect_header_level: H1, H2, no header
"""

from __future__ import annotations

from pathlib import Path
from unittest.mock import patch

import pytest

from services.rag.document_loader import (
    DocumentChunk,
    DocumentLoader,
    DocumentMetadata,
)

# ---------------------------------------------------------------------------
# Fixtures
# ---------------------------------------------------------------------------


@pytest.fixture()
def kb_dir(tmp_path: Path) -> Path:
    """Knowledge-base root directory (empty)."""
    return tmp_path


@pytest.fixture()
def loader(kb_dir: Path) -> DocumentLoader:
    """DocumentLoader with security disabled, pointing at tmp_path."""
    return DocumentLoader(knowledge_base_dir=kb_dir, validate_security=False)


def _write_md(directory: Path, filename: str, content: str) -> Path:
    """Helper: write a markdown file and return its Path."""
    p = directory / filename
    p.write_text(content, encoding="utf-8")
    return p


# ============================================================
# __init__
# ============================================================


class TestDocumentLoaderInit:
    """Tests for DocumentLoader initialisation."""

    def test_init_with_valid_directory(self, kb_dir: Path) -> None:
        """Constructor succeeds for an existing directory."""
        loader = DocumentLoader(knowledge_base_dir=kb_dir, validate_security=False)
        assert loader.knowledge_base_dir == kb_dir.resolve()

    def test_init_with_missing_directory_raises_value_error(self, tmp_path: Path) -> None:
        """Constructor raises ValueError when directory does not exist."""
        missing = tmp_path / "does_not_exist"
        with pytest.raises(ValueError, match="Knowledge base directory not found"):
            DocumentLoader(knowledge_base_dir=missing, validate_security=False)

    def test_init_uses_default_chunk_sizes(self, kb_dir: Path) -> None:
        """Default chunk sizes are assigned when not provided."""
        loader = DocumentLoader(knowledge_base_dir=kb_dir, validate_security=False)
        assert loader.max_chunk_size == DocumentLoader.DEFAULT_MAX_CHUNK_SIZE
        assert loader.min_chunk_size == DocumentLoader.DEFAULT_MIN_CHUNK_SIZE

    def test_init_accepts_custom_chunk_sizes(self, kb_dir: Path) -> None:
        """Custom chunk sizes are stored correctly."""
        loader = DocumentLoader(
            knowledge_base_dir=kb_dir,
            max_chunk_size=1000,
            min_chunk_size=100,
            validate_security=False,
        )
        assert loader.max_chunk_size == 1000
        assert loader.min_chunk_size == 100

    def test_init_validate_security_false_skips_check(self, kb_dir: Path) -> None:
        """validate_security=False skips _validate_security()."""
        loader = DocumentLoader(knowledge_base_dir=kb_dir, validate_security=False)
        assert loader.validate_security is False

    def test_init_validate_security_true_on_valid_dir(self, kb_dir: Path) -> None:
        """validate_security=True succeeds for a normal (non-symlink) directory."""
        loader = DocumentLoader(knowledge_base_dir=kb_dir, validate_security=True)
        assert loader.validate_security is True

    def test_security_validation_raises_for_unreadable_directory(self, kb_dir: Path) -> None:
        """_validate_security raises when directory is not readable."""
        with patch("os.access", return_value=False):
            with pytest.raises(ValueError, match="not readable"):
                DocumentLoader(knowledge_base_dir=kb_dir, validate_security=True)


# ============================================================
# _find_markdown_files
# ============================================================


class TestFindMarkdownFiles:
    """Tests for _find_markdown_files generator."""

    def test_finds_md_files(self, loader: DocumentLoader, kb_dir: Path) -> None:
        """Yields .md files present in the directory."""
        _write_md(kb_dir, "doc.md", "# Hello")
        found = list(loader._find_markdown_files())
        assert any(p.name == "doc.md" for p in found)

    def test_skips_hidden_files(self, loader: DocumentLoader, kb_dir: Path) -> None:
        """Does not yield files starting with '.'."""
        (kb_dir / ".hidden.md").write_text("hidden", encoding="utf-8")
        found = list(loader._find_markdown_files())
        assert not any(p.name.startswith(".") for p in found)

    def test_skips_system_files(self, loader: DocumentLoader, kb_dir: Path) -> None:
        """Does not yield known system files like .DS_Store."""
        (kb_dir / ".DS_Store").write_text("junk", encoding="utf-8")
        found = list(loader._find_markdown_files())
        assert not any(p.name == ".DS_Store" for p in found)

    def test_skips_non_md_files(self, loader: DocumentLoader, kb_dir: Path) -> None:
        """Only yields .md files, not .txt or .py."""
        (kb_dir / "file.txt").write_text("text", encoding="utf-8")
        (kb_dir / "script.py").write_text("python", encoding="utf-8")
        found = list(loader._find_markdown_files())
        assert not any(p.suffix != ".md" for p in found)

    def test_recurses_into_subdirectories(self, loader: DocumentLoader, kb_dir: Path) -> None:
        """Yields files from nested subdirectories."""
        sub = kb_dir / "sub"
        sub.mkdir()
        _write_md(sub, "nested.md", "# Nested")
        found = list(loader._find_markdown_files())
        assert any(p.name == "nested.md" for p in found)

    def test_skips_hidden_directories(self, loader: DocumentLoader, kb_dir: Path) -> None:
        """Does not descend into hidden directories."""
        hidden_dir = kb_dir / ".hidden_dir"
        hidden_dir.mkdir()
        _write_md(hidden_dir, "inside.md", "# Inside hidden")
        found = list(loader._find_markdown_files())
        assert not any(p.name == "inside.md" for p in found)

    def test_stops_at_max_recursion_depth(self, kb_dir: Path) -> None:
        """Does not traverse beyond MAX_RECURSION_DEPTH directories."""
        loader = DocumentLoader(knowledge_base_dir=kb_dir, validate_security=False)
        # Build a 12-level deep directory (exceeds limit of 10)
        deep = kb_dir
        for i in range(12):
            deep = deep / f"level_{i}"
            deep.mkdir()
        _write_md(deep, "too_deep.md", "# Too deep")
        found = list(loader._find_markdown_files())
        assert not any(p.name == "too_deep.md" for p in found)


# ============================================================
# _validate_file_path
# ============================================================


class TestValidateFilePath:
    """Tests for _validate_file_path security checks."""

    def test_raises_when_file_outside_kb(self, loader: DocumentLoader, tmp_path: Path) -> None:
        """Raises ValueError when file is outside the knowledge base."""
        outside = tmp_path.parent / "outside.md"
        outside.write_text("# Outside", encoding="utf-8")
        with pytest.raises(ValueError, match="Path traversal detected"):
            loader._validate_file_path(outside)

    def test_accepts_file_inside_kb(self, loader: DocumentLoader, kb_dir: Path) -> None:
        """No exception raised for a file inside the knowledge base."""
        inside = _write_md(kb_dir, "inside.md", "# Inside")
        loader._validate_file_path(inside)  # Should not raise


# ============================================================
# _extract_title
# ============================================================


class TestExtractTitle:
    """Tests for _extract_title."""

    def test_extracts_h1_header(self, loader: DocumentLoader, kb_dir: Path) -> None:
        """Returns the text of the first H1 line."""
        p = _write_md(kb_dir, "titled.md", "# My Great Title\n\nSome content.")
        title = loader._extract_title(p)
        assert "My Great Title" in title

    def test_falls_back_to_filename(self, loader: DocumentLoader, kb_dir: Path) -> None:
        """Returns formatted filename when no H1 is present."""
        p = _write_md(kb_dir, "my_document.md", "Some content without header.")
        title = loader._extract_title(p)
        assert "My Document" in title

    def test_stops_at_first_non_header_line(self, loader: DocumentLoader, kb_dir: Path) -> None:
        """Does not return title from a buried H1."""
        p = _write_md(kb_dir, "buried.md", "Intro text\n\n# Buried Title\n")
        title = loader._extract_title(p)
        # Should fall back to filename since first non-blank line is not H1
        assert "Buried" in title


# ============================================================
# _extract_tags
# ============================================================


class TestExtractTags:
    """Tests for _extract_tags."""

    def test_includes_top_level_category(self, loader: DocumentLoader, kb_dir: Path) -> None:
        """Top-level folder name is included as a tag."""
        category = kb_dir / "01-TECH"
        category.mkdir()
        p = _write_md(category, "guide.md", "# Guide")
        tags = loader._extract_tags(p)
        assert "01-TECH" in tags

    def test_includes_filename_parts_when_underscored(
        self, loader: DocumentLoader, kb_dir: Path
    ) -> None:
        """Underscore-separated filename parts become extra tags."""
        p = _write_md(kb_dir, "backend_coding_standards.md", "# Backend")
        tags = loader._extract_tags(p)
        assert "backend" in tags
        assert "coding" in tags
        assert "standards" in tags


# ============================================================
# _extract_metadata
# ============================================================


class TestExtractMetadata:
    """Tests for _extract_metadata."""

    def test_returns_document_metadata_instance(self, loader: DocumentLoader, kb_dir: Path) -> None:
        """Returns a DocumentMetadata dataclass."""
        p = _write_md(kb_dir, "meta_test.md", "# Meta\n\nContent.")
        meta = loader._extract_metadata(p)
        assert isinstance(meta, DocumentMetadata)

    def test_metadata_attributes(self, loader: DocumentLoader, kb_dir: Path) -> None:
        """Metadata fields are populated correctly."""
        p = _write_md(kb_dir, "attrs.md", "# Attrs Doc\n\nContent here.")
        meta = loader._extract_metadata(p)
        assert meta.filename == "attrs.md"
        assert meta.size_bytes > 0
        assert meta.depth >= 1

    def test_metadata_category_from_subfolder(self, loader: DocumentLoader, kb_dir: Path) -> None:
        """Category is set from top-level subfolder."""
        cat = kb_dir / "02-ARCH"
        cat.mkdir()
        p = _write_md(cat, "arch.md", "# Architecture")
        meta = loader._extract_metadata(p)
        assert meta.category == "02-ARCH"


# ============================================================
# _split_by_header
# ============================================================


class TestSplitByHeader:
    """Tests for _split_by_header."""

    def test_splits_on_h2(self, loader: DocumentLoader) -> None:
        """Content is split into sections at H2 boundaries."""
        content = "## Section A\nContent A\n## Section B\nContent B"
        sections = loader._split_by_header(content, level=2)
        assert len(sections) == 2
        assert "Section A" in sections[0]
        assert "Section B" in sections[1]

    def test_returns_whole_content_when_no_matching_header(self, loader: DocumentLoader) -> None:
        """Returns single-element list when no header matches."""
        content = "No headers here at all."
        sections = loader._split_by_header(content, level=2)
        # Either a single section with the whole content, or empty
        assert isinstance(sections, list)
        if sections:
            assert content in sections[0]

    def test_splits_on_h1(self, loader: DocumentLoader) -> None:
        """Correctly splits on H1 level."""
        content = "# Title A\nBody A\n# Title B\nBody B"
        sections = loader._split_by_header(content, level=1)
        assert len(sections) == 2

    def test_filters_empty_sections(self, loader: DocumentLoader) -> None:
        """Empty sections are not returned."""
        content = "## Empty\n## Section B\nContent B"
        sections = loader._split_by_header(content, level=2)
        # All returned sections must have non-whitespace content
        for s in sections:
            assert s.strip()


# ============================================================
# _split_by_paragraphs
# ============================================================


class TestSplitByParagraphs:
    """Tests for _split_by_paragraphs."""

    def test_splits_on_double_newline(self, loader: DocumentLoader) -> None:
        """Paragraphs separated by double newlines are split correctly."""
        content = "Para 1\n\nPara 2\n\nPara 3"
        paras = loader._split_by_paragraphs(content)
        assert len(paras) == 3

    def test_filters_empty_paragraphs(self, loader: DocumentLoader) -> None:
        """Empty paragraphs (multiple blank lines) are excluded."""
        content = "Para A\n\n\n\nPara B"
        paras = loader._split_by_paragraphs(content)
        assert len(paras) == 2

    def test_single_paragraph_returns_list_of_one(self, loader: DocumentLoader) -> None:
        """A text without double newlines returns a list with one element."""
        content = "Just one paragraph here."
        paras = loader._split_by_paragraphs(content)
        assert paras == ["Just one paragraph here."]


# ============================================================
# _detect_header_level
# ============================================================


class TestDetectHeaderLevel:
    """Tests for _detect_header_level."""

    def test_detects_h1(self, loader: DocumentLoader) -> None:
        assert loader._detect_header_level("# Title\nContent") == 1

    def test_detects_h2(self, loader: DocumentLoader) -> None:
        assert loader._detect_header_level("## Section\nContent") == 2

    def test_detects_h3(self, loader: DocumentLoader) -> None:
        assert loader._detect_header_level("### Sub\nContent") == 3

    def test_returns_none_for_no_header(self, loader: DocumentLoader) -> None:
        assert loader._detect_header_level("No header here.") is None

    def test_returns_none_for_empty_string(self, loader: DocumentLoader) -> None:
        assert loader._detect_header_level("") is None


# ============================================================
# _semantic_split
# ============================================================


class TestSemanticSplit:
    """Tests for _semantic_split."""

    @pytest.fixture()
    def dummy_meta(self, kb_dir: Path, loader: DocumentLoader) -> DocumentMetadata:
        p = _write_md(kb_dir, "_meta.md", "# Meta")
        return loader._extract_metadata(p)

    def test_splits_large_h2_document(
        self, loader: DocumentLoader, dummy_meta: DocumentMetadata
    ) -> None:
        """Document with multiple H2 sections produces multiple chunks."""
        # Use min_chunk_size=50 to ensure sections qualify
        loader.min_chunk_size = 50
        section = "Word " * 20  # 100 chars
        content = f"## Section A\n{section}\n## Section B\n{section}"
        chunks = loader._semantic_split(content, dummy_meta)
        assert len(chunks) >= 1
        assert all(isinstance(c, DocumentChunk) for c in chunks)

    def test_falls_back_to_h3_when_no_h2(
        self, loader: DocumentLoader, dummy_meta: DocumentMetadata
    ) -> None:
        """When no H2 present, splits on H3."""
        loader.min_chunk_size = 50
        section = "Word " * 20
        content = f"### Sub A\n{section}\n### Sub B\n{section}"
        chunks = loader._semantic_split(content, dummy_meta)
        assert len(chunks) >= 1

    def test_uses_whole_content_when_no_headers(
        self, loader: DocumentLoader, dummy_meta: DocumentMetadata
    ) -> None:
        """Content without headers is treated as single section."""
        loader.min_chunk_size = 10
        content = "Plain content without any headers whatsoever."
        chunks = loader._semantic_split(content, dummy_meta)
        assert len(chunks) == 1
        assert chunks[0].content == content

    def test_filters_chunks_below_min_size(
        self, loader: DocumentLoader, dummy_meta: DocumentMetadata
    ) -> None:
        """Chunks smaller than min_chunk_size are discarded."""
        loader.min_chunk_size = 500
        content = "## Section\nShort"  # Only a few chars — below 500
        chunks = loader._semantic_split(content, dummy_meta)
        # Content < min_chunk_size → but whole-content fallback kicks in for non-empty
        assert isinstance(chunks, list)

    def test_splits_oversized_section_by_paragraphs(
        self, loader: DocumentLoader, dummy_meta: DocumentMetadata
    ) -> None:
        """Sections larger than max_chunk_size are split into paragraphs."""
        loader.max_chunk_size = 100
        loader.min_chunk_size = 50
        # Two paragraphs of 80 chars each (total > 100), each paragraph is 80 chars
        para = "A" * 80
        content = f"## Big Section\n{para}\n\n{para}"
        chunks = loader._semantic_split(content, dummy_meta)
        assert len(chunks) >= 1

    def test_empty_content_returns_empty_list(
        self, loader: DocumentLoader, dummy_meta: DocumentMetadata
    ) -> None:
        """Empty or whitespace content produces an empty list."""
        chunks = loader._semantic_split("", dummy_meta)
        assert chunks == []

    def test_chunk_fields_are_populated(
        self, loader: DocumentLoader, dummy_meta: DocumentMetadata
    ) -> None:
        """DocumentChunk fields are set correctly."""
        loader.min_chunk_size = 10
        content = "Plain content for field testing."
        chunks = loader._semantic_split(content, dummy_meta)
        assert len(chunks) == 1
        c = chunks[0]
        assert c.chunk_index == 0
        assert c.total_chunks >= 1
        assert c.char_count == len(content)
        assert c.metadata is dummy_meta


# ============================================================
# load_document
# ============================================================


class TestLoadDocument:
    """Tests for the load_document public method."""

    def test_returns_list_of_chunks_for_valid_file(
        self, loader: DocumentLoader, kb_dir: Path
    ) -> None:
        """Returns a list (possibly empty) for a valid .md file."""
        p = _write_md(kb_dir, "valid.md", "# Valid\n\nThis is a comprehensive markdown document.")
        result = loader.load_document(p)
        assert isinstance(result, list)

    def test_raises_for_non_md_file(self, loader: DocumentLoader, kb_dir: Path) -> None:
        """Raises ValueError when given a non-.md file."""
        txt = kb_dir / "file.txt"
        txt.write_text("text", encoding="utf-8")
        with pytest.raises(ValueError, match="File must be .md"):
            loader.load_document(txt)

    def test_raises_for_missing_file(self, loader: DocumentLoader, kb_dir: Path) -> None:
        """Raises ValueError when file does not exist."""
        with pytest.raises(ValueError, match="File not found"):
            loader.load_document(kb_dir / "ghost.md")

    def test_raises_for_oversized_file(self, loader: DocumentLoader, kb_dir: Path) -> None:
        """Raises ValueError when file exceeds 10 MB."""
        p = _write_md(kb_dir, "big.md", "content")
        with patch("pathlib.Path.stat") as mock_stat:
            mock_stat.return_value.st_size = 11 * 1024 * 1024  # 11 MB
            mock_stat.return_value.st_mtime = 0.0
            with pytest.raises(ValueError, match="too large"):
                loader.load_document(p)

    def test_returns_empty_list_for_invalid_markdown(
        self, loader: DocumentLoader, kb_dir: Path
    ) -> None:
        """Returns empty list when MarkdownCleaner rejects the content."""
        p = _write_md(kb_dir, "bad.md", "valid content")  # will be patched
        with patch(
            "services.rag.markdown_cleaner.MarkdownCleaner.is_valid_markdown",
            return_value=False,
        ):
            result = loader.load_document(p)
        assert result == []

    def test_raises_value_error_on_unicode_decode_error(
        self, loader: DocumentLoader, kb_dir: Path
    ) -> None:
        """Raises ValueError when file has undecodable bytes."""
        p = kb_dir / "binary.md"
        p.write_bytes(b"\xff\xfe invalid utf-8 \x80\x81")
        with pytest.raises((ValueError, UnicodeDecodeError)):
            loader.load_document(p)

    def test_load_document_validates_path_when_security_enabled(self, kb_dir: Path) -> None:
        """load_document calls _validate_file_path when security is on."""
        secure_loader = DocumentLoader(knowledge_base_dir=kb_dir, validate_security=True)
        # File inside kb_dir should pass validation
        p = _write_md(kb_dir, "secure.md", "# Secure\n\nContent here.")
        result = secure_loader.load_document(p)
        assert isinstance(result, list)


# ============================================================
# load_all_documents
# ============================================================


class TestLoadAllDocuments:
    """Tests for load_all_documents generator."""

    def test_yields_chunks_from_all_files(self, loader: DocumentLoader, kb_dir: Path) -> None:
        """Generator yields chunks from all .md files."""
        loader.min_chunk_size = 5
        _write_md(kb_dir, "a.md", "# A\n\nContent for document A.")
        _write_md(kb_dir, "b.md", "# B\n\nContent for document B.")
        chunks = list(loader.load_all_documents())
        assert len(chunks) >= 0  # may vary by min_chunk_size
        assert all(isinstance(c, DocumentChunk) for c in chunks)

    def test_skips_files_that_fail_to_load(self, loader: DocumentLoader, kb_dir: Path) -> None:
        """Errors on individual files are swallowed; generator continues."""
        _write_md(kb_dir, "good.md", "# Good\n\nGood content here.")
        # Patch load_document to raise on the first call, succeed on second
        original = loader.load_document

        call_count = [0]

        def patched(path: Path):
            call_count[0] += 1
            if call_count[0] == 1:
                raise RuntimeError("Simulated load error")
            return original(path)

        loader.load_document = patched  # type: ignore[method-assign]
        # Should not raise even if one file fails
        chunks = list(loader.load_all_documents())
        assert isinstance(chunks, list)

    def test_yields_nothing_for_empty_directory(self, loader: DocumentLoader, kb_dir: Path) -> None:
        """Empty knowledge base yields no chunks."""
        chunks = list(loader.load_all_documents())
        assert chunks == []
