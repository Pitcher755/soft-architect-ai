# 🎯 PLAN MAESTRO DE IMPLEMENTACIÓN: HU-3.x Proyecto-First Refactor (Sprint 3)

> **Fecha:** 02/02/2026
> **Versión:** 1.0 - Plan Integral
> **Estado:** ✅ LISTO PARA EJECUCIÓN
> **Responsable:** ArchitectZero (AI Lead) + Development Team
> **Rama Base:** `feature/ui-proyecto-shell` (rebasada sobre `develop` - e948025)

---

## 📖 Tabla de Contenidos

1. [Resumen Ejecutivo](#-resumen-ejecutivo)
2. [Visión General del Refactor](#-visión-general-del-refactor)
3. [Cronograma de Implementación (8 Semanas)](#-cronograma-de-implementación-8-semanas)
4. [Estructura de Ramas y Git Workflow](#-estructura-de-ramas-y-git-workflow)
5. [Detalles por Fase](#-detalles-por-fase)
6. [Asignación de Recursos](#-asignación-de-recursos)
7. [Riesgos y Mitigaciones](#-riesgos-y-mitigaciones)
8. [Métricas de Éxito](#-métricas-de-éxito)
9. [Checklist de Hitos](#-checklist-de-hitos)
10. [Apéndices](#-apéndices)

---

## 🎯 Resumen Ejecutivo

### Propósito

Refactorizar Sprint 3 de **Chat-First** (3 HUs, 50 pts) a **Proyecto-First Sequential Documento Generation** (5 HUs, 70 pts) para mejorar UX, control del usuario y calidad de salidas documentoales.

### Cambio Fundamental

```
ANTES: Usuario chatea → IA responde → [Usuario copia/pega]
DESPUÉS: Usuario crea Proyecto → IA propone 25 documentos secuenciales → Usuario valida cada uno → Documentación completa
```

### Números Clave

| Métrica | Valor |
|---------|-------|
| **Total Puntos** | 70 pts |
| **Duración** | 8 semanas (vs. 6 anterior) |
| **HUs** | 5 (HU-3.1 a HU-3.5) |
| **Ramas** | 5 (1 por HU) |
| **Pruebaing Target** | >85% cobertura |
| **Inicio Esperado** | 06/02/2026 |
| **Finalización** | 01/04/2026 |

### Decisión Requerida

**¿Proceder con refactor Proyecto-First?**

- ✅ **SÍ** → Ejecutar este plan
- ❌ **NO** → Mantener HU-3.x original
- 🤔 **MODIFICAR** → Especificar cambios

---

## 🏗️ Visión General del Refactor

### Modelo Actual (HU-3.x v1 - Chat-First)

```
Arquitectura Chat-First:
┌────────────────────────────────┐
│  Usuario                       │
│  └─ Abre app                   │
│     └─ Ve ChatScreen           │
│        └─ Escribe en chat      │
│           └─ IA responde       │
│              └─ [Usuario copia]│
│                 └─ FINITO      │
└────────────────────────────────┘

Problemas:
- ❌ Sin persistencia explícita
- ❌ Usuario responsable de guardar
- ❌ Sin validación de propuestas
- ❌ Generación "libre" sin guía
- ❌ Sin control de flujo
```

### Modelo Propuesto (HU-3.x v2 - Proyecto-First Sequential)

```
Arquitectura Project-First Sequential:
┌──────────────────────────────────────────┐
│  Usuario                                 │
│  └─ Crea Proyecto (nombre + ruta)       │
│     └─ Auto-crean dirs: context/10-40/  │
│        └─ Selecciona proyecto            │
│           └─ ProjectDashboard            │
│              ├─ ChatPanel                │
│              ├─ FileTreePanel (live)     │
│              └─ ProgressBar (Doc N/25)   │
│                 └─ IA propone DOC 1      │
│                    ├─ Usuario: ✅ Valida │
│                    │  └─ Persiste        │
│                    │     └─ DOC 2        │
│                    └─ Usuario: 🔄 Itera  │
│                       └─ Chat refina    │
│                          └─ IA regenera │
│                             └─ Valida   │
│                                └─ ...   │
│                                   DOC25 │
│        └─ ✅ Documentación completa     │
└──────────────────────────────────────────┘

Beneficios:
- ✅ Persistencia automática (tras validación)
- ✅ Usuario controla cada paso
- ✅ Validación explícita
- ✅ RAG 100% guiado por templates
- ✅ Flujo secuencial garantizado
- ✅ Iteración conversacional
```

### 5 HUs que Componen el Refactor

```
HU-3.1: Project Shell (UI & Navigation)
├─ Responsabilidad: Crear interfaz tipo IDE para gestionar proyectos
├─ Puntos: 13 (XL)
├─ Rama: feature/ui-project-shell
├─ Dependencias: ❌ Ninguna (FOUNDATION)
└─ Estado: 🔴 No iniciado

HU-3.2: FileSystemService (Backend Motor)
├─ Responsabilidad: Motor I/O para crear/leer/escribir archivos
├─ Puntos: 8 (M)
├─ Rama: feature/backend-filesystem-service
├─ Dependencias: HU-3.1 (saber estructura dirs)
└─ Estado: 🔴 No iniciado

HU-3.3: Chat Sequential Document Generation
├─ Responsabilidad: Flujo secuencial de propuestas + validación iterativa
├─ Puntos: 21 (XXL)
├─ Rama: feature/ui-chat-sequential-docs
├─ Dependencias: HU-3.1, HU-3.2 (foundation)
└─ Estado: 🔴 No iniciado

HU-3.4: Error Handling & Validation Gates
├─ Responsabilidad: Resilience layer (retry, timeouts, fallbacks)
├─ Puntos: 5 (S)
├─ Rama: feature/backend-error-handling
├─ Dependencias: HU-3.3 (necesita funcionar antes)
└─ Estado: 🔴 No iniciado

HU-3.5: Streaming & Performance Optimization
├─ Responsabilidad: SSE + UI optimistic + caching
├─ Puntos: 8 (M)
├─ Rama: feature/ui-streaming-optimization
├─ Dependencias: HU-3.3, HU-3.4
└─ Estado: 🔴 No iniciado

TOTAL: 55 pts en 5 HUs independientes
```

---

## ⏱️ Cronograma de Implementación (8 Semanas)

### Timeline General

```
SEMANA 1 (06/02 - 12/02)
├─ Fase 1: Setup & Foundation
├─ HU-3.1: Project Shell (50%)
├─ HU-3.2: FileSystemService (inicio)
└─ Spike: RAG Orchestration design

SEMANA 2 (13/02 - 19/02)
├─ HU-3.1: Project Shell (100% - COMPLETE)
├─ HU-3.2: FileSystemService (100% - COMPLETE)
├─ HU-3.3: Chat Sequential (20%)
└─ Code review + Merge HU-3.1 + HU-3.2

SEMANA 3 (20/02 - 26/02)
├─ HU-3.3: Chat Sequential (50%)
├─ HU-3.4: Error Handling (20%)
└─ Integration HU-3.1 + 3.2

SEMANA 4 (27/02 - 05/03)
├─ HU-3.3: Chat Sequential (80%)
├─ HU-3.4: Error Handling (60%)
└─ Testing HU-3.3 (unit tests)

SEMANA 5 (06/03 - 12/03)
├─ HU-3.3: Chat Sequential (100% - COMPLETE)
├─ HU-3.4: Error Handling (100% - COMPLETE)
├─ HU-3.5: Streaming (50%)
└─ Code review + Merge HU-3.3 + 3.4

SEMANA 6 (13/03 - 19/03)
├─ HU-3.5: Streaming (100% - COMPLETE)
├─ Integration testing (E2E)
└─ Code review + Merge HU-3.5

SEMANA 7 (20/03 - 26/03)
├─ Testing & Bug Fixes
├─ Performance profiling
├─ Documentación final
└─ Staging deployment

SEMANA 8 (27/03 - 01/04)
├─ Final QA
├─ User acceptance testing
├─ Release preparation
└─ Deployment a Producción

DURACIÓN TOTAL: 8 semanas
```

### Hitos Clave

```
✓ HITO 1: HU-3.1 + HU-3.2 Merged (12/02)
  └─ Foundation completa, listo para HU-3.3

✓ HITO 2: HU-3.3 Merged (12/03)
  └─ Core functionality completa

✓ HITO 3: HU-3.4 + HU-3.5 Merged (19/03)
  └─ Todas las HUs merged

✓ HITO 4: Testing Completo (26/03)
  └─ >85% cobertura validada

✓ HITO 5: Release Candidate (01/04)
  └─ Listo para producción
```

---

## 🌿 Estructura de Ramas y Git Workflow

### Nombre Padrón de Ramas

```
Base Branch: develop (no main)

Feature Branches (1 por HU):
├─ feature/ui-project-shell                 ← HU-3.1
├─ feature/backend-filesystem-service       ← HU-3.2
├─ feature/ui-chat-sequential-docs          ← HU-3.3
├─ feature/backend-error-handling           ← HU-3.4
└─ feature/ui-streaming-optimization        ← HU-3.5

Support Branches (si necesario):
├─ bugfix/[description]
├─ hotfix/[description]
└─ spike/rag-orchestration-design
```

### Workflow Git (Gitflow)

```
Step 1: Crear feature branch
$ git checkout develop
$ git pull origin develop
$ git checkout -b feature/[hu-name]

Step 2: Desarrollo + Commits frecuentes
$ git add [files]
$ git commit -m "feat(hu-X.Y): description"

Step 3: Pre-commit validation
- Black formatting
- Ruff linting
- Pyright type checking
- Tests (>85% coverage)

Step 4: Push
$ git push origin feature/[hu-name]

Step 5: Pull Request
- Title: "feat(hu-X.Y): [description]"
- Description: Checklist de criterios aceptación
- Reviewers: Tech Lead + 1 peer

Step 6: Code Review + Merge
- Require 2 approvals (min)
- Squash merge para historial limpio
- Delete branch después de merge

Step 7: CI/CD Pipeline
- GitHub Actions: lint, test, type-check
- All checks must pass before merge
```

### Estado de Ramas (Actual)

```
✅ feature/ui-project-shell (ACTUAL BRANCH)
   └─ Commits: Documentación HU-3 (a486720)
   └─ Status: Rebasada sobre develop (e948025)
   └─ Working tree: Limpio
   └─ Acción: Push + PR cuando usuario confirme

🔴 feature/backend-filesystem-service (PRÓXIMA)
   └─ Acción: Crear después HU-3.1 merged

🔴 feature/ui-chat-sequential-docs (PRÓXIMA)
   └─ Acción: Crear después HU-3.2 merged

🔴 feature/backend-error-handling (PRÓXIMA)
   └─ Acción: Crear después HU-3.3 merged

🔴 feature/ui-streaming-optimization (PRÓXIMA)
   └─ Acción: Crear después HU-3.4 merged
```

---

## 📋 Detalles por Fase

### FASE 0: Pre-Sprint (02/02 - 05/02)

**Objetivo:** Finalizar análisis, obtener aprobaciones, preparar ambiente

#### Tareas

1. **Confirmación de Usuario** (02/02)
   - Usuario confirma: ✅ Proceder / ❌ No / 🤔 Modificar
   - Si no confirmado → STOP
   - Si confirmado → Continuar

2. **Push de Rama** (02/02)
   ```bash
   git push origin feature/ui-project-shell
   ```
   - Rama disponible en GitHub
   - Documentoación visible para revisar

3. **Crear PR Draft** (02/02-03/02)
   - Título: "refactor(hu-3): Proyecto-First Sequential Documento Generation"
   - Base: `develop`
   - Head: `feature/ui-proyecto-shell`
   - Estado: DRAFT (no reviewers aún)

4. **Revisión Arquitectónica** (03/02-04/02)
   - Tech Lead revisa análisis completo
   - Verifica: Especificaciones, Timeline, Riesgos
   - Aprobación: "OK para proceder"

5. **Setup del Ambiente** (04/02-05/02)
   ```bash
   # En cada developer machine
   git checkout develop
   git pull origin develop
   git checkout feature/ui-project-shell

   # Instalar dependencias (if needed)
   cd src/server && poetry install
   cd ../.. && flutter pub get
   ```

#### Criterios de Aceptación
- ✅ Usuario confirmó (✅ Opción)
- ✅ Rama en GitHub con documentoación
- ✅ PR Draft creada
- ✅ Tech Lead aprobó
- ✅ Team está listo

---

### FASE 1: Fundación (Week 1-2)

**Objetivo:** Implementar HU-3.1 + HU-3.2 (Fundación)

#### HU-3.1: Proyecto Shell (Semana 1-2)

**Rama:** `feature/ui-proyecto-shell` (ya existe)

**Responsable:** Frontend Lead

**Tareas:**

1. **Crear ProyectoSidebar Widget** (Day 1-2)
   ```dart
   // src/client/lib/presentation/screens/main_screen.dart

   class ProjectSidebar extends ConsumerWidget {
     // Lista proyectos (scrollable)
     // Botón '+' crear proyecto
     // Selección proyecto
   }
   ```
   - Pruebas: Widget pruebas (100% coverage)

2. **Crear ProyectoDashboard Widget** (Day 3-4)
   ```dart
   // src/client/lib/presentation/screens/project_dashboard.dart

   class ProjectDashboard extends ConsumerWidget {
     // SummaryPanel (título, progreso)
     // ChatPanel (vacío por ahora)
     // FileTreePanel (lista dirs)
   }
   ```
   - Pruebas: Widget pruebas (100% coverage)

3. **Crear Modal CrearProyecto** (Day 5)
   ```dart
   // src/client/lib/presentation/widgets/create_project_dialog.dart

   class CreateProjectDialog extends StatefulWidget {
     // Input: Nombre + Descripción
     // Botón: Crear
   }
   ```
   - Pruebas: Modal interaction pruebas

4. **Conectar con ProyectoProvider (Riverpod)** (Day 6)
   ```dart
   // src/client/lib/providers/project_provider.dart

   final projectListProvider = StreamProvider<List<Project>>((ref) async* {
     // Lee lista de proyectos
     // Sincroniza con backend
   });
   ```

5. **Pruebaing Completo** (Day 7)
   - Unit pruebas: 100% coverage
   - Widget pruebas: Interacciones
   - Integración prueba: E2E flow (crear proyecto)

**Puntos:** 13 (estimado)

**Criterios de Aceptación:**
- ✅ UI sigue DESIGN_SYSTEM.md (Dark Mode)
- ✅ Crear proyecto abre modal
- ✅ Validar modal → Backend (próximo)
- ✅ Dashboard muestra proyectos
- ✅ Responsive (redimensionamiento)
- ✅ Pruebas >85% cobertura

---

#### HU-3.2: ArchivoSystemService (Semana 1-2, paralelo con HU-3.1)

**Rama:** `feature/backend-archivosystem-service` (nueva)

**Responsable:** Backend Lead

**Tareas:**

1. **Crear ArchivoSystemService Core** (Day 1-3)
   ```python
   # src/server/services/filesystem/file_system_service.py

   class FileSystemService:
       async def create_project(
           self,
           project_name: str,
           base_path: str
       ) -> ProjectCreationResult:
           """Crear estructura base + metadatos"""
           # Crear /project_name/
           # Crear /project_name/context/
           # Crear dirs: 10-CONTEXT, 20-REQUIREMENTS, 30-ARCHITECTURE, 35-UX_UI, 40-PLANNING
           # Crear .project.json

       async def get_project_state(
           self,
           project_id: str
       ) -> ProjectFileState:
           """Leer estado actual del proyecto"""
           # List archivos en context/
           # Verificar qué templates faltan

       async def write_validated_document(
           self,
           project_id: str,
           section: str,
           content: str
       ) -> FileWriteResult:
           """Guardar documento validado"""
           # Backup versión anterior
           # Validar permisos
           # Escribir archivo
   ```
   - Pruebas: Unit pruebas (mocked archivo system)

2. **Crear PathValidator** (Day 2-3)
   ```python
   # src/server/services/filesystem/path_validator.py

   class PathValidator:
       @staticmethod
       def validate_project_path(path: str) -> bool:
           """Validar que path es seguro (no ../ escapes)"""

       @staticmethod
       def validate_permissions(path: str) -> bool:
           """Verificar permisos read/write"""
   ```
   - Pruebas: Security pruebas (path traversal, permissions)

3. **Crear Endpoint POST /api/v1/proyectos/crear** (Day 4-5)
   ```python
   # src/server/api/v1/endpoints/projects.py

   @router.post("/projects")
   async def create_project(
       request: CreateProjectRequest
   ) -> ProjectResponse:
       """Crear proyecto y retornar metadatos"""
       # Llamar FileSystemService.create_project()
       # Guardar en DB
       # Retornar respuesta
   ```
   - Pruebas: Integración pruebas (mock DB)

4. **Crear Endpoints GET /api/v1/proyectos** (Day 5)
   ```python
   # GET /projects/ → lista proyectos
   # GET /projects/{id} → metadatos proyecto
   ```

5. **Pruebaing Completo** (Day 6-7)
   - Unit pruebas: ArchivoSystemService (pyprueba)
   - Integración pruebas: Endpoints
   - E2E: Crear proyecto + verificar estructura en disk

**Puntos:** 8 (estimado)

**Criterios de Aceptación:**
- ✅ crear_proyecto() crea estructura correcta
- ✅ get_proyecto_state() retorna docs existentes
- ✅ write_validated_documento() crea backup
- ✅ Validación de permisos funciona
- ✅ Path traversal prevenido
- ✅ Endpoint POST /proyectos retorna JSON
- ✅ Pruebas >90% cobertura

---

#### Spike: RAG Orchestration Design (Week 1)

**Responsable:** AI/RAG Specialist

**Objetivo:** Diseñar arquitectura para HU-3.3

**Tareas:**

1. **Analizar Templates** (Day 1-2)
   - Revisar 01-TEMPLATES/ en packages/knowledge_base
   - Mapear 25 templates → fases 10-CONTEXT, 20-REQUIREMENTS, etc.
   - Documentoar dependencias (Doc X requiere output de Doc Y)

2. **Diseñar Orquestador RAG** (Day 3-4)
   ```python
   # Pseudocódigo de RAG Orchestrator

   class RAGOrchestrator:
       """Orquesta la generación secuencial de documentos"""

       def __init__(self, project_context: ProjectContext):
           self.project = project_context
           self.doc_queue = [...]  # 25 docs en orden
           self.rag_service = RAGService()

       async def generate_next_document(self):
           """Generar siguiente documento"""
           # 1. Obtener template correcto
           # 2. Inyectar contexto del proyecto
           # 3. Inyectar salida de documentos previos
           # 4. Llamar LLM (Ollama/Groq)
           # 5. Retornar propuesta
   ```

3. **Documentoar State Machine** (Day 5)
   - Diagrama: Estados posibles por documentoo
   - Transiciones: Propuesto → Validado → Guardado
   - Excepciones: Qué pasa si usuario rechaza

**Deliverables:**
- [ ] `doc/03-HU-TRACKING/HU-3.3/RAG_ARCHITECTURE_DESIGN.md`
- [ ] Pseudocódigo de RAGOrchestrator
- [ ] Diagrama de secuencia

---

#### Checklist Fase 1

```
Semana 1:
☐ HU-3.1 iniciada (UI widgets 50%)
☐ HU-3.2 iniciada (Backend 50%)
☐ Spike RAG design completada
☐ Equipo sigue ritmo

Semana 2:
☐ HU-3.1 completa (UI 100%, tests >85%)
☐ HU-3.2 completa (Backend 100%, tests >90%)
☐ Code review pasada
☐ PR merged a develop
☐ HITO 1: Foundation Completa ✓
```

---

### FASE 2: Lógica Central (Week 3-5)

**Objetivo:** Implementar HU-3.3 (Chat Sequential Documento Generation)

#### HU-3.3: Chat Sequential Documento Generation

**Rama:** `feature/ui-chat-sequential-docs` (nueva)

**Responsable:** Frontend Lead + Backend Lead (colaborativo)

**Puntos:** 21 (XXL) - La HU más compleja

**Tareas (Resumidas):**

1. **Backend: RAGOrchestrator Implementación** (Week 3-4)
   - Implementar RAGOrchestrator basado en spike
   - Conectar con VectorStoreService (S2)
   - Inyectar contexto de proyecto
   - Manejo de templates

2. **Backend: DocumentoProposalService** (Week 3-4)
   - Servicio que mantiene estado de propuestas
   - Persistencia en BD (PROPOSAL_DOCUMENT table)
   - Historial de versiones

3. **Frontend: ChatPanel Enhanced** (Week 3-5)
   - Input area para chat (user messages)
   - Display de propuestas (DocumentoProposalWidget)
   - Botones: Validar | Iterar
   - ProgressBar: "Doc X/25"

4. **Frontend: DocumentoProposalWidget** (Week 4)
   - Preview de markdown
   - Edit mode opcional
   - Botones de acción

5. **Integración: Chat ↔ RAG Pipeline** (Week 4-5)
   - WebSocket para streaming (opcional SSE en W5)
   - Manejo de estado complejo
   - Error handling (próxima HU)

**Criterios de Aceptación:**
- ✅ User describe proyecto en chat
- ✅ RAG genera Doc 1 propuesta
- ✅ Frontend muestra propuesta
- ✅ User puede "Validar" o "Iterar"
- ✅ Si "Iterar" → Chat refina → RAG regenera
- ✅ Si "Validar" → Doc guardado → Doc 2 propuesta
- ✅ Flujo es secuencial (nunca paralelo)
- ✅ Pruebas >85% cobertura

**Hitos Intermedios:**
- [ ] Week 3: Backend 50%, Frontend 30%
- [ ] Week 4: Backend 100%, Frontend 70%
- [ ] Week 5: Frontend 100%, Integración 100%, Pruebas 100%

---

### FASE 3: Resiliencia & Performance (Week 6)

**Objetivo:** Implementar HU-3.4 + HU-3.5

#### HU-3.4: Error Handling & Validation Gates (Week 5-6)

**Rama:** `feature/backend-error-handling`

**Tareas:**
- Try-catch en RAG orchestrator
- Retry logic (3x con backoff exponencial)
- Fallback a template vacío si RAG falla
- Error messages amigables al user
- Logging exhaustivo

---

#### HU-3.5: Streaming & Performance (Week 6)

**Rama:** `feature/ui-streaming-optimization`

**Tareas:**
- Implementar SSE (Server-Sent Events)
- Frontend: Recibir chunks y renderizar en tiempo real
- Cache de templates en memoria
- Pre-compute embeddings
- Benchmark: <500ms UI latency, <5min para 25 docs

---

### FASE 4: Pruebaing & Polish (Week 7-8)

**Objetivo:** QA, bug fixes, documentoación final

#### Tareas
- Pruebaing E2E completo (flow 25 docs)
- Performance profiling
- Cross-platform pruebaing (Windows/Linux/macOS)
- Documentoación usuario
- Staging deployment

---

## 👥 Asignación de Recursos

### Equipo Recomendado

```
👨‍💼 Product Owner / Stakeholder
└─ Role: Decisiones, feedback
└─ Horas/semana: 2-3h
└─ Disponibilidad: Flex

🏛️ Tech Lead / Architect (ArchitectZero)
└─ Role: Oversight, spikes, reviews
└─ Horas/semana: 8-10h
└─ Disponibilidad: Full-time

💻 Backend Lead Developer
└─ Role: HU-3.2, 3.4, integraciones backend
└─ Horas/semana: 40h (full-time)
└─ Disponibilidad: 8 semanas

🎨 Frontend Lead Developer
└─ Role: HU-3.1, 3.3, 3.5, UI/UX
└─ Horas/semana: 40h (full-time)
└─ Disponibilidad: 8 semanas

🤖 RAG/AI Specialist
└─ Role: Spike RAG, RAGOrchestrator, templates
└─ Horas/semana: 20-30h
└─ Disponibilidad: 6-8 semanas

🔐 QA / Tester
└─ Role: Test plan, E2E, cross-platform
└─ Horas/semana: 30h
└─ Disponibilidad: 4-8 semanas (intenso W7-W8)

📊 DevOps / Infrastructure
└─ Role: CI/CD pipeline updates, staging deployment
└─ Horas/semana: 5-10h
└─ Disponibilidad: Flex
```

### Total Recursos

- **FTE (Full-Time Equivalents):** 3.5 FTE
- **Total Horas:** ~280 horas en 8 semanas
- **Costo Estimado (si contratar):** ~$70k-100k USD

---

## ⚠️ Riesgos y Mitigaciones

### Riesgo 1: Complejidad del RAG Orchestrator

**Severidad:** MEDIUM | **Probabilidad:** HIGH

**Descripción:**
Orquestar 25 documentoos secuenciales con dependencias complejas requiere state machine sofisticada.

**Impacto:**
- Delays en HU-3.3 (impacta W4-W5)
- Necesidad de re-design mid-sprint

**Mitigación:**
1. **Spike exhaustiva (W1):** 3-4 días diseñando RAGOrchestrator
2. **Prototyping:** Crear POC con 3-5 documentoos antes de 25
3. **Documentoation:** Pseudocódigo + diagramas claros
4. **Code review temprana:** Tech Lead revisa W3 día 3

**Contingency:**
- Si spike falla: Reducir a 10 documentoos clave (HU-3.3 Lite)
- Timeline: +1 semana si necesario

---

### Riesgo 2: Permisos del Sistema de Archivos

**Severidad:** MEDIUM | **Probabilidad:** MEDIUM

**Descripción:**
ArchivoSystemService necesita escribir en disco con permisos variables (Windows vs. Linux).

**Impacto:**
- Fallos en multi-OS (impacta HU-3.2)
- User confusion si no tiene permisos

**Mitigación:**
1. **Pruebaing multi-OS (W1-W2):**
   - Windows: Vagrant VM o GitHub Actions
   - Linux: Native pruebaing
   - macOS: GitHub Actions
2. **Path validation exhaustiva:** Detectar problemas temprano
3. **Clear error messages:** User sabe qué hacer

**Contingency:**
- Si multi-OS falla: Limitar a Linux solo (MVP)
- Timeline: +2-3 días para fixing

---

### Riesgo 3: Timeline Slip

**Severidad:** HIGH | **Probabilidad:** MEDIUM

**Descripción:**
Scope creep, underestimation, o delays externos.

**Impacto:**
- Salida de producción retrasada (1-2 semanas)
- Sprint 4 afectado

**Mitigación:**
1. **Estimación realista (70 pts):** Buffer incluido vs. 50 anterior
2. **Paralelización:** HU-3.1 + HU-3.2 en paralelo
3. **Daily standup:** Detectar delays temprano
4. **Scope control:** Decir "No" a cambios nuevos

**Contingency:**
1. Si W1-W2 slip: Reducir HU-3.4 (error handling) a "básico"
2. Si W3-W5 slip: Reducir HU-3.5 (streaming) a "versión 2"
3. Si W6-W7 slip: Omitir cross-platform pruebaing (solo Linux)

---

### Riesgo 4: Calidad de Propuestas RAG

**Severidad:** MEDIUM | **Probabilidad:** MEDIUM

**Descripción:**
RAG puede generar propuestas de baja calidad si templates o contexto es pobre.

**Impacto:**
- User frustracion (propuestas malas)
- Iteración excesiva (no converge)

**Mitigación:**
1. **Templates quality (Pre-W1):** Revisar packages/knowledge_base/
2. **Context injection (W3):** Diseñar bien cómo se inyecta contexto
3. **Feedback loop (W4):** User pruebaing temprana con propuestas reales
4. **Fine-tuning (W5-W6):** Ajustar prompts según feedback

**Contingency:**
- Si calidad es pobre: Ofrecer "Edit mode" para usuario editar propuestas antes de validar

---

### Riesgo 5: Gestión de Estado Conversacional

**Severidad:** MEDIUM | **Probabilidad:** MEDIUM

**Descripción:**
Mantener contexto conversacional a través de 25 documentoos y múltiples iteraciones.

**Impacto:**
- Chat pierde contexto entre documentoos
- Generaciones incoherentes

**Mitigación:**
1. **State machine clara (Spike):** Definir exactamente qué contexto persiste
2. **DB schema (HU-3.3):** Diseñar bien cómo guardar conversación
3. **Unit pruebas (W4):** Verificar contexto se mantiene

---

## 📊 Métricas de Éxito

### Métricas de Código

```
✅ Type Safety
   - Pylance errors: 0
   - Mypy/Pyright: 100% passing
   - Target: Before merge

✅ Code Quality
   - Ruff violations: 0
   - Black formatting: 100%
   - Target: Before merge

✅ Test Coverage
   - Overall: >85%
   - Backend: >90%
   - Frontend: >80%
   - Target: W7

✅ Performance
   - UI latency: <500ms (Doc generation start → visible)
   - RAG latency: <2s per document
   - Full pipeline (25 docs): <5 minutes
   - Memory usage: <500MB
   - Target: W6-W7
```

### Métricas de Proceso

```
✅ Velocity
   - Week 1-2: 21 pts (HU-3.1 + 3.2)
   - Week 3-5: 21 pts (HU-3.3)
   - Week 6: 13 pts (HU-3.4 + 3.5)
   - Target: On schedule

✅ Defect Rate
   - Critical bugs: 0 en production
   - Major bugs: <2
   - Minor bugs: <5
   - Target: <1 per HU pre-merge

✅ Code Review
   - Approval time: <24h
   - Comments per PR: <5 (clean PRs)
   - Merge blockers: 0
   - Target: W1-W8

✅ Documentation
   - Inline comments: 100% on public API
   - Docstrings: 100% on classes/methods
   - CHANGELOG entries: Complete
   - Target: W8
```

### Métricas de User Experience

```
✅ Usability Testing
   - Users can create project: 100%
   - Users can understand Doc 1 propuesta: >90%
   - Users can iterate/validate flow: >85%
   - Target: W7 (pre-staging)

✅ Adoption
   - Team starts using Project-First: Y/N
   - First 5 projects created: Y/N
   - Zero critical bugs in staging: Y/N
   - Target: W8
```

---

## ✅ Checklist de Hitos

### HITO 1: Fundación Ready (05/02 - antes de W1)

```
☐ Usuario confirmó decisión (✅ Opción A)
☐ Rama feature/ui-project-shell en GitHub
☐ PR Draft creada
☐ Tech Lead aprobó
☐ Equipo ambiente configurado
☐ Se puede empezar W1
```

---

### HITO 2: Fundación Complete (12/02 - fin W2)

```
☐ HU-3.1 Merged (UI completa, tests >85%)
☐ HU-3.2 Merged (Backend completa, tests >90%)
☐ Spike RAG design documentada
☐ Docs actualizadas en develop
☐ Team ready para HU-3.3
```

---

### HITO 3: Lógica Central Complete (12/03 - fin W5)

```
☐ HU-3.3 Merged (Chat sequential, tests >85%)
☐ HU-3.4 Merged (Error handling, tests >85%)
☐ RAG Orchestrator funcional
☐ E2E flow testeable (propuesta → validación → siguiente)
☐ Staging deployment listo
```

---

### HITO 4: Performance Optimized (19/03 - fin W6)

```
☐ HU-3.5 Merged (Streaming, tests >80%)
☐ Performance benchmarks met (<5min para 25 docs)
☐ SSE streaming funcional
☐ All PRs merged a develop
☐ develop is stable
```

---

### HITO 5: Release Candidate (01/04 - fin W8)

```
☐ Testing E2E completo (flow 25 docs end-to-end)
☐ Cross-platform testing (Windows/Linux/macOS)
☐ Bug fixes completados
☐ Documentation completa
☐ Staging deployment verificado
☐ Ready for Production Deployment
```

---

## 📎 Apéndices

### Apéndice A: Especificaciones Técnicas Detalladas

Ver documentoos:
- [HU-3_SPECIFICATIONS.es.md](./HU-3_SPECIFICATIONS.es.md) - Especificación completa de cada HU
- [HU-3_IMPROVEMENT_PROPOSALS.es.md](./HU-3_IMPROVEMENT_PROPOSALS.es.md) - Código de ejemplo + arquitectura

### Apéndice B: Análisis y Justificación

Ver documentoos:
- [HU-3_REFACTOR_ANALYSIS.es.md](./HU-3_REFACTOR_ANALYSIS.es.md) - Análisis comparativo
- [HU-3_EXECUTIVE_SUMMARY.es.md](./HU-3_EXECUTIVE_SUMMARY.es.md) - Resumen ejecutivo

### Apéndice C: Guía de Desarrollo

```bash
# Setup inicial (hacer una vez)
git clone https://github.com/Pitcher755/soft-architect-ai.git
cd soft-architect-ai

# Por cada HU
git checkout develop
git pull origin develop
git checkout -b feature/[hu-name]

# Desarrollo (frecuente)
git add [files]
git commit -m "feat(hu-X.Y): [description]"

# Pre-commit validation (automático)
# - Black formatting
# - Ruff linting
# - Pyright type checking

# Push
git push origin feature/[hu-name]

# Code review → Merge
```

### Apéndice D: Stack Técnico

```
Frontend:
- Flutter 3.x (Desktop target)
- Riverpod (state management)
- flutter_markdown (rendering)
- freezed (immutable data classes)

Backend:
- FastAPI + Pydantic
- Python 3.12.3
- ChromaDB (vector storage)
- SQLite (chat history)
- LangChain (RAG)

AI:
- Ollama (local LLM)
- Groq (cloud fallback)
- Embeddings: all-MiniLM-L6-v2 (local)

DevOps:
- Docker & docker-compose
- GitHub Actions (CI/CD)
- Linux/Windows/macOS (cross-platform)
```

### Apéndice E: Calendario Detallado (Google Calendar Format)

```
SEMANA 1 (06/02 - 12/02)
├─ 06/02 (M): Team kickoff, sprint planning
├─ 07/02-08/02 (T-W): HU-3.1 UI widgets
├─ 07/02-09/02 (T-Th): HU-3.2 Backend
├─ 08/02 (W): Spike RAG design review
├─ 10/02 (F): Sprint review, status check
└─ 11/02-12/02 (Sa-Su): Testing + PR prep

SEMANA 2 (13/02 - 19/02)
├─ 13/02 (M): HU-3.1 finalization
├─ 13/02 (M): HU-3.2 finalization
├─ 14/02 (Tu): Code review HU-3.1 + 3.2
├─ 15/02-17/02 (W-F): Merge + HITO 1
└─ 18/02-19/02 (Sa-Su): Rest + W3 prep

[... continúa W3-W8 ...]
```

---

## 🎯 CONCLUSIÓN

Este Plan Maestro proporciona:

✅ **Visión clara:** De Chat-First a Proyecto-First Sequential
✅ **Timeline realista:** 8 semanas con mitigaciones
✅ **Estructura definida:** 5 HUs independientes y secuenciales
✅ **Recursos asignados:** 3.5 FTE
✅ **Riesgos identificados:** Con mitigaciones
✅ **Métricas de éxito:** Cuantificables y verificables
✅ **Hitos claros:** 5 puntos de validación

### Próximo Paso

**Usuario debe confirmar:**
```
¿Proceder con este Plan Maestro de Implementación?

✅ SÍ - Comenzar Phase 0 (Pre-Sprint)
❌ NO - Mantener HU-3.x original
🤔 MODIFICAR - Especificar cambios
```

---

**Plan Maestro Versión 1.0**
**Creado por:** ArchitectZero (AI Lead)
**Fecha:** 02/02/2026
**Estado:** ✅ LISTO PARA EJECUCIÓN
**Responsable de Ejecución:** Development Team + Tech Lead
