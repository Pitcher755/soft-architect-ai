# 🔴 PHASE 1: RED - SQLite Investigation Report

> **Project:** SoftArchitect AI
> **HU:** HU-3.6 Test Suite Completion & SQLite Fix (PIT-80)
> **Phase:** 1.2 SQLite Investigation
> **Date:** 2025-01-30
> **Status:** ⚠️ PHASE 1 STEP 1.2 - Codebase Review Complete
> **Methodology:** Empirical code analysis (not speculation)

---

## 📖 Table of Contents

1. [Executive Summary](#executive-summary)
2. [SQLite-Related Test Failures](#sqlite-related-test-failures)
3. [Current SQLite Implementation Analysis](#current-sqlite-implementation-analysis)
4. [Codebase Architecture Review](#codebase-architecture-review)
5. [Identified Gaps and Problems](#identified-gaps-and-problems)
6. [Root Cause Deep Dive](#root-cause-deep-dive)
7. [SQLite Design Recommendations](#sqlite-design-recommendations)
8. [Implementation Plan (PHASE 2: GREEN)](#implementation-plan-phase-2-green)
9. [References](#references)

---

## Executive Summary

### Current State Assessment

| **Aspect** | **Status** | **Details** |
|-----------|-----------|-----------|
| **Transaction Management** | ✅ **IMPLEMENTED** | `TransactionManager` class exists, design looks correct |
| **Connection Pooling** | ⚠️ **INCOMPLETE** | `ConnectionPool` class exists but not integrated |
| **Schema Definition** | ❌ **MISSING** | No CREATE TABLE statements exist anywhere |
| **Domain Entities** | ❌ **MINIMAL** | Only `ChatMessage` exists, no persistence entities |
| **Repository Pattern** | ❌ **MISSING** | Repository interfaces defined but no implementations |
| **CRUD Operations** | ❌ **NOT IMPLEMENTED** | No insert/select/update/delete wrappers |
| **Error Handling** | ⚠️ **PARTIAL** | TransactionManager has error handling, but no domain-level handling |
| **Migrations** | ❌ **NOT IMPLEMENTED** | No schema versioning or migration scripts |
| **Tests** | ❌ **BROKEN** | 13/13 new SQLite tests failing (fixture issue) |

### Critical Findings

1. **Agent's Premature Implementation:**
   - `TransactionManager.py` created without proper testing
   - Tests created with broken fixture (`initialized_db`)
   - 13 immediate test failures due to in-memory database isolation

2. **Architectural Separation is Clean:**
   - Core database initialization logic is isolated (`core/database.py`)
   - Transaction management abstraction is well-designed
   - But not integrated with domain layer

3. **Major Gaps:**
   - No SQL schema defined anywhere
   - Domain entities don't map to database tables
   - No way to persist ANY data to SQLite yet
   - Tests fail because tables don't exist

4. **Current Blocker:**
   - Fixture creates schema in one connection
   - Tests fail because new connections don't see the schema
   - `:memory:` databases are isolated per connection

---

## SQLite-Related Test Failures

### Total SQLite Failures from pytest

**Data Source:** `python_test_results_initial.log`

**Summary:**
- **Total SQLite-specific test failures:** 13
- **Location:** `tests/python/unit/infrastructure/persistence/test_transaction_manager.py`
- **All are from agent-created code** (not pre-existing tests)

### Failure Breakdown by Test Class

#### Class: TestTransactionCommit (3 failures)

| Test Name | Error | Root Cause |
|-----------|-------|-----------|
| `test_transaction_commits_on_success` | `sqlite3.OperationalError: no such table: test` | Table `test` created in fixture, not visible in test |
| `test_insert_commit` | `sqlite3.OperationalError: no such table: projects` | Table `projects` created in fixture, not visible in test |
| `test_update_commit` | `sqlite3.OperationalError: no such table: projects` | Same as above |

#### Class: TestTransactionRollback (3 failures)

| Test Name | Error | Root Cause |
|-----------|-------|-----------|
| `test_rollback_on_exception` | `sqlite3.OperationalError: no such table: test` | Fixture isolation issue |
| `test_partial_changes_rollback` | `sqlite3.OperationalError: no such table: projects` | Fixture isolation issue |
| `test_constraint_violation_rollback` | `sqlite3.OperationalError: no such table: project_metadata` | Fixture isolation issue |

#### Class: TestTransactionAcidity (3 failures)

| Test Name | Error | Root Cause |
|-----------|-------|-----------|
| `test_atomicity` | `sqlite3.OperationalError: no such table: projects` | Fixture isolation issue |
| `test_isolation_level_deferred` | `sqlite3.OperationalError: no such table: test` | Fixture isolation issue |
| `test_multiple_sequential_transactions` | `sqlite3.OperationalError: no such table: projects` | Fixture isolation issue |

#### Class: TestTransactionExecution (2 failures)

| Test Name | Error | Root Cause |
|-----------|-------|-----------|
| `test_execute_multiple_operations` | `sqlite3.OperationalError: no such table: projects` | Fixture isolation issue |
| `test_execute_transaction_rollback_on_error` | `sqlite3.OperationalError: no such table: projects` | Fixture isolation issue |

#### Class: TestTransactionEdgeCases (2 failures)

| Test Name | Error | Root Cause |
|-----------|-------|-----------|
| `test_double_close` | `sqlite3.OperationalError: no such table: test` | Fixture isolation issue |
| `test_transaction_with_rollback_error` | `AssertionError + Rollback Error` | Fixture cleanup failed + assertion error |

### Error Pattern Analysis

**Consistent Error Message:**
```
sqlite3.OperationalError: no such table: {table_name}
```

**Stack Trace Pattern:**
```python
tests/python/unit/infrastructure/persistence/test_transaction_manager.py:60: in test_transaction_commits_on_success
    with tx_manager.transaction() as conn:
src/server/app/infrastructure/persistence/transaction_manager.py:91: in __exit__
    raise
sqlite3.OperationalError: no such table: test
```

**Logger Output (from test execution):**
```
ERROR src.server.app.infrastructure.persistence.transaction_manager:transaction_manager.py:91
Transaction rolled back (operational error): no such table: test
```

### Flutter SQLite Tests

**Status:** No Flutter-specific SQLite tests found (compilation errors prevent test execution)

---

## Current SQLite Implementation Analysis

### 1.2.2 Review Current SQLite Implementation

#### A. Database Initialization (Validated ✅)

**File:** `src/server/app/core/database.py`

**Status:** ✅ CORRECT - Only initializes directories, no database schema

```python
def init_sqlite():
    """Initialize SQLite relational database connection."""
    db_path = Path("./data/softarchitect.db")
    db_path.parent.mkdir(parents=True, exist_ok=True)
    return f"sqlite:///{db_path}"
```

**Assessment:**
- Creates `./data/` directory for database file
- Returns SQLAlchemy-compatible connection string
- ✅ Safe and correct approach

#### B. Transaction Manager (Implemented ❌ with Broken Tests)

**File:** `src/server/app/infrastructure/persistence/transaction_manager.py` (118 lines)

**Status:** ⚠️ **CODE LOOKS CORRECT, TESTS ARE BROKEN**

**Implementation Checklist:**

| Feature | Status | Details |
|---------|--------|---------|
| **Transaction context manager** | ✅ YES | Uses `@contextmanager` decorator |
| **Isolation levels** | ✅ YES | Supports DEFERRED, IMMEDIATE, EXCLUSIVE |
| **Automatic commit** | ✅ YES | Commits on success |
| **Automatic rollback** | ✅ YES | Rollbacks on exception |
| **Error handling** | ✅ YES | Catches IntegrityError, OperationalError, generic Exception |
| **Connection cleanup** | ✅ YES | Closes connection in finally block |
| **Bulk operations** | ✅ YES | `execute_transaction()` method for multiple SQLs |
| **Logging** | ✅ YES | Logs all operations at appropriate levels |

**Code Quality:**
- ✅ Type hints for all parameters
- ✅ Comprehensive docstrings
- ✅ Example usage in docstrings
- ✅ Exception specifications in docstrings

**Problem Identified:**
```python
def __init__(self, db_path: str):
    self.db_path = db_path  # ← Stores path, creates new connection each time
```

Each call to `.transaction()` creates a NEW connection to the database. This is fine for file-based SQLite but problematic for `:memory:` databases because each connection gets isolated in-memory instance.

#### C. Connection Pool (Created but Incomplete ❌)

**File:** `src/server/app/infrastructure/persistence/connection_pool.py` (145 lines)

**Status:** ❌ **INCOMPLETE - NOT INTEGRATED**

**Observation:**
- File exists but probably imports don't work correctly
- Not referenced anywhere in codebase
- Not used in tests

#### D. Domain Entities (Minimal ⚠️)

**File:** `src/server/app/domain/entities/__init__.py` (64 lines)

**Existing Entities:**
```python
class ChatMessage:
    """Represents a message in a chat session."""
    # Basic attributes: id, session_id, role, content, timestamp
```

**Missing Entities:**
- ❌ `Project` (for project management)
- ❌ `FileNode` (for filesystem representation)
- ❌ `ProjectMetadata` (for project tracking)
- ❌ `ChatSession` (for chat context)
- ❌ `DocumentProposal` (for RAG proposals)

#### E. Repository Pattern (Defined but Empty ❌)

**File:** `src/server/app/domain/repositories/__init__.py` (5 lines)

**Status:** ❌ **EMPTY - INTERFACES ONLY**

```python
"""Domain layer: Repository interfaces (contracts)."""
```

**Missing:**
- ❌ `IProjectRepository` interface
- ❌ `IChatRepository` interface
- ❌ Implementations of repositories

---

## Codebase Architecture Review

### Current Directory Structure

```
src/server/app/
├── core/
│   ├── database.py              ✅ Database initialization
│   ├── config.py                ✅ App config
│   ├── errors.py                ✅ Error definitions
│   └── ...
├── domain/
│   ├── entities/
│   │   └── __init__.py          ⚠️ ChatMessage only
│   ├── repositories/
│   │   └── __init__.py          ❌ EMPTY
│   ├── services/
│   │   └── __init__.py
│   └── streaming/
│       └── stream_protocol.py
├── infrastructure/
│   ├── persistence/
│   │   ├── transaction_manager.py        ⚠️ Implemented (tests broken)
│   │   └── connection_pool.py            ❌ Incomplete
│   ├── vector_store/
│   │   └── __init__.py
│   ├── llm/
│   │   └── __init__.py
│   └── external/
│       └── __init__.py
├── api/
│   └── v1/
│       └── ...
└── main.py                      ✅ App entry point
```

### What EXISTS (Clean Architecture)

✅ **Core Layer:** Centralized database, config, error handling
✅ **Domain Layer:** Entity definitions (minimal)
✅ **Infrastructure Layer:** Transaction management, vector store
✅ **API Layer:** REST endpoints

### What DOESN'T EXIST (Critical Gaps)

❌ **Database Schema:** No SQL CREATE TABLE statements
❌ **Data Layer:** No SQLAlchemy models or ORMs
❌ **Repository Implementations:** No concrete data access objects
❌ **Migrations:** No Alembic or custom migration scripts
❌ **Persistence Tests:** Only transaction manager tests (broken)

---

## Identified Gaps and Problems

### Problem 1: No Database Schema ❌

**Severity:** CRITICAL

**Description:**
There is NO file or location where SQL schema is defined. The application initializes a database file but never creates any tables.

**Evidence:**
```bash
$ grep -r "CREATE TABLE" src/
# Returns: (empty - no results)
```

**Impact:**
- Cannot store ANY data in SQLite
- All persistence operations fail
- Core RAG system cannot persist projects/metadata

### Problem 2: Broken Test Fixture ❌

**Severity:** CRITICAL (Blocks testing)

**Description:**
The `initialized_db` fixture creates tables in one connection but tests fail to find those tables.

**Code Issue:**
```python
@pytest.fixture
def initialized_db(tx_manager):
    """Create a test database with schema."""
    with tx_manager.transaction() as conn:  # Creates NEW connection
        conn.execute("CREATE TABLE projects (...)")
    return tx_manager  # Returns DIFFERENT manager (new connection)

def test_insert_commit(self, initialized_db):
    with initialized_db.transaction() as conn:  # Another NEW connection!
        # conn doesn't see the tables created above
        conn.execute("INSERT INTO projects ...")  # ❌ Table doesn't exist!
```

**Root Cause:**
- `:memory:` SQLite databases are isolated per connection
- Each `transaction()` call creates a NEW connection
- Tables created in connection #1 are invisible to connection #2

**Evidence from Logs:**
```
sqlite3.OperationalError: no such table: test
sqlite3.OperationalError: no such table: projects
```

### Problem 3: Missing Domain-to-Database Mapping ❌

**Severity:** HIGH

**Description:**
Domain entities (ChatMessage, Project, etc.) don't have:
- SQLAlchemy model definitions
- Table mappings
- Column definitions
- Primary keys
- Foreign keys

**Example Missing:**
```python
# ❌ NOT IMPLEMENTED
from sqlalchemy import Column, Integer, String
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()

class ProjectEntity(Base):
    __tablename__ = "projects"

    id = Column(Integer, primary_key=True)
    name = Column(String(255), unique=True, nullable=False)
    path = Column(String(500), nullable=False)
    created_at = Column(DateTime, default=datetime.now)
```

### Problem 4: No CRUD Operations ❌

**Severity:** HIGH

**Description:**
There are no repository implementations for:
- **Create:** INSERT operations
- **Read:** SELECT queries with filters
- **Update:** UPDATE operations with PUT/PATCH semantics
- **Delete:** DELETE operations with cascading

**Missing Implementations:**
```python
# ❌ NOT IMPLEMENTED
class ProjectRepository(IProjectRepository):
    def create(self, name: str, path: str) -> Project: ...
    def find_by_id(self, project_id: int) -> Project: ...
    def find_all(self) -> list[Project]: ...
    def update(self, project_id: int, **kwargs) -> Project: ...
    def delete(self, project_id: int) -> bool: ...
```

### Problem 5: Connection Pool Not Integrated ❌

**Severity:** MEDIUM

**Description:**
- `ConnectionPool` class exists but:
  - Not imported anywhere
  - Not used by TransactionManager
  - Not referenced in tests
  - Probably doesn't work with new connection each time

**As Code Shows:**
```python
# connection_pool.py exists but TransactionManager doesn't use it:
class TransactionManager:
    def __init__(self, db_path: str):
        self.db_path = db_path

    @contextmanager
    def transaction(self, isolation_level: str = "DEFERRED"):
        conn = sqlite3.connect(self.db_path)  # ← NEW connection each time
        # connection_pool.py is NOT used here
```

### Problem 6: Missing Error Handling Abstractions ❌

**Severity:** MEDIUM

**Description:**
While TransactionManager has try/except blocks, there's no domain-level error abstraction:

```python
# ❌ NOT IMPLEMENTED
class DatabaseError(Exception):
    """Base class for database errors."""

class ProjectNotFoundError(DatabaseError):
    """Project does not exist."""

class ProjectAlreadyExistsError(DatabaseError):
    """Project name is already taken."""

class DataIntegrityError(DatabaseError):
    """Constraint violation or data corruption."""
```

---

## Root Cause Deep Dive

### Why Do All 13 Tests Fail?

#### The Core Problem: `:memory:` Database Isolation

**SQLite Behavior:**
```
sqlite3.connect(":memory:")  # Connection #1 - isolated in-memory DB
sqlite3.connect(":memory:")  # Connection #2 - DIFFERENT isolated in-memory DB
```

Each `:memory:` connection gets its own isolated RAM database. Tables exist ONLY in that connection.

#### How This Breaks the Tests

**Step 1: Fixture Creates Tables**
```python
@pytest.fixture
def initialized_db(tx_manager):  # tx_manager = TransactionManager(":memory:")
    with tx_manager.transaction() as conn:  # Connection #1
        conn.execute("CREATE TABLE projects (...)")  # Tables exist in conn #1
    return tx_manager
```

**Step 2: Test Uses Same Manager**
```python
def test_insert_commit(self, initialized_db):
    with initialized_db.transaction() as conn:  # Connection #2 (NEW!)
        # Tables created in Connection #1 are NOT visible here
        conn.execute("INSERT INTO projects ...")  # ❌ "no such table"
```

**Visual Representation:**
```
Connection #1 (fixture):
┌──────────────────┐
│ In-Memory DB #1  │
│ ┌──────────────┐ │
│ │ projects     │ │  ← Created here
│ │ metadata     │ │
│ └──────────────┘ │
└──────────────────┘

Connection #2 (test):
┌──────────────────┐
│ In-Memory DB #2  │  ← DIFFERENT isolated database!
│ ┌──────────────┐ │
│ │ (empty)      │ │  ← Tables from #1 are NOT here
│ └──────────────┘ │
└──────────────────┘
```

#### Why TransactionManager Creates New Connections

**Code Pattern:**
```python
class TransactionManager:
    def __init__(self, db_path: str):
        self.db_path = db_path  # Stores PATH, not connection

    @contextmanager
    def transaction(self):
        conn = sqlite3.connect(self.db_path)  # ← NEW connection every time!
        # ...
        finally:
            conn.close()
```

**Design Rationale:**
- ✅ Good for file-based SQLite (each session gets fresh connection)
- ❌ Bad for in-memory testing (each connection is isolated)

---

## SQLite Design Recommendations

### Architecture Pattern: Repository Pattern + TransactionManager

**Recommended Structure:**

```
src/server/app/
├── core/
│   └── database.py                   [Database initialization]
│
├── domain/
│   ├── entities/
│   │   ├── __init__.py              [Pure data classes]
│   │   ├── project.py               [Project entity]
│   │   ├── chat_message.py          [ChatMessage entity]
│   │   └── document_proposal.py     [DocumentProposal entity]
│   │
│   └── repositories/
│       └── __init__.py              [Repository interfaces]
│
├── infrastructure/
│   └── persistence/
│       ├── models.py                [SQLAlchemy models]
│       ├── transaction_manager.py  [ACID context manager]
│       ├── connection_pool.py       [Connection pooling]
│       ├── repositories/
│       │   ├── __init__.py
│       │   ├── project_repository.py [Project CRUD impl]
│       │   ├── chat_repository.py    [Chat CRUD impl]
│       │   └── proposal_repository.py [Proposal CRUD impl]
│       └── migrations/
│           └── versions/
│               └── 001_initial_schema.sql
└── api/
    └── v1/
        └── [endpoints that use repositories]
```

### Schema Design (SQL)

**Required Tables (Based on Test Requirements):**

```sql
-- Projects table
CREATE TABLE projects (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    name TEXT NOT NULL UNIQUE,
    path TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Project metadata table
CREATE TABLE project_metadata (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER NOT NULL UNIQUE,
    last_modified TIMESTAMP,
    last_accessed TIMESTAMP,
    file_count INTEGER DEFAULT 0,
    FOREIGN KEY(project_id) REFERENCES projects(id) ON DELETE CASCADE
);

-- Chat sessions table
CREATE TABLE chat_sessions (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    project_id INTEGER NOT NULL,
    title TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(project_id) REFERENCES projects(id) ON DELETE CASCADE
);

-- Chat messages table
CREATE TABLE chat_messages (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    session_id INTEGER NOT NULL,
    role TEXT NOT NULL CHECK(role IN ('user', 'assistant', 'system')),
    content TEXT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(session_id) REFERENCES chat_sessions(id) ON DELETE CASCADE
);

-- Document proposals table
CREATE TABLE document_proposals (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    message_id INTEGER NOT NULL,
    file_name TEXT NOT NULL,
    validation_state TEXT NOT NULL CHECK(validation_state IN ('pending', 'approved', 'rejected')),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY(message_id) REFERENCES chat_messages(id) ON DELETE CASCADE
);
```

### Test Fixture Fix (PHASE 2)

**Solution: Persistent Shared Connection**

```python
@pytest.fixture
def sqlite_db():
    """Provide a shared in-memory database for all tests."""
    # Create ONE persistent in-memory connection
    conn = sqlite3.connect(":memory:", check_same_thread=False)

    # Create all schema on THIS connection
    conn.execute("""
        CREATE TABLE projects (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL UNIQUE,
            path TEXT NOT NULL,
            created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
        )
    """)
    conn.execute("""
        CREATE TABLE project_metadata (
            id INTEGER PRIMARY KEY,
            project_id INTEGER NOT NULL UNIQUE,
            last_modified TIMESTAMP,
            FOREIGN KEY(project_id) REFERENCES projects(id)
        )
    """)
    conn.commit()

    # Create manager with reference to shared connection
    manager = TransactionManager(":memory:")
    manager._shared_conn = conn  # Inject persistent connection

    yield manager

    conn.close()
```

### Implementation Phases

#### Phase 2.1: Fix Test Fixture
- Modify `initialized_db` to use persistent connection
- Verify all 13 tests pass

#### Phase 2.2: Create SQLAlchemy Models
- Define `ProjectEntity`, `ChatMessageEntity`, etc.
- Map domain entities to database tables

#### Phase 2.3: Implement Repositories
- `ProjectRepository` with CRUD operations
- `ChatSessionRepository`
- `DocumentProposalRepository`

#### Phase 2.4: Integration
- Wire repositories into API endpoints
- Add database initialization to `main.py`
- Create migration chain

---

## Implementation Plan (PHASE 2: GREEN)

### Deliverables for PHASE 2

| Deliverable | File(s) | Est. Effort | Priority |
|-------------|---------|-------------|----------|
| **Fix Test Fixture** | `test_transaction_manager.py` | 30 min | 🔴 URGENT |
| **Verify Tests Pass** | Test execution | 15 min | 🔴 URGENT |
| **Create Schema** | `migrations/001_initial_schema.sql` | 45 min | 🔴 CRITICAL |
| **SQLAlchemy Models** | `persistence/models.py` | 60 min | 🔴 CRITICAL |
| **Project Repository** | `persistence/repositories/project_repository.py` | 60 min | 🟠 HIGH |
| **Chat Repository** | `persistence/repositories/chat_repository.py` | 45 min | 🟠 HIGH |
| **Error Abstractions** | `domain/exceptions/persistence.py` | 30 min | 🟠 HIGH |
| **Coverage Tests** | New test cases for CRUD ops | 90 min | 🟠 HIGH |
| **Integration Tests** | Full persistence workflow tests | 60 min | 🟠 HIGH |

**Total Estimated Effort:** 6-7 hours

### Acceptance Criteria (PHASE 2 Exit)

- ✅ All 13 Python tests pass (blue status)
- ✅ Coverage ≥80% on persistence modules
- ✅ All CRUD operations tested and working
- ✅ Schema properly initialized at app startup
- ✅ 0 compilation errors in Flutter tests
- ✅ No breaking changes to existing API contracts

---

## References

### Files Analyzed

**Core Database:**
- `src/server/app/core/database.py` - ✅ Validated

**Transaction Management:**
- `src/server/app/infrastructure/persistence/transaction_manager.py` - ⚠️ Code correct, tests broken
- `src/server/app/infrastructure/persistence/connection_pool.py` - ❌ Incomplete

**Domain Layer:**
- `src/server/app/domain/entities/__init__.py` - ⚠️ Minimal (only ChatMessage)
- `src/server/app/domain/repositories/__init__.py` - ❌ Empty

**Tests:**
- `tests/python/unit/infrastructure/persistence/test_transaction_manager.py` - ❌ 13 failures
- `python_test_results_initial.log` - ✅ 184 lines, detailed failure info

### Key Issues Summary

| Issue | Severity | Root Cause | Fix |
|-------|----------|-----------|-----|
| 13 test failures | 🔴 CRITICAL | `:memory:` DB isolation + fixture design | Persistent shared connection |
| No schema | 🔴 CRITICAL | Never implemented | Create SQL migration files |
| No repositories | 🔴 CRITICAL | Not implemented | Create repository classes |
| No CRUD | 🔴 CRITICAL | Missing data layer | Implement repository methods |
| Connection pool unused | 🟠 HIGH | Not integrated | Wire into TransactionManager |
| Missing entities | 🟠 HIGH | Not defined | Create Project, etc. entities |

---

**Document Status:** ✅ COMPLETE (Phase 1 Step 1.2)
**Deliverables Created:** This investigation report
**Next Step:** Phase 1 Step 1.3 - i18n Architecture Design
**Last Updated:** 2025-01-30
