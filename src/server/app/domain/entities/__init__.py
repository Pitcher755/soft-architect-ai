"""
Domain layer: Core business entities.
"""

from datetime import datetime

# `List` and `Optional` from `typing` are not required because
# we use modern annotations (PEP 585/604) like `list[...]` and
# `X | None` throughout this module.


class ChatMessage:
    """
    Represents a message in a chat session.

    Attributes:
        id: Unique message identifier
        session_id: Parent chat session ID
        role: Message role (user, assistant, system)
        content: Message content
        timestamp: When the message was created
    """

    def __init__(
        self,
        id: str,
        session_id: str,
        role: str,
        content: str,
        timestamp: datetime | None = None,
    ):
        self.id = id
        self.session_id = session_id
        self.role = role
        self.content = content
        self.timestamp = timestamp or datetime.utcnow()


class ChatSession:
    """
    Represents a chat session.

    Attributes:
        id: Unique session identifier
        title: Session title/summary
        messages: List of messages in this session
        created_at: When session was created
        updated_at: When session was last updated
    """

    def __init__(
        self,
        id: str,
        title: str,
        messages: list[ChatMessage] | None = None,
        created_at: datetime | None = None,
        updated_at: datetime | None = None,
    ):
        self.id = id
        self.title = title
        self.messages = messages or []
        self.created_at = created_at or datetime.utcnow()
        self.updated_at = updated_at or datetime.utcnow()
