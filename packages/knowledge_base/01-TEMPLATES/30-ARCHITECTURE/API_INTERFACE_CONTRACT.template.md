# 🔌 API Interface Contract

Contrato de comunicación para **{{PROJECT_NAME}}**.
**Protocolo:** {{PROTOCOL}} (REST / GraphQL / gRPC).
**Base URL:** `/api/v1`
**Auth Standard:** Bearer Token (JWT).

## 1. Endpoints Públicos (Public)

### Auth
* `POST /auth/login`
    * **Input:** `LoginRequest` (email, password).
    * **Output:** `TokenResponse` (access_token, refresh_token).
* `POST /auth/register`
    * **Input:** `RegisterRequest`.

## 2. Endpoints Privados (Protected)
*Requiere Header:* `Authorization: Bearer <token>`

### Recurso: {{RESOURCE_NAME_1}} (Ej: Users)
* `GET /{{RESOURCE_PLURAL}}` - Listar (Paginado).
* `POST /{{RESOURCE_PLURAL}}` - Crear nuevo.
* `GET /{{RESOURCE_PLURAL}}/{id}` - Detalle.
* `PATCH /{{RESOURCE_PLURAL}}/{id}` - Actualización parcial.

### Recurso: {{RESOURCE_NAME_2}}
* `GET /{{RESOURCE_2_PLURAL}}` - Listar.
* `POST /{{RESOURCE_2_PLURAL}}` - Crear.

## 3. Modelos de Datos (DTOs)

#### `{{DTO_NAME}}`
```json
{
  "id": "uuid",
  "name": "string",
  "created_at": "iso8601",
  "status": "enum(active, inactive)"
}
```
