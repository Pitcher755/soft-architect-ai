# 📡 HU-4.2: API Contract Specification

> **Version:** 1.0.0
> **Base URL:** `/api/v1`
> **Protocol:** HTTP/1.1
> **Format:** OpenAPI 3.1.0

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Authentication](#authentication)
3. [Endpoints](#endpoints)
   - [POST /conversations/](#post-conversations)
   - [GET /conversations/{id}](#get-conversationsid)
   - [GET /conversations/](#get-conversations)
4. [Schemas](#schemas)
5. [Error Responses](#error-responses)
6. [Examples](#examples)

---

## 🔍 Overview

### Base Information

| Property | Value |
|----------|-------|
| **API Version** | v1 |
| **Base Path** | `/api/v1` |
|**Content-Type** | `application/json` |
| **Response Format** | JSON |
| **Rate Limit** | None (MVP) |

### Versioning Strategy

- **URL Versioning:** `/api/v1/`, `/api/v2/`, etc.
- **Backward Compatibility:** Breaking changes require new version
- **Deprecation Policy:** 6 months notice before removal

---

## 🔐 Authentication

### API Key (Required)

**Header:**
```http
X-API-Key: <your-api-key>
```

**Validation:**
- Minimum length: 10 characters
- Validated on every request
- Returns `401 Unauthorized` if missing or invalid

**Example:**
```bash
curl -H "X-API-Key: my-secret-key" \
     https://api.example.com/api/v1/conversations/
```

---

## 🛣️ Endpoints

### POST /conversations/

**Create a new conversation**

#### Request

**Method:** `POST`
**Path:** `/api/v1/conversations/`
**Content-Type:** `application/json`

**Request Body:**
```json
{
  "project_id": "uuid",
  "title": "string | null"
}
```

**Schema:** `ConversationCreate`

| Field | Type | Required | Constraints | Description |
|-------|------|----------|-------------|-------------|
| `project_id` | UUID | ✅ Yes | Valid UUID v4 | Project identifier |
| `title` | string \| null | ❌ No | Max 255 chars | Conversation title |

#### Response

**Status Code:** `201 Created`

**Response Body:**
```json
{
  "id": "uuid",
  "project_id": "uuid",
  "title": "string | null",
  "messages": [],
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

**Schema:** `ConversationResponse`

#### Example

**Request:**
```bash
curl -X POST https://api.example.com/api/v1/conversations/ \
  -H "Content-Type: application/json" \
  -H "X-API-Key: my-key" \
  -d '{
    "project_id": "123e4567-e89b-12d3-a456-426614174000",
    "title": "My first conversation"
  }'
```

**Response (201):**
```json
{
  "id": "987fcdeb-51a2-43c1-9876-fedcba098765",
  "project_id": "123e4567-e89b-12d3-a456-426614174000",
  "title": "My first conversation",
  "messages": [],
  "created_at": "2026-02-14T10:30:00Z",
  "updated_at": "2026-02-14T10:30:00Z"
}
```

#### Error Responses

**422 Unprocessable Entity** (validation error):
```json
{
  "detail": [
    {
      "loc": ["body", "project_id"],
      "msg": "value is not a valid uuid",
      "type": "type_error.uuid"
    }
  ]
}
```

---

### GET /conversations/{id}

**Retrieve a conversation by ID**

#### Request

**Method:** `GET`
**Path:** `/api/v1/conversations/{id}`
**Content-Type:** N/A (no body)

**Path Parameters:**

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `id` | UUID | ✅ Yes | Conversation ID |

#### Response

**Status Code:** `200 OK`

**Response Body:**
```json
{
  "id": "uuid",
  "project_id": "uuid",
  "title": "string | null",
  "messages": [
    {
      "id": "uuid",
      "conversation_id": "uuid",
      "role": "USER | ASSISTANT | SYSTEM",
      "content": "string",
      "created_at": "datetime"
    }
  ],
  "created_at": "datetime",
  "updated_at": "datetime"
}
```

**Schema:** `ConversationResponse`

#### Example

**Request:**
```bash
curl -X GET https://api.example.com/api/v1/conversations/987fcdeb-51a2-43c1-9876-fedcba098765 \
  -H "X-API-Key: my-key"
```

**Response (200):**
```json
{
  "id": "987fcdeb-51a2-43c1-9876-fedcba098765",
  "project_id": "123e4567-e89b-12d3-a456-426614174000",
  "title": "My first conversation",
  "messages": [
    {
      "id": "111e1111-e11b-11d1-a111-111111111111",
      "conversation_id": "987fcdeb-51a2-43c1-9876-fedcba098765",
      "role": "USER",
      "content": "Hello, how can I create a REST API?",
      "created_at": "2026-02-14T10:31:00Z"
    },
    {
      "id": "222e2222-e22b-22d2-a222-222222222222",
      "conversation_id": "987fcdeb-51a2-43c1-9876-fedcba098765",
      "role": "ASSISTANT",
      "content": "To create a REST API, you can use FastAPI...",
      "created_at": "2026-02-14T10:31:05Z"
    }
  ],
  "created_at": "2026-02-14T10:30:00Z",
  "updated_at": "2026-02-14T10:31:05Z"
}
```

#### Error Responses

**404 Not Found:**
```json
{
  "detail": "Conversation 987fcdeb-51a2-43c1-9876-fedcba098765 not found"
}
```

---

### GET /conversations/

**List conversations with pagination**

#### Request

**Method:** `GET`
**Path:** `/api/v1/conversations/`
**Content-Type:** N/A (no body)

**Query Parameters:**

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `project_id` | UUID | ❌ No | null | Filter by project |
| `skip` | integer | ❌ No | 0 | Pagination offset |
| `limit` | integer | ❌ No | 100 | Max records to return |

**Constraints:**
- `skip`: ≥0
- `limit`: 1-1000 (max 1000 records per request)

#### Response

**Status Code:** `200 OK`

**Response Body:**
```json
{
  "conversations": [
    {
      "id": "uuid",
      "project_id": "uuid",
      "title": "string | null",
      "messages": [],
      "created_at": "datetime",
      "updated_at": "datetime"
    }
  ],
  "total": "integer",
  "skip": "integer",
  "limit": "integer"
}
```

**Schema:** `ConversationList`

#### Example

**Request (with pagination):**
```bash
curl -X GET "https://api.example.com/api/v1/conversations/?skip=0&limit=10" \
  -H "X-API-Key: my-key"
```

**Response (200):**
```json
{
  "conversations": [
    {
      "id": "987fcdeb-51a2-43c1-9876-fedcba098765",
      "project_id": "123e4567-e89b-12d3-a456-426614174000",
      "title": "My first conversation",
      "messages": [],
      "created_at": "2026-02-14T10:30:00Z",
      "updated_at": "2026-02-14T10:30:00Z"
    },
    {
      "id": "876dcba9-40a1-32b0-8765-edcba9876543",
      "project_id": "123e4567-e89b-12d3-a456-426614174000",
      "title": "Second conversation",
      "messages": [],
      "created_at": "2026-02-14T11:00:00Z",
      "updated_at": "2026-02-14T11:00:00Z"
    }
  ],
  "total": 2,
  "skip": 0,
  "limit": 10
}
```

**Request (filtered by project):**
```bash
curl -X GET "https://api.example.com/api/v1/conversations/?project_id=123e4567-e89b-12d3-a456-426614174000" \
  -H "X-API-Key: my-key"
```

#### Error Responses

**422 Unprocessable Entity** (invalid query param):
```json
{
  "detail": [
    {
      "loc": ["query", "skip"],
      "msg": "ensure this value is greater than or equal to 0",
      "type": "value_error"
    }
  ]
}
```

---

## 📦 Schemas

### ConversationCreate

**Request schema for creating conversations**

```json
{
  "type": "object",
  "properties": {
    "project_id": {
      "type": "string",
      "format": "uuid",
      "description": "Project identifier"
    },
    "title": {
      "type": "string",
      "maxLength": 255,
      "nullable": true,
      "description": "Conversation title"
    }
  },
  "required": ["project_id"]
}
```

---

### ConversationResponse

**Response schema for conversation details**

```json
{
  "type": "object",
  "properties": {
    "id": {
      "type": "string",
      "format": "uuid",
      "description": "Conversation ID"
    },
    "project_id": {
      "type": "string",
      "format": "uuid",
      "description": "Project identifier"
    },
    "title": {
      "type": "string",
      "maxLength": 255,
      "nullable": true,
      "description": "Conversation title"
    },
    "messages": {
      "type": "array",
      "items": {
        "$ref": "#/components/schemas/MessageResponse"
      },
      "description": "List of messages in conversation"
    },
    "created_at": {
      "type": "string",
      "format": "date-time",
      "description": "Creation timestamp (ISO 8601)"
    },
    "updated_at": {
      "type": "string",
      "format": "date-time",
      "description": "Last update timestamp (ISO 8601)"
    }
  },
  "required": ["id", "project_id", "messages", "created_at", "updated_at"]
}
```

---

### MessageResponse

**Response schema for messages**

```json
{
  "type": "object",
  "properties": {
    "id": {
      "type": "string",
      "format": "uuid",
      "description": "Message ID"
    },
    "conversation_id": {
      "type": "string",
      "format": "uuid",
      "description": "Parent conversation ID"
    },
    "role": {
      "type": "string",
      "enum": ["USER", "ASSISTANT", "SYSTEM"],
      "description": "Message sender role"
    },
    "content": {
      "type": "string",
      "maxLength": 5000,
      "description": "Message content"
    },
    "created_at": {
      "type": "string",
      "format": "date-time",
      "description": "Message timestamp (ISO 8601)"
    }
  },
  "required": ["id", "conversation_id", "role", "content", "created_at"]
}
```

---

### ConversationList

**Response schema for paginated conversation list**

```json
{
  "type": "object",
  "properties": {
    "conversations": {
      "type": "array",
      "items": {
        "$ref": "#/components/schemas/ConversationResponse"
      },
      "description": "List of conversations"
    },
    "total": {
      "type": "integer",
      "description": "Total number of conversations (ignores pagination)"
    },
    "skip": {
      "type": "integer",
      "description": "Pagination offset used"
    },
    "limit": {
      "type": "integer",
      "description": "Max records per page"
    }
  },
  "required": ["conversations", "total", "skip", "limit"]
}
```

---

## ❌ Error Responses

### Standard Error Format

All errors follow FastAPI's standard format:

```json
{
  "detail": "string | object"
}
```

### HTTP Status Codes

| Code | Description | When Used |
|------|-------------|-----------|
| **200 OK** | Success | GET requests |
| **201 Created** | Resource created | POST requests |
| **400 Bad Request** | Invalid request | Malformed JSON |
| **401 Unauthorized** | Missing/invalid API key | Authentication failure |
| **404 Not Found** | Resource not found | Invalid ID |
| **422 Unprocessable Entity** | Validation error | Pydantic validation failure |
| **500 Internal Server Error** | Server error | Database connection failure |

---

## 📘 Examples

### Example 1: Create → Retrieve → List Flow

**Step 1: Create conversation**
```bash
curl -X POST https://api.example.com/api/v1/conversations/ \
  -H "Content-Type: application/json" \
  -H "X-API-Key: my-key" \
  -d '{"project_id": "123e4567-e89b-12d3-a456-426614174000", "title": "Test"}'
```

**Response:**
```json
{
  "id": "abc12345-6789-0abc-def1-234567890abc",
  "project_id": "123e4567-e89b-12d3-a456-426614174000",
  "title": "Test",
  "messages": [],
  "created_at": "2026-02-14T12:00:00Z",
  "updated_at": "2026-02-14T12:00:00Z"
}
```

**Step 2: Retrieve conversation**
```bash
curl -X GET https://api.example.com/api/v1/conversations/abc12345-6789-0abc-def1-234567890abc \
  -H "X-API-Key: my-key"
```

**Response:**
```json
{
  "id": "abc12345-6789-0abc-def1-234567890abc",
  "project_id": "123e4567-e89b-12d3-a456-426614174000",
  "title": "Test",
  "messages": [],
  "created_at": "2026-02-14T12:00:00Z",
  "updated_at": "2026-02-14T12:00:00Z"
}
```

**Step 3: List all conversations**
```bash
curl -X GET https://api.example.com/api/v1/conversations/ \
  -H "X-API-Key: my-key"
```

**Response:**
```json
{
  "conversations": [
    {
      "id": "abc12345-6789-0abc-def1-234567890abc",
      "project_id": "123e4567-e89b-12d3-a456-426614174000",
      "title": "Test",
      "messages": [],
      "created_at": "2026-02-14T12:00:00Z",
      "updated_at": "2026-02-14T12:00:00Z"
    }
  ],
  "total": 1,
  "skip": 0,
  "limit": 100
}
```

---

### Example 2: Pagination

**Page 1 (records 0-9):**
```bash
curl -X GET "https://api.example.com/api/v1/conversations/?skip=0&limit=10" \
  -H "X-API-Key: my-key"
```

**Page 2 (records 10-19):**
```bash
curl -X GET "https://api.example.com/api/v1/conversations/?skip=10&limit=10" \
  -H "X-API-Key: my-key"
```

**Page 3 (records 20-29):**
```bash
curl -X GET "https://api.example.com/api/v1/conversations/?skip=20&limit=10" \
  -H "X-API-Key: my-key"
```

---

### Example 3: Error Handling

**Invalid UUID:**
```bash
curl -X POST https://api.example.com/api/v1/conversations/ \
  -H "Content-Type: application/json" \
  -H "X-API-Key: my-key" \
  -d '{"project_id": "not-a-uuid", "title": "Test"}'
```

**Response (422):**
```json
{
  "detail": [
    {
      "loc": ["body", "project_id"],
      "msg": "value is not a valid uuid",
      "type": "type_error.uuid"
    }
  ]
}
```

**Nonexistent conversation:**
```bash
curl -X GET https://api.example.com/api/v1/conversations/00000000-0000-0000-0000-000000000000 \
  -H "X-API-Key: my-key"
```

**Response (404):**
```json
{
  "detail": "Conversation 00000000-0000-0000-0000-000000000000 not found"
}
```

---

## 🔗 Related Documentation

- **OpenAPI Spec:** `/api/v1/openapi.json` (auto-generated by FastAPI)
- **Swagger UI:** `/docs` (interactive API documentation)
- **ReDoc:** `/redoc` (alternative documentation view)
- **Security Audit:** [SECURITY_AUDIT.md](./SECURITY_AUDIT.md)
- **Test Coverage:** [COVERAGE_REPORT.md](./COVERAGE_REPORT.md)

---

## ✅ Contract Validation

All endpoints tested with:
- ✅ Integration tests (5 scenarios)
- ✅ Pydantic schema validation
- ✅ OpenAPI spec compliance
- ✅ HTTP method correctness
- ✅ Status code accuracy

**Contract Status:** ✅ **VERIFIED**

---

*API Contract v1.0.0 - Generated 2026-02-14*
*OpenAPI 3.1.0 - FastAPI auto-documentation*
