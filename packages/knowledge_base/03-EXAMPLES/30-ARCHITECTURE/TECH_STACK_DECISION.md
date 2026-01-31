# 🏗️ Tech Stack Decision: SoftArchitect AI Architecture

> **Versión:** 1.0
> **Fecha:** 30/01/2026
> **Estado:** ✅ Definido y Justificado
> **Cambio Última vez:** Frontend → Flutter (Desktop-First)

---

## 📖 Tabla de Contenidos

1. [Decisiones Principales](#decisiones-principales)
2. [Frontend: Flutter vs Alternativas](#frontend-flutter-vs-alternativas)
3. [Backend: FastAPI vs Alternativas](#backend-fastapi-vs-alternativas)
4. [IA Engine: Ollama vs Alternativas](#ia-engine-ollama-vs-alternativas)
5. [Vector Store: ChromaDB vs Alternativas](#vector-store-chromadb-vs-alternativas)
6. [Persistencia: SQLite vs Alternativas](#persistencia-sqlite-vs-alternativas)
7. [Stack Completo Visualizado](#stack-completo-visualizado)

---

## Decisiones Principales

```
┌─────────────────────────────────────────────────────────┐
│ SoftArchitect AI - Tech Stack Decision Matrix           │
├──────────────┬──────────────────┬──────────────┬────────┤
│ Layer        │ Elegido          │ Alternativa  │ Motivo │
├──────────────┼──────────────────┼──────────────┼────────┤
│ Frontend     │ ✅ Flutter       │ Electron    │ Native │
│              │                  │ (React)     │ perf   │
│ Backend      │ ✅ FastAPI       │ Django      │ Async  │
│              │                  │ (Python)    │ +RAG   │
│ RAG Engines  │ ✅ LangChain     │ LlamaIndex  │ Proven │
│ Vector DB    │ ✅ ChromaDB      │ Pinecone    │ Local  │
│ LLM          │ ✅ Ollama        │ Groq Cloud  │ Private│
│ Config       │ ✅ SQLite        │ JSON        │ Query  │
│ Deployment   │ ✅ Docker        │ Binary      │ Repeat │
│ CI/CD        │ ✅ GitHub Actions│ Workflows   │ Native │
└──────────────┴──────────────────┴──────────────┴────────┘
```

---

## Frontend: Flutter vs Alternativas

### Decision Matrix

```
┌────────────────────────────┬─────────────┬──────────┬──────────┐
│ Criterio                   │ Flutter     │ Electron │ Web(TS)  │
├────────────────────────────┼─────────────┼──────────┼──────────┤
│ Single Binary              │ ✅ Sí       │ ❌ No    │ ❌ No    │
│ Offline-First              │ ✅ Sí       │ ✅ Sí    │ ❌ No    │
│ Performance                │ ✅ 60fps    │ ⚠️ 30fps │ ✅ 60fps │
│ Bundle Size                │ ✅ 50MB     │ ❌ 200MB │ ✅ 5MB   │
│ Desktop Native Feel        │ ✅ Alto     │ ⚠️ Medio │ ❌ Bajo  │
│ Hot Reload                 │ ✅ Sí       │ ✅ Sí    │ ✅ Sí    │
│ Tipo de Devs Disponibles   │ ⚠️ Pocos    │ ✅ Muchos│ ✅ Muchos│
│ Deploy Multi-Platform      │ ✅ Simple   │ ✅ Simple│ ✅ Simple│
│ UI Customization           │ ✅ Fácil    │ ✅ Fácil │ ✅ Muy   │
│ State Management Maduro    │ ✅ Riverpod │ ✅ Redux │ ✅ Zustand
│ Costo de Operación         │ ✅ $0       │ ✅ $0    │ ✅ $0    │
└────────────────────────────┴─────────────┴──────────┴──────────┘

WINNER: Flutter
Razones:
  1. Single binary (distribución = copia archivo)
  2. Performance nativa (UI responsiva siempre)
  3. Offline-first (zero internet needed)
  4. Bundle pequeño (distribución fácil)
```

### Justificación

```
¿Por qué NO Electron?
  ❌ Bundle de 200MB (distribución = dolor de cabeza)
  ❌ CPU/Memory heavy (Chromium embebido)
  ❌ Performance mediocre para refresh frecuente

¿Por qué NO Web (TypeScript)?
  ❌ Requiere servidor web running
  ❌ No offline-first (crítico para IA local)
  ❌ UX desktop mediocre

¿Por qué SÍ Flutter?
  ✅ Desktop app nativa (single binary)
  ✅ Excelente performance (Dart + Skia rendering)
  ✅ Offline-first (ChromaDB local, sin internet)
  ✅ Multi-platform (Windows, Mac, Linux, iOS, Android con mismo código)
  ✅ Riverpod = state management moderno
```

---

## Backend: FastAPI vs Alternativas

### Decision Matrix

```
┌────────────────────────────┬──────────┬─────────┬──────────┐
│ Criterio                   │ FastAPI  │ Django  │ Go+Gin   │
├────────────────────────────┼──────────┼─────────┼──────────┤
│ Async-First                │ ✅ Nativo│ ⚠️ Plus │ ✅ Nativo│
│ Documentación API Auto     │ ✅ Sí    │ ❌ Manua│ ❌ No    │
│ Type Safety                │ ✅ Total │ ⚠️ Part │ ✅ Total │
│ Learning Curve             │ ✅ Fácil │ ⚠️ Media│ ✅ Fácil │
│ RAG Integration (LangChain)│ ✅ Ideal │ ❌ Raro │ ❌ No    │
│ Performance (req/sec)      │ ✅ 10K+ │ ⚠️ 5K  │ ✅ 50K+ │
│ Developers Disponibles     │ ✅ Muchos│ ✅ Muchos│ ⚠️ Menos │
│ Dependencias Setup         │ ✅ pip   │ ✅ pip  │ ✅ 1 exe │
│ Prototipado Rápido        │ ✅ 1 día │ ⚠️ 2-3d │ ✅ 1 día │
│ Costo de Operación         │ ✅ Bajo  │ ✅ Bajo │ ✅ Muy B │
│ Integracion con Python AI  │ ✅ Native│ ✅ Sí   │ ❌ No    │
└────────────────────────────┴──────────┴─────────┴──────────┘

WINNER: FastAPI
Razones:
  1. Async-first (ideal para I/O: LLM, ChromaDB calls)
  2. Documentación automática (Swagger + ReDoc)
  3. Integración perfecta con LangChain (Python)
  4. Type hints (Pydantic validation)
  5. Performance suficiente para RAG
```

### Justificación

```
¿Por qué NO Django?
  ❌ Más lento (syncrono por defecto)
  ❌ Overkill para una API RAG (necesita DB admin, auth, templates)
  ❌ Mejoró async pero no es first-class

¿Por qué NO Go+Gin?
  ❌ LangChain es Python-first (tendrías que hacer bindings)
  ❌ Compiling adds friction a desarrollo iterativo
  ❌ Overkill de performance si la botella es LLM (siempre tarda segundos)

¿Por qué SÍ FastAPI?
  ✅ Async nativo (I/O-bound RAG queries)
  ✅ LangChain integración directa
  ✅ Documentación automática (sin swagger yaml)
  ✅ Pydantic validation (type safety)
  ✅ Fast enough (LLM es bottleneck, no FastAPI)
  ✅ Prototipado rápido
```

---

## IA Engine: Ollama vs Alternativas

### Decision Matrix

```
┌────────────────────────────┬─────────┬──────────┬───────────┐
│ Criterio                   │ Ollama  │ Groq API │ OpenAI    │
├────────────────────────────┼─────────┼──────────┼───────────┤
│ Privacy (datos locales)    │ ✅ 100% │ ⚠️ Groq  │ ❌ 0%     │
│ Offline Capability         │ ✅ Sí   │ ❌ No    │ ❌ No     │
│ Latencia (p50)             │ ⚠️ 2-3s │ ✅ <500ms│ ✅ <1s    │
│ Costo por millón tokens    │ ✅ $0   │ ✅ $0.15 │ ❌ $2-10  │
│ Calidad de respuestas      │ ✅ 7/10 │ ✅ 8.5/10│ ✅ 9.5/10 │
│ Modelos Disponibles        │ ✅ 20+  │ ✅ LLama │ ❌ 1-2    │
│ Setup Complexity           │ ✅ Bajo │ ✅ Muy B │ ✅ Muy B  │
│ GPU Memory Required        │ ⚠️ 8GB+ │ ✅ Ninguna│ ✅ Ninguna│
│ Dependency on External API │ ❌ Sí   │ ✅ No    │ ❌ Sí     │
│ SLA/Uptime Guarantee       │ ❌ No   │ ✅ 99.9% │ ✅ 99.9%  │
└────────────────────────────┴─────────┴──────────┴───────────┘

WINNER: Ollama (Local-First)
FALLBACK: Groq (Consentimiento usuario)

Razones:
  1. Privacy absoluta (cero datos enviados)
  2. Offline-first (crítico para SoftArchitect)
  3. Gratis (zero costo operacional)
  4. Modelo local (Mistral-7B recomendado)
```

### Justificación

```
¿Por qué NO OpenAI?
  ❌ $2-10 por millón tokens ($$$ a escala)
  ❌ Privacidad: datos de usuario a OpenAI
  ❌ Contro
l cero (dependencia vendor)
  ❌ No offline (siempre requiere internet)

¿Por qué NO solo Groq?
  ⚠️ Mejor latencia pero no local
  ⚠️ Datos enviados a Groq (privacidad)
  ✅ OK como fallback si usuario lo elige

¿Por qué SÍ Ollama?
  ✅ 100% local (privacy first)
  ✅ Offline-capable (internet opcional)
  ✅ Modelos abiertos (Mistral, Llama)
  ✅ Cero costo operacional
  ✅ Control total

Modelos recomendados:
  - Mistral-7B (recomendado, rápido + quality)
  - Llama-2-13B (si GPU lo permite)
  - Neural-Chat-7B (eficiente)
```

---

## Vector Store: ChromaDB vs Alternativas

### Decision Matrix

```
┌────────────────────────────┬──────────┬──────────┬────────────┐
│ Criterio                   │ ChromaDB │ Pinecone │ Weaviate   │
├────────────────────────────┼──────────┼──────────┼────────────┤
│ Local/On-Premise           │ ✅ Sí    │ ❌ Cloud │ ✅ Sí      │
│ SQL Backend Option         │ ✅ Sí    │ ❌ No    │ ❌ No      │
│ Offline Capability         │ ✅ Sí    │ ❌ No    │ ⚠️ Partial │
│ Setup Complexity           │ ✅ Muy B │ ✅ Muy B │ ⚠️ Media   │
│ Documentación              │ ✅ Muy B │ ✅ Muy B │ ✅ Buena   │
│ Query Latency (p50)        │ ✅ <10ms │ ⚠️ 50ms │ ✅ <20ms   │
│ Escalabilidad Vector Búsq  │ ⚠️ 50M   │ ✅ ∞    │ ✅ 1B+     │
│ Metadata Filtering         │ ✅ Sí    │ ✅ Sí    │ ✅ Sí      │
│ Multi-Vector Support       │ ✅ Sí    │ ✅ Sí    │ ✅ Sí      │
│ Costo                      │ ✅ $0    │ ❌ $10+/m│ ✅ $0      │
└────────────────────────────┴──────────┴──────────┴────────────┘

WINNER: ChromaDB
Razones:
  1. Local-first (privacy)
  2. SQLite backend (queryable)
  3. Offline-capable
  4. Cero costo
  5. Setup simple (pip install)
```

### Justificación

```
¿Por qué NO Pinecone?
  ❌ Cloud-only (no local-first)
  ❌ Costo $10+/mes (agregado)
  ❌ Privacy: embeddings en Pinecone
  ❌ No offline

¿Por qué SÍ ChromaDB?
  ✅ Local-first (SQLite backend)
  ✅ Offline (critique para SoftArchitect)
  ✅ Cero costo
  ✅ Simple setup
  ✅ Suficiente para 20K docs (nuestra KB)

Limitaciones aceptadas:
  - Máximo ~50M vectores (vs Pinecone ∞)
  - Performance solo para local (vs Pinecone CDN global)
  - Control: SÍ lo queremos (trade-off aceptado)
```

---

## Persistencia: SQLite vs Alternativas

### Decision Matrix

```
┌────────────────────────────┬────────┬─────────┬────────────┐
│ Criterio                   │ SQLite │ Postgres│ JSON Files │
├────────────────────────────┼────────┼─────────┼────────────┤
│ Setup Complexity           │ ✅ Cero│ ⚠️ Media│ ✅ Cero    │
│ Offline Capability         │ ✅ Sí  │ ❌ No   │ ✅ Sí      │
│ Performance (pequeño)      │ ✅ Muy │ ✅ Muy B│ ✅ Muy B   │
│ ACID Compliance            │ ✅ Sí  │ ✅ Sí   │ ❌ No      │
│ Concurrent Writes          │ ⚠️ Lim │ ✅ Sí   │ ❌ Riesgo  │
│ Query Flexibility          │ ✅ SQL │ ✅ SQL  │ ⚠️ Manual  │
│ Costo                      │ ✅ $0  │ ✅ $0   │ ✅ $0      │
│ Escalabilidad (10K+)       │ ⚠️ Lim │ ✅ ∞    │ ❌ Lento   │
│ Tooling (migrations)       │ ⚠️ Bajo│ ✅ Alto │ ❌ Nada    │
└────────────────────────────┴────────┴─────────┴────────────┘

WINNER: SQLite
Razones:
  1. Zero setup (already in Python)
  2. Offline-capable
  3. ACID compliance
  4. Suficiente para metadata
```

---

## Stack Completo Visualizado

```
┌─────────────────────────────────────────────────────────────┐
│                     USUARIO (Desktop)                        │
└────────────────────┬────────────────────────────────────────┘
                     │
            ┌────────▼────────┐
            │ Flutter Desktop │  (Native UI, Offline-first)
            │ (Windows, Linux)│
            │   + Riverpod    │
            └────────┬────────┘
                     │ HTTP/JSON
        ┌────────────▼────────────┐
        │   FastAPI Backend       │  (Python 3.12)
        │   └─ LangChain RAG      │
        │   └─ API Endpoints      │
        └────┬────────────┬──────┘
             │            │
      ┌──────▼────┐  ┌────▼──────────┐
      │ ChromaDB   │  │ SQLite Config │
      │ (Vectors)  │  │ (Metadata)    │
      └─────┬──────┘  └─────┬────────┘
            │                │
      ┌─────▼──────────┐  ┌──▼──────────┐
      │    Ollama      │  │ Local Files │
      │  + Mistral-7B  │  │ (.db, .json)│
      │                │  │             │
      │(LLM Inference) │  │             │
      └────────────────┘  └─────────────┘

Todas las capas se ejecutan LOCALMENTE
Cero datos a la nube (a menos que el usuario lo elige)
Offline-capable
Zero cost (except machine/electricity)
```

---

## Alternativas Rechazadas y Por Qué

### Electron (Frontend)
```
❌ Bundle 200MB (pesado para distribución)
❌ CPU-heavy (Chromium completo)
❌ Performance mediocre para UI frecuente
❌ Overkill para app local
```

### Django (Backend)
```
❌ Synchronous por defecto
❌ Overkill (admin, ORM, templates)
❌ LangChain integration rara
❌ Menos ideal para I/O async (LLM calls)
```

### Pinecone/Weaviate (Vector Store)
```
❌ No local-first
❌ Costo adicional ($10+/mes)
❌ Privacidad: datos a terceros
❌ No offline-capable
```

### JSON Files (Persistencia)
```
❌ No ACID compliance
❌ Queries difíciles (sin SQL)
❌ Performance baja (no indexed)
❌ Riesgo de corrupción (concurrent writes)
```

---

## Trade-offs Aceptados

```
Local-First (GANANCIA)            vs   Escalabilidad global (PÉRDIDA)
  └─ Aceptado: SoftArchitect es single-user local app

Privacy 100% (GANANCIA)            vs   Cloud convenience (PÉRDIDA)
  └─ Aceptado: Privacidad es core value proposition

Latencia <200ms para respuestas  vs   Máxima calidad LLM (PÉRDIDA)
  └─ Aceptado: Mistral-7B es suficiente para decisiones arquitectónicas

Dev team pequeño (GANANCIA)      vs   Enterprise features (PÉRDIDA)
  └─ Aceptado: MVP focused, features después
```

---

## Justificación Final

**SoftArchitect AI Tech Stack** está optimizado para:

✅ **Privacidad Total**: Cero datos enviados (by default)
✅ **Offline-First**: Funciona sin internet
✅ **Performance**: Respuestas <200ms
✅ **Costo Cero**: Libre de licensing
✅ **Simplicity**: Setup = 5 minutos
✅ **MVP Focus**: Decisiones > features

No es la stack "más escalable" o "más enterprise", pero es la stack CORRECTA para las restricciones y valores de SoftArchitect AI. 🎯
