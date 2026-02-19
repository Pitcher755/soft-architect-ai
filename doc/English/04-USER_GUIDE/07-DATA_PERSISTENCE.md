# 💾 Data Persistence - SoftArchitect AI

> **Date:** 02/19/2026
> **Status:** ✅ Data storage guide
> **Reading time:** 10 minutes

---

## 📖 Table of Contents

- [Where Your Data is Stored](#where-your-data-is-stored)
- [File Structure](#file-structure)
- [Backup and Restore](#backup-and-restore)
- [Privacy and Security](#privacy-and-security)
- [Data Migration](#data-migration)

---

## 📁 Where Your Data is Stored

**Fundamental principle:** Everything is saved **locally on your computer**. Never sent to the cloud (except if you use Groq Cloud for inference, but only question context, NOT your data).

### Location Map

```
soft-architect-ai/
├── data/                          ← YOUR MAIN DATA
│   ├── projects/                  ← Created projects
│   │   ├── academic-blog/
│   │   │   ├── 00-governance/
│   │   │   ├── 01-architecture/
│   │   │   ├── 02-implementation/
│   │   │   └── 03-tracking/
│   │   └── ecommerce-mvp/
│   │
│   ├── chat_history/              ← Conversation history
│   │   ├── 2026-02-19.json
│   │   └── 2026-02-20.json
│   │
│   └── user_config/               ← Custom configuration
│       ├── preferences.json
│       └── tech_packs_custom.json
│
├── infrastructure/
│   └── chroma_data/               ← Vector database (RAG)
│       ├── chroma.sqlite3
│       └── embeddings/
│
└── .env                           ← Secrets (API keys, etc.)
```

---

## 🏗️ File Structure

### 1. Projects (`data/projects/`)

Each project has this structure:

```
data/projects/<project-name>/
├── metadata.json                  ← Project information
├── 00-governance/
│   ├── PROBLEM_STATEMENT.md       ← Problem definition
│   ├── STAKEHOLDERS.md            ← Stakeholders and requirements
│   └── FUNCTIONAL_REQUIREMENTS.md ← Functional requirements
│
├── 01-architecture/
│   ├── ADR-001-DATABASE.md        ← Architecture decisions
│   ├── C4_CONTEXT_DIAGRAM.md      ← C4 diagrams
│   ├── TECH_STACK.md              ← Chosen tech stack
│   └── SYSTEM_DESIGN.md           ← System design
│
├── 02-implementation/
│   ├── USER_STORIES.md            ← User stories
│   ├── BACKLOG.md                 ← Prioritized backlog
│   └── TASKS.json                 ← Technical tasks
│
└── 03-tracking/
    ├── SPRINT_1.md                ← Executed sprints
    ├── METRICS.json               ← Progress metrics
    └── RETROSPECTIVES.md          ← Retrospectives
```

#### Example: `metadata.json`

```json
{
  "id": "academic-blog-2026-02-19",
  "name": "Academic Blog Platform",
  "created_at": "2026-02-19T10:30:00Z",
  "updated_at": "2026-02-20T15:45:00Z",
  "status": "active",
  "tech_stack": ["Python", "FastAPI", "PostgreSQL", "Flutter"],
  "team_size": 3,
  "target_launch_date": "2026-05-01"
}
```

---

### 2. Chat History (`data/chat_history/`)

Conversations are saved as JSON by date.

#### Example: `2026-02-19.json`

```json
{
  "session_id": "sess_1234567890",
  "project_id": "academic-blog-2026-02-19",
  "date": "2026-02-19",
  "messages": [
    {
      "id": 1,
      "role": "user",
      "content": "I need to design a blog app for universities",
      "timestamp": "2026-02-19T10:30:15Z"
    },
    {
      "id": 2,
      "role": "assistant",
      "content": "Perfect, let's start by defining stakeholders...",
      "timestamp": "2026-02-19T10:30:20Z",
      "sources": [
        "packages/knowledge_base/01-TEMPLATES/PROBLEM_STATEMENT.md"
      ]
    }
  ],
  "total_messages": 42,
  "tokens_used": 8521
}
```

---

### 3. User Configuration (`data/user_config/`)

#### `preferences.json`

```json
{
  "theme": "dark",
  "language": "en",
  "streaming_enabled": true,
  "default_tech_stack": ["Python", "PostgreSQL"],
  "notifications": {
    "email": false,
    "desktop": true
  }
}
```

#### `tech_packs_custom.json`

```json
{
  "custom_packs": [
    {
      "name": "My Custom Stack",
      "path": "/home/user/custom_packs/my_stack.md",
      "enabled": true
    }
  ]
}
```

---

### 4. Vector Database (`infrastructure/chroma_data/`)

**Technology:** ChromaDB (SQLite + vector embeddings)

**What it contains:**
- Knowledge Base embeddings (Tech Packs, Templates)
- Semantic search index

**Typical size:** 500MB - 2GB (depends on installed Tech Packs)

**Backup:** Copy entire `chroma_data/` folder

---

## 💾 Backup and Restore

### Option A: Manual Backup (Recommended)

```bash
# 1. Create backup folder
mkdir -p ~/backups/soft-architect-ai/$(date +%Y%m%d)

# 2. Copy data
cp -r ./data ~/backups/soft-architect-ai/$(date +%Y%m%d)/
cp -r ./infrastructure/chroma_data ~/backups/soft-architect-ai/$(date +%Y%m%d)/
cp .env ~/backups/soft-architect-ai/$(date +%Y%m%d)/

# 3. Compress (optional)
tar -czvf ~/backups/soft-architect-ai_$(date +%Y%m%d).tar.gz \
  -C ~/backups/soft-architect-ai/ $(date +%Y%m%d)
```

---

### Option B: Automated Backup (Script)

**Create script:** `scripts/backup.sh`

```bash
#!/bin/bash

BACKUP_DIR="$HOME/backups/soft-architect-ai"
DATE=$(date +%Y%m%d_%H%M%S)
SOURCE_DIR="$(pwd)"

# Create backup directory
mkdir -p "$BACKUP_DIR"

# Backup
tar -czvf "$BACKUP_DIR/backup_$DATE.tar.gz" \
  --exclude='./node_modules' \
  --exclude='./venv' \
  --exclude='./build' \
  ./data \
  ./infrastructure/chroma_data \
  ./.env

echo "✅ Backup complete: $BACKUP_DIR/backup_$DATE.tar.gz"
```

**Execute:**
```bash
chmod +x scripts/backup.sh
./scripts/backup.sh
```

---

### Restore from Backup

```bash
# 1. Stop application
docker-compose down  # If using Docker

# 2. Extract backup
tar -xzvf ~/backups/soft-architect-ai_20260219.tar.gz -C ./

# 3. Verify permissions
chmod -R 755 ./data
chmod -R 755 ./infrastructure/chroma_data

# 4. Restart application
docker-compose up -d
```

---

## 🔒 Privacy and Security

### Privacy Guarantees

✅ **Data Sovereignty:** All your data is on your machine, under your physical control.
✅ **Zero Telemetry:** No analytics, no tracking, no "phone home".
✅ **GDPR Compliant:** Complies with European data protection legislation.
✅ **Offline-First:** Works without internet connection (if using Ollama Local).

---

### Sensitive Data

**❌ NEVER commit these files:**
```
.env                    ← API keys, secrets
data/                   ← Your private projects
infrastructure/chroma_data/ ← Database
```

**Verify `.gitignore`:**
```gitignore
# .gitignore
.env
.env.local
data/
infrastructure/chroma_data/
*.log
*.sqlite3
```

---

### Encryption (Optional)

**For ultra-confidential projects:**

```bash
# Encrypt data folder with GPG
tar -czf - ./data | gpg --symmetric --cipher-algo AES256 > data_encrypted.tar.gz.gpg

# Decrypt
gpg --decrypt data_encrypted.tar.gz.gpg | tar -xzf -
```

---

### File Permissions

**Linux/Mac:**
```bash
# Only your user can read/write
chmod 700 data/
chmod 700 infrastructure/chroma_data/
chmod 600 .env
```

**Windows:**
```powershell
# Configure NTFS permissions
icacls "data" /inheritance:r /grant:r "%USERNAME%:(OI)(CI)F"
```

---

## 🔄 Data Migration

### Migrate Between Versions

**Scenario:** Updated from v0.1.0 to v0.2.0 and data structure changed.

**Process:**

1. **Backup old data** (see previous section)

2. **Run migration script:**
   ```bash
   python scripts/migrate_data.py --from 0.1.0 --to 0.2.0
   ```

3. **Verify integrity:**
   ```bash
   python scripts/verify_data_integrity.py
   ```

---

### Export to Other Formats

#### To Notion

**Use Notion API:**
```bash
python scripts/export_to_notion.py \
  --project "academic-blog" \
  --notion-api-key "secret_xxxxx" \
  --notion-database-id "xxxxx"
```

#### To Confluence

**Use Confluence REST API:**
```bash
python scripts/export_to_confluence.py \
  --project "academic-blog" \
  --confluence-url "https://company.atlassian.net" \
  --token "xxxxx"
```

#### To PDF

**Export complete documentation:**
```bash
# Requires Pandoc
pandoc data/projects/academic-blog/**/*.md \
  -o academic-blog-docs.pdf \
  --toc \
  --pdf-engine=xelatex
```

---

## 📊 Disk Space Management

### Check Usage

```bash
# Total size
du -sh data/
du -sh infrastructure/chroma_data/

# By project
du -sh data/projects/*/
```

### Clean Old Data

```bash
# Delete chat history > 30 days
find data/chat_history/ -type f -mtime +30 -delete

# Delete archived projects
rm -rf data/projects/archived_*/

# Reindex ChromaDB (free space)
python scripts/reindex_chroma.py --optimize
```

---

## 🛠️ Troubleshooting

### ❌ "Can't save files (Permission denied)"

**Solution:**
```bash
# Linux/Mac
sudo chown -R $USER:$USER data/
chmod -R 755 data/

# Windows: Run as Administrator
icacls "data" /reset /t
```

---

### ❌ "My projects disappeared"

**Common cause:** `data/` folder moved or accidentally deleted

**Solution:**
1. Check backup (see Backup section)
2. Restore from most recent backup
3. If no backup, data is lost 😢

**Prevention:**
- Daily automatic backup
- Use Docker volumes (guaranteed persistence)

---

## 📚 Related Documents

- [Installation](02-INSTALLATION.md) - Initial setup
- [Troubleshooting](08-TROUBLESHOOTING.md) - Common errors
- [Security](../../context/SECURITY_HARDENING_POLICY.en.md) - Security policies

---

<p align="center">
  <a href="08-TROUBLESHOOTING.md">Troubleshooting →</a> |
  <a href="06-STREAMING_RESPONSES.md">← Streaming</a>
</p>
