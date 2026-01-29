# 📑 HU-TRACKING: User Stories Index

## 🇬🇧 English

> **Directory:** User Story tracking documentation  
> **Structure:** `doc/03-HU-TRACKING/HU-{Sprint}-{Name}/`  
> **Last Updated:** January 29, 2026

---

## 📊 STATE OF THE UNION

### Sprint 1: Infrastructure & Scaffolding (The Bedrock)

**Goal:** Have a dockerized environment where frontend and backend can run and communicate.

| HU | Name | Owner | Status | Progress | Docs |
|----|------|-------|--------|----------|------|
| **HU-1.1** | Orchestration & Environment | DevOps | 🔄 IN PROGRESS | 14% | [→ Go](HU-1.1-DOCKER-SETUP/) |
| HU-1.2 | Backend Skeleton (FastAPI) | Backend Lead | ⏳ PENDING | 0% | [→ Go](HU-1.2-BACKEND-SKELETON/) |

### Sprint 2: RAG Brain (Knowledge Injection)

**Goal:** Provide memory to the system by ingesting Tech Packs and vectorizing them.

| HU | Name | Owner | Status | Progress | Docs |
|----|------|-------|--------|----------|------|
| HU-2.1 | Knowledge Ingestion | Backend | ⏳ PENDING | 0% | [→ Go](HU-2.1-RAG-INGESTION/) |
| HU-2.2 | Vectorization to ChromaDB | Backend | ⏳ PENDING | 0% | [→ Go](HU-2.2-VECTORIZATION/) |

### Sprint 3: Interface & Conversation (The Face)

**Goal:** Connect users to the brain through a smooth Flutter UI.

| HU | Name | Owner | Status | Progress | Docs |
|----|------|-------|--------|----------|------|
| HU-3.1 | Chat UI + Markdown | Frontend | ⏳ PENDING | 0% | [→ Go](HU-3.1-CHAT-UI/) |
| HU-3.2 | Streaming + API Connection | Frontend | ⏳ PENDING | 0% | [→ Go](HU-3.2-STREAMING/) |

---

## 🔍 HOW TO USE THIS DIRECTORY

### Structure for Each HU

```
HU-{Sprint}-{Name}/
├── README.md        # Description, acceptance criteria, dependencies
├── PROGRESS.md      # Task checklist (6 phases)
├── ARTIFACTS.md     # Files to generate
└── WORKFLOW.md      # (Optional) Specific workflow details
```

### Example: HU-1.1

```
HU-1.1-DOCKER-SETUP/
├── README.md        → HU description
├── PROGRESS.md      → 60+ checkable items
├── ARTIFACTS.md     → Files: docker-compose.yml, scripts, etc.
└── WORKFLOW.md      → 6 phases (Phase 0-6)
```

### Quick Access

- **Track HU-1.1 progress:**  
  → `doc/03-HU-TRACKING/HU-1.1-DOCKER-SETUP/PROGRESS.md`

- **See HU-1.1 artifacts:**  
  → `doc/03-HU-TRACKING/HU-1.1-DOCKER-SETUP/ARTIFACTS.md`

- **Detailed phases:**  
  → `doc/03-HU-TRACKING/HU-1.1-DOCKER-SETUP/WORKFLOW.md` (if available)

---

## 📌 RULES FOR DOCUMENTING HUs

1. **Directory Name:** `HU-{ID}-{NAME-IN-UPPERCASE}`
   - Example: `HU-1.1-DOCKER-SETUP`, `HU-2.1-RAG-INGESTION`

2. **Required Files:**
   - `README.md` - Context, criteria, dependencies
   - `PROGRESS.md` - 6-phase checklist
   - `ARTIFACTS.md` - Generated files list

3. **Optional Files:**
   - `WORKFLOW.md` - Detailed phases (if complex)
   - `DECISIONS.md` - Technical decisions made
   - `LESSONS.md` - Lessons learned (post-completion)

4. **Updates:**
   - Update `PROGRESS.md` after each phase
   - Update this index (README.md) with status
   - Keep links functional

5. **Git Convention:**
   - Create branch: `git checkout -b feature/hu-{id}-{name}`
   - Commit: `feat(hu-{id}): description`
   - PR: Reference `Fixes #HU-{id}`

---

## 🔗 REFERENCES

### Source of Truth
- [context/40-ROADMAP/USER_STORIES_MASTER.en.json](../../context/40-ROADMAP/USER_STORIES_MASTER.en.json) - Official HU definition
- [AGENTS.md](../../AGENTS.md) - Architecture rules
- [doc/INDEX.md](../INDEX.md) - Documentation index

