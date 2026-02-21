# 💾 HU-4.2: Persistencia e Historial de Conversaciones

> **Sprint:** S4 - Inteligencia Artificial y Chat (The Brain)
> **Epic:** E4 - Backend IA & RAG
> **Status:** 🔄 In Progress
> **Priority:** 🔴 Critical
> **Estimation:** M (Medium)
> **Branch:** `feature/backend-conversation-history`

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

Implement **conversation persistence using SQLite** with SQLAlchemy ORM to store complete chat history. Enable **context window management** (last 10 messages) for LLM prompt construction, ensuring continuity in multi-turn conversations without memory overflow.

**This is the memory system** - it allows the AI to maintain context across multiple user interactions.

---

### 📝 Description

#### Functional Requirements

The system must:
1. **Store** every message (user + assistant) in SQLite database
2. **Retrieve** conversation history via `GET /api/v1/conversations/{id}`
3. **Inject** last 10 messages into LLM prompt for context continuity
4. **Support** creating new conversations via `POST /api/v1/conversations`
5. **Support** listing all conversations via `GET /api/v1/conversations`
6. **Handle** concurrent writes safely (transaction isolation)

#### Non-Functional Requirements

- **Storage efficiency:** SQLite sufficient for MVP (100K+ conversations)
- **Security:** Parameterized queries only (no raw SQL to prevent SQL injection)
- **Architecture:** Clean Architecture (Domain entities → Repository protocol → SQLAlchemy adapter)
- **Performance:** Query optimization (indexes on `conversation_id`, `created_at`)
- **Context window:** Limit to 10 messages (prevent token overflow, memory optimization)

---

### 🔗 Dependencies

| Dependency | Status | Notes |
|------------|--------|-------|
| **HU-4.1** (Chat Endpoint) | ✅ Complete | Chat endpoint exists, ready to integrate history |
| SQLite | ✅ Available | Bundled with Python |
| SQLAlchemy | ✅ Installed | Async ORM support via `asyncpg` or `aiosqlite` |

---

### ✅ Verification Criteria

#### Functional Tests
- ⏳ **POST /api/v1/conversations** creates new conversation with empty history
- ⏳ **GET /api/v1/conversations/{id}** returns complete message history
- ⏳ **GET /api/v1/conversations** lists all conversations (paginated)
- ⏳ **POST /api/v1/chat/message** stores message in database automatically
- ⏳ LLM receives last 10 messages for context (not entire history)
- ⏳ Concurrent writes handled safely (no data corruption)

#### Quality Gates
- ⏳ **Unit tests** for domain entities >95% coverage
- ⏳ **Unit tests** for repository adapter >90% coverage
- ⏳ **Integration tests** for CRUD endpoints >85% coverage
- ⏳ **Security tests** for SQL injection prevention (ORM validation)
- ⏳ **Type safety:** 0 Pyright errors
- ⏳ **Code formatting:** Black compliant
- ⏳ **Linting:** Ruff passes

---

### 🔧 Technical Tasks

#### Phase 0: Setup (1 hour)
- ✅ Create feature branch `feature/backend-conversation-history`
- ✅ Create documentation structure (README, PROGRESS, ARTIFACTS, WORKFLOW)
- ⏳ Define SQLAlchemy models structure

#### Phase 1: Domain Layer (2 hours)
- ⏳ Create `Conversation` entity with validation
- ⏳ Create `MessageRole` enum (USER, ASSISTANT, SYSTEM)
- ⏳ Create `ConversationRepository` protocol (port)
- ⏳ Write TDD tests for entities

#### Phase 2: Infrastructure Layer (3 hours)
- ⏳ Implement SQLAlchemy models (`ConversationModel`, `MessageModel`)
- ⏳ Implement `SQLAlchemyConversationRepository` (adapter)
- ⏳ Create database session management (dependency injection)
- ⏳ Write TDD tests for repository adapter

#### Phase 3: Service Layer (2 hours)
- ⏳ Create `ConversationService` with context window logic (last 10 messages)
- ⏳ Integrate with existing chat endpoint (`POST /chat/message`)
- ⏳ Write TDD tests for service layer

#### Phase 4: API Layer (2 hours)
- ⏳ Implement `POST /api/v1/conversations` endpoint
- ⏳ Implement `GET /api/v1/conversations/{id}` endpoint
- ⏳ Implement `GET /api/v1/conversations` endpoint (with pagination)
- ⏳ Write integration tests for endpoints

