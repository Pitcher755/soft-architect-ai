"""
SoftArchitect AI Backend - Main Entry Point

FastAPI application for RAG-based software architecture assistant.
Local-first, privacy-preserving AI service.
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
    """Initialize resources on application startup."""
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
    """Cleanup resources on application shutdown."""
    logger.info(f"Shutting down {settings.APP_NAME}")


# ═══════════════════════════════════════════════════════════════
# Error Handlers
# ═══════════════════════════════════════════════════════════════
@app.exception_handler(ValueError)
async def value_error_handler(request: Request, exc: ValueError):
    """Handle validation errors gracefully."""
    return JSONResponse(
        status_code=400,
        content={"detail": str(exc)},
    )


@app.exception_handler(Exception)
async def general_exception_handler(request: Request, exc: Exception):
    """Handle unexpected errors without exposing stack traces."""
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
    """API root endpoint with general information."""
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
        # Bind to 0.0.0.0 so the container/network interface
        # accepts external connections. This is intentional for
        # Docker deployments where the service must be reachable
        # from the host and other containers.
        host="0.0.0.0",  # noqa: S104  (intentional for Docker exposure)
        port=8000,
        reload=settings.DEBUG,
        log_level=settings.LOG_LEVEL.lower(),
    )
