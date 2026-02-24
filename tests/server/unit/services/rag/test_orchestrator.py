"""Unit tests for RAG Orchestrator (core business logic)."""

from unittest.mock import AsyncMock, MagicMock
from uuid import uuid4

import pytest

from app.core.exceptions import LLMConnectionError
from app.domain.schemas.chat import ChatRequest, ChatResponse
from app.services.rag.orchestrator import RAGOrchestrator


class TestRAGOrchestrator:
    """Test RAG orchestration logic."""

    @pytest.fixture
    def mock_vector_store(self):
        """Mock ChromaDB vector store."""
        mock = AsyncMock()
        mock.search.return_value = ["Doc1 context", "Doc2 context"]
        return mock

    @pytest.fixture
    def mock_template_builder(self):
        """Mock template builder."""
        mock = MagicMock()
        mock.select_template.return_value = "20-PLANNING"
        mock.build_prompt.return_value = (
            "System: You are an AI assistant.\n\n"
            "Context: Doc1, Doc2\n\n"
            "User: How to test?"
        )
        return mock

    @pytest.fixture
    def mock_llm_client(self):
        """Mock LLM client."""
        mock = AsyncMock()
        mock.generate.return_value = "This is the AI response based on context."
        return mock

    @pytest.mark.asyncio
    async def test_orchestrator_happy_path(
        self,
        mock_vector_store,
        mock_template_builder,
        mock_llm_client,
    ):
        """Happy path: All services respond successfully."""
        orchestrator = RAGOrchestrator(
            vector_store=mock_vector_store,
            template_builder=mock_template_builder,
            llm_client=mock_llm_client,
        )

        request = ChatRequest(
            conversation_id=uuid4(),
            message="How to test in Python?",
            project_id=uuid4(),
        )

        response = await orchestrator.process_message(request)

        assert isinstance(response, ChatResponse)
        assert response.ai_response == "This is the AI response based on context."
        # Dual-channel combines master examples + user context
        assert any("Doc" in src for src in response.sources)
        assert response.template_used is not None

        # Dual-channel calls search twice (user + master query)
        assert mock_vector_store.search.call_count >= 1
        mock_template_builder.build_prompt.assert_called_once()
        mock_llm_client.generate.assert_called_once()

    @pytest.mark.asyncio
    async def test_orchestrator_empty_vector_results(
        self,
        mock_vector_store,
        mock_template_builder,
        mock_llm_client,
    ):
        """No vector results: Should use fallback template."""
        mock_vector_store.search.return_value = []
        mock_template_builder.build_prompt.return_value = (
            "System: No context available. Answer generically."
        )

        orchestrator = RAGOrchestrator(
            vector_store=mock_vector_store,
            template_builder=mock_template_builder,
            llm_client=mock_llm_client,
        )

        request = ChatRequest(
            conversation_id=uuid4(),
            message="Random question",
            project_id=uuid4(),
        )

        response = await orchestrator.process_message(request)

        assert response.sources == []
        assert response.template_used == "FALLBACK"
        mock_llm_client.generate.assert_called_once()

    @pytest.mark.asyncio
    async def test_orchestrator_llm_failure_raises_exception(
        self,
        mock_vector_store,
        mock_template_builder,
        mock_llm_client,
    ):
        """LLM connection failure: Should raise LLMConnectionError."""
        mock_llm_client.generate.side_effect = LLMConnectionError("Ollama is down")

        orchestrator = RAGOrchestrator(
            vector_store=mock_vector_store,
            template_builder=mock_template_builder,
            llm_client=mock_llm_client,
        )

        request = ChatRequest(
            conversation_id=uuid4(),
            message="Test",
            project_id=uuid4(),
        )

        with pytest.raises(LLMConnectionError):
            await orchestrator.process_message(request)

    @pytest.mark.asyncio
    async def test_orchestrator_vector_failure_degrades_gracefully(
        self,
        mock_vector_store,
        mock_template_builder,
        mock_llm_client,
    ):
        """Vector store failure: Should degrade gracefully (HU-4.4 GAP 1).

        After implementing graceful degradation, ChromaDB failures no longer
        raise RAGRetrievalError. Instead, the system continues with empty
        sources and FALLBACK template, ensuring 100% availability.
        """
        mock_vector_store.search.side_effect = Exception("ChromaDB connection failed")

        orchestrator = RAGOrchestrator(
            vector_store=mock_vector_store,
            template_builder=mock_template_builder,
            llm_client=mock_llm_client,
        )

        request = ChatRequest(
            conversation_id=uuid4(),
            message="Test",
            project_id=uuid4(),
        )

        # Should NOT raise exception, should complete successfully
        response = await orchestrator.process_message(request)

        # Verify graceful degradation behavior
        assert isinstance(response, ChatResponse)
        assert response.sources == []  # Empty sources due to ChromaDB failure
        assert response.template_used == "FALLBACK"  # Fallback template used
        assert response.ai_response is not None  # LLM still generated response
