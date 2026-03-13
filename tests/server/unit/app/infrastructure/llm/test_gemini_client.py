"""
Unit tests for GeminiClient (Google Gemini LLM integration).

Coverage target: >80% (current: 29%)
"""

import pytest
from unittest.mock import AsyncMock, MagicMock, patch

from google.api_core.exceptions import GoogleAPIError
from google.generativeai.types import HarmBlockThreshold, HarmCategory

from app.core.exceptions import LLMConnectionError, LLMStreamError
from app.infrastructure.llm.gemini_client import GeminiClient


class TestGeminiClientInitialization:
    """Test suite for GeminiClient initialization."""

    @patch("app.infrastructure.llm.gemini_client.genai")
    def test_init_with_valid_api_key(self, mock_genai):
        """Test successful initialization with valid API key."""
        mock_model = MagicMock()
        mock_genai.GenerativeModel.return_value = mock_model

        client = GeminiClient(api_key="valid-api-key", model="gemini-1.5-flash")

        # Verify genai.configure called with API key
        mock_genai.configure.assert_called_once_with(api_key="valid-api-key")

        # Verify model initialized
        mock_genai.GenerativeModel.assert_called_once_with("gemini-1.5-flash")
        assert client.model_name == "gemini-1.5-flash"
        assert client.model == mock_model

    @patch("app.infrastructure.llm.gemini_client.genai")
    def test_init_with_default_model(self, mock_genai):
        """Test initialization with default model."""
        mock_genai.GenerativeModel.return_value = MagicMock()

        client = GeminiClient(api_key="valid-key")

        assert client.model_name == "gemini-1.5-flash"

    def test_init_with_empty_api_key_raises_error(self):
        """Test that empty API key raises ValueError."""
        with pytest.raises(ValueError, match="GEMINI_API_KEY is required"):
            GeminiClient(api_key="")

    @patch("app.infrastructure.llm.gemini_client.genai")
    def test_init_safety_settings_configured(self, mock_genai):
        """Test that safety settings are configured correctly."""
        mock_genai.GenerativeModel.return_value = MagicMock()

        client = GeminiClient(api_key="valid-key")

        # Verify all safety categories disabled
        assert len(client.safety_settings) == 4
        assert (
            client.safety_settings[HarmCategory.HARM_CATEGORY_HARASSMENT]
            == HarmBlockThreshold.BLOCK_NONE
        )
        assert (
            client.safety_settings[HarmCategory.HARM_CATEGORY_HATE_SPEECH]
            == HarmBlockThreshold.BLOCK_NONE
        )
        assert (
            client.safety_settings[HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT]
            == HarmBlockThreshold.BLOCK_NONE
        )
        assert (
            client.safety_settings[HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT]
            == HarmBlockThreshold.BLOCK_NONE
        )


class TestBuildConfig:
    """Test suite for _build_config method."""

    @patch("app.infrastructure.llm.gemini_client.genai")
    def test_build_config_with_all_params(self, mock_genai):
        """Test building config with max_tokens and temperature."""
        mock_config_class = MagicMock()
        mock_genai.GenerationConfig = mock_config_class
        mock_genai.GenerativeModel.return_value = MagicMock()

        client = GeminiClient(api_key="valid-key")
        client._build_config(max_tokens=500, temperature=0.7)

        # Verify GenerationConfig called with correct args
        mock_config_class.assert_called_once_with(
            max_output_tokens=500, temperature=0.7
        )

    @patch("app.infrastructure.llm.gemini_client.genai")
    def test_build_config_with_only_max_tokens(self, mock_genai):
        """Test building config with only max_tokens."""
        mock_config_class = MagicMock()
        mock_genai.GenerationConfig = mock_config_class
        mock_genai.GenerativeModel.return_value = MagicMock()

        client = GeminiClient(api_key="valid-key")
        client._build_config(max_tokens=300, temperature=None)

        mock_config_class.assert_called_once_with(max_output_tokens=300)

    @patch("app.infrastructure.llm.gemini_client.genai")
    def test_build_config_with_only_temperature(self, mock_genai):
        """Test building config with only temperature."""
        mock_config_class = MagicMock()
        mock_genai.GenerationConfig = mock_config_class
        mock_genai.GenerativeModel.return_value = MagicMock()

        client = GeminiClient(api_key="valid-key")
        client._build_config(max_tokens=None, temperature=0.9)

        mock_config_class.assert_called_once_with(temperature=0.9)

    @patch("app.infrastructure.llm.gemini_client.genai")
    def test_build_config_with_no_params(self, mock_genai):
        """Test building config with no parameters."""
        mock_config_class = MagicMock()
        mock_genai.GenerationConfig = mock_config_class
        mock_genai.GenerativeModel.return_value = MagicMock()

        client = GeminiClient(api_key="valid-key")
        client._build_config(max_tokens=None, temperature=None)

        mock_config_class.assert_called_once_with()


