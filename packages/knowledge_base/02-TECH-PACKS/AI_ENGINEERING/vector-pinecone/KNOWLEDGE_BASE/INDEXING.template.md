# 🗂️ Pinecone Indexing Strategy

> **Propósito:** Cómo estructurar datos vectoriales en Pinecone
> **Filosofía:** Namespaces para multi-tenancy, Metadatos para filtrado
> **Patrón:** 1 Índice → N Namespaces → M Clientes

Guía para maximizar rendimiento, escalabilidad y seguridad en Pinecone.

---

## 📖 Tabla de Contenidos

1. [Namespaces: Aislamiento Lógico](#namespaces-aislamiento-lógico)
2. [Metadatos: Filtrado Avanzado](#metadatos-filtrado-avanzado)
3. [Estrategia de IDs](#estrategia-de-ids)
4. [Upsert: Insert/Update](#upsert-insertupdate)
5. [Queries Complejas](#queries-complejas)
6. [Serverless Configuration](#serverless-configuration)
7. [Anti-Patterns](#anti-patterns)

---

## Namespaces: Aislamiento Lógico

**Regla:** NO crear un índice por cliente. Usar **Namespaces**.

### Estructura Recomendada

```
Workspace: "SoftArchitect"
└── Index: "softarchitect-knowledge" (Único)
    ├── Namespace: "default"          (Conocimiento general)
    ├── Namespace: "tenant-google"    (Documentos Google)
    ├── Namespace: "tenant-microsoft" (Documentos Microsoft)
    └── Namespace: "tenant-apple"     (Documentos Apple)
```

### Ventajas

✅ **Un índice:** Menos costos de gestión
✅ **Búsqueda aislada:** Las queries en un namespace NO ven vectores de otros
✅ **Escalabilidad:** Agregar 1000 clientes = agregar 1000 namespaces (gratis)
✅ **Mantenimiento:** Actualizar config central sin tocar índices múltiples

### Implementación

```python
import pinecone
from typing import List

class PineconeIndexing:
    def __init__(self, index_name: str, api_key: str):
        self.pc = pinecone.Pinecone(api_key=api_key)
        self.index = self.pc.Index(index_name)

    def create_namespace_if_not_exists(self, namespace: str):
        """Pinecone crea namespaces automáticamente al hacer upsert."""
        # No hay que crear explícitamente; se crean on-demand
        pass

    def upsert_documents(
        self,
        namespace: str,
        documents: List[dict]
    ):
        """
        Upsert documentos a un namespace específico.

        documents = [
            {
                "id": "doc_1",
                "embedding": [0.1, 0.2, ...],
                "metadata": {"source": "contracts/nda.pdf", "date": "2024-01"}
            },
            ...
        ]
        """
        vectors = [
            (doc["id"], doc["embedding"], doc["metadata"])
            for doc in documents
        ]

        self.index.upsert(
            vectors=vectors,
            namespace=namespace
        )

    def search(
        self,
        namespace: str,
        query_embedding: List[float],
        top_k: int = 5,
        filters: dict = None
    ) -> List[dict]:
        """
        Busca en un namespace específico (no ve otros namespaces).
        """
        results = self.index.query(
            vector=query_embedding,
            top_k=top_k,
            namespace=namespace,
            filter=filters,  # Opcional: metadatos
            include_metadata=True
        )

        return [
            {
                "id": match["id"],
                "score": match["score"],
                "metadata": match["metadata"]
            }
            for match in results["matches"]
        ]
```

---

## Metadatos: Filtrado Avanzado

Los **metadatos** son datos NO vectorizados asociados a cada vector. Permiten filtrado rápido.

### Tipos de Metadatos Soportados

| Tipo | Ejemplo | Operadores |
|:---|:---|:---|
| **string** | `"source": "doc.pdf"` | `$eq`, `$ne`, `$in` |
| **number** | `"year": 2024` | `$eq`, `$lte`, `$gte`, `$gt`, `$lt` |
| **boolean** | `"is_public": true` | `$eq` |

### Estructura de Datos

```python
vector_with_metadata = {
    "id": "contract_2024_001",
    "values": [0.1, 0.2, ..., 0.8],  # Embedding
    "metadata": {
        # Strings
        "source": "contracts/NDA_2024.pdf",
        "author": "legal@acme.com",
        "client_id": "acme",
        "category": "legal",

        # Numbers
        "year": 2024,
        "page_count": 15,
        "retention_days": 365,

        # Booleans
        "is_draft": False,
        "requires_signature": True
    }
}
```

### Queries con Filtros

**Operador `$eq` (Equal):**

```python
# Busca en namespace "tenant-google", solo documentos de tipo "legal"
results = index.query(
    vector=query_embedding,
    top_k=5,
    namespace="tenant-google",
    filter={
        "category": {"$eq": "legal"}
    }
)
```

**Operadores `$gte`, `$lte` (Mayor/Menor):**

```python
# Documentos de 2024 o posteriores
results = index.query(
    vector=query_embedding,
    filter={
        "year": {"$gte": 2024}
    }
)
```

**Operador `$in` (En lista):**

```python
# Documentos de categorías específicas
results = index.query(
    vector=query_embedding,
    filter={
        "category": {"$in": ["legal", "compliance"]}
    }
)
```

**Combinaciones AND/OR:**

```python
# AND: Documentos de 2024 Y categoría "legal" Y requieren firma
results = index.query(
    vector=query_embedding,
    filter={
        "$and": [
            {"year": {"$eq": 2024}},
            {"category": {"$eq": "legal"}},
            {"requires_signature": {"$eq": True}}
        ]
    }
)

# OR: Documentos públicos O de ACME
results = index.query(
    vector=query_embedding,
    filter={
        "$or": [
            {"is_public": {"$eq": True}},
            {"client_id": {"$eq": "acme"}}
        ]
    }
)
```

---

## Estrategia de IDs

Los **IDs** deben ser únicos dentro del namespace.

### Convenciones Recomendadas

```python
# Formato: {type}_{tenant}_{timestamp}_{hash}

# Ejemplo 1: Documento
id_doc = f"doc_acme_{int(time.time())}_{hash(content)}"

# Ejemplo 2: Fragmento de documento (chunks)
id_chunk = f"chunk_google_contracts_2024_001_002"  # doc_001, chunk_002

# Ejemplo 3: Con UUIDs
from uuid import uuid4
id_unique = f"doc_{uuid4().hex[:8]}"
```

### Sistema de Chunking

Si los documentos son grandes, dividirlos en "chunks" más pequeños.

```python
class DocumentChunking:
    @staticmethod
    def chunk_document(
        document_id: str,
        text: str,
        chunk_size: int = 512,
        overlap: int = 100
    ) -> List[dict]:
        """
        Divide un documento en chunks con overlap.
        """
        chunks = []
        start = 0

        chunk_number = 0
        while start < len(text):
            end = min(start + chunk_size, len(text))
            chunk_text = text[start:end]

            chunks.append({
                "id": f"{document_id}_chunk_{chunk_number:03d}",
                "text": chunk_text,
                "metadata": {
                    "parent_doc_id": document_id,
                    "chunk_number": chunk_number,
                    "start_offset": start,
                    "end_offset": end
                }
            })

            chunk_number += 1
            start = end - overlap  # Overlap para continuidad

        return chunks

# Uso
chunks = DocumentChunking.chunk_document(
    document_id="contract_2024_001",
    text="Lorem ipsum dolor...",
    chunk_size=512,
    overlap=100
)

# Upsert todos los chunks
vectors = [
    (chunk["id"], embedding(chunk["text"]), chunk["metadata"])
    for chunk in chunks
]
index.upsert(vectors=vectors, namespace="tenant-acme")
```

---

## Upsert: Insert/Update

**Upsert** = Update si existe, Insert si no existe.

### Operación Simple

```python
index.upsert(
    vectors=[
        ("doc_1", [0.1, 0.2, ...], {"source": "doc.pdf"}),
        ("doc_2", [0.3, 0.4, ...], {"source": "email.txt"}),
    ],
    namespace="tenant-google"
)
```

### Batch Upsert (Recomendado)

Para millones de vectores, usar batching.

```python
def batch_upsert(index, vectors, namespace, batch_size=100):
    """Upsert en batches para evitar timeouts."""
    for i in range(0, len(vectors), batch_size):
        batch = vectors[i : i + batch_size]
        index.upsert(vectors=batch, namespace=namespace)
        print(f"Upserted batch {i // batch_size + 1}")

# Uso
batch_upsert(index, all_vectors, namespace="tenant-microsoft", batch_size=100)
```

### Eliminar Vectores

```python
# Eliminar por ID
index.delete(ids=["doc_1", "doc_2"], namespace="tenant-google")

# Eliminar por filtro (más lento, cuidado)
# Pinecone no soporta delete_by_filter; usar script externo
```

---

## Queries Complejas

### Búsqueda Híbrida (Semántica + Keyword)

Pinecone soporta búsqueda semántica. Para búsqueda keyword, integrar con DB relacional.

```python
# Pinecone: Búsqueda semántica
def search_semantic(query_embedding: List[float]) -> List[str]:
    results = index.query(
        vector=query_embedding,
        top_k=10,
        namespace="tenant-google"
    )
    return [match["id"] for match in results["matches"]]

# DB Relacional: Búsqueda keyword (SQL)
def search_keyword(query: str) -> List[str]:
    return db.query(
        "SELECT id FROM documents WHERE source LIKE ?",
        (f"%{query}%",)
    )

# Fusión
semantic_ids = set(search_semantic(embedding))
keyword_ids = set(search_keyword("NDA"))
final_ids = semantic_ids & keyword_ids  # Intersección
```

### Re-ranking

Recuperar top-20 semántico, luego re-rankear con modelo ligero.

```python
def search_with_rerank(
    query_embedding: List[float],
    query_text: str,
    top_k: int = 5
) -> List[dict]:
    # Paso 1: Recuperar top-20 semántico
    candidates = index.query(
        vector=query_embedding,
        top_k=20,
        namespace="tenant-google"
    )

    # Paso 2: Re-rankear con modelo local
    from sentence_transformers import CrossEncoder
    reranker = CrossEncoder("ms-marco-MiniLM-L-12-v2")

    scores = reranker.predict([
        (query_text, match["metadata"]["content"])
        for match in candidates["matches"]
    ])

    # Paso 3: Retornar top-5 re-rankeados
    ranked = sorted(
        zip(candidates["matches"], scores),
        key=lambda x: x[1],
        reverse=True
    )

    return [{"match": m, "rerank_score": s} for m, s in ranked[:top_k]]
```

---

## Serverless Configuration

Para SoftArchitect, recomendamos índices **Serverless**.

### Crear Índice (Python)

```python
from pinecone import Pinecone, ServerlessSpec

pc = Pinecone(api_key="...")

# Crear índice serverless
pc.create_index(
    name="softarchitect-knowledge",
    dimension=1536,  # OpenAI embedding dimension
    metric="cosine",
    spec=ServerlessSpec(
        cloud="aws",
        region="us-east-1"  # Misma región que backend
    )
)

# Usar índice
index = pc.Index("softarchitect-knowledge")
```

### Configuración Recomendada

| Parámetro | Valor | Razón |
|:---|:---|:---|
| **metric** | `cosine` | Estándar para embeddings de texto |
| **cloud** | `aws` \| `gcp` | Menor latencia si coincide con backend |
| **region** | Same as backend | Minimiza latencia |
| **dimension** | 1536 (OpenAI) \| 768 (Cohere) | Debe coincidir con embedder |

---

## Anti-Patterns

### ❌ ANTI-PATTERN 1: Índice por Cliente

```python
# ❌ BAD: Demasiados índices
for client in clients:
    pc.create_index(f"index_{client}", ...)  # 🔥 Overhead innecesario
```

**DEBE SER:** Namespaces.

```python
# ✅ GOOD
pc.create_index("softarchitect-knowledge")  # Un índice
for client in clients:
    index.upsert(..., namespace=client)  # Namespaces
```

### ❌ ANTI-PATTERN 2: Sin Metadatos

```python
# ❌ BAD: No puedes filtrar/auditar
index.upsert([("doc_1", [0.1, ...])], namespace="tenant-a")

# ✅ GOOD: Metadatos ricos
index.upsert(
    [("doc_1", [0.1, ...], {
        "source": "contracts/nda.pdf",
        "uploaded_by": "legal@acme.com",
        "date": "2024-01-15"
    })],
    namespace="tenant-a"
)
```

### ❌ ANTI-PATTERN 3: IDs Genéricos

```python
# ❌ BAD: Difícil de rastrear
index.upsert([("1", [...]), ("2", [...])], namespace="tenant-a")

# ✅ GOOD: IDs descriptivos
index.upsert([
    ("contract_2024_001", [...]),
    ("email_inbox_12345", [...])
], namespace="tenant-a")
```

### ❌ ANTI-PATTERN 4: Upserts Síncronos en Lote

```python
# ❌ BAD: Lento para millones
for vector in vectors:
    index.upsert([vector])

# ✅ GOOD: Batch
batch_upsert(index, vectors, batch_size=100)
```

---

## Checklist: Indexing Bien Formado

```bash
# ✅ 1. Namespaces
[ ] Un índice principal
[ ] Namespaces por tenant/cliente
[ ] Convención de nombres consistente

# ✅ 2. Metadatos
[ ] Cada vector tiene metadata
[ ] Metadatos incluyen: source, date, client_id, etc.
[ ] Metadata es queryable (filtros)

# ✅ 3. IDs
[ ] IDs únicos dentro del namespace
[ ] IDs descriptivos (no "1", "2", "3")
[ ] Estrategia de chunking documentada

# ✅ 4. Upsert
[ ] Batching configurado (batch_size=100)
[ ] Error handling en operaciones
[ ] Tracking de upsert success

# ✅ 5. Queries
[ ] Queries con filtros de metadata
[ ] Re-ranking si es necesario
[ ] Timeout/retry configurado

# ✅ 6. Security
[ ] Metadatos contienen audit trail
[ ] Namespace isolation verificada
[ ] API keys rotadas regularmente
```

---

**Fecha:** 30 de Enero de 2026
**Status:** ✅ PRODUCTION-READY STRATEGY
**Responsable:** ArchitectZero AI Agent
