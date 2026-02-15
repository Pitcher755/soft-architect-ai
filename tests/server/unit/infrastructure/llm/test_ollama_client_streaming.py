"""Unit tests for Ollama client streaming functionality (HU-4.3).

This module tests the `stream_generate()` method of OllamaClient,
which implements Server-Sent Events (SSE) streaming for real-time
AI response generation.

Test Coverage:
- Token-by-token streaming (NDJSON parsing)
- Error handling (connection, timeout, stream interruption)
- Edge cases (empty response, malformed JSON)

TDD Cycle: RED Phase
Expected: All tests FAIL (stream_generate() not implemented yet).
"""

from unittest.mock import AsyncMock, MagicMock, patch

import httpx
import pytest

from app.core.exceptions import LLMConnectionError, LLMTimeoutError
from app.infrastructure.llm.ollama_client import OllamaClient


class TestOllamaClientStreaming:
    """Test suite for OllamaClient.stream_generate() method."""

    @pytest.fixture
    def ollama_client(self) -> OllamaClient:
        """Create OllamaClient instance for testing."""
        return OllamaClient(base_url="http://localhost:11434")

    @pytest.fixture
    def mock_ndjson_response(self) -> list[str]:
        """
        Mock NDJSON response stream from Ollama.

        Format: One JSON object per line (Newline Delimited JSON).
        Each line represents a token event from the LLM.
        """
        lines = [
            '{"response":"Hello","done":false}\n',
            '{"response":" world","done":false}\n',
            '{"response":"!","done":false}\n',
            '{"response":"","done":true,"total_duration":1000000}\n',
        ]
        return lines

    @pytest.mark.asyncio
    async def test_stream_generate_yields_tokens(
        self,
        ollama_client: OllamaClient,
        mock_ndjson_response: list[str],
    ) -> None:
        """
        Test that stream_generate yields tokens progressively.

        Verifies:
        - Tokens are yielded one-by-one as they arrive
        - Final "done" event is not yielded as a token
        - Token order is preserved
        """

        # Arrange
        async def mock_aiter_lines():
            """Mock async generator for aiter_lines()."""
            for line in mock_ndjson_response:
                yield line

        with patch("httpx.AsyncClient.stream") as mock_stream:
            mock_response = AsyncMock()
            mock_response.aiter_lines = mock_aiter_lines
            mock_response.raise_for_status = MagicMock()
            mock_stream.return_value.__aenter__.return_value = mock_response

            # Act
            tokens: list[str] = []
            async for token in ollama_client.stream_generate("Test prompt"):
                tokens.append(token)

            # Assert
            assert tokens == [
                "Hello",
                " world",
                "!",
            ], "Should yield tokens in order (excluding done event)"
            assert len(tokens) == 3, "Should yield exactly 3 tokens"

    @pytest.mark.asyncio
    async def test_stream_generate_handles_ndjson_parsing(
        self,
        ollama_client: OllamaClient,
    ) -> None:
        """
        Test that NDJSON lines are parsed correctly.

        Verifies:
        - Valid JSON lines are parsed successfully
        - Malformed JSON lines are skipped (not raise exception)
        - Streaming continues after malformed line
        """
        # Arrange
        lines = [
            '{"response":"Token1","done":false}\n',
            '{"response":"Token2","done":false}\n',
            "invalid json line\n",  # Should be skipped
            '{"response":"Token3","done":false}\n',
            '{"response":"","done":true}\n',
        ]

        async def mock_aiter_lines():
            """Mock async generator for aiter_lines()."""
            for line in lines:
                yield line

        with patch("httpx.AsyncClient.stream") as mock_stream:
            mock_response = AsyncMock()
            mock_response.aiter_lines = mock_aiter_lines
            mock_response.raise_for_status = MagicMock()
            mock_stream.return_value.__aenter__.return_value = mock_response

            # Act
            tokens: list[str] = []
            async for token in ollama_client.stream_generate("Test"):
                tokens.append(token)

            # Assert
            assert tokens == [
                "Token1",
                "Token2",
                "Token3",
            ], "Should skip malformed JSON and continue streaming"

    @pytest.mark.asyncio
    async def test_stream_generate_empty_response(
        self,
        ollama_client: OllamaClient,
    ) -> None:
        """
        Test handling of empty response stream.

        Verifies:
        - Empty response (only "done" event) yields no tokens
        - No exception is raised
        - Generator completes successfully
        """
        # Arrange
        lines = ['{"response":"","done":true}\n']

        async def mock_aiter_lines():
            """Mock async generator for aiter_lines()."""
            for line in lines:
                yield line

        with patch("httpx.AsyncClient.stream") as mock_stream:
            mock_response = AsyncMock()
            mock_response.aiter_lines = mock_aiter_lines
            mock_response.raise_for_status = MagicMock()
            mock_stream.return_value.__aenter__.return_value = mock_response

            # Act
            tokens: list[str] = []
            async for token in ollama_client.stream_generate("Test"):
                tokens.append(token)

            # Assert
            assert tokens == [], "Empty response should yield no tokens"

    @pytest.mark.asyncio
    async def test_stream_generate_connection_error(
        self,
        ollama_client: OllamaClient,
    ) -> None:
        """
        Test handling of connection errors during streaming.

        Verifies:
        - Connection errors are wrapped in LLMConnectionError
        - Error message includes helpful context
        """
        # Arrange
        with patch("httpx.AsyncClient.stream") as mock_stream:
            mock_stream.side_effect = httpx.ConnectError("Connection refused")

            # Act & Assert
            with pytest.raises(LLMConnectionError) as exc_info:
                async for _ in ollama_client.stream_generate("Test"):
                    pass

            assert "Connection refused" in str(
                exc_info.value
            ), "Error message should include original exception message"

    @pytest.mark.asyncio
    async def test_stream_generate_timeout(
        self,
        ollama_client: OllamaClient,
    ) -> None:
        """
        Test handling of timeout during streaming.

        Verifies:
        - Timeout errors are wrapped in LLMTimeoutError
        - Error message indicates timeout occurred
        """
        # Arrange
        with patch("httpx.AsyncClient.stream") as mock_stream:
            mock_stream.side_effect = httpx.TimeoutException("Request timeout")

            # Act & Assert
            with pytest.raises(LLMTimeoutError) as exc_info:
                async for _ in ollama_client.stream_generate("Test"):
                    pass

            assert (
                "timeout" in str(exc_info.value).lower()
            ), "Error message should indicate timeout"
