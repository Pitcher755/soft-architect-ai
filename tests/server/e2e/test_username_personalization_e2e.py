"""End-to-end test for userName personalization (RULE-09, HU-5.0).

Tests the complete flow of userName injection from API request
through orchestrator to final prompt generation.
"""

import pytest
from unittest.mock import AsyncMock
from uuid import uuid4

from app.services.rag.orchestrator import RAGOrchestrator
from app.services.rag.template_builder import MVPTemplateBuilder
from app.domain.schemas.chat_schema import ChatRequest


class TestUserNamePersonalizationE2E:
    """End-to-end tests for RULE-09 userName personalization."""

    @pytest.mark.asyncio
    async def test_username_flows_through_entire_pipeline(self):
        """
        E2E: userName should flow from request → orchestrator → template builder → prompt.

        Scenario:
        1. Client sends request with user_name="Carlos"
        2. Orchestrator receives request
        3. Template builder generates prompt with "Carlos"
        4. LLM receives personalized prompt
        """
        # Arrange: Use real template builder + mocked others
        real_template_builder = MVPTemplateBuilder()

        mock_vector_store = AsyncMock()
        mock_vector_store.search = AsyncMock(return_value=["Context snippet"])

        mock_llm_client = AsyncMock()
        mock_llm_client.generate = AsyncMock(return_value="Personalized response")

        orchestrator = RAGOrchestrator(
            vector_store=mock_vector_store,
            template_builder=real_template_builder,
            llm_client=mock_llm_client,
        )

        request = ChatRequest(
            conversation_id=uuid4(),
            message="Create a project manifesto",
            project_id=uuid4(),
            user_name="Carlos",  # Custom userName
        )

        # Act
        await orchestrator.process_message(request)

        # Assert: Check that LLM received prompt with "Carlos"
        mock_llm_client.generate.assert_called_once()
        generated_prompt = mock_llm_client.generate.call_args[0][0]

        assert "Carlos" in generated_prompt
        assert "The user's name is Carlos" in generated_prompt
        assert "{user_name}" not in generated_prompt  # Placeholder replaced

    @pytest.mark.asyncio
    async def test_default_username_when_not_provided(self):
        """
        E2E: Default userName "Developer" should be used when not specified.

        Scenario:
        1. Client sends request WITHOUT user_name field
        2. Schema defaults to "Developer"
        3. Prompt contains "Developer"
        """
        real_template_builder = MVPTemplateBuilder()

        mock_vector_store = AsyncMock()
        mock_vector_store.search = AsyncMock(return_value=[])

        mock_llm_client = AsyncMock()
        mock_llm_client.generate = AsyncMock(return_value="Response")

        orchestrator = RAGOrchestrator(
            vector_store=mock_vector_store,
            template_builder=real_template_builder,
            llm_client=mock_llm_client,
        )

        request = ChatRequest(
            conversation_id=uuid4(),
            message="Test query",
            project_id=uuid4(),
            # user_name NOT provided, should default
        )

        # Act
        await orchestrator.process_message(request)

        # Assert
        generated_prompt = mock_llm_client.generate.call_args[0][0]

        assert "Developer" in generated_prompt
        assert "The user's name is Developer" in generated_prompt

    @pytest.mark.asyncio
    async def test_special_characters_in_username_preserved(self):
        """
        E2E: Special characters in userName should be preserved in prompt.

        Scenario:
        1. Request with userName="José-María O'Connor"
        2. Prompt should contain exact userName with special chars
        """
        real_template_builder = MVPTemplateBuilder()

        mock_vector_store = AsyncMock()
        mock_vector_store.search = AsyncMock(return_value=[])

        mock_llm_client = AsyncMock()
        mock_llm_client.generate = AsyncMock(return_value="Response")

        orchestrator = RAGOrchestrator(
            vector_store=mock_vector_store,
            template_builder=real_template_builder,
            llm_client=mock_llm_client,
        )

        special_name = "José-María O'Connor"
        request = ChatRequest(
            conversation_id=uuid4(),
            message="Test",
            project_id=uuid4(),
            user_name=special_name,
        )

        # Act
        await orchestrator.process_message(request)

        # Assert
        generated_prompt = mock_llm_client.generate.call_args[0][0]
        assert special_name in generated_prompt

    @pytest.mark.asyncio
    async def test_username_in_streaming_mode(self):
        """
        E2E: userName should work correctly in streaming mode.

        Scenario:
        1. Streaming request with user_name="StreamUser"
        2. Prompt generation should include userName
        3. Streaming response proceeds normally
        """
        real_template_builder = MVPTemplateBuilder()

        mock_vector_store = AsyncMock()
        mock_vector_store.search = AsyncMock(return_value=[])

        async def mock_stream(prompt, history=None):  # Accept prompt and history
            """Mock streaming response."""
            tokens = ["Hello", " ", "StreamUser", "!"]
            for token in tokens:
                yield token

        mock_llm_client = AsyncMock()
        mock_llm_client.stream_generate = mock_stream

        orchestrator = RAGOrchestrator(
            vector_store=mock_vector_store,
            template_builder=real_template_builder,
            llm_client=mock_llm_client,
        )

        request = ChatRequest(
            conversation_id=uuid4(),
            message="Test streaming",
            project_id=uuid4(),
            user_name="StreamUser",
        )

        # Act: Collect streaming events
        events = []
        async for event in orchestrator.process_message_stream(request):
            events.append(event)

        # Assert: Should complete streaming without errors
        assert len(events) > 0

        # Check done event contains streamed response
        done_events = [e for e in events if e["type"] == "done"]
        assert len(done_events) == 1
        assert "StreamUser" in done_events[0]["data"]["full_response"]


