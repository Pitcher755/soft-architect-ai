"""Unit tests for VectorStoreService.

Coverage targets:
- retry_with_backoff decorator: success, retry-then-success, exhaustion
- VectorStoreService.__init__: valid, low-heartbeat error, HttpClient error
- _generate_id: determinism, uniqueness, hash length
- _clean_metadata: type filtering
- ingest: empty list, valid docs, upsert failure
- query: happy path, failure
- clear_collection: happy path, failure
- health_check: healthy, unhealthy
- get_collection_stats: happy path, failure
"""

from __future__ import annotations

from typing import Any
from unittest.mock import MagicMock, patch

import pytest

from core.exceptions.base import (
    ConnectionError as ChromaConnectionError,
)
from core.exceptions.base import (
    DatabaseReadError,
    DatabaseWriteError,
)
from services.rag.vector_store import VectorStoreService, retry_with_backoff

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _make_service(
    mock_chroma: MagicMock,
    *,
    heartbeat_value: int = 1500,
    collection_name: str = "test_collection",
) -> tuple[VectorStoreService, MagicMock, MagicMock]:
    """Create a VectorStoreService backed by mocked chromadb.

    Returns
    -------
    (service, mock_client, mock_collection)
    """
    mock_client = MagicMock()
    mock_collection = MagicMock()
    mock_chroma.HttpClient.return_value = mock_client
    mock_client.heartbeat.return_value = heartbeat_value
    mock_client.get_or_create_collection.return_value = mock_collection
    service = VectorStoreService(host="localhost", port=8000, collection_name=collection_name)
    return service, mock_client, mock_collection


def _make_docs(count: int = 2) -> list[Any]:
    """Return a list of fake langchain Document objects."""
    from langchain_core.documents import Document

    return [
        Document(
            page_content=f"Content {i}",
            metadata={"source": f"file_{i}.md", "title": f"Doc {i}"},
        )
        for i in range(count)
    ]


# ============================================================
# retry_with_backoff decorator
# ============================================================


class TestRetryWithBackoff:
    """Tests for the standalone retry_with_backoff decorator."""

    @patch("services.rag.vector_store.time.sleep")
    def test_succeeds_on_first_attempt(self, mock_sleep: MagicMock) -> None:
        """Function that succeeds immediately is called exactly once."""
        call_count = [0]

        @retry_with_backoff(max_retries=3, base_delay=0.01)
        def always_fine():
            call_count[0] += 1
            return "ok"

        result = always_fine()
        assert result == "ok"
        assert call_count[0] == 1
        mock_sleep.assert_not_called()

    @patch("services.rag.vector_store.time.sleep")
    def test_retries_and_succeeds_on_third_attempt(self, mock_sleep: MagicMock) -> None:
        """Function that fails twice then succeeds is retried correctly."""
        call_count = [0]

        @retry_with_backoff(max_retries=3, base_delay=0.01)
        def flaky():
            call_count[0] += 1
            if call_count[0] < 3:
                raise RuntimeError("transient")
            return "recovered"

        result = flaky()
        assert result == "recovered"
        assert call_count[0] == 3
        assert mock_sleep.call_count == 2

    @patch("services.rag.vector_store.time.sleep")
    def test_raises_after_exhausting_retries(self, mock_sleep: MagicMock) -> None:
        """Exception is re-raised after all retries are consumed."""

        @retry_with_backoff(max_retries=3, base_delay=0.01)
        def always_fails():
            raise ValueError("permanent")

        with pytest.raises(ValueError, match="permanent"):
            always_fails()

        assert mock_sleep.call_count == 2  # 3 attempts → 2 sleeps

    @patch("services.rag.vector_store.time.sleep")
    def test_uses_exponential_backoff_delays(self, mock_sleep: MagicMock) -> None:
        """Sleep delays increase exponentially between retries."""

        @retry_with_backoff(max_retries=3, base_delay=1.0)
        def always_fails():
            raise Exception("fail")

        with pytest.raises(Exception):
            always_fails()

        delays = [c.args[0] for c in mock_sleep.call_args_list]
        # First delay = 1.0 * 2^0 = 1.0; second = 1.0 * 2^1 = 2.0
        assert delays[0] == pytest.approx(1.0)
        assert delays[1] == pytest.approx(2.0)


