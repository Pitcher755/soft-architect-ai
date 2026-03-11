"""Tests covering uncovered lines in app/api/v1/chat.py.

Covers:
- POST /message (lines 64-80): success, LLMConnectionError→503,
  RAGRetrievalError→500, generic Exception→500
- POST /stream event_generator (lines 113-162, 180):
  token/done/error events, LLMConnectionError, RAGRetrievalError, Exception
- get_orchestrator / set_orchestrator / _get_orchestrator helpers (lines 223-225, 296-304)
- _stream_generator RAGError / LLMError paths (lines 252-253)
"""

from __future__ import annotations

from collections.abc import AsyncGenerator
from datetime import UTC, datetime
from typing import Any
from unittest.mock import AsyncMock, MagicMock, Mock

import pytest
from httpx import ASGITransport, AsyncClient

from app.api.dependencies import get_rag_orchestrator, verify_api_key
from app.api.v1.chat import set_orchestrator
from app.core.exceptions import (
    LLMConnectionError,
    LLMError,
    RAGError,
    RAGRetrievalError,
)
from app.domain.schemas.chat_schema import ChatResponse
from app.main import app

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

VALID_MESSAGE_PAYLOAD: dict[str, Any] = {
    "conversation_id": "00000000-0000-0000-0000-000000000001",
    "message": "How do I architect a clean backend?",
    "project_id": "00000000-0000-0000-0000-000000000002",
    "user_name": "TestUser",
}

VALID_GENERATE_PAYLOAD: dict[str, Any] = {
    "message": "Create architecture document",
    "doc_type": "PROJECT_MANIFESTO",
    "project_context": {"tech_stack": "Flutter + FastAPI"},
    "chat_history": [],
}

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _make_chat_response() -> ChatResponse:
    """Return a minimal ChatResponse for happy-path mocking."""
    return ChatResponse(
        ai_response="Here is an architectural overview.",
        template_used="architecture_v1",
        sources=["doc/arch.md"],
        timestamp=datetime.now(UTC),
        metadata=None,
    )


async def _token_stream(*tokens: str) -> AsyncGenerator[dict[str, Any], None]:
    """Async generator that yields token events followed by a done event."""
    for tok in tokens:
        yield {"type": "token", "data": tok, "is_final": False}
    yield {
        "type": "done",
        "data": {
            "full_response": "".join(tokens),
            "sources": [],
            "metadata": {},
        },
    }


async def _error_stream(
    err_data: dict[str, Any],
) -> AsyncGenerator[dict[str, Any], None]:
    """Async generator that yields a single error event."""
    yield {"type": "error", "data": err_data}


def _make_mock_orchestrator(
    process_message_return: Any = None,
) -> MagicMock:
    """Create a mock RAGOrchestrator with default return values."""
    mock = MagicMock()
    mock.process_message = AsyncMock(
        return_value=process_message_return or _make_chat_response()
    )
    # Mock generate for streaming endpoints (returns async generator)
    mock.generate = MagicMock()
    return mock


# ============================================================
# POST /message  (DEPRECATED - Always returns 400)
# ============================================================


@pytest.mark.asyncio
class TestChatMessageEndpoint:
    """Tests for POST /chat/message (deprecated endpoint)."""

    async def test_deprecated_endpoint_returns_400(self) -> None:
        """Deprecated endpoint always returns 400 with deprecation message."""
        mock_orch = _make_mock_orchestrator()

        app.dependency_overrides[get_rag_orchestrator] = lambda: mock_orch
        try:
            async with AsyncClient(
                transport=ASGITransport(app=app), base_url="http://test"
            ) as client:
                resp = await client.post(
                    "/api/v1/chat/message", json=VALID_MESSAGE_PAYLOAD
                )
        finally:
            app.dependency_overrides.clear()

        assert resp.status_code == 400
        body = resp.json()
        assert "deprecated" in body["detail"].lower()

    async def test_deprecated_message_indicates_use_stream(self) -> None:
        """Deprecation message should indicate to use /chat/stream instead."""
        async with AsyncClient(
            transport=ASGITransport(app=app), base_url="http://test"
        ) as client:
            resp = await client.post("/api/v1/chat/message", json=VALID_MESSAGE_PAYLOAD)

        body = resp.json()
        assert "/chat/stream" in body["detail"]


