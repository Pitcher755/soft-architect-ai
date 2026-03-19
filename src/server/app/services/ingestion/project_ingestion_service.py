"""Service layer for ingesting project documents into the per-project vector store.

Architecture: Service Layer (Clean Architecture).
  - Port  : ChromaProjectStore (infrastructure adapter)
  - Service: ProjectIngestionService (this file)
  - Caller : POST /api/v1/projects/{project_id}/documents/ingest

Responsibilities:
  - Split raw markdown content into chunks suited for embedding.
  - Attach metadata (doc_name) to each chunk for auditability.
  - Delegate persistence to ChromaProjectStore (upsert semantics).
"""

from __future__ import annotations

import logging
from typing import Any

from app.infrastructure.vector_store.chroma_store import ChromaProjectStore

logger = logging.getLogger(__name__)

# Maximum characters per chunk before splitting at a paragraph boundary.
_MAX_CHUNK_CHARS: int = 4_000


def _split_into_chunks(text: str, max_chars: int = _MAX_CHUNK_CHARS) -> list[str]:
    """Split *text* into chunks ≤ *max_chars* chars at paragraph boundaries.

    Strategy: split on double-newline (paragraph), then group consecutive
    paragraphs into a single chunk as long as the cumulative length stays
    below *max_chars*.  Lone paragraphs that exceed the limit are accepted
    as oversized chunks (ChromaProjectStore truncates them on upsert).

    Args:
        text: Raw markdown content to split.
        max_chars: Soft upper bound per chunk (characters).

    Returns:
        Non-empty list of text chunks.  Returns a single-element list when
        the whole content fits in one chunk.
    """
    paragraphs = [p.strip() for p in text.split("\n\n") if p.strip()]
    if not paragraphs:
        return [text.strip()] if text.strip() else []

    chunks: list[str] = []
    current_parts: list[str] = []
    current_len: int = 0

    for para in paragraphs:
        # + 2 accounts for the "\n\n" separator when joining.
        if current_parts and current_len + len(para) + 2 > max_chars:
            chunks.append("\n\n".join(current_parts))
            current_parts = [para]
            current_len = len(para)
        else:
            current_parts.append(para)
            current_len += len(para) + (2 if current_parts else 0)

    if current_parts:
        chunks.append("\n\n".join(current_parts))

    return chunks


class ProjectIngestionService:
    """Orchestrates splitting and storing project documents into ChromaDB.

    Usage::

        store = ChromaProjectStore(host="chromadb", port=8000)
        service = ProjectIngestionService(store=store)
        count = service.ingest_document(
            project_id="abc123",
            doc_name="PROJECT_MANIFESTO.md",
            markdown_content="# Vision\\n\\nWe build ...",
        )
        # count → number of chunks stored

    The service is intentionally synchronous: ChromaDB HTTP calls are
    fast enough for a single ingest request.  The FastAPI endpoint wraps
    it with ``run_in_executor`` if necessary.
    """

    def __init__(self, store: ChromaProjectStore) -> None:
        """Initialise the service with a vector store adapter.

        Args:
            store: Pre-built ChromaProjectStore instance.
        """
        self._store = store

    def ingest_document(
        self,
        project_id: str,
        doc_name: str,
        markdown_content: str,
    ) -> int:
        """Split *markdown_content* into chunks and upsert them into the store.

        Each chunk is annotated with ``doc_name`` and ``chunk_index`` metadata
        so the origin document can be identified in query results.

        Args:
            project_id: Target project identifier.
            doc_name: Human-readable document name (e.g. "PROJECT_MANIFESTO.md").
            markdown_content: Raw markdown text to ingest.

        Returns:
            Number of chunks stored.

        Raises:
            ValueError: If *markdown_content* is empty after stripping.
        """
        content = markdown_content.strip()
        if not content:
            raise ValueError(f"markdown_content is empty for doc_name={doc_name!r}")

        chunks = _split_into_chunks(content)
        metadatas: list[dict[str, Any]] = [
            {"doc_name": doc_name, "chunk_index": i} for i in range(len(chunks))
        ]

        count = self._store.add_documents(
            project_id=project_id,
            texts=chunks,
            metadatas=metadatas,
        )
        logger.info(
            "Ingested doc_name=%r into project=%s → %d chunks",
            doc_name,
            project_id,
            count,
        )
        return count
