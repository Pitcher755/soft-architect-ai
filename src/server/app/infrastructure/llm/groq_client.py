"""Groq LLM client implementation (cloud inference) - STUB.

Currently returns placeholder. Full implementation in future sprint.
"""

import logging
from collections.abc import AsyncGenerator

from app.infrastructure.llm.base import BaseLLMClient

logger = logging.getLogger(__name__)


class GroqClient(BaseLLMClient):
    """Groq cloud LLM client (stub implementation)."""

    def __init__(self, api_key: str):
        self.api_key = api_key
        logger.warning("GroqClient is a STUB - not fully implemented yet")

    async def generate(
        self,
        prompt: str,
        max_tokens: int | None = None,
        temperature: float | None = None,
    ) -> str:
        logger.warning("GroqClient.generate() called - returning stub response")
        return "STUB: Groq API not yet implemented. Please use Ollama for now."

    async def stream_generate(
        self,
        prompt: str,
        max_tokens: int | None = None,
        temperature: float | None = None,
    ) -> AsyncGenerator[str, None]:
        """
        Stream generate for Groq (not yet implemented - HU-4.3).

        TODO: Implement Groq streaming when API is available.
        Groq uses OpenAI-compatible API, likely supports SSE.

        Args:
            prompt: The prompt to send to Groq
            max_tokens: Optional token limit for response
            temperature: Optional sampling temperature (0.0-1.0)

        Yields:
            Individual tokens (currently raises NotImplementedError)

        Raises:
            NotImplementedError: Groq streaming not yet implemented
        """
        logger.warning("GroqClient.stream_generate() called - not yet implemented")
        raise NotImplementedError(
            "Groq streaming not yet implemented. Use Ollama for now."
        )
        # Yield to satisfy AsyncGenerator type hint (unreachable)
        yield ""  # pragma: no cover
