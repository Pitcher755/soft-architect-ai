"""
Integration tests for conversation API endpoints.

Test Coverage:
- POST /api/v1/conversations (create)
- GET /api/v1/conversations/{id} (retrieve)
- GET /api/v1/conversations (list)
"""

import pytest
from httpx import AsyncClient, ASGITransport
from uuid import uuid4

from src.server.app.main import app


@pytest.mark.asyncio
async def test_create_conversation_returns_201(override_get_db):
    """Test creating conversation via API."""
    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as client:
        # Arrange
        payload = {"project_id": str(uuid4()), "title": "Test Conversation"}

        # Act
        response = await client.post("/api/v1/conversations/", json=payload)

        # Assert
        assert response.status_code == 201
        data = response.json()
        assert "id" in data
        assert data["title"] == "Test Conversation"


@pytest.mark.asyncio
async def test_get_conversation_returns_200(override_get_db):
    """Test retrieving conversation via API."""
    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as client:
        # Arrange: Create conversation first
        payload = {"project_id": str(uuid4()), "title": "Test"}
        create_response = await client.post("/api/v1/conversations/", json=payload)
        conv_id = create_response.json()["id"]

        # Act: Retrieve
        response = await client.get(f"/api/v1/conversations/{conv_id}")

        # Assert
        assert response.status_code == 200
        data = response.json()
        assert data["id"] == conv_id
        assert data["title"] == "Test"


@pytest.mark.asyncio
async def test_list_conversations_returns_200(override_get_db):
    """Test listing conversations via API."""
    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as client:
        # Act
        response = await client.get("/api/v1/conversations/")

        # Assert
        assert response.status_code == 200
        data = response.json()
        assert "conversations" in data
        assert "total" in data


@pytest.mark.asyncio
async def test_get_nonexistent_conversation_returns_404(override_get_db):
    """Test retrieving nonexistent conversation returns 404."""
    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as client:
        # Arrange
        fake_id = uuid4()

        # Act
        response = await client.get(f"/api/v1/conversations/{fake_id}")

        # Assert
        assert response.status_code == 404


@pytest.mark.asyncio
async def test_list_conversations_with_pagination(override_get_db):
    """Test listing conversations with pagination parameters."""
    async with AsyncClient(
        transport=ASGITransport(app=app), base_url="http://test"
    ) as client:
        # Act
        response = await client.get("/api/v1/conversations/?skip=0&limit=10")

        # Assert
        assert response.status_code == 200
        data = response.json()
        assert "skip" in data
        assert "limit" in data
        assert data["skip"] == 0
        assert data["limit"] == 10
