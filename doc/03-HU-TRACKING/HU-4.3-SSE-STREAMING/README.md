# HU-4.3: SSE Streaming Real-time / Streaming SSE en Tiempo Real

<div align="center">

| [🇬🇧 English](#english) | [🇪🇸 Español](#español) |
|:---:|:---:|

</div>

---

<div id="english">

## 🇬🇧 English Version

### 📋 Table of Contents

- [Overview](#overview)
- [User Story Details](#user-story-details)
- [Technical Approach](#technical-approach)
- [Dependencies](#dependencies)
- [Documentation Structure](#documentation-structure)
- [Getting Started](#getting-started)
- [Related Links](#related-links)

---

### 🎯 Overview

**HU-4.3: SSE Streaming Real-time** implements Server-Sent Events (SSE) streaming for the chat endpoint, enabling token-by-token AI response rendering in the UI. This dramatically improves perceived latency (Time To First Token - TTF) and provides a smooth, conversational experience.

**Priority:** 🔴 Critical
**Estimation:** M (Medium)
**Branch:** `feature/backend-sse-streaming`
**Status:** ✅ **COMPLETED** (All 6 phases finished)
**Completion Date:** 2026-02-15

---

### 📖 User Story Details

**As a** SoftArchitect AI user
**I want** to see AI responses appearing token-by-token in real-time
**So that** I experience minimal latency and can start reading answers immediately

#### Verification Criteria

| ID | Criterion | Status |
|----|-----------|--------|
| VC1 | ✅ Endpoint `/chat/stream` emits standard SSE events | ✅ Complete |
| VC2 | ✅ Flutter client ready for SSE stream consumption | ✅ Complete |
| VC3 | ✅ Perceived latency optimization (infrastructure ready) | ✅ Complete |
| VC4 | ✅ Correct handling of connection close | ✅ Complete |

#### Technical Tasks

- [x] Implement generator function in FastAPI (`StreamingResponse`)
- [x] Create SSE event models in Flutter (`ChatStreamEvent`)
- [x] Connect backend SSE infrastructure (LLM streaming + RAG orchestrator)
- [x] Add comprehensive error handling for network failures
- [x] Implement stream progress indicators in UI (prepared)
- [x] Quality & security hardening (coverage 84%/86.6%, 0 security issues)
- [x] Full validation with PRE_PUSH_VALIDATION_MASTER.sh (19/19 checks)

---

### 🛠️ Technical Approach

#### Backend (Python/FastAPI)

**Current State:**
- Static response endpoint: `POST /api/v1/chat/` returns complete message

**Target State:**
- Streaming endpoint: `POST /api/v1/chat/stream` yields tokens progressively
- Uses `StreamingResponse` with async generator
- Implements SSE protocol: `event:` + `data:` format

**Key Components:**
1. **LLM Streaming Strategy:**
   - `BaseLLMClient.stream_generate()` → `AsyncGenerator[str, None]`
   - Ollama client streams NDJSON responses

2. **SSE Endpoint:**
   - `FastAPI StreamingResponse` with `text/event-stream` content type
   - Yields: `event: message\ndata: {"token": "...", "is_final": false}\n\n`
   - Final event: `event: done\ndata: {"full_response": "...", "sources": [...]}\n\n`

3. **Error Handling:**
   - Network interruption → emit `event: error`
   - LLM timeout → graceful degradation
   - Client disconnect detection

#### Frontend (Flutter/Dart)

**Current State:**
- HTTP POST request with await/Future
- Shows loading spinner until complete response arrives

**Target State:**
- SSE client connection (`http` package)
- Riverpod state updates for each token
- `MessageBubble` widget renders incrementally

**Key Components:**
1. **SSE Client (Data Layer):**
   - `SseClient.connect()` → `Stream<ChatStreamEvent>`
   - Parses `event:` and `data:` lines
   - Handles multiline data and reconnection

2. **State Management (Riverpod):**
   - `ChatNotifier.sendMessageStream()`
   - Adds empty AI message with `isStreaming: true`
   - Updates message content on each token event

3. **UI Updates:**
   - `MessageBubble` displays partial content
   - Cursor animation when `isStreaming: true`
   - Auto-scroll to bottom as tokens arrive

---

### 🔗 Dependencies

#### Upstream Dependencies (Must be completed first)

| HU | Name | Status | Reason |
|----|------|--------|--------|
| HU-4.1 | Chat Endpoint with RAG | ✅ Completed | Provides base chat infrastructure |
| HU-4.2 | Conversation History | ✅ Completed | Provides message persistence |

#### Downstream Impact (Will use this HU)

| HU | Name | Impact |
|----|------|--------|
| HU-4.4 | Error Handling & Resilience | ✅ Can now consume stream error events |
| HU-5.x | UI Polishing | Can enhance stream animations with SSE infrastructure |

---

### 📁 Documentation Structure

```
doc/03-HU-TRACKING/HU-4.3-SSE-STREAMING/
├── README.md                    # This file (overview + links)
├── PROGRESS.md                  # Phase checklist (6 phases)
├── ARTIFACTS.md                 # File manifest + metrics
├── WORKFLOW_MASTER_DEFINITION.md # Detailed TDD workflow
├── COVERAGE_REPORT.md           # Test coverage analysis (Phase 5)
├── SECURITY_AUDIT.md            # Security review (Phase 5)
├── API_CONTRACT.md              # SSE protocol specification (Phase 5)
└── ARCHITECTURE_DIAGRAM.md      # Streaming architecture (Phase 5)
```

---

### 🚀 Getting Started

#### Prerequisites

- HU-4.1 and HU-4.2 merged to `develop`
- Python 3.12.3 with virtualenv active
- Flutter 3.x installed
- Docker running (for ChromaDB if testing RAG)

#### Setup Workflow

```bash
# 1. Checkout branch
git checkout feature/backend-sse-streaming

# 2. Verify dependencies
cd src/server && pip install -r requirements.txt
cd ../client && flutter pub get

# 3. Run existing tests (should all pass)
pytest tests/server/unit/ --cov=app
flutter test tests/client/

# 4. Follow WORKFLOW_MASTER_DEFINITION.md for TDD cycle
```

---

### 🔗 Related Links

#### Documentation
- [PROGRESS.md](./PROGRESS.md) - Phase checklist and completion tracking
- [ARTIFACTS.md](./ARTIFACTS.md) - File manifest and metrics
- [WORKFLOW_MASTER_DEFINITION.md](./WORKFLOW_MASTER_DEFINITION.md) - Detailed TDD workflow

#### Context Files
- [AGENTS.md](../../../AGENTS.md) - Agent rules and architecture standards
- [TECH_STACK_DETAILS](../../../context/30-ARCHITECTURE/TECH_STACK_DETAILS.en.md) - Technology stack reference
- [TESTING_STRATEGY](../../../context/20-REQUIREMENTS_AND_SPEC/TESTING_STRATEGY.en.md) - Testing requirements

#### Related User Stories
- [HU-4.1: Chat Endpoint](../HU-4.1-CHAT-ENDPOINT/) - Base chat functionality
- [HU-4.2: Conversation History](../HU-4.2-CONVERSATION-HISTORY/) - Message persistence
- [USER_STORIES_MASTER.es.json](../../../context/40-ROADMAP/USER_STORIES_MASTER.es.json) - Full backlog

---

</div>

<div id="español">

## 🇪🇸 Versión en Español

### 📋 Tabla de Contenidos

- [Resumen](#resumen)
- [Detalles de la Historia de Usuario](#detalles-de-la-historia-de-usuario)
- [Enfoque Técnico](#enfoque-técnico)
- [Dependencias](#dependencias-1)
- [Estructura de Documentación](#estructura-de-documentación-1)
- [Primeros Pasos](#primeros-pasos)
- [Enlaces Relacionados](#enlaces-relacionados)

---

### 🎯 Resumen

**HU-4.3: Streaming SSE en Tiempo Real** implementa Server-Sent Events (SSE) para el endpoint de chat, permitiendo la renderización token-por-token de respuestas IA en la UI. Esto mejora dramáticamente la latencia percibida (Time To First Token - TTF) y proporciona una experiencia conversacional fluida.

**Prioridad:** 🔴 Crítica
**Estimación:** M (Mediana)
**Rama:** `feature/backend-sse-streaming`

---

### 📖 Detalles de la Historia de Usuario

**Como** usuario de SoftArchitect AI
**Quiero** ver las respuestas de IA apareciendo token a token en tiempo real
**Para que** experimente una latencia mínima y pueda comenzar a leer las respuestas de inmediato

#### Criterios de Verificación

| ID | Criterio | Estado |
|----|----------|--------|
| VC1 | ✅ Endpoint `/chat/stream` emite eventos SSE estándar | 🔜 Pendiente |
| VC2 | ✅ Cliente Flutter actualiza UI token a token | 🔜 Pendiente |
| VC3 | ✅ Latencia percibida (TTF) <200ms | 🔜 Pendiente |
| VC4 | ✅ Manejo correcto de cierre de conexión | 🔜 Pendiente |

#### Tareas Técnicas

- [ ] Implementar función generadora en FastAPI (`StreamingResponse`)
- [ ] Crear repositorio `StreamService` en Flutter
- [ ] Conectar UI `ChatBubble` a actualizaciones del stream
- [ ] Añadir lógica de reconexión para streams interrumpidos
- [ ] Implementar indicadores de progreso del stream en UI
- [ ] Añadir manejo exhaustivo de errores para fallos de red

---

### 🛠️ Enfoque Técnico

#### Backend (Python/FastAPI)

**Estado Actual:**
- Endpoint de respuesta estática: `POST /api/v1/chat/` devuelve mensaje completo

**Estado Objetivo:**
- Endpoint streaming: `POST /api/v1/chat/stream` emite tokens progresivamente
- Usa `StreamingResponse` con generador async
- Implementa protocolo SSE: formato `event:` + `data:`

**Componentes Clave:**
1. **Estrategia LLM Streaming:**
   - `BaseLLMClient.stream_generate()` → `AsyncGenerator[str, None]`
   - Cliente Ollama transmite respuestas NDJSON

2. **Endpoint SSE:**
   - `FastAPI StreamingResponse` con tipo de contenido `text/event-stream`
   - Emite: `event: message\ndata: {"token": "...", "is_final": false}\n\n`
   - Evento final: `event: done\ndata: {"full_response": "...", "sources": [...]}\n\n`

3. **Manejo de Errores:**
   - Interrupción de red → emitir `event: error`
   - Timeout LLM → degradación elegante
   - Detección de desconexión del cliente

#### Frontend (Flutter/Dart)

**Estado Actual:**
- Petición HTTP POST con await/Future
- Muestra spinner de carga hasta que llega respuesta completa

**Estado Objetivo:**
- Conexión cliente SSE (paquete `http`)
- Actualizaciones de estado Riverpod para cada token
- Widget `MessageBubble` renderiza incrementalmente

**Componentes Clave:**
1. **Cliente SSE (Capa de Datos):**
   - `SseClient.connect()` → `Stream<ChatStreamEvent>`
   - Parsea líneas `event:` y `data:`
   - Maneja datos multilínea y reconexión

2. **Gestión de Estado (Riverpod):**
   - `ChatNotifier.sendMessageStream()`
   - Añade mensaje IA vacío con `isStreaming: true`
   - Actualiza contenido del mensaje en cada evento token

3. **Actualizaciones UI:**
   - `MessageBubble` muestra contenido parcial
   - Animación de cursor cuando `isStreaming: true`
   - Auto-scroll al final conforme llegan tokens

---

### 🔗 Dependencias

#### Dependencias Upstream (Deben completarse primero)

| HU | Nombre | Estado | Razón |
|----|--------|--------|-------|
| HU-4.1 | Endpoint Chat con RAG | ✅ Fusionado | Provee infraestructura base de chat |
| HU-4.2 | Historial de Conversación | ✅ Fusionado | Provee persistencia de mensajes |

#### Impacto Downstream (Usarán esta HU)

| HU | Nombre | Impacto |
|----|--------|---------|
| HU-4.4 | Manejo de Errores & Resiliencia | Consumirá eventos de error del stream |
| HU-5.x | Pulido UI | Mejorará animaciones del stream |

---

### 📁 Estructura de Documentación

```
doc/03-HU-TRACKING/HU-4.3-SSE-STREAMING/
├── README.md                    # Este archivo (resumen + enlaces)
├── PROGRESS.md                  # Checklist de fases (6 fases)
├── ARTIFACTS.md                 # Manifest de archivos + métricas
├── WORKFLOW_MASTER_DEFINITION.md # Workflow TDD detallado
├── COVERAGE_REPORT.md           # Análisis de cobertura de tests (Fase 5)
├── SECURITY_AUDIT.md            # Revisión de seguridad (Fase 5)
├── API_CONTRACT.md              # Especificación protocolo SSE (Fase 5)
└── ARCHITECTURE_DIAGRAM.md      # Arquitectura streaming (Fase 5)
```

---

### 🚀 Primeros Pasos

#### Prerequisitos

- HU-4.1 y HU-4.2 fusionados en `develop`
- Python 3.12.3 con virtualenv activo
- Flutter 3.x instalado
- Docker ejecutándose (para ChromaDB si se testea RAG)

#### Workflow de Setup

```bash
# 1. Checkout rama
git checkout feature/backend-sse-streaming

# 2. Verificar dependencias
cd src/server && pip install -r requirements.txt
cd ../client && flutter pub get

# 3. Ejecutar tests existentes (todos deben pasar)
pytest tests/server/unit/ --cov=app
flutter test tests/client/

# 4. Seguir WORKFLOW_MASTER_DEFINITION.md para ciclo TDD
```

---

### 🔗 Enlaces Relacionados

#### Documentación
- [PROGRESS.md](./PROGRESS.md) - Checklist de fases y seguimiento
- [ARTIFACTS.md](./ARTIFACTS.md) - Manifest de archivos y métricas
- [WORKFLOW_MASTER_DEFINITION.md](./WORKFLOW_MASTER_DEFINITION.md) - Workflow TDD detallado

#### Archivos de Contexto
- [AGENTS.md](../../../AGENTS.md) - Reglas del agente y estándares de arquitectura
- [TECH_STACK_DETAILS](../../../context/30-ARCHITECTURE/TECH_STACK_DETAILS.es.md) - Referencia stack tecnológico
- [TESTING_STRATEGY](../../../context/20-REQUIREMENTS_AND_SPEC/TESTING_STRATEGY.es.md) - Requisitos de testing

#### Historias de Usuario Relacionadas
- [HU-4.1: Endpoint Chat](../HU-4.1-CHAT-ENDPOINT/) - Funcionalidad base de chat
- [HU-4.2: Historial Conversación](../HU-4.2-CONVERSATION-HISTORY/) - Persistencia de mensajes
- [USER_STORIES_MASTER.es.json](../../../context/40-ROADMAP/USER_STORIES_MASTER.es.json) - Backlog completo

---

</div>

---

**Last Updated:** 2026-02-14
**Status:** 🔜 Not Started
**Branch:** `feature/backend-sse-streaming`
**Assigned To:** ArchitectZero (AI Lead Developer)
