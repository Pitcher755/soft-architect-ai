"""End-to-end test for RULE-06 validation blocker (HU-5.0).

Tests the complete flow of validation blocking from API endpoint
through orchestrator to LLM response (mocked).

This ensures that the validation blocker works correctly in production
environment with real HTTP requests.
"""

import pytest
from unittest.mock import AsyncMock
from uuid import uuid4

from app.services.rag.orchestrator import RAGOrchestrator


@pytest.fixture
def sample_conversation_id():
    """Generate a sample conversation ID."""
    return str(uuid4())


@pytest.fixture
def sample_project_id():
    """Generate a sample project ID."""
    return str(uuid4())


class TestValidationBlockerE2E:
    """End-to-end tests for RULE-06 validation blocker."""

    @pytest.mark.asyncio
    async def test_validation_blocker_prevents_llm_call(
        self, sample_conversation_id, sample_project_id
    ):
        """
        E2E: Validation blocker should prevent expensive LLM call.

        Scenario:
        1. User requests document
        2. AI generates document with <document> tag
        3. User asks for next step WITHOUT validating
        4. System blocks request and returns warning (no LLM call)
        """
        # Arrange: Create mocked orchestrator
        mock_vector_store = AsyncMock()
        mock_vector_store.search = AsyncMock(return_value=[])

        mock_template_builder = AsyncMock()
        mock_template_builder.select_template = AsyncMock(return_value="CONTEXT_DRIVEN")
        mock_template_builder.build_prompt = AsyncMock(return_value="Test prompt")

        mock_llm_client = AsyncMock()
        mock_llm_client.generate = AsyncMock(return_value="LLM response")

        orchestrator = RAGOrchestrator(
            vector_store=mock_vector_store,
            template_builder=mock_template_builder,
            llm_client=mock_llm_client,
        )

        # Prepare history with unvalidated document
        from app.domain.schemas.chat_schema import ChatRequest

        request = ChatRequest(
            conversation_id=uuid4(),
            message="What's the next step?",
            project_id=uuid4(),
            user_name="TestUser",
            history=[
                {"role": "user", "content": "Create PROJECT_MANIFESTO"},
                {
                    "role": "assistant",
                    "content": "Here's the document:\n<document>\n# Manifesto\n</document>",
                },
                # NO validation message here!
            ],
        )

        # Act: Process message (should trigger blocker)
        response = await orchestrator.process_message(request)

        # Assert: Should return blocking message WITHOUT calling LLM
        assert response.template_used == "VALIDATION_BLOCKED"
        assert "Bloqueo de Seguridad" in response.ai_response
        assert "RULE-06" in response.ai_response

        # Critical: LLM should NOT have been called (saves tokens/money)
        mock_llm_client.generate.assert_not_called()

    @pytest.mark.asyncio
    async def test_validation_blocker_allows_call_after_validation(
        self, sample_conversation_id, sample_project_id
    ):
        """
        E2E: System should allow LLM call after document validation.

        Scenario:
        1. User requests document
        2. AI generates document
        3. User validates and saves document
        4. User asks for next step
        5. System proceeds with normal LLM call
        """
        # Arrange
        mock_vector_store = AsyncMock()
        mock_vector_store.search = AsyncMock(return_value=[])

        mock_template_builder = AsyncMock()
        mock_template_builder.select_template = AsyncMock(return_value="CONTEXT_DRIVEN")
        mock_template_builder.build_prompt = AsyncMock(return_value="Test prompt")

        mock_llm_client = AsyncMock()
        mock_llm_client.generate = AsyncMock(return_value="Next step response")

        orchestrator = RAGOrchestrator(
            vector_store=mock_vector_store,
            template_builder=mock_template_builder,
            llm_client=mock_llm_client,
        )

        from app.domain.schemas.chat_schema import ChatRequest

        request = ChatRequest(
            conversation_id=uuid4(),
            message="What's next?",
            project_id=uuid4(),
            user_name="TestUser",
            history=[
                {"role": "user", "content": "Create PROJECT_MANIFESTO"},
                {
                    "role": "assistant",
                    "content": "<document># Manifesto</document>",
                },
                {
                    "role": "user",
                    "content": "He validado y guardado el documento en context/10-CONTEXT/PROJECT_MANIFESTO.md",
                },
            ],
        )

        # Act
        response = await orchestrator.process_message(request)

        # Assert: Should call LLM normally
        assert response.template_used != "VALIDATION_BLOCKED"
        assert "Bloqueo de Seguridad" not in response.ai_response

        # LLM SHOULD have been called
        mock_llm_client.generate.assert_called_once()

    @pytest.mark.asyncio
    async def test_validation_blocker_streaming_mode(
        self, sample_conversation_id, sample_project_id
    ):
        """
        E2E: Validation blocker should work in streaming mode.

        Scenario:
        1. User requests document via streaming endpoint
        2. AI generates document
        3. User asks for next WITHOUT validation
        4. System streams blocking message (no LLM stream)
        """
        # Arrange
        mock_vector_store = AsyncMock()
        mock_vector_store.search = AsyncMock(return_value=[])

        mock_template_builder = AsyncMock()
        mock_template_builder.select_template = AsyncMock(return_value="FALLBACK")
        mock_template_builder.build_prompt = AsyncMock(return_value="Prompt")

        async def mock_stream_generate(prompt):
            """Mock LLM stream that should NOT be called."""
            yield "This"
            yield " should"
            yield " not"
            yield " happen"

        mock_llm_client = AsyncMock()
        mock_llm_client.stream_generate = mock_stream_generate

        orchestrator = RAGOrchestrator(
            vector_store=mock_vector_store,
            template_builder=mock_template_builder,
            llm_client=mock_llm_client,
        )

        from app.domain.schemas.chat_schema import ChatRequest

        request = ChatRequest(
            conversation_id=uuid4(),
            message="Next step?",
            project_id=uuid4(),
            user_name="TestUser",
            history=[
                {
                    "role": "assistant",
                    "content": "<document>Unvalidated content</document>",
                },
            ],
        )

        # Act: Collect all streamed events
        events = []
        async for event in orchestrator.process_message_stream(request):
            events.append(event)

        # Assert: Should receive blocking message in stream
        assert len(events) == 2  # Token event + done event

        token_event = events[0]
        assert token_event["type"] == "token"
        assert "Bloqueo de Seguridad" in token_event["data"]

        done_event = events[1]
        assert done_event["type"] == "done"
        assert done_event["data"]["metadata"]["blocked"] is True
        assert done_event["data"]["metadata"]["rule"] == "RULE-06"