@pytest.mark.asyncio
class TestGenerate:
    """Test suite for generate method (non-streaming)."""

    @patch("app.infrastructure.llm.gemini_client.genai")
    async def test_generate_successful_response(self, mock_genai):
        """Test successful text generation."""
        # Mock model response
        mock_response = MagicMock()
        mock_response.text = "Generated response from Gemini"

        mock_model = MagicMock()
        mock_model.generate_content_async = AsyncMock(return_value=mock_response)
        mock_genai.GenerativeModel.return_value = mock_model
        mock_genai.GenerationConfig = MagicMock()

        client = GeminiClient(api_key="valid-key")
        result = await client.generate(prompt="What is AI?", max_tokens=100)

        assert result == "Generated response from Gemini"
        mock_model.generate_content_async.assert_called_once()

    @patch("app.infrastructure.llm.gemini_client.genai")
    async def test_generate_with_custom_parameters(self, mock_genai):
        """Test generate with custom max_tokens and temperature."""
        mock_response = MagicMock()
        mock_response.text = "Response"

        mock_model = MagicMock()
        mock_model.generate_content_async = AsyncMock(return_value=mock_response)
        mock_genai.GenerativeModel.return_value = mock_model
        mock_genai.GenerationConfig = MagicMock(return_value="config")

        client = GeminiClient(api_key="valid-key")
        result = await client.generate(prompt="Test", max_tokens=200, temperature=0.5)

        assert result == "Response"

    @patch("app.infrastructure.llm.gemini_client.genai")
    async def test_generate_google_api_error(self, mock_genai):
        """Test generate handles GoogleAPIError."""
        mock_model = MagicMock()
        mock_model.generate_content_async = AsyncMock(
            side_effect=GoogleAPIError("API quota exceeded")
        )
        mock_genai.GenerativeModel.return_value = mock_model
        mock_genai.GenerationConfig = MagicMock()

        client = GeminiClient(api_key="valid-key")

        with pytest.raises(LLMConnectionError) as exc_info:
            await client.generate(prompt="Test")

        assert "Gemini API connection failed" in str(exc_info.value)
        assert exc_info.value.details["provider"] == "gemini"

    @patch("app.infrastructure.llm.gemini_client.genai")
    async def test_generate_unexpected_error(self, mock_genai):
        """Test generate handles unexpected exceptions."""
        mock_model = MagicMock()
        mock_model.generate_content_async = AsyncMock(
            side_effect=RuntimeError("Unexpected failure")
        )
        mock_genai.GenerativeModel.return_value = mock_model
        mock_genai.GenerationConfig = MagicMock()

        client = GeminiClient(api_key="valid-key")

        with pytest.raises(LLMConnectionError) as exc_info:
            await client.generate(prompt="Test")

        assert "Gemini unexpected error" in str(exc_info.value)


