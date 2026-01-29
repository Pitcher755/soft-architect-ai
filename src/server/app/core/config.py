"""
Configuration settings for SoftArchitect AI backend.
Loads from .env file with sensible defaults.
"""

from typing import Literal

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """
    Application settings from environment variables.

    Attributes:
        DEBUG: Enable debug mode (default: False)
        APP_NAME: Application name (default: "SoftArchitect AI")
        APP_VERSION: Application version (default: "0.1.0")
        API_V1_STR: API v1 prefix (default: "/api/v1")

        LLM_PROVIDER: LLM provider ('local' for Ollama, 'cloud' for Groq)
        OLLAMA_BASE_URL: Ollama server URL
        GROQ_API_KEY: Groq API key for cloud inference

        CHROMADB_PATH: Local ChromaDB storage path
        CHROMA_COLLECTION_NAME: Vector collection name

        LOG_LEVEL: Logging level (DEBUG, INFO, WARNING, ERROR)
    """

    # App Configuration
    DEBUG: bool = False
    APP_NAME: str = "SoftArchitect AI"
    APP_VERSION: str = "0.1.0"
    API_V1_STR: str = "/api/v1"

    # LLM Configuration
    LLM_PROVIDER: Literal["local", "cloud"] = "local"
    OLLAMA_BASE_URL: str = "http://localhost:11434"
    GROQ_API_KEY: str = ""

    # Vector Store Configuration
    CHROMADB_PATH: str = "./data/chromadb"
    CHROMA_COLLECTION_NAME: str = "softarchitect"

    # Logging
    LOG_LEVEL: str = "INFO"

    class Config:
        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = True


# Global settings instance
settings = Settings()
