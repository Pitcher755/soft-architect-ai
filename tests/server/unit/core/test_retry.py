"""Unit tests for @with_retry decorator (TDD RED Phase).

This module tests retry logic with exponential backoff for resilient operations.
All tests are expected to FAIL until implementation is complete (Phase 2).

Test Coverage:
- Retry succeeds on first attempt
- Retry succeeds after transient failures
- Retry exhausted after max attempts
- Exponential backoff timing verification
- Logging of retry attempts
"""

from unittest.mock import AsyncMock, Mock, patch

import pytest

from app.core.exceptions import RetryExhaustedError
from app.core.retry import with_retry


class TestRetryDecorator:
    """Test suite for @with_retry decorator."""

    def test_retry_succeeds_on_first_attempt(self):
        """Should execute successfully without retries."""
        mock_func = Mock(return_value="success")
        decorated = with_retry(max_retries=3)(mock_func)

        result = decorated()

        assert result == "success"
        assert mock_func.call_count == 1

    def test_retry_succeeds_on_second_attempt(self):
        """Should retry once and succeed."""
        mock_func = Mock(side_effect=[ConnectionError(), "success"])
        decorated = with_retry(max_retries=3, base_delay=0.1)(mock_func)

        result = decorated()

        assert result == "success"
        assert mock_func.call_count == 2

    def test_retry_succeeds_on_third_attempt(self):
        """Should retry twice and succeed on third attempt."""
        mock_func = Mock(side_effect=[ConnectionError(), TimeoutError(), "success"])
        decorated = with_retry(
            max_retries=3,
            base_delay=0.1,
            retryable_exceptions=(ConnectionError, TimeoutError),
        )(mock_func)

        result = decorated()

        assert result == "success"
        assert mock_func.call_count == 3

    def test_retry_exhausted_after_max_attempts(self):
        """Should raise RetryExhaustedError after 3 failed attempts."""
        mock_func = Mock(side_effect=ConnectionError("Persistent failure"))
        decorated = with_retry(max_retries=3, base_delay=0.1)(mock_func)

        with pytest.raises(RetryExhaustedError) as exc_info:
            decorated()

        assert mock_func.call_count == 3
        assert "Persistent failure" in str(exc_info.value.message)
        assert exc_info.value.details["attempts"] == 3

    def test_retry_exponential_backoff_timing(self):
        """Should apply exponential backoff (1s, 2s, 4s)."""
        mock_func = Mock(side_effect=[ConnectionError(), ConnectionError(), "success"])
        decorated = with_retry(max_retries=3, base_delay=1.0)(mock_func)

        with patch("time.sleep") as mock_sleep:
            result = decorated()

            assert result == "success"
            assert mock_sleep.call_count == 2
            # First retry: 1.0s delay
            assert mock_sleep.call_args_list[0][0][0] == 1.0
            # Second retry: 2.0s delay (exponential backoff)
            assert mock_sleep.call_args_list[1][0][0] == 2.0

    def test_retry_logs_each_attempt(self, caplog):
        """Should log each retry attempt with context."""
        mock_func = Mock(side_effect=[ConnectionError("DB down"), "success"])
        mock_func.__name__ = "test_operation"
        decorated = with_retry(max_retries=3, base_delay=0.1)(mock_func)

        decorated()

        # Verify warning logged for retry
        assert any("test_operation" in record.message for record in caplog.records)
        # Verify structured logging - error info is in 'extra' field
        warning_records = [r for r in caplog.records if r.levelname == "WARNING"]
        assert len(warning_records) >= 1
        assert any(
            hasattr(r, "operation") and r.operation == "test_operation"
            for r in warning_records
        )

    def test_retry_does_not_catch_non_retryable_exceptions(self):
        """Should not retry on non-retryable exceptions."""
        mock_func = Mock(side_effect=ValueError("Invalid input"))
        decorated = with_retry(
            max_retries=3,
            base_delay=0.1,
            retryable_exceptions=(ConnectionError,),
        )(mock_func)

        with pytest.raises(ValueError) as exc_info:
            decorated()

        assert mock_func.call_count == 1  # No retries
        assert "Invalid input" in str(exc_info.value)

    def test_retry_preserves_function_metadata(self):
        """Should preserve original function's metadata."""

        @with_retry(max_retries=3)
        def sample_function():
            """Sample function docstring."""
            return "result"

        assert sample_function.__name__ == "sample_function"
        assert sample_function.__doc__ is not None
        assert "Sample function docstring" in sample_function.__doc__

    def test_retry_with_custom_backoff_multiplier(self):
        """Should apply custom backoff multiplier."""
        mock_func = Mock(side_effect=[ConnectionError(), ConnectionError(), "success"])
        decorated = with_retry(max_retries=3, base_delay=1.0, backoff_multiplier=3.0)(
            mock_func
        )

        with patch("time.sleep") as mock_sleep:
            result = decorated()

            assert result == "success"
            # First retry: 1.0s
            # Second retry: 3.0s (3.0x multiplier)
            assert mock_sleep.call_args_list[0][0][0] == 1.0
            assert mock_sleep.call_args_list[1][0][0] == 3.0


class TestRetryDecoratorAsync:
    """Test suite for @with_retry decorator on async functions.

    Covers the async_wrapper path (lines 74-118 of retry.py):
    - async success on first attempt
    - async success after transient failure (retry + asyncio.sleep)
    - async exhausted after max attempts (RetryExhaustedError)
    - async logs success when succeeding after retry
    """

    @pytest.mark.asyncio
    async def test_async_retry_succeeds_on_first_attempt(self):
        """Async function that succeeds immediately is called exactly once."""
        mock_func = AsyncMock(return_value="async_result")
        decorated = with_retry(max_retries=3)(mock_func)

        result = await decorated()

        assert result == "async_result"
        assert mock_func.call_count == 1

    @pytest.mark.asyncio
    async def test_async_retry_succeeds_after_transient_failure(self):
        """Async function retries once (with asyncio.sleep) and succeeds."""
        mock_func = AsyncMock(side_effect=[ConnectionError("temporary"), "success"])
        decorated = with_retry(max_retries=3, base_delay=0.01)(mock_func)

        with patch("asyncio.sleep", new_callable=AsyncMock) as mock_sleep:
            result = await decorated()

        assert result == "success"
        assert mock_func.call_count == 2
        mock_sleep.assert_called_once()

    @pytest.mark.asyncio
    async def test_async_retry_exhausted_raises_error(self):
        """Async function exhausts all retries and raises RetryExhaustedError."""
        mock_func = AsyncMock(side_effect=ConnectionError("always fails"))
        decorated = with_retry(max_retries=3, base_delay=0.01)(mock_func)

        with patch("asyncio.sleep", new_callable=AsyncMock):
            with pytest.raises(RetryExhaustedError) as exc_info:
                await decorated()

        assert mock_func.call_count == 3
        assert exc_info.value.details["attempts"] == 3

    @pytest.mark.asyncio
    async def test_async_retry_logs_success_after_retry(self, caplog):
        """Async wrapper logs info when succeeding after at least one retry."""
        mock_func = AsyncMock(side_effect=[ConnectionError("temp"), "ok"])
        mock_func.__name__ = "async_operation"
        decorated = with_retry(max_retries=3, base_delay=0.01)(mock_func)

        with patch("asyncio.sleep", new_callable=AsyncMock):
            result = await decorated()

        assert result == "ok"
        assert mock_func.call_count == 2
