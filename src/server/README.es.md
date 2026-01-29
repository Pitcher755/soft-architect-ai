🐍 SoftArchitect AI - Backend
FastAPI + Clean Architecture + Motor RAG

## Tabla de Contenidos
- Descripción
- Arquitectura
- Stack Tecnológico
- Instalación Local
- Testing
- Estructura del Proyecto
- Documentación de la API

## Descripción
Servicio backend para SoftArchitect AI, un asistente de arquitectura de software impulsado por IA.

Características Clave:

- Clean Architecture (Domain-Driven Design)
- Configuración type-safe (Pydantic Settings)
- Motor RAG (Retrieval-Augmented Generation)
- IA local-first con integración Ollama
- ChromaDB como vector store para base de conocimiento

## Arquitectura
Sigue los principios de Clean Architecture:

src/server/
├── core/           # Configuración, seguridad, eventos
├── domain/         # Lógica de negocio (entidades, esquemas)
├── services/       # Servicios de aplicación (RAG, vectores)
├── api/            # Capa API (routers, endpoints)
└── utils/          # Helpers genéricos

Referencia: context/30-ARCHITECTURE/PROJECT_STRUCTURE_MAP.en.md

## Stack Tecnológico
Framework: FastAPI 0.115.6
Servidor: Uvicorn 0.34.0 (ASGI)
Validación: Pydantic 2.10.5
Linter: Ruff 0.8.6
Testing: Pytest 8.3.4 + pytest-cov 6.0.0
Python: 3.12.3

## Instalación Local
Prerequisitos
Python 3.12.3+
Poetry 1.7.0+

Instalación
```bash
cd src/server
poetry install
```

Configurar entorno:
```bash
cp ../../infrastructure/.env.example .env
# Editar .env con tu configuración
```

Ejecutar servidor de desarrollo:
```bash
poetry run uvicorn main:app --reload --host 0.0.0.0 --port 8000
```

Acceder a la API:

API: http://localhost:8000
Swagger UI: http://localhost:8000/docs
ReDoc: http://localhost:8000/redoc

## Testing
Ejecutar todos los tests
```bash
poetry run pytest
```
Ejecutar con cobertura
```bash
poetry run pytest --cov=. --cov-report=html
```
Ver reporte de cobertura: open htmlcov/index.html

Ejecutar linter
```bash
# Solo verificar
poetry run ruff check .

# Auto-fix
poetry run ruff check --fix .

# Formatear
poetry run ruff format .
```

## Estructura del Proyecto
Ver la estructura del proyecto en la raíz del repositorio. Carpeta clave:

src/server/
├── api/
│   └── v1/
│       ├── endpoints/      # Implementaciones de endpoints
│       │   └── system.py   # Endpoints de health, status
│       └── router.py       # Agregador de routers API
├── core/
│   ├── config.py           # Pydantic Settings (vars entorno)
│   └── errors.py           # Clases de error custom
├── domain/
│   ├── models/             # Entidades de negocio (vacío por ahora)
│   └── schemas/            # DTOs Pydantic
│       └── health.py       # Esquemas de respuesta health
├── services/
│   ├── rag/                # Lógica RAG (HU-2.1)
│   └── vectors/            # Lógica ChromaDB (HU-2.2)
├── utils/                  # Utilidades genéricas
├── tests/
├── main.py                 # Punto de entrada FastAPI
├── pyproject.toml          # Config Poetry + herramientas
└── README.md               # Este archivo

## Documentación de la API
Health Check
Endpoint: GET /api/v1/system/health

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
Endpoint: GET /api/v1/system/health/detailed

Respuesta:

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

## Referencias
- Mapa de Estructura del Proyecto
- Detalles del Stack Técnico
- Estándar de Manejo de Errores
- Reglas de Seguridad
- Estrategia de Testing
