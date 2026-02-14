# 🧠 HU-4.1: Backend Chat Endpoint & RAG Orchestration

> **Sprint:** S4 - Inteligencia Artificial y Chat (The Brain)
> **Epic:** E4 - Backend IA & RAG
> **Status:** ✅ Completed (Validation 19/19 passed)
> **Priority:** 🔴 Critical
> **Estimation:** L (Large)
> **Branch:** `feature/backend-chat-endpoint`

---

## 🌍 Language / Idioma

<table>
<tr>
<td width="50%" align="center">
<a href="#english"><b>🇬🇧 English</b></a>
</td>
<td width="50%" align="center">
<a href="#español"><b>🇪🇸 Español</b></a>
</td>
</tr>
</table>

---

<div id="english">

## 📋 English Version

### 📖 Table of Contents
- [Objective](#objective)
- [Description](#description)
- [Dependencies](#dependencies)
- [Verification Criteria](#verification-criteria)
- [Technical Tasks](#technical-tasks)
- [Tech Stack](#tech-stack)
- [Related Documentation](#related-documentation)

---

### 🎯 Objective

Implement **POST /api/v1/chat/message** endpoint with integrated RAG (Retrieval-Augmented Generation) orchestration. This is the **core AI engine** that connects ChromaDB vector store, dynamic template injection, and LLM clients (Ollama local / Groq cloud) to provide intelligent, context-aware responses to user queries.

**This is the most critical endpoint of the project** - it's the bridge between the user interface and the AI brain.

---

### 📝 Description

#### Functional Requirements

The endpoint must:
1. **Receive** chat requests with `conversation_id`, `message`, and `project_id`
2. **Retrieve** relevant knowledge fragments from ChromaDB based on user query
3. **Select** the appropriate template based on current project phase
4. **Inject** RAG context + user input into the template
5. **Call** LLM (Ollama or Groq) with constructed prompt
6. **Return** AI response with metadata (template used, sources)

#### Non-Functional Requirements

- **Response time:** <500ms (non-streaming mode)
- **Security:** Input sanitization (prevent prompt injection, XSS)
- **Resilience:** Retry mechanism for LLM failures (3x with backoff)
- **Observability:** Structured logging with request ID tracing
- **Modularity:** Strategy pattern for LLM clients (easy to swap Ollama ↔ Groq)

---

### 🔗 Dependencies

| Dependency | Status | Notes |
|------------|--------|-------|
| **HU-2.2** (RAG Vectorization) | ✅ Complete | ChromaDB ingestion pipeline ready |
| ChromaDB Service | ✅ Running | Docker container healthy |
| Ollama (Local LLM) | ⚠️ Manual Setup | Must be installed on host |

---

### ✅ Verification Criteria

#### Functional Tests
- ✅ **POST /chat/message** responds in <500ms (non-streaming mode)
- ✅ System retrieves relevant fragments from ChromaDB (RAG query works)
- ✅ Template injection works correctly based on project phase
- ✅ Supports `ollama` (local) mode
- ✅ Prepared for `groq` (cloud) mode (config flag ready)

#### Quality Gates
- ✅ **Unit tests** for RAG orchestrator >90% coverage
- ✅ **Unit tests** for template loader >90% coverage
- ✅ **Integration tests** for E2E endpoint >80% coverage
- ✅ **Security tests** for prompt injection prevention
- ✅ **Type safety:** 0 Pyright errors
- ✅ **Code formatting:** Black compliant
- ✅ **Linting:** Ruff passes

---

### 🔧 Technical Tasks

#### Phase 1: Domain & Security (TDD Red)
- [x] Define Pydantic schemas (`ChatRequest`, `ChatResponse`)
- [x] Implement input sanitization (HTML tags, length limits)
- [x] Write validation tests (XSS, prompt injection, DOS prevention)

#### Phase 2: Infrastructure (TDD Green)
- [x] Implement `BaseLLMClient` abstract class (Strategy pattern)
- [x] Create `OllamaClient` implementation
- [x] Create `GroqClient` stub (ready for future integration)
- [x] Write unit tests for LLM clients (mock external calls)

#### Phase 3: RAG Orchestrator (TDD Refactor)
- [x] Implement `RAGOrchestrator` service
  - [x] Vector search integration
  - [x] Template builder integration
  - [x] Context injection logic
  - [x] LLM client invocation
- [x] Write unit tests for orchestration logic

#### Phase 4: FastAPI Endpoint
- [x] Implement `/api/v1/chat/message` POST route
- [x] Add dependency injection for `RAGOrchestrator`
- [x] Implement error handling (custom exceptions)
- [x] Write integration tests (E2E with mocked LLM)

#### Phase 5: Quality & Security Hardening
- [x] Security audit (Bandit scan)
- [x] Performance profiling (<500ms target)
- [x] Error scenarios testing (connection failures, timeouts)
- [x] Documentation (API docs, architecture diagrams)

#### Phase 6: Validation & PR
- [x] Run `./scripts/testing/PRE_PUSH_VALIDATION_MASTER.sh`
- [ ] Verify all GitHub Actions pass
- [x] Update tracking documentation
- [ ] Open PR to `develop`

---

### 🛠️ Tech Stack

| Component | Technology | Purpose |
|-----------|-----------|---------|
| **Endpoint** | FastAPI | REST API framework |
| **Orchestration** | LangChain | RAG pipeline coordination |
| **Vector DB** | ChromaDB | Semantic search retrieval |
| **LLM (Local)** | Ollama | Open-source local inference |
| **LLM (Cloud)** | Groq | Fast cloud inference (future) |
| **Validation** | Pydantic | Input sanitization & type safety |
| **Testing** | pytest | Unit + integration tests |
| **Type Checking** | Pyright | Static type analysis |

---

### 📚 Related Documentation

**Workflow & Procedures:**
- [WORKFLOW_MASTER_DEFINITION.md](./WORKFLOW_MASTER_DEFINITION.md) - Complete TDD workflow
- [PROGRESS.md](./PROGRESS.md) - Phase tracking checklist
- [ARTIFACTS.md](./ARTIFACTS.md) - Files manifest

**Architecture:**
- [context/30-ARCHITECTURE/RAG_ARCHITECTURE_AND_FLOW.en.md](../../../context/30-ARCHITECTURE/RAG_ARCHITECTURE_AND_FLOW.en.md)
- [context/30-ARCHITECTURE/API_INTERFACE_CONTRACT.en.md](../../../context/30-ARCHITECTURE/API_INTERFACE_CONTRACT.en.md)

**Security:**
- [context/SECURITY_HARDENING_POLICY.en.md](../../../context/SECURITY_HARDENING_POLICY.en.md)
- [AGENTS.md](../../../AGENTS.md#-8-reglas-estrictas-de-cicd-pipeline-mandatory) - CI/CD rules

**User Stories:**
- [context/40-ROADMAP/USER_STORIES_MASTER.en.json](../../../context/40-ROADMAP/USER_STORIES_MASTER.en.json)

---

</div>

<div id="español">

## 📋 Versión en Español

### 📖 Tabla de Contenidos
- [Objetivo](#objetivo-1)
- [Descripción](#descripción-1)
- [Dependencias](#dependencias-1)
- [Criterios de Verificación](#criterios-de-verificación-1)
- [Tareas Técnicas](#tareas-técnicas-1)
- [Stack Tecnológico](#stack-tecnológico-1)
- [Documentación Relacionada](#documentación-relacionada-1)

---

### 🎯 Objetivo

Implementar el endpoint **POST /api/v1/chat/message** con orquestación RAG (Retrieval-Augmented Generation) integrada. Este es el **motor central de IA** que conecta la base de datos vectorial ChromaDB, inyección dinámica de templates y clientes LLM (Ollama local / Groq nube) para proporcionar respuestas inteligentes y contextuales a las consultas del usuario.

**Este es el endpoint más crítico del proyecto** - es el puente entre la interfaz de usuario y el cerebro de IA.

---

### 📝 Descripción

#### Requisitos Funcionales

El endpoint debe:
1. **Recibir** solicitudes de chat con `conversation_id`, `message` y `project_id`
2. **Recuperar** fragmentos de conocimiento relevantes de ChromaDB basados en la consulta del usuario
3. **Seleccionar** el template apropiado según la fase actual del proyecto
4. **Inyectar** contexto RAG + input del usuario en el template
5. **Llamar** al LLM (Ollama o Groq) con el prompt construido
6. **Retornar** respuesta de IA con metadatos (template usado, fuentes)

#### Requisitos No Funcionales

- **Tiempo de respuesta:** <500ms (modo no-streaming)
- **Seguridad:** Sanitización de input (prevenir inyección de prompts, XSS)
- **Resiliencia:** Mecanismo de reintentos para fallos del LLM (3x con backoff)
- **Observabilidad:** Logging estructurado con trazabilidad por request ID
- **Modularidad:** Patrón Strategy para clientes LLM (fácil intercambiar Ollama ↔ Groq)

---

### 🔗 Dependencias

| Dependencia | Estado | Notas |
|-------------|--------|-------|
| **HU-2.2** (Vectorización RAG) | ✅ Completa | Pipeline de ingesta ChromaDB listo |
| Servicio ChromaDB | ✅ Ejecutando | Contenedor Docker saludable |
| Ollama (LLM Local) | ⚠️ Setup Manual | Debe instalarse en host |

---

### ✅ Criterios de Verificación

#### Tests Funcionales
- ✅ **POST /chat/message** responde en <500ms (modo no-streaming)
- ✅ El sistema recupera fragmentos relevantes de ChromaDB (query RAG funciona)
- ✅ Inyección de template funciona correctamente según fase del proyecto
- ✅ Soporta modo `ollama` (local)
- ✅ Preparado para modo `groq` (nube) (flag de config listo)

#### Gates de Calidad
- ✅ **Tests unitarios** para orquestador RAG >90% cobertura
- ✅ **Tests unitarios** para cargador de templates >90% cobertura
- ✅ **Tests de integración** para endpoint E2E >80% cobertura
- ✅ **Tests de seguridad** para prevención de inyección de prompts
- ✅ **Type safety:** 0 errores de Pyright
- ✅ **Formateo de código:** Cumple con Black
- ✅ **Linting:** Ruff pasa

---

### 🔧 Tareas Técnicas

#### Fase 1: Dominio & Seguridad (TDD Red)
- [x] Definir schemas Pydantic (`ChatRequest`, `ChatResponse`)
- [x] Implementar sanitización de input (etiquetas HTML, límites de longitud)
- [x] Escribir tests de validación (XSS, inyección de prompts, prevención DOS)

#### Fase 2: Infraestructura (TDD Green)
- [x] Implementar clase abstracta `BaseLLMClient` (Patrón Strategy)
- [x] Crear implementación `OllamaClient`
- [x] Crear stub `GroqClient` (listo para integración futura)
- [x] Escribir tests unitarios para clientes LLM (mockear llamadas externas)

#### Fase 3: Orquestador RAG (TDD Refactor)
- [x] Implementar servicio `RAGOrchestrator`
  - [x] Integración de búsqueda vectorial
  - [x] Integración de constructor de prompts
  - [x] Lógica de inyección de contexto
  - [x] Invocación de cliente LLM
- [x] Escribir tests unitarios para lógica de orquestación

#### Fase 4: Endpoint FastAPI
- [x] Implementar ruta POST `/api/v1/chat/message`
- [x] Añadir inyección de dependencias para `RAGOrchestrator`
- [x] Implementar manejo de errores (excepciones personalizadas)
- [x] Escribir tests de integración (E2E con LLM mockeado)

#### Fase 5: Calidad & Endurecimiento de Seguridad
- [x] Auditoría de seguridad (escaneo Bandit)
- [x] Perfilado de rendimiento (objetivo <500ms)
- [x] Pruebas de escenarios de error (fallos de conexión, timeouts)
- [x] Documentación (docs de API, diagramas de arquitectura)

#### Fase 6: Validación & PR
- [x] Ejecutar `./scripts/testing/PRE_PUSH_VALIDATION_MASTER.sh`
- [ ] Verificar que todas las GitHub Actions pasen
- [x] Actualizar documentación de tracking
- [ ] Abrir PR hacia `develop`

---

### 🛠️ Stack Tecnológico

| Componente | Tecnología | Propósito |
|------------|-----------|-----------|
| **Endpoint** | FastAPI | Framework de API REST |
| **Orquestación** | LangChain | Coordinación de pipeline RAG |
| **Base de Datos Vectorial** | ChromaDB | Recuperación de búsqueda semántica |
| **LLM (Local)** | Ollama | Inferencia local open-source |
| **LLM (Nube)** | Groq | Inferencia rápida en nube (futuro) |
| **Validación** | Pydantic | Sanitización de input & type safety |
| **Testing** | pytest | Tests unitarios + integración |
| **Type Checking** | Pyright | Análisis de tipos estático |

---

### 📚 Documentación Relacionada

**Workflow & Procedimientos:**
- [WORKFLOW_MASTER_DEFINITION.md](./WORKFLOW_MASTER_DEFINITION.md) - Workflow TDD completo
- [PROGRESS.md](./PROGRESS.md) - Checklist de seguimiento de fases
- [ARTIFACTS.md](./ARTIFACTS.md) - Manifiesto de archivos

**Arquitectura:**
- [context/30-ARCHITECTURE/RAG_ARCHITECTURE_AND_FLOW.es.md](../../../context/30-ARCHITECTURE/RAG_ARCHITECTURE_AND_FLOW.es.md)
- [context/30-ARCHITECTURE/API_INTERFACE_CONTRACT.es.md](../../../context/30-ARCHITECTURE/API_INTERFACE_CONTRACT.es.md)

**Seguridad:**
- [context/SECURITY_HARDENING_POLICY.es.md](../../../context/SECURITY_HARDENING_POLICY.es.md)
- [AGENTS.md](../../../AGENTS.md#-8-reglas-estrictas-de-cicd-pipeline-mandatory) - Reglas CI/CD

**Historias de Usuario:**
- [context/40-ROADMAP/USER_STORIES_MASTER.es.json](../../../context/40-ROADMAP/USER_STORIES_MASTER.es.json)

---

</div>
