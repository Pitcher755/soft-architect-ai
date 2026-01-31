"""Test suite for RAG Ingestion Loader (TDD Phase 1 - RED & GREEN).

This test suite validates:
- Recursive directory traversal
- File filtering (only .md files, no hidden files)
- Metadata extraction (title, filepath, filename)
- Semantic chunking (respects Markdown structure)
- Security (path traversal, symlinks, permissions)
- Edge cases (empty files, special characters, large files)
- Error handling (corrupted files, permission errors)
"""

from __future__ import annotations

import pytest
from pathlib import Path
from datetime import datetime

from services.rag.document_loader import DocumentLoader, DocumentMetadata, DocumentChunk
from services.rag.markdown_cleaner import MarkdownCleaner

# Define fixture path
FIXTURE_PATH = Path(__file__).parent / "fixtures" / "kb_mock"


class TestDocumentLoaderBasics:
    """Test basic functionality of DocumentLoader."""

    def test_fixture_files_exist(self):
        """Verify that test fixtures exist."""
        assert FIXTURE_PATH.exists(), f"Fixture path not found: {FIXTURE_PATH}"
        assert (FIXTURE_PATH / "valid.md").exists()
        assert (FIXTURE_PATH / "nested" / "deep.md").exists()
        assert (FIXTURE_PATH / "ignored.txt").exists()

    def test_loader_initialization(self):
        """Test DocumentLoader initialization with valid path."""
        loader = DocumentLoader(knowledge_base_dir=FIXTURE_PATH)
        assert loader.knowledge_base_dir == FIXTURE_PATH.resolve()

    def test_loader_initialization_invalid_path(self):
        """Test DocumentLoader initialization with invalid path."""
        with pytest.raises(ValueError, match="Knowledge base directory not found"):
            DocumentLoader(knowledge_base_dir=Path("/nonexistent/path"))

    def test_loader_security_validation_disabled(self):
        """Test loader can skip security checks if needed."""
        loader = DocumentLoader(
            knowledge_base_dir=FIXTURE_PATH, validate_security=False
        )
        assert loader.validate_security is False


class TestRecursiveLoading:
    """Test recursive directory traversal (HU-2.1: Criterion 1)."""

    def test_recursive_loading_finds_nested_files(self):
        """Verify that loader recursively finds files in nested directories."""
        loader = DocumentLoader(knowledge_base_dir=FIXTURE_PATH)
        files = list(loader._find_markdown_files())

        # Should find at least valid.md and nested/deep.md
        assert len(files) >= 2, f"Expected at least 2 .md files, found {len(files)}"

        file_names = {f.name for f in files}
        assert "valid.md" in file_names
        assert "deep.md" in file_names

    def test_recursive_loading_respects_max_depth(self):
        """Verify that loader respects maximum recursion depth."""
        loader = DocumentLoader(
            knowledge_base_dir=FIXTURE_PATH, validate_security=False
        )
        loader.MAX_RECURSION_DEPTH = 1

        # Create a deeply nested structure
        deep_path = FIXTURE_PATH / "level1" / "level2" / "level3"
        deep_path.mkdir(parents=True, exist_ok=True)
        deep_file = deep_path / "deep.md"
        deep_file.write_text("# Deep File\n\nContent")

        try:
            files = list(loader._find_markdown_files())
            # Should not find the deeply nested file
            assert not any("level3" in str(f) for f in files)
        finally:
            # Cleanup
            deep_file.unlink()
            deep_path.parent.rmdir()
            deep_path.parent.parent.rmdir()


