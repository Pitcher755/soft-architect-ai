"""ChromaDB per-project vector store adapter (Task 4 – Dynamic RAG).

Implements VectorStoreProtocol using a per-project ChromaDB collection so
that each user project has its own isolated embedding space.

Architecture: Adapter Pattern (Ports & Adapters / Hexagonal).
  - Port  : VectorStoreProtocol  (app/services/rag/vector_store_protocol.py)
  - Adapter: ChromaProjectStore  (this file)
  - Driver : chromadb.HttpClient (external dependency)

Collection naming convention:
  project_{sanitised_project_id}
  e.g. "project_a1b2c3d4e5f6..."

Design decisions:
  - DefaultEmbeddingFunction: avoids a heavy sentence-transformers dependency
    at this stage; can be swapped for a dedicated embedding model later.
  - SHA-256 IDs: deterministic, collision-resistant, short (64 hex chars).
  - Upsert semantics: idempotent ingestion (no duplicates on re-ingest).
"""

from __future__ import annotations

import hashlib
import logging
import re
from typing import Any

import chromadb
from chromadb.api import ClientAPI
from chromadb.api.types import QueryResult
from chromadb.utils.embedding_functions import DefaultEmbeddingFunction

from app.services.rag.vector_store_protocol import VectorStoreProtocol

logger = logging.getLogger(__name__)

# Maximum characters of a single document chunk sent to ChromaDB.
# Keeps embedding quality high and avoids token-limit errors.
_MAX_CHUNK_CHARS: int = 4_000

# Prefix for all per-project collections so they are easy to list/audit.
_COLLECTION_PREFIX: str = "project_"


def _sanitise_project_id(project_id: str) -> str:
    """Return a ChromaDB-safe collection-name fragment from a project id.

    ChromaDB collection names must match ``[a-zA-Z0-9_-]`` and be 3–63 chars.
    We keep only alphanumeric chars and hyphens, then truncate to 50 chars
    (leaving room for the ``project_`` prefix so the total stays ≤ 63).
    """
    safe = re.sub(r"[^a-zA-Z0-9\-]", "", project_id)
    if not safe:
        # Fall back to a deterministic hash if the id is entirely special chars.
        safe = hashlib.sha256(project_id.encode()).hexdigest()[:16]
    return safe[:50]


def _generate_chunk_id(project_id: str, text: str, index: int) -> str:
    """Return a deterministic SHA-256 id for a text chunk.

    Encoding: ``project_id + ":" + index + ":" + text[:200]``
    The first 200 chars of text are enough to distinguish chunks reliably
    while keeping hashing fast.
    """
    raw = f"{project_id}:{index}:{text[:200]}"
    return hashlib.sha256(raw.encode("utf-8")).hexdigest()