### Related
- [doc/01-PROJECT_REPORT/CONTEXT_COVERAGE_REPORT.en.md](../01-PROJECT_REPORT/CONTEXT_COVERAGE_REPORT.en.md) - Coverage report
- [doc/02-SETUP_DEV/SETUP_GUIDE.en.md](../02-SETUP_DEV/SETUP_GUIDE.en.md) - Setup guide
- [doc/02-SETUP_DEV/DOCKER_COMPOSE_GUIDE.en.md](../02-SETUP_DEV/DOCKER_COMPOSE_GUIDE.en.md) - Docker compose guide

---

## ⚙️ STANDARD WORKFLOW

For each HU follow this flow:

```
1. Create branch: git checkout -b feature/hu-{id}-{name}
2. Create directory: doc/03-HU-TRACKING/HU-{id}-{NAME}/
3. Create README, PROGRESS, ARTIFACTS
4. Update this index with the HU link
5. Execute Phase 0 (Preparation)
6. Execute Phases 1-6 (Iterative)
7. Mark as COMPLETED when Definition of Done ✅
8. Merge PR into develop
9. Create tag: git tag -a v{version} -m "Release HU-{id}"
```

---

## 📊 METRICS

### Documentation Coverage
- ✅ HU-1.1: 100% (README, PROGRESS, ARTIFACTS)
- ⏳ HU-1.2: 0% (Pending)
- ⏳ HU-2.1: 0% (Pending)
- ⏳ HU-2.2: 0% (Pending)
- ⏳ HU-3.1: 0% (Pending)
- ⏳ HU-3.2: 0% (Pending)

### Progress Overview
```
Phase 0 (Prep):   ██████░░░░░░░░░░░░░░░░░░░░░░ 100% (HU-1.1)
Phase 1 (TDD):    ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  0% (All)
Phase 2 (Code):   ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  0% (All)
Phase 3 (Hard):   ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  0% (All)
Phase 4 (Docs):   ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  0% (All)
Phase 5 (Test):   ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  0% (All)
Phase 6 (Git):    ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  0% (All)
```

---

**Last Updated:** January 29, 2026  
**Owner:** ArchitectZero (Lead Software Architect)

---

## 🇪🇸 Español

> **Directorio:** Documentación de seguimiento por User Story (HU)  
> **Estructura:** `doc/03-HU-TRACKING/HU-{Sprint}-{Name}/`  
> **Última Actualización:** 29 de Enero de 2026

---

## 📊 STATE OF THE UNION

### Sprint 1: Infraestructura y Scaffolding (The Bedrock)

**Goal:** Tener un entorno 'Dockerizado' donde Frontend y Backend se ejecuten y comuniquen básicamente.

| HU | Nombre | Owner | Status | Progreso | Docs |
|----|--------|-------|--------|----------|------|
| **HU-1.1** | Orquestación y Entorno | DevOps | 🔄 EN PROGRESO | 14% | [→ Ir](HU-1.1-DOCKER-SETUP/) |
| HU-1.2 | Backend Skeleton (FastAPI) | Backend Lead | ⏳ PENDIENTE | 0% | [→ Ir](HU-1.2-BACKEND-SKELETON/) |

### Sprint 2: El Cerebro RAG (Knowledge Injection)

**Goal:** Dotar al sistema de memoria. Que sea capaz de leer los Tech Packs y vectorizarlos.

| HU | Nombre | Owner | Status | Progreso | Docs |
|----|--------|-------|--------|----------|------|
| HU-2.1 | Ingesta de Conocimiento | Backend | ⏳ PENDIENTE | 0% | [→ Ir](HU-2.1-RAG-INGESTION/) |
| HU-2.2 | Vectorización a ChromaDB | Backend | ⏳ PENDIENTE | 0% | [→ Ir](HU-2.2-VECTORIZATION/) |

### Sprint 3: Interfaz y Conversación (The Face)

**Goal:** Conectar al usuario con el cerebro a través de una UI fluida en Flutter.

| HU | Nombre | Owner | Status | Progreso | Docs |
|----|--------|-------|--------|----------|------|
| HU-3.1 | Chat UI + Markdown | Frontend | ⏳ PENDIENTE | 0% | [→ Ir](HU-3.1-CHAT-UI/) |
| HU-3.2 | Streaming + API Connection | Frontend | ⏳ PENDIENTE | 0% | [→ Ir](HU-3.2-STREAMING/) |

---

## 🔍 CÓMO USAR ESTE DIRECTORIO

### Estructura de cada HU

```
HU-{Sprint}-{Name}/
├── README.md        # Descripción, criterios de aceptación, dependencias
├── PROGRESS.md      # Checklist de tareas (6 fases)
├── ARTIFACTS.md     # Lista de archivos a generar
└── WORKFLOW.md      # (Opcional) Detalles de workflow específico
```

### Ejemplo: HU-1.1

