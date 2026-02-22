"""Unit tests for RULE-05 Path Validator (HU-5.0).

Tests the "Directory Dictatorship" feature that enforces:
- Everything goes under context/ except 00-ROOT/ artifacts
- Strict directory structure validation
- Path compliance checks

Coverage target: 100% for path validation logic
Expected test count: 6 tests
"""

from pathlib import Path


class PathValidator:
    """Validates file paths against RULE-05 directory structure."""

    ALLOWED_ROOT_FILES = {
        "README.md",
        "AGENTS.md",
        "LICENSE",
        "PROJECT_SUMMARY.md",
    }

    @staticmethod
    def is_valid_root_artifact(file_name: str) -> bool:
        """
        Check if file is allowed in root (00-ROOT/ artifacts).

        Args:
            file_name: Name of the file (e.g., "README.md")

        Returns:
            True if file is allowed in root
        """
        return file_name in PathValidator.ALLOWED_ROOT_FILES

    @staticmethod
    def must_be_in_context_dir(file_name: str) -> bool:
        """
        Check if file must be inside context/ directory.

        Args:
            file_name: Name of the file

        Returns:
            True if file must be in context/
        """
        return not PathValidator.is_valid_root_artifact(file_name)

    @staticmethod
    def validate_path(file_path: str) -> tuple[bool, str]:
        """
        Validate that path complies with RULE-05 directory structure.

        Args:
            file_path: Full path to validate

        Returns:
            Tuple (is_valid, error_message)
        """
        path = Path(file_path)
        file_name = path.name

        # Check if root artifact
        if PathValidator.is_valid_root_artifact(file_name):
            # Root artifacts MUST be in project root
            if str(path.parent) == "." or path.parent == Path("."):
                return (True, "")
            else:
                return (
                    False,
                    f"Root artifact {file_name} must be in project root, not {path.parent}",
                )

        # All other files must be in context/
        parts = path.parts
        if len(parts) > 0 and parts[0] == "context":
            return (True, "")
        else:
            return (
                False,
                f"File {file_name} must be in context/ directory (RULE-05: Directory Dictatorship)",
            )

    @staticmethod
    def suggest_correct_path(file_name: str, subdirectory: str = "") -> str:
        """
        Suggest correct path for a file based on RULE-05.

        Args:
            file_name: Name of the file
            subdirectory: Optional subdirectory under context/

        Returns:
            Suggested path string
        """
        if PathValidator.is_valid_root_artifact(file_name):
            return file_name  # Root files go in project root

        # Everything else goes in context/
        if subdirectory:
            return f"context/{subdirectory}/{file_name}"
        else:
            return f"context/{file_name}"


class TestPathValidatorRootArtifacts:
    """Tests for root artifact validation."""

    def test_readme_is_allowed_in_root(self):
        """
        RULE-05: README.md is allowed in project root.

        Scenario: Check if README.md is a valid root artifact.
        Expected: is_valid_root_artifact() returns True.
        """
        result = PathValidator.is_valid_root_artifact("README.md")

        assert result is True, "README.md should be allowed in root"

    def test_agents_is_allowed_in_root(self):
        """
        RULE-05: AGENTS.md is allowed in project root.

        Scenario: Check if AGENTS.md is a valid root artifact.
        Expected: is_valid_root_artifact() returns True.
        """
        result = PathValidator.is_valid_root_artifact("AGENTS.md")

        assert result is True, "AGENTS.md should be allowed in root"

    def test_arbitrary_file_not_allowed_in_root(self):
        """
        RULE-05: Arbitrary files NOT allowed in root.

        Scenario: Check if "MY_DOCUMENT.md" is allowed in root.
        Expected: is_valid_root_artifact() returns False.
        """
        result = PathValidator.is_valid_root_artifact("MY_DOCUMENT.md")

        assert result is False, "Arbitrary files should NOT be in root"


class TestPathValidatorDirectoryEnforcement:
    """Tests for context/ directory enforcement."""

    def test_validate_path_accepts_context_files(self):
        """
        RULE-05: Files in context/ are valid.

        Scenario: Validate "context/10-BUSINESS/VISION.md".
        Expected: validate_path() returns (True, "").
        """
        path = "context/10-BUSINESS/VISION.md"

        is_valid, error_msg = PathValidator.validate_path(path)

        assert is_valid is True, f"context/ files should be valid: {error_msg}"
        assert error_msg == "", "No error message for valid path"

    def test_validate_path_rejects_root_non_artifacts(self):
        """
        RULE-05: Non-artifact files in root are invalid.

        Scenario: Validate "MY_DOCUMENT.md" in root.
        Expected: validate_path() returns (False, error_message).
        """
        path = "MY_DOCUMENT.md"

        is_valid, error_msg = PathValidator.validate_path(path)

        assert is_valid is False, "Non-artifacts should NOT be in root"
        assert "context/" in error_msg, "Error should mention context/ requirement"

    def test_validate_path_accepts_readme_in_root(self):
        """
        RULE-05: README.md in root is valid.

        Scenario: Validate "README.md" path.
        Expected: validate_path() returns (True, "").
        """
        path = "README.md"

        is_valid, error_msg = PathValidator.validate_path(path)

        assert is_valid is True, "README.md in root should be valid"


class TestPathValidatorSuggestions:
    """Tests for path suggestion feature."""

    def test_suggest_correct_path_for_root_artifact(self):
        """
        RULE-05: Suggest root path for root artifacts.

        Scenario: Suggest path for "AGENTS.md".
        Expected: suggest_correct_path() returns "AGENTS.md" (no context/).
        """
        suggestion = PathValidator.suggest_correct_path("AGENTS.md")

        assert suggestion == "AGENTS.md", "Root artifacts should stay in root"

    def test_suggest_correct_path_for_regular_file(self):
        """
        RULE-05: Suggest context/ path for regular files.

        Scenario: Suggest path for "VISION.md" in "10-BUSINESS/".
        Expected: suggest_correct_path() returns "context/10-BUSINESS/VISION.md".
        """
        suggestion = PathValidator.suggest_correct_path(
            "VISION.md", subdirectory="10-BUSINESS"
        )

        assert (
            suggestion == "context/10-BUSINESS/VISION.md"
        ), "Regular files should go in context/"

    def test_suggest_correct_path_without_subdirectory(self):
        """
        RULE-05: Suggest context/ path without subdirectory.

        Scenario: Suggest path for "NOTES.md" (no subdirectory specified).
        Expected: suggest_correct_path() returns "context/NOTES.md".
        """
        suggestion = PathValidator.suggest_correct_path("NOTES.md")

        assert (
            suggestion == "context/NOTES.md"
        ), "Files without subdirectory should go in context/"
