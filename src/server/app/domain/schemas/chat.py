"""Chat domain schemas for HU-4.1.

Security considerations:
- Input sanitization (HTML entity escaping, length limits)
- XSS prevention (escape user content, NOT removal)
- Prompt injection prevention (pattern detection)
"""

from datetime import UTC, datetime
from uuid import UUID

from pydantic import BaseModel, Field, field_validator

from app.core.config import settings
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
        max_length=32000,  # Dynamic limit applied in validator
        description=f"User message (max {settings.CHAT_MAX_MESSAGE_LENGTH} chars, configurable via CHAT_MAX_MESSAGE_LENGTH)",
        json_schema_extra={
            "examples": ["How do I implement authentication in Flutter?"]
        },
    )
    project_id: UUID = Field(
        ...,
        description="Associated project identifier for context",
        json_schema_extra={"examples": ["7c9e6679-7425-40de-944b-e07fc1f90ae7"]},
    )

    # ✅ HU-5.0: User name for prompt personalization (RULE-09)
    user_name: str = Field(
        default="Developer",
        max_length=100,
        description="User's name for LLM prompt personalization (injected into system instruction)",
        json_schema_extra={"examples": ["Developer", "Juan", "María", "Alex"]},
    )

    # ✅ NEW: Chat history for conversational context
    history: list[dict[str, str]] = Field(
        default_factory=list,
        description="Chat context history (last N messages for LLM context window)",
        json_schema_extra={
            "examples": [
                [
                    {"role": "user", "content": "What is Clean Architecture?"},
                    {
                        "role": "assistant",
                        "content": "Clean Architecture is a software design...",
                    },
                    {"role": "user", "content": "How do I implement it in Flutter?"},
                ]
            ]
        },
    )

    @field_validator("message")
    @classmethod
    def sanitize_message(cls, v: str) -> str:
        """Sanitize user input and enforce dynamic length limit."""
        if len(v) > settings.CHAT_MAX_MESSAGE_LENGTH:
            raise ValueError(
                f"Message exceeds maximum length of {settings.CHAT_MAX_MESSAGE_LENGTH} characters "
                f"(got {len(v)}). Adjust CHAT_MAX_MESSAGE_LENGTH env var if needed."
            )
        return InputSanitizer.sanitize_message(v)

    @field_validator("history")
    @classmethod
    def validate_history(cls, v: list[dict[str, str]]) -> list[dict[str, str]]:
        """
        Validate chat history structure and limit size.

        Rules:
        - Max N messages (configurable via CHAT_MAX_HISTORY_MESSAGES)
        - Each message must have 'role' and 'content'
        - Role must be 'user' or 'assistant'
        - Content max M chars per message (configurable via CHAT_MAX_MESSAGE_LENGTH)

        Args:
            v: List of chat messages

        Returns:
            Validated and sanitized chat history

        Raises:
            ValueError: If validation fails
        """
        max_messages = settings.CHAT_MAX_HISTORY_MESSAGES
        if len(v) > max_messages:
            raise ValueError(
                f"Chat history exceeds maximum length ({max_messages} messages). "
                "Adjust CHAT_MAX_HISTORY_MESSAGES env var if needed."
            )

        valid_roles = {"user", "assistant"}
        sanitized_history = []

        for i, msg in enumerate(v):
            # Validate structure (runtime check for untrusted data)
            if not isinstance(msg, dict):  # pyright: ignore[reportUnnecessaryIsInstance]
                raise ValueError(f"Message {i} must be a dictionary")

            if "role" not in msg or "content" not in msg:
                raise ValueError(f"Message {i} must have 'role' and 'content' fields")

            # Validate role
            role = msg["role"]
            if role not in valid_roles:
                raise ValueError(
                    f"Message {i} has invalid role '{role}'. "
                    f"Must be one of: {valid_roles}"
                )

            # Validate and sanitize content
            content = msg["content"]
            if not isinstance(content, str):  # pyright: ignore[reportUnnecessaryIsInstance]
                raise ValueError(f"Message {i} content must be a string")

            max_length = settings.CHAT_MAX_MESSAGE_LENGTH
            if len(content) > max_length:
                raise ValueError(
                    f"Message {i} content exceeds {max_length} characters (got {len(content)}). "
                    "Adjust CHAT_MAX_MESSAGE_LENGTH env var if needed."
                )

            # Sanitize content (XSS prevention)
            sanitized_content = InputSanitizer.sanitize_message(content)

            sanitized_history.append({"role": role, "content": sanitized_content})

        return sanitized_history


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
__version__ = "0.2.0-chat-history"
__status__ = "Production (HU-4.2 Chat History Support)"
