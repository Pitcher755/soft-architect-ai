"""
VectorStoreService: Vector embedding persistence layer (HU-2.2)

Responsibilities:
1. Connect to ChromaDB (HTTP)
2. Transform LangChain documents to Chroma format
3. Generate deterministic IDs for idempotency
4. Handle errors with controlled error codes

Architecture: Adapter Pattern (ChromaDB is an external dependency)
"""

import hashlib
import logging
import time
from collections.abc import Callable
from functools import wraps
from typing import Any

import chromadb
from langchain_core.documents import Document

from core.exceptions import (
    ConnectionError,
    DatabaseReadError,
    DatabaseWriteError,
)

logger = logging.getLogger(__name__)


def retry_with_backoff(max_retries: int = 3, base_delay: float = 1.0):
    """
    Decorator for retry logic with exponential backoff.

    Strategy:
    - 1st attempt: fails → wait 1s
    - 2nd attempt: fails → wait 2s
    - 3rd attempt: fails → wait 4s
    - If all fail → raise exception

    Args:
        max_retries: Maximum number of retry attempts
        base_delay: Initial delay in seconds
    """

    def decorator(func: Callable) -> Callable:
        @wraps(func)
        def wrapper(*args, **kwargs):
            last_exception = None
            for attempt in range(max_retries):
                try:
                    return func(*args, **kwargs)
                except Exception as e:
                    last_exception = e
                    if attempt < max_retries - 1:
                        delay = base_delay * (2**attempt)
                        logger.warning(
                            f"Attempt {attempt + 1} failed: {e}. "
                            f"Retrying in {delay}s..."
                        )
                        time.sleep(delay)

            if last_exception:
                raise last_exception

        return wrapper

    return decorator


