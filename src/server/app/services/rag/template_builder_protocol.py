"""Protocol for template builder abstraction."""

from abc import ABC, abstractmethod
from uuid import UUID


class TemplateBuilderProtocol(ABC):
    """Abstract protocol for template operations."""

    @abstractmethod
    def select_template(self, project_id: UUID) -> str:
        """Select the appropriate template identifier."""

    @abstractmethod
    def build_prompt(
        self,
        query: str,
        context: list[str],
        template_id: str,
        history: list[dict[str, str]] | None = None,
    ) -> str:
        """
        Build final prompt with query, context, and optional history.

        ✅ UPDATED: Now supports optional chat history parameter.

        Args:
            query: User's current question
            context: RAG-retrieved knowledge snippets
            template_id: Selected template identifier
            history: Optional chat history (list of {"role": str, "content": str})

        Returns:
            Complete formatted prompt ready for LLM
        """