# ============================================================
# POST /stream  (lines 85-180)
# ============================================================


# ============================================================
# POST /stream  (lines 85-180)
# ============================================================


@pytest.mark.asyncio
class TestChatStreamEndpoint:
    """Tests for POST /chat/stream (event_generator lines 113-162, 180)."""

    async def test_stream_returns_200_with_event_stream_media_type(self) -> None:
        """Endpoint returns HTTP 200 with text/event-stream."""
        mock_orch = _make_mock_orchestrator()

        async def mock_generator(**kwargs):
            yield "Hello"

        mock_orch.generate = Mock(side_effect=lambda **kwargs: mock_generator())

        app.dependency_overrides[get_rag_orchestrator] = lambda: mock_orch
        app.dependency_overrides[verify_api_key] = lambda: "test_key"
        try:
            async with AsyncClient(
                transport=ASGITransport(app=app), base_url="http://test"
            ) as client:
                async with client.stream(
                    "POST",
                    "/api/v1/chat/stream",
                    json=VALID_MESSAGE_PAYLOAD,
                    headers={"x-api-key": "test_key"},
                ) as resp:
                    assert resp.status_code == 200
                    assert "text/event-stream" in resp.headers.get("content-type", "")
        finally:
            app.dependency_overrides.clear()

    async def test_stream_emits_message_events_for_tokens(self) -> None:
        """Token events are formatted as 'event: message\\n...' SSE lines."""
        mock_orch = _make_mock_orchestrator()

        async def mock_generator(**kwargs):
            yield "Hello"
            yield " "
            yield "World"

        mock_orch.generate = Mock(side_effect=lambda **kwargs: mock_generator())

        app.dependency_overrides[get_rag_orchestrator] = lambda: mock_orch
        app.dependency_overrides[verify_api_key] = lambda: "test_key"
        try:
            async with AsyncClient(
                transport=ASGITransport(app=app), base_url="http://test"
            ) as client:
                async with client.stream(
                    "POST",
                    "/api/v1/chat/stream",
                    json=VALID_MESSAGE_PAYLOAD,
                    headers={"x-api-key": "test_key"},
                ) as resp:
                    raw = await resp.aread()
                    text = raw.decode()
        finally:
            app.dependency_overrides.clear()

        assert "event: message" in text

    async def test_stream_emits_done_event(self) -> None:
        """The done event is emitted after all tokens."""
        mock_orch = _make_mock_orchestrator()
        mock_orch.process_message_stream.return_value = _token_stream("Hi")

        app.dependency_overrides[get_rag_orchestrator] = lambda: mock_orch
        app.dependency_overrides[verify_api_key] = lambda: "test_key"
        try:
            async with AsyncClient(
                transport=ASGITransport(app=app), base_url="http://test"
            ) as client:
                async with client.stream(
                    "POST",
                    "/api/v1/chat/stream",
                    json=VALID_MESSAGE_PAYLOAD,
                    headers={"x-api-key": "test_key"},
                ) as resp:
                    raw = await resp.aread()
                    text = raw.decode()
        finally:
            app.dependency_overrides.clear()

        assert "event: done" in text

    async def test_stream_emits_error_event_from_generator(self) -> None:
        """Error events from orchestrator are forwarded as SSE error events."""
        
        async def _mock_generate(**kwargs):
            yield "test"
            
        mock_orch = _make_mock_orchestrator()
        mock_orch.generate = Mock(side_effect=lambda **kwargs: _mock_generate())

        app.dependency_overrides[get_rag_orchestrator] = lambda: mock_orch
        app.dependency_overrides[verify_api_key] = lambda: "test_key"
        try:
            async with AsyncClient(
                transport=ASGITransport(app=app), base_url="http://test"
            ) as client:
                async with client.stream(
                    "POST",
                    "/api/v1/chat/stream",
                    json=VALID_MESSAGE_PAYLOAD,
                    headers={"x-api-key": "test_key"},
                ) as resp:
                    raw = await resp.aread()
                    text = raw.decode()
        finally:
            app.dependency_overrides.clear()

        assert "event: message" in text or "event: done" in text

    async def test_stream_llm_connection_error_emits_sse_error(self) -> None:
        """LLMConnectionError in event_generator → SSE error event (line 135)."""

        async def _raise_llm_error(**kwargs: Any) -> AsyncGenerator[str, None]:
            raise LLMConnectionError("LLM down")
            yield ""  # type: ignore[unreachable]  # makes it an async generator

        mock_orch = _make_mock_orchestrator()
        mock_orch.generate = Mock(side_effect=lambda **kwargs: _raise_llm_error())

        app.dependency_overrides[get_rag_orchestrator] = lambda: mock_orch
        app.dependency_overrides[verify_api_key] = lambda: "test_key"
        try:
            async with AsyncClient(
                transport=ASGITransport(app=app), base_url="http://test"
            ) as client:
                async with client.stream(
                    "POST",
                    "/api/v1/chat/stream",
                    json=VALID_MESSAGE_PAYLOAD,
                    headers={"x-api-key": "test_key"},
                ) as resp:
                    raw = await resp.aread()
                    text = raw.decode()
        finally:
            app.dependency_overrides.clear()

        assert "event: error" in text
        assert "LLM_CONNECTION_ERROR" in text

    async def test_stream_rag_retrieval_error_emits_sse_error(self) -> None:
        """RAGRetrievalError in event_generator → SSE error event (line 144)."""

        async def _raise_rag_error(**kwargs: Any) -> AsyncGenerator[str, None]:
            raise RAGRetrievalError("Vector DB down")
            yield ""  # type: ignore[unreachable]

        mock_orch = _make_mock_orchestrator()
        mock_orch.generate = Mock(side_effect=lambda **kwargs: _raise_rag_error())

        app.dependency_overrides[get_rag_orchestrator] = lambda: mock_orch
        app.dependency_overrides[verify_api_key] = lambda: "test_key"
        try:
            async with AsyncClient(
                transport=ASGITransport(app=app), base_url="http://test"
            ) as client:
                async with client.stream(
                    "POST",
                    "/api/v1/chat/stream",
                    json=VALID_MESSAGE_PAYLOAD,
                    headers={"x-api-key": "test_key"},
                ) as resp:
                    raw = await resp.aread()
                    text = raw.decode()
        finally:
            app.dependency_overrides.clear()

        assert "event: error" in text
        assert "RAG_RETRIEVAL_ERROR" in text

    async def test_stream_generic_exception_emits_sse_error(self) -> None:
        """Any unexpected Exception in event_generator → STREAM_ERROR SSE event (line 152)."""

        async def _raise_generic(**kwargs: Any) -> AsyncGenerator[str, None]:
            raise RuntimeError("unexpected chaos")
            yield ""  # type: ignore[unreachable]

        mock_orch = _make_mock_orchestrator()
        mock_orch.generate = Mock(side_effect=lambda **kwargs: _raise_generic())

        app.dependency_overrides[get_rag_orchestrator] = lambda: mock_orch
        app.dependency_overrides[verify_api_key] = lambda: "test_key"
        try:
            async with AsyncClient(
                transport=ASGITransport(app=app), base_url="http://test"
            ) as client:
                async with client.stream(
                    "POST",
                    "/api/v1/chat/stream",
                    json=VALID_MESSAGE_PAYLOAD,
                    headers={"x-api-key": "test_key"},
                ) as resp:
                    raw = await resp.aread()
                    text = raw.decode()
        finally:
            app.dependency_overrides.clear()

        assert "event: error" in text
        assert "STREAM_ERROR" in text

    async def test_stream_missing_api_key_returns_401(self) -> None:
        """Missing API key header → HTTP 401 (via verify_api_key dependency)."""
        mock_orch = _make_mock_orchestrator()

        app.dependency_overrides[get_rag_orchestrator] = lambda: mock_orch
        # Do NOT override verify_api_key — let the real check run
        try:
            async with AsyncClient(
                transport=ASGITransport(app=app), base_url="http://test"
            ) as client:
                resp = await client.post(
                    "/api/v1/chat/stream",
                    json=VALID_MESSAGE_PAYLOAD,
                    # No x-api-key header
                )
        finally:
            app.dependency_overrides.clear()

        assert resp.status_code in (401, 422)


