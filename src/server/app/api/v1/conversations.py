"""
Conversation API endpoints for HU-4.2.

Endpoints:
- POST /api/v1/conversations (create)
- GET /api/v1/conversations/{id} (retrieve)
- GET /api/v1/conversations (list)
"""

from uuid import UUID

from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from src.server.app.domain.schemas.conversation import (
    ConversationCreate,
    ConversationList,
    ConversationResponse,
)
from src.server.app.infrastructure.persistence.database import get_db_session
from src.server.app.infrastructure.persistence.repositories.sqlalchemy_conversation_repository import (
    SQLAlchemyConversationRepository,
)
from src.server.app.services.conversation.conversation_service import (
    ConversationService,
)

router = APIRouter(prefix="/conversations", tags=["Conversations"])


def get_conversation_service(
    db: AsyncSession = Depends(get_db_session),
) -> ConversationService:
    """Dependency injection for conversation service."""
    repository = SQLAlchemyConversationRepository(db)
    return ConversationService(repository)


@router.post(
    "/", response_model=ConversationResponse, status_code=status.HTTP_201_CREATED
)
async def create_conversation(
    payload: ConversationCreate,
    service: ConversationService = Depends(get_conversation_service),
):
    """Create new conversation."""
    conversation = await service.create_conversation(
        project_id=payload.project_id, title=payload.title
    )
    return conversation


@router.get("/{conversation_id}", response_model=ConversationResponse)
async def get_conversation(
    conversation_id: UUID,
    service: ConversationService = Depends(get_conversation_service),
):
    """Get conversation by ID."""
    conversation = await service.get_conversation(conversation_id)

    if conversation is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Conversation {conversation_id} not found",
        )

    return conversation


@router.get("/", response_model=ConversationList)
async def list_conversations(
    project_id: UUID | None = None,
    skip: int = 0,
    limit: int = 100,
    service: ConversationService = Depends(get_conversation_service),
):
    """List conversations with pagination."""
    conversations = await service.list_conversations(
        project_id=project_id, skip=skip, limit=limit
    )

    return ConversationList(
        conversations=[ConversationResponse.model_validate(c) for c in conversations],
        total=len(conversations),
        skip=skip,
        limit=limit,
    )
