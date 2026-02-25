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
        user_name: str = "Developer",
    ) -> str:
        """
        Build final prompt with query, context, optional history, and user personalization.

        ✅ UPDATED (HU-5.0): Now supports optional chat history and user_name for personalization.

        Args:
            query: User's current question
            context: RAG-retrieved knowledge snippets
            template_id: Selected template identifier
            history: Optional chat history (list of {"role": str, "content": str})
            user_name: User's name for prompt personalization (default: "Developer")

        Returns:
            Complete formatted prompt ready for LLM
        """
