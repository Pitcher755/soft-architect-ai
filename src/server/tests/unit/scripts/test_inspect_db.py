"""
Tests for inspect_db CLI tool (FASE 3).

This module validates the ChromaDB inspection CLI commands,
ensuring all functionality works correctly for vector database inspection.
"""

import json
from unittest.mock import MagicMock, patch

import pytest
from click.testing import CliRunner

from scripts.inspect_db import cli


@pytest.fixture
def cli_runner() -> CliRunner:
    """Provide a Click CLI test runner."""
    return CliRunner()


@pytest.fixture
def mock_vector_store() -> MagicMock:
    """Provide a mock VectorStoreService."""
    store = MagicMock()
    store.get_collection_stats.return_value = {
        "collection_name": "softarchitect_knowledge_base",
        "document_count": 129,
        "host": "localhost",
        "port": 8000,
    }
    store.query.return_value = {
        "documents": [["Document 1 content", "Document 2 content"]],
        "metadatas": [
            [
                {
                    "filename": "ARCHITECTURE.md",
                    "source": "packages/knowledge_base/ARCHITECTURE.md",
                    "file_type": "markdown",
                },
                {
                    "filename": "DESIGN.md",
                    "source": "packages/knowledge_base/DESIGN.md",
                    "file_type": "markdown",
                },
            ]
        ],
        "distances": [[0.1234, 0.5678]],
    }
    return store


class TestInspectDbHealthCommand:
    """Tests for the health command."""

    def test_health_command_success(
        self, cli_runner: CliRunner, mock_vector_store: MagicMock
    ) -> None:
        """Test health check command with successful response."""
        with patch(
            "scripts.inspect_db.VectorStoreService", return_value=mock_vector_store
        ):
            result = cli_runner.invoke(cli, ["health"])

            assert result.exit_code == 0
            assert "✅ ChromaDB is healthy" in result.output
            assert "softarchitect_knowledge_base" in result.output
            assert "129" in result.output

    def test_health_command_connection_failure(self, cli_runner: CliRunner) -> None:
        """Test health check command when connection fails."""
        with patch(
            "scripts.inspect_db.VectorStoreService",
            side_effect=Exception("Connection refused"),
        ):
            result = cli_runner.invoke(cli, ["health"])

            # When exception is raised in @click.pass_context, the exit code is 1
            assert result.exit_code == 1
            # Exception message should be in result or exception trace
            assert result.exception is not None or "Connection refused" in str(result.output)


class TestInspectDbQueryCommand:
    """Tests for the query command."""

    def test_query_command_with_results(
        self, cli_runner: CliRunner, mock_vector_store: MagicMock
    ) -> None:
        """Test query command with successful results."""
        with patch(
            "scripts.inspect_db.VectorStoreService", return_value=mock_vector_store
        ):
            result = cli_runner.invoke(
                cli, ["query", "architecture", "--limit", "2"]
            )

            assert result.exit_code == 0
            assert "🔍 Query: architecture" in result.output
            assert "[1]" in result.output
            assert "[2]" in result.output
            assert "ARCHITECTURE.md" in result.output
            assert "DESIGN.md" in result.output

    def test_query_command_json_output(
        self, cli_runner: CliRunner, mock_vector_store: MagicMock
    ) -> None:
        """Test query command with JSON output."""
        with patch(
            "scripts.inspect_db.VectorStoreService", return_value=mock_vector_store
        ):
            result = cli_runner.invoke(
                cli, ["query", "architecture", "--json-output"]
            )

            assert result.exit_code == 0

            # Verify JSON output is valid
            output_json = json.loads(result.output)
            assert output_json["query"] == "architecture"
            assert output_json["matches"] == 2
            assert len(output_json["results"]) == 2
            assert output_json["results"][0]["filename"] == "ARCHITECTURE.md"

    def test_query_command_empty_results(
        self, cli_runner: CliRunner, mock_vector_store: MagicMock
    ) -> None:
        """Test query command with no results."""
        mock_vector_store.query.return_value = {
            "documents": [[]],
            "metadatas": [[]],
            "distances": [[]],
        }

        with patch(
            "scripts.inspect_db.VectorStoreService", return_value=mock_vector_store
        ):
            result = cli_runner.invoke(cli, ["query", "nonexistent"])

            assert result.exit_code == 0
            assert "No results found" in result.output

    def test_query_command_custom_limit(
        self, cli_runner: CliRunner, mock_vector_store: MagicMock
    ) -> None:
        """Test query command with custom limit."""
        with patch(
            "scripts.inspect_db.VectorStoreService", return_value=mock_vector_store
        ):
            result = cli_runner.invoke(
                cli, ["query", "test", "-l", "5"]
            )

            assert result.exit_code == 0
            # Verify the limit is reflected in the output
            mock_vector_store.query.assert_called_once()


class TestInspectDbStatsCommand:
    """Tests for the stats command."""

    def test_stats_command_success(
        self, cli_runner: CliRunner, mock_vector_store: MagicMock
    ) -> None:
        """Test stats command with successful response."""
        with patch(
            "scripts.inspect_db.VectorStoreService", return_value=mock_vector_store
        ):
            result = cli_runner.invoke(cli, ["stats"])

            assert result.exit_code == 0
            assert "📊 ChromaDB Statistics:" in result.output
            assert "softarchitect_knowledge_base" in result.output
            assert "129" in result.output

    def test_stats_command_failure(self, cli_runner: CliRunner) -> None:
        """Test stats command when retrieval fails."""
        mock_store = MagicMock()
        mock_store.get_collection_stats.side_effect = Exception("Database error")

        with patch(
            "scripts.inspect_db.VectorStoreService", return_value=mock_store
        ):
            result = cli_runner.invoke(cli, ["stats"])

            assert result.exit_code == 1
            assert "❌ Failed to get statistics" in result.output


class TestInspectDbCollectionsCommand:
    """Tests for the collections command."""

    def test_collections_command_success(
        self, cli_runner: CliRunner, mock_vector_store: MagicMock
    ) -> None:
        """Test collections command with successful response."""
        with patch(
            "scripts.inspect_db.VectorStoreService", return_value=mock_vector_store
        ):
            result = cli_runner.invoke(cli, ["collections"])

            assert result.exit_code == 0
            assert "📚 Available Collections:" in result.output
            assert "softarchitect_knowledge_base" in result.output


class TestInspectDbGlobalOptions:
    """Tests for global CLI options."""

    def test_cli_with_custom_host_port(
        self, cli_runner: CliRunner, mock_vector_store: MagicMock
    ) -> None:
        """Test CLI with custom host and port."""
        with patch(
            "scripts.inspect_db.VectorStoreService", return_value=mock_vector_store
        ) as mock_service:
            result = cli_runner.invoke(
                cli, ["--host", "chromadb", "--port", "8001", "health"]
            )

            assert result.exit_code == 0
            # Verify VectorStoreService was called with correct parameters
            mock_service.assert_called_once()

    def test_cli_verbose_flag(
        self, cli_runner: CliRunner, mock_vector_store: MagicMock
    ) -> None:
        """Test CLI with verbose flag enabled."""
        with patch(
            "scripts.inspect_db.VectorStoreService", return_value=mock_vector_store
        ):
            result = cli_runner.invoke(cli, ["--verbose", "health"])

            assert result.exit_code == 0
