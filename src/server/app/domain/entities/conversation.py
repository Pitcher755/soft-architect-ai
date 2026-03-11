"""
Conversation domain entity for HU-4.2.

This is a PURE domain entity with ZERO infrastructure dependencies.
"""

from dataclasses import dataclass, field
from datetime import UTC, datetime
from uuid import UUID

from app.domain.entities.message import Message


@dataclass
class Conversation:
    """
    Conversation entity (mutable to allow adding messages).

    Validation rules:
    - title: max 255 chars, optional
    - messages: list of Message entities (can be empty)
    """

    id: UUID
    project_id: UUID
    title: str | None
    messages: list[Message] = field(default_factory=list)
    created_at: datetime = field(default_factory=lambda: datetime.now(UTC))
    updated_at: datetime = field(default_factory=lambda: datetime.now(UTC))

    def __post_init__(self):
        """Validate fields."""
        # Validate title length
        if self.title is not None and len(self.title) > 255:
            raise ValueError(f"Title exceeds maximum length (255 chars): {len(self.title)}")

    def add_message(self, message: Message) -> None:
        """Add message to conversation and update timestamp."""
        self.messages.append(message)
        self.updated_at = datetime.now(UTC)

    def get_last_n_messages(self, n: int = 10) -> list[Message]:
        """
        Get last N messages (context window).

        Args:
            n: Number of messages to retrieve (default 10)

        Returns:
            List of last N messages (chronological order)
        """
        return self.messages[-n:] if len(self.messages) >= n else self.messages
