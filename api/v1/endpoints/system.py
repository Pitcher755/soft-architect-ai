"""
System endpoints: health checks, status, version info.

Based on: context/40-ROADMAP/USER_STORIES_MASTER.en.json (HU-1.2)
"""

from fastapi import APIRouter, status

from core.config import settings
from domain.schemas.health import DetailedHealthResponse, HealthResponse

router = APIRouter()


@router.get(
    "/health",
    response_model=HealthResponse,
    status_code=status.HTTP_200_OK,
    summary="Basic health check",
    description="Returns basic application status and metadata",
)
def health_check() -> HealthResponse:
    """
    Verify that the backend is alive and configuration is loaded.

    Returns:
        HealthResponse: Basic health status
    """
    return HealthResponse(
        status="ok",
        app=settings.PROJECT_NAME,
        version=settings.VERSION,
        environment=settings.ENVIRONMENT,
        debug_mode=settings.DEBUG,
    )


@router.get(
    "/health/detailed",
    response_model=DetailedHealthResponse,
    status_code=status.HTTP_200_OK,
    summary="Detailed health check",
    description="Returns health status including dependent services",
)
def detailed_health_check() -> DetailedHealthResponse:
    """
    Extended health check with service dependencies.

    Returns:
        DetailedHealthResponse: Health status with services
    """
    # TODO: Implement actual service checks in HU-2.x
    services = {
        "chromadb": "unknown",  # Will be checked in HU-2.2
        "ollama": "unknown",  # Will be checked in HU-2.1
    }

    return DetailedHealthResponse(
        status="ok",
        app=settings.PROJECT_NAME,
        version=settings.VERSION,
        environment=settings.ENVIRONMENT,
        debug_mode=settings.DEBUG,
        services=services,
    )
