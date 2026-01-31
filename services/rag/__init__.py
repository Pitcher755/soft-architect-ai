"""RAG (Retrieval Augmented Generation) service module.

This module provides functionality for document loading, processing, and
semantic chunking to build a knowledge base for AI-powered retrieval.

Main components:
- DocumentLoader: Recursive Markdown file loading with semantic chunking
- MarkdownCleaner: Text normalization and security hardening
"""

from .document_loader import DocumentLoader, DocumentMetadata, DocumentChunk
from .markdown_cleaner import MarkdownCleaner

__all__ = [
    "DocumentLoader",
    "DocumentMetadata",
    "DocumentChunk",
    "MarkdownCleaner",
]
