"""Factory for creating LLM clients based on configuration.

Allows runtime switching between Ollama and Groq based on environment variable.
"""

import logging
import os

from app.infrastructure.llm.base import BaseLLMClient
from app.infrastructure.llm.groq_client import GroqClient
from app.infrastructure.llm.ollama_client import OllamaClient

logger = logging.getLogger(__name__)


def get_llm_client(mode: str | None = None) -> BaseLLMClient:
    """Factory function to create LLM client based on mode."""
    selected_mode = (mode or os.getenv("LLM_PROVIDER", "ollama")).lower()

    if selected_mode == "ollama":
        base_url = os.getenv("OLLAMA_BASE_URL", "http://localhost:11434")
        model = os.getenv("OLLAMA_MODEL", "llama2")
        timeout = float(os.getenv("OLLAMA_TIMEOUT", "30.0"))

        logger.info(f"Creating Ollama client: {base_url}, model={model}")
        return OllamaClient(base_url=base_url, model=model, timeout=timeout)

    if selected_mode == "groq":
        api_key = os.getenv("GROQ_API_KEY", "")
        if not api_key:
            logger.warning("GROQ_API_KEY not set - Groq client will fail")

        logger.info("Creating Groq client (stub)")
        return GroqClient(api_key=api_key)

    raise ValueError(f"Invalid LLM mode: {selected_mode}. Supported: ollama, groq")
