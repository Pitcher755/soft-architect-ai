# 📋 HU-4.4: RAG/LLM Resilience Extensions

> **Historia de Usuario:** Completar resilience crítica faltante en error handling (extiende HU-3.4)
> **Sprint:** S4 - Inteligencia Artificial y Chat (The Brain)
> **Epic:** E4 - Backend IA & RAG
> **Prioridad:** 🔥 **HIGH** (Bloqueante para producción)
> **Estimación:** S (~4 horas)
> **Rama:** `feature/rag-llm-resilience`
> **Estado:** 🟡 **FASE 0 - Setup**

---

<div align="center">

[🇬🇧 English](#english) | [🇪🇸 Español](#español)

</div>

---

<div id="español">

## 📖 Tabla de Contenidos

1. [Información General](#-información-general)
2. [Objetivo](#-objetivo)
3. [Contexto Técnico](#-contexto-técnico)
4. [Alcance (4 GAPS Críticos)](#-alcance-4-gaps-críticos)
5. [Dependencias](#-dependencias)
6. [Entregables](#-entregables)
7. [Criterios de Aceptación](#-criterios-de-aceptación)
8. [Escenarios de Prueba](#-escenarios-de-prueba)
9. [Documentación Relacionada](#-documentación-relacionada)

---

## 📊 Información General

| Campo | Valor |
|-------|-------|
| **ID** | HU-4.4 |
| **Nombre** | RAG/LLM Resilience Extensions |
| **Sprint** | S4 - Inteligencia Artificial y Chat |
| **Epic** | E4 - Backend IA & RAG |
| **Prioridad** | 🔥 HIGH (Bloqueante producción) |
| **Estimación** | S (~4 horas) |
| **Estado** | 🟡 Fase 0 - Setup |
| **Branch** | `feature/rag-llm-resilience` |
| **Dependencias Upstream** | HU-3.4 ✅ (base error handling), HU-4.3 ✅ (SSE streaming) |
| **Dependencias Downstream** | HU-5.1 (Tests integración), HU-6.1 (Packaging) |

---

## 🎯 Objetivo

**Completar los 4 GAPS críticos** identificados en el análisis de HU-3.4 (Error Handling & Validation Gates) para garantizar que el sistema sea **production-ready** con resilience completa ante fallos de infraestructura (Ollama offline, ChromaDB caído, latencia alta).

**Filosofía:** "Sistema Antifragil - El chat debe funcionar SIEMPRE, incluso cuando ChromaDB falla"

### Relación con HU-3.4

**HU-3.4 construyó la base (75%):**
- ✅ Decorator `@with_retry` genérico
- ✅ ErrorMapper con 15+ códigos
- ✅ SnackbarService (autohide/manual)
- ✅ Validation Gates (VAL_001-005)
- ✅ Error logging estructurado

**HU-4.4 completa resilience crítica (25% faltante):**
- 🔴 **GAP 1:** Graceful degradation en RAG orchestrator
- 🟡 **GAP 2:** Aplicar `@with_retry` a LLM calls
- 🟡 **GAP 3:** Timeout 30s para RAG operations
- 🟢 **GAP 4:** Códigos de error faltantes (DB_ERR_001, RAG_ERR_001)

---

## 🔍 Contexto Técnico

### Problema Actual (Estado en `develop`)

#### 1. **Graceful Degradation NO Implementado** 🔴 **CRÍTICO**

**Archivo:** `src/server/app/services/rag/orchestrator.py` líneas 89-103

**Comportamiento actual (BLOQUEANTE):**
```python
try:
    sources = await self.vector_store.search(request.message, top_k=5)
except Exception as error:
    logger.error("Vector search failed: %s", error)
    yield {"type": "error", ...}
    raise RAGRetrievalError(...)  # ❌ FLUJO SE DETIENE
```

**Impacto:** Si ChromaDB está caído, **el chat NO funciona** (0% disponibilidad).

**Solución HU-4.4:**
```python
try:
    sources = await self.vector_store.search(request.message, top_k=5)
except Exception as error:
    logger.warning("⚠️ RAG degraded: continuing without context")
    sources = []  # ✅ CONTINÚA con FALLBACK template
```

---

#### 2. **Retry NO Aplicado a LLM Calls** 🟡 **HIGH**

**Archivo:** `src/server/app/infrastructure/llm/ollama_client.py` líneas 83-128

**Comportamiento actual:**
```python
async def generate(self, prompt: str, ...) -> str:
    # ❌ NO tiene @with_retry decorator
    try:
        response = await client.post(endpoint, json=payload)
        ...
```

**Impacto:** Fallos transitorios de red causan error inmediato sin reintentos.

**Solución HU-4.4:**
```python
from app.core.retry import with_retry

@with_retry(max_retries=3, base_delay=0.5, retryable_exceptions=(httpx.RequestError,))
async def generate(self, prompt: str, ...) -> str:
    ...
```

---

#### 3. **Timeout RAG Inexistente** 🟡 **MEDIUM**

**Archivo:** `orchestrator.py` línea 89

**Comportamiento actual:**
```python
sources = await self.vector_store.search(request.message, top_k=5)
# ❌ Si ChromaDB se cuelga, espera indefinidamente
```

**Impacto:** Latencia alta (>30s) bloquea UI indefinidamente.

**Solución HU-4.4:**
```python
import asyncio

sources = await asyncio.wait_for(
    self.vector_store.search(request.message, top_k=5),
    timeout=30.0
)
```

---

#### 4. **Códigos de Error Incompletos** 🟢 **LOW**

**Archivo:** `src/server/app/core/exceptions.py`

**Faltan:**
- `DB_ERR_001`: "ChromaDB connection failed"
- `RAG_ERR_001`: "RAG retrieval failed"

**Solución HU-4.4:** Agregar clases de excepción faltantes.

---

## 📦 Alcance (4 GAPS Críticos)

### Backend (3 archivos modificados)

| Archivo | Cambio | Líneas | Tests |
|---------|--------|--------|-------|
| `src/server/app/services/rag/orchestrator.py` | Graceful degradation + timeout | ~40 | 6 |
| `src/server/app/infrastructure/llm/ollama_client.py` | Aplicar `@with_retry` | ~10 | 8 |
| `src/server/app/core/exceptions.py` | Agregar 2 códigos | ~30 | N/A |

### Frontend (1 archivo modificado)

| Archivo | Cambio | Líneas | Tests |
|---------|--------|--------|-------|
| `src/client/lib/core/error_handling/error_mapper.dart` | Agregar mensajes ES para DB_ERR_001, RAG_ERR_001 | ~10 | 1 |

### Tests (15 nuevos tests)

| Módulo | Tests | Archivo |
|--------|-------|---------|
| Retry LLM | 8 tests | `tests/server/unit/infrastructure/llm/test_ollama_retry.py` |
| Graceful Degradation | 6 tests | `tests/server/unit/services/rag/test_orchestrator_degradation.py` |
| Timeout | 1 test | `tests/server/unit/services/rag/test_orchestrator_timeout.py` |

---

## 🔗 Dependencias

### Bloqueantes (DEBEN estar completas)

- ✅ **HU-3.4:** Error Handling & Validation Gates (base retry decorator)
- ✅ **HU-4.1:** Chat Endpoint con RAG Orchestrator
- ✅ **HU-4.3:** SSE Streaming implementado

### Contribuye a (Desbloquea)

- 🔜 **HU-5.1:** Integration Tests (necesita sistema resiliente)
- 🔜 **HU-6.1:** Packaging/Instaladores (requiere producción-ready)

---

## 📦 Entregables

### 1. Backend: Graceful Degradation (GAP 1) 🔴

**Archivo:** `src/server/app/services/rag/orchestrator.py`

- Wrap `vector_store.search()` en try-except
- Continuar con `sources=[]` si falla (usar FALLBACK template)
- Log warning (no error) cuando se degrada
- Agregar timeout de 30s con `asyncio.wait_for()`

**Tests:** 6 tests degradation + 1 test timeout

---

### 2. Backend: Retry en LLM Calls (GAP 2) 🟡

**Archivo:** `src/server/app/infrastructure/llm/ollama_client.py`

- Aplicar `@with_retry` a `generate()` method
- Aplicar `@with_retry` a `stream_generate()` method
- Configurar retries=3, base_delay=0.5s
- Exceptions retryables: `httpx.RequestError`, `httpx.TimeoutException`

**Tests:** 8 tests retry logic

---

### 3. Backend: Códigos de Error Faltantes (GAP 4) 🟢

**Archivo:** `src/server/app/core/exceptions.py`

```python
class ChromaDBConnectionError(BaseAppError):
    code: str = "DB_ERR_001"
    message: str = "ChromaDB connection failed"

class RAGRetrievalError(BaseAppError):
    code: str = "RAG_ERR_001"
    message: str = "RAG retrieval failed"
```

**Tests:** Cubierto por tests de orchestrator

---

### 4. Frontend: Mensajes de Error Faltantes (GAP 4) 🟢

**Archivo:** `src/client/lib/core/error_handling/error_mapper.dart`

```dart
static const Map<String, String> _messages = {
  // Existing...
  'DB_ERR_001': '🗄️ La base de datos vectorial no responde',
  'RAG_ERR_001': '📚 Error al buscar contexto en la base de conocimiento',
};

static const Map<String, String> _suggestions = {
  'DB_ERR_001': 'Verifica que Docker esté ejecutando ChromaDB',
  'RAG_ERR_001': 'Intenta nuevamente o continúa sin contexto adicional',
};
```

**Tests:** 1 test mapping

---

## ✅ Criterios de Aceptación

### Funcionales (Críticos - MUST HAVE)

| # | Criterio | Validación |
|---|----------|------------|
| 1 | ✅ Si ChromaDB falla, chat continúa sin contexto RAG | Test manual: detener ChromaDB → enviar mensaje → recibir respuesta |
| 2 | ✅ LLM calls se reintentan 3x antes de fallar | Test unitario: mock httpx.RequestError → verificar 3 intentos |
| 3 | ✅ RAG search tiene timeout de 30s | Test unitario: mock sleep(35s) → verificar TimeoutError |
| 4 | ✅ Mensajes de error traducidos para DB_ERR_001, RAG_ERR_001 | Test unitario: ErrorMapper.getUserMessage() |
| 5 | ✅ Log warning (no error) cuando RAG se degrada | Test unitario: verificar logger.warning() llamado |

### No Funcionales (Calidad - MUST HAVE)

| # | Criterio | Validación |
|---|----------|------------|
| 6 | ✅ Cobertura ≥90% en orchestrator degradation | pytest --cov=orchestrator --cov-fail-under=90 |
| 7 | ✅ Cobertura ≥95% en retry logic LLM | pytest --cov=ollama_client --cov-fail-under=95 |
| 8 | ✅ 0 errores Pyright en código modificado | pyright src/server/app/services/rag/ |
| 9 | ✅ Black + Ruff passing | black --check src/server/ && ruff check src/server/ |
| 10 | ✅ 15/15 tests passing (8 retry + 6 degradation + 1 timeout) | pytest tests/server/unit/ -v |

### Seguridad (OWASP - MUST HAVE)

| # | Criterio | Validación |
|---|----------|------------|
| 11 | ✅ No exponer stack traces en logs ante degradación | Revisar logs: no debe haber traceback completo |
| 12 | ✅ No exponer datos de usuario en error logs | Bandit src/server/ -q |

---

## 🔍 Escenarios de Prueba

### Escenario 1: ChromaDB Caído (Graceful Degradation)

**Precondiciones:**
```bash
docker-compose stop chromadb
```

**Pasos:**
1. Usuario envía mensaje: "¿Cómo implementar la fase 2?"
2. Backend intenta buscar en ChromaDB
3. Vector search falla con ConnectionError

**Resultado Esperado:**
- ⚠️ Log WARNING: "RAG degraded: continuing without context"
- ✅ Chat responde con conocimiento general del LLM
- ✅ Usuario NO ve error crítico (operación transparente)
- ✅ Response incluye `"template_used": "FALLBACK"`

**Validación:**
```bash
curl -X POST http://localhost:8000/api/v1/chat/stream \
  -d '{"message":"test","project_id":"1"}' \
  -H "Content-Type: application/json"
# Debe responder (no error 500)
```

---

### Escenario 2: Ollama con Fallos Transitorios (Retry Logic)

**Precondiciones:**
```bash
# Simular latencia de red alta
tc qdisc add dev lo root netem delay 100ms 20ms
```

**Pasos:**
1. Usuario envía 3 mensajes consecutivos
2. Ollama tiene fallos intermitentes (httpx.RequestError)
3. Backend reintenta automáticamente

**Resultado Esperado:**
- ⚠️ Log WARNING: "Retry attempt 1/3 for generate failed"
- ⚠️ Log WARNING: "Retry attempt 2/3 for generate failed"
- ✅ Log INFO: "Retry successful for generate" (intento 3)
- ✅ Usuario recibe respuesta (no nota reintentos)

**Validación:**
```python
# Test unitario
@patch('httpx.AsyncClient.post', side_effect=[
    httpx.RequestError("Connection refused"),
    httpx.RequestError("Connection refused"),
    MagicMock(status_code=200, json=lambda: {"response": "success"})
])
async def test_ollama_retry_succeeds_third_attempt(mock_post):
    client = OllamaClient()
    result = await client.generate("test prompt")
    assert result == "success"
    assert mock_post.call_count == 3
```

---

### Escenario 3: ChromaDB Timeout (>30s)

**Precondiciones:**
```python
# Mock vector_store.search() con sleep(35s)
@patch('app.services.rag.vector_store.search', side_effect=lambda *args: asyncio.sleep(35))
```

**Pasos:**
1. Usuario envía mensaje que requiere RAG
2. ChromaDB tarda >30s en responder
3. Timeout corta la espera

**Resultado Esperado:**
- ⚠️ Log WARNING: "RAG search timeout (30s exceeded)"
- ✅ Chat continúa con `sources=[]` (graceful degradation)
- ✅ Usuario recibe respuesta en <32s (30s timeout + 2s LLM)

**Validación:**
```python
@pytest.mark.asyncio
async def test_rag_timeout_triggers_degradation():
    orchestrator = RAGOrchestrator(slow_vector_store, ...)
    with pytest.raises(asyncio.TimeoutError):
        await orchestrator.process_message(ChatRequest(...))
    # Verify logger.warning called
```

---

## 📚 Documentación Relacionada

### Contexto del Proyecto

- [AGENTS.md](../../../AGENTS.md) - Reglas de desarrollo, TDD, seguridad OWASP
- [USER_STORIES_MASTER.es.json](../../../context/40-ROADMAP/USER_STORIES_MASTER.es.json) - Roadmap Sprint 4

### HUs Relacionadas

- [HU-3.4: Error Handling & Validation Gates](../HU-3.4_ERROR_HANDLING_GATES/README.md) - Base de HU-4.4
- [HU-4.1: Chat Endpoint con RAG](../HU-4.1-CHAT-ENDPOINT/README.md) - Arquitectura RAG
- [HU-4.3: SSE Streaming](../HU-4.3-SSE-STREAMING/README.md) - Streaming implementation

### Documentación Técnica

- [Error Handling Standard](../../../context/30-ARCHITECTURE/ERROR_HANDLING_STANDARD.md) - Estándar de errores
- [RAG Architecture](../../../context/30-ARCHITECTURE/RAG_ARCHITECTURE.md) - Diseño del sistema RAG
- [Testing Strategy](../../../context/20-REQUIREMENTS_AND_SPEC/TESTING_STANDARDS.md) - Estrategia TDD

---

</div>

<div id="english">

## 📋 Table of Contents

1. [General Information](#-general-information)
2. [Objective](#-objective)
3. [Technical Context](#-technical-context)
4. [Scope (4 Critical GAPS)](#-scope-4-critical-gaps)
5. [Dependencies](#-dependencies-1)
6. [Deliverables](#-deliverables-1)
7. [Acceptance Criteria](#-acceptance-criteria-1)
8. [Test Scenarios](#-test-scenarios)
9. [Related Documentation](#-related-documentation)

---

## 📊 General Information

| Field | Value |
|-------|-------|
| **ID** | HU-4.4 |
| **Name** | RAG/LLM Resilience Extensions |
| **Sprint** | S4 - Artificial Intelligence and Chat |
| **Epic** | E4 - Backend AI & RAG |
| **Priority** | 🔥 HIGH (Production blocker) |
| **Estimation** | S (~4 hours) |
| **Status** | 🟡 Phase 0 - Setup |
| **Branch** | `feature/rag-llm-resilience` |
| **Upstream Dependencies** | HU-3.4 ✅ (base error handling), HU-4.3 ✅ (SSE streaming) |
| **Downstream Dependencies** | HU-5.1 (Integration tests), HU-6.1 (Packaging) |

---

## 🎯 Objective

**Complete the 4 critical GAPS** identified in HU-3.4 (Error Handling & Validation Gates) analysis to ensure the system is **production-ready** with full resilience against infrastructure failures (Ollama offline, ChromaDB down, high latency).

**Philosophy:** "Antifragile System - Chat MUST work ALWAYS, even when ChromaDB fails"

### Relationship with HU-3.4

**HU-3.4 built the foundation (75%):**
- ✅ Generic `@with_retry` decorator
- ✅ ErrorMapper with 15+ codes
- ✅ SnackbarService (autohide/manual)
- ✅ Validation Gates (VAL_001-005)
- ✅ Structured error logging

**HU-4.4 completes critical resilience (25% missing):**
- 🔴 **GAP 1:** Graceful degradation in RAG orchestrator
- 🟡 **GAP 2:** Apply `@with_retry` to LLM calls
- 🟡 **GAP 3:** 30s timeout for RAG operations
- 🟢 **GAP 4:** Missing error codes (DB_ERR_001, RAG_ERR_001)

---

## 🔍 Technical Context

### Current Problem (State in `develop`)

#### 1. **Graceful Degradation NOT Implemented** 🔴 **CRITICAL**

**File:** `src/server/app/services/rag/orchestrator.py` lines 89-103

**Current behavior (BLOCKER):**
```python
try:
    sources = await self.vector_store.search(request.message, top_k=5)
except Exception as error:
    logger.error("Vector search failed: %s", error)
    yield {"type": "error", ...}
    raise RAGRetrievalError(...)  # ❌ FLOW STOPS
```

**Impact:** If ChromaDB is down, **chat does NOT work** (0% availability).

**HU-4.4 Solution:**
```python
try:
    sources = await self.vector_store.search(request.message, top_k=5)
except Exception as error:
    logger.warning("⚠️ RAG degraded: continuing without context")
    sources = []  # ✅ CONTINUES with FALLBACK template
```

---

#### 2. **Retry NOT Applied to LLM Calls** 🟡 **HIGH**

**File:** `src/server/app/infrastructure/llm/ollama_client.py` lines 83-128

**Current behavior:**
```python
async def generate(self, prompt: str, ...) -> str:
    # ❌ NO @with_retry decorator
    try:
        response = await client.post(endpoint, json=payload)
        ...
```

**Impact:** Transient network failures cause immediate error without retries.

**HU-4.4 Solution:**
```python
from app.core.retry import with_retry

@with_retry(max_retries=3, base_delay=0.5, retryable_exceptions=(httpx.RequestError,))
async def generate(self, prompt: str, ...) -> str:
    ...
```

---

#### 3. **RAG Timeout Non-existent** 🟡 **MEDIUM**

**File:** `orchestrator.py` line 89

**Current behavior:**
```python
sources = await self.vector_store.search(request.message, top_k=5)
# ❌ If ChromaDB hangs, waits indefinitely
```

**Impact:** High latency (>30s) blocks UI indefinitely.

**HU-4.4 Solution:**
```python
import asyncio

sources = await asyncio.wait_for(
    self.vector_store.search(request.message, top_k=5),
    timeout=30.0
)
```

---

#### 4. **Incomplete Error Codes** 🟢 **LOW**

**File:** `src/server/app/core/exceptions.py`

**Missing:**
- `DB_ERR_001`: "ChromaDB connection failed"
- `RAG_ERR_001`: "RAG retrieval failed"

**HU-4.4 Solution:** Add missing exception classes.

---

## 📦 Scope (4 Critical GAPS)

### Backend (3 files modified)

| File | Change | Lines | Tests |
|------|--------|-------|-------|
| `src/server/app/services/rag/orchestrator.py` | Graceful degradation + timeout | ~40 | 6 |
| `src/server/app/infrastructure/llm/ollama_client.py` | Apply `@with_retry` | ~10 | 8 |
| `src/server/app/core/exceptions.py` | Add 2 codes | ~30 | N/A |

### Frontend (1 file modified)

| File | Change | Lines | Tests |
|------|--------|-------|-------|
| `src/client/lib/core/error_handling/error_mapper.dart` | Add ES messages for DB_ERR_001, RAG_ERR_001 | ~10 | 1 |

### Tests (15 new tests)

| Module | Tests | File |
|--------|-------|------|
| Retry LLM | 8 tests | `tests/server/unit/infrastructure/llm/test_ollama_retry.py` |
| Graceful Degradation | 6 tests | `tests/server/unit/services/rag/test_orchestrator_degradation.py` |
| Timeout | 1 test | `tests/server/unit/services/rag/test_orchestrator_timeout.py` |

---

## 🔗 Dependencies

### Blocking (MUST be completed)

- ✅ **HU-3.4:** Error Handling & Validation Gates (base retry decorator)
- ✅ **HU-4.1:** Chat Endpoint with RAG Orchestrator
- ✅ **HU-4.3:** SSE Streaming implemented

### Contributes to (Unlocks)

- 🔜 **HU-5.1:** Integration Tests (requires resilient system)
- 🔜 **HU-6.1:** Packaging/Installers (requires production-ready)

---

## 📦 Deliverables

### 1. Backend: Graceful Degradation (GAP 1) 🔴

**File:** `src/server/app/services/rag/orchestrator.py`

- Wrap `vector_store.search()` in try-except
- Continue with `sources=[]` if fails (use FALLBACK template)
- Log warning (not error) when degrading
- Add 30s timeout with `asyncio.wait_for()`

**Tests:** 6 degradation tests + 1 timeout test

---

### 2. Backend: Retry on LLM Calls (GAP 2) 🟡

**File:** `src/server/app/infrastructure/llm/ollama_client.py`

- Apply `@with_retry` to `generate()` method
- Apply `@with_retry` to `stream_generate()` method
- Configure retries=3, base_delay=0.5s
- Retryable exceptions: `httpx.RequestError`, `httpx.TimeoutException`

**Tests:** 8 retry logic tests

---

### 3. Backend: Missing Error Codes (GAP 4) 🟢

**File:** `src/server/app/core/exceptions.py`

```python
class ChromaDBConnectionError(BaseAppError):
    code: str = "DB_ERR_001"
    message: str = "ChromaDB connection failed"

class RAGRetrievalError(BaseAppError):
    code: str = "RAG_ERR_001"
    message: str = "RAG retrieval failed"
```

**Tests:** Covered by orchestrator tests

---

### 4. Frontend: Missing Error Messages (GAP 4) 🟢

**File:** `src/client/lib/core/error_handling/error_mapper.dart`

```dart
static const Map<String, String> _messages = {
  // Existing...
  'DB_ERR_001': '🗄️ Vector database not responding',
  'RAG_ERR_001': '📚 Error searching context in knowledge base',
};

static const Map<String, String> _suggestions = {
  'DB_ERR_001': 'Verify Docker is running ChromaDB',
  'RAG_ERR_001': 'Try again or continue without additional context',
};
```

**Tests:** 1 mapping test

---

## ✅ Acceptance Criteria

### Functional (Critical - MUST HAVE)

| # | Criterion | Validation |
|---|-----------|------------|
| 1 | ✅ If ChromaDB fails, chat continues without RAG context | Manual test: stop ChromaDB → send message → receive response |
| 2 | ✅ LLM calls retry 3x before failing | Unit test: mock httpx.RequestError → verify 3 attempts |
| 3 | ✅ RAG search has 30s timeout | Unit test: mock sleep(35s) → verify TimeoutError |
| 4 | ✅ Translated error messages for DB_ERR_001, RAG_ERR_001 | Unit test: ErrorMapper.getUserMessage() |
| 5 | ✅ Log warning (not error) when RAG degrades | Unit test: verify logger.warning() called |

### Non-Functional (Quality - MUST HAVE)

| # | Criterion | Validation |
|---|-----------|------------|
| 6 | ✅ Coverage ≥90% on orchestrator degradation | pytest --cov=orchestrator --cov-fail-under=90 |
| 7 | ✅ Coverage ≥95% on retry logic LLM | pytest --cov=ollama_client --cov-fail-under=95 |
| 8 | ✅ 0 Pyright errors on modified code | pyright src/server/app/services/rag/ |
| 9 | ✅ Black + Ruff passing | black --check src/server/ && ruff check src/server/ |
| 10 | ✅ 15/15 tests passing (8 retry + 6 degradation + 1 timeout) | pytest tests/server/unit/ -v |

### Security (OWASP - MUST HAVE)

| # | Criterion | Validation |
|---|-----------|------------|
| 11 | ✅ No stack traces exposed in degradation logs | Review logs: no full traceback |
| 12 | ✅ No user data exposed in error logs | Bandit src/server/ -q |

---

## 🔍 Test Scenarios

### Scenario 1: ChromaDB Down (Graceful Degradation)

**Preconditions:**
```bash
docker-compose stop chromadb
```

**Steps:**
1. User sends message: "How to implement phase 2?"
2. Backend tries ChromaDB search
3. Vector search fails with ConnectionError

**Expected Result:**
- ⚠️ Log WARNING: "RAG degraded: continuing without context"
- ✅ Chat responds with LLM general knowledge
- ✅ User does NOT see critical error (transparent operation)
- ✅ Response includes `"template_used": "FALLBACK"`

**Validation:**
```bash
curl -X POST http://localhost:8000/api/v1/chat/stream \
  -d '{"message":"test","project_id":"1"}' \
  -H "Content-Type: application/json"
# Must respond (not 500 error)
```

---

### Scenario 2: Ollama with Transient Failures (Retry Logic)

**Preconditions:**
```bash
# Simulate high network latency
tc qdisc add dev lo root netem delay 100ms 20ms
```

**Steps:**
1. User sends 3 consecutive messages
2. Ollama has intermittent failures (httpx.RequestError)
3. Backend retries automatically

**Expected Result:**
- ⚠️ Log WARNING: "Retry attempt 1/3 for generate failed"
- ⚠️ Log WARNING: "Retry attempt 2/3 for generate failed"
- ✅ Log INFO: "Retry successful for generate" (attempt 3)
- ✅ User receives response (doesn't notice retries)

**Validation:**
```python
# Unit test
@patch('httpx.AsyncClient.post', side_effect=[
    httpx.RequestError("Connection refused"),
    httpx.RequestError("Connection refused"),
    MagicMock(status_code=200, json=lambda: {"response": "success"})
])
async def test_ollama_retry_succeeds_third_attempt(mock_post):
    client = OllamaClient()
    result = await client.generate("test prompt")
    assert result == "success"
    assert mock_post.call_count == 3
```

---

### Scenario 3: ChromaDB Timeout (>30s)

**Preconditions:**
```python
# Mock vector_store.search() with sleep(35s)
@patch('app.services.rag.vector_store.search', side_effect=lambda *args: asyncio.sleep(35))
```

**Steps:**
1. User sends message requiring RAG
2. ChromaDB takes >30s to respond
3. Timeout cuts the wait

**Expected Result:**
- ⚠️ Log WARNING: "RAG search timeout (30s exceeded)"
- ✅ Chat continues with `sources=[]` (graceful degradation)
- ✅ User receives response in <32s (30s timeout + 2s LLM)

**Validation:**
```python
@pytest.mark.asyncio
async def test_rag_timeout_triggers_degradation():
    orchestrator = RAGOrchestrator(slow_vector_store, ...)
    with pytest.raises(asyncio.TimeoutError):
        await orchestrator.process_message(ChatRequest(...))
    # Verify logger.warning called
```

---

## 📚 Related Documentation

### Project Context

- [AGENTS.md](../../../AGENTS.md) - Development rules, TDD, OWASP security
- [USER_STORIES_MASTER.es.json](../../../context/40-ROADMAP/USER_STORIES_MASTER.es.json) - Sprint 4 Roadmap

### Related HUs

- [HU-3.4: Error Handling & Validation Gates](../HU-3.4_ERROR_HANDLING_GATES/README.md) - Base of HU-4.4
- [HU-4.1: Chat Endpoint with RAG](../HU-4.1-CHAT-ENDPOINT/README.md) - RAG Architecture
- [HU-4.3: SSE Streaming](../HU-4.3-SSE-STREAMING/README.md) - Streaming implementation

### Technical Documentation

- [Error Handling Standard](../../../context/30-ARCHITECTURE/ERROR_HANDLING_STANDARD.md) - Error standards
- [RAG Architecture](../../../context/30-ARCHITECTURE/RAG_ARCHITECTURE.md) - RAG system design
- [Testing Strategy](../../../context/20-REQUIREMENTS_AND_SPEC/TESTING_STANDARDS.md) - TDD Strategy

---

</div>
