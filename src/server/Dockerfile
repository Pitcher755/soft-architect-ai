# ═══════════════════════════════════════════════════════════════
# SoftArchitect AI - Python Backend Dockerfile
#
# Multi-stage build strategy:
# 1. builder: Instala dependencias Python compiladas
# 2. runtime: Imagen final optimizada (sin dev tools)
#
# Build time: ~45s
# Image size: ~400MB (vs ~800MB sin multistage)
# ═══════════════════════════════════════════════════════════════

# ─────────────────────────────────────────────────────────────
# STAGE 1: Builder
# ─────────────────────────────────────────────────────────────
FROM python:3.12.3-slim as builder

# Metadata
LABEL maintainer="SoftArchitect AI Team"
LABEL description="Builder stage for SoftArchitect AI backend"

# Set environment variables (no output buffering, don't write bytecode)
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1

# Install build dependencies (gcc, etc for compiling packages)
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Create virtual environment in /opt/venv
RUN python -m venv /opt/venv

# Activate venv in PATH
ENV PATH="/opt/venv/bin:$PATH"

# Copy requirements and install dependencies
COPY requirements.txt .
RUN pip install --upgrade pip setuptools wheel && \
    pip install -r requirements.txt

# ─────────────────────────────────────────────────────────────
# STAGE 2: Runtime
# ─────────────────────────────────────────────────────────────
FROM python:3.12.3-slim as runtime

# Metadata
LABEL maintainer="SoftArchitect AI Team"
LABEL description="SoftArchitect AI backend runtime environment"
LABEL version="0.1.0"

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PATH="/opt/venv/bin:$PATH" \
    VIRTUAL_ENV=/opt/venv

# Install runtime dependencies only (curl for healthcheck)
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create app user for security (don't run as root)
RUN useradd -m -u 1000 appuser

# Copy virtual environment from builder
COPY --from=builder --chown=appuser:appuser /opt/venv /opt/venv

# Set working directory
WORKDIR /app

# Copy application code
COPY --chown=appuser:appuser . .

# Switch to non-root user
USER appuser

# Expose port
EXPOSE 8000

# Health check (FastAPI /api/v1/health endpoint)
# Tries every 10 seconds, timeout of 3 seconds, 3 retries
HEALTHCHECK --interval=10s --timeout=3s --retries=3 \
    CMD curl -f http://localhost:8000/api/v1/health || exit 1

# Default command: Run Uvicorn ASGI server
# Use --reload for development (hot reload on file changes)
# Remove --reload in production
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