```
HU-1.1-DOCKER-SETUP/
├── README.md        → Descripción de la HU
├── PROGRESS.md      → 60+ items checkeable
├── ARTIFACTS.md     → Archivos: docker-compose.yml, scripts, etc.
└── WORKFLOW.md      → 6 fases (Fase 0-6)
```

### Acceso Rápido

- **Quiero ver el progreso de HU-1.1:**  
  → `doc/03-HU-TRACKING/HU-1.1-DOCKER-SETUP/PROGRESS.md`

- **Quiero saber qué archivos genera HU-1.1:**  
  → `doc/03-HU-TRACKING/HU-1.1-DOCKER-SETUP/ARTIFACTS.md`

- **Quiero las fases detalladas:**  
  → `doc/03-HU-TRACKING/HU-1.1-DOCKER-SETUP/WORKFLOW.md` (si existe)

---

## 📌 REGLAS PARA DOCUMENTAR HUs

1. **Nombre del Directorio:** `HU-{ID}-{NOMBRE-EN-MAYUSCULAS}`
   - Ejemplo: `HU-1.1-DOCKER-SETUP`, `HU-2.1-RAG-INGESTION`

2. **Archivos Obligatorios:**
   - `README.md` - Contexto, criterios, dependencias
   - `PROGRESS.md` - Checklist de 6 fases
   - `ARTIFACTS.md` - Lista de generables

3. **Archivos Opcionales:**
   - `WORKFLOW.md` - Fases detalladas (si es muy complejo)
   - `DECISIONS.md` - Decisiones técnicas tomadas
   - `LESSONS.md` - Lecciones aprendidas (post-completitud)

4. **Actualización:**
   - Actualizar `PROGRESS.md` después de cada fase
   - Marcar status en este índice (README.md)
   - Mantener links funcionales

5. **Convención Git:**
   - Crear rama: `git checkout -b feature/hu-{id}-{name}`
   - Commit: `feat(hu-{id}): descripción`
   - PR: Referenciar `Fixes #HU-{id}`

---

## 🔗 REFERENCIAS

### Source of Truth
- [context/40-ROADMAP/USER_STORIES_MASTER.es.json](../../context/40-ROADMAP/USER_STORIES_MASTER.es.json) - Definición oficial de HUs
- [AGENTS.md](../../AGENTS.md) - Reglas de arquitectura
- [doc/INDEX.md](../INDEX.md) - Índice general de documentación

### Relacionados
- [doc/01-PROJECT_REPORT/CONTEXT_COVERAGE_REPORT.es.md](../01-PROJECT_REPORT/CONTEXT_COVERAGE_REPORT.es.md) - Reporte de cobertura
- [doc/02-SETUP_DEV/SETUP_GUIDE.es.md](../02-SETUP_DEV/SETUP_GUIDE.es.md) - Guía de setup
- [doc/02-SETUP_DEV/DOCKER_COMPOSE_GUIDE.es.md](../02-SETUP_DEV/DOCKER_COMPOSE_GUIDE.es.md) - Guía de Docker Compose

---

## ⚙️ FLUJO DE TRABAJO ESTÁNDAR

Para cada HU seguir este flujo:

```
1. Crear rama: git checkout -b feature/hu-{id}-{name}
2. Crear directorio: doc/03-HU-TRACKING/HU-{id}-{NAME}/
3. Crear README, PROGRESS, ARTIFACTS
4. Actualizar este índice con link a la HU
5. Ejecutar Fase 0 (Preparación)
6. Ejecutar Fases 1-6 (Iterativas)
7. Marcar como COMPLETADA cuando Definition of Done ✅
8. Mergear PR a develop
9. Crear tag: git tag -a v{version} -m "Release HU-{id}"
```

---

## 📊 MÉTRICAS

### Cobertura de Documentación
- ✅ HU-1.1: 100% (README, PROGRESS, ARTIFACTS)
- ⏳ HU-1.2: 0% (Pendiente)
- ⏳ HU-2.1: 0% (Pendiente)
- ⏳ HU-2.2: 0% (Pendiente)
- ⏳ HU-3.1: 0% (Pendiente)
- ⏳ HU-3.2: 0% (Pendiente)

### Progress Overview
```
Fase 0 (Prep):   ██████░░░░░░░░░░░░░░░░░░░░░░ 100% (HU-1.1)
Fase 1 (TDD):    ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  0% (All)
Fase 2 (Code):   ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  0% (All)
Fase 3 (Hard):   ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  0% (All)
Fase 4 (Docs):   ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  0% (All)
Fase 5 (Test):   ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  0% (All)
Fase 6 (Git):    ░░░░░░░░░░░░░░░░░░░░░░░░░░░░░  0% (All)
```

---

**Última Actualización:** 29 de Enero de 2026  
**Responsable:** ArchitectZero (Lead Software Architect)
