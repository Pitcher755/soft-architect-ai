import logging
from collections.abc import AsyncGenerator
from typing import Any

import google.generativeai as genai
from google.api_core.exceptions import GoogleAPIError
from google.generativeai.types import HarmBlockThreshold, HarmCategory

from app.core.exceptions import LLMConnectionError, LLMStreamError
from app.infrastructure.llm.base import BaseLLMClient

logger = logging.getLogger(__name__)


class GeminiClient(BaseLLMClient):
    """Google Gemini LLM client."""

    def __init__(self, api_key: str, model: str = "gemini-1.5-flash"):
        if not api_key:
            raise ValueError("GEMINI_API_KEY is required")

        genai.configure(api_key=api_key)
        self.model_name = model

        # Opcional: Desactivar los filtros de seguridad si te bloquean código
        self.safety_settings = {
            HarmCategory.HARM_CATEGORY_HARASSMENT: HarmBlockThreshold.BLOCK_NONE,
            HarmCategory.HARM_CATEGORY_HATE_SPEECH: HarmBlockThreshold.BLOCK_NONE,
            HarmCategory.HARM_CATEGORY_SEXUALLY_EXPLICIT: HarmBlockThreshold.BLOCK_NONE,
            HarmCategory.HARM_CATEGORY_DANGEROUS_CONTENT: HarmBlockThreshold.BLOCK_NONE,
        }

        self.model = genai.GenerativeModel(self.model_name)
        logger.info(f"Initialized Gemini client, model={model}")

    def _build_config(
        self, max_tokens: int | None, temperature: float | None
    ) -> genai.GenerationConfig:
        config_args = {}
        if max_tokens is not None:
            config_args["max_output_tokens"] = max_tokens
        if temperature is not None:
            config_args["temperature"] = temperature
        return genai.GenerationConfig(**config_args)

    async def generate(
        self,
        prompt: str,
        max_tokens: int | None = None,
        temperature: float | None = None,
        **kwargs: Any,
    ) -> str:
        try:
            config = self._build_config(max_tokens, temperature)
            response = await self.model.generate_content_async(
                prompt, generation_config=config, safety_settings=self.safety_settings
            )
            return response.text

        except GoogleAPIError as error:
            logger.error(f"Gemini API error: {error}")
            raise LLMConnectionError(
                message=f"Gemini API connection failed: {error}",
                details={"provider": "gemini", "error": str(error)},
            ) from error
        except Exception as error:
            logger.error(f"Gemini unexpected error: {error}")
            raise LLMConnectionError(
                message=f"Gemini unexpected error: {error}",
                details={"provider": "gemini"},
            ) from error

    async def stream_generate(
        self,
        prompt: str,
        max_tokens: int | None = None,
        temperature: float | None = None,
        **kwargs: Any,
    ) -> AsyncGenerator[str, None]:

        try:
            config = self._build_config(max_tokens, temperature)
            response = await self.model.generate_content_async(
                prompt, generation_config=config, safety_settings=self.safety_settings, stream=True
            )

            async for chunk in response:
                if chunk.text:
                    yield chunk.text

        except GoogleAPIError as error:
            logger.error(f"Gemini API stream error: {error}")
            raise LLMStreamError(
                message=f"Gemini streaming failed: {error}",
                details={"provider": "gemini", "error": str(error)},
            ) from error
        except Exception as error:
            logger.error(f"Gemini unexpected streaming error: {error}")
            raise LLMStreamError(
                message=f"Unexpected error during Gemini streaming: {str(error)}",
                details={"provider": "gemini"},
            ) from error
