"""
Chat API endpoints for document generation with RAG and streaming.

Provides endpoints for sequential document generation using RAG + LLM.
"""

import json
from collections.abc import AsyncGenerator
from typing import Any

from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import StreamingResponse
from pydantic import BaseModel, Field

from app.api.dependencies import get_rag_orchestrator, verify_api_key
from app.core.exceptions import (
    LLMConnectionError,
    LLMError,
    RAGError,
    RAGRetrievalError,
)
from app.domain.schemas.chat import ChatRequest, ChatResponse
from app.services.rag.orchestrator import RAGOrchestrator
from app.services.rag.sequential_orchestrator import SequentialOrchestrator
from app.services.rag.template_loader import TemplateLoader

router = APIRouter(prefix="/chat", tags=["chat"])

# Global orchestrator instance (will be injected via dependency)
_orchestrator: SequentialOrchestrator | None = None

# For testing purposes - global orchestrator variable
orchestrator = None


class ChatMessage(BaseModel):
    """Represents a single chat message."""

    role: str = Field(..., description="Role: user, assistant, or system")
    content: str = Field(..., description="Message content")


class GenerateRequest(BaseModel):
    """Request model for document generation."""

    message: str = Field(..., description="User message/requirements")
    doc_type: str = Field(..., description="Document type (e.g., PROJECT_MANIFESTO)")
    project_context: dict[str, Any] = Field(
        default_factory=dict,
        description="Project context data",
    )
    chat_history: list[ChatMessage] = Field(
        default_factory=list,
        description="Previous chat messages for context",
    )


@router.post("/message", response_model=ChatResponse, status_code=200)
async def chat_message(
    request: ChatRequest,
    orchestrator: RAGOrchestrator = Depends(get_rag_orchestrator),
) -> ChatResponse:
    """Process a chat message using RAG orchestration."""
    try:
        return await orchestrator.process_message(request)
    except LLMConnectionError as error:
        raise HTTPException(
            status_code=503,
            detail="AI Engine is currently unreachable. Please try again later.",
        ) from error
    except RAGRetrievalError as error:
        raise HTTPException(
            status_code=500,
            detail="Knowledge base search failed. Please contact support.",
        ) from error
    except Exception as error:
        import traceback

        traceback.print_exc()
        raise HTTPException(
            status_code=500,
            detail="An unexpected error occurred processing your request.",
        ) from error


@router.post("/stream", status_code=200)
async def chat_message_stream(
    request: ChatRequest,
    orchestrator: RAGOrchestrator = Depends(get_rag_orchestrator),
    _api_key: str = Depends(verify_api_key),
) -> StreamingResponse:
    """Process a chat message using RAG orchestration with SSE streaming.

    Streams AI response in real-time using Server-Sent Events (SSE).
    Emits three event types:
    - `event: message` with `data: {"token": "...", "is_final": false}`
    - `event: done` with `data: {"full_response": "...", "sources": [...], "metadata": {...}}`
    - `event: error` with `data: {"error": "...", "code": "...", "retry": true/false}`

    Args:
        request: ChatRequest with message and project_id
        orchestrator: Injected RAGOrchestrator instance

    Returns:
        StreamingResponse with text/event-stream content type

    Note:
        - Always returns HTTP 200 (errors emitted as SSE error events)
        - Client should handle event types: message, done, error
        - Connection kept alive with Cache-Control: no-cache
    """

    async def event_generator() -> AsyncGenerator[str, None]:
        """Convert dict events from orchestrator to SSE format."""
        try:
            async for event in orchestrator.process_message_stream(request):
                event_type = event.get("type", "message")

                # Map event types to SSE format
                if event_type == "token":
                    # Token event: stream individual tokens
                    sse_data = {
                        "token": event["data"],
                        "is_final": event.get("is_final", False),
                    }
                    yield f"event: message\ndata: {json.dumps(sse_data)}\n\n"

                elif event_type == "done":
                    # Done event: final response with metadata
                    yield f"event: done\ndata: {json.dumps(event['data'])}\n\n"

                elif event_type == "error":
                    # Error event: error details with retry flag
                    yield f"event: error\ndata: {json.dumps(event['data'])}\n\n"
                    break  # Stop streaming after error

        except LLMConnectionError:
            # AI service unreachable - emit error event
            error_data = {
                "error": "AI Engine is currently unreachable",
                "code": "LLM_CONNECTION_ERROR",
                "retry": True,
            }
            yield f"event: error\ndata: {json.dumps(error_data)}\n\n"
        except RAGRetrievalError:
            # Vector store error - emit error event
            error_data = {
                "error": "Knowledge base search failed",
                "code": "RAG_RETRIEVAL_ERROR",
                "retry": True,
            }
            yield f"event: error\ndata: {json.dumps(error_data)}\n\n"
        except Exception:
            # Catch-all for unexpected errors
            error_data = {
                "error": "An unexpected error occurred",
                "code": "STREAM_ERROR",
                "retry": False,
            }
            yield f"event: error\ndata: {json.dumps(error_data)}\n\n"

    return StreamingResponse(
        event_generator(),
        media_type="text/event-stream",
        headers={
            "Cache-Control": "no-cache",
            "Connection": "keep-alive",
            "X-Accel-Buffering": "no",
        },
    )


