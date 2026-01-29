"""
Tests: Conftest for pytest configuration and shared fixtures.
"""

import pytest
from httpx import AsyncClient

from app.main import app


@pytest.fixture
async def client():
    """
    Create a test HTTP client for API testing.
    """
    async with AsyncClient(app=app, base_url="http://test") as client:
        yield client
