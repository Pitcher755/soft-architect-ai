# 📝 HU-4.4: RECENT CHANGES - Fase 6 & 7

> **User Story:** HU-4.4 - RAG/LLM Resiliencia Extensions
> **Branch:** `feature/rag-llm-resilience` (merged to `develop`)
> **Estado:** ✅ **COMPLETE**
> **Fecha:** January 2025
> **Commits:** 01eec76 (Fase 6), 3786589 (Fase 7)

---

<div align="center">

[🇬🇧 English](#english) | [🇪🇸 Español](#español)

</div>

---

<div id="español">

## 📖 Tabla de Contenidos

1. [Resumen Ejecutivo](#-resumen-ejecutivo)
2. [Fase 6: Soporte de Historial de Chat](#-fase-6-soporte-de-historial-de-chat-backend)
3. [Fase 7: Límites Configurables](#-fase-7-límites-configurables)
4. [Tabla de Comparación Antes/Después](#-tabla-de-comparación-antesdespués)
5. [Guía de Migración](#-guía-de-migración)
6. [Ejemplos de Configuración](#-ejemplos-de-configuración)

---

## 🎯 Resumen Ejecutivo

**Objetivo:** Documentoar las mejoras implementadas después de los 4 GAPS críticos de resilience, enfocándose en **contexto conversacional** y **configurabilidad dinámica**.

### Cambios Principales

| Fase | Feature | Impact | Commit |
|-------|---------|--------|--------|
| **Fase 6** | Chat History Support (Backend) | Memoria conversacional en LLM | 01eec76 |
| **Fase 7** | Configurable Chat Limits | 5x más contexto, tuneable sin recompilar | 3786589 |

**Beneficios Clave:**
- 🧠 **Contexto Conversacional:** El LLM recuerda las interacciones previas (memoria a corto plazo).
- ⚙️ **Configurabilidad:** Ajustar límites sin recompilación ni despliegue.
- 📈 **Escalabilidad:** Proyectos grandes (25+ documentoos) ahora soportados con 100 mensajes de historial.
- 🚀 **Rendimiento:** Frontend carga y envía últimos 100 mensajes automáticamente.

---

## 🧠 Fase 6: Soporte de Historial de Chat (Backend)

> **Commit:** `01eec76`
> **Fecha:** Enero 2025
> **Estado:** ✅ Complete

### 6.1 Descripción

Implementación de **memoria conversacional** en el backend para que el LLM tenga contexto de mensajes previos en una sesión.

### 6.2 Cambios Técnicos

#### Backend Schema (`chat.py`)

**Archivo:** `src/server/app/domain/schemas/chat.py`

**Cambio Principal:** Campo opcional `history` en `ChatRequest`

```python
class ChatRequest(BaseModel):
    message: str
    project_id: str
    conversation_id: str | None = None
    history: list[dict[str, str]] = Field(
        default_factory=list,
        description="Chat history for conversational context"
    )

    @model_validator(mode="after")
    def validate_history(self) -> Self:
        """Validate chat history format and sanitize content."""
        if not self.history:
            return self

        # Validation rules (Phase 6 - hardcoded limits):
        # - Max 20 messages (10 user + 10 assistant pairs)
        # - Valid roles: 'user' or 'assistant'
        # - Max 5000 chars per message
        # - XSS sanitization via InputSanitizer

        if len(self.history) > 20:
            raise ValueError("Chat history exceeds maximum length (20 messages)...")

        for i, msg in enumerate(self.history):
            role = msg.get("role")
            content = msg.get("content")

            if role not in ("user", "assistant"):
                raise ValueError(f"Invalid role: {role}. Must be 'user' or 'assistant'.")

            if len(content) > 5000:
                raise ValueError(f"Message {i} content exceeds 5000 characters...")

            # Sanitize content
            msg["content"] = InputSanitizer.sanitize_message(content)

        return self
```

**Características:**
- ✅ Campo opcional (backward compatible)
- ✅ Validación de roles (`user` / `assistant`)
- ✅ Límites de tamaño (20 mensajes, 5000 chars/mensaje) - **hardcoded en Fase 6**
- ✅ Sanitización XSS en contenido

#### Template Builder (`dependencies.py`)

**Archivo:** `src/server/app/api/dependencies.py`

**Cambio:** Método `build_prompt()` ahora acepta parámetro `history`

```python
class MVPTemplateBuilder:
    def build_prompt(
        self,
        query: str,
        context: list[dict[str, Any]],
        template_id: str,
        history: list[dict[str, str]] | None = None,  # ✅ NEW
    ) -> str:
        """Build a prompt from template with history support."""
        system_msg = templates[template_id]["system"]

        # Format chat history (if provided)
        history_section = ""
        if history:
            history_section = "\n\nConversation History:\n"
            for msg in history:
                role = msg["role"].capitalize()  # User / Assistant
                content = msg["content"]
                history_section += f"{role}: {content}\n"

        # Format context (RAG sources)
        context_section = "\n\nContext:\n"
        for idx, doc in enumerate(context, start=1):
            context_section += f"[{idx}] {doc['content']}\n"

        # Assemble final prompt
        prompt = f"{system_msg}{history_section}{context_section}\n\nUser Query: {query}"
        return prompt
```

**Estructura del Prompt:**
```
System Message
  ↓
Conversation History (if provided)
  User: Previous question 1
  Assistant: Previous answer 1
  ...
  ↓
Context (RAG sources)
  [1] Document chunk 1
  [2] Document chunk 2
  ...
  ↓
User Query: Current question
```

#### Orchestrator Integración (`orchestrator.py`)

**Archivo:** `src/server/app/services/rag/orchestrator.py`

**Cambio:** Pasar `history` al template builder

```python
async def process_message(self, request: ChatRequest) -> ChatResponse:
    """Process a chat message through the RAG pipeline."""
    # ... vector search logic ...

    prompt = self.template_builder.build_prompt(
        query=request.message,
        context=sources,
        template_id=template_id,
        history=request.history,  # ✅ NEW: Pass history to template
    )

    ai_response = await self.llm_client.generate(prompt)
    # ...

async def process_message_stream(...) -> AsyncGenerator[dict[str, Any], None]:
    """Process streaming with history support."""
    # ... vector search logic ...

    prompt = self.template_builder.build_prompt(
        query=request.message,
        context=sources,
        template_id=template_id,
        history=request.history,  # ✅ NEW: Pass history to template
    )

    async for token in self.llm_client.stream_generate(prompt):
        yield {"type": "data", "content": token}
    # ...
```

### 6.3 Pruebas Creados (21 pruebas)

**Archivos de Prueba:**
- `pruebas/server/unit/domain/schemas/prueba_chat_history.py` (9 pruebas)
- `pruebas/server/unit/api/prueba_template_builder_history.py` (7 pruebas)
- `pruebas/server/integration/api/v1/prueba_chat_history_integration.py` (5 pruebas)

**Cobertura de Pruebas:**
1. ✅ Accept valid history
2. ✅ Default to empty history
3. ✅ Reject >20 messages
4. ✅ Reject invalid roles
5. ✅ Reject missing content field
6. ✅ Sanitize XSS in history content
7. ✅ Reject oversized message (>5000 chars)
8. ✅ Validate message type
9. ✅ Validate content is string
10. ✅ Template builder formats history correctly
11. ✅ Integración endpoint accepts history
12. ✅ Integración endpoint rejects invalid history

### 6.4 Limitaciones de Fase 6

**Restricciones Hardcoded:**
- ❌ Max 20 mensajes (límite pequeño para proyectos grandes)
- ❌ Max 5000 chars/mensaje (el modelo soporta 32K tokens)
- ❌ **Frontend NO enviaba historial** (backend listo pero no utilizado)

**Estas limitaciones se resuelven en Fase 7.**

---

## ⚙️ Fase 7: Límites Configurables

> **Commit:** `3786589`
> **Fecha:** Enero 2025
> **Estado:** ✅ Complete

### 7.1 Descripción

Conversión de límites hardcoded en **configurables vía environment variables**, permitiendo ajuste dinámico sin recompilar. Además, **integración completa del frontend** para enviar historial.

### 7.2 Cambios Técnicos

#### Backend Configuración (`config.py`)

**Archivo:** `src/server/app/core/config.py`

**Cambio:** Nuevos campos en `Settings` class

```python
class Settings(BaseSettings):
    """Application settings loaded from environment."""

    # ... existing fields ...

    # Chat History Configuration (NEW - Phase 7)
    CHAT_MAX_HISTORY_MESSAGES: int = 100  # Max messages (50 user + 50 assistant)
    CHAT_MAX_MESSAGE_LENGTH: int = 20000  # Max chars per message (model supports 32K)

    # ... rest of settings ...
```

**Defaults:**
- `CHAT_MAX_HISTORY_MESSAGES`: **100** (5x más que Fase 6)
- `CHAT_MAX_MESSAGE_LENGTH`: **20000** (4x más que Fase 6)

#### Dynamic Validation (`chat.py`)

**Archivo:** `src/server/app/domain/schemas/chat.py`

**Cambio:** Validadores leen de `settings` en lugar de hardcoded values

```python
from app.core.config import settings  # ✅ NEW import

class ChatRequest(BaseModel):
    message: str = Field(
        ...,
        max_length=32000,  # Pydantic max, dynamic limit in validator
        description=f"User message (max {settings.CHAT_MAX_MESSAGE_LENGTH} chars, configurable)",
    )

    @field_validator("message")
    @classmethod
    def sanitize_message(cls, v: str) -> str:
        """Sanitize and validate message length."""
        # ✅ Dynamic limit check
        if len(v) > settings.CHAT_MAX_MESSAGE_LENGTH:
            raise ValueError(
                f"Message exceeds maximum length of {settings.CHAT_MAX_MESSAGE_LENGTH} characters "
                f"(got {len(v)}). Adjust CHAT_MAX_MESSAGE_LENGTH env var if needed."
            )
        return InputSanitizer.sanitize_message(v)

    @model_validator(mode="after")
    def validate_history(self) -> Self:
        """Validate chat history with dynamic limits."""
        if not self.history:
            return self

        # ✅ Read max from settings (not hardcoded)
        max_messages = settings.CHAT_MAX_HISTORY_MESSAGES
        if len(self.history) > max_messages:
            raise ValueError(
                f"Chat history exceeds maximum length ({max_messages} messages). "
                "Adjust CHAT_MAX_HISTORY_MESSAGES env var if needed."
            )

        # ✅ Read max length from settings
        max_length = settings.CHAT_MAX_MESSAGE_LENGTH
        for i, msg in enumerate(self.history):
            content = msg.get("content", "")
            if len(content) > max_length:
                raise ValueError(
                    f"Message {i} content exceeds {max_length} characters (got {len(content)}). "
                    "Adjust CHAT_MAX_MESSAGE_LENGTH env var if needed."
                )
            # ... rest of validation ...

        return self
```

**Características:**
- ✅ Límites leídos dinámicamente de `settings`
- ✅ Mensajes de error incluyen límite configurado
- ✅ Sugerencia de ajustar env var en mensajes de validación

#### Frontend History Loading (`chat_repository_impl.dart`)

**Archivo:** `src/client/lib/features/chat/data/repositories/chat_repository_impl.dart`

**Cambio:** Cargar historial desde SQLite y enviar al backend

**ANTES (Fase 6):**
```dart
@override
Stream<ChatStreamEvent> sendMessageStream(String message, String projectId) {
  final body = {
    'message': message,
    'project_id': projectId,
    'conversation_id': _generateConversationId(),
    // ❌ NO history field
  };
  return sseClient.connect(url, body, headers: headers);
}
```

**DESPUÉS (Fase 7):**
```dart
@override
Stream<ChatStreamEvent> sendMessageStream(
  String message,
  String projectId,
) async* {  // ✅ Changed to async* generator
  final url = '$baseUrl/api/v1/chat/stream';

  // ✅ Load chat history from SQLite to provide conversational context
  var historyPayload = <Map<String, String>>[];
  try {
    final chatHistory = await getChatHistory(projectId);

    // Limit to last 100 messages (50 user + 50 assistant pairs)
    const maxHistoryMessages = 100;
    final limitedHistory = chatHistory.length > maxHistoryMessages
        ? chatHistory.sublist(chatHistory.length - maxHistoryMessages)
        : chatHistory;

    // Transform ChatMessage entities to backend format: {role, content}
    historyPayload = limitedHistory
        .map((msg) => {
              'role': msg.role.name, // 'user' or 'assistant'
              'content': msg.content,
            })
        .toList();

    print('📤 Sending ${historyPayload.length} history messages to backend');
  } on Exception catch (e) {
    print('⚠️ Failed to load chat history: $e. Sending without context.');
    // Continue without history if loading fails (graceful degradation)
  }

  final body = {
    'message': message,
    'project_id': projectId,
    'conversation_id': _generateConversationId(),
    'history': historyPayload, // ✅ NEW: Include chat history
  };
  final headers = {'X-API-Key': apiKey};

  try {
    yield* sseClient.connect(url, body, headers: headers);
  } on SseException catch (e) {
    yield ErrorEvent(message: 'Connection error: ${e.message}');
  }
}
```

**Características:**
- ✅ Carga historial desde SQLite antes de enviar
- ✅ Limita a últimos 100 mensajes (configurable en código)
- ✅ Transforma `ChatMessage` entities → `{role: string, content: string}`
- ✅ Envía `history` field en request body
- ✅ Graceful degradation: Si falla carga, envía sin contexto

#### Configuración Archivos

##### 1. Environment Variables (`.env.example`)

**Archivo:** `src/server/.env.example`

```bash
# ─────────────────────────────────────────────────────────────
# CHAT HISTORY CONFIGURATION
# ─────────────────────────────────────────────────────────────
# Máximo de mensajes en el historial conversacional
# Para proyectos grandes (25+ documentos), se recomienda 100+
# Default: 100 (50 user + 50 assistant)
CHAT_MAX_HISTORY_MESSAGES=100

# Máximo de caracteres por mensaje
# El modelo soporta 32K tokens (~32000 chars)
# Se recomienda 20000 para documentos extensos
# Default: 20000
CHAT_MAX_MESSAGE_LENGTH=20000
```

##### 2. Docker Compose (`docker-compose.yml`)

**Archivo:** `infrastructure/docker-compose.yml`

```yaml
services:
  backend:
    # ... existing config ...
    environment:
      # Chat Memory Configuration (NEW)
      - CHAT_MAX_HISTORY_MESSAGES=${CHAT_MAX_HISTORY_MESSAGES:-100}
      - CHAT_MAX_MESSAGE_LENGTH=${CHAT_MAX_MESSAGE_LENGTH:-20000}
```

**Características:**
- ✅ Defaults aplicados con sintaxis `${VAR:-default}`
- ✅ Env vars mapeadas desde host → container

### 7.3 Pruebas Actualizados (17 pruebas)

**Archivos Modificados:**
- `pruebas/server/unit/domain/schemas/prueba_chat_history.py` (9 pruebas actualizados)
- `pruebas/server/integration/api/v1/prueba_chat_history_integration.py` (4 pruebas actualizados)

**Cambios en Pruebas:**
- ✅ `prueba_chat_request_rejects_history_exceeding_20_messages` → Ahora usa 101 mensajes (excede default 100)
- ✅ `prueba_chat_request_rejects_oversized_message_in_history` → Ahora usa 20001 chars (excede default 20000)
- ✅ Docstrings actualizados: mencionan "default config"

**Resultadoado:** ✅ 13 unit pruebas + 4 integration pruebas = **17/17 passing**

### 7.4 Impacto de Fase 7

**Mejoras Cuantitativas:**
- 📈 **5x más mensajes:** 20 → 100 (capacidad para conversaciones extensas)
- 📈 **4x más caracteres:** 5000 → 20000 (soporte para documentoos largos)
- ⚙️ **Configuración sin downtime:** Cambiar `.env` y restart (no recompilación)
- 🚀 **Frontend integrado:** Historial enviado automáticamente en cada request

**Mejoras Cualitativas:**
- ✅ Proyectos grandes (25+ documentoos) ahora viables
- ✅ Tuning sin conocimientos de programación (solo editar `.env`)
- ✅ Graceful degradation en frontend (continúa si SQLite falla)
- ✅ Mensajes de error informativos (incluyen límite actual)

---

## 📊 Tabla de Comparación Antes/Después

| Feature | Before Fase 6 | Fase 6 (Hardcoded) | Fase 7 (Configurable) |
|---------|----------------|---------------------|------------------------|
| **Backend Chat History** | ❌ No soportado | ✅ Soportado | ✅ Soportado |
| **Max Messages** | N/A | 20 (hardcoded) | 100 (configurable) |
| **Max Chars/Message** | 30000 (mensaje actual) | 5000 (historial, hardcoded) | 20000 (configurable) |
| **Frontend Sends History** | ❌ No | ❌ No | ✅ Sí (últimos 100) |
| **Configuración Method** | N/A | Recompilación | `.env` / Docker env vars |
| **Prompt Structure** | System → Context → Query | System → History → Context → Query | System → History → Context → Query |
| **Pruebas** | N/A | +21 pruebas | +17 pruebas actualizados |
| **Graceful Degradation** | N/A | Backend solo | Backend + Frontend |
| **Use Case Viability** | Proyectos pequeños | Proyectos medianos | Proyectos grandes (25+ docs) |

**Resumen:**
- Fase 6: Fundación (backend ready, frontend no integrado)
- Fase 7: Producción (configuración dinámica, frontend integrado)

---

## 🚀 Guía de Migración

### Para Deployments Existentes

#### Escenario 1: Sin Action Requerida (Defaults Funcionan)

**Condición:** Proyectos típicos (<25 documentoos, mensajes <20K chars)

**Action:** Ninguna. Los defaults (100 mensajes, 20000 chars) son adecuados.

```bash
# No changes needed, just deploy
docker-compose up -d
```

#### Escenario 2: Proyectos Grandes (25+ Documentoos)

**Condición:** Necesitas más contexto conversacional

**Action:** Incrementar `CHAT_MAX_HISTORY_MESSAGES`

```bash
# Method 1: Edit .env file
echo "CHAT_MAX_HISTORY_MESSAGES=150" >> .env
docker-compose down && docker-compose up -d

# Method 2: Export environment variable
export CHAT_MAX_HISTORY_MESSAGES=150
docker-compose up -d
```

#### Escenario 3: Documentoos Extensos

**Condición:** Mensajes típicos >20K caracteres (ej. pegar código completo)

**Action:** Incrementar `CHAT_MAX_MESSAGE_LENGTH`

```bash
# Edit .env
echo "CHAT_MAX_MESSAGE_LENGTH=25000" >> .env
docker-compose restart backend
```

#### Escenario 4: Restricciones de RAM

**Condición:** Servidor con poca RAM (<8GB)

**Action:** Reducir límites para ahorrar memoria

```bash
# Reduce both limits
echo "CHAT_MAX_HISTORY_MESSAGES=50" >> .env
echo "CHAT_MAX_MESSAGE_LENGTH=10000" >> .env
docker-compose restart backend
```

### Verificación Post-Migración

```bash
# 1. Verificar que backend carga env vars
docker-compose exec backend env | grep CHAT_MAX

# Expected output:
# CHAT_MAX_HISTORY_MESSAGES=100
# CHAT_MAX_MESSAGE_LENGTH=20000

# 2. Test validation endpoint (should reject 101 messages)
curl -X POST http://localhost:8000/api/v1/chat/stream \
  -H "X-API-Key: your-key" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Test",
    "project_id": "test-project",
    "history": [/* 101 messages */]
  }'

# Expected: 400 Bad Request with error message mentioning limit

# 3. Check Flutter logs (should show history sent)
# Open app, send message, check console:
# "📤 Sending X history messages to backend"
```

---

## 🔧 Ejemplos de Configuración

### Development (Local `.env`)

**Archivo:** `src/server/.env`

```bash
# Development: Relaxed limits for testing
CHAT_MAX_HISTORY_MESSAGES=200
CHAT_MAX_MESSAGE_LENGTH=30000

# Other dev settings...
LOG_LEVEL=DEBUG
```

**Restart:**
```bash
cd src/server
source venv/bin/activate
uvicorn app.main:app --reload
```

### Docker Compose (Staging)

**Archivo:** `infrastructure/docker-compose.yml`

```yaml
services:
  backend:
    environment:
      # Staging: Moderate limits
      - CHAT_MAX_HISTORY_MESSAGES=150
      - CHAT_MAX_MESSAGE_LENGTH=20000
      - LOG_LEVEL=INFO
```

**Deploy:**
```bash
docker-compose -f infrastructure/docker-compose.yml up -d
```

### Production (Environment Variables)

**Opción 1: Systemd Service Archivo**

```ini
# /etc/systemd/system/softarchitect-backend.service
[Service]
Environment="CHAT_MAX_HISTORY_MESSAGES=100"
Environment="CHAT_MAX_MESSAGE_LENGTH=20000"
ExecStart=/usr/local/bin/uvicorn app.main:app --host 0.0.0.0
```

**Opción 2: Docker Swarm Secrets**

```yaml
# docker-compose.prod.yml
services:
  backend:
    environment:
      - CHAT_MAX_HISTORY_MESSAGES=${CHAT_MAX_HISTORY_MESSAGES}
      - CHAT_MAX_MESSAGE_LENGTH=${CHAT_MAX_MESSAGE_LENGTH}
    secrets:
      - chat_config
```

**Opción 3: Kubernetes ConfigMap**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: backend-config
data:
  CHAT_MAX_HISTORY_MESSAGES: "100"
  CHAT_MAX_MESSAGE_LENGTH: "20000"
```

### Performance Tuning Examples

#### High-Volume Production (Low Latency Priority)

```bash
# Reduce context to minimize LLM processing time
CHAT_MAX_HISTORY_MESSAGES=50
CHAT_MAX_MESSAGE_LENGTH=10000
```

#### Research/Documentoation Proyectos (High Context Priority)

```bash
# Maximize context for deep technical discussions
CHAT_MAX_HISTORY_MESSAGES=200
CHAT_MAX_MESSAGE_LENGTH=30000
```

#### RAM-Constrained Environments (VPS <4GB)

```bash
# Conservative limits to avoid OOM
CHAT_MAX_HISTORY_MESSAGES=30
CHAT_MAX_MESSAGE_LENGTH=8000
```

---

## 🔍 Pruebaing & Validation

### Backend Pruebas

```bash
# Run all chat history tests
cd src/server
pytest ../../tests/server/unit/domain/schemas/test_chat_history.py -v
pytest ../../tests/server/integration/api/v1/test_chat_history_integration.py -v

# Expected: 13 unit + 4 integration = 17/17 passing
```

### Frontend Pruebas

```bash
# Dart analyze (should be clean)
cd src/client
dart analyze lib/features/chat/data/repositories/chat_repository_impl.dart --fatal-infos

# Expected: No issues found!
```

### E2E Manual Prueba

1. **Setup:** Configure límites en `.env`
2. **Start Backend:** `docker-compose up -d`
3. **Start Frontend:** `flutter ejecutar -d linux`
4. **Prueba Scenario:**
   - Enviar 10 mensajes consecutivos
   - Verificar en logs: "📤 Sending 10 history messages to backend"
   - Verificar respuesta del LLM incluye contexto previo
5. **Prueba Limit Validation:**
   - Intentar enviar 101 mensajes (API call manual con curl)
   - Verificar error 400 con mensaje: "exceeds maximum length (100 messages)"

---

## 📚 Referencias

### Commits

- **Fase 6:** `01eec76` - feat(backend): add chat history support for conversational context
- **Fase 7:** `3786589` - feat(chat): make history limits configurable via environment variables

### Related Documentoation

- [HU-4.4 README.md](./README.md) - HU principal (4 GAPS de resilience)
- [HU-4.4 PROGRESS.md](./PROGRESS.md) - Tracking detallado de trabajo
- [HU-4.4 ARTIFACTS.md](./ARTIFACTS.md) - Lista de archivos modificados
- [HU-4.2 CONVERSATION-HISTORY](../HU-4.2-CONVERSATION-HISTORY/) - Persistencia SQLite (frontend)

### Code Archivos Modified

**Fase 6:**
- `src/server/app/domain/schemas/chat.py` (history field + validation)
- `src/server/app/api/dependencies.py` (template builder)
- `src/server/app/services/rag/orchestrator.py` (integration)
- `pruebas/server/unit/domain/schemas/prueba_chat_history.py` (9 pruebas)
- `pruebas/server/integration/api/v1/prueba_chat_history_integration.py` (5 pruebas)

**Fase 7:**
- `src/server/app/core/config.py` (Settings fields)
- `src/server/app/domain/schemas/chat.py` (dynamic validation)
- `src/client/lib/features/chat/data/repositories/chat_repository_impl.dart` (history loading)
- `src/server/.env.example` (documentoation)
- `infrastructure/docker-compose.yml` (env vars)
- `pruebas/server/unit/domain/schemas/prueba_chat_history.py` (updated limits)
- `pruebas/server/integration/api/v1/prueba_chat_history_integration.py` (updated limits)

---

</div>

---

<div id="english">

## 📖 Tabla de Contenidos

1. [Executive Summary](#-executive-summary-1)
2. [Fase 6: Chat History Support](#-fase-6-chat-history-support-backend-1)
3. [Fase 7: Configurable Limits](#-fase-7-configurable-limits-1)
4. [Before/After Comparison Table](#-beforeafter-comparison-table)
5. [Migration Guide](#-migration-guide-1)
6. [Configuración Examples](#-configuración-examples-1)

---

## 🎯 Executive Summary

**Goal:** Documento improvements implemented after the 4 critical resilience GAPS, focusing on **conversational context** and **dynamic configurability**.

### Main Changes

| Fase | Feature | Impact | Commit |
|-------|---------|--------|--------|
| **Fase 6** | Chat History Support (Backend) | Conversational memory for LLM | 01eec76 |
| **Fase 7** | Configurable Chat Limits | 5x more context, tunable without recompilation | 3786589 |

**Key Benefits:**
- 🧠 **Conversational Context:** LLM remembers anterior interactions (short-term memory).
- ⚙️ **Configurability:** Adjust limits without recompilation or redeployment.
- 📈 **Scalability:** Large proyectos (25+ documentos) now supported with 100 message history.
- 🚀 **Performance:** Frontend loads and sends last 100 messages automatically.

---

## 🧠 Fase 6: Chat History Support (Backend)

> **Commit:** `01eec76`
> **Fecha:** January 2025
> **Estado:** ✅ Complete

### 6.1 Descripción

Implementación of **conversational memory** in the backend so the LLM has context of anterior messages in a session.

### 6.2 Technical Changes

#### Backend Schema (`chat.py`)

**Archivo:** `src/server/app/domain/schemas/chat.py`

**Main Change:** Optional `history` field in `ChatRequest`

```python
class ChatRequest(BaseModel):
    message: str
    project_id: str
    conversation_id: str | None = None
    history: list[dict[str, str]] = Field(
        default_factory=list,
        description="Chat history for conversational context"
    )

    @model_validator(mode="after")
    def validate_history(self) -> Self:
        """Validate chat history format and sanitize content."""
        if not self.history:
            return self

        # Validation rules (Phase 6 - hardcoded limits):
        # - Max 20 messages (10 user + 10 assistant pairs)
        # - Valid roles: 'user' or 'assistant'
        # - Max 5000 chars per message
        # - XSS sanitization via InputSanitizer

        if len(self.history) > 20:
            raise ValueError("Chat history exceeds maximum length (20 messages)...")

        for i, msg in enumerate(self.history):
            role = msg.get("role")
            content = msg.get("content")

            if role not in ("user", "assistant"):
                raise ValueError(f"Invalid role: {role}. Must be 'user' or 'assistant'.")

            if len(content) > 5000:
                raise ValueError(f"Message {i} content exceeds 5000 characters...")

            # Sanitize content
            msg["content"] = InputSanitizer.sanitize_message(content)

        return self
```

**Features:**
- ✅ Optional field (backward compatible)
- ✅ Role validation (`user` / `assistant`)
- ✅ Size limits (20 messages, 5000 chars/message) - **hardcoded in Fase 6**
- ✅ XSS sanitization on content

#### Template Builder (`dependencies.py`)

**Archivo:** `src/server/app/api/dependencies.py`

**Change:** `build_prompt()` method now accepts `history` parameter

```python
class MVPTemplateBuilder:
    def build_prompt(
        self,
        query: str,
        context: list[dict[str, Any]],
        template_id: str,
        history: list[dict[str, str]] | None = None,  # ✅ NEW
    ) -> str:
        """Build a prompt from template with history support."""
        system_msg = templates[template_id]["system"]

        # Format chat history (if provided)
        history_section = ""
        if history:
            history_section = "\n\nConversation History:\n"
            for msg in history:
                role = msg["role"].capitalize()  # User / Assistant
                content = msg["content"]
                history_section += f"{role}: {content}\n"

        # Format context (RAG sources)
        context_section = "\n\nContext:\n"
        for idx, doc in enumerate(context, start=1):
            context_section += f"[{idx}] {doc['content']}\n"

        # Assemble final prompt
        prompt = f"{system_msg}{history_section}{context_section}\n\nUser Query: {query}"
        return prompt
```

**Prompt Structure:**
```
System Message
  ↓
Conversation History (if provided)
  User: Previous question 1
  Assistant: Previous answer 1
  ...
  ↓
Context (RAG sources)
  [1] Document chunk 1
  [2] Document chunk 2
  ...
  ↓
User Query: Current question
```

#### Orchestrator Integración (`orchestrator.py`)

**Archivo:** `src/server/app/services/rag/orchestrator.py`

**Change:** Pass `history` to template builder

```python
async def process_message(self, request: ChatRequest) -> ChatResponse:
    """Process a chat message through the RAG pipeline."""
    # ... vector search logic ...

    prompt = self.template_builder.build_prompt(
        query=request.message,
        context=sources,
        template_id=template_id,
        history=request.history,  # ✅ NEW: Pass history to template
    )

    ai_response = await self.llm_client.generate(prompt)
    # ...

async def process_message_stream(...) -> AsyncGenerator[dict[str, Any], None]:
    """Process streaming with history support."""
    # ... vector search logic ...

    prompt = self.template_builder.build_prompt(
        query=request.message,
        context=sources,
        template_id=template_id,
        history=request.history,  # ✅ NEW: Pass history to template
    )

    async for token in self.llm_client.stream_generate(prompt):
        yield {"type": "data", "content": token}
    # ...
```

### 6.3 Pruebas Creard (21 pruebas)

**Prueba Archivos:**
- `pruebas/server/unit/domain/schemas/prueba_chat_history.py` (9 pruebas)
- `pruebas/server/unit/api/prueba_template_builder_history.py` (7 pruebas)
- `pruebas/server/integration/api/v1/prueba_chat_history_integration.py` (5 pruebas)

**Prueba Coverage:**
1. ✅ Accept valid history
2. ✅ Default to empty history
3. ✅ Reject >20 messages
4. ✅ Reject invalid roles
5. ✅ Reject missing content field
6. ✅ Sanitize XSS in history content
7. ✅ Reject oversized message (>5000 chars)
8. ✅ Validate message type
9. ✅ Validate content is string
10. ✅ Template builder formats history correctly
11. ✅ Integración endpoint accepts history
12. ✅ Integración endpoint rejects invalid history

### 6.4 Fase 6 Limitations

**Hardcoded Restrictions:**
- ❌ Max 20 messages (too small for large proyectos)
- ❌ Max 5000 chars/message (model supports 32K tokens)
- ❌ **Frontend did NOT send history** (backend ready but not used)

**These limitations are resolved in Fase 7.**

---

## ⚙️ Fase 7: Configurable Limits

> **Commit:** `3786589`
> **Fecha:** January 2025
> **Estado:** ✅ Complete

### 7.1 Descripción

Conversion of hardcoded limits to **configurable via environment variables**, allowing dynamic tuning without recompilation. Additionally, **full frontend integration** to send history.

### 7.2 Technical Changes

#### Backend Configuración (`config.py`)

**Archivo:** `src/server/app/core/config.py`

**Change:** New fields in `Settings` class

```python
class Settings(BaseSettings):
    """Application settings loaded from environment."""

    # ... existing fields ...

    # Chat History Configuration (NEW - Phase 7)
    CHAT_MAX_HISTORY_MESSAGES: int = 100  # Max messages (50 user + 50 assistant)
    CHAT_MAX_MESSAGE_LENGTH: int = 20000  # Max chars per message (model supports 32K)

    # ... rest of settings ...
```

**Defaults:**
- `CHAT_MAX_HISTORY_MESSAGES`: **100** (5x more than Fase 6)
- `CHAT_MAX_MESSAGE_LENGTH`: **20000** (4x more than Fase 6)

#### Dynamic Validation (`chat.py`)

**Archivo:** `src/server/app/domain/schemas/chat.py`

**Change:** Validators read from `settings` instead of hardcoded values

```python
from app.core.config import settings  # ✅ NEW import

class ChatRequest(BaseModel):
    message: str = Field(
        ...,
        max_length=32000,  # Pydantic max, dynamic limit in validator
        description=f"User message (max {settings.CHAT_MAX_MESSAGE_LENGTH} chars, configurable)",
    )

    @field_validator("message")
    @classmethod
    def sanitize_message(cls, v: str) -> str:
        """Sanitize and validate message length."""
        # ✅ Dynamic limit check
        if len(v) > settings.CHAT_MAX_MESSAGE_LENGTH:
            raise ValueError(
                f"Message exceeds maximum length of {settings.CHAT_MAX_MESSAGE_LENGTH} characters "
                f"(got {len(v)}). Adjust CHAT_MAX_MESSAGE_LENGTH env var if needed."
            )
        return InputSanitizer.sanitize_message(v)

    @model_validator(mode="after")
    def validate_history(self) -> Self:
        """Validate chat history with dynamic limits."""
        if not self.history:
            return self

        # ✅ Read max from settings (not hardcoded)
        max_messages = settings.CHAT_MAX_HISTORY_MESSAGES
        if len(self.history) > max_messages:
            raise ValueError(
                f"Chat history exceeds maximum length ({max_messages} messages). "
                "Adjust CHAT_MAX_HISTORY_MESSAGES env var if needed."
            )

        # ✅ Read max length from settings
        max_length = settings.CHAT_MAX_MESSAGE_LENGTH
        for i, msg in enumerate(self.history):
            content = msg.get("content", "")
            if len(content) > max_length:
                raise ValueError(
                    f"Message {i} content exceeds {max_length} characters (got {len(content)}). "
                    "Adjust CHAT_MAX_MESSAGE_LENGTH env var if needed."
                )
            # ... rest of validation ...

        return self
```

**Features:**
- ✅ Limits read dynamically from `settings`
- ✅ Error messages include configured limit
- ✅ Suggestion to adjust env var in validation messages

#### Frontend History Loading (`chat_repository_impl.dart`)

**Archivo:** `src/client/lib/features/chat/data/repositories/chat_repository_impl.dart`

**Change:** Load history from SQLite and send to backend

**BEFORE (Fase 6):**
```dart
@override
Stream<ChatStreamEvent> sendMessageStream(String message, String projectId) {
  final body = {
    'message': message,
    'project_id': projectId,
    'conversation_id': _generateConversationId(),
    // ❌ NO history field
  };
  return sseClient.connect(url, body, headers: headers);
}
```

**AFTER (Fase 7):**
```dart
@override
Stream<ChatStreamEvent> sendMessageStream(
  String message,
  String projectId,
) async* {  // ✅ Changed to async* generator
  final url = '$baseUrl/api/v1/chat/stream';

  // ✅ Load chat history from SQLite to provide conversational context
  var historyPayload = <Map<String, String>>[];
  try {
    final chatHistory = await getChatHistory(projectId);

    // Limit to last 100 messages (50 user + 50 assistant pairs)
    const maxHistoryMessages = 100;
    final limitedHistory = chatHistory.length > maxHistoryMessages
        ? chatHistory.sublist(chatHistory.length - maxHistoryMessages)
        : chatHistory;

    // Transform ChatMessage entities to backend format: {role, content}
    historyPayload = limitedHistory
        .map((msg) => {
              'role': msg.role.name, // 'user' or 'assistant'
              'content': msg.content,
            })
        .toList();

    print('📤 Sending ${historyPayload.length} history messages to backend');
  } on Exception catch (e) {
    print('⚠️ Failed to load chat history: $e. Sending without context.');
    // Continue without history if loading fails (graceful degradation)
  }

  final body = {
    'message': message,
    'project_id': projectId,
    'conversation_id': _generateConversationId(),
    'history': historyPayload, // ✅ NEW: Include chat history
  };
  final headers = {'X-API-Key': apiKey};

  try {
    yield* sseClient.connect(url, body, headers: headers);
  } on SseException catch (e) {
    yield ErrorEvent(message: 'Connection error: ${e.message}');
  }
}
```

**Features:**
- ✅ Loads history from SQLite before sending
- ✅ Limits to last 100 messages (configurable in código)
- ✅ Transforms `ChatMessage` entities → `{role: string, content: string}`
- ✅ Sends `history` field in request body
- ✅ Graceful degradation: If load fails, sends without context

#### Configuración Archivos

##### 1. Environment Variables (`.env.example`)

**Archivo:** `src/server/.env.example`

```bash
# ─────────────────────────────────────────────────────────────
# CHAT HISTORY CONFIGURATION
# ─────────────────────────────────────────────────────────────
# Maximum messages in conversational history
# For large projects (25+ documents), 100+ recommended
# Default: 100 (50 user + 50 assistant)
CHAT_MAX_HISTORY_MESSAGES=100

# Maximum characters per message
# Model supports 32K tokens (~32000 chars)
# 20000 recommended for extensive documents
# Default: 20000
CHAT_MAX_MESSAGE_LENGTH=20000
```

##### 2. Docker Compose (`docker-compose.yml`)

**Archivo:** `infrastructure/docker-compose.yml`

```yaml
services:
  backend:
    # ... existing config ...
    environment:
      # Chat Memory Configuration (NEW)
      - CHAT_MAX_HISTORY_MESSAGES=${CHAT_MAX_HISTORY_MESSAGES:-100}
      - CHAT_MAX_MESSAGE_LENGTH=${CHAT_MAX_MESSAGE_LENGTH:-20000}
```

**Features:**
- ✅ Defaults applied with syntax `${VAR:-default}`
- ✅ Env vars mapped from host → container

### 7.3 Pruebas Updated (17 pruebas)

**Archivos Modified:**
- `pruebas/server/unit/domain/schemas/prueba_chat_history.py` (9 pruebas updated)
- `pruebas/server/integration/api/v1/prueba_chat_history_integration.py` (4 pruebas updated)

**Changes in Pruebas:**
- ✅ `prueba_chat_request_rejects_history_exceeding_20_messages` → Now uses 101 messages (exceeds default 100)
- ✅ `prueba_chat_request_rejects_oversized_message_in_history` → Now uses 20001 chars (exceeds default 20000)
- ✅ Docstrings updated: mention "default config"

**Resultado:** ✅ 13 unit pruebas + 4 integration pruebas = **17/17 passing**

### 7.4 Impact of Fase 7

**Quantitative Improvements:**
- 📈 **5x more messages:** 20 → 100 (capacity for extensive conversations)
- 📈 **4x more characters:** 5000 → 20000 (support for long documentos)
- ⚙️ **Configuración without downtime:** Change `.env` and restart (no recompilation)
- 🚀 **Frontend integrated:** History sent automatically in each request

**Qualitative Improvements:**
- ✅ Large proyectos (25+ documentos) now viable
- ✅ Tuning without programming knowledge (just edit `.env`)
- ✅ Graceful degradation in frontend (continues if SQLite fails)
- ✅ Informative error messages (include current limit)

---

## 📊 Before/After Comparison Table

| Feature | Before Fase 6 | Fase 6 (Hardcoded) | Fase 7 (Configurable) |
|---------|----------------|---------------------|------------------------|
| **Backend Chat History** | ❌ Not supported | ✅ Supported | ✅ Supported |
| **Max Messages** | N/A | 20 (hardcoded) | 100 (configurable) |
| **Max Chars/Message** | 30000 (current message) | 5000 (history, hardcoded) | 20000 (configurable) |
| **Frontend Sends History** | ❌ No | ❌ No | ✅ Yes (last 100) |
| **Configuración Method** | N/A | Recompilation | `.env` / Docker env vars |
| **Prompt Structure** | System → Context → Query | System → History → Context → Query | System → History → Context → Query |
| **Pruebas** | N/A | +21 pruebas | +17 pruebas updated |
| **Graceful Degradation** | N/A | Backend only | Backend + Frontend |
| **Use Case Viability** | Small proyectos | Medium proyectos | Large proyectos (25+ docs) |

**Summary:**
- Fase 6: Fundación (backend ready, frontend not integrated)
- Fase 7: Production (dynamic configuración, frontend integrated)

---

## 🚀 Migration Guide

### For Existing Deployments

#### Scenario 1: No Action Required (Defaults Work)

**Condition:** Typical proyectos (<25 documentos, messages <20K chars)

**Action:** None. Defaults (100 messages, 20000 chars) are adequate.

```bash
# No changes needed, just deploy
docker-compose up -d
```

#### Scenario 2: Large Proyectos (25+ Documentos)

**Condition:** Need more conversational context

**Action:** Increase `CHAT_MAX_HISTORY_MESSAGES`

```bash
# Method 1: Edit .env file
echo "CHAT_MAX_HISTORY_MESSAGES=150" >> .env
docker-compose down && docker-compose up -d

# Method 2: Export environment variable
export CHAT_MAX_HISTORY_MESSAGES=150
docker-compose up -d
```

#### Scenario 3: Extensive Documentos

**Condition:** Typical messages >20K characters (e.g., paste complete código)

**Action:** Increase `CHAT_MAX_MESSAGE_LENGTH`

```bash
# Edit .env
echo "CHAT_MAX_MESSAGE_LENGTH=25000" >> .env
docker-compose restart backend
```

#### Scenario 4: RAM Constraints

**Condition:** Server with low RAM (<8GB)

**Action:** Reduce limits to save memory

```bash
# Reduce both limits
echo "CHAT_MAX_HISTORY_MESSAGES=50" >> .env
echo "CHAT_MAX_MESSAGE_LENGTH=10000" >> .env
docker-compose restart backend
```

### Post-Migration Verificación

```bash
# 1. Verify backend loads env vars
docker-compose exec backend env | grep CHAT_MAX

# Expected output:
# CHAT_MAX_HISTORY_MESSAGES=100
# CHAT_MAX_MESSAGE_LENGTH=20000

# 2. Test validation endpoint (should reject 101 messages)
curl -X POST http://localhost:8000/api/v1/chat/stream \
  -H "X-API-Key: your-key" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Test",
    "project_id": "test-project",
    "history": [/* 101 messages */]
  }'

# Expected: 400 Bad Request with error message mentioning limit

# 3. Check Flutter logs (should show history sent)
# Open app, send message, check console:
# "📤 Sending X history messages to backend"
```

---

## 🔧 Configuración Examples

### Development (Local `.env`)

**Archivo:** `src/server/.env`

```bash
# Development: Relaxed limits for testing
CHAT_MAX_HISTORY_MESSAGES=200
CHAT_MAX_MESSAGE_LENGTH=30000

# Other dev settings...
LOG_LEVEL=DEBUG
```

**Restart:**
```bash
cd src/server
source venv/bin/activate
uvicorn app.main:app --reload
```

### Docker Compose (Staging)

**Archivo:** `infrastructure/docker-compose.yml`

```yaml
services:
  backend:
    environment:
      # Staging: Moderate limits
      - CHAT_MAX_HISTORY_MESSAGES=150
      - CHAT_MAX_MESSAGE_LENGTH=20000
      - LOG_LEVEL=INFO
```

**Deploy:**
```bash
docker-compose -f infrastructure/docker-compose.yml up -d
```

### Production (Environment Variables)

**Option 1: Systemd Service Archivo**

```ini
# /etc/systemd/system/softarchitect-backend.service
[Service]
Environment="CHAT_MAX_HISTORY_MESSAGES=100"
Environment="CHAT_MAX_MESSAGE_LENGTH=20000"
ExecStart=/usr/local/bin/uvicorn app.main:app --host 0.0.0.0
```

**Option 2: Docker Swarm Secrets**

```yaml
# docker-compose.prod.yml
services:
  backend:
    environment:
      - CHAT_MAX_HISTORY_MESSAGES=${CHAT_MAX_HISTORY_MESSAGES}
      - CHAT_MAX_MESSAGE_LENGTH=${CHAT_MAX_MESSAGE_LENGTH}
    secrets:
      - chat_config
```

**Option 3: Kubernetes ConfigMap**

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: backend-config
data:
  CHAT_MAX_HISTORY_MESSAGES: "100"
  CHAT_MAX_MESSAGE_LENGTH: "20000"
```

### Performance Tuning Examples

#### High-Volume Production (Low Latency Priority)

```bash
# Reduce context to minimize LLM processing time
CHAT_MAX_HISTORY_MESSAGES=50
CHAT_MAX_MESSAGE_LENGTH=10000
```

#### Research/Documentoation Proyectos (High Context Priority)

```bash
# Maximize context for deep technical discussions
CHAT_MAX_HISTORY_MESSAGES=200
CHAT_MAX_MESSAGE_LENGTH=30000
```

#### RAM-Constrained Environments (VPS <4GB)

```bash
# Conservative limits to avoid OOM
CHAT_MAX_HISTORY_MESSAGES=30
CHAT_MAX_MESSAGE_LENGTH=8000
```

---

## 🔍 Pruebaing & Validation

### Backend Pruebas

```bash
# Run all chat history tests
cd src/server
pytest ../../tests/server/unit/domain/schemas/test_chat_history.py -v
pytest ../../tests/server/integration/api/v1/test_chat_history_integration.py -v

# Expected: 13 unit + 4 integration = 17/17 passing
```

### Frontend Pruebas

```bash
# Dart analyze (should be clean)
cd src/client
dart analyze lib/features/chat/data/repositories/chat_repository_impl.dart --fatal-infos

# Expected: No issues found!
```

### E2E Manual Prueba

1. **Setup:** Configure limits in `.env`
2. **Start Backend:** `docker-compose up -d`
3. **Start Frontend:** `flutter ejecutar -d linux`
4. **Prueba Scenario:**
   - Send 10 consecutive messages
   - Verify in logs: "📤 Sending 10 history messages to backend"
   - Verify LLM response includes anterior context
5. **Prueba Limit Validation:**
   - Try sending 101 messages (manual API call with curl)
   - Verify error 400 with message: "exceeds maximum length (100 messages)"

---

## 📚 References

### Commits

- **Fase 6:** `01eec76` - feat(backend): add chat history support for conversational context
- **Fase 7:** `3786589` - feat(chat): make history limits configurable via environment variables

### Related Documentoation

- [HU-4.4 README.md](./README.md) - Main HU (4 resilience GAPS)
- [HU-4.4 PROGRESS.md](./PROGRESS.md) - Detailed work tracking
- [HU-4.4 ARTIFACTS.md](./ARTIFACTS.md) - List of modified archivos
- [HU-4.2 CONVERSATION-HISTORY](../HU-4.2-CONVERSATION-HISTORY/) - SQLite persistence (frontend)

### Code Archivos Modified

**Fase 6:**
- `src/server/app/domain/schemas/chat.py` (history field + validation)
- `src/server/app/api/dependencies.py` (template builder)
- `src/server/app/services/rag/orchestrator.py` (integration)
- `pruebas/server/unit/domain/schemas/prueba_chat_history.py` (9 pruebas)
- `pruebas/server/integration/api/v1/prueba_chat_history_integration.py` (5 pruebas)

**Fase 7:**
- `src/server/app/core/config.py` (Settings fields)
- `src/server/app/domain/schemas/chat.py` (dynamic validation)
- `src/client/lib/features/chat/data/repositories/chat_repository_impl.dart` (history loading)
- `src/server/.env.example` (documentoation)
- `infrastructure/docker-compose.yml` (env vars)
- `pruebas/server/unit/domain/schemas/prueba_chat_history.py` (updated limits)
- `pruebas/server/integration/api/v1/prueba_chat_history_integration.py` (updated limits)

---

</div>
