"""
Temporary RAG test endpoint for verification.

⚠️ NOTE: This endpoint is TEMPORARY and should be removed before production.
         Use only for validating RAG integration during development.
"""

import logging
from typing import Optional

from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel, Field

from app.core.exceptions import VectorStoreError
from services.rag.vector_store import VectorStoreService

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/rag/test", tags=["RAG Testing"])


class QueryRequest(BaseModel):
    """Request model for RAG test queries."""

    question: str = Field(..., min_length=1, max_length=500, description="Query text")
    limit: int = Field(default=3, ge=1, le=10, description="Max results to return")

    model_config = {
        "json_schema_extra": {
            "example": {
                "question": "How do I set up Docker?",
                "limit": 3
            }
        }
    }


class RetrievalResult(BaseModel):
    """Single retrieval result."""

    content: str = Field(..., description="Document excerpt (first 300 chars)")
    source: str = Field(..., description="Source filename")
    path: str = Field(..., description="Full path to document")


class QueryResponse(BaseModel):
    """Response model for RAG test queries."""

    status: str = Field(..., description="Operation status")
    query: str = Field(..., description="Original query")
    matches: int = Field(..., ge=0, description="Number of matches found")
    data: list[RetrievalResult] = Field(..., description="Retrieval results")
    warning: Optional[str] = Field(None, description="Optional warning message")


@router.post(
    "/retrieval",
    response_model=QueryResponse,
    status_code=status.HTTP_200_OK,
    summary="Test RAG retrieval",
    description="Temporary endpoint to validate RAG vector retrieval integration."
)
async def test_rag_retrieval(body: QueryRequest) -> QueryResponse:
    """
    Test RAG retrieval pipeline.

    ⚠️ TEMPORARY ENDPOINT - Remove after verification phase.

    Accepts a natural language query and returns relevant document chunks
    from the knowledge base via ChromaDB vector search.

    Args:
        body: Query request with question and optional limit

    Returns:
        QueryResponse with retrieval results

    Raises:
        HTTPException: If ChromaDB connection fails or query errors
    """
    try:
        # Initialize VectorStoreService with Docker internal hostname
        # In container networking, service name is the hostname
        store = VectorStoreService(host="chromadb", port=8000)

        logger.info(f"RAG test query: {body.question}")

        # Query the vector store
        results = store.query(body.question, n_results=body.limit)

        # Format results for API response
        formatted_results: list[RetrievalResult] = []

        # Safely extract documents and metadata
        documents_list = results.get("documents")
        metadatas_list = results.get("metadatas")

        if (
            documents_list is not None
            and len(documents_list) > 0
            and metadatas_list is not None
            and len(metadatas_list) > 0
        ):
            docs = documents_list[0]
            metas = metadatas_list[0]

            for doc, meta in zip(docs, metas):
                # Ensure meta is dict (doc is guaranteed to be str from ChromaDB)
                if not isinstance(meta, dict):
                    meta = {}

                # Limit content to 300 chars for API response
                excerpt = doc[:300] + ("..." if len(doc) > 300 else "")

                source_value = meta.get("filename", "unknown")
                path_value = meta.get("source", "unknown")

                # Type-safe conversions
                source_str = (
                    str(source_value)
                    if source_value is not None
                    else "unknown"
                )
                path_str = (
                    str(path_value) if path_value is not None else "unknown"
                )

                formatted_results.append(
                    RetrievalResult(
                        content=excerpt,
                        source=source_str,
                        path=path_str,
                    )
                )

        logger.info(f"RAG query returned {len(formatted_results)} results")

        return QueryResponse(
            status="success",
            query=body.question,
            matches=len(formatted_results),
            data=formatted_results,
            warning="⚠️ This endpoint is temporary and will be removed before production",
        )

    except VectorStoreError as e:
        logger.error(f"VectorStore error: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"RAG query failed: {str(e)}",
        ) from e

    except Exception as e:
        logger.exception(f"Unexpected error in RAG test endpoint: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail="An unexpected error occurred",
        ) from e


@router.get(
    "/health",
    response_model=dict,
    status_code=status.HTTP_200_OK,
    summary="Check RAG health"
)
async def rag_health() -> dict:
    """
    Check RAG system health.

    Returns:
        dict: Health status with heartbeat time
    """
    try:
        store = VectorStoreService(host="chromadb", port=8000)
        heartbeat = store.health_check()

        return {
            "status": "healthy",
            "heartbeat_ms": heartbeat,
            "message": "RAG system is operational"
        }

    except Exception as e:
        logger.error(f"Health check failed: {e}")
        raise HTTPException(
            status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
            detail="RAG system is not available"
        ) from e
