"""
SQLAlchemy model for messages table.

Security:
- Foreign key constraint enforced (conversation must exist)
- Role enum validation
"""

import uuid
from datetime import UTC, datetime

from sqlalchemy import (
    CheckConstraint,
    Column,
    DateTime,
    ForeignKey,
    Index,
    String,
    Text,
)
from sqlalchemy.dialects.postgresql import UUID as PG_UUID
from sqlalchemy.orm import relationship
from src.server.app.infrastructure.persistence.database import Base


class MessageModel(Base):
    """SQLAlchemy model for messages table."""

    __tablename__ = "messages"

    id = Column(
        PG_UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, nullable=False
    )

    conversation_id = Column(
        PG_UUID(as_uuid=True),
        ForeignKey("conversations.id", ondelete="CASCADE"),
        nullable=False,
    )

    role = Column(String(20), nullable=False)

    content = Column(Text, nullable=False)

    created_at = Column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(UTC)
    )

    # Relationship: many messages belong to one conversation
    conversation = relationship("ConversationModel", back_populates="messages")

    # Constraints
    __table_args__ = (
        CheckConstraint(
            "role IN ('USER', 'ASSISTANT', 'SYSTEM')", name="check_role_enum"
        ),
        Index("idx_messages_conversation_id", "conversation_id"),
        Index("idx_messages_created_at", "created_at"),
    )
