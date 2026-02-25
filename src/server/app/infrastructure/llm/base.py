"""Base protocol for LLM clients (Strategy Pattern).

Defines the contract that all LLM implementations must follow.
Allows seamless switching between Ollama, Groq, or future providers.
"""

from abc import ABC, abstractmethod
from collections.abc import AsyncGenerator
from typing import Any


class BaseLLMClient(ABC):
    """Abstract base class for LLM clients."""

    @abstractmethod
    async def generate(
        self,
        prompt: str,
        max_tokens: int | None = None,
        temperature: float | None = None,
        **kwargs: Any,
    ) -> str:
        """Generate a response from the underlying LLM.

        Args:
            prompt: The input prompt to send to the LLM
            max_tokens: Optional token limit for response
            temperature: Optional sampling temperature (0.0-1.0)

        Returns:
            Generated text response

        Raises:
            LLMConnectionError: If connection fails
            LLMTimeoutError: If request times out
        """
        ...

    @abstractmethod
    def stream_generate(
        self,
        prompt: str,
        max_tokens: int | None = None,
        temperature: float | None = None,
        **kwargs: Any,
    ) -> AsyncGenerator[str, None]:
        """
        Generate a streaming response from the LLM, yielding tokens progressively.

        This method enables real-time UI updates by yielding tokens as they are
        generated, dramatically improving perceived latency (Time To First Token).

        Args:
            prompt: The input prompt to send to the LLM
            max_tokens: Optional token limit for response
            temperature: Optional sampling temperature (0.0-1.0)

        Yields:
            Individual tokens as strings (e.g., "Hello", " world", "!")

        Raises:
            LLMConnectionError: If connection to LLM service fails
            LLMTimeoutError: If request times out
            LLMStreamError: If stream is interrupted or malformed

        Example:
            >>> async for token in client.stream_generate("Why is the sky blue?"):
            ...     print(token, end='', flush=True)
            The sky is blue because of Rayleigh scattering...
        """
        ...
