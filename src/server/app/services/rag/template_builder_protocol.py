"""Protocol for template builder abstraction."""

from abc import ABC, abstractmethod
from uuid import UUID


class TemplateBuilderProtocol(ABC):
    """Abstract protocol for template operations."""

    @abstractmethod
    def select_template(self, project_id: UUID) -> str:
        """Select the appropriate template identifier."""

    @abstractmethod
    def build_prompt(self, query: str, context: list[str], template_id: str) -> str:
        """Build final prompt with query and retrieved context."""
