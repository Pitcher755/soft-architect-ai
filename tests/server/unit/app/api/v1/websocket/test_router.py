"""
Unit tests for WebSocket router (streaming chat endpoint).

Coverage target: >80% (current: 32%)
"""

import asyncio
import json
import pytest
from unittest.mock import AsyncMock, patch

from fastapi import WebSocket, WebSocketDisconnect

from app.api.v1.websocket.router import (
    stream_chat,
    _generate_tokens,
    _extract_query,
)


class TestGenerateTokens:
    """Test suite for _generate_tokens helper function."""

    def test_generate_tokens_normal_query(self):
        """Test token generation for normal query."""
        tokens = list(_generate_tokens("Hello world"))
        assert tokens == ["Hello ", "world "]

    def test_generate_tokens_single_word(self):
        """Test token generation for single word."""
        tokens = list(_generate_tokens("hello"))
        assert tokens == ["hello "]

    def test_generate_tokens_empty_string(self):
        """Test token generation for empty string."""
        tokens = list(_generate_tokens(""))
        assert tokens == ["token"]

    def test_generate_tokens_long_query(self):
        """Test token generation for 'long' keyword (200 tokens)."""
        tokens = list(_generate_tokens("This is a long query"))
        assert len(tokens) == 200
        assert all(token == "token" for token in tokens)

    def test_generate_tokens_very_long_query(self):
        """Test token generation for 'very long' keyword (600 tokens)."""
        tokens = list(_generate_tokens("This is a very long query"))
        assert len(tokens) == 600
        assert all(token == "token" for token in tokens)

    def test_generate_tokens_case_insensitive(self):
        """Test token generation is case-insensitive for keywords."""
        tokens_lower = list(_generate_tokens("VERY LONG QUERY"))
        assert len(tokens_lower) == 600

        tokens_upper = list(_generate_tokens("Long Query"))
        assert len(tokens_upper) == 200


class TestExtractQuery:
    """Test suite for _extract_query helper function."""

    def test_extract_query_valid_json_with_query_type(self):
        """Test extracting query from valid JSON with type='query'."""
        message = json.dumps({"type": "query", "content": "What is Docker?"})
        result = _extract_query(message)
        assert result == "What is Docker?"

    def test_extract_query_json_without_query_type(self):
        """Test extracting query from JSON without type='query'."""
        message = json.dumps({"type": "command", "content": "some content"})
        result = _extract_query(message)
        assert result == ""

    def test_extract_query_json_missing_content(self):
        """Test extracting query from JSON with missing 'content' field."""
        message = json.dumps({"type": "query"})
        result = _extract_query(message)
        assert result == ""

    def test_extract_query_plain_text(self):
        """Test extracting query from plain text (not JSON)."""
        message = "This is plain text"
        result = _extract_query(message)
        assert result == "This is plain text"

    def test_extract_query_invalid_json(self):
        """Test extracting query from malformed JSON falls back to raw message."""
        message = '{"invalid": json}'
        result = _extract_query(message)
        assert result == '{"invalid": json}'

    def test_extract_query_json_with_non_string_content(self):
        """Test extracting query converts non-string content to string."""
        message = json.dumps({"type": "query", "content": 12345})
        result = _extract_query(message)
        assert result == "12345"

    def test_extract_query_json_list(self):
        """Test extracting query from JSON list returns raw message."""
        message = json.dumps(["item1", "item2"])
        result = _extract_query(message)
        assert result == '["item1", "item2"]'


