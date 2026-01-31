# 🧠 RAG Services - Vector Store & Embeddings Management

## Descripción General

Este módulo implementa la capa de persistencia vectorial para el RAG (Retrieval-Augmented Generation) de SoftArchitect AI, completando la **HU-2.2: RAG Vectorization**.

### Responsabilidades Principales

1. **Conectar a ChromaDB (HTTP)** - Persistencia vectorial local
2. **Transformar documentos** - LangChain Document → Formato Chroma
3. **Generar IDs deterministas** - Idempotencia mediante hashing MD5
4. **Manejo de errores controlado** - Códigos SYS_001, DB_WRITE_ERR, DB_READ_ERR

---

## 📁 Estructura del Módulo

```
services/rag/
├── __init__.py              # Exports VectorStoreService
├── vector_store.py          # ⭐ Implementación principal (312 líneas)
└── README.md                # Este archivo
```

---

## 🎯 Características Principales

### 1. **Idempotencia Garantizada**
- IDs deterministas basados en hash MD5 del contenido
- ChromaDB `upsert` semantics: actualiza si existe, inserta si no

### 2. **Retry Logic con Backoff Exponencial**
- `@retry_with_backoff(max_retries=3, base_delay=1.0)` decorator
- Resilencia automática ante fallos transitorios

### 3. **Limpieza de Metadatos**
- ChromaDB solo soporta: `str`, `int`, `float`, `bool`
- Filtra tipos complejos (list, dict, None)

### 4. **Error Handling Estructurado**
- `ConnectionError` (SYS_001) - Fallo de conexión
- `DatabaseWriteError` (DB_WRITE_ERR) - Fallos en upsert
- `DatabaseReadError` (DB_READ_ERR) - Fallos en query

---

## 🚀 Uso Rápido

```python
from services.rag.vector_store import VectorStoreService
from langchain_core.documents import Document

# Conectar
service = VectorStoreService(host="localhost", port=8000)

# Ingestar
docs = [Document(page_content="...", metadata={"source": "..."})]
count = service.ingest(docs)

# Query
results = service.query("buscar algo", n_results=5)

# Health
health = service.health_check()
```

---

## 🧪 Testing

### Tests Unitarios (15 tests)
```bash
cd src/server
pytest tests/unit/services/rag/test_vector_store.py -v
# ✅ 15/15 PASSED
```

### Tests E2E (Requiere Docker)
```bash
export CHROMA_HOST=localhost CHROMA_PORT=8000
pytest tests/integration/services/rag/test_vector_store_e2e.py -v
```

---

## 📊 Script de Ingesta

```bash
# Ingestar documentos
python src/server/scripts/ingest.py

# Dry-run
python src/server/scripts/ingest.py --dry-run

# Con opciones
python src/server/scripts/ingest.py --host chromadb --port 8000
```

---

## ✅ Criterios de Aceptación

### Positivos (Must Have)
- [x] Documentos se almacenan en ChromaDB
- [x] Metadatos (source, filename, header) preservados
- [x] IDs deterministas → idempotencia garantizada
- [x] Query devuelve resultados con similaridad
- [x] Funciona offline
- [x] Tests unitarios 100% pasando
- [x] Coverage >80%

### Negativos (Must NOT)
- [x] NO se duplican documentos
- [x] NO explota si ChromaDB falla → SYS_001
- [x] NO llama a APIs externas
- [x] NO compromete privacidad (100% local)

---

**Última Actualización:** 31/01/2026
**Estado:** ✅ COMPLETADO (HU-2.2 Fases 0-6)
