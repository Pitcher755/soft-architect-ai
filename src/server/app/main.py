"""
SoftArchitect AI Backend - Main Entry Point.

This module provides the FastAPI application instance with all middleware,
event handlers, and routes configured for the RAG-based software architecture
assistant. The application follows Clean Architecture principles.

Key Components:
    - CORS middleware for local development
    - Startup/shutdown event handlers for resource initialization
    - Exception handlers for graceful error handling
    - Root endpoint for API information
    - API v1 router with all versioned endpoints

Environment Variables:
    APP_NAME: Application name (default: "SoftArchitect AI")
    APP_VERSION: Version string (default: "0.1.0")
    DEBUG: Debug mode enabled (default: False)
    LOG_LEVEL: Logging level (default: "INFO")

Local-First Privacy Notice:
    This service is designed to run locally only. All AI processing
    happens on the user's machine with no external API calls unless
    explicitly configured and authorized.
"""

import logging

from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse

from app.api.v1 import router as api_v1_router
from app.core.config import settings
from app.core.database import init_chromadb, init_sqlite

# ═══════════════════════════════════════════════════════════════
# Logging Setup
# ═══════════════════════════════════════════════════════════════
logging.basicConfig(
    level=settings.LOG_LEVEL,
    format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
)
logger = logging.getLogger(__name__)


# ═══════════════════════════════════════════════════════════════
# FastAPI App Creation
# ═══════════════════════════════════════════════════════════════
app = FastAPI(
    title=settings.APP_NAME,
    description="Local-First AI Assistant for Software Architecture",
    version=settings.APP_VERSION,
    debug=settings.DEBUG,
)


# ═══════════════════════════════════════════════════════════════
# CORS Middleware Configuration
# ═══════════════════════════════════════════════════════════════
app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:*",
        "http://127.0.0.1:*",
    ],  # Local development only
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# ═══════════════════════════════════════════════════════════════
# Startup & Shutdown Events
# ═══════════════════════════════════════════════════════════════
@app.on_event("startup")
async def startup_event():
    """
    Initialize resources on application startup.

    This event handler runs once when the application starts and is responsible
    for:
    - Initializing database connections (ChromaDB, SQLite)
    - Logging startup information
    - Verifying LLM provider configuration

    Raises:
        Any exceptions during initialization will be logged and the app
        will still start (graceful degradation).
    """
    logger.info(f"Starting {settings.APP_NAME} v{settings.APP_VERSION}")

    # Initialize databases
    chromadb_path = init_chromadb()
    logger.info(f"ChromaDB initialized at {chromadb_path}")

    sqlite_url = init_sqlite()
    logger.info(f"SQLite initialized at {sqlite_url}")

    # LLM Provider info
    logger.info(f"LLM Provider: {settings.LLM_PROVIDER}")
    if settings.LLM_PROVIDER == "local":
        logger.info(f"Ollama URL: {settings.OLLAMA_BASE_URL}")
    elif settings.LLM_PROVIDER == "cloud":
        logger.info("Groq Cloud provider configured")


@app.on_event("shutdown")
async def shutdown_event():
    """
    Clean up resources on application shutdown.

    This event handler runs once when the application is shutting down
    and is responsible for:
    - Closing database connections
    - Flushing logs
    - Cleaning up temporary resources
    """
    logger.info(f"Shutting down {settings.APP_NAME}")


# ═══════════════════════════════════════════════════════════════
# Error Handlers
# ═══════════════════════════════════════════════════════════════
@app.exception_handler(ValueError)
async def value_error_handler(request: Request, exc: ValueError):
    """
    Handle validation errors gracefully.

    Converts ValueError exceptions into 400 Bad Request responses
    with the error message exposed to the client.

    Args:
        request: FastAPI request object
        exc: The ValueError exception

    Returns:
        JSONResponse with 400 status code and error detail
    """
    return JSONResponse(
        status_code=400,
        content={"detail": str(exc)},
    )


@app.exception_handler(Exception)
async def general_exception_handler(request: Request, exc: Exception):
    """
    Handle unexpected errors without exposing stack traces.

    Catches all unhandled exceptions and returns a generic 500 error
    without exposing sensitive information (stack traces). Exceptions
    are logged with full details for debugging.

    Args:
        request: FastAPI request object
        exc: The unhandled exception

    Returns:
        JSONResponse with 500 status code and generic error message
    """
    logger.error(f"Unexpected error: {exc}", exc_info=True)
    return JSONResponse(
        status_code=500,
        content={"detail": "Internal server error"},
    )


# ═══════════════════════════════════════════════════════════════
# Root Route
# ═══════════════════════════════════════════════════════════════
@app.get("/", tags=["root"])
async def root():
    """
    Get API root information.

    Returns general information about the API including version,
    status, and links to documentation.

    Returns:
        dict: Contains app name, version, status, docs URL, and API v1 URL
    """
    return {
        "name": settings.APP_NAME,
        "version": settings.APP_VERSION,
        "status": "running",
        "docs": "/docs",
        "api_v1": settings.API_V1_STR,
    }


# ═══════════════════════════════════════════════════════════════
# API Routes
# ═══════════════════════════════════════════════════════════════
app.include_router(api_v1_router)


# ═══════════════════════════════════════════════════════════════
# Development Server
# ═══════════════════════════════════════════════════════════════
if __name__ == "__main__":
    import uvicorn

    uvicorn.run(
        "app.main:app",
        # Bind to 0.0.0.0 so the container/network interface
        # accepts external connections. This is intentional for
        # Docker deployments where the service must be reachable
        # from the host and other containers.
        host="0.0.0.0",  # noqa: S104  (intentional for Docker exposure)
        port=8000,
        reload=settings.DEBUG,
        log_level=settings.LOG_LEVEL.lower(),
    )
