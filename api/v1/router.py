"""
API v1 router aggregator.

Collects all endpoint routers and exposes them under /api/v1.
"""

from fastapi import APIRouter

from api.v1.endpoints import system

api_router = APIRouter()

# Include all endpoint routers
api_router.include_router(
    system.router,
    prefix="/system",
    tags=["system"],
)

# Future routers will be added here:
# api_router.include_router(rag.router, prefix="/rag", tags=["rag"])
# api_router.include_router(chat.router, prefix="/chat", tags=["chat"])
