# 🤝 API Interface Contract (Backend <-> Frontend)

> **Protocol:** HTTP/1.1 (REST) + Server-Sent Events (SSE) for Streaming.
> **Host:** `http://localhost:8000` (Docker Service: `api-server`).
> **Version:** `v1` (`/api/v1/...`).

---

## 1. Response Standard (JSON Envelope)

All responses (except streaming) must follow this strict format. The Frontend will validate these fields.

```json
{
  "status": "success | error",
  "code": 200,           // HTTP code replicated
  "message": "Operation successful", // Human-readable message (Dev)
  "data": { ... },       // Real payload (can be null on errors)
  "meta": {              // Optional metadata
    "timestamp": "2026-01-28T12:00:00Z",
    "version": "1.0.0"
  }
}

```

---

## 2. Core Endpoints (MVP)

### 🩺 Health Check

* **GET** `/health`
* **Usage:** Verify that the Python container and LangChain are alive.
* **Response:** `{"status": "success", "message": "System operational"}`.

### 🧠 Chat & RAG (Streaming)

#### POST /api/v1/chat/generate

**Description:** Generates document content using RAG + LLM with SSE streaming.

**Headers:** `Accept: text/event-stream`, `Content-Type: application/json`

**Request:**
```json
{
  "message": "Generate the Project Manifesto for an inventory management system",
  "doc_type": "PROJECT_MANIFESTO",
  "project_context": {
    "name": "InventoryPro",
    "description": "Inventory management system for retail",
    "tech_stack": ["Flutter", "Python", "PostgreSQL"]
  },
  "chat_history": [
    {"role": "user", "content": "I need a project..."},
    {"role": "assistant", "content": "Perfect, let's start..."}
  ]
}
```

**Response:** `text/event-stream` (SSE)

```
event: token
data: {"token": "# ", "index": 0}

event: token
data: {"token": "Project", "index": 1}

event: token
data: {"token": " Manifesto", "index": 2}

event: done
data: {"total_tokens": 450, "duration_ms": 3200}
```

**Error Codes:**
- `RAG_001`: ChromaDB unavailable
- `LLM_001`: Ollama timeout (>30s)
- `STREAM_001`: SSE connection error

---

#### POST /api/v1/chat/stream (Legacy)

* **Headers:** `Accept: text/event-stream`
* **Body:**
```json
{
  "message": "How to implement Clean Arch in Flutter?",
  "model_provider": "ollama", // or "groq"
  "session_id": "uuid-v4-..."
}

```


* **Response (Stream):** SSE events.
* `event: token` -> `data: "To"`
* `event: token` -> `data: " imple"`
* `event: token` -> `data: "ment..."`
* `event: end` -> `data: {"usage": 150 tokens}`



### 📚 Knowledge Ingestion

* **POST** `/api/v1/knowledge/ingest`
* **Usage:** Force re-scan of `packages/knowledge_base`.
* **Body:** `{"force_rebuild": true}`
* **Response:** 202 Accepted (Background process).

---

## 3. Common Data Types (DTOs)

### `ChatMessage`

```json
{
  "role": "user | assistant | system",
  "content": "Message text...",
  "timestamp": 1234567890
}

```

### `Settings`

```json
{
  "theme": "dark",
  "default_model": "ollama:qwen2.5-coder",
  "temperature": 0.7
}

```
