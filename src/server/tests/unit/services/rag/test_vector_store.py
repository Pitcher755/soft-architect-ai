"""
Unit Tests for VectorStoreService (HU-2.2)

TDD Approach: Tests escritos ANTES de la implementación.
Usamos Mocking para evitar dependencia de Docker en CI.

Cobertura:
- ✅ Connection failure (SYS_001)
- ✅ Document ingestion with metadata
- ✅ ID generation (deterministic hashing)
- ✅ Upsert idempotency
- ✅ Metadata cleaning (Chroma constraints)
"""

from unittest.mock import MagicMock, patch

import pytest
from langchain_core.documents import Document

from core.exceptions.base import VectorStoreError
from services.rag.vector_store import VectorStoreService

# ==================== FIXTURES ====================


@pytest.fixture
def sample_documents():
    """Sample documents output from HU-2.1 MarkdownLoader"""
    return [
        Document(
            page_content="Clean Architecture ensures that business rules are not coupled to UI frameworks.",
            metadata={
                "source": "packages/knowledge_base/01-ARCHITECTURE/CLEAN_ARCH.md",
                "filename": "CLEAN_ARCH.md",
                "header": "Intro",
            },
        ),
        Document(
            page_content="Docker provides container isolation and reproducible deployments.",
            metadata={
                "source": "packages/knowledge_base/02-DEVOPS/DOCKER.md",
                "filename": "DOCKER.md",
                "header": None,  # Some docs may not have headers
            },
        ),
        Document(
            page_content="ChromaDB uses HNSW algorithm for fast vector similarity search.",
            metadata={
                "source": "packages/knowledge_base/03-TECH-STACK/CHROMA.md",
                "filename": "CHROMA.md",
                "header": "How It Works",
            },
        ),
    ]


@pytest.fixture
def mock_chroma_client():
    """Mock ChromaDB HTTP client"""
    with patch("chromadb.HttpClient") as mock:
        mock_collection = MagicMock()
        mock.return_value.get_or_create_collection.return_value = mock_collection
        yield mock


# ==================== TEST SUITE ====================


class TestVectorStoreServiceInitialization:
    """Group 1: Connection and Initialization Tests"""

    def test_initialization_success(self, mock_chroma_client):
        """✅ Should successfully initialize when ChromaDB is reachable"""
        # Arrange: Mock successful heartbeat
        mock_chroma_client.return_value.heartbeat.return_value = {"ok": True}

        # Act
        service = VectorStoreService(host="localhost", port=8000)

        # Assert
        assert service.host == "localhost"
        assert service.port == 8000
        assert service.collection_name == "softarchitect_knowledge_base"
        mock_chroma_client.assert_called_once_with(host="localhost", port=8000)

    def test_connection_failure_raises_sys_001(self):
        """❌ Should raise VectorStoreError with SYS_001 if connection fails"""
        with patch("chromadb.HttpClient") as mock_client:
            # Simulate connection refused
            mock_client.side_effect = Exception("Connection refused: Errno 111")

            # Act & Assert
            with pytest.raises(VectorStoreError) as exc_info:
                VectorStoreService(host="unreachable_host", port=9999)

            assert exc_info.value.code == "SYS_001"
            assert (
                "Connection" in exc_info.value.message
                or "connect" in exc_info.value.message.lower()
            )

    def test_heartbeat_failure_raises_sys_001(self):
        """❌ Should raise SYS_001 if heartbeat check fails"""
        with patch("chromadb.HttpClient") as mock_client:
            mock_client.return_value.heartbeat.side_effect = Exception("Timeout")

            with pytest.raises(VectorStoreError) as exc_info:
                VectorStoreService()

            assert exc_info.value.code == "SYS_001"


