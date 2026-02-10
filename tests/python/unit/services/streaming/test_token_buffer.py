"""Unit tests for token buffer."""

import asyncio

import pytest

from app.services.streaming.token_buffer import TokenBuffer


class TestTokenBuffer:
    """Test suite for efficient token buffering."""

    def test_buffer_initialization_with_max_size(self) -> None:
        """Should initialize buffer with configurable max size."""
        buffer = TokenBuffer(max_size=100)

        assert buffer.max_size == 100
        assert buffer.size == 0
        assert buffer.is_empty is True

    @pytest.mark.asyncio
    async def test_add_token_increments_buffer_size(self) -> None:
        """Should increment size when adding tokens."""
        buffer = TokenBuffer(max_size=10)

        await buffer.add("Hello")
        await buffer.add("World")

        assert buffer.size == 2

    @pytest.mark.asyncio
    async def test_consume_token_returns_fifo_order(self) -> None:
        """Should return tokens in FIFO order."""
        buffer = TokenBuffer(max_size=10)
        await buffer.add("First")
        await buffer.add("Second")
        await buffer.add("Third")

        token1 = await buffer.consume()
        token2 = await buffer.consume()
        token3 = await buffer.consume()

        assert token1 == "First"
        assert token2 == "Second"
        assert token3 == "Third"

    @pytest.mark.asyncio
    async def test_buffer_blocks_when_full(self) -> None:
        """Should block producer when buffer is full."""
        buffer = TokenBuffer(max_size=2)
        await buffer.add("Token1")
        await buffer.add("Token2")

        with pytest.raises(asyncio.TimeoutError):
            await asyncio.wait_for(buffer.add("Token3"), timeout=0.05)

    @pytest.mark.asyncio
    async def test_buffer_unblocks_after_consume(self) -> None:
        """Should unblock producer after consuming tokens."""
        buffer = TokenBuffer(max_size=2)
        await buffer.add("Token1")
        await buffer.add("Token2")

        await buffer.consume()

        await asyncio.wait_for(buffer.add("Token3"), timeout=0.05)
        assert buffer.size == 2

    @pytest.mark.asyncio
    async def test_clear_empties_buffer(self) -> None:
        """Should clear buffer completely."""
        buffer = TokenBuffer(max_size=10)
        await buffer.add("Token1")
        await buffer.add("Token2")

        buffer.clear()

        assert buffer.is_empty is True
        assert buffer.size == 0
