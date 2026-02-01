# HU-2.3: RAG Verification Tools

> **Fecha:** 01/02/2026
> **Estado:** ✅ READY FOR EXECUTION
> **Rama:** chore/rag-verification-tools
> **Issue Linear:** PIT-65

---

<div id="english">

## 🎯 User Story

**As a** Developer
**I want** inspection and persistence tools for ChromaDB visible on the host
**So that** I can validate that the RAG works before integrating the Frontend

### Context

The RAG (Retrieval-Augmented Generation) system needs verification tools that provide:
1. **Visibility:** Physical access to persisted vector data on the host filesystem
2. **Inspection:** CLI tools to query and inspect what ChromaDB remembers
3. **Integration Testing:** API endpoints to validate the complete retrieval pipeline

### Business Value

- Reduces debugging time when vector retrieval fails
- Provides confidence in RAG quality before Frontend integration
- Enables early detection of ingestion issues
- Facilitates end-to-end validation of Backend → RAG → Vector DB pipeline

---

## ✅ Acceptance Criteria

### Infrastructure
- ✅ **Criterion 1:** Folder `infrastructure/chroma_data` is visible on host and contains files after ingestion
- ✅ **Criterion 2:** Data persists after `docker compose down && docker compose up -d`
- ✅ **Criterion 3:** Directory has proper permissions (755) and is writable

### Inspection Tools
- ✅ **Criterion 4:** CLI script `inspect_db.py` returns readable text fragments from the database
- ✅ **Criterion 5:** Script supports multiple commands: `health`, `query`, `stats`
- ✅ **Criterion 6:** JSON output mode for scripting/automation

### API Integration
- ✅ **Criterion 7:** Temporary endpoint `POST /api/v1/rag/test/retrieval` returns JSON with context
- ✅ **Criterion 8:** Response includes matched documents with source metadata
- ✅ **Criterion 9:** Error handling prevents stack trace exposure

### Quality Standards
- ✅ **Criterion 10:** All code has 100% type hints (Pylance clean)
- ✅ **Criterion 11:** Test coverage >80% for all new modules
- ✅ **Criterion 12:** Full documentation with bilingual support

---

## 📚 Implementation Details

### Files Created (6 files)

1. **scripts/inspect_db.py** (186 lines)
   - Interactive CLI with Click framework
   - Commands: health, query, stats
   - Full type hints and error handling

2. **app/api/v1/endpoints/rag_test.py** (156 lines)
   - POST /rag/test/retrieval - retrieval endpoint
   - GET /rag/test/health - health check
   - Pydantic models with validation

3. **tests/integration/services/rag/test_chroma_mount.py** (12 lines)
   - Verify bind mount configuration

4. **tests/integration/services/rag/test_persistence.py** (30 lines)
   - Verify data persistence after ingestion

5. **tests/unit/scripts/test_inspect_db.py** (18 lines)
   - CLI command testing

6. **tests/unit/app/api/test_rag_endpoint.py** (60 lines)
   - Endpoint validation with mocks

### Files Modified (3 files)

1. **infrastructure/docker-compose.yml**
   - Add bind mount: `./chroma_data:/chroma/chroma`

2. **src/server/pyproject.toml**
   - Add dependency: `click>=8.1.0`

3. **src/server/app/api/v1/router.py**
   - Register rag_test router

### Key Architectural Decisions

| Decision | Rationale |
|----------|-----------|
| Bind mount in docker-compose | Enables host-side data inspection and debugging |
| Temporary endpoint (not production) | Reduces merge friction; cleanup tracked in separate issue |
| CLI + API dual approach | Supports both manual inspection and automated testing |
| Type hints on all functions | Ensures code quality and IDE support |
| Comprehensive tests | Validates entire pipeline from DB to API |

---

## 🚀 Execution Summary

The workflow consists of **6 phases**, each validated before proceeding:

| Phase | Duration | Goal |
|-------|----------|------|
| **FASE 0** | 5 min | Initialization and context |
| **FASE 1** | 10 min | Infrastructure setup (bind mount) |
| **FASE 2** | 5 min | Ingestion and data verification |
| **FASE 3** | 15 min | CLI tool implementation and testing |
| **FASE 4** | 15 min | API endpoint implementation |
| **FASE 5** | 10 min | Final validation and documentation |
| **TOTAL** | ~60 min | Complete end-to-end verification |

---

## 📖 Related Documentation

- **Workflow Guide:** See [WORKFLOW_MASTER_DEFINITION.md](./WORKFLOW_MASTER_DEFINITION.md)
- **Progress Tracker:** See [PROGRESS.md](./PROGRESS.md)
- **Artifacts Manifest:** See [ARTIFACTS.md](./ARTIFACTS.md)
- **Architecture Rules:** See [../../../AGENTS.md](../../../AGENTS.md)
- **Testing Strategy:** See [../../../context/20-REQUIREMENTS_AND_SPEC/TESTING_STRATEGY.en.md](../../../context/20-REQUIREMENTS_AND_SPEC/TESTING_STRATEGY.en.md)

</div>

---

<div id="español">

## 🎯 Historia de Usuario

**Como** Desarrollador
**Quiero** herramientas de inspección y persistencia visible en ChromaDB en el host
**Para** validar que el RAG funciona antes de integrar el Frontend

### Contexto

