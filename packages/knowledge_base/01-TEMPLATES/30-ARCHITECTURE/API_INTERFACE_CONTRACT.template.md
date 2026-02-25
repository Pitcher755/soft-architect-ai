# 📡 API Interface Contract

<!-- ════════════════════════════════════════════════════════════════════════════════
📘 TEMPLATE GUIDE: How to Fill Out This Document
════════════════════════════════════════════════════════════════════════════════

PURPOSE:
This document is THE CONTRACT between clients (Frontend/Mobile) and servers (Backend).
It defines all API endpoints, methods, and request/response schemas. It prevents breaking changes and allows parallel development.

WHEN TO CREATE:
- **Generation Order:** 10/24 (Phase 3 - ARCHITECTURE)
- **Phase:** 3 - ARCHITECTURE
- **Prerequisites:** 30-ARCHITECTURE/DATA_MODEL_SCHEMA.md MUST be complete.

BEST PRACTICES & AI INSTRUCTIONS:
✅ **NO HALLUCINATIONS:** Only document endpoints that are strictly necessary for the User Stories defined in the REQUIREMENTS Phase. Do not invent unnecessary CRUD operations.
✅ **BE PRECISE:** Always specify exact HTTP methods, path parameters (e.g., /users/{id}), and expected HTTP Status Codes for both success and error states.
✅ **USE EXAMPLES AS GUIDES:** Read the hidden HTML comments () for context, but do not copy them verbatim.
✅ **REPLACE VARIABLES:** Swap all {{PLACEHOLDERS}} with actual project data.
✅ **SELF-DESTRUCT:** You MUST remove this entire TEMPLATE GUIDE comment block before outputting the final Markdown.

⚠️ **CRITICAL ROUTING:**
   This file MUST be saved in the 30-ARCHITECTURE directory.
   Filename MUST be: API_INTERFACE_CONTRACT.md
   Correct path: /context/30-ARCHITECTURE/API_INTERFACE_CONTRACT.md
   Incorrect path: /context/API_INTERFACE_CONTRACT.md or /API_INTERFACE_CONTRACT.md
════════════════════════════════════════════════════════════════════════════════ -->

> **API Version:** {{API_VERSION}}
> **Base URL:** {{BASE_URL}}
> **Documentation:** {{SWAGGER_URL}}
> **Status:** {{STATUS}}

---

## 📖 Table of Contents

