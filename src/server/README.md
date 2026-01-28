# SoftArchitect AI - Python Backend

## Overview

Backend API for **SoftArchitect AI**, built with FastAPI.

- ✅ Multi-platform support: Linux, Windows, macOS
- ✅ Async/await with Uvicorn ASGI server
- ✅ Modular Monolith architecture
- ✅ Privacy-first (Local-only by default, optional Cloud)
- ✅ ChromaDB for vector embeddings
- ✅ Ollama (local) or Groq (cloud) for LLM inference

## Architecture

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

## Quick Start

### 1. Setup Python Environment

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

### 2. Configure Environment

```bash
cp .env.example .env
# Edit .env with your configuration
```

### 3. Run Development Server

```bash
# Start API with auto-reload
python -m uvicorn app.main:app --reload --host 0.0.0.0 --port 8000

# Or use the direct command
uvicorn app.main:app --reload
```

Server will start at: **http://localhost:8000**

### 4. API Documentation

Once running, visit:
- **Swagger UI:** http://localhost:8000/docs
- **ReDoc:** http://localhost:8000/redoc

### 5. Health Check

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

## Running Tests

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

## Code Quality

```bash
# Format code with Black
black app/

# Lint with Flake8
flake8 app/

# Type checking with MyPy
mypy app/
```

## Dependencies

### Core Framework
- `fastapi` (0.104.1) - Modern web framework
- `uvicorn` (0.24.0) - ASGI server

### Data & Validation
- `pydantic` (2.5.0) - Data validation
- `pydantic-settings` (2.1.0) - Settings management

### Vector & LLM
- `chromadb` (0.4.21) - Vector database
- `langchain` (0.1.1) - LLM framework
- `ollama` (0.1.0) - Ollama client
- `groq` (0.4.1) - Groq API client

### Database
- `sqlalchemy` (2.0.23) - SQL toolkit
- `sqlite3-python` (1.0.0) - SQLite bindings

### Security
- `bcrypt` (4.1.1) - Password hashing
- `python-multipart` (0.0.6) - Form data

### Testing
- `pytest` (7.4.3) - Testing framework
- `pytest-asyncio` (0.21.1) - Async test support
- `httpx` (0.25.2) - HTTP testing client

### Code Quality
- `black` (23.12.0) - Formatter
- `flake8` (6.1.0) - Linter
- `mypy` (1.7.1) - Type checker

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `DEBUG` | `False` | Enable debug mode |
| `LOG_LEVEL` | `INFO` | Logging level (DEBUG, INFO, WARNING, ERROR) |
| `LLM_PROVIDER` | `local` | LLM provider (`local` or `cloud`) |
| `OLLAMA_BASE_URL` | `http://localhost:11434` | Ollama server URL |
| `GROQ_API_KEY` | `` | Groq API key (if using cloud) |
| `CHROMADB_PATH` | `./data/chromadb` | ChromaDB storage path |
| `CHROMA_COLLECTION_NAME` | `softarchitect` | Vector collection name |

## Project Structure

Following Modular Monolith pattern with Clean Architecture principles:
- **Separation of Concerns:** API layer, Domain logic, Infrastructure
- **Dependency Inversion:** Domain depends on nothing, infrastructure implements contracts
- **Privacy First:** Local-only by default, cloud optional
- **Type Safety:** Full MyPy compliance

## Next Phases

- **Phase 2:** Implement Chat endpoints with LLM integration
- **Phase 3:** Implement Knowledge base search with ChromaDB
- **Phase 4:** Deploy with Docker Compose

## References

- [FastAPI Documentation](https://fastapi.tiangolo.com/)
- [Pydantic V2](https://docs.pydantic.dev/)
- [ChromaDB Docs](https://docs.trychroma.com/)
- [LangChain](https://python.langchain.com/)
