# 📋 Especificación Detallada: Las 5 HUs del Sprint 3 (Project-First)

> **Fecha:** 02/02/2026
> **Estado:** ✅ ESPECIFICACIÓN FINAL
> **Relacionado con:** HU-3_REFACTOR_ANALYSIS.es.md
> **Total Estimación:** 55 pts

---

## 🎯 Resumen de HUs

| ID | Nombre | Puntos | Rama | Dependencias | Criticidad |
|----|----|---------|------|-----------|------------|
| **HU-3.1** | Project Shell (UI & Navigation) | 13 | `feature/ui-project-shell` | ❌ Ninguna | ⭐⭐⭐ |
| **HU-3.2** | FileSystemService (Backend Motor) | 8 | `feature/backend-filesystem-service` | HU-3.1 | ⭐⭐⭐ |
| **HU-3.3** | Chat Sequential Document Generation | 21 | `feature/ui-chat-sequential-docs` | HU-3.1, 3.2 | ⭐⭐⭐ |
| **HU-3.4** | Error Handling & Validation Gates | 5 | `feature/backend-error-handling` | HU-3.3 | ⭐⭐ |
| **HU-3.5** | Streaming & Performance Optimization | 8 | `feature/ui-streaming-optimization` | HU-3.3, 3.4 | ⭐⭐ |

---

## 📌 HU-3.1: Project Shell (UI & Navigation) ⭐ PRIMERA

### Descripción
Crear **interfaz de escritorio que permita crear proyectos y auto-generar estructura de directorios** (`context/10-20-30-35-40/`).

### Historia de Usuario
> **Como** usuario
> **Quiero** crear un nuevo proyecto con nombre y descripción
> **Para** establecer el contexto organizacional de mi documentación

### Responsabilidades
1. **Frontend (Flutter)**
   - Pantalla inicial: "Nuevo Proyecto" (input: nombre, descripción)
   - Dashboard: Listar proyectos existentes
   - Clickear proyecto → Carga vista de "Generación de Documentos"
   - Dark mode compatible
   - Responsive (redimensionamiento ventana)

2. **Backend (FastAPI)**
   - Endpoint `POST /api/v1/projects/create` → crea dirs automáticamente
   - Endpoint `GET /api/v1/projects/list` → retorna lista de proyectos
   - Endpoint `GET /api/v1/projects/{project_id}` → retorna metadatos

### Criterios de Aceptación
- ✅ Usuario ingresa nombre + descripción
- ✅ Backend crea estructura:
  ```
  /user/projects/{project_id}/
  ├── context/
  │   ├── 10-CONTEXT/
  │   ├── 20-REQUIREMENTS/
  │   ├── 30-ARCHITECTURE/
  │   ├── 35-UX_UI/
  │   └── 40-PLANNING/
  ├── .project.json (metadata)
  └── CHAT_HISTORY.db (SQLite)
  ```
- ✅ Dashboard se actualiza con nuevo proyecto
- ✅ Tests: Unit + Integration > 85% cobertura

### Datos de Entrada (Ejemplo)
```json
{
  "name": "SoftArchitect AI",
  "description": "Asistente de ingeniería offline basado en RAG local"
}
```

### Datos de Salida (Ejemplo)
```json
{
  "project_id": "proj_abc123",
  "name": "SoftArchitect AI",
  "created_at": "2026-02-02T10:00:00Z",
  "base_path": "/home/user/projects/proj_abc123"
}
```

### Puntos de Riesgo
- Permisos del SO (Windows vs. Linux vs. macOS)
- Manejo de rutas con espacios/caracteres especiales
- Conflicto si proyecto ya existe

### Puntos de Estimación
**13 pts (XL)**
- UI: 5 pts
- Backend: 5 pts
- Testing: 3 pts

### Rama
`feature/ui-project-shell`

### Dependencias
❌ Ninguna (PRIMERA HU)

---

## 📌 HU-3.2: FileSystemService (Backend Motor) ⭐ CRÍTICA

### Descripción
Implementar **servicio backend que gestione lectura/escritura segura de archivos**, control de acceso y persistencia en directorios del proyecto.

### Historia de Usuario
> **Como** backend
> **Quiero** un servicio centralizado de I/O con validaciones de seguridad
> **Para** garantizar que los documentos se guardan correctamente y con permisos controlados