El sistema RAG (Generación Aumentada con Recuperación) necesita herramientas de verificación que proporcionen:
1. **Visibilidad:** Acceso físico a datos vectoriales persistentes en el filesystem del host
2. **Inspección:** Herramientas CLI para consultar e inspeccionar qué recuerda ChromaDB
3. **Testing de Integración:** Endpoints API para validar el pipeline completo de recuperación

### Valor de Negocio

- Reduce el tiempo de debugging cuando la recuperación vectorial falla
- Proporciona confianza en la calidad del RAG antes de integración con Frontend
- Permite detección temprana de problemas de ingesta
- Facilita validación end-to-end del pipeline Backend → RAG → Vector DB

---

## ✅ Criterios de Aceptación

### Infraestructura
- ✅ **Criterio 1:** La carpeta `infrastructure/chroma_data` es visible en host y contiene archivos tras ingesta
- ✅ **Criterio 2:** Los datos persisten tras `docker compose down && docker compose up -d`
- ✅ **Criterio 3:** El directorio tiene permisos correctos (755) y es escribible

### Herramientas de Inspección
- ✅ **Criterio 4:** Script CLI `inspect_db.py` devuelve fragmentos de texto legibles de la base de datos
- ✅ **Criterio 5:** El script soporta múltiples comandos: `health`, `query`, `stats`
- ✅ **Criterio 6:** Modo de salida JSON para scripting/automatización

### Integración API
- ✅ **Criterio 7:** Endpoint temporal `POST /api/v1/rag/test/retrieval` devuelve JSON con contexto
- ✅ **Criterio 8:** La respuesta incluye documentos coincidentes con metadata de origen
- ✅ **Criterio 9:** Manejo de errores previene exposición de stack traces

### Estándares de Calidad
- ✅ **Criterio 10:** Todo el código tiene 100% type hints (Pylance limpio)
- ✅ **Criterio 11:** Coverage de tests >80% para todos los nuevos módulos
- ✅ **Criterio 12:** Documentación completa con soporte bilingüe

---

## 📚 Detalles de Implementación

### Archivos Creados (6 archivos)

1. **scripts/inspect_db.py** (186 líneas)
   - CLI interactivo con framework Click
   - Comandos: health, query, stats
   - Type hints completos y manejo de errores

2. **app/api/v1/endpoints/rag_test.py** (156 líneas)
   - POST /rag/test/retrieval - endpoint de recuperación
   - GET /rag/test/health - chequeo de salud
   - Modelos Pydantic con validación

3. **tests/integration/services/rag/test_chroma_mount.py** (12 líneas)
   - Verificar configuración de bind mount

4. **tests/integration/services/rag/test_persistence.py** (30 líneas)
   - Verificar persistencia de datos tras ingesta

5. **tests/unit/scripts/test_inspect_db.py** (18 líneas)
   - Testing de comandos CLI

6. **tests/unit/app/api/test_rag_endpoint.py** (60 líneas)
   - Validación de endpoint con mocks

### Archivos Modificados (3 archivos)

1. **infrastructure/docker-compose.yml**
   - Agregar bind mount: `./chroma_data:/chroma/chroma`

2. **src/server/pyproject.toml**
   - Agregar dependencia: `click>=8.1.0`

3. **src/server/app/api/v1/router.py**
   - Registrar router rag_test

### Decisiones Arquitectónicas Clave

| Decisión | Justificación |
|----------|---------------|
| Bind mount en docker-compose | Habilita inspección de datos desde host y debugging |
| Endpoint temporal (no producción) | Reduce fricción en merge; cleanup rastreado en issue separada |
| Enfoque dual CLI + API | Soporta tanto inspección manual como testing automatizado |
| Type hints en todas las funciones | Asegura calidad de código y soporte IDE |
| Tests comprehensivos | Valida todo el pipeline desde DB hasta API |

---

## 🚀 Resumen de Ejecución

El workflow consiste en **6 fases**, cada una validada antes de proceder:

| Fase | Duración | Objetivo |
|------|----------|----------|
| **FASE 0** | 5 min | Inicialización y contexto |
| **FASE 1** | 10 min | Setup de infraestructura (bind mount) |
| **FASE 2** | 5 min | Ingesta y verificación de datos |
| **FASE 3** | 15 min | Implementación y testing de herramienta CLI |
| **FASE 4** | 15 min | Implementación de endpoint API |
| **FASE 5** | 10 min | Validación final y documentación |
| **TOTAL** | ~60 min | Verificación end-to-end completa |

---

## 📖 Documentación Relacionada

- **Guía de Workflow:** Ver [WORKFLOW_MASTER_DEFINITION.md](./WORKFLOW_MASTER_DEFINITION.md)
- **Tracker de Progreso:** Ver [PROGRESS.md](./PROGRESS.md)
- **Manifest de Artifacts:** Ver [ARTIFACTS.md](./ARTIFACTS.md)
- **Reglas de Arquitectura:** Ver [../../../AGENTS.md](../../../AGENTS.md)
- **Estrategia de Testing:** Ver [../../../context/20-REQUIREMENTS_AND_SPEC/TESTING_STRATEGY.es.md](../../../context/20-REQUIREMENTS_AND_SPEC/TESTING_STRATEGY.es.md)

</div>

---

**Última actualización:** 01/02/2026
