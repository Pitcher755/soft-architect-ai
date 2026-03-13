"""
Unit tests for RAG test endpoint (temporary debugging endpoint).

Coverage target: >80% (current: 42%)
"""

import pytest
from fastapi import HTTPException, status
from unittest.mock import MagicMock, patch

from app.api.v1.rag_test import (
    QueryRequest,
    QueryResponse,
    RetrievalResult,
    rag_retrieval_endpoint,
    rag_health,
)
from app.core.exceptions import VectorStoreError


class TestQueryRequest:
    """Test suite for QueryRequest model validation."""

    def test_valid_query_request(self):
        """Test creating a valid QueryRequest."""
        request = QueryRequest(question="What is Docker?", limit=5)
        assert request.question == "What is Docker?"
        assert request.limit == 5

    def test_default_limit(self):
        """Test QueryRequest with default limit."""
        request = QueryRequest(question="Test query")
        assert request.limit == 3

    def test_empty_question_fails(self):
        """Test that empty question raises ValidationError."""
        with pytest.raises(ValueError):
            QueryRequest(question="", limit=3)

    def test_limit_boundary_conditions(self):
        """Test limit validation boundaries."""
        # Valid limits
        QueryRequest(question="test", limit=1)
        QueryRequest(question="test", limit=10)

        # Invalid limits
        with pytest.raises(ValueError):
            QueryRequest(question="test", limit=0)

        with pytest.raises(ValueError):
            QueryRequest(question="test", limit=11)


class TestRetrievalResult:
    """Test suite for RetrievalResult model."""

    def test_valid_retrieval_result(self):
        """Test creating a valid RetrievalResult."""
        result = RetrievalResult(
            content="Sample content",
            source="README.md",
            path="/path/to/README.md",
        )
        assert result.content == "Sample content"
        assert result.source == "README.md"
        assert result.path == "/path/to/README.md"


class TestQueryResponse:
    """Test suite for QueryResponse model."""

    def test_valid_query_response(self):
        """Test creating a valid QueryResponse."""
        response = QueryResponse(
            status="success",
            query="What is Docker?",
            matches=2,
            data=[
                RetrievalResult(
                    content="Docker is...", source="docker.md", path="/docs/docker.md"
                )
            ],
            warning=None,
        )
        assert response.status == "success"
        assert response.matches == 2
        assert len(response.data) == 1


