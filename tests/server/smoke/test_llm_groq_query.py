"""Smoke test for Groq LLM API connectivity.

Tests that the LLM client (Groq) instantiates correctly and has proper method signatures.
Uses mocks to avoid real API calls and token consumption.
"""

import pytest
from unittest.mock import AsyncMock, patch

from app.infrastructure.llm.groq_client import GroqClient


@pytest.mark.asyncio
async def test_groq_api_connectivity():
    """
    Smoke Test: Groq client should instantiate and respond correctly.

    Uses mocks to avoid real API calls.
    Tests client initialization and basic method signature.
    """
    api_key = "test_api_key_12345"  # Mock key for testing

    with patch("app.infrastructure.llm.groq_client.AsyncGroq") as mock_groq:
        # Configure mock client
        mock_client_instance = AsyncMock()
        mock_client_instance.chat.completions.create = AsyncMock(
            return_value=AsyncMock(
                choices=[AsyncMock(message=AsyncMock(content="OK, I can hear you!"))]
            )
        )
        mock_groq.return_value = mock_client_instance

        # Create client
        client = GroqClient(api_key=api_key)

        # Simple test query (mocked)
        response = await client.generate(
            prompt="Say 'OK' if you can hear me.",
        )

        assert isinstance(response, str), "LLM should return string"
        assert len(response) > 0, "LLM response should not be empty"


@pytest.mark.asyncio
async def test_groq_streaming_mode():
    """
    Smoke Test: Groq streaming should work.

    Uses mocks to test streaming functionality without API calls.
    """
    api_key = "test_api_key_12345"  # Mock key for testing

    with patch("app.infrastructure.llm.groq_client.AsyncGroq") as mock_groq:
        # Configure mock streaming - must return an async generator
        async def mock_stream(*args, **kwargs):
            # Simulate streaming tokens
            for token in ["1", " ", "2", " ", "3"]:
                yield AsyncMock(choices=[AsyncMock(delta=AsyncMock(content=token))])

        mock_client_instance = AsyncMock()
        # Make create() return the async generator directly (not awaitable)
        mock_client_instance.chat.completions.create = AsyncMock(
            return_value=mock_stream()
        )
        mock_groq.return_value = mock_client_instance

        # Create client
        client = GroqClient(api_key=api_key)

        # Test streaming
        tokens = []
        async for token in client.stream_generate(
            prompt="Count: 1",
        ):
            tokens.append(token)

        assert len(tokens) > 0, "Streaming should yield tokens"

        # Combine tokens into response
        full_response = "".join(tokens)
        assert len(full_response) > 0, "Streamed response should not be empty"


@pytest.mark.asyncio
async def test_groq_handles_invalid_model():
    """
    Smoke Test: LLM client should handle invalid model gracefully.

    Tests error handling for bad configuration using mocks.
    """
    api_key = "test_api_key_12345"  # Mock key for testing

    with patch("app.infrastructure.llm.groq_client.AsyncGroq") as mock_groq:
        # Configure mock to raise error for invalid model
        mock_client_instance = AsyncMock()
        mock_client_instance.chat.completions.create = AsyncMock(
            side_effect=Exception("Invalid model: nonexistent-model-xyz")
        )
        mock_groq.return_value = mock_client_instance

        # Create client with test key
        client = GroqClient(api_key=api_key)
        client.model = "nonexistent-model-xyz"  # Override to test error handling

        with pytest.raises(Exception):  # Should raise error from mock
            await client.generate(prompt="Test")
