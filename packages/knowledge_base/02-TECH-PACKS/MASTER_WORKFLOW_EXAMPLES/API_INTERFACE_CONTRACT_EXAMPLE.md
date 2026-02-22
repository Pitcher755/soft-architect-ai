# 🔌 API Interface Contract - SoftArchitect AI

> **Document Type:** Technical Specification (OpenAPI 3.1.0)
> **Project:** SoftArchitect AI Backend API
> **Version:** 1.0.0
> **Last Updated:** February 2026
> **Status:** ✅ Implemented & Tested
> **Base URL:** `http://localhost:8000/api/v1`

---

## 📖 Table of Contents

1. [API Overview](#-api-overview)
2. [Authentication](#-authentication)
3. [Endpoints](#-endpoints)
4. [Data Models](#-data-models)
5. [Error Handling](#-error-handling)
6. [OpenAPI Specification](#-openapi-specification)

---

## 🎯 API Overview

### Purpose
RESTful API providing AI-powered project management, chat interface, and document generation capabilities for SoftArchitect AI desktop application.

### Design Principles
- **Stateless:** Each request contains all necessary context (project_id, conversation_id)
- **Idempotent:** Safe retries for network failures (use request_id for deduplication)
- **Versioned:** All endpoints under `/api/v1` (breaking changes require v2)
- **Self-Documenting:** OpenAPI spec auto-generated from Pydantic models

### Technology Stack
- **Framework:** FastAPI 0.109.0 (Python 3.12)
- **Validation:** Pydantic v2 for request/response schemas
- **Async:** Full async/await support (uvicorn ASGI server)
- **Streaming:** Server-Sent Events (SSE) for chat responses

---

## 🔐 Authentication

### Current (MVP): No Authentication
- **Rationale:** Desktop app = single-user, no network exposure
- **Security:** API binds to `localhost:8000` (not accessible remotely)

### Future (v2.0): API Key Authentication
```yaml
security:
  - ApiKeyAuth: []

components:
  securitySchemes:
    ApiKeyAuth:
      type: apiKey
      in: header
      name: X-API-Key
```

---

## 📡 Endpoints

### Chat Interface

#### POST `/api/v1/chat/stream`
**Description:** Send message to AI and receive streaming response via SSE.

**Request Body:**
```json
{
  "message": "Generate a Vision Document for my SaaS project",
  "project_id": "550e8400-e29b-41d4-a716-446655440000",
  "conversation_id": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
  "user_name": "Developer",
  "history": [
    {"role": "user", "content": "What's my project about?"},
    {"role": "assistant", "content": "You're building a local-first AI assistant..."}
  ]
}
```

**Response (SSE Stream):**
```
event: token
data: {"content": "I'll", "type": "text"}

event: token
data: {"content": " generate", "type": "text"}

event: token
data: {"content": " the Vision Document...", "type": "text"}

event: done
data: {"full_response": "I'll generate the Vision Document...", "metadata": {"tokens": 142, "duration_ms": 3400}}
```

**Status Codes:**
- `200 OK`: Stream started successfully
- `400 Bad Request`: Invalid project_id or message empty
- `503 Service Unavailable`: LLM service (Ollama/Groq) unreachable

**cURL Example:**
```bash
curl -X POST http://localhost:8000/api/v1/chat/stream \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Create Tech Stack document",
    "project_id": "550e8400-e29b-41d4-a716-446655440000",
    "user_name": "Developer"
  }'
```

---

#### POST `/api/v1/chat/query`
**Description:** Non-streaming chat endpoint (legacy, prefer `/stream`).

**Request Body:**
```json
{
  "message": "What frameworks should I use for a Flutter + Python project?",
  "project_id": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Response:**
```json
{
  "response": "For a Flutter + Python project, I recommend:\n- **Frontend:** Flutter 3.10+ with Riverpod for state management\n- **Backend:** FastAPI for async performance...",
  "metadata": {
    "model": "llama3.3:70b",
    "tokens_used": 284,
    "duration_ms": 4200,
    "sources": [
      "Flutter Tech Pack - State Management Best Practices",
      "FastAPI Tech Pack - Async Patterns"
    ]
  }
}
```

**Status Codes:**
- `200 OK`: Response generated successfully
- `422 Unprocessable Entity`: Validation error (e.g., message too long > 10,000 chars)
- `500 Internal Server Error`: Unexpected backend error

---

### Project Management

#### POST `/api/v1/projects`
**Description:** Create new project metadata.

**Request Body:**
```json
{
  "name": "EcommercePlatform",
  "root_path": "/home/dev/projects/ecommerce",
  "description": "Multi-tenant SaaS ecommerce platform with inventory management",
  "tech_stack_preference": "python_fastapi_postgresql"
}
```

**Response:**
```json
{
  "project_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "name": "EcommercePlatform",
  "root_path": "/home/dev/projects/ecommerce",
  "created_at": "2026-02-22T14:30:00Z",
  "status": "initialized",
  "phase": 0
}
```

---

#### GET `/api/v1/projects/{project_id}`
**Description:** Retrieve project metadata.

**Path Parameters:**
- `project_id` (UUID): Unique project identifier

**Response:**
```json
{
  "project_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "name": "EcommercePlatform",
  "root_path": "/home/dev/projects/ecommerce",
  "created_at": "2026-02-22T14:30:00Z",
  "updated_at": "2026-02-23T10:15:00Z",
  "status": "in_progress",
  "phase": 2,
  "completion_percentage": 42.5,
  "documents": {
    "completed": ["VISION.md", "TECH_STACK.md", "API_CONTRACT.md"],
    "pending": ["DATABASE_SCHEMA.md", "SPRINT_PLAN.md"]
  }
}
```

**Status Codes:**
- `200 OK`: Project found
- `404 Not Found`: Project ID doesn't exist

---

#### DELETE `/api/v1/projects/{project_id}`
**Description:** Delete project metadata (files in root_path NOT deleted).

**Response:**
```json
{
  "message": "Project metadata deleted successfully",
  "project_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "files_deleted": false
}
```

---

### Document Generation

#### POST `/api/v1/documents/generate`
**Description:** Generate specific project document (Vision, Tech Stack, API Contract, etc.)

**Request Body:**
```json
{
  "project_id": "f47ac10b-58cc-4372-a567-0e02b2c3d479",
  "document_type": "VISION",
  "context": {
    "project_description": "Multi-tenant ecommerce platform",
    "target_users": "Small business owners",
    "key_features": ["Inventory management", "Payment processing", "Analytics dashboard"]
  },
  "template_id": "vision_v1"
}
```

**Response:**
```json
{
  "document_id": "doc_8f7e3c1a",
  "document_type": "VISION",
  "content": "# 🎯 Project Vision - EcommercePlatform\n\n## Problem Statement\n...",
  "file_path": "context/VISION.md",
  "status": "generated",
  "generated_at": "2026-02-23T11:20:00Z"
}
```

**Status Codes:**
- `201 Created`: Document generated and saved
- `409 Conflict`: Document already exists (use `force_overwrite: true` to replace)

---

#### GET `/api/v1/documents/{project_id}/{document_type}`
**Description:** Retrieve previously generated document.

**Response:**
```json
{
  "document_type": "TECH_STACK",
  "content": "# 🛠️ Technology Stack Decision\n\n## Recommended Stack\n...",
  "file_path": "context/TECH_STACK.md",
  "last_modified": "2026-02-23T09:45:00Z",
  "version": "1.0.0"
}
```

**Status Codes:**
- `200 OK`: Document found
- `404 Not Found`: Document not generated yet

---

### Knowledge Base (RAG)

#### POST `/api/v1/knowledge/ingest`
**Description:** Ingest custom documents into RAG knowledge base.

**Request Body (multipart/form-data):**
```
files: [file1.md, file2.md, custom_tech_pack.pdf]
collection_name: "custom_flutter_patterns"
metadata: {"source": "internal_wiki", "author": "DevTeam"}
```

**Response:**
```json
{
  "ingestion_id": "ing_9a2f4b3c",
  "status": "processing",
  "files_count": 3,
  "estimated_duration_seconds": 120
}
```

---

#### GET `/api/v1/knowledge/search`
**Description:** Search knowledge base using semantic similarity.

**Query Parameters:**
- `query` (string): Search text
- `collection` (string, optional): Filter by collection (default: all)
- `top_k` (int, default: 5): Number of results

**Example:**
```
GET /api/v1/knowledge/search?query=FastAPI+dependency+injection&top_k=3
```

**Response:**
```json
{
  "results": [
    {
      "content": "FastAPI dependency injection allows you to declare reusable components...",
      "metadata": {
        "source": "FastAPI Tech Pack",
        "page": 12,
        "similarity_score": 0.89
      }
    },
    {
      "content": "Database sessions in FastAPI should be managed using Depends()...",
      "metadata": {
        "source": "FastAPI Tech Pack",
        "page": 24,
        "similarity_score": 0.82
      }
    }
  ],
  "query": "FastAPI dependency injection",
  "total_results": 2
}
```

---

### Health & Monitoring

#### GET `/api/v1/health`
**Description:** Health check endpoint for monitoring.

**Response:**
```json
{
  "status": "healthy",
  "version": "1.0.0",
  "services": {
    "llm": {
      "status": "online",
      "provider": "ollama",
      "model": "llama3.3:70b",
      "latency_ms": 142
    },
    "vector_db": {
      "status": "online",
      "provider": "chromadb",
      "collections": 3,
      "documents": 1247
    },
    "database": {
      "status": "online",
      "provider": "sqlite",
      "path": "/data/projects.db"
    }
  },
  "timestamp": "2026-02-23T12:00:00Z"
}
```

**Status Codes:**
- `200 OK`: All services healthy
- `503 Service Unavailable`: One or more services down

---

## 📦 Data Models

### ChatRequest
```python
class ChatRequest(BaseModel):
    message: str = Field(..., min_length=1, max_length=10000, description="User message")
    project_id: str = Field(..., description="UUID of active project")
    conversation_id: str | None = Field(None, description="Optional conversation UUID for multi-turn chats")
    user_name: str = Field(default="Developer", description="User display name for personalization")
    history: list[ChatHistoryItem] | None = Field(None, description="Recent chat history for context (max 100 messages)")

class ChatHistoryItem(BaseModel):
    role: Literal["user", "assistant", "system"]
    content: str
```

### ChatResponse
```python
class ChatResponse(BaseModel):
    response: str = Field(..., description="AI-generated response")
    metadata: ResponseMetadata

class ResponseMetadata(BaseModel):
    model: str = Field(..., description="LLM model used (e.g., 'llama3.3:70b')")
    tokens_used: int = Field(..., description="Total tokens in prompt + response")
    duration_ms: int = Field(..., description="Response generation time in milliseconds")
    sources: list[str] | None = Field(None, description="RAG sources retrieved (if applicable)")
```

### ProjectCreate
```python
class ProjectCreate(BaseModel):
    name: str = Field(..., min_length=1, max_length=100, pattern=r"^[a-zA-Z0-9_\-]+$")
    root_path: str = Field(..., description="Absolute path to project directory")
    description: str | None = Field(None, max_length=500)
    tech_stack_preference: str | None = Field(None, description="Preferred stack ID (e.g., 'python_fastapi_postgresql')")
```

### DocumentGenerateRequest
```python
class DocumentGenerateRequest(BaseModel):
    project_id: str = Field(..., description="UUID of project")
    document_type: Literal["VISION", "TECH_STACK", "API_CONTRACT", "DATABASE_SCHEMA", "SPRINT_PLAN", "README", "ADR"]
    context: dict[str, Any] = Field(default_factory=dict, description="Additional context for generation")
    template_id: str = Field(default="default", description="Template variant to use")
    force_overwrite: bool = Field(default=False, description="Overwrite existing document")
```

---

## ⚠️ Error Handling

### Standard Error Response
All errors return consistent JSON structure:

```json
{
  "error": {
    "code": "VALIDATION_ERROR",
    "message": "Project ID must be a valid UUID",
    "details": {
      "field": "project_id",
      "provided_value": "invalid-uuid",
      "constraint": "UUID format"
    },
    "timestamp": "2026-02-23T12:30:00Z",
    "request_id": "req_7f3a9d2b"
  }
}
```

### Error Codes

| Code | HTTP Status | Description | Retry? |
|------|-------------|-------------|--------|
| `VALIDATION_ERROR` | 422 | Invalid request payload | ❌ No (fix input) |
| `NOT_FOUND` | 404 | Resource doesn't exist | ❌ No |
| `CONFLICT` | 409 | Resource already exists | ❌ No (use different ID or force_overwrite) |
| `LLM_UNAVAILABLE` | 503 | Ollama/Groq service down | ✅ Yes (exponential backoff) |
| `RATE_LIMIT_EXCEEDED` | 429 | Too many requests (Groq API limit) | ✅ Yes (wait 60 seconds) |
| `INTERNAL_ERROR` | 500 | Unexpected backend error | ✅ Yes (max 3 retries) |

---

## 📜 OpenAPI Specification

### Full Spec (YAML)

```yaml
openapi: 3.1.0
info:
  title: SoftArchitect AI API
  description: Local-first AI development assistant API
  version: 1.0.0
  contact:
    name: Development Team
    url: https://github.com/Pitcher755/soft-architect-ai

servers:
  - url: http://localhost:8000/api/v1
    description: Local development server

paths:
  /chat/stream:
    post:
      summary: Stream AI chat response via SSE
      operationId: chatStream
      tags: [Chat]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ChatRequest'
      responses:
        '200':
          description: SSE stream of tokens
          content:
            text/event-stream:
              schema:
                type: string
        '400':
          $ref: '#/components/responses/BadRequest'
        '503':
          $ref: '#/components/responses/ServiceUnavailable'

  /projects:
    post:
      summary: Create new project
      operationId: createProject
      tags: [Projects]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/ProjectCreate'
      responses:
        '201':
          description: Project created successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ProjectResponse'
        '422':
          $ref: '#/components/responses/ValidationError'

  /projects/{project_id}:
    get:
      summary: Get project details
      operationId: getProject
      tags: [Projects]
      parameters:
        - name: project_id
          in: path
          required: true
          schema:
            type: string
            format: uuid
      responses:
        '200':
          description: Project found
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/ProjectResponse'
        '404':
          $ref: '#/components/responses/NotFound'
    delete:
      summary: Delete project metadata
      operationId: deleteProject
      tags: [Projects]
      parameters:
        - name: project_id
          in: path
          required: true
          schema:
            type: string
            format: uuid
      responses:
        '200':
          description: Project deleted
          content:
            application/json:
              schema:
                type: object
                properties:
                  message:
                    type: string
                  project_id:
                    type: string

  /documents/generate:
    post:
      summary: Generate project document
      operationId: generateDocument
      tags: [Documents]
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/DocumentGenerateRequest'
      responses:
        '201':
          description: Document generated
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/DocumentResponse'
        '409':
          $ref: '#/components/responses/Conflict'

  /knowledge/search:
    get:
      summary: Search knowledge base
      operationId: searchKnowledge
      tags: [Knowledge Base]
      parameters:
        - name: query
          in: query
          required: true
          schema:
            type: string
        - name: top_k
          in: query
          schema:
            type: integer
            default: 5
      responses:
        '200':
          description: Search results
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/SearchResponse'

  /health:
    get:
      summary: Health check
      operationId: healthCheck
      tags: [Monitoring]
      responses:
        '200':
          description: System healthy
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/HealthResponse'

components:
  schemas:
    ChatRequest:
      type: object
      required: [message, project_id]
      properties:
        message:
          type: string
          minLength: 1
          maxLength: 10000
        project_id:
          type: string
          format: uuid
        conversation_id:
          type: string
          format: uuid
          nullable: true
        user_name:
          type: string
          default: "Developer"
        history:
          type: array
          items:
            $ref: '#/components/schemas/ChatHistoryItem'

    ChatHistoryItem:
      type: object
      required: [role, content]
      properties:
        role:
          type: string
          enum: [user, assistant, system]
        content:
          type: string

    ProjectCreate:
      type: object
      required: [name, root_path]
      properties:
        name:
          type: string
          pattern: '^[a-zA-Z0-9_\-]+$'
        root_path:
          type: string
        description:
          type: string
          nullable: true
        tech_stack_preference:
          type: string
          nullable: true

    ProjectResponse:
      type: object
      properties:
        project_id:
          type: string
          format: uuid
        name:
          type: string
        root_path:
          type: string
        created_at:
          type: string
          format: date-time
        status:
          type: string
          enum: [initialized, in_progress, completed]
        phase:
          type: integer
          minimum: 0
          maximum: 6

    DocumentGenerateRequest:
      type: object
      required: [project_id, document_type]
      properties:
        project_id:
          type: string
          format: uuid
        document_type:
          type: string
          enum: [VISION, TECH_STACK, API_CONTRACT, DATABASE_SCHEMA, SPRINT_PLAN, README, ADR]
        context:
          type: object
          additionalProperties: true
        template_id:
          type: string
          default: "default"
        force_overwrite:
          type: boolean
          default: false

    HealthResponse:
      type: object
      properties:
        status:
          type: string
          enum: [healthy, degraded, unhealthy]
        version:
          type: string
        services:
          type: object

  responses:
    BadRequest:
      description: Invalid request
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorResponse'
    NotFound:
      description: Resource not found
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorResponse'
    Conflict:
      description: Resource already exists
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorResponse'
    ValidationError:
      description: Validation failed
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorResponse'
    ServiceUnavailable:
      description: Service temporarily unavailable
      content:
        application/json:
          schema:
            $ref: '#/components/schemas/ErrorResponse'
```

---

## 📎 Appendices

### Testing with Swagger UI

Start server:
```bash
cd src/server && uvicorn app.main:app --reload
```

Open browser: http://localhost:8000/docs

### Rate Limiting (Groq Cloud)

| Tier | Requests/Minute | Tokens/Day |
|------|-----------------|------------|
| **Free** | 30 | 14,400 |
| **Pro** | 6,000 | 1,000,000 |

---

> **Document Metadata:**
> **Created:** 2026-02-12
> **Last Updated:** 2026-02-23
> **Owner:** Backend Team
> **Review Frequency:** Before each release
> **Version:** 1.0.0
> **Status:** ✅ Production-Ready
