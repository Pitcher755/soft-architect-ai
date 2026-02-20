# 🔴 FASE 5: Integración The Gate (TDD RED)

> **Fecha:** 6 de febrero de 2026
> **Estado:** 🔴 RED - Prueba Failing (13 errores identificados)
> **Objetivo:** Conectar Frontend → Backend → ArchivoSystem (HU-3.2)

---

## 📋 Tabla de Contenidos

- [1. Resumen Ejecutivo](#1-resumen-ejecutivo)
- [2. Prueba de Integración Creado](#2-prueba-de-integración-creado)
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

## 2. Prueba de Integración Creado

### 📝 Archivo

**Ubicación:** `pruebas/prueba/integration/features/chat/chat_flow_prueba.dart`

### 🧪 Casos de Prueba

#### Prueba 1: `should complete full documento generation cycle`

**Escenario:**
1. Launch app
2. Navigate to "Nuevo Proyecto" (chat screen)
3. Enter prompt: "Genera el Proyecto Manifesto"
4. Wait for streaming (5 segundos)
5. Validate proposal widget appears
6. Tap "Validar y Guardar"
7. Verify success toast + progress counter

#### Prueba 2: `should handle streaming errors gracefully`

**Escenario:**
1. Launch app
2. Navigate to chat
3. Send message
4. Wait 3 segundos (para que falle la conexión)
5. Verify error message appears
6. Verify "Reintentar" botón visible

---

## 3. Errores RED Identificados

### 🔴 Error #1: Widget "Nuevo Proyecto" Not Found

**Error:**
```
The finder "Found 0 widgets with text "Nuevo Proyecto": []"
could not find any matching widgets.
```

**Causa:** El widget SoftArchitectApp no renderiza un botón con ese texto en la pantalla principal.

**Ubicación:** `src/client/lib/main.dart` → `SoftArchitectApp` (Presentación Layer)

**Qué Falta:**
- [ ] Main navigation screen con botón "Nuevo Proyecto"
- [ ] Router configuración para navegar a chat screen
- [ ] La pantalla inicial no existe o no tiene este botón

---

### 🔴 Error #2: LateInitializationError (Database Initialization)

**Error:**
```
LateInitializationError: Field 'isWeb' has already been initialized.
```

**Causa:** Al ejecutar dos pruebas seguidos, `initializeSqfliteForDesktop()` intenta inicializar `isWeb` dos veces.

**Ubicación:** `src/client/lib/core/database_initializer.dart` (Late field)

**Qué Falta:**
- [ ] Setup/Teardown logic para pruebas que resetee el estado de late fields
- [ ] Singleton pattern para evitar reinicialización
- [ ] Prueba harness que isole cada prueba

---

### 🔴 Error #3-#6: Missing TextField y Input Handling

**Problema:** El prueba busca un `TextField` en la UI para ingresar el prompt.

**Qué Falta:**
- [ ] Chat input widget (TextField + send botón)
- [ ] Input handling en ChatNotifier
- [ ] Integración entre UI input → backend request

---

### 🔴 Error #7-#9: Missing Backend API Integración

**Problema:** No existe backend API conectada con el frontend.

**Qué Falta:**
- [ ] Backend FastAPI ejecutarning (en `src/server/main.py`)
- [ ] `/api/v1/chat/stream` endpoint (POST)
- [ ] RAG service integration (LLM streaming)
- [ ] Request serialization (DTOs)
- [ ] HTTP client in frontend (`http` package or similar)

---

### 🔴 Error #10: Missing ProposalCardWidget Rendering

**Problema:** El widget no aparece después del streaming completado.

**Qué Falta:**
- [ ] ChatNotifier debe emitir estado con `currentProposal` no null
- [ ] Presentación layer debe renderizar ProposalCardWidget cuando `state.currentProposal != null`
- [ ] Streaming debe parsear respuesta y crear DocumentoProposal entity

---

### 🔴 Error #11: Missing "Validar y Guardar" Botón

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
- [ ] Handler que dispare toast cuando documentoo se guarda exitosamente
- [ ] Integración con ArchivoSystem

---

### 🔴 Error #13: Missing Progress Display

**Error:**
```
expect(find.text('Doc 2/25'), findsOneWidget);
```

**Problema:** No existe contador de documentoos generados.

**Qué Falta:**
- [ ] Progress widget en chat screen que muestre "Doc X/25"
- [ ] ChatNotifier debe trackear `completedDocumentos` y `totalDocumentos`
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

**Order of Implementación (Critical Path):**

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
   - TextField + send botón
   - Input validation

6. **UI Components**
   - Toast/Snackbar
   - Progress counter
   - Error message display

---

## 5. Checklist de Implementación (GREEN)

### ✅ Backend Layer (Python FastAPI)

- [ ] Crear `src/server/api/v1/endpoints/chat.py`
  - [ ] `POST /api/v1/chat/stream` endpoint
  - [ ] Request validation (message: str)
  - [ ] Response streaming (SSE or WebSocket)
  - [ ] Error handling (return 500 + error message)

- [ ] Crear `src/server/services/rag/chat_service.py`
  - [ ] `query()` method that calls Ollama
  - [ ] Response parsing
  - [ ] Token-by-token streaming

- [ ] Crear `src/server/services/archivosystem/writer.py`
  - [ ] `save_documento()` method
  - [ ] Archivo validation
  - [ ] Directory creation

### ✅ Frontend Data Layer

- [ ] Crear `src/client/lib/features/chat/data/datasources/chat_remote_datasource.dart`
  - [ ] HTTP client initialization
  - [ ] `streamMessage()` method
  - [ ] Error handling

- [ ] Crear `src/client/lib/features/chat/data/repositories/chat_repository_impl.dart`
  - [ ] Implement `ChatRepository` with HTTP calls
  - [ ] Stream handling

### ✅ Frontend Presentación Layer

- [ ] Crear `src/client/lib/features/chat/presentation/widgets/chat_input_widget.dart`
  - [ ] TextField
  - [ ] Send botón
  - [ ] Input validation

- [ ] Crear `src/client/lib/features/chat/presentation/widgets/chat_screen.dart`
  - [ ] Build main chat interface
  - [ ] Render message bubbles
  - [ ] Render proposals

- [ ] Enhance `ChatNotifier`
  - [ ] Update `sendMessage()` to call API
  - [ ] Implement streaming handler
  - [ ] Add `validateAndSaveProposal()` method
  - [ ] Add progress tracking

- [ ] Crear `src/client/lib/core/widgets/toast_widget.dart`
  - [ ] Show success/error toast
  - [ ] Auto-dismiss after 3 seconds

- [ ] Crear `src/client/lib/core/widgets/progress_counter_widget.dart`
  - [ ] Display "Doc X/25"
  - [ ] Update in real-time

### ✅ Navigation

- [ ] Update `src/client/lib/core/router/app_router.dart`
  - [ ] Define routes (home, chat, etc.)
  - [ ] Navigation handlers

- [ ] Crear home screen
  - [ ] "Nuevo Proyecto" botón
  - [ ] Navigate to chat on tap

### ✅ Configuración

- [ ] Crear/Update `.env` archivo
  - [ ] `BACKEND_URL=http://localhost:8000`
  - [ ] `API_TIMEOUT=30s`

- [ ] Update `src/client/lib/core/config/app_config.dart`
  - [ ] Read backend URL from env
  - [ ] Expose as provider

### ✅ Pruebaing Infraestructura

- [ ] Crear prueba setup/teardown
  - [ ] Mock backend (mockito or dio_mock)
  - [ ] Reset late fields between pruebas
  - [ ] Database cleanup

- [ ] Crear `pruebas/prueba/integration/fixtures/`
  - [ ] Sample streaming responses
  - [ ] Error scenarios

---

## 📊 Siguiente Fase: VERDE (GREEN)

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

- HU-3.2: Documento Sequential Generation with Backend Integración
- AGENTS.md: Pruebaing & QA section (TDD workflow)
- `context/30-ARCHITECTURE/TECHNICAL_STACK.en.md`: FastAPI + Flutter integration

---

**Autor:** ArchitectZero (AI Agent)
**Estado:** 🔴 RED - Preparado para GREEN fase
**Próximo:** Implement Backend `/api/v1/chat/stream` endpoint
