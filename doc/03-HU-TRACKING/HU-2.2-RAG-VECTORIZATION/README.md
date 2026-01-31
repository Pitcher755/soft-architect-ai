# HU-2.2: RAG Vectorization

**Estado:** ❌ PENDIENTE
**Prioridad:** Critical
**Estimación:** L (Large)
**Branch:** feature/rag-vectorization

## Descripción

Como Sistema, quiero vectorizar el contenido y guardarlo en ChromaDB, para poder recuperarlo semánticamente.

## Criterios de Verificación

- ❌ La carpeta `chroma_data` aumenta de tamaño tras la ingesta.
- ❌ Una consulta de prueba devuelve los fragmentos del Tech Pack correcto.
- ❌ Funciona offline usando embeddings locales.
- ❌ Si ChromaDB está caído, el sistema lanza el error `SYS_001` (ConnectionRefused) controlado.

## Tareas Técnicas

- ❌ Configurar cliente ChromaDB en Python.
- ❌ Implementar `VectorStoreService`.
- ❌ Crear script `ingest.py` para ejecución manual.