class TestDocumentIngestion:
    """Group 2: Document Ingestion and Transformation Tests"""

    def test_ingest_empty_list(self, mock_chroma_client):
        """✅ Should return 0 for empty document list (graceful degradation)"""
        service = VectorStoreService()
        count = service.ingest([])

        assert count == 0
        mock_chroma_client.return_value.get_or_create_collection.return_value.upsert.assert_not_called()

    def test_ingest_single_document(self, mock_chroma_client, sample_documents):
        """✅ Should ingest single document with correct ID and metadata"""
        service = VectorStoreService()
        mock_collection = (
            mock_chroma_client.return_value.get_or_create_collection.return_value
        )

        # Act
        count = service.ingest([sample_documents[0]])

        # Assert
        assert count == 1
        mock_collection.upsert.assert_called_once()

        # Inspect the call arguments
        call_kwargs = mock_collection.upsert.call_args[1]
        assert len(call_kwargs["ids"]) == 1
        assert len(call_kwargs["documents"]) == 1
        assert len(call_kwargs["metadatas"]) == 1

        # Verify ID is deterministic (hash-based)
        doc_id = call_kwargs["ids"][0]
        assert isinstance(doc_id, str)
        assert len(doc_id) == 32  # MD5 hash length

    def test_ingest_multiple_documents(self, mock_chroma_client, sample_documents):
        """✅ Should ingest multiple documents in batch"""
        service = VectorStoreService()
        mock_collection = (
            mock_chroma_client.return_value.get_or_create_collection.return_value
        )

        # Act
        count = service.ingest(sample_documents)

        # Assert
        assert count == 3
        mock_collection.upsert.assert_called_once()

        call_kwargs = mock_collection.upsert.call_args[1]
        assert len(call_kwargs["ids"]) == 3
        assert len(call_kwargs["documents"]) == 3
        assert len(call_kwargs["metadatas"]) == 3

        # All IDs should be unique
        ids = call_kwargs["ids"]
        assert len(set(ids)) == 3

    def test_metadata_cleaning(self, mock_chroma_client, sample_documents):
        """✅ Should clean metadata (only str/int/float/bool for Chroma)"""
        service = VectorStoreService()
        mock_collection = (
            mock_chroma_client.return_value.get_or_create_collection.return_value
        )

        # Create document with complex metadata (should be cleaned)
        doc_with_complex_meta = Document(
            page_content="Test",
            metadata={
                "source": "test.md",
                "filename": "test.md",
                "list_field": ["a", "b"],  # Not allowed in Chroma
                "dict_field": {"nested": "data"},  # Not allowed
                "valid_field": "string_value",  # Allowed
                "number_field": 42,  # Allowed
            },
        )

        # Act
        service.ingest([doc_with_complex_meta])

        # Assert
        call_kwargs = mock_collection.upsert.call_args[1]
        metadata = call_kwargs["metadatas"][0]

        assert "valid_field" in metadata
        assert "number_field" in metadata
        assert "list_field" not in metadata
        assert "dict_field" not in metadata

    def test_deterministic_id_generation(self, sample_documents):
        """✅ Should generate same ID for same document (idempotency)"""
        # Create two identical documents
        doc1 = sample_documents[0]
        doc2 = Document(
            page_content=doc1.page_content,  # Exact same content
            metadata={"source": doc1.metadata["source"]},  # Exact same source
        )

        with patch("chromadb.HttpClient"):
            service = VectorStoreService()

            # Generate IDs twice
            id1 = service._generate_id(doc1.page_content, doc1.metadata["source"])
            id2 = service._generate_id(doc2.page_content, doc2.metadata["source"])

            # Assert
            assert id1 == id2  # Deterministic


class TestIdempotency:
    """Group 3: Idempotency Tests (Critical for RAG)"""

    def test_upsert_twice_no_duplicates(self, mock_chroma_client, sample_documents):
        """✅ Should not duplicate documents when run twice"""
        service = VectorStoreService()
        mock_collection = (
            mock_chroma_client.return_value.get_or_create_collection.return_value
        )

        # Act: Ingest same documents twice
        service.ingest(sample_documents)
        service.ingest(sample_documents)

        # Assert: upsert called twice
        assert mock_collection.upsert.call_count == 2

        # Both calls should have same IDs (deterministic)
        call1_ids = mock_collection.upsert.call_args_list[0][1]["ids"]
        call2_ids = mock_collection.upsert.call_args_list[1][1]["ids"]
        assert call1_ids == call2_ids


class TestErrorHandling:
    """Group 4: Error Handling and Resilience"""

    def test_ingestion_database_error(self, mock_chroma_client):
        """❌ Should raise VectorStoreError if upsert fails"""
        service = VectorStoreService()
        mock_collection = (
            mock_chroma_client.return_value.get_or_create_collection.return_value
        )
        mock_collection.upsert.side_effect = Exception("Database write failed")

        doc = Document(page_content="Test", metadata={"source": "test.md"})

        with pytest.raises(VectorStoreError) as exc_info:
            service.ingest([doc])

        assert exc_info.value.code == "DB_WRITE_ERR"

    def test_error_to_dict(self):
        """✅ Should convert error to API response format"""
        error = VectorStoreError(
            code="SYS_001",
            message="Connection failed",
            details={"host": "localhost", "port": 8000},
        )

        error_dict = error.to_dict()
        assert error_dict["error_code"] == "SYS_001"
        assert error_dict["error_message"] == "Connection failed"
        assert error_dict["details"]["host"] == "localhost"
