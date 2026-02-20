# 🏗️ HU-4.2: System Architecture Diagrams

> **Versión:** 1.0.0
> **Architectural Pattern:** Clean Architecture + Hexagonal Architecture (Ports & Adapters)
> **Fecha:** 2026-02-14

---

## 📋 Table of Contents

1. [Overview](#overview)
2. [Clean Architecture Layers](#clean-architecture-layers)
3. [Data Flow Diagram](#data-flow-diagram)
4. [Component Relationships](#component-relationships)
5. [Persistence Architecture](#persistence-architecture)
6. [Request/Response Lifecycle](#requestresponse-lifecycle)
7. [Dependency Rules](#dependency-rules)

---

## 🔍 Overview

### Architectural Principles

| Principle | Implementación |
|-----------|----------------|
| **Separation of Concerns** | Clean Architecture 4 layers |
| **Dependency Inversion** | Domain layer independent |
| **Pruebaability** | 96% prueba coverage |
| **Framework Independence** | Business logic decoupled |
| **Database Independence** | Repository pattern abstraction |

### Layer Responsibilities

| Layer | Responsibility | Dependencies |
|-------|----------------|--------------|
| **Domain** | Business entities, rules | None (pure Python) |
| **Infraestructura** | Database, persistence | Domain only |
| **Service** | Use cases, orchestration | Domain + Infraestructura |
| **API** | HTTP endpoints, validation | Service + Domain schemas |

---

## 🧱 Clean Architecture Layers

### Layer Structure (Conceptual)

```mermaid
graph TB
    subgraph "External World"
        Client[HTTP Client]
    end

    subgraph "API Layer (Adapters)"
        Router[FastAPI Router<br/>conversations.py]
        Schemas[Pydantic Schemas<br/>conversation.py]
    end

    subgraph "Service Layer (Use Cases)"
        Service[ConversationService<br/>conversation_service.py]
    end

    subgraph "Infrastructure Layer (Adapters)"
        Repo[SQLAlchemyConversationRepository]
        Models[SQLAlchemy Models<br/>conversation_models.py]
        DB[(SQLite Database<br/>conversations.db)]
    end

    subgraph "Domain Layer (Core)"
        Entities[Entities<br/>Conversation, Message]
        IRepo[Repository Protocol<br/>IConversationRepository]
    end

    Client -->|HTTP Request| Router
    Router -->|DTO| Schemas
    Router -->|Call| Service
    Service -->|Use| IRepo
    Service -->|Domain Objects| Entities
    Repo -.->|Implements| IRepo
    Repo -->|ORM| Models
    Models -->|SQL| DB

    style Domain fill:#e1f5e1
    style Service fill:#e3f2fd
    style Infrastructure fill:#fff3e0
    style API fill:#fce4ec
```

---

## 🔄 Data Flow Diagram

### Request → Response Flow

```mermaid
sequenceDiagram
    participant Client
    participant API as API Layer<br/>(conversations.py)
    participant Schema as Pydantic Schema<br/>(ConversationCreate)
    participant Service as Service Layer<br/>(ConversationService)
    participant Domain as Domain Entity<br/>(Conversation)
    participant Repo as Infrastructure<br/>(SQLAlchemyRepository)
    participant DB as Database<br/>(SQLite)

    Client->>API: POST /api/v1/conversations/
    API->>Schema: Validate request body
    Schema-->>API: ✅ ConversationCreate DTO
    API->>Service: create_conversation(dto)
    Service->>Domain: Conversation.create(...)
    Domain-->>Service: ✅ Conversation entity
    Service->>Repo: add(conversation)
    Repo->>DB: INSERT INTO conversations
    DB-->>Repo: ✅ Row inserted
    Repo-->>Service: ✅ Conversation saved
    Service-->>API: ✅ Conversation entity
    API->>Schema: ConversationResponse.from_entity()
    Schema-->>API: ✅ Response DTO
    API-->>Client: 201 Created (JSON)
```

---

## 🧩 Component Relationships

### Dependency Graph

```mermaid
graph LR
    subgraph "Domain Layer (Pure)"
        E[Entities<br/>conversation.py<br/>message.py]
        R[Repository Protocol<br/>base.py]
    end

    subgraph "Infrastructure Layer"
        M[SQLAlchemy Models<br/>conversation_models.py]
        SR[SQLAlchemy Repository<br/>conversation_repository.py]
        DB[(SQLite DB)]
    end

    subgraph "Service Layer"
        CS[ConversationService<br/>conversation_service.py]
    end

    subgraph "API Layer"
        RT[FastAPI Router<br/>conversations.py]
        S[Pydantic Schemas<br/>conversation.py]
    end

    CS -->|Uses| E
    CS -->|Depends on| R
    SR -.->|Implements| R
    SR -->|Uses| M
    SR -->|Queries| DB
    RT -->|Calls| CS
    RT -->|Validates| S
    S -->|Converts to/from| E
    M -->|Maps to| E

    style E fill:#4caf50,color:#fff
    style R fill:#4caf50,color:#fff
    style CS fill:#2196f3,color:#fff
    style SR fill:#ff9800,color:#fff
    style M fill:#ff9800,color:#fff
    style RT fill:#e91e63,color:#fff
    style S fill:#e91e63,color:#fff
```

**Legend:**
- 🟢 **Green:** Domain Layer (Pure Business Logic)
- 🔵 **Blue:** Service Layer (Use Cases)
- 🟠 **Orange:** Infraestructura Layer (Persistence)
- 🔴 **Pink:** API Layer (HTTP Interface)

---

## 💾 Persistence Architecture

### SQLAlchemy + SQLite Stack

```mermaid
graph TB
    subgraph "Application Layer"
        Service[ConversationService]
    end

    subgraph "Repository Layer (Port)"
        IRepo[IConversationRepository<br/>Protocol/Interface]
    end

    subgraph "Adapter Layer (Implementation)"
        SQLRepo[SQLAlchemyConversationRepository]
        SessionMgr[Database Session Manager]
    end

    subgraph "ORM Layer"
        ConvModel[ConversationModel<br/>SQLAlchemy Table]
        MsgModel[MessageModel<br/>SQLAlchemy Table]
    end

    subgraph "Database Layer"
        SQLite[(SQLite Database<br/>File: conversations.db)]
    end

    Service -->|Depends on| IRepo
    SQLRepo -.->|Implements| IRepo
    SQLRepo -->|Uses| SessionMgr
    SQLRepo -->|CRUD Operations| ConvModel
    SQLRepo -->|CRUD Operations| MsgModel
    ConvModel -->|Mapped to Table| SQLite
    MsgModel -->|Mapped to Table| SQLite

    style IRepo fill:#4caf50,color:#fff
    style SQLRepo fill:#ff9800,color:#fff
    style ConvModel fill:#ff9800,color:#fff
    style MsgModel fill:#ff9800,color:#fff
    style SQLite fill:#607d8b,color:#fff
```

### Table Schema (Entity-Relationship)

```mermaid
erDiagram
    CONVERSATIONS {
        UUID id PK
        UUID project_id
        string title
        datetime created_at
        datetime updated_at
    }

    MESSAGES {
        UUID id PK
        UUID conversation_id FK
        string role
        string content
        datetime created_at
    }

    CONVERSATIONS ||--o{ MESSAGES : "has many"
```

**Relationships:**
- One conversation has many messages (1:N)
- Messages are cascade-eliminard when conversation is eliminard
- All IDs are UUID v4 format

---

## 🔁 Request/Response Lifecycle

### POST /conversations/ (Crear)

```mermaid
flowchart TD
    Start([HTTP POST Request])

    Start --> Validate{Pydantic<br/>Validation}
    Validate -->|❌ Invalid| Error422[422 Unprocessable Entity]
    Validate -->|✅ Valid| CreateDTO[ConversationCreate DTO]

    CreateDTO --> ServiceCall[ConversationService.create_conversation]
    ServiceCall --> DomainCreate[Conversation.create factory]
    DomainCreate --> ValidateDomain{Domain<br/>Validation}
    ValidateDomain -->|❌ Invalid| ErrorDomain[Domain Exception]
    ValidateDomain -->|✅ Valid| Entity[Conversation Entity]

    Entity --> RepoAdd[repository.add entity]
    RepoAdd --> SQL[SQLAlchemy INSERT]
    SQL --> DBWrite[(Write to SQLite)]
    DBWrite --> Commit{Transaction<br/>Commit}
    Commit -->|❌ Failed| Error500[500 Internal Error]
    Commit -->|✅ Success| RefreshEntity[Refresh Entity from DB]

    RefreshEntity --> ConvertResponse[Convert to ConversationResponse]
    ConvertResponse --> Return201[201 Created + JSON]

    Error422 --> End([Return to Client])
    ErrorDomain --> End
    Error500 --> End
    Return201 --> End

    style CreateDTO fill:#e3f2fd
    style Entity fill:#e1f5e1
    style DBWrite fill:#fff3e0
    style Return201 fill:#c8e6c9
    style Error422 fill:#ffcdd2
    style Error500 fill:#ffcdd2
```

---

### GET /conversations/{id} (Retrieve)

```mermaid
flowchart TD
    Start([HTTP GET Request])

    Start --> ValidateID{UUID<br/>Validation}
    ValidateID -->|❌ Invalid| Error422[422 Unprocessable Entity]
    ValidateID -->|✅ Valid| ServiceCall[ConversationService.get_by_id]

    ServiceCall --> RepoGet[repository.get_by_id]
    RepoGet --> SQL[SQLAlchemy SELECT + JOIN]
    SQL --> DBRead[(Read from SQLite)]
    DBRead --> CheckExists{Entity<br/>Found?}
    CheckExists -->|❌ Not Found| Error404[404 Not Found]
    CheckExists -->|✅ Found| Entity[Conversation Entity + Messages]

    Entity --> ConvertResponse[Convert to ConversationResponse]
    ConvertResponse --> Return200[200 OK + JSON]

    Error422 --> End([Return to Client])
    Error404 --> End
    Return200 --> End

    style ServiceCall fill:#e3f2fd
    style Entity fill:#e1f5e1
    style DBRead fill:#fff3e0
    style Return200 fill:#c8e6c9
    style Error404 fill:#ffcdd2
```

---

### GET /conversations/ (List)

```mermaid
flowchart TD
    Start([HTTP GET Request])

    Start --> ValidateParams{Query Params<br/>Validation}
    ValidateParams -->|❌ Invalid| Error422[422 Unprocessable Entity]
    ValidateParams -->|✅ Valid| ServiceCall[ConversationService.list_conversations]

    ServiceCall --> RepoList[repository.list skip, limit]
    RepoList --> SQL[SQLAlchemy SELECT LIMIT OFFSET]
    SQL --> DBRead[(Read from SQLite)]
    DBRead --> CountTotal[COUNT total records]
    CountTotal --> Entities[List of Conversation Entities]

    Entities --> ConvertList[Convert to ConversationList DTO]
    ConvertList --> AddPagination[Add total, skip, limit]
    AddPagination --> Return200[200 OK + JSON]

    Error422 --> End([Return to Client])
    Return200 --> End

    style ServiceCall fill:#e3f2fd
    style Entities fill:#e1f5e1
    style DBRead fill:#fff3e0
    style Return200 fill:#c8e6c9
```

---

## 🚫 Dependency Rules

### The Dependency Rule (Clean Architecture)

> **Core Principle:** Dependencies can only point **inwards**. Outer layers depend on inner layers, but inner layers know nothing about outer layers.

```mermaid
graph TD
    subgraph "Outer Layers (Details)"
        API[API Layer<br/>FastAPI, HTTP]
        Infra[Infrastructure Layer<br/>SQLAlchemy, SQLite]
    end

    subgraph "Inner Layers (Business Logic)"
        Service[Service Layer<br/>Use Cases]
        Domain[Domain Layer<br/>Entities, Rules]
    end

    API -->|Depends on| Service
    API -->|Depends on| Domain
    Service -->|Depends on| Domain
    Infra -->|Depends on| Domain

    Domain -.->|NEVER depends on| API
    Domain -.->|NEVER depends on| Infra
    Domain -.->|NEVER depends on| Service

    style Domain fill:#4caf50,color:#fff
    style Service fill:#2196f3,color:#fff
    style Infra fill:#ff9800,color:#fff
    style API fill:#e91e63,color:#fff
```

### Dependency Matrix

| From ↓ / To → | Domain | Service | Infraestructura | API |
|---------------|--------|---------|----------------|-----|
| **Domain** | ✅ | ❌ | ❌ | ❌ |
| **Service** | ✅ | ✅ | ✅ (via interface) | ❌ |
| **Infraestructura** | ✅ | ❌ | ✅ | ❌ |
| **API** | ✅ | ✅ | ✅ (for DI) | ✅ |

**Legend:**
- ✅ Allowed dependency
- ❌ Forbidden dependency (violates Clean Architecture)

---

## 📐 Hexagonal Architecture (Ports & Adapters)

### Primary & Secondary Ports

```mermaid
graph LR
    subgraph "Primary Adapters (Drivers)"
        HTTP[HTTP REST API<br/>FastAPI Router]
        CLI[CLI Commands<br/>Future]
    end

    subgraph "Application Core"
        Port1[Primary Port<br/>ConversationService]
        Domain[Domain Logic<br/>Entities]
        Port2[Secondary Port<br/>IConversationRepository]
    end

    subgraph "Secondary Adapters (Driven)"
        SQLite[SQLite Adapter<br/>SQLAlchemyRepository]
        Memory[In-Memory Adapter<br/>For Testing]
    end

    HTTP -->|Drives| Port1
    CLI -->|Drives| Port1
    Port1 -->|Uses| Domain
    Port1 -->|Requires| Port2
    SQLite -.->|Implements| Port2
    Memory -.->|Implements| Port2

    style Domain fill:#4caf50,color:#fff
    style Port1 fill:#2196f3,color:#fff
    style Port2 fill:#2196f3,color:#fff
    style HTTP fill:#e91e63,color:#fff
    style SQLite fill:#ff9800,color:#fff
```

**Explanation:**
- **Primary Ports (Left):** Application services (driven by external actors)
- **Secondary Ports (Right):** Repository interfaces (required by application)
- **Primary Adapters:** HTTP API, CLI (future)
- **Secondary Adapters:** SQLite persistence, in-memory pruebaing adapter

---

## 🧪 Pruebaing Architecture

### Prueba Pyramid

```mermaid
graph TB
    subgraph "Test Layers"
        E2E[E2E Tests<br/>Future: Full app]
        Integration[Integration Tests<br/>5 tests: API + DB]
        Unit[Unit Tests<br/>23 tests: Domain + Service + Infrastructure]
    end

    E2E -->|Depends on| Integration
    Integration -->|Depends on| Unit

    style Unit fill:#4caf50,color:#fff
    style Integration fill:#2196f3,color:#fff
    style E2E fill:#ff9800,color:#fff
```

**Coverage Desglose:**
- **Unit Pruebas:** 23 pruebas (Domain 11, Infraestructura 6, Service 6)
- **Integración Pruebas:** 5 pruebas (API endpoints with real DB)
- **Total Coverage:** 96% (199/205 statements)

---

## 🔗 Related Documentoation

- **API Contract:** [API_CONTRACT.md](./API_CONTRACT.md)
- **Coverage Report:** [COVERAGE_REPORT.md](./COVERAGE_REPORT.md)
- **Security Audit:** [SECURITY_AUDIT.md](./SECURITY_AUDIT.md)
- **Clean Architecture Reference:** Uncle Bob's Clean Architecture (2012)

---

## ✅ Architecture Validation

| Criteria | Estado | Evidence |
|----------|--------|----------|
| **Dependency Rule** | ✅ Pass | 0 Pyright errors (no circular deps) |
| **Layer Separation** | ✅ Pass | Clear carpeta structure: domain/ infra/ services/ api/ |
| **Pruebaability** | ✅ Pass | 96% coverage, pruebas isolated |
| **Framework Independence** | ✅ Pass | Domain layer has 0 FastAPI/SQLAlchemy imports |
| **Database Independence** | ✅ Pass | Repository protocol abstracts persistence |

**Architecture Estado:** ✅ **COMPLIANT WITH CLEAN ARCHITECTURE**

---

*Architecture Diagram v1.0.0 - Generated 2026-02-14*
*Clean Architecture + Hexagonal Pattern*