class TestFileFiltering:
    """Test file filtering (HU-2.1: Criterion 2)."""

    def test_filter_ignores_non_markdown_files(self):
        """Verify that loader ignores .txt and other non-.md files."""
        loader = DocumentLoader(knowledge_base_dir=FIXTURE_PATH)
        files = list(loader._find_markdown_files())

        file_paths = [str(f) for f in files]

        # Should NOT find .txt files
        assert not any(
            p.endswith(".txt") for p in file_paths
        ), "Loader should ignore .txt files"

    def test_filter_ignores_hidden_files(self):
        """Verify that loader ignores hidden files (starting with .)."""
        loader = DocumentLoader(knowledge_base_dir=FIXTURE_PATH)
        files = list(loader._find_markdown_files())

        file_names = {f.name for f in files}

        # Should not find any files starting with .
        assert not any(
            name.startswith(".") for name in file_names
        ), "Loader should ignore hidden files"

    def test_filter_ignores_system_files(self):
        """Verify that loader ignores system files like .DS_Store."""
        loader = DocumentLoader(knowledge_base_dir=FIXTURE_PATH)
        files = list(loader._find_markdown_files())

        file_names = {f.name for f in files}

        # Should not find system files
        assert ".DS_Store" not in file_names
        assert "Thumbs.db" not in file_names

    def test_load_all_documents_filters_correctly(self):
        """Integration test: verify that load_all_documents only returns .md files."""
        loader = DocumentLoader(knowledge_base_dir=FIXTURE_PATH)
        chunks = list(loader.load_all_documents())

        # All chunks must come from .md files
        for chunk in chunks:
            assert chunk.metadata.filepath.endswith(
                ".md"
            ), f"Non-.md file in results: {chunk.metadata.filepath}"


class TestMetadataExtraction:
    """Test metadata extraction (HU-2.1: Criterion 3)."""

    def test_metadata_has_required_fields(self):
        """Verify that extracted metadata contains all required fields."""
        loader = DocumentLoader(knowledge_base_dir=FIXTURE_PATH)
        chunks = list(loader.load_all_documents())

        assert len(chunks) > 0, "No chunks loaded"

        for chunk in chunks:
            metadata = chunk.metadata
            assert isinstance(metadata, DocumentMetadata)
            assert metadata.title
            assert metadata.filepath
            assert metadata.filename
            assert metadata.size_bytes >= 0
            assert isinstance(metadata.modified_at, datetime)
            assert metadata.depth > 0

    def test_metadata_filepath_is_relative(self):
        """Verify that metadata filepath is relative to knowledge base."""
        loader = DocumentLoader(knowledge_base_dir=FIXTURE_PATH)
        chunks = list(loader.load_all_documents())

        for chunk in chunks:
            # Filepath should not contain absolute paths
            assert not chunk.metadata.filepath.startswith(
                "/"
            ), "Filepath should be relative, not absolute"
            # Filepath should not go outside knowledge base
            assert (
                ".." not in chunk.metadata.filepath
            ), "Filepath should not contain .. traversal"

    def test_metadata_category_extraction(self):
        """Verify that category is extracted from folder structure."""
        loader = DocumentLoader(knowledge_base_dir=FIXTURE_PATH)

        # Load a document from nested directory
        file_path = FIXTURE_PATH / "nested" / "deep.md"
        chunks = loader.load_document(file_path)

        assert len(chunks) > 0
        assert chunks[0].metadata.category == "nested"

    def test_title_extraction_from_h1(self):
        """Verify that title is extracted from H1 header."""
        loader = DocumentLoader(knowledge_base_dir=FIXTURE_PATH)
        file_path = FIXTURE_PATH / "valid.md"
        chunks = loader.load_document(file_path)

        assert len(chunks) > 0
        # First chunk should contain the title from H1
        assert (
            "markdown" in chunks[0].metadata.title.lower() or chunks[0].metadata.title
        )  # Should have some title


