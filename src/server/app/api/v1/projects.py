"""Project document management endpoints.

Provides REST endpoints so the Flutter client can notify the backend when
new documents have been generated, triggering ingestion into the per-project
ChromaDB vector store for use in subsequent RAG queries.

Endpoints:
    POST /api/v1/projects/{project_id}/documents/ingest
        Ingest a markdown document into the project's vector store.
"""

from __future__ import annotations

import logging
from typing import Any

from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field

from app.services.ingestion.project_ingestion_service import ProjectIngestionService

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/projects", tags=["projects"])


class IngestDocumentRequest(BaseModel):
    """Payload for the document ingestion endpoint."""

    doc_name: str = Field(
        ...,
        description="Human-readable document name (e.g. 'PROJECT_MANIFESTO.md').",
        min_length=1,
        max_length=255,
    )
    markdown_content: str = Field(
        ...,
        description="Full markdown text of the document to ingest.",
        min_length=1,
    )


class IngestDocumentResponse(BaseModel):
    """Successful response returned after ingestion."""

    project_id: str = Field(..., description="Target project identifier.")
    doc_name: str = Field(..., description="Name of the ingested document.")
    chunks_ingested: int = Field(..., description="Number of chunks stored.")


def _get_ingestion_service() -> ProjectIngestionService:
    """Build a ProjectIngestionService with a real ChromaDB connection."""
    # Lazy import to avoid loading chromadb at module import time (gRPC compatibility).
    from app.infrastructure.vector_store.chroma_store import (
        ChromaProjectStore,  # noqa: PLC0415
    )

    store = ChromaProjectStore()
    return ProjectIngestionService(store=store)


@router.post(
    "/{project_id}/documents/ingest",
    response_model=IngestDocumentResponse,
    status_code=status.HTTP_200_OK,
    summary="Ingest a project document into the vector store",
    description=(
        "Splits the provided markdown document into chunks and upserts them "
        "into the per-project ChromaDB collection. Idempotent: calling this "
        "endpoint again with the same content is safe (upsert semantics)."
    ),
)
async def ingest_document(
    project_id: str,
    request: IngestDocumentRequest,
    service: ProjectIngestionService = Depends(_get_ingestion_service),
) -> dict[str, Any]:
    """Ingest a markdown document for *project_id* into ChromaDB.

    Returns HTTP 200 with the number of chunks stored on success, or
    HTTP 500 with a structured error body on failure.

    Args:
        project_id: Path parameter – the project's unique identifier.
        request: JSON body with ``doc_name`` and ``markdown_content``.
        service: Injected ingestion service (overrideable in tests).

    Raises:
        HTTPException(400): If the request payload is invalid (empty content).
        HTTPException(500): If ingestion fails due to a backend error.
    """
    logger.info(
        "Ingest request: project_id=%s doc_name=%r content_len=%d",
        project_id,
        request.doc_name,
        len(request.markdown_content),
    )

    try:
        chunks_ingested = service.ingest_document(
            project_id=project_id,
            doc_name=request.doc_name,
            markdown_content=request.markdown_content,
        )
    except ValueError as exc:
        logger.warning("Invalid ingest payload: %s", exc)
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail=str(exc),
        ) from exc
    except Exception as exc:
        logger.error(
            "Ingestion failed for project=%s doc=%r: %s",
            project_id,
            request.doc_name,
            exc,
        )
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="Document ingestion failed. Check server logs for details.",
        ) from exc

    return {
        "project_id": project_id,
        "doc_name": request.doc_name,
        "chunks_ingested": chunks_ingested,
    }
