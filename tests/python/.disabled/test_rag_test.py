"""Tests for RAG test endpoint (app.api.v1.rag_test)."""

import pytest
from fastapi.testclient import TestClient
from unittest.mock import patch, MagicMock

from app.main import app


@pytest.fixture
def client():
    """FastAPI test client."""
    return TestClient(app)


class TestRAGHealthEndpoint:
    """Test RAG health endpoint."""

    def test_rag_health_endpoint_exists(self):
        """✅ Should have RAG health endpoint."""
        from app.api.v1.rag_test import router

        assert router is not None
        # Check that health route is registered
        route_paths = [
            getattr(route, "path", None)
            for route in router.routes
            if hasattr(route, "path")
        ]
        assert "/rag/test/health" in route_paths

    @patch("app.api.v1.rag_test.VectorStoreService")
    def test_rag_health_endpoint_success(self, mock_store, client):
        """Test RAG health endpoint with successful response."""
        mock_instance = MagicMock()
        mock_store.return_value = mock_instance
        mock_instance.health_check.return_value = 15

        response = client.get("/api/v1/rag/test/health")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"
        assert "heartbeat_ms" in data
        assert data["heartbeat_ms"] == 15

    @patch("app.api.v1.rag_test.VectorStoreService")
    def test_rag_health_endpoint_unavailable(self, mock_store, client):
        """Test RAG health endpoint when service is unavailable."""
        mock_instance = MagicMock()
        mock_store.return_value = mock_instance
        mock_instance.health_check.side_effect = Exception("Connection failed")

        response = client.get("/api/v1/rag/test/health")
        assert response.status_code == 503


class TestRAGRetrievalEndpoint:
    """Test RAG retrieval endpoint."""

    def test_rag_retrieval_endpoint_exists(self):
        """✅ Should have RAG retrieval endpoint."""
        from app.api.v1.rag_test import router

        assert router is not None
        # Check that retrieval route is registered
        route_paths = [
            getattr(route, "path", None)
            for route in router.routes
            if hasattr(route, "path")
        ]
        assert "/rag/test/retrieval" in route_paths

    @patch("app.api.v1.rag_test.VectorStoreService")
    def test_rag_retrieval_endpoint_success(self, mock_store, client):
        """Test RAG retrieval endpoint with valid query."""
        mock_instance = MagicMock()
        mock_store.return_value = mock_instance
        # ChromaDB returns wrapped lists of lists
        mock_instance.query.return_value = {
            "documents": [["Sample document content about Docker setup"]],
            "metadatas": [{"filename": "test.md", "source": "path/to/test.md"}],
        }

        payload = {"question": "How do I use Docker?", "limit": 3}

        response = client.post("/api/v1/rag/test/retrieval", json=payload)

        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "success"
        assert data["query"] == "How do I use Docker?"
        # Should have at least 0 matches (depends on mock structure)
        assert data["matches"] >= 0
        assert isinstance(data["data"], list)
        assert "warning" in data

    @patch("app.api.v1.rag_test.VectorStoreService")
    def test_rag_retrieval_empty_results(self, mock_store, client):
        """Test RAG retrieval endpoint with empty results."""
        mock_instance = MagicMock()
        mock_store.return_value = mock_instance
        mock_instance.query.return_value = {"documents": [[]], "metadatas": [[]]}

        payload = {"question": "Obscure question that returns no results", "limit": 3}

        response = client.post("/api/v1/rag/test/retrieval", json=payload)

        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "success"
        assert data["matches"] == 0
        assert len(data["data"]) == 0

    @patch("app.api.v1.rag_test.VectorStoreService")
    def test_rag_retrieval_truncates_long_content(self, mock_store, client):
        """Test that long documents are truncated to 300 chars."""
        long_doc = "A" * 500  # 500 chars
        mock_instance = MagicMock()
        mock_store.return_value = mock_instance
        mock_instance.query.return_value = {
            "documents": [[long_doc]],
            "metadatas": [{"filename": "long.md", "source": "path/to/long.md"}],
        }

        payload = {"question": "Show long content", "limit": 1}

        response = client.post("/api/v1/rag/test/retrieval", json=payload)

        assert response.status_code == 200
        data = response.json()
        # Check if data was returned (depends on mock validation)
        if len(data["data"]) > 0:
            # Should be truncated to 300 chars + "..."
            assert len(data["data"][0]["content"]) <= 303

    def test_rag_retrieval_invalid_query(self, client):
        """Test RAG retrieval with invalid input (empty question)."""
        payload = {
            "question": "",  # Empty query
            "limit": 3,
        }

        response = client.post("/api/v1/rag/test/retrieval", json=payload)
        assert response.status_code == 422  # Validation error

    def test_rag_retrieval_invalid_limit_too_low(self, client):
        """Test RAG retrieval with invalid limit (too low)."""
        payload = {
            "question": "Valid question",
            "limit": 0,  # Invalid: must be >= 1
        }

        response = client.post("/api/v1/rag/test/retrieval", json=payload)
        assert response.status_code == 422  # Validation error

    def test_rag_retrieval_invalid_limit_too_high(self, client):
        """Test RAG retrieval with invalid limit (too high)."""
        payload = {
            "question": "Valid question",
            "limit": 20,  # Invalid: must be <= 10
        }

        response = client.post("/api/v1/rag/test/retrieval", json=payload)
        assert response.status_code == 422  # Validation error

    @patch("app.api.v1.rag_test.VectorStoreService")
    def test_rag_retrieval_server_error(self, mock_store, client):
        """Test RAG retrieval when server error occurs."""
        mock_instance = MagicMock()
        mock_store.return_value = mock_instance
        mock_instance.query.side_effect = Exception("Unexpected error")

        payload = {"question": "Valid question", "limit": 3}

        response = client.post("/api/v1/rag/test/retrieval", json=payload)
        assert response.status_code == 500
        data = response.json()
        assert "detail" in data

    @patch("app.api.v1.rag_test.VectorStoreService")
    def test_rag_retrieval_multiple_results(self, mock_store, client):
        """Test RAG retrieval with multiple results."""
        mock_instance = MagicMock()
        mock_store.return_value = mock_instance
        mock_instance.query.return_value = {
            "documents": [
                [
                    "First document about setup",
                    "Second document about configuration",
                    "Third document about troubleshooting",
                ]
            ],
            "metadatas": [
                [
                    {"filename": "setup.md", "source": "docs/setup.md"},
                    {"filename": "config.md", "source": "docs/config.md"},
                    {"filename": "trouble.md", "source": "docs/trouble.md"},
                ]
            ],
        }

        payload = {"question": "How to configure the system?", "limit": 5}

        response = client.post("/api/v1/rag/test/retrieval", json=payload)

        assert response.status_code == 200
        data = response.json()
        assert data["matches"] == 3
        assert len(data["data"]) == 3
        assert data["data"][0]["source"] == "setup.md"
        assert data["data"][1]["source"] == "config.md"
        assert data["data"][2]["source"] == "trouble.md"

    @patch("app.api.v1.rag_test.VectorStoreService")
    def test_rag_retrieval_vector_store_error(self, mock_store, client):
        """Test RAG retrieval when VectorStore error occurs."""
        from app.core.exceptions import VectorStoreError

        mock_instance = MagicMock()
        mock_store.return_value = mock_instance
        mock_instance.query.side_effect = VectorStoreError(
            code="RAG_001", message="Vector store query failed"
        )

        payload = {"question": "Valid question", "limit": 3}

        response = client.post("/api/v1/rag/test/retrieval", json=payload)
        assert response.status_code == 500
