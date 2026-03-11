"""
Template loading and rendering for RAG document generation.

Provides functionality to load templates from disk and render them with variables.
"""

import re
from pathlib import Path
from typing import Any

from app.core.exceptions import TemplateNotFoundError


class Template:
    """Represents a template with placeholders."""

    def __init__(self, name: str, content: str):
        """
        Initialize a template.

        Args:
            name: Template name (e.g., "PROJECT_MANIFESTO")
            content: Template content with {placeholder} variables
        """
        self.name = name
        self.content = content

    def list_variables(self) -> list[str]:
        """
        Extract all placeholder variable names from template.

        Returns:
            List of variable names found in template
        """
        pattern = r"\{(\w+)\}"
        matches = re.findall(pattern, self.content)
        return list(dict.fromkeys(matches))  # Remove duplicates, preserve order

    def render(self, **kwargs: Any) -> str:
        """
        Render template by replacing placeholders with values.

        Args:
            **kwargs: Variable names and values to substitute

        Returns:
            Rendered template content

        Raises:
            KeyError: If required variable is missing
        """
        result = self.content
        required_vars = self.list_variables()

        # Verify all required variables are provided
        missing_vars = set(required_vars) - set(kwargs.keys())
        if missing_vars:
            raise KeyError(f"Missing required variables: {missing_vars}")

        # Replace placeholders
        for var_name in required_vars:
            placeholder = "{" + var_name + "}"
            result = result.replace(placeholder, str(kwargs[var_name]))

        return result


class TemplateLoader:
    """Loads templates from disk."""

    def __init__(self, templates_path: Path | str | None = None):
        """
        Initialize template loader.

        Args:
            templates_path: Path to templates directory
                          (default: packages/knowledge_base/03-TEMPLATES)
        """
        if templates_path is None:
            # Default to knowledge base templates directory
            templates_path = (
                Path(__file__).parent.parent.parent.parent
                / "packages/knowledge_base/03-TEMPLATES"
            )
        else:
            templates_path = Path(templates_path)

        self.templates_path = templates_path

    def load(self, template_name: str) -> Template:
        """
        Load a template by name.

        Args:
            template_name: Name of template (e.g., "PROJECT_MANIFESTO")

        Returns:
            Template object

        Raises:
            TemplateNotFoundError: If template file not found
        """
        template_file = self.templates_path / f"{template_name}.md"

        if not template_file.exists():
            raise TemplateNotFoundError(template_name)

        try:
            content = template_file.read_text(encoding="utf-8")
            return Template(name=template_name, content=content)
        except Exception as e:
            raise TemplateNotFoundError(
                template_name, message=f"Failed to load template: {str(e)}"
            ) from e
