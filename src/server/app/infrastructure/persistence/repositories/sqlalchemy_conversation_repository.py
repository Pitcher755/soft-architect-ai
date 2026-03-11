"""
SQLAlchemy implementation of ConversationRepository.

Security:
- All queries use ORM (parameterized, SQL injection safe)
- Foreign key constraints enforced by database
"""

from datetime import UTC, datetime
from uuid import UUID

from sqlalchemy import desc, select
from sqlalchemy.ext.asyncio import AsyncSession

from app.domain.entities.conversation import Conversation
from app.domain.entities.message import Message, MessageRole
from app.infrastructure.persistence.models.conversation_model import (
    ConversationModel,
)
from app.infrastructure.persistence.models.message_model import MessageModel


class SQLAlchemyConversationRepository:
    """
    SQLAlchemy adapter for ConversationRepository protocol.

    Translates between domain entities and SQLAlchemy models.
    """

    def __init__(self, session: AsyncSession):
        """Initialize with async session."""
        self.session = session

    async def create_conversation(self, project_id: UUID, title: str | None = None) -> Conversation:
        """Create new conversation."""
        # Create SQLAlchemy model
        model = ConversationModel(project_id=project_id, title=title)

        self.session.add(model)
        await self.session.commit()
        await self.session.refresh(model)

        # Convert to domain entity
        return self._model_to_entity(model)

    async def get_conversation(self, conversation_id: UUID) -> Conversation | None:
        """Get conversation by ID with messages."""
        stmt = select(ConversationModel).where(ConversationModel.id == conversation_id)
        result = await self.session.execute(stmt)
        model = result.scalar_one_or_none()

        if model is None:
            return None

        return self._model_to_entity(model)

    async def list_conversations(
        self, project_id: UUID | None = None, skip: int = 0, limit: int = 100
    ) -> list[Conversation]:
        """List conversations with pagination."""
        stmt = select(ConversationModel).order_by(desc(ConversationModel.created_at))

        if project_id is not None:
            stmt = stmt.where(ConversationModel.project_id == project_id)

        stmt = stmt.offset(skip).limit(limit)

        result = await self.session.execute(stmt)
        models = result.scalars().all()

        return [self._model_to_entity(model) for model in models]

    async def add_message(self, conversation_id: UUID, message: Message) -> Message:
        """Add message to conversation."""
        # Create SQLAlchemy model
        model = MessageModel(
            id=message.id,
            conversation_id=conversation_id,
            role=message.role.value,
            content=message.content,
            created_at=message.created_at,
        )

        self.session.add(model)
        await self.session.commit()
        await self.session.refresh(model)

        # Update conversation timestamp
        stmt = select(ConversationModel).where(ConversationModel.id == conversation_id)
        result = await self.session.execute(stmt)
        conv_model = result.scalar_one()
        conv_model.updated_at = datetime.now(UTC)  # type: ignore[assignment]  # SQLAlchemy runtime type
        await self.session.commit()

        return self._message_model_to_entity(model)

    async def get_last_n_messages(self, conversation_id: UUID, n: int = 10) -> list[Message]:
        """Get last N messages from conversation."""
        stmt = (
            select(MessageModel)
            .where(MessageModel.conversation_id == conversation_id)
            .order_by(desc(MessageModel.created_at))
            .limit(n)
        )

        result = await self.session.execute(stmt)
        models = result.scalars().all()

        # Reverse to chronological order (oldest first)
        messages = [self._message_model_to_entity(model) for model in reversed(models)]

        return messages

    def _model_to_entity(self, model: ConversationModel) -> Conversation:
        """Convert SQLAlchemy model to domain entity."""
        messages = [self._message_model_to_entity(msg) for msg in model.messages]

        return Conversation(
            id=model.id,  # type: ignore[arg-type]  # SQLAlchemy runtime type
            project_id=model.project_id,  # type: ignore[arg-type]
            title=model.title,  # type: ignore[arg-type]
            messages=messages,
            created_at=model.created_at,  # type: ignore[arg-type]
            updated_at=model.updated_at,  # type: ignore[arg-type]
        )

    def _message_model_to_entity(self, model: MessageModel) -> Message:
        """Convert SQLAlchemy MessageModel to domain Message entity."""
        return Message(
            id=model.id,  # type: ignore[arg-type]  # SQLAlchemy runtime type
            conversation_id=model.conversation_id,  # type: ignore[arg-type]
            role=MessageRole(model.role),  # type: ignore[arg-type]
            content=model.content,  # type: ignore[arg-type]
            created_at=model.created_at,  # type: ignore[arg-type]
        )
