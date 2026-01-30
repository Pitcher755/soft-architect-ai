# 🆔 Tech Profile: Pinecone

> **Categoría:** Managed Vector Database (SaaS)
> **Tipo:** Cloud-Native, Serverless
> **Web:** https://www.pinecone.io/
> **Versión Objetivo:** v4.0+ (API v1)

Base de datos vectorial gestionada para búsqueda semántica a escala y baja latencia.

---

## 📖 Tabla de Contenidos

1. [Casos de Uso (Suitability)](#casos-de-uso-suitability)
2. [Conceptos Clave](#conceptos-clave)
3. [Comparativa: Pinecone vs Chroma vs Milvus](#comparativa-pinecone-vs-chroma-vs-milvus)
4. [Requisitos y Setup](#requisitos-y-setup)
5. [Decisión de Adopción](#decisión-de-adopción)

---

## Casos de Uso (Suitability)

### ✅ Ideal Para (Best Fit)

* **Producción High-Scale:** Millones de vectores con latencia <100ms garantizada por SLA.
* **Serverless:** No quieres gestionar contenedores Docker, volúmenes, parches de seguridad ni escalado manual.
* **Multi-tenancy:** Namespaces aislados por cliente/usuario sin crear índices múltiples.
* **Búsqueda Semántica Robusta:** Encuentra documentos similares, recomendaciones, etc. sin escribir queries SQL complejas.
* **Integración con SK/LangChain:** Connectors nativos para ambos frameworks.
* **Cumplimiento Regulatory:** SOC2 Type II, HIPAA, GDPR ready (datos en AWS/GCP/Azure específicamente).

### ❌ No Usar Para (Anti-Patterns)

* **Desarrollo Local/Offline:** Requiere conexión a internet. Para local + offline, usar ChromaDB o FAISS.
* **Datos Ultra-Sensibles On-Premise:** Si los datos NO pueden salir de tu servidor físico (aunque Pinecone cumple compliance).
* **Prototipado Hackathon:** Chroma local es más rápido para iniciar (sin API keys, sin setup cloud).
* **Almacenamiento de Documentos Completos:** Pinecone guarda vectores + metadatos ligeros. Para documentos enteros, usar blob storage + índice vectorial.

---

## Conceptos Clave

### Índices (Indexes)

Un **Index** es la unidad principal. Contiene millones de vectores.

* **Nombre:** Único dentro tu workspace (ej: `softarchitect-knowledge`)
* **Dimensionalidad:** Debe coincidir con el embedder (OpenAI 1536, Cohere 768, etc.)
* **Métrica:** `cosine` (recomendado para texto), `euclidean`, `dotproduct`

### Namespaces

**Particiones lógicas** dentro de un índice. La ventaja de usar namespaces es evitar crear 100 índices para 100 clientes.

```python
# En lugar de:
index_client_1 = pinecone.Index("client-1")  # ❌ Exceso de índices
index_client_2 = pinecone.Index("client-2")

# Usa:
index = pinecone.Index("softarchitect-knowledge")  # ✅ Un índice
index.upsert(..., namespace="client-1")
index.upsert(..., namespace="client-2")
```

### Metadatos (Metadata)

Datos adicionales asociados a cada vector (NO vectorizados).

```json
{
  "id": "doc_456",
  "values": [0.1, 0.2, ..., 0.8],  // Vector (embeddings)
  "metadata": {
    "source": "contracts/NDA_2024.pdf",
    "author": "legal@company.com",
    "date": "2024-01-15",
    "client_id": "acme"
  }
}
```

### Tipos de Deployment

| Tipo | Latencia | Costo | Escalado | Recomendado |
|:---|:---|:---|:---|:---|
| **Serverless** | <50ms | Pay-per-use | Auto | ✅ Para SoftArchitect |
| **Pod-based** | <20ms (reserved) | Fixed monthly | Manual | ⚠️ Legacy |

**Para SoftArchitect:** Usar **Serverless** (defecto).

---

## Comparativa: Pinecone vs Chroma vs Milvus

| Aspecto | Pinecone | Chroma | Milvus |
|:---|:---|:---|:---|
| **Tipo** | SaaS (Cloud) | Open-source (Local/Cloud) | Open-source (Self-hosted) |
| **Setup** | 5 minutos (API key) | 30 segundos (pip install) | 1+ hora (Docker + config) |
| **Latencia** | <50ms (Serverless) | ~100ms (local) | <20ms (bien tuned) |
| **Escala** | Millones | Millones (si cloud) | Billones (cluster) |
| **Costo** | USD/mes | $0 (local) o USD/mes (cloud) | $0 (solo infra) |
| **Offline** | ❌ Requiere internet | ✅ Soporta local | ✅ Soporta local |
| **Multi-tenancy** | ✅ Namespaces | ⚠️ Requiere multi-client | ✅ Particiones |
| **Enterprise** | ✅ SOC2, HIPAA | ⚠️ Community-driven | ✅ Enterprise plans |

**Decisión SoftArchitect:**
- **Desarrollo:** ChromaDB (local, offline)
- **Staging/Prod:** Pinecone (serverless, managed)

---

## Requisitos y Setup

### SDK Python

```bash
pip install pinecone-client>=3.0.0
```

### Credenciales

Obtén tu API key en https://app.pinecone.io/keys.

```bash
export PINECONE_API_KEY="your-api-key"
export PINECONE_INDEX_NAME="softarchitect-knowledge"
```

### Inicialización

```python
import pinecone

# Conectar
pc = pinecone.Pinecone(api_key=os.getenv("PINECONE_API_KEY"))

# Acceder a índice
index = pc.Index(os.getenv("PINECONE_INDEX_NAME"))

# Upsert (insert/update)
index.upsert(
    vectors=[
        ("id-1", [0.1, 0.2, ...], {"source": "doc.pdf"}),
        ("id-2", [0.3, 0.4, ...], {"source": "email.txt"}),
    ],
    namespace="default"
)

# Query
results = index.query(
    vector=[0.15, 0.25, ...],
    top_k=5,
    namespace="default"
)
```

### Cloud Region

* **AWS:** us-east-1, eu-west-1, etc.
* **GCP:** us-central1
* **Azure:** (limitado)

**Recomendación:** Misma región que tu backend (ej: si backend está en `us-east-1`, Pinecone también).

---

## Decisión de Adopción

✅ **SoftArchitect adopta Pinecone como vector DB para producción** bajo estas condiciones:

1. **Serverless deployment:** Defecto para nuevos índices
2. **Namespace isolation:** Uno por cliente/tenant (sin índices múltiples)
3. **Metadata filtering:** Usar metadatos para queries complejas
4. **Integration:** Connectors con LangChain y Semantic Kernel

**Stack Recomendado:**
```
Backend (FastAPI) → Embedder (OpenAI/Cohere) → Pinecone (SaaS)
                                         ↓
                    ChromaDB (dev/testing local)
```

---

**Fecha:** 30 de Enero de 2026
**Status:** ✅ ADOPTED (Production VectorDB)
**Responsable:** ArchitectZero AI Agent
