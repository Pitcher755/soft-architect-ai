"""
SQLAlchemy model for conversations table.

Security:
- Foreign keys enforced
- Cascading deletes (delete conversation → delete messages)
"""

import uuid
from datetime import UTC, datetime

from sqlalchemy import Column, DateTime, Index, String
from sqlalchemy.dialects.postgresql import UUID as PG_UUID
from sqlalchemy.orm import relationship

from app.infrastructure.persistence.database import Base


class ConversationModel(Base):
    """SQLAlchemy model for conversations table."""

    __tablename__ = "conversations"

    id = Column(
        PG_UUID(as_uuid=True), primary_key=True, default=uuid.uuid4, nullable=False
    )

    project_id = Column(PG_UUID(as_uuid=True), nullable=False)

    title = Column(String(255), nullable=True)

    created_at = Column(
        DateTime(timezone=True), nullable=False, default=lambda: datetime.now(UTC)
    )

    updated_at = Column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(UTC),
        onupdate=lambda: datetime.now(UTC),
    )

    # Relationship: one conversation has many messages
    messages = relationship(
        "MessageModel",
        back_populates="conversation",
        cascade="all, delete-orphan",  # Delete messages when conversation deleted
        lazy="selectin",  # Load messages eagerly
    )

    # Indexes
    __table_args__ = (
        Index("idx_conversations_project_id", "project_id"),
        Index("idx_conversations_created_at", "created_at"),
    )
