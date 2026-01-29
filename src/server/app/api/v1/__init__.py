"""
API v1 initialization and router aggregation.

This module sets up the FastAPI APIRouter for version 1 of the API
and includes all versioned endpoints. Using API versioning allows for
backward compatibility when making breaking changes in future versions.

Included Routers:
    - health: System health check endpoints (/api/v1/system/health)
    - chat: Chat/conversation endpoints (HU-3.x)
    - knowledge: Knowledge base management endpoints (HU-2.x)

Router Prefix:
    All endpoints are prefixed with /api/v1 to allow for future versions
    like /api/v2, /api/v3, etc. without breaking client code.

Example URLs:
    - GET /api/v1/system/health
    - POST /api/v1/chat/send
    - GET /api/v1/knowledge/search
"""

from fastapi import APIRouter

from .chat import router as chat_router
from .health import router as health_router
from .knowledge import router as knowledge_router

# Main router for API v1
# All endpoints are grouped under /api/v1
router = APIRouter(prefix="/api/v1")

# Include all versioned routers
# Mount health under /system to keep compatibility
# with top-level API expectations (GET /api/v1/system/health)
router.include_router(health_router, prefix="/system")
router.include_router(chat_router)
router.include_router(knowledge_router)
