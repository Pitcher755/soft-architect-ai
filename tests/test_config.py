"""
Configuration system tests.

Validates Pydantic Settings and environment variable loading.
"""

from core.config import get_settings


def test_settings_singleton():
    """Settings should be a singleton (cached)."""
    settings1 = get_settings()
    settings2 = get_settings()
    assert settings1 is settings2


def test_settings_defaults():
    """Default values should be set correctly."""
    settings = get_settings()
    assert settings.PROJECT_NAME == "SoftArchitect AI"
    assert settings.VERSION == "0.1.0"
    assert settings.API_V1_STR == "/api/v1"
    assert settings.HOST == "0.0.0.0"
    assert settings.PORT == 8000


def test_cors_origins_parsing():
    """CORS origins should be parsed correctly."""
    settings = get_settings()
    assert isinstance(settings.BACKEND_CORS_ORIGINS, list)
    assert len(settings.BACKEND_CORS_ORIGINS) > 0