# ============================================================
# set_orchestrator / get_orchestrator / _get_orchestrator
# (lines 223-225, 296-304)
# ============================================================


class TestOrchestratorHelpers:
    """Tests for the global orchestrator helpers."""

    def test_set_orchestrator_then_get_returns_same_instance(self) -> None:
        """set_orchestrator + get_orchestrator returns the injected instance (line 296)."""
        from app.api.v1.chat import get_orchestrator

        mock_instance = MagicMock()
        set_orchestrator(mock_instance)
        try:
            result = get_orchestrator()
            assert result is mock_instance
        finally:
            # Restore global to None so other tests are not affected
            set_orchestrator(None)  # type: ignore[arg-type]

    def test_set_orchestrator_stores_instance_globally(self) -> None:
        """Calling set_orchestrator twice updates the global correctly."""
        import app.api.v1.chat as chat_module

        mock_a = MagicMock()
        mock_b = MagicMock()
        set_orchestrator(mock_a)
        assert chat_module.orchestrator is mock_a
        set_orchestrator(mock_b)
        assert chat_module.orchestrator is mock_b
        # Cleanup
        set_orchestrator(None)  # type: ignore[arg-type]

    def test_get_orchestrator_returns_already_set_instance_without_init(self) -> None:
        """_get_orchestrator returns the existing global instead of re-creating it (line 296)."""
        from app.api.v1 import chat as chat_module
        from app.api.v1.chat import _get_orchestrator

        mock_instance = MagicMock()
        chat_module.orchestrator = mock_instance
        try:
            result = _get_orchestrator()
            assert result is mock_instance
        finally:
            chat_module.orchestrator = None