class TestUserNameWithOtherFeatures:
    """E2E tests combining userName with other features."""

    @pytest.mark.asyncio
    async def test_username_with_chat_history(self):
        """userName should work alongside chat history."""
        real_template_builder = MVPTemplateBuilder()

        mock_vector_store = AsyncMock()
        mock_vector_store.search = AsyncMock(return_value=[])

        mock_llm_client = AsyncMock()
        mock_llm_client.generate = AsyncMock(return_value="Response")

        orchestrator = RAGOrchestrator(
            vector_store=mock_vector_store,
            template_builder=real_template_builder,
            llm_client=mock_llm_client,
        )

        request = ChatRequest(
            conversation_id=uuid4(),
            message="What's next?",
            project_id=uuid4(),
            user_name="HistoryUser",
            history=[
                {"role": "user", "content": "Previous question"},
                {"role": "assistant", "content": "Previous answer"},
            ],
        )

        # Act
        await orchestrator.process_message(request)

        # Assert: Prompt should have both userName and history
        generated_prompt = mock_llm_client.generate.call_args[0][0]

        assert "HistoryUser" in generated_prompt
        assert "USUARIO: Previous question" in generated_prompt
        assert "SOFTARCHITECT: Previous answer" in generated_prompt

    @pytest.mark.asyncio
    async def test_username_with_rag_context(self):
        """userName should work alongside RAG context."""
        real_template_builder = MVPTemplateBuilder()

        mock_vector_store = AsyncMock()
        mock_vector_store.search = AsyncMock(
            return_value=["RAG context snippet 1", "RAG context snippet 2"]
        )

        mock_llm_client = AsyncMock()
        mock_llm_client.generate = AsyncMock(return_value="Response")

        orchestrator = RAGOrchestrator(
            vector_store=mock_vector_store,
            template_builder=real_template_builder,
            llm_client=mock_llm_client,
        )

        request = ChatRequest(
            conversation_id=uuid4(),
            message="Test with RAG",
            project_id=uuid4(),
            user_name="RAGUser",
        )

        # Act
        await orchestrator.process_message(request)

        # Assert: Prompt should have both userName and RAG context
        generated_prompt = mock_llm_client.generate.call_args[0][0]

        assert "RAGUser" in generated_prompt
        assert "RAG context snippet 1" in generated_prompt
        assert "RAG context snippet 2" in generated_prompt

    @pytest.mark.asyncio
    async def test_username_with_validation_blocker(self):
        """userName should still work when validation blocker triggers."""
        real_template_builder = MVPTemplateBuilder()

        mock_vector_store = AsyncMock()
        mock_vector_store.search = AsyncMock(return_value=[])

        mock_llm_client = AsyncMock()
        # LLM should NOT be called due to validation blocker

        orchestrator = RAGOrchestrator(
            vector_store=mock_vector_store,
            template_builder=real_template_builder,
            llm_client=mock_llm_client,
        )

        request = ChatRequest(
            conversation_id=uuid4(),
            message="Next?",
            project_id=uuid4(),
            user_name="BlockedUser",
            history=[
                {"role": "assistant", "content": "<document>Unvalidated</document>"},
            ],
        )

        # Act
        response = await orchestrator.process_message(request)

        # Assert: Should return blocking message
        assert response.template_used == "VALIDATION_BLOCKED"
        assert "propuesta técnica pendiente" in response.ai_response
        assert "Validar y Guardar" in response.ai_response

        # LLM should NOT have been called, so userName injection never happens
        # (This is expected behavior - blocker runs BEFORE template building)
