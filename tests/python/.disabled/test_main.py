"""
Unit tests for app/main.py - FastAPI application startup and configuration.

Tests cover:
- FastAPI app creation and configuration
- CORS middleware setup
- Startup/shutdown event handlers
- Exception handlers
- Root endpoint
- API router inclusion
"""

from unittest.mock import MagicMock, patch

import pytest
from fastapi import Request
from fastapi.responses import JSONResponse
from fastapi.testclient import TestClient

from app.core.config import settings
from app.main import (
    app,
    general_exception_handler,
    root,
    shutdown_event,
    startup_event,
    value_error_handler,
)


class TestFastAPIApp:
    """Test FastAPI application creation and configuration."""

    def test_app_creation(self):
        """Test that FastAPI app is created with correct configuration."""

        assert app.title == settings.APP_NAME
        assert app.description == "Local-First AI Assistant for Software Architecture"
        assert app.version == settings.APP_VERSION
        assert app.debug == settings.DEBUG

    def test_cors_middleware_configured(self):
        """Test that CORS middleware is properly configured for local development."""
        cors_middleware = None
        for middleware in app.user_middleware:
            if hasattr(middleware, "cls") and "CORSMiddleware" in str(middleware.cls):
                cors_middleware = middleware
                break

        # CORS middleware should be configured
        assert cors_middleware is not None

    def test_api_router_included(self):
        """Test that API v1 router is included in the app."""
        # Check that routes from the API router are present
        routes = [
            getattr(route, "path", "") for route in app.routes if hasattr(route, "path")
        ]

        # Should have root route and API routes
        assert "/" in routes
        assert any("/health" in route for route in routes)


class TestStartupShutdownEvents:
    """Test application startup and shutdown event handlers."""

    @pytest.mark.asyncio
    async def test_startup_event_success(self, caplog):
        """Test successful startup event execution."""
        with (
            patch("app.main.init_chromadb") as mock_chroma,
            patch("app.main.init_sqlite") as mock_sqlite,
            patch("app.main.settings") as mock_settings,
        ):
            # Configure mocks
            mock_chroma.return_value = "/path/to/chroma"
            mock_sqlite.return_value = "sqlite:///test.db"
            mock_settings.APP_NAME = "TestApp"
            mock_settings.APP_VERSION = "1.0.0"
            mock_settings.LLM_PROVIDER = "local"
            mock_settings.OLLAMA_BASE_URL = "http://localhost:11434"

            # Execute startup
            await startup_event()

            # Verify database initializations were called
            mock_chroma.assert_called_once()
            mock_sqlite.assert_called_once()

            # Check log messages
            assert "Starting TestApp v1.0.0" in caplog.text
            assert "ChromaDB initialized at /path/to/chroma" in caplog.text
            assert "SQLite initialized at sqlite:///test.db" in caplog.text
            assert "LLM Provider: local" in caplog.text
            assert "Ollama URL: http://localhost:11434" in caplog.text

    @pytest.mark.asyncio
    async def test_startup_event_cloud_provider(self, caplog):
        """Test startup event with cloud LLM provider."""
        with (
            patch("app.main.init_chromadb") as mock_chroma,
            patch("app.main.init_sqlite") as mock_sqlite,
            patch("app.main.settings") as mock_settings,
        ):
            mock_chroma.return_value = "/path/to/chroma"
            mock_sqlite.return_value = "sqlite:///test.db"
            mock_settings.APP_NAME = "TestApp"
            mock_settings.APP_VERSION = "1.0.0"
            mock_settings.LLM_PROVIDER = "cloud"

            await startup_event()

            assert "LLM Provider: cloud" in caplog.text
            assert "Groq Cloud provider configured" in caplog.text

    @pytest.mark.asyncio
    async def test_startup_event_database_failure(self, caplog):
        """Test startup event handles database initialization failures."""
        with (
            patch("app.main.init_chromadb", side_effect=Exception("ChromaDB failed")),
            patch("app.main.init_sqlite") as mock_sqlite,
            patch("app.main.settings") as mock_settings,
        ):
            mock_sqlite.return_value = "sqlite:///test.db"
            mock_settings.APP_NAME = "TestApp"
            mock_settings.APP_VERSION = "1.0.0"
            mock_settings.LLM_PROVIDER = "local"

            # Should raise exception when ChromaDB fails
            with pytest.raises(Exception, match="ChromaDB failed"):
                await startup_event()

    @pytest.mark.asyncio
    async def test_shutdown_event(self, caplog):
        """Test shutdown event logging."""
        with patch("app.main.settings") as mock_settings:
            mock_settings.APP_NAME = "TestApp"

            await shutdown_event()

            assert "Shutting down TestApp" in caplog.text


class TestExceptionHandlers:
    """Test custom exception handlers."""

    @pytest.mark.asyncio
    async def test_value_error_handler(self):
        """Test ValueError exception handler returns 400 status."""
        request = MagicMock(spec=Request)
        exc = ValueError("Invalid input data")

        response = await value_error_handler(request, exc)

        assert isinstance(response, JSONResponse)
        assert response.status_code == 400
        assert response.body == b'{"detail":"Invalid input data"}'

    @pytest.mark.asyncio
    async def test_general_exception_handler(self, caplog):
        """Test general exception handler returns 500 and logs error."""
        request = MagicMock(spec=Request)
        exc = RuntimeError("Something went wrong")

        response = await general_exception_handler(request, exc)

        assert isinstance(response, JSONResponse)
        assert response.status_code == 500
        assert response.body == b'{"detail":"Internal server error"}'

        # Check that full error was logged
        assert "Unexpected error: Something went wrong" in caplog.text


class TestRootEndpoint:
    """Test root endpoint functionality."""

    @pytest.mark.asyncio
    async def test_root_endpoint(self):
        """Test root endpoint returns correct information."""
        with patch("app.main.settings") as mock_settings:
            mock_settings.APP_NAME = "TestApp"
            mock_settings.APP_VERSION = "2.0.0"
            mock_settings.API_V1_STR = "/api/v1"

            response = await root()

            expected = {
                "name": "TestApp",
                "version": "2.0.0",
                "status": "running",
                "docs": "/docs",
                "api_v1": "/api/v1",
            }

            assert response == expected

    def test_root_endpoint_with_test_client(self):
        """Test root endpoint via FastAPI TestClient."""
        with TestClient(app) as client:
            response = client.get("/")

            assert response.status_code == 200
            data = response.json()

            assert "name" in data
            assert "version" in data
            assert data["status"] == "running"
            assert data["docs"] == "/docs"
            assert "api_v1" in data


def test_health_endpoint():
    """Test health endpoint returns correct response."""
    from app.main import app

    with TestClient(app) as client:
        resp = client.get("/api/v1/system/health")
        assert resp.status_code == 200
        data = resp.json()
        assert data.get("status") == "OK"
        assert "version" in data