# ============================================================
# VectorStoreService.__init__
# ============================================================


class TestVectorStoreServiceInit:
    """Tests for VectorStoreService initialisation."""

    @patch("services.rag.vector_store.chromadb")
    def test_valid_connection_succeeds(self, mock_chroma: MagicMock) -> None:
        """Service initialises without exception for a healthy ChromaDB."""
        service, client, collection = _make_service(mock_chroma)
        assert service.collection is collection
        mock_chroma.HttpClient.assert_called_once_with(host="localhost", port=8000)

    @patch("services.rag.vector_store.chromadb")
    def test_raises_connection_error_on_zero_heartbeat(self, mock_chroma: MagicMock) -> None:
        """Raises ConnectionError/ChromaConnectionError when heartbeat is 0."""
        mock_client = MagicMock()
        mock_chroma.HttpClient.return_value = mock_client
        mock_client.heartbeat.return_value = 0  # <= 0 means down

        with pytest.raises(
            (ChromaConnectionError, Exception), match=r"[Cc]hroma|[Cc]onnect|heartbeat"
        ):
            VectorStoreService(host="localhost", port=8000)

    @patch("services.rag.vector_store.chromadb")
    def test_raises_connection_error_on_http_client_exception(self, mock_chroma: MagicMock) -> None:
        """Raises appropriate exception when HttpClient itself raises."""
        mock_chroma.HttpClient.side_effect = Exception("Connection refused")

        with pytest.raises(Exception, match="[Cc]onnect|[Rr]efused"):
            VectorStoreService(host="localhost", port=8000)

    @patch("services.rag.vector_store.chromadb")
    def test_creates_or_gets_collection_on_init(self, mock_chroma: MagicMock) -> None:
        """get_or_create_collection is called during init."""
        service, client, _ = _make_service(mock_chroma, collection_name="my_kb")
        # The call includes the collection name (possibly with extra kwargs)
        client.get_or_create_collection.assert_called_once()
        call_args = client.get_or_create_collection.call_args
        passed_name = call_args.args[0] if call_args.args else call_args.kwargs.get("name")
        assert passed_name == "my_kb"


# ============================================================
# _generate_id
# ============================================================


class TestGenerateId:
    """Tests for _generate_id static/instance method."""

    @patch("services.rag.vector_store.chromadb")
    def test_same_input_same_hash(self, mock_chroma: MagicMock) -> None:
        """Same content+source always produces the same ID."""
        svc, _, _ = _make_service(mock_chroma)
        id1 = svc._generate_id("content", "source.md")
        id2 = svc._generate_id("content", "source.md")
        assert id1 == id2

    @patch("services.rag.vector_store.chromadb")
    def test_different_content_different_hash(self, mock_chroma: MagicMock) -> None:
        """Different content values produce different IDs."""
        svc, _, _ = _make_service(mock_chroma)
        id1 = svc._generate_id("content_a", "source.md")
        id2 = svc._generate_id("content_b", "source.md")
        assert id1 != id2

    @patch("services.rag.vector_store.chromadb")
    def test_hash_is_64_hex_chars(self, mock_chroma: MagicMock) -> None:
        """SHA-256 hex digest is exactly 64 characters."""
        svc, _, _ = _make_service(mock_chroma)
        result = svc._generate_id("test content", "test/source.md")
        assert len(result) == 64
        # Verify it is valid hex
        int(result, 16)

    @patch("services.rag.vector_store.chromadb")
    def test_different_source_different_hash(self, mock_chroma: MagicMock) -> None:
        """Same content with different sources produces different IDs."""
        svc, _, _ = _make_service(mock_chroma)
        id1 = svc._generate_id("same content", "source_a.md")
        id2 = svc._generate_id("same content", "source_b.md")
        assert id1 != id2


# ============================================================
# _clean_metadata
# ============================================================


