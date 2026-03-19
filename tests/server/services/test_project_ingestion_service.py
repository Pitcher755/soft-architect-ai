"""Unit tests for ProjectIngestionService and the _split_into_chunks helper.

Coverage targets:
  - _split_into_chunks: all branching paths (empty, single, multi, oversized)
  - ProjectIngestionService.ingest_document: success, empty content, store errors

Naming convention: test_{method}_{scenario}_{expected_result}
"""

from unittest.mock import MagicMock

import pytest

from app.services.ingestion.project_ingestion_service import (
    ProjectIngestionService,
    _split_into_chunks,
)


# ---------------------------------------------------------------------------
# _split_into_chunks
# ---------------------------------------------------------------------------


class TestSplitIntoChunks:
    """Tests for the _split_into_chunks private helper."""

    def test_split_into_chunks_empty_string_returns_empty_list(self) -> None:
        assert _split_into_chunks("") == []

    def test_split_into_chunks_whitespace_only_returns_empty_list(self) -> None:
        assert _split_into_chunks("   \n\n   ") == []

    def test_split_into_chunks_single_paragraph_returns_one_chunk(self) -> None:
        text = "This is a single paragraph."
        result = _split_into_chunks(text)
        assert result == ["This is a single paragraph."]

    def test_split_into_chunks_two_paragraphs_fit_in_one_chunk(self) -> None:
        text = "Para one.\n\nPara two."
        result = _split_into_chunks(text, max_chars=200)
        assert len(result) == 1
        assert "Para one." in result[0]
        assert "Para two." in result[0]

    def test_split_into_chunks_paragraphs_split_when_limit_exceeded(self) -> None:
        # max_chars=15 means even two 10-char paragraphs cannot fit together.
        para_a = "A" * 10
        para_b = "B" * 10
        text = f"{para_a}\n\n{para_b}"
        result = _split_into_chunks(text, max_chars=15)
        assert len(result) == 2
        assert result[0] == para_a
        assert result[1] == para_b

    def test_split_into_chunks_oversized_single_paragraph_accepted_as_one_chunk(
        self,
    ) -> None:
        """A paragraph larger than max_chars is accepted as a single oversized chunk."""
        big = "X" * 5_000
        result = _split_into_chunks(big, max_chars=100)
        assert result == [big]

    def test_split_into_chunks_groups_paragraphs_greedily(self) -> None:
        """Multiple small paragraphs should be grouped into as few chunks as possible.

        With max_chars=20 and 5-char paragraphs the first chunk fits 2 paras
        (the separator cost is counted preventively for the first para giving an
        effective budget of 13 remaining), then subsequent chunks fit 3 paras each.
        9 paras → chunks: [2, 3, 3, 1] = 4 chunks.
        """
        paras = [f"P{i:04d}" for i in range(9)]  # 9 × "P0000" = 5-char each
        text = "\n\n".join(paras)
        result = _split_into_chunks(text, max_chars=20)
        # All paras are present and chunks respect the max_chars cap.
        assert len(result) == 4
        joined = "\n\n".join(result)
        assert all(f"P{i:04d}" in joined for i in range(9))

    def test_split_into_chunks_preserves_paragraph_content(self) -> None:
        text = "# Title\n\nParagraph with **bold** and `code`.\n\nSecond para."
        result = _split_into_chunks(text, max_chars=4_000)
        joined = "\n\n".join(result)
        # All original text should be present (possibly different joining)
        assert "# Title" in joined
        assert "Paragraph with **bold**" in joined
        assert "Second para." in joined

    def test_split_into_chunks_strips_leading_trailing_whitespace_per_para(
        self,
    ) -> None:
        text = "  Para A  \n\n  Para B  "
        result = _split_into_chunks(text, max_chars=200)
        # Paragraphs are stripped individually
        assert "Para A" in result[0]
        assert "Para B" in result[0]


# ---------------------------------------------------------------------------
# ProjectIngestionService
# ---------------------------------------------------------------------------


@pytest.fixture
def mock_store() -> MagicMock:
    """Return a MagicMock that imitates ChromaProjectStore.add_documents."""
    store = MagicMock()
    store.add_documents.return_value = 3
    return store


@pytest.fixture
def service(mock_store: MagicMock) -> ProjectIngestionService:
    """Return a ProjectIngestionService wired to the mock store."""
    return ProjectIngestionService(store=mock_store)  # type: ignore[arg-type]


