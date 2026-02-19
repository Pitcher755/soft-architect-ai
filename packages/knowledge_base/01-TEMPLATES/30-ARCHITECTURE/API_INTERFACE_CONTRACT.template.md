# 🔌 API Interface Contract

Communication contract for **{{PROJECT_NAME}}**.
**Protocol:** {{PROTOCOL}} (REST / GraphQL / gRPC).
**Base URL:** `/api/v1`
**Auth Standard:** Bearer Token (JWT).

## 1. Public Endpoints

### Auth
* `POST /auth/login`
    * **Input:** `LoginRequest` (email, password).
    * **Output:** `TokenResponse` (access_token, refresh_token).
* `POST /auth/register`
    * **Input:** `RegisterRequest`.

## 2. Protected Endpoints
*Requires Header:* `Authorization: Bearer <token>`

### Resource: {{RESOURCE_NAME_1}} (e.g., Users)
* `GET /{{RESOURCE_PLURAL}}` - List (Paginated).
* `POST /{{RESOURCE_PLURAL}}` - Create new.
* `GET /{{RESOURCE_PLURAL}}/{id}` - Detail.
* `PATCH /{{RESOURCE_PLURAL}}/{id}` - Partial update.

### Resource: {{RESOURCE_NAME_2}}
* `GET /{{RESOURCE_2_PLURAL}}` - List.
* `POST /{{RESOURCE_2_PLURAL}}` - Create.

## 3. Data Models (DTOs)

#### `{{DTO_NAME}}`
```json
{
  "id": "uuid",
  "name": "string",
  "created_at": "iso8601",
  "status": "enum(active, inactive)"
}
```
