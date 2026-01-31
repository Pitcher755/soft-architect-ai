# 📋 Requirements Analysis: SoftArchitect AI MVP

> **Versión:** 1.0
> **Fecha:** 30/01/2026
> **Estado:** ✅ Definido
> **Stakeholders:** Engineering team, Community

---

## 📖 Tabla de Contenidos

1. [Requisitos Funcionales](#requisitos-funcionales)
2. [Requisitos No-Funcionales](#requisitos-no-funcionales)
3. [Restricciones](#restricciones)
4. [Dependencias](#dependencias)
5. [Criterios de Aceptación](#criterios-de-aceptación)

---

## Requisitos Funcionales

### RF-1: Decision Framework

```
USUARIO puede:
  ✅ Hacer preguntas arquitectónicas
  ✅ Recibir Decision Matrix estructurada
  ✅ Ver trade-offs explícitos
  ✅ Acceder a código de ejemplo
  ✅ Calcular costos estimados

EJEMPLO:
  Usuario: "¿React o Angular para SPA?"
  Sistema:
    - Decision Matrix (6 criterios)
    - Ejemplos de código
    - Costos por opción
    - Recomendación contextual
```

**Criterio de Aceptación:**
- [ ] Respuesta en <2 segundos
- [ ] Matriz contiene ≥5 criterios de decisión
- [ ] Código ejemplo es ejecutable
- [ ] Costos estimados incluyen TCO (Total Cost of Ownership)

---

### RF-2: Knowledge Base Search

```
USUARIO puede:
  ✅ Buscar en 20K+ líneas de documentación
  ✅ Filtrar por tecnología
  ✅ Ver ejemplos relacionados
  ✅ Acceder a full documentation

EJEMPLO:
  Usuario busca: "PostgreSQL performance tuning"
  Sistema:
    - Snippets relevantes
    - Links a full docs
    - Relacionados (MySQL, Redis comparisons)
```

**Criterio de Aceptación:**
- [ ] Búsqueda <200ms latencia
- [ ] Top 3 resultados son relevantes (>85% similarity)
- [ ] Cada resultado incluye excerpt (100 chars)
- [ ] Soporta 43+ tecnologías

---

### RF-3: RAG Context Generation

```
SISTEMA debe:
  ✅ Retriever: ChromaDB busca documentos relevantes
  ✅ Contextualize: Considera equipo size, budget, timeframe
  ✅ Generate: LLM produce respuesta contextualizada
  ✅ Format: Matriz + ejemplos + costos + next steps

FLUJO:
  Pregunta → ChromaDB retrieve → LLM context → Response
```

**Criterio de Aceptación:**
- [ ] Respuesta siempre incluye tabla comparativa
- [ ] Código ejemplo es production-ready
- [ ] Costos desglosados (hosting, licensing, DevOps)
- [ ] Recomendación es clara y justificada

---

### RF-4: Offline Operation

```
SISTEMA debe:
  ✅ Funcionar sin internet
  ✅ Usar LLM local (Ollama)
  ✅ Usar vector DB local (ChromaDB)
  ✅ Usar config local (SQLite)

NO debe:
  ❌ Enviar datos a la nube (sin consentimiento)
  ❌ Requerir API keys (por defecto)
  ❌ Fallar si internet cae
```

**Criterio de Aceptación:**
- [ ] App funciona completamente offline
- [ ] Cero requests a external APIs (en modo default)
- [ ] Todo dato guardado localmente
- [ ] SLA: 99.9% uptime (local server)

---

### RF-5: Multi-Platform Support

```
USUARIO puede usar en:
  ✅ Windows 10+
  ✅ macOS 10.15+
  ✅ Linux (Ubuntu 20.04+)

FUTURO (Nice-to-have):
  - iOS app (SwiftUI)
  - Android app (Compose)
  - Web version (self-hosted option)
```

**Criterio de Aceptación:**
- [ ] Single binary per platform
- [ ] Same UI experience across platforms
- [ ] File distribution <100MB

---

## Requisitos No-Funcionales

### RNF-1: Performance

```
Requisito                       Métrica
────────────────────────────────────────────
Response Latency                <2 segundos (p95)
Search Latency                  <200ms (p95)
UI Responsiveness               No freezes >100ms
Memory Usage                    <500MB (idle)
First Launch                    <10 segundos
Model Load                      <5 segundos (cached)
```

**Medición:**
```bash
# Response time test
time curl -X POST http://localhost:8000/query \
  -d '{"question": "React vs Angular?"}'
# Expected: < 2 segundos
```

---

### RNF-2: Reliability

```
Requisito                       Métrica
────────────────────────────────────────────
Uptime                          99.9% (3.65 horas/año max downtime)
Recovery Time                   <1 minuto after restart
Data Integrity                  ACID compliance (SQLite)
Backup                          Auto backup diario (local)
```

---

### RNF-3: Security

```
Requisito                       Implementación
─────────────────────────────────────────────────
Data at Rest                    Encriptación SQLite (optional)
Data in Transit                 HTTPS (si cloud mode)
Authentication                  Local (no passwords MVP)
Authorization                   Not applicable (single user)
Input Validation                Sanitize all LLM inputs
Secrets Management              .env file (never committed)
```

---

### RNF-4: Scalability

```
Requisito                       Métrica
────────────────────────────────────────────
Documentación Size              Soportar 20K+ líneas (✅ Hoy)
Vectores en ChromaDB            Soportar 50K+ vectors
Concurrent Queries              1 user (MVP), 10+ (future)
Response Quality                Score ≥7/10 (similar a GPT-3.5)
```

---

### RNF-5: Usability

```
Requisito                       Métrica
────────────────────────────────────────────
Setup Time                      <5 minutos (primer usuario)
Learning Curve                  <1 hora para proficiency
UI Intuitiveness                80%+ user prefer vs web search
Documentation                   <15 min para entender architecture
Error Messages                  ✅ Clara y accionable
```

---

## Restricciones

### CONST-1: Privacidad (Core Value)

```
"Un byte de dato de usuario NUNCA sale sin consentimiento"

Restricción:
  ✅ Todos los datos local por default
  ✅ Zero API calls to cloud (default)
  ✅ User puede opt-in a cloud (Groq)
  ✅ Encriptación en tránsito si cloud

Violación:
  ❌ Vendría datos a OpenAI/Anthropic sin permiso
  ❌ Logging de queries sin consentimiento
  ❌ Tracking de usuario
```

---

### CONST-2: Open Source

```
Restricción:
  ✅ MIT License
  ✅ Source code público
  ✅ Community contributions bienvenidas
  ✅ No proprietary blobs

Implicaciones:
  ❌ No usar tech cerrada (esotéricas)
  ❌ Documentar decisiones arquitectónicas
  ❌ Mantener código limpio
```

---

### CONST-3: Budget & Resources

```
Recursos Disponibles:
  - 1 Architect Lead (ArchitectZero)
  - Engineering community contributors
  - Infrastructure: GitHub (free tier)

Budget:
  - Server hosting: $0 (local app)
  - LLM: $0 (Ollama local)
  - Vector DB: $0 (ChromaDB local)
  - Total: $0/month

Implicación:
  ❌ No escalar horizontalmente (MVP = local)
  ❌ No usar managed services
```

---

## Dependencias

### DEP-1: Tecnologías Externas

```
Tecnología           Versión      Requisito
──────────────────────────────────────────
Python               3.12+        Backend
Flutter              3.x+         Frontend
FastAPI              0.100+       Web framework
LangChain            0.1.0+       RAG orchestration
ChromaDB             0.3.21+      Vector store
Ollama               latest       LLM runtime
SQLite               3.35+        Config DB
Docker               20.10+       Deployment
```

### DEP-2: Documentación

```
Documentación Requerida:
  ✅ 43 archivos Tech Pack knowledge (20K+ líneas)
  ✅ Ejemplos de código ejecutable
  ✅ Decision matrices
  ✅ Trade-offs explícitos
  ✅ Costos estimados

Estado: ✅ YA COMPLETADO (Sesión actual)
```

---

## Criterios de Aceptación

### MVP DONE Criteria

```
✅ FUNCIONALIDAD
  [ ] Usuario puede hacer preguntas arquitectónicas
  [ ] Recibe Decision Matrix estructurada
  [ ] Accede a 20K+ líneas documentación
  [ ] Funciona completamente offline

✅ PERFORMANCE
  [ ] Response latency <2 segundos
  [ ] Search latency <200ms
  [ ] Memory usage <500MB
  [ ] Zero freezes en UI

✅ QUALITY
  [ ] Tests >80% code coverage
  [ ] Zero security issues (bandit/pip-audit)
  [ ] Documentación completa
  [ ] Setup funciona en <5 minutos

✅ DEPLOYMENT
  [ ] Single binary per platform
  [ ] Works on Windows/Mac/Linux
  [ ] No external dependencies (excepto Ollama)
  [ ] Docker Compose para dev setup

✅ DOCUMENTATION
  [ ] README (setup + primeros pasos)
  [ ] CONTRIBUTING.md (para collaborators)
  [ ] ADRs (Architecture Decision Records)
  [ ] 03-EXAMPLES/ (este proyecto completo)
```

### Success Metrics

```
Métrica                         Target      Status
────────────────────────────────────────────────────
Pregunta → Respuesta time      <2s         ✅ Goal
Response relevance score       ≥7/10       ✅ Mistral-7B target
User setup time                <5 min      ✅ Goal
Documentation coverage         100%        ✅ 43 files done
Test coverage                  ≥80%        ⏳ Next phase
Uptime (local)                 99.9%       ✅ Goal
Zero data leaks                100%        ✅ Audited
```

---

## User Stories (Ejemplos)

### US-1: Decision Support

```
AS A   software architect
WANT   to compare React vs Angular quickly
SO     I can make informed decision in minutes, not weeks

ACCEPTANCE CRITERIA:
  ✅ Recibo matriz de decisión (≥6 criterios)
  ✅ Veo ejemplos de código para cada
  ✅ Tengo estimado de costo total
  ✅ Hay recomendación contextual

EXAMPLE:
  INPUT:   "React vs Angular for SPA?"
  OUTPUT:  Matriz + ejemplos + $87/mes estimate + recomendación
  TIME:    <2 segundos
```

### US-2: Learn New Stack

```
AS A   developer new to Go
WANT   to learn best practices and patterns
SO     I can write idiomatic Go code

ACCEPTANCE CRITERIA:
  ✅ Búsqueda devuelve Go learning path
  ✅ Incluye código ejecutable examples
  ✅ Muestra common gotchas/mistakes
  ✅ Links a full documentation
```

### US-3: Offline Usage

```
AS A   traveler/remote developer
WANT   to use SoftArchitect without internet
SO     I can make decisions anywhere

ACCEPTANCE CRITERIA:
  ✅ App funciona totalmente offline
  ✅ Consultas devuelven resultados (ChromaDB local)
  ✅ Zero error messages sobre connection
  ✅ Performance igual que online
```

---

**SoftArchitect AI Requirements** está optimizado para MVP: Decisiones arquitectónicas informadas, localmente, offline, con privacidad total. 🎯
