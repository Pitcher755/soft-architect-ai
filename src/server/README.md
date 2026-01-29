🐍 SoftArchitect AI - Backend
FastAPI + Clean Architecture + RAG Engine

## Table of Contents
- Overview
- Architecture
- Tech Stack
- Local Setup
- Testing
- Project Structure
- API Documentation

## Overview
Backend service for SoftArchitect AI, an AI-powered software architecture assistant.

Key Features:

- Clean Architecture (Domain-Driven Design)
- Type-safe configuration (Pydantic Settings)
- RAG (Retrieval-Augmented Generation) engine
- Local-first AI with Ollama integration
- ChromaDB vector store for knowledge base

## Architecture
Follows Clean Architecture principles:

src/server/
├── core/           # Configuration, security, events
├── domain/         # Business logic (entities, schemas)
├── services/       # Application services (RAG, vectors)
├── api/            # API layer (routers, endpoints)
└── utils/          # Generic helpers

Reference: context/30-ARCHITECTURE/PROJECT_STRUCTURE_MAP.en.md

## Tech Stack
Framework: FastAPI 0.115.6
Server: Uvicorn 0.34.0 (ASGI)
Validation: Pydantic 2.10.5
Linter: Ruff 0.8.6
Testing: Pytest 8.3.4 + pytest-cov 6.0.0
Python: 3.12.3

## Local Setup
Prerequisites
Python 3.12.3+
Poetry 1.7.0+

Installation
```bash
cd src/server
poetry install
```

Configure environment:
```bash
cp ../../infrastructure/.env.example .env
# Edit .env with your configuration
```

Run development server:
```bash
poetry run uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Access API:

API: http://localhost:8000
Swagger UI: http://localhost:8000/docs
ReDoc: http://localhost:8000/redoc

## Testing
Run all tests
```bash
poetry run pytest
```
Run with coverage
```bash
poetry run pytest --cov=. --cov-report=html
```
View coverage report: open htmlcov/index.html

Run linter
```bash
# Check only
poetry run ruff check .

# Auto-fix
poetry run ruff check --fix .

# Format
poetry run ruff format .
```

## Project Structure
See project layout in the repository root. Key folders:

src/server/
├── api/
│   └── v1/
│       ├── endpoints/      # Endpoint implementations
│       │   └── system.py   # Health, status endpoints
│       └── router.py       # API router aggregator
├── core/
│   ├── config.py           # Pydantic Settings (env vars)
│   └── errors.py           # Custom error classes
├── domain/
│   ├── models/             # Business entities (empty for now)
│   └── schemas/            # Pydantic DTOs
│       └── health.py       # Health response schemas
├── services/
│   ├── rag/                # RAG logic (HU-2.1)
│   └── vectors/            # ChromaDB logic (HU-2.2)
├── utils/                  # Generic utilities
├── tests/
├── main.py                 # FastAPI app entrypoint
├── pyproject.toml          # Poetry config + tool settings
└── README.md               # This file

## API Documentation
Health Check
Endpoint: GET /api/v1/system/health

Response:

```json
{
  "status": "ok",
  "app": "SoftArchitect AI",
  "version": "0.1.0",
  "environment": "development",
  "debug_mode": false
}
```

Detailed Health Check
Endpoint: GET /api/v1/system/health/detailed

Response:

```json
{
  "status": "ok",
  "app": "SoftArchitect AI",
  "version": "0.1.0",
  "environment": "development",
  "debug_mode": false,
  "services": {
    "chromadb": "unknown",
    "ollama": "unknown"
  }
}
```

## References
- Project Structure Map
- Tech Stack Details
- Error Handling Standard
- Security Rules
- Testing Strategy
# 🐍 SoftArchitect AI - Python Backend

**Languages:** [English](#english) | [Español](#español)

---

<a name="english"></a>

## 🇬🇧 English Version

### 🐍 SoftArchitect AI - Python Backend

#### Overview

Backend API for **SoftArchitect AI**, built with FastAPI.

- ✅ Multi-platform support: Linux, Windows, macOS
- ✅ Async/await with Uvicorn ASGI server
- ✅ Modular Monolith architecture
- ✅ Privacy-first (Local-only by default, optional Cloud)
- ✅ ChromaDB for vector embeddings
- ✅ Ollama (local) or Groq (cloud) for LLM inference

#### Architecture

```
app/
├── main.py                  # FastAPI entry point
├── core/                    # Global configuration
│   ├── config.py            # Settings from .env
│   ├── database.py          # ChromaDB & SQLite setup
│   └── security.py          # Input sanitization & validation
├── api/                     # API routes (versioned)
│   ├── v1/
│   │   ├── health.py        # Health check endpoint
│   │   ├── chat.py          # Chat messages (Phase 2)
│   │   └── knowledge.py     # Knowledge retrieval (Phase 2)
│   └── dependencies.py      # Shared dependencies
├── domain/                  # Business logic (Clean Arch)
│   ├── entities/            # ChatMessage, ChatSession
│   ├── services/            # Use cases
│   └── repositories/        # Data contracts
├── infrastructure/          # External integrations
│   ├── llm/                 # Ollama/Groq client
│   ├── vector_store/        # ChromaDB wrapper
│   └── external/            # Third-party APIs
└── tests/                   # Test suite
    ├── unit/                # Unit tests
    ├── integration/         # API integration tests
    └── fixtures/            # Test data
