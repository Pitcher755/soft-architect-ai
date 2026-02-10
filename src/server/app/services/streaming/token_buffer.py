"""
Asynchronous token buffer with bounded capacity.

Implements producer-consumer pattern with asyncio queues for efficient
token buffering in streaming scenarios.
"""

from __future__ import annotations

import asyncio
import logging

logger = logging.getLogger(__name__)


class TokenBuffer:
    """Bounded FIFO buffer for token streaming."""

    def __init__(self, max_size: int = 100) -> None:
        """Initialize token buffer."""
        self._queue: asyncio.Queue[str] = asyncio.Queue(maxsize=max_size)
        self._max_size = max_size

    @property
    def max_size(self) -> int:
        """Get maximum buffer capacity."""
        return self._max_size

    @property
    def size(self) -> int:
        """Get current number of buffered tokens."""
        return self._queue.qsize()

    @property
    def is_empty(self) -> bool:
        """Check if buffer is empty."""
        return self._queue.empty()

    @property
    def is_full(self) -> bool:
        """Check if buffer is full."""
        return self._queue.full()

    async def add(self, token: str) -> None:
        """Add token to buffer (blocks if full)."""
        await self._queue.put(token)
        logger.debug("Token buffered", extra={"buffer_size": self.size})

    async def consume(self) -> str:
        """Consume token from buffer (blocks if empty)."""
        token = await self._queue.get()
        logger.debug("Token consumed", extra={"buffer_size": self.size})
        return token

    def clear(self) -> None:
        """Clear all buffered tokens."""
        while not self._queue.empty():
            try:
                self._queue.get_nowait()
            except asyncio.QueueEmpty:
                break
        logger.info("Token buffer cleared")

    async def consume_batch(self, batch_size: int) -> list[str]:
        """Consume multiple tokens at once."""
        tokens: list[str] = []
        for _ in range(batch_size):
            if self.is_empty:
                break
            try:
                token = await asyncio.wait_for(self.consume(), timeout=0.1)
                tokens.append(token)
            except TimeoutError:
                break
        return tokens
