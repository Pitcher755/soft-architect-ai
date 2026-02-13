"""Chat domain schemas for HU-4.1 Backend Chat Endpoint.

This module provides the core data models for the chat feature:
- ChatRequest: Input validation schema for user messages
- ChatResponse: Output schema for AI responses
- RAGContext: Internal DTO for RAG orchestration pipeline

Author: ArchitectZero
Created: 2025-01-08
Version: 0.1.0 (Phase 0 - Skeleton)
"""

from datetime import datetime
from uuid import UUID

from pydantic import BaseModel, Field, field_validator

from app.domain.utils.sanitizer import InputSanitizer


class ChatRequest(BaseModel):
    """Input schema for chat message endpoint.

    Validates and sanitizes user input before processing.
    Security features will be implemented in Phase 1 (TDD RED/GREEN cycle).

    Attributes:
        conversation_id: Unique identifier for the conversation thread
        message: User's message (max 2000 chars to prevent DOS)
        project_id: Reference to the SoftArchitect AI project context
    """

    conversation_id: UUID = Field()
    message: str = Field()
    project_id: UUID = Field()

    @field_validator("message")
    @classmethod
    def sanitize_message(cls, v: str) -> str:
        """Full security sanitization (Phase 1).

        Pipeline:
        - Strip whitespace
        - HTML entity escaping (html.escape - preserves code)
        - Prompt injection detection (logging)

        Args:
            v: Raw message string

        Returns:
            str: Sanitized message (XSS-safe, code-preserved)
        """
        return InputSanitizer.sanitize_message(v)


class ChatResponse(BaseModel):
    """Output schema for chat endpoint.

    Contains the AI-generated response with metadata for transparency.

    Attributes:
        ai_response: LLM-generated answer to user's query
        template_used: Name of the SystemPromptTemplate applied
        sources: List of knowledge base documents used for context
        timestamp: UTC timestamp of response generation
        metadata: Optional additional information (e.g., confidence score)
    """

    ai_response: str = Field()
    template_used: str = Field()
    sources: list[str] = Field(
        default_factory=list,
        description="Knowledge base documents retrieved for context",
        example=["doc://tech-packs/python-testing.md", "doc://workflows/tdd-guide.md"],
    )
    timestamp: datetime = Field(
        default_factory=datetime.utcnow,
        description="UTC timestamp of response generation",
    )
    metadata: dict | None = Field(
        default=None,
        description="Optional metadata (e.g., confidence score, token count)",
        example={"confidence": 0.92, "tokens": 150, "latency_ms": 420},
    )


class RAGContext(BaseModel):
    """Internal DTO for RAG orchestration pipeline.

    Not exposed through API - used for internal passage between RAG components.

    Attributes:
        query: Sanitized user query after validation
        project_phase: Current phase of the user's project (e.g., "design", "implementation")
        retrieved_docs: Raw knowledge base documents from ChromaDB
        template: Selected SystemPromptTemplate name
        constructed_prompt: Final prompt sent to LLM (query + context + template)
    """

    query: str = Field(..., description="Sanitized user query after validation")
    project_phase: str = Field()
    retrieved_docs: list[str] = Field(
        default_factory=list,
        description="Raw knowledge base documents from ChromaDB",
    )
    template: str = Field()
    constructed_prompt: str = Field(
        ...,
        description="Final prompt sent to LLM (query + context + template)",
    )


# Version metadata for Phase 0
__version__ = "0.1.0-phase0"
__status__ = "Skeleton (awaiting Phase 1 security implementation)"