```

#### Quick Start

##### 1. Setup Python Environment

```bash
cd src/server

# Create virtual environment
python3.11 -m venv venv

# Activate virtual environment
# On Linux/macOS:
source venv/bin/activate
# On Windows:
# venv\Scripts\activate

# Upgrade pip
pip install --upgrade pip

# Install dependencies
pip install -r requirements.txt
```

##### 2. Configure Environment

```bash
cp .env.example .env
# Edit .env with your configuration
```

##### 3. Run Development Server

```bash
# Start API with auto-reload
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Or use the direct command
uvicorn app.main:app --reload
```

Server will start at: **http://localhost:8000**

##### 4. API Documentation

Once running, visit:
- **Swagger UI:** http://localhost:8000/docs
- **ReDoc:** http://localhost:8000/redoc

##### 5. Health Check

```bash
curl http://localhost:8000/api/v1/health
```

Response:
```json
{
  "status": "OK",
  "message": "SoftArchitect AI backend is running",
  "version": "0.1.0"
}
```

#### Running Tests

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=app tests/

# Run specific test file
pytest app/tests/unit/test_security.py

# Run in verbose mode
pytest -v

# Run with asyncio support
pytest --asyncio-mode=auto
```

#### Code Quality

```bash
# Format code with Black
black app/

# Lint with Flake8
flake8 app/

# Type checking with MyPy
mypy app/
```

#### Dependencies

##### Core Framework
- `fastapi` (0.104.1) - Modern web framework
- `uvicorn` (0.24.0) - ASGI server

##### Data & Validation
- `pydantic` (2.5.0) - Data validation
- `pydantic-settings` (2.1.0) - Settings management

##### Vector & LLM
- `chromadb` (0.4.21) - Vector database
- `langchain` (0.1.1) - LLM framework
- `ollama` (0.1.0) - Ollama client
- `groq` (0.4.1) - Groq API client

##### Database
- `sqlalchemy` (2.0.23) - SQL toolkit
- `sqlite3-python` (1.0.0) - SQLite bindings

##### Security
- `bcrypt` (4.1.1) - Password hashing
- `python-multipart` (0.0.6) - Form data

##### Testing
- `pytest` (7.4.3) - Testing framework
- `pytest-asyncio` (0.21.1) - Async test support
- `httpx` (0.25.2) - HTTP testing client

##### Code Quality
- `black` (23.12.0) - Formatter
- `flake8` (6.1.0) - Linter
- `mypy` (1.7.1) - Type checker

#### Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DEBUG` | `False` | Enable debug mode |
| `LOG_LEVEL` | `INFO` | Logging level (DEBUG, INFO, WARNING, ERROR) |
| `LLM_PROVIDER` | `local` | LLM provider (`local` or `cloud`) |
| `OLLAMA_BASE_URL` | `http://localhost:11434` | Ollama server URL |
| `GROQ_API_KEY` | `` | Groq API key (if using cloud) |
| `CHROMADB_PATH` | `./data/chromadb` | ChromaDB storage path |
| `CHROMA_COLLECTION_NAME` | `softarchitect` | Vector collection name |

#### Project Structure

Following Modular Monolith pattern with Clean Architecture principles:
- **Separation of Concerns:** API layer, Domain logic, Infrastructure
- **Dependency Inversion:** Domain depends on nothing, infrastructure implements contracts
- **Privacy First:** Local-only by default, cloud optional
- **Type Safety:** Full MyPy compliance

#### Next Phases

- **Phase 2:** Implement Chat endpoints with LLM integration
- **Phase 3:** Implement Knowledge base search with ChromaDB
- **Phase 4:** Deploy with Docker Compose

#### References

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Pydantic V2](https://docs.pydantic.dev/)
- [ChromaDB Docs](https://docs.trychroma.com/)
- [LangChain](https://python.langchain.com/)

---

<a name="español"></a>

## 🇪🇸 Versión en Español

### 🐍 SoftArchitect AI - Backend en Python

#### Descripción General

API Backend para **SoftArchitect AI**, construida con FastAPI.

- ✅ Soporte multi-plataforma: Linux, Windows, macOS
- ✅ Async/await con servidor ASGI Uvicorn
- ✅ Arquitectura Modular Monolith
- ✅ Privacy-first (Solo local por defecto, Cloud opcional)
- ✅ ChromaDB para embeddings vectoriales
- ✅ Ollama (local) o Groq (cloud) para inferencia LLM

#### Arquitectura

```
app/
├── main.py                  # Punto de entrada FastAPI
├── core/                    # Configuración global
│   ├── config.py            # Configuración desde .env
│   ├── database.py          # Setup de ChromaDB & SQLite
│   └── security.py          # Sanitización y validación de input
├── api/                     # Rutas API (versionadas)
│   ├── v1/
│   │   ├── health.py        # Endpoint de verificación
│   │   ├── chat.py          # Mensajes de chat (Fase 2)
│   │   └── knowledge.py     # Búsqueda de conocimiento (Fase 2)
│   └── dependencies.py      # Dependencias compartidas
├── domain/                  # Lógica de negocio (Clean Arch)
│   ├── entities/            # ChatMessage, ChatSession
│   ├── services/            # Use cases
│   └── repositories/        # Contratos de datos
├── infrastructure/          # Integraciones externas
│   ├── llm/                 # Cliente Ollama/Groq
│   ├── vector_store/        # Wrapper de ChromaDB
│   └── external/            # APIs de terceros
└── tests/                   # Suite de pruebas
    ├── unit/                # Pruebas unitarias
    ├── integration/         # Pruebas de integración
    └── fixtures/            # Datos de prueba
```

#### Inicio Rápido

##### 1. Configurar Entorno Python

```bash
cd src/server

# Crear entorno virtual
python3.11 -m venv venv

# Activar entorno virtual
# En Linux/macOS:
source venv/bin/activate
# En Windows:
# venv\Scripts\activate

# Actualizar pip
pip install --upgrade pip

# Instalar dependencias
pip install -r requirements.txt
```

##### 2. Configurar Entorno

```bash
cp .env.example .env
# Edita .env con tu configuración
```

##### 3. Ejecutar Servidor de Desarrollo

```bash
# Iniciar API con auto-recarga
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# O usar el comando directo
uvicorn app.main:app --reload
```

El servidor comenzará en: **http://localhost:8000**

##### 4. Documentación de API

Una vez corriendo, visita:
- **Swagger UI:** http://localhost:8000/docs
- **ReDoc:** http://localhost:8000/redoc

##### 5. Verificación de Salud

```bash
curl http://localhost:8000/api/v1/health
```

Respuesta:
```json
{
  "status": "OK",
  "message": "SoftArchitect AI backend is running",
  "version": "0.1.0"
}
```

#### Ejecutar Pruebas

```bash
# Ejecutar todas las pruebas
pytest

# Ejecutar con cobertura
pytest --cov=app tests/

# Ejecutar archivo de prueba específico
pytest app/tests/unit/test_security.py

# Ejecutar en modo verbose
pytest -v

# Ejecutar con soporte asyncio
pytest --asyncio-mode=auto
```

#### Calidad de Código

```bash
# Formatear código con Black
black app/

# Lint con Flake8
flake8 app/

# Type checking con MyPy
mypy app/
```

#### Dependencias

##### Framework Core
- `fastapi` (0.104.1) - Framework web moderno
- `uvicorn` (0.24.0) - Servidor ASGI

##### Datos & Validación
- `pydantic` (2.5.0) - Validación de datos
- `pydantic-settings` (2.1.0) - Gestión de configuración

##### Vector & LLM
- `chromadb` (0.4.21) - Base de datos vectorial
- `langchain` (0.1.1) - Framework LLM
- `ollama` (0.1.0) - Cliente Ollama
- `groq` (0.4.1) - Cliente API Groq

##### Base de Datos
- `sqlalchemy` (2.0.23) - SQL toolkit
- `sqlite3-python` (1.0.0) - Bindings SQLite

##### Seguridad
- `bcrypt` (4.1.1) - Hash de contraseñas
- `python-multipart` (0.0.6) - Datos de formulario

##### Testing
- `pytest` (7.4.3) - Framework de testing
- `pytest-asyncio` (0.21.1) - Soporte para tests async
- `httpx` (0.25.2) - Cliente HTTP para testing

##### Calidad de Código
- `black` (23.12.0) - Formateador
- `flake8` (6.1.0) - Linter
- `mypy` (1.7.1) - Type checker

#### Variables de Entorno

| Variable | Default | Descripción |
|----------|---------|-------------|
| `DEBUG` | `False` | Habilitar modo debug |
| `LOG_LEVEL` | `INFO` | Nivel de logging (DEBUG, INFO, WARNING, ERROR) |
| `LLM_PROVIDER` | `local` | Proveedor LLM (`local` o `cloud`) |
| `OLLAMA_BASE_URL` | `http://localhost:11434` | URL del servidor Ollama |
| `GROQ_API_KEY` | `` | API key de Groq (si usa cloud) |
| `CHROMADB_PATH` | `./data/chromadb` | Ruta de almacenamiento ChromaDB |
| `CHROMA_COLLECTION_NAME` | `softarchitect` | Nombre de colección vectorial |

#### Estructura del Proyecto

Siguiendo patrón Modular Monolith con principios de Clean Architecture:
- **Separación de Responsabilidades:** Capa API, lógica de dominio, infraestructura
- **Inversión de Dependencias:** El dominio no depende de nada, la infraestructura implementa contratos
- **Privacy First:** Solo local por defecto, cloud opcional
- **Seguridad de Tipos:** Cumplimiento total con MyPy

#### Próximas Fases

- **Fase 2:** Implementar endpoints de Chat con integración LLM
- **Fase 3:** Implementar búsqueda de base de conocimiento con ChromaDB
- **Fase 4:** Deploy con Docker Compose

#### Referencias

- [Documentación FastAPI](https://fastapi.tiangolo.com/)
- [Pydantic V2](https://docs.pydantic.dev/)
- [Docs ChromaDB](https://docs.trychroma.com/)
- [LangChain](https://python.langchain.com/)
