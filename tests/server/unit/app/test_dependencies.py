"""
Unit tests for shared FastAPI dependencies.

Covers:
- API key verification (verify_api_key)
- Orchestrator factory (get_rag_orchestrator) – Task 13: project_store injection
"""

from unittest.mock import MagicMock, patch

import pytest
from fastapi import HTTPException

from app.api.dependencies import get_rag_orchestrator, verify_api_key


@pytest.mark.asyncio
async def test_verify_api_key_none_raises():
    with pytest.raises(HTTPException):
        await verify_api_key(None)


@pytest.mark.asyncio
async def test_verify_api_key_short_raises():
    with pytest.raises(HTTPException):
        await verify_api_key("short")


@pytest.mark.asyncio
async def test_verify_api_key_ok_returns_key():
    key = "longenoughapikey"
    result = await verify_api_key(key)
    assert result == key


# ---------------------------------------------------------------------------
# Task 13 – get_rag_orchestrator injects ChromaProjectStore
# ---------------------------------------------------------------------------


class TestGetRagOrchestrator:
    """Tests for the get_rag_orchestrator factory function.

    Each test clears the lru_cache before and after execution to prevent
    cross-test contamination from the cached singleton.
    """

    def setup_method(self) -> None:
        """Clear lru_cache before each test."""
        get_rag_orchestrator.cache_clear()

    def teardown_method(self) -> None:
        """Clear lru_cache after each test to restore a clean state."""
        get_rag_orchestrator.cache_clear()

    def test_get_rag_orchestrator_injects_project_store(self) -> None:
        """Verify the factory passes a ChromaProjectStore instance to the orchestrator.

        Task 13 requirement: project_store must be non-None so that the
        sequential orchestrator can perform per-project semantic RAG retrieval.
        """
        mock_project_store = MagicMock()

        with (
            patch("app.api.dependencies.get_llm_client", return_value=MagicMock()),
            patch("app.api.dependencies.VectorStoreService", return_value=MagicMock()),
            patch("app.api.dependencies.WorkflowInjector", return_value=MagicMock()),
            patch("app.api.dependencies.TemplateLoader", return_value=MagicMock()),
            patch(
                "app.infrastructure.vector_store.chroma_store.ChromaProjectStore",
                return_value=mock_project_store,
            ),
        ):
            result = get_rag_orchestrator()

        assert result.project_store is mock_project_store

    def test_get_rag_orchestrator_is_cached(self) -> None:
        """Verify the factory returns the same instance on repeated calls."""
        with (
            patch("app.api.dependencies.get_llm_client", return_value=MagicMock()),
            patch("app.api.dependencies.VectorStoreService", return_value=MagicMock()),
            patch("app.api.dependencies.WorkflowInjector", return_value=MagicMock()),
            patch("app.api.dependencies.TemplateLoader", return_value=MagicMock()),
            patch(
                "app.infrastructure.vector_store.chroma_store.ChromaProjectStore",
                return_value=MagicMock(),
            ),
        ):
            first = get_rag_orchestrator()
            second = get_rag_orchestrator()

        assert first is second

    def test_get_rag_orchestrator_normalises_local_to_ollama(self) -> None:
        """Verify 'local' LLM_PROVIDER is normalised to 'ollama' before client init."""
        with (
            patch("os.getenv", return_value="local"),
            patch(
                "app.api.dependencies.get_llm_client", return_value=MagicMock()
            ) as mock_llm,
            patch("app.api.dependencies.VectorStoreService", return_value=MagicMock()),
            patch("app.api.dependencies.WorkflowInjector", return_value=MagicMock()),
            patch("app.api.dependencies.TemplateLoader", return_value=MagicMock()),
            patch(
                "app.infrastructure.vector_store.chroma_store.ChromaProjectStore",
                return_value=MagicMock(),
            ),
        ):
            get_rag_orchestrator()

        mock_llm.assert_called_once_with(mode="ollama")

    def test_get_rag_orchestrator_normalises_cloud_to_groq(self) -> None:
        """Verify 'cloud' LLM_PROVIDER is normalised to 'groq' before client init."""
        with (
            patch("os.getenv", return_value="cloud"),
            patch(
                "app.api.dependencies.get_llm_client", return_value=MagicMock()
            ) as mock_llm,
            patch("app.api.dependencies.VectorStoreService", return_value=MagicMock()),
            patch("app.api.dependencies.WorkflowInjector", return_value=MagicMock()),
            patch("app.api.dependencies.TemplateLoader", return_value=MagicMock()),
            patch(
                "app.infrastructure.vector_store.chroma_store.ChromaProjectStore",
                return_value=MagicMock(),
            ),
        ):
            get_rag_orchestrator()

        mock_llm.assert_called_once_with(mode="groq")
