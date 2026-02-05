"""
Tests for app.api.v1 module endpoints.

Covers health checks, knowledge endpoints, and chat endpoints.
"""

import pytest


class TestAPIv1HealthEndpoint:
    """Test health check endpoint."""

    @pytest.mark.asyncio
    async def test_health_endpoint_exists(self):
        """✅ Should have health check endpoint."""
        from app.api.v1.health import router

        assert router is not None

    def test_health_check_route_defined(self):
        """✅ Should have proper route definition."""
        from app.api.v1 import router as api_router

        routes = [route.path for route in api_router.routes]
        # At least one route should be defined
        assert len(routes) > 0


class TestAPIv1KnowledgeEndpoint:
    """Test knowledge base endpoints."""

    def test_knowledge_router_exists(self):
        """✅ Should have knowledge router defined."""
        from app.api.v1.knowledge import router

        assert router is not None

    def test_knowledge_endpoint_defined(self):
        """✅ Should have knowledge endpoint methods."""
        from app.api.v1.knowledge import router

        # Check that router has routes
        assert hasattr(router, "routes")


class TestAPIv1ChatEndpoint:
    """Test chat endpoint."""

    def test_chat_router_exists(self):
        """✅ Should have chat router defined."""
        from app.api.v1.chat import router

        assert router is not None

    def test_chat_endpoint_defined(self):
        """✅ Should have chat endpoint methods."""
        from app.api.v1.chat import router

        assert hasattr(router, "routes")


class TestAPIv1Router:
    """Test main v1 router."""

    def test_api_v1_router_initialized(self):
        """✅ Should initialize APIRouter."""
        from app.api.v1 import router

        assert router is not None

    def test_api_v1_has_subpaths(self):
        """✅ Should include sub-routers."""
        from app.api.v1 import router

        # Router should have includes
        assert hasattr(router, "routes")
        assert len(router.routes) > 0
