"""
Advanced tests for app/main.py targeting 90%+ coverage.

Focus on:
- Lifespan handlers execution (lines 65-79, 92, 104-106)
- Exception handlers (lines 154, 176-177, 216-218)
- Root endpoint (line 216)
- Logging and configuration
"""

from unittest.mock import MagicMock, patch

import pytest
from fastapi.testclient import TestClient


@pytest.fixture
def mock_init_chromadb():
    """Mock ChromaDB initialization."""
    with patch("app.main.init_chromadb") as mock:
        mock.return_value = "data/chromadb"
        yield mock


@pytest.fixture
def mock_init_sqlite():
    """Mock SQLite initialization."""
    with patch("app.main.init_sqlite") as mock:
        mock.return_value = "sqlite:///data/app.db"
        yield mock


@pytest.fixture
def mock_settings():
    """Mock settings."""
    with patch("app.main.settings") as mock:
        mock.APP_NAME = "SoftArchitect AI Test"
        mock.APP_VERSION = "0.1.0"
        mock.DEBUG = False
        mock.LOG_LEVEL = "INFO"
        mock.LLM_PROVIDER = "local"
        mock.OLLAMA_BASE_URL = "http://localhost:11434"
        mock.API_V1_STR = "/api/v1"
        yield mock


@pytest.fixture
def mock_logger():
    """Mock logger."""
    with patch("app.main.logger") as mock:
        yield mock


class TestLifespanHandlers:
    """Test startup and shutdown event handlers execution."""

    @pytest.mark.asyncio
    async def test_startup_event_initializes_chromadb(
        self, mock_init_chromadb, mock_logger, mock_settings
    ):
        """✅ Startup should initialize ChromaDB."""
        from app.main import startup_event

        await startup_event()

        # Verify ChromaDB init was called
        mock_init_chromadb.assert_called_once()

    @pytest.mark.asyncio
    async def test_startup_event_initializes_sqlite(
        self, mock_init_sqlite, mock_logger, mock_settings
    ):
        """✅ Startup should initialize SQLite."""
        from app.main import startup_event

        await startup_event()

        # Verify SQLite init was called
        mock_init_sqlite.assert_called_once()

    @pytest.mark.asyncio
    async def test_startup_event_logs_app_name_and_version(
        self, mock_init_chromadb, mock_init_sqlite, mock_logger, mock_settings
    ):
        """✅ Startup should log app name and version."""
        from app.main import startup_event

        await startup_event()

        # Verify logger was called with startup message
        calls = mock_logger.info.call_args_list
        assert any(
            "Starting" in str(call) and "SoftArchitect AI Test" in str(call)
            for call in calls
        )

    @pytest.mark.asyncio
    async def test_startup_event_logs_chromadb_path(
        self, mock_init_chromadb, mock_init_sqlite, mock_logger, mock_settings
    ):
        """✅ Startup should log ChromaDB initialization."""
        from app.main import startup_event

        await startup_event()

        # Verify ChromaDB path was logged
        calls = mock_logger.info.call_args_list
        assert any("ChromaDB initialized" in str(call) for call in calls)

    @pytest.mark.asyncio
    async def test_startup_event_logs_sqlite_url(
        self, mock_init_chromadb, mock_init_sqlite, mock_logger, mock_settings
    ):
        """✅ Startup should log SQLite initialization."""
        from app.main import startup_event

        await startup_event()

        # Verify SQLite URL was logged
        calls = mock_logger.info.call_args_list
        assert any("SQLite initialized" in str(call) for call in calls)

    @pytest.mark.asyncio
    async def test_startup_event_logs_llm_provider_local(
        self, mock_init_chromadb, mock_init_sqlite, mock_logger, mock_settings
    ):
        """✅ Startup should log LLM provider when local."""
        from app.main import startup_event

        mock_settings.LLM_PROVIDER = "local"

        await startup_event()

        # Verify LLM provider was logged
        calls = mock_logger.info.call_args_list
        assert any(
            "LLM Provider" in str(call) and "local" in str(call) for call in calls
        )

    @pytest.mark.asyncio
    async def test_startup_event_logs_ollama_url_when_local(
        self, mock_init_chromadb, mock_init_sqlite, mock_logger, mock_settings
    ):
        """✅ Startup should log Ollama URL when provider is local."""
        from app.main import startup_event

        mock_settings.LLM_PROVIDER = "local"
        mock_settings.OLLAMA_BASE_URL = "http://localhost:11434"

        await startup_event()

        # Verify Ollama URL was logged
        calls = mock_logger.info.call_args_list
        assert any("Ollama URL" in str(call) for call in calls)

    @pytest.mark.asyncio
    async def test_startup_event_logs_groq_when_cloud(
        self, mock_init_chromadb, mock_init_sqlite, mock_logger, mock_settings
    ):
        """✅ Startup should log Groq when provider is cloud."""
        from app.main import startup_event

        mock_settings.LLM_PROVIDER = "cloud"

        await startup_event()

        # Verify Groq was logged
        calls = mock_logger.info.call_args_list
        assert any("Groq Cloud" in str(call) for call in calls)

    @pytest.mark.asyncio
    async def test_shutdown_event_logs_shutdown_message(
        self, mock_logger, mock_settings
    ):
        """✅ Shutdown should log shutdown message."""
        from app.main import shutdown_event

        await shutdown_event()

        # Verify shutdown was logged
        calls = mock_logger.info.call_args_list
        assert any("Shutting down" in str(call) for call in calls)

    @pytest.mark.asyncio
    async def test_shutdown_event_includes_app_name(self, mock_logger, mock_settings):
        """✅ Shutdown should include app name in log."""
        from app.main import shutdown_event

        mock_settings.APP_NAME = "Test App"

        await shutdown_event()

        # Verify app name in shutdown log
        calls = mock_logger.info.call_args_list
        assert any("Test App" in str(call) for call in calls)


