"""Retry decorator with exponential backoff for resilient operations.

This module provides a @with_retry decorator that retries failed operations
with exponential backoff. Useful for transient failures in network calls,
database operations, and LLM API calls.

Example:
    @with_retry(max_retries=3, base_delay=1.0)
    def query_database():
        return db.query()
"""

import functools
import logging
import time
from collections.abc import Callable
from typing import Any, TypeVar

from app.core.exceptions import RetryExhaustedError

logger = logging.getLogger(__name__)

T = TypeVar("T")


def with_retry(
    max_retries: int = 3,
    base_delay: float = 1.0,
    backoff_multiplier: float = 2.0,
    retryable_exceptions: tuple[type[Exception], ...] = (ConnectionError, TimeoutError),
) -> Callable[[Callable[..., T]], Callable[..., T]]:
    """
    Decorator that retries a function on failure with exponential backoff.

    Args:
        max_retries: Maximum number of retry attempts (default: 3)
        base_delay: Initial delay in seconds (default: 1.0)
        backoff_multiplier: Delay multiplier for each retry (default: 2.0)
        retryable_exceptions: Tuple of exception types to catch (default: ConnectionError, TimeoutError)

    Returns:
        Decorated function with retry logic

    Raises:
        RetryExhaustedError: When all retry attempts are exhausted

    Example:
        @with_retry(max_retries=3, base_delay=1.0)
        def query_database():
            return db.query()
    """

    def decorator(func: Callable[..., T]) -> Callable[..., T]:
        @functools.wraps(func)
        def wrapper(*args: Any, **kwargs: Any) -> T:
            last_exception: Exception | None = None
            func_name = getattr(func, "__name__", "unknown_function")

            for attempt in range(max_retries):
                try:
                    result = func(*args, **kwargs)
                    if attempt > 0:
                        logger.info(
                            f"✅ Retry successful for {func_name}",
                            extra={
                                "operation": func_name,
                                "attempt": attempt + 1,
                                "max_retries": max_retries,
                            },
                        )
                    return result

                except retryable_exceptions as e:
                    last_exception = e

                    if attempt < max_retries - 1:
                        delay = base_delay * (backoff_multiplier**attempt)
                        logger.warning(
                            f"⚠️ Retry attempt {attempt + 1}/{max_retries} for {func_name} failed",
                            extra={
                                "operation": func_name,
                                "attempt": attempt + 1,
                                "max_retries": max_retries,
                                "delay_seconds": delay,
                                "error": str(e),
                            },
                        )
                        time.sleep(delay)
                    else:
                        logger.error(
                            f"❌ All {max_retries} retry attempts exhausted for {func_name}",
                            extra={
                                "operation": func_name,
                                "attempts": max_retries,
                                "last_error": str(last_exception),
                            },
                        )

            # All retries exhausted
            raise RetryExhaustedError(
                operation=func_name,
                attempts=max_retries,
                last_error=str(last_exception),
            )

        return wrapper

    return decorator
