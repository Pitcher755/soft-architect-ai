"""
Health check schemas.

These are the DTOs (Data Transfer Objects) for API responses.
"""

from pydantic import BaseModel, Field


class HealthResponse(BaseModel):
    """Response model for health check endpoint."""

    status: str = Field(..., description="Service status", examples=["ok", "degraded"])
    app: str = Field(..., description="Application name")
    version: str = Field(..., description="API version")
    environment: str = Field(..., description="Environment name")
    debug_mode: bool = Field(..., description="Debug mode flag")


class DetailedHealthResponse(HealthResponse):
    """Extended health response with service dependencies."""

    services: dict[str, str] = Field(..., description="Status of dependent services")
