"""Tests for domain entities in app.domain.entities."""

from datetime import datetime

from app.domain.entities import ChatMessage, ChatSession


def test_chat_message_defaults_timestamp_when_missing() -> None:
    msg = ChatMessage(
        id="m1",
        session_id="s1",
        role="user",
        content="hola",
    )

    assert msg.id == "m1"
    assert msg.session_id == "s1"
    assert msg.role == "user"
    assert msg.content == "hola"
    assert isinstance(msg.timestamp, datetime)


def test_chat_message_respects_provided_timestamp() -> None:
    ts = datetime(2026, 1, 1, 10, 0, 0)
    msg = ChatMessage(
        id="m2",
        session_id="s2",
        role="assistant",
        content="ok",
        timestamp=ts,
    )

    assert msg.timestamp == ts


def test_chat_session_defaults_for_messages_and_timestamps() -> None:
    session = ChatSession(id="s1", title="Sesión")

    assert session.id == "s1"
    assert session.title == "Sesión"
    assert session.messages == []
    assert isinstance(session.created_at, datetime)
    assert isinstance(session.updated_at, datetime)


def test_chat_session_respects_provided_values() -> None:
    ts_created = datetime(2026, 2, 1, 9, 0, 0)
    ts_updated = datetime(2026, 2, 1, 10, 0, 0)
    msg = ChatMessage(
        id="m3",
        session_id="s3",
        role="system",
        content="init",
        timestamp=ts_created,
    )

    session = ChatSession(
        id="s3",
        title="Con mensajes",
        messages=[msg],
        created_at=ts_created,
        updated_at=ts_updated,
    )

    assert session.messages == [msg]
    assert session.created_at == ts_created
    assert session.updated_at == ts_updated
