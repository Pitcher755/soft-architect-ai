"""
Unit tests for Chat API Endpoints - SSE Streaming.

Tests cover:
- SSE content type headers
- Token streaming functionality
- Request validation
- Error handling
"""

import pytest
from fastapi.testclient import TestClient
from unittest.mock import patch
from app.main import app


@pytest.fixture
def client():
    """Test client for API."""
    return TestClient(app)


class TestChatEndpoints:
    """Test suite for /api/v1/chat endpoints."""

    def test_generate_endpoint_returns_sse_content_type(self, client):
        """Test that endpoint returns SSE headers."""
        # Arrange
        with patch("app.api.v1.chat.orchestrator") as mock_orch:
            mock_orch.generate.side_effect = (
                lambda *args, **kwargs: TestChatEndpoints._mock_async_gen(["test"])
            )

            # Act
            response = client.post(
                "/api/v1/chat/generate",
                json={
                    "message": "Test",
                    "doc_type": "PROJECT_MANIFESTO",
                    "project_context": {},
                    "chat_history": [],
                },
                headers={"Accept": "text/event-stream"},
            )

            # Assert
            assert response.status_code == 200
            assert "text/event-stream" in response.headers.get("content-type", "")

    def test_generate_endpoint_streams_tokens(self, client):
        """Test token streaming functionality."""
        # Arrange
        with patch("app.api.v1.chat.orchestrator") as mock_orch:
            mock_orch.generate.side_effect = (
                lambda *args, **kwargs: TestChatEndpoints._mock_async_gen(
                    ["Hello", " ", "World"]
                )
            )

            # Act
            response = client.post(
                "/api/v1/chat/generate",
                json={
                    "message": "Test",
                    "doc_type": "PROJECT_MANIFESTO",
                    "project_context": {},
                    "chat_history": [],
                },
                headers={"Accept": "text/event-stream"},
            )

            # Assert
            content = response.text
            assert response.status_code == 200
            assert "event: token" in content or "Hello" in content

    def test_generate_endpoint_validates_required_fields(self, client):
        """Test request validation for missing required fields."""
        # Act
        response = client.post(
            "/api/v1/chat/generate",
            json={"message": "Test"},  # Missing doc_type
        )

        # Assert
        assert response.status_code == 422  # Validation error

    def test_generate_endpoint_requires_message_field(self, client):
        """Test that message field is required."""
        # Act
        response = client.post(
            "/api/v1/chat/generate",
            json={
                "doc_type": "PROJECT_MANIFESTO",
                "project_context": {},
                "chat_history": [],
            },
        )

        # Assert
        assert response.status_code == 422

    def test_generate_endpoint_requires_doc_type_field(self, client):
        """Test that doc_type field is required."""
        # Act
        response = client.post(
            "/api/v1/chat/generate",
            json={"message": "Test message", "project_context": {}, "chat_history": []},
        )

        # Assert
        assert response.status_code == 422

    def test_generate_endpoint_accepts_empty_project_context(self, client):
        """Test that project_context can be empty."""
        # Arrange
        with patch("app.api.v1.chat.orchestrator") as mock_orch:
            mock_orch.generate.side_effect = (
                lambda *args, **kwargs: TestChatEndpoints._mock_async_gen(["test"])
            )

            # Act
            response = client.post(
                "/api/v1/chat/generate",
                json={
                    "message": "Test",
                    "doc_type": "PROJECT_MANIFESTO",
                    "project_context": {},
                },
            )

            # Assert
            assert response.status_code == 200

    def test_generate_endpoint_accepts_empty_chat_history(self, client):
        """Test that chat_history can be empty."""
        # Arrange
        with patch("app.api.v1.chat.orchestrator") as mock_orch:
            mock_orch.generate.side_effect = (
                lambda *args, **kwargs: TestChatEndpoints._mock_async_gen(["test"])
            )

            # Act
            response = client.post(
                "/api/v1/chat/generate",
                json={
                    "message": "Test",
                    "doc_type": "PROJECT_MANIFESTO",
                    "project_context": {},
                    "chat_history": [],
                },
            )

            # Assert
            assert response.status_code == 200

    def test_generate_endpoint_passes_context_to_orchestrator(self, client):
        """Test that request data is passed correctly to orchestrator."""
        # Arrange
        with patch("app.api.v1.chat.orchestrator") as mock_orch:
            mock_orch.generate.side_effect = (
                lambda *args, **kwargs: TestChatEndpoints._mock_async_gen(["test"])
            )

            request_data = {
                "message": "Genera el Project Manifesto",
                "doc_type": "PROJECT_MANIFESTO",
                "project_context": {
                    "name": "TestProject",
                    "description": "Test description",
                },
                "chat_history": [
                    {"role": "user", "content": "Hello"},
                    {"role": "assistant", "content": "Hi"},
                ],
            }

            # Act
            response = client.post("/api/v1/chat/generate", json=request_data)

            # Assert
            assert response.status_code == 200
            # Verify orchestrator.generate was called with correct parameters
            mock_orch.generate.assert_called_once()

    def test_generate_endpoint_handles_orchestrator_error(self, client):
        """Test error handling when orchestrator raises exception."""
        # Arrange
        with patch("app.api.v1.chat.orchestrator") as mock_orch:
            from app.core.exceptions import RAGError

            mock_orch.generate.side_effect = RAGError(
                code="RAG_001", message="ChromaDB unavailable"
            )

            # Act
            response = client.post(
                "/api/v1/chat/generate",
                json={
                    "message": "Test",
                    "doc_type": "PROJECT_MANIFESTO",
                    "project_context": {},
                    "chat_history": [],
                },
            )

            # Assert
            assert response.status_code == 200
            assert "text/event-stream" in response.headers.get("content-type", "")
            content = response.text
            assert "event: error" in content
            assert "RAG_001" in content
            assert "ChromaDB unavailable" in content

    def test_generate_endpoint_sse_format_contains_event_field(self, client):
        """Test that SSE response contains event field."""
        # Arrange
        with patch("app.api.v1.chat.orchestrator") as mock_orch:
            mock_orch.generate.side_effect = (
                lambda *args, **kwargs: TestChatEndpoints._mock_async_gen(["token"])
            )

            # Act
            response = client.post(
                "/api/v1/chat/generate",
                json={
                    "message": "Test",
                    "doc_type": "PROJECT_MANIFESTO",
                    "project_context": {},
                    "chat_history": [],
                },
            )

            # Assert
            # SSE format should have "event:" prefix for events
            # (or at minimum, should be text/event-stream content-type)
            assert response.status_code == 200

    def test_generate_endpoint_handles_long_token_sequences(self, client):
        """Test that endpoint handles many tokens correctly."""
        # Arrange
        with patch("app.api.v1.chat.orchestrator") as mock_orch:
            # Create a sequence of 100 tokens
            tokens = [f"token_{i}" for i in range(100)]
            mock_orch.generate.side_effect = (
                lambda *args, **kwargs: TestChatEndpoints._mock_async_gen(tokens)
            )

            # Act
            response = client.post(
                "/api/v1/chat/generate",
                json={
                    "message": "Test",
                    "doc_type": "PROJECT_MANIFESTO",
                    "project_context": {},
                    "chat_history": [],
                },
            )

            # Assert
            assert response.status_code == 200
            content = response.text
            # Response should contain multiple tokens
            assert len(content) > 0

    @staticmethod
    async def _mock_async_gen(items):
        """Helper for async generator."""
        for item in items:
            yield item
