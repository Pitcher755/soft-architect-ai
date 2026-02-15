"""
Pydantic schemas for conversation API endpoints (HU-4.2).

Request/Response models:
- ConversationCreate (request)
- ConversationResponse (response)
- ConversationList (response with pagination)
"""

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field

from app.domain.entities.message import MessageRole


class MessageResponse(BaseModel):
    """Message response schema."""

    model_config = ConfigDict(from_attributes=True)

    id: UUID
    conversation_id: UUID
    role: MessageRole
    content: str
    created_at: datetime


class ConversationCreate(BaseModel):
    """Request schema for creating conversation."""

    project_id: UUID = Field(..., description="Project UUID")
    title: str | None = Field(None, max_length=255, description="Conversation title")


class ConversationResponse(BaseModel):
    """Response schema for conversation."""

    model_config = ConfigDict(from_attributes=True)

    id: UUID
    project_id: UUID
    title: str | None
    messages: list[MessageResponse] = []
    created_at: datetime
    updated_at: datetime


class ConversationList(BaseModel):
    """Response schema for conversation list with pagination."""

    conversations: list[ConversationResponse]
    total: int
    skip: int = 0
    limit: int = 100
