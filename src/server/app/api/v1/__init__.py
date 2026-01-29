"""
API v1 initialization and router setup.
"""
from fastapi import APIRouter

from .chat import router as chat_router
from .health import router as health_router
from .knowledge import router as knowledge_router

# Main router for API v1
router = APIRouter(prefix="/api/v1")

# Include all routers
router.include_router(health_router)
router.include_router(chat_router)
router.include_router(knowledge_router)
