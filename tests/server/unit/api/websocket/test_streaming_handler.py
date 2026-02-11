"""Unit tests for WebSocket streaming handler."""

import asyncio
from unittest.mock import AsyncMock, MagicMock

import pytest
from fastapi import WebSocket

from app.api.v1.websocket.streaming_handler import StreamingHandler


class TestStreamingHandler:
    """Test suite for token streaming via WebSocket."""

    @pytest.fixture
    def mock_websocket(self) -> MagicMock:
        """Create a mocked WebSocket connection."""
        ws = MagicMock(spec=WebSocket)
        ws.send_text = AsyncMock()
        ws.receive_text = AsyncMock()
        ws.accept = AsyncMock()
        ws.close = AsyncMock()
        return ws

    @pytest.mark.asyncio
    async def test_connect_accepts_websocket_connection(
        self, mock_websocket: MagicMock
    ) -> None:
        """Should accept WebSocket connection successfully."""
        handler = StreamingHandler(
            heartbeat_interval_seconds=0.05, token_delay_seconds=0.01
        )

        await handler.connect(mock_websocket)

        mock_websocket.accept.assert_called_once()
        assert handler.active_connections == 1

    @pytest.mark.asyncio
    async def test_stream_tokens_sends_tokens_incrementally(
        self, mock_websocket: MagicMock
    ) -> None:
        """Should send tokens incrementally with <100ms latency."""
        handler = StreamingHandler(
            heartbeat_interval_seconds=0.05, token_delay_seconds=0.01
        )
        tokens = ["Hello", " ", "World", "!"]

        start_time = asyncio.get_event_loop().time()
        await handler.stream_tokens(mock_websocket, tokens)
        end_time = asyncio.get_event_loop().time()

        assert mock_websocket.send_text.call_count >= len(tokens)
        time_per_token = (end_time - start_time) / len(tokens)
        assert time_per_token < 0.1

    @pytest.mark.asyncio
    async def test_heartbeat_sends_ping_messages(
        self, mock_websocket: MagicMock
    ) -> None:
        """Should send heartbeat pings at configured interval."""
        handler = StreamingHandler(
            heartbeat_interval_seconds=0.05, token_delay_seconds=0.01
        )
        await handler.connect(mock_websocket)

        with pytest.raises(asyncio.TimeoutError):
            await asyncio.wait_for(
                handler.maintain_heartbeat(mock_websocket), timeout=0.18
            )

        ping_calls = [
            call
            for call in mock_websocket.send_text.call_args_list
            if '"type": "ping"' in str(call)
        ]
        assert len(ping_calls) >= 2

    @pytest.mark.asyncio
    async def test_disconnect_cleans_up_resources(
        self, mock_websocket: MagicMock
    ) -> None:
        """Should clean up resources on disconnect."""
        handler = StreamingHandler(
            heartbeat_interval_seconds=0.05, token_delay_seconds=0.01
        )
        await handler.connect(mock_websocket)

        await handler.disconnect(mock_websocket)

        assert handler.active_connections == 0
        mock_websocket.close.assert_called_once()

    @pytest.mark.asyncio
    async def test_backpressure_slows_down_tokens(
        self, mock_websocket: MagicMock
    ) -> None:
        """Should slow down when client is slow to consume tokens."""
        handler = StreamingHandler(
            heartbeat_interval_seconds=0.05, token_delay_seconds=0.01
        )

        async def slow_send(_: str) -> None:
            await asyncio.sleep(0.05)

        mock_websocket.send_text = AsyncMock(side_effect=slow_send)

        tokens = ["token"] * 5
        start_time = asyncio.get_event_loop().time()
        await handler.stream_tokens(mock_websocket, tokens)
        end_time = asyncio.get_event_loop().time()

        total_time = end_time - start_time
        assert total_time >= 0.2
