"""RAG Services package - Vector store and embeddings management.

Exports:
- VectorStoreService: Service for managing vector embeddings in ChromaDB
"""

from services.rag.vector_store import VectorStoreService

__all__ = ["VectorStoreService"]
