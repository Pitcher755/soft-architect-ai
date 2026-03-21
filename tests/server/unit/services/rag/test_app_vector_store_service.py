"""Unit tests for the app-level VectorStoreService stub.

Covers:
- VectorStoreService.__init__ (line 22)
- VectorStoreService.query return value (line 38)
- VectorStoreService.health_check return value (line 42)
"""

from app.services.rag.vector_store import VectorStoreService


class TestAppVectorStoreService:
    """Tests for the app-layer VectorStoreService stub implementation."""

    def test_init_creates_instance(self):
        """Constructor should create a valid instance with no args."""
        service = VectorStoreService()
        assert service is not None

    def test_init_accepts_positional_and_keyword_args(self):
        """Constructor should accept arbitrary args/kwargs gracefully."""
        service = VectorStoreService("localhost", port=8000, collection_name="test")
        assert service is not None

    def test_query_returns_empty_structure(self):
        """query() returns an empty dict with required keys."""
        service = VectorStoreService()
        result = service.query("what is hexagonal architecture?")

        assert result == {"docs": [], "metadatas": [], "distances": []}

    def test_query_returns_correct_keys(self):
        """query() always returns the three required keys."""
        service = VectorStoreService()
        result = service.query("test")

        assert "docs" in result
        assert "metadatas" in result
        assert "distances" in result

    def test_health_check_returns_one(self):
        """health_check() returns stub heartbeat value 1."""
        service = VectorStoreService()
        result = service.health_check()

        assert result == 1
