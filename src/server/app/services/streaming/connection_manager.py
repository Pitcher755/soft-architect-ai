"""WebSocket connection manager for streaming sessions."""

from __future__ import annotations

import asyncio
import logging
from collections.abc import Iterable

from fastapi import WebSocket

logger = logging.getLogger(__name__)


class ConnectionManager:
    """Manages active WebSocket connections."""

    def __init__(self) -> None:
        self._connections: set[WebSocket] = set()

    @property
    def active_count(self) -> int:
        """Return number of active connections."""
        return len(self._connections)

    def list_connections(self) -> Iterable[WebSocket]:
        """Return a snapshot of active connections."""
        return tuple(self._connections)

    async def add(self, websocket: WebSocket) -> None:
        """Add a WebSocket connection."""
        self._connections.add(websocket)
        logger.info("WebSocket registered", extra={"active_connections": self.active_count})

    async def remove(self, websocket: WebSocket) -> None:
        """Remove a WebSocket connection."""
        self._connections.discard(websocket)
        logger.info("WebSocket removed", extra={"active_connections": self.active_count})

    async def broadcast(self, message: str) -> None:
        """Broadcast message to all active connections."""
        if not self._connections:
            return
        await asyncio.gather(*(ws.send_text(message) for ws in self._connections))
