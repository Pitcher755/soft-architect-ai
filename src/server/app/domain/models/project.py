"""Project domain model.

Core entity representing a software project in the system.

Author: ArchitectZero
Created: 2026-02-10
"""

from dataclasses import dataclass, field
from datetime import UTC, datetime


@dataclass
class Project:
    """Project entity representing a software project.

    Attributes:
        id: Unique identifier for the project
        name: Human-readable project name
        path: Filesystem path where project is located
        description: Optional project description
        created_at: ISO timestamp of creation
        updated_at: ISO timestamp of last update
        metadata: Optional dictionary for custom metadata
    """

    id: str
    name: str
    path: str
    description: str | None = None
    created_at: str | None = None
    updated_at: str | None = None
    metadata: dict = field(default_factory=dict)

    def __post_init__(self) -> None:
        """Initialize timestamps if not provided."""
        now = datetime.now(UTC).isoformat()
        if self.created_at is None:
            self.created_at = now
        if self.updated_at is None:
            self.updated_at = now

    def __repr__(self) -> str:
        """Readable representation for logging."""
        return f"<Project id={self.id} name={self.name!r} path={self.path}>"