@pytest.mark.asyncio
class TestStreamChat:
    """Test suite for stream_chat WebSocket endpoint."""

    @patch("app.api.v1.websocket.router._handler")
    async def test_stream_chat_normal_flow(self, mock_handler):
        """Test normal WebSocket streaming flow."""
        # Mock WebSocket
        mock_websocket = AsyncMock(spec=WebSocket)
        mock_websocket.receive_text = AsyncMock(
            side_effect=[
                json.dumps({"type": "query", "content": "Hello"}),
                WebSocketDisconnect(),
            ]
        )

        # Mock handler methods
        mock_handler.connect = AsyncMock()
        mock_handler.maintain_heartbeat = AsyncMock(
            return_value=asyncio.create_task(asyncio.sleep(100))
        )
        mock_handler.stream_tokens = AsyncMock()
        mock_handler.disconnect = AsyncMock()

        # Execute
        await stream_chat(mock_websocket)

        # Assertions
        mock_handler.connect.assert_called_once_with(mock_websocket)
        mock_handler.stream_tokens.assert_called_once()
        mock_handler.disconnect.assert_called_once_with(mock_websocket)

    @patch("app.api.v1.websocket.router._handler")
    async def test_stream_chat_multiple_messages(self, mock_handler):
        """Test WebSocket handling multiple messages before disconnect."""
        mock_websocket = AsyncMock(spec=WebSocket)
        mock_websocket.receive_text = AsyncMock(
            side_effect=[
                json.dumps({"type": "query", "content": "First"}),
                json.dumps({"type": "query", "content": "Second"}),
                json.dumps({"type": "query", "content": "Third"}),
                WebSocketDisconnect(),
            ]
        )

        mock_handler.connect = AsyncMock()
        mock_handler.maintain_heartbeat = AsyncMock(
            return_value=asyncio.create_task(asyncio.sleep(100))
        )
        mock_handler.stream_tokens = AsyncMock()
        mock_handler.disconnect = AsyncMock()

        await stream_chat(mock_websocket)

        # Should have called stream_tokens 3 times
        assert mock_handler.stream_tokens.call_count == 3

    @patch("app.api.v1.websocket.router._handler")
    async def test_stream_chat_empty_query(self, mock_handler):
        """Test WebSocket ignores empty queries."""
        mock_websocket = AsyncMock(spec=WebSocket)
        mock_websocket.receive_text = AsyncMock(
            side_effect=[
                json.dumps({"type": "command", "content": "ignored"}),  # Empty query
                json.dumps({"type": "query", "content": "Valid"}),
                WebSocketDisconnect(),
            ]
        )

        mock_handler.connect = AsyncMock()
        mock_handler.maintain_heartbeat = AsyncMock(
            return_value=asyncio.create_task(asyncio.sleep(100))
        )
        mock_handler.stream_tokens = AsyncMock()
        mock_handler.disconnect = AsyncMock()

        await stream_chat(mock_websocket)

        # Should only call stream_tokens once (second message)
        assert mock_handler.stream_tokens.call_count == 1

    @patch("app.api.v1.websocket.router._handler")
    async def test_stream_chat_disconnect_cleanup(self, mock_handler):
        """Test WebSocket properly cleans up on disconnect."""
        mock_websocket = AsyncMock(spec=WebSocket)
        mock_websocket.receive_text = AsyncMock(side_effect=WebSocketDisconnect())

        # Create a real task that we can cancel
        heartbeat_task = asyncio.create_task(asyncio.sleep(100))
        mock_handler.connect = AsyncMock()
        mock_handler.maintain_heartbeat = AsyncMock(return_value=heartbeat_task)
        mock_handler.disconnect = AsyncMock()

        await stream_chat(mock_websocket)

        # Verify disconnect cleanup was called (critical behavior)
        mock_handler.disconnect.assert_called_once_with(mock_websocket)

        # Clean up: Cancel task if still running
        if not heartbeat_task.done():
            heartbeat_task.cancel()
            try:
                await heartbeat_task
            except asyncio.CancelledError:
                pass

    @patch("app.api.v1.websocket.router._handler")
    async def test_stream_chat_with_long_query(self, mock_handler):
        """Test WebSocket handles 'long' query (200 tokens)."""
        mock_websocket = AsyncMock(spec=WebSocket)
        mock_websocket.receive_text = AsyncMock(
            side_effect=[
                json.dumps({"type": "query", "content": "This is a long query"}),
                WebSocketDisconnect(),
            ]
        )

        mock_handler.connect = AsyncMock()
        mock_handler.maintain_heartbeat = AsyncMock(
            return_value=asyncio.create_task(asyncio.sleep(100))
        )
        mock_handler.stream_tokens = AsyncMock()
        mock_handler.disconnect = AsyncMock()

        await stream_chat(mock_websocket)

        # Verify stream_tokens called with generator producing 200 tokens
        call_args = mock_handler.stream_tokens.call_args
        tokens = list(call_args[0][1])  # Second argument is the token generator
        assert len(tokens) == 200

    @patch("app.api.v1.websocket.router._handler")
    async def test_stream_chat_with_very_long_query(self, mock_handler):
        """Test WebSocket handles 'very long' query (600 tokens)."""
        mock_websocket = AsyncMock(spec=WebSocket)
        mock_websocket.receive_text = AsyncMock(
            side_effect=[
                json.dumps({"type": "query", "content": "This is a very long query"}),
                WebSocketDisconnect(),
            ]
        )

        mock_handler.connect = AsyncMock()
        mock_handler.maintain_heartbeat = AsyncMock(
            return_value=asyncio.create_task(asyncio.sleep(100))
        )
        mock_handler.stream_tokens = AsyncMock()
        mock_handler.disconnect = AsyncMock()

        await stream_chat(mock_websocket)

        # Verify stream_tokens called with generator producing 600 tokens
        call_args = mock_handler.stream_tokens.call_args
        tokens = list(call_args[0][1])
        assert len(tokens) == 600
