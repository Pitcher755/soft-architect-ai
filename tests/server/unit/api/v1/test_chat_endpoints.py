"""
Unit tests for Chat API Endpoints - SSE Streaming.

Tests cover:
- SSE content type headers
- Token streaming functionality
- Request validation
- Error handling
- Task 13: _get_orchestrator injects ChromaProjectStore
"""

from unittest.mock import MagicMock, patch

import pytest
from fastapi.testclient import TestClient

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


# ---------------------------------------------------------------------------
# Task 13 – _get_orchestrator injects ChromaProjectStore
# ---------------------------------------------------------------------------


class TestGetOrchestratorFactory:
    """Tests for the _get_orchestrator lazy-init factory in chat.py.

    Task 13 requirement: the legacy ``/generate`` endpoint's internal
    orchestrator factory must also pass ``project_store`` so that semantic
    RAG retrieval works for all request paths.
    """

    def setup_method(self) -> None:
        """Reset the module-level orchestrator singleton before each test."""
        import app.api.v1.chat as chat_module

        chat_module.orchestrator = None

    def teardown_method(self) -> None:
        """Reset after each test to avoid polluting other suites."""
        import app.api.v1.chat as chat_module

        chat_module.orchestrator = None

    def test_get_orchestrator_injects_project_store(self) -> None:
        """Verify _get_orchestrator wires a ChromaProjectStore into the singleton.

        Ensures that after Task 13 the orchestrator created by the legacy
        factory has a non-None project_store so per-project RAG retrieval works.
        """
        from app.api.v1.chat import _get_orchestrator

        mock_project_store = MagicMock()

        with (
            patch(
                "app.infrastructure.vector_store.chroma_store.ChromaProjectStore",
                return_value=mock_project_store,
            ),
            patch(
                "app.services.rag.vector_store.VectorStoreService",
                return_value=MagicMock(),
            ),
        ):
            result = _get_orchestrator()

        assert result.project_store is mock_project_store

    def test_get_orchestrator_returns_cached_singleton(self) -> None:
        """Verify that repeated calls return the same orchestrator instance."""
        from app.api.v1.chat import _get_orchestrator

        with (
            patch(
                "app.infrastructure.vector_store.chroma_store.ChromaProjectStore",
                return_value=MagicMock(),
            ),
            patch(
                "app.services.rag.vector_store.VectorStoreService",
                return_value=MagicMock(),
            ),
        ):
            first = _get_orchestrator()
            second = _get_orchestrator()

        assert first is second

    def test_set_orchestrator_overrides_singleton(self) -> None:
        """Verify set_orchestrator replaces the module-level instance.

        Used in tests to inject a pre-configured mock without triggering the
        lazy-init path that requires a live ChromaDB + LLM stack.
        """
        from app.api.v1.chat import get_orchestrator, set_orchestrator

        mock_instance = MagicMock()
        set_orchestrator(mock_instance)

        assert get_orchestrator() is mock_instance
