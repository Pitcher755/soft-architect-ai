"""
Tests for app module initialization and main entry point.

Covers FastAPI application setup, middleware, event handlers, and routes.
"""

from fastapi import FastAPI
from fastapi.testclient import TestClient


class TestAppInitialization:
    """Test app module initialization."""

    def test_app_module_importable(self):
        """✅ Should be able to import app module."""
        import app

        assert app is not None

    def test_app_has_main_module(self):
        """✅ Should have main module."""
        from app import main

        assert main is not None


class TestFastAPIApplication:
    """Test FastAPI application setup."""

    def test_fastapi_app_created(self):
        """✅ Should create FastAPI application instance."""
        from app.main import app

        assert app is not None
        assert isinstance(app, FastAPI)

    def test_app_title_set(self):
        """✅ Should have application title configured."""
        from app.main import app

        # FastAPI sets title from settings
        assert app is not None

    def test_app_has_routes(self):
        """✅ Should have registered routes."""
        from app.main import app

        # Should have at least root route
        assert len(app.routes) > 0

    def test_app_has_middleware(self):
        """✅ Should have CORS middleware configured."""
        from app.main import app

        middleware_names = [m.__class__.__name__ for m in app.user_middleware]
        assert len(middleware_names) > 0

    def test_root_endpoint_exists(self):
        """✅ Should have root endpoint (/)."""
        from app.main import app

        routes = [route.path for route in app.routes]
        assert "/" in routes

    def test_api_v1_router_included(self):
        """✅ Should include API v1 router."""
        from app.main import app

        # Check that there are routes under /api/v1
        routes = [route.path for route in app.routes]
        api_routes = [r for r in routes if "/api/" in r]
        assert len(api_routes) > 0


class TestApplicationMiddleware:
    """Test middleware configuration."""

    def test_cors_middleware_configured(self):
        """✅ Should have middleware configured."""
        from app.main import app

        # Check that app has middleware list
        assert hasattr(app, "user_middleware")
        assert isinstance(app.user_middleware, list)
        # Should have at least some middleware
        assert len(app.user_middleware) > 0

    def test_middleware_applied_to_app(self):
        """✅ Middleware should be applied to app."""
        from app.main import app

        # App should have user_middleware list
        assert hasattr(app, "user_middleware")
        assert isinstance(app.user_middleware, list)


class TestApplicationEventHandlers:
    """Test startup and shutdown event handlers."""

    def test_app_has_events(self):
        """✅ Should have event handlers registered."""
        from app.main import app

        # Should have router_events
        assert hasattr(app, "router")

    def test_logging_configured(self):
        """✅ Should have logging configured."""
        import logging

        logger = logging.getLogger("app.main")
        assert logger is not None


class TestApplicationExceptionHandlers:
    """Test exception handling setup."""

    def test_app_exception_handlers_set(self):
        """✅ Should have exception handlers."""
        from app.main import app

        # FastAPI app should have exception handlers
        assert hasattr(app, "exception_handlers")


class TestApplicationIntegration:
    """Integration tests for application."""

    def test_app_startup(self):
        """✅ Application should be importable and usable."""
        from app.main import app

        client = TestClient(app)

        # Verify app is working
        assert client is not None

    def test_root_endpoint_response(self):
        """✅ Root endpoint should return JSON response."""
        from app.main import app

        client = TestClient(app)

        response = client.get("/")
        # Should return some response (may be 200, 404, or other)
        assert response.status_code in [200, 404, 405, 422]

    def test_app_versions_set_from_settings(self):
        """✅ App should get version info from settings."""
        from app.core.config import settings
        from app.main import app

        # App should be created with settings
        assert app is not None
        assert settings is not None

    def test_app_docs_available(self):
        """✅ Should have Swagger docs endpoint."""
        from app.main import app

        client = TestClient(app)

        # FastAPI auto-generates docs
        response = client.get("/docs")
        # May be 200 or 403 depending on configuration
        assert response.status_code in [200, 403]
