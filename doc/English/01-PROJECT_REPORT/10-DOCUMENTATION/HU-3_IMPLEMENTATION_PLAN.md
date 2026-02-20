# 🔧 Plan de Implementation: Creación de Rama y Next Steps

> **Date:** 02/02/2026
> **Status:** 📋 CHECKLIST DE ACCIONES PRE-RAMA
> **Tipo:** Operational Runbook
> **Audiencia:** Development Team + ArchitectZero

---

## 📖 Table of Contents

1. [Decisiones Requeridas](#-decisiones-requeridas)
2. [Estructura de Rama](#-estructura-de-rama)
3. [Cambios en Files](#-cambios-en-files)
4. [Pasos de Implementation](#-pasos-de-implementation)
5. [Timeline Estimado](#-timeline-estimado)
6. [Criterios de Aceptación](#-criterios-de-aceptación)

---

## ✅ Decisiones Requeridas

### Pre-Requisito: Confirmación del Usuario

**El usuario DEBE confirmar:**

```
❓ ¿Aprobar el refactor de HU-3.x a Project-First Paradigm?
   Opciones:
   a) ✅ SÍ - Proceder con Opción B (5 HUs, 70 pts)
   b) ❌ NO - Mantener Opción A (3 HUs, 50 pts)
   c) 🤔 MODIFICAR - Proponer cambios a la propuesta

❓ ¿Impacto en Sprint 3?
   a) ✅ OK aumentar a 8 semanas
   b) ❌ NO - Mantener 6 semanas (requiere priorizaciones)

❓ ¿Recursos disponibles?
   a) ✅ Sí, tenemos para 70 pts
   b) ❌ No, limitar a 50 pts máximo
```

**Instrucción:** Por favor, comenta abajo cuál es tu decisión.

---

## 🌿 Estructura de Rama

### Name Propuesto

```
feature/hu-3-project-first-refactor
```

### Origen

```
develop
  ↓
  └─ feature/hu-3-project-first-refactor
```

### Alcance

```
Cambios SOLO en:
├─ context/40-ROADMAP/USER_STORIES_MASTER.es.json
├─ doc/01-PROJECT_REPORT/ (análisis y propuestas)
└─ Opcional: README.md (si necesita actualización)

NO cambios en:
├─ src/client/
├─ src/server/
├─ infrastructure/
└─ Ningún código (aún)
```

### Duración Esperada

```
Creación: 02/02/2026
├─ Branch creada en GitHub
├─ PR abierta (Draft)
├─ Revisión: ~2-3 días
└─ Merge a develop: 05/02/2026

Implementación inicia: 06/02/2026
```

---

## 📝 Cambios en Files

### File 1: `USER_STORIES_MASTER.es.json`

#### Step 1.1: Actualizar HU-3.1

**Antes:**
```json
{
  "hu_id": "HU-3.1",
  "name": "Como Usuario, quiero una interfaz de chat limpia que renderice Markdown...",
  "priority": "High",
  "estimation": "L",
  "branch_name": "feature/ui-chat-widget",
  "technical_tasks": [
    "Implementar `ChatScreen` usando el prompt de Stitch...",
    ...
  ]
}
```

**Después:**
```json
{
  "hu_id": "HU-3.1",
  "name": "Como Usuario, quiero una interfaz estilo IDE que me permita crear y gestionar Proyectos Locales, para tener control total sobre mis arquitecturas.",
  "priority": "Critical",
  "estimation": "XL",
  "branch_name": "feature/ui-project-shell",
  "context": "Project-First Paradigm - UI & Navigation",
  "description": [
    "Interfaz tipo VS Code Dark Mode con Sidebar para lista de proyectos",
    "Botón '+' para crear nuevo proyecto (abre modal con Name + BasePath)",
    "Dashboard central que cambia según proyecto seleccionado",
    "Visualización de progreso de documentos (progress bar)",
    "NO hay concepto de 'login' (es puramente local)"
  ],
  "verification_criteria": [
    "✅ (Positivo) Crear nuevo proyecto abre modal 'Nombre' + 'Ruta Base'",
    "✅ (Positivo) Al validar modal, se crea carpeta en disco + estructura base",
    "✅ (Positivo) Sidebar muestra lista actualizada de proyectos",
    "✅ (Positivo) Seleccionar proyecto cambia el panel central a ProjectDashboard",
    "✅ (Positivo) UI responde fluidamente a redimensionamiento de ventana",
    "✅ (Positivo) Colores siguen DESIGN_SYSTEM.md (Dark Mode)",
    "✅ (Positivo) Progress bar muestra porcentaje de documentos completados",
    "❌ (Negativo) No hay persistencia de proyecto en disco hasta HU-3.2"
  ],
  "technical_tasks": [
    "Implementar MainScreen con Riverpod State Management",
    "Crear ProjectListProvider (StreamProvider que escucha cambios)",
    "Implementar ProjectSidebarWidget con lista scrollable",
    "Implementar ProjectDashboard con SummaryPanel + ChatArea + FileTree stubs",
    "Crear modal 'CreateProjectDialog' reusable",
    "Conectar con FileSystemService (HU-3.2) - solo lectura",
    "Tests: ProjectSidebar widget tests, modal interaction tests"
  ],
  "dependencies": [
    "context/30-ARCHITECTURE/DESIGN_SYSTEM.md",
    "HU-3.2"
  ]
}
```

#### Step 1.2: Actualizar HU-3.2

**Antes:**
```json
{
  "hu_id": "HU-3.2",
  "name": "Como Usuario, quiero recibir la respuesta de la IA en tiempo real (Streaming)...",
  "priority": "Critical",
  "estimation": "XL",
  "branch_name": "feature/ui-api-connection",
  ...
}
```

**Después:**
```json
{
  "hu_id": "HU-3.2",
  "name": "Como Backend, quiero implementar FileSystemService para crear y gestionar proyectos en disco de forma segura, permitiendo la persistencia controlada de documentos.",
  "priority": "Critical",
  "estimation": "L",
  "branch_name": "feature/backend-filesystem-service",
  "context": "Project-First Paradigm - Core Infrastructure",
  "description": [
    "Motor de I/O para gestionar proyectos locales",
    "Crear carpeta proyecto: root/ + root/context/ + root/.project.json",
    "Validar permisos antes de escribir (seguridad del usuario)",
    "Leer estado de proyecto (qué documentos existen)",
    "Escribir documentos tras validación explícita",
    "Backup automático de versiones previas"
  ],
  "verification_criteria": [
    "✅ (Positivo) Crear proyecto crea estructura correcta: project/ + project/context/ + project/.project.json",
    "✅ (Positivo) get_project_state() retorna lista correcta de documentos existentes",
    "✅ (Positivo) write_validated_document() no sobrescribe archivos sin crear backup",
    "✅ (Positivo) Manejo de permisos: función devuelve error legible si no hay permisos write",
    "✅ (Positivo) Audit log creado automáticamente en project/.audit.log",
    "✅ (Positivo) Path traversal attacks prevenidos (no permite ../ escapes)",
    "❌ (Negativo) Endpoint API todavía no escrito (eso es HU-4.x)"
  ],
  "technical_tasks": [
    "Crear services/filesystem/file_system_service.py con métodos core",
    "Crear services/filesystem/path_validator.py para validaciones de seguridad",
    "Implementar create_project(name, base_path) → ProjectCreationResult",
    "Implementar get_project_state(base_path) → ProjectFileState",
    "Implementar write_validated_document(project_path, doc_type, content) → FileWriteResult",
    "Implementar backup logic (rename old file to .bak.{timestamp})",
    "Crear unit tests exhaustivos (pytest con tmp_path)",
    "Documentar requerimientos de permisos por plataforma (Windows/Linux/macOS)"
  ],
  "dependencies": [
    "HU-3.1",
    "context/20-REQUIREMENTS_AND_SPEC/SECURITY_AND_PRIVACY_RULES.md"
  ]
}
```

#### Step 1.3: Actualizar HU-3.3

**Antes:**
```json
{
  "hu_id": "HU-3.3",
  "name": "Como Usuario, quiero que los errores se muestren de forma clara y amigable...",
  "priority": "High",
  "estimation": "S",
  "branch_name": "feature/ui-error-handling",
  ...
}
```

**Después:**
```json
{
  "hu_id": "HU-3.3",
  "name": "Como Usuario, quiero propuestas de documentos desde la IA con botón de validación explícita, para mantener control sobre qué se escribe en mi proyecto.",
  "priority": "Critical",
  "estimation": "XL",
  "branch_name": "feature/ui-document-proposals",
  "context": "Project-First Paradigm - User Interaction",
  "description": [
    "Chat mejorado con soporte para dos tipos de mensajes:",
    "  1. Texto conversacional (streaming normal)",
    "  2. Propuesta de documento (widget especial con contenido + sources + botones)",
    "Propuesta renderiza Markdown con resaltado de código",
    "Usuario puede editar contenido ANTES de validar (Edit Mode)",
    "Botón 'Validar y Guardar' persiste documento a través de backend",
    "Streaming via Server-Sent Events (SSE) sin bloqueo de UI"
  ],
  "verification_criteria": [
    "✅ (Positivo) Chat recibe dos tipos de mensaje: conversational + document_proposal",
    "✅ (Positivo) Document_proposal renderiza Markdown completo con fuentes",
    "✅ (Positivo) Usuario puede hacer clic en 'Edit' para modificar contenido",
    "✅ (Positivo) Botón 'Validar' está habilitado solo cuando hay propuesta",
    "✅ (Positivo) Al validar, UI muestra spinner y desactiva botones",
    "✅ (Positivo) Respuesta del backend confirma guardado + path del archivo",
    "✅ (Positivo) Error: muestra ErrorBanner amigable (nunca stack trace)",
    "✅ (Positivo) Streaming funciona sin bloqueo de UI (async/await)",
    "❌ (Negativo) RAG no integrado todavía (eso es HU-4.x)"
  ],
  "technical_tasks": [
    "Crear DocumentProposalMessage widget (renderiza Markdown + sources + botones)",
    "Crear ValidationButton widget con loading state",
    "Crear EditMode para permitir edición previa a validación",
    "Extender ChatProvider (Riverpod) para manejar dos tipos de mensajes",
    "Implementar chatRepository.validateAndSaveDocument(proposal, editedContent)",
    "Integración con backend endpoint /api/v1/projects/{id}/document/validate",
    "Manejo de errores con ErrorBanner widget",
    "Tests: DocumentProposal widget tests, edit mode interaction, validation flow"
  ],
  "dependencies": [
    "HU-3.1",
    "HU-3.2",
    "HU-3.4",
    "HU-3.5",
    "context/30-ARCHITECTURE/API_INTERFACE_CONTRACT.md"
  ]
}
```

#### Step 1.4: Agregar HU-3.4 (Nueva)

```json
{
  "hu_id": "HU-3.4",
  "name": "Como Usuario, quiero que los errores se muestren de forma clara y que el sistema reintente automáticamente cuando sea posible, para tener una experiencia sin frustración.",
  "priority": "High",
  "estimation": "M",
  "branch_name": "feature/ui-resilience-layer",
  "context": "Cross-cutting Concern - Error Handling",
  "description": [
    "ErrorBanner widget reusable que aparece al pie de la pantalla",
    "Mapear códigos de error backend a mensajes amigables en español",
    "Retry automático para errores transitorios (timeout, conexión)",
    "Timeout handling + fallback UI cuando backend no responde"
  ],
  "verification_criteria": [
    "✅ (Positivo) Si backend no responde: muestra 'No hay conexión con el servidor'",
    "✅ (Positivo) Si FileSystemService falla: 'No se puede escribir en disco, verifica permisos'",
    "✅ (Positivo) Si ChromaDB caído: 'Base de conocimiento no disponible, reintentando...'",
    "✅ (Positivo) Errores desaparecen automáticamente después de 5 segundos",
    "✅ (Positivo) Retry automático hasta 3 intentos con exponential backoff",
    "❌ (Negativo) Stack traces nunca visibles al usuario final"
  ],
  "technical_tasks": [
    "Crear ErrorBanner widget con timer autohide",
    "Crear error code → mensaje map (bilingual ES/EN)",
    "Implementar ErrorMiddleware en Riverpod",
    "Implementar retry logic con exponential backoff (1s, 2s, 4s)",
    "Crear ErrorHandler service centralizado",
    "Tests: error display, autohide timer, retry counting"
  ],
  "dependencies": [
    "HU-3.3",
    "context/30-ARCHITECTURE/ERROR_HANDLING_STANDARD.md"
  ]
}
```

#### Step 1.5: Agregar HU-3.5 (Nueva)

```json
{
  "hu_id": "HU-3.5",
  "name": "Como Usuario, quiero que el chat responda en tiempo real sin bloquear la interfaz, para mantener la sensación de responsividad.",
  "priority": "High",
  "estimation": "M",
  "branch_name": "feature/ui-streaming-optimization",
  "context": "UX Performance - Streaming & UI Responsiveness",
  "description": [
    "Implementar Server-Sent Events (SSE) para streaming de respuestas",
    "Optimistic UI: mostrar input vacío inmediatamente (no esperar confirmación)",
    "Auto-scroll al nuevo contenido (chat siempre visible)",
    "Manejo de desconexión + reconexión automática"
  ],
  "verification_criteria": [
    "✅ (Positivo) Al enviar mensaje, input se limpia inmediatamente",
    "✅ (Positivo) Tokens de respuesta llegan uno a uno (streaming visible)",
    "✅ (Positivo) Scroll baja automáticamente con nuevo contenido",
    "✅ (Positivo) Latencia de primer token <200ms (según requisitos)",
    "✅ (Positivo) Si conexión se corta, reintenta automáticamente",
    "❌ (Negativo) No hay freezing de UI durante streaming"
  ],
  "technical_tasks": [
    "Implementar SSE client en Dart (usar http package)",
    "Crear StreamProvider con Riverpod para SSE",
    "Auto-scroll logic usando ScrollController",
    "Reconexión automática con exponential backoff",
    "Tests: SSE stream mocking, token arrival verification, scroll behavior"
  ],
  "dependencies": [
    "HU-3.3",
    "HU-3.4"
  ]
}
```

---

## 🔄 Pasos de Implementation

### Phase 0: Confirmación (HOY)

**Acción:** Usuario confirma decisiones en esta conversación

```
Usuario confirma: "✅ Procedo con Opción B"
```

### Phase 1: Create Rama (02/02/2026)

**Acción Técnica:**
```bash
# En la máquina local
cd /home/pitcherdev/Espacio-de-trabajo/Master/soft-architect-ai

# Verificar estamos en develop
git status
# > On branch develop

# Crear rama nueva
git checkout -b feature/hu-3-project-first-refactor

# Verificar
git branch -a
# > * feature/hu-3-project-first-refactor
# >   develop
# >   main
```

### Phase 2: Actualizar Files (02/02/2026)

**Acción:** Realizar cambios en `USER_STORIES_MASTER.es.json` (Pasos 1.1-1.5 arriba)

**Herramienta:** Usar `replace_string_in_file` múltiples veces O usar `multi_replace_string_in_file`

**Validación:**
```bash
# Verificar sintaxis JSON
python -m json.tool context/40-ROADMAP/USER_STORIES_MASTER.es.json > /dev/null
# Si no da error: ✅ JSON válido
```

### Phase 3: Commit y Push (02/02/2026)

**Acción:**
```bash
# Agregar cambios
git add context/40-ROADMAP/USER_STORIES_MASTER.es.json

# Commit
git commit -m "refactor(hu-3): convert to Project-First paradigm (5 HUs)

- HU-3.1: Project Shell (UI & Navigation) - XL, CRITICAL
- HU-3.2: File System Logic (Motor I/O) - L, CRITICAL
- HU-3.3: Chat with Document Proposals - XL, CRITICAL
- HU-3.4: Error Handling & Resilience - M, HIGH
- HU-3.5: Streaming Optimization - M, HIGH

Total estimation: 70 pts (vs. 50 previous)
Dependencies: Updated to reflect new architecture
Impacts: S4 (HU-4.1, HU-4.4 new)

See HU-3_REFACTOR_ANALYSIS.es.md for full details"

# Push a rama
git push origin feature/hu-3-project-first-refactor
```

### Phase 4: Create PR y Revisar (03-04/02/2026)

**Acción:**
1. Ir a GitHub
2. Create PR: `feature/hu-3-project-first-refactor` → `develop`
3. Description: Copiar del commit (arriba)
4. Marcar como **Draft** (no lista para merge)
5. Agregar labels: `epic/sprint3`, `refactoring`, `architecture`

**Revisión:**
- Leer comentarios del equipo
- Responder preguntas
- Hacer ajustes si es necesario

### Phase 5: Mergear a Develop (05/02/2026)

**Acción:**
1. Esperar aprobaciones del equipo
2. Cambiar PR de Draft → Ready
3. Click: "Squash and merge" (1 commit limpio en develop)

**Result:**
```
main ──────────────────────────────────
                                  (sin cambios)

develop ─────────────────────────────────o
                                (merge PR)
```

---

## 📊 Timeline Estimado

```
02/02/2026 (Hoy)
├─ ✅ Análisis completo (completado)
├─ ✅ Documentos de propuesta (completados)
├─ ⏳ DECISIÓN DEL USUARIO (esperando)
└─ Si ✅: Crear rama + actualizar JSON

03-04/02/2026
└─ Revisión de PR + ajustes del equipo

05/02/2026
└─ Merge a develop

06/02/2026
└─ 🚀 Sprint 3 INICIA con nuevas HUs
    ├─ Week 1-2: HU-3.1 + HU-3.2 (paralelo)
    ├─ Week 2-4: HU-3.3 integration
    ├─ Week 4-5: HU-3.4 + HU-3.5 (paralelo)
    ├─ Week 5-6: Testing + QA
    ├─ Week 6-7: Bug fixes
    └─ Week 7-8: Integration S4
```

---

## ✅ Criterios de Aceptación

### Para la Rama Creada

```
✅ Rama existe en GitHub
✅ Branch name es feature/hu-3-project-first-refactor
✅ Basada en develop
✅ USER_STORIES_MASTER.es.json sintaxis válida
✅ 5 HUs claramente definidas (HU-3.1 a HU-3.5)
✅ Estimaciones realistas (70 pts total)
✅ Dependencies correctamente mapeadas
```

### Para la PR

```
✅ PR en estado Draft (no auto-merge)
✅ Título: "refactor(hu-3): Project-First Paradigm - 5 HUs"
✅ Descripción clara en bilingual (EN/ES)
✅ Linked issues: ninguno (es speculative)
✅ Labels: epic/sprint3, refactoring, architecture
✅ Reviewers: @team
```

### Antes del Merge

```
✅ Al menos 2 aprobaciones del equipo
✅ Todas las conversaciones resueltas
✅ JSON validado
✅ Acuerdo sobre timeline (8 semanas vs. 6)
✅ Acuerdo sobre 70 pts de estimación
```

---

## 📌 Notas Importantes

### NO hacer cambios en código (aún)

Esta rama es **SOLO para actualizar la especificación**, no para implementar.

Implementation comienza en Sprint 3 (después de merge).

### Bilingual Support

Todos los nombres de ramas, commits, PRs deben ser en **inglés**.
Los documents (es.md) pueden ser en español.

### Versioning

Después del merge, considerar:
- Create tag `v0.1-spec-refactor` para referencia histórica
- Marcar esta decisión en CHANGELOG.md

---

## 🎯 Conclusión

Esta rama es un **checkpoint arquitectónico importante**.

Marca la transición de:
- **Chat-First** (simple) → **Project-First** (robusto)
- **50 pts** (underestimated) → **70 pts** (realistic)
- **3 HUs** (ambiguas) → **5 HUs** (claras)

Éxito depende de:
1. ✅ Decisión clara del usuario (HOY)
2. ✅ Aprobación del equipo (3-4/02)
3. ✅ Merge limpio (05/02)
4. ✅ Implementation disciplinada (06/02 en adelante)

---

**Próxima acción:** Esperar confirmación del usuario en conversación.
