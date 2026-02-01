# HU-2.2: RAG Vectorization

> **Última Actualización:** 31/01/2026 | **Estado:** 🔄 EN PROGRESO | **Versión:** v0.2.0

---

## 🌐 Language Selection | Selecciona tu idioma

| 🇬🇧 English | 🇪🇸 Español |
|-----------|----------|
| [→ English Documentation](#english) | [→ Documentación en Español](#español) |

---

<div id="english">

## 📖 English Documentation

### 🎯 Feature Overview

**User Story ID:** HU-2.2

**Title:** RAG Vectorization - ChromaDB Integration Engine

**Context:** The RAG system requires a robust vector storage engine that:
- Connects to ChromaDB for vector similarity search
- Ingests and stores document embeddings with metadata
- Provides deterministic ID generation for idempotency
- Handles connection failures gracefully with proper error codes

**Scope:**
- Initialize ChromaDB HTTP client connection
- Implement document ingestion with metadata cleaning
- Generate deterministic IDs using content hashing
- Ensure upsert idempotency for repeated executions
- Handle database connection and write errors

**Current Status:** 🔴 FASE 1/6 COMPLETED (TDD RED)
- ✅ Test suite created (11 tests, all failing as expected)
- ✅ Base exception system implemented
- 🔄 Ready for FASE 2: GREEN (implementation)

---

### ✅ Acceptance Criteria

| # | Criterion | Status |
|---|-----------|--------|
| 1 | `chroma_data` folder increases in size after ingestion | 🔄 PENDING |
| 2 | Test query returns correct Tech Pack fragments | 🔄 PENDING |
| 3 | Works offline using local embeddings | 🔄 PENDING |
| 4 | Throws `SYS_001` error when ChromaDB is down | ✅ IMPLEMENTED (tests written) |

---

### 🏗️ Technical Tasks

- ✅ Configure ChromaDB Python client (mocked tests)
- ❌ Implement `VectorStoreService`
- ❌ Create `ingest.py` script for manual execution

---

### 📊 Progress Tracking

**Phase 1/6:** 🔴 RED (Test Failing) - ✅ COMPLETED
- Comprehensive test suite created with 11 tests covering all scenarios
- All tests fail as expected (ModuleNotFoundError: VectorStoreService not implemented)
- Commit: "FASE 1: TDD - RED - Tests suite completa creada, todos fallan"

**Next Phase:** 🟢 GREEN (Implementation)
- Implement VectorStoreService to make all tests pass
- Connect to ChromaDB with proper error handling
- Ensure deterministic ID generation and metadata cleaning

---

### 🔗 Links & References

- [Test Suite](test_vector_store.py) - Complete TDD test suite
- [Base Exceptions](../core/exceptions/base.py) - Error handling system
- [FASE 1 Report](FASE_1_RED_COMPLETION_REPORT.md) - Detailed completion report
- [Progress Tracking](PROGRESS.md) - Phase-by-phase progress
- [Artifacts Manifest](ARTIFACTS.md) - File generation status

</div>

---

<div id="español">

## 📖 Documentación en Español

### 🎯 Resumen de la Feature

**ID de Historia de Usuario:** HU-2.2

**Título:** Vectorización RAG - Motor de Integración ChromaDB

**Contexto:** El sistema RAG requiere un motor robusto de almacenamiento vectorial que:
- Se conecte a ChromaDB para búsqueda de similitud vectorial
- Ingerir y almacenar embeddings de documentos con metadata
- Proporcione generación determinística de IDs para idempotencia
- Maneje fallos de conexión graceful con códigos de error apropiados

**Alcance:**
- Inicializar conexión de cliente HTTP ChromaDB
- Implementar ingestión de documentos con limpieza de metadata
- Generar IDs determinísticos usando hash de contenido
- Asegurar idempotencia de upsert para ejecuciones repetidas
- Manejar errores de conexión y escritura de base de datos

**Estado Actual:** 🔴 FASE 1/6 COMPLETADA (TDD RED)
- ✅ Suite de tests creada (11 tests, todos fallando como esperado)
- ✅ Sistema base de excepciones implementado
- 🔄 Listo para FASE 2: GREEN (implementación)

---

### ✅ Criterios de Verificación

| # | Criterio | Estado |
|---|----------|--------|
| 1 | La carpeta `chroma_data` aumenta de tamaño tras la ingesta | 🔄 PENDIENTE |
| 2 | Una consulta de prueba devuelve los fragmentos del Tech Pack correcto | 🔄 PENDIENTE |
| 3 | Funciona offline usando embeddings locales | 🔄 PENDIENTE |
| 4 | Lanza error `SYS_001` cuando ChromaDB está caído | ✅ IMPLEMENTADO (tests escritos) |

---

### 🏗️ Tareas Técnicas

- ✅ Configurar cliente ChromaDB en Python (tests mockeados)
- ❌ Implementar `VectorStoreService`
- ❌ Crear script `ingest.py` para ejecución manual

---

### 📊 Seguimiento de Progreso

**Fase 1/6:** 🔴 RED (Tests que Fallan) - ✅ COMPLETADA
- Suite completa de tests creada con 11 tests cubriendo todos los escenarios
- Todos los tests fallan como esperado (ModuleNotFoundError: VectorStoreService no implementado)
- Commit: "FASE 1: TDD - RED - Tests suite completa creada, todos fallan"

**Próxima Fase:** 🟢 GREEN (Implementación)
- Implementar VectorStoreService para que todos los tests pasen
- Conectar a ChromaDB con manejo apropiado de errores
- Asegurar generación determinística de IDs y limpieza de metadata

---

### 🔗 Enlaces y Referencias

- [Suite de Tests](test_vector_store.py) - Suite completa de tests TDD
- [Excepciones Base](../core/exceptions/base.py) - Sistema de manejo de errores
- [Reporte FASE 1](FASE_1_RED_COMPLETION_REPORT.md) - Reporte detallado de completación
- [Seguimiento de Progreso](PROGRESS.md) - Progreso fase por fase
- [Manifiesto de Artefactos](ARTIFACTS.md) - Estado de generación de archivos

</div>
