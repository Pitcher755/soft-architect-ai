"""
Unit tests for Ollama LLM client retry logic (HU-4.4 GAP 2).

Tests that LLM calls retry 3x with exponential backoff on transient failures:
- httpx.RequestError (connection refused, DNS failure)
- httpx.TimeoutException (request timeout)
- Successful retry after N attempts
- Exhaustion after 3 failed attempts

Critical: Transient network issues MUST NOT reach the user.
"""

import asyncio
from unittest.mock import AsyncMock, MagicMock, patch

import httpx
import pytest

from app.core.exceptions import LLMConnectionError
from app.infrastructure.llm.ollama_client import OllamaClient


class TestOllamaRetryLogic:
    """Test retry logic for Ollama LLM client."""

    @pytest.fixture
    def ollama_client(self):
        """Create Ollama client for testing."""
        return OllamaClient(base_url="http://localhost:11434")

    @pytest.mark.asyncio
    async def test_ollama_retry_succeeds_third_attempt(self, ollama_client):
        """
        CRITICAL: Retry should succeed on 3rd attempt after 2 failures.

        Scenario: Network glitch causes first 2 attempts to fail
        Expected: 3rd attempt succeeds, user gets response
        """
        # ARRANGE: Mock client that fails twice, then succeeds
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.json.return_value = {"response": "Response from 3rd attempt"}

        attempt_count = {"count": 0}

        async def mock_post(*args, **kwargs):
            attempt_count["count"] += 1
            if attempt_count["count"] < 3:
                raise httpx.RequestError("Connection refused", request=MagicMock())
            return mock_response

        with patch("httpx.AsyncClient") as mock_client_class:
            mock_client = AsyncMock()
            mock_client.__aenter__.return_value = mock_client
            mock_client.post = mock_post
            mock_client_class.return_value = mock_client

            # ACT: Generate response (should retry 2x, succeed on 3rd)
            response = await ollama_client.generate(prompt="Test prompt")

            # ASSERT: Should succeed with response from 3rd attempt
            assert response == "Response from 3rd attempt"
            assert attempt_count["count"] == 3

    @pytest.mark.asyncio
    async def test_ollama_retry_exhausts_after_max_retries(self, ollama_client):
        """
        Retry should exhaust after 3 failed attempts.

        Scenario: Ollama completely down (all 3 attempts fail)
        Expected: Raise LLMConnectionError (wrapping RetryExhaustedError)
        """

        # ARRANGE: Mock client that always fails
        async def mock_post_always_fails(*args, **kwargs):
            raise httpx.RequestError("Connection refused", request=MagicMock())

        with patch("httpx.AsyncClient") as mock_client_class:
            mock_client = AsyncMock()
            mock_client.__aenter__.return_value = mock_client
            mock_client.post = mock_post_always_fails
            mock_client_class.return_value = mock_client

            # ACT & ASSERT: Should raise LLMConnectionError after 3 attempts
            # (wrapper converts RetryExhaustedError to domain exception)
            with pytest.raises(LLMConnectionError) as exc_info:
                await ollama_client.generate(prompt="Test prompt")

            # Verify message indicates retry exhaustion
            assert "after 3 attempts" in str(exc_info.value)

    @pytest.mark.asyncio
    async def test_ollama_retry_uses_exponential_backoff(self, ollama_client):
        """
        Retry should use exponential backoff: 0.5s, 1.0s, 2.0s.

        Scenario: Test timing between retry attempts
        Expected: Delays match exponential backoff pattern
        """
        # ARRANGE: Mock that tracks timing
        attempt_times = []

        async def mock_post_with_timing(*args, **kwargs):
            attempt_times.append(asyncio.get_event_loop().time())
            if len(attempt_times) < 3:
                raise httpx.RequestError("Retry test", request=MagicMock())

            mock_response = MagicMock()
            mock_response.status_code = 200
            mock_response.json.return_value = {"response": "Success"}
            return mock_response

        with patch("httpx.AsyncClient") as mock_client_class:
            mock_client = AsyncMock()
            mock_client.__aenter__.return_value = mock_client
            mock_client.post = mock_post_with_timing
            mock_client_class.return_value = mock_client

            # ACT: Generate (will retry 2x)
            await ollama_client.generate(prompt="Test prompt")

            # ASSERT: Check backoff delays (allow 0.3s margin)
            assert len(attempt_times) == 3
            delay_1 = attempt_times[1] - attempt_times[0]
            delay_2 = attempt_times[2] - attempt_times[1]

            assert 0.4 < delay_1 < 0.8  # ~0.5s backoff
            assert 0.9 < delay_2 < 1.3  # ~1.0s backoff

    @pytest.mark.asyncio
    async def test_ollama_retry_logs_warnings_on_retries(self, ollama_client):
        """Retry should log WARNING for each retry attempt."""
        # ARRANGE: Mock that fails once
        attempt_count = {"count": 0}

        async def mock_post(*args, **kwargs):
            attempt_count["count"] += 1
            if attempt_count["count"] == 1:
                raise httpx.RequestError("First fail", request=MagicMock())

            mock_response = MagicMock()
            mock_response.status_code = 200
            mock_response.json.return_value = {"response": "Success"}
            return mock_response

        with patch("httpx.AsyncClient") as mock_client_class:
            mock_client = AsyncMock()
            mock_client.__aenter__.return_value = mock_client
            mock_client.post = mock_post
            mock_client_class.return_value = mock_client

            with patch("app.core.retry.logger") as mock_logger:
                # ACT: Generate
                await ollama_client.generate(prompt="Test")

                # ASSERT: Should log warning for retry
                assert mock_logger.warning.called
                warning_call = str(mock_logger.warning.call_args)
                assert "retry" in warning_call.lower()

    @pytest.mark.asyncio
    async def test_ollama_retry_logs_success_after_retry(self, ollama_client):
        """Should log INFO when retry succeeds."""
        # ARRANGE: Fail once, succeed on retry
        attempt_count = {"count": 0}

        async def mock_post(*args, **kwargs):
            attempt_count["count"] += 1
            if attempt_count["count"] == 1:
                raise httpx.TimeoutException("Timeout", request=MagicMock())

            mock_response = MagicMock()
            mock_response.status_code = 200
            mock_response.json.return_value = {"response": "Success after retry"}
            return mock_response

        with patch("httpx.AsyncClient") as mock_client_class:
            mock_client = AsyncMock()
            mock_client.__aenter__.return_value = mock_client
            mock_client.post = mock_post
            mock_client_class.return_value = mock_client

            with patch("app.core.retry.logger") as mock_logger:
                # ACT: Generate
                await ollama_client.generate(prompt="Test")

                # ASSERT: Should log success
                assert mock_logger.info.called
                info_calls = [str(call) for call in mock_logger.info.call_args_list]
                assert any(
                    "success" in call.lower() or "retry" in call.lower()
                    for call in info_calls
                )

    @pytest.mark.asyncio
    async def test_ollama_no_retry_on_immediate_success(self, ollama_client):
        """If first attempt succeeds, no retry should occur."""
        # ARRANGE: Mock that succeeds immediately
        mock_response = MagicMock()
        mock_response.status_code = 200
        mock_response.json.return_value = {"response": "Immediate success"}

        call_count = {"count": 0}

        async def mock_post(*args, **kwargs):
            call_count["count"] += 1
            return mock_response

        with patch("httpx.AsyncClient") as mock_client_class:
            mock_client = AsyncMock()
            mock_client.__aenter__.return_value = mock_client
            mock_client.post = mock_post
            mock_client_class.return_value = mock_client

            # ACT: Generate
            response = await ollama_client.generate(prompt="Test")

            # ASSERT: Should succeed on first try (no retries)
            assert response == "Immediate success"
            assert call_count["count"] == 1  # Only 1 attempt

    @pytest.mark.asyncio
    async def test_ollama_stream_works_without_retry(self, ollama_client):
        """stream_generate() works (NO retry - AsyncGenerators are complex)."""

        # ARRANGE: Mock successful stream
        class MockStreamResponse:
            def __init__(self):
                self.status_code = 200

            def raise_for_status(self):
                pass

            async def aiter_lines(self):
                yield '{"response": "Chunk 1", "done": false}'
                yield '{"response": "Chunk 2", "done": false}'
                yield '{"response": "", "done": true}'

            async def __aenter__(self):
                return self

            async def __aexit__(self, exc_type, exc_val, exc_tb):
                pass

        def mock_stream(*args, **kwargs):
            return MockStreamResponse()

        with patch("httpx.AsyncClient") as mock_client_class:
            mock_client = AsyncMock()
            mock_client.__aenter__.return_value = mock_client
            mock_client.stream = mock_stream
            mock_client_class.return_value = mock_client

            # ACT: Stream response
            chunks = []
            async for chunk in ollama_client.stream_generate(prompt="Test"):
                chunks.append(chunk)

            # ASSERT: Should get chunks
            assert len(chunks) == 2
            assert "Chunk 1" in chunks
            assert "Chunk 2" in chunks

    def test_retry_decorator_sync_path(self):
        """Test @with_retry decorator works with synchronous functions."""
        from app.core.retry import with_retry

        # ARRANGE: Sync function that fails twice then succeeds
        attempt_count = {"count": 0}

        @with_retry(max_retries=3, base_delay=0.1, retryable_exceptions=(ValueError,))
        def sync_function(value: str) -> str:
            attempt_count["count"] += 1
            if attempt_count["count"] < 3:
                raise ValueError(f"Attempt {attempt_count['count']} failed")
            return f"Success after {attempt_count['count']} attempts"

        # ACT: Call sync function
        result = sync_function("test")

        # ASSERT: Should succeed on 3rd attempt
        assert attempt_count["count"] == 3
        assert result == "Success after 3 attempts"
