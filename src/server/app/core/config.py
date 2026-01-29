"""
Configuration settings for SoftArchitect AI backend.

This module provides type-safe configuration management using Pydantic Settings.
All environment variables are read from .env file with sensible defaults.

Configuration Categories:
    - App Configuration: APP_NAME, APP_VERSION, DEBUG, API_V1_STR
    - LLM Configuration: LLM_PROVIDER, OLLAMA_BASE_URL, GROQ_API_KEY
    - Vector Store: CHROMADB_PATH, CHROMA_COLLECTION_NAME
    - Logging: LOG_LEVEL

Environment Variables (.env file):
    DEBUG (bool): Enable debug mode (default: False)
    APP_NAME (str): Application name (default: "SoftArchitect AI")
    APP_VERSION (str): Application version (default: "0.1.0")
    API_V1_STR (str): API v1 prefix (default: "/api/v1")
    LLM_PROVIDER (str): Either "local" (Ollama) or "cloud" (Groq)
    OLLAMA_BASE_URL (str): Ollama server URL (default: http://localhost:11434)
    GROQ_API_KEY (str): Groq API key for cloud inference (default: empty)
    CHROMADB_PATH (str): Local ChromaDB storage path (default: ./data/chromadb)
    CHROMA_COLLECTION_NAME (str): Vector collection name (default: softarchitect)
    LOG_LEVEL (str): Logging level - DEBUG, INFO, WARNING, ERROR (default: INFO)

Security Notes:
    - NO secrets should be hardcoded in code
    - API keys are loaded from .env file (NEVER commit .env)
    - Use environment variable injection in production
    - Settings instance is a singleton accessible as 'settings' in this module
"""

from typing import Literal

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """
    Application settings from environment variables.

    This class uses Pydantic BaseSettings to load configuration from
    environment variables and .env file with validation and type checking.

    Attributes:
        DEBUG: Enable debug mode and verbose logging
        APP_NAME: Name displayed in API documentation and logs
        APP_VERSION: Semantic version of the application
        API_V1_STR: URL prefix for API v1 endpoints (e.g., /api/v1)

        LLM_PROVIDER: Which LLM backend to use ("local" or "cloud")
        OLLAMA_BASE_URL: HTTP URL to Ollama server for local inference
        GROQ_API_KEY: API key for Groq Cloud (if using cloud provider)

        CHROMADB_PATH: Filesystem path where ChromaDB stores vector embeddings
        CHROMA_COLLECTION_NAME: Name of the vector collection in ChromaDB

        LOG_LEVEL: Verbosity for application logging (DEBUG, INFO, WARNING, ERROR)
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
        """Pydantic configuration for Settings class."""

        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = True


# Global settings instance
# Use this singleton throughout the application to access configuration
settings = Settings()