### Responsabilidades
1. **Crear estructura de dirs** (`context/10-20-30-35-40/`)
2. **Validar permisos** de lectura/escritura del SO
3. **Guardar documentos** en markdown con nombrado predecible
4. **Leer documentos** guardados (para historial + contexto)
5. **Manejo de excepciones** (disco lleno, permisos denegados, etc.)

### Criterios de Aceptación
- ✅ Servicio crea dirs sin errores (idempotente)
- ✅ Valida permisos antes de escribir (throw si no tiene acceso)
- ✅ Guarda archivos con nombrado: `{number}-{SECTION}.md`
- ✅ Lee archivos existentes y retorna contenido
- ✅ Tests (unit + integration): > 90% cobertura
- ✅ Documentación Docstring (Python) completa

### Estructura de Archivos (Salida Esperada)
```
/project_dir/context/
├── 10-CONTEXT/
│   └── 10-CONTEXT.md          ← Guardado aquí
├── 20-REQUIREMENTS/
│   └── 20-REQUIREMENTS.md      ← Guardado aquí
├── 30-ARCHITECTURE/
│   └── 30-ARCHITECTURE.md      ← Guardado aquí
├── 35-UX_UI/
│   └── 35-UX_UI.md             ← Guardado aquí
└── 40-PLANNING/
    └── 40-PLANNING.md          ← Guardado aquí
```

### Métodos del Servicio (Python)

```python
class FileSystemService:
    async def create_project_structure(
        self,
        project_base_path: str
    ) -> dict[str, str]:
        """Crea estructura de dirs. Retorna mapeo {section: path}"""

    async def save_document(
        self,
        project_base_path: str,
        section: str,  # "10-CONTEXT", "20-REQUIREMENTS", etc.
        content: str   # Markdown content
    ) -> str:
        """Guarda documento en disco. Retorna path guardado."""

    async def read_document(
        self,
        project_base_path: str,
        section: str
    ) -> str:
        """Lee documento desde disco. Retorna contenido."""

    async def get_project_state(
        self,
        project_base_path: str
    ) -> dict[str, bool]:
        """Retorna qué documentos existen: {section: exists}"""

    async def validate_permissions(
        self,
        project_base_path: str
    ) -> bool:
        """Valida permisos antes de proceder. Throw si falla."""
```

### Puntos de Riesgo
- Manejo de paths con caracteres especiales
- Permisos insuficientes en SO (especialmente Linux)
- Carrera de condiciones si múltiples procesos escriben simultáneamente

### Puntos de Estimación
**8 pts (M)**
- Core logic: 4 pts
- Error handling: 2 pts
- Testing: 2 pts

### Rama
`feature/backend-filesystem-service`

### Dependencias
- HU-3.1 (necesita saber estructura de dirs del proyecto)

---

## 📌 HU-3.3: Chat Sequential Document Generation ⭐ NÚCLEO

### Descripción
Implementar **flujo de chat que genera documentos secuencialmente usando RAG guiado por templates**, permitiendo usuario iterar antes de guardar.

### Historia de Usuario
> **Como** usuario
> **Quiero** describir mi proyecto una vez y recibir 25 documentos de arquitectura generados secuencialmente
> **Para** tener documentación completa de ingeniería sin escribir manualmente

### Responsabilidades
1. **Frontend (Flutter)**
   - Chat input area (textarea para descripción inicial)
   - Mostrar propuesta de documento en formato markdown
   - Botones: "✅ Validar" | "🔄 Iterar"
   - Si Iterar: Chat permite refinar contexto
   - Si Validar: Guardar + pasar a documento siguiente
   - Indicador de progreso (Doc N de 25)

2. **Backend (FastAPI)**
   - Endpoint `POST /api/v1/chat/start-project` → inicia flujo
   - Endpoint `POST /api/v1/chat/message` → acepta refinamientos
   - Endpoint `POST /api/v1/chat/validate-doc` → guarda documento
   - Orquestador RAG que:
     - Carga template de documento N (ej: `01-TEMPLATES/10-CONTEXT.md`)
     - Inyecta contexto de proyecto + documentos previos
     - Llama a LLM (Ollama/Groq) para rellenar template
     - Retorna propuesta de documento

