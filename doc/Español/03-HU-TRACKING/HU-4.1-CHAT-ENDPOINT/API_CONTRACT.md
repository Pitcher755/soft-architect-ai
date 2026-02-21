# API Contract: POST /api/v1/chat/message

> **Versión:** 1.0.0
> **Estado:** ✅ Fase 0 Complete
> **Creard:** 2026-02-13
> **Author:** ArchitectZero

---

## 📖 Tabla de Contenidos

- [Overview](#overview)
- [Endpoint Specification](#endpoint-specification)
- [Request Schema](#request-schema)
- [Response Schema](#response-schema)
- [Error Codes](#error-codes)
- [Performance SLA](#performance-sla)
- [Security Considerations](#security-considerations)
- [Example Usage](#example-usage)
- [Integración Notes](#integration-notes)

---

## Overview

**Purpose:** Backend endpoint for SoftArchitect AI chat feature with RAG-powered context injection.

**Capabilities:**
- Accepts user messages with conversation/proyecto context
- Performs security sanitization (XSS prevention, prompt injection detection)
- Orchestrates RAG pipeline (vector search → template selection → LLM generation)
- Returns AI response with transparency metadata (sources, template used)

**Design Philosophy:**
- **Privacy First:** All processing happens locally (Ollama) or with explicit cloud opt-in (Groq)
- **Security Hardened:** HTML entity escaping, prompt injection detection, DOS prevention
- **Pruebaability:** Dependency injection for LLM clients, ChromaDB stub support
- **Performance:** <500ms target (p95) through async processing and caching

---

## Endpoint Specification

| Attribute | Value |
|-----------|-------|
| **Method** | POST |
| **Path** | `/api/v1/chat/message` |
| **Content-Type** | `application/json` |
| **Authentication** | None (Fase 1), Bearer Token (Fase 2) |
| **Rate Limiting** | 30 requests/min per IP (future) |
| **CORS** | Enabled for webapp frontend |

---

## Request Schema

### ChatRequest (JSON Body)

```json
{
  "conversation_id": "550e8400-e29b-41d4-a716-446655440000",
  "message": "How do I implement unit tests in Python?",
  "project_id": "7c9e6679-7425-40de-944b-e07fc1f90ae7"
}
```

### Fields

| Field | Type | Required | Constraints | Descripción |
|-------|------|----------|-------------|-------------|
| `conversation_id` | UUID | ✅ Yes | Valid UUIDv4 | Unique identifier for the conversation thread |
| `message` | string | ✅ Yes | 1-2000 chars | User's message (sanitized before processing) |
| `proyecto_id` | UUID | ✅ Yes | Valid UUIDv4 | Reference to SoftArchitect AI proyecto context |

### Validation Rules

1. **Length Limit:** `message` must be ≤2000 characters (DOS prevention)
2. **UUID Format:** `conversation_id` and `proyecto_id` must be valid UUIDv4
3. **Sanitization:**
   - HTML entities escaped (`<` → `&lt;`, `>` → `&gt;`)
   - Prompt injection patterns detected and logged
   - Code snippets preserved (Developer Tool Trap fix)

### Example: Minimal Request

```bash
curl -X POST http://localhost:8000/api/v1/chat/message \
  -H "Content-Type: application/json" \
  -d '{
    "conversation_id": "550e8400-e29b-41d4-a716-446655440000",
    "message": "Hello",
    "project_id": "7c9e6679-7425-40de-944b-e07fc1f90ae7"
  }'
```

---

## Response Schema

### ChatResponse (JSON)

```json
{
  "ai_response": "To implement unit tests in Python, use pytest or unittest...",
  "template_used": "software_architecture_expert",
  "sources": [
    "doc://tech-packs/python-testing.md",
    "doc://workflows/tdd-guide.md"
  ],
  "timestamp": "2025-01-08T14:32:15.123456Z",
  "metadata": {
    "confidence": 0.92,
    "tokens": 150,
    "latency_ms": 420
  }
}
```

### Fields

| Field | Type | Required | Descripción |
|-------|------|----------|-------------|
| `ai_response` | string | ✅ Yes | LLM-generated answer to user query |
| `template_used` | string | ✅ Yes | Name of SystemPromptTemplate applied |
| `sources` | array[string] | ✅ Yes | Knowledge base docs retrieved (empty if no RAG context) |
| `timestamp` | datetime (ISO8601) | ✅ Yes | UTC timestamp of response generation |
| `metadata` | object | ❌ No | Optional metadata (confidence, token count, latency) |

### Example: Success Response (200 OK)

```json
{
  "ai_response": "For Python testing, I recommend using pytest with these steps:\n\n1. Install: pip install pytest\n2. Create test_*.py files\n3. Run: pytest -v\n\nSee the retrieved docs for detailed examples.",
  "template_used": "software_architecture_expert",
  "sources": [
    "doc://tech-packs/python-testing.md",
    "doc://workflows/tdd-guide.md",
    "doc://best-practices/testing-pyramid.md"
  ],
  "timestamp": "2026-02-13T14:32:15.123456Z",
  "metadata": {
    "confidence": 0.95,
    "tokens": 180,
    "latency_ms": 420,
    "retriever_latency_ms": 50,
    "llm_latency_ms": 350
  }
}
```

---

## Error Codes

### 422 Unprocessable Entity (Validation Error)

**Cause:** Request validation failed (invalid UUID, message too long, etc.)

**Response:**

```json
{
  "detail": [
    {
      "loc": ["body", "message"],
      "msg": "ensure this value has at most 2000 characters",
      "type": "value_error.any_str.max_length"
    }
  ]
}
```

**Example Scenarios:**
- `message` exceeds 2000 characters
- `conversation_id` is not a valid UUID
- Required fields missing

---

### 503 Service Unavailable (LLM Client Error)

**Cause:** LLM service (Ollama/Groq) is unreachable or timed out

**Response:**

```json
{
  "error": "LLM_CONNECTION_ERROR",
  "message": "Unable to connect to local AI engine",
  "code": "AI_001",
  "retry_after": 30
}
```

**Example Scenarios:**
- Ollama server not ejecutarning (`docker-compose` not started)
- Network timeout (>10s)
- Groq API rate limit exceeded

**Client Action:** Retry after `retry_after` seconds (exponential backoff)

---

### 500 Internal Server Error (RAG Pipeline Failure)

**Cause:** Unexpected error in RAG orchestration (ChromaDB failure, template error, etc.)

**Response:**

```json
{
  "error": "RAG_RETRIEVAL_ERROR",
  "message": "Knowledge base search failed (fallback response used)",
  "code": "RAG_001"
}
```

**Example Scenarios:**
- ChromaDB connection failure
- Template not found in knowledge base
- LLM response parsing error

**Client Action:** Show generic error to user, report incident ID to support

---

## Performance SLA

| Metric | Target | Measurement | Notes |
|--------|--------|-------------|-------|
| **Response Time (p50)** | <300ms | End-to-end latency | Excluding LLM generation |
| **Response Time (p95)** | <500ms | End-to-end latency | Including RAG orchestration |
| **Response Time (p99)** | <1000ms | End-to-end latency | Worst-case scenarios |
| **Availability** | >99.5% | Uptime (local Ollama) | Excludes user's system downtime |
| **Throughput** | 50 req/sec | Single worker | Limited by LLM token generation speed |

### Hard Limits

- **Target:** <500ms (p95)
- **Timeout:** 10s (hard limit)
- **Retry Policy:** 3x with exponential backoff (client-side)

### Latency Desglose (Target)

| Fase | Duration | Percentage |
|-------|----------|------------|
| **Input Validation** | <10ms | 2% |
| **Vector Search (ChromaDB)** | <50ms | 10% |
| **Template Selection** | <5ms | 1% |
| **LLM Generation** | <400ms | 87% |
| **Response Serialization** | <5ms | 1% |

---

## Security Considerations

### 🔒 Input Sanitization

**Applied Before RAG Processing:**

1. **HTML Entity Escaping:**
```python
   # ✅ CORRECT (html.escape)
   "List<String>" → "List&lt;String&gt;"  # Preserves code
   "<script>alert(1)</script>" → "&lt;script&gt;alert(1)&lt;/script&gt;"  # Blocks XSS
```

2. **Prompt Injection Detection:**
   - Patterns: `"ignore anterior instructions"`, `"system:"`, `"new role:"`
   - Action: Log warning, proceed with sanitized input (defense in depth)

3. **Developer Tool Trap Fix:**
   - **Problem:** Regex stripping destroys code snippets (`"List<String>"` → `"ListString"`)
   - **Solution:** Use `html.escape()` to preserve structure while preventing XSS

### 🛡️ DOS Prevention

- **Message Length Limit:** 2000 characters (prevents long-input DOS)
- **Rate Limiting (Future):** 30 requests/min per IP
- **Timeout:** 10s for LLM generation (prevents hung requests)

### 🔐 Privacy Guarantees

- **Local-First:** Default to Ollama (no data leaves user's machine)
- **Cloud Opt-In:** Groq requires explicit user consent in settings
- **No Telemetry:** No usage data sent to external services

---

## Example Usage

### Success Case (200 OK)

```bash
curl -X POST http://localhost:8000/api/v1/chat/message \
  -H "Content-Type: application/json" \
  -d '{
    "conversation_id": "550e8400-e29b-41d4-a716-446655440000",
    "message": "How do I use Promise<T> in TypeScript?",
    "project_id": "7c9e6679-7425-40de-944b-e07fc1f90ae7"
  }'
```

**Response:**

```json
{
  "ai_response": "In TypeScript, Promise<T> is a generic type where T is the resolved value type. Example:\n\nasync function fetchUser(): Promise<User> {\n  return await api.getUser();\n}\n\nSee the retrieved TypeScript guide for more details.",
  "template_used": "software_architecture_expert",
  "sources": [
    "doc://tech-packs/typescript-async.md"
  ],
  "timestamp": "2025-01-08T14:35:20.123456Z",
  "metadata": {
    "confidence": 0.93,
    "tokens": 120,
    "latency_ms": 380
  }
}
```

---

### Validation Error (422 Unprocessable Entity)

```bash
curl -X POST http://localhost:8000/api/v1/chat/message \
  -H "Content-Type: application/json" \
  -d '{
    "conversation_id": "invalid-uuid",
    "message": "Test",
    "project_id": "7c9e6679-7425-40de-944b-e07fc1f90ae7"
  }'
```

**Response:**

```json
{
  "detail": [
    {
      "loc": ["body", "conversation_id"],
      "msg": "value is not a valid uuid",
      "type": "type_error.uuid"
    }
  ]
}
```

---

### LLM Unavailable (503 Service Unavailable)

```bash
# Prerequisites: Docker not running (no Ollama)
curl -X POST http://localhost:8000/api/v1/chat/message \
  -H "Content-Type: application/json" \
  -d '{
    "conversation_id": "550e8400-e29b-41d4-a716-446655440000",
    "message": "Test",
    "project_id": "7c9e6679-7425-40de-944b-e07fc1f90ae7"
  }'
```

**Response:**

```json
{
  "detail": "LLM service unavailable",
  "error_code": "LLM_CONNECTION_ERROR",
  "retry_after": 60
}
```

---

## Integración Notes

### Frontend Integración (Flutter)

```dart
// Example: Call chat endpoint from Flutter client
Future<ChatResponse> sendMessage({
  required UUID conversationId,
  required String message,
  required UUID projectId,
}) async {
  final response = await http.post(
    Uri.parse('http://localhost:8000/api/v1/chat/message'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'conversation_id': conversationId.toString(),
      'message': message,
      'project_id': projectId.toString(),
    }),
  );

  if (response.statusCode == 200) {
    return ChatResponse.fromJson(jsonDecode(response.body));
  } else if (response.statusCode == 422) {
    throw ValidationException(response.body);
  } else if (response.statusCode == 503) {
    throw LLMUnavailableException(response.body);
  } else {
    throw ServerException(response.body);
  }
}
```

### Pruebaing Integración

**Unit Pruebas (Python):**
```python
# Example: Test endpoint with mocked RAG orchestrator
async def test_chat_endpoint_success(client: TestClient, mock_rag):
    mock_rag.orchestrate.return_value = RAGResponse(
        ai_response="Test response",
        template_used="test_template",
        sources=["doc://test.md"],
    )

    response = client.post(
        "/api/v1/chat/message",
        json={
            "conversation_id": "550e8400-e29b-41d4-a716-446655440000",
            "message": "Test",
            "project_id": "7c9e6679-7425-40de-944b-e07fc1f90ae7",
        },
    )

    assert response.status_code == 200
    assert response.json()["ai_response"] == "Test response"
```

---

## Changelog

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2025-01-08 | Fase 0: Initial API contract specification |

---

## References

- [HU-4.1 README](./README.md)
- [WORKFLOW_MASTER_DEFINITION.md](./WORKFLOW_MASTER_DEFINITION.md)
- [OpenAPI Specification](https://spec.openapis.org/oas/v3.1.0)
- [Pydantic Validation](https://docs.pydantic.dev/)

---

> **Estado:** ✅ Fase 0 Complete - Preparado para Fase 1 implementación (TDD RED/GREEN cycles)
