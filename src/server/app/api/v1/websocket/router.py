"""WebSocket endpoints for streaming chat tokens."""

from __future__ import annotations

import asyncio
import json
import logging
from collections.abc import Iterable

from fastapi import APIRouter, WebSocket, WebSocketDisconnect

from app.api.v1.websocket.streaming_handler import StreamingHandler

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/chat", tags=["chat"])

_handler = StreamingHandler()


def _generate_tokens(query: str) -> Iterable[str]:
    """Generate placeholder tokens for streaming tests."""
    if "very long" in query.lower():
        return ["token"] * 600
    if "long" in query.lower():
        return ["token"] * 200
    words = query.split()
    if words:
        return [word + " " for word in words]
    return ["token"]


@router.websocket("/stream")
async def stream_chat(websocket: WebSocket) -> None:
    """WebSocket endpoint for streaming chat tokens."""
    await _handler.connect(websocket)
    heartbeat_task = asyncio.create_task(_handler.maintain_heartbeat(websocket))

    try:
        while True:
            message = await websocket.receive_text()
            query = _extract_query(message)
            if not query:
                continue
            await _handler.stream_tokens(websocket, _generate_tokens(query))
    except WebSocketDisconnect:
        logger.info("WebSocket client disconnected")
    finally:
        heartbeat_task.cancel()
        await _handler.disconnect(websocket)


def _extract_query(message: str) -> str:
    """Extract query content from client message."""
    try:
        payload = json.loads(message)
    except json.JSONDecodeError:
        return message

    if isinstance(payload, dict):
        if payload.get("type") == "query":
            return str(payload.get("content", ""))
        return ""
    return message
