"""
VectorStoreService: Capa de persistencia para RAG (HU-2.2)

Responsabilidades:
1. Conectar a ChromaDB (HTTP)
2. Transformar documentos de LangChain a formato Chroma
3. Generar IDs deterministas para idempotencia
4. Manejar errores con códigos controlados

Architecture: Adapter Pattern (ChromaDB is an external dependency)
"""

import hashlib
import logging

import chromadb
from langchain_core.documents import Document

from core.exceptions.base import VectorStoreError

logger = logging.getLogger(__name__)


class VectorStoreService:
    """
    Service for managing vector embeddings in ChromaDB.

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
            collection_name: Name of collection to use (default: softarchitect_knowledge_base)

        Raises:
            VectorStoreError: If connection to ChromaDB fails (code SYS_001)
        """
        self.host = host
        self.port = port
        self.collection_name = collection_name

        try:
            logger.info(f"Attempting to connect to ChromaDB at {host}:{port}...")

            # Initialize HTTP client (for Docker/production)
            self.client = chromadb.HttpClient(host=host, port=port)

            # Check connection with heartbeat
            heartbeat_response = self.client.heartbeat()
            logger.info(f"ChromaDB heartbeat OK: {heartbeat_response}")

            # Get or create collection with HNSW space for semantic similarity
            self.collection = self.client.get_or_create_collection(
                name=self.collection_name,
                metadata={
                    "hnsw:space": "cosine",  # Cosine similarity for embeddings
                    "description": "SoftArchitect AI Knowledge Base",
                },
            )

            logger.info(
                f"✅ Successfully connected to ChromaDB collection: {self.collection_name}"
            )

        except chromadb.errors.ChromaError as e:
            logger.error(f"❌ ChromaDB native error: {e}")
            raise VectorStoreError(
                code="SYS_001",
                message=f"Failed to connect to ChromaDB at {host}:{port}",
                details={"host": host, "port": port, "error": str(e)},
            ) from e
        except Exception as e:
            logger.error(f"❌ Unexpected error connecting to ChromaDB: {e}")
            raise VectorStoreError(
                code="SYS_001",
                message="Connection refused: ChromaDB is not reachable",
                details={"error": str(e)},
            ) from e

    def _generate_id(self, content: str, source: str) -> str:
        """
        Generate deterministic ID for document (hash-based for idempotency).

        Uses MD5 hash of content + source to ensure:
        - Same document always gets same ID
        - IDs are unique per document content
        - Idempotency: running ingest twice doesn't duplicate

        Args:
            content: Document page content
            source: Document source path

        Returns:
            Hexadecimal MD5 hash (32 characters)
        """
        raw_id = f"{source}:{content[:100]}"  # Use source + first 100 chars
        return hashlib.md5(raw_id.encode("utf-8")).hexdigest()  # noqa: S324

    def _clean_metadata(self, metadata: dict) -> dict:
        """
        Clean document metadata for Chroma compatibility.

        Chroma only accepts: str, int, float, bool
        This method filters out complex types (list, dict, None)

        Args:
            metadata: Raw metadata dict

        Returns:
            Cleaned metadata with only Chroma-compatible types
        """
        cleaned = {}
        for key, value in metadata.items():
            if isinstance(value, str | int | float | bool):
                cleaned[key] = value
            elif value is not None:
                # Log non-serializable metadata (for debugging)
                logger.debug(
                    f"Filtered out non-serializable metadata: {key}={type(value)}"
                )
        return cleaned

    def ingest(self, documents: list[Document]) -> int:
        """
        Ingest documents into ChromaDB vector store.

        Process:
        1. Validate and transform documents
        2. Generate deterministic IDs
        3. Clean metadata
        4. Upsert into Chroma (idempotent)

        Args:
            documents: List of LangChain Document objects

        Returns:
            Number of documents successfully ingested

        Raises:
            VectorStoreError: If upsert operation fails
        """
        if not documents:
            logger.warning("No documents provided for ingestion")
            return 0

        logger.info(f"Starting ingestion of {len(documents)} documents...")

        ids = []
        texts = []
        metadatas = []

        # Transform documents
        for i, doc in enumerate(documents):
            try:
                # Generate deterministic ID
                doc_id = self._generate_id(
                    content=doc.page_content,
                    source=doc.metadata.get("source", f"doc_{i}"),
                )
                ids.append(doc_id)

                # Add content
                texts.append(doc.page_content)

                # Clean and add metadata
                clean_meta = self._clean_metadata(doc.metadata)
                metadatas.append(clean_meta)

                logger.debug(f"Prepared document {i+1}/{len(documents)}: {doc_id}")

            except Exception as e:
                logger.error(f"Error preparing document {i}: {e}")
                raise VectorStoreError(
                    code="INGEST_001",
                    message=f"Error transforming document at index {i}",
                    details={"index": i, "error": str(e)},
                ) from e

        # Upsert to Chroma
        try:
            logger.info(
                f"Upserting {len(ids)} vectors to Chroma collection: {self.collection_name}"
            )

            self.collection.upsert(
                ids=ids,
                documents=texts,
                metadatas=metadatas,
                # embeddings: Chroma generates automatically using default model
            )

            logger.info(f"✅ Successfully ingested {len(ids)} documents")
            return len(ids)

        except Exception as e:
            logger.error(f"❌ Error upserting to ChromaDB: {e}")
            raise VectorStoreError(
                code="DB_WRITE_ERR",
                message="Failed to write vectors to database",
                details={"collection": self.collection_name, "error": str(e)},
            ) from e

    def query(self, query_text: str, n_results: int = 5) -> list[dict]:
        """
        Query the vector store for similar documents.

        Args:
            query_text: Text query to search
            n_results: Number of results to return

        Returns:
            List of similar documents with metadata

        Raises:
            VectorStoreError: If query fails
        """
        try:
            results = self.collection.query(
                query_texts=[query_text], n_results=n_results
            )
            logger.info(f"Query returned {len(results['documents'][0])} results")
            return results
        except Exception as e:
            logger.error(f"Error querying ChromaDB: {e}")
            raise VectorStoreError(
                code="DB_READ_ERR",
                message="Failed to query vector store",
                details={"error": str(e)},
            ) from e
