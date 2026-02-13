#!/usr/bin/env python
"""
CLI tool for inspecting ChromaDB collections and query results.

Provides interactive inspection of vector database content,
useful for validating RAG ingestion and retrieval quality.

Usage:
    poetry run python scripts/inspect_db.py health
    poetry run python scripts/inspect_db.py query "architecture" --limit 5
    poetry run python scripts/inspect_db.py stats
    poetry run python scripts/inspect_db.py query "Docker" --limit 2 --json-output
"""

import json
import logging
import sys
from pathlib import Path
from typing import Any

import click

# Add src/server to path for imports
sys.path.insert(0, str(Path(__file__).parent.parent))

from services.rag.vector_store import VectorStoreService

logger = logging.getLogger(__name__)


@click.group()
@click.option("--host", default="localhost", help="ChromaDB server hostname")
@click.option("--port", default=8000, type=int, help="ChromaDB server port")
@click.option("--verbose", is_flag=True, help="Enable verbose logging")
@click.pass_context
def cli(ctx: click.Context, host: str, port: int, verbose: bool) -> None:
    """
    ChromaDB Inspection CLI.

    Interactive tool for querying and inspecting vector database content,
    verifying RAG ingestion quality and retrieval performance.
    """
    # Setup logging
    if verbose:
        logging.basicConfig(
            level=logging.DEBUG,
            format="%(asctime)s - %(name)s - %(levelname)s - %(message)s",
        )
    else:
        logging.basicConfig(
            level=logging.INFO,
            format="%(name)s - %(levelname)s - %(message)s",
        )

    # Initialize context
    ctx.ensure_object(dict)

    try:
        ctx.obj["store"] = VectorStoreService(
            host=host,
            port=port,
            collection_name="softarchitect_knowledge_base",
        )
        if verbose:
            click.echo(f"✓ Connected to ChromaDB at {host}:{port}")
    except Exception as e:
        click.echo(f"❌ Failed to connect to ChromaDB: {e}", err=True)
        click.echo(f"   Make sure ChromaDB is running at {host}:{port}", err=True)
        sys.exit(1)


@cli.command()
@click.pass_context
def health(ctx: click.Context) -> None:
    """Check ChromaDB health status."""
    store: VectorStoreService = ctx.obj["store"]

    try:
        # Try to get collection stats to verify connection
        stats_data = store.get_collection_stats()

        click.echo("✅ ChromaDB is healthy")
        click.echo(f"   Collection: {stats_data.get('collection_name', 'unknown')}")
        click.echo(f"   Documents: {stats_data.get('document_count', 0)}")
        host = stats_data.get("host", "unknown")
        port = stats_data.get("port", "unknown")
        click.echo(f"   Host: {host}:{port}")
    except Exception as e:
        click.echo(f"❌ ChromaDB health check failed: {e}", err=True)
        sys.exit(1)


