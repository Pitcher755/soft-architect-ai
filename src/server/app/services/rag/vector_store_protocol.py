"""Protocol for vector store abstraction."""

from abc import ABC, abstractmethod


class VectorStoreProtocol(ABC):
    """Abstract protocol for vector store operations."""

    @abstractmethod
    async def search(self, query: str, top_k: int = 5) -> list[str]:
        """Search vector store for relevant document snippets."""
