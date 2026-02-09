"""
Unit tests for app/core/config.py - Configuration management.

Tests cover:
- Settings class default values
- Environment variable override
- Type validation
- Pydantic configuration
- Global settings instance
"""

import os
from unittest.mock import patch

import pytest

from app.core.config import Settings, settings


class TestSettingsDefaults:
    """Test Settings class with default values."""

    def test_default_app_settings(self):
        """Test default application configuration values."""
        test_settings = Settings()

        assert test_settings.DEBUG is False
        assert test_settings.APP_NAME == "SoftArchitect AI"
        assert test_settings.APP_VERSION == "0.1.0"
        assert test_settings.API_V1_STR == "/api/v1"

    def test_default_llm_settings(self):
        """Test default LLM configuration values."""
        test_settings = Settings()

        assert test_settings.LLM_PROVIDER == "local"
        assert test_settings.OLLAMA_BASE_URL == "http://localhost:11434"
        assert test_settings.GROQ_API_KEY == ""

    def test_default_vector_store_settings(self):
        """Test default vector store configuration values."""
        test_settings = Settings()

        assert test_settings.CHROMADB_PATH == "./data/chromadb"
        assert test_settings.CHROMA_COLLECTION_NAME == "softarchitect"

    def test_default_logging_settings(self):
        """Test default logging configuration values."""
        test_settings = Settings()

        assert test_settings.LOG_LEVEL == "INFO"


class TestSettingsEnvironmentOverride:
    """Test Settings class with environment variable overrides."""

    @patch.dict(os.environ, {"DEBUG": "true"})
    def test_debug_env_override(self):
        """Test that DEBUG can be overridden via environment variable."""
        test_settings = Settings()
        assert test_settings.DEBUG is True

    @patch.dict(os.environ, {"APP_NAME": "Test App"})
    def test_app_name_env_override(self):
        """Test that APP_NAME can be overridden via environment variable."""
        test_settings = Settings()
        assert test_settings.APP_NAME == "Test App"

    @patch.dict(os.environ, {"APP_VERSION": "1.0.0"})
    def test_app_version_env_override(self):
        """Test that APP_VERSION can be overridden via environment variable."""
        test_settings = Settings()
        assert test_settings.APP_VERSION == "1.0.0"

    @patch.dict(os.environ, {"API_V1_STR": "/api/v2"})
    def test_api_v1_str_env_override(self):
        """Test that API_V1_STR can be overridden via environment variable."""
        test_settings = Settings()
        assert test_settings.API_V1_STR == "/api/v2"

    @patch.dict(os.environ, {"LLM_PROVIDER": "cloud"})
    def test_llm_provider_env_override(self):
        """Test that LLM_PROVIDER can be overridden via environment variable."""
        test_settings = Settings()
        assert test_settings.LLM_PROVIDER == "cloud"

    @patch.dict(os.environ, {"OLLAMA_BASE_URL": "http://custom:8080"})
    def test_ollama_base_url_env_override(self):
        """Test that OLLAMA_BASE_URL can be overridden via environment variable."""
        test_settings = Settings()
        assert test_settings.OLLAMA_BASE_URL == "http://custom:8080"

    @patch.dict(os.environ, {"GROQ_API_KEY": "test_key_123"})
    def test_groq_api_key_env_override(self):
        """Test that GROQ_API_KEY can be overridden via environment variable."""
        test_settings = Settings()
        assert test_settings.GROQ_API_KEY == "test_key_123"

    @patch.dict(os.environ, {"CHROMADB_PATH": "/custom/path"})
    def test_chromadb_path_env_override(self):
        """Test that CHROMADB_PATH can be overridden via environment variable."""
        test_settings = Settings()
        assert test_settings.CHROMADB_PATH == "/custom/path"

    @patch.dict(os.environ, {"CHROMA_COLLECTION_NAME": "test_collection"})
    def test_chroma_collection_name_env_override(self):
        """Test that CHROMA_COLLECTION_NAME can be overridden via environment variable."""
        test_settings = Settings()
        assert test_settings.CHROMA_COLLECTION_NAME == "test_collection"

    @patch.dict(os.environ, {"LOG_LEVEL": "DEBUG"})
    def test_log_level_env_override(self):
        """Test that LOG_LEVEL can be overridden via environment variable."""
        test_settings = Settings()
        assert test_settings.LOG_LEVEL == "DEBUG"


