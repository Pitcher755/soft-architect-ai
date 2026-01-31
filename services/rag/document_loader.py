"""DocumentLoader for reading and processing Markdown files from knowledge base.

This module provides functionality to recursively load Markdown files from
packages/knowledge_base, extract metadata, and perform semantic chunking.

Security: Validates path traversal, symlinks, and file permissions.
"""

from __future__ import annotations

import os
import re
import logging
from pathlib import Path
from typing import Generator, Optional
from dataclasses import dataclass, field
from datetime import datetime

from .markdown_cleaner import MarkdownCleaner

# Configure logging
logger = logging.getLogger(__name__)


@dataclass
class DocumentMetadata:
    """Metadata extracted from a document."""

    title: str
    filepath: str
    filename: str
    size_bytes: int
    modified_at: datetime
    depth: int  # Folder depth in knowledge base hierarchy
    category: Optional[str] = None  # From folder structure (e.g., "02-TECH-PACKS")
    tags: list = field(default_factory=list)


@dataclass
class DocumentChunk:
    """A semantic chunk of document content."""

    content: str
    metadata: DocumentMetadata
    chunk_index: int
    total_chunks: int
    char_count: int
    header_level: Optional[int] = None  # H1, H2, H3, etc. if part of structure


class DocumentLoader:
    """Load and process Markdown documents from knowledge base.

    This loader:
    - Recursively traverses packages/knowledge_base directory
    - Extracts metadata (title, path, modified time)
    - Performs semantic splitting on large documents
    - Ignores non-.md files and system hidden files
    - Validates document integrity and security

    Security features:
    - Path traversal prevention
    - Symlink detection
    - File permission validation
    - Safe Unicode handling
    """

    # Configuration constants
    DEFAULT_MAX_CHUNK_SIZE = 2000  # characters
    DEFAULT_MIN_CHUNK_SIZE = 500  # characters
    SYSTEM_FILES = {".DS_Store", ".gitkeep", "Thumbs.db"}
    KNOWLEDGE_BASE_DIR = (
        Path(__file__).parent.parent.parent / "packages" / "knowledge_base"
    )

    # Security limits
    MAX_FILE_SIZE = 10 * 1024 * 1024  # 10 MB
    MAX_RECURSION_DEPTH = 10

    def __init__(
        self,
        knowledge_base_dir: Optional[Path] = None,
        max_chunk_size: int = DEFAULT_MAX_CHUNK_SIZE,
        min_chunk_size: int = DEFAULT_MIN_CHUNK_SIZE,
        validate_security: bool = True,
    ):
        """Initialize the DocumentLoader.

        Args:
            knowledge_base_dir: Path to knowledge_base root. If None, uses default.
            max_chunk_size: Maximum characters per chunk (before splitting).
            min_chunk_size: Minimum characters to consider a valid chunk.
            validate_security: Enable security checks (path traversal, symlinks).

        Raises:
            ValueError: If knowledge_base_dir doesn't exist or security check fails.
        """
        self.knowledge_base_dir = knowledge_base_dir or self.KNOWLEDGE_BASE_DIR
        self.max_chunk_size = max_chunk_size
        self.min_chunk_size = min_chunk_size
        self.validate_security = validate_security

        if not self.knowledge_base_dir.exists():
            raise ValueError(
                f"Knowledge base directory not found: {self.knowledge_base_dir}"
            )

        # Resolve to absolute path to prevent traversal
        self.knowledge_base_dir = self.knowledge_base_dir.resolve()

        if self.validate_security:
            self._validate_security()

        logger.info(f"DocumentLoader initialized with: {self.knowledge_base_dir}")

    def _validate_security(self) -> None:
        """Validate security constraints on knowledge base directory.

        Raises:
            ValueError: If security checks fail.
        """
        # Check for symlinks
        if self.knowledge_base_dir.is_symlink():
            raise ValueError(
                f"Knowledge base directory is a symlink: {self.knowledge_base_dir}"
            )

        # Check for path traversal attempts (.. in path)
        if ".." in str(self.knowledge_base_dir):
            raise ValueError("Path traversal detected: '..' in path")

        # Check readability
        if not os.access(self.knowledge_base_dir, os.R_OK):
            raise ValueError(
                f"Knowledge base directory not readable: {self.knowledge_base_dir}"
            )

    def load_all_documents(self) -> Generator[DocumentChunk, None, None]:
        """Yield all document chunks from knowledge base.

        Yields:
            DocumentChunk: Semantic chunks of documents.

        Example:
            >>> loader = DocumentLoader()
            >>> for chunk in loader.load_all_documents():
            ...     print(chunk.metadata.title)
        """
        for md_file in self._find_markdown_files():
            try:
                chunks = self.load_document(md_file)
                for chunk in chunks:
                    yield chunk
            except Exception as e:
                logger.error(f"Error processing {md_file}: {e}")
                continue

    def load_document(self, filepath: Path) -> list[DocumentChunk]:
        """Load and chunk a single document.

        Args:
            filepath: Path to .md file.

        Returns:
            List of DocumentChunk objects.

        Raises:
            ValueError: If file is not .md or doesn't exist.
            IOError: If file cannot be read.
        """
        filepath = Path(filepath).resolve()

        # Security: Validate file is within knowledge base
        if self.validate_security:
            self._validate_file_path(filepath)

        if filepath.suffix != ".md":
            raise ValueError(f"File must be .md: {filepath}")

        if not filepath.exists():
            raise ValueError(f"File not found: {filepath}")

        # Security: Check file size
        if filepath.stat().st_size > self.MAX_FILE_SIZE:
            raise ValueError(f"File too large (>10MB): {filepath}")

        # Extract metadata
        metadata = self._extract_metadata(filepath)

        # Read and clean content
        try:
            with open(filepath, "r", encoding="utf-8") as f:
                raw_content = f.read()
        except UnicodeDecodeError as e:
            logger.error(f"Unicode decode error in {filepath}: {e}")
            raise ValueError(f"File encoding error: {filepath}") from e

        # Validate Markdown
        if not MarkdownCleaner.is_valid_markdown(raw_content):
            logger.warning(f"File appears invalid: {filepath}")
            return []

        # Clean content
        cleaned_content = MarkdownCleaner.clean(raw_content)

        # Perform semantic chunking
        chunks = self._semantic_split(cleaned_content, metadata)

        return chunks

    def _validate_file_path(self, filepath: Path) -> None:
        """Validate that file is within knowledge base directory.

        Raises:
            ValueError: If path traversal or symlink detected.
        """
        # Ensure file is resolved (resolves symlinks)
        resolved_file = filepath.resolve()

        # Check that resolved file is under knowledge base
        try:
            resolved_file.relative_to(self.knowledge_base_dir)
        except ValueError:
            raise ValueError(
                f"Path traversal detected: {filepath} is outside knowledge base"
            )

        # Check for symlinks
        if filepath.is_symlink():
            raise ValueError(f"Symlinks not allowed: {filepath}")

    def _find_markdown_files(self) -> Generator[Path, None, None]:
        """Recursively find all .md files in knowledge_base.

        Yields:
            Path: Path to markdown files.

        Filters:
            - Skips hidden files (starting with .)
            - Skips system files (.DS_Store, etc.)
            - Only includes .md files
            - Validates recursion depth
        """
        for root, dirs, files in os.walk(self.knowledge_base_dir):
            # Check recursion depth
            depth = len(Path(root).relative_to(self.knowledge_base_dir).parts)
            if depth > self.MAX_RECURSION_DEPTH:
                logger.warning(f"Max recursion depth reached: {root}")
                dirs.clear()
                continue

            # Skip hidden directories (in-place modification of dirs list)
            dirs[:] = [d for d in dirs if not d.startswith(".")]

            for filename in files:
                # Skip hidden and system files
                if filename.startswith(".") or filename in self.SYSTEM_FILES:
                    continue

                # Only process .md files
                if not filename.endswith(".md"):
                    continue

                yield Path(root) / filename

    def _extract_metadata(self, filepath: Path) -> DocumentMetadata:
        """Extract metadata from a markdown file.

        Args:
            filepath: Path to document.

        Returns:
            DocumentMetadata object.
        """
        # Get basic file info
        stat = filepath.stat()
        relative_path = filepath.relative_to(self.knowledge_base_dir)
        depth = len(relative_path.parts)
        category = relative_path.parts[0] if relative_path.parts else None

        # Extract title from H1 or filename
        title = self._extract_title(filepath)

        return DocumentMetadata(
            title=title,
            filepath=str(relative_path),
            filename=filepath.name,
            size_bytes=stat.st_size,
            modified_at=datetime.fromtimestamp(stat.st_mtime),
            depth=depth,
            category=category,
            tags=self._extract_tags(filepath),
        )

    def _extract_title(self, filepath: Path) -> str:
        """Extract title from document.

        Priority:
        1. H1 header (# Title)
        2. Filename without extension
        """
        try:
            with open(filepath, "r", encoding="utf-8") as f:
                for line in f:
                    line = line.strip()
                    if line.startswith("# "):
                        # Extract title from H1 and clean it
                        title = line[2:].strip()
                        return MarkdownCleaner.clean_header(title)
                    if line and not line.startswith("#"):
                        # Stop at first non-header content
                        break
        except Exception as e:
            logger.debug(f"Could not extract title from {filepath}: {e}")

        # Fallback to filename
        return filepath.stem.replace("_", " ").replace("-", " ").title()

    def _extract_tags(self, filepath: Path) -> list[str]:
        """Extract tags from document metadata or filename.

        Args:
            filepath: Path to document.

        Returns:
            List of tag strings.
        """
        tags = []

        # Tags from folder structure
        relative_path = filepath.relative_to(self.knowledge_base_dir)
        if relative_path.parts:
            tags.append(relative_path.parts[0])

        # Tags from filename patterns (e.g., "backend_coding_standards.md")
        filename = filepath.stem.lower()
        if "_" in filename:
            tags.extend(filename.split("_"))

        return list(set(tags))  # Remove duplicates

    def _semantic_split(
        self, content: str, metadata: DocumentMetadata
    ) -> list[DocumentChunk]:
        """Perform semantic splitting on document content.

        Strategy:
        1. Split by H2 headers (semantic boundaries)
        2. If sections too large, split by H3
        3. If still too large, split by paragraphs
        4. Ensure min/max chunk sizes

        Args:
            content: Raw document content.
            metadata: Document metadata.

        Returns:
            List of DocumentChunk objects.
        """
        chunks = []

        # First pass: Split by H2 headers
        sections = self._split_by_header(content, level=2)

        if not sections:
            # No H2 headers, try H3
            sections = self._split_by_header(content, level=3)

        if not sections:
            # No semantic structure, use whole document
            sections = [content] if content else []

        chunk_index = 0
        for section in sections:
            # Check if section needs further splitting
            if len(section) > self.max_chunk_size:
                # Split by paragraphs
                sub_chunks = self._split_by_paragraphs(section)
            else:
                sub_chunks = [section]

            # Create chunks, filtering by size
            for sub_chunk in sub_chunks:
                sub_chunk = sub_chunk.strip()

                if len(sub_chunk) < self.min_chunk_size:
                    continue

                # Detect header level in chunk
                header_level = self._detect_header_level(sub_chunk)

                chunks.append(
                    DocumentChunk(
                        content=sub_chunk,
                        metadata=metadata,
                        chunk_index=chunk_index,
                        total_chunks=len(
                            [
                                x
                                for x in sub_chunks
                                if len(x.strip()) >= self.min_chunk_size
                            ]
                        ),
                        char_count=len(sub_chunk),
                        header_level=header_level,
                    )
                )
                chunk_index += 1

        # If no chunks were created, return the whole content as one chunk
        if not chunks and len(content.strip()) > 0:
            chunks.append(
                DocumentChunk(
                    content=content,
                    metadata=metadata,
                    chunk_index=0,
                    total_chunks=1,
                    char_count=len(content),
                    header_level=None,
                )
            )

        return chunks

    def _split_by_header(self, content: str, level: int) -> list[str]:
        """Split content by header level.

        Args:
            content: Document content.
            level: Header level (1-6, where 1 is H1 #).

        Returns:
            List of sections, each starting with the header.
        """
        header_marker = "#" * level
        pattern = f"^{re.escape(header_marker)} "

        sections = []
        current_section = []

        for line in content.split("\n"):
            if re.match(pattern, line) and current_section:
                # Start new section
                sections.append("\n".join(current_section))
                current_section = [line]
            else:
                current_section.append(line)

        if current_section:
            sections.append("\n".join(current_section))

        return [s for s in sections if s.strip()]

    def _split_by_paragraphs(self, content: str) -> list[str]:
        """Split content by paragraphs (double newlines).

        Args:
            content: Document content.

        Returns:
            List of paragraphs.
        """
        # Split by double newlines (paragraph breaks)
        paragraphs = content.split("\n\n")
        return [p.strip() for p in paragraphs if p.strip()]

    def _detect_header_level(self, chunk: str) -> Optional[int]:
        """Detect header level of chunk (if starts with header).

        Args:
            chunk: Document chunk.

        Returns:
            Header level (1-6) or None if no header.
        """
        first_line = chunk.split("\n")[0]
        match = re.match(r"^(#+)\s", first_line)
        if match:
            return len(match.group(1))
        return None