class ChromaProjectStore(VectorStoreProtocol):
    """Adapter that maps VectorStoreProtocol onto a ChromaDB HTTP instance.

    Each project gets its own isolated collection so queries, clears and
    stats never bleed across projects.

    Usage (production):
        store = ChromaProjectStore(host="chromadb", port=8000)
        store.add_documents(project_id="abc123", texts=["Doc 1", "Doc 2"])
        results = await store.query_project("abc123", "architecture decision")

    Usage (tests):
        store = ChromaProjectStore(host="localhost", port=8000)
        # or inject a mock client via the `client` parameter in tests.
    """

    def __init__(
        self,
        host: str = "chromadb",
        port: int = 8000,
        *,
        client: ClientAPI | None = None,
    ) -> None:
        """Initialise adapter and verify connectivity.

        Args:
            host: ChromaDB server hostname (default ``"chromadb"`` for Docker).
            port: ChromaDB server port (default ``8000``).
            client: Optional pre-built client (injection point for tests).

        Raises:
            ConnectionError: If the ChromaDB server is unreachable.
        """
        if client is not None:
            self._client: ClientAPI = client
        else:
            self._client = chromadb.HttpClient(host=host, port=port)

        self._embedding_fn = DefaultEmbeddingFunction()
        logger.info("ChromaProjectStore initialised – host=%s port=%s", host, port)

    # ------------------------------------------------------------------
    # Collection management
    # ------------------------------------------------------------------

    def get_or_create_project_collection(self, project_id: str) -> chromadb.Collection:
        """Return (creating if absent) the ChromaDB collection for a project.

        Collection name: ``project_{sanitised_project_id}``

        Args:
            project_id: Raw project identifier (UUID string or similar).

        Returns:
            The chromadb Collection object ready for upsert / query.
        """
        collection_name = _COLLECTION_PREFIX + _sanitise_project_id(project_id)
        collection: chromadb.Collection = self._client.get_or_create_collection(
            name=collection_name,
            embedding_function=self._embedding_fn,  # type: ignore[arg-type]
            metadata={"hnsw:space": "cosine"},
        )
        logger.debug(
            "Collection resolved: %s (project=%s)", collection_name, project_id
        )
        return collection

    # ------------------------------------------------------------------
    # Ingestion
    # ------------------------------------------------------------------

    def add_documents(
        self,
        project_id: str,
        texts: list[str],
        metadatas: list[dict[str, Any]] | None = None,
    ) -> int:
        """Upsert a list of text chunks into the project collection.

        Idempotent: calling this method twice with the same texts produces
        a single stored copy (upsert semantics via deterministic IDs).

        Args:
            project_id: Target project identifier.
            texts: Plain-text chunks to embed and store.
            metadatas: Optional per-chunk metadata dicts (same length as texts).
                       Values must be ``str | int | float | bool``.

        Returns:
            Number of chunks actually upserted.

        Raises:
            ValueError: If ``texts`` is empty.
        """
        if not texts:
            raise ValueError("texts must be a non-empty list")

        collection = self.get_or_create_project_collection(project_id)

        # Truncate oversized chunks to avoid embedding quality degradation.
        truncated = [t[:_MAX_CHUNK_CHARS] for t in texts]

        ids = [_generate_chunk_id(project_id, text, i) for i, text in enumerate(texts)]
        metas: list[dict[str, Any]] = metadatas if metadatas else [{} for _ in texts]

        collection.upsert(documents=truncated, ids=ids, metadatas=metas)  # type: ignore[arg-type]
        logger.info(
            "Upserted %d chunks into project=%s collection",
            len(ids),
            project_id,
        )
        return len(ids)

    # ------------------------------------------------------------------
    # Query
    # ------------------------------------------------------------------

    def query_project(
        self,
        project_id: str,
        query_text: str,
        n_results: int = 5,
    ) -> list[str]:
        """Return the ``n_results`` most relevant chunk texts for a query.

        Args:
            project_id: Project whose collection will be searched.
            query_text: Natural-language query string.
            n_results: Maximum number of results to return.

        Returns:
            List of text chunks ordered by descending relevance.
            Empty list when the collection has no documents.
        """
        collection = self.get_or_create_project_collection(project_id)

        count: int = collection.count()
        if count == 0:
            logger.debug("Collection empty for project=%s – returning []", project_id)
            return []

        # Cap n_results to the actual number of stored chunks.
        effective_n = min(n_results, count)

        results: QueryResult = collection.query(
            query_texts=[query_text],
            n_results=effective_n,
            include=["documents"],
        )

        # results["documents"] is a list-of-lists (one per query) or None.
        raw_docs = results.get("documents") or [[]]
        docs: list[str] = raw_docs[0] or []
        logger.debug(
            "query_project: project=%s query=%r → %d results",
            project_id,
            query_text[:80],
            len(docs),
        )
        return docs

    # ------------------------------------------------------------------
    # VectorStoreProtocol implementation
    # ------------------------------------------------------------------

    async def search(self, query: str, top_k: int = 5) -> list[str]:
        """Satisfy VectorStoreProtocol.search (global knowledge-base search).

        Note: This adapter is primarily per-project.  The global search
        method searches the built-in ``softarchitect_kb`` collection which
        holds the curated tech-pack knowledge base.

        Args:
            query: Natural-language search query.
            top_k: Maximum number of results.

        Returns:
            Relevant text chunks (may be empty when KB is not ingested).
        """
        try:
            return self.query_project("softarchitect_kb", query, n_results=top_k)
        except Exception as exc:  # noqa: BLE001
            logger.warning("Global KB search failed – returning []: %s", exc)
            return []

    # ------------------------------------------------------------------
    # Utility
    # ------------------------------------------------------------------

    def delete_project_collection(self, project_id: str) -> None:
        """Delete the entire collection for a project (irreversible).

        Useful for cleanup in tests and when a user deletes their project.

        Args:
            project_id: Project whose collection should be deleted.
        """
        collection_name = _COLLECTION_PREFIX + _sanitise_project_id(project_id)
        self._client.delete_collection(collection_name)
        logger.info("Deleted collection for project=%s", project_id)

    def get_project_chunk_count(self, project_id: str) -> int:
        """Return the number of chunks stored for a project.

        Args:
            project_id: Target project identifier.

        Returns:
            Number of stored chunks (0 if collection does not exist yet).
        """
        collection = self.get_or_create_project_collection(project_id)
        return collection.count()