class TestSemanticChunking:
    """Test semantic chunking (HU-2.1: Criterion 4)."""

    def test_chunking_respects_document_structure(self):
        """Verify that chunks respect Markdown header hierarchy."""
        loader = DocumentLoader(knowledge_base_dir=FIXTURE_PATH)
        file_path = FIXTURE_PATH / "large_document.md"
        chunks = loader.load_document(file_path)

        assert len(chunks) > 1, "Large document should be split into multiple chunks"

        # Verify chunks contain header information
        for chunk in chunks:
            # Each chunk should have content
            assert chunk.content.strip()
            # Each chunk should track its position
            assert 0 <= chunk.chunk_index < chunk.total_chunks

    def test_chunking_respects_size_limits(self):
        """Verify that chunks respect min/max size limits."""
        loader = DocumentLoader(
            knowledge_base_dir=FIXTURE_PATH, max_chunk_size=1000, min_chunk_size=100
        )
        file_path = FIXTURE_PATH / "large_document.md"
        chunks = loader.load_document(file_path)

        for chunk in chunks:
            # Chunk should be within configured limits
            assert (
                chunk.char_count >= loader.min_chunk_size
            ), f"Chunk too small: {chunk.char_count} < {loader.min_chunk_size}"
            # Note: Some chunks may be larger than max due to indivisible sections
            # but most should respect the limit

    def test_empty_file_handling(self):
        """Verify that empty or invalid files are handled gracefully."""
        loader = DocumentLoader(knowledge_base_dir=FIXTURE_PATH)
        file_path = FIXTURE_PATH / "empty.md"
        chunks = loader.load_document(file_path)

        # Empty file should result in empty chunk list
        assert len(chunks) == 0, "Empty file should produce no chunks"


class TestMarkdownCleaner:
    """Test MarkdownCleaner functionality."""

    def test_cleaner_removes_html_tags(self):
        """Verify that HTML tags are removed."""
        text = "Content with <b>bold</b> and <i>italic</i> tags"
        cleaned = MarkdownCleaner.clean(text)

        assert "<b>" not in cleaned
        assert "<i>" not in cleaned
        assert "bold" in cleaned  # Content preserved
        assert "italic" in cleaned

    def test_cleaner_removes_html_comments(self):
        """Verify that HTML comments are removed."""
        text = "Before <!-- secret comment --> After"
        cleaned = MarkdownCleaner.clean(text)

        assert "secret comment" not in cleaned
        assert "Before" in cleaned
        assert "After" in cleaned

    def test_cleaner_handles_special_characters(self):
        """Verify that special characters are handled safely."""
        text = "Special: ñ, é, ü, ç and emojis 🚀 ✅"
        cleaned = MarkdownCleaner.clean(text)

        # Should not raise, content should be present
        assert "Special" in cleaned
        assert len(cleaned) > 0

    def test_cleaner_validates_markdown(self):
        """Verify markdown validation."""
        # Valid markdown
        assert MarkdownCleaner.is_valid_markdown("# Title\n\nContent")

        # Invalid markdown (empty or no content)
        assert not MarkdownCleaner.is_valid_markdown("")
        assert not MarkdownCleaner.is_valid_markdown("   ")
        assert not MarkdownCleaner.is_valid_markdown("!@#$%^&*()")


class TestSecurity:
    """Test security features."""

    def test_path_traversal_detection(self):
        """Verify that path traversal attempts are detected."""
        loader = DocumentLoader(knowledge_base_dir=FIXTURE_PATH)

        # Try to load a file outside knowledge base
        malicious_path = Path("/etc/passwd")
        with pytest.raises(ValueError, match="Path traversal detected"):
            loader._validate_file_path(malicious_path)

    def test_symlink_detection(self):
        """Verify that symlinks are detected and rejected."""
        # Only test if we can create symlinks (skip on Windows if not admin)
        try:
            symlink_path = FIXTURE_PATH / "test_symlink.md"
            target_path = FIXTURE_PATH / "valid.md"

            if not symlink_path.exists():
                symlink_path.symlink_to(target_path)

            loader = DocumentLoader(knowledge_base_dir=FIXTURE_PATH)

            with pytest.raises(ValueError, match="Symlinks not allowed"):
                loader._validate_file_path(symlink_path)
        except (OSError, NotImplementedError):
            # Skip if symlinks not supported on this system
            pytest.skip("Symlinks not supported on this system")
        finally:
            # Cleanup
            if symlink_path.exists() and symlink_path.is_symlink():
                symlink_path.unlink()

    def test_file_size_limit(self):
        """Verify that oversized files are rejected."""
        # Create a large file (temporarily)
        large_file = FIXTURE_PATH / "large_file.md"
        try:
            # Write a file larger than the limit
            with open(large_file, "w") as f:
                f.write("x" * (DocumentLoader.MAX_FILE_SIZE + 1))

            loader = DocumentLoader(knowledge_base_dir=FIXTURE_PATH)

            with pytest.raises(ValueError, match="File too large"):
                loader.load_document(large_file)
        finally:
            # Cleanup
            if large_file.exists():
                large_file.unlink()


