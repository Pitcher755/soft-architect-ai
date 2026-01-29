# HU-1.2: Artifacts Manifest

> **Historia de Usuario:** Backend Skeleton (FastAPI + Clean Architecture)  
> **Fecha de creación:** 29/01/2026  
> **Estado:** 📋 TEMPLATE

---

## 📋 Tabla de Contenidos

1. [Código Fuente](#código-fuente)
2. [Tests](#tests)
3. [Configuración](#configuración)
4. [Documentación](#documentación)
5. [Validación](#validación)

---

## 📦 Código Fuente

### Core Layer

| Archivo | Descripción | Líneas (estimado) | Estado |
|---------|-------------|-------------------|--------|
| `src/server/core/config.py` | Pydantic Settings para configuración tipada | ~120 | ⏸ Pendiente |
| `src/server/core/errors.py` | Sistema de errores custom (ERROR_HANDLING_STANDARD) | ~100 | ⏸ Pendiente |
| `src/server/core/__init__.py` | Package init | ~10 | ⏸ Pendiente |

### Domain Layer

| Archivo | Descripción | Líneas (estimado) | Estado |
|---------|-------------|-------------------|--------|
| `src/server/domain/schemas/health.py` | DTOs para health check responses | ~30 | ⏸ Pendiente |
| `src/server/domain/schemas/__init__.py` | Package init | ~5 | ⏸ Pendiente |
| `src/server/domain/models/__init__.py` | Package init (vacío por ahora) | ~5 | ⏸ Pendiente |
| `src/server/domain/__init__.py` | Package init | ~5 | ⏸ Pendiente |

### API Layer

| Archivo | Descripción | Líneas (estimado) | Estado |
|---------|-------------|-------------------|--------|
| `src/server/api/v1/endpoints/system.py` | Endpoints de health check | ~80 | ⏸ Pendiente |
| `src/server/api/v1/endpoints/__init__.py` | Package init | ~5 | ⏸ Pendiente |
| `src/server/api/v1/router.py` | API router aggregator | ~20 | ⏸ Pendiente |
| `src/server/api/v1/__init__.py` | Package init | ~5 | ⏸ Pendiente |
| `src/server/api/__init__.py` | Package init | ~5 | ⏸ Pendiente |

### Services Layer

| Archivo | Descripción | Líneas (estimado) | Estado |
|---------|-------------|-------------------|--------|
| `src/server/services/rag/__init__.py` | Package init (vacío para HU-2.1) | ~5 | ⏸ Pendiente |
| `src/server/services/vectors/__init__.py` | Package init (vacío para HU-2.2) | ~5 | ⏸ Pendiente |
| `src/server/services/__init__.py` | Package init | ~5 | ⏸ Pendiente |

### Utils Layer

| Archivo | Descripción | Líneas (estimado) | Estado |
|---------|-------------|-------------------|--------|
| `src/server/utils/__init__.py` | Package init (helpers generales) | ~5 | ⏸ Pendiente |

### Main Application

| Archivo | Descripción | Líneas (estimado) | Estado |
|---------|-------------|-------------------|--------|
| `src/server/main.py` | FastAPI app entrypoint con CORS | ~80 | ⏸ Pendiente |

---

## 🧪 Tests

### Architecture Tests

| Archivo | Descripción | Líneas (estimado) | Estado |
|---------|-------------|-------------------|--------|
| `src/server/tests/test_architecture.py` | Validación de estructura de carpetas | ~60 | ⏸ Pendiente |

### Unit Tests

| Archivo | Descripción | Líneas (estimado) | Estado |
|---------|-------------|-------------------|--------|
| `src/server/tests/test_config.py` | Tests de Pydantic Settings | ~40 | ⏸ Pendiente |
| `src/server/tests/test_errors.py` | Tests del sistema de errores | ~50 | ⏸ Pendiente |

### Integration Tests

| Archivo | Descripción | Líneas (estimado) | Estado |
|---------|-------------|-------------------|--------|
| `src/server/tests/test_api.py` | Tests de endpoints (TestClient) | ~100 | ⏸ Pendiente |

### Test Utilities

| Archivo | Descripción | Líneas (estimado) | Estado |
|---------|-------------|-------------------|--------|
| `src/server/tests/__init__.py` | Package init | ~5 | ⏸ Pendiente |

---

## ⚙️ Configuración

### Poetry Configuration

| Archivo | Descripción | Líneas (estimado) | Estado |
|---------|-------------|-------------------|--------|
| `src/server/pyproject.toml` | Poetry config + Ruff + Pytest settings | ~100 | ⏸ Pendiente |
| `src/server/poetry.lock` | Lockfile de dependencias | Auto-generado | ⏸ Pendiente |

### Docker Requirements

| Archivo | Descripción | Líneas (estimado) | Estado |
|---------|-------------|-------------------|--------|
| `src/server/requirements.txt` | Exportado desde Poetry para Docker | ~30 | ⏸ Pendiente |

### Pre-commit (Opcional)

| Archivo | Descripción | Líneas (estimado) | Estado |
|---------|-------------|-------------------|--------|
| `src/server/.pre-commit-config.yaml` | Hooks de pre-commit (Ruff, etc.) | ~30 | ⏸ Opcional |

---

## 📚 Documentación

### Technical Docs

| Archivo | Descripción | Líneas (estimado) | Estado |
|---------|-------------|-------------------|--------|
| `src/server/README.md` | Guía técnica EN (setup, testing, structure) | ~250 | ⏸ Pendiente |
| `src/server/README.es.md` | Guía técnica ES (traducción completa) | ~250 | ⏸ Pendiente |

### Project Tracking

| Archivo | Descripción | Líneas (estimado) | Estado |
|---------|-------------|-------------------|--------|
| `doc/03-HU-TRACKING/HU-1.2-BACKEND-SKELETON/README.md` | Overview de la HU | ~200 | ✅ Creado |
| `doc/03-HU-TRACKING/HU-1.2-BACKEND-SKELETON/WORKFLOW.md` | Workflow detallado (6 fases) | ~1200 | ✅ Creado |
| `doc/03-HU-TRACKING/HU-1.2-BACKEND-SKELETON/PROGRESS.md` | Tracking de tareas | ~300 | ✅ Creado |
| `doc/03-HU-TRACKING/HU-1.2-BACKEND-SKELETON/ARTIFACTS.md` | Este archivo | ~200 | ✅ Creado |

### Index Updates

| Archivo | Descripción | Estado |
|---------|-------------|--------|
| `doc/INDEX.md` | Añadir entrada HU-1.2 | ⏸ Pendiente |

---

## ✅ Validación

### Code Quality Reports

| Artefacto | Descripción | Estado |
|-----------|-------------|--------|
| Ruff Check Report | Output de `ruff check .` (0 errores) | ⏸ Pendiente |
| Ruff Format Report | Output de `ruff format .` (archivos formateados) | ⏸ Pendiente |
| Pytest Coverage Report | HTML coverage report (htmlcov/index.html) | ⏸ Pendiente |
| Pytest Summary | Output de pytest con % cobertura | ⏸ Pendiente |

### Security Reports

| Artefacto | Descripción | Estado |
|-----------|-------------|--------|
| Bandit Security Scan | Output de `bandit -r .` (0 críticos) | ⏸ Pendiente |
| Secret Detection Report | Output de `security-validation.sh` | ⏸ Pendiente |

### Docker Validation

| Artefacto | Descripción | Estado |
|-----------|-------------|--------|
| Docker Build Logs | Logs de `docker compose build` | ⏸ Pendiente |
| Docker Run Logs | Logs de `docker logs sa_api` | ⏸ Pendiente |
| Swagger UI Screenshot | Captura de http://localhost:8000/docs | ⏸ Pendiente |

---

## 📊 Resumen de Artefactos

| Categoría | Total | Completados | Pendientes | Opcional |
|-----------|-------|-------------|------------|----------|
| **Código Fuente** | 18 archivos | 0 | 18 | 0 |
| **Tests** | 5 archivos | 0 | 5 | 0 |
| **Configuración** | 3 archivos | 0 | 2 | 1 |
| **Documentación** | 6 archivos | 4 | 2 | 0 |
| **Validación** | 7 reportes | 0 | 7 | 0 |

**Total de artefactos:** 39 (35 obligatorios + 4 completados)

---

## 🔖 Leyenda de Estados

- ✅ **Creado** - Artefacto existe y está completo
- 🔄 **En Progreso** - Trabajando en el artefacto
- ⏸ **Pendiente** - No iniciado
- ❌ **Bloqueado** - Requiere resolución de dependencia
- 🔀 **Opcional** - No requerido para completar la HU

---

## 📝 Notas de Implementación

### Archivos Críticos (Bloqueantes)

Estos archivos deben completarse OBLIGATORIAMENTE:

1. `main.py` - Sin esto no hay API
2. `core/config.py` - Sin configuración no arranca
3. `core/errors.py` - Manejo de errores es crítico
4. `api/v1/endpoints/system.py` - Endpoints health son criterio de aceptación
5. `tests/test_api.py` - Sin tests no se puede mergear

### Archivos Nice-to-Have (Mejoran calidad)

Estos archivos mejoran la calidad pero no bloquean el merge:

1. `.pre-commit-config.yaml` - Automatiza linting
2. Screenshots de Swagger UI - Visual pero no funcional

### Orden Recomendado de Implementación

1. **Fase 1:** Configuración (config.py, errors.py)
2. **Fase 2:** Schemas (health.py)
3. **Fase 3:** Endpoints (system.py, router.py, main.py)
4. **Fase 4:** Tests (test_*.py)
5. **Fase 5:** Documentación (README.md)
6. **Fase 6:** Validación (ruff, bandit, docker)

---

**Última actualización:** 29/01/2026  
**Responsable:** Backend Dev  
**Próxima revisión:** Al completar Fase 2 (Scaffolding)