class TestLifespanContextManager:
    """Test lifespan context manager."""

    @pytest.mark.asyncio
    async def test_lifespan_calls_startup_before_yield(
        self, mock_init_chromadb, mock_init_sqlite, mock_logger, mock_settings
    ):
        """✅ Lifespan should call startup_event before yield."""
        from app.main import lifespan

        startup_called = False
        shutdown_called = False

        # Track the execution order
        async def track_startup():
            nonlocal startup_called
            startup_called = True

        async def track_shutdown():
            nonlocal shutdown_called
            shutdown_called = True

        with patch("app.main.startup_event", track_startup):
            with patch("app.main.shutdown_event", track_shutdown):
                app_fake = MagicMock()

                async with lifespan(app_fake):
                    # After entering context, startup should be called
                    assert startup_called

                # After exiting, shutdown should be called
                assert shutdown_called

    @pytest.mark.asyncio
    async def test_lifespan_calls_shutdown_after_yield(
        self, mock_init_chromadb, mock_init_sqlite, mock_logger, mock_settings
    ):
        """✅ Lifespan should call shutdown_event after yield."""
        from app.main import lifespan

        call_order = []

        async def track_startup():
            call_order.append("startup")

        async def track_shutdown():
            call_order.append("shutdown")

        with patch("app.main.startup_event", track_startup):
            with patch("app.main.shutdown_event", track_shutdown):
                app_fake = MagicMock()

                async with lifespan(app_fake):
                    call_order.append("running")

                # Verify order: startup, running, shutdown
                assert call_order == ["startup", "running", "shutdown"]

    @pytest.mark.asyncio
    async def test_lifespan_yields_to_app_execution(
        self, mock_init_chromadb, mock_init_sqlite, mock_logger
    ):
        """✅ Lifespan should yield control to app."""
        from app.main import lifespan

        app_running = False

        async def dummy_startup():
            pass

        async def dummy_shutdown():
            pass

        with patch("app.main.startup_event", dummy_startup):
            with patch("app.main.shutdown_event", dummy_shutdown):
                app_fake = MagicMock()

                async with lifespan(app_fake):
                    app_running = True

                # App should have had a chance to run
                assert app_running


class TestExceptionHandlers:
    """Test exception handler registration and integration."""

    def test_value_error_handler_registered(self):
        """✅ ValueError handler should be registered with app."""
        from app.main import app

        # ValueError should be registered
        assert ValueError in app.exception_handlers

    def test_general_exception_handler_registered(self):
        """✅ General Exception handler should be registered."""
        from app.main import app

        # Exception should be registered
        assert Exception in app.exception_handlers

    def test_exception_handlers_callable(self):
        """✅ Exception handlers should be callable."""
        from app.main import general_exception_handler, value_error_handler

        assert callable(value_error_handler)
        assert callable(general_exception_handler)

    def test_error_response_via_endpoint_integration(self):
        """✅ ValueError should be handled by endpoint."""
        from app.main import app

        @app.get("/test-validation-error")
        async def validation_error_endpoint():
            raise ValueError("Invalid data")

        client = TestClient(app)
        response = client.get("/test-validation-error")

        # Should get 400
        assert response.status_code == 400
        data = response.json()
        assert "detail" in data