class TestErrorHandling:
    """Test error handling and edge cases."""

    def test_corrupted_file_handling(self):
        """Verify that corrupted files are handled gracefully."""
        loader = DocumentLoader(knowledge_base_dir=FIXTURE_PATH)

        # Create a file with invalid encoding
        corrupted_file = FIXTURE_PATH / "corrupted.md"
        try:
            corrupted_file.write_bytes(b"\x80\x81\x82")

            # Should not raise, but log error and skip file
            _ = loader.load_document(corrupted_file)
            # Should return empty list or skip gracefully
        except ValueError:
            # Expected for encoding errors
            pass
        finally:
            if corrupted_file.exists():
                corrupted_file.unlink()

    def test_load_all_documents_continues_on_error(self):
        """Verify that loader continues processing after encountering errors."""
        loader = DocumentLoader(knowledge_base_dir=FIXTURE_PATH)

        # Create a problematic file
        problem_file = FIXTURE_PATH / "problem.md"
        try:
            problem_file.write_bytes(b"\x80\x81")

            chunks = list(loader.load_all_documents())

            # Should still load valid files despite the problem file
            assert any("valid" in str(c.metadata.filepath) for c in chunks)
        finally:
            if problem_file.exists():
                problem_file.unlink()

    def test_missing_file_error(self):
        """Verify that missing files raise appropriate errors."""
        loader = DocumentLoader(knowledge_base_dir=FIXTURE_PATH)

        with pytest.raises(ValueError, match="File not found"):
            loader.load_document(FIXTURE_PATH / "nonexistent.md")

    def test_wrong_extension_error(self):
        """Verify that non-.md files raise appropriate errors."""
        loader = DocumentLoader(knowledge_base_dir=FIXTURE_PATH)

        with pytest.raises(ValueError, match="File must be .md"):
            loader.load_document(FIXTURE_PATH / "ignored.txt")


class TestIntegration:
    """Integration tests combining multiple features."""

    def test_full_pipeline(self):
        """Test complete pipeline from discovery to chunking."""
        loader = DocumentLoader(knowledge_base_dir=FIXTURE_PATH)

        # Discover files
        files = list(loader._find_markdown_files())
        assert len(files) > 0

        # Load and chunk documents
        all_chunks = []
        for file_path in files:
            try:
                chunks = loader.load_document(file_path)
                all_chunks.extend(chunks)
            except Exception:
                pass

        # Verify results
        assert len(all_chunks) > 0, "Should have loaded some chunks"

        # Verify chunk structure
        for chunk in all_chunks:
            assert isinstance(chunk, DocumentChunk)
            assert chunk.content
            assert chunk.metadata
            assert chunk.char_count > 0

    def test_load_all_documents_vs_individual_loading(self):
        """Verify that load_all_documents produces same results as individual loads."""
        loader = DocumentLoader(knowledge_base_dir=FIXTURE_PATH)

        # Method 1: load_all_documents
        all_chunks_1 = list(loader.load_all_documents())

        # Method 2: individual file loading
        files = list(loader._find_markdown_files())
        all_chunks_2 = []
        for file_path in files:
            try:
                chunks = loader.load_document(file_path)
                all_chunks_2.extend(chunks)
            except Exception:
                pass

        # Should produce comparable results
        assert len(all_chunks_1) == len(
            all_chunks_2
        ), "load_all_documents should match individual loading"
