"""Unit tests for the Master Workflow registry (domain/constants/workflow.py)."""

from app.domain.constants.workflow import (
    MASTER_WORKFLOW,
    WorkflowStep,
    get_next_step,
    get_step_by_type,
)


class TestMasterWorkflowRegistry:
    """Tests for the MASTER_WORKFLOW constant (immutable 24-step sequence)."""

    def test_master_workflow_has_24_steps(self) -> None:
        """MASTER_WORKFLOW must contain exactly 24 steps."""
        assert len(MASTER_WORKFLOW) == 24

    def test_first_step_is_project_manifesto(self) -> None:
        """Step 1 must be PROJECT_MANIFESTO (entry point of the workflow)."""
        first = MASTER_WORKFLOW[0]
        assert first.step_number == 1
        assert first.doc_type == "PROJECT_MANIFESTO"

    def test_last_step_is_readme(self) -> None:
        """Step 24 must be README (exit point of the workflow)."""
        last = MASTER_WORKFLOW[-1]
        assert last.step_number == 24
        assert last.doc_type == "README"

    def test_step_numbers_are_sequential(self) -> None:
        """Step numbers must be consecutive integers starting at 1."""
        numbers = [step.step_number for step in MASTER_WORKFLOW]
        assert numbers == list(range(1, 25))

    def test_all_step_numbers_unique(self) -> None:
        """No two steps may share the same step_number."""
        numbers = [step.step_number for step in MASTER_WORKFLOW]
        assert len(numbers) == len(set(numbers))

    def test_all_doc_types_unique(self) -> None:
        """No two steps may share the same doc_type."""
        doc_types = [step.doc_type for step in MASTER_WORKFLOW]
        assert len(doc_types) == len(set(doc_types))

    def test_all_steps_have_non_empty_paths(self) -> None:
        """Every step must have non-empty template_path, example_path and output_path."""
        for step in MASTER_WORKFLOW:
            assert (
                step.template_path
            ), f"Step {step.step_number} has empty template_path"
            assert step.example_path, f"Step {step.step_number} has empty example_path"
            assert step.output_path, f"Step {step.step_number} has empty output_path"

    def test_all_steps_have_non_empty_phase_folder(self) -> None:
        """Every step must declare a non-empty phase_folder."""
        for step in MASTER_WORKFLOW:
            assert step.phase_folder, f"Step {step.step_number} has empty phase_folder"

    def test_workflow_step_is_dataclass(self) -> None:
        """WorkflowStep must be a dataclass with the expected field names."""
        import dataclasses

        fields = {f.name for f in dataclasses.fields(WorkflowStep)}
        assert fields == {
            "step_number",
            "doc_type",
            "phase_folder",
            "template_path",
            "example_path",
            "output_path",
        }


class TestGetStepByType:
    """Tests for get_step_by_type helper function."""

    def test_returns_correct_step_for_known_doc_type(self) -> None:
        """Should return the matching step when doc_type exists."""
        step = get_step_by_type("PROJECT_MANIFESTO")
        assert step is not None
        assert step.doc_type == "PROJECT_MANIFESTO"
        assert step.step_number == 1

    def test_returns_middle_step_correctly(self) -> None:
        """Should correctly retrieve a step from the middle of the sequence."""
        step = get_step_by_type("TECH_STACK_DECISION")
        assert step is not None
        assert step.step_number == 8

    def test_returns_last_step_correctly(self) -> None:
        """Should correctly retrieve the last step (README)."""
        step = get_step_by_type("README")
        assert step is not None
        assert step.step_number == 24

    def test_returns_none_for_unknown_doc_type(self) -> None:
        """Should return None when doc_type is not registered."""
        assert get_step_by_type("NONEXISTENT_STEP") is None

    def test_returns_none_for_empty_string(self) -> None:
        """Should return None for an empty string."""
        assert get_step_by_type("") is None

    def test_is_case_sensitive(self) -> None:
        """doc_type lookup must be case-sensitive."""
        result_lower = get_step_by_type("project_manifesto")
        assert result_lower is None
        result_upper = get_step_by_type("PROJECT_MANIFESTO")
        assert result_upper is not None


class TestGetNextStep:
    """Tests for get_next_step helper function."""

    def test_returns_next_step_from_first(self) -> None:
        """After step 1, the next step must be step 2."""
        nxt = get_next_step("PROJECT_MANIFESTO")
        assert nxt is not None
        assert nxt.step_number == 2
        assert nxt.doc_type == "DOMAIN_LANGUAGE"

    def test_returns_none_after_last_step(self) -> None:
        """After the final step (README), get_next_step must return None."""
        assert get_next_step("README") is None

    def test_returns_none_for_unknown_doc_type(self) -> None:
        """Should return None when the given doc_type does not exist."""
        assert get_next_step("UNKNOWN_DOC") is None

    def test_increments_step_number_by_one(self) -> None:
        """The returned step must always be exactly one step ahead."""
        for step in MASTER_WORKFLOW[:-1]:
            next_step = get_next_step(step.doc_type)
            assert next_step is not None
            assert next_step.step_number == step.step_number + 1
