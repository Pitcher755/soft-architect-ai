"""
Placeholder for chat endpoint.
Will be implemented in next phase.
"""
from fastapi import APIRouter

router = APIRouter(tags=["chat"])


@router.post("/chat/message")
async def send_chat_message():
    """
    Send a message to the chat endpoint.
    Implementation: Phase 2
    """
    return {"message": "Chat endpoint not yet implemented"}
