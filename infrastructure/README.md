# 🐳 Infrastructure

## Navigation / Navegación

- [English](#english)
- [Español](#español)

---

<a name="english"></a>
## 🇬🇧 English

### Overview

This directory contains the Docker Compose stack that runs all backend services for
SoftArchitect AI.

| Service | Container | Port | Description |
|---------|-----------|------|-------------|
| **FastAPI Backend** | `sa_api` | `8000` | Python API + RAG engine |
| **ChromaDB** | `sa_chromadb` | `8001` | Vector store (knowledge base) |
| **Ollama** | `sa_ollama` | `11434` | Local LLM runtime |

Internal network: `sa_network` — bridge `172.25.0.0/16`.

---

### ⚙️ Environment Configuration

All environment variables live in **one file** at the **repository root**: `.env` (gitignored).

```bash
# Run from the repo root — create your .env from the template
cp .env.example .env

# Edit the file to match your setup
nano .env
```

The `.env.example` file in this directory is the **authoritative template**. It is committed to
version control to document every available variable and its default value. Never edit it
directly for local use — copy it to the repo root first.

> **Why root `.env`?** See
> [ADR-003: Centralized Env Configuration](../context/30-ARCHITECTURE/ADR/ADR-003-Centralized-Env-Configuration.en.md)
> for the full rationale.

---

### 🚀 Running the Stack

#### Option 1 — From `infrastructure/` (canonical form)

```bash
cd infrastructure
docker compose --env-file ../.env up -d
```

#### Option 2 — From the repository root

```bash
docker compose -f infrastructure/docker-compose.yml --env-file .env up -d
```

> **Why `--env-file`?** Docker Compose v2 resolves the implicit `.env` relative to the compose
> file's directory (`infrastructure/`). The `--env-file` flag makes the source explicit and
> deterministic regardless of CWD. Without it, `${VAR}` substitutions in the compose file
> silently fall back to empty strings.

#### Option 3 — Helper script (recommended, includes health checks)

```bash
# From the repo root
./scripts/devops/start_stack.sh
```

---

### 🔧 Common Commands

```bash
# Check running services
docker compose -f infrastructure/docker-compose.yml ps

# Follow logs (all services)
docker compose -f infrastructure/docker-compose.yml logs -f

# Follow logs (single service: api-server | chromadb | ollama)
docker compose -f infrastructure/docker-compose.yml logs -f api-server

# Stop all services (preserves volumes)
docker compose -f infrastructure/docker-compose.yml --env-file .env down

# Stop and remove volumes (full reset)
docker compose -f infrastructure/docker-compose.yml --env-file .env down -v

# Rebuild and restart a single service
docker compose -f infrastructure/docker-compose.yml --env-file .env up -d --build api-server
```

---

### 🎮 GPU Acceleration (NVIDIA)

The `api-server` service is configured for optional NVIDIA GPU pass-through via the Docker
Compose `deploy.resources.reservations.devices` block. On CPU-only machines this block is
ignored automatically by Docker Compose — no changes needed.

To verify GPU availability inside the container:

```bash
docker exec sa_api nvidia-smi
```

---

### 📂 Directory Contents

```
infrastructure/
├── docker-compose.yml       ← Service definitions (api-server, chromadb, ollama)
├── .env.example             ← Environment template (committed, never edit directly)
├── pre_check.py             ← Pre-flight validation (run before docker compose up)
├── verify_setup.py          ← Post-deployment health checks
├── security-validation.sh   ← Security gate checks
├── validate-docker-setup.sh ← Docker configuration validator
├── chroma_data/             ← ChromaDB persistent index (gitignored)
└── data/                    ← Additional persistent volumes (gitignored)
```

---

### 📚 Related Documentation

- [ADR-003: Centralized Env Configuration](../context/30-ARCHITECTURE/ADR/ADR-003-Centralized-Env-Configuration.en.md)
- [Docker Compose Guide](../doc/English/02-SETUP_DEV/02-DOCKER/DOCKER_COMPOSE_UPDATE_SUMMARY.md)
- [Hardware Acceleration Guide](../doc/English/02-SETUP_DEV/01-INSTALLATION/HARDWARE_ACCELERATION_GUIDE.md)
- [Security Hardening Policy](../context/SECURITY_HARDENING_POLICY.en.md)

---

<a name="español"></a>
## 🇪🇸 Español

### Descripción General

Este directorio contiene el stack de Docker Compose que ejecuta todos los servicios backend de
SoftArchitect AI.

| Servicio | Contenedor | Puerto | Descripción |
|----------|------------|--------|-------------|
| **FastAPI Backend** | `sa_api` | `8000` | API Python + motor RAG |
| **ChromaDB** | `sa_chromadb` | `8001` | Vector store (base de conocimiento) |
| **Ollama** | `sa_ollama` | `11434` | Runtime LLM local |

Red interna: `sa_network` — bridge `172.25.0.0/16`.

---

### ⚙️ Configuración del Entorno

Todas las variables de entorno viven en **un único archivo** en la **raíz del repositorio**:
`.env` (en .gitignore).

```bash
# Ejecutar desde la raíz del repo — crear tu .env desde la plantilla
cp .env.example .env

# Editar el archivo según tu configuración
nano .env
```

El archivo `.env.example` de este directorio es la **plantilla autoritativa**. Está versionado
en control de cambios para documentar cada variable disponible y su valor por defecto. Nunca lo
edites directamente para uso local — cópialo primero a la raíz del repo.

> **¿Por qué `.env` en la raíz?** Consulta
> [ADR-003: Configuración de Entorno Centralizada](../context/30-ARCHITECTURE/ADR/ADR-003-Centralized-Env-Configuration.es.md)
> para el razonamiento completo.

---

### 🚀 Arrancar el Stack

#### Opción 1 — Desde `infrastructure/` (forma canónica)

```bash
cd infrastructure
docker compose --env-file ../.env up -d
```

#### Opción 2 — Desde la raíz del repositorio

```bash
docker compose -f infrastructure/docker-compose.yml --env-file .env up -d
```

> **¿Por qué `--env-file`?** Docker Compose v2 resuelve el `.env` implícito relativo al
> directorio del archivo compose (`infrastructure/`). El flag `--env-file` hace la fuente
> explícita y determinística independientemente del CWD. Sin él, las sustituciones `${VAR}` en
> el archivo compose caen silenciosamente a cadenas vacías.

#### Opción 3 — Script auxiliar (recomendado, incluye chequeos de salud)

```bash
# Desde la raíz del repo
./scripts/devops/start_stack.sh
```

---

### 🔧 Comandos Habituales

```bash
# Ver servicios en ejecución
docker compose -f infrastructure/docker-compose.yml ps

# Ver logs en tiempo real (todos los servicios)
docker compose -f infrastructure/docker-compose.yml logs -f

# Ver logs de un servicio concreto (api-server | chromadb | ollama)
docker compose -f infrastructure/docker-compose.yml logs -f api-server

# Detener todos los servicios (conserva los volúmenes)
docker compose -f infrastructure/docker-compose.yml --env-file .env down

# Detener y eliminar volúmenes (reinicio completo)
docker compose -f infrastructure/docker-compose.yml --env-file .env down -v

# Reconstruir y reiniciar un servicio concreto
docker compose -f infrastructure/docker-compose.yml --env-file .env up -d --build api-server
```

---

### 🎮 Aceleración GPU (NVIDIA)

El servicio `api-server` está configurado para el paso a través opcional de GPU NVIDIA mediante
el bloque `deploy.resources.reservations.devices` de Docker Compose. En máquinas sin GPU este
bloque es ignorado automáticamente — no se requieren cambios.

Para verificar la disponibilidad de la GPU dentro del contenedor:

```bash
docker exec sa_api nvidia-smi
```

---

### 📂 Contenido del Directorio

```
infrastructure/
├── docker-compose.yml       ← Definición de servicios (api-server, chromadb, ollama)
├── .env.example             ← Plantilla de entorno (versionado, nunca editar directamente)
├── pre_check.py             ← Verificación previa (ejecutar antes de docker compose up)
├── verify_setup.py          ← Chequeos de salud post-despliegue
├── security-validation.sh   ← Chequeos de seguridad
├── validate-docker-setup.sh ← Validador de configuración Docker
├── chroma_data/             ← Índice persistente de ChromaDB (en .gitignore)
└── data/                    ← Volúmenes de datos adicionales (en .gitignore)
```

---

### 📚 Documentación Relacionada

- [ADR-003: Configuración de Entorno Centralizada](../context/30-ARCHITECTURE/ADR/ADR-003-Centralized-Env-Configuration.es.md)
- [Guía Docker Compose](../doc/Español/02-SETUP_DEV/02-DOCKER/DOCKER_COMPOSE_UPDATE_SUMMARY.md)
- [Guía de Aceleración Hardware](../doc/Español/02-SETUP_DEV/01-INSTALACION/HARDWARE_ACCELERATION_GUIDE.md)
- [Política de Hardening de Seguridad](../context/SECURITY_HARDENING_POLICY.es.md)
