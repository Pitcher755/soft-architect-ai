"""Unit tests for LLM factory (Strategy runtime selection)."""

import pytest

from app.infrastructure.llm.factory import get_llm_client
from app.infrastructure.llm.groq_client import GroqClient
from app.infrastructure.llm.ollama_client import OllamaClient


class TestLLMFactory:
    """Test LLM factory runtime selection behavior."""

    def test_factory_returns_ollama_client(self, monkeypatch):
        """Factory should return Ollama client for ollama mode."""
        monkeypatch.setenv("LLM_PROVIDER", "ollama")
        monkeypatch.setenv("OLLAMA_BASE_URL", "http://localhost:11434")
        monkeypatch.setenv("OLLAMA_MODEL", "llama2")
        monkeypatch.setenv("OLLAMA_TIMEOUT", "15.0")

        client = get_llm_client()
        assert isinstance(client, OllamaClient)

    def test_factory_returns_groq_client(self, monkeypatch):
        """Factory should return Groq client for groq mode."""
        monkeypatch.setenv("LLM_PROVIDER", "groq")
        monkeypatch.setenv("GROQ_API_KEY", "test-key")

        client = get_llm_client()
        assert isinstance(client, GroqClient)

    def test_factory_rejects_invalid_mode(self):
        """Factory should raise ValueError for unsupported mode."""
        with pytest.raises(ValueError, match="Invalid LLM mode"):
            get_llm_client(mode="invalid")
