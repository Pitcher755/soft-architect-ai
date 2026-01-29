"""
FastAPI application entrypoint.

Based on:
- context/30-ARCHITECTURE/TECH_STACK_DETAILS.en.md
- context/20-REQUIREMENTS_AND_SPEC/SECURITY_AND_PRIVACY_RULES.en.md
"""

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import RedirectResponse

from api.v1.router import api_router
from core.config import settings

# Create FastAPI app instance
app = FastAPI(
    title=settings.PROJECT_NAME,
    description=settings.DESCRIPTION,
    version=settings.VERSION,
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    docs_url="/docs",
    redoc_url="/redoc",
    debug=settings.DEBUG,
)

# Configure CORS (CRITICAL for Flutter/Web client communication)
if settings.BACKEND_CORS_ORIGINS:
    app.add_middleware(
        CORSMiddleware,
        allow_origins=[str(origin) for origin in settings.BACKEND_CORS_ORIGINS],
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

# Include API v1 routes
app.include_router(api_router, prefix=settings.API_V1_STR)


@app.get("/", include_in_schema=False)
def root() -> RedirectResponse:
    """
    Root endpoint redirects to API documentation.

    Returns:
        RedirectResponse: Redirect to /docs
    """
    return RedirectResponse(url="/docs")


@app.get("/ping", include_in_schema=False)
def ping() -> dict[str, str]:
    """
    Minimal ping endpoint for load balancers/health checkers.

    Returns:
        dict: Simple pong response
    """
    return {"ping": "pong"}