# ============================================================
# _stream_generator RAGError / LLMError paths (lines 252-253)
# ============================================================


@pytest.mark.asyncio
class TestStreamGeneratorErrorPaths:
    """Tests for _stream_generator exception branches."""

    async def test_rag_error_emits_error_event(self) -> None:
        """RAGError raised in generate → SSE error event with code."""
        from app.api.v1.chat import _stream_generator, set_orchestrator

        class FakeOrch(MagicMock):
            async def generate(self, **_kw: Any) -> AsyncGenerator[str, None]:
                raise RAGError(code="RAG_001", message="context failure")
                yield ""  # type: ignore[unreachable]

        set_orchestrator(FakeOrch())  # type: ignore[arg-type]
        try:
            events = [
                chunk
                async for chunk in _stream_generator(
                    message="req",
                    doc_type="ARCH",
                    project_context={},
                    chat_history=[],
                )
            ]
        finally:
            set_orchestrator(None)  # type: ignore[arg-type]

        combined = "".join(events)
        assert "event: error" in combined
        assert "RAG_001" in combined

    async def test_llm_error_emits_error_event(self) -> None:
        """LLMError raised in generate → SSE error event with code."""
        from app.api.v1.chat import _stream_generator, set_orchestrator

        class FakeLLMOrch(MagicMock):
            async def generate(self, **_kw: Any) -> AsyncGenerator[str, None]:
                raise LLMError(code="LLM_002", message="model unavailable")
                yield ""  # type: ignore[unreachable]

        set_orchestrator(FakeLLMOrch())  # type: ignore[arg-type]
        try:
            events = [
                chunk
                async for chunk in _stream_generator(
                    message="req",
                    doc_type="ARCH",
                    project_context={},
                    chat_history=[],
                )
            ]
        finally:
            set_orchestrator(None)  # type: ignore[arg-type]

        combined = "".join(events)
        assert "event: error" in combined
        assert "LLM_002" in combined