@pytest.mark.asyncio
class TestStreamGenerate:
    """Test suite for stream_generate method (streaming)."""

    @patch("app.infrastructure.llm.gemini_client.genai")
    async def test_stream_generate_successful(self, mock_genai):
        """Test successful streaming generation."""
        # Mock streaming chunks
        mock_chunk_1 = MagicMock()
        mock_chunk_1.text = "First "

        mock_chunk_2 = MagicMock()
        mock_chunk_2.text = "Second "

        mock_chunk_3 = MagicMock()
        mock_chunk_3.text = "Third"

        async def mock_stream():
            for chunk in [mock_chunk_1, mock_chunk_2, mock_chunk_3]:
                yield chunk

        mock_model = MagicMock()
        mock_model.generate_content_async = AsyncMock(return_value=mock_stream())
        mock_genai.GenerativeModel.return_value = mock_model
        mock_genai.GenerationConfig = MagicMock()

        client = GeminiClient(api_key="valid-key")

        # Collect streamed tokens
        tokens = []
        async for token in client.stream_generate(prompt="Stream test"):
            tokens.append(token)

        assert tokens == ["First ", "Second ", "Third"]

    @patch("app.infrastructure.llm.gemini_client.genai")
    async def test_stream_generate_with_empty_chunks(self, mock_genai):
        """Test streaming handles chunks with empty text."""
        mock_chunk_valid = MagicMock()
        mock_chunk_valid.text = "Valid"

        mock_chunk_empty = MagicMock()
        mock_chunk_empty.text = ""

        mock_chunk_none = MagicMock()
        mock_chunk_none.text = None

        async def mock_stream():
            for chunk in [mock_chunk_valid, mock_chunk_empty, mock_chunk_none]:
                yield chunk

        mock_model = MagicMock()
        mock_model.generate_content_async = AsyncMock(return_value=mock_stream())
        mock_genai.GenerativeModel.return_value = mock_model
        mock_genai.GenerationConfig = MagicMock()

        client = GeminiClient(api_key="valid-key")

        tokens = []
        async for token in client.stream_generate(prompt="Test"):
            tokens.append(token)

        # Only non-empty chunks should be yielded
        assert tokens == ["Valid"]

    @patch("app.infrastructure.llm.gemini_client.genai")
    async def test_stream_generate_google_api_error(self, mock_genai):
        """Test stream_generate handles GoogleAPIError."""
        mock_model = MagicMock()
        mock_model.generate_content_async = AsyncMock(
            side_effect=GoogleAPIError("Streaming failed")
        )
        mock_genai.GenerativeModel.return_value = mock_model
        mock_genai.GenerationConfig = MagicMock()

        client = GeminiClient(api_key="valid-key")

        with pytest.raises(LLMStreamError) as exc_info:
            async for _ in client.stream_generate(prompt="Test"):
                pass

        assert "Gemini streaming failed" in str(exc_info.value)
        assert exc_info.value.details["provider"] == "gemini"

    @patch("app.infrastructure.llm.gemini_client.genai")
    async def test_stream_generate_unexpected_error(self, mock_genai):
        """Test stream_generate handles unexpected exceptions."""
        mock_model = MagicMock()
        mock_model.generate_content_async = AsyncMock(
            side_effect=ValueError("Unexpected error")
        )
        mock_genai.GenerativeModel.return_value = mock_model
        mock_genai.GenerationConfig = MagicMock()

        client = GeminiClient(api_key="valid-key")

        with pytest.raises(LLMStreamError) as exc_info:
            async for _ in client.stream_generate(prompt="Test"):
                pass

        assert "Unexpected error during Gemini streaming" in str(exc_info.value)

    @patch("app.infrastructure.llm.gemini_client.genai")
    async def test_stream_generate_with_parameters(self, mock_genai):
        """Test stream_generate with custom max_tokens and temperature."""
        mock_chunk = MagicMock()
        mock_chunk.text = "Token"

        async def mock_stream():
            yield mock_chunk

        mock_model = MagicMock()
        mock_model.generate_content_async = AsyncMock(return_value=mock_stream())
        mock_genai.GenerativeModel.return_value = mock_model
        mock_genai.GenerationConfig = MagicMock(return_value="config")

        client = GeminiClient(api_key="valid-key")

        tokens = []
        async for token in client.stream_generate(
            prompt="Test", max_tokens=500, temperature=0.8
        ):
            tokens.append(token)

        assert tokens == ["Token"]
        # Verify config was built with parameters
        mock_genai.GenerationConfig.assert_called()
