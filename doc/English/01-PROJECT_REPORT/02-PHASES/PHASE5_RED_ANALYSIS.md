# 🔴 FASE 5: Integration The Gate (TDD RED)

> **Fecha:** 6 de febrero de 2026
> **Estado:** 🔴 RED - Test Failing (13 errores identificados)
> **Objetivo:** Conectar Frontend → Backend → FileSystem (HU-3.2)

---

## 📋 Tabla de Contenidos

- [1. Resumen Ejecutivo](#1-resumen-ejecutivo)
- [2. Test de Integración Creado](#2-test-de-integración-creado)
- [3. Errores RED Identificados](#3-errores-red-identificados)
- [4. Análisis de Gaps](#4-análisis-de-gaps)
- [5. Checklist de Implementación (GREEN)](#5-checklist-de-implementación-green)

---

## 1. Resumen Ejecutivo

### 📊 Métricas

```
Integration Tests: 2
  ✅ Created: tests/test/integration/features/chat/chat_flow_test.dart
  ❌ Passing: 0/2
  🔴 Failing: 2/2

Error Categories:
  ❌ UI Widget Hierarchy (1)
  ❌ Initialization State (1)
  ❌ Missing Backend API (Multiple)
  ❌ Missing FileSystem Integration (Multiple)
  ❌ Missing Toast/Snackbar Component (1)
  ❌ Missing Progress Display (1)
```

### 🎯 Objetivo de FASE 5

Validar que el flujo **E2E (End-to-End)** funciona:

```
User Input (Chat)
  ↓
Frontend (Riverpod ChatNotifier)
  ↓
Backend (Python FastAPI RAG Service)
  ↓
Document Generation
  ↓
FileSystem (Save .md file)
  ↓
UI Update (Success Toast + Progress)
```

---

## 2. Test de Integración Creado

### 📝 Archivo

**Ubicación:** `tests/test/integration/features/chat/chat_flow_test.dart`

### 🧪 Casos de Prueba

#### Test 1: `should complete full document generation cycle`

**Escenario:**
1. Launch app
2. Navigate to "Nuevo Proyecto" (chat screen)
3. Enter prompt: "Genera el Project Manifesto"
4. Wait for streaming (5 segundos)
5. Validate proposal widget appears
6. Tap "Validar y Guardar"
7. Verify success toast + progress counter

#### Test 2: `should handle streaming errors gracefully`

**Escenario:**
1. Launch app
2. Navigate to chat
3. Send message
4. Wait 3 segundos (para que falle la conexión)
5. Verify error message appears
6. Verify "Reintentar" button visible

---

## 3. Errores RED Identificados

### 🔴 Error #1: Widget "Nuevo Proyecto" Not Found

**Error:**
```
The finder "Found 0 widgets with text "Nuevo Proyecto": []"
could not find any matching widgets.
```

**Causa:** El widget SoftArchitectApp no renderiza un botón con ese texto en la pantalla principal.

**Ubicación:** `src/client/lib/main.dart` → `SoftArchitectApp` (Presentation Layer)

**Qué Falta:**
- [ ] Main navigation screen con botón "Nuevo Proyecto"
- [ ] Router configuration para navegar a chat screen
- [ ] La pantalla inicial no existe o no tiene este botón

---

### 🔴 Error #2: LateInitializationError (Database Initialization)

**Error:**
```
LateInitializationError: Field 'isWeb' has already been initialized.
```

**Causa:** Al ejecutar dos tests seguidos, `initializeSqfliteForDesktop()` intenta inicializar `isWeb` dos veces.

**Ubicación:** `src/client/lib/core/database_initializer.dart` (Late field)

**Qué Falta:**
- [ ] Setup/Teardown logic para tests que resetee el estado de late fields
- [ ] Singleton pattern para evitar reinicialización
- [ ] Test harness que isole cada test

---

### 🔴 Error #3-#6: Missing TextField y Input Handling

**Problema:** El test busca un `TextField` en la UI para ingresar el prompt.

**Qué Falta:**
- [ ] Chat input widget (TextField + send button)
- [ ] Input handling en ChatNotifier
- [ ] Integration entre UI input → backend request

---

### 🔴 Error #7-#9: Missing Backend API Integration

**Problema:** No existe backend API conectada con el frontend.

**Qué Falta:**
- [ ] Backend FastAPI running (en `src/server/main.py`)
- [ ] `/api/v1/chat/stream` endpoint (POST)
- [ ] RAG service integration (LLM streaming)
- [ ] Request serialization (DTOs)
- [ ] HTTP client in frontend (`http` package or similar)

---

### 🔴 Error #10: Missing ProposalCardWidget Rendering

**Problema:** El widget no aparece después del streaming completado.

**Qué Falta:**
- [ ] ChatNotifier debe emitir estado con `currentProposal` no null
- [ ] Presentation layer debe renderizar ProposalCardWidget cuando `state.currentProposal != null`
- [ ] Streaming debe parsear respuesta y crear DocumentProposal entity

---

### 🔴 Error #11: Missing "Validar y Guardar" Button

**Problema:** El botón para validar y guardar proposal no existe.

**Qué Falta:**
- [ ] ProposalCardWidget debe tener botón "Validar y Guardar"
- [ ] Handler onPressed que llame a `validateAndSaveProposal()` en ChatNotifier

---

### 🔴 Error #12: Missing Toast Component

**Error:**
```
expect(find.text('✅ Documento guardado'), findsOneWidget);
```

**Problema:** No existe toast/snackbar que muestre éxito.

**Qué Falta:**
- [ ] Toast/Snackbar component (UI)
- [ ] Handler que dispare toast cuando documento se guarda exitosamente
- [ ] Integration con FileSystem

---

### 🔴 Error #13: Missing Progress Display

**Error:**
```
expect(find.text('Doc 2/25'), findsOneWidget);
```

**Problema:** No existe contador de documentos generados.

**Qué Falta:**
- [ ] Progress widget en chat screen que muestre "Doc X/25"
- [ ] ChatNotifier debe trackear `completedDocuments` y `totalDocuments`
- [ ] UI debe actualizar en tiempo real

---

## 4. Análisis de Gaps

### 🏗️ Arquitectura Faltante

```
BACKEND (Python FastAPI)
  ├── ❌ /api/v1/chat/stream endpoint
  ├── ❌ RAG service (Ollama integration)
  ├── ❌ Prompt sanitization
  ├── ❌ Document generation logic
  └── ❌ FileSystem writer

FRONTEND (Flutter)
  ├── ❌ HTTP Client (for API calls)
  ├── ❌ Navigation structure
  ├── ❌ Chat input widget
  ├── ❌ Toast/Snackbar component
  ├── ❌ Progress display widget
  └── ❌ ChatNotifier enhancements (streaming handler)

INTEGRATION POINTS
  ├── ❌ Environment config (backend URL)
  ├── ❌ Error handling (network + backend errors)
  ├── ❌ State serialization (JSON ↔ Dart objects)
  └── ❌ FileSystem operations
```

### 📋 Dependencias por Implementar

**Order of Implementation (Critical Path):**

1. **Backend API Setup** ← BLOCKER
   - FastAPI server debe correr en `http://localhost:8000`
   - `/api/v1/chat/stream` endpoint (Server-Sent Events o WebSocket)

2. **Frontend HTTP Client** ← BLOCKER
   - `http` package o `dio` para requests HTTP
   - Streaming handler para SSE/WebSocket

3. **ChatNotifier Enhancement** ← BLOCKER
   - `sendMessage()` debe hacer HTTP request al backend
   - Stream handler que parseea respuesta
   - `validateAndSaveProposal()` method

4. **Navigation Structure**
   - Main screen con botón "Nuevo Proyecto"
   - Navigate to chat screen

5. **Chat Input Widget**
   - TextField + send button
   - Input validation

6. **UI Components**
   - Toast/Snackbar
   - Progress counter
   - Error message display

---

## 5. Checklist de Implementación (GREEN)

### ✅ Backend Layer (Python FastAPI)

- [ ] Create `src/server/api/v1/endpoints/chat.py`
  - [ ] `POST /api/v1/chat/stream` endpoint
  - [ ] Request validation (message: str)
  - [ ] Response streaming (SSE or WebSocket)
  - [ ] Error handling (return 500 + error message)

- [ ] Create `src/server/services/rag/chat_service.py`
  - [ ] `query()` method that calls Ollama
  - [ ] Response parsing
  - [ ] Token-by-token streaming

- [ ] Create `src/server/services/filesystem/writer.py`
  - [ ] `save_document()` method
  - [ ] File validation
  - [ ] Directory creation

### ✅ Frontend Data Layer

- [ ] Create `src/client/lib/features/chat/data/datasources/chat_remote_datasource.dart`
  - [ ] HTTP client initialization
  - [ ] `streamMessage()` method
  - [ ] Error handling

- [ ] Create `src/client/lib/features/chat/data/repositories/chat_repository_impl.dart`
  - [ ] Implement `ChatRepository` with HTTP calls
  - [ ] Stream handling

### ✅ Frontend Presentation Layer

- [ ] Create `src/client/lib/features/chat/presentation/widgets/chat_input_widget.dart`
  - [ ] TextField
  - [ ] Send button
  - [ ] Input validation

- [ ] Create `src/client/lib/features/chat/presentation/widgets/chat_screen.dart`
  - [ ] Build main chat interface
  - [ ] Render message bubbles
  - [ ] Render proposals

- [ ] Enhance `ChatNotifier`
  - [ ] Update `sendMessage()` to call API
  - [ ] Implement streaming handler
  - [ ] Add `validateAndSaveProposal()` method
  - [ ] Add progress tracking

- [ ] Create `src/client/lib/core/widgets/toast_widget.dart`
  - [ ] Show success/error toast
  - [ ] Auto-dismiss after 3 seconds

- [ ] Create `src/client/lib/core/widgets/progress_counter_widget.dart`
  - [ ] Display "Doc X/25"
  - [ ] Update in real-time

### ✅ Navigation

- [ ] Update `src/client/lib/core/router/app_router.dart`
  - [ ] Define routes (home, chat, etc.)
  - [ ] Navigation handlers

- [ ] Create home screen
  - [ ] "Nuevo Proyecto" button
  - [ ] Navigate to chat on tap

### ✅ Configuration

- [ ] Create/Update `.env` file
  - [ ] `BACKEND_URL=http://localhost:8000`
  - [ ] `API_TIMEOUT=30s`

- [ ] Update `src/client/lib/core/config/app_config.dart`
  - [ ] Read backend URL from env
  - [ ] Expose as provider

### ✅ Testing Infrastructure

- [ ] Create test setup/teardown
  - [ ] Mock backend (mockito or dio_mock)
  - [ ] Reset late fields between tests
  - [ ] Database cleanup

- [ ] Create `tests/test/integration/fixtures/`
  - [ ] Sample streaming responses
  - [ ] Error scenarios

---

## 📊 Next Phase: VERDE (GREEN)

**Cuando todas las checklist items estén ✅:**

```
Integration Tests: 2
  ✅ Passing: 2/2
  ❌ Failing: 0/2

Full E2E Flow Working:
  ✅ User input → ChatNotifier
  ✅ ChatNotifier → Backend API
  ✅ Backend → LLM (Ollama)
  ✅ LLM → Response streaming
  ✅ Response → UI update
  ✅ Validation → FileSystem save
  ✅ FileSystem → Success notification
```

---

## 🔗 Referencias

- HU-3.2: Document Sequential Generation with Backend Integration
- AGENTS.md: Testing & QA section (TDD workflow)
- `context/30-ARCHITECTURE/TECHNICAL_STACK.en.md`: FastAPI + Flutter integration

---

**Autor:** ArchitectZero (AI Agent)
**Estado:** 🔴 RED - Ready for GREEN phase
**Próximo:** Implement Backend `/api/v1/chat/stream` endpoint
