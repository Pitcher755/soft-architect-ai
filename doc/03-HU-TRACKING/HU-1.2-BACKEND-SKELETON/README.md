# HU-1.2: Backend Skeleton (FastAPI + Clean Architecture)

> **Epic:** E1 - Orchestration & Environment
> **Sprint:** S1 - Infrastructure & Scaffolding (The Bedrock)
> **Status:** ✅ COMPLETED
> **Priority:** High
> **Estimate:** S (Small - 1-2 days)
> **Last Updated:** 29/01/2026

---

## 📋 Table of Contents (EN) | Tabla de Contenidos (ES)

### English Version
1. [User Story](#user-story-en)
2. [Description](#description-en)
3. [Acceptance Criteria](#acceptance-criteria-en)
4. [Dependencies](#dependencies-en)
5. [Key Files](#key-files-en)
6. [Quick Start](#quick-start-en)
7. [References](#references-en)

### Versión en Español
1. [Historia de Usuario](#historia-de-usuario-es)
2. [Descripción](#descripción-es)
3. [Criterios de Aceptación](#criterios-de-aceptación-es)
4. [Dependencias](#dependencias-es)
5. [Archivos Clave](#archivos-clave-es)
6. [Inicio Rápido](#inicio-rápido-es)
7. [Referencias](#referencias-es)

---

## 🎯 User Story (EN)

**As** Backend Developer,
**I want** a FastAPI base structure,
**So that** I can start developing endpoints on a clean architecture.

---

## 📝 Description (EN)

Implemented the complete backend scaffolding using FastAPI following Clean Architecture (DDD) principles. This story provides the foundation for future RAG engine implementations (HU-2.1, HU-2.2) and frontend Flutter integration (HU-3.x).

**Scope:**
- Poetry dependency management configured
- Folder structure following `PROJECT_STRUCTURE_MAP.md`
- Type-safe configuration system with Pydantic Settings
- Basic health check endpoints
- Custom error handling system
- Tests with >80% coverage
- Bilingual documentation (EN + ES)

### ✅ Acceptance Criteria

1. **Reproducible Environment** ✅
   - `poetry install` configures everything without errors
   - `poetry.lock` generated correctly

2. **Clean Architecture** ✅
   - `src/server/` structure matches `PROJECT_STRUCTURE_MAP.md` exactly
   - Architecture test passes (`test_architecture.py`)

3. **Type-Safe Configuration** ✅
   - Environment variables read via Pydantic Settings
   - NO `os.getenv()` usage

4. **Code Quality** ✅
   - Ruff configured and enforces code standards
   - `ruff check .` returns 0 errors, 0 warnings

5. **Healthy API** ✅
   - `GET /api/v1/system/health` returns 200 OK
   - Response includes: status, app, version, environment, debug_mode

6. **Base Security** ✅
   - CORS configured with explicit whitelist (NO wildcard `*`)
   - No hardcoded secrets in code

7. **Error Handling** ✅
   - Custom error system per `ERROR_HANDLING_STANDARD.md`
   - Errors categorized: SYS_XXX, API_XXX, RAG_XXX, DB_XXX

8. **Test Coverage** ✅
   - `pytest --cov` reports >80% coverage (~98%)
   - Unit, integration and architecture tests pass

9. **Bilingual Docs** ✅
   - README with EN + ES blocks
   - Docstrings in English in all public modules

## 🔗 Dependencies

**Blocking (MUST):**
- ✅ HU-1.1: Docker Infrastructure Setup (merged to `develop`)
- ✅ `infrastructure/docker-compose.yml` functional
- ✅ `.env.example` exists and documented

**References (SHOULD READ):**
- [`context/30-ARCHITECTURE/PROJECT_STRUCTURE_MAP.en.md`](../../../../context/30-ARCHITECTURE/PROJECT_STRUCTURE_MAP.en.md)
- [`context/30-ARCHITECTURE/TECH_STACK_DETAILS.en.md`](../../../../context/30-ARCHITECTURE/TECH_STACK_DETAILS.en.md)
- [`context/30-ARCHITECTURE/ERROR_HANDLING_STANDARD.en.md`](../../../../context/30-ARCHITECTURE/ERROR_HANDLING_STANDARD.en.md)
- [`context/20-REQUIREMENTS_AND_SPEC/SECURITY_AND_PRIVACY_RULES.en.md`](../../../../context/20-REQUIREMENTS_AND_SPEC/SECURITY_AND_PRIVACY_RULES.en.md)

## 📂 Key Files (EN)

| File | Purpose | Status |
|------|---------|--------|
| `src/server/app/main.py` | FastAPI app entrypoint | ✅ |
| `src/server/app/api/v1/__init__.py` | Router aggregator | ✅ |
| `src/server/app/api/v1/health.py` | Health endpoints | ✅ |
| `src/server/app/core/config.py` | Pydantic Settings | ✅ |
| `src/server/app/core/security.py` | Security utilities | ✅ |
| `src/server/app/core/database.py` | DB initialization | ✅ |
| `src/server/tests/` | Unit + Integration tests | ✅ |
| `src/server/pyproject.toml` | Dependencies & tools config | ✅ |

## 🚀 Quick Start (EN)

```bash
# 1. Navigate to backend
cd src/server

# 2. Create virtual environment
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate

# 3. Install dependencies
pip install -r requirements.txt

# 4. Run tests with coverage
PYTHONPATH=. pytest -q --cov=. --cov-report=html

# 5. Start development server
PYTHONPATH=. uvicorn app.main:app --reload --port 8000

# 6. Access API
# - API: http://localhost:8000
# - Swagger UI: http://localhost:8000/docs
# - ReDoc: http://localhost:8000/redoc
```

## 🔍 References (EN)

- [WORKFLOW.md](WORKFLOW.md) - Step-by-step guide (6 phases)
- [PROGRESS.md](PROGRESS.md) - Task tracking checklist
- [ARTIFACTS.md](ARTIFACTS.md) - Generated artifacts manifest
- [PHASE_5_SECURITY_VALIDATION_REPORT.md](PHASE_5_SECURITY_VALIDATION_REPORT.md) - Security audit results
- [src/server/README.md](../../../../src/server/README.md) - Detailed backend guide

---

---

## 🎯 Historia de Usuario (ES)

**Como** Desarrollador Backend,
**Quiero** la estructura base de FastAPI,
**Para** empezar a desarrollar endpoints sobre una arquitectura limpia.

---

## 📝 Descripción (ES)

Se implementó el scaffolding completo del backend usando FastAPI siguiendo los principios de Clean Architecture (DDD). Esta historia proporciona la base para futuras implementaciones del motor RAG (HU-2.1, HU-2.2) e integración con frontend Flutter (HU-3.x).

**Alcance:**
- Gestor de dependencias Poetry configurado
- Estructura de carpetas según `PROJECT_STRUCTURE_MAP.md`
- Sistema de configuración type-safe con Pydantic Settings
- Endpoints básicos de health check
- Sistema personalizado de manejo de errores
- Tests con cobertura >80%
- Documentación bilingüe (EN + ES)

### ✅ Criterios de Aceptación (ES)

1. **Entorno Reproducible** ✅
   - `poetry install` configura todo sin errores
   - `poetry.lock` generado correctamente

2. **Arquitectura Limpia** ✅
   - Estructura `src/server/` coincide exactamente con `PROJECT_STRUCTURE_MAP.md`
   - Test de arquitectura pasa (`test_architecture.py`)

3. **Configuración Type-Safe** ✅
   - Variables de entorno leídas vía Pydantic Settings
   - SIN uso de `os.getenv()`

4. **Calidad de Código** ✅
   - Ruff configurado y aplica estándares
   - `ruff check .` devuelve 0 errores, 0 warnings

5. **API Saludable** ✅
   - `GET /api/v1/system/health` devuelve 200 OK
   - Respuesta incluye: status, app, version, environment, debug_mode

6. **Seguridad Base** ✅
   - CORS configurado con lista blanca explícita (SIN wildcard `*`)
   - Sin secrets hardcodeados en código

7. **Manejo de Errores** ✅
   - Sistema de errores personalizado per `ERROR_HANDLING_STANDARD.md`
   - Errores categorizados: SYS_XXX, API_XXX, RAG_XXX, DB_XXX

8. **Cobertura de Tests** ✅
   - `pytest --cov` reporta cobertura >80% (~98%)
   - Tests unitarios, integración y arquitectura pasan

9. **Docs Bilingüe** ✅
   - README con bloques EN + ES
   - Docstrings en inglés en todos los módulos públicos

## 🔗 Dependencias (ES)

**Bloqueantes (MUST):**
- ✅ HU-1.1: Docker Infrastructure Setup (merged a `develop`)
- ✅ `infrastructure/docker-compose.yml` funcional
- ✅ `.env.example` existente y documentado

**Referencias (SHOULD READ):**
- [`context/30-ARCHITECTURE/PROJECT_STRUCTURE_MAP.en.md`](../../../../context/30-ARCHITECTURE/PROJECT_STRUCTURE_MAP.en.md)
- [`context/30-ARCHITECTURE/TECH_STACK_DETAILS.en.md`](../../../../context/30-ARCHITECTURE/TECH_STACK_DETAILS.en.md)
- [`context/30-ARCHITECTURE/ERROR_HANDLING_STANDARD.en.md`](../../../../context/30-ARCHITECTURE/ERROR_HANDLING_STANDARD.en.md)
- [`context/20-REQUIREMENTS_AND_SPEC/SECURITY_AND_PRIVACY_RULES.en.md`](../../../../context/20-REQUIREMENTS_AND_SPEC/SECURITY_AND_PRIVACY_RULES.en.md)

## 📂 Archivos Clave (ES)

| Archivo | Propósito | Estado |
|---------|-----------|--------|
| `src/server/app/main.py` | Punto de entrada FastAPI | ✅ |
| `src/server/app/api/v1/__init__.py` | Agregador de routers | ✅ |
| `src/server/app/api/v1/health.py` | Endpoints de health | ✅ |
| `src/server/app/core/config.py` | Pydantic Settings | ✅ |
| `src/server/app/core/security.py` | Utilidades de seguridad | ✅ |
| `src/server/app/core/database.py` | Inicialización de BD | ✅ |
| `src/server/tests/` | Tests unitarios + integración | ✅ |
| `src/server/pyproject.toml` | Config de dependencias y herramientas | ✅ |

## 🚀 Inicio Rápido (ES)

```bash
# 1. Navegar al backend
cd src/server

# 2. Crear entorno virtual
python -m venv venv
source venv/bin/activate  # En Windows: venv\Scripts\activate

# 3. Instalar dependencias
pip install -r requirements.txt

# 4. Ejecutar tests con cobertura
PYTHONPATH=. pytest -q --cov=. --cov-report=html

# 5. Iniciar servidor de desarrollo
PYTHONPATH=. uvicorn app.main:app --reload --port 8000

# 6. Acceder a la API
# - API: http://localhost:8000
# - Swagger UI: http://localhost:8000/docs
# - ReDoc: http://localhost:8000/redoc
```

## 🔍 Referencias (ES)

- [WORKFLOW.md](WORKFLOW.md) - Guía paso a paso (6 fases)
- [PROGRESS.md](PROGRESS.md) - Checklist de seguimiento
- [ARTIFACTS.md](ARTIFACTS.md) - Manifiesto de artefactos
- [src/server/README.md](../../../../src/server/README.md) - Guía detallada del backend

---

**Última Actualización:** 29/01/2026
**Responsable:** Backend Dev
**Rama:** `feature/backend-skeleton`
