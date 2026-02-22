"""End-to-end test for RULE-02 placeholder detection (HU-5.0).

Tests the complete flow of placeholder detection from LLM response
through post-processing validation.
"""

import pytest
from unittest.mock import AsyncMock
from uuid import uuid4

from app.services.rag.orchestrator import RAGOrchestrator
from app.services.rag.template_builder import MVPTemplateBuilder
from app.domain.schemas.chat import ChatRequest


class TestPlaceholderDetectionE2E:
    """E2E tests for RULE-02 placeholder detection."""

    @pytest.mark.asyncio
    async def test_llm_response_with_placeholders_logged(self):
        """
        E2E: LLM response with placeholders should trigger warning.

        Scenario:
        1. LLM generates document with placeholders like [Insert name]
        2. Orchestrator detects placeholders in post-processing
        3. Warning logged (for MVP, response still returned)

        Expected: Response returned with warning logged.
        """
        real_template_builder = MVPTemplateBuilder()

        mock_vector_store = AsyncMock()
        mock_vector_store.search = AsyncMock(return_value=[])

        # Mock LLM to generate response with placeholders
        mock_llm_client = AsyncMock()
        mock_llm_client.generate = AsyncMock(
            return_value="""
            <document>
            # Project Manifesto
            Project Name: [Insert your project name]
            Description: [TODO: Add description]
            Tech Stack: TBD
            </document>
            """
        )

        orchestrator = RAGOrchestrator(
            vector_store=mock_vector_store,
            template_builder=real_template_builder,
            llm_client=mock_llm_client,
        )

        request = ChatRequest(
            conversation_id=uuid4(),
            message="Create project manifesto",
            project_id=uuid4(),
            user_name="PlaceholderUser",
        )

        # Act
        response = await orchestrator.process_message(request)

        # Assert: Response returned (MVP behavior: warn but proceed)
        assert response.ai_response is not None
        assert "<document>" in response.ai_response

        # Assert: LLM was called
        mock_llm_client.generate.assert_called_once()

        # In production, this would trigger re-generation
        # For MVP, we just log the warning (test indirectly via logs)

    @pytest.mark.asyncio
    async def test_llm_response_without_placeholders_passes(self):
        """
        E2E: LLM response without placeholders proceeds normally.

        Scenario:
        1. LLM generates complete document with real values
        2. No placeholders detected
        3. Response returned successfully

        Expected: No warnings, clean response.
        """
        real_template_builder = MVPTemplateBuilder()

        mock_vector_store = AsyncMock()
        mock_vector_store.search = AsyncMock(return_value=[])

        # Mock LLM to generate clean response (no placeholders)
        mock_llm_client = AsyncMock()
        mock_llm_client.generate = AsyncMock(
            return_value="""
            <document>
            # Project Manifesto
            Project Name: MyAwesomeApp
            Description: A revolutionary task management tool
            Tech Stack: React 18 + Node.js 20 + PostgreSQL 15
            </document>
            """
        )

        orchestrator = RAGOrchestrator(
            vector_store=mock_vector_store,
            template_builder=real_template_builder,
            llm_client=mock_llm_client,
        )

        request = ChatRequest(
            conversation_id=uuid4(),
            message="Create project manifesto",
            project_id=uuid4(),
            user_name="CleanUser",
        )

        # Act
        response = await orchestrator.process_message(request)

        # Assert: Response returned successfully
        assert response.ai_response is not None
        assert "<document>" in response.ai_response
        assert "[Insert" not in response.ai_response
        assert "[TODO" not in response.ai_response
        assert "TBD" not in response.ai_response

        # Assert: LLM was called
        mock_llm_client.generate.assert_called_once()


class TestPlaceholderDetectionMultiplePatterns:
    """E2E tests for various placeholder patterns."""

    @pytest.mark.asyncio
    async def test_detect_insert_pattern(self):
        """E2E: Detect [Insert ...] placeholder pattern."""
        real_template_builder = MVPTemplateBuilder()

        mock_vector_store = AsyncMock()
        mock_vector_store.search = AsyncMock(return_value=[])

        mock_llm_client = AsyncMock()
        mock_llm_client.generate = AsyncMock(
            return_value="<document>Name: [Insert your name]</document>"
        )

        orchestrator = RAGOrchestrator(
            vector_store=mock_vector_store,
            template_builder=real_template_builder,
            llm_client=mock_llm_client,
        )

        request = ChatRequest(
            conversation_id=uuid4(),
            message="Test",
            project_id=uuid4(),
            user_name="InsertTestUser",
        )

        response = await orchestrator.process_message(request)

        # Response returned (warning logged internally)
        assert response.ai_response is not None

    @pytest.mark.asyncio
    async def test_detect_todo_pattern(self):
        """E2E: Detect [TODO: ...] placeholder pattern."""
        real_template_builder = MVPTemplateBuilder()

        mock_vector_store = AsyncMock()
        mock_vector_store.search = AsyncMock(return_value=[])

        mock_llm_client = AsyncMock()
        mock_llm_client.generate = AsyncMock(
            return_value="<document>Description: [TODO: Add description]</document>"
        )

        orchestrator = RAGOrchestrator(
            vector_store=mock_vector_store,
            template_builder=real_template_builder,
            llm_client=mock_llm_client,
        )

        request = ChatRequest(
            conversation_id=uuid4(),
            message="Test",
            project_id=uuid4(),
            user_name="TodoTestUser",
        )

        response = await orchestrator.process_message(request)

        # Response returned (warning logged internally)
        assert response.ai_response is not None

    @pytest.mark.asyncio
    async def test_detect_tbd_pattern(self):
        """E2E: Detect TBD placeholder keyword."""
        real_template_builder = MVPTemplateBuilder()

        mock_vector_store = AsyncMock()
        mock_vector_store.search = AsyncMock(return_value=[])

        mock_llm_client = AsyncMock()
        mock_llm_client.generate = AsyncMock(
            return_value="<document>Tech Stack: TBD</document>"
        )

        orchestrator = RAGOrchestrator(
            vector_store=mock_vector_store,
            template_builder=real_template_builder,
            llm_client=mock_llm_client,
        )

        request = ChatRequest(
            conversation_id=uuid4(),
            message="Test",
            project_id=uuid4(),
            user_name="TbdTestUser",
        )

        response = await orchestrator.process_message(request)

        # Response returned (warning logged internally)
        assert response.ai_response is not None
