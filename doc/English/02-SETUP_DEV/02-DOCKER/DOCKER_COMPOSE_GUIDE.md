# 🐋 Docker Compose Guide — SoftArchitect AI

> **Last Updated:** March 22, 2026
> **Status:** ✅ Production Ready
> **Tested on:** Linux (Ubuntu 22.04), Windows (WSL2), macOS (M1/Intel)

---

## 📋 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Centralized .env (Project Root)](#centralized-env-project-root)
3. [Essential Commands](#essential-commands)
4. [Execution Modes](#execution-modes)
5. [Service Verification](#service-verification)
6. [Logs and Monitoring](#logs-and-monitoring)
7. [Builds and Rebuilding](#builds-and-rebuilding)
8. [Troubleshooting](#troubleshooting)
9. [Service Architecture](#service-architecture)

---

## ✅ Prerequisites

### Minimum Hardware

```yaml
CPU: 2 cores (4 recommended)
RAM: 8 GB (4 GB Ollama + 2 GB ChromaDB + 2 GB System)
Disk: 20 GB free
GPU: Optional (NVIDIA CUDA 11.8+ to accelerate Ollama)
```

### Required Software

```bash
docker --version        # >= 24.0.0
docker compose version  # >= 2.20.0
```

**Installation:**

- **Linux:** `curl -fsSL https://get.docker.com | sh`
- **macOS/Windows:** [Docker Desktop](https://www.docker.com/products/docker-desktop/)

---

## 📁 Centralized .env (Project Root)

> ⚠️ **The `.env` file lives at the repository root**, NOT inside `infrastructure/`.
> The `docker-compose.yml` reads variables via `env_file: ../.env` (one level up).

### File structure

```
soft-architect-ai/          ← REPOSITORY ROOT
├── .env                    ← ✅ Master configuration file (here)
├── .env.example            ← ✅ Public template (no real secrets)
└── infrastructure/
    ├── docker-compose.yml  ← Reads env_file: ../.env automatically
    └── ...
```

### Create your .env from the template

```bash
# From the repository root
cp .env.example .env

# Edit if you need to adjust values
# Defaults work fine for local development
nano .env
```

### Key variables in .env

```bash
# LLM provider: ollama | groq | gemini
LLM_PROVIDER=ollama
OLLAMA_MODEL=qwen2.5-coder:3b

# ChromaDB
CHROMADB_HOST=sa_chromadb
CHROMADB_PORT=8000

# FastAPI
DEBUG=True
LOG_LEVEL=DEBUG

# API Keys (only needed for cloud providers)
GROQ_API_KEY=
GEMINI_API_KEY=
```

---

## ⚡ Essential Commands

> All commands run from the **repository root** (`soft-architect-ai/`).
> The `--env-file .env` flag is required when invoking from the root.

### Start the stack (detached)

```bash
docker compose --env-file .env -f infrastructure/docker-compose.yml up -d
```

### Stop the stack

```bash
docker compose --env-file .env -f infrastructure/docker-compose.yml down
```

### View service status

```bash
docker compose --env-file .env -f infrastructure/docker-compose.yml ps
```

### Use the automation script (recommended)

```bash
# Script performs pre-checks, validates .env, pulls images, starts stack
./scripts/devops/start_stack.sh

# To stop
./scripts/devops/stop_stack.sh
```

---

## 🎛️ Execution Modes

### Mode 1: Development (live logs)

```bash
docker compose --env-file .env -f infrastructure/docker-compose.yml up
```

- ✅ Live logs in your current terminal
- ✅ `Ctrl+C` cleanly stops all services

### Mode 2: Background (detached)

```bash
docker compose --env-file .env -f infrastructure/docker-compose.yml up -d
```

- ✅ Frees your terminal
- ✅ Services persist after terminal is closed

### Mode 3: Rebuild images

```bash
# Build and start with freshly rebuilt images
docker compose --env-file .env -f infrastructure/docker-compose.yml up --build -d
```

### Mode 4: Build without cache (clean rebuild)

```bash
# Step 1: Build without using Docker layer cache
docker compose --env-file .env -f infrastructure/docker-compose.yml build --no-cache

# Step 2: Start services
docker compose --env-file .env -f infrastructure/docker-compose.yml up -d
```

> 💡 Use this when you update `requirements.txt`, the `Dockerfile`, or OS-level dependencies inside the container.

### Mode 5: Full teardown and rebuild from scratch

```bash
# ⚠️ The -v flag also removes volumes (erases ChromaDB data)
docker compose --env-file .env -f infrastructure/docker-compose.yml down -v
docker compose --env-file .env -f infrastructure/docker-compose.yml build --no-cache
docker compose --env-file .env -f infrastructure/docker-compose.yml up -d
```

### Mode 6: Rebuild only the API (avoid reloading Ollama)

```bash
docker compose --env-file .env -f infrastructure/docker-compose.yml build --no-cache api-server
docker compose --env-file .env -f infrastructure/docker-compose.yml up -d api-server
```

---

## 🔍 Service Verification

### Container status

```bash
docker compose --env-file .env -f infrastructure/docker-compose.yml ps
```

**Expected output (all services `Up (healthy)`):**

```
NAME           IMAGE                    STATUS
sa_api         sa_api:latest            Up (healthy)
sa_chromadb    chromadb/chroma:latest   Up (healthy)
sa_ollama      ollama/ollama:latest     Up (healthy)
```

### Backend health check

```bash
curl http://localhost:8000/api/v1/health
```

**Expected response:**

```json
{"status":"OK","message":"SoftArchitect AI backend is running","version":"0.1.0"}
```

### Swagger UI (interactive API explorer)

```
http://localhost:8000/docs
```

### Verify environment variables inside the container

```bash
# Check LLM-related variables
docker exec sa_api env | grep -i llm

# Check ChromaDB variables
docker exec sa_api env | grep -i chroma

# Check debug mode
docker exec sa_api env | grep -i debug
```

### Open a shell inside a container

```bash
# Interactive shell in the API container
docker exec -it sa_api bash

# Shell in ChromaDB
docker exec -it sa_chromadb bash
```

---

## 📋 Logs and Monitoring

### Live logs (all services)

```bash
docker compose --env-file .env -f infrastructure/docker-compose.yml logs -f
```

### Logs for the backend only (sa_api)

```bash
docker logs -f sa_api
```

### Backend logs with timestamps

```bash
docker logs -f --timestamps sa_api
```

### ChromaDB logs

```bash
docker logs -f sa_chromadb
```

### Ollama logs

```bash
docker logs -f sa_ollama
```

### View last N lines

```bash
docker logs --tail 100 sa_api
docker logs --tail 50  sa_chromadb
docker logs --tail 50  sa_ollama
```

### Filter logs by level or pattern

```bash
# Errors only
docker logs -f sa_api 2>&1 | grep -i "error\|exception\|critical"

# HTTP requests only
docker logs -f sa_api 2>&1 | grep -i "POST\|GET\|DELETE\|PUT"

# Startup messages only
docker logs sa_api 2>&1 | grep -i "started\|running\|uvicorn"
```

### Real-time resource monitoring (CPU/RAM/Network)

```bash
# All project containers
docker stats sa_api sa_chromadb sa_ollama

# Snapshot only (no live refreshing)
docker stats --no-stream sa_api sa_chromadb sa_ollama
```

---

## 🏗️ Builds and Rebuilding

### List project images

```bash
docker images | grep sa_
```

### Validate Docker Compose configuration (dry run)

```bash
docker compose --env-file .env -f infrastructure/docker-compose.yml config
```

### Remove API image to force a full rebuild

```bash
docker rmi sa_api
docker compose --env-file .env -f infrastructure/docker-compose.yml up --build -d
```

### Restart a service without stopping the whole stack

```bash
# Restart API only
docker compose --env-file .env -f infrastructure/docker-compose.yml restart api-server

# Restart ChromaDB only
docker compose --env-file .env -f infrastructure/docker-compose.yml restart chromadb
```

### Clean up unused Docker resources

```bash
# Stopped containers, orphan images, unused networks
docker system prune -f

# ⚠️ Also removes volumes (erases ChromaDB data)
docker system prune -f --volumes
```

### View Docker disk usage

```bash
docker system df
```

---

## 🔧 Troubleshooting

### ❌ "env file .env not found"

```bash
# Cause: running docker compose from inside infrastructure/ without --env-file
# ✅ Fix A: always run from repo root with --env-file .env
docker compose --env-file .env -f infrastructure/docker-compose.yml up -d

# ✅ Fix B: run from infrastructure/ with relative path
cd infrastructure
docker compose --env-file ../.env up -d
```

### ❌ "Cannot connect to Docker daemon"

```bash
sudo systemctl start docker    # Linux (systemd)
sudo service docker start      # Linux (init.d)
# macOS/Windows: open Docker Desktop
docker ps                      # verify it responds
```

### ❌ "Port 8000 already in use"

```bash
# Find which process is using port 8000
lsof -i :8000

# Kill that process
kill -9 <PID>

# Alternative: change port in .env
# API_PORT=8001
```

### ❌ "Ollama out of memory"

```bash
# Option 1: use a lighter model in .env
OLLAMA_MODEL=qwen2.5-coder:1.5b

# Option 2: check available RAM
docker stats --no-stream
free -h
```

### ❌ "ChromaDB connection refused" from API

```bash
# Check ChromaDB status and logs
docker logs sa_chromadb

# Restart only ChromaDB
docker compose --env-file .env -f infrastructure/docker-compose.yml restart chromadb

# Check which host the API sees in its environment
docker exec sa_api env | grep CHROMA
```

### ❌ API won't start (ModuleNotFoundError / ImportError)

```bash
# Force rebuild without cache (fixes dependency issues)
docker compose --env-file .env -f infrastructure/docker-compose.yml build --no-cache api-server
docker compose --env-file .env -f infrastructure/docker-compose.yml up -d api-server

# Verify the code is mounted inside the container
docker exec sa_api ls -la /app/app/main.py
docker exec sa_api pip list | grep fastapi
```

---

## 🏛️ Service Architecture

```
soft-architect-ai/              ← Project root
├── .env                        ← Master variables (here)
└── infrastructure/
    └── docker-compose.yml      ← Orchestration (reads ../.env via env_file)

Internal Docker network: sa_network
┌────────────────────────────────────────────────────┐
│  sa_api       (FastAPI)     localhost:8000          │
│  sa_chromadb  (ChromaDB)    localhost:8001          │
│  sa_ollama    (Ollama LLM)  localhost:11434         │
└────────────────────────────────────────────────────┘

Typical data flow:
  Flutter App → sa_api:8000 → sa_chromadb:8000 (internal)
                            → sa_ollama:11434  (internal)
```

| Service | Image | Ext. Port | Int. Port | Description |
|---------|-------|-----------|-----------|-------------|
| `sa_api` | `sa_api:latest` (local build) | `8000` | `8000` | FastAPI backend |
| `sa_chromadb` | `chromadb/chroma:latest` | `8001` | `8000` | Vector database |
| `sa_ollama` | `ollama/ollama:latest` | `11434` | `11434` | Local LLM engine |

---

## 🔗 References

- [Quick Start](../01-INSTALLATION/QUICK_START_GUIDE.md) — Full setup in 15 minutes
- [Automation Scripts](../04-AUTOMATION/AUTOMATION.md) — `start_stack.sh`, `stop_stack.sh`
- [CI/CD Pipeline](../05-CI-CD/) — Automated validation in GitHub Actions
- [infrastructure/docker-compose.yml](../../../../infrastructure/docker-compose.yml) — Source orchestration file
- [.env.example](../../../../.env.example) — Public template for environment variables
