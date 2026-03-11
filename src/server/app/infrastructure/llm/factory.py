"""Factory for creating LLM clients based on configuration.

Allows runtime switching between Ollama, Groq, and Gemini based on environment variable.
"""

import logging
import os

from app.infrastructure.llm.base import BaseLLMClient
from app.infrastructure.llm.gemini_client import GeminiClient
from app.infrastructure.llm.groq_client import GroqClient
from app.infrastructure.llm.ollama_client import OllamaClient

logger = logging.getLogger(__name__)


def get_llm_client(mode: str | None = None) -> BaseLLMClient:
    """Factory function to create LLM client based on mode."""
    # Leemos la variable unificada LLM_PROVIDER
    selected_mode = (mode or os.getenv("LLM_PROVIDER", "ollama")).lower()

    if selected_mode == "ollama":
        base_url = os.getenv("OLLAMA_BASE_URL", "http://sa_ollama:11434")
        model = os.getenv("OLLAMA_MODEL", "llama3.2")
        timeout = float(os.getenv("OLLAMA_TIMEOUT", "30.0"))

        logger.info(f"Creating Ollama client: {base_url}, model={model}")
        return OllamaClient(base_url=base_url, model=model, timeout=timeout)

    if selected_mode == "groq":
        api_key = os.getenv("GROQ_API_KEY", "")
        if not api_key:
            logger.warning("GROQ_API_KEY not set - Groq client will fail")

        logger.info("Creating Groq client")
        return GroqClient(api_key=api_key)

    if selected_mode == "gemini":
        api_key = os.getenv("GEMINI_API_KEY", "")
        if not api_key:
            logger.warning("GEMINI_API_KEY not set - Gemini client will fail")

        model = os.getenv("GEMINI_MODEL", "gemini-1.5-flash")
        logger.info(f"Creating Gemini client, model={model}")
        return GeminiClient(api_key=api_key, model=model)

    raise ValueError(f"Invalid LLM mode: {selected_mode}. Supported: ollama, groq, gemini")