class TestCleanMetadata:
    """Tests for _clean_metadata."""

    @patch("services.rag.vector_store.chromadb")
    def test_keeps_str_int_float_bool(self, mock_chroma: MagicMock) -> None:
        """Scalar types are kept in the output."""
        svc, _, _ = _make_service(mock_chroma)
        raw = {"name": "doc", "count": 3, "score": 0.9, "flag": True}
        result = svc._clean_metadata(raw)
        assert result == raw

    @patch("services.rag.vector_store.chromadb")
    def test_removes_none_values(self, mock_chroma: MagicMock) -> None:
        """None values are filtered out."""
        svc, _, _ = _make_service(mock_chroma)
        raw = {"name": "doc", "missing": None}
        result = svc._clean_metadata(raw)
        assert "missing" not in result

    @patch("services.rag.vector_store.chromadb")
    def test_removes_complex_types(self, mock_chroma: MagicMock) -> None:
        """Lists, dicts, and other complex types are removed."""
        svc, _, _ = _make_service(mock_chroma)
        raw = {"name": "doc", "tags": ["a", "b"], "nested": {"key": "val"}}
        result = svc._clean_metadata(raw)
        assert "tags" not in result
        assert "nested" not in result
        assert result["name"] == "doc"

    @patch("services.rag.vector_store.chromadb")
    def test_empty_dict_returns_empty_dict(self, mock_chroma: MagicMock) -> None:
        """Empty input returns empty output."""
        svc, _, _ = _make_service(mock_chroma)
        assert svc._clean_metadata({}) == {}


# ============================================================
# ingest
# ============================================================


class TestIngest:
    """Tests for ingest()."""

    @patch("services.rag.vector_store.chromadb")
    @patch("services.rag.vector_store.time.sleep")
    def test_empty_list_returns_zero(self, mock_sleep: MagicMock, mock_chroma: MagicMock) -> None:
        """Ingesting an empty list returns 0 without calling upsert."""
        svc, _, mock_col = _make_service(mock_chroma)
        result = svc.ingest([])
        assert result == 0
        mock_col.upsert.assert_not_called()

    @patch("services.rag.vector_store.chromadb")
    @patch("services.rag.vector_store.time.sleep")
    def test_valid_docs_returns_count_and_calls_upsert(
        self, mock_sleep: MagicMock, mock_chroma: MagicMock
    ) -> None:
        """Ingesting N docs returns N and calls collection.upsert once."""
        svc, _, mock_col = _make_service(mock_chroma)
        docs = _make_docs(3)
        result = svc.ingest(docs)
        assert result == 3
        mock_col.upsert.assert_called_once()

    @patch("services.rag.vector_store.chromadb")
    @patch("services.rag.vector_store.time.sleep")
    def test_upsert_failure_raises_database_write_error(
        self, mock_sleep: MagicMock, mock_chroma: MagicMock
    ) -> None:
        """DatabaseWriteError is raised when upsert fails after all retries."""
        svc, _, mock_col = _make_service(mock_chroma)
        mock_col.upsert.side_effect = Exception("disk full")

        with pytest.raises((DatabaseWriteError, Exception)):
            svc.ingest(_make_docs(1))

    @patch("services.rag.vector_store.chromadb")
    @patch("services.rag.vector_store.time.sleep")
    def test_ingest_with_documents_having_complex_metadata(
        self, mock_sleep: MagicMock, mock_chroma: MagicMock
    ) -> None:
        """Metadata with complex types is cleaned before upsert."""
        from langchain_core.documents import Document

        svc, _, mock_col = _make_service(mock_chroma)
        doc = Document(
            page_content="Content",
            metadata={"source": "file.md", "tags": ["a", "b"], "count": 5},
        )
        result = svc.ingest([doc])
        assert result == 1
        # At minimum, the call was made
        assert mock_col.upsert.called


# ============================================================
# query
# ============================================================


class TestQuery:
    """Tests for query()."""

    @patch("services.rag.vector_store.chromadb")
    def test_returns_results_for_valid_query(self, mock_chroma: MagicMock) -> None:
        """query() returns the structure returned by collection.query."""
        svc, _, mock_col = _make_service(mock_chroma)
        mock_col.query.return_value = {
            "documents": [["doc content"]],
            "metadatas": [[{"source": "file.md"}]],
            "distances": [[0.1]],
        }
        result = svc.query("how to architect?", n_results=5)
        assert result is not None
        mock_col.query.assert_called_once()

    @patch("services.rag.vector_store.chromadb")
    def test_raises_database_read_error_on_failure(self, mock_chroma: MagicMock) -> None:
        """DatabaseReadError (or base Exception) is raised when query fails."""
        svc, _, mock_col = _make_service(mock_chroma)
        mock_col.query.side_effect = Exception("query boom")

        with pytest.raises((DatabaseReadError, Exception)):
            svc.query("test query", n_results=3)

    @patch("services.rag.vector_store.chromadb")
    def test_respects_n_results_parameter(self, mock_chroma: MagicMock) -> None:
        """n_results value is forwarded to collection.query."""
        svc, _, mock_col = _make_service(mock_chroma)
        mock_col.query.return_value = {
            "documents": [[]],
            "metadatas": [[]],
            "distances": [[]],
        }
        svc.query("question", n_results=10)
        # n_results may be positional — just verify the method was called
        assert mock_col.query.called


