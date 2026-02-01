"""
Tests for app.core.config module.

Covers all configuration settings and initialization.
"""

from app.core.config import Settings, settings


class TestSettingsInitialization:
    """Test Settings class initialization and defaults."""

    def test_settings_singleton(self):
        """✅ Should load global settings singleton."""
        assert settings is not None
        assert isinstance(settings, Settings)

    def test_default_values(self):
        """✅ Should have correct default values."""
        assert settings.DEBUG is False
        assert settings.APP_NAME == "SoftArchitect AI"
        assert settings.APP_VERSION == "0.1.0"
        assert settings.API_V1_STR == "/api/v1"
        assert settings.LLM_PROVIDER == "local"
        assert settings.OLLAMA_BASE_URL == "http://localhost:11434"
        assert settings.CHROMADB_PATH == "./data/chromadb"
        assert settings.LOG_LEVEL == "INFO"

    def test_all_required_attributes_present(self):
        """✅ Should have all required attributes."""
        required_attrs = [
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
        for attr in required_attrs:
            assert hasattr(settings, attr)

    def test_llm_provider_literal(self):
        """✅ LLM_PROVIDER should only be 'local' or 'cloud'."""
        assert settings.LLM_PROVIDER in ["local", "cloud"]

    def test_log_level_is_valid(self):
        """✅ LOG_LEVEL should be one of standard levels."""
        assert settings.LOG_LEVEL in ["DEBUG", "INFO", "WARNING", "ERROR", "CRITICAL"]

    def test_types_validation(self):
        """✅ All settings should have correct types."""
        assert isinstance(settings.DEBUG, bool)
        assert isinstance(settings.APP_NAME, str)
        assert isinstance(settings.APP_VERSION, str)
        assert isinstance(settings.API_V1_STR, str)
        assert isinstance(settings.LLM_PROVIDER, str)
        assert isinstance(settings.OLLAMA_BASE_URL, str)
        assert isinstance(settings.CHROMADB_PATH, str)
        assert isinstance(settings.LOG_LEVEL, str)

    def test_api_v1_str_format(self):
        """✅ API_V1_STR should start with /api/."""
        assert settings.API_V1_STR.startswith("/api/")

    def test_settings_accessible_globally(self):
        """✅ Settings should be accessible as module singleton."""
        from app.core.config import settings as imported_settings

        assert imported_settings is settings