### Criterios de Aceptación
- ✅ Chat acepta descripción inicial del proyecto
- ✅ Backend genera propuesta de Doc 1 usando template `01-TEMPLATES/10-CONTEXT.md`
- ✅ Frontend muestra propuesta en formato readable (markdown)
- ✅ Usuario puede "Iterar" (chat refina) o "Validar" (guardar)
- ✅ After validar: Automáticamente genera Doc 2 propuesta
- ✅ Flujo es **SECUENCIAL OBLIGATORIO** (nunca paralelo)
- ✅ Después de Doc 25: Mensaje "✅ Documentación completa guardada"
- ✅ Tests: Unit (validación) + Integration (flujo E2E): > 85% cobertura

### Flujo Secuencial (ASCII Diagram)
```
┌─────────────────────────────────────────────────────────────┐
│ 1. Usuario describe proyecto en chat                        │
└────────────────────┬────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────────┐
│ 2. Backend carga template 1 (10-CONTEXT)                   │
│    + inyecta contexto del proyecto                         │
└────────────────────┬────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────────┐
│ 3. RAG llama LLM (Ollama/Groq) → rellena template          │
└────────────────────┬────────────────────────────────────────┘
                     ↓
┌─────────────────────────────────────────────────────────────┐
│ 4. Frontend propone Doc 1 (preview markdown)               │
└────────────────────┬────────────────────────────────────────┘
                     ↓
            ┌────────┴─────────┐
            ↓                  ↓
      ┌──────────┐         ┌──────────┐
      │  ITERAR  │         │ VALIDAR  │
      └────┬─────┘         └────┬─────┘
           │                    │
           ↓ (chat refina)      ↓ (guardar)
      REGENERATE           SAVE to disk
      Doc 1                context/10-CONTEXT/
           │                    │
           └────────┬───────────┘
                    ↓
         Doc 1 guardado ✅
                    │
                    ↓ (auto)
      Generar Doc 2 propuesta
                    │
                    ↓
         [Repetir 24 veces más]
                    │
                    ↓
         ✅ 25 documentos completados
```

### Datos de Entrada (Ejemplo)
```json
{
  "project_id": "proj_abc123",
  "initial_description": "Un asistente de IA offline para arquitectura de software basado en RAG local"
}
```

### Datos de Salida (Documento 1 Propuesto - Ejemplo)
```markdown
# 📋 10-CONTEXT (Generado automáticamente)

## Visión del Proyecto
Un asistente de IA offline para arquitectura de software basado en RAG local...

## Objetivos Principales
1. Privacidad total (data sovereignty)
2. Operación offline
3. Latencia baja (<200ms)

## Stack Tecnológico Inferido
- Frontend: Flutter (Desktop)
- Backend: Python + FastAPI
- IA: Ollama (local) / Groq (cloud)
- DB: ChromaDB (vectorial) + SQLite (relacional)
```

### Puntos de Riesgo
- RAG timeout (necesita fallback a template vacío)
- Usuario quiere saltar documentos (rechazamos: secuencial obligatorio)
- Consumo de memoria si guardar chat history completo

### Puntos de Estimación
**21 pts (XXL)**
- Frontend chat UI: 7 pts
- Backend RAG orchestration: 10 pts
- Testing (E2E workflow): 4 pts

### Rama
`feature/ui-chat-sequential-docs`

### Dependencias
- HU-3.1 (crear proyecto)
- HU-3.2 (guardar archivos)

---

## 📌 HU-3.4: Error Handling & Validation Gates

### Descripción
Agregar **mecanismos de validación y manejo de errores** en flujo secuencial (ej: RAG falla, disco lleno, timeout).

### Historia de Usuario
> **Como** usuario
> **Quiero** que el sistema maneje gracefully fallos (disco lleno, timeout LLM, etc.)
> **Para** no perder mi trabajo y poder reintentar sin frustración

### Responsabilidades
1. **Backend Exception Handling**
   - Try-catch para: RAG timeout, DB insert failure, I/O permission errors
   - Retry logic: 3 intentos con backoff exponencial (1s, 2s, 4s)
   - Fallback: Si RAG falla, mostrar template vacío + error amigable

2. **Frontend Error Display**
   - Mostrar errors en toast/banner (no bloquear UI)
   - Botones: "🔄 Reintentar" | "⏭️ Saltar (no recomendado)"
   - Log de errores local (para debugging)

