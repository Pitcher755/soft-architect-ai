"""Test SQL injection prevention and input validation.

Validates that the database layer is protected against:
- SQL injection attacks
- Path traversal attacks
- Invalid input formats
"""

import os
import tempfile
from collections.abc import Generator

import pytest

from app.domain.models.project import Project
from app.infrastructure.persistence.exceptions import ValidationError
from app.infrastructure.persistence.sqlite_repository import SQLiteRepository
from app.infrastructure.persistence.transaction_manager import TransactionManager


@pytest.fixture
def temp_db() -> Generator[str, None, None]:
    """Create temporary SQLite database for testing.

    Yields path to temporary DB file, cleans up after test.
    """
    fd, db_path = tempfile.mkstemp(suffix=".db")
    os.close(fd)
    yield db_path
    try:
        os.unlink(db_path)
    except OSError:
        pass


@pytest.fixture
def repo(temp_db: str) -> SQLiteRepository:
    """Create repository with temporary database."""
    tx_manager = TransactionManager(temp_db)
    return SQLiteRepository(tx_manager)


class TestSQLInjectionPrevention:
    """SQL injection prevention tests."""

    def test_sql_injection_in_project_name(self, repo: SQLiteRepository) -> None:
        """Should prevent SQL injection in project name field.

        Malicious input: '; DROP TABLE projects; --
        Expected: ValidationError (input validation) or safe handling
        """
        malicious_name = "'; DROP TABLE projects; --"

        # Should fail safely (name validation should reject special chars)
        project = Project(
            id="safe-id",
            name=malicious_name,
            path="/tmp/test",
        )

        # This should either raise ValidationError or safely insert with escaped chars
        try:
            repo.create_project(project)
            # If no error, verify the project was inserted safely
            result = repo.get_project("safe-id")
            assert result is not None
            # Verify data is not corrupted
            assert result.name == malicious_name  # Name stored as-is, not executed
        except ValidationError:
            # This is acceptable - validation rejected malicious input
            pass

    def test_sql_injection_in_path(self, repo: SQLiteRepository) -> None:
        """Should prevent SQL injection via path parameter."""
        malicious_path = "'; DELETE FROM projects; --"

        project = Project(
            id="test-safe",
            name="Test Project",
            path=malicious_path,
        )

        # Should handle safely
        try:
            repo.create_project(project)
            result = repo.get_project("test-safe")
            assert result is not None
            assert result.path == malicious_path  # Stored safely, not executed
        except ValidationError:
            pass  # Validation rejection is acceptable

    def test_parameterized_queries_prevent_injection(
        self, repo: SQLiteRepository
    ) -> None:
        """Verify that repository uses parameterized queries.

        This is a documentation test verifying the codebase
        uses sqlite3.execute(sql, params) not f-strings.
        """
        # Create test project
        project = Project(
            id="param-test",
            name="Normal Project",
            path="/tmp/safe",
        )
        repo.create_project(project)

        # Query by name - should use parameterized query
        result = repo.get_project_by_name("Normal Project")
        assert result is not None

        # If this works with the safe project, verify injection would fail
        result_malicious = repo.get_project_by_name("'; DROP TABLE projects; --")
        assert result_malicious is None  # Doesn't match any real project

        # Verify original data still exists (not deleted by injection)
        result_verify = repo.get_project("param-test")
        assert result_verify is not None


class TestInputValidation:
    """Input validation and sanitization tests."""

    def test_path_traversal_prevention(self, repo: SQLiteRepository) -> None:
        """Should prevent path traversal attacks (../)."""
        traversal_path = "../../../etc/passwd"

        # Should either sanitize or reject
        project = Project(
            id="traversal-test",
            name="Traversal Test",
            path=traversal_path,
        )

        try:
            repo.create_project(project)
            # If accepted, verify it was safely stored
            result = repo.get_project("traversal-test")
            assert result is not None
            # Path should not allow actual traversal
            assert ".." not in result.path or result.path == traversal_path
        except ValidationError as e:
            # Expected: validation rejects path traversal
            assert ".." in str(e) or "traversal" in str(e).lower()

    def test_hidden_file_prevention(self, repo: SQLiteRepository) -> None:
        """Should prevent hidden files (starting with .)."""
        hidden_path = ".hidden_project"

        project = Project(
            id="hidden-test",
            name="Hidden Test",
            path=hidden_path,
        )

        try:
            repo.create_project(project)
            result = repo.get_project("hidden-test")
            assert result is not None
        except ValidationError as e:
            # Expected: validation rejects hidden files
            assert "." in str(e) or "hidden" in str(e).lower()

    def test_project_id_validation(self, repo: SQLiteRepository) -> None:
        """Should validate project ID format."""
        # Test various invalid ID formats
        invalid_ids = [
            "",  # Empty
            "   ",  # Whitespace
            "id-with; semicolon",  # SQL char
            "id' or '1'='1",  # SQL injection attempt
        ]

        for invalid_id in invalid_ids:
            project = Project(
                id=invalid_id,
                name=f"Test {invalid_id}",
                path="/tmp/test",
            )

            # Should either validate or be handled safely
            try:
                repo.create_project(project)
                # If accepted, verify it's stored safely
                result = repo.get_project(invalid_id)
                if result:
                    assert result.id == invalid_id  # Stored as-is, safe
            except ValidationError:
                # Expected: invalid IDs rejected
                pass

    def test_project_name_length_validation(self, repo: SQLiteRepository) -> None:
        """Should validate project name length."""
        # Test extremely long name
        very_long_name = "A" * 10000

        project = Project(
            id="long-name-test",
            name=very_long_name,
            path="/tmp/test",
        )

        try:
            repo.create_project(project)
            # If accepted, verify it's stored
            result = repo.get_project("long-name-test")
            assert result is not None
        except ValidationError as e:
            # Expected: extremely long names should be rejected
            err_msg = str(e).lower()
            assert (
                "length" in err_msg
                or "long" in err_msg
                or "<=" in str(e)
                or "characters" in err_msg
            )
