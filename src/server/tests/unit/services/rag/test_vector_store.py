"""
Unit Tests for VectorStoreService (HU-2.2)

TDD Approach: Tests written BEFORE implementation.
Uses Mocking to avoid dependency on Docker in CI.

Test Coverage:
- Connection failures (SYS_001)
- Document ingestion with metadata
- ID generation (deterministic hashing)
- Upsert idempotency
- Metadata cleaning (Chroma constraints)
"""

from unittest.mock import MagicMock, patch

import pytest
from langchain_core.documents import Document

from core.exceptions import ConnectionError, DatabaseWriteError

# ==================== FIXTURES ====================


@pytest.fixture
def sample_documents():
    """Sample documents output from HU-2.1 MarkdownLoader."""
    return [
        Document(
            page_content="Clean Architecture ensures that business rules are not coupled to UI frameworks.",
            metadata={
                "source": "CLEAN_ARCHITECTURE.md",
                "filename": "CLEAN_ARCHITECTURE.md",
                "header": "Principles",
            },
        ),
        Document(
            page_content="Docker provides container isolation and reproducible deployments.",
            metadata={
                "source": "DOCKER_GUIDE.md",
                "filename": "DOCKER_GUIDE.md",
                "header": "Introduction",
            },
        ),
        Document(
            page_content="ChromaDB uses HNSW algorithm for fast vector similarity search.",
            metadata={
                "source": "CHROMADB_DOCS.md",
                "filename": "CHROMADB_DOCS.md",
                "header": "Architecture",
            },
        ),
    ]


# ==================== TEST SUITE ====================


class TestVectorStoreServiceInitialization:
    """Group 1: Connection and Initialization Tests."""

    @patch("services.rag.vector_store.chromadb")
    def test_initialization_success(self, mock_chroma):
        """✅ Should successfully initialize when ChromaDB is reachable."""
        from services.rag.vector_store import VectorStoreService

        mock_client = MagicMock()
        mock_client.heartbeat.return_value = {"ok": True}
        mock_chroma.HttpClient.return_value = mock_client

        service = VectorStoreService(host="localhost", port=8000)

        assert service.host == "localhost"
        assert service.port == 8000
        assert service.collection_name == "softarchitect_knowledge_base"
        mock_chroma.HttpClient.assert_called_once_with(host="localhost", port=8000)

    @patch("services.rag.vector_store.chromadb")
    def test_connection_failure_raises_sys_001(self, mock_chroma):
        """❌ Should raise ConnectionError with SYS_001 if connection fails."""
        mock_chroma.HttpClient.side_effect = Exception("Connection refused")

        from services.rag.vector_store import VectorStoreService

        with pytest.raises(ConnectionError) as exc_info:
            VectorStoreService(host="localhost", port=8000)

        assert exc_info.value.code == "SYS_001"

    @patch("services.rag.vector_store.chromadb")
    def test_heartbeat_failure_raises_sys_001(self, mock_chroma):
        """❌ Should raise SYS_001 if heartbeat check fails."""
        mock_client = MagicMock()
        mock_client.heartbeat.side_effect = Exception("Timeout")
        mock_chroma.HttpClient.return_value = mock_client

        from services.rag.vector_store import VectorStoreService

        with pytest.raises(ConnectionError) as exc_info:
            VectorStoreService(host="localhost", port=8000)

        assert exc_info.value.code == "SYS_001"