@cli.command()
@click.argument("query_text")
@click.option("--limit", "-l", default=3, type=int, help="Number of results to return")
@click.option("--json-output", is_flag=True, help="Output results as JSON")
@click.pass_context
def query(  # noqa: C901
    ctx: click.Context,
    query_text: str,
    limit: int,
    json_output: bool,
) -> None:
    """
    Query the vector database.

    QUERY_TEXT: The text to search for in the knowledge base.
    """
    store: VectorStoreService = ctx.obj["store"]

    try:
        results = store.query(query_text, n_results=limit)

        if json_output:
            # Output as JSON for piping to other tools
            output: dict[str, Any] = {
                "query": query_text,
                "limit": limit,
                "matches": 0,
                "results": [],
            }

            documents = results.get("documents")
            metadatas = results.get("metadatas")
            distances = results.get("distances")

            # Validate we have document results
            if documents and len(documents) > 0:
                doc_list = documents[0]
                meta_list = metadatas[0] if metadatas else []
                dist_list = distances[0] if distances else []

                if len(doc_list) > 0:
                    output["matches"] = len(doc_list)

                    for idx, doc in enumerate(doc_list):
                        meta = meta_list[idx] if idx < len(meta_list) else {}
                        distance = dist_list[idx] if idx < len(dist_list) else None

                        distance_value: float | None = None
                        if distance is not None:
                            try:
                                distance_value = float(distance)
                            except (ValueError, TypeError):
                                distance_value = None

                        output["results"].append(
                            {
                                "content": doc[:300],
                                "filename": (meta.get("filename", "unknown") if isinstance(meta, dict) else "unknown"),
                                "source": (meta.get("source", "unknown") if isinstance(meta, dict) else "unknown"),
                                "file_type": (
                                    meta.get("file_type", "unknown") if isinstance(meta, dict) else "unknown"
                                ),
                                "distance": distance_value,
                            }
                        )

            click.echo(json.dumps(output, indent=2))
        else:
            # Pretty print for human consumption
            click.echo(f"\n🔍 Query: {query_text}")
            click.echo(f"📊 Limit: {limit}\n")

            documents = results.get("documents")
            metadatas = results.get("metadatas")
            distances = results.get("distances")

            if documents and len(documents) > 0:
                doc_list = documents[0]
                meta_list = metadatas[0] if metadatas else []
                dist_list = distances[0] if distances else []

                if len(doc_list) > 0:
                    for idx, doc in enumerate(doc_list, 1):
                        meta = meta_list[idx - 1] if idx - 1 < len(meta_list) else {}
                        distance = dist_list[idx - 1] if idx - 1 < len(dist_list) else None

                        distance_str = "N/A"
                        if distance is not None:
                            try:
                                distance_str = f"{float(distance):.4f}"
                            except (ValueError, TypeError):
                                distance_str = "N/A"

                        filename = meta.get("filename", "unknown") if isinstance(meta, dict) else "unknown"
                        source = meta.get("source", "unknown") if isinstance(meta, dict) else "unknown"
                        file_type = meta.get("file_type", "unknown") if isinstance(meta, dict) else "unknown"

                        click.echo(f"[{idx}] 📄 {filename}")
                        click.echo(f"    📍 {source}")
                        click.echo(f"    Type: {file_type}")
                        click.echo(f"    Distance: {distance_str}")
                        click.echo("    Content:\n")

                        doc_str = doc
                        content = doc_str[:500] + "..." if len(doc_str) > 500 else doc_str
                        for line in content.split("\n"):
                            click.echo(f"       {line}")
                        click.echo()
                else:
                    click.echo("   No results found.")
            else:
                click.echo("   No results found.")

    except Exception as e:
        click.echo(f"❌ Query failed: {e}", err=True)
        sys.exit(1)


@cli.command()
@click.pass_context
def stats(ctx: click.Context) -> None:
    """Display collection statistics."""
    store: VectorStoreService = ctx.obj["store"]

    try:
        stats_data = store.get_collection_stats()

        click.echo("\n📊 ChromaDB Statistics:")
        click.echo(f"  Collection Name: {stats_data.get('collection_name', 'unknown')}")
        click.echo(f"  Document Count: {stats_data.get('document_count', 0)}")
        host = stats_data.get("host", "unknown")
        port = stats_data.get("port", "unknown")
        click.echo(f"  Host: {host}:{port}")
        click.echo()

    except Exception as e:
        click.echo(f"❌ Failed to get statistics: {e}", err=True)
        sys.exit(1)


@cli.command()
@click.pass_context
def collections(ctx: click.Context) -> None:
    """List all available collections."""
    store: VectorStoreService = ctx.obj["store"]

    try:
        # Get collection stats which includes collection name
        stats_data = store.get_collection_stats()

        click.echo("\n📚 Available Collections:")
        collection_name = stats_data.get("collection_name", "unknown")
        doc_count = stats_data.get("document_count", 0)
        click.echo(f"  {collection_name}")
        click.echo(f"    Documents: {doc_count}")
        click.echo()

    except Exception as e:
        click.echo(f"❌ Failed to list collections: {e}", err=True)
        sys.exit(1)


if __name__ == "__main__":
    cli()
