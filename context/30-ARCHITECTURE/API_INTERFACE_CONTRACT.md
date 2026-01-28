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

* **POST** `/api/v1/chat/stream`
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

