"""Chat domain schemas for HU-4.1.

Security considerations:
- Input sanitization (HTML entity escaping, length limits)
- XSS prevention (escape user content, NOT removal)
- Prompt injection prevention (pattern detection)
"""

from datetime import UTC, datetime
from uuid import UUID

from pydantic import BaseModel, Field, field_validator

from app.domain.utils.sanitizer import InputSanitizer


class ChatRequest(BaseModel):
    """Incoming chat message request."""

    conversation_id: UUID = Field(
        ...,
        description="Unique conversation identifier",
        json_schema_extra={"examples": ["550e8400-e29b-41d4-a716-446655440000"]},
    )
    message: str = Field(
        ...,
        max_length=2000,
        description="User message (max 2000 chars for DOS prevention)",
        json_schema_extra={
            "examples": ["How do I implement authentication in Flutter?"]
        },
    )
    project_id: UUID = Field(
        ...,
        description="Associated project identifier for context",
        json_schema_extra={"examples": ["7c9e6679-7425-40de-944b-e07fc1f90ae7"]},
    )

    @field_validator("message")
    @classmethod
    def sanitize_message(cls, v: str) -> str:
        """Sanitize user input using security utility."""
        return InputSanitizer.sanitize_message(v)


class ChatResponse(BaseModel):
    """AI-generated response with metadata."""

    ai_response: str = Field(
        ...,
        description="Generated AI response text",
    )
    template_used: str = Field(
        ...,
        description="Template identifier that was used for this response",
    )
    sources: list[str] = Field(
        default_factory=list,
        description="Knowledge base sources used (file paths or IDs)",
    )
    timestamp: datetime = Field(
        default_factory=lambda: datetime.now(UTC),
        description="Response generation timestamp (UTC)",
    )
    metadata: dict | None = Field(
        default=None,
        description="Optional debug metadata (only in dev mode)",
    )


class RAGContext(BaseModel):
    """Internal DTO for RAG pipeline state (not exposed via API)."""

    query: str
    project_phase: str
    retrieved_docs: list[str]
    template: str
    constructed_prompt: str


# Version metadata for Phase 0
__version__ = "0.1.0-phase0"
__status__ = "Skeleton (awaiting Phase 1 security implementation)"
