"""
Shared dependencies for API endpoints.
"""
from fastapi import HTTPException, status
from typing import Optional

from ..core.security import TokenValidator


async def verify_api_key(x_api_key: Optional[str] = None) -> str:
    """
    Verify API key from request header.

    Args:
        x_api_key: API key from X-API-Key header

    Returns:
        Verified API key

    Raises:
        HTTPException: If API key is invalid or missing
    """
    if not x_api_key or not TokenValidator.validate_api_key(x_api_key):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or missing API key",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return x_api_key
