"""
Health check endpoint.
"""
from fastapi import APIRouter, status
from pydantic import BaseModel

router = APIRouter(tags=["health"])


class HealthResponse(BaseModel):
    """Health check response."""

    status: str
    message: str
    version: str


@router.get(
    "/health",
    response_model=HealthResponse,
    status_code=status.HTTP_200_OK,
    summary="Health Check",
    description="Verify that the API is running and responsive",
)
async def health_check() -> HealthResponse:
    """
    Health check endpoint.

    Returns:
        HealthResponse with status OK and version info
    """
    return HealthResponse(
        status="OK",
        message="SoftArchitect AI backend is running",
        version="0.1.0",
    )
