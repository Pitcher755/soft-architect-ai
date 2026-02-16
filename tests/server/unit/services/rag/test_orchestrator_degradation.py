"""
Unit tests for RAG orchestrator graceful degradation (HU-4.4 GAP 1).

Tests that orchestrator continues with FALLBACK template when:
- ChromaDB connection fails
- ChromaDB timeout (>30s)
- Generic exceptions from vector store

Critical: System MUST NOT fail when RAG unavailable.
"""

import asyncio
from unittest.mock import AsyncMock, MagicMock, patch
from uuid import uuid4

import pytest

from app.domain.schemas.chat import ChatRequest, ChatResponse
from app.services.rag.orchestrator import RAGOrchestrator


class TestRAGOrchestratorGracefulDegradation:
    """Test graceful degradation when RAG infrastructure fails."""

    @pytest.fixture
    def mock_vector_store(self):
        """Mock vector store for testing."""
        mock = MagicMock()
        mock.search = AsyncMock()
        return mock

    @pytest.fixture
    def mock_template_builder(self):
        """Mock template builder."""
        mock = MagicMock()
        mock.select_template.return_value = "FALLBACK"
        mock.build_prompt.return_value = "Fallback prompt"
        return mock

    @pytest.fixture
    def mock_llm_client(self):
        """Mock LLM client."""
        mock = MagicMock()
        mock.generate = AsyncMock(return_value="Fallback response from LLM")
        mock.stream_generate = AsyncMock()
        return mock

    @pytest.fixture
    def orchestrator(self, mock_vector_store, mock_template_builder, mock_llm_client):
        """Create orchestrator with mocked dependencies."""
        return RAGOrchestrator(
            vector_store=mock_vector_store,
            template_builder=mock_template_builder,
            llm_client=mock_llm_client,
        )

    @pytest.mark.asyncio
    async def test_orchestrator_continues_when_chromadb_fails(
        self, orchestrator, mock_vector_store
    ):
        """
        CRITICAL: Orchestrator MUST continue with sources=[] when vector store fails.

        Scenario: ChromaDB connection error
        Expected: Orchestrator uses FALLBACK template and continues
        """
        # ARRANGE: Mock vector store raises ConnectionError
        mock_vector_store.search.side_effect = ConnectionError("ChromaDB unreachable")

        request = ChatRequest(
            conversation_id=uuid4(),
            message="How to implement auth?",
            project_id=uuid4(),
        )

        # ACT: Process message (should NOT raise exception)
        response = await orchestrator.process_message(request)

        # ASSERT: Response generated with FALLBACK template
        assert isinstance(response, ChatResponse)
        assert response.ai_response == "Fallback response from LLM"
        assert response.template_used == "FALLBACK"
        assert response.sources == []  # No sources due to degradation
        assert "Fallback" in response.ai_response

    @pytest.mark.asyncio
    async def test_orchestrator_logs_warning_not_error_on_degradation(
        self, orchestrator, mock_vector_store
    ):
        """
        Orchestrator should log WARNING (not ERROR) when degrading.

        Rationale: Degradation is expected behavior, not a system error.
        """
        # ARRANGE: Mock vector store failure
        mock_vector_store.search.side_effect = Exception("Vector search failed")

        request = ChatRequest(
            conversation_id=uuid4(),
            message="Test message",
            project_id=uuid4(),
        )

        # ACT & ASSERT: Should log warning
        with patch("app.services.rag.orchestrator.logger") as mock_logger:
            await orchestrator.process_message(request)

            # Should call logger.warning, NOT logger.error
            assert mock_logger.warning.called
            assert not mock_logger.error.called

            # Verify warning message
            warning_call = mock_logger.warning.call_args
            assert "degraded" in str(warning_call).lower()

    @pytest.mark.asyncio
    async def test_orchestrator_handles_chromadb_connection_error(
        self, orchestrator, mock_vector_store
    ):
        """Test specific handling of ConnectionError from ChromaDB."""
        mock_vector_store.search.side_effect = ConnectionError("Connection refused")

        request = ChatRequest(
            conversation_id=uuid4(),
            message="Test",
            project_id=uuid4(),
        )

        # Should NOT raise exception
        response = await orchestrator.process_message(request)

        assert response is not None
        assert response.sources == []

    @pytest.mark.asyncio
    async def test_orchestrator_handles_chromadb_timeout_error(
        self, orchestrator, mock_vector_store
    ):
        """Test handling of asyncio.TimeoutError (30s timeout)."""
        mock_vector_store.search.side_effect = asyncio.TimeoutError()

        request = ChatRequest(
            conversation_id=uuid4(),
            message="Test",
            project_id=uuid4(),
        )

        # Should NOT raise exception
        response = await orchestrator.process_message(request)

        assert response is not None
        assert response.sources == []

    @pytest.mark.asyncio
    async def test_orchestrator_handles_generic_vector_store_exception(
        self, orchestrator, mock_vector_store
    ):
        """Test handling of generic Exception from vector store."""
        mock_vector_store.search.side_effect = RuntimeError("Unexpected error")

        request = ChatRequest(
            conversation_id=uuid4(),
            message="Test",
            project_id=uuid4(),
        )

        # Should NOT raise exception
        response = await orchestrator.process_message(request)

        assert response is not None
        assert response.sources == []

    @pytest.mark.asyncio
    async def test_orchestrator_applies_30s_timeout_to_rag_search(
        self, orchestrator, mock_vector_store
    ):
        """
        CRITICAL: RAG search MUST have 30s timeout to prevent indefinite waits.

        Scenario: ChromaDB hangs for >30s
        Expected: Timeout triggers, orchestrator continues with degradation
        """

        # ARRANGE: Mock vector store that takes 35 seconds
        async def slow_search(*args, **kwargs):
            await asyncio.sleep(35)
            return ["doc1", "doc2"]

        mock_vector_store.search = slow_search

        request = ChatRequest(
            conversation_id=uuid4(),
            message="Test",
            project_id=uuid4(),
        )

        # ACT: Process with timeout
        start_time = asyncio.get_event_loop().time()
        response = await orchestrator.process_message(request)
        elapsed_time = asyncio.get_event_loop().time() - start_time

        # ASSERT: Should timeout after ~30s, not 35s
        assert elapsed_time < 32  # Allow 2s margin for test overhead
        assert response.sources == []  # Degraded due to timeout

    @pytest.mark.asyncio
    async def test_orchestrator_stream_degrades_when_chromadb_fails(
        self, orchestrator, mock_vector_store, mock_llm_client
    ):
        """Test streaming variant also degrades gracefully."""
        mock_vector_store.search.side_effect = ConnectionError("ChromaDB down")

        # Mock stream_generate to return async generator
        async def mock_stream():
            yield "Chunk 1 "
            yield "Chunk 2"

        # Use side_effect to return new generator on each call
        mock_llm_client.stream_generate = MagicMock(side_effect=lambda _: mock_stream())

        request = ChatRequest(
            conversation_id=uuid4(),
            message="Test streaming",
            project_id=uuid4(),
        )

        # ACT: Stream response
        events = []
        async for event in orchestrator.process_message_stream(request):
            events.append(event)

        # ASSERT: Should stream response despite ChromaDB failure
        assert len(events) > 0

        # Should have token events
        token_events = [e for e in events if e.get("type") == "token"]
        assert len(token_events) > 0

        # Should have done event with FALLBACK template
        done_events = [e for e in events if e.get("type") == "done"]
        assert len(done_events) == 1
        assert done_events[0]["data"]["metadata"]["template_used"] == "FALLBACK"
        assert done_events[0]["data"]["sources"] == []
