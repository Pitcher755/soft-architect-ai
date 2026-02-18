"""Integration tests for POST /api/v1/chat/stream with history support."""

from unittest.mock import AsyncMock
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
    mock_orchestrator = AsyncMock()

    async def mock_stream():
        yield {"type": "token", "data": "Based", "is_final": False}
        yield {"type": "token", "data": " on our previous", "is_final": False}
        yield {"type": "token", "data": " conversation...", "is_final": False}
        yield {
            "type": "done",
            "data": {
                "full_response": "Based on our previous conversation...",
                "template_used": "CONTEXT_DRIVEN",
                "sources": ["doc://test.md"],
                "metadata": {"response_length": 35, "source_count": 1},
            },
        }

    mock_orchestrator.process_message_stream.return_value = mock_stream()

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

    # Verify history was passed to orchestrator
    call_args = mock_orchestrator.process_message_stream.call_args
    request_arg = call_args[0][0]  # First positional argument
    assert len(request_arg.history) == 2
    assert request_arg.history[0]["role"] == "user"

    # Cleanup
    app.dependency_overrides.clear()


@pytest.mark.asyncio
async def test_chat_stream_endpoint_without_history() -> None:
    """Request without history: Should work with empty/missing history field."""
    mock_orchestrator = AsyncMock()

    async def mock_stream():
        yield {"type": "token", "data": "Response", "is_final": False}
        yield {
            "type": "done",
            "data": {
                "full_response": "Response",
                "template_used": "CONTEXT_DRIVEN",
                "sources": [],
                "metadata": {"response_length": 8, "source_count": 0},
            },
        }

    mock_orchestrator.process_message_stream.return_value = mock_stream()

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

    # Verify empty history was passed
    call_args = mock_orchestrator.process_message_stream.call_args
    request_arg = call_args[0][0]
    assert request_arg.history == []

    # Cleanup
    app.dependency_overrides.clear()


@pytest.mark.asyncio
async def test_chat_stream_endpoint_rejects_invalid_history() -> None:
    """Invalid history: Should return 422 for malformed history."""
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
    """Oversized history: Should return 422 for >20 messages."""
    large_history = [
        {"role": "user" if i % 2 == 0 else "assistant", "content": f"Message {i}"}
        for i in range(21)
    ]

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
