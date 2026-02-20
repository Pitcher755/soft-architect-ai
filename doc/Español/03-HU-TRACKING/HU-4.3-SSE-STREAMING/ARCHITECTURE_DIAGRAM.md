# Architecture Diagram: SSE Streaming (HU-4.3 Fase 2)

> **Versión:** 1.0.0
> **Estado:** ✅ Fase 2 Complete
> **Creard:** 2026-02-15
> **Author:** ArchitectZero

---

## 📖 Tabla de Contenidos

- [Overview](#overview)
- [System Architecture](#system-architecture)
- [Component Diagram](#component-diagram)
- [Sequence Diagram](#sequence-diagram)
- [Data Flow](#data-flow)
- [Error Flow](#error-flow)
- [Technology Stack](#technology-stack)

---

## Overview

This documento provides architectural diagrams for the SSE streaming feature implemented in HU-4.3 Fase 2. It covers the full request-response cycle, component interactions, and error handling flows.

**Key Architectural Decisions:**
1. **SSE Protocol:** Chosen over WebSockets for simplicity (HTTP-based, auto-reconnection)
2. **AsyncGenerator Pattern:** Python async generators for natural streaming semantics
3. **Event-Driven Design:** Three event types (message, done, error) for clear state management
4. **Stateless Backend:** No connection state stored (conversation context passed per request)

---

## System Architecture

### High-Level Architecture

```mermaid
graph TB
    subgraph "Client Layer"
        FlutterApp["Flutter App<br/>(UI)"]
        HttpClient["HTTP Client<br/>(EventSource/SSE)"]
    end

    subgraph "API Layer"
        Router["FastAPI Router<br/>/api/v1/chat/stream"]
        AuthGuard["API Key<br/>Validator"]
        EventGen["Event Generator<br/>(SSE Formatter)"]
    end

    subgraph "Service Layer"
        Orchestrator["RAG Orchestrator<br/>process_message_stream()"]
        VectorStore["Vector Store<br/>(Stub/ChromaDB)"]
        TemplateBuilder["Template Builder<br/>(Prompt Construction)"]
    end

    subgraph "Infrastructure Layer"
        LLMClient["LLM Client<br/>(Ollama/Groq)"]
        OllamaAPI["Ollama API<br/>(NDJSON Streaming)"]
    end

    FlutterApp -->|1. POST /stream| HttpClient
    HttpClient -->|2. JSON Request| Router
    Router -->|3. Validate| AuthGuard
    AuthGuard -->|4. Inject| Router
    Router -->|5. Stream Events| EventGen
    EventGen -->|6. Process Stream| Orchestrator
    Orchestrator -->|7. Search Context| VectorStore
    Orchestrator -->|8. Build Prompt| TemplateBuilder
    Orchestrator -->|9. Stream Tokens| LLMClient
    LLMClient -->|10. NDJSON Stream| OllamaAPI
    OllamaAPI -.->|11. Tokens| LLMClient
    LLMClient -.->|12. Yield Tokens| Orchestrator
    Orchestrator -.->|13. Dict Events| EventGen
    EventGen -.->|14. SSE Format| Router
    Router -.->|15. text/event-stream| HttpClient
    HttpClient -.->|16. Token Updates| FlutterApp

    style Router fill:#e1f5fe
    style Orchestrator fill:#f3e5f5
    style LLMClient fill:#fff3e0
    style EventGen fill:#e8f5e9
```

---

## Component Diagram

### Layer Responsibilities

```mermaid
graph LR
    subgraph "Clean Architecture Layers"
        direction TB

        subgraph "1. API Layer (Interface Adapters)"
            Router["chat.py<br/>POST /stream endpoint"]
            Dependency["dependencies.py<br/>verify_api_key()"]
            Schemas["schemas/chat.py<br/>ChatRequest"]
        end

        subgraph "2. Service Layer (Use Cases)"
            Orchestrator["orchestrator.py<br/>RAGOrchestrator"]
            VectorProtocol["vector_store_protocol.py"]
            TemplateProtocol["template_builder_protocol.py"]
        end

        subgraph "3. Infrastructure Layer (Frameworks)"
            BaseLLM["llm/base.py<br/>BaseLLMClient"]
            OllamaClient["llm/ollama_client.py<br/>stream_generate()"]
            GroqClient["llm/groq_client.py<br/>(Stub)"]
        end

        subgraph "4. Domain Layer (Entities)"
            Exceptions["exceptions.py<br/>LLMStreamError"]
            Security["security.py<br/>InputSanitizer"]
        end

        Router --> Dependency
        Router --> Orchestrator
        Router --> Schemas
        Orchestrator --> VectorProtocol
        Orchestrator --> TemplateProtocol
        Orchestrator --> BaseLLM
        BaseLLM --> OllamaClient
        BaseLLM --> GroqClient
        Orchestrator --> Exceptions
        Schemas --> Security
    end

    style Router fill:#bbdefb
    style Orchestrator fill:#ce93d8
    style BaseLLM fill:#ffe0b2
    style Exceptions fill:#ffccbc
```

### Component Details

| Component | Responsibility | Key Methods |
|-----------|----------------|-------------|
| **chat.py** | SSE endpoint router | `chat_message_stream()`, `event_generator()` |
| **dependencies.py** | DI & auth | `verify_api_key()`, `get_rag_orchestrator()` |
| **orchestrator.py** | Streaming orchestration | `process_message_stream()` (AsyncGenerator) |
| **base.py** | LLM protocol | `stream_generate()` abstract method |
| **ollama_client.py** | Ollama streaming | `stream_generate()` NDJSON parser |
| **schemas/chat.py** | Request validation | `ChatRequest` Pydantic model |
| **exceptions.py** | Domain errors | `LLMStreamError`, `RAGRetrievalError` |

---

## Sequence Diagram

### Happy Path: Successful Streaming

```mermaid
sequenceDiagram
    autonumber
    participant Client as Flutter App
    participant Router as FastAPI Router
    participant Auth as API Key Validator
    participant Orchestrator as RAG Orchestrator
    participant Vector as Vector Store
    participant Template as Template Builder
    participant LLM as Ollama Client
    participant Ollama as Ollama API

    Client->>Router: POST /api/v1/chat/stream<br/>{message, conv_id, project_id}
    Router->>Auth: verify_api_key(x_api_key)
    Auth-->>Router: ✅ Valid API Key

    Router->>Orchestrator: process_message_stream(request)

    Note over Orchestrator: Phase 1: RAG Context Retrieval
    Orchestrator->>Vector: search(message, top_k=5)
    Vector-->>Orchestrator: sources: List[str]

    Note over Orchestrator: Phase 2: Template Selection
    Orchestrator->>Template: select_template(project_id)
    Template-->>Orchestrator: template_id: str

    Note over Orchestrator: Phase 3: Prompt Construction
    Orchestrator->>Template: build_prompt(message, sources, template_id)
    Template-->>Orchestrator: prompt: str

    Note over Orchestrator: Phase 4: LLM Streaming
    Orchestrator->>LLM: stream_generate(prompt)
    LLM->>Ollama: POST /api/generate {stream: true}

    loop For each token
        Ollama-->>LLM: NDJSON: {"response": "token"}
        LLM-->>Orchestrator: yield token: str
        Orchestrator-->>Router: yield {"type": "token", "data": "..."}
        Router-->>Client: event: message<br/>data: {"token": "..."}
    end

    Ollama-->>LLM: NDJSON: {"done": true}
    LLM-->>Orchestrator: (stream complete)

    Note over Orchestrator: Phase 5: Done Event
    Orchestrator-->>Router: yield {"type": "done", "data": {...}}
    Router-->>Client: event: done<br/>data: {"full_response": "...", "sources": [...]}

    Client->>Client: Close SSE connection
```

---

## Data Flow

### Token Streaming Flow

```mermaid
graph LR
    subgraph "1. Input Processing"
        Request["ChatRequest<br/>{message, conv_id, project_id}"]
        Sanitizer["InputSanitizer<br/>HTML escaping, injection detection"]
        ValidatedInput["Validated Input"]
    end

    subgraph "2. RAG Pipeline"
        VectorSearch["Vector Store<br/>Semantic search (top_k=5)"]
        TemplateSelect["Template Builder<br/>Select template by project_id"]
        PromptBuild["Prompt Construction<br/>Augmented with context"]
    end

    subgraph "3. LLM Streaming"
        OllamaStream["Ollama API<br/>NDJSON streaming"]
        TokenParser["Token Parser<br/>JSON.parse each line"]
        TokenYield["Yield Token"]
    end

    subgraph "4. SSE Formatting"
        EventMapper["Event Mapper<br/>token → message event"]
        SSEFormatter["SSE Formatter<br/>event: + data: + \\n\\n"]
        ClientStream["Client Receives SSE"]
    end

    Request --> Sanitizer
    Sanitizer --> ValidatedInput
    ValidatedInput --> VectorSearch
    VectorSearch --> TemplateSelect
    TemplateSelect --> PromptBuild
    PromptBuild --> OllamaStream
    OllamaStream --> TokenParser
    TokenParser --> TokenYield
    TokenYield --> EventMapper
    EventMapper --> SSEFormatter
    SSEFormatter --> ClientStream

    style Sanitizer fill:#ffcdd2
    style OllamaStream fill:#fff9c4
    style SSEFormatter fill:#c8e6c9
```

### Event Type Mapping

| Source | Event Type | Payload | Condition |
|--------|-----------|---------|-----------|
| `LLM.stream_generate()` | `token` | `{"token": str, "is_final": false}` | During streaming |
| `Orchestrator` | `done` | `{"full_response": str, "sources": list, "metadata": dict}` | After all tokens |
| `Exception` | `error` | `{"error": str, "code": str, "retry": bool}` | On failure |

---

## Error Flow

### Error Handling Chain

```mermaid
graph TB
    Start["Client POST Request"]

    subgraph "Pre-Stream Validation"
        AuthCheck{API Key Valid?}
        SchemaCheck{Request Schema Valid?}
    end

    subgraph "Streaming Errors"
        VectorError{Vector Search<br/>Failed?}
        LLMError{LLM Connection<br/>Failed?}
        StreamError{Stream<br/>Interrupted?}
    end

    subgraph "Error Responses"
        HTTP401["HTTP 401 Unauthorized"]
        HTTP422["HTTP 422 Validation Error"]
        SSEError["SSE error event<br/>{code, retry: true}"]
        SSEFatal["SSE error event<br/>{code, retry: false}"]
    end

    Start --> AuthCheck
    AuthCheck -->|No| HTTP401
    AuthCheck -->|Yes| SchemaCheck
    SchemaCheck -->|No| HTTP422
    SchemaCheck -->|Yes| VectorError

    VectorError -->|Yes| SSEError
    VectorError -->|No| LLMError
    LLMError -->|Yes| SSEError
    LLMError -->|No| StreamError
    StreamError -->|Yes| SSEError
    StreamError -->|No| Success["Stream Complete"]

    SSEError --> RetryDecision{retry: true?}
    RetryDecision -->|Yes| ClientRetry["Client Reconnects"]
    RetryDecision -->|No| SSEFatal

    style HTTP401 fill:#ef5350
    style HTTP422 fill:#ff7043
    style SSEError fill:#ffa726
    style Success fill:#66bb6a
```

### Error Code Matrix

| Error Condition | HTTP Estado | SSE Event | Code | Retry? |
|----------------|-------------|-----------|------|--------|
| Missing API key | 401 | N/A | N/A | No |
| Invalid UUID | 422 | N/A | N/A | No |
| Vector store down | 200 | `error` | `RAG_RETRIEVAL_ERROR` | Yes |
| Ollama unreachable | 200 | `error` | `LLM_CONNECTION_ERROR` | Yes |
| Stream timeout | 200 | `error` | `LLM_STREAM_ERROR` | Yes |
| Unexpected exception | 200 | `error` | `ORCHESTRATOR_ERROR` | No |

---

## Technology Stack

### Backend Components

| Layer | Technology | Version | Purpose |
|-------|-----------|---------|---------|
| **API Framework** | FastAPI | 0.115.6 | Async HTTP server, SSE support |
| **HTTP Client** | httpx | 0.28.1 | Async LLM API calls, streaming |
| **Validation** | Pydantic | 2.10.6 | Request/response schema validation |
| **LLM Provider** | Ollama | Laprueba | Local inference, NDJSON streaming |
| **Vector Store** | ChromaDB (stub) | Future | Semantic search for RAG context |
| **Pruebaing** | pyprueba + httpx | 8.3.4 | Integración pruebas with ASGITransport |

### Frontend Components (Flutter)

| Component | Package | Purpose |
|-----------|---------|---------|
| SSE Client | `http` | Native Dart SSE parsing |
| State Management | `riverpod` | Stream subscription management |
| UI Updates | `Stream<String>` | Real-time text rendering |

### Protocol Standards

- **SSE Specification:** W3C EventSource ([spec](https://html.spec.whatwg.org/multipage/server-sent-events.html))
- **Content-Type:** `text/event-stream; charset=utf-8`
- **Event Format:** `event: <type>\ndata: <json>\n\n`

---

## Performance Optimizations

### 1. Async Pipeline

```python
# Parallel execution of RAG retrieval and template selection
async with asyncio.TaskGroup() as tg:
    sources_task = tg.create_task(vector_store.search(...))
    template_task = tg.create_task(template_builder.select_template(...))
```

### 2. Streaming Buffering

```python
# Immediate token flushing (no chunking delay)
async for token in llm_client.stream_generate(prompt):
    yield {"type": "token", "data": token, "is_final": False}
    # Flushed to client instantly via StreamingResponse
```

### 3. Connection Pooling

```python
# httpx AsyncClient reused across requests
async with httpx.AsyncClient(timeout=30.0) as client:
    async with client.stream("POST", endpoint, json=payload) as response:
        # Connection kept alive until stream complete
```

---

## Security Architecture

### Defense Layers

```mermaid
graph LR
    Input["User Input"] --> Layer1["1. Pydantic Validation<br/>(Schema + Length)"]
    Layer1 --> Layer2["2. InputSanitizer<br/>(HTML Escaping)"]
    Layer2 --> Layer3["3. Prompt Injection Detection<br/>(Keyword Scanning)"]
    Layer3 --> Layer4["4. API Key Auth<br/>(Header Validation)"]
    Layer4 --> Safe["Safe Execution"]

    style Layer1 fill:#ffe0b2
    style Layer2 fill:#ffccbc
    style Layer3 fill:#ffab91
    style Layer4 fill:#ff8a65
    style Safe fill:#a5d6a7
```

### Security Controls

1. **Input Validation:** Pydantic enforces UUID format, max length (2000 chars)
2. **HTML Escaping:** `<`, `>`, `&` converted to entities
3. **Prompt Injection Prevention:** Detects "ignore", "system:", "jailbreak"
4. **API Key Authentication:** Min 10 chars, validated before streaming
5. **HTTPS Enforcement:** Required in production (TLS 1.2+)

---

## Related Documentos

- [API_CONTRACT.md](./API_CONTRACT.md) - SSE endpoint specification
- [COVERAGE_REPORT.md](./COVERAGE_REPORT.md) - Prueba metrics
- [PROGRESS.md](./PROGRESS.md) - Implementación timeline

---

**Changelog:**

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-02-15 | Initial architecture documentoation |
