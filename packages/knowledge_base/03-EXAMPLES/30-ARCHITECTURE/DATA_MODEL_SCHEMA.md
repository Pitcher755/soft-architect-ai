# 🗂️ Data Model Schema: SoftArchitect AI

> **Versión:** 1.0
> **Fecha:** 30/01/2026
> **Estado:** ✅ Definido
> **DB Engine:** SQLite + ChromaDB (vectors)
> **Migration Tool:** Alembic

---

## 📖 Tabla de Contenidos

1. [Database Architecture](#database-architecture)
2. [Tables & Schemas](#tables--schemas)
3. [Relationships](#relationships)
4. [Indexes & Performance](#indexes--performance)
5. [Migration Strategy](#migration-strategy)

---

## Database Architecture

### Multi-Store Pattern

```
┌─────────────────────────────────────────────────┐
│       SoftArchitect Data Layer                  │
├─────────────────────────────────────────────────┤
│                                                 │
│  SQLite (Relational)  ←→  ChromaDB (Vector)   │
│  ├─ Queries           └─  Embeddings          │
│  ├─ Users             └─  Semantic search     │
│  ├─ Decisions         └─  RAG indexing        │
│  ├─ CodeExamples      └─  Similarity matching │
│  ├─ Config                                     │
│  └─ Audit logs                                 │
│                                                 │
└─────────────────────────────────────────────────┘
```

### Storage Locations

```
$HOME/.softarchitect/
├── data/
│   ├── app.db                 (SQLite, ~50MB typical)
│   ├── chroma/                (Vector store)
│   │   ├── chroma.db         (index metadata)
│   │   └── data/             (embeddings)
│   └── exports/              (user backups)
└── config/
    └── settings.json
```

---

## Tables & Schemas

### 1. Users Table

**Purpose:** User profiles and authentication metadata

```sql
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_uuid(),
  email VARCHAR(255) UNIQUE,
  username VARCHAR(128) UNIQUE NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_login TIMESTAMP,
  preferences JSON,
  status ENUM('active', 'inactive', 'suspended'),
  INDEX idx_email (email),
  INDEX idx_created_at (created_at)
);
```

**Sample Row:**

```json
{
  "id": "user-123-abc",
  "email": "alice@architect.dev",
  "username": "alice",
  "created_at": "2026-01-15T08:00:00Z",
  "last_login": "2026-01-30T10:00:00Z",
  "preferences": {
    "language": "en",
    "theme": "dark",
    "notifications": true
  },
  "status": "active"
}
```

---

### 2. Queries Table

**Purpose:** Track user questions and responses

```sql
CREATE TABLE queries (
  id UUID PRIMARY KEY DEFAULT gen_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  query_text TEXT NOT NULL,
  response_text TEXT,
  model_used VARCHAR(128),
  temperature FLOAT DEFAULT 0.7,
  max_tokens INTEGER DEFAULT 2048,
  processing_time_ms INTEGER,
  tokens_used INTEGER,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  status ENUM('pending', 'completed', 'failed'),
  error_message TEXT,
  metadata JSON,
  INDEX idx_user_created (user_id, created_at),
  INDEX idx_status (status),
  FULLTEXT INDEX ft_query_text (query_text)
);
```

**Sample Row:**

```json
{
  "id": "query-456-def",
  "user_id": "user-123-abc",
  "query_text": "How to setup Kubernetes?",
  "response_text": "Kubernetes is a container orchestration platform...",
  "model_used": "mistral:latest",
  "temperature": 0.7,
  "max_tokens": 2048,
  "processing_time_ms": 1250,
  "tokens_used": 512,
  "created_at": "2026-01-30T10:30:00Z",
  "status": "completed",
  "metadata": {
    "source_docs": 3,
    "confidence": 0.95
  }
}
```

---

### 3. Decisions Table

**Purpose:** Store architectural decisions with context

```sql
CREATE TABLE decisions (
  id UUID PRIMARY KEY DEFAULT gen_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  options JSON NOT NULL,         -- Array of alternatives considered
  selected_option VARCHAR(255),  -- Chosen option
  rationale TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  status ENUM('draft', 'active', 'archived'),
  tags JSON,
  related_tech_packs JSON,
  metadata JSON,
  INDEX idx_user_created (user_id, created_at),
  INDEX idx_status (status),
  INDEX idx_tags (tags)
);
```

**Sample Row:**

```json
{
  "id": "decision-789-ghi",
  "user_id": "user-123-abc",
  "title": "Frontend Framework Selection",
  "description": "Choose between React, Vue, and Svelte for UI",
  "options": [
    {
      "name": "React",
      "pros": ["Large ecosystem", "Performance", "Jobs"],
      "cons": ["Learning curve", "Boilerplate"]
    },
    {
      "name": "Vue",
      "pros": ["Easy to learn", "Great docs"],
      "cons": ["Smaller ecosystem"]
    }
  ],
  "selected_option": "React",
  "rationale": "Team expertise and ecosystem support",
  "created_at": "2026-01-20T14:00:00Z",
  "status": "active",
  "tags": ["frontend", "ui", "decision"],
  "related_tech_packs": ["react-2024", "frontend-patterns"]
}
```

---

### 4. CodeExamples Table

**Purpose:** Store code snippets with metadata

```sql
CREATE TABLE code_examples (
  id UUID PRIMARY KEY DEFAULT gen_uuid(),
  user_id UUID REFERENCES users(id) ON DELETE CASCADE,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  language VARCHAR(50),          -- python, dart, typescript, etc.
  code_content TEXT NOT NULL,
  decision_id UUID REFERENCES decisions(id) ON DELETE SET NULL,
  tags JSON,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  visibility ENUM('private', 'shared', 'public'),
  metadata JSON,
  INDEX idx_language (language),
  INDEX idx_decision (decision_id),
  FULLTEXT INDEX ft_code (code_content)
);
```

**Sample Row:**

```json
{
  "id": "code-012-jkl",
  "user_id": "user-123-abc",
  "title": "Pydantic Model Example",
  "description": "Data validation with Pydantic",
  "language": "python",
  "code_content": "from pydantic import BaseModel\nclass Decision(BaseModel):\n  title: str\n  ...",
  "decision_id": "decision-789-ghi",
  "tags": ["backend", "python", "validation"],
  "created_at": "2026-01-25T09:30:00Z",
  "visibility": "private"
}
```

---

### 5. KnowledgeDocuments Table

**Purpose:** Index uploaded documents

```sql
CREATE TABLE knowledge_documents (
  id UUID PRIMARY KEY DEFAULT gen_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  filename VARCHAR(255) NOT NULL,
  file_size_bytes INTEGER,
  content_type VARCHAR(100),     -- text/markdown, text/plain, application/json
  file_hash VARCHAR(64) NOT NULL UNIQUE,  -- SHA256 dedup
  category VARCHAR(100),
  tags JSON,
  chunks_count INTEGER,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  last_accessed TIMESTAMP,
  status ENUM('indexed', 'pending', 'failed'),
  error_message TEXT,
  chroma_collection_id VARCHAR(255),  -- Link to ChromaDB
  metadata JSON,
  INDEX idx_user_category (user_id, category),
  INDEX idx_file_hash (file_hash),
  FULLTEXT INDEX ft_filename (filename)
);
```

**Sample Row:**

```json
{
  "id": "kdoc-345-mno",
  "user_id": "user-123-abc",
  "filename": "kubernetes-deployment-guide.md",
  "file_size_bytes": 45000,
  "content_type": "text/markdown",
  "file_hash": "sha256:abc123def456...",
  "category": "infrastructure",
  "tags": ["kubernetes", "deployment", "devops"],
  "chunks_count": 12,
  "created_at": "2026-01-15T10:00:00Z",
  "status": "indexed",
  "chroma_collection_id": "kdoc-345-mno-chunks",
  "metadata": {
    "source": "internal",
    "version": "1.2"
  }
}
```

---

### 6. AuditLogs Table

**Purpose:** Track all user actions for security

```sql
CREATE TABLE audit_logs (
  id UUID PRIMARY KEY DEFAULT gen_uuid(),
  user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  action VARCHAR(100) NOT NULL,  -- 'query', 'upload', 'delete', 'config_change'
  resource_type VARCHAR(100),    -- 'decision', 'query', 'document'
  resource_id UUID,
  details JSON,
  ip_address VARCHAR(45),        -- IPv4 or IPv6
  user_agent TEXT,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  status ENUM('success', 'failure'),
  INDEX idx_user_created (user_id, created_at),
  INDEX idx_action (action),
  INDEX idx_timestamp (created_at)
);
```

**Sample Row:**

```json
{
  "id": "audit-678-pqr",
  "user_id": "user-123-abc",
  "action": "query",
  "resource_type": "query",
  "resource_id": "query-456-def",
  "details": {
    "query_length": 45,
    "response_tokens": 512
  },
  "ip_address": "127.0.0.1",
  "user_agent": "Flutter/3.10.0",
  "created_at": "2026-01-30T10:30:00Z",
  "status": "success"
}
```

---

### 7. Settings Table

**Purpose:** Store user and system configuration

```sql
CREATE TABLE settings (
  id UUID PRIMARY KEY DEFAULT gen_uuid(),
  user_id UUID UNIQUE NOT NULL REFERENCES users(id) ON DELETE CASCADE,
  model_name VARCHAR(128) DEFAULT 'mistral:latest',
  temperature FLOAT DEFAULT 0.7,
  max_tokens INTEGER DEFAULT 2048,
  language VARCHAR(10) DEFAULT 'en',
  theme VARCHAR(20) DEFAULT 'dark',
  encrypt_at_rest BOOLEAN DEFAULT true,
  telemetry_enabled BOOLEAN DEFAULT false,
  cloud_sync_enabled BOOLEAN DEFAULT false,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  UNIQUE (user_id)
);
```

---

## Relationships

### Entity Relationship Diagram

```
┌──────────────┐
│   Users      │
│──────────────│
│ id (PK)      │
│ email        │
│ username     │
└────┬─────────┘
     │ 1:N
     ├─────────────────┐
     │                 │
     ▼                 ▼
┌──────────────┐  ┌──────────────────┐
│  Queries     │  │  Decisions       │
│──────────────│  │──────────────────│
│ id (PK)      │  │ id (PK)          │
│ user_id (FK) │  │ user_id (FK)     │
│ query_text   │  │ title            │
│ response     │  │ selected_option  │
└──────────────┘  └────┬─────────────┘
                       │ 1:N
                       │
                       ▼
                ┌──────────────────┐
                │  CodeExamples    │
                │──────────────────│
                │ id (PK)          │
                │ user_id (FK)     │
                │ decision_id (FK) │
                │ code_content     │
                └──────────────────┘

┌──────────────────────────────┐
│  KnowledgeDocuments          │
│──────────────────────────────│
│ id (PK)                      │
│ user_id (FK)                 │
│ chroma_collection_id         │
└──────────────────────────────┘

┌──────────────────────────────┐
│  AuditLogs                   │
│──────────────────────────────│
│ id (PK)                      │
│ user_id (FK)                 │
│ resource_id (flexible)       │
└──────────────────────────────┘
```

### Foreign Key Constraints

```
users ← queries (user_id)
users ← decisions (user_id)
users ← code_examples (user_id)
users ← knowledge_documents (user_id)
users ← audit_logs (user_id)
users ← settings (user_id)

decisions ← code_examples (decision_id)
```

---

## Indexes & Performance

### Primary Indexes

```sql
-- User lookups
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_created ON users(created_at);

-- Query lookups
CREATE INDEX idx_queries_user_created ON queries(user_id, created_at DESC);
CREATE INDEX idx_queries_status ON queries(status);

-- Decision lookups
CREATE INDEX idx_decisions_user_created ON decisions(user_id, created_at DESC);
CREATE INDEX idx_decisions_status ON decisions(status);

-- Document lookups
CREATE INDEX idx_kdocs_user_category ON knowledge_documents(user_id, category);
CREATE INDEX idx_kdocs_file_hash ON knowledge_documents(file_hash);

-- Audit trail
CREATE INDEX idx_audit_user_created ON audit_logs(user_id, created_at DESC);
CREATE INDEX idx_audit_action ON audit_logs(action, created_at DESC);
```

### Full-Text Search Indexes

```sql
-- Query search
CREATE FULLTEXT INDEX ft_queries_text ON queries(query_text, response_text);

-- Code search
CREATE FULLTEXT INDEX ft_code_content ON code_examples(code_content);

-- Document search
CREATE FULLTEXT INDEX ft_kdocs_filename ON knowledge_documents(filename);
```

### Performance Targets

```
Operation                 Target Time  Query Example
────────────────────────────────────────────────────────
User lookup               < 1ms        SELECT * FROM users WHERE id = ?
Query search (user)       < 10ms       SELECT * FROM queries WHERE user_id = ? LIMIT 20
Full-text search          < 50ms       FULLTEXT SEARCH queries(query_text) MATCH ?
Vector search (ChromaDB)  < 100ms      similarity_search(query_embedding, top_k=5)
Aggregate (user stats)    < 100ms      SELECT COUNT(*), AVG(processing_time) FROM queries
```

---

## Migration Strategy

### Versioning

```
Version   Date         Description
─────────────────────────────────────────────
1.0       2026-01-30   Initial schema
2.0       TBD          Add team support
3.0       TBD          Add collaboration
```

### Migration Tool: Alembic

```bash
# Initialize migrations
alembic init migrations

# Create migration
alembic revision -m "Add queries table"

# Apply migration
alembic upgrade head

# Rollback
alembic downgrade -1
```

### Sample Migration File

```python
# alembic/versions/001_initial_schema.py

from alembic import op
import sqlalchemy as sa

def upgrade():
    op.create_table(
        'users',
        sa.Column('id', sa.String(36), primary_key=True),
        sa.Column('email', sa.String(255), unique=True),
        sa.Column('username', sa.String(128), nullable=False),
        # ... more columns
    )
    op.create_index('idx_users_email', 'users', ['email'])

def downgrade():
    op.drop_table('users')
```

### Backup Strategy

```bash
# Local backup
sqlite3 ~/.softarchitect/data/app.db ".backup app-backup-$(date +%Y%m%d).db"

# ChromaDB backup
cp -r ~/.softarchitect/data/chroma ~/.softarchitect/backups/chroma-$(date +%Y%m%d)

# User export (before account deletion)
python scripts/export_user_data.py --user-id <user-id> --output backup.json
```

---

**Data Model Schema** define la persistencia y recuperabilidad de todas las decisiones del usuario. Es el "corazón" del almacenamiento. 💾