class TestDocumentIngestion:
    """Group 2: Document Ingestion and Transformation Tests."""

    @patch("services.rag.vector_store.chromadb")
    def test_ingest_empty_list(self, mock_chroma):
        """✅ Should return 0 for empty document list (graceful degradation)."""
        mock_client = MagicMock()
        mock_client.heartbeat.return_value = {"ok": True}
        mock_collection = MagicMock()
        mock_client.get_or_create_collection.return_value = mock_collection
        mock_chroma.HttpClient.return_value = mock_client

        from services.rag.vector_store import VectorStoreService

        service = VectorStoreService()
        count = service.ingest([])

        assert count == 0
        mock_collection.upsert.assert_not_called()

    @patch("services.rag.vector_store.chromadb")
    def test_ingest_single_document(self, mock_chroma, sample_documents):
        """✅ Should ingest single document with correct ID and metadata."""
        mock_client = MagicMock()
        mock_client.heartbeat.return_value = {"ok": True}
        mock_collection = MagicMock()
        mock_client.get_or_create_collection.return_value = mock_collection
        mock_chroma.HttpClient.return_value = mock_client

        from services.rag.vector_store import VectorStoreService

        service = VectorStoreService()
        count = service.ingest([sample_documents[0]])

        assert count == 1
        mock_collection.upsert.assert_called_once()

        call_kwargs = mock_collection.upsert.call_args[1]
        assert len(call_kwargs["ids"]) == 1
        assert len(call_kwargs["documents"]) == 1
        assert len(call_kwargs["metadatas"]) == 1

        doc_id = call_kwargs["ids"][0]
        assert isinstance(doc_id, str)
        assert len(doc_id) == 32  # MD5 hash length

    @patch("services.rag.vector_store.chromadb")
    def test_ingest_multiple_documents(self, mock_chroma, sample_documents):
        """✅ Should ingest multiple documents in batch."""
        mock_client = MagicMock()
        mock_client.heartbeat.return_value = {"ok": True}
        mock_collection = MagicMock()
        mock_client.get_or_create_collection.return_value = mock_collection
        mock_chroma.HttpClient.return_value = mock_client

        from services.rag.vector_store import VectorStoreService

        service = VectorStoreService()
        count = service.ingest(sample_documents)

        assert count == 3
        mock_collection.upsert.assert_called_once()

        call_kwargs = mock_collection.upsert.call_args[1]
        assert len(call_kwargs["ids"]) == 3
        assert len(call_kwargs["documents"]) == 3
        assert len(call_kwargs["metadatas"]) == 3

        ids = call_kwargs["ids"]
        assert len(set(ids)) == 3

    @patch("services.rag.vector_store.chromadb")
    def test_metadata_cleaning(self, mock_chroma):
        """✅ Should clean metadata (only str/int/float/bool for Chroma)."""
        mock_client = MagicMock()
        mock_client.heartbeat.return_value = {"ok": True}
        mock_collection = MagicMock()
        mock_client.get_or_create_collection.return_value = mock_collection
        mock_chroma.HttpClient.return_value = mock_client

        from services.rag.vector_store import VectorStoreService

        service = VectorStoreService()

        doc_with_complex_meta = Document(
            page_content="Test",
            metadata={
                "valid_field": "string_value",
                "number_field": 42,
                "list_field": [1, 2, 3],
                "dict_field": {"nested": "value"},
            },
        )

        service.ingest([doc_with_complex_meta])

        call_kwargs = mock_collection.upsert.call_args[1]
        metadata = call_kwargs["metadatas"][0]

        assert "valid_field" in metadata
        assert "number_field" in metadata
        assert "list_field" not in metadata
        assert "dict_field" not in metadata

    @patch("services.rag.vector_store.chromadb")
    def test_deterministic_id_generation(self, mock_chroma, sample_documents):
        """✅ Should generate same ID for same document (idempotency)."""
        mock_client = MagicMock()
        mock_client.heartbeat.return_value = {"ok": True}
        mock_collection = MagicMock()
        mock_client.get_or_create_collection.return_value = mock_collection
        mock_chroma.HttpClient.return_value = mock_client

        from services.rag.vector_store import VectorStoreService

        doc1 = sample_documents[0]
        doc2 = Document(
            page_content=doc1.page_content, metadata={"source": doc1.metadata["source"]}
        )

        service = VectorStoreService()
        service.ingest([doc1])

        call_args_1 = mock_collection.upsert.call_args[1]
        id1 = call_args_1["ids"][0]

        mock_collection.reset_mock()
        service.ingest([doc2])

        call_args_2 = mock_collection.upsert.call_args[1]
        id2 = call_args_2["ids"][0]

        assert id1 == id2


class TestIdempotency:
    """Group 3: Idempotency Tests (Critical for RAG)."""

    @patch("services.rag.vector_store.chromadb")
    def test_upsert_twice_no_duplicates(self, mock_chroma, sample_documents):
        """✅ Should not duplicate documents when run twice."""
        mock_client = MagicMock()
        mock_client.heartbeat.return_value = {"ok": True}
        mock_collection = MagicMock()
        mock_client.get_or_create_collection.return_value = mock_collection
        mock_chroma.HttpClient.return_value = mock_client

        from services.rag.vector_store import VectorStoreService

        service = VectorStoreService()

        service.ingest(sample_documents)
        service.ingest(sample_documents)

        assert mock_collection.upsert.call_count == 2

        call1_ids = mock_collection.upsert.call_args_list[0][1]["ids"]
        call2_ids = mock_collection.upsert.call_args_list[1][1]["ids"]
        assert call1_ids == call2_ids


