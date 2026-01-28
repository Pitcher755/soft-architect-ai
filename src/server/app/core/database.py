"""
Database and vector store configuration.
"""
from pathlib import Path


def init_chromadb():
    """
    Initialize ChromaDB connection.
    Creates local data directory if it doesn't exist.
    """
    db_path = Path("./data/chromadb")
    db_path.parent.mkdir(parents=True, exist_ok=True)
    return db_path


def init_sqlite():
    """
    Initialize SQLite connection.
    Creates local data directory if it doesn't exist.
    """
    db_path = Path("./data/softarchitect.db")
    db_path.parent.mkdir(parents=True, exist_ok=True)
    return f"sqlite:///{db_path}"
