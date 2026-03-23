"""Unit tests for stream_protocol message types.

Covers:
- QueryMessage.__init__ and to_dict (lines 28-30, 33-35)
- PingMessage.__init__ (line 61)
- PongMessage.__init__ (line 69)
- DoneMessage.to_dict (lines 100-102)
- ErrorMessage.to_dict (lines 105-107)
"""

from app.domain.streaming.stream_protocol import (
    DoneMessage,
    ErrorMessage,
    PingMessage,
    PongMessage,
    QueryMessage,
)


class TestQueryMessage:
    """Tests for QueryMessage."""

    def test_init_sets_attributes(self):
        """QueryMessage.__init__ sets content, session_id and type."""
        msg = QueryMessage(content="What is clean code?", session_id="sess-1")

        assert msg.content == "What is clean code?"
        assert msg.session_id == "sess-1"
        assert msg.type == "query"

    def test_to_dict_returns_full_payload(self):
        """to_dict includes type, content and session_id."""
        msg = QueryMessage(content="hello", session_id="s42")
        result = msg.to_dict()

        assert result == {
            "type": "query",
            "content": "hello",
            "session_id": "s42",
        }


class TestPingPongMessages:
    """Tests for heartbeat messages."""

    def test_ping_message_init(self):
        """PingMessage sets type to 'ping'."""
        msg = PingMessage()
        assert msg.type == "ping"

    def test_pong_message_init(self):
        """PongMessage sets type to 'pong'."""
        msg = PongMessage()
        assert msg.type == "pong"


class TestDoneMessage:
    """Tests for DoneMessage."""

    def test_to_dict_returns_tokens_and_latency(self):
        """DoneMessage.to_dict includes total_tokens and latency_ms."""
        msg = DoneMessage(total_tokens=42, latency_ms=123.5)
        result = msg.to_dict()

        assert result == {
            "type": "done",
            "total_tokens": 42,
            "latency_ms": 123.5,
        }


class TestErrorMessage:
    """Tests for ErrorMessage."""

    def test_to_dict_returns_code_and_message(self):
        """ErrorMessage.to_dict includes code and message."""
        msg = ErrorMessage(code="LLM_001", message="Connection refused")
        result = msg.to_dict()

        assert result == {
            "type": "error",
            "code": "LLM_001",
            "message": "Connection refused",
        }