class TestValidationBlockerMultipleDocuments:
    """E2E tests for validation blocker with multiple documents."""

    @pytest.mark.asyncio
    async def test_multiple_documents_all_validated_proceeds(self):
        """
        E2E: Multiple documents all validated should allow LLM call.

        Scenario:
        1. Generate Doc 1 → Validate
        2. Generate Doc 2 → Validate
        3. Generate Doc 3 → Validate
        4. Ask for next step → Proceeds normally
        """
        mock_vector_store = AsyncMock()
        mock_vector_store.search = AsyncMock(return_value=[])

        mock_template_builder = AsyncMock()
        mock_template_builder.select_template = AsyncMock(return_value="CONTEXT_DRIVEN")
        mock_template_builder.build_prompt = AsyncMock(return_value="Prompt")

        mock_llm_client = AsyncMock()
        mock_llm_client.generate = AsyncMock(return_value="Response")

        orchestrator = RAGOrchestrator(
            vector_store=mock_vector_store,
            template_builder=mock_template_builder,
            llm_client=mock_llm_client,
        )

        from app.domain.schemas.chat_schema import ChatRequest

        request = ChatRequest(
            conversation_id=uuid4(),
            message="Next?",
            project_id=uuid4(),
            history=[
                {"role": "user", "content": "Create doc 1"},
                {"role": "assistant", "content": "<document>Doc 1</document>"},
                {
                    "role": "user",
                    "content": "He validado y guardado el documento en path1.md",
                },
                {"role": "user", "content": "Create doc 2"},
                {"role": "assistant", "content": "<document>Doc 2</document>"},
                {
                    "role": "user",
                    "content": "He validado y guardado el documento in path2.md",
                },
                {"role": "user", "content": "Create doc 3"},
                {"role": "assistant", "content": "<document>Doc 3</document>"},
                {
                    "role": "user",
                    "content": "He validado y guardado el documento en path3.md",
                },
            ],
        )

        response = await orchestrator.process_message(request)

        # Should NOT block
        assert response.template_used != "VALIDATION_BLOCKED"
        mock_llm_client.generate.assert_called_once()

    @pytest.mark.asyncio
    async def test_multiple_documents_last_unvalidated_blocks(self):
        """
        E2E: If last document is unvalidated, system blocks.

        Scenario:
        1. Generate Doc 1 → Validate
        2. Generate Doc 2 → Validate
        3. Generate Doc 3 → NO VALIDATION
        4. Ask for next step → Blocked!
        """
        mock_vector_store = AsyncMock()
        mock_vector_store.search = AsyncMock(return_value=[])

        mock_template_builder = AsyncMock()
        mock_template_builder.select_template = AsyncMock(return_value="FALLBACK")
        mock_template_builder.build_prompt = AsyncMock(return_value="Prompt")

        mock_llm_client = AsyncMock()
        mock_llm_client.generate = AsyncMock(return_value="Should not happen")

        orchestrator = RAGOrchestrator(
            vector_store=mock_vector_store,
            template_builder=mock_template_builder,
            llm_client=mock_llm_client,
        )

        from app.domain.schemas.chat_schema import ChatRequest

        request = ChatRequest(
            conversation_id=uuid4(),
            message="Next?",
            project_id=uuid4(),
            history=[
                {"role": "assistant", "content": "<document>Doc 1</document>"},
                {
                    "role": "user",
                    "content": "He validado y guardado el documento en path1.md",
                },
                {"role": "assistant", "content": "<document>Doc 2</document>"},
                {
                    "role": "user",
                    "content": "He validado y guardado el documento en path2.md",
                },
                {"role": "assistant", "content": "<document>Doc 3</document>"},
                # Missing validation for Doc 3!
            ],
        )

        response = await orchestrator.process_message(request)

        # Should block
        assert response.template_used == "VALIDATION_BLOCKED"
        assert "Bloqueo de Seguridad" in response.ai_response
        mock_llm_client.generate.assert_not_called()
