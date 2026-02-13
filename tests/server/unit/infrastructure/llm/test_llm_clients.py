"""Unit tests for LLM client implementations (Strategy Pattern).

Tests:
- Ollama client success flow
- Groq client success flow (stub for now)
- Connection error handling
- Timeout handling
- Custom domain exceptions
"""

from unittest.mock import AsyncMock, patch

import pytest

from src.server.app.core.exceptions import LLMConnectionError, LLMTimeoutError
from src.server.app.infrastructure.llm.groq_client import GroqClient
from src.server.app.infrastructure.llm.ollama_client import OllamaClient


class TestOllamaClient:
    """Test Ollama local LLM client."""

    @pytest.mark.asyncio
    @patch("httpx.AsyncClient.post")
    async def test_ollama_generate_success(self, mock_post):
        """Happy path: Ollama returns valid response."""
        mock_response = AsyncMock()
        mock_response.status_code = 200
        mock_response.json.return_value = {"response": "Mocked AI Response"}
        mock_post.return_value = mock_response

        client = OllamaClient(base_url="http://localhost:11434")
        response = await client.generate("Test prompt")

        assert response == "Mocked AI Response"
        mock_post.assert_called_once()

    @pytest.mark.asyncio
    @patch("httpx.AsyncClient.post")
    async def test_ollama_connection_error_raises_domain_exception(self, mock_post):
        """Network failure: Should raise LLMConnectionError."""
        mock_post.side_effect = Exception("Connection refused")

        client = OllamaClient(base_url="http://localhost:11434")

        with pytest.raises(LLMConnectionError) as exc_info:
            await client.generate("Test prompt")

        assert "Ollama" in str(exc_info.value)

    @pytest.mark.asyncio
    @patch("httpx.AsyncClient.post")
    async def test_ollama_timeout_raises_domain_exception(self, mock_post):
        """Timeout: Should raise LLMTimeoutError."""
        import httpx

        mock_post.side_effect = httpx.TimeoutException("Request timeout")

        client = OllamaClient(base_url="http://localhost:11434", timeout=10.0)

        with pytest.raises(LLMTimeoutError) as exc_info:
            await client.generate("Test prompt")

        assert "timeout" in str(exc_info.value).lower()

    @pytest.mark.asyncio
    @patch("httpx.AsyncClient.post")
    async def test_ollama_invalid_json_raises_exception(self, mock_post):
        """Malformed response: Should raise LLMConnectionError."""
        mock_response = AsyncMock()
        mock_response.status_code = 200
        mock_response.json.side_effect = ValueError("Invalid JSON")
        mock_post.return_value = mock_response

        client = OllamaClient(base_url="http://localhost:11434")

        with pytest.raises(LLMConnectionError):
            await client.generate("Test prompt")


class TestGroqClient:
    """Test Groq cloud LLM client (stub implementation for now)."""

    @pytest.mark.asyncio
    async def test_groq_stub_returns_placeholder(self):
        """Groq stub: Should return placeholder text for now."""
        client = GroqClient(api_key="test_key")
        response = await client.generate("Test prompt")

        assert "not yet implemented" in response.lower() or "stub" in response.lower()

    @pytest.mark.asyncio
    async def test_groq_respects_base_protocol(self):
        """Type check: GroqClient conforms to BaseLLMClient protocol."""
        from src.server.app.infrastructure.llm.base import BaseLLMClient

        client = GroqClient(api_key="test_key")
        assert isinstance(client, BaseLLMClient)
