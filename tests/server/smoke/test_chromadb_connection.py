"""Smoke test for ChromaDB vector store connectivity.

Tests that the RAG vector store (ChromaDB) is accessible and functional.
"""

import pytest

from app.services.rag.vector_store import VectorStoreService


@pytest.mark.asyncio
async def test_chromadb_connection():
    """
    Smoke Test: ChromaDB should be reachable and responsive.

    Tests basic connectivity to the vector database.
    If this fails, check docker-compose.yml for ChromaDB service.
    """
    try:
        # Create vector store instance (uses env config)
        vector_store = VectorStoreService()

        # Test connection with heartbeat (sync method returns int)
        heartbeat = vector_store.health_check()

        assert heartbeat > 0, "ChromaDB is not responding"

    except ConnectionError as e:
        pytest.fail(f"ChromaDB connection failed: {e}")


@pytest.mark.asyncio
async def test_chromadb_search_basic_query():
    """
    Smoke Test: ChromaDB should accept basic queries.

    Tests that query functionality works (empty results OK).
    """
    vector_store = VectorStoreService()

    # Perform simple query (results not critical)
    results = vector_store.query(
        query_text="test smoke query",
    )

    # Just check it doesn't crash
    assert isinstance(results, dict), "Query should return dict"


@pytest.mark.asyncio
async def test_chromadb_handles_empty_collection():
    """
    Smoke Test: ChromaDB should handle queries to empty/nonexistent collections.

    Graceful failure mode verification.
    """
    vector_store = VectorStoreService()

    # Query with simple text
    results = vector_store.query(
        query_text="test",
    )

    # Should return dict, not crash
    assert isinstance(results, dict)
