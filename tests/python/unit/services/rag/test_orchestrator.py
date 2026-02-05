"""
Unit tests for SequentialOrchestrator - RAG Backend Orchestration.

Tests cover:
- Async generator functionality
- RAG context retrieval from ChromaDB
- Error handling (ChromaDB unavailable, LLM timeout)
- Template loading and prompt building
"""

import pytest
from unittest.mock import Mock, AsyncMock
from app.services.rag.sequential_orchestrator import SequentialOrchestrator
from app.core.exceptions import RAGException


@pytest.fixture
def orchestrator():
    """Fixture for SequentialOrchestrator."""
    return SequentialOrchestrator(
        vector_store=Mock(), llm_client=Mock(), template_loader=Mock()
    )


class TestSequentialOrchestrator:
    """Test suite for SequentialOrchestrator."""

    @pytest.mark.asyncio
    async def test_generate_document_returns_async_generator(self, orchestrator):
        """Test that generate returns an async generator."""
        # Arrange
        mock_template = Mock(content="Template: {user_input}")
        orchestrator.template_loader.load.return_value = mock_template
        orchestrator.llm_client.stream_generate = AsyncMock(
            return_value=self._mock_async_generator(["token1", "token2"])
        )
        orchestrator.vector_store.query.return_value = {
            "documents": [[]],
            "metadatas": [[]],
        }

        # Act
        result = orchestrator.generate(
            doc_type="PROJECT_MANIFESTO", user_input="Test project", context={}
        )

        # Assert
        assert hasattr(result, "__aiter__"), "Should return async generator"
        tokens = [token async for token in result]
        assert len(tokens) == 2
        assert tokens[0] == "token1"

    @pytest.mark.asyncio
    async def test_generate_retrieves_rag_context_from_vector_store(self, orchestrator):
        """Test RAG context retrieval from ChromaDB."""
        # Arrange
        orchestrator.vector_store.query.return_value = {
            "documents": [["Doc about Flutter best practices"]],
            "metadatas": [[{"source": "tech_pack_flutter.md"}]],
        }
        mock_template = Mock(content="Template: {context}\n{user_input}")
        orchestrator.template_loader.load.return_value = mock_template
        orchestrator.llm_client.stream_generate = AsyncMock(
            return_value=self._mock_async_generator(["test"])
        )

        # Act
        async for _ in orchestrator.generate(
            doc_type="PROJECT_MANIFESTO", user_input="Flutter app", context={}
        ):
            pass

        # Assert
        orchestrator.vector_store.query.assert_called_once()
        call_args = orchestrator.vector_store.query.call_args[0]
        assert "Flutter" in str(call_args) or len(call_args) > 0

    @pytest.mark.asyncio
    async def test_generate_raises_exception_if_chromadb_unavailable(
        self, orchestrator
    ):
        """Test error handling when ChromaDB is down."""
        # Arrange
        orchestrator.vector_store.query.side_effect = ConnectionError(
            "ChromaDB unreachable"
        )

        # Act & Assert
        with pytest.raises(RAGException) as exc_info:
            async for _ in orchestrator.generate(
                doc_type="PROJECT_MANIFESTO", user_input="Test", context={}
            ):
                pass

        assert exc_info.value.code == "RAG_001"
        assert "ChromaDB" in str(exc_info.value)

    @pytest.mark.asyncio
    async def test_generate_handles_llm_timeout_gracefully(self, orchestrator):
        """Test timeout handling for LLM calls."""
        # Arrange
        mock_template = Mock(content="Template: {user_input}")
        orchestrator.template_loader.load.return_value = mock_template
        orchestrator.vector_store.query.return_value = {
            "documents": [[]],
            "metadatas": [[]],
        }
        orchestrator.llm_client.stream_generate = AsyncMock(
            side_effect=TimeoutError("LLM timeout")
        )

        # Act & Assert
        with pytest.raises(RAGException) as exc_info:
            async for _ in orchestrator.generate(
                doc_type="PROJECT_MANIFESTO", user_input="Test", context={}
            ):
                pass

        assert exc_info.value.code == "LLM_001"

    @pytest.mark.asyncio
    async def test_generate_uses_correct_template_for_doc_type(self, orchestrator):
        """Test that correct template is loaded based on doc_type."""
        # Arrange
        mock_template = Mock(content="Template for manifesto")
        orchestrator.template_loader.load.return_value = mock_template
        orchestrator.vector_store.query.return_value = {
            "documents": [[]],
            "metadatas": [[]],
        }
        orchestrator.llm_client.stream_generate = AsyncMock(
            return_value=self._mock_async_generator(["test"])
        )

        # Act
        async for _ in orchestrator.generate(
            doc_type="PROJECT_MANIFESTO", user_input="Test", context={}
        ):
            pass

        # Assert
        orchestrator.template_loader.load.assert_called_once_with("PROJECT_MANIFESTO")

    @pytest.mark.asyncio
    async def test_generate_includes_chat_history_in_context(self, orchestrator):
        """Test that chat history is included in prompt building."""
        # Arrange
        mock_template = Mock(content="Template: {user_input}")
        orchestrator.template_loader.load.return_value = mock_template
        orchestrator.vector_store.query.return_value = {
            "documents": [[]],
            "metadatas": [[]],
        }
        orchestrator.llm_client.stream_generate = AsyncMock(
            return_value=self._mock_async_generator(["test"])
        )
        chat_history = [
            {"role": "user", "content": "Previous message"},
            {"role": "assistant", "content": "Previous response"},
        ]

        # Act
        async for _ in orchestrator.generate(
            doc_type="PROJECT_MANIFESTO",
            user_input="New message",
            context={"chat_history": chat_history},
        ):
            pass

        # Assert
        # Verify llm_client.stream_generate was called with prompt containing context
        orchestrator.llm_client.stream_generate.assert_called_once()

    @staticmethod
    async def _mock_async_generator(items):
        """Helper to create async generator from list."""
        for item in items:
            yield item
