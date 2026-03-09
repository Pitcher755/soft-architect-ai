"""Unit tests for WorkflowInjector (services/rag/workflow_injector.py)."""

from pathlib import Path
from unittest.mock import MagicMock, patch

import pytest

from app.services.rag.workflow_injector import WorkflowInjector


class TestWorkflowInjectorInit:
    """Tests for WorkflowInjector initialisation."""

    def test_knowledge_base_path_is_docker_path(self) -> None:
        """WorkflowInjector should use Docker knowledge base path."""
        injector = WorkflowInjector()
        assert injector.knowledge_base_path == Path("/app/knowledge_base")

    def test_knowledge_base_path_is_absolute(self) -> None:
        """knowledge_base_path must be an absolute Path."""
        injector = WorkflowInjector()
        assert injector.knowledge_base_path.is_absolute()


class TestGetInjectedPromptUnknownDocType:
    """Tests for get_injected_prompt when doc_type is not registered."""

    def test_returns_empty_string_for_unknown_doc_type(self) -> None:
        """Unknown doc_type must return an empty string without raising."""
        injector = WorkflowInjector()
        result = injector.get_injected_prompt("NONEXISTENT_DOC_TYPE")
        assert result == ""

    def test_returns_empty_string_for_empty_doc_type(self) -> None:
        """Empty string doc_type must return an empty string without raising."""
        injector = WorkflowInjector()
        result = injector.get_injected_prompt("")
        assert result == ""


class TestGetInjectedPromptKnownDocType:
    """Tests for get_injected_prompt when doc_type exists in MASTER_WORKFLOW."""

    @pytest.fixture
    def injector_with_mocked_files(self) -> WorkflowInjector:
        """Return a WorkflowInjector whose _read_with_fallback is mocked."""
        injector = WorkflowInjector()
        injector._read_with_fallback = MagicMock(  # type: ignore[method-assign]
            side_effect=lambda direct_path, file_name: (
                "# Template content for testing"
                if "template" in file_name.lower()
                else "# Example content for testing"
            )
        )
        return injector

    def test_returns_non_empty_string_for_known_doc_type(
        self, injector_with_mocked_files: WorkflowInjector
    ) -> None:
        """Known doc_type with mocked files must produce a non-empty result."""
        result = injector_with_mocked_files.get_injected_prompt("PROJECT_MANIFESTO")
        assert isinstance(result, str)
        assert len(result) > 0

    def test_prompt_contains_template_section_marker(
        self, injector_with_mocked_files: WorkflowInjector
    ) -> None:
        """The result must include the <template> XML tag."""
        result = injector_with_mocked_files.get_injected_prompt("PROJECT_MANIFESTO")
        assert "<template>" in result

    def test_prompt_contains_example_section_marker(
        self, injector_with_mocked_files: WorkflowInjector
    ) -> None:
        """The result must include the <example> XML tag."""
        result = injector_with_mocked_files.get_injected_prompt("PROJECT_MANIFESTO")
        assert "<example>" in result

    def test_prompt_contains_template_file_content(
        self, injector_with_mocked_files: WorkflowInjector
    ) -> None:
        """The template file content must appear verbatim in the result."""
        result = injector_with_mocked_files.get_injected_prompt("PROJECT_MANIFESTO")
        assert "# Template content for testing" in result

    def test_prompt_contains_example_file_content(
        self, injector_with_mocked_files: WorkflowInjector
    ) -> None:
        """The example file content must appear verbatim in the result."""
        result = injector_with_mocked_files.get_injected_prompt("PROJECT_MANIFESTO")
        assert "# Example content for testing" in result

    def test_readme_prompt_contains_closing_instruction(
        self, injector_with_mocked_files: WorkflowInjector
    ) -> None:
        """README doc_type must append the <project_closing_instruction> block."""
        result = injector_with_mocked_files.get_injected_prompt("README")
        assert "<project_closing_instruction>" in result
        assert "LAST document" in result

    def test_non_readme_prompt_has_no_closing_instruction(
        self, injector_with_mocked_files: WorkflowInjector
    ) -> None:
        """Non-README doc_types must NOT include the closing instruction block."""
        result = injector_with_mocked_files.get_injected_prompt("PROJECT_MANIFESTO")
        assert "<project_closing_instruction>" not in result

    def test_read_with_fallback_called_twice_per_invocation(
        self, injector_with_mocked_files: WorkflowInjector
    ) -> None:
        """_read_with_fallback must be called exactly twice: once for template, once for example."""
        injector_with_mocked_files.get_injected_prompt("PROJECT_MANIFESTO")
        assert injector_with_mocked_files._read_with_fallback.call_count == 2  # type: ignore[attr-defined]


class TestReadWithFallback:
    """Tests for the _read_with_fallback helper method."""

    def test_returns_file_content_when_file_exists(self, tmp_path: Path) -> None:
        """_read_with_fallback must return the exact file contents for an existing file."""
        test_file = tmp_path / "sample.md"
        test_file.write_text("Hello, workflow!", encoding="utf-8")

        injector = WorkflowInjector()
        result = injector._read_with_fallback(test_file, "sample.md")
        assert result == "Hello, workflow!"

    def test_returns_empty_string_when_file_not_found(self, tmp_path: Path) -> None:
        """_read_with_fallback must return '' when file not found in direct path or fallback."""
        non_existent = tmp_path / "does_not_exist.md"
        injector = WorkflowInjector()
        # Mock knowledge_base_path to tmp_path to avoid searching system
        injector.knowledge_base_path = tmp_path
        result = injector._read_with_fallback(non_existent, "does_not_exist.md")
        assert result == ""

    def test_returns_empty_string_on_os_error(self, tmp_path: Path) -> None:
        """_read_with_fallback must return '' when an OSError is raised during reading."""
        test_file = tmp_path / "locked.md"
        test_file.write_text("content", encoding="utf-8")

        injector = WorkflowInjector()
        injector.knowledge_base_path = tmp_path
        with patch("builtins.open", side_effect=OSError("Permission denied")):
            result = injector._read_with_fallback(test_file, "locked.md")
        assert result == ""

    def test_reads_utf8_content_correctly(self, tmp_path: Path) -> None:
        """_read_with_fallback must handle UTF-8 encoded content (including non-ASCII)."""
        test_file = tmp_path / "utf8.md"
        unicode_content = "# Título del proyecto — versión β"
        test_file.write_text(unicode_content, encoding="utf-8")

        injector = WorkflowInjector()
        result = injector._read_with_fallback(test_file, "utf8.md")
        assert result == unicode_content
