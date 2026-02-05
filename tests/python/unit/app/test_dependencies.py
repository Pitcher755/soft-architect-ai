import pytest
from fastapi import HTTPException

from app.api.dependencies import verify_api_key


@pytest.mark.asyncio
async def test_verify_api_key_none_raises():
    with pytest.raises(HTTPException):
        await verify_api_key(None)


@pytest.mark.asyncio
async def test_verify_api_key_short_raises():
    with pytest.raises(HTTPException):
        await verify_api_key("short")


@pytest.mark.asyncio
async def test_verify_api_key_ok_returns_key():
    key = "longenoughapikey"
    result = await verify_api_key(key)
    assert result == key