3. **Telemetría**
   - Guardar todos los errores en `context/40-PLANNING/ERROR_LOG.md`
   - Incluir: timestamp, error code, stack trace (no exponer al user)

### Criterios de Aceptación
- ✅ Si RAG timeout (>30s) → Auto-retry 3x
- ✅ Si RAG falla finalmente → Mostrar template vacío + "⚠️ RAG no respondió"
- ✅ Si disco lleno → Error claro + sugerencia "libera 500MB"
- ✅ Si permisos denegados → Error + "verifica permisos en /context"
- ✅ Tests: Simular fallos + verificar retry logic: > 90% cobertura

### Puntos de Riesgo
- Retry loop infinito (necesita max attempts)
- Ocultar errors importantes (vs. user confusion)

### Puntos de Estimación
**5 pts (S)**
- Exception handling: 2 pts
- Retry logic: 2 pts
- Testing: 1 pt

### Rama
`feature/backend-error-handling`

### Dependencias
- HU-3.3 (necesita estar funcional antes de hardening)

---

## 📌 HU-3.5: Streaming & Performance Optimization

### Descripción
Optimizar **latencia del flujo RAG** (target: <2s por documento) usando streaming de respuestas LLM.

### Historia de Usuario
> **Como** usuario
> **Quiero** ver el documento siendo generado en tiempo real (no esperar)
> **Para** saber que el sistema está trabajando y sentir responsiveness

### Responsabilidades
1. **Backend (FastAPI)**
   - Usar SSE (Server-Sent Events) para streaming de texto
   - Backend envía chunks de texto conforme LLM genera

2. **Frontend (Flutter)**
   - Recibir chunks de SSE
   - Renderizar texto en tiempo real (no esperar respuesta completa)
   - Indicador visual: "⏳ Generando..." con spinner

3. **Optimizaciones**
   - Cache en memoria de templates (no leer disco c/vez)
   - Pre-computar embeddings de templates para búsqueda rápida
   - Índice en ChromaDB para retrieval <100ms

### Criterios de Aceptación
- ✅ Latencia UI: <500ms desde "Validar Doc N" hasta ver "Generando Doc N+1..."
- ✅ Streaming visible: usuario ve texto aparecer línea-por-línea
- ✅ Benchmark: Generar 25 documentos en <5 minutos
- ✅ Memory usage: <500MB (no crecer indefinidamente)
- ✅ Tests: Performance benchmarks + memory profiling

### Puntos de Riesgo
- SSE drops conexión (necesita reconnect logic)
- Frontend acumula chunks sin límite (memory leak)

### Puntos de Estimación
**8 pts (M)**
- SSE backend: 3 pts
- Frontend streaming: 3 pts
- Performance optimization: 2 pts

### Rama
`feature/ui-streaming-optimization`

### Dependencias
- HU-3.3 (base funcional)
- HU-3.4 (manejo de errores necesario para SSE drops)

---

## 🔄 Secuencia de Implementación Recomendada

```
Semana 1:
  ├─ HU-3.1 (Project Shell) → MERGED
  └─ HU-3.2 (FileSystemService) → MERGED

Semana 2:
  ├─ HU-3.3 (Chat Sequential) → MERGED
  └─ HU-3.4 (Error Handling) → MERGED

Semana 3:
  └─ HU-3.5 (Streaming Optimization) → MERGED

Resultado: 55 pts completados en ~3 semanas
```

---

## 📊 Matriz de Dependencias

```
HU-3.1 (Project Shell)
  ↓
HU-3.2 (FileSystemService) ←─────┐
  ↓                               │
HU-3.3 (Chat Sequential) ────────→ HU-3.4 (Error Handling)
  ↓                               ↓
  └─────────────────────────────→ HU-3.5 (Streaming)
```

---

## ✅ Próximos Pasos

1. ✅ Crear rama: `feature/ui-project-shell` (base: `develop`)
2. ✅ Mover documentos análisis a la rama
3. ✅ Crear PR draft con toda esta especificación
4. ✅ Asignar equipo: Frontend (3.1, 3.3, 3.5) + Backend (3.2, 3.4)
5. ✅ Dar start a HU-3.1 (foundation para resto)

---

**Especificación validada. Listo para ejecución.**