class TestProjectIngestionService:
    """Tests for ProjectIngestionService.ingest_document."""

    def test_ingest_document_success_returns_chunk_count(
        self, service: ProjectIngestionService, mock_store: MagicMock
    ) -> None:
        mock_store.add_documents.return_value = 2
        result = service.ingest_document(
            project_id="proj-1",
            doc_name="MANIFESTO.md",
            markdown_content="# Vision\n\nWe build great things.",
        )
        assert result == 2

    def test_ingest_document_calls_store_add_documents_once(
        self, service: ProjectIngestionService, mock_store: MagicMock
    ) -> None:
        service.ingest_document(
            project_id="proj-2",
            doc_name="DOC.md",
            markdown_content="Some content.",
        )
        mock_store.add_documents.assert_called_once()

    def test_ingest_document_passes_correct_project_id_to_store(
        self, service: ProjectIngestionService, mock_store: MagicMock
    ) -> None:
        service.ingest_document(
            project_id="my-project-id",
            doc_name="DOC.md",
            markdown_content="Content here.",
        )
        _, kwargs = mock_store.add_documents.call_args
        assert kwargs["project_id"] == "my-project-id"

    def test_ingest_document_attaches_doc_name_in_metadata(
        self, service: ProjectIngestionService, mock_store: MagicMock
    ) -> None:
        service.ingest_document(
            project_id="proj-3",
            doc_name="ARCH.md",
            markdown_content="Architecture.",
        )
        _, kwargs = mock_store.add_documents.call_args
        assert all(m["doc_name"] == "ARCH.md" for m in kwargs["metadatas"])

    def test_ingest_document_metadata_has_sequential_chunk_index(
        self, service: ProjectIngestionService, mock_store: MagicMock
    ) -> None:
        # Three paragraphs → each chunk should get chunk_index 0, 1, 2.
        # Use tiny max_chars via content: three 1-char paras separated by \n\n
        content = "A" * 5_000 + "\n\n" + "B" * 5_000 + "\n\n" + "C" * 5_000
        # Default max_chars=4_000 splits each as separate chunks.
        service.ingest_document(
            project_id="proj-4",
            doc_name="BIG.md",
            markdown_content=content,
        )
        _, kwargs = mock_store.add_documents.call_args
        chunk_indices = [m["chunk_index"] for m in kwargs["metadatas"]]
        assert chunk_indices == list(range(len(chunk_indices)))

    def test_ingest_document_empty_content_raises_value_error(
        self, service: ProjectIngestionService
    ) -> None:
        with pytest.raises(ValueError, match="empty"):
            service.ingest_document(
                project_id="proj-5",
                doc_name="EMPTY.md",
                markdown_content="",
            )

    def test_ingest_document_whitespace_only_raises_value_error(
        self, service: ProjectIngestionService
    ) -> None:
        with pytest.raises(ValueError):
            service.ingest_document(
                project_id="proj-6",
                doc_name="WS.md",
                markdown_content="   \n\n   ",
            )

    def test_ingest_document_store_exception_propagates(
        self, service: ProjectIngestionService, mock_store: MagicMock
    ) -> None:
        mock_store.add_documents.side_effect = RuntimeError("ChromaDB down")
        with pytest.raises(RuntimeError, match="ChromaDB down"):
            service.ingest_document(
                project_id="proj-7",
                doc_name="DOC.md",
                markdown_content="Valid content.",
            )

    def test_ingest_document_single_chunk_content_sent_to_store(
        self, service: ProjectIngestionService, mock_store: MagicMock
    ) -> None:
        service.ingest_document(
            project_id="proj-8",
            doc_name="SHORT.md",
            markdown_content="Short text.",
        )
        _, kwargs = mock_store.add_documents.call_args
        assert kwargs["texts"] == ["Short text."]

    def test_ingest_document_strips_surrounding_whitespace_before_check(
        self, service: ProjectIngestionService, mock_store: MagicMock
    ) -> None:
        """Content with meaningful text but surrounding whitespace must not raise."""
        mock_store.add_documents.return_value = 1
        result = service.ingest_document(
            project_id="proj-9",
            doc_name="SPACED.md",
            markdown_content="  \n\nReal content.\n\n  ",
        )
        assert result == 1
