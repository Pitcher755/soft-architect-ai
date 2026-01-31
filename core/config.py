"""
Application configuration using Pydantic Settings.

Reads environment variables from .env file safely and with validation.
NO os.getenv() calls allowed (security rule).

Based on: context/20-REQUIREMENTS_AND_SPEC/SECURITY_AND_PRIVACY_RULES.en.md
"""

from functools import lru_cache

from pydantic import Field, field_validator
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """
    Application settings with type validation.

    All settings are read from environment variables or .env file.
    """

    # Project Info
    PROJECT_NAME: str = Field(default="SoftArchitect AI", description="Project name")
    VERSION: str = Field(default="0.1.0", description="API version")
    API_V1_STR: str = Field(default="/api/v1", description="API v1 prefix")
    DESCRIPTION: str = Field(
        default="AI-Powered Software Architecture Assistant",
        description="Project description",
    )

    # Environment
    DEBUG: bool = Field(default=False, description="Debug mode flag")
    ENVIRONMENT: str = Field(default="development", description="Environment name")

    # Server Configuration
    HOST: str = Field(default="0.0.0.0", description="Server host")  # noqa: S104
    PORT: int = Field(default=8000, description="Server port", ge=1, le=65535)

    # CORS Configuration (Security)
    BACKEND_CORS_ORIGINS: list[str] = Field(
        default=["http://localhost:3000", "http://localhost:8080"],
        description="Allowed CORS origins (whitelist)",
    )

    @field_validator("BACKEND_CORS_ORIGINS", mode="before")
    @classmethod
    def assemble_cors_origins(cls, v: str | list[str]) -> list[str]:
        """Parse CORS origins from comma-separated string or list."""
        if isinstance(v, str):
            return [origin.strip() for origin in v.split(",")]
        return v

    # ChromaDB Configuration
    CHROMADB_HOST: str = Field(default="localhost", description="ChromaDB host")
    CHROMADB_PORT: int = Field(
        default=8001, description="ChromaDB port", ge=1, le=65535
    )

    # Ollama Configuration
    OLLAMA_HOST: str = Field(default="localhost", description="Ollama host")
    OLLAMA_PORT: int = Field(default=11434, description="Ollama port", ge=1, le=65535)
    OLLAMA_MODEL: str = Field(
        default="llama3.2:latest", description="Ollama model name"
    )

    # LLM Provider (local or cloud)
    LLM_PROVIDER: str = Field(default="local", description="LLM provider (local/cloud)")

    # Groq Cloud (if LLM_PROVIDER=cloud)
    GROQ_API_KEY: str | None = Field(default=None, description="Groq API key")

    # Security
    SECRET_KEY: str = Field(
        default="CHANGE_ME_IN_PRODUCTION",  # noqa: S105
        description="Secret key for JWT/sessions",
    )

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=True,
        extra="ignore",  # Ignore extra env vars
    )


@lru_cache
def get_settings() -> Settings:
    """
    Get cached settings instance.

    Uses lru_cache to avoid reloading .env on every call.
    """
    return Settings()


# Global settings instance
settings = get_settings()
