#!/usr/bin/env python
"""
Ingestion Script for SoftArchitect AI Knowledge Base (HU-2.2)

This script loads Markdown documents from the knowledge base,
transforms them into LangChain Documents, and ingests them
into ChromaDB for semantic search.

Usage:
    python src/server/scripts/ingest.py
    python src/server/scripts/ingest.py --host chromadb --port 8000
    python src/server/scripts/ingest.py --clear  # Clear existing collection

Environment:
    CHROMA_HOST: ChromaDB server hostname (default: localhost)
    CHROMA_PORT: ChromaDB server port (default: 8000)
"""

import argparse
import logging
import sys
from pathlib import Path

# Add src/server to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))

from langchain_core.documents import Document

from core.exceptions import ConnectionError as ChromaConnectionError
from services.rag.vector_store import VectorStoreService

# Configure logging
logging.basicConfig(
    level=logging.INFO, format="%(asctime)s - %(name)s - %(levelname)s - %(message)s"
)
logger = logging.getLogger(__name__)


def load_markdown_documents(knowledge_base_path: str) -> list[Document]:
    """
    Load Markdown documents from knowledge base directory.

    Args:
        knowledge_base_path: Path to knowledge_base directory

    Returns:
        List of LangChain Document objects
    """
    kb_path = Path(knowledge_base_path)

    if not kb_path.exists():
        logger.warning(f"Knowledge base path does not exist: {kb_path}")
        return []

    documents = []
    md_files = list(kb_path.rglob("*.md"))

    logger.info(f"Found {len(md_files)} Markdown files in {kb_path}")

    for md_file in md_files:
        try:
            with open(md_file, encoding="utf-8") as f:
                content = f.read()

            # Extract relative path as source
            try:
                source = str(md_file.relative_to(kb_path.parent))
            except ValueError:
                source = str(md_file)

            doc = Document(
                page_content=content,
                metadata={
                    "source": source,
                    "filename": md_file.name,
                    "file_path": str(md_file),
                    "size_bytes": md_file.stat().st_size,
                },
            )
            documents.append(doc)
            logger.debug(f"Loaded: {md_file.name} ({len(content)} chars)")

        except Exception as e:
            logger.error(f"Failed to load {md_file}: {e}")
            continue

    logger.info(f"✅ Successfully loaded {len(documents)} documents")
    return documents


def main():
    """Main ingestion workflow."""
    parser = argparse.ArgumentParser(
        description="Ingest Markdown documents into ChromaDB for SoftArchitect AI"
    )
    parser.add_argument(
        "--host",
        default="localhost",
        help="ChromaDB server hostname (default: localhost)",
    )
    parser.add_argument(
        "--port", type=int, default=8000, help="ChromaDB server port (default: 8000)"
    )
    parser.add_argument(
        "--knowledge-base",
        default="packages/knowledge_base",
        help="Path to knowledge base directory (default: packages/knowledge_base)",
    )
    parser.add_argument(
        "--clear",
        action="store_true",
        help="Clear collection before ingestion (not implemented)",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Show what would be ingested without actually ingesting",
    )

    args = parser.parse_args()

    logger.info("=" * 70)
    logger.info("🚀 SoftArchitect AI Knowledge Base Ingestion")
    logger.info("=" * 70)
    logger.info(f"ChromaDB: {args.host}:{args.port}")
    logger.info(f"Knowledge Base: {args.knowledge_base}")
    logger.info(f"Dry Run: {args.dry_run}")

    # Load documents
    logger.info("\n📂 Loading Markdown documents...")
    documents = load_markdown_documents(args.knowledge_base)

    if not documents:
        logger.error("No documents loaded. Exiting.")
        return 1

    if args.dry_run:
        logger.info("\n📋 DRY RUN - Would ingest the following documents:")
        for i, doc in enumerate(documents, 1):
            source = doc.metadata.get("source", "unknown")
            size = len(doc.page_content)
            logger.info(f"  {i:3d}. {source:50s} ({size:6d} chars)")
        logger.info(f"\nTotal: {len(documents)} documents")
        return 0

    # Connect to ChromaDB
    logger.info("\n🔗 Connecting to ChromaDB...")
    try:
        vector_store = VectorStoreService(
            host=args.host,
            port=args.port,
            collection_name="softarchitect_knowledge_base",
        )
    except ChromaConnectionError as e:
        logger.error(f"❌ Failed to connect to ChromaDB: {e}")
        logger.error(f"   Make sure ChromaDB is running at {args.host}:{args.port}")
        logger.error("   You can start it with: docker-compose up -d chroma")
        return 1

    # Ingest documents
    logger.info(f"\n📥 Ingesting {len(documents)} documents...")
    try:
        count = vector_store.ingest(documents)
        logger.info(f"✅ Successfully ingested {count} documents")
    except Exception as e:
        logger.error(f"❌ Ingestion failed: {e}")
        return 1

    # Get collection stats
    logger.info("\n📊 Collection Statistics:")
    try:
        stats = vector_store.get_collection_stats()
        logger.info(f"  Collection Name: {stats['collection_name']}")
        logger.info(f"  Document Count: {stats['document_count']}")
        logger.info(f"  ChromaDB Host: {stats['host']}:{stats['port']}")
    except Exception as e:
        logger.warning(f"Could not retrieve stats: {e}")

    logger.info("\n" + "=" * 70)
    logger.info("✅ Ingestion completed successfully!")
    logger.info("=" * 70)
    return 0


if __name__ == "__main__":
    sys.exit(main())