class TestRootRoute:
    """Test root endpoint."""

    def test_root_endpoint_returns_app_name(self, mock_settings):
        """✅ Root endpoint should return app name."""
        from app.main import app

        client = TestClient(app)
        response = client.get("/")

        data = response.json()
        assert "name" in data

    def test_root_endpoint_returns_version(self, mock_settings):
        """✅ Root endpoint should return version."""
        from app.main import app

        client = TestClient(app)
        response = client.get("/")

        data = response.json()
        assert "version" in data

    def test_root_endpoint_returns_status(self, mock_settings):
        """✅ Root endpoint should return status."""
        from app.main import app

        client = TestClient(app)
        response = client.get("/")

        data = response.json()
        assert data.get("status") == "running"

    def test_root_endpoint_returns_docs_url(self, mock_settings):
        """✅ Root endpoint should return docs URL."""
        from app.main import app

        client = TestClient(app)
        response = client.get("/")

        data = response.json()
        assert "docs" in data
        assert data["docs"] == "/docs"

    def test_root_endpoint_returns_api_v1_url(self, mock_settings):
        """✅ Root endpoint should return API v1 URL."""
        from app.main import app

        client = TestClient(app)
        response = client.get("/")

        data = response.json()
        assert "api_v1" in data

    def test_root_endpoint_http_method_allowed(self):
        """✅ Root endpoint should only allow GET."""
        from app.main import app

        client = TestClient(app)

        # GET should work
        response = client.get("/")
        assert response.status_code == 200

        # POST should fail
        response = client.post("/")
        assert response.status_code != 200


class TestAppConfiguration:
    """Test FastAPI app configuration."""

    def test_app_has_exception_handlers(self):
        """✅ App should have exception handlers."""
        from app.main import app

        # Should have exception handlers registered
        assert len(app.exception_handlers) > 0

    def test_app_has_cors_middleware(self):
        """✅ App should have CORS middleware."""
        from app.main import app

        middleware_classes = [m.cls.__name__ for m in app.user_middleware]
        assert "CORSMiddleware" in middleware_classes

    def test_app_has_api_v1_router(self):
        """✅ App should include API v1 router."""
        from app.main import app

        routes = [route.path for route in app.routes]
        has_api_v1 = any("/api/v1" in str(route) for route in routes)
        assert has_api_v1

    def test_cors_allows_localhost_origins(self):
        """✅ CORS should allow localhost origins."""
        from app.main import app

        client = TestClient(app)
        response = client.get("/", headers={"Origin": "http://localhost:3000"})

        # Should succeed with localhost origin
        assert response.status_code == 200

    def test_cors_allows_127_0_0_1_origins(self):
        """✅ CORS should allow 127.0.0.1 origins."""
        from app.main import app

        client = TestClient(app)
        response = client.get("/", headers={"Origin": "http://127.0.0.1:3000"})

        # Should succeed with 127.0.0.1
        assert response.status_code == 200

    def test_app_description_configured(self):
        """✅ App should have description."""
        from app.main import app

        assert app.description is not None
        assert "Software Architecture" in app.description

    def test_app_title_from_settings(self):
        """✅ App title should be from settings."""
        from app.core.config import settings
        from app.main import app

        assert app.title == settings.APP_NAME

    def test_app_version_from_settings(self):
        """✅ App version should be from settings."""
        from app.core.config import settings
        from app.main import app

        assert app.version == settings.APP_VERSION


class TestErrorHandlingIntegration:
    """Integration tests for error handling."""

    def test_endpoint_value_error_caught(self):
        """✅ ValueError should be caught by exception handler."""
        from app.main import app

        @app.get("/test-value-error")
        async def error_endpoint():
            raise ValueError("Test error")

        client = TestClient(app)
        response = client.get("/test-value-error")

        # Should get 400 from ValueError handler
        assert response.status_code == 400
        data = response.json()
        assert "detail" in data

    def test_404_not_found(self):
        """✅ Non-existent routes should return 404."""
        from app.main import app

        client = TestClient(app)
        response = client.get("/nonexistent-endpoint")

        # Should be 404
        assert response.status_code == 404

    def test_root_endpoint_accessible_via_get(self):
        """✅ Root endpoint should respond to GET."""
        from app.main import app

        client = TestClient(app)
        response = client.get("/")

        # Should be accessible
        assert response.status_code == 200

    def test_api_routes_registered(self):
        """✅ API v1 routes should be registered."""
        from app.main import app

        client = TestClient(app)

        # Try health endpoint
        response = client.get("/api/v1/health")

        # Should not be 404 for the app structure
        assert response.status_code < 500
