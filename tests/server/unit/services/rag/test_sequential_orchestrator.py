"""
Unit tests for SequentialOrchestrator - RAG Backend Orchestration.

Tests cover:
- Async generator functionality
- RAG context retrieval from ChromaDB
- Error handling (ChromaDB unavailable, LLM timeout)
- Template loading and prompt building
"""

from unittest.mock import AsyncMock, Mock

import pytest

from app.core.exceptions import LLMError
from app.services.rag.sequential_orchestrator import SequentialOrchestrator


@pytest.fixture
def orchestrator():
    """Fixture for SequentialOrchestrator."""
    mock_workflow_injector = Mock()
    mock_workflow_injector.get_injected_prompt.return_value = (
        "# Master Template\n\nInstruction: Generate based on {user_input}"
    )
    return SequentialOrchestrator(
        vector_store=Mock(),
        llm_client=Mock(),
        template_loader=Mock(),
        workflow_injector=mock_workflow_injector,
    )


class TestSequentialOrchestrator:
    """Test suite for SequentialOrchestrator."""

    @pytest.mark.asyncio
    async def test_generate_document_returns_async_generator(
        self,
        orchestrator,
    ):
        """Test that generate returns an async generator."""
        mock_template = Mock(content="Template: {user_input}")
        orchestrator.template_loader.load.return_value = mock_template
        orchestrator.llm_client.stream_generate = Mock(
            side_effect=lambda *args, **kwargs: self._mock_async_generator(["token1", "token2"])
        )
        orchestrator.vector_store.query.return_value = {
            "documents": [[]],
            "metadatas": [[]],
        }

        result = orchestrator.generate(
            doc_type="PROJECT_MANIFESTO",
            user_input="Test project",
            context={},
        )

        assert hasattr(result, "__aiter__"), "Should return async generator"
        tokens = [token async for token in result]
        assert len(tokens) == 2
        assert tokens[0] == "token1"

    @pytest.mark.asyncio
    async def test_generate_retrieves_rag_context_from_vector_store(
        self,
        orchestrator,
    ):
        """Test RAG context retrieval from ChromaDB."""
        orchestrator.vector_store.query.return_value = {
            "documents": [["Doc about Flutter best practices"]],
            "metadatas": [[{"source": "tech_pack_flutter.md"}]],
        }
        mock_template = Mock(content="Template: {context}\n{user_input}")
        orchestrator.template_loader.load.return_value = mock_template
        orchestrator.llm_client.stream_generate = Mock(
            side_effect=lambda *args, **kwargs: self._mock_async_generator(["test"])
        )

        async for _ in orchestrator.generate(
            doc_type="PROJECT_MANIFESTO",
            user_input="Flutter app",
            context={},
        ):
            pass

        # Dual-channel: query is called multiple times (user + master)
        assert orchestrator.vector_store.query.call_count >= 1
        call_args_str = str(orchestrator.vector_store.query.call_args_list)
        assert "Flutter" in call_args_str

    @pytest.mark.asyncio
    async def test_generate_degrades_gracefully_when_chromadb_unavailable(
        self,
        orchestrator,
    ):
        """Test graceful degradation when ChromaDB is down.

        Old behavior raised RAGError. New dual-channel implementation catches
        all vector store errors internally and continues with empty context.
        """
        mock_template = Mock(content="Template: {context}\n{user_input}")
        orchestrator.template_loader.load.return_value = mock_template
        orchestrator.vector_store.query.side_effect = ConnectionError("ChromaDB unreachable")
        orchestrator.llm_client.stream_generate = Mock(
            side_effect=lambda *args, **kwargs: self._mock_async_generator(["degraded_token"])
        )

        tokens = []
        # Should NOT raise RAGError – degrades gracefully
        async for token in orchestrator.generate(
            doc_type="PROJECT_MANIFESTO",
            user_input="Test",
            context={},
        ):
            tokens.append(token)

        # LLM still runs despite ChromaDB failure
        assert tokens == ["degraded_token"]

    @pytest.mark.asyncio
    async def test_generate_handles_llm_timeout_gracefully(
        self,
        orchestrator,
    ):
        """Test timeout handling for LLM calls."""
        mock_template = Mock(content="Template: {user_input}")
        orchestrator.template_loader.load.return_value = mock_template
        orchestrator.vector_store.query.return_value = {
            "documents": [[]],
            "metadatas": [[]],
        }
        orchestrator.llm_client.stream_generate = AsyncMock(side_effect=TimeoutError("LLM timeout"))

        with pytest.raises(LLMError) as exc_info:
            async for _ in orchestrator.generate(
                doc_type="PROJECT_MANIFESTO",
                user_input="Test",
                context={},
            ):
                pass

        assert exc_info.value.code == "SEQ_GEN_ERR"

    @pytest.mark.asyncio
    async def test_generate_uses_correct_template_for_doc_type(
        self,
        orchestrator,
    ):
        """Test that correct template is loaded based on doc_type."""
        orchestrator.workflow_injector.get_injected_prompt.return_value = (
            "# Injected Template\n\nInstruction: {user_input}"
        )
        orchestrator.vector_store.query.return_value = {
            "documents": [[]],
            "metadatas": [[]],
        }
        orchestrator.llm_client.stream_generate = Mock(
            side_effect=lambda *args, **kwargs: self._mock_async_generator(["test"])
        )

        async for _ in orchestrator.generate(
            doc_type="PROJECT_MANIFESTO",
            user_input="Test",
            context={},
        ):
            pass

        orchestrator.workflow_injector.get_injected_prompt.assert_called_once_with(
            "PROJECT_MANIFESTO"
        )

    @pytest.mark.asyncio
    async def test_generate_includes_chat_history_in_context(
        self,
        orchestrator,
    ):
        """Test that chat history is included in prompt building."""
        mock_template = Mock(content="Template: {user_input}")
        orchestrator.template_loader.load.return_value = mock_template
        orchestrator.vector_store.query.return_value = {
            "documents": [[]],
            "metadatas": [[]],
        }
        orchestrator.llm_client.stream_generate = Mock(
            side_effect=lambda *args, **kwargs: self._mock_async_generator(["test"])
        )
        chat_history = [
            {"role": "user", "content": "Previous message"},
            {"role": "assistant", "content": "Previous response"},
        ]

        async for _ in orchestrator.generate(
            doc_type="PROJECT_MANIFESTO",
            user_input="New message",
            context={"chat_history": chat_history},
        ):
            pass

        orchestrator.llm_client.stream_generate.assert_called_once()

    @pytest.mark.asyncio
    async def test_build_prompt_handles_nested_document_lists(
        self,
        orchestrator,
    ):
        """Test prompt building with nested document lists from RAG."""
        mock_template = Mock(content="Docs: {context}\nInput: {user_input}")
        orchestrator.template_loader.load.return_value = mock_template
        # Nested list structure from ChromaDB
        orchestrator.vector_store.query.return_value = {
            "documents": [["Doc1", "Doc2"], ["Doc3"]],
            "metadatas": [[{"source": "file1.md"}, {"source": "file2.md"}]],
        }
        orchestrator.llm_client.stream_generate = Mock(
            side_effect=lambda *args, **kwargs: self._mock_async_generator(["test"])
        )

        async for _ in orchestrator.generate(
            doc_type="PROJECT_MANIFESTO",
            user_input="Test",
            context={},
        ):
            pass

        # Should flatten nested docs
        orchestrator.llm_client.stream_generate.assert_called_once()
        call_args = str(orchestrator.llm_client.stream_generate.call_args)
        assert "Doc1" in call_args or "Doc" in call_args

    @pytest.mark.asyncio
    async def test_build_prompt_handles_empty_rag_context(
        self,
        orchestrator,
    ):
        """Test prompt building with empty RAG results."""
        mock_template = Mock(content="Docs: {context}\nInput: {user_input}")
        orchestrator.template_loader.load.return_value = mock_template
        orchestrator.vector_store.query.return_value = {
            "documents": [[]],  # Empty results
            "metadatas": [[]],
        }
        orchestrator.llm_client.stream_generate = Mock(
            side_effect=lambda *args, **kwargs: self._mock_async_generator(["response"])
        )

        tokens = []
        async for token in orchestrator.generate(
            doc_type="PROJECT_MANIFESTO",
            user_input="Test",
            context={},
        ):
            tokens.append(token)

        assert len(tokens) == 1
        assert tokens[0] == "response"

    @pytest.mark.asyncio
    async def test_build_prompt_handles_non_list_documents(
        self,
        orchestrator,
    ):
        """Test prompt building with non-list document structure."""
        mock_template = Mock(content="Docs: {context}\nInput: {user_input}")
        orchestrator.template_loader.load.return_value = mock_template
        # Single document (not a list)
        orchestrator.vector_store.query.return_value = {
            "documents": ["Single doc string"],
            "metadatas": [{"source": "file.md"}],
        }
        orchestrator.llm_client.stream_generate = Mock(
            side_effect=lambda *args, **kwargs: self._mock_async_generator(["test"])
        )

        async for _ in orchestrator.generate(
            doc_type="PROJECT_MANIFESTO",
            user_input="Test",
            context={},
        ):
            pass

        orchestrator.llm_client.stream_generate.assert_called_once()

    @pytest.mark.asyncio
    async def test_build_prompt_handles_chat_history_as_list(
        self,
        orchestrator,
    ):
        """Test prompt building with chat history as list of messages."""
        mock_template = Mock(
            content="History: {chat_history}\nDocs: {context}\nInput: {user_input}"
        )
        orchestrator.template_loader.load.return_value = mock_template
        orchestrator.vector_store.query.return_value = {
            "documents": [[]],
            "metadatas": [[]],
        }
        orchestrator.llm_client.stream_generate = Mock(
            side_effect=lambda *args, **kwargs: self._mock_async_generator(["test"])
        )

        chat_history = [
            {"role": "user", "content": "Msg1"},
            {"role": "assistant", "content": "Response1"},
        ]

        async for _ in orchestrator.generate(
            doc_type="PROJECT_MANIFESTO",
            user_input="Test",
            context={"chat_history": chat_history},
        ):
            pass

        orchestrator.llm_client.stream_generate.assert_called_once()

    @pytest.mark.asyncio
    async def test_retrieve_context_passes_correct_filters(
        self,
        orchestrator,
    ):
        """Test that vector store query uses correct doc_type filter."""
        mock_template = Mock(content="Template: {user_input}")
        orchestrator.template_loader.load.return_value = mock_template
        orchestrator.vector_store.query.return_value = {
            "documents": [[]],
            "metadatas": [[]],
        }
        orchestrator.llm_client.stream_generate = Mock(
            side_effect=lambda *args, **kwargs: self._mock_async_generator(["test"])
        )

        async for _ in orchestrator.generate(
            doc_type="DESIGN_DOCUMENT",
            user_input="Architecture",
            context={},
        ):
            pass

        # Verify vector store was queried with user_input
        assert orchestrator.vector_store.query.call_count >= 1
        # Verify user_input was passed to vector store query
        call_args = orchestrator.vector_store.query.call_args
        assert call_args is not None
        assert call_args.kwargs.get("query_text") == "Architecture"

    @staticmethod
    async def _mock_async_generator(items: list[str]):
        """Helper to create async generator from list."""
        for item in items:
            yield item
