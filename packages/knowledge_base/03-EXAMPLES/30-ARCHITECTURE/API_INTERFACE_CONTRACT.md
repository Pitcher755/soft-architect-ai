# 📡 API Interface Contract: SoftArchitect AI

> **Versión:** 1.0
> **Fecha:** 30/01/2026
> **Estado:** ✅ Especificado
> **Base URL:** `http://localhost:8000/api/v1`
> **Auth:** None (local app, single user)

---

## 📖 Tabla de Contenidos

1. [Overview](#overview)
2. [Endpoints](#endpoints)
3. [Request/Response Schemas](#requestresponse-schemas)
4. [Error Handling](#error-handling)
5. [Rate Limiting](#rate-limiting)

---

## Overview

### Architecture

```
┌─────────────┐
│  Flutter    │  (Desktop UI)
│  App        │
└──────┬──────┘
       │ HTTP/REST
       │ (TLS 1.3+)
       ▼
┌──────────────────────────────────────┐
│  FastAPI Backend (localhost:8000)    │
├──────────────────────────────────────┤
│ /api/v1/                             │
│ ├─ /llm/*         (query processing) │
│ ├─ /rag/*         (vector search)    │
│ ├─ /knowledge/*   (knowledge base)   │
│ ├─ /config/*      (settings)         │
│ └─ /health        (status)           │
└──────────────────────────────────────┘
```

### Versions & Support

```
API Version    Status       Sunset
────────────────────────────────────
v1             CURRENT      2026-12-31
v0             DEPRECATED   2026-03-31
```

---

## Endpoints

### 1. LLM Query Processing

#### POST `/api/v1/llm/query`

**Purpose:** Send question, get RAG-augmented response

**Request:**

```json
{
  "query": "How to choose between React and Vue?",
  "context": {
    "max_tokens": 2048,
    "temperature": 0.7,
    "model": "mistral:latest"
  },
  "stream": true
}
```

**Parameters:**

| Field | Type | Required | Constraints |
|:---|:---|:---:|:---|
| `query` | string | Yes | 1-5000 chars, non-empty |
| `context.max_tokens` | integer | No | 100-4096 (default: 2048) |
| `context.temperature` | number | No | 0.0-1.0 (default: 0.7) |
| `context.model` | string | No | Ollama model name (default: "mistral:latest") |
| `stream` | boolean | No | Server-sent events if true (default: false) |

**Response (Non-Streaming):**

```json
{
  "id": "query-uuid-here",
  "query": "How to choose between React and Vue?",
  "response": "React uses JSX while Vue uses templates...",
  "context_docs": [
    {
      "id": "doc-1",
      "title": "React Fundamentals",
      "similarity": 0.95,
      "excerpt": "React is a JavaScript library for building UIs..."
    }
  ],
  "metadata": {
    "processing_time_ms": 1250,
    "tokens_used": 512,
    "model": "mistral:latest"
  },
  "timestamp": "2026-01-30T10:30:00Z"
}
```

**Response (Streaming):**

```
data: {"id": "query-uuid", "chunk": "React uses", "position": 0}
data: {"id": "query-uuid", "chunk": " JSX", "position": 10}
data: [DONE]
```

**Status Codes:**

| Code | Meaning |
|:---:|:---|
| 200 | Success |
| 400 | Bad query (too long, empty, invalid) |
| 422 | Validation error (temp out of range, etc.) |
| 500 | Ollama/processing error |
| 503 | Service temporarily unavailable |

---

### 2. RAG Search (Vector Search)

#### GET `/api/v1/rag/search`

**Purpose:** Search knowledge base by semantic similarity

**Query Parameters:**

```
GET /api/v1/rag/search?q=cloud+deployment&limit=5&threshold=0.8
```

| Param | Type | Required | Constraints |
|:---|:---|:---:|:---|
| `q` | string | Yes | Search query (1-500 chars) |
| `limit` | integer | No | Max results (1-50, default: 5) |
| `threshold` | number | No | Similarity threshold (0.0-1.0, default: 0.7) |

**Response:**

```json
{
  "query": "cloud deployment",
  "results": [
    {
      "id": "doc-001",
      "title": "AWS Deployment Guide",
      "content": "AWS offers multiple deployment options...",
      "similarity": 0.95,
      "source": "tech-packs/cloud/aws.md",
      "tags": ["aws", "deployment", "cloud"]
    },
    {
      "id": "doc-002",
      "title": "Azure Deployment Options",
      "content": "Azure provides similar services...",
      "similarity": 0.92,
      "source": "tech-packs/cloud/azure.md",
      "tags": ["azure", "deployment", "cloud"]
    }
  ],
  "total": 2,
  "took_ms": 150
}
```

---

### 3. Knowledge Base Management

#### POST `/api/v1/knowledge/upload`

**Purpose:** Upload new documents to knowledge base

**Content-Type:** `multipart/form-data`

**Request:**

```
POST /api/v1/knowledge/upload
Content-Type: multipart/form-data

file: <binary markdown/json/txt content>
tags: ["backend", "database"]
category: "architecture"
```

**Response:**

```json
{
  "id": "uploaded-doc-123",
  "filename": "database-design.md",
  "size_bytes": 5240,
  "chunks": 12,
  "status": "indexed",
  "tags": ["backend", "database"],
  "category": "architecture",
  "created_at": "2026-01-30T10:35:00Z"
}
```

---

#### GET `/api/v1/knowledge/list`

**Purpose:** List all documents in knowledge base

**Query Parameters:**

```
GET /api/v1/knowledge/list?category=architecture&limit=20&offset=0
```

**Response:**

```json
{
  "total": 150,
  "documents": [
    {
      "id": "doc-001",
      "title": "React Fundamentals",
      "size_bytes": 12500,
      "chunks": 5,
      "tags": ["frontend", "react"],
      "category": "frontend",
      "uploaded_at": "2026-01-15T08:00:00Z",
      "last_accessed": "2026-01-30T09:15:00Z"
    }
  ],
  "limit": 20,
  "offset": 0
}
```

---

#### DELETE `/api/v1/knowledge/{doc_id}`

**Purpose:** Remove document from knowledge base

**Response:**

```json
{
  "id": "doc-001",
  "status": "deleted",
  "reclaimed_space_bytes": 12500
}
```

---

### 4. Configuration Management

#### GET `/api/v1/config/settings`

**Purpose:** Get current settings

**Response:**

```json
{
  "model": "mistral:latest",
  "temperature": 0.7,
  "max_tokens": 2048,
  "language": "en",
  "privacy": {
    "encrypt_at_rest": true,
    "collect_telemetry": false,
    "share_with_cloud": false
  },
  "ui": {
    "theme": "dark",
    "font_size": 14
  }
}
```

---

#### PUT `/api/v1/config/settings`

**Purpose:** Update settings

**Request:**

```json
{
  "model": "llama2:latest",
  "temperature": 0.8,
  "privacy": {
    "encrypt_at_rest": true
  }
}
```

**Response:** Updated settings object (same as GET)

---

### 5. System Health

#### GET `/api/v1/health`

**Purpose:** Check backend status

**Response:**

```json
{
  "status": "healthy",
  "components": {
    "fastapi": "ok",
    "ollama": "ok",
    "chromadb": "ok",
    "sqlite": "ok"
  },
  "uptime_seconds": 86400,
  "version": "0.1.0"
}
```

**Status Codes:**

| Code | Meaning |
|:---:|:---|
| 200 | All systems operational |
| 503 | One or more components down |

---

## Request/Response Schemas

### Common Structures

#### Error Response

```json
{
  "error": {
    "code": "INVALID_QUERY",
    "message": "Query must be between 1 and 5000 characters",
    "details": {
      "field": "query",
      "received": 5001,
      "constraint": "max_length:5000"
    },
    "timestamp": "2026-01-30T10:30:00Z",
    "request_id": "req-uuid-here"
  }
}
```

#### Pagination

```json
{
  "total": 100,
  "limit": 10,
  "offset": 0,
  "items": [],
  "next_offset": 10,
  "has_more": true
}
```

#### Metadata

```json
{
  "timestamp": "2026-01-30T10:30:00Z",
  "request_id": "req-uuid-here",
  "version": "1.0",
  "processing_time_ms": 1250
}
```

---

## Error Handling

### Error Codes

```
VALIDATION_ERROR (400)
  └─ Malformed request
  └─ Invalid parameters
  └─ Constraint violations

NOT_FOUND (404)
  └─ Document/resource not found

RATE_LIMIT_EXCEEDED (429)
  └─ Too many requests

INTERNAL_ERROR (500)
  └─ Server-side failure
  └─ Ollama unavailable
  └─ Database error

SERVICE_UNAVAILABLE (503)
  └─ Backend restarting
  └─ Maintenance mode
```

### Retry Strategy

```
Status    Retry?    Backoff
─────────────────────────────
400       ❌ No     N/A
404       ❌ No     N/A
429       ✅ Yes    Exponential (2s, 4s, 8s)
500       ✅ Yes    Exponential (1s, 2s, 4s)
503       ✅ Yes    Exponential (5s, 10s, 20s)
```

---

## Rate Limiting

### Limits (Per User/Session)

```
Endpoint Group    Limit              Window
──────────────────────────────────────────────
/llm/*            10 requests        per minute
/rag/*            50 requests        per minute
/knowledge/*      5 requests         per minute
/config/*         100 requests       per hour
/health           Unlimited          -
```

### Headers

**Request:**

```http
X-Request-ID: unique-uuid
```

**Response:**

```http
X-RateLimit-Limit: 10
X-RateLimit-Remaining: 8
X-RateLimit-Reset: 2026-01-30T10:31:00Z
```

---

## Testing & Examples

### cURL Examples

```bash
# Query with streaming
curl -X POST http://localhost:8000/api/v1/llm/query \
  -H "Content-Type: application/json" \
  -d '{
    "query": "What is Docker?",
    "stream": true
  }'

# Search knowledge base
curl "http://localhost:8000/api/v1/rag/search?q=kubernetes&limit=5"

# Upload document
curl -X POST http://localhost:8000/api/v1/knowledge/upload \
  -F "file=@my-guide.md" \
  -F "category=backend"

# Health check
curl http://localhost:8000/api/v1/health
```

---

**API Contract** define el "contrato" entre cliente y servidor. Cambios en endpoints requieren versionado. 📡
