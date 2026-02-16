"""Ollama LLM client implementation (local inference).

Connects to local Ollama server via HTTP API.
Default model: llama2 (configurable via environment).
"""

import json
import logging
from collections.abc import AsyncGenerator
from inspect import isawaitable

import httpx

from app.core.exceptions import (
    LLMConnectionError,
    LLMStreamError,
    LLMTimeoutError,
    RetryExhaustedError,
)
from app.core.retry import with_retry
from app.infrastructure.llm.base import BaseLLMClient

logger = logging.getLogger(__name__)


class OllamaClient(BaseLLMClient):
    """Ollama local LLM client."""

    def __init__(
        self,
        base_url: str = "http://localhost:11434",
        model: str = "llama2",
        timeout: float = 30.0,
    ):
        self.base_url = base_url
        self.model = model
        self.timeout = timeout
        logger.info(f"Initialized Ollama client: {base_url}, model={model}")

    def _build_payload(
        self,
        prompt: str,
        max_tokens: int | None,
        temperature: float | None,
    ) -> dict[str, object]:
        payload: dict[str, object] = {
            "model": self.model,
            "prompt": prompt,
            "stream": False,
        }

        if max_tokens is not None:
            payload["options"] = {"num_predict": max_tokens}
        if temperature is not None:
            options = payload.setdefault("options", {})
            if isinstance(options, dict):
                options["temperature"] = temperature

        return payload

    async def _extract_generated_text(self, response: httpx.Response) -> str:
        if response.status_code != 200:
            raise LLMConnectionError(
                message=f"Ollama returned status {response.status_code}",
                details={
                    "status": response.status_code,
                    "body": str(getattr(response, "text", ""))[:200],
                },
            )

        data = response.json()
        if isawaitable(data):
            data = await data

        generated_text = data.get("response", "") if isinstance(data, dict) else ""
        if not generated_text:
            raise LLMConnectionError(
                message="Ollama returned empty response",
                details={"response": data},
            )

        return str(generated_text)

    @with_retry(
        max_retries=3,
        base_delay=0.5,
        retryable_exceptions=(httpx.RequestError, httpx.TimeoutException),
    )
    async def _generate_with_retry(
        self,
        prompt: str,
        max_tokens: int | None = None,
        temperature: float | None = None,
    ) -> str:
        """
        Internal method: Generate LLM response with retry logic.

        This method is wrapped by @with_retry and throws httpx exceptions.
        Use public generate() method which converts to domain exceptions.

        Raises:
            httpx.RequestError: On network failures (after retries)
            httpx.TimeoutException: On timeout (after retries)
            RetryExhaustedError: After 3 failed retries
        """
        endpoint = f"{self.base_url}/api/generate"
        payload = self._build_payload(prompt, max_tokens, temperature)

        async with httpx.AsyncClient(timeout=self.timeout) as client:
            response = await client.post(endpoint, json=payload)
            generated_text = await self._extract_generated_text(response)
            logger.debug(f"Ollama generated {len(generated_text)} chars")
            return generated_text

    async def generate(
        self,
        prompt: str,
        max_tokens: int | None = None,
        temperature: float | None = None,
    ) -> str:
        """
        Generate LLM response (Clean Architecture wrapper).

        Retry behavior (HU-4.4 GAP 2):
        - Max 3 retries on network errors
        - Exponential backoff: 0.5s, 1.0s, 2.0s
        - Logs WARNING on retries, INFO on success

        Args:
            prompt: The prompt to send to LLM
            max_tokens: Maximum tokens in response
            temperature: LLM temperature (0.0-1.0)

        Returns:
            Generated text from LLM

        Raises:
            LLMConnectionError: Network/connection failures (after 3 retries)
            LLMTimeoutError: Timeout errors (after 3 retries)
        """
        try:
            return await self._generate_with_retry(prompt, max_tokens, temperature)
        except RetryExhaustedError as error:
            # Map RetryExhaustedError to domain exception based on original cause
            if "timeout" in str(error).lower():
                logger.error(f"Ollama timeout after retries: {error}")
                raise LLMTimeoutError(
                    message=f"Request timeout after {error.attempts} attempts",
                    details={
                        "provider": "ollama",
                        "base_url": self.base_url,
                        "attempts": error.attempts,
                        "operation": "generate",
                    },
                ) from error
            else:
                logger.error(f"Ollama connection failed after retries: {error}")
                raise LLMConnectionError(
                    message=f"Failed to connect to Ollama after {error.attempts} attempts",
                    details={
                        "provider": "ollama",
                        "base_url": self.base_url,
                        "attempts": error.attempts,
                        "operation": "generate",
                    },
                ) from error
        except (ValueError, KeyError) as error:
            logger.error(f"Ollama response parsing error: {error}")
            raise LLMConnectionError(
                message=f"Failed to parse Ollama response: {error}",
                details={"provider": "ollama", "base_url": self.base_url},
            ) from error
        except Exception as error:
            logger.error(f"Ollama unexpected error: {error}")
            raise LLMConnectionError(
                message=f"Ollama unexpected error: {error}",
                details={"provider": "ollama", "base_url": self.base_url},
            ) from error

    async def stream_generate(  # noqa: C901
        self,
        prompt: str,
        max_tokens: int | None = None,
        temperature: float | None = None,
    ) -> AsyncGenerator[str, None]:
        """
        Stream LLM response from Ollama (NO RETRY - AsyncGenerators are complex).

        NOTE: Retry logic NOT implemented for streaming due to technical complexity:
        - AsyncGenerators execute lazily (not until first anext())
        - Retry would need to track partial stream state
        - Exception handling interferes with decorator pattern

        For retry behavior, use generate() (non-streaming) instead.
        """
        """
        Generate streaming response from Ollama, yielding tokens progressively.

        Ollama streams responses in NDJSON format (one JSON object per line).
        Each line contains: {"response": "token", "done": false}
        Final line: {"response": "", "done": true, "total_duration": 1234567890}

        Args:
            prompt: The prompt to send to Ollama
            max_tokens: Optional token limit for response
            temperature: Optional sampling temperature (0.0-1.0)

        Yields:
            Individual tokens as strings

        Raises:
            LLMConnectionError: If cannot connect to Ollama
            LLMTimeoutError: If streaming times out
            LLMStreamError: If stream is malformed or interrupted
        """
        endpoint = f"{self.base_url}/api/generate"
        payload = self._build_payload(prompt, max_tokens, temperature)
        payload["stream"] = True  # Enable streaming mode

        try:
            async with httpx.AsyncClient(timeout=self.timeout) as client:
                async with client.stream("POST", endpoint, json=payload) as response:
                    response.raise_for_status()

                    async for line in response.aiter_lines():
                        if not line.strip():
                            continue  # Skip empty lines

                        try:
                            data = json.loads(line)
                        except json.JSONDecodeError:
                            # Log malformed line but continue streaming
                            logger.warning(
                                f"Malformed JSON in Ollama stream: {line[:100]}"
                            )
                            continue

                        # Check if stream is done
                        if data.get("done", False):
                            logger.debug(
                                f"Ollama stream complete: {data.get('total_duration', 'N/A')}ns"
                            )
                            break

                        # Yield token if present
                        token = data.get("response", "")
                        if token:
                            yield token

        except httpx.ConnectError as error:
            logger.error(f"Ollama connection error: {error}")
            raise LLMConnectionError(
                message=f"Cannot connect to Ollama at {self.base_url}: {str(error)}",
                details={"base_url": self.base_url, "error": str(error)},
            ) from error

        except httpx.TimeoutException as error:
            logger.error(f"Ollama timeout: {error}")
            raise LLMTimeoutError(
                message=f"Ollama streaming timeout after {self.timeout}s: {str(error)}",
                details={"timeout": self.timeout, "error": str(error)},
            ) from error

        except httpx.HTTPStatusError as error:
            logger.error(f"Ollama HTTP error: {error}")
            raise LLMStreamError(
                message=f"Ollama HTTP error {error.response.status_code}: {error.response.text}",
                details={
                    "status_code": error.response.status_code,
                    "response_text": error.response.text[:200],
                },
            ) from error

        except (LLMConnectionError, LLMTimeoutError, LLMStreamError):
            raise

        except Exception as error:
            logger.error(f"Ollama unexpected streaming error: {error}")
            raise LLMStreamError(
                message=f"Unexpected error during Ollama streaming: {str(error)}",
                details={"error": str(error)},
            ) from error
