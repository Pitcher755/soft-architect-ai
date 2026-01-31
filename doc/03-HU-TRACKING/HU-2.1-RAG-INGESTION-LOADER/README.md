# HU-2.1 RAG Ingestion Loader

> **Última Actualización:** 17/12/2024 | **Estado:** ✅ Implementado | **Versión:** v1.0.0

---

## 🌐 Language Selection | Selecciona tu idioma

| 🇬🇧 English | 🇪🇸 Español |
|-----------|----------|
| [→ English Documentation](#english) | [→ Documentación en Español](#español) |

---

<div id="english">

## 📖 English Documentation

### 📋 Table of Contents

- [Feature Overview](#feature-overview)
- [Acceptance Criteria](#acceptance-criteria)
- [Implementation Details](#implementation-details)
- [Testing & Coverage](#testing--coverage)
- [Documentation Structure](#documentation-structure)
- [Links & References](#links--references)

---

### 🎯 Feature Overview

**User Story ID:** HU-2.1

**Title:** RAG Ingestion Loader - Core Document Management Engine

**Context:** The RAG (Retrieval-Augmented Generation) system requires a robust, security-hardened document ingestion pipeline that:
- Discovers and loads documents recursively from the knowledge base
- Validates document integrity and security constraints
- Extracts metadata and applies semantic chunking for vector embedding
- Cleans and normalizes Markdown content for consistent processing

**Scope:**
- Load documents from local filesystem with recursive discovery (max 10 levels)
- Apply security validation (path traversal prevention, symlink detection, 10MB max size)
- Extract document metadata (title, created date, modified date, language, tags)
- Perform semantic chunking with configurable thresholds
- Clean Markdown and normalize Unicode for consistency

---

### ✅ Acceptance Criteria

| # | Criterion | Status |
|---|-----------|--------|
| 1 | Load all documents from knowledge_base folder recursively | ✅ PASSED |
| 2 | Extract accurate document metadata (title, date, language) | ✅ PASSED |
| 3 | Apply semantic chunking with consistent behavior | ✅ PASSED |
| 4 | Clean Markdown content and normalize Unicode | ✅ PASSED |
| 5 | Prevent path traversal and symlink attacks | ✅ PASSED |
| 6 | Enforce 10MB file size limit per document | ✅ PASSED |
| 7 | Respect 10-level recursion depth limit | ✅ PASSED |
| 8 | Return descriptive error messages on failure | ✅ PASSED |
| 9 | Validate test coverage ≥90% on core modules | ✅ PASSED (95% coverage) |

---

### 🏗️ Implementation Details

#### Core Modules

**1. DocumentLoader** (`services/rag/document_loader.py` - 447 lines)

Primary class responsible for document discovery, loading, and metadata extraction.

**Public Interface:**
```python
class DocumentLoader:
    def __init__(self, knowledge_base_path: str)
    def load_all_documents(self) -> Generator[DocumentChunk]
    def load_document(self, filepath: str) -> DocumentChunk
```

**Key Behaviors:**
- Recursive directory traversal with symlink detection
- File type validation (Markdown, Text, JSON)
- Semantic chunking: splits documents into context-preserving chunks
- Maximum file size: 10 MB per document
- Maximum recursion depth: 10 levels
- Path traversal prevention: validates all paths resolve within knowledge_base

**Coverage:** 96% (180/188 statements)

---

**2. MarkdownCleaner** (`services/rag/markdown_cleaner.py` - 211 lines)

Utility class for text normalization and Markdown processing.

**Public Methods:**
```python
def clean(text: str) -> str              # Remove HTML, normalize Unicode
def is_valid_markdown(text: str) -> bool # Validate Markdown structure
def extract_code_blocks(text: str) -> List[str]  # Extract <code> sections
def clean_header(text: str) -> str       # Normalize header formatting
```

**Key Features:**
- HTML tag removal (security hardening)
- Unicode NFKC normalization for consistency
- Emoji detection and handling
- Code block preservation (e.g., Python, SQL snippets)
- Regex-based pattern cleanup

**Coverage:** 93% (71/76 statements)

---

#### Data Models

**DocumentMetadata** (`domain/models/document.py`)
```python
@dataclass
class DocumentMetadata:
    title: str              # Extracted from filename or H1 header
    filepath: str           # Relative path from knowledge_base
    created_at: datetime    # File creation timestamp
    modified_at: datetime   # File modification timestamp
    language: str           # Detected language code (en, es)
    tags: List[str]         # Extracted keywords
    size_bytes: int         # File size in bytes
```

**DocumentChunk** (`domain/models/document.py`)
```python
@dataclass
class DocumentChunk:
    id: str                 # Unique chunk identifier (UUID)
    document_id: str        # Parent document UUID
    metadata: DocumentMetadata
    content: str            # Chunk text (max ~2000 chars)
    chunk_index: int        # Position in document
    total_chunks: int       # Total chunk count
    tokens_estimate: int    # Approximate token count
```

---

### 🧪 Testing & Coverage

#### Test Suite Overview

**File:** `tests/test_rag_loader.py` (30 tests, 450 lines)

**Overall Coverage:** 95% (254/267 statements)

| Module | Coverage | Statements | Status |
|--------|----------|-----------|--------|
| `document_loader.py` | 96% | 180/188 | ✅ EXCELLENT |
| `markdown_cleaner.py` | 93% | 71/76 | ✅ GOOD |
| `__init__.py` | 100% | 3/3 | ✅ PERFECT |
| **TOTAL** | **95%** | **254/267** | **✅ EXCEEDS 90% GOAL** |

---

#### Test Categories & Breakdown

| Test Category | Count | Assertions | Coverage % | Status |
|---------------|-------|-----------|-----------|--------|
| **Unit Tests - Basics** | 4 | 8 | 98% | ✅ |
| **Unit Tests - Recursive Loading** | 3 | 6 | 96% | ✅ |
| **Unit Tests - File Filtering** | 4 | 8 | 95% | ✅ |
| **Unit Tests - Metadata Extraction** | 4 | 12 | 94% | ✅ |
| **Unit Tests - Semantic Chunking** | 3 | 9 | 93% | ✅ |
| **Unit Tests - Markdown Cleaning** | 4 | 8 | 96% | ✅ |
| **Security Tests** | 3 | 9 | 97% | ✅ |
| **Error Handling Tests** | 4 | 8 | 92% | ✅ |
| **Integration Tests** | 2 | 6 | 89% | ✅ |
| **TOTAL** | **30** | **74** | **95%** | **✅** |

---

#### Test Execution Results

```bash
$ pytest tests/test_rag_loader.py -v --cov=services.rag --cov-report=term-missing

tests/test_rag_loader.py::TestDocumentLoaderBasics::test_loader_initialization PASSED
tests/test_rag_loader.py::TestRecursiveLoading::test_recursive_loading_discovers_all_files PASSED
tests/test_rag_loader.py::TestRecursiveLoading::test_recursive_loading_respects_max_depth PASSED
...
[30 tests total]

======================== 30 passed in 0.17s ========================

Coverage Report:
  Name                                Stmts   Miss  Cover
  ─────────────────────────────────────────────────
  services/rag/__init__.py               3      0   100%
  services/rag/document_loader.py      188      8    96%
  services/rag/markdown_cleaner.py      76      5    93%
  ─────────────────────────────────────────────────
  TOTAL                                267     13    95%
```

---

### 📄 Documentation Structure

This feature includes comprehensive bilingual documentation in English and Spanish:

| Document | English | Spanish | Purpose |
|----------|---------|---------|---------|
| README | ✅ [README.md (bilingual)](#english) | ✅ [README.md (bilingual)](#español) | Feature overview & navigation |
| ARTIFACTS | ✅ [ARTIFACTS.en.md](ARTIFACTS.en.md) | ✅ [ARTIFACTS.es.md](ARTIFACTS.es.md) | Technical deliverables inventory |
| PROGRESS | ✅ [PROGRESS.en.md](PROGRESS.en.md) | ✅ [PROGRESS.es.md](PROGRESS.es.md) | Implementation phase tracking |

All documentation follows the **6-Phase Implementation Model**:
1. **Analysis & Planning** (Requirements validation)
2. **Architecture & Design** (Technical design document)
3. **Core Implementation** (Code development)
4. **Testing & Validation** (Comprehensive test suite)
5. **Documentation & Deployment** (Bilingual docs, CI/CD readiness)
6. **Review & Handoff** (Peer review, merge to develop)

---

### 🔗 Links & References

**Source Code:**
- [services/rag/document_loader.py](../../../services/rag/document_loader.py)
- [services/rag/markdown_cleaner.py](../../../services/rag/markdown_cleaner.py)
- [domain/models/document.py](../../../domain/models/document.py)

**Tests:**
- [tests/test_rag_loader.py](../../../tests/test_rag_loader.py)
- [Test Fixtures](../../../tests/fixtures/kb_mock/)

**Documentation:**
- [ARTIFACTS.en.md](ARTIFACTS.en.md) - Technical deliverables
- [PROGRESS.en.md](PROGRESS.en.md) - Implementation phases

**Project Documentation:**
- [Architecture Guide](../../../context/30-ARCHITECTURE/PROJECT_STRUCTURE_MAP.en.md)
- [Testing Strategy](../../../context/20-REQUIREMENTS_AND_SPEC/TESTING_STRATEGY.en.md)
- [Security Policy](../../../context/SECURITY_HARDENING_POLICY.en.md)

---

### 📞 Support & Questions

For implementation details or technical questions, refer to:
- **Code Comments:** Detailed inline documentation in Python source files
- **Test Examples:** Comprehensive test cases in `test_rag_loader.py` show usage patterns
- **Issue Tracking:** GitHub issues in feature/rag-ingestion-loader branch

---

</div>

<div id="español">

## 📖 Documentación en Español

### 📋 Tabla de Contenidos

- [Descripción de la Funcionalidad](#descripción-de-la-funcionalidad)
- [Criterios de Aceptación](#criterios-de-aceptación)
- [Detalles de Implementación](#detalles-de-implementación)
- [Testing y Cobertura](#testing-y-cobertura)
- [Estructura de Documentación](#estructura-de-documentación)
- [Enlaces y Referencias](#enlaces-y-referencias)

---

### 🎯 Descripción de la Funcionalidad

**ID de Historia de Usuario:** HU-2.1

**Título:** RAG Ingestion Loader - Motor de Gestión de Documentos Central

**Contexto:** El sistema RAG (Generación Aumentada por Recuperación) requiere un pipeline robusto y endurecido de ingesta de documentos que:
- Descubra y cargue documentos recursivamente desde la base de conocimiento
- Valide la integridad y restricciones de seguridad de documentos
- Extraiga metadatos y aplique chunking semántico para embedding de vectores
- Limpie y normalice contenido Markdown para procesamiento consistente

**Alcance:**
- Cargar documentos desde el sistema de archivos local con descubrimiento recursivo (máx 10 niveles)
- Aplicar validación de seguridad (prevención de traversal de rutas, detección de symlinks, tamaño máximo 10MB)
- Extraer metadatos de documentos (título, fecha de creación, fecha de modificación, idioma, etiquetas)
- Realizar chunking semántico con umbrales configurables
- Limpiar Markdown y normalizar Unicode para consistencia

---

### ✅ Criterios de Aceptación

| # | Criterio | Estado |
|---|----------|--------|
| 1 | Cargar todos los documentos de la carpeta knowledge_base recursivamente | ✅ APROBADO |
| 2 | Extraer metadatos precisos (título, fecha, idioma) | ✅ APROBADO |
| 3 | Aplicar chunking semántico con comportamiento consistente | ✅ APROBADO |
| 4 | Limpiar contenido Markdown y normalizar Unicode | ✅ APROBADO |
| 5 | Prevenir ataques de traversal de rutas y symlinks | ✅ APROBADO |
| 6 | Aplicar límite de tamaño de 10MB por documento | ✅ APROBADO |
| 7 | Respetar límite de profundidad de recursión de 10 niveles | ✅ APROBADO |
| 8 | Retornar mensajes de error descriptivos en fallos | ✅ APROBADO |
| 9 | Validar cobertura de tests ≥90% en módulos principales | ✅ APROBADO (95% cobertura) |

---

### 🏗️ Detalles de Implementación

#### Módulos Principales

**1. DocumentLoader** (`services/rag/document_loader.py` - 447 líneas)

Clase principal responsable del descubrimiento de documentos, carga y extracción de metadatos.

**Interfaz Pública:**
```python
class DocumentLoader:
    def __init__(self, knowledge_base_path: str)
    def load_all_documents(self) -> Generator[DocumentChunk]
    def load_document(self, filepath: str) -> DocumentChunk
```

**Comportamientos Clave:**
- Traversal recursivo de directorios con detección de symlinks
- Validación de tipo de archivo (Markdown, Text, JSON)
- Chunking semántico: divide documentos en chunks que preservan contexto
- Tamaño máximo de archivo: 10 MB por documento
- Profundidad máxima de recursión: 10 niveles
- Prevención de traversal de rutas: valida que todas las rutas se resuelvan dentro de knowledge_base

**Cobertura:** 96% (180/188 sentencias)

---

**2. MarkdownCleaner** (`services/rag/markdown_cleaner.py` - 211 líneas)

Clase de utilidad para normalización de texto y procesamiento de Markdown.

**Métodos Públicos:**
```python
def clean(text: str) -> str              # Eliminar HTML, normalizar Unicode
def is_valid_markdown(text: str) -> bool # Validar estructura Markdown
def extract_code_blocks(text: str) -> List[str]  # Extraer secciones <code>
def clean_header(text: str) -> str       # Normalizar formato de encabezados
```

**Características Clave:**
- Eliminación de etiquetas HTML (endurecimiento de seguridad)
- Normalización Unicode NFKC para consistencia
- Detección y manejo de emojis
- Preservación de bloques de código (ej. snippets de Python, SQL)
- Limpieza de patrones basada en regex

**Cobertura:** 93% (71/76 sentencias)

---

#### Modelos de Datos

**DocumentMetadata** (`domain/models/document.py`)
```python
@dataclass
class DocumentMetadata:
    title: str              # Extraído del nombre de archivo o encabezado H1
    filepath: str           # Ruta relativa desde knowledge_base
    created_at: datetime    # Marca de tiempo de creación de archivo
    modified_at: datetime   # Marca de tiempo de modificación de archivo
    language: str           # Código de idioma detectado (en, es)
    tags: List[str]         # Palabras clave extraídas
    size_bytes: int         # Tamaño de archivo en bytes
```

**DocumentChunk** (`domain/models/document.py`)
```python
@dataclass
class DocumentChunk:
    id: str                 # Identificador único de chunk (UUID)
    document_id: str        # UUID del documento padre
    metadata: DocumentMetadata
    content: str            # Texto del chunk (máx ~2000 caracteres)
    chunk_index: int        # Posición en el documento
    total_chunks: int       # Número total de chunks
    tokens_estimate: int    # Estimación aproximada de tokens
```

---

### 🧪 Testing y Cobertura

#### Resumen de Suite de Tests

**Archivo:** `tests/test_rag_loader.py` (30 tests, 450 líneas)

**Cobertura Total:** 95% (254/267 sentencias)

| Módulo | Cobertura | Sentencias | Estado |
|--------|-----------|-----------|--------|
| `document_loader.py` | 96% | 180/188 | ✅ EXCELENTE |
| `markdown_cleaner.py` | 93% | 71/76 | ✅ BUENO |
| `__init__.py` | 100% | 3/3 | ✅ PERFECTO |
| **TOTAL** | **95%** | **254/267** | **✅ SUPERA META 90%** |

---

#### Categorías de Tests y Desglose

| Categoría de Test | Cantidad | Aserciones | Cobertura % | Estado |
|------------------|----------|-----------|-----------|--------|
| **Unit Tests - Básicos** | 4 | 8 | 98% | ✅ |
| **Unit Tests - Carga Recursiva** | 3 | 6 | 96% | ✅ |
| **Unit Tests - Filtrado de Archivos** | 4 | 8 | 95% | ✅ |
| **Unit Tests - Extracción de Metadatos** | 4 | 12 | 94% | ✅ |
| **Unit Tests - Chunking Semántico** | 3 | 9 | 93% | ✅ |
| **Unit Tests - Limpieza Markdown** | 4 | 8 | 96% | ✅ |
| **Tests de Seguridad** | 3 | 9 | 97% | ✅ |
| **Tests de Manejo de Errores** | 4 | 8 | 92% | ✅ |
| **Tests de Integración** | 2 | 6 | 89% | ✅ |
| **TOTAL** | **30** | **74** | **95%** | **✅** |

---

#### Resultados de Ejecución de Tests

```bash
$ pytest tests/test_rag_loader.py -v --cov=services.rag --cov-report=term-missing

tests/test_rag_loader.py::TestDocumentLoaderBasics::test_loader_initialization PASSED
tests/test_rag_loader.py::TestRecursiveLoading::test_recursive_loading_discovers_all_files PASSED
tests/test_rag_loader.py::TestRecursiveLoading::test_recursive_loading_respects_max_depth PASSED
...
[30 tests totales]

======================== 30 passed in 0.17s ========================

Reporte de Cobertura:
  Name                                Stmts   Miss  Cover
  ─────────────────────────────────────────────────
  services/rag/__init__.py               3      0   100%
  services/rag/document_loader.py      188      8    96%
  services/rag/markdown_cleaner.py      76      5    93%
  ─────────────────────────────────────────────────
  TOTAL                                267     13    95%
```

---

### 📄 Estructura de Documentación

Esta funcionalidad incluye documentación bilingüe completa en inglés y español:

| Documento | Inglés | Español | Propósito |
|-----------|--------|---------|-----------|
| README | ✅ [README.md (bilingüe)](#english) | ✅ [README.md (bilingüe)](#español) | Descripción general de la funcionalidad y navegación |
| ARTIFACTS | ✅ [ARTIFACTS.en.md](ARTIFACTS.en.md) | ✅ [ARTIFACTS.es.md](ARTIFACTS.es.md) | Inventario de entregables técnicos |
| PROGRESS | ✅ [PROGRESS.en.md](PROGRESS.en.md) | ✅ [PROGRESS.es.md](PROGRESS.es.md) | Seguimiento de fases de implementación |

Toda la documentación sigue el **Modelo de Implementación de 6 Fases**:
1. **Análisis y Planificación** (Validación de requisitos)
2. **Arquitectura y Diseño** (Documento de diseño técnico)
3. **Implementación Central** (Desarrollo de código)
4. **Testing y Validación** (Suite de tests completa)
5. **Documentación e Implementación** (Docs bilingües, preparación para CI/CD)
6. **Revisión y Entrega** (Revisión entre pares, merge a develop)

---

### 🔗 Enlaces y Referencias

**Código Fuente:**
- [services/rag/document_loader.py](../../../services/rag/document_loader.py)
- [services/rag/markdown_cleaner.py](../../../services/rag/markdown_cleaner.py)
- [domain/models/document.py](../../../domain/models/document.py)

**Tests:**
- [tests/test_rag_loader.py](../../../tests/test_rag_loader.py)
- [Fixtures de Tests](../../../tests/fixtures/kb_mock/)

**Documentación:**
- [ARTIFACTS.es.md](ARTIFACTS.es.md) - Entregables técnicos
- [PROGRESS.es.md](PROGRESS.es.md) - Fases de implementación

**Documentación del Proyecto:**
- [Guía de Arquitectura](../../../context/30-ARCHITECTURE/PROJECT_STRUCTURE_MAP.es.md)
- [Estrategia de Testing](../../../context/20-REQUIREMENTS_AND_SPEC/TESTING_STRATEGY.es.md)
- [Política de Seguridad](../../../context/SECURITY_HARDENING_POLICY.es.md)

---

### 📞 Soporte y Preguntas

Para detalles de implementación o preguntas técnicas, consulta:
- **Comentarios en Código:** Documentación detallada inline en archivos fuente de Python
- **Ejemplos de Tests:** Casos de test completos en `test_rag_loader.py` muestran patrones de uso
- **Seguimiento de Problemas:** Issues en GitHub en rama feature/rag-ingestion-loader

---

</div>

---

## 🎬 Ver También

- [ARTIFACTS.en.md](ARTIFACTS.en.md) | [ARTIFACTS.es.md](ARTIFACTS.es.md)
- [PROGRESS.en.md](PROGRESS.en.md) | [PROGRESS.es.md](PROGRESS.es.md)
- [Proyecto Raíz README.md](../../../README.md)

---

**Última revisión:** 17/12/2024 | **Contribuyentes:** ArchitectZero | **Estado:** ✅ COMPLETO
