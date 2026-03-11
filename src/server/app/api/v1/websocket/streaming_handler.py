"""
WebSocket streaming handler for real-time token delivery.

This module implements optimized WebSocket communication for streaming
LLM tokens with low latency and stable connections.
"""

from __future__ import annotations

import asyncio
import json
import logging
import time
from collections.abc import Iterable
from datetime import UTC, datetime

from fastapi import WebSocket, WebSocketDisconnect

from app.core.config import settings
from app.core.exceptions import StreamingError
from app.core.performance.metrics_collector import MetricsCollector
from app.domain.streaming.stream_protocol import DoneMessage, ErrorMessage, TokenMessage

logger = logging.getLogger(__name__)


class StreamingHandler:
    """Manages WebSocket connections for streaming tokens."""

    def __init__(
        self,
        heartbeat_interval_seconds: float | None = None,
        token_delay_seconds: float | None = None,
    ) -> None:
        self._connections: set[WebSocket] = set()
        self._heartbeat_interval = (
            heartbeat_interval_seconds
            if heartbeat_interval_seconds is not None
            else settings.WS_HEARTBEAT_INTERVAL_SECONDS
        )
        self._token_delay = (
            token_delay_seconds
            if token_delay_seconds is not None
            else settings.WS_TOKEN_DELAY_SECONDS
        )
        self._metrics = MetricsCollector()

    @property
    def active_connections(self) -> int:
        """Return number of active connections."""
        return len(self._connections)

    async def connect(self, websocket: WebSocket) -> None:
        """Accept a new WebSocket connection."""
        with self._metrics.measure_ttfb():
            try:
                await websocket.accept()
            except RuntimeError as exc:
                self._metrics.record_connection_failure()
                logger.error("WebSocket accept failed", extra={"error_code": "WS_ACCEPT"})
                raise StreamingError(
                    code="WS_CONNECTION_FAILED",
                    message="Failed to establish WebSocket connection",
                    operation="connect",
                ) from exc

        self._connections.add(websocket)
        self._metrics.record_connection_success()
        logger.info("WebSocket connected", extra={"active_connections": self.active_connections})

    async def disconnect(self, websocket: WebSocket) -> None:
        """Close WebSocket connection and clean up resources."""
        self._connections.discard(websocket)
        try:
            await websocket.close()
        except RuntimeError:
            logger.warning("WebSocket close failed")
        logger.info(
            "WebSocket disconnected",
            extra={"active_connections": self.active_connections},
        )

    async def stream_tokens(self, websocket: WebSocket, tokens: Iterable[str]) -> None:
        """Stream tokens incrementally with controlled latency."""
        token_count = 0
        start_time = time.perf_counter()

        try:
            for token in tokens:
                send_start = time.perf_counter()
                message = TokenMessage(
                    content=token,
                    timestamp=datetime.now(tz=UTC).isoformat(),
                )
                await websocket.send_text(json.dumps(message.to_dict()))
                token_count += 1

                elapsed_ms = (time.perf_counter() - send_start) * 1000
                self._metrics.record_token_sent(elapsed_ms)

                delay = self._token_delay - (time.perf_counter() - send_start)
                if delay > 0:
                    await asyncio.sleep(delay)

            total_ms = (time.perf_counter() - start_time) * 1000
            done_message = DoneMessage(total_tokens=token_count, latency_ms=round(total_ms, 2))
            await websocket.send_text(json.dumps(done_message.to_dict()))

        except WebSocketDisconnect:
            await self.disconnect(websocket)
        except (RuntimeError, ValueError, TypeError) as exc:
            error_payload = ErrorMessage(
                code="WS_STREAM_FAILED",
                message="Failed to stream tokens",
            )
            await websocket.send_text(json.dumps(error_payload.to_dict()))
            raise StreamingError(
                code="WS_STREAM_FAILED",
                message="Failed to stream tokens",
                operation="stream_tokens",
            ) from exc

    async def maintain_heartbeat(self, websocket: WebSocket) -> None:
        """Send periodic heartbeat to keep connection alive."""
        try:
            while websocket in self._connections:
                await asyncio.sleep(self._heartbeat_interval)
                await websocket.send_text(json.dumps({"type": "ping"}))
        except WebSocketDisconnect:
            await self.disconnect(websocket)
        except RuntimeError:
            logger.warning("Heartbeat failed")

    async def handle_backpressure(self, buffer_size: int) -> None:
        """Apply backpressure if client buffer is full."""
        threshold = settings.WS_BACKPRESSURE_THRESHOLD_BYTES
        if buffer_size > threshold:
            delay = min(0.5, (buffer_size / threshold) * 0.1)
            await asyncio.sleep(delay)
            logger.warning("Backpressure applied", extra={"delay": delay})
