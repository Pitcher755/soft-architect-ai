"""Unit tests for RULE-10 Workflow Sequence Validator (HU-5.0).

Tests the "Sequential Flow 24 Docs" feature that ensures:
- Documents are generated in strict order (0-23)
- Each phase (0-3) completed before next starts
- Step-by-step validation enforcement

Coverage target: 100% for workflow sequence validation
Expected test count: 6 tests
"""

from enum import Enum


class WorkflowPhase(Enum):
    """Workflow phases (0-3) representing the 24-document sequence."""

    PHASE_0_ROOT = 0  # Docs 0-4: Vision, Summary, Roadmap, README, Agents
    PHASE_1_BUSINESS = 1  # Docs 5-10: Business requirements
    PHASE_2_TECHNICAL = 2  # Docs 11-17: Technical specs
    PHASE_3_IMPLEMENTATION = 3  # Docs 18-23: Implementation guides


class WorkflowSequenceValidator:
    """Validates document generation follows sequential order."""

    TOTAL_DOCUMENTS = 24
    DOCUMENTS_PER_PHASE = {
        WorkflowPhase.PHASE_0_ROOT: 5,  # 0-4
        WorkflowPhase.PHASE_1_BUSINESS: 6,  # 5-10
        WorkflowPhase.PHASE_2_TECHNICAL: 7,  # 11-17
        WorkflowPhase.PHASE_3_IMPLEMENTATION: 6,  # 18-23
    }

    @staticmethod
    def get_phase_for_document(doc_index: int) -> WorkflowPhase:
        """
        Get workflow phase for document index (0-23).

        Args:
            doc_index: Document index (0-23)

        Returns:
            WorkflowPhase enum value
        """
        if 0 <= doc_index <= 4:
            return WorkflowPhase.PHASE_0_ROOT
        elif 5 <= doc_index <= 10:
            return WorkflowPhase.PHASE_1_BUSINESS
        elif 11 <= doc_index <= 17:
            return WorkflowPhase.PHASE_2_TECHNICAL
        elif 18 <= doc_index <= 23:
            return WorkflowPhase.PHASE_3_IMPLEMENTATION
        else:
            raise ValueError(f"Invalid document index: {doc_index} (must be 0-23)")

    @staticmethod
    def can_generate_document(doc_index: int, generated_docs: list[int]) -> bool:
        """
        Check if document can be generated (previous docs completed).

        Args:
            doc_index: Document index to check (0-23)
            generated_docs: List of already generated document indices

        Returns:
            True if document can be generated, False if prerequisites missing
        """
        if doc_index < 0 or doc_index >= WorkflowSequenceValidator.TOTAL_DOCUMENTS:
            return False

        # Document 0 can always be generated (start of workflow)
        if doc_index == 0:
            return True

        # Check if previous document was generated
        previous_doc = doc_index - 1
        return previous_doc in generated_docs

    @staticmethod
    def get_next_document_index(generated_docs: list[int]) -> int | None:
        """
        Get the next document that should be generated.

        Args:
            generated_docs: List of already generated document indices

        Returns:
            Next document index (0-23), or None if all completed
        """
        if not generated_docs:
            return 0  # Start with document 0

        # Find the highest generated document
        max_generated = max(generated_docs)

        # If all 24 documents generated, return None
        if max_generated >= WorkflowSequenceValidator.TOTAL_DOCUMENTS - 1:
            return None

        # Return next sequential document
        return max_generated + 1

    @staticmethod
    def is_phase_complete(phase: WorkflowPhase, generated_docs: list[int]) -> bool:
        """
        Check if all documents in a phase are completed.

        Args:
            phase: WorkflowPhase to check
            generated_docs: List of already generated document indices

        Returns:
            True if all phase documents are generated
        """
        if phase == WorkflowPhase.PHASE_0_ROOT:
            required_docs = set(range(0, 5))
        elif phase == WorkflowPhase.PHASE_1_BUSINESS:
            required_docs = set(range(5, 11))
        elif phase == WorkflowPhase.PHASE_2_TECHNICAL:
            required_docs = set(range(11, 18))
        elif phase == WorkflowPhase.PHASE_3_IMPLEMENTATION:
            required_docs = set(range(18, 24))
        else:
            return False

        return required_docs.issubset(set(generated_docs))


class TestWorkflowSequenceValidatorPhases:
    """Tests for phase identification."""

    def test_get_phase_for_document_phase_0(self):
        """
        RULE-10: Documents 0-4 belong to Phase 0 (ROOT).

        Scenario: Check phase for document 0 (Vision).
        Expected: get_phase_for_document(0) returns PHASE_0_ROOT.
        """
        phase = WorkflowSequenceValidator.get_phase_for_document(0)

        assert phase == WorkflowPhase.PHASE_0_ROOT

    def test_get_phase_for_document_phase_1(self):
        """
        RULE-10: Documents 5-10 belong to Phase 1 (BUSINESS).

        Scenario: Check phase for document 5.
        Expected: get_phase_for_document(5) returns PHASE_1_BUSINESS.
        """
        phase = WorkflowSequenceValidator.get_phase_for_document(5)

        assert phase == WorkflowPhase.PHASE_1_BUSINESS

    def test_get_phase_for_document_phase_3(self):
        """
        RULE-10: Documents 18-23 belong to Phase 3 (IMPLEMENTATION).

        Scenario: Check phase for document 23 (last document).
        Expected: get_phase_for_document(23) returns PHASE_3_IMPLEMENTATION.
        """
        phase = WorkflowSequenceValidator.get_phase_for_document(23)

        assert phase == WorkflowPhase.PHASE_3_IMPLEMENTATION


