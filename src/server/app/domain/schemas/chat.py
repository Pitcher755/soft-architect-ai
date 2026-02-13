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


class ChatRequest(BaseModel):
    """Input schema for chat message endpoint.

    Validates and sanitizes user input before processing.
    Security features will be implemented in Phase 1 (TDD RED/GREEN cycle).

    Attributes:
        conversation_id: Unique identifier for the conversation thread
        message: User's message (max 2000 chars to prevent DOS)
        project_id: Reference to the SoftArchitect AI project context
    """

    conversation_id: UUID = Field(
        ...,
        description="Unique identifier for the conversation thread",
        example="550e8400-e29b-41d4-a716-446655440000",
    )
    message: str = Field(
        ...,
        max_length=2000,
        description="User message with security sanitization",
        example="How do I implement unit tests in Python?",
    )
    project_id: UUID = Field(
        ...,
        description="Reference to the SoftArchitect AI project",
        example="7c9e6679-7425-40de-944b-e07fc1f90ae7",
    )

    @field_validator("message")
    @classmethod
    def sanitize_message(cls, v: str) -> str:
        """Basic sanitization (Phase 0 placeholder).

        TODO (Phase 1): Implement full security validation:
        - HTML entity escaping (html.escape)
        - Prompt injection detection
        - Developer Tool Trap fix (preserve code snippets)

        Args:
            v: Raw message string

        Returns:
            str: Sanitized message (Phase 0: only strips whitespace)
        """
        return v.strip()


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

    ai_response: str = Field(
        ...,
        description="AI-generated response to user query",
        example="To implement unit tests in Python, use pytest or unittest...",
    )
    template_used: str = Field(
        ...,
        description="Name of the SystemPromptTemplate applied",
        example="software_architecture_expert",
    )
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
    project_phase: str = Field(
        ...,
        description="Current phase of the user's project",
        example="implementation",
    )
    retrieved_docs: list[str] = Field(
        default_factory=list,
        description="Raw knowledge base documents from ChromaDB",
    )
    template: str = Field(
        ...,
        description="Selected SystemPromptTemplate name",
        example="software_architecture_expert",
    )
    constructed_prompt: str = Field(
        ...,
        description="Final prompt sent to LLM (query + context + template)",
    )


# Version metadata for Phase 0
__version__ = "0.1.0-phase0"
__status__ = "Skeleton (awaiting Phase 1 security implementation)"