class TestErrorHandling:
    """Group 4: Error Handling and Resilience."""

    @patch("services.rag.vector_store.chromadb")
    def test_ingestion_database_error(self, mock_chroma):
        """❌ Should raise VectorStoreError if upsert fails."""
        mock_client = MagicMock()
        mock_client.heartbeat.return_value = {"ok": True}
        mock_collection = MagicMock()
        mock_collection.upsert.side_effect = Exception("Database write failed")
        mock_client.get_or_create_collection.return_value = mock_collection
        mock_chroma.HttpClient.return_value = mock_client

        from services.rag.vector_store import VectorStoreService

        service = VectorStoreService()
        doc = Document(page_content="Test", metadata={"source": "test.md"})

        with pytest.raises(DatabaseWriteError):
            service.ingest([doc])

    def test_error_to_dict(self):
        """✅ Should convert error to API response format."""
        error = ConnectionError(
            host="localhost", port=8000, reason="Connection refused"
        )

        error_dict = error.to_dict()
        assert error_dict["error_code"] == "SYS_001"
        assert "Failed to connect" in error_dict["error_message"]
        assert error_dict["details"]["host"] == "localhost"
        assert error_dict["details"]["port"] == 8000


class TestQueryFunctionality:
    """Group 5: Query and Retrieval Tests."""

    @patch("services.rag.vector_store.chromadb")
    def test_query_basic(self, mock_chroma):
        """✅ Should query collection and return results."""
        mock_client = MagicMock()
        mock_client.heartbeat.return_value = {"ok": True}
        mock_collection = MagicMock()

        mock_collection.query.return_value = {
            "documents": [["Test document"]],
            "metadatas": [[{"source": "test.md"}]],
            "distances": [[0.1]],
            "ids": [["doc_id_1"]],
        }

        mock_client.get_or_create_collection.return_value = mock_collection
        mock_chroma.HttpClient.return_value = mock_client

        from services.rag.vector_store import VectorStoreService

        service = VectorStoreService()
        results = service.query("test query", n_results=5)

        assert "documents" in results
        assert len(results["documents"][0]) > 0

    @patch("services.rag.vector_store.chromadb")
    def test_query_returns_metadatas(self, mock_chroma):
        """✅ Should include metadata in query results."""
        mock_client = MagicMock()
        mock_client.heartbeat.return_value = {"ok": True}
        mock_collection = MagicMock()

        mock_collection.query.return_value = {
            "documents": [["Document with metadata"]],
            "metadatas": [[{"source": "source.md", "header": "Title"}]],
            "distances": [[0.05]],
            "ids": [["id_1"]],
        }

        mock_client.get_or_create_collection.return_value = mock_collection
        mock_chroma.HttpClient.return_value = mock_client

        from services.rag.vector_store import VectorStoreService

        service = VectorStoreService()
        results = service.query("search term")

        assert "metadatas" in results
        assert results["metadatas"][0][0]["source"] == "source.md"


class TestHealthCheck:
    """Group 6: Health Check Tests."""

    @patch("services.rag.vector_store.chromadb")
    def test_health_check_success(self, mock_chroma):
        """✅ Should return True when ChromaDB is healthy."""
        mock_client = MagicMock()
        mock_client.heartbeat.return_value = {"ok": True}
        mock_chroma.HttpClient.return_value = mock_client

        from services.rag.vector_store import VectorStoreService

        service = VectorStoreService()
        health = service.health_check()

        assert health is True

    @patch("services.rag.vector_store.chromadb")
    def test_health_check_failure(self, mock_chroma):
        """❌ Should raise error when ChromaDB is unhealthy."""
        mock_client = MagicMock()
        # First heartbeat (during init) succeeds, second (in health_check) fails
        mock_client.heartbeat.side_effect = [
            {"ok": True},  # Init success
            Exception("Heartbeat failed"),  # health_check failure
        ]
        mock_chroma.HttpClient.return_value = mock_client

        from services.rag.vector_store import VectorStoreService

        service = VectorStoreService()

        with pytest.raises(ConnectionError):
            service.health_check()
