"""
Unit tests for TemplateLoader - RAG Template Management.

Tests cover:
- Loading existing templates
- Error handling for missing templates
- Template variable replacement
- Variable extraction from templates
"""

import pytest
from app.services.rag.template_loader import TemplateLoader, Template
from app.core.exceptions import TemplateNotFoundError


class TestTemplateLoader:
    """Test suite for TemplateLoader."""

    @pytest.fixture
    def template_loader(self, tmp_path):
        """Fixture with temporary templates directory."""
        templates_dir = tmp_path / "templates"
        templates_dir.mkdir()

        # Create mock template
        (templates_dir / "PROJECT_MANIFESTO.md").write_text(
            "# Project: {project_name}\n{user_input}"
        )

        # Create another template for variety
        (templates_dir / "TECHNICAL_SPEC.md").write_text(
            "## Technical Specification\n"
            "### Project: {project_name}\n"
            "### Description: {description}\n"
            "### Tech Stack: {tech_stack}\n"
            "{user_input}"
        )

        return TemplateLoader(templates_path=templates_dir)

    def test_load_existing_template_returns_template_object(self, template_loader):
        """Test loading existing template."""
        # Act
        template = template_loader.load("PROJECT_MANIFESTO")

        # Assert
        assert isinstance(template, Template)
        assert "Project:" in template.content
        assert "{project_name}" in template.content

    def test_load_nonexistent_template_raises_exception(self, template_loader):
        """Test error handling for missing templates."""
        # Act & Assert
        with pytest.raises(TemplateNotFoundError) as exc_info:
            template_loader.load("NONEXISTENT_DOC")

        assert "NONEXISTENT_DOC" in str(exc_info.value)

    def test_template_render_replaces_placeholders(self, template_loader):
        """Test template variable replacement."""
        # Arrange
        template = template_loader.load("PROJECT_MANIFESTO")

        # Act
        rendered = template.render(
            project_name="TestProject", user_input="This is a test app"
        )

        # Assert
        assert "TestProject" in rendered
        assert "This is a test app" in rendered
        assert "{project_name}" not in rendered
        assert "{user_input}" not in rendered

    def test_template_list_variables_returns_all_placeholders(self, template_loader):
        """Test extraction of template variables."""
        # Arrange
        template = template_loader.load("PROJECT_MANIFESTO")

        # Act
        variables = template.list_variables()

        # Assert
        assert "project_name" in variables
        assert "user_input" in variables
        assert len(variables) == 2

    def test_template_render_with_multiple_variables(self, template_loader):
        """Test rendering template with multiple variables."""
        # Arrange
        template = template_loader.load("TECHNICAL_SPEC")

        # Act
        rendered = template.render(
            project_name="InventoryPro",
            description="Sistema de gestión de inventarios",
            tech_stack="Flutter, Python, PostgreSQL",
            user_input="Este es el contenido especificado por el usuario",
        )

        # Assert
        assert "InventoryPro" in rendered
        assert "Sistema de gestión de inventarios" in rendered
        assert "Flutter, Python, PostgreSQL" in rendered
        assert "Este es el contenido especificado por el usuario" in rendered
        # Verify no placeholders remain
        assert "{" not in rendered
        assert "}" not in rendered

    def test_template_render_with_extra_variables_ignores_them(self, template_loader):
        """Test that extra variables passed to render are ignored gracefully."""
        # Arrange
        template = template_loader.load("PROJECT_MANIFESTO")

        # Act - pass extra variables not in template
        rendered = template.render(
            project_name="TestProject",
            user_input="Test content",
            extra_param="This should be ignored",
            another_extra="Also ignored",
        )

        # Assert
        assert "TestProject" in rendered
        assert "Test content" in rendered
        # Extra params should not appear in output
        assert "should be ignored" not in rendered

    def test_template_render_with_missing_required_variable_raises_error(
        self, template_loader
    ):
        """Test that missing required variables raise an error."""
        # Arrange
        template = template_loader.load("PROJECT_MANIFESTO")

        # Act & Assert
        with pytest.raises((KeyError, ValueError)):
            template.render(
                project_name="TestProject"
                # Missing: user_input
            )

    def test_template_list_variables_for_complex_template(self, template_loader):
        """Test variable extraction from complex template."""
        # Arrange
        template = template_loader.load("TECHNICAL_SPEC")

        # Act
        variables = template.list_variables()

        # Assert
        assert "project_name" in variables
        assert "description" in variables
        assert "tech_stack" in variables
        assert "user_input" in variables
        assert len(variables) == 4

    def test_load_template_preserves_markdown_formatting(self, template_loader):
        """Test that template loading preserves markdown structure."""
        # Arrange & Act
        template = template_loader.load("PROJECT_MANIFESTO")

        # Assert
        assert "# Project:" in template.content
        assert "Project:" in template.content

    def test_template_render_handles_multiline_values(self, template_loader):
        """Test template rendering with multiline variable values."""
        # Arrange
        template = template_loader.load("PROJECT_MANIFESTO")
        multiline_input = "Line 1\nLine 2\nLine 3"

        # Act
        rendered = template.render(
            project_name="TestProject", user_input=multiline_input
        )

        # Assert
        assert "Line 1" in rendered
        assert "Line 2" in rendered
        assert "Line 3" in rendered
