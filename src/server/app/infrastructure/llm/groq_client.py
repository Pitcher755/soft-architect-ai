"""Groq LLM client implementation (cloud inference) - STUB.

Currently returns placeholder. Full implementation in future sprint.
"""

import logging

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
