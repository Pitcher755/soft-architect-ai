# HU-1.2: Backend Skeleton (FastAPI + Clean Architecture)

> **Epic:** E1 - Orquestación y Entorno  
> **Sprint:** S1 - Infraestructura y Scaffolding (The Bedrock)  
> **Estado:** 📋 READY FOR IMPLEMENTATION  
> **Prioridad:** High  
> **Estimación:** S (Small - 1-2 días)

---

## 📖 Tabla de Contenidos

1. [User Story](#user-story)
2. [Descripción](#descripción)
3. [Criterios de Aceptación](#criterios-de-aceptación)
4. [Dependencias](#dependencias)
5. [Tareas Técnicas](#tareas-técnicas)
6. [Referencias](#referencias)
7. [Archivos del Tracking](#archivos-del-tracking)

---

## 🎯 User Story

**Como** Backend Dev,  
**Quiero** la estructura base de FastAPI,  
**Para** empezar a desarrollar endpoints sobre una arquitectura limpia.

---

## 📝 Descripción

Implementar el scaffolding completo del backend usando FastAPI siguiendo los principios de Clean Architecture (DDD). Esta historia prepara la base para futuras implementaciones del motor RAG (HU-2.1, HU-2.2) y la integración con el frontend Flutter (HU-3.x).

**Alcance:**
- Configuración de Poetry como gestor de dependencias
- Estructura de carpetas siguiendo `PROJECT_STRUCTURE_MAP.md`
- Sistema de configuración tipada con Pydantic Settings
- Endpoints básicos de health check
- Sistema de manejo de errores custom
- Suite de tests con >80% cobertura
- Documentación bilingüe (EN + ES)

---

## ✅ Criterios de Aceptación

### Positivos (✅)

1. **Entorno Reproducible**
   - Ejecutar `poetry install` configura todo el entorno sin errores
   - `poetry.lock` generado correctamente

2. **Arquitectura Limpia**
   - La estructura de carpetas `src/server/` coincide exactamente con `PROJECT_STRUCTURE_MAP.md`
   - Test de arquitectura (`test_architecture.py`) pasa

3. **Configuración Tipada**
   - Variables de entorno se leen mediante Pydantic Settings
   - NO se usa `os.getenv()` en ningún lugar

4. **Calidad de Código**
   - Ruff (linter/formatter) está configurado
   - Ejecutar `ruff check .` devuelve 0 errores, 0 warnings

5. **API Saludable**
   - Endpoint `GET /api/v1/health` devuelve 200 OK
   - Respuesta incluye: status, app, version, environment, debug_mode

6. **Seguridad Base**
   - CORS configurado con lista blanca explícita (NO wildcard `*`)
   - No hay secrets hardcodeados en el código

7. **Manejo de Errores**
   - Sistema de errores custom según `ERROR_HANDLING_STANDARD.md`
   - Errores categorizados: SYS_XXX, API_XXX, RAG_XXX, DB_XXX

8. **Cobertura de Tests**
   - `pytest --cov` reporta >80% de cobertura
   - Tests unitarios, integración y arquitectura pasan

9. **Documentación Bilingüe**
   - `README.md` (EN) con guía de setup
   - `README.es.md` (ES) con traducción completa
   - Docstrings en inglés en todos los módulos públicos

### Negativos (❌)

1. **Linting Bloqueante**
   - Si se intenta hacer commit con código sin formatear, Ruff falla
   - Pre-commit hooks bloquean commits con errores de estilo

2. **Tests de Arquitectura**
   - Si falta alguna carpeta requerida, `test_architecture.py` falla
   - Si faltan `__init__.py`, el test de paquetes falla

3. **Seguridad**
   - Bandit reporta 0 vulnerabilidades críticas
   - Script de detección de secrets (`security-validation.sh`) pasa

---

## 🔗 Dependencias

### Bloqueantes (MUST)

- ✅ **HU-1.1:** Docker Infrastructure Setup (merged a `develop`)
- ✅ `infrastructure/docker-compose.yml` funcional
- ✅ `.env.example` existente y documentado

### Referencias (SHOULD READ)

- [`context/30-ARCHITECTURE/PROJECT_STRUCTURE_MAP.en.md`](../../../context/30-ARCHITECTURE/PROJECT_STRUCTURE_MAP.en.md)
- [`context/30-ARCHITECTURE/TECH_STACK_DETAILS.en.md`](../../../context/30-ARCHITECTURE/TECH_STACK_DETAILS.en.md)
- [`context/30-ARCHITECTURE/ERROR_HANDLING_STANDARD.en.md`](../../../context/30-ARCHITECTURE/ERROR_HANDLING_STANDARD.en.md)
- [`context/20-REQUIREMENTS_AND_SPEC/SECURITY_AND_PRIVACY_RULES.en.md`](../../../context/20-REQUIREMENTS_AND_SPEC/SECURITY_AND_PRIVACY_RULES.en.md)
- [`context/20-REQUIREMENTS_AND_SPEC/TESTING_STRATEGY.en.md`](../../../context/20-REQUIREMENTS_AND_SPEC/TESTING_STRATEGY.en.md)

---

## 🛠️ Tareas Técnicas

### Core Infrastructure

- [ ] Inicializar Poetry (`poetry init`)
- [ ] Instalar dependencias: FastAPI, Uvicorn, Pydantic Settings
- [ ] Crear estructura de carpetas (core, api, domain, services, utils)
- [ ] Configurar Pydantic Settings (`core/config.py`)
- [ ] Implementar sistema de errores custom (`core/errors.py`)

### API Layer

- [ ] Crear FastAPI app (`main.py`)
- [ ] Configurar CORS middleware con lista blanca
- [ ] Implementar endpoint `/api/v1/system/health`
- [ ] Implementar endpoint `/api/v1/system/health/detailed`
- [ ] Configurar OpenAPI schema (Swagger UI)

### Quality Assurance

- [ ] Configurar Ruff (linter + formatter)
- [ ] Configurar Pytest + pytest-cov
- [ ] Implementar test de arquitectura (`test_architecture.py`)
- [ ] Crear tests unitarios (config, errors)
- [ ] Crear tests de integración (API endpoints)
- [ ] Configurar pre-commit hooks (opcional)

### Security

- [ ] Configurar Bandit (security linter)
- [ ] Validar que no hay secrets en código
- [ ] Validar CORS con lista blanca
- [ ] Verificar que `.env` NO está en Git

### Documentation

- [ ] Crear `README.md` (EN) con setup guide
- [ ] Crear `README.es.md` (ES) con traducción
- [ ] Agregar docstrings en módulos públicos
- [ ] Actualizar `doc/INDEX.md` con HU-1.2

### Docker Integration

- [ ] Exportar `requirements.txt` desde Poetry
- [ ] Verificar que Docker levanta el backend
- [ ] Probar endpoints desde host

---

## 📂 Archivos del Tracking

- **[WORKFLOW.md](WORKFLOW.md)** - Guía paso a paso detallada (6 fases)
- **[PROGRESS.md](PROGRESS.md)** - Checklist de seguimiento de tareas
- **[ARTIFACTS.md](ARTIFACTS.md)** - Lista de artefactos a generar
- **README.md** - Este archivo (overview de la HU)

---

## 📊 Métricas Esperadas

- **Tiempo:** 1-2 días (5.5 horas efectivas)
- **Archivos creados:** ~15
- **Líneas de código:** ~850 (producción + tests)
- **Cobertura de tests:** >80% (target: 87%)
- **Complejidad ciclomática:** <10 (Ruff mccabe)

---

## 🔜 Próximos Pasos (Post-Merge)

1. **HU-2.1:** Implementar loader de Knowledge Base (Markdown → Chunks)
2. **HU-2.2:** Integrar ChromaDB y vectorización
3. **HU-3.1:** Conectar frontend Flutter con estos endpoints

---

**Última actualización:** 29/01/2026  
**Responsable:** Backend Dev  
**Rama:** `feature/backend-skeleton`