#### Phase 5: Quality & Documentation (2 hours)
- ⏳ Verify coverage >85%
- ⏳ Run security audit (Bandit)
- ⏳ Create API documentation (OpenAPI spec)
- ⏳ Update architecture diagrams

#### Phase 6: Validation & PR (1 hour)
- ⏳ Run `PRE_PUSH_VALIDATION_MASTER.sh`
- ⏳ Commit and push to remote
- ⏳ Create Pull Request with documentation

**Total Estimated Time:** 13 hours

---

### 🛠️ Tech Stack

| Layer | Technology | Purpose |
|-------|-----------|---------|
| **ORM** | SQLAlchemy 2.0 (Async) | Database abstraction, async queries |
| **Database** | SQLite 3 | Local-first persistence (MVP sufficient) |
| **API Framework** | FastAPI 0.115+ | REST endpoints |
| **Validation** | Pydantic V2 | Schema validation |
| **Testing** | pytest + pytest-asyncio | TDD workflow |
| **Type Checking** | Pyright | Static analysis |

---

### 📚 Related Documentation

- [WORKFLOW_MASTER_DEFINITION.md](./WORKFLOW_MASTER_DEFINITION.md) - **Start here! TDD workflow step-by-step**
- [PROGRESS.md](./PROGRESS.md) - Track completion of 6 phases
- [ARTIFACTS.md](./ARTIFACTS.md) - File inventory and purpose
- [HU-4.1 README](../HU-4.1-CHAT-ENDPOINT/README.md) - Previous HU (dependency)
- [Clean Architecture Reference](../../../context/30-ARCHITECTURE/BACKEND_CLEAN_ARCHITECTURE.md) - Design principles

---

</div>

---

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

Implementar **persistencia de conversaciones usando SQLite** con SQLAlchemy ORM para almacenar el historial completo del chat. Habilitar **gestión de ventana de contexto** (últimos 10 mensajes) para la construcción de prompts del LLM, asegurando continuidad en conversaciones multi-turno sin desbordamiento de memoria.

**Este es el sistema de memoria** - permite que la IA mantenga el contexto a través de múltiples interacciones del usuario.

---

### 📝 Descripción

#### Requisitos Funcionales

El sistema debe:
1. **Almacenar** cada mensaje (usuario + asistente) en base de datos SQLite
2. **Recuperar** historial de conversación vía `GET /api/v1/conversations/{id}`
3. **Inyectar** los últimos 10 mensajes en el prompt del LLM para continuidad de contexto
4. **Soportar** creación de nuevas conversaciones vía `POST /api/v1/conversations`
5. **Soportar** listar todas las conversaciones vía `GET /api/v1/conversations`
6. **Manejar** escrituras concurrentes de forma segura (aislamiento de transacciones)

#### Requisitos No Funcionales

- **Eficiencia de almacenamiento:** SQLite suficiente para MVP (100K+ conversaciones)
- **Seguridad:** Solo queries parametrizadas (no SQL raw para prevenir inyección SQL)
- **Arquitectura:** Clean Architecture (Entidades de dominio → Protocolo de repositorio → Adaptador SQLAlchemy)
- **Performance:** Optimización de queries (índices en `conversation_id`, `created_at`)
- **Ventana de contexto:** Límite de 10 mensajes (prevenir desbordamiento de tokens, optimización de memoria)

---

### 🔗 Dependencias

| Dependencia | Estado | Notas |
|-------------|--------|-------|
| **HU-4.1** (Chat Endpoint) | ✅ Completo | Endpoint de chat existe, listo para integrar historial |
| SQLite | ✅ Disponible | Incluido con Python |
| SQLAlchemy | ✅ Instalado | Soporte ORM async vía `asyncpg` o `aiosqlite` |

---

### ✅ Criterios de Verificación

#### Tests Funcionales
- ⏳ **POST /api/v1/conversations** crea nueva conversación con historial vacío
- ⏳ **GET /api/v1/conversations/{id}** retorna historial completo de mensajes
- ⏳ **GET /api/v1/conversations** lista todas las conversaciones (paginado)
- ⏳ **POST /api/v1/chat/message** almacena mensaje en base de datos automáticamente
- ⏳ El LLM recibe los últimos 10 mensajes para contexto (no todo el historial)
- ⏳ Escrituras concurrentes manejadas de forma segura (sin corrupción de datos)

