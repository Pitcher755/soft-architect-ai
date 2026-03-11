"""Streaming protocol message definitions and helpers."""

from __future__ import annotations

from dataclasses import dataclass
from typing import Any


@dataclass(frozen=True)
class StreamMessage:
    """Base stream message."""

    type: str

    def to_dict(self) -> dict[str, Any]:
        """Serialize message to dict."""
        return {"type": self.type}


@dataclass(frozen=True)
class QueryMessage(StreamMessage):
    """Client query message."""

    content: str
    session_id: str

    def __init__(self, content: str, session_id: str) -> None:
        super().__init__(type="query")
        object.__setattr__(self, "content", content)
        object.__setattr__(self, "session_id", session_id)

    def to_dict(self) -> dict[str, Any]:
        payload = super().to_dict()
        payload.update({"content": self.content, "session_id": self.session_id})
        return payload


@dataclass(frozen=True)
class TokenMessage(StreamMessage):
    """Server token message."""

    content: str
    timestamp: str

    def __init__(self, content: str, timestamp: str) -> None:
        super().__init__(type="token")
        object.__setattr__(self, "content", content)
        object.__setattr__(self, "timestamp", timestamp)

    def to_dict(self) -> dict[str, Any]:
        payload = super().to_dict()
        payload.update({"content": self.content, "timestamp": self.timestamp})
        return payload


@dataclass(frozen=True)
class PingMessage(StreamMessage):
    """Heartbeat ping message."""

    def __init__(self) -> None:
        super().__init__(type="ping")


@dataclass(frozen=True)
class PongMessage(StreamMessage):
    """Heartbeat pong message."""

    def __init__(self) -> None:
        super().__init__(type="pong")


@dataclass(frozen=True)
class DoneMessage(StreamMessage):
    """Completion message."""

    total_tokens: int
    latency_ms: float

    def __init__(self, total_tokens: int, latency_ms: float) -> None:
        super().__init__(type="done")
        object.__setattr__(self, "total_tokens", total_tokens)
        object.__setattr__(self, "latency_ms", latency_ms)

    def to_dict(self) -> dict[str, Any]:
        payload = super().to_dict()
        payload.update({"total_tokens": self.total_tokens, "latency_ms": self.latency_ms})
        return payload


@dataclass(frozen=True)
class ErrorMessage(StreamMessage):
    """Error message."""

    code: str
    message: str

    def __init__(self, code: str, message: str) -> None:
        super().__init__(type="error")
        object.__setattr__(self, "code", code)
        object.__setattr__(self, "message", message)

    def to_dict(self) -> dict[str, Any]:
        payload = super().to_dict()
        payload.update({"code": self.code, "message": self.message})
        return payload
