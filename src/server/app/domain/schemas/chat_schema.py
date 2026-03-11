"""Chat domain schemas for HU-4.1.

Security considerations:
- Input sanitization (HTML entity escaping, length limits)
- XSS prevention (escape user content, NOT removal)
- Prompt injection prevention (pattern detection)
"""

from datetime import UTC, datetime
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field, field_validator

from app.core.config import settings
from app.domain.utils.sanitizer import InputSanitizer


class ChatRequest(BaseModel):
    """Incoming chat message request."""

    # 🎯 FIX: Permite que Flutter envíe campos extra (id, timestamp, etc) sin explotar
    model_config = ConfigDict(extra="ignore")

    conversation_id: UUID = Field(
        ...,
        description="Unique conversation identifier",
        json_schema_extra={"examples": ["550e8400-e29b-41d4-a716-446655440000"]},
    )
    message: str = Field(
        ...,
        max_length=32000,
        description=(
            f"User message (max {settings.CHAT_MAX_MESSAGE_LENGTH} chars, "
            "configurable via CHAT_MAX_MESSAGE_LENGTH)"
        ),
        json_schema_extra={"examples": ["How do I implement authentication in Flutter?"]},
    )
    project_id: UUID = Field(
        ...,
        description="Associated project identifier for context",
        json_schema_extra={"examples": ["7c9e6679-7425-40de-944b-e07fc1f90ae7"]},
    )

    user_name: str = Field(
        default="Developer",
        max_length=100,
        description=(
            "User's name for LLM prompt personalization " "(injected into system instruction)"
        ),
        json_schema_extra={"examples": ["Developer", "Juan", "María", "Alex"]},
    )

    # 🎯 EL CABLE DEL FRONTEND: El campo clave para la "Operación Raíles"
    doc_type: str | None = Field(
        default=None,
        description=(
            "The specific document type to generate (e.g., 'PROJECT_MANIFESTO'). "
            "Used by the Sequential Orchestrator to inject the exact template and example."
        ),
        json_schema_extra={"examples": ["PROJECT_MANIFESTO", "DOMAIN_LANGUAGE"]},
    )

    history: list[dict[str, str]] = Field(
        default_factory=list,
        description="Chat context history (last N messages for LLM context window)",
    )

    metadata: dict[str, str] | None = Field(
        default=None,
        description="Optional key-value metadata from the client.",
    )

    @field_validator("message")
    @classmethod
    def sanitize_message(cls, v: str) -> str:
        if len(v) > settings.CHAT_MAX_MESSAGE_LENGTH:
            raise ValueError(
                f"Message exceeds maximum length of {settings.CHAT_MAX_MESSAGE_LENGTH} characters."
            )
        return InputSanitizer.sanitize_message(v)

    @field_validator("history")
    @classmethod
    def validate_history(cls, v: list[dict[str, str]]) -> list[dict[str, str]]:
        max_msgs = settings.CHAT_MAX_HISTORY_MESSAGES
        if len(v) > max_msgs:
            raise ValueError(f"Chat history exceeds maximum length ({max_msgs} messages).")

        # 🎯 FIX CRÍTICO: Añadimos "system" a los roles válidos para que no de error 422
        valid_roles = {"user", "assistant", "system"}
        max_msg_length = settings.CHAT_MAX_MESSAGE_LENGTH
        sanitized_history = []

        for i, msg in enumerate(v):
            if not isinstance(msg, dict):
                raise ValueError(f"Message {i} must be a dictionary")
            if "role" not in msg or "content" not in msg:
                raise ValueError(f"Message {i} must have 'role' and 'content' fields")

            role = msg["role"]
            if role not in valid_roles:
                raise ValueError(f"Message {i} has invalid role '{role}'.")

            content = msg["content"]
            if not isinstance(content, str):
                raise ValueError(f"Message {i} content must be a string")

            # Validate individual message length
            if len(content) > max_msg_length:
                raise ValueError(f"Message {i} content exceeds {max_msg_length} characters.")

            sanitized_content = InputSanitizer.sanitize_message(content)
            sanitized_history.append({"role": role, "content": sanitized_content})

        return sanitized_history


class ChatResponse(BaseModel):
    """AI-generated response with metadata."""

    model_config = ConfigDict(extra="ignore")

    ai_response: str = Field(..., description="Generated AI response text")
    template_used: str = Field(
        ..., description="Template identifier that was used for this response"
    )
    sources: list[str] = Field(default_factory=list, description="Knowledge base sources used")
    timestamp: datetime = Field(default_factory=lambda: datetime.now(UTC))
    metadata: dict | None = Field(default=None)


class RAGContext(BaseModel):
    model_config = ConfigDict(extra="ignore")
    query: str
    project_phase: str
    retrieved_docs: list[str]
    template: str
    constructed_prompt: str


__version__ = "0.3.0-state-machine"
__status__ = "Production (Operación Raíles)"
