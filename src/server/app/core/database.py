"""
Database and vector store initialization utilities.

This module provides functions to initialize and configure local data stores:
    - ChromaDB: Vector database for semantic search and embeddings
    - SQLite: Relational database for structured data

Both databases are stored locally to ensure data sovereignty and privacy.
The module automatically creates necessary directories if they don't exist.

Functions:
    init_chromadb(): Initialize ChromaDB vector store
    init_sqlite(): Initialize SQLite relational database

Directory Structure:
    ./data/chromadb/        - ChromaDB vector database files
    ./data/softarchitect.db - SQLite database file
"""

from pathlib import Path


def init_chromadb():
    """
    Initialize ChromaDB vector database connection.

    Creates the local data directory structure if it doesn't exist.
    ChromaDB is used for storing and retrieving vector embeddings
    from the knowledge base for RAG (Retrieval-Augmented Generation).

    Returns:
        Path: The path where ChromaDB data is stored

    Side Effects:
        Creates ./data/chromadb/ directory if it doesn't exist

    Note:
        This function is idempotent - it's safe to call multiple times
    """
    db_path = Path("./data/chromadb")
    db_path.parent.mkdir(parents=True, exist_ok=True)
    return db_path


def init_sqlite():
    """
    Initialize SQLite relational database connection.

    Creates the local data directory structure if it doesn't exist.
    SQLite is used for storing structured data like configuration,
    user sessions, and metadata that doesn't fit the vector model.

    Returns:
        str: SQLite connection string in the format "sqlite:///path/to/db.db"

    Side Effects:
        Creates ./data/ directory if it doesn't exist

    Note:
        This function is idempotent - it's safe to call multiple times
        The connection string is compatible with SQLAlchemy and other ORMs
    """
    db_path = Path("./data/softarchitect.db")
    db_path.parent.mkdir(parents=True, exist_ok=True)
    return f"sqlite:///{db_path}"
