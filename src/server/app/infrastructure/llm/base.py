"""Base protocol for LLM clients (Strategy Pattern).

Defines the contract that all LLM implementations must follow.
Allows seamless switching between Ollama, Groq, or future providers.
"""

from abc import ABC, abstractmethod


class BaseLLMClient(ABC):
    """Abstract base class for LLM clients."""

    @abstractmethod
    async def generate(
        self,
        prompt: str,
        max_tokens: int | None = None,
        temperature: float | None = None,
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