class VectorStoreService:
    """
    Service for managing vector embeddings in ChromaDB.

    Implements idempotent document ingestion with deterministic ID generation,
    error handling with specific error codes, and retry logic for resilience.

    Attributes:
        host (str): ChromaDB server hostname
        port (int): ChromaDB server port
        collection_name (str): Name of the Chroma collection
        client: ChromaDB HTTP client instance
        collection: Active Chroma collection object
    """

    def __init__(
        self,
        host: str = "localhost",
        port: int = 8000,
        collection_name: str = "softarchitect_knowledge_base",
    ):
        """
        Initialize VectorStoreService with ChromaDB connection.

        Args:
            host: ChromaDB server hostname (default: localhost)
            port: ChromaDB server port (default: 8000)
            collection_name: Name of collection to use

        Raises:
            ConnectionError: If connection to ChromaDB fails (code SYS_001)
        """
        self.host = host
        self.port = port
        self.collection_name = collection_name

        try:
            logger.info(f"Attempting to connect to ChromaDB at {host}:{port}...")
            self.client = chromadb.HttpClient(host=host, port=port)

            # Verify connection with heartbeat
            heartbeat_result = self.client.heartbeat()
            # heartbeat() returns milliseconds (int), not a dict
            if not isinstance(heartbeat_result, (int, float)) or heartbeat_result <= 0:
                raise Exception(f"Heartbeat check failed: {heartbeat_result}")

            logger.info("✅ ChromaDB connection successful")

            # Get or create collection
            self.collection = self.client.get_or_create_collection(
                name=collection_name,
                metadata={"description": "SoftArchitect AI Knowledge Base"},
            )
            logger.info(f"✅ Collection '{collection_name}' ready")

        except Exception as e:
            logger.error(f"❌ Connection failed: {e}")
            raise ConnectionError(host=host, port=port, reason=str(e)) from e

    def _generate_id(self, content: str, source: str) -> str:
        """
        Generate deterministic ID for document (hash-based).

        Ensures idempotency: same content + source always produces same ID.

        Args:
            content: Document page content
            source: Document source/filename

        Returns:
            32-character MD5 hash string
        """
        raw_id = f"{content.strip()}::{source.strip()}"
        return hashlib.md5(raw_id.encode("utf-8")).hexdigest()  # noqa: S324 - MD5 used for deterministic hashing, not cryptography

    def _clean_metadata(self, metadata: dict[str, Any]) -> dict[str, Any]:
        """
        Clean metadata to only include Chroma-compatible types.

        Chroma only supports: str, int, float, bool.
        Removes lists, dicts, None values, and complex types.

        Args:
            metadata: Raw metadata dictionary

        Returns:
            Cleaned metadata with only valid types
        """
        cleaned = {}
        valid_types = (str, int, float, bool)

        for key, value in metadata.items():
            if isinstance(value, valid_types):
                cleaned[key] = value
            elif value is None:
                # Skip None values
                continue
            else:
                # Convert other types to string if they exist
                logger.debug(f"Skipping metadata field '{key}' with type {type(value)}")

        return cleaned

    @retry_with_backoff(max_retries=3, base_delay=1.0)
    def ingest(self, documents: list[Document]) -> int:
        """
        Ingest documents into ChromaDB with deterministic IDs.

        Implements idempotency: running twice with same documents
        won't create duplicates (ChromaDB upsert semantics).

        Args:
            documents: List of LangChain Document objects

        Returns:
            Number of documents ingested

        Raises:
            DatabaseWriteError: If upsert operation fails
        """
        if not documents:
            logger.info("No documents to ingest")
            return 0

        try:
            ids = []
            texts = []
            metadatas = []

            for doc in documents:
                # Generate deterministic ID
                doc_id = self._generate_id(
                    doc.page_content, doc.metadata.get("source", "unknown")
                )
                ids.append(doc_id)
                texts.append(doc.page_content)

                # Clean metadata
                cleaned_meta = self._clean_metadata(doc.metadata)
                metadatas.append(cleaned_meta)

            # Upsert to collection (idempotent operation)
            self.collection.upsert(ids=ids, documents=texts, metadatas=metadatas)

            logger.info(f"✅ Successfully ingested {len(documents)} documents")
            return len(documents)

        except Exception as e:
            logger.error(f"❌ Ingestion failed: {e}")
            raise DatabaseWriteError(operation="upsert", reason=str(e)) from e

    def query(self, query_text: str, n_results: int = 5) -> dict[str, Any]:
        """
        Query the vector store for semantically similar documents.

        Args:
            query_text: Query text to find similar documents
            n_results: Number of results to return (default: 5)

        Returns:
            Dictionary with 'documents', 'metadatas', 'distances', 'ids'

        Raises:
            DatabaseReadError: If query operation fails
        """
        try:
            results = self.collection.query(
                query_texts=[query_text], n_results=n_results
            )
            logger.debug(f"Query returned {len(results['documents'][0])} results")
            return results

        except Exception as e:
            logger.error(f"❌ Query failed: {e}")
            raise DatabaseReadError(operation="query", reason=str(e)) from e

    def health_check(self) -> bool:
        """
        Check if ChromaDB is healthy and collection is accessible.

        Returns:
            True if healthy

        Raises:
            ConnectionError: If heartbeat fails
        """
        try:
            heartbeat = self.client.heartbeat()
            # heartbeat() returns milliseconds (int), not a dict
            if not isinstance(heartbeat, (int, float)) or heartbeat <= 0:
                raise Exception(f"Heartbeat check failed: {heartbeat}")

            logger.debug("✅ ChromaDB health check passed")
            return True

        except Exception as e:
            logger.error(f"❌ Health check failed: {e}")
            raise ConnectionError(host=self.host, port=self.port, reason=str(e)) from e

    def get_collection_stats(self) -> dict[str, Any]:
        """
        Get statistics about the collection.

        Returns:
            Dictionary with collection metadata and stats
        """
        try:
            collection_metadata = self.collection.metadata
            count = self.collection.count()

            return {
                "collection_name": self.collection_name,
                "metadata": collection_metadata,
                "document_count": count,
                "host": self.host,
                "port": self.port,
            }

        except Exception as e:
            logger.error(f"❌ Failed to get collection stats: {e}")
            raise DatabaseReadError(operation="get_stats", reason=str(e)) from e
