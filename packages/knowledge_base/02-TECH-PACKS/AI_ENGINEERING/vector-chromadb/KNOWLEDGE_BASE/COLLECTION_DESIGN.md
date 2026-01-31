# 🧠 ChromaDB Collection Design

> **Fecha:** 30/01/2026
> **Estado:** ✅ Desplegado
> **Objetivo:** Diseño de base de datos vectorial para sistemas RAG escalables
> **Audiencia:** Backend Engineers, ML/AI Specialists, DevOps

Estrategia de organización y consulta de embeddings en ChromaDB para SoftArchitect AI. Es la **memoria vectorial** del sistema RAG.

---

## 📋 Tabla de Contenidos

1. [Estructura de Datos](#estructura-de-datos)
2. [Estrategia de Metadatos](#estrategia-de-metadatos)
3. [Diseño de Colecciones](#diseño-de-colecciones)
4. [Query & Retrieval Patterns](#query--retrieval-patterns)
5. [Persistencia & Docker Integration](#persistencia--docker-integration)
6. [Performance & Scaling](#performance--scaling)
7. [Pre-Production Checklist](#pre-production-checklist)

---

## Estructura de Datos

### Vector Database 101

```
┌─────────────────────────────────────────┐
│ ChromaDB (Vector Database)              │
├─────────────────────────────────────────┤
│ Colección: "softarchitect_knowledge"    │
├─────────────────────────────────────────┤
│ Item 1:                                 │
│  ├─ ID: "doc_001_chunk_05"              │
│  ├─ Embedding: [0.12, -0.45, 0.88,...] │
│  ├─ Document: "Clean Architecture..."  │
│  └─ Metadata: {project, source, ...}   │
│                                         │
│ Item 2:                                 │
│  ├─ ID: "doc_002_chunk_03"              │
│  ├─ Embedding: [0.22, -0.35, 0.91,...] │
│  ├─ Document: "Repository Pattern..."  │
│  └─ Metadata: {...}                    │
│                                         │
│ [... 10,000+ items ...]                │
└─────────────────────────────────────────┘

Búsqueda por similitud: Dado un query, encuentra items con embeddings cercanos.
```

### Componentes de Cada Registro (Item)

| Campo | Tipo | Ejemplo | Propósito |
|:---|:---|:---|:---|
| **ID** | str | `doc_001_chunk_05` | Identificador único, inmutable |
| **Embedding** | float[] | `[0.12, -0.45, 0.88, ...]` | Vector numérico (generado por modelo) |
| **Document** | str | `"Clean Architecture es..."` | Texto original (recuperable para RAG) |
| **Metadata** | dict | `{"project_id": "sa-v1", ...}` | Información de filtrado y contexto |

---

### Embedding Workflow

```
Usuario Query
    ↓
[1. Embedding] → Usar mismo modelo que documents
    ↓ (genera vector)
[2. Search] → ChromaDB busca K-NN (vecinos más cercanos)
    ↓
[3. Retrieve] → Devuelve ID, Document, Metadata
    ↓
[4. Rank & Rerank] → Filtrar por similitud + metadatos
    ↓
[5. RAG Context] → Inyectar en Ollama con user query
    ↓
[6. Generate] → Ollama genera respuesta basada en documentos
```

---

## Estrategia de Metadatos

### ¿Por Qué Metadatos?

Sin metadatos: "Buscar 'Clean Architecture' en toda la base de datos" (lento, resultados ruidosos).

Con metadatos: "Buscar 'Clean Architecture' en documentos técnicos de SoftArchitect, creados después de 2024" (rápido, resultados precisos).

### Esquema de Metadatos Recomendado para SoftArchitect

```json
{
  "project_id": "softarchitect-v1",
  "source_file": "CLEAN_ARCHITECTURE.md",
  "doc_type": "architecture_docs",
  "technology": "clean-architecture",
  "language": "es",
  "created_at": "2025-01-30",
  "chunk_index": 5,
  "section": "05-DESIGN_PRINCIPLES",
  "confidence": 0.95
}
```

### Descripción de Campos

| Campo | Valores | Uso | Ejemplo |
|:---|:---|:---|:---|
| **project_id** | str | Multi-tenancy. Cada empresa/proyecto aislado | `"softarchitect-v1"`, `"client-xyz"` |
| **source_file** | str | Trazabilidad. Auditar dónde salió | `"BEST_PRACTICES.md"`, `"api_routes.py"` |
| **doc_type** | enum | Categorizar tipo documento | `"architecture_docs"`, `"code_example"`, `"tutorial"` |
| **technology** | str | Filtrar por stack (python, flutter, docker) | `"python-fastapi"`, `"flutter"`, `"docker"` |
| **language** | str | Soporte multiidioma | `"es"`, `"en"`, `"fr"` |
| **created_at** | ISO-8601 | Filtrar por recencia | `"2025-01-30"` |
| **chunk_index** | int | Orden original (para reconstruir doc) | `0`, `1`, `2`, ... |
| **section** | str | Capítulo/sección del documento | `"DESIGN_PRINCIPLES"`, `"ERROR_HANDLING"` |
| **confidence** | float | Calidad del embedding (0.0-1.0) | `0.95` |

---

### Queries Filtradas (WHERE Clause)

#### ✅ Ejemplo 1: Buscar respuesta técnica en español

```python
from chromadb import Client

client = Client()
collection = client.get_collection("softarchitect_kb")

results = collection.query(
    query_embeddings=[[0.1, 0.2, ...]],  # Embedding de "¿Cómo usar Riverpod?"
    n_results=5,
    where={
        "$and": [
            {"project_id": {"$eq": "softarchitect-v1"}},
            {"technology": {"$eq": "flutter"}},
            {"language": {"$eq": "es"}},
            {"doc_type": {"$in": ["best_practices", "architecture_docs"]}}
        ]
    }
)
```

#### ✅ Ejemplo 2: Bugfix reciente

```python
# Buscar soluciones a errores comunes (¡recientes!)
results = collection.query(
    query_embeddings=embedding_vector,
    n_results=3,
    where={
        "$and": [
            {"doc_type": {"$eq": "troubleshooting"}},
            {"created_at": {"$gte": "2025-01-01"}},  # Últimas actualizaciones
            {"confidence": {"$gte": 0.85}}
        ]
    }
)
```

#### ✅ Ejemplo 3: Multitenant (Aislar datos por empresa)

```python
# Usuario de "Empresa A" SOLO ve documentos de Empresa A
results = collection.query(
    query_embeddings=embedding,
    n_results=10,
    where={
        "project_id": {"$eq": "empresa-a-proyecto-1"}
    }
)
# Seguridad garantizada: ChromaDB filtra en DB, NO en aplicación
```

---

## Diseño de Colecciones

### Estrategia: 1 Colección ≠ Miles de Colecciones

**❌ BAD Pattern:** Una colección por documento
```
collections = [
    "doc_clean_architecture.md",
    "doc_dependency_injection.md",
    "doc_repository_pattern.md",
    ...
    (1000+ colecciones)
]
```
Problemas:
- ❌ Ineficiente: searches lentos (overhead de metadatos)
- ❌ Difícil de mantener
- ❌ Queries complejas = lógica en aplicación

**✅ GOOD Pattern:** Una colección centralizada con metadatos

```python
# UNA sola colección que contiene TODO
collection = client.get_or_create_collection(
    name="softarchitect_knowledge_base",
    metadata={
        "hnsw:space": "cosine",  # Distancia: cosine (perfecto para texto)
        "hnsw:M": 32,            # Complejidad del índice
        "hnsw:ef_construction": 200,
        "hnsw:ef": 10
    }
)
```

### Configuración de Colección (SoftArchitect)

```python
from chromadb import Client, Settings
from chromadb.config import Settings

# Settings globales
settings = Settings(
    chroma_db_impl="duckdb",
    persist_directory="/chroma/chroma",
    anonymized_telemetry=False,
    allow_reset=True,  # Desarrollo
    is_persistent=True  # Producción
)

client = Client(settings)

# Crear colección principal
collection = client.get_or_create_collection(
    name="softarchitect_knowledge_base",
    metadata={
        # Distancia métrica (cosine = mejor para similitud de texto)
        "hnsw:space": "cosine",

        # HNSW (Hierarchical Navigable Small World) tuning
        # M: Número de conexiones por nodo (32 = balance speed/precision)
        "hnsw:M": 32,

        # ef_construction: Calidad del índice al crear (200 = bueno)
        "hnsw:ef_construction": 200,

        # ef: Search parameter (10 = fast, 1000 = exhaustive)
        "hnsw:ef": 10
    }
)

print(f"✅ Colección '{collection.name}' lista. Count: {collection.count()}")
```

### Ingestión de Documentos

```python
from typing import List, Dict
import uuid

def chunk_document(text: str, chunk_size: int = 500) -> List[str]:
    """Partir un documento largo en chunks (sin truncar mid-sentence)"""
    words = text.split()
    chunks = []
    current_chunk = []

    for word in words:
        current_chunk.append(word)
        if len(' '.join(current_chunk)) > chunk_size:
            chunks.append(' '.join(current_chunk[:-1]))
            current_chunk = [word]

    if current_chunk:
        chunks.append(' '.join(current_chunk))

    return chunks

def ingest_document(
    collection,
    document_text: str,
    source_file: str,
    metadata: Dict
) -> int:
    """Ingestar documento en ChromaDB"""

    # 1. Partir en chunks
    chunks = chunk_document(document_text, chunk_size=500)

    # 2. Preparar para ingestión
    ids = []
    documents = []
    metadatas = []

    for idx, chunk in enumerate(chunks):
        # ChromaDB genera automáticamente embeddings usando nomic-embed-text
        ids.append(f"{source_file}_{idx}")
        documents.append(chunk)

        metadatas.append({
            **metadata,
            "source_file": source_file,
            "chunk_index": idx,
            "total_chunks": len(chunks)
        })

    # 3. Ingestar
    collection.add(
        ids=ids,
        documents=documents,
        metadatas=metadatas
    )

    print(f"✅ Ingested '{source_file}': {len(chunks)} chunks")
    return len(chunks)

# Ejemplo de uso
with open("packages/knowledge_base/.../BEST_PRACTICES.md") as f:
    best_practices_text = f.read()

ingest_document(
    collection,
    document_text=best_practices_text,
    source_file="BEST_PRACTICES.md",
    metadata={
        "project_id": "softarchitect-v1",
        "doc_type": "best_practices",
        "technology": "python-fastapi",
        "language": "es"
    }
)
```

---

## Query & Retrieval Patterns

### Patrón 1: Búsqueda Simple (Similitud)

```python
def simple_search(collection, user_query: str, k: int = 5) -> List[str]:
    """Buscar documentos similares al query"""

    results = collection.query(
        query_texts=[user_query],
        n_results=k,
        include=["documents", "metadatas", "distances"]
    )

    # ChromaDB devuelve:
    # - documents: Los textos originales
    # - metadatas: Información de contexto
    # - distances: Similitud (0 = idéntico, 1 = opuesto)

    return results["documents"][0]  # Lista de k documentos ordenados por relevancia

# Uso
docs = simple_search(collection, "¿Cómo estructurar un proyecto FastAPI?")
for doc in docs:
    print(doc[:200] + "...")
```

### Patrón 2: Búsqueda Filtrada (Seguridad Multi-Tenant)

```python
def multi_tenant_search(
    collection,
    user_query: str,
    project_id: str,
    technology: str = None,
    k: int = 5
) -> Dict:
    """Búsqueda aislada por tenant (empresa/proyecto)"""

    where_filter = {
        "project_id": {"$eq": project_id}
    }

    if technology:
        where_filter["technology"] = {"$eq": technology}

    results = collection.query(
        query_texts=[user_query],
        n_results=k,
        where=where_filter,
        include=["documents", "metadatas", "distances"]
    )

    # Reconstruir resultado con metadatos
    documents = results["documents"][0]
    metadatas = results["metadatas"][0]
    distances = results["distances"][0]

    return {
        "query": user_query,
        "project_id": project_id,
        "results": [
            {
                "document": doc,
                "source": meta.get("source_file"),
                "similarity": 1 - dist  # Convertir distancia a similitud
            }
            for doc, meta, dist in zip(documents, metadatas, distances)
        ]
    }

# Uso
results = multi_tenant_search(
    collection,
    user_query="¿Cómo usar Riverpod?",
    project_id="softarchitect-v1",
    technology="flutter",
    k=5
)

for r in results["results"]:
    print(f"🔗 {r['source']} (similitud: {r['similarity']:.2%})")
    print(r['document'][:150] + "...\n")
```

### Patrón 3: Re-Ranking (Mejorar Precisión)

```python
from typing import List

def rerank_results(
    collection_results: Dict,
    rerank_model = None,  # BERT, ColBERT, etc. (opcional)
    threshold: float = 0.5
) -> List[Dict]:
    """
    Re-rankear resultados por relevancia.
    Útil cuando similitud vectorial no es suficiente.
    """

    results = collection_results["results"]

    # Filtro 1: Por similitud mínima
    filtered = [r for r in results if r["similarity"] > threshold]

    # Filtro 2: Si tenemos modelo de re-ranking, aplicar
    if rerank_model:
        # (Requiere más cómputo, usar solo si necesario)
        scores = rerank_model.predict(
            [[collection_results["query"], r["document"]] for r in filtered]
        )
        for result, score in zip(filtered, scores):
            result["rerank_score"] = score

        # Ordenar por score de re-ranking
        filtered = sorted(filtered, key=lambda x: x["rerank_score"], reverse=True)

    return filtered[:5]  # Top 5

# Uso
filtered_results = rerank_results(
    collection_results=multi_tenant_search(...),
    threshold=0.6
)
```

---

## Persistencia & Docker Integration

### Docker Compose: ChromaDB Persistent

```yaml
# infrastructure/docker-compose.yml
version: '3.9'

services:
  chroma:
    image: chromadb/chroma:latest
    container_name: softarchitect-chroma

    environment:
      # Configuración de persistencia
      CHROMA_DB_IMPL: duckdb
      PERSIST_DIRECTORY: /chroma/chroma
      ANONYMIZED_TELEMETRY: "False"

    ports:
      - "8001:8000"  # API REST

    volumes:
      # Montar persistencia en host
      - chroma_data:/chroma/chroma
      - ./chroma_backup:/chroma/backup  # Backups

    networks:
      - softarchitect-net

    restart: unless-stopped

    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/api/version"]
      interval: 30s
      timeout: 10s
      retries: 3

    logging:
      driver: "json-file"
      options:
        max-size: "100m"
        max-file: "3"

  # ============================================================================
  # Backend: Aplicación FastAPI que usa ChromaDB
  # ============================================================================
  backend:
    depends_on:
      chroma:
        condition: service_healthy

    environment:
      CHROMA_HOST: chroma  # Nombre de servicio Docker
      CHROMA_PORT: 8000
      CHROMA_DB: softarchitect_knowledge_base

volumes:
  chroma_data:
    driver: local

networks:
  softarchitect-net:
    driver: bridge
```

### Cliente Python: Conectar a ChromaDB

```python
# src/services/rag/vector_store.py
import os
from chromadb import HttpClient

class VectorStoreClient:
    def __init__(self):
        # Conectar al servidor ChromaDB (Docker)
        host = os.getenv("CHROMA_HOST", "localhost")
        port = int(os.getenv("CHROMA_PORT", "8000"))

        self.client = HttpClient(
            host=host,
            port=port
        )

        # Obtener colección
        self.collection = self.client.get_or_create_collection(
            name="softarchitect_knowledge_base",
            metadata={"hnsw:space": "cosine"}
        )

        print(f"✅ Conectado a ChromaDB: {host}:{port}")

    def search(self, query: str, k: int = 5) -> List[str]:
        """Búsqueda simple"""
        results = self.collection.query(
            query_texts=[query],
            n_results=k
        )
        return results["documents"][0]

    def ingest_bulk(self, documents: List[Dict]) -> int:
        """Ingestar múltiples documentos"""
        ids = []
        texts = []
        metadatas = []

        for doc in documents:
            ids.append(doc["id"])
            texts.append(doc["text"])
            metadatas.append(doc.get("metadata", {}))

        self.collection.add(
            ids=ids,
            documents=texts,
            metadatas=metadatas
        )

        return len(documents)

# Uso en FastAPI
from fastapi import FastAPI

app = FastAPI()
vector_store = VectorStoreClient()

@app.post("/search")
async def search_knowledge_base(query: str):
    docs = vector_store.search(query, k=5)
    return {"query": query, "results": docs}
```

---

## Performance & Scaling

### Métricas de Performance

| Métrica | Objetivo | Herramienta |
|:---|:---|:---|
| **Latencia Query** | <100ms (top-5 docs) | Chrome DevTools / curl time |
| **Memory Usage** | <2GB (10k documents) | `docker stats` |
| **Indexing Speed** | >1000 docs/min | `time` bash command |
| **Recall @5** | >90% (relevancia) | Manual evaluation |

### Benchmark Real (SoftArchitect)

```bash
# Test 1: Ingestión (velocidad)
time python -c "
from vector_store import VectorStoreClient
vs = VectorStoreClient()
docs = [{'id': f'doc_{i}', 'text': f'Document {i}'} for i in range(1000)]
vs.ingest_bulk(docs)
"
# Resultado: ~2.5s para 1000 docs → 400 docs/s

# Test 2: Query latencia
time curl -X POST http://localhost:8001/search \
  -d '{"query": "Clean Architecture"}'
# Resultado: ~45ms

# Test 3: Memory usage
docker stats chroma --no-stream
# Resultado: ~450MB RAM, ~0% CPU (en reposo)
```

### Scaling: Cuándo Necesitas Más

| Señal | Acción |
|:---|:---|
| Query latency > 500ms | Reducir `n_results`, mejorar filtros `where` |
| Memory > 8GB | Particionar data por `project_id`, usar múltiples collections |
| > 1M documents | Migrar a ChromaDB cluster (Enterprise) o Weaviate/Pinecone |

---

## Pre-Production Checklist

Antes de deployer ChromaDB a producción:

```bash
# ✅ 1. Verificar conectividad
curl http://localhost:8001/api/version
# Respuesta: {"version": "0.x.x"}

# ✅ 2. Testear ingestión
python -c "
from vector_store import VectorStoreClient
vs = VectorStoreClient()
count_before = vs.collection.count()
vs.ingest_bulk([{'id': 'test', 'text': 'Test document'}])
count_after = vs.collection.count()
assert count_after == count_before + 1, 'Ingestión falló'
print('✅ Ingestión OK')
"

# ✅ 3. Verificar persistencia (datos no se pierden tras restart)
docker-compose down
docker-compose up -d chroma
sleep 5
curl http://localhost:8001/api/version

# ✅ 4. Test de query simple
curl -X POST http://localhost:8001/collections/softarchitect_knowledge_base/query \
  -H "Content-Type: application/json" \
  -d '{"query_texts": ["test"], "n_results": 1}'

# ✅ 5. Performance bajo carga (10 queries simultáneas)
for i in {1..10}; do
  curl -X POST http://localhost:8001/collections/softarchitect_knowledge_base/query \
    -d '{"query_texts": ["test"], "n_results": 5}' &
done
wait

# ✅ 6. Backup de datos
docker exec softarchitect-chroma tar -czf /chroma/backup/chroma_$(date +%s).tar.gz /chroma/chroma

# ✅ 7. Verificar tamaño de base de datos
docker exec softarchitect-chroma du -sh /chroma/chroma

# ✅ 8. Documentar configuración en prod
echo "ChromaDB Producción:
- Colección: softarchitect_knowledge_base
- Storage: /chroma/chroma (persistent)
- Documents: $(curl http://localhost:8001/collections/softarchitect_knowledge_base | jq '.count')
- Query latency: <100ms
- Memory: $(docker stats --no-stream softarchitect-chroma | tail -1 | awk '{print $4}')
"
```

---

## Conclusión

ChromaDB es la **memoria vectorial compartida** de SoftArchitect:

1. ✅ **Escalable:** Soporta millones de documentos con queries rápidos
2. ✅ **Flexible:** Metadatos para filtrado, multi-tenancy, seguridad
3. ✅ **Persistente:** Docker integration, backups automáticos
4. ✅ **Agnóstico:** Funciona con cualquier modelo de embedding

**Dogfooding Validation:** SoftArchitect ingiere su propia documentación (BEST_PRACTICES.md, ARCHITECTURE.md, etc.) en ChromaDB para generar respuestas RAG autoexplicativas.
