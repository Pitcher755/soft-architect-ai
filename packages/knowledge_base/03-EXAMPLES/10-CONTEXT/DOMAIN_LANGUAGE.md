# 🗣️ Domain Language: SoftArchitect AI

> **Versión:** 1.0
> **Fecha:** 30/01/2026
> **Estado:** ✅ Definido
> **Propósito:** Léxico compartido del proyecto

---

## 📖 Tabla de Contenidos

1. [Conceptos Core](#conceptos-core)
2. [Entidades](#entidades)
3. [Valores](#valores)
4. [Relaciones](#relaciones)
5. [Glosario Completo](#glosario-completo)

---

## Conceptos Core

### Decision (Decisión)

**Definición:** Problema de arquitectura con múltiples opciones evaluadas

```
Estructura:
  ├─ Question: "React vs Angular?"
  ├─ Options: [React, Angular, Vue]
  ├─ Criteria: [Performance, Learning, Ecosystem]
  ├─ Scores: {React: 9/10, Angular: 7/10, ...}
  ├─ Recommendation: "React"
  └─ Rationale: "Mejor performance + ecosystem"

Ejemplo:
  Decision {
    id: "DECIDE-001",
    question: "Frontend framework selection",
    timestamp: 2026-01-30T10:00:00Z,
    user: "john@example.com",
    ...
  }
```

### RAG (Retrieval-Augmented Generation)

**Definición:** Proceso de SoftArchitect: retrieve tech-packs → augment context → generate response

```
Pipeline:
  1. Retriever: ChromaDB búsqueda de docs
  2. Augmenter: Añadir contexto usuario
  3. Generator: LLM (Ollama) genera respuesta
  4. Formatter: JSON estructurado

Output: Decision Matrix (estructurada)
```

### Tech-Pack

**Definición:** Documentación curada de 1-2 tecnologías (43 packs disponibles)

```
Composición:
  ├─ FRONTEND/ (13 packs: React, Angular, Vue, Flutter, etc)
  ├─ BACKEND/ (12 packs: FastAPI, Django, Go, Java, etc)
  ├─ DATA/ (3 packs: PostgreSQL, MongoDB, Redis)
  └─ DEVOPS_CLOUD/ (6 packs: Docker, K8s, AWS, Azure, etc)

Contenido por pack:
  - Overview (qué es)
  - When to use (cuándo)
  - Trade-offs (ventajas/desventajas)
  - Code examples (ejecutables)
  - Cost estimate (TCO)
  - Learning resources (links)
```

### Vector Store (ChromaDB)

**Definición:** Base de datos de embeddings para búsqueda semántica

```
Uso en SoftArchitect:
  - Todos los 43 tech-packs vectorizados
  - Usuario pregunta → búsqueda de vectores similares
  - Top-K resultados → usado como RAG context
  - Permite búsqueda sin keywords exactos

Ventaja: Búsqueda semántica (no depende de keywords)
```

---

## Entidades

### User (Usuario)

```
Propiedades:
  - id: UUID
  - email: string
  - name: string
  - created_at: timestamp
  - last_login: timestamp
  - preferences: JSON

Relaciones:
  - has many: Decisions
  - has many: SavedSearch
  - has one: Profile
```

### Question (Pregunta)

```
Propiedades:
  - id: UUID
  - text: string (la pregunta del usuario)
  - user_id: FK
  - timestamp: timestamp
  - resolved: boolean
  - decision_id: FK (si genera decision)

Ejemplos:
  - "React vs Angular for SPA?"
  - "Best database for microservices?"
  - "How to deploy FastAPI to Kubernetes?"
```

### DecisionMatrix (Matriz de Decisión)

```
Propiedades:
  - id: UUID
  - decision_id: FK
  - criteria: array[string] (Performance, Learning, Ecosystem)
  - options: array[string] (React, Angular, Vue)
  - scores: dict[string, float] (0-10)
  - recommendation: string (opción recomendada)
  - rationale: string (por qué)

Estructura JSON:
  {
    "criteria": ["Performance", "Learning", "Ecosystem"],
    "options": ["React", "Angular", "Vue"],
    "matrix": [
      {"option": "React", "scores": [9, 7, 10]},
      {"option": "Angular", "scores": [7, 5, 8]}
    ],
    "recommendation": "React",
    "rationale": "Best performance + learning"
  }
```

### CodeExample (Ejemplo de Código)

```
Propiedades:
  - id: UUID
  - decision_id: FK
  - language: string (Python, Dart, SQL)
  - title: string
  - code: string (código executable)
  - explanation: string
  - source_pack: string (cuál tech-pack)

Ejemplo:
  {
    "language": "python",
    "title": "FastAPI basic setup",
    "code": "from fastapi import FastAPI\napp = FastAPI()",
    "source_pack": "BACKEND/FastAPI.md"
  }
```

---

## Valores

### Priority Levels

```
High:    Decisión crítica, bloquea proyecto
Medium:  Importante, afecta timeline
Low:     Importante, pero no urgente
```

### EstimationSizes

```
XS: <1 hour
S:  1-2 hours
M:  4-8 hours
L:  1-2 days
XL: >2 days
```

### Status

```
PENDING:    Esperando input
PROCESSING: Generando respuesta
COMPLETED:  Entregada
ARCHIVED:   Histórico
STARRED:    Importante (saved)
```

---

## Relaciones

### Decision → CodeExamples

```
Relación: 1-to-many
  - 1 Decision puede tener múltiples CodeExamples
  - Cada language (Python, Dart, SQL)
  - Cada ejemplo de cada opción

Ejemplo:
  Decision "React vs Angular"
    ├─ CodeExample (React - JavaScript)
    ├─ CodeExample (Angular - TypeScript)
    └─ CodeExample (Setup - npm vs ng)
```

### Decision → TechPacks

```
Relación: many-to-many
  - 1 Decision usa múltiples tech-packs
  - 1 Tech-pack pode ser usado en múltiples decisions

Ejemplo:
  Decision "React vs Angular" usa:
    ├─ FRONTEND/React.md
    ├─ FRONTEND/Angular.md
    └─ FRONTEND/Vue.md
```

### User → Decision

```
Relación: 1-to-many
  - 1 Usuario tiene múltiples decisions
  - Historial personal (query log)
  - Permite tracking de decisiones tomadas

Historial:
  User:
    ├─ Decision 1: React vs Angular (Jan 15, 2026)
    ├─ Decision 2: PostgreSQL vs MongoDB (Jan 20, 2026)
    └─ Decision 3: Docker vs Kubernetes (Jan 25, 2026)
```

---

## Glosario Completo

```
Término                  Definición
─────────────────────────────────────────────────────────────

LLM                      Large Language Model (Ollama)
RAG                      Retrieval-Augmented Generation
Embedding                Vectorización de texto
ChromaDB                 Vector store local
Tech-Pack                Documentación curada de tech
Decision Matrix          Matriz de comparación
Criterion                Un factor de decisión
Option                   Una alternativa a evaluar
Score                    Puntuación (0-10) para option+criterion
Recommendation           Opción recomendada
Rationale                Justificación de recomendación
Context                  Información de usuario (budget, team size)
Query                    Pregunta del usuario
Response                 Decision matrix + examples + cost
Artifact                 Resultado generado (doc, code, etc)
Knowledge Base           Los 43 tech-packs como fuente
Offline-First            Funciona sin internet
Privacy-First            Cero datos a la nube por defecto
Local-First              Todo se ejecuta localmente
Async-First              I/O operations no-blocking
Sanitization             Validar input antes de LLM
Type Safety              Type hints obligatorios
ACID Compliance          Transacciones confiables
Latency                  Tiempo respuesta (p95 <2s)
SLA                      Service Level Agreement
Uptime                   % tiempo disponible (99.9%)
MVP                      Minimum Viable Product
ADR                      Architecture Decision Record
Clean Architecture       Separation of concerns
Hexagonal Architecture   Ports & adapters pattern
Domain Language          Léxico del proyecto
Ubiquitous Language      Mismo vocabulario team+código
```

---

**Domain Language** asegura que todo el equipo habla el mismo idioma. Estas definiciones son referencias en documentación, código, y conversaciones. 🗣️