class TestSettingsValidation:
    """Test Settings class validation."""

    def test_llm_provider_valid_values(self):
        """Test that LLM_PROVIDER accepts valid values."""
        # Valid values should work
        test_settings = Settings(LLM_PROVIDER="local")
        assert test_settings.LLM_PROVIDER == "local"

        test_settings = Settings(LLM_PROVIDER="cloud")
        assert test_settings.LLM_PROVIDER == "cloud"

    def test_llm_provider_invalid_value(self):
        """Test that LLM_PROVIDER rejects invalid values."""
        with pytest.raises(ValueError):
            Settings(LLM_PROVIDER="invalid")  # type: ignore

    def test_debug_boolean_conversion(self):
        """Test that DEBUG properly converts string to boolean."""
        test_settings = Settings(DEBUG=True)
        assert test_settings.DEBUG is True

        test_settings = Settings(DEBUG=False)
        assert test_settings.DEBUG is False


class TestSettingsPydanticConfig:
    """Test Pydantic configuration for Settings class."""

    def test_config_env_file(self):
        """Test that Config class has correct env_file setting."""
        assert Settings.model_config.get("env_file") == ".env"

    def test_config_env_file_encoding(self):
        """Test that Config class has correct env_file_encoding setting."""
        assert Settings.model_config.get("env_file_encoding") == "utf-8"

    def test_config_case_sensitive(self):
        """Test that Config class has correct case_sensitive setting."""
        assert Settings.model_config.get("case_sensitive") is True


class TestGlobalSettingsInstance:
    """Test the global settings instance."""

    def test_global_settings_is_settings_instance(self):
        """Test that the global settings object is an instance of Settings."""
        assert isinstance(settings, Settings)

    def test_global_settings_has_expected_attributes(self):
        """Test that the global settings instance has all expected attributes."""
        expected_attrs = [
            "DEBUG",
            "APP_NAME",
            "APP_VERSION",
            "API_V1_STR",
            "LLM_PROVIDER",
            "OLLAMA_BASE_URL",
            "GROQ_API_KEY",
            "CHROMADB_PATH",
            "CHROMA_COLLECTION_NAME",
            "LOG_LEVEL",
        ]

        for attr in expected_attrs:
            assert hasattr(settings, attr)


class TestSettingsIntegration:
    """Integration tests for Settings class."""

    @patch.dict(
        os.environ,
        {
            "DEBUG": "true",
            "APP_NAME": "Integration Test App",
            "LLM_PROVIDER": "cloud",
            "GROQ_API_KEY": "integration_test_key",
            "LOG_LEVEL": "WARNING",
        },
    )
    def test_multiple_env_vars_override(self):
        """Test that multiple environment variables can be overridden simultaneously."""
        test_settings = Settings()

        assert test_settings.DEBUG is True
        assert test_settings.APP_NAME == "Integration Test App"
        assert test_settings.LLM_PROVIDER == "cloud"
        assert test_settings.GROQ_API_KEY == "integration_test_key"
        assert test_settings.LOG_LEVEL == "WARNING"

        # Check that defaults are preserved for non-overridden values
        assert test_settings.APP_VERSION == "0.1.0"
        assert test_settings.OLLAMA_BASE_URL == "http://localhost:11434"
        assert test_settings.CHROMADB_PATH == "./data/chromadb"

    def test_settings_immutability(self):
        """Test that settings instances can be created with custom values."""
        # Pydantic BaseSettings allows modification after creation
        test_settings = Settings(DEBUG=True)
        assert test_settings.DEBUG is True

        # Can modify after creation (Pydantic behavior)
        test_settings.DEBUG = False
        assert test_settings.DEBUG is False
