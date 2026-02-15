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
)
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

    async def generate(
        self,
        prompt: str,
        max_tokens: int | None = None,
        temperature: float | None = None,
    ) -> str:
        endpoint = f"{self.base_url}/api/generate"
        payload = self._build_payload(prompt, max_tokens, temperature)

        try:
            async with httpx.AsyncClient(timeout=self.timeout) as client:
                response = await client.post(endpoint, json=payload)

                generated_text = await self._extract_generated_text(response)
                logger.debug(f"Ollama generated {len(generated_text)} chars")
                return generated_text

        except httpx.TimeoutException as error:
            logger.error(f"Ollama timeout: {error}")
            raise LLMTimeoutError(
                message=f"Ollama request timeout after {self.timeout}s",
                details={"timeout": self.timeout},
            ) from error

        except httpx.RequestError as error:
            logger.error(f"Ollama connection error: {error}")
            raise LLMConnectionError(
                message=f"Failed to connect to Ollama at {self.base_url}",
                details={"error": str(error)},
            ) from error

        except (ValueError, KeyError) as error:
            logger.error(f"Ollama invalid response: {error}")
            raise LLMConnectionError(
                message="Ollama returned invalid JSON response",
                details={"error": str(error)},
            ) from error

        except (LLMConnectionError, LLMTimeoutError):
            raise

        except Exception as error:
            logger.error(f"Ollama unexpected error: {error}")
            raise LLMConnectionError(
                message=f"Ollama unexpected failure: {error}",
                details={"error": str(error)},
            ) from error

    async def stream_generate(  # noqa: C901
        self,
        prompt: str,
        max_tokens: int | None = None,
        temperature: float | None = None,
    ) -> AsyncGenerator[str, None]:
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
