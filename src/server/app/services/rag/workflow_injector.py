"""Workflow Injector Service.

Reads template and example files directly from disk using the MASTER_WORKFLOW registry,
building deterministic prompts for the LLM without relying on vector search.
"""

import logging
from pathlib import Path

from app.domain.constants.workflow import get_step_by_type

logger = logging.getLogger(__name__)


class WorkflowInjector:
    def __init__(self) -> None:
        """Initialize WorkflowInjector with Docker container knowledge base path."""
        self.knowledge_base_path = Path("/app/knowledge_base")
        logger.info(
            "WorkflowInjector knowledge_base_path: %s", self.knowledge_base_path
        )

    def get_injected_prompt(self, doc_type: str) -> str:
        """Build a deterministic injection block for the given doc_type."""
        step = get_step_by_type(doc_type)

        if not step:
            logger.error(
                "doc_type '%s' is not registered in MASTER_WORKFLOW.", doc_type
            )
            return ""

        # Strip registry prefix to avoid duplication in final path
        clean_template_path = step.template_path.replace(
            "packages/knowledge_base/", "", 1
        )
        clean_example_path = step.example_path.replace(
            "packages/knowledge_base/", "", 1
        )

        template_full_path = self.knowledge_base_path / clean_template_path
        example_full_path = self.knowledge_base_path / clean_example_path

        template_content = self._read_file(template_full_path)
        example_content = self._read_file(example_full_path)

        if not template_content:
            logger.warning("Template not found. Path: %s", template_full_path)
        if not example_content:
            logger.warning("Example not found. Path: %s", example_full_path)

        injection = (
            "=== MANDATORY STRUCTURE (TEMPLATE) ===\n"
            "Fill in this exact template. Do not omit or rename any section.\n"
            f"{template_content}\n\n"
            "=== MASTER EXAMPLE (DENSITY AND STYLE REFERENCE) ===\n"
            "Use this example to understand the expected technical depth."
            " Mirror its level of detail.\n"
            f"{example_content}\n"
        )

        if doc_type == "README":
            injection += (
                "\n=== PROJECT CLOSING INSTRUCTION ===\n"
                "This is the LAST document of the Master Workflow.\n"
                "After closing the </document> tag, you MUST include "
                "the following celebration message:\n\n"
                "Congratulations! All architecture documents are ready. "
                "You can now open your IDE and start coding."
            )

        logger.info(
            "Injector prepared document: %s (Step %d)", doc_type, step.step_number
        )
        return injection

    def _read_file(self, file_path: Path) -> str:
        """Read a text file safely, returning an empty string on any failure."""
        if not file_path.exists():
            logger.error("File not found on disk: %s", file_path)
            return ""
        try:
            with open(file_path, encoding="utf-8") as f:
                return f.read()
        except OSError as e:
            logger.error("Error reading %s: %s", file_path, e)
            return ""
