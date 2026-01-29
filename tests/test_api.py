"""
API endpoint tests.

Validates all API endpoints with real HTTP requests.
"""

from fastapi.testclient import TestClient

from core.config import settings
from main import app

client = TestClient(app)


def test_root_redirect():
    """Root endpoint should redirect to docs."""
    response = client.get("/", follow_redirects=False)
    assert response.status_code == 307
    assert response.headers["location"] == "/docs"


def test_ping():
    """Ping endpoint should return pong."""
    response = client.get("/ping")
    assert response.status_code == 200
    assert response.json() == {"ping": "pong"}


def test_health_check():
    """Health check should return 200 with correct structure."""
    response = client.get(f"{settings.API_V1_STR}/system/health")
    assert response.status_code == 200

    content = response.json()
    assert content["status"] == "ok"
    assert content["app"] == settings.PROJECT_NAME
    assert content["version"] == settings.VERSION
    assert "environment" in content
    assert "debug_mode" in content


def test_detailed_health_check():
    """Detailed health check should include services."""
    response = client.get(f"{settings.API_V1_STR}/system/health/detailed")
    assert response.status_code == 200

    content = response.json()
    assert content["status"] == "ok"
    assert "services" in content
    assert isinstance(content["services"], dict)


def test_openapi_schema():
    """OpenAPI schema should be accessible."""
    response = client.get(f"{settings.API_V1_STR}/openapi.json")
    assert response.status_code == 200
    schema = response.json()
    assert "openapi" in schema
    assert schema["info"]["title"] == settings.PROJECT_NAME


def test_cors_headers():
    """CORS headers should be present in responses."""
    response = client.options(
        f"{settings.API_V1_STR}/system/health",
        headers={"Origin": "http://localhost:3000"},
    )
    assert "access-control-allow-origin" in response.headers
