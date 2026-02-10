# 🤝 Contrato de Interfaz API (Backend <-> Frontend)

> **Protocolo:** HTTP/1.1 (REST) + Server-Sent Events (SSE) para Streaming.
> **Host:** `http://localhost:8000` (Docker Service: `api-server`).
> **Versión:** `v1` (`/api/v1/...`).

---

## 1. Estándar de Respuesta (JSON Envelope)

Todas las respuestas (excepto streaming) deben seguir este formato estricto. El Frontend validará estos campos.

```json
{
  "status": "success | error",
  "code": 200,           // Código HTTP replicado
  "message": "Operación exitosa", // Mensaje legible para humanos (Dev)
  "data": { ... },       // Payload real (puede ser null en errores)
  "meta": {              // Metadatos opcionales
    "timestamp": "2026-01-28T12:00:00Z",
    "version": "1.0.0"
  }
}

```

---

## 2. Endpoints Core (MVP)

### 🩺 Health Check

* **GET** `/health`
* **Uso:** Verificar que el contenedor Python y LangChain están vivos.
* **Respuesta:** `{"status": "success", "message": "System operational"}`.

### 🧠 Chat & RAG (Streaming)

#### POST /api/v1/chat/generate

**Descripción:** Genera contenido de documento usando RAG + LLM con streaming SSE.

**Headers:** `Accept: text/event-stream`, `Content-Type: application/json`

**Request:**
```json
{
  "message": "Genera el Project Manifesto para un sistema de gestión de inventarios",
  "doc_type": "PROJECT_MANIFESTO",
  "project_context": {
    "name": "InventoryPro",
    "description": "Sistema de gestión de inventarios para retail",
    "tech_stack": ["Flutter", "Python", "PostgreSQL"]
  },
  "chat_history": [
    {"role": "user", "content": "Necesito un proyecto..."},
    {"role": "assistant", "content": "Perfecto, empecemos..."}
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

**Códigos de Error:**
- `RAG_001`: ChromaDB no disponible
- `LLM_001`: Timeout de Ollama (>30s)
- `STREAM_001`: Error en conexión SSE

---

#### POST /api/v1/chat/stream (Legacy)

* **Headers:** `Accept: text/event-stream`
* **Body:**
```json
{
  "message": "¿Cómo implemento Clean Arch en Flutter?",
  "model_provider": "ollama", // o "groq"
  "session_id": "uuid-v4-..."
}

```


* **Respuesta (Stream):** Eventos SSE.
* `event: token` -> `data: "Para"`
* `event: token` -> `data: " imple"`
* `event: token` -> `data: "mentar..."`
* `event: end` -> `data: {"usage": 150 tokens}`

---

## WebSocket Streaming Endpoint

### WS /api/v1/chat/stream

**Propósito:** Streaming en tiempo real de tokens LLM con latencia <200ms.

**Connection Flow:**
1. Client: `ws://localhost:8000/api/v1/chat/stream`
2. Server: Accept WebSocket
3. Client: Send query as JSON `{"type":"query","content":"...","session_id":"uuid-v4"}`
4. Server: Stream tokens incrementalmente
5. Server: Send `{"type":"ping"}` cada 30s
6. Client: Respond `{"type":"pong"}`
7. Server: Send `{"type":"done"}` al finalizar

**Message Format:**

**Client → Server (Query):**
```json
{
  "type": "query",
  "content": "User query text",
  "session_id": "uuid-v4"
}
```

**Server → Client (Token):**
```json
{
  "type": "token",
  "content": "single token",
  "timestamp": "2026-02-10T12:00:00Z"
}
```

**Server → Client (Heartbeat):**
```json
{
  "type": "ping"
}
```

**Client → Server (Heartbeat Response):**
```json
{
  "type": "pong"
}
```

**Server → Client (Completion):**
```json
{
  "type": "done",
  "total_tokens": 150,
  "latency_ms": 185
}
```

**Error Handling:**
```json
{
  "type": "error",
  "code": "WS_STREAM_FAILED",
  "message": "Error en español"
}
```

**Performance Guarantees:**
- TTFB: <200ms (p95)
- Token Rate: 10+ tokens/sec
- Max Message Size: 5MB
- Keep-Alive: 30s interval
- Idle Timeout: 5 minutes



### 📚 Knowledge Ingestion

* **POST** `/api/v1/knowledge/ingest`
* **Uso:** Forzar re-escaneo de `packages/knowledge_base`.
* **Body:** `{"force_rebuild": true}`
* **Respuesta:** 202 Accepted (Proceso en background).

---

## 3. Tipos de Datos Comunes (DTOs)

### `ChatMessage`

```json
{
  "role": "user | assistant | system",
  "content": "Texto del mensaje...",
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
