"""
Conversation service for HU-4.2.

Business logic:
- Context window management (last 10 messages)
- Conversation lifecycle
"""

from uuid import UUID

from app.domain.entities.conversation import Conversation
from app.domain.entities.message import Message
from app.domain.repositories.conversation_repository import (
    ConversationRepository,
)


class ConversationService:
    """
    Service layer for conversation management.

    Dependencies:
    - ConversationRepository (protocol)
    """

    def __init__(self, repository: ConversationRepository):
        """Initialize with repository."""
        self.repository = repository

    async def create_conversation(
        self, project_id: UUID, title: str | None = None
    ) -> Conversation:
        """Create new conversation."""
        return await self.repository.create_conversation(project_id, title)

    async def get_conversation(self, conversation_id: UUID) -> Conversation | None:
        """Get conversation by ID."""
        return await self.repository.get_conversation(conversation_id)

    async def list_conversations(
        self,
        project_id: UUID | None = None,
        skip: int = 0,
        limit: int = 100,
    ) -> list[Conversation]:
        """List conversations with pagination."""
        return await self.repository.list_conversations(project_id, skip, limit)

    async def add_message(self, conversation_id: UUID, message: Message) -> Message:
        """Add message to conversation."""
        return await self.repository.add_message(conversation_id, message)

    async def get_context_window(
        self, conversation_id: UUID, window_size: int = 10
    ) -> list[Message]:
        """
        Get last N messages for LLM context window.

        Args:
            conversation_id: Conversation UUID
            window_size: Number of messages (default 10)

        Returns:
            List of last N messages (chronological order)
        """
        return await self.repository.get_last_n_messages(conversation_id, window_size)
