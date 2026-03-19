"""Unit tests for POST /api/v1/projects/{project_id}/documents/ingest endpoint.

Strategy: use FastAPI's dependency_overrides to inject a mock
ProjectIngestionService so no real ChromaDB connection is needed.

Coverage targets:
  - HTTP 200 on successful ingestion
  - HTTP 400 when service raises ValueError (empty content)
  - HTTP 500 when service raises an unexpected exception
  - Pydantic schema validation (missing required fields → HTTP 422)
  - Response body structure matches IngestDocumentResponse schema

Naming convention: test_{endpoint}_{scenario}_{expected_result}
"""

from __future__ import annotations

from unittest.mock import MagicMock

import pytest
from fastapi.testclient import TestClient

from app.api.v1.projects import _get_ingestion_service
from app.main import app
from app.services.ingestion.project_ingestion_service import ProjectIngestionService


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _make_mock_service(return_value: int = 3) -> MagicMock:
    """Build a MagicMock that satisfies ProjectIngestionService contract."""
    svc = MagicMock(spec=ProjectIngestionService)
    svc.ingest_document.return_value = return_value
    return svc


@pytest.fixture
def client_with_mock_service():
    """Yield a TestClient with the ingestion service dependency overridden."""
    mock_svc = _make_mock_service(return_value=4)

    app.dependency_overrides[_get_ingestion_service] = lambda: mock_svc

    with TestClient(app) as client:
        yield client, mock_svc

    # Always clean up overrides after test.
    app.dependency_overrides.pop(_get_ingestion_service, None)


# ---------------------------------------------------------------------------
# Success path
# ---------------------------------------------------------------------------


class TestIngestDocumentSuccess:
    """Tests that verify the happy-path behaviour of the ingest endpoint."""

    def test_ingest_document_returns_200(
        self, client_with_mock_service: tuple[TestClient, MagicMock]
    ) -> None:
        client, _ = client_with_mock_service
        response = client.post(
            "/api/v1/projects/proj-abc/documents/ingest",
            json={"doc_name": "DOC.md", "markdown_content": "# Title\n\nContent."},
        )
        assert response.status_code == 200

    def test_ingest_document_response_contains_project_id(
        self, client_with_mock_service: tuple[TestClient, MagicMock]
    ) -> None:
        client, _ = client_with_mock_service
        response = client.post(
            "/api/v1/projects/my-project/documents/ingest",
            json={"doc_name": "F.md", "markdown_content": "Text."},
        )
        assert response.json()["project_id"] == "my-project"

    def test_ingest_document_response_contains_doc_name(
        self, client_with_mock_service: tuple[TestClient, MagicMock]
    ) -> None:
        client, _ = client_with_mock_service
        response = client.post(
            "/api/v1/projects/p1/documents/ingest",
            json={"doc_name": "ARCH.md", "markdown_content": "Content here."},
        )
        assert response.json()["doc_name"] == "ARCH.md"

    def test_ingest_document_response_contains_chunks_ingested(
        self, client_with_mock_service: tuple[TestClient, MagicMock]
    ) -> None:
        client, _ = client_with_mock_service
        response = client.post(
            "/api/v1/projects/p2/documents/ingest",
            json={"doc_name": "D.md", "markdown_content": "Text."},
        )
        # mock returns 4
        assert response.json()["chunks_ingested"] == 4

    def test_ingest_document_calls_service_with_correct_args(
        self, client_with_mock_service: tuple[TestClient, MagicMock]
    ) -> None:
        client, mock_svc = client_with_mock_service
        client.post(
            "/api/v1/projects/target-proj/documents/ingest",
            json={"doc_name": "X.md", "markdown_content": "Hello world."},
        )
        mock_svc.ingest_document.assert_called_once_with(
            project_id="target-proj",
            doc_name="X.md",
            markdown_content="Hello world.",
        )


# ---------------------------------------------------------------------------
# Error paths
# ---------------------------------------------------------------------------


class TestIngestDocumentErrors:
    """Tests for error handling in the ingest endpoint."""

    def test_ingest_document_value_error_returns_400(self) -> None:
        mock_svc = _make_mock_service()
        mock_svc.ingest_document.side_effect = ValueError("markdown_content is empty")

        app.dependency_overrides[_get_ingestion_service] = lambda: mock_svc
        try:
            with TestClient(app) as client:
                response = client.post(
                    "/api/v1/projects/p/documents/ingest",
                    json={"doc_name": "E.md", "markdown_content": "x"},
                )
            assert response.status_code == 400
            assert "empty" in response.json()["detail"]
        finally:
            app.dependency_overrides.pop(_get_ingestion_service, None)

    def test_ingest_document_unexpected_error_returns_500(self) -> None:
        mock_svc = _make_mock_service()
        mock_svc.ingest_document.side_effect = RuntimeError("ChromaDB unreachable")

        app.dependency_overrides[_get_ingestion_service] = lambda: mock_svc
        try:
            with TestClient(app) as client:
                response = client.post(
                    "/api/v1/projects/p/documents/ingest",
                    json={"doc_name": "E.md", "markdown_content": "content"},
                )
            assert response.status_code == 500
            assert "ingestion failed" in response.json()["detail"].lower()
        finally:
            app.dependency_overrides.pop(_get_ingestion_service, None)

    def test_ingest_document_missing_doc_name_returns_422(self) -> None:
        app.dependency_overrides[_get_ingestion_service] = lambda: _make_mock_service()
        try:
            with TestClient(app) as client:
                response = client.post(
                    "/api/v1/projects/p/documents/ingest",
                    json={"markdown_content": "content"},  # doc_name missing
                )
            assert response.status_code == 422
        finally:
            app.dependency_overrides.pop(_get_ingestion_service, None)

    def test_ingest_document_missing_markdown_content_returns_422(self) -> None:
        app.dependency_overrides[_get_ingestion_service] = lambda: _make_mock_service()
        try:
            with TestClient(app) as client:
                response = client.post(
                    "/api/v1/projects/p/documents/ingest",
                    json={"doc_name": "D.md"},  # markdown_content missing
                )
            assert response.status_code == 422
        finally:
            app.dependency_overrides.pop(_get_ingestion_service, None)

    def test_ingest_document_empty_doc_name_returns_422(self) -> None:
        """Pydantic min_length=1 rejects empty string."""
        app.dependency_overrides[_get_ingestion_service] = lambda: _make_mock_service()
        try:
            with TestClient(app) as client:
                response = client.post(
                    "/api/v1/projects/p/documents/ingest",
                    json={"doc_name": "", "markdown_content": "content"},
                )
            assert response.status_code == 422
        finally:
            app.dependency_overrides.pop(_get_ingestion_service, None)

    def test_ingest_document_empty_markdown_content_returns_422(self) -> None:
        """Pydantic min_length=1 rejects empty markdown_content."""
        app.dependency_overrides[_get_ingestion_service] = lambda: _make_mock_service()
        try:
            with TestClient(app) as client:
                response = client.post(
                    "/api/v1/projects/p/documents/ingest",
                    json={"doc_name": "D.md", "markdown_content": ""},
                )
            assert response.status_code == 422
        finally:
            app.dependency_overrides.pop(_get_ingestion_service, None)