class TestWorkflowSequenceValidatorSequential:
    """Tests for sequential document generation."""

    def test_can_generate_document_first_doc(self):
        """
        RULE-10: Document 0 can be generated without prerequisites.

        Scenario: No documents generated yet.
        Expected: can_generate_document(0, []) returns True.
        """
        result = WorkflowSequenceValidator.can_generate_document(0, [])

        assert result is True, "Document 0 can always be generated"

    def test_can_generate_document_with_prerequisite(self):
        """
        RULE-10: Document can be generated if previous doc exists.

        Scenario: Document 0 already generated.
        Expected: can_generate_document(1, [0]) returns True.
        """
        generated_docs = [0]

        result = WorkflowSequenceValidator.can_generate_document(1, generated_docs)

        assert result is True, "Document 1 can be generated after doc 0"

    def test_can_generate_document_without_prerequisite(self):
        """
        RULE-10: Document CANNOT be generated if previous doc missing.

        Scenario: Try to generate document 2 but 1 is missing.
        Expected: can_generate_document(2, [0]) returns False.
        """
        generated_docs = [0]  # Missing document 1

        result = WorkflowSequenceValidator.can_generate_document(2, generated_docs)

        assert result is False, "Document 2 cannot skip document 1"


class TestWorkflowSequenceValidatorNavigation:
    """Tests for workflow navigation helpers."""

    def test_get_next_document_index_at_start(self):
        """
        RULE-10: Next document at start is 0 (Vision).

        Scenario: No documents generated yet.
        Expected: get_next_document_index([]) returns 0.
        """
        next_doc = WorkflowSequenceValidator.get_next_document_index([])

        assert next_doc == 0, "First document should be 0"

    def test_get_next_document_index_in_progress(self):
        """
        RULE-10: Next document is sequential after last generated.

        Scenario: Documents 0, 1, 2 generated.
        Expected: get_next_document_index([0, 1, 2]) returns 3.
        """
        generated_docs = [0, 1, 2]

        next_doc = WorkflowSequenceValidator.get_next_document_index(generated_docs)

        assert next_doc == 3, "Should suggest next sequential document"

    def test_get_next_document_index_at_end(self):
        """
        RULE-10: No next document after all 24 completed.

        Scenario: All 24 documents (0-23) generated.
        Expected: get_next_document_index([0..23]) returns None.
        """
        generated_docs = list(range(24))  # All 24 documents

        next_doc = WorkflowSequenceValidator.get_next_document_index(generated_docs)

        assert next_doc is None, "Should return None when workflow complete"


class TestWorkflowSequenceValidatorPhaseCompletion:
    """Tests for phase completion checking."""

    def test_is_phase_complete_phase_0(self):
        """
        RULE-10: Phase 0 complete when docs 0-4 generated.

        Scenario: Documents 0, 1, 2, 3, 4 all generated.
        Expected: is_phase_complete(PHASE_0_ROOT, [...]) returns True.
        """
        generated_docs = [0, 1, 2, 3, 4]

        is_complete = WorkflowSequenceValidator.is_phase_complete(
            WorkflowPhase.PHASE_0_ROOT, generated_docs
        )

        assert is_complete is True, "Phase 0 should be complete"

    def test_is_phase_complete_phase_incomplete(self):
        """
        RULE-10: Phase NOT complete if any document missing.

        Scenario: Documents 0, 1, 2 generated (missing 3, 4).
        Expected: is_phase_complete(PHASE_0_ROOT, [0,1,2]) returns False.
        """
        generated_docs = [0, 1, 2]  # Missing docs 3, 4

        is_complete = WorkflowSequenceValidator.is_phase_complete(
            WorkflowPhase.PHASE_0_ROOT, generated_docs
        )

        assert is_complete is False, "Phase 0 should NOT be complete"

    def test_is_phase_complete_phase_3(self):
        """
        RULE-10: Phase 3 complete when docs 18-23 generated.

        Scenario: All documents 0-23 generated.
        Expected: is_phase_complete(PHASE_3_IMPLEMENTATION, [...]) returns True.
        """
        generated_docs = list(range(24))  # All 24 documents

        is_complete = WorkflowSequenceValidator.is_phase_complete(
            WorkflowPhase.PHASE_3_IMPLEMENTATION, generated_docs
        )

        assert is_complete is True, "Phase 3 should be complete"