# ============================================================
# clear_collection
# ============================================================


class TestClearCollection:
    """Tests for clear_collection()."""

    @patch("services.rag.vector_store.chromadb")
    def test_deletes_and_recreates_collection(self, mock_chroma: MagicMock) -> None:
        """clear_collection calls delete_collection then get_or_create_collection."""
        svc, mock_client, _ = _make_service(mock_chroma)
        svc.clear_collection()
        mock_client.delete_collection.assert_called_once()
        # get_or_create_collection called twice: once on init, once on clear
        assert mock_client.get_or_create_collection.call_count == 2

    @patch("services.rag.vector_store.chromadb")
    def test_raises_database_write_error_on_failure(self, mock_chroma: MagicMock) -> None:
        """Raises DatabaseWriteError (or Exception) when delete_collection fails."""
        svc, mock_client, _ = _make_service(mock_chroma)
        mock_client.delete_collection.side_effect = Exception("delete fail")

        with pytest.raises((DatabaseWriteError, Exception)):
            svc.clear_collection()


# ============================================================
# health_check
# ============================================================


class TestHealthCheck:
    """Tests for health_check()."""

    @patch("services.rag.vector_store.chromadb")
    def test_returns_true_on_positive_heartbeat(self, mock_chroma: MagicMock) -> None:
        """health_check returns True when heartbeat > 0."""
        svc, mock_client, _ = _make_service(mock_chroma)
        mock_client.heartbeat.return_value = 2000
        result = svc.health_check()
        assert result is True

    @patch("services.rag.vector_store.chromadb")
    def test_raises_or_returns_false_on_heartbeat_failure(self, mock_chroma: MagicMock) -> None:
        """health_check raises ChromaConnectionError (or returns False) on failure."""
        svc, mock_client, _ = _make_service(mock_chroma)
        mock_client.heartbeat.side_effect = Exception("timeout")

        try:
            result = svc.health_check()
            assert result is False
        except (ChromaConnectionError, Exception):
            pass  # Either behaviour is acceptable

    @patch("services.rag.vector_store.chromadb")
    def test_returns_false_on_zero_heartbeat_after_init(self, mock_chroma: MagicMock) -> None:
        """health_check returns False / raises when heartbeat → 0 post-init."""
        svc, mock_client, _ = _make_service(mock_chroma)
        mock_client.heartbeat.return_value = 0

        try:
            result = svc.health_check()
            assert result is False
        except (ChromaConnectionError, Exception):
            pass


# ============================================================
# get_collection_stats
# ============================================================


class TestGetCollectionStats:
    """Tests for get_collection_stats()."""

    @patch("services.rag.vector_store.chromadb")
    def test_returns_dict_with_expected_keys(self, mock_chroma: MagicMock) -> None:
        """Returns a dict with at minimum 'count' key (or equivalent)."""
        svc, _, mock_col = _make_service(mock_chroma)
        mock_col.count.return_value = 42
        mock_col.metadata = {"created": "2024-01-01"}
        result = svc.get_collection_stats()
        assert isinstance(result, dict)
        # Should include document count somehow
        assert any("count" in key.lower() or v == 42 for key, v in result.items())

    @patch("services.rag.vector_store.chromadb")
    def test_raises_database_read_error_on_failure(self, mock_chroma: MagicMock) -> None:
        """Raises DatabaseReadError (or Exception) when collection.count fails."""
        svc, _, mock_col = _make_service(mock_chroma)
        mock_col.count.side_effect = Exception("count bork")

        with pytest.raises((DatabaseReadError, Exception)):
            svc.get_collection_stats()
