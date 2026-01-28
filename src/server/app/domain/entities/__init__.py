"""
Domain layer: Core business entities.
"""
from typing import List, Optional
from datetime import datetime


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
        timestamp: Optional[datetime] = None,
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
        messages: Optional[List[ChatMessage]] = None,
        created_at: Optional[datetime] = None,
        updated_at: Optional[datetime] = None,
    ):
        self.id = id
        self.title = title
        self.messages = messages or []
        self.created_at = created_at or datetime.utcnow()
        self.updated_at = updated_at or datetime.utcnow()
