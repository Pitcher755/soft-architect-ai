"""
Health check endpoints for API liveness and readiness probes.

This module provides endpoints to monitor the health and status of the
SoftArchitect AI backend. These endpoints are used for:
    - Docker container health checks
    - Kubernetes liveness/readiness probes
    - Load balancer health monitoring
    - Client connection verification

Endpoints:
    - GET /api/v1/system/health: Simple health check
    - GET /api/v1/system/health/detailed: Extended health with service status

Response Models:
    HealthResponse: Basic health status with version information
"""

from fastapi import APIRouter, status
from pydantic import BaseModel

router = APIRouter(tags=["health"])


class HealthResponse(BaseModel):
    """
    Health check response model.

    Represents the basic health status of the API with version information.
    Used for simple liveness probes and quick health verifications.

    Attributes:
        status: Health status indicator ("OK", "DEGRADED", "ERROR")
        message: Human-readable health status message
        version: Application version string
    """

    status: str
    message: str
    version: str


@router.get(
    "/health",
    response_model=HealthResponse,
    status_code=status.HTTP_200_OK,
    summary="Health Check",
    description="Verify that the API is running and responsive. "
    "Used for Docker and Kubernetes liveness probes.",
)
async def health_check() -> HealthResponse:
    """
    Simple health check endpoint for liveness verification.

    This endpoint performs a quick check to verify that the API is running
    and can respond to requests. It's lightweight and fast, suitable for
    frequent polling by load balancers and orchestration systems.

    Returns:
        HealthResponse: Status OK with version information

    HTTP Status:
        200 OK: API is healthy and running

    Use Cases:
        - Docker HEALTHCHECK instruction
        - Kubernetes liveness probe
        - Load balancer health monitoring
        - Client connection verification

    Example Response:
        {
            "status": "OK",
            "message": "SoftArchitect AI backend is running",
            "version": "0.1.0"
        }
    """
    return HealthResponse(
        status="OK",
        message="SoftArchitect AI backend is running",
        version="0.1.0",
    )
