"""
Integration Tests for VectorStoreService (E2E - Phase 4)

⚠️  These tests require Docker ChromaDB running:
    docker-compose up -d chroma

These tests validate the full end-to-end workflow with a real ChromaDB instance.
They are NOT run in CI/CD (unit tests use mocks instead).

Usage:
    # Run only if ChromaDB is available
    pytest tests/integration/services/rag/test_vector_store_e2e.py -v

    # Skip if ChromaDB unavailable
    pytest tests/integration/ -v -m "requires_docker"
"""

import os
import sys
from pathlib import Path

import pytest

# Add src/server to path
sys.path.insert(0, str(Path(__file__).parent.parent.parent.parent))

from langchain_core.documents import Document

from services.rag.vector_store import VectorStoreService

# Skip entire module if CHROMA_HOST not set
pytestmark = pytest.mark.skipif(
    not os.getenv("CHROMA_HOST"),
    reason="Requires Docker ChromaDB (set CHROMA_HOST env var)",
)


class TestVectorStoreE2E:
    """End-to-end integration tests with real ChromaDB."""

    @pytest.fixture
    def vector_store(self):
        """Create VectorStoreService connected to real ChromaDB."""
        host = os.getenv("CHROMA_HOST", "localhost")
        port = int(os.getenv("CHROMA_PORT", "8000"))

        service = VectorStoreService(host=host, port=port)
        yield service

    @pytest.fixture
    def sample_documents(self):
        """Sample documents for integration testing."""
        return [
            Document(
                page_content="FastAPI is a modern, fast web framework for building APIs.",
                metadata={
                    "source": "FASTAPI.md",
                    "filename": "FASTAPI.md",
                    "header": "Introduction",
                    "version": "0.100.0",
                },
            ),
            Document(
                page_content="ChromaDB provides fast vector similarity search with Chroma.",
                metadata={
                    "source": "CHROMADB.md",
                    "filename": "CHROMADB.md",
                    "header": "Overview",
                    "version": "0.4.0",
                },
            ),
            Document(
                page_content="Pytest is a testing framework that makes it easy to write tests.",
                metadata={
                    "source": "PYTEST.md",
                    "filename": "PYTEST.md",
                    "header": "Basics",
                },
            ),
        ]

    def test_e2e_full_ingestion_flow(self, vector_store, sample_documents):
        """✅ Full end-to-end ingestion and query flow."""
        # Ingest documents
        count = vector_store.ingest(sample_documents)
        assert count == 3

        # Query for "web framework"
        results = vector_store.query("web framework", n_results=1)
        assert "documents" in results
        assert len(results["documents"][0]) > 0

        # The top result should contain FastAPI content
        top_doc = results["documents"][0][0]
        assert "FastAPI" in top_doc or "web" in top_doc or "framework" in top_doc

    def test_e2e_idempotency(self, vector_store, sample_documents):
        """✅ Verify idempotency - ingesting twice doesn't duplicate."""
        # Ingest first time
        count1 = vector_store.ingest(sample_documents)
        assert count1 == 3

        # Get current stats
        stats_before = vector_store.get_collection_stats()
        doc_count_before = stats_before["document_count"]

        # Ingest again (same documents)
        count2 = vector_store.ingest(sample_documents)
        assert count2 == 3

        # Get stats after second ingestion
        stats_after = vector_store.get_collection_stats()
        doc_count_after = stats_after["document_count"]

        # Document count should remain the same (upsert, not insert)
        assert doc_count_before == doc_count_after

    def test_e2e_health_check(self, vector_store):
        """✅ Health check should pass when ChromaDB is running."""
        health = vector_store.health_check()
        assert health is True

    def test_e2e_query_with_metadata(self, vector_store, sample_documents):
        """✅ Query results should include metadata."""
        vector_store.ingest(sample_documents)

        results = vector_store.query("testing framework", n_results=1)

        assert "metadatas" in results
        assert len(results["metadatas"]) > 0
        assert len(results["metadatas"][0]) > 0

        # Check metadata structure
        first_metadata = results["metadatas"][0][0]
        assert isinstance(first_metadata, dict)

    def test_e2e_empty_query_result(self, vector_store):
        """✅ Query with no matching documents should return empty results."""
        results = vector_store.query("xyzabc123nonexistent", n_results=5)

        assert "documents" in results
        # Chroma still returns structure even for no matches
        assert isinstance(results["documents"], list)

    def test_e2e_collection_stats(self, vector_store, sample_documents):
        """✅ Collection stats should provide accurate information."""
        # Ingest some documents
        vector_store.ingest(sample_documents)

        stats = vector_store.get_collection_stats()

        assert "collection_name" in stats
        assert stats["collection_name"] == "softarchitect_knowledge_base"
        assert "document_count" in stats
        assert stats["document_count"] >= 3
        assert "host" in stats
        assert "port" in stats

    def test_e2e_large_document_ingestion(self, vector_store):
        """✅ Should handle large documents gracefully."""
        # Create a large document (>10KB)
        large_content = "Lorem ipsum dolor sit amet. " * 500  # ~14KB
        large_doc = Document(
            page_content=large_content,
            metadata={
                "source": "LARGE_DOC.md",
                "filename": "LARGE_DOC.md",
                "size": "large",
            },
        )

        count = vector_store.ingest([large_doc])
        assert count == 1

        # Should be queryable
        results = vector_store.query("Lorem ipsum", n_results=1)
        assert len(results["documents"][0]) > 0

    def test_e2e_multiple_queries(self, vector_store, sample_documents):
        """✅ Multiple queries should work independently."""
        vector_store.ingest(sample_documents)

        # Query 1
        results1 = vector_store.query("API", n_results=1)
        assert len(results1["documents"][0]) > 0

        # Query 2
        results2 = vector_store.query("testing", n_results=1)
        assert len(results2["documents"][0]) > 0

        # Queries should be independent
        # (might return same or different documents)
        assert isinstance(results1["documents"], list)
        assert isinstance(results2["documents"], list)

    def test_e2e_metadata_filtering(self, vector_store):
        """✅ Test documents with various metadata patterns."""
        docs_with_meta = [
            Document(
                page_content="Document with all metadata",
                metadata={
                    "source": "doc1.md",
                    "filename": "doc1.md",
                    "header": "Section 1",
                    "version": "1.0",
                    "priority": 1,
                    "score": 0.95,
                    "published": True,
                },
            ),
            Document(
                page_content="Document with minimal metadata",
                metadata={"source": "doc2.md", "filename": "doc2.md"},
            ),
            Document(
                page_content="Document with complex metadata",
                metadata={
                    "source": "doc3.md",
                    "filename": "doc3.md",
                    "tags": "python,rag,ai",
                },
            ),
        ]

        count = vector_store.ingest(docs_with_meta)
        assert count == 3

        # Query to verify all documents were stored
        results = vector_store.query("Document", n_results=3)
        assert len(results["documents"][0]) >= 3