def get_orchestrator() -> SequentialOrchestrator:
    """
    Get or create the orchestrator instance (for testing).

    Returns:
        SequentialOrchestrator instance
    """
    return _get_orchestrator()


async def _stream_generator(
    message: str,
    doc_type: str,
    project_context: dict[str, Any],
    chat_history: list[ChatMessage],
) -> AsyncGenerator[str, None]:
    """
    Generator that streams tokens as SSE events.

    Args:
        message: User message
        doc_type: Document type
        project_context: Project context
        chat_history: Chat history

    Yields:
        SSE formatted event strings
    """
    orchestrator = _get_orchestrator()
    context = {
        "project_context": project_context,
        "chat_history": [h.model_dump() for h in chat_history],
    }

    try:
        async for token in orchestrator.generate(
            doc_type=doc_type,
            user_input=message,
            context=context,
        ):
            event_data = {"token": token, "index": 0}
            yield f"event: token\ndata: {json.dumps(event_data)}\n\n"

        # Signal completion
        done_data = {"total_tokens": 0, "duration_ms": 0}
        yield f"event: done\ndata: {json.dumps(done_data)}\n\n"

    except RAGError as e:
        error_data = {"code": e.code, "message": e.message}
        yield f"event: error\ndata: {json.dumps(error_data)}\n\n"
    except LLMError as e:
        error_data = {"code": e.code, "message": e.message}
        yield f"event: error\ndata: {json.dumps(error_data)}\n\n"


@router.post("/generate")
async def generate_document(request: GenerateRequest) -> StreamingResponse:
    """
    Generate document content using RAG + LLM with SSE streaming.

    Args:
        request: GenerateRequest with message, doc_type, context

    Returns:
        StreamingResponse with SSE events

    Raises:
        HTTPException: If request validation or processing fails
    """
    try:
        return StreamingResponse(
            _stream_generator(
                message=request.message,
                doc_type=request.doc_type,
                project_context=request.project_context,
                chat_history=request.chat_history,
            ),
            media_type="text/event-stream",
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e)) from e


def _get_orchestrator() -> SequentialOrchestrator:
    """
    Get or create the orchestrator instance.

    Returns:
        SequentialOrchestrator instance

    Raises:
        RuntimeError: If orchestrator not initialized
    """
    global orchestrator
    if orchestrator is None:
        # Initialize with default components
        # This is a placeholder - proper DI will be done later
        try:
            from app.services.rag.vector_store import VectorStoreService

            # TDD RED: These will fail for now - that's expected
            vector_store = VectorStoreService()
            llm_client = None  # Will be injected
            template_loader = TemplateLoader()
            orchestrator = SequentialOrchestrator(
                vector_store=vector_store,
                llm_client=llm_client,
                template_loader=template_loader,
            )
        except Exception as e:
            raise RuntimeError(f"Failed to initialize orchestrator: {str(e)}") from e

    return orchestrator


def set_orchestrator(orchestrator_instance: SequentialOrchestrator) -> None:
    """
    Set the orchestrator instance (for testing/DI).

    Args:
        orchestrator_instance: SequentialOrchestrator instance
    """
    global orchestrator
    orchestrator = orchestrator_instance
