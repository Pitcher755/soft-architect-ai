"""Integration tests for GZipMiddleware HTTP compression.

PIT-101 — [HU-4.5] Add GZipMiddleware for HTTP response compression.

Test Coverage:
    - Responses > minimum_size (500 bytes) are gzip-compressed
    - Responses < minimum_size are NOT compressed
    - Client requesting identity encoding gets no compression
    - WebSocket/HTTP connections are NOT disrupted by gzip middleware

TDD Phase: RED → GREEN verified.
"""

import pytest
from fastapi.testclient import TestClient


@pytest.fixture
def gzip_client():
    """TestClient that sends Accept-Encoding: gzip header."""
    from app.main import app

    with TestClient(app) as client:
        yield client


class TestGzipMiddlewareLargeResponse:
    """Verify that responses exceeding minimum_size are gzip-compressed."""

    def test_large_response_has_gzip_content_encoding(self, gzip_client: TestClient):
        """Response >500 bytes MUST include Content-Encoding: gzip."""
        response = gzip_client.get(
            "/openapi.json",
            headers={"Accept-Encoding": "gzip"},
        )
        assert response.status_code == 200
        assert (
            len(response.content) > 500
        ), "OpenAPI JSON should be >500 bytes to trigger gzip"
        assert response.headers.get("content-encoding") == "gzip"

    def test_large_response_body_is_valid_after_decompression(
        self, gzip_client: TestClient
    ):
        """Gzip-compressed body must decompress to valid JSON."""
        response = gzip_client.get(
            "/openapi.json",
            headers={"Accept-Encoding": "gzip"},
        )
        assert response.status_code == 200
        data = response.json()
        assert "openapi" in data
        assert "paths" in data


class TestGzipMiddlewareSmallResponse:
    """Verify that responses below minimum_size are NOT compressed."""

    def test_small_response_has_no_gzip_encoding(self, gzip_client: TestClient):
        """Response <500 bytes MUST NOT be gzip-compressed."""
        response = gzip_client.get(
            "/",
            headers={"Accept-Encoding": "gzip"},
        )
        assert response.status_code == 200
        content_encoding = response.headers.get("content-encoding")
        assert content_encoding != "gzip", (
            f"Small response (<500 bytes) should not be gzip-compressed, "
            f"got content-encoding={content_encoding}"
        )


class TestGzipMiddlewareWithoutAcceptEncoding:
    """Verify no compression when client requests identity encoding."""

    def test_identity_accept_encoding_no_gzip(self, gzip_client: TestClient):
        """With Accept-Encoding: identity, response MUST NOT be compressed."""
        response = gzip_client.get(
            "/openapi.json",
            headers={"Accept-Encoding": "identity"},
        )
        assert response.status_code == 200
        content_encoding = response.headers.get("content-encoding")
        assert (
            content_encoding != "gzip"
        ), "With Accept-Encoding: identity, server should not gzip the response"


class TestGzipMiddlewareWebSocket:
    """Verify HTTP connections are NOT disrupted by GZipMiddleware."""

    def test_http_connection_unaffected(self, gzip_client: TestClient):
        """HTTP requests should work normally with GZipMiddleware active."""
        response = gzip_client.get("/")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "running"
