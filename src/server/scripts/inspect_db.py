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

from core.exceptions import ConnectionError as ChromaConnectionError
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
    except ChromaConnectionError as e:
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
        click.echo(f"   Collection: {stats_data['collection_name']}")
        click.echo(f"   Documents: {stats_data['document_count']}")
        click.echo(f"   Host: {stats_data['host']}:{stats_data['port']}")
    except Exception as e:
        click.echo(f"❌ ChromaDB health check failed: {e}", err=True)
        sys.exit(1)


@cli.command()
@click.argument("query_text")
@click.option("--limit", "-l", default=3, type=int, help="Number of results to return")
@click.option("--json-output", is_flag=True, help="Output results as JSON")
@click.pass_context
def query(ctx: click.Context, query_text: str, limit: int, json_output: bool) -> None:
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

            if results.get("documents") and results["documents"][0]:
                output["matches"] = len(results["documents"][0])

                for doc, meta, distance in zip(
                    results["documents"][0],
                    results["metadatas"][0] if results.get("metadatas") else [],
                    results["distances"][0] if results.get("distances") else [],
                ):
                    output["results"].append(
                        {
                            "content": doc[:300],
                            "filename": meta.get("filename", "unknown"),
                            "source": meta.get("source", "unknown"),
                            "file_type": meta.get("file_type", "unknown"),
                            "distance": float(distance) if distance is not None else None,
                        }
                    )

            click.echo(json.dumps(output, indent=2))
        else:
            # Pretty print for human consumption
            click.echo(f"\n🔍 Query: {query_text}")
            click.echo(f"📊 Limit: {limit}\n")

            if results.get("documents") and results["documents"][0]:
                for idx, (doc, meta, distance) in enumerate(
                    zip(
                        results["documents"][0],
                        results["metadatas"][0] if results.get("metadatas") else [],
                        results["distances"][0] if results.get("distances") else [],
                    ),
                    1,
                ):
                    distance_str = (
                        f"{float(distance):.4f}" if distance is not None else "N/A"
                    )
                    click.echo(f"[{idx}] 📄 {meta.get('filename', 'unknown')}")
                    click.echo(f"    📍 {meta.get('source', 'unknown')}")
                    click.echo(f"    🏷️  Type: {meta.get('file_type', 'unknown')}")
                    click.echo(f"    📐 Distance: {distance_str}")
                    click.echo(f"    📝 Content:\n")
                    content = doc[:500] + "..." if len(doc) > 500 else doc
                    for line in content.split("\n"):
                        click.echo(f"       {line}")
                    click.echo()
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
        click.echo(f"  Collection Name: {stats_data['collection_name']}")
        click.echo(f"  Document Count: {stats_data['document_count']}")
        click.echo(f"  Host: {stats_data['host']}:{stats_data['port']}")
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
        click.echo(f"  {stats_data['collection_name']}")
        click.echo(f"    Documents: {stats_data['document_count']}")
        click.echo()

    except Exception as e:
        click.echo(f"❌ Failed to list collections: {e}", err=True)
        sys.exit(1)


if __name__ == "__main__":
    cli()
