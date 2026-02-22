"""Smoke test for API health endpoint.

Tests infrastructure readiness by verifying the /health endpoint.
This should be the first smoke test to run - if this fails, the API is down.
"""

from fastapi.testclient import TestClient


def test_health_endpoint_returns_200(client: TestClient):
    """
    Smoke Test: /api/v1/system/health endpoint should return 200 OK.

    If this test fails, the FastAPI server is not running or misconfigured.
    """
    response = client.get("/api/v1/system/health")

    assert response.status_code == 200, f"Health check failed: {response.status_code}"
    data = response.json()
    assert "status" in data, "Health response should contain 'status' field"


def test_health_endpoint_no_auth_required(client: TestClient):
    """
    Smoke Test: /api/v1/system/health should be accessible without auth.

    Public health checks should not require authentication.
    """
    response = client.get("/api/v1/system/health")

    # Should not return 401/403
    assert response.status_code != 401, "Health check should not require auth"
    assert response.status_code != 403, "Health check should not be forbidden"
    assert response.status_code == 200


def test_health_endpoint_fast_response(client: TestClient):
    """
    Smoke Test: /api/v1/system/health should respond quickly (<100ms).

    Health checks should be lightweight and fast.
    """
    import time

    start = time.time()
    response = client.get("/api/v1/system/health")
    duration = time.time() - start

    assert response.status_code == 200
    assert duration < 0.1, f"Health check too slow: {duration:.3f}s (max 0.1s)"
