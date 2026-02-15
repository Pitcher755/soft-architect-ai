"""Integration tests for /api/v1/chat/stream SSE endpoint (HU-4.3 Phase 2).

This module tests the Server-Sent Events (SSE) streaming endpoint for real-time
AI response generation. Tests validate SSE protocol compliance, event formatting,
error handling, and authentication.

Test Coverage:
- SSE event format validation (event: + data: + \n\n)
- Content-Type header validation (text/event-stream)
- Token, done, and error event emission
- Empty response handling
- Exception handling (error events)
- Authentication enforcement (API key required)

TDD Cycle: RED Phase
Expected: All tests FAIL (endpoint not implemented yet).
"""

import json
from typing import AsyncGenerator, Callable
from unittest.mock import patch

import pytest
from httpx import ASGITransport, AsyncClient

from app.main import app


class TestChatStreamEndpoint:
    """Test suite for SSE streaming chat endpoint."""

    @pytest.fixture
    def mock_llm_stream(self) -> Callable[[], AsyncGenerator[dict, None]]:
        """
        Mock RAG orchestrator streaming response with tokens and done event.

        Returns:
            Async generator yielding dict events matching orchestrator format.
        """

        async def _stream() -> AsyncGenerator[dict, None]:
            # Yield token events
            tokens = ["The", " sky", " is", " blue."]
            for token in tokens:
                yield {
                    "type": "token",
                    "data": token,
                    "is_final": False,
                }
            # Yield done event
            yield {
                "type": "done",
                "data": {
                    "full_response": "The sky is blue.",
                    "sources": [],
                    "metadata": {
                        "template_used": "FALLBACK",
                        "token_count": 4,
                        "source_count": 0,
                    },
                },
            }

        return _stream

    @pytest.mark.asyncio
    async def test_chat_stream_returns_sse_events(
        self, mock_llm_stream: Callable[[], AsyncGenerator[dict, None]]
    ) -> None:
        """
        Test that /chat/stream returns properly formatted SSE events.

        Verifies:
        - Response status code is 200
        - Events are SSE-formatted (event: + data: + \n\n)
        - Token events contain correct structure
        - At least 4 token events + 1 done event emitted
        """
        # Arrange
        transport = ASGITransport(app=app)
        async with AsyncClient(transport=transport, base_url="http://test") as client:
            with patch(
                "app.services.rag.orchestrator.RAGOrchestrator.process_message_stream"
            ) as mock_rag:
                mock_rag.return_value = mock_llm_stream()

                # Act
                response = await client.post(
                    "/api/v1/chat/stream",
                    json={
                        "conversation_id": "550e8400-e29b-41d4-a716-446655440000",
                        "message": "Why is the sky blue?",
                        "project_id": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
                    },
                    headers={"X-API-Key": "test-key-12345"},
                )

                # Assert
                assert response.status_code == 200, "SSE endpoint should return 200 OK"

                # Parse SSE events
                events = []
                for line in response.text.split("\n\n"):
                    if line.strip():
                        events.append(line)

                # Should have 4 token events + 1 done event
                assert len(events) >= 4, f"Expected >= 4 events, got {len(events)}"

                # Check first token event
                assert events[0].startswith(
                    "event: message"
                ), "First event should be message type"
                assert (
                    '"token":"The"' in events[0] or '"token": "The"' in events[0]
                ), "First token should be 'The'"
                assert (
                    '"is_final":false' in events[0] or '"is_final": false' in events[0]
                ), "Token event should have is_final: false"

    @pytest.mark.asyncio
    async def test_chat_stream_content_type_header(self) -> None:
        """
        Test that Content-Type is text/event-stream.

        Verifies:
        - Content-Type header includes 'text/event-stream'
        - Charset is UTF-8
        """

        # Arrange
        async def empty_stream() -> AsyncGenerator[dict, None]:
            """Empty stream with only done event."""
            yield {
                "type": "done",
                "data": {
                    "full_response": "",
                    "sources": [],
                    "metadata": {
                        "template_used": "FALLBACK",
                        "token_count": 0,
                        "source_count": 0,
                    },
                },
            }

        transport = ASGITransport(app=app)
        async with AsyncClient(transport=transport, base_url="http://test") as client:
            with patch(
                "app.services.rag.orchestrator.RAGOrchestrator.process_message_stream"
            ) as mock_rag:
                mock_rag.return_value = empty_stream()

                # Act
                response = await client.post(
                    "/api/v1/chat/stream",
                    json={
                        "conversation_id": "550e8400-e29b-41d4-a716-446655440000",
                        "message": "Test",
                        "project_id": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
                    },
                    headers={"X-API-Key": "test-key-12345"},
                )

                # Assert
                content_type = response.headers.get("content-type", "")
                assert (
                    "text/event-stream" in content_type
                ), f"Expected text/event-stream, got {content_type}"
                assert "charset=utf-8" in content_type.lower(), "Expected UTF-8 charset"

    @pytest.mark.asyncio
    async def test_chat_stream_handles_empty_response(self) -> None:
        """
        Test handling of empty LLM response.

        Verifies:
        - Empty stream still returns 200
        - At least a 'done' event is emitted
        - No exceptions raised
        """

        # Arrange
        async def empty_stream() -> AsyncGenerator[dict, None]:
            """Generator with only done event."""
            yield {
                "type": "done",
                "data": {
                    "full_response": "",
                    "sources": [],
                    "metadata": {
                        "template_used": "FALLBACK",
                        "token_count": 0,
                        "source_count": 0,
                    },
                },
            }

        transport = ASGITransport(app=app)
        async with AsyncClient(transport=transport, base_url="http://test") as client:
            with patch(
                "app.services.rag.orchestrator.RAGOrchestrator.process_message_stream"
            ) as mock_rag:
                mock_rag.return_value = empty_stream()

                # Act
                response = await client.post(
                    "/api/v1/chat/stream",
                    json={
                        "conversation_id": "550e8400-e29b-41d4-a716-446655440000",
                        "message": "Why is the sky blue?",
                        "project_id": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
                    },
                    headers={"X-API-Key": "test-key-12345"},
                )

                # Assert
                assert (
                    response.status_code == 200
                ), "Empty stream should still return 200"
                assert (
                    "event: done" in response.text
                ), "Empty stream should emit done event"

    @pytest.mark.asyncio
    async def test_chat_stream_emits_done_event(
        self, mock_llm_stream: Callable[[], AsyncGenerator[dict, None]]
    ) -> None:
        """
        Test that stream ends with done event containing metadata.

        Verifies:
        - 'done' event is present in stream
        - Done event contains full_response
        - Done event contains sources and metadata
        """
        # Arrange
        transport = ASGITransport(app=app)
        async with AsyncClient(transport=transport, base_url="http://test") as client:
            with patch(
                "app.services.rag.orchestrator.RAGOrchestrator.process_message_stream"
            ) as mock_rag:
                mock_rag.return_value = mock_llm_stream()

                # Act
                response = await client.post(
                    "/api/v1/chat/stream",
                    json={
                        "conversation_id": "550e8400-e29b-41d4-a716-446655440000",
                        "message": "Test",
                        "project_id": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
                    },
                    headers={"X-API-Key": "test-key-12345"},
                )

                # Assert
                assert (
                    "event: done" in response.text
                ), "Stream should end with done event"

                # Extract done event data
                done_lines = [
                    line for line in response.text.split("\n") if "event: done" in line
                ]
                assert len(done_lines) > 0, "Should have at least one done event"

                # Find data line after done event
                response_lines = response.text.split("\n")
                for i, line in enumerate(response_lines):
                    if "event: done" in line and i + 1 < len(response_lines):
                        data_line = response_lines[i + 1]
                        if data_line.startswith("data:"):
                            data_json = data_line.replace("data:", "").strip()
                            data = json.loads(data_json)
                            assert (
                                "full_response" in data
                            ), "Done event should contain full_response"
                            break

    @pytest.mark.asyncio
    async def test_chat_stream_error_event_on_exception(self) -> None:
        """
        Test that errors are emitted as error events.

        Verifies:
        - Exceptions during streaming emit 'error' events
        - Error event contains error message
        - Response still returns 200 (SSE protocol)
        """

        # Arrange
        async def failing_stream() -> AsyncGenerator[dict, None]:
            """Generator that yields one token then fails."""
            yield {
                "type": "token",
                "data": "Token1",
                "is_final": False,
            }
            raise Exception("LLM connection failed")

        transport = ASGITransport(app=app)
        async with AsyncClient(transport=transport, base_url="http://test") as client:
            with patch(
                "app.services.rag.orchestrator.RAGOrchestrator.process_message_stream"
            ) as mock_rag:
                mock_rag.return_value = failing_stream()

                # Act
                response = await client.post(
                    "/api/v1/chat/stream",
                    json={
                        "conversation_id": "550e8400-e29b-41d4-a716-446655440000",
                        "message": "Test",
                        "project_id": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
                    },
                    headers={"X-API-Key": "test-key-12345"},
                )

                # Assert
                assert (
                    response.status_code == 200
                ), "SSE always returns 200 (errors in stream)"
                assert "event: error" in response.text, "Error event should be emitted"
                assert (
                    "LLM connection failed" in response.text
                    or "error" in response.text.lower()
                ), "Error message should be in response"

    @pytest.mark.asyncio
    async def test_chat_stream_requires_authentication(self) -> None:
        """
        Test that endpoint requires API key.

        Verifies:
        - Request without API key returns 401 Unauthorized
        - Authentication is enforced before streaming
        """
        # Arrange
        transport = ASGITransport(app=app)
        async with AsyncClient(transport=transport, base_url="http://test") as client:
            # Act - No API key
            response = await client.post(
                "/api/v1/chat/stream",
                json={
                    "conversation_id": "550e8400-e29b-41d4-a716-446655440000",
                    "message": "Test",
                    "project_id": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
                },
            )

            # Assert
            assert (
                response.status_code == 401
            ), "Request without API key should return 401 Unauthorized"
