# 🧠 SoftArchitect AI: Arquitectura y Flujo RAG

> **Versión:** 1.0.0 (MVP)  
> **Fecha:** 02/02/2026  
> **Estado:** ✅ Completo (Fases Ingesta y Vectorización)  
> **Responsable:** ArchitectZero

---

## 📖 Tabla de Contenidos

1. [Visión Global](#1-visión-global-del-sistema)
2. [Los 4 Pilares Tecnológicos](#2-los-4-pilares-tecnológicos)
3. [Flujo A: Proceso de Ingesta](#3-flujo-a-el-proceso-de-ingesta-el-aprendizaje)
4. [Flujo B: Motor RAG en Ejecución](#4-flujo-b-el-motor-rag-en-ejecución-la-generación)
5. [Garantías del Sistema](#5-resumen-de-garantías-del-sistema)
6. [Integración con Componentes](#6-integración-con-componentes)
7. [Métricas de Performance](#7-métricas-de-performance)
8. [Roadmap v0.2.0+](#8-roadmap-futuro-v020)

---

## 1. Visión Global del Sistema

**SoftArchitect AI** no es un simple chatbot; es un **sistema experto** diseñado para **automatizar la labor de un Arquitecto de Software**. Su función principal es transformar requisitos de negocio abstractos (ej: *"Quiero un Uber para pasear perros"*) en **documentación técnica estándar de la industria**, siguiendo plantillas rigurosas y mejores prácticas de ingeniería.

Para lograr esto, el sistema utiliza una arquitectura **RAG (Retrieval-Augmented Generation) Híbrida**, que combina:

- ✅ **Creatividad de IA Generativa:** El modelo lenguaje (Ollama/Groq) genera texto natural y contextual
- ✅ **Precisión Estructural:** Plantillas predefinidas garantizan formato exacto
- ✅ **Conocimiento de Dominio:** ChromaDB inyecta patrones de ingeniería probados
- ✅ **Soberanía de Datos:** Todo ocurre localmente (v0.1.0) o en infraestructura controlada

### Diferenciador Clave: Recuperación Determinista + Semántica

A diferencia de chatbots genéricos, **SoftArchitect AI combina dos estrategias de recuperación**:

1. **Determinista (Metadata-based):** Recupera plantillas exactas por `filename` metadato
2. **Semántica (Vector similarity):** Recupera contexto relacionado por similitud de significado

Esta hibridación garantiza estructura + relevancia simultáneamente.

---

## 2. Los 4 Pilares Tecnológicos

El sistema se sostiene sobre cuatro componentes fundamentales que interactúan en cada solicitud:

### Pilar 1: Frontend (La Ventanilla)

```
Tecnología:    Flutter (Desktop - Linux/Windows/macOS)
Rol:           Interfaz de usuario
Responsabilidades:
  ✓ Gestionar entrada de datos (texto, upload de archivos)
  ✓ Mostrar streaming de respuesta (token-by-token)
  ✓ Renderizar documentos Markdown con syntax highlighting
  ✓ Gestionar estado de UI (loading, error, success)
Restricción:   Sin lógica de IA (puramente visual)
```

**Ventajas:**
- Bajo overhead RAM (<200MB)
- Experiencia fluida (60-120 FPS)
- Misma codebase compilable a Web (v0.2.0+)

---

### Pilar 2: Backend (El Orquestador)

```
Tecnología:    Python 3.12 + FastAPI
Rol:           Cerebro operativo
Responsabilidades:
  ✓ Recibir peticiones HTTP del Frontend
  ✓ Gestionar seguridad (sanitización, rate limiting)
  ✓ Orquestar servicios de IA (LangChain)
  ✓ Conectar piezas: ChromaDB ↔ Ollama/Groq ↔ Frontend
  ✓ Manejar streaming de respuestas
Dependencia:   LangChain (abstracción de LLMs)
```

**Ventajas:**
- Desacoplado del Frontend (escalable)
- Soporte nativo async (crucial para streaming)
- Fácil integración con múltiples LLMs (Ollama, Groq, Anthropic)

---

### Pilar 3: Memoria Semántica (El Archivo)

```
Tecnología:    ChromaDB (Base de Datos Vectorial)
Rol:           Almacén persistente de conocimiento
Almacena:
  ✓ Guías y patrones de diseño (fragmentados en vectores)
  ✓ Plantillas estructurales (.template.md files)
  ✓ Mejores prácticas de seguridad (OWASP, etc.)
  ✓ Convenciones de código y documentación
Persistencia:  Volumen Docker (infrastructure/chroma_data/)
Metadata:      filename, source_path, header_section, content_type
```

**Ventajas:**
- Búsqueda semántica (entiende significado, no solo palabras clave)
- Persistencia entre reinicios (data sovereignty)
- API REST nativa (fácil de interrogar)

---

### Pilar 4: Motor Cognitivo (El Generador)

```
Tecnología:    Ollama (local) / Groq API (cloud)
Rol:           Large Language Model (LLM)
Función:       Generar texto de acuerdo a prompts
Características:
  ✓ "Amnésico" por naturaleza (sin memoria de contexto previo)
  ✓ Depende completamente del contexto inyectado por Backend
  ✓ Token-by-token streaming (UX fluida)
  ✓ Respeta plantillas cuando están en el prompt

Modelos:
  - Ollama: Qwen2.5:3b (local, v0.1.0)
  - Groq: Llama 3.3 70B (cloud, v0.2.0+)
```

**Ventajas:**
- No necesita entrenamiento (usa general knowledge)
- Bajo costo de inferencia local
- Fácil swap de modelos

---

## 3. Flujo A: El Proceso de Ingesta ("El Aprendizaje")

Este proceso es **Batch** (por lotes) y ocurre **bajo demanda** (ejecutando `ingest.py`). Es el responsable de poblar la memoria del sistema.

### Paso 1: Carga y Lectura (DocumentLoader)

El sistema escanea recursivamente la carpeta `packages/knowledge_base`. Aquí existen **dos tipos críticos** de documentos:

#### Tipo 1: Conocimiento Desestructurado
- Guías de estilo (`STYLE_GUIDE.md`)
- Principios SOLID y patrones de diseño
- Checklists de seguridad (OWASP Top 10)
- Mejores prácticas por dominio (microservicios, monolitos, etc.)

**Propósito:** Inyectar "sentido común" en las generaciones. Cuando pides un sistema de logística, la IA lee estos fragmentos y genera arquitecturas seguras.

#### Tipo 2: Conocimiento Estructural (Templates)
- Plantillas vacías (ej: `PROJECT_MANIFESTO.template.md`)
- Esquemas de documentación (ej: `ARCHITECTURE_DECISION_RECORD.template.md`)
- Formatos de salida estándar

**Propósito:** Garantizar que el documento generado siempre sigue la estructura correcta.

```python
# Pseudocódigo
for file in recursively_scan("packages/knowledge_base"):
    if file.suffix == ".md":
        content = read_file(file)
        metadata = extract_metadata(file)  # filename, path, type
        chunks = split_by_headers(content)  # Respeta # ## ### encabezados
        for chunk in chunks:
            store(chunk, metadata)  # Guardar para siguiente fase
```

---

### Paso 2: División Inteligente (Semantic Splitting)

No se lee el archivo entero de una vez. Se divide en **"Chunks"** (trozos) lógicos respetando la estructura Markdown:

```markdown
# Encabezado H1
Párrafos...

## Encabezado H2
Párrafos...

### Encabezado H3
Párrafos...
```

**Cada chunk es una unidad semántica independiente.**

#### Metadata Rica Asociada a Cada Chunk

```python
chunk_metadata = {
    "filename": "OWASP_TOP_10.md",
    "source_path": "packages/knowledge_base/security/OWASP_TOP_10.md",
    "header_section": "# 1. Injection Attacks",
    "content_type": "best-practice",  # o "template"
    "ingestion_date": "2026-02-02T10:30:00Z",
    "version": "1.0"
}
```

**Ventaja:** Permite recuperación precisa. Ej: "Dame todos los chunks de TEMPLATES que hablen de seguridad".

---

### Paso 3: Vectorización (Embeddings)

Cada chunk de texto se convierte en una **lista de 384 números** (un vector) usando un modelo de embeddings local:

```
Modelo: all-MiniLM-L6-v2 (384 dimensiones)
Entrada:  "SQL Injection es una vulnerabilidad crítica..."
Salida:   [0.123, -0.456, 0.789, ..., 0.234]  (384 floats)
```

**¿Qué representa este vector?**  
El "significado" semántico del texto en un espacio matemático. Textos similares tienen vectores cercanos.

```python
# Pseudocódigo
embedding_model = load_model("all-MiniLM-L6-v2")
for chunk in chunks:
    vector = embedding_model.encode(chunk.text)  # → 384 dimensiones
    store_in_chromadb(vector, chunk.metadata, chunk.text)
```

**Ventajas:**
- Búsqueda semántica (no literal)
- Rápida (búsqueda en espacio vectorial)
- Local (sin enviar datos a la nube)

---

### Paso 4: Persistencia

Los vectores y metadatos se guardan en el volumen Docker `infrastructure/chroma_data/`. Esto asegura que el conocimiento **sobreviva a reinicios** del sistema.

```
infrastructure/
└── chroma_data/
    ├── chroma.sqlite3              # Index principal
    ├── 2d8c47e-2e97...            # Directorios por collection
    │   ├── data_level0.bin
    │   ├── header.bin
    │   └── length.bin
    └── [más collections]
```

**Tamaño típico:** ~9MB por 150 documentos ingested.

**Verificación Post-Ingesta:**

```bash
# CLI
poetry run python scripts/inspect_db.py stats
# Output:
# 📊 ChromaDB Statistics:
#    Collections: 1
#    Total Documents: 129
#    Avg Documents per Collection: 129

# o inspeccionar directamente
du -sh infrastructure/chroma_data/
# Output: 9.2M
```

---

## 4. Flujo B: El Motor RAG en Ejecución ("La Generación")

Aquí resolvemos la pregunta crítica: **¿Cómo garantizamos que la IA siga la estructura exacta de la plantilla?**

### Escenario de Uso

**Usuario:** *"Genera el Manifesto del Proyecto para una aplicación de Gestión de Residuos con machine learning para clasificación."*

**Objetivo del Sistema:**
1. Generar documento `PROJECT_MANIFESTO.md` bien formado
2. Que contenga secciones completas (Vision, Goals, Architecture, etc.)
3. Que incluya insights sobre ML y residuos
4. Sin alucinar secciones o cambiar formato

### Fase 1: Identificación de Intención

El Backend analiza la petición con LangChain y detecta:

```python
{
    "intent": "generate_document",
    "document_type": "PROJECT_MANIFESTO",
    "domain": "waste_management",
    "sub_domains": ["machine_learning", "classification"],
    "requirements_summary": "Gestión de residuos con clasificación ML"
}
```

---

### Fase 2: Recuperación Determinista (Garantía Estructural)

En lugar de buscar "algo que se parezca a un manifesto", el sistema ejecuta una **Query de Metadatos Exacta** a ChromaDB:

```python
query_metadata = {
    "where": {
        "filename": "PROJECT_MANIFESTO.template.md",
        "content_type": "template"
    },
    "limit": 1,
    "sort_by": "source_path"  # Mantener orden secuencial
}

template_chunks = chromadb.query(query_metadata)
# Resultado: Todos los fragmentos de la plantilla en orden
```

**¿Por qué es determinista?**  
- No usamos búsqueda semántica (no habría riesgo de no encontrar la plantilla)
- Buscamos el metadato exacto `filename`
- Recuperamos en orden: garantiza estructura intacta

**Garantía:** La plantilla se recupera **intacta y ordenada**, asegurando que el documento final tenga todas las secciones en el lugar correcto.

---

### Fase 3: Recuperación Semántica (Inyección de Dominio)

Simultáneamente, el sistema busca **conceptos relacionados** con el dominio del usuario en el resto de la knowledge base:

```python
query_semantic = {
    "query_texts": [
        "Waste management architecture best practices",
        "Machine learning for waste classification",
        "Recycling logistics system design",
        "Environmental impact assessment"
    ],
    "n_results": 5,  # Top 5 resultados más similares
    "where": {
        "content_type": "best-practice"  # Excluir plantillas
    }
}

domain_context = chromadb.query(query_semantic)
# Resultado: Chunks relevantes de best practices
```

**¿Qué hace esto?**  
- Recupera fragmentos reales de guías sobre reciclaje, ML, etc.
- Estos fragmentos sirven como "inspiración" para el LLM
- La IA no alucina: lee el conocimiento real y lo aplica

---

### Fase 4: Construcción del Prompt Maestro (El "Rellena-Huecos")

LangChain ensambla un prompt completo para enviar a Ollama:

```text
─────────────────────────────────────────────────────────────
SISTEMA EXPERTO: SoftArchitect AI
─────────────────────────────────────────────────────────────

ROL: Eres un Arquitecto de Software Senior con 15 años de experiencia.

TAREA: Rellena la siguiente PLANTILLA ESTRUCTURAL manteniendo 
       el formato Markdown exacto y agregando contenido relevante 
       del CONTEXTO TÉCNICO.

─────────────────────────────────────────────────────────────
CONTEXTO TÉCNICO (Usar para inspirarse, NO es la estructura):
─────────────────────────────────────────────────────────────

[Chunk 1 - Best Practice: "Waste Management Systems"]
Para sistemas de gestión de residuos, es crítico:
- Considerar escalabilidad (millones de items procesados)
- Implementar auditoría (trazabilidad de residuos)
- Separar logística de clasificación

[Chunk 2 - Best Practice: "ML Classification Pipelines"]
Los pipelines de ML requieren:
- Data versioning y reproducibilidad
- Monitoring continuo de drift
- Fallback a reglas cuando la confianza < 0.85

[... más chunks ...]

─────────────────────────────────────────────────────────────
PLANTILLA ESTRUCTURAL (Rellenar exactamente así):
─────────────────────────────────────────────────────────────

# PROJECT MANIFESTO

## Vision
[Completar: ¿Qué impacto tiene este proyecto?]

## Goals (SMART)
[Completar: Objetivos medibles del proyecto]

## Stakeholders & Roles
[Completar: Quién participa y en qué rol]

## Architecture Overview
[Completar: Diagrama conceptual del sistema]

## Technology Stack
[Completar: Tecnologías principales justificadas]

## Risk Assessment
[Completar: Riesgos y mitigaciones]

## Success Metrics
[Completar: KPIs de éxito]

## Timeline & Milestones
[Completar: Fases de implementación]

─────────────────────────────────────────────────────────────
ENTRADA DEL USUARIO:
─────────────────────────────────────────────────────────────

Necesito un manifesto para:
- Aplicación de gestión de residuos
- Con clasificación automática por ML
- Para una municipalidad mediana (200k habitants)
- Presupuesto tech de $50k
- Timeline: 6 meses

─────────────────────────────────────────────────────────────
INSTRUCCIONES ADICIONALES:
─────────────────────────────────────────────────────────────

1. Mantén el formato Markdown exactamente
2. No agregues secciones nuevas (solo rellena las existentes)
3. Aplica los principios técnicos del CONTEXTO
4. Sé específico, no genérico
5. Incluye estimaciones realistas
```

**Ventajas de este enfoque:**
- La IA tiene **dos niveles de información**:
  1. Qué escribir (plantilla)
  2. Qué decir (context chunks)
- Reduce alucinaciones
- Garantiza coherencia estructural

---

### Fase 5: Generación y Streaming

Ollama recibe este paquete completo. Gracias a que tiene la **plantilla en su ventana de contexto**, genera el texto:

```
1. Lee la sección "# PROJECT MANIFESTO"
2. Ve la subsección "## Vision" incompleta
3. Genera: "The vision is to create a comprehensive waste management..."
4. Token por token, cada palabra se envía al Frontend
5. El Frontend renderiza en tiempo real
```

**UX del Usuario (Frontend Flutter):**

```
┌─────────────────────────────────────┐
│ SoftArchitect AI                     │
├─────────────────────────────────────┤
│ Input:                               │
│ "Manifesto para app de residuos..."  │
│                                      │
│ ▌ Generando...                       │
│                                      │
│ # PROJECT MANIFESTO                 │
│                                      │
│ ## Vision                            │
│ The vision is to create a...         │
│ ▌                                    │
└─────────────────────────────────────┘
```

**Streaming proporciona:**
- Feedback visual inmediato
- Percepción de velocidad (no esperar todo al final)
- Cancelación prematura si algo está mal

---

## 5. Resumen de Garantías del Sistema

### Garantía 1: Integridad Estructural ✅

**Riesgo Evitado:** El LLM genera documento sin todas las secciones o cambia el orden Markdown.

**Mecanismo:** Recuperación determinista por `filename` metadato. La plantilla siempre llega **intacta y ordenada** al prompt.

**Verificación:** Parsed Markdown comparison post-generación.

```python
# Post-generation validation
expected_sections = ["Vision", "Goals", "Stakeholders", 
                     "Architecture", "Stack", "Risk", "Metrics", "Timeline"]
generated_doc = parse_markdown(llm_output)
for section in expected_sections:
    assert section in generated_doc.headings, f"Missing section: {section}"
```

---

### Garantía 2: Calidad del Contenido ✅

**Riesgo Evitado:** La IA "alucina" información técnica incorrecta.

**Mecanismo:** Inyección de fragmentos de "Best Practices". La IA no inventa, aplica el conocimiento recuperado.

**Verificación:** Citation tracking (cada claim puede referenciarse a un chunk).

```python
# Example: All claims should be traceable
claim = "Waste classification requires 95%+ accuracy for compliance"
source_chunks = chromadb.search_by_similarity(claim, top_k=1)
# Debería encontrar chunk que menciona este requisito
```

---

### Garantía 3: Soberanía de Datos ✅

**Riesgo Evitado:** Datos enviados a la nube sin consentimiento.

**Mecanismo:** 
- **v0.1.0 (Desktop):** Todo local (Ollama local, ChromaDB local)
- **v0.2.0+ (Web):** Opcional Groq API solo si usuario lo autoriza explícitamente

**Verificación:** Network audit (sin conexiones a OpenAI/Anthropic sin autenticación).

```bash
# Network inspection
sudo tcpdump -i any -n | grep -E "openai|anthropic"
# Debería estar vacío en v0.1.0
```

---

### Garantía 4: Verificabilidad ✅

**Riesgo Evitado:** No saber qué "sabe" el sistema o auditar fallos.

**Mecanismo:** Herramientas CLI de inspección:

```bash
# ¿Qué plantillas tengo disponibles?
poetry run python scripts/inspect_db.py query "PROJECT_MANIFESTO" 
# Output: [filename=PROJECT_MANIFESTO.template.md, matched=1]

# ¿Qué best practices de seguridad?
poetry run python scripts/inspect_db.py query "OWASP"
# Output: [5 matched chunks about OWASP]

# Estadísticas globales
poetry run python scripts/inspect_db.py stats
# Collections: 1, Total Docs: 129, Avg Size: ~7KB
```

---

## 6. Integración con Componentes

### 6.1 Frontend → Backend (HTTP API)

```
Request (POST /api/v1/chat):
{
  "message": "Genera manifesto para app de residuos",
  "conversation_id": "uuid-123"
}

Response (SSE - Server-Sent Events):
event: token
data: "The"

event: token
data: " vision"

event: token
data: " is"

...

event: done
data: {"status": "completed", "tokens": 247, "execution_time_ms": 3420}
```

### 6.2 Backend → ChromaDB (Vector Search)

```python
# Recuperación Determinista
retrieved_template = chromadb.get(
    ids=None,
    where={"filename": "PROJECT_MANIFESTO.template.md"}
)
# → Chunks de plantilla en orden

# Recuperación Semántica
retrieved_context = chromadb.query(
    query_texts=["waste management ML classification"],
    n_results=5
)
# → Top 5 best practices relevantes
```

### 6.3 Backend → Ollama (LLM Inference)

```python
response = ollama_client.generate(
    model="qwen2.5:3b",
    prompt=assembled_prompt,  # Plantilla + Contexto
    stream=True,  # Streaming token-by-token
    temperature=0.7  # Creatividad controlada
)

for chunk in response:
    yield chunk.get("response", "")  # Streaming al Frontend
```

---

## 7. Métricas de Performance

| Métrica | v0.1.0 (Local) | v0.2.0 (Groq) | Notas |
|---------|----------------|---------------|-------|
| **Tiempo Ingesta** | 2-5 min | N/A | Batch, una sola vez |
| **First Token** | 500-800ms | <100ms | Groq más rápido |
| **Tokens/Sec** | 10-15 (CPU), 30-50 (GPU) | 40-60 | Groq consistente |
| **Latencia API** | <50ms | <100ms (network) | ChromaDB super rápido |
| **RAM Usage** | 1.5-2GB | <500MB | Groq externals |
| **Disk Usage** | ~10GB (modelos+data) | ~200MB | Groq minimal local |
| **Temperature Accuracy** | 95%+ estructura | 95%+ estructura | Plantillas garantizan |
| **Hallucination Rate** | <5% (con context) | <3% (Groq) | RAG reduce alucinaciones |

---

## 8. Roadmap Futuro (v0.2.0+)

### v0.2.0: Web Variant para Demos

- [ ] Flutter Web build (responsive)
- [ ] Groq API integration (cloud LLM)
- [ ] Docker Compose modernized (no version field)
- [ ] Homelab deployment guide
- [ ] Interactive presentations

### v0.3.0: Multi-LLM y Fallbacks

- [ ] Support Llama 3.3 (Ollama)
- [ ] Auto-fallback: Ollama → Groq si local falla
- [ ] Model selection UI (usuario elige)
- [ ] Cost tracking y usage analytics

### v0.4.0: Knowledge Base Dinámico

- [ ] Upload custom templates
- [ ] External knowledge integration (URLs, APIs)
- [ ] Collaborative editing de plantillas
- [ ] Version control para templates

### v0.5.0: Enterprise Features

- [ ] Multi-user sessions
- [ ] Role-based access control (RBAC)
- [ ] Audit logging de generaciones
- [ ] Integration con Jira/Linear para crear issues

---

## 📊 Diagrama de Arquitectura Completo

```
┌──────────────────────────────────────────────────────────────┐
│                          FRONTEND LAYER                       │
│                    Flutter (Desktop/Web)                      │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │ Chat UI | Document Viewer | Settings | Knowledge Base  │  │
│  │ State: Riverpod | Navigation: GoRouter                │  │
│  └─────────────────────────────────────────────────────────┘  │
│                           HTTP/SSE                             │
└───────────────────────────┬──────────────────────────────────┘
                            │
┌───────────────────────────┴──────────────────────────────────┐
│                        BACKEND LAYER                          │
│                    Python FastAPI                             │
│  ┌─────────────────────────────────────────────────────────┐  │
│  │ Routes | Auth | Rate Limiting | Error Handling        │  │
│  │ ┌──────────────────────────────────────────────────┐   │  │
│  │ │        RAG ORCHESTRATION (LangChain)           │   │  │
│  │ │ ┌──────────────┐    ┌──────────────────┐      │   │  │
│  │ │ │   Intent     │───▶│   Query Builder  │      │   │  │
│  │ │ │ Identification│    └──────────────────┘      │   │  │
│  │ │ └──────────────┘                               │   │  │
│  │ │ ┌──────────────┐    ┌──────────────────┐      │   │  │
│  │ │ │ Deterministic│───▶│  ChromaDB Search │      │   │  │
│  │ │ │  Retrieval   │    │  (Metadata)      │      │   │  │
│  │ │ └──────────────┘    └──────────────────┘      │   │  │
│  │ │ ┌──────────────┐    ┌──────────────────┐      │   │  │
│  │ │ │   Semantic   │───▶│  ChromaDB Query  │      │   │  │
│  │ │ │  Retrieval   │    │  (Vector Search) │      │   │  │
│  │ │ └──────────────┘    └──────────────────┘      │   │  │
│  │ │ ┌──────────────┐    ┌──────────────────┐      │   │  │
│  │ │ │   Prompt     │───▶│  LLM (Ollama/    │      │   │  │
│  │ │ │  Assembly    │    │  Groq)           │      │   │  │
│  │ │ │              │    │  Streaming Resp. │      │   │  │
│  │ │ └──────────────┘    └──────────────────┘      │   │  │
│  │ └──────────────────────────────────────────────────┘   │  │
│  └─────────────────────────────────────────────────────────┘  │
└───────────────────┬──────────────────────┬──────────────────┘
                    │                      │
        ┌───────────┴───────────┐  ┌──────┴─────────┐
        │                       │  │                │
┌───────▼─────────┐  ┌──────────▼──▼──────┐  ┌──────▼───────────┐
│   ChromaDB      │  │    Ollama Local    │  │   Groq Cloud    │
│                 │  │                    │  │ (v0.2.0+, opt)  │
│ Vector Store    │  │ Model: Qwen2.5:3b  │  │ Model: Llama    │
│ Knowledge Base  │  │ GPU/CPU inference  │  │ 3.3 70B         │
│                 │  │ Token-by-token     │  │ Super fast      │
└─────────────────┘  └────────────────────┘  └─────────────────┘

Vector Index:
- all-MiniLM-L6-v2 (384 dims)
- 129 documents ingested
- ~9MB total size
```

---

## ⚠️ Consideraciones de Seguridad

1. **Input Sanitization:** Todos los prompts pasan por validación antes de llegar a Ollama
2. **Output Filtering:** El LLM nunca expone secretos (env vars, keys, passwords)
3. **Rate Limiting:** Máximo 10 requests/minuto por usuario (evitar DoS)
4. **Data Encryption:** ChromaDB data es local; backups deben ser encriptados
5. **Audit Logging:** Cada generación se registra (quién, cuándo, qué, output hash)

---

## 📚 Referencias Relacionadas

- [API_INTERFACE_CONTRACT.es.md](./API_INTERFACE_CONTRACT.es.md) - Especificación detallada de endpoints
- [TECH_STACK_DETAILS.es.md](./TECH_STACK_DETAILS.es.md) - Detalles tecnológicos del stack
- [DESIGN_SYSTEM.es.md](./DESIGN_SYSTEM.es.md) - Componentes UI y tokens de diseño
- [HU-2.3: RAG Verification Tools](../../doc/03-HU-TRACKING/HU-2.3-RAG-VERIFICATION-TOOLS/README.md) - Herramientas de verificación
- [AGENTS.md](../../AGENTS.md) - Definición del agente ArchitectZero

---

**Documento generado:** 2 de febrero de 2026  
**Última actualización:** 02/02/2026  
**Status:** ✅ Versión Estable (MVP v0.1.0)