- [Versioning Strategy](#versioning-strategy)
- [Authentication](#authentication)
- [Error Handling](#error-handling)
- [Endpoints](#endpoints)

---

## 🔄 Versioning Strategy

**Approach:** {{VERSIONING_STRATEGY}}
<!-- e.g., "URI Versioning (v1, v2)" OR "Header-based (Accept: application/vnd.api+json;version=1)" -->

**Breaking Change Policy:**

- ✅ **Safe:** Add new endpoints, add optional parameters
- ❌ **Breaking:** Remove endpoints, rename fields, change types

**Deprecation Process:**

1. Mark endpoint `@deprecated` in Swagger
2. Add `Sunset` header (RFC 8594) with removal date
3. Support both versions for {{DEPRECATION_PERIOD}}
<!-- e.g., "3 months" -->
4. Remove old version

---

## 🔑 Authentication

**Method:** {{AUTH_METHOD}}
<!-- e.g., "Bearer JWT" OR "API Key Header" -->

**Header:**

```http
Authorization: Bearer {JWT_TOKEN}
```

**Token Expiry:** {{TOKEN_EXPIRY}}  <!-- e.g., "30 minutes (access), 7 days (refresh)" -->

---

## 🚨 Error Handling

**Standard Error Response:**

```json
{
  "error": {
    "code": "{{ERROR_CODE}}",
    "message": "{{ERROR_MESSAGE}}",
    "details": {
      "field": "{{FIELD_NAME}}",
      "reason": "{{REASON}}"
    },
    "request_id": "{{REQUEST_ID}}",
    "timestamp": "{{ISO_8601}}"
  }
}
```

**HTTP Status Codes:**

| Code | Meaning | When to Use |
|------|---------|-------------|
| 200 OK | Success (read) | GET requests |
| 201 Created | Success (create) | POST requests |
| 204 No Content | Success (delete) | DELETE requests |
| 400 Bad Request | Invalid input | Validation errors |
| 401 Unauthorized | Missing/invalid token | Authentication failure |
| 403 Forbidden | Valid token, no permission | Authorization failure |
| 404 Not Found | Resource doesn't exist | Unknown ID |
| 429 Too Many Requests | Rate limit exceeded | >100 req/min |
| 500 Internal Server Error | Server crash | Unhandled exceptions |

---

## 🛣️ Endpoints

### 1. {{ENDPOINT_1_NAME}}

**Method:** `{{HTTP_METHOD_1}}`
**Path:** `{{ENDPOINT_1_PATH}}`
**Description:** {{ENDPOINT_1_DESC}}

**Request:**

```json
{
  "{{REQUEST_FIELD_1}}": "{{REQUEST_VALUE_1}}",
  "{{REQUEST_FIELD_2}}": {{REQUEST_VALUE_2}}
}
```

**Response (200 OK):**

```json
{
  "{{RESPONSE_FIELD_1}}": "{{RESPONSE_VALUE_1}}",
  "{{RESPONSE_FIELD_2}}": {{RESPONSE_VALUE_2}}
}
```

**Example:**

```bash
curl -X {{HTTP_METHOD_1}} {{BASE_URL}}{{ENDPOINT_1_PATH}} \
  -H "Authorization: Bearer {token}" \
  -H "Content-Type: application/json" \
  -d '{{REQUEST_EXAMPLE}}'
```

<!-- FULL EXAMPLE:

### 1. Create Project

**Method:** `POST`
**Path:** `/api/v1/projects`
**Description:** Create a new software project

**Request:**

```json
{
  "name": "MyApp",
  "tech_stack": "Flutter + Python",
  "description": "A RAG-powered AI assistant"
}
```

**Response (201 Created):**

```json
{
  "id": "proj_abc123",
  "name": "MyApp",
  "created_at": "2024-02-22T10:30:00Z",
  "status": "active"
}
```

**Example:**

```bash
curl -X POST https://api.example.com/api/v1/projects \
  -H "Authorization: Bearer eyJhbGc..." \
  -H "Content-Type: application/json" \
  -d '{"name": "MyApp", "tech_stack": "Flutter + Python"}'
```

**Errors:**

- 400: Name already exists
- 401: Invalid token
- 422: Missing required field "tech_stack"
-->

---

### 2. {{ENDPOINT_2_NAME}}

<!-- Repeat structure above for each endpoint -->

---

## 📊 Request/Response Schemas

### {{SCHEMA_1_NAME}}

```json
{
  "{{FIELD_1}}": "{{TYPE_1}}",  // {{DESCRIPTION_1}}
  "{{FIELD_2}}": {{TYPE_2}},    // {{DESCRIPTION_2}}
  "{{FIELD_3}}": [              // {{DESCRIPTION_3}}
    {
      "{{NESTED_FIELD}}": "{{NESTED_TYPE}}"
    }
  ]
}
```

<!-- EXAMPLE:

### Project Schema

```json
{
  "id": "string",              // Unique identifier (UUID)
  "name": "string",            // Max 100 chars
  "tech_stack": "string",      // Comma-separated (e.g., "Flutter,Python")
  "status": "enum",            // active, archived, deleted
  "created_at": "ISO 8601",    // UTC timestamp
  "documents": [               // Generated documents
    {
      "doc_id": "string",
      "title": "string",
      "status": "enum"         // pending, complete, error
    }
  ]
}
```
-->

---

## 🔒 Rate Limiting

**Limits:**

| Plan | Requests/Minute | Requests/Day |
|------|-----------------|--------------|
| Free | {{FREE_LIMIT_MIN}} | {{FREE_LIMIT_DAY}} |
| Pro | {{PRO_LIMIT_MIN}} | {{PRO_LIMIT_DAY}} |

**Headers:**

```http
X-RateLimit-Limit: 100
X-RateLimit-Remaining: 87
X-RateLimit-Reset: 1677074400
```

---

## 🔗 Related Documents

- [DATA_MODEL_SCHEMA.md](DATA_MODEL_SCHEMA.md) - Database schemas
- [SECURITY_THREAT_MODEL.md](SECURITY_THREAT_MODEL.md) - API security
- [TESTING_STRATEGY.md](../40-PLANNING/TESTING_STRATEGY.md) - API tests