@pytest.mark.asyncio
class TestRagRetrieval:
    """Test suite for test_rag_retrieval endpoint."""

    @patch("app.api.v1.rag_test.VectorStoreService")
    async def test_successful_retrieval(self, mock_store_class):
        """Test successful RAG retrieval with valid results."""
        # Mock VectorStoreService
        mock_store = MagicMock()
        mock_store_class.return_value = mock_store

        # Mock query results
        mock_store.query.return_value = {
            "documents": [
                [
                    "Docker is a platform for containerization...",
                    "Docker Compose orchestrates multiple containers...",
                ]
            ],
            "metadatas": [
                [
                    {"filename": "docker.md", "source": "/docs/docker.md"},
                    {"filename": "compose.md", "source": "/docs/compose.md"},
                ]
            ],
        }

        # Test request
        request = QueryRequest(question="What is Docker?", limit=3)
        response = await rag_retrieval_endpoint(request)

        # Assertions
        assert response.status == "success"
        assert response.query == "What is Docker?"
        assert response.matches == 2
        assert len(response.data) == 2
        assert response.data[0].source == "docker.md"
        assert response.warning is not None

        # Verify VectorStoreService called correctly
        mock_store_class.assert_called_once_with(host="chromadb", port=8000)
        mock_store.query.assert_called_once_with("What is Docker?", n_results=3)

    @patch("app.api.v1.rag_test.VectorStoreService")
    async def test_retrieval_no_results(self, mock_store_class):
        """Test RAG retrieval with no matching documents."""
        mock_store = MagicMock()
        mock_store_class.return_value = mock_store

        # Empty results
        mock_store.query.return_value = {"documents": [[]], "metadatas": [[]]}

        request = QueryRequest(question="nonexistent topic", limit=3)
        response = await rag_retrieval_endpoint(request)

        assert response.status == "success"
        assert response.matches == 0
        assert len(response.data) == 0

    @patch("app.api.v1.rag_test.VectorStoreService")
    async def test_retrieval_with_none_metadata(self, mock_store_class):
        """Test RAG retrieval handles None metadata gracefully."""
        mock_store = MagicMock()
        mock_store_class.return_value = mock_store

        # Results with None metadata values
        mock_store.query.return_value = {
            "documents": [["Content without metadata"]],
            "metadatas": [[{"filename": None, "source": None}]],
        }

        request = QueryRequest(question="test", limit=3)
        response = await rag_retrieval_endpoint(request)

        assert response.status == "success"
        assert response.matches == 1
        assert response.data[0].source == "unknown"
        assert response.data[0].path == "unknown"

    @patch("app.api.v1.rag_test.VectorStoreService")
    async def test_retrieval_content_truncation(self, mock_store_class):
        """Test that long content is truncated to 300 chars."""
        mock_store = MagicMock()
        mock_store_class.return_value = mock_store

        # Create content longer than 300 chars
        long_content = "A" * 400

        mock_store.query.return_value = {
            "documents": [[long_content]],
            "metadatas": [[{"filename": "test.md", "source": "/test.md"}]],
        }

        request = QueryRequest(question="test", limit=1)
        response = await rag_retrieval_endpoint(request)

        assert response.matches == 1
        retrieved_content = response.data[0].content
        assert len(retrieved_content) == 303  # 300 chars + "..."
        assert retrieved_content.endswith("...")

    @patch("app.api.v1.rag_test.VectorStoreService")
    async def test_retrieval_with_invalid_metadata_type(self, mock_store_class):
        """Test RAG retrieval handles non-dict metadata gracefully."""
        mock_store = MagicMock()
        mock_store_class.return_value = mock_store

        # Invalid metadata (not a dict)
        mock_store.query.return_value = {
            "documents": [["Test content"]],
            "metadatas": [["not a dict"]],  # Invalid type
        }

        request = QueryRequest(question="test", limit=1)
        response = await rag_retrieval_endpoint(request)

        assert response.matches == 1
        assert response.data[0].source == "unknown"
        assert response.data[0].path == "unknown"

    @patch("app.api.v1.rag_test.VectorStoreService")
    async def test_retrieval_vector_store_error(self, mock_store_class):
        """Test RAG retrieval handles VectorStoreError."""
        mock_store = MagicMock()
        mock_store_class.return_value = mock_store

        # Simulate VectorStoreError
        mock_store.query.side_effect = VectorStoreError("Connection failed")

        request = QueryRequest(question="test", limit=3)

        with pytest.raises(HTTPException) as exc_info:
            await rag_retrieval_endpoint(request)

        assert exc_info.value.status_code == status.HTTP_500_INTERNAL_SERVER_ERROR
        assert "RAG query failed" in exc_info.value.detail

    @patch("app.api.v1.rag_test.VectorStoreService")
    async def test_retrieval_unexpected_error(self, mock_store_class):
        """Test RAG retrieval handles unexpected exceptions."""
        mock_store = MagicMock()
        mock_store_class.return_value = mock_store

        # Simulate unexpected error
        mock_store.query.side_effect = RuntimeError("Unexpected failure")

        request = QueryRequest(question="test", limit=3)

        with pytest.raises(HTTPException) as exc_info:
            await rag_retrieval_endpoint(request)

        assert exc_info.value.status_code == status.HTTP_500_INTERNAL_SERVER_ERROR
        assert "unexpected error" in exc_info.value.detail.lower()


@pytest.mark.asyncio
class TestRagHealth:
    """Test suite for rag_health endpoint."""

    @patch("app.api.v1.rag_test.VectorStoreService")
    async def test_health_check_success(self, mock_store_class):
        """Test successful RAG health check."""
        mock_store = MagicMock()
        mock_store_class.return_value = mock_store

        # Mock heartbeat response (milliseconds)
        mock_store.health_check.return_value = 42

        response = await rag_health()

        assert response["status"] == "healthy"
        assert response["heartbeat_ms"] == 42
        assert "operational" in response["message"].lower()

        mock_store_class.assert_called_once_with(host="chromadb", port=8000)
        mock_store.health_check.assert_called_once()

    @patch("app.api.v1.rag_test.VectorStoreService")
    async def test_health_check_failure(self, mock_store_class):
        """Test RAG health check when service is unavailable."""
        mock_store = MagicMock()
        mock_store_class.return_value = mock_store

        # Simulate health check failure
        mock_store.health_check.side_effect = ConnectionError("ChromaDB unreachable")

        with pytest.raises(HTTPException) as exc_info:
            await rag_health()

        assert exc_info.value.status_code == status.HTTP_503_SERVICE_UNAVAILABLE
        assert "not available" in exc_info.value.detail.lower()
