"""
Chat API endpoints for document generation with RAG and streaming.
Provides endpoints for sequential document generation using RAG + LLM.
"""

import json
from collections.abc import AsyncGenerator
from typing import Any

from fastapi import APIRouter, Depends, HTTPException
from fastapi.responses import StreamingResponse
from pydantic import BaseModel, ConfigDict, Field

from app.api.dependencies import get_rag_orchestrator, verify_api_key
from app.core.exceptions import (
    LLMConnectionError,
    LLMError,
    RAGError,
    RAGRetrievalError,
)
from app.domain.schemas.chat_schema import ChatRequest, ChatResponse
from app.services.rag.sequential_orchestrator import SequentialOrchestrator
from app.services.rag.template_loader import TemplateLoader

router = APIRouter(prefix="/chat", tags=["chat"])

_orchestrator: SequentialOrchestrator | None = None
orchestrator = None


class ChatMessage(BaseModel):
    """Represents a single chat message."""

    # 🎯 FIX: Ignora campos extra (id, timestamp, metadata) enviados por Flutter
    model_config = ConfigDict(extra="ignore")

    role: str = Field(..., description="Role: user, assistant, or system")
    content: str = Field(..., description="Message content")


class GenerateRequest(BaseModel):
    """Request model for document generation."""

    # 🎯 FIX: También permitimos flexibilidad en la petición general
    model_config = ConfigDict(extra="ignore")

    message: str = Field(..., description="User message/requirements")
    doc_type: str = Field(..., description="Document type (e.g., PROJECT_MANIFESTO)")
    project_context: dict[str, Any] = Field(default_factory=dict)
    chat_history: list[ChatMessage] = Field(default_factory=list)


@router.post("/message", response_model=ChatResponse, status_code=200)
async def chat_message(
    request: ChatRequest,
    orchestrator: SequentialOrchestrator = Depends(get_rag_orchestrator),
) -> ChatResponse:
    raise HTTPException(
        status_code=400,
        detail="Synchronous chat is deprecated in Operación Raíles. Please use /chat/stream endpoint.",
    )


@router.post("/stream", status_code=200)
async def chat_message_stream(
    request: ChatRequest,
    orchestrator: SequentialOrchestrator = Depends(get_rag_orchestrator),
    _api_key: str = Depends(verify_api_key),
) -> StreamingResponse:
    async def event_generator() -> AsyncGenerator[str, None]:
        doc_type = request.doc_type or "UNSORTED"
        context = {
            "chat_history": request.history,
            "project_id": str(request.project_id),
            "user_name": request.user_name,
        }

        try:
            async for token in orchestrator.generate(
                doc_type=doc_type, user_input=request.message, context=context
            ):
                yield f"event: message\ndata: {json.dumps({'token': token, 'is_final': False})}\n\n"

            done_data = {
                "full_response": "",
                "sources": [doc_type],
                "metadata": {"template_used": doc_type},
            }
            yield f"event: done\ndata: {json.dumps(done_data)}\n\n"

        except LLMConnectionError:
            yield f"event: error\ndata: {json.dumps({'error': 'AI Engine is unreachable', 'code': 'LLM_CONNECTION_ERROR', 'retry': True})}\n\n"
        except RAGRetrievalError:
            yield f"event: error\ndata: {json.dumps({'error': 'Knowledge base search failed', 'code': 'RAG_RETRIEVAL_ERROR', 'retry': False})}\n\n"
        except Exception as e:
            yield f"event: error\ndata: {json.dumps({'error': str(e), 'code': 'STREAM_ERROR', 'retry': False})}\n\n"

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
    return _get_orchestrator()


async def _stream_generator(
    message: str,
    doc_type: str,
    project_context: dict[str, Any],
    chat_history: list[ChatMessage],
) -> AsyncGenerator[str, None]:
    orchestrator = _get_orchestrator()
    context = {
        "project_context": project_context,
        "chat_history": [h.model_dump() for h in chat_history],
    }
    try:
        async for token in orchestrator.generate(
            doc_type=doc_type, user_input=message, context=context
        ):
            yield f"event: token\ndata: {json.dumps({'token': token, 'index': 0})}\n\n"
        yield f"event: done\ndata: {json.dumps({'total_tokens': 0, 'duration_ms': 0})}\n\n"
    except RAGError as e:
        yield f"event: error\ndata: {json.dumps({'code': e.code, 'message': e.message})}\n\n"
    except LLMError as e:
        yield f"event: error\ndata: {json.dumps({'code': e.code, 'message': e.message})}\n\n"
    except Exception as e:
        yield f"event: error\ndata: {json.dumps({'code': 'ERR', 'message': str(e)})}\n\n"


@router.post("/generate")
async def generate_document(request: GenerateRequest) -> StreamingResponse:
    try:
        return StreamingResponse(
            _stream_generator(
                request.message,
                request.doc_type,
                request.project_context,
                request.chat_history,
            ),
            media_type="text/event-stream",
        )
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e)) from e


def _get_orchestrator() -> SequentialOrchestrator:
    global orchestrator
    if orchestrator is None:
        try:
            from app.services.rag.vector_store import VectorStoreService

            vector_store = VectorStoreService()
            orchestrator = SequentialOrchestrator(
                vector_store=vector_store,
                llm_client=None,
                template_loader=TemplateLoader(),
            )
        except Exception as e:
            raise RuntimeError(f"Failed to init orchestrator: {str(e)}") from e
    return orchestrator


def set_orchestrator(orchestrator_instance: SequentialOrchestrator) -> None:
    global orchestrator
    orchestrator = orchestrator_instance
