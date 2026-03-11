"""
Conversation repository protocol (port) for HU-4.2.

This is an INTERFACE (Protocol) - defines contract, NOT implementation.
"""

from typing import Protocol
from uuid import UUID

from app.domain.entities.conversation import Conversation
from app.domain.entities.message import Message


class ConversationRepository(Protocol):
    """
    Repository protocol for conversation persistence.

    Implementations:
    - SQLAlchemyConversationRepository (infrastructure layer)
    """

    async def create_conversation(
        self, project_id: UUID, title: str | None = None
    ) -> Conversation:
        """
        Create new conversation.

        Args:
            project_id: Associated project UUID
            title: Optional conversation title

        Returns:
            Created Conversation entity

        Raises:
            DatabaseWriteError: If creation fails
        """
        ...

    async def get_conversation(self, conversation_id: UUID) -> Conversation | None:
        """
        Get conversation by ID with all messages.

        Args:
            conversation_id: Conversation UUID

        Returns:
            Conversation entity or None if not found

        Raises:
            DatabaseReadError: If query fails
        """
        ...

    async def list_conversations(
        self, project_id: UUID | None = None, skip: int = 0, limit: int = 100
    ) -> list[Conversation]:
        """
        List conversations with pagination.

        Args:
            project_id: Filter by project (optional)
            skip: Number of records to skip
            limit: Maximum records to return

        Returns:
            List of Conversation entities

        Raises:
            DatabaseReadError: If query fails
        """
        ...

    async def add_message(self, conversation_id: UUID, message: Message) -> Message:
        """
        Add message to conversation.

        Args:
            conversation_id: Conversation UUID
            message: Message entity to add

        Returns:
            Created Message entity

        Raises:
            DatabaseWriteError: If write fails
            NotFoundError: If conversation doesn't exist
        """
        ...

    async def get_last_n_messages(
        self, conversation_id: UUID, n: int = 10
    ) -> list[Message]:
        """
        Get last N messages from conversation (context window).

        Args:
            conversation_id: Conversation UUID
            n: Number of messages to retrieve

        Returns:
            List of last N messages (chronological order)

        Raises:
            DatabaseReadError: If query fails
        """
        ...
