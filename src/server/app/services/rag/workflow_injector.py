"""Workflow Injector Service.

Reads template and example files directly from disk using the MASTER_WORKFLOW registry.
Prioritizes direct path access for performance, with a recursive fallback for resilience.
Builds deterministic prompts using XML tags for better LLM comprehension.
"""

import logging
from pathlib import Path

from app.domain.constants.workflow import get_step_by_type

logger = logging.getLogger(__name__)


class WorkflowInjector:
    """Injects deterministic templates and examples into LLM prompts."""

    def __init__(self) -> None:
        """Initialize WorkflowInjector with the Docker container knowledge base path."""
        self.knowledge_base_path = Path("/app/knowledge_base")
        logger.info("WorkflowInjector initialized with path: %s", self.knowledge_base_path)

    def get_injected_prompt(self, doc_type: str) -> str:
        """Build a deterministic injection block for the given document type."""
        step = get_step_by_type(doc_type)

        if not step:
            logger.error("Document type '%s' is not registered in MASTER_WORKFLOW.", doc_type)
            return ""

        template_name = Path(step.template_path).name
        example_name = Path(step.example_path).name

        direct_template_path = (
            self.knowledge_base_path
            / "01-TEMPLATES"
            / self._get_template_subfolder(doc_type)
            / template_name
        )
        direct_example_path = self.knowledge_base_path / "MASTER_WORKFLOW_EXAMPLES" / example_name

        template_content = self._read_with_fallback(direct_template_path, template_name)
        example_content = self._read_with_fallback(direct_example_path, example_name)

        if not template_content:
            logger.error("Template not found for: %s", template_name)
        if not example_content:
            logger.warning("Example not found for: %s", example_name)

        injection = (
            "<system_instructions>\n"
            "You are SoftArchitect AI, a strict Principal Software Engineer.\n"
            "Your ONLY task is to generate the final document. DO NOT output your thought process.\n"
            "DO NOT repeat the template or the example in your output. Just output the final result.\n"
            "Translate all headers and text to the user's language.\n"
            "</system_instructions>\n\n"
            "<template>\n"
            f"{template_content}\n"
            "</template>\n\n"
            "<example>\n"
            f"{example_content}\n"
            "</example>\n"
        )

        if doc_type == "README":
            injection += (
                "\n<project_closing_instruction>\n"
                "This is the LAST document of the Master Workflow.\n"
                "After closing the document, you MUST include "
                "the following celebration message:\n\n"
                "Congratulations! All architecture documents are ready. "
                "You can now open your IDE and start coding.\n"
                "</project_closing_instruction>\n"
            )

        logger.info("Injector prepared document: %s (Step %d)", doc_type, step.step_number)
        return injection

    def _get_template_subfolder(self, doc_type: str) -> str:
        """Map doc_type to its subfolder in 01-TEMPLATES for direct access."""
        if doc_type in ["PROJECT_MANIFESTO", "DOMAIN_LANGUAGE", "USER_JOURNEY_MAP"]:
            return "10-CONTEXT"
        if doc_type in [
            "REQUIREMENTS_MASTER",
            "USER_STORIES_MASTER",
            "SECURITY_PRIVACY_POLICY",
            "COMPLIANCE_MATRIX",
        ]:
            return "20-REQUIREMENTS"
        if doc_type in [
            "TECH_STACK_DECISION",
            "DATA_MODEL_SCHEMA",
            "API_INTERFACE_CONTRACT",
            "PROJECT_STRUCTURE_MAP",
            "SECURITY_THREAT_MODEL",
            "ARCH_DECISION_RECORDS",
        ]:
            return "30-ARCHITECTURE"
        if doc_type in ["DESIGN_SYSTEM", "UI_WIREFRAMES_FLOW", "ACCESSIBILITY_GUIDE"]:
            return "35-UX_UI"
        if doc_type in [
            "ROADMAP_PHASES",
            "DEPLOYMENT_INFRASTRUCTURE",
            "CI_CD_PIPELINE",
            "TESTING_STRATEGY",
        ]:
            return "40-PLANNING"
        if doc_type in ["RULES", "CONTRIBUTING", "AGENTS", "README"]:
            return "00-ROOT"
        return ""

    def _read_with_fallback(self, direct_path: Path, file_name: str) -> str:
        """Attempt to read file from direct path, fallback to recursive search."""
        if direct_path.exists():
            try:
                with open(direct_path, encoding="utf-8") as f:
                    return f.read()
            except OSError as e:
                logger.error("Error reading direct path %s: %s", direct_path, e)

        logger.warning(
            "File not found at %s, triggering recursive fallback search for %s",
            direct_path,
            file_name,
        )

        for file_path in self.knowledge_base_path.rglob(file_name):
            try:
                with open(file_path, encoding="utf-8") as f:
                    logger.info("Fallback successful. Found at: %s", file_path)
                    return f.read()
            except OSError as e:
                logger.error("Error reading %s during fallback: %s", file_path, e)

        return ""
