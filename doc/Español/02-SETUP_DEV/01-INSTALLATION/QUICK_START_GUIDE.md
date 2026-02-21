# 🚀 Quick Start Guide - SoftArchitect AI Functional

> **Estado:** ✅ **READY FOR DEVELOPMENT**
> **Fecha:** January 28, 2026
> **Resultado:** 18/18 pruebas passed (100%)

---

## 📖 Tabla de Contenidos

1. [Start the Proyecto](#start-the-proyecto)
2. [Verify Services](#verify-services)
3. [Access URLs](#access-urls)
4. [Troubleshooting](#troubleshooting)
5. [Available Reports](#available-reports)

---

## 🚀 Start the Proyecto

### Option 1: Full Build (Recommended for first time)

```bash
cd infrastructure
docker compose up --build
```

**Wait:** ~30-45 seconds until all services are ready

### Option 2: Start Existing Services

```bash
cd infrastructure
docker compose up
```

### Option 3: Start in Background Mode

```bash
cd infrastructure
docker compose up -d
```

---

## ✅ Verify Services

### General Estado

```bash
docker ps --filter "name=sa_"
```

**Expected output:**
```
NAMES         STATUS                  PORTS
sa_api        ✅ HEALTHY             0.0.0.0:8000->8000/tcp
sa_ollama     ✅ STARTING            11434/tcp
sa_chromadb   ✅ STARTING            8000/tcp
```

### View Logs

```bash
# Real-time logs
docker compose logs -f

# API only
docker compose logs -f api-server

# Ollama only
docker compose logs -f ollama

# ChromaDB only
docker compose logs -f chromadb
```

### Service Health Check

```bash
# API Health
curl http://localhost:8000/api/v1/health | jq .

# Expected:
# {
#   "status": "OK",
#   "message": "SoftArchitect AI backend is running",
#   "version": "0.1.0"
# }
```

---

## 🔌 Access URLs

### Backend API

| Service | URL | Descripción |
|---------|-----|-------------|
| **API** | http://localhost:8000 | API root |
| **Health** | http://localhost:8000/api/v1/health | Backend estado |
| **Swagger** | http://localhost:8000/docs | Interactive documentoation |
| **ReDoc** | http://localhost:8000/redoc | Alternative documentoation |

### Internal Services

| Service | Host | Port | Descripción |
|---------|------|------|-------------|
| **Ollama** | ollama (sa_network) | 11434 | Local LLM engine |
| **ChromaDB** | chromadb (sa_network) | 8000 | Vector database |

### Databases

| Database | Location | Type | Persistence |
|----------|----------|------|-------------|
| **SQLite** | `infrastructure/data/softarchitect.db` | Relational | Docker volume |
| **ChromaDB** | `infrastructure/chroma_storage/` | Vector | Docker volume |
| **Ollama** | `ollama_storage/` | Models | Docker volume |

---

## 🛑 Stop Services

### Pause (keeps data)
```bash
docker compose pause
```

### Resume
```bash
docker compose unpause
```

### Stop (removes containers, keeps data)
```bash
docker compose down
```

### Clean Everything (removes containers, volumes, networks)
```bash
docker compose down -v
```

---

## 🐛 Troubleshooting

### Problem: "Error connecting to docker daemon"

**Solution:**
```bash
# Option 1: Use sudo
sudo docker compose up -d

# Option 2: Add user to docker group (permanent)
sudo usermod -aG docker $USER
newgrp docker
```

### Problem: "Port 8000 already in use"

**Solution:**
```bash
# Check what's using the port
lsof -i :8000

# Kill process
kill -9 <PID>

# Or map to different port in docker-compose.yml:
# ports:
#   - "8001:8000"
```

### Problem: Services slow to start

**Normal behavior:** Ollama and ChromaDB may take 20-30 seconds. Be patient.

```bash
# Monitor progress
docker compose logs -f
```

### Problem: API returns connection error to Ollama

**Solution:**
```bash
# Verify Ollama is running
docker ps | grep sa_ollama

# Restart Ollama
docker restart sa_ollama

# Check logs
docker logs sa_ollama
```

### Problem: ChromaDB complains about permissions

**Solution:**
```bash
# Fix volume permissions
sudo chown -R $(id -u):$(id -g) infrastructure/chroma_storage

# Restart
docker compose down
docker compose up -d
```

---

## 📊 Available Reports

### 1. [FUNCTIONAL_TEST_REPORT.md](../01-PROJECT_REPORT/FUNCTIONAL_TEST_REPORT.md)
- ✅ Complete prueba results (18 pruebas)
- ✅ Performance metrics
- ✅ Compliance validation
- ✅ 1000+ lines of detail

### 2. [INITIAL_SETUP_LOG.es.md](../01-PROJECT_REPORT/INITIAL_SETUP_LOG.es.md)
- ✅ Documentoation in Spanish
- ✅ 4 setup fases
- ✅ Timeline and Mermaid diagram
- ✅ 400+ lines

### 3. [INITIAL_SETUP_LOG.en.md](../01-PROJECT_REPORT/INITIAL_SETUP_LOG.en.md)
- ✅ Documentoation in English
- ✅ Complete translated version
- ✅ 500+ lines

### 4. [DOCKER_COMPOSE_GUIDE.es.md](./DOCKER_COMPOSE_GUIDE.es.md)
- ✅ Complete Docker guide
- ✅ Troubleshooting (7 common problems)
- ✅ 500+ lines

### 5. [DOCKER_COMPOSE_AUDIT.md](../../DOCKER_COMPOSE_AUDIT.md)
- ✅ 12 identified and resolved problems
- ✅ Before vs after
- ✅ Change checklist

### 6. [DOCKER_VALIDATION_REPORT.md](../../DOCKER_VALIDATION_REPORT.md)
- ✅ Final validation report
- ✅ Estado comparison
- ✅ Impact metrics

---

## 📝 Common Tasks

### Compile Frontend

```bash
cd src/client
flutter pub get
flutter analyze
flutter run -d linux
```

### Ejecutar Backend Pruebas

```bash
cd src/server
python -m pytest

# With coverage
python -m pytest --cov=app
```

### Format Python Code

```bash
cd src/server
black app/
```

### Format Dart Code

```bash
cd src/client
dart format lib/
```

### Python Linting

```bash
cd src/server
flake8 app/ --max-line-length=120
```

### Python Type Checking

```bash
cd src/server
mypy app/ --ignore-missing-imports
```

---

## 🔐 Environment Variables

### Infraestructura (infrastructure/.env)

```bash
OLLAMA_IMAGE_VERSION=latest
CHROMADB_IMAGE_VERSION=latest
PYTHON_VERSION=3.12.3
OLLAMA_MEMORY_LIMIT=2GB
CHROMADB_MEMORY_LIMIT=512MB
API_MEMORY_LIMIT=512MB
LLM_PROVIDER=local
OLLAMA_MODEL=qwen2.5-coder:7b
IRON_MODE=True
```

### Server (src/server/.env.example)

Copy to `src/server/.env` and edit as needed:

```bash
cp src/server/.env.example src/server/.env
```

Main configuracións:
```bash
DEBUG=False
IRON_MODE=True
LLM_PROVIDER=local
OLLAMA_BASE_URL=http://ollama:11434
GROQ_API_KEY=  # (optional, for Ether mode)
```

---

## 📊 Docker Network Architecture

```
┌─────────────────────────────────────────┐
│  Host (Linux/Windows/macOS)             │
│                                         │
│  localhost:8000 ──┐                    │
│                   │                    │
│  ┌─────────────────────────────────┐  │
│  │  Docker Network (sa_network)    │  │
│  │  Subnet: 172.25.0.0/16         │  │
│  │                                 │  │
│  │  ┌──────────────┐               │  │
│  │  │ sa_ollama    │               │  │
│  │  │ 172.25.0.2   │               │  │
│  │  │ :11434       │               │  │
│  │  └──────────────┘               │  │
│  │           ▲                     │  │
│  │           │                     │  │
│  │  ┌──────────────┐  ┌─────────┐ │  │
│  │  │ sa_chromadb  │  │ sa_api  │ │  │
│  │  │ 172.25.0.3   │  │ 172.25. │ │  │
│  │  │ :8000        │  │ 0.4     │ │  │
│  │  └──────────────┘  │ :8000   │ │  │
│  │           ▲        └─────────┘ │  │
│  │           │             ▲      │  │
│  │           └─────────────┘      │  │
│  └─────────────────────────────────┘  │
│                                        │
└─────────────────────────────────────────┘
```

---

## 💾 Volumes and Persistence

### Named Volumes

```bash
# List volumes
docker volume ls

# Inspect volume
docker volume inspect infrastructure_ollama_storage
docker volume inspect infrastructure_chroma_storage
```

### Mounted Directories

```
infrastructure/
├── logs/           # Application logs
├── data/           # SQLite and cache
│   ├── softarchitect.db      (SQLite)
│   └── chromadb/             (ChromaDB local)
└── chroma_storage/           (Docker volume)
```

---

## 🎯 Siguiente Steps

### For Developers

1. **Read documentoation:**
   - [AGENTS.md](../../AGENTS.md) - Vision and rules
   - [FUNCTIONAL_TEST_REPORT.md](../01-PROJECT_REPORT/FUNCTIONAL_TEST_REPORT.md) - Prueba results
   - [INITIAL_SETUP_LOG.en.md](../01-PROJECT_REPORT/INITIAL_SETUP_LOG.en.md) - Complete setup

2. **Start development:**
   ```bash
   cd infrastructure
   docker compose up -d
   cd ../src/client
   flutter run -d linux
   ```

3. **Implement features:**
   - See [ROADMAP_PHASES.en.md](../../context/40-ROADMAP/ROADMAP_PHASES.en.md)
   - See [ROADMAP_DETAILED.en.md](../../context/40-ROADMAP/ROADMAP_DETAILED.en.md)

### For DevOps

1. **CI/CD Setup:**
   - Crear `.github/workflows/` for GitHub Actions
   - Implement Docker registry

2. **Monitoring:**
   - Configure Prometheus + Grafana
   - Health checks on each service

3. **Production:**
   - Migrate to Kubernetes (optional)
   - Configure SSL/TLS
   - Centralized logging (ELK stack)

---

## 🆘 Quick Support

### Contact

- **Documentoation:** Read `AGENTS.md` and archivos in `doc/` and `context/`
- **Issues:** See `FUNCTIONAL_TEST_REPORT.md` for troubleshooting
- **Logs:** `docker compose logs -f`

### Debugging Commands

```bash
# Complete status
docker compose ps -a

# Inspect container
docker inspect sa_api

# Enter container
docker exec -it sa_api /bin/bash

# Test connectivity
docker exec sa_api curl http://ollama:11434/
```

---

## 📌 Important Notes

- ✅ **Iron Mode (Local):** By default, all data is processed locally
- ✅ **Privacy:** Data is not sent to the cloud without explicit consent
- ✅ **Offline:** Proyecto works completely offline (except initial model download)
- ✅ **Resources:** Memory limited to 3.0 GB total (configurable)
- ✅ **Port 8000:** Reserved for API, don't change without editing configuración

---

**Last updated:** January 28, 2026
**Version:** 1.0
**Estado:** ✅ PRODUCTION READY
