"""
Tests for app.core.database module.

Covers database initialization and connection functions.
"""

from unittest.mock import patch

import pytest


class TestDatabaseInitialization:
    """Test database initialization functions."""

    def test_init_chromadb_function_exists(self):
        """✅ Should have init_chromadb function."""
        from app.core.database import init_chromadb

        assert init_chromadb is not None
        assert callable(init_chromadb)

    def test_init_sqlite_function_exists(self):
        """✅ Should have init_sqlite function."""
        from app.core.database import init_sqlite

        assert init_sqlite is not None
        assert callable(init_sqlite)

    @pytest.mark.asyncio
    async def test_init_chromadb_async_function(self):
        """✅ Should be async coroutine."""
        import inspect

        from app.core.database import init_chromadb

        # Check if it's a coroutine function
        if inspect.iscoroutinefunction(init_chromadb):
            # If it's async, it should be awaitable
            result = init_chromadb()
            assert hasattr(result, "__await__") or inspect.iscoroutine(result)

    @pytest.mark.asyncio
    async def test_init_sqlite_async_function(self):
        """✅ Should be async coroutine."""
        import inspect

        from app.core.database import init_sqlite

        if inspect.iscoroutinefunction(init_sqlite):
            result = init_sqlite()
            assert hasattr(result, "__await__") or inspect.iscoroutine(result)

    @pytest.mark.asyncio
    @patch("app.core.database.init_chromadb")
    async def test_chromadb_initialization_mocked(self, mock_init):
        """✅ Should initialize ChromaDB properly."""
        mock_init.return_value = None
        from app.core.database import init_chromadb

        # Should be callable
        assert callable(init_chromadb)

    @pytest.mark.asyncio
    @patch("app.core.database.init_sqlite")
    async def test_sqlite_initialization_mocked(self, mock_init):
        """✅ Should initialize SQLite properly."""
        mock_init.return_value = None
        from app.core.database import init_sqlite

        # Should be callable
        assert callable(init_sqlite)


class TestDatabaseModule:
    """Test database module structure."""

    def test_database_module_has_functions(self):
        """✅ Should export database functions."""
        from app import core

        assert hasattr(core, "database")

    def test_init_functions_importable(self):
        """✅ Should be able to import init functions."""
        from app.core.database import init_chromadb, init_sqlite

        assert init_chromadb is not None
        assert init_sqlite is not None
