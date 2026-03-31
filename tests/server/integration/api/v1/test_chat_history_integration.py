"""Integration tests for POST /api/v1/chat/stream with history support."""

from unittest.mock import MagicMock
from uuid import uuid4

import pytest
from httpx import ASGITransport, AsyncClient

from app.api.dependencies import get_rag_orchestrator, verify_api_key
from app.api.v1 import router as api_v1_router

# Create test app with v1 router (includes /api/v1 prefix)
from fastapi import FastAPI

app = FastAPI()
app.include_router(api_v1_router)


@pytest.mark.asyncio
async def test_chat_stream_endpoint_with_history_success() -> None:
    """Valid request with history: Should stream response with history context."""
    # Mock orchestrator
    mock_orchestrator = MagicMock()

    async def mock_stream():
        """Mock generator for orchestrator.generate()."""
        yield "Based"
        yield " on our previous"
        yield " conversation..."

    mock_orchestrator.generate = MagicMock(
        side_effect=lambda *args, **kwargs: mock_stream()
    )

    app.dependency_overrides[get_rag_orchestrator] = lambda: mock_orchestrator
    app.dependency_overrides[verify_api_key] = lambda: "test-api-key"

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.post(
            "/api/v1/chat/stream",
            json={
                "conversation_id": str(uuid4()),
                "message": "Continue the implementation",
                "project_id": str(uuid4()),
                "history": [
                    {"role": "user", "content": "What is Clean Architecture?"},
                    {
                        "role": "assistant",
                        "content": "Clean Architecture is a design pattern...",
                    },
                ],
            },
        )

    assert response.status_code == 200

    # Verify generate was called with correct context including history
    call_args = mock_orchestrator.generate.call_args
    context_arg = call_args[1]["context"]  # Keyword argument 'context'
    assert "chat_history" in context_arg
    assert len(context_arg["chat_history"]) == 2
    assert context_arg["chat_history"][0]["role"] == "user"

    # Cleanup
    app.dependency_overrides.clear()


@pytest.mark.asyncio
async def test_chat_stream_endpoint_without_history() -> None:
    """Request without history: Should work with empty/missing history field."""
    mock_orchestrator = MagicMock()

    async def mock_stream():
        """Mock generator for orchestrator.generate()."""
        yield "Response"

    mock_orchestrator.generate = MagicMock(
        side_effect=lambda *args, **kwargs: mock_stream()
    )

    app.dependency_overrides[get_rag_orchestrator] = lambda: mock_orchestrator
    app.dependency_overrides[verify_api_key] = lambda: "test-api-key"

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.post(
            "/api/v1/chat/stream",
            json={
                "conversation_id": str(uuid4()),
                "message": "Test message",
                "project_id": str(uuid4()),
                # No 'history' field provided
            },
        )

    assert response.status_code == 200

    # Verify generate was called with empty history in context
    call_args = mock_orchestrator.generate.call_args
    context_arg = call_args[1]["context"]  # Keyword argument 'context'
    assert context_arg["chat_history"] == []

    # Cleanup
    app.dependency_overrides.clear()


@pytest.mark.asyncio
async def test_chat_stream_endpoint_rejects_invalid_history() -> None:
    """Invalid history: Should return 422 for malformed history."""
    mock_orchestrator = MagicMock()
    app.dependency_overrides[get_rag_orchestrator] = lambda: mock_orchestrator
    app.dependency_overrides[verify_api_key] = lambda: "test-api-key"

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.post(
            "/api/v1/chat/stream",
            json={
                "conversation_id": str(uuid4()),
                "message": "Test",
                "project_id": str(uuid4()),
                "history": [
                    {"role": "invalid_role", "content": "Bad message"}  # Invalid role
                ],
            },
        )

    assert response.status_code == 422  # Validation error
    error_detail = response.json()["detail"]
    assert any("invalid role" in str(err).lower() for err in error_detail)

    # Cleanup
    app.dependency_overrides.clear()


@pytest.mark.asyncio
async def test_chat_stream_endpoint_rejects_oversized_history() -> None:
    """Oversized history: Should return 422 for >100 messages (default config)."""
    large_history = [
        {"role": "user" if i % 2 == 0 else "assistant", "content": f"Message {i}"}
        for i in range(101)  # Exceeds default limit of 100
    ]

    mock_orchestrator = MagicMock()
    app.dependency_overrides[get_rag_orchestrator] = lambda: mock_orchestrator
    app.dependency_overrides[verify_api_key] = lambda: "test-api-key"

    transport = ASGITransport(app=app)
    async with AsyncClient(transport=transport, base_url="http://test") as client:
        response = await client.post(
            "/api/v1/chat/stream",
            json={
                "conversation_id": str(uuid4()),
                "message": "Test",
                "project_id": str(uuid4()),
                "history": large_history,
            },
        )

    assert response.status_code == 422
    error_detail = response.json()["detail"]
    assert any("exceeds maximum length" in str(err).lower() for err in error_detail)

    # Cleanup
    app.dependency_overrides.clear()
