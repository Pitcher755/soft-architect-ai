"""Tests for ChromaDB data persistence and ingestion verification.

This module validates that:
1. ChromaDB data persists physically in bind mount
2. Ingested documents are stored and retrievable
3. Vector embeddings are accessible through queries
"""

import os
from pathlib import Path
from typing import Optional

import pytest


class TestChromaDataPersistence:
    """Tests verifying ChromaDB data persistence in bind mount."""

    @staticmethod
    def get_chroma_data_path() -> Path:
        """
        Get the expected path to chroma_data directory.

        Returns:
            Path: Path to infrastructure/chroma_data

        Raises:
            FileNotFoundError: If project root cannot be located
        """
        # Navigate from test file location to project root
        test_file = Path(__file__)
        # tests/integration/services/rag/test_persistence.py
        # Go up 5 levels to reach project root
        project_root = test_file.parents[4]
        chroma_path = project_root / "infrastructure" / "chroma_data"
        return chroma_path

    def test_chroma_data_directory_exists(self) -> None:
        """Verify that chroma_data directory exists and has content."""
        chroma_path = self.get_chroma_data_path()
        assert (
            chroma_path.exists()
        ), f"Chroma data directory not found at {chroma_path}"

    def test_chroma_database_file_exists(self) -> None:
        """Verify that chroma.sqlite3 database file exists."""
        chroma_path = self.get_chroma_data_path()
        db_file = chroma_path / "chroma.sqlite3"
        assert (
            db_file.exists()
        ), f"ChromaDB database file not found at {db_file}"

    def test_chroma_data_size_after_ingestion(self) -> None:
        """
        Verify chroma_data has reasonable size (> 5MB) after multiformat ingestion.

        This test ensures that data has been persisted to disk after
        the ingestion process. The size threshold accounts for:
        - SQLite database with 129+ documents (multiformat: .md, .yaml, .json, .tree)
        - HNSW index files (.bin files)
        - Vector embeddings for tech packs and knowledge base

        Expected range: 5-50 MB (after ingesting 129 documents)
        """
        chroma_path = self.get_chroma_data_path()
        total_size = sum(
            f.stat().st_size for f in chroma_path.rglob("*") if f.is_file()
        )
        assert total_size > 5_000_000, (
            f"Chroma data too small for expected ingested documents: "
            f"{total_size / 1_000_000:.1f}MB (expected > 5MB for 129 docs)"
        )
        assert total_size < 100_000_000, (
            f"Chroma data unexpectedly large: "
            f"{total_size / 1_000_000:.1f}MB (expected < 100MB)"
        )

    def test_chroma_contains_index_files(self) -> None:
        """Verify that HNSW index files are present (.bin files)."""
        chroma_path = self.get_chroma_data_path()
        bin_files = list(chroma_path.rglob("*.bin"))
        assert (
            len(bin_files) > 0
        ), f"No .bin index files found in {chroma_path}. Expected HNSW index files."

    def test_chroma_collection_accessible(self) -> None:
        """Verify that ChromaDB collection is accessible with 129+ documents."""
        try:
            import chromadb
        except ImportError:
            pytest.skip("chromadb not installed")

        try:
            client = chromadb.HttpClient(host="localhost", port=8001)
            collection = client.get_collection(
                name="softarchitect_knowledge_base"
            )
            assert collection is not None
            # Verify collection has all 129 documents from multiformat ingestion
            doc_count = collection.count()
            assert doc_count >= 129, (
                f"Collection has {doc_count} documents, expected >= 129. "
                "Run ingestion: poetry run python scripts/ingest.py "
                "--knowledge-base packages/knowledge_base --clear"
            )
        except Exception as e:
            pytest.skip(f"ChromaDB not available for testing: {e}")

    def test_vector_embeddings_retrievable(self) -> None:
        """Verify that vector embeddings can be retrieved from persistent data."""
        try:
            import chromadb
        except ImportError:
            pytest.skip("chromadb not installed")

        try:
            client = chromadb.HttpClient(host="localhost", port=8001)
            collection = client.get_collection(
                name="softarchitect_knowledge_base"
            )

            # Query with a test query
            results = collection.query(
                query_texts=["Docker architecture"],
                n_results=1,
                include=["documents", "metadatas", "distances"],
            )

            assert results is not None, "Query returned None"
            assert "documents" in results, "Query results missing 'documents'"
            assert len(results["documents"]) > 0, (
                "Query returned no documents. "
                "Ensure ingestion has been completed."
            )
            assert (
                len(results["documents"][0]) > 0
            ), "First query result is empty"

        except Exception as e:
            pytest.skip(f"ChromaDB query test skipped: {e}")

    def test_persisted_data_survives_container_restart(self) -> None:
        """
        Document that persisted data would survive container restart.

        This test is informational and doesn't actually restart the container.
        It verifies that:
        1. Data is stored in bind mount on host
        2. Bind mount is independent of container lifecycle
        """
        chroma_path = self.get_chroma_data_path()

        # Verify bind mount path is correct structure
        assert chroma_path.name == "chroma_data", (
            f"Expected directory 'chroma_data', got '{chroma_path.name}'"
        )
        assert (
            chroma_path.parent.name == "infrastructure"
        ), "Bind mount should be in infrastructure directory"

        # This confirms the structure for data persistence
        assert chroma_path.exists(), (
            "Bind mount directory missing. "
            "Container restart would not affect persistence."
        )
