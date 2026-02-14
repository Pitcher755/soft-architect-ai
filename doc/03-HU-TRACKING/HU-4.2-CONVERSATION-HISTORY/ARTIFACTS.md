# 📦 HU-4.2: Artifacts Manifest

> **Purpose:** Complete file inventory for conversation persistence implementation
> **Last Updated:** 2026-02-14
> **Status:** Phase 0 Complete (Documentation), Phase 1-6 Pending

---

## 📖 Table of Contents

1. [Documentation Files](#documentation-files)
2. [Source Code Files](#source-code-files)
3. [Test Files](#test-files)
4. [Configuration Files](#configuration-files)
5. [Migration Files](#migration-files)
6. [File Status Matrix](#file-status-matrix)

---

## 📄 Documentation Files

| File | Purpose | Status | Phase |
|------|---------|--------|-------|
| `README.md` | HU overview, objectives, verification criteria (bilingual) | ✅ Complete | Phase 0 |
| `PROGRESS.md` | 6-phase progress tracker with checklists | ✅ Complete | Phase 0 |
| `ARTIFACTS.md` | This file - complete file inventory | ✅ Complete | Phase 0 |
| `WORKFLOW_MASTER_DEFINITION.md` | TDD workflow step-by-step guide | ✅ Complete | Phase 0 |
| `ARCHITECTURE_DIAGRAM.md` | System architecture with Mermaid diagrams | ⏳ Pending | Phase 5 |
| `COVERAGE_REPORT.md` | Test coverage analysis (≥85% target) | ⏳ Pending | Phase 5 |
| `SECURITY_AUDIT.md` | Bandit security audit report (SQL injection checks) | ⏳ Pending | Phase 5 |
| `API_CONTRACT.md` | OpenAPI spec for conversation endpoints | ⏳ Pending | Phase 5 |
| `FINAL_AUDIT_REPORT.md` | 100% completion certification | ⏳ Pending | Phase 6 |

---

## 💻 Source Code Files

### Domain Layer (Phase 1)

| File | Purpose | Dependencies | Status |
|------|---------|--------------|--------|
| `src/server/app/domain/entities/conversation.py` | `Conversation` entity with validation (Pydantic) | pydantic, datetime, uuid | ⏳ Pending |
| `src/server/app/domain/entities/message.py` | `Message` entity with role enum validation | pydantic, enum, datetime | ⏳ Pending |
| `src/server/app/domain/repositories/conversation_repository.py` | Repository protocol (port) - interface only | typing.Protocol, ABC | ⏳ Pending |

**Lines of Code (Estimated):** ~250 lines

---

### Infrastructure Layer (Phase 2)

| File | Purpose | Dependencies | Status |
|------|---------|--------------|--------|
| `src/server/app/infrastructure/persistence/models/conversation_model.py` | SQLAlchemy `ConversationModel` table definition | sqlalchemy, uuid, datetime | ⏳ Pending |
| `src/server/app/infrastructure/persistence/models/message_model.py` | SQLAlchemy `MessageModel` table definition | sqlalchemy, enum | ⏳ Pending |
| `src/server/app/infrastructure/persistence/repositories/sqlalchemy_conversation_repository.py` | Repository adapter (implements protocol) | sqlalchemy.ext.asyncio, domain entities | ⏳ Pending |
| `src/server/app/infrastructure/persistence/database.py` | Async session factory, connection pooling | sqlalchemy.ext.asyncio, aiosqlite | ⏳ Pending |

**Lines of Code (Estimated):** ~400 lines

---

### Service Layer (Phase 3)

| File | Purpose | Dependencies | Status |
|------|---------|--------------|--------|
| `src/server/app/services/conversation/conversation_service.py` | Business logic for conversations (context window) | domain repositories, entities | ⏳ Pending |
| `src/server/app/services/conversation/__init__.py` | Service exports | - | ⏳ Pending |

**Lines of Code (Estimated):** ~200 lines

---

### API Layer (Phase 4)

| File | Purpose | Dependencies | Status |
|------|---------|--------------|--------|
| `src/server/app/api/v1/conversations.py` | FastAPI router with CRUD endpoints | fastapi, pydantic schemas | ⏳ Pending |
| `src/server/app/domain/schemas/conversation.py` | Pydantic request/response schemas | pydantic, datetime, uuid | ⏳ Pending |
| `src/server/app/api/dependencies.py` | Update with conversation service DI | dependency_injector | ⏳ Modified |

**Lines of Code (Estimated):** ~300 lines

---

## 🧪 Test Files

### Unit Tests (Phase 1-4)

| File | Purpose | Coverage Target | Status |
|------|---------|-----------------|--------|
| `tests/server/unit/domain/entities/test_conversation.py` | Test `Conversation` entity validation | >95% | ⏳ Pending |
| `tests/server/unit/domain/entities/test_message.py` | Test `Message` entity validation | >95% | ⏳ Pending |
| `tests/server/unit/infrastructure/persistence/test_sqlalchemy_conversation_repository.py` | Test repository adapter (mocked DB) | >90% | ⏳ Pending |
| `tests/server/unit/services/conversation/test_conversation_service.py` | Test service layer (mocked repository) | >90% | ⏳ Pending |

**Total Unit Test Files:** 4

---

### Integration Tests (Phase 2, 4)

| File | Purpose | Coverage Target | Status |
|------|---------|-----------------|--------|
| `tests/server/integration/persistence/test_conversation_crud.py` | Test CRUD operations with real SQLite database | >85% | ⏳ Pending |
| `tests/server/integration/api/v1/test_conversation_endpoints.py` | Test E2E API endpoints with database | >85% | ⏳ Pending |
| `tests/server/integration/services/test_conversation_chat_integration.py` | Test conversation service integration with chat endpoint | >85% | ⏳ Pending |

**Total Integration Test Files:** 3

---

### Security Tests (Phase 5)

| File | Purpose | Tools | Status |
|------|---------|-------|--------|
| `tests/server/integration/security/test_sql_injection_conversation.py` | Verify SQL injection prevention (ORM validation) | pytest, sqlalchemy | ⏳ Pending |

**Total Security Test Files:** 1

---

## ⚙️ Configuration Files

| File | Purpose | Modifications | Status |
|------|---------|---------------|--------|
| `.env` | Add `CONTEXT_WINDOW_SIZE=10` config | Add new environment variable | ⏳ Pending |
| `src/server/pyproject.toml` | Add `aiosqlite` dependency if missing | Update dependencies | ⏳ Check |
| `alembic.ini` | Database migration config (if using Alembic) | Create if needed | ⏳ Optional |

---

## 🗄️ Migration Files (Optional)

| File | Purpose | Status |
|------|---------|--------|
| `src/server/app/infrastructure/persistence/migrations/001_create_conversations_table.py` | Alembic migration for conversations table | ⏳ Optional |
| `src/server/app/infrastructure/persistence/migrations/002_create_messages_table.py` | Alembic migration for messages table | ⏳ Optional |

**Note:** For MVP, we can use SQLAlchemy's `create_all()` method. Alembic migrations are recommended for production.

---

## 📊 File Status Matrix

### Summary by Phase

| Phase | Files Expected | Files Complete | Completion % |
|-------|----------------|----------------|--------------|
| **Phase 0** (Documentation) | 4 | 4 | 100% ✅ |
| **Phase 1** (Domain) | 5 | 0 | 0% ⏳ |
| **Phase 2** (Infrastructure) | 8 | 0 | 0% ⏳ |
| **Phase 3** (Service) | 4 | 0 | 0% ⏳ |
| **Phase 4** (API) | 6 | 0 | 0% ⏳ |
| **Phase 5** (Quality) | 6 | 0 | 0% ⏳ |
| **Phase 6** (Validation) | 1 | 0 | 0% ⏳ |
| **TOTAL** | **34** | **4** | **11.76%** |

---

### Summary by Type

| File Type | Total Files | Complete | Pending |
|-----------|-------------|----------|---------|
| Documentation | 9 | 4 | 5 |
| Source Code (Production) | 12 | 0 | 12 |
| Unit Tests | 4 | 0 | 4 |
| Integration Tests | 3 | 0 | 3 |
| Security Tests | 1 | 0 | 1 |
| Configuration | 3 | 0 | 3 |
| Migration (Optional) | 2 | 0 | 2 |
| **TOTAL** | **34** | **4** | **30** |

---

## 🔍 Critical Path Files

These files MUST be completed first (dependencies for other files):

1. **Phase 1: Domain Entities** (blocks Phase 2-6)
   - `conversation.py` and `message.py` (entities)
   - `conversation_repository.py` (protocol)

2. **Phase 2: Infrastructure** (blocks Phase 3-6)
   - `database.py` (session management)
   - `conversation_model.py` and `message_model.py` (SQLAlchemy models)
   - `sqlalchemy_conversation_repository.py` (adapter)

3. **Phase 3: Service Layer** (blocks Phase 4)
   - `conversation_service.py` (business logic)

4. **Phase 4: API Layer**
   - `conversations.py` (endpoints)
   - `conversation.py` (schemas)

---

## 📈 Lines of Code Estimate

| Layer | Files | Estimated LOC | Actual LOC | Difference |
|-------|-------|---------------|------------|------------|
| Domain | 3 | 250 | 0 | - |
| Infrastructure | 4 | 400 | 0 | - |
| Service | 2 | 200 | 0 | - |
| API | 3 | 300 | 0 | - |
| Tests (Unit) | 4 | 600 | 0 | - |
| Tests (Integration) | 3 | 450 | 0 | - |
| Documentation | 9 | 3000 | 1200 | -1800 |
| **TOTAL** | **28** | **5200** | **1200** | **-4000** |

**Note:** LOC estimates are conservative. TDD approach may increase test LOC.

---

## 🚀 File Creation Order (Recommended)

Follow this order to minimize dependency issues:

### Phase 1 (Domain)
1. `conversation.py` → `message.py` → `conversation_repository.py`
2. `test_conversation.py` → `test_message.py`

### Phase 2 (Infrastructure)
1. `database.py` (session management first)
2. `conversation_model.py` → `message_model.py`
3. `sqlalchemy_conversation_repository.py`
4. `test_sqlalchemy_conversation_repository.py` → `test_conversation_crud.py`

### Phase 3 (Service)
1. `conversation_service.py`
2. `test_conversation_service.py` → `test_conversation_chat_integration.py`

### Phase 4 (API)
1. `conversation.py` (schemas)
2. `conversations.py` (router)
3. `test_conversation_endpoints.py`

### Phase 5 (Quality)
1. Run coverage analysis
2. Create documentation (`COVERAGE_REPORT.md`, `SECURITY_AUDIT.md`, etc.)
3. `test_sql_injection_conversation.py` (security test)

### Phase 6 (Validation)
1. Run `PRE_PUSH_VALIDATION_MASTER.sh`
2. `FINAL_AUDIT_REPORT.md`

---

## 📝 Notes

### Dependencies Between Files
- **Domain entities** are referenced by ALL other layers
- **Repository protocol** must be defined before infrastructure implementation
- **SQLAlchemy models** must match domain entities (field mapping)
- **Service layer** depends on repository protocol (NOT concrete implementation)

### Testing Strategy
- **Unit tests:** Mock all external dependencies (database, services)
- **Integration tests:** Use real SQLite database (in-memory or temporary file)
- **Security tests:** Attempt SQL injection attacks (ORM should prevent)

### Code Quality Targets
- **Coverage:** ≥85% overall, ≥95% domain layer
- **Type Safety:** 0 Pyright errors
- **Security:** 0 high-severity Bandit issues
- **Linting:** Black formatted, Ruff clean

---

## 🔗 Related Documentation

- [README.md](./README.md) - HU overview and objectives
- [PROGRESS.md](./PROGRESS.md) - Phase completion tracker
- [WORKFLOW_MASTER_DEFINITION.md](./WORKFLOW_MASTER_DEFINITION.md) - TDD workflow step-by-step
