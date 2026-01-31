"""
Tests for app.api.dependencies module.

Covers API dependency injection and validation functions.
"""

from unittest.mock import patch

import pytest
from fastapi import HTTPException, status

from app.api.dependencies import verify_api_key


class TestVerifyAPIKey:
    """Test API key verification dependency."""

    @pytest.mark.asyncio
    async def test_valid_api_key(self):
        """✅ Should accept valid API key."""
        with patch(
            "app.api.dependencies.TokenValidator.validate_api_key", return_value=True
        ):
            result = await verify_api_key(x_api_key="valid-key-12345")
            assert result == "valid-key-12345"

    @pytest.mark.asyncio
    async def test_missing_api_key(self):
        """❌ Should raise HTTPException when API key is missing."""
        with pytest.raises(HTTPException) as exc_info:
            await verify_api_key(x_api_key=None)

        assert exc_info.value.status_code == status.HTTP_401_UNAUTHORIZED
        assert "Invalid or missing API key" in exc_info.value.detail

    @pytest.mark.asyncio
    async def test_empty_api_key(self):
        """❌ Should raise HTTPException for empty API key."""
        with pytest.raises(HTTPException) as exc_info:
            await verify_api_key(x_api_key="")

        assert exc_info.value.status_code == status.HTTP_401_UNAUTHORIZED

    @pytest.mark.asyncio
    async def test_invalid_api_key(self):
        """❌ Should raise HTTPException for invalid API key."""
        with patch(
            "app.api.dependencies.TokenValidator.validate_api_key", return_value=False
        ):
            with pytest.raises(HTTPException) as exc_info:
                await verify_api_key(x_api_key="invalid-key")

            assert exc_info.value.status_code == status.HTTP_401_UNAUTHORIZED

    @pytest.mark.asyncio
    async def test_authentication_header(self):
        """✅ Should include WWW-Authenticate header in error."""
        with patch(
            "app.api.dependencies.TokenValidator.validate_api_key", return_value=False
        ):
            with pytest.raises(HTTPException) as exc_info:
                await verify_api_key(x_api_key="bad-key")

            assert "WWW-Authenticate" in exc_info.value.headers

    @pytest.mark.asyncio
    async def test_returns_original_key_on_success(self):
        """✅ Should return the original API key on success."""
        test_key = "test-api-key-xyz"
        with patch(
            "app.api.dependencies.TokenValidator.validate_api_key", return_value=True
        ):
            result = await verify_api_key(x_api_key=test_key)
            assert result == test_key
