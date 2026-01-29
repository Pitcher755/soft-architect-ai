"""
Placeholder for knowledge base endpoint.
Will be implemented in next phase.
"""

from fastapi import APIRouter

router = APIRouter(tags=["knowledge"])


@router.get("/knowledge/search")
async def search_knowledge():
    """
    Search the knowledge base.
    Implementation: Phase 2
    """
    return {"message": "Knowledge search not yet implemented"}
