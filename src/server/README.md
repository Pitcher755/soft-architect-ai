🐍 SoftArchitect AI - Backend
FastAPI + Clean Architecture + RAG Engine
🐍 SoftArchitect AI - Backend
FastAPI + Clean Architecture + RAG Engine

## Navegación
- [Español](#es)
- [English](#en)

---

<a name="es"></a>
## 🇪🇸 Español

**Índice (ES)**
- [Descripción](#es-overview)
- [Arquitectura](#es-architecture)
- [Stack Tecnológico](#es-tech)
- [Instalación Local](#es-setup)
- [Testing](#es-testing)
- [Estructura del Proyecto](#es-structure)
- [Documentación de la API](#es-api)
- [Referencias](#es-refs)

[Ir a English](#en)

---

<a name="es-overview"></a>
### 🎯 Descripción
Backend para SoftArchitect AI, un asistente de arquitectura de software impulsado por IA.

Características clave:
- Clean Architecture (Domain-Driven Design)
- Configuración type-safe (Pydantic Settings)
- Motor RAG (Retrieval-Augmented Generation)
- IA local-first con integración Ollama
- ChromaDB como vector store para la base de conocimiento

<a name="es-architecture"></a>
### 🏗️ Arquitectura
Sigue los principios de Clean Architecture:

```
src/server/
├── core/           # Configuración, seguridad, eventos
├── domain/         # Lógica de negocio (entidades, esquemas)
├── services/       # Servicios de aplicación (RAG, vectores)
├── api/            # Capa API (routers, endpoints)
└── utils/          # Helpers genéricos
```

Referencia: `context/30-ARCHITECTURE/PROJECT_STRUCTURE_MAP.en.md`

<a name="es-tech"></a>
### 🛠️ Stack Tecnológico
- Framework: FastAPI 0.115.6
- Servidor: Uvicorn 0.34.0 (ASGI)
- Validación: Pydantic 2.10.5
- Linter: Ruff 0.8.6
- Testing: Pytest 8.3.4 + pytest-cov 6.0.0
- Python: 3.12.3

<a name="es-setup"></a>
### 🚀 Instalación Local
Prerequisitos: Python 3.12.3+, Poetry 1.7.0+

Instalación:
```bash
cd src/server
poetry install
```

Configurar entorno:
```bash
# La configuración de entorno vive en la raíz del repositorio
# Ejecutar desde la raíz (si aún no existe el .env)
cp .env.example .env
# Editar .env con tu configuración
```

Ejecutar servidor de desarrollo:
```bash
poetry run uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Acceder a la API:
- API: http://localhost:8000
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

<a name="es-testing"></a>
### 🧪 Testing
Ejecutar todos los tests:
```bash
poetry run pytest
```
Con cobertura:
```bash
poetry run pytest --cov=. --cov-report=html
```
Ver reporte: `htmlcov/index.html`

Linter y formato:
```bash
poetry run ruff check .
poetry run ruff check --fix .
poetry run ruff format .
```

<a name="es-structure"></a>
### 📂 Estructura del Proyecto
Resumen de carpetas clave:

```
src/server/
├── api/
│   └── v1/
│       ├── endpoints/      # Implementaciones de endpoints
│       └── router.py       # Agregador de routers
├── core/
│   ├── config.py           # Pydantic Settings
│   └── errors.py           # Clases de error
├── domain/
│   ├── models/
│   └── schemas/
├── services/               # RAG, vectores
├── utils/
├── tests/
└── main.py
```

<a name="es-api"></a>
### 📖 Documentación de la API
Health Check
- Endpoint: `GET /api/v1/system/health`

Respuesta:
```json
{
  "status": "ok",
  "app": "SoftArchitect AI",
  "version": "0.1.0",
  "environment": "development",
  "debug_mode": false
}
```

Health Check Detallado
- Endpoint: `GET /api/v1/system/health/detailed`

Respuesta:
```json
{
  "status": "ok",
  "app": "SoftArchitect AI",
  "version": "0.1.0",
  "environment": "development",
  "debug_mode": false,
  "services": { "chromadb": "unknown", "ollama": "unknown" }
}
```

<a name="es-refs"></a>
### 🔗 Referencias
- Project Structure Map
- Tech Stack Details
- Error Handling Standard
- Security Rules
- Testing Strategy

---

<a name="en"></a>
## 🇬🇧 English

**Index (EN)**
- [Overview](#en-overview)
- [Architecture](#en-architecture)
- [Tech Stack](#en-tech)
- [Local Setup](#en-setup)
- [Testing](#en-testing)
- [Project Structure](#en-structure)
- [API Documentation](#en-api)
- [References](#en-refs)

[Ir a Español](#es)

---

<a name="en-overview"></a>
### 🎯 Overview
Backend service for SoftArchitect AI, an AI-powered software architecture assistant.

Key features:
- Clean Architecture (Domain-Driven Design)
- Type-safe configuration (Pydantic Settings)
- RAG engine (Retrieval-Augmented Generation)
- Local-first AI with Ollama integration
- ChromaDB vector store for knowledge base

<a name="en-architecture"></a>
### 🏗️ Architecture
Follows Clean Architecture principles:

```
src/server/
├── core/           # Configuration, security, events
├── domain/         # Business logic (entities, schemas)
├── services/       # Application services (RAG, vectors)
├── api/            # API layer (routers, endpoints)
└── utils/          # Generic helpers
```

Reference: `context/30-ARCHITECTURE/PROJECT_STRUCTURE_MAP.en.md`

<a name="en-tech"></a>
### 🛠️ Tech Stack
- Framework: FastAPI 0.115.6
- Server: Uvicorn 0.34.0 (ASGI)
- Validation: Pydantic 2.10.5
- Linter: Ruff 0.8.6
- Testing: Pytest 8.3.4 + pytest-cov 6.0.0
- Python: 3.12.3

<a name="en-setup"></a>
### 🚀 Local Setup
Prerequisites: Python 3.12.3+, Poetry 1.7.0+

Installation:
```bash
cd src/server
poetry install
```

Configure environment:
```bash
# Environment configuration lives at the repository root
# Run from the repo root (if .env does not exist yet)
cp .env.example .env
# Edit .env with your configuration
```

Run development server:
```bash
poetry run uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Access API:
- API: http://localhost:8000
- Swagger UI: http://localhost:8000/docs
- ReDoc: http://localhost:8000/redoc

<a name="en-testing"></a>
### 🧪 Testing
Run all tests:
```bash
poetry run pytest
```
With coverage:
```bash
poetry run pytest --cov=. --cov-report=html
```

Lint & format:
```bash
poetry run ruff check .
poetry run ruff check --fix .
poetry run ruff format .
```

<a name="en-structure"></a>
### 📂 Project Structure
```
src/server/
├── api/
│   └── v1/
│       ├── endpoints/      # Endpoint implementations
│       └── router.py       # API router aggregator
├── core/
│   ├── config.py           # Pydantic Settings (env vars)
│   └── errors.py           # Custom error classes
├── domain/
│   ├── models/
│   └── schemas/
├── services/               # RAG, vectors
├── utils/
├── tests/
└── main.py
```

<a name="en-api"></a>
### 📖 API Documentation
Health Check
- Endpoint: `GET /api/v1/system/health`

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
- Endpoint: `GET /api/v1/system/health/detailed`

Response:
```json
{
  "status": "ok",
  "app": "SoftArchitect AI",
  "version": "0.1.0",
  "environment": "development",
  "debug_mode": false,
  "services": { "chromadb": "unknown", "ollama": "unknown" }
}
```

<a name="en-refs"></a>
### 🔗 References
- Project Structure Map
- Tech Stack Details
- Error Handling Standard
- Security Rules
- Testing Strategy
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

#### LLM & RAG Configuration (Advanced)

| Variable | Default | Description |
|----------|---------|-------------|
| `LLM_MAX_PROMPT_CHARS` | `200000` | Hard ceiling for the assembled LLM prompt (chars ≈ tokens × 4). |
| `RAG_MAX_CHUNKS` | `3` | Number of per-project RAG chunks retrieved from ChromaDB per query. |

**`LLM_MAX_PROMPT_CHARS`** — Controls the maximum length of the full prompt sent to
the LLM. The default of `200000` is safe for cloud models (Gemini 1.5 Flash,
GPT-4). **Reduce to `30000`** when running local Ollama models with an 8 K-token
context window (≈32†00 chars) to avoid Out-of-Memory errors on commodity hardware.

**`RAG_MAX_CHUNKS`** — Controls how many project-specific document
fragments are retrieved from ChromaDB for each generation request.
- Set to `5` for maximum precision with large-context cloud models (Gemini / GPT-4).
- Set to `2` to reduce API token costs or to lighten the load on local models.

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

#### Configuración LLM & RAG (Avanzado)

| Variable | Default | Descripción |
|----------|---------|-------------|
| `LLM_MAX_PROMPT_CHARS` | `200000` | Límite máximo del prompt completo enviado al LLM (chars ≈ tokens × 4). |
| `RAG_MAX_CHUNKS` | `3` | Número de fragmentos de proyecto recuperados de ChromaDB por consulta. |

**`LLM_MAX_PROMPT_CHARS`** — Controla la longitud máxima del prompt enviado al LLM.
El valor por defecto `200000` es seguro para modelos en la nube (Gemini 1.5 Flash,
GPT-4). **Reducir a `30000`** cuando se usen modelos locales Ollama con ventana de
contexto de 8 K tokens (≈32†00 caracteres) para evitar errores Out-of-Memory en
hardware convencional.

**`RAG_MAX_CHUNKS`** — Controla cuántos fragmentos de documentos del proyecto se
recuperan de ChromaDB por cada solicitud de generación.
- Usar `5` para máxima precisión con modelos en la nube de gran contexto (Gemini / GPT-4).
- Usar `2` para reducir costes de tokens de API o aligerar modelos locales.

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
