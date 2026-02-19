# 💾 WORKFLOW MASTER: HU-4.2 Conversation History & Persistence

> **Version:** 1.0.0
> **Methodology:** TDD Strict + Clean Architecture + Security-First
> **Author:** ArchitectZero
> **Last Updated:** 2026-02-14

---

## 📖 Table of Contents

1. [Introduction & Philosophy](#1-introduction--philosophy)
2. [Phase 0: Setup & Database Schema](#phase-0-setup--database-schema)
3. [Phase 1: Domain Layer (TDD Red/Green)](#phase-1-domain-layer-tdd-redgreen)
4. [Phase 2: Infrastructure - SQLAlchemy (TDD Red/Green)](#phase-2-infrastructure---sqlalchemy-tdd-redgreen)
5. [Phase 3: Service Layer - Context Window (TDD Red/Green)](#phase-3-service-layer---context-window-tdd-redgreen)
6. [Phase 4: FastAPI Endpoints (TDD Red/Green)](#phase-4-fastapi-endpoints-tdd-redgreen)
7. [Phase 5: Quality & Security Hardening](#phase-5-quality--security-hardening)
8. [Phase 6: Validation & PR](#phase-6-validation--pr)
9. [Emergency Procedures](#emergency-procedures)
10. [Success Criteria Matrix](#success-criteria-matrix)

---

## 1. Introduction & Philosophy

### 🎯 Workflow Objectives

**"Construir el sistema de memoria persistente del proyecto con paranoia sobre SQL injection y consistencia de datos"**

Este workflow está diseñado para:
- ✅ **TDD Estricto:** Ninguna línea de código sin test previo (Red → Green → Refactor).
- ✅ **Clean Architecture:** Separación de capas (Domain → Infrastructure → Service → API).
- ✅ **Security-First:** Prevención de inyecciones SQL mediante ORM exclusivamente (ZERO raw SQL).
- ✅ **Type Safety:** 0 errores de Pyright, contratos explícitos con Protocols.
- ✅ **Async-First:** SQLAlchemy 2.0 async API para escalabilidad.

---

### 🔴 Critical Success Factors

| Factor | Acceptance | Validation Method |
|--------|-----------|------------------|
| **Test Coverage** | ≥85% (domain ≥95%) | `pytest --cov --cov-fail-under=85` |
| **SQL Injection Prevention** | 0 vulnerabilities | `bandit -r app/` + manual ORM validation |
| **Type Safety** | 0 Pyright errors | `python -m pyright app/` |
| **Data Integrity** | Foreign keys enforced | Integration tests with constraint violations |
| **Concurrent Writes** | No data corruption | Parallel transaction tests |
| **Code Quality** | Black + Ruff clean | PRE_PUSH_VALIDATION_MASTER.sh |

---

### 🚨 Non-Negotiable Rules

1. **NEVER use raw SQL** (only ORM queries to prevent SQL injection)
2. **NEVER expose SQLAlchemy models outside infrastructure layer** (domain entities only)
3. **NEVER commit code without tests passing**
4. **NEVER skip foreign key constraints** (enforce referential integrity)
5. **NEVER push without running `PRE_PUSH_VALIDATION_MASTER.sh`**
6. **ALWAYS use async/await** for database operations (AsyncSession only)

---

## Phase 0: Setup & Database Schema

**Duration:** 1-2 hours
**Objective:** Define exact database schema and API contracts before coding

---

### ✅ Checklist

#### 0.1 Git & Branch Setup

```bash
# Already done ✅
git checkout develop
git pull origin develop
git checkout -b feature/backend-conversation-history
git branch --show-current

# Create documentation structure ✅
mkdir -p doc/03-HU-TRACKING/HU-4.2-CONVERSATION-HISTORY
```

---

#### 0.2 Define Database Schema (Design Phase)

**Tables Required:**

**1. `conversations` table:**

```sql
CREATE TABLE conversations (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    project_id UUID NOT NULL,  -- Foreign key to projects table (future)
    title VARCHAR(255),          -- Optional conversation title
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_conversations_project_id ON conversations(project_id);
CREATE INDEX idx_conversations_created_at ON conversations(created_at);
```

**2. `messages` table:**

```sql
CREATE TABLE messages (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    conversation_id UUID NOT NULL REFERENCES conversations(id) ON DELETE CASCADE,
    role VARCHAR(20) NOT NULL CHECK (role IN ('USER', 'ASSISTANT', 'SYSTEM')),
    content TEXT NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_messages_conversation_id ON messages(conversation_id);
CREATE INDEX idx_messages_created_at ON messages(created_at);
```

**Relationships:**
- `conversations` 1:N `messages` (one conversation has many messages)
- Foreign key cascade: Deleting conversation deletes all messages

---

#### 0.3 Define Pydantic Schema Contracts

**File:** `src/server/app/domain/schemas/conversation.py`

Create schema skeleton (structure only):

```python
"""
Conversation domain schemas for HU-4.2.

Security considerations:
- UUID validation for all IDs
- Content length limits (max 5000 chars per message)
- Role enum validation (prevent arbitrary roles)
"""

from datetime import datetime
from uuid import UUID
from pydantic import BaseModel, Field
from enum import Enum
from typing import List, Optional


class MessageRole(str, Enum):
    """Message role enum (USER, ASSISTANT, SYSTEM)."""
    USER = "USER"
    ASSISTANT = "ASSISTANT"
    SYSTEM = "SYSTEM"


class MessageCreate(BaseModel):
    """Schema for creating a message."""
    conversation_id: UUID
    role: MessageRole
    content: str = Field(..., max_length=5000)


class MessageResponse(BaseModel):
    """Schema for message response."""
    id: UUID
    conversation_id: UUID
    role: MessageRole
    content: str
    created_at: datetime

    model_config = {"from_attributes": True}


class ConversationCreate(BaseModel):
    """Schema for creating a conversation."""
    project_id: UUID
    title: Optional[str] = Field(None, max_length=255)


class ConversationResponse(BaseModel):
    """Schema for conversation response."""
    id: UUID
    project_id: UUID
    title: Optional[str]
    created_at: datetime
    updated_at: datetime
    messages: List[MessageResponse] = []

    model_config = {"from_attributes": True}


class ConversationList(BaseModel):
    """Schema for paginated conversation list."""
    conversations: List[ConversationResponse]
    total: int
    skip: int
    limit: int
```

---

### 📝 Phase 0 Validation

Run this checklist before proceeding to Phase 1:

```bash
# 1. Verify branch
git branch --show-current  # Should output: feature/backend-conversation-history

# 2. Verify documentation exists
ls doc/03-HU-TRACKING/HU-4.2-CONVERSATION-HISTORY/
# Should show: README.md, PROGRESS.md, ARTIFACTS.md, WORKFLOW_MASTER_DEFINITION.md

# 3. Verify schema design reviewed
cat doc/03-HU-TRACKING/HU-4.2-CONVERSATION-HISTORY/WORKFLOW_MASTER_DEFINITION.md | grep "conversations table"
```

✅ **Phase 0 Complete** when all files created and schema validated.

---

## Phase 1: Domain Layer (TDD Red/Green)

**Duration:** 2 hours
**Objective:** Create domain entities and repository protocol with TDD validation

---

### 🔴 Step 1.1: Domain Entities (Red → Green)

#### 1.1.1 Create Test First (RED)

**File:** `tests/server/unit/domain/entities/test_message.py`

```python
"""
Unit tests for Message entity.

Test Coverage:
- Field validation (UUID, role enum, content length)
- Required field enforcement
- Timestamp generation
"""

import pytest
from datetime import datetime, UTC
from uuid import uuid4
from src.server.app.domain.entities.message import Message, MessageRole


def test_message_creation_with_valid_data():
    """Test creating message with all valid fields."""
    # Arrange
    msg_id = uuid4()
    conv_id = uuid4()
    role = MessageRole.USER
    content = "Hello, world!"
    created_at = datetime.now(UTC)

    # Act
    message = Message(
        id=msg_id,
        conversation_id=conv_id,
        role=role,
        content=content,
        created_at=created_at
    )

    # Assert
    assert message.id == msg_id
    assert message.conversation_id == conv_id
    assert message.role == MessageRole.USER
    assert message.content == content
    assert message.created_at == created_at


def test_message_content_must_not_be_empty():
    """Test that empty content raises validation error."""
    # Arrange
    msg_id = uuid4()
    conv_id = uuid4()

    # Act & Assert
    with pytest.raises(ValueError, match="Content cannot be empty"):
        Message(
            id=msg_id,
            conversation_id=conv_id,
            role=MessageRole.USER,
            content="",
            created_at=datetime.now(UTC)
        )


def test_message_content_max_length_5000_chars():
    """Test that content >5000 chars raises validation error."""
    # Arrange
    msg_id = uuid4()
    conv_id = uuid4()
    long_content = "a" * 5001  # 5001 characters

    # Act & Assert
    with pytest.raises(ValueError, match="Content exceeds maximum length"):
        Message(
            id=msg_id,
            conversation_id=conv_id,
            role=MessageRole.USER,
            content=long_content,
            created_at=datetime.now(UTC)
        )


def test_message_role_must_be_valid_enum():
    """Test that invalid role raises validation error."""
    # Arrange
    msg_id = uuid4()
    conv_id = uuid4()

    # Act & Assert
    with pytest.raises(ValueError, match="Invalid role"):
        Message(
            id=msg_id,
            conversation_id=conv_id,
            role="INVALID_ROLE",  # Not in enum
            content="Hello",
            created_at=datetime.now(UTC)
        )
```

#### 1.1.2 Run Test (Should FAIL - RED)

```bash
cd /home/pitcherdev/Espacio-de-trabajo/Master/soft-architect-ai
source venv/bin/activate
pytest tests/server/unit/domain/entities/test_message.py -v
```

**Expected Output:** `ModuleNotFoundError` (entity doesn't exist yet).

---

#### 1.1.3 Implement Minimum Code (GREEN)

**File:** `src/server/app/domain/entities/message.py`

```python
"""
Message domain entity for HU-4.2.

This is a PURE domain entity with ZERO infrastructure dependencies.
"""

from dataclasses import dataclass
from datetime import datetime
from uuid import UUID
from enum import Enum


class MessageRole(str, Enum):
    """Message role enum."""
    USER = "USER"
    ASSISTANT = "ASSISTANT"
    SYSTEM = "SYSTEM"


@dataclass(frozen=True)
class Message:
    """
    Message entity (immutable).

    Validation rules:
    - content: max 5000 chars, not empty
    - role: must be valid MessageRole enum value
    """

    id: UUID
    conversation_id: UUID
    role: MessageRole
    content: str
    created_at: datetime

    def __post_init__(self):
        """Validate fields (runs after __init__)."""
        # Validate content
        if not self.content or len(self.content) == 0:
            raise ValueError("Content cannot be empty")

        if len(self.content) > 5000:
            raise ValueError(f"Content exceeds maximum length (5000 chars): {len(self.content)}")

        # Validate role
        if not isinstance(self.role, MessageRole):
            raise ValueError(f"Invalid role: {self.role}. Must be MessageRole enum.")
```

#### 1.1.4 Run Test (Should PASS - GREEN)

```bash
pytest tests/server/unit/domain/entities/test_message.py -v
```

**Expected Output:** All 4 tests pass ✅

---

### 🔴 Step 1.2: Conversation Entity (Red → Green)

#### 1.2.1 Create Test First (RED)

**File:** `tests/server/unit/domain/entities/test_conversation.py`

```python
"""
Unit tests for Conversation entity.

Test Coverage:
- Field validation (UUID, title length)
- Message list relationship
- Timestamp generation
"""

import pytest
from datetime import datetime, UTC
from uuid import uuid4
from src.server.app.domain.entities.conversation import Conversation
from src.server.app.domain.entities.message import Message, MessageRole


def test_conversation_creation_with_valid_data():
    """Test creating conversation with all valid fields."""
    # Arrange
    conv_id = uuid4()
    project_id = uuid4()
    title = "Test Conversation"
    created_at = datetime.now(UTC)
    updated_at = datetime.now(UTC)

    # Act
    conversation = Conversation(
        id=conv_id,
        project_id=project_id,
        title=title,
        messages=[],
        created_at=created_at,
        updated_at=updated_at
    )

    # Assert
    assert conversation.id == conv_id
    assert conversation.project_id == project_id
    assert conversation.title == title
    assert len(conversation.messages) == 0
    assert conversation.created_at == created_at


def test_conversation_title_optional():
    """Test that title is optional (can be None)."""
    # Arrange
    conv_id = uuid4()
    project_id = uuid4()

    # Act
    conversation = Conversation(
        id=conv_id,
        project_id=project_id,
        title=None,
        messages=[],
        created_at=datetime.now(UTC),
        updated_at=datetime.now(UTC)
    )

    # Assert
    assert conversation.title is None


def test_conversation_title_max_length_255_chars():
    """Test that title >255 chars raises validation error."""
    # Arrange
    conv_id = uuid4()
    project_id = uuid4()
    long_title = "a" * 256  # 256 characters

    # Act & Assert
    with pytest.raises(ValueError, match="Title exceeds maximum length"):
        Conversation(
            id=conv_id,
            project_id=project_id,
            title=long_title,
            messages=[],
            created_at=datetime.now(UTC),
            updated_at=datetime.now(UTC)
        )


def test_conversation_can_have_messages():
    """Test that conversation can store messages."""
    # Arrange
    conv_id = uuid4()
    project_id = uuid4()
    msg1 = Message(
        id=uuid4(),
        conversation_id=conv_id,
        role=MessageRole.USER,
        content="Hello",
        created_at=datetime.now(UTC)
    )

    # Act
    conversation = Conversation(
        id=conv_id,
        project_id=project_id,
        title="Test",
        messages=[msg1],
        created_at=datetime.now(UTC),
        updated_at=datetime.now(UTC)
    )

    # Assert
    assert len(conversation.messages) == 1
    assert conversation.messages[0].content == "Hello"
```

#### 1.2.2 Implement Conversation Entity (GREEN)

**File:** `src/server/app/domain/entities/conversation.py`

```python
"""
Conversation domain entity for HU-4.2.

This is a PURE domain entity with ZERO infrastructure dependencies.
"""

from dataclasses import dataclass, field
from datetime import datetime
from uuid import UUID
from typing import List, Optional
from src.server.app.domain.entities.message import Message


@dataclass
class Conversation:
    """
    Conversation entity (mutable to allow adding messages).

    Validation rules:
    - title: max 255 chars, optional
    - messages: list of Message entities (can be empty)
    """

    id: UUID
    project_id: UUID
    title: Optional[str]
    messages: List[Message] = field(default_factory=list)
    created_at: datetime = field(default_factory=lambda: datetime.now(UTC))
    updated_at: datetime = field(default_factory=lambda: datetime.now(UTC))

    def __post_init__(self):
        """Validate fields."""
        # Validate title length
        if self.title is not None and len(self.title) > 255:
            raise ValueError(f"Title exceeds maximum length (255 chars): {len(self.title)}")

    def add_message(self, message: Message) -> None:
        """Add message to conversation and update timestamp."""
        self.messages.append(message)
        self.updated_at = datetime.now(UTC)

    def get_last_n_messages(self, n: int = 10) -> List[Message]:
        """
        Get last N messages (context window).

        Args:
            n: Number of messages to retrieve (default 10)

        Returns:
            List of last N messages (chronological order)
        """
        return self.messages[-n:] if len(self.messages) >= n else self.messages
```

#### 1.2.3 Run Tests (GREEN)

```bash
pytest tests/server/unit/domain/entities/test_conversation.py -v
```

---

### 🔴 Step 1.3: Repository Protocol (Port)

#### 1.3.1 Define Protocol

**File:** `src/server/app/domain/repositories/conversation_repository.py`

```python
"""
Conversation repository protocol (port) for HU-4.2.

This is an INTERFACE (Protocol) - defines contract, NOT implementation.
"""

from typing import Protocol, List, Optional
from uuid import UUID
from src.server.app.domain.entities.conversation import Conversation
from src.server.app.domain.entities.message import Message


class ConversationRepository(Protocol):
    """
    Repository protocol for conversation persistence.

    Implementations:
    - SQLAlchemyConversationRepository (infrastructure layer)
    """

    async def create_conversation(
        self,
        project_id: UUID,
        title: Optional[str] = None
    ) -> Conversation:
        """
        Create new conversation.

        Args:
            project_id: Associated project UUID
            title: Optional conversation title

        Returns:
            Created Conversation entity

        Raises:
            DatabaseWriteError: If creation fails
        """
        ...

    async def get_conversation(self, conversation_id: UUID) -> Optional[Conversation]:
        """
        Get conversation by ID with all messages.

        Args:
            conversation_id: Conversation UUID

        Returns:
            Conversation entity or None if not found

        Raises:
            DatabaseReadError: If query fails
        """
        ...

    async def list_conversations(
        self,
        project_id: Optional[UUID] = None,
        skip: int = 0,
        limit: int = 100
    ) -> List[Conversation]:
        """
        List conversations with pagination.

        Args:
            project_id: Filter by project (optional)
            skip: Number of records to skip
            limit: Maximum records to return

        Returns:
            List of Conversation entities

        Raises:
            DatabaseReadError: If query fails
        """
        ...

    async def add_message(
        self,
        conversation_id: UUID,
        message: Message
    ) -> Message:
        """
        Add message to conversation.

        Args:
            conversation_id: Conversation UUID
            message: Message entity to add

        Returns:
            Created Message entity

        Raises:
            DatabaseWriteError: If write fails
            NotFoundError: If conversation doesn't exist
        """
        ...

    async def get_last_n_messages(
        self,
        conversation_id: UUID,
        n: int = 10
    ) -> List[Message]:
        """
        Get last N messages from conversation (context window).

        Args:
            conversation_id: Conversation UUID
            n: Number of messages to retrieve

        Returns:
            List of last N messages (chronological order)

        Raises:
            DatabaseReadError: If query fails
        """
        ...
```

---

### 📝 Phase 1 Validation

Run these commands:

```bash
# 1. Run domain entity tests
pytest tests/server/unit/domain/entities/ -v --cov=src/server/app/domain/entities --cov-report=term-missing

# 2. Verify >95% coverage
# Expected: test_message.py (4 tests), test_conversation.py (4 tests) = 8 tests pass

# 3. Type check
python -m pyright src/server/app/domain/

# 4. Format code
black src/server/app/domain/
```

✅ **Phase 1 Complete** when:
- 8 tests pass
- Coverage >95%
- 0 Pyright errors

---

## Phase 2: Infrastructure - SQLAlchemy (TDD Red/Green)

**Duration:** 3 hours
**Objective:** Implement database models and repository adapter with async support

---

### 🔴 Step 2.1: SQLAlchemy Models (Red → Green)

#### 2.1.1 Create Database Configuration

**File:** `src/server/app/infrastructure/persistence/database.py`

```python
"""
Database session management for SQLite with async support.

Security:
- Connection pooling (max 5 concurrent connections)
- Parameterized queries only (ORM enforced)
"""

from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker
from sqlalchemy.orm import declarative_base
import os

# Database URL (SQLite async)
DATABASE_URL = os.getenv("DATABASE_URL", "sqlite+aiosqlite:///./conversations.db")

# Create async engine
engine = create_async_engine(
    DATABASE_URL,
    echo=False,  # Set True for SQL query logging (dev only)
    pool_size=5,
    max_overflow=10
)

# Create async session maker
async_session_maker = async_sessionmaker(
    engine,
    class_=AsyncSession,
    expire_on_commit=False
)

# Base class for models
Base = declarative_base()


async def get_db_session() -> AsyncSession:
    """
    Dependency injection for FastAPI.

    Usage:
        @app.get("/api/v1/conversations")
        async def list_conversations(db: AsyncSession = Depends(get_db_session)):
            ...
    """
    async with async_session_maker() as session:
        try:
            yield session
            await session.commit()
        except Exception:
            await session.rollback()
            raise
        finally:
            await session.close()


async def create_tables():
    """Create all tables (for development/testing)."""
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)


async def drop_tables():
    """Drop all tables (for testing cleanup)."""
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.drop_all)
```

#### 2.1.2 Create SQLAlchemy Models

**File:** `src/server/app/infrastructure/persistence/models/conversation_model.py`

```python
"""
SQLAlchemy model for conversations table.

Security:
- Foreign keys enforced
- Cascading deletes (delete conversation → delete messages)
"""

from sqlalchemy import Column, String, DateTime, Index
from sqlalchemy.dialects.postgresql import UUID as PG_UUID
from sqlalchemy.orm import relationship
from datetime import datetime, UTC
import uuid

from src.server.app.infrastructure.persistence.database import Base


class ConversationModel(Base):
    """SQLAlchemy model for conversations table."""

    __tablename__ = "conversations"

    id = Column(
        PG_UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        nullable=False
    )

    project_id = Column(PG_UUID(as_uuid=True), nullable=False)

    title = Column(String(255), nullable=True)

    created_at = Column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(UTC)
    )

    updated_at = Column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(UTC),
        onupdate=lambda: datetime.now(UTC)
    )

    # Relationship: one conversation has many messages
    messages = relationship(
        "MessageModel",
        back_populates="conversation",
        cascade="all, delete-orphan",  # Delete messages when conversation deleted
        lazy="selectin"  # Load messages eagerly
    )

    # Indexes
    __table_args__ = (
        Index("idx_conversations_project_id", "project_id"),
        Index("idx_conversations_created_at", "created_at"),
    )
```

**File:** `src/server/app/infrastructure/persistence/models/message_model.py`

```python
"""
SQLAlchemy model for messages table.

Security:
- Foreign key constraint enforced (conversation must exist)
- Role enum validation
"""

from sqlalchemy import Column, String, Text, DateTime, ForeignKey, Index, CheckConstraint
from sqlalchemy.dialects.postgresql import UUID as PG_UUID
from sqlalchemy.orm import relationship
from datetime import datetime, UTC
import uuid

from src.server.app.infrastructure.persistence.database import Base


class MessageModel(Base):
    """SQLAlchemy model for messages table."""

    __tablename__ = "messages"

    id = Column(
        PG_UUID(as_uuid=True),
        primary_key=True,
        default=uuid.uuid4,
        nullable=False
    )

    conversation_id = Column(
        PG_UUID(as_uuid=True),
        ForeignKey("conversations.id", ondelete="CASCADE"),
        nullable=False
    )

    role = Column(String(20), nullable=False)

    content = Column(Text, nullable=False)

    created_at = Column(
        DateTime(timezone=True),
        nullable=False,
        default=lambda: datetime.now(UTC)
    )

    # Relationship: many messages belong to one conversation
    conversation = relationship("ConversationModel", back_populates="messages")

    # Constraints
    __table_args__ = (
        CheckConstraint("role IN ('USER', 'ASSISTANT', 'SYSTEM')", name="check_role_enum"),
        Index("idx_messages_conversation_id", "conversation_id"),
        Index("idx_messages_created_at", "created_at"),
    )
```

---

### 🔴 Step 2.2: Repository Adapter (Red → Green)

#### 2.2.1 Create Test First (RED)

**File:** `tests/server/unit/infrastructure/persistence/test_sqlalchemy_conversation_repository.py`

```python
"""
Unit tests for SQLAlchemyConversationRepository.

Test Coverage:
- CRUD operations (create, read, list)
- Context window (get_last_n_messages)
- Error handling (not found, database errors)
"""

import pytest
from uuid import uuid4
from datetime import datetime, UTC
from unittest.mock import AsyncMock, MagicMock, patch

from src.server.app.infrastructure.persistence.repositories.sqlalchemy_conversation_repository import (
    SQLAlchemyConversationRepository
)
from src.server.app.domain.entities.conversation import Conversation
from src.server.app.domain.entities.message import Message, MessageRole


@pytest.mark.asyncio
async def test_create_conversation_success():
    """Test creating conversation successfully."""
    # Arrange
    mock_session = AsyncMock()
    repository = SQLAlchemyConversationRepository(mock_session)
    project_id = uuid4()
    title = "Test Conversation"

    # Act
    conversation = await repository.create_conversation(project_id, title)

    # Assert
    assert conversation.project_id == project_id
    assert conversation.title == title
    assert len(conversation.messages) == 0
    mock_session.add.assert_called_once()
    mock_session.commit.assert_awaited_once()


@pytest.mark.asyncio
async def test_get_conversation_returns_entity_when_found():
    """Test retrieving existing conversation."""
    # Arrange
    mock_session = AsyncMock()
    repository = SQLAlchemyConversationRepository(mock_session)
    conv_id = uuid4()

    # Mock result
    mock_model = MagicMock()
    mock_model.id = conv_id
    mock_model.project_id = uuid4()
    mock_model.title = "Test"
    mock_model.messages = []
    mock_model.created_at = datetime.now(UTC)
    mock_model.updated_at = datetime.now(UTC)

    mock_session.execute = AsyncMock(return_value=MagicMock(scalar_one_or_none=lambda: mock_model))

    # Act
    conversation = await repository.get_conversation(conv_id)

    # Assert
    assert conversation is not None
    assert conversation.id == conv_id


@pytest.mark.asyncio
async def test_get_conversation_returns_none_when_not_found():
    """Test retrieving non-existent conversation returns None."""
    # Arrange
    mock_session = AsyncMock()
    repository = SQLAlchemyConversationRepository(mock_session)
    conv_id = uuid4()

    # Mock no result
    mock_session.execute = AsyncMock(return_value=MagicMock(scalar_one_or_none=lambda: None))

    # Act
    conversation = await repository.get_conversation(conv_id)

    # Assert
    assert conversation is None
```

#### 2.2.2 Implement Repository Adapter (GREEN)

**File:** `src/server/app/infrastructure/persistence/repositories/sqlalchemy_conversation_repository.py`

```python
"""
SQLAlchemy implementation of ConversationRepository.

Security:
- All queries use ORM (parameterized, SQL injection safe)
- Foreign key constraints enforced by database
"""

from typing import List, Optional
from uuid import UUID
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, desc
from datetime import datetime, UTC

from src.server.app.domain.entities.conversation import Conversation
from src.server.app.domain.entities.message import Message, MessageRole
from src.server.app.infrastructure.persistence.models.conversation_model import ConversationModel
from src.server.app.infrastructure.persistence.models.message_model import MessageModel


class SQLAlchemyConversationRepository:
    """
    SQLAlchemy adapter for ConversationRepository protocol.

    Translates between domain entities and SQLAlchemy models.
    """

    def __init__(self, session: AsyncSession):
        """Initialize with async session."""
        self.session = session

    async def create_conversation(
        self,
        project_id: UUID,
        title: Optional[str] = None
    ) -> Conversation:
        """Create new conversation."""
        # Create SQLAlchemy model
        model = ConversationModel(
            project_id=project_id,
            title=title
        )

        self.session.add(model)
        await self.session.commit()
        await self.session.refresh(model)

        # Convert to domain entity
        return self._model_to_entity(model)

    async def get_conversation(self, conversation_id: UUID) -> Optional[Conversation]:
        """Get conversation by ID with messages."""
        stmt = select(ConversationModel).where(ConversationModel.id == conversation_id)
        result = await self.session.execute(stmt)
        model = result.scalar_one_or_none()

        if model is None:
            return None

        return self._model_to_entity(model)

    async def list_conversations(
        self,
        project_id: Optional[UUID] = None,
        skip: int = 0,
        limit: int = 100
    ) -> List[Conversation]:
        """List conversations with pagination."""
        stmt = select(ConversationModel).order_by(desc(ConversationModel.created_at))

        if project_id is not None:
            stmt = stmt.where(ConversationModel.project_id == project_id)

        stmt = stmt.offset(skip).limit(limit)

        result = await self.session.execute(stmt)
        models = result.scalars().all()

        return [self._model_to_entity(model) for model in models]

    async def add_message(
        self,
        conversation_id: UUID,
        message: Message
    ) -> Message:
        """Add message to conversation."""
        # Create SQLAlchemy model
        model = MessageModel(
            id=message.id,
            conversation_id=conversation_id,
            role=message.role.value,
            content=message.content,
            created_at=message.created_at
        )

        self.session.add(model)
        await self.session.commit()
        await self.session.refresh(model)

        # Update conversation timestamp
        stmt = select(ConversationModel).where(ConversationModel.id == conversation_id)
        result = await self.session.execute(stmt)
        conv_model = result.scalar_one()
        conv_model.updated_at = datetime.now(UTC)
        await self.session.commit()

        return self._message_model_to_entity(model)

    async def get_last_n_messages(
        self,
        conversation_id: UUID,
        n: int = 10
    ) -> List[Message]:
        """Get last N messages from conversation."""
        stmt = (
            select(MessageModel)
            .where(MessageModel.conversation_id == conversation_id)
            .order_by(MessageModel.created_at)
            .limit(n)
        )

        result = await self.session.execute(stmt)
        models = result.scalars().all()

        # Get last N (slice from end)
        last_n = list(models)[-n:]

        return [self._message_model_to_entity(model) for model in last_n]

    def _model_to_entity(self, model: ConversationModel) -> Conversation:
        """Convert SQLAlchemy model to domain entity."""
        messages = [self._message_model_to_entity(msg) for msg in model.messages]

        return Conversation(
            id=model.id,
            project_id=model.project_id,
            title=model.title,
            messages=messages,
            created_at=model.created_at,
            updated_at=model.updated_at
        )

    def _message_model_to_entity(self, model: MessageModel) -> Message:
        """Convert SQLAlchemy MessageModel to domain Message entity."""
        return Message(
            id=model.id,
            conversation_id=model.conversation_id,
            role=MessageRole(model.role),
            content=model.content,
            created_at=model.created_at
        )
```

---

### 🔴 Step 2.3: Integration Tests (Database)

**File:** `tests/server/integration/persistence/test_conversation_crud.py`

```python
"""
Integration tests for conversation persistence.

Uses real SQLite database (in-memory for speed).

Test Coverage:
- Complete CRUD flow
- Foreign key constraints
- Concurrent writes (transaction isolation)
"""

import pytest
from uuid import uuid4
from datetime import datetime, UTC
from sqlalchemy.ext.asyncio import create_async_engine, AsyncSession, async_sessionmaker

from src.server.app.infrastructure.persistence.database import Base
from src.server.app.infrastructure.persistence.repositories.sqlalchemy_conversation_repository import (
    SQLAlchemyConversationRepository
)
from src.server.app.domain.entities.message import Message, MessageRole


# Fixture: in-memory database
@pytest.fixture
async def db_session():
    """Create in-memory SQLite database for testing."""
    engine = create_async_engine("sqlite+aiosqlite:///:memory:")

    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    async_session = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

    async with async_session() as session:
        yield session

    await engine.dispose()


@pytest.mark.asyncio
async def test_create_and_retrieve_conversation(db_session):
    """Test E2E: create conversation → retrieve with messages."""
    # Arrange
    repository = SQLAlchemyConversationRepository(db_session)
    project_id = uuid4()
    title = "Test Conversation"

    # Act: Create conversation
    conversation = await repository.create_conversation(project_id, title)

    # Act: Add message
    message = Message(
        id=uuid4(),
        conversation_id=conversation.id,
        role=MessageRole.USER,
        content="Hello, world!",
        created_at=datetime.now(UTC)
    )
    await repository.add_message(conversation.id, message)

    # Act: Retrieve conversation
    retrieved = await repository.get_conversation(conversation.id)

    # Assert
    assert retrieved is not None
    assert retrieved.id == conversation.id
    assert retrieved.title == title
    assert len(retrieved.messages) == 1
    assert retrieved.messages[0].content == "Hello, world!"


@pytest.mark.asyncio
async def test_list_conversations_with_pagination(db_session):
    """Test listing conversations with skip/limit."""
    # Arrange
    repository = SQLAlchemyConversationRepository(db_session)
    project_id = uuid4()

    # Create 5 conversations
    for i in range(5):
        await repository.create_conversation(project_id, f"Conv {i}")

    # Act: List first 2
    conversations = await repository.list_conversations(skip=0, limit=2)

    # Assert
    assert len(conversations) == 2


@pytest.mark.asyncio
async def test_get_last_n_messages_returns_correct_count(db_session):
    """Test context window (last 10 messages)."""
    # Arrange
    repository = SQLAlchemyConversationRepository(db_session)
    project_id = uuid4()
    conversation = await repository.create_conversation(project_id, "Test")

    # Add 15 messages
    for i in range(15):
        message = Message(
            id=uuid4(),
            conversation_id=conversation.id,
            role=MessageRole.USER,
            content=f"Message {i}",
            created_at=datetime.now(UTC)
        )
        await repository.add_message(conversation.id, message)

    # Act: Get last 10
    last_10 = await repository.get_last_n_messages(conversation.id, n=10)

    # Assert
    assert len(last_10) == 10
    assert last_10[-1].content == "Message 14"  # Last message
```

---

### 📝 Phase 2 Validation

Run these commands:

```bash
# 1. Run unit tests for repository
pytest tests/server/unit/infrastructure/persistence/ -v --cov=src/server/app/infrastructure/persistence/repositories

# 2. Run integration tests (with real database)
pytest tests/server/integration/persistence/ -v

# 3. Type check
python -m pyright src/server/app/infrastructure/

# 4. Format code
black src/server/app/infrastructure/
```

✅ **Phase 2 Complete** when:
- All tests pass (unit + integration)
- Coverage >90%
- 0 Pyright errors

---

## Phase 3: Service Layer - Context Window (TDD Red/Green)

**Duration:** 2 hours
**Objective:** Create service layer with context window logic and integrate with chat endpoint

---

### 🔴 Step 3.1: Conversation Service (Red → Green)

#### 3.1.1 Create Test First (RED)

**File:** `tests/server/unit/services/conversation/test_conversation_service.py`

```python
"""
Unit tests for ConversationService.

Test Coverage:
- Context window logic (exactly 10 messages)
- Integration with chat endpoint
"""

import pytest
from uuid import uuid4
from unittest.mock import AsyncMock, MagicMock
from datetime import datetime, UTC

from src.server.app.services.conversation.conversation_service import ConversationService
from src.server.app.domain.entities.conversation import Conversation
from src.server.app.domain.entities.message import Message, MessageRole


@pytest.mark.asyncio
async def test_get_context_window_returns_last_10_messages():
    """Test that context window returns exactly 10 messages."""
    # Arrange
    mock_repository = AsyncMock()
    service = ConversationService(mock_repository)
    conv_id = uuid4()

    # Mock 15 messages
    messages = [
        Message(
            id=uuid4(),
            conversation_id=conv_id,
            role=MessageRole.USER,
            content=f"Message {i}",
            created_at=datetime.now(UTC)
        )
        for i in range(15)
    ]

    mock_repository.get_last_n_messages.return_value = messages[-10:]

    # Act
    context = await service.get_context_window(conv_id)

    # Assert
    assert len(context) == 10
    assert context[-1].content == "Message 14"


@pytest.mark.asyncio
async def test_create_conversation_calls_repository():
    """Test creating conversation."""
    # Arrange
    mock_repository = AsyncMock()
    service = ConversationService(mock_repository)
    project_id = uuid4()
    title = "Test"

    mock_conversation = Conversation(
        id=uuid4(),
        project_id=project_id,
        title=title,
        messages=[],
        created_at=datetime.now(UTC),
        updated_at=datetime.now(UTC)
    )
    mock_repository.create_conversation.return_value = mock_conversation

    # Act
    conversation = await service.create_conversation(project_id, title)

    # Assert
    assert conversation.project_id == project_id
    mock_repository.create_conversation.assert_awaited_once_with(project_id, title)
```

#### 3.1.2 Implement Service (GREEN)

**File:** `src/server/app/services/conversation/conversation_service.py`

```python
"""
Conversation service for HU-4.2.

Business logic:
- Context window management (last 10 messages)
- Conversation lifecycle
"""

from typing import List, Optional
from uuid import UUID

from src.server.app.domain.entities.conversation import Conversation
from src.server.app.domain.entities.message import Message
from src.server.app.domain.repositories.conversation_repository import ConversationRepository


class ConversationService:
    """
    Service layer for conversation management.

    Dependencies:
    - ConversationRepository (protocol)
    """

    def __init__(self, repository: ConversationRepository):
        """Initialize with repository."""
        self.repository = repository

    async def create_conversation(
        self,
        project_id: UUID,
        title: Optional[str] = None
    ) -> Conversation:
        """Create new conversation."""
        return await self.repository.create_conversation(project_id, title)

    async def get_conversation(self, conversation_id: UUID) -> Optional[Conversation]:
        """Get conversation by ID."""
        return await self.repository.get_conversation(conversation_id)

    async def list_conversations(
        self,
        project_id: Optional[UUID] = None,
        skip: int = 0,
        limit: int = 100
    ) -> List[Conversation]:
        """List conversations with pagination."""
        return await self.repository.list_conversations(project_id, skip, limit)

    async def add_message(
        self,
        conversation_id: UUID,
        message: Message
    ) -> Message:
        """Add message to conversation."""
        return await self.repository.add_message(conversation_id, message)

    async def get_context_window(
        self,
        conversation_id: UUID,
        window_size: int = 10
    ) -> List[Message]:
        """
        Get last N messages for LLM context window.

        Args:
            conversation_id: Conversation UUID
            window_size: Number of messages (default 10)

        Returns:
            List of last N messages (chronological order)
        """
        return await self.repository.get_last_n_messages(conversation_id, window_size)
```

---

### 📝 Phase 3 Validation

```bash
# 1. Run service tests
pytest tests/server/unit/services/conversation/ -v --cov=src/server/app/services/conversation

# 2. Type check
python -m pyright src/server/app/services/

# 3. Format code
black src/server/app/services/
```

✅ **Phase 3 Complete** when:
- All tests pass
- Coverage >90%
- 0 Pyright errors

---

## Phase 4: FastAPI Endpoints (TDD Red/Green)

**Duration:** 2 hours
**Objective:** Implement REST endpoints for conversation CRUD

---

### 🔴 Step 4.1: API Endpoints (Red → Green)

#### 4.1.1 Create Test First (RED)

**File:** `tests/server/integration/api/v1/test_conversation_endpoints.py`

```python
"""
Integration tests for conversation API endpoints.

Test Coverage:
- POST /api/v1/conversations (create)
- GET /api/v1/conversations/{id} (retrieve)
- GET /api/v1/conversations (list)
"""

import pytest
from httpx import AsyncClient, ASGITransport
from uuid import uuid4
from src.server.app.main import app


@pytest.mark.asyncio
async def test_create_conversation_returns_201():
    """Test creating conversation via API."""
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        # Arrange
        payload = {
            "project_id": str(uuid4()),
            "title": "Test Conversation"
        }

        # Act
        response = await client.post("/api/v1/conversations", json=payload)

        # Assert
        assert response.status_code == 201
        data = response.json()
        assert "id" in data
        assert data["title"] == "Test Conversation"


@pytest.mark.asyncio
async def test_get_conversation_returns_200():
    """Test retrieving conversation via API."""
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        # Arrange: Create conversation first
        payload = {"project_id": str(uuid4()), "title": "Test"}
        create_response = await client.post("/api/v1/conversations", json=payload)
        conv_id = create_response.json()["id"]

        # Act: Retrieve
        response = await client.get(f"/api/v1/conversations/{conv_id}")

        # Assert
        assert response.status_code == 200
        data = response.json()
        assert data["id"] == conv_id


@pytest.mark.asyncio
async def test_list_conversations_returns_200():
    """Test listing conversations via API."""
    async with AsyncClient(transport=ASGITransport(app=app), base_url="http://test") as client:
        # Act
        response = await client.get("/api/v1/conversations")

        # Assert
        assert response.status_code == 200
        data = response.json()
        assert "conversations" in data
        assert "total" in data
```

#### 4.1.2 Implement Endpoints (GREEN)

**File:** `src/server/app/api/v1/conversations.py`

```python
"""
Conversation API endpoints for HU-4.2.

Endpoints:
- POST /api/v1/conversations (create)
- GET /api/v1/conversations/{id} (retrieve)
- GET /api/v1/conversations (list)
"""

from fastapi import APIRouter, Depends, HTTPException, status
from uuid import UUID
from typing import Optional
from sqlalchemy.ext.asyncio import AsyncSession

from src.server.app.domain.schemas.conversation import (
    ConversationCreate,
    ConversationResponse,
    ConversationList
)
from src.server.app.services.conversation.conversation_service import ConversationService
from src.server.app.infrastructure.persistence.repositories.sqlalchemy_conversation_repository import (
    SQLAlchemyConversationRepository
)
from src.server.app.infrastructure.persistence.database import get_db_session

router = APIRouter(prefix="/api/v1/conversations", tags=["Conversations"])


def get_conversation_service(db: AsyncSession = Depends(get_db_session)) -> ConversationService:
    """Dependency injection for conversation service."""
    repository = SQLAlchemyConversationRepository(db)
    return ConversationService(repository)


@router.post("/", response_model=ConversationResponse, status_code=status.HTTP_201_CREATED)
async def create_conversation(
    payload: ConversationCreate,
    service: ConversationService = Depends(get_conversation_service)
):
    """Create new conversation."""
    conversation = await service.create_conversation(
        project_id=payload.project_id,
        title=payload.title
    )
    return conversation


@router.get("/{conversation_id}", response_model=ConversationResponse)
async def get_conversation(
    conversation_id: UUID,
    service: ConversationService = Depends(get_conversation_service)
):
    """Get conversation by ID."""
    conversation = await service.get_conversation(conversation_id)

    if conversation is None:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Conversation {conversation_id} not found"
        )

    return conversation


@router.get("/", response_model=ConversationList)
async def list_conversations(
    project_id: Optional[UUID] = None,
    skip: int = 0,
    limit: int = 100,
    service: ConversationService = Depends(get_conversation_service)
):
    """List conversations with pagination."""
    conversations = await service.list_conversations(
        project_id=project_id,
        skip=skip,
        limit=limit
    )

    return ConversationList(
        conversations=conversations,
        total=len(conversations),
        skip=skip,
        limit=limit
    )
```

**Update:** `src/server/app/main.py` (add router)

```python
from src.server.app.api.v1 import conversations

app.include_router(conversations.router)
```

---

### 📝 Phase 4 Validation

```bash
# 1. Run integration tests
pytest tests/server/integration/api/v1/test_conversation_endpoints.py -v

# 2. Type check
python -m pyright src/server/app/api/

# 3. Format code
black src/server/app/api/
```

✅ **Phase 4 Complete** when:
- All integration tests pass
- Coverage >85%
- 0 Pyright errors

---

## Phase 5: Quality & Security Hardening

**Duration:** 2 hours
**Objective:** Verify coverage, audit security, create documentation

---

### ✅ Checklist

#### 5.1 Test Coverage Verification

```bash
# Run full test suite with coverage
pytest tests/server/ \
  --cov=src/server/app \
  --cov-report=term-missing \
  --cov-report=html \
  --cov-fail-under=85

# Generate coverage report
./scripts/testing/generate_coverage_html.sh
```

**Target:** ≥85% overall, ≥95% domain layer

---

#### 5.2 Security Audit

```bash
# Run Bandit security scanner
bandit -r src/server/app/ -ll -q

# Verify 0 high-severity issues (focus on SQL injection)
# Expected: No issues (all queries use ORM)
```

---

#### 5.3 Create Documentation

Create these files:

1. **COVERAGE_REPORT.md** - Test coverage analysis
2. **SECURITY_AUDIT.md** - Bandit results + SQL injection validation
3. **API_CONTRACT.md** - OpenAPI spec for conversation endpoints
4. **ARCHITECTURE_DIAGRAM.md** - System architecture with Mermaid diagrams

---

#### 5.4 Code Quality Gates

```bash
# Format code
black src/server/app/

# Lint code
ruff check src/server/app/

# Type check
python -m pyright src/server/app/
```

---

### 📝 Phase 5 Validation

✅ **Phase 5 Complete** when:
- Coverage ≥85%
- Bandit: 0 high-severity issues
- All documentation created
- Black formatted
- Ruff clean
- 0 Pyright errors

---

## Phase 6: Validation & PR

**Duration:** 1 hour
**Objective:** Final validation and Pull Request submission

---

### ✅ Checklist

#### 6.1 Run PRE_PUSH Validation

```bash
# MANDATORY: Run validation script before push
./scripts/testing/PRE_PUSH_VALIDATION_MASTER.sh
```

**Expected:** All phases pass (formatting, linting, type checking, tests, security)

---

#### 6.2 Commit & Push

```bash
# Stage all changes
git add -A

# Commit (descriptive message)
git commit -m "feat(backend): implement conversation persistence (HU-4.2)

- Add SQLAlchemy models for conversations and messages
- Implement SQLAlchemyConversationRepository adapter
- Add ConversationService with context window logic (last 10 messages)
- Implement FastAPI endpoints (POST, GET, LIST)
- Add comprehensive tests (unit + integration) with >85% coverage
- Security: ORM-only queries (SQL injection prevention)
- Documentation: COVERAGE_REPORT, SECURITY_AUDIT, API_CONTRACT"

# Push to remote
git push origin feature/backend-conversation-history
```

---

#### 6.3 Create Pull Request

**PR Title:** `feat(backend): HU-4.2 - Conversation History & Persistence`

**PR Description Template:**

```markdown
## 📝 Summary

Implements conversation persistence using SQLite with SQLAlchemy ORM for HU-4.2.

## ✨ Features

- **SQLite persistence** with async support (aiosqlite)
- **Clean Architecture** (Domain → Infrastructure → Service → API)
- **Context window management** (last 10 messages for LLM prompt)
- **REST endpoints:**
  - POST /api/v1/conversations (create)
  - GET /api/v1/conversations/{id} (retrieve)
  - GET /api/v1/conversations (list with pagination)

## ✅ Test Results

- **Total tests:** X tests pass
- **Coverage:** X% (≥85% target)
- **Domain layer:** X% (≥95% target)

## 🔒 Security

- **SQL Injection Prevention:** ORM-only queries (0 raw SQL)
- **Bandit:** 0 high-severity issues
- **Foreign key constraints:** Enforced by database
- **Input validation:** Pydantic schemas

## 📚 Documentation

- [README.md](doc/03-HU-TRACKING/HU-4.2-CONVERSATION-HISTORY/README.md)
- [WORKFLOW_MASTER_DEFINITION.md](doc/03-HU-TRACKING/HU-4.2-CONVERSATION-HISTORY/WORKFLOW_MASTER_DEFINITION.md)
- [COVERAGE_REPORT.md](doc/03-HU-TRACKING/HU-4.2-CONVERSATION-HISTORY/COVERAGE_REPORT.md)
- [SECURITY_AUDIT.md](doc/03-HU-TRACKING/HU-4.2-CONVERSATION-HISTORY/SECURITY_AUDIT.md)
- [API_CONTRACT.md](doc/03-HU-TRACKING/HU-4.2-CONVERSATION-HISTORY/API_CONTRACT.md)

## ✅ Verification Criteria

- [x] Schema SQLite creado correctamente (conversations, messages tables)
- [x] GET /conversations/{id} recupera el historial completo
- [x] El LLM recibe los últimos 10 mensajes para mantener contexto
- [x] Tests de persistencia pasando (>85% coverage)
- [x] Security audit clean (0 high-severity issues)

## 🔗 Related

- Closes #X (issue number)
- Depends on: HU-4.1 (chat endpoint)
- Next: HU-4.3 (streaming responses)
```

---

### 📝 Phase 6 Validation

✅ **Phase 6 Complete** when:
- PRE_PUSH validation passes
- Changes committed and pushed
- Pull Request created with complete description

---

## Emergency Procedures

### 🚨 If Tests Fail

1. **Identify failing test:**
   ```bash
   pytest tests/server/ -v --tb=short
   ```

2. **Debug specific test:**
   ```bash
   pytest tests/server/path/to/test_file.py::test_function_name -vv --pdb
   ```

3. **Check logs:**
   ```bash
   tail -f logs/app.log
   ```

---

### 🚨 If Coverage Below 85%

1. **Identify untested code:**
   ```bash
   pytest --cov=src/server/app --cov-report=term-missing
   ```

2. **Write missing tests** (focus on uncovered lines)

3. **Re-run coverage:**
   ```bash
   pytest --cov --cov-fail-under=85
   ```

---

### 🚨 If Type Errors

1. **Run Pyright:**
   ```bash
   python -m pyright src/server/app/
   ```

2. **Fix errors** (add type annotations)

3. **Re-validate:**
   ```bash
   python -m pyright src/server/app/
   ```

---

## Success Criteria Matrix

### Overall Success Criteria

| Criterion | Target | Validation | Status |
|-----------|--------|-----------|--------|
| **Functional Tests** | All pass | `pytest tests/server/ -v` | ⏳ |
| **Coverage** | ≥85% overall | `pytest --cov-fail-under=85` | ⏳ |
| **Domain Coverage** | ≥95% | Coverage report | ⏳ |
| **Type Safety** | 0 errors | `pyright src/server/app/` | ⏳ |
| **Security** | 0 high-severity | `bandit -r src/server/app/` | ⏳ |
| **Code Quality** | Clean | `black --check` + `ruff check` | ⏳ |
| **Documentation** | Complete | All 9 docs exist | ⏳ |
| **PRE_PUSH** | Pass | `PRE_PUSH_VALIDATION_MASTER.sh` | ⏳ |

---

### Phase-Specific Success Criteria

| Phase | Criterion | Status |
|-------|-----------|--------|
| **Phase 0** | Documentation structure created | ✅ |
| **Phase 1** | Domain entities + repository protocol | ⏳ |
| **Phase 2** | SQLAlchemy models + adapter | ⏳ |
| **Phase 3** | Service layer + context window | ⏳ |
| **Phase 4** | FastAPI endpoints + integration tests | ⏳ |
| **Phase 5** | Coverage >85% + security audit | ⏳ |
| **Phase 6** | PRE_PUSH pass + PR created | ⏳ |

---

## 🎉 Completion Checklist

Before marking HU-4.2 as COMPLETE:

- [ ] All 6 phases completed
- [ ] 100% of verification criteria met
- [ ] Documentation complete (9 files)
- [ ] PRE_PUSH validation passed
- [ ] Pull Request created and reviewed
- [ ] No outstanding bugs or blockers

---

**END OF WORKFLOW MASTER DEFINITION**
