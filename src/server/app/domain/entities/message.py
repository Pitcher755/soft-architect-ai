"""
Message domain entity for HU-4.2.

This is a PURE domain entity with ZERO infrastructure dependencies.
"""

from dataclasses import dataclass
from datetime import datetime
from enum import Enum
from uuid import UUID


class MessageRole(str, Enum):
    """Message role enum."""

    USER = "USER"
    ASSISTANT = "ASSISTANT"
    SYSTEM = "SYSTEM"


@dataclass(frozen=True)
class Message:
    """
    Message entity (immutable).

    Validation rules:
    - content: max 30000 chars, not empty (qwen2.5-coder:3b supports up to 32K tokens)
    - role: must be valid MessageRole enum value
    """

    id: UUID
    conversation_id: UUID
    role: MessageRole
    content: str
    created_at: datetime

    def __post_init__(self):
        """Validate fields (runs after __init__)."""
        # Validate role (runtime check: type hints don't prevent callers passing raw strings)
        if not isinstance(self.role, MessageRole):  # pyright: ignore[reportUnnecessaryIsInstance]
            raise ValueError(
                f"Invalid role: {self.role}. Must be MessageRole enum (USER, ASSISTANT, SYSTEM)"
            )

        # Validate content
        if not self.content or len(self.content) == 0:
            raise ValueError("Content cannot be empty")

        if len(self.content) > 30000:
            raise ValueError(
                f"Content exceeds maximum length (30000 chars): {len(self.content)}"
            )
