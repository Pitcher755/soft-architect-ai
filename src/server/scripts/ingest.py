#!/usr/bin/env python
"""
Ingestion Script for SoftArchitect AI Knowledge Base (HU-2.3)

This script loads multi-format documents from the knowledge base,
transforms them into LangChain Documents, and ingests them
into ChromaDB for semantic search.

Supported formats:
- .md (Markdown documentation)
- .yaml/.yml (YAML configuration and tech packs)
- .json (JSON schemas and user stories)
- .tree (Tree structure files)

Usage:
    python src/server/scripts/ingest.py
    python src/server/scripts/ingest.py --knowledge-base /app/knowledge_base/02-TECH-PACKS
    python src/server/scripts/ingest.py --host chromadb --port 8000
    python src/server/scripts/ingest.py --clear  # Clear collection before ingestion

Environment:
    CHROMA_HOST: ChromaDB server hostname (default: localhost)
    CHROMA_PORT: ChromaDB server port (default: 8000)
"""

import argparse
import json
import logging
import os  # ✅ AÑADIDO: Necesario para leer variables de entorno
import sys
from pathlib import Path

import yaml

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


def load_multiformat_documents(  # noqa: C901
    knowledge_base_path: str,
) -> list[Document]:
    """
    Load multi-format documents from knowledge base directory.

    Supported formats:
    - .md (Markdown)
    - .yaml/.yml (YAML)
    - .json (JSON)
    - .tree (Tree structure)

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

    # Find all supported file types
    file_patterns = {
        "*.md": "markdown",
        "*.yaml": "yaml",
        "*.yml": "yaml",
        "*.json": "json",
        "*.tree": "tree",
    }

    all_files = []
    for pattern, file_type in file_patterns.items():
        files = list(kb_path.rglob(pattern))
        all_files.extend([(f, file_type) for f in files])

    logger.info(f"Found {len(all_files)} total files in {kb_path}. Applying filters...")

    for file_path, file_type in all_files:
        try:
            path_str = str(file_path)

            # 🎯 FILTER: Skip templates and workflow examples to avoid semantic contamination
            # We only want pure technical knowledge (Tech Packs) in the Vector Store.
            if (
                "01-TEMPLATES" in path_str
                or "03-EXAMPLES" in path_str
                or "MASTER_WORKFLOW_EXAMPLES" in path_str
            ):
                continue

            content = None
            metadata_extra = {"file_type": file_type}

            if file_type == "markdown":
                with open(file_path, encoding="utf-8") as f:
                    content = f.read()

            elif file_type == "yaml":
                with open(file_path, encoding="utf-8") as f:
                    data = yaml.safe_load(f)
                    content = yaml.dump(data, default_flow_style=False) if data else ""
                    metadata_extra["yaml_keys"] = (
                        list(data.keys()) if isinstance(data, dict) else "list"
                    )

            elif file_type == "json":
                with open(file_path, encoding="utf-8") as f:
                    data = json.load(f)
                    content = json.dumps(data, indent=2, ensure_ascii=False)
                    metadata_extra["json_type"] = type(data).__name__

            elif file_type == "tree":
                with open(file_path, encoding="utf-8") as f:
                    content = f.read()

            if not content or not content.strip():
                logger.warning(f"Skipping empty file: {file_path}")
                continue

            # Extract relative path as source
            try:
                source = str(file_path.relative_to(kb_path.parent))
            except ValueError:
                source = str(file_path)

            doc = Document(
                page_content=content,
                metadata={
                    "source": source,
                    "filename": file_path.name,
                    "file_path": str(file_path),
                    "size_bytes": file_path.stat().st_size,
                    **metadata_extra,
                },
            )
            documents.append(doc)
            logger.debug(
                f"Loaded: {file_path.name} ({len(content)} chars, type={file_type})"
            )

        except Exception as e:
            logger.error(f"Failed to load {file_path}: {e}")
            continue

    logger.info(f"✅ Successfully loaded {len(documents)} filtered knowledge documents")
    return documents


def main():
    """Main ingestion workflow."""
    parser = argparse.ArgumentParser(
        description="Ingest Markdown documents into ChromaDB for SoftArchitect AI"
    )

    # ✅ CORRECCIÓN 1: Leer host de entorno o usar nombre del servicio Docker
    default_host = os.getenv("CHROMADB_HOST", "chromadb")
    parser.add_argument(
        "--host",
        default=default_host,
        help=f"ChromaDB server hostname (default: {default_host})",
    )

    # ✅ CORRECCIÓN 2: Leer puerto de entorno
    default_port = int(os.getenv("CHROMADB_PORT", 8000))
    parser.add_argument(
        "--port",
        type=int,
        default=default_port,
        help=f"ChromaDB server port (default: {default_port})",
    )

    # ✅ CORRECCIÓN 3: Apuntamos directamente al subdirectorio TECH_PACKS por defecto
    parser.add_argument(
        "--knowledge-base",
        default="/app/knowledge_base/02-TECH-PACKS",
        help="Path to knowledge base directory (default: /app/knowledge_base/02-TECH-PACKS)",
    )

    parser.add_argument(
        "--clear",
        action="store_true",
        help="Clear collection before ingestion",
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
    logger.info("\n📂 Loading multi-format documents...")
    documents = load_multiformat_documents(args.knowledge_base)

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
        logger.error("   You can start it with: docker-compose up -d chromadb")
        return 1

    # Clear collection if requested
    if args.clear:
        logger.info("\n🧹 Clearing existing collection...")
        try:
            vector_store.clear_collection()
        except Exception as e:
            logger.error(f"❌ Failed to clear collection: {e}")
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