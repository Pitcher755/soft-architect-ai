"""Integration tests for chat endpoint."""

# ruff: noqa: S101

from unittest.mock import AsyncMock
from uuid import uuid4

import pytest
from httpx import ASGITransport, AsyncClient

from app.api.dependencies import get_rag_orchestrator
from app.core.exceptions import LLMConnectionError, RAGRetrievalError
from app.domain.schemas.chat_schema import ChatResponse
from app.main import app


class TestChatEndpoint:
    """Integration tests for POST /api/v1/chat/message."""

    @pytest.fixture
    def mock_orchestrator_success(self) -> AsyncMock:
        """Mock orchestrator that returns success."""
        mock = AsyncMock()
        mock.process_message.return_value = ChatResponse(
            ai_response="Mocked AI response",
            template_used="10-CONTEXT",
            sources=["test.md"],
        )
        return mock

    @pytest.mark.asyncio
    async def test_chat_endpoint_success(
        self,
        mock_orchestrator_success: AsyncMock,
    ) -> None:
        """Valid request: Should return 200 OK with ChatResponse."""
        app.dependency_overrides[get_rag_orchestrator] = (
            lambda: mock_orchestrator_success
        )

        transport = ASGITransport(app=app)
        async with AsyncClient(transport=transport, base_url="http://test") as client:
            response = await client.post(
                "/api/v1/chat/message",
                json={
                    "conversation_id": str(uuid4()),
                    "message": "How to test in Python?",
                    "project_id": str(uuid4()),
                },
            )

        assert response.status_code == 200
        data = response.json()
        assert data["ai_response"] == "Mocked AI response"
        assert data["template_used"] == "10-CONTEXT"
        assert data["sources"] == ["test.md"]

        app.dependency_overrides.clear()

    @pytest.mark.asyncio
    async def test_chat_endpoint_validation_error(self) -> None:
        """Invalid request: Should return 422 Unprocessable Entity."""
        transport = ASGITransport(app=app)
        async with AsyncClient(transport=transport, base_url="http://test") as client:
            response = await client.post(
                "/api/v1/chat/message",
                json={
                    "conversation_id": "not-a-uuid",
                    "message": "Test",
                    "project_id": str(uuid4()),
                },
            )

        assert response.status_code == 422
        data = response.json()
        assert "detail" in data

    @pytest.mark.asyncio
    async def test_chat_endpoint_llm_failure(self) -> None:
        """LLM failure: Should return 503 Service Unavailable."""
        mock = AsyncMock()
        mock.process_message.side_effect = LLMConnectionError("Ollama is down")

        app.dependency_overrides[get_rag_orchestrator] = lambda: mock

        transport = ASGITransport(app=app)
        async with AsyncClient(transport=transport, base_url="http://test") as client:
            response = await client.post(
                "/api/v1/chat/message",
                json={
                    "conversation_id": str(uuid4()),
                    "message": "Test",
                    "project_id": str(uuid4()),
                },
            )

        assert response.status_code == 503
        data = response.json()
        assert "AI Engine" in data["detail"] or "unreachable" in data["detail"].lower()

        app.dependency_overrides.clear()

    @pytest.mark.asyncio
    async def test_chat_endpoint_rag_failure(self) -> None:
        """RAG failure: Should return 500 Internal Server Error."""
        mock = AsyncMock()
        mock.process_message.side_effect = RAGRetrievalError("Vector store offline")

        app.dependency_overrides[get_rag_orchestrator] = lambda: mock

        transport = ASGITransport(app=app)
        async with AsyncClient(transport=transport, base_url="http://test") as client:
            response = await client.post(
                "/api/v1/chat/message",
                json={
                    "conversation_id": str(uuid4()),
                    "message": "Test",
                    "project_id": str(uuid4()),
                },
            )

        assert response.status_code == 500
        data = response.json()
        assert "error" in data["detail"].lower() or "failed" in data["detail"].lower()

        app.dependency_overrides.clear()