#### Puertas de Calidad
- ⏳ **Tests unitarios** para entidades de dominio >95% cobertura
- ⏳ **Tests unitarios** para adaptador de repositorio >90% cobertura
- ⏳ **Tests de integración** para endpoints CRUD >85% cobertura
- ⏳ **Tests de seguridad** para prevención de inyección SQL (validación ORM)
- ⏳ **Type safety:** 0 errores de Pyright
- ⏳ **Formateo de código:** Compliant con Black
- ⏳ **Linting:** Ruff pasa

---

### 🔧 Tareas Técnicas

#### Fase 0: Setup (1 hora)
- ✅ Crear rama feature `feature/backend-conversation-history`
- ✅ Crear estructura de documentación (README, PROGRESS, ARTIFACTS, WORKFLOW)
- ⏳ Definir estructura de modelos SQLAlchemy

#### Fase 1: Capa de Dominio (2 horas)
- ⏳ Crear entidad `Conversation` con validación
- ⏳ Crear enum `MessageRole` (USER, ASSISTANT, SYSTEM)
- ⏳ Crear protocolo `ConversationRepository` (puerto)
- ⏳ Escribir tests TDD para entidades

#### Fase 2: Capa de Infrastructura (3 horas)
- ⏳ Implementar modelos SQLAlchemy (`ConversationModel`, `MessageModel`)
- ⏳ Implementar `SQLAlchemyConversationRepository` (adaptador)
- ⏳ Crear gestión de sesión de base de datos (dependency injection)
- ⏳ Escribir tests TDD para adaptador de repositorio

#### Fase 3: Capa de Servicio (2 horas)
- ⏳ Crear `ConversationService` con lógica de ventana de contexto (últimos 10 mensajes)
- ⏳ Integrar con endpoint de chat existente (`POST /chat/message`)
- ⏳ Escribir tests TDD para capa de servicio

#### Fase 4: Capa de API (2 horas)
- ⏳ Implementar endpoint `POST /api/v1/conversations`
- ⏳ Implementar endpoint `GET /api/v1/conversations/{id}`
- ⏳ Implementar endpoint `GET /api/v1/conversations` (con paginación)
- ⏳ Escribir tests de integración para endpoints

#### Fase 5: Calidad & Documentación (2 horas)
- ⏳ Verificar cobertura >85%
- ⏳ Ejecutar auditoría de seguridad (Bandit)
- ⏳ Crear documentación de API (spec OpenAPI)
- ⏳ Actualizar diagramas de arquitectura

#### Fase 6: Validación & PR (1 hora)
- ⏳ Ejecutar `PRE_PUSH_VALIDATION_MASTER.sh`
- ⏳ Commit y push al remoto
- ⏳ Crear Pull Request con documentación

**Tiempo Total Estimado:** 13 horas

---

### 🛠️ Stack Tecnológico

| Capa | Tecnología | Propósito |
|------|-----------|-----------|
| **ORM** | SQLAlchemy 2.0 (Async) | Abstracción de base de datos, queries async |
| **Base de Datos** | SQLite 3 | Persistencia local-first (suficiente para MVP) |
| **Framework API** | FastAPI 0.115+ | Endpoints REST |
| **Validación** | Pydantic V2 | Validación de schemas |
| **Testing** | pytest + pytest-asyncio | Workflow TDD |
| **Type Checking** | Pyright | Análisis estático |

---

### 📚 Documentación Relacionada

- [WORKFLOW_MASTER_DEFINITION.md](./WORKFLOW_MASTER_DEFINITION.md) - **¡Empieza aquí! Workflow TDD paso a paso**
- [PROGRESS.md](./PROGRESS.md) - Seguimiento de completitud de 6 fases
- [ARTIFACTS.md](./ARTIFACTS.md) - Inventario de archivos y propósito
- [HU-4.1 README](../HU-4.1-CHAT-ENDPOINT/README.md) - HU previa (dependencia)
- [Referencia Clean Architecture](../../../context/30-ARCHITECTURE/BACKEND_CLEAN_ARCHITECTURE.md) - Principios de diseño

---

</div>
