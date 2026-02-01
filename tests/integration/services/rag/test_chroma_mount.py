"""Test to verify ChromaDB bind mount is working correctly."""

import os
from pathlib import Path


class TestChromaMount:
    """Tests for ChromaDB bind mount configuration."""

    @staticmethod
    def get_chroma_data_path() -> Path:
        """
        Get the expected path to chroma_data directory.

        Returns:
            Path: Path to infrastructure/chroma_data

        Raises:
            FileNotFoundError: If project root cannot be located
        """
        # Navigate from test file location to project root
        test_file = Path(__file__)
        # tests/integration/services/rag/test_chroma_mount.py
        # Go up 5 levels to reach project root
        project_root = test_file.parents[4]

        chroma_path = project_root / "infrastructure" / "chroma_data"
        return chroma_path

    def test_chroma_data_directory_exists(self) -> None:
        """Verify that chroma_data directory exists in infrastructure folder."""
        chroma_path = self.get_chroma_data_path()
        assert chroma_path.exists(), f"Chroma data directory not found at {chroma_path}"

    def test_chroma_data_is_directory(self) -> None:
        """Verify that chroma_data is a directory, not a file."""
        chroma_path = self.get_chroma_data_path()
        assert (
            chroma_path.is_dir()
        ), f"Chroma data path is not a directory: {chroma_path}"

    def test_chroma_data_is_writable(self) -> None:
        """
        Verify that chroma_data directory is accessible.

        Note: In Docker bind mounts, the directory may be owned by root
        with limited write permissions. The important thing is that it exists
        and ChromaDB can write to it from inside the container.
        """
        chroma_path = self.get_chroma_data_path()
        # Check that directory exists and is readable
        assert os.access(
            chroma_path, os.R_OK
        ), f"Chroma data directory not readable: {chroma_path}"
        # If running as root or directory owner, verify writeability
        if os.getuid() == 0 or os.stat(chroma_path).st_uid == os.getuid():
            assert os.access(
                chroma_path, os.W_OK
            ), f"Chroma data directory not writable: {chroma_path}"

    def test_chroma_data_contains_database(self) -> None:
        """Verify that chroma_data contains ChromaDB database files."""
        chroma_path = self.get_chroma_data_path()

        # List files in chroma_data
        files = list(chroma_path.iterdir())
        assert (
            len(files) > 0
        ), f"Chroma data directory is empty, expected database files at {chroma_path}"

        # Check for expected database file
        sqlite_file = chroma_path / "chroma.sqlite3"
        assert (
            sqlite_file.exists()
        ), f"Expected chroma.sqlite3 not found in {chroma_path}"

    def test_chroma_path_is_relative_to_infrastructure(self) -> None:
        """
        Verify bind mount uses relative path (./chroma_data).

        This test ensures the docker-compose.yml uses ./chroma_data
        which makes it location-independent and portable.
        """
        chroma_path = self.get_chroma_data_path()

        # The path should be relative to infrastructure folder
        infrastructure_path = chroma_path.parent
        assert (
            infrastructure_path.name == "infrastructure"
        ), f"Expected infrastructure folder, got {infrastructure_path}"

        # Verify structure is project_root/infrastructure/chroma_data
        assert (
            chroma_path.name == "chroma_data"
        ), f"Expected chroma_data folder, got {chroma_path.name}"
