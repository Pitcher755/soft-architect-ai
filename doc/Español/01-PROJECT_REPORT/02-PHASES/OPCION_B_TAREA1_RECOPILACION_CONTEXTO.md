# Opción B — Tarea 1: Recopilación de Contexto (Frontend)

> **Categoría:** 01-PROJECT_REPORT / 02-PHASES
> **Fecha:** 2026-03-16
> **Estado:** ✅ Completado
> **Rama:** `feature/hu-5.0-full-workflow-refinement`
> **Alcance:** Inyección de contexto con grafo de dependencias estático — pipeline Flutter ↔ Python

---

## 📋 Tabla de Contenidos

1. [Resumen](#resumen)
2. [Cambios Implementados](#cambios-implementados)
   - [2.1 ProjectProgressService.gatherProjectContext()](#21-projectprogressservicegatherprojectcontext)
   - [2.2 ChatNotifier.sendMessageStream()](#22-chatnotifiersendmessagestream)
   - [2.3 Interfaz ChatRepository](#23-interfaz-chatrepository)
   - [2.4 ChatRepositoryImpl.sendMessageStream()](#24-chatrepositoryimplsendmessagestream)
   - [2.5 Backend: Presupuesto Adaptativo](#25-backend-presupuesto-adaptativo)
   - [2.6 Backend: Helper _buildHistoryText()](#26-backend-helper-_buildhistorytext)
3. [Cobertura de Tests](#cobertura-de-tests)
4. [Quality Gates](#quality-gates)
5. [Decisión de Arquitectura](#decisión-de-arquitectura)
6. [Diagrama de Flujo de Datos](#diagrama-de-flujo-de-datos)

---

## Resumen

Esta tarea implementa el componente de **Recopilación de Contexto en el Frontend** dentro de la estrategia de Grafo de Dependencias Estático (Opción B, ADR-002).

Antes de esta tarea, el frontend Flutter enviaba únicamente el mensaje del usuario al backend.
Tras esta tarea, cada petición también lleva `project_context`: un `Map<String, String>` de rutas relativas → contenido de archivo, para todos los ficheros `.md` y `.json` del proyecto objetivo.

Esto cierra el **bucle de amnesia del LLM**: aunque cada petición HTTP es sin estado, la IA ahora recibe los documentos que ya generó para este proyecto concreto y puede mantener consistencia (nombre del proyecto, stack tecnológico, vocabulario de dominio, idioma) a lo largo de los 24 pasos del workflow.

---

## Cambios Implementados

### 2.1 ProjectProgressService.gatherProjectContext()

**Archivo:** [src/client/lib/features/project_shell/infrastructure/services/project_progress_service.dart](../../../../src/client/lib/features/project_shell/infrastructure/services/project_progress_service.dart)

**Firma:**
```dart
static Future<Map<String, String>> gatherProjectContext(String projectPath)
```

**Comportamiento:**
- Retorna `{}` inmediatamente en proyectos mock (prefijo `mock://`) — sin coste de I/O.
- Escanea recursivamente `<projectPath>/context/` buscando archivos `.md` y `.json`, excluyendo patrones `readme` y `untitled`.
- Lee los 4 documentos de la fase ROOT desde la raíz: `RULES.md`, `CONTRIBUTING.md`, `AGENTS.md`, `README.md`.
- Usa **rutas relativas** como claves (ej. `context/10-CONTEXT/PROJECT_MANIFESTO.md`) para que el backend las resuelva contra el grafo de dependencias `MASTER_WORKFLOW`.
- No fatal: las excepciones `FileSystemException` individuales se capturan por archivo y se registran en el log; el mapa se retorna con los archivos leídos con éxito.

```dart
final context = await ProjectProgressService.gatherProjectContext(projectPath);
// Retorna p.ej.:
// {
//   'context/10-CONTEXT/PROJECT_MANIFESTO.md': '# Manifiesto del Proyecto\n...',
//   'context/20-REQUIREMENTS/REQUIREMENTS_MASTER.md': '# Requisitos\n...',
//   'RULES.md': '# Reglas de Desarrollo\n...',
// }
```

### 2.2 ChatNotifier.sendMessageStream()

**Archivo:** [src/client/lib/features/chat/presentation/notifiers/chat_notifier.dart](../../../../src/client/lib/features/chat/presentation/notifiers/chat_notifier.dart)

`sendMessageStream` llama a `gatherProjectContext` antes de despachar la petición de stream:

```dart
// 🧠 Recopila el contexto completo del proyecto para inyección en el LLM (Opción B)
final projectContext = await ProjectProgressService.gatherProjectContext(
  projectPath,
);

final stream = repository.sendMessageStream(
  message,
  projectId,
  docType: currentDocType,
  userName: currentUserName,
  history: compatibleHistory,
  projectContext: projectContext,     // ← inyectado aquí
);
```

**Decisiones de diseño:**
- La llamada es `await`-ada antes de iniciar el stream; el pequeño coste de I/O (leer pocos KB) es preferible a una condición de carrera en el streaming.
- Los proyectos mock retornan inmediatamente con `{}` para no afectar la UX del modo guía.

### 2.3 Interfaz ChatRepository

**Archivo:** [src/client/lib/features/chat/domain/repositories/chat_repository.dart](../../../../src/client/lib/features/chat/domain/repositories/chat_repository.dart)

La interfaz ya declaraba `projectContext` como parámetro nombrado opcional:

```dart
Stream<ChatStreamEvent> sendMessageStream(
  String message,
  String projectId, {
  String? docType,
  String? userName,
  List<ChatMessage>? history,
  Map<String, String>? projectContext,  // ← inyección de contexto
});
```

Sin cambios necesarios; el contrato quedó establecido en la Tarea 8.

### 2.4 ChatRepositoryImpl.sendMessageStream()

**Archivo:** [src/client/lib/features/chat/data/repositories/chat_repository_impl.dart](../../../../src/client/lib/features/chat/data/repositories/chat_repository_impl.dart)

La implementación serializa el mapa dentro del body de la petición de forma condicional (sólo se incluye cuando no es nulo ni vacío), preservando compatibilidad hacia atrás:

```dart
final body = {
  'message': message,
  'project_id': projectId,
  // ...
  if (projectContext != null && projectContext.isNotEmpty)
    'project_context': projectContext,
};
```

### 2.5 Backend: Presupuesto Adaptativo

**Archivo:** [src/server/app/services/rag/sequential_orchestrator.py](../../../../src/server/app/services/rag/sequential_orchestrator.py)

Resuelve la causa raíz de los errores HTTP 500 de Gemini a partir del documento 5.

#### Inyección de contexto en dos etapas:

**Etapa 1 — Filtrado por grafo de dependencias (`_filter_relevant_context`)**

Reduce el mapa completo de `project_context` a SÓLO los 2-4 archivos que son predecesores directos del `doc_type` actual, tal como se declara en `CONTEXT_DEPENDENCIES` (workflow.py):

```python
# Para DOMAIN_LANGUAGE:  necesita ["PROJECT_MANIFESTO"]
# Para USER_STORIES:     necesita ["PROJECT_MANIFESTO", "DOMAIN_LANGUAGE", "REQUIREMENTS_MASTER"]
needed_types: list[str] = get_context_dependencies(doc_type)
```

Esto mantiene el bloque `<project_documents>` con tamaño constante independientemente del avance en el workflow.

**Etapa 2 — Presupuesto de caracteres adaptativo (`_build_prompt`)**

Mide todas las demás secciones antes de calcular el espacio restante para los documentos del proyecto:

```python
static_sections_chars = (
    len(injection_block) + len(rag_context) +
    len(history_text) + len(user_input) + 2_000  # overhead
)
adaptive_budget = min(
    max(0, _MAX_PROMPT_CHARS - static_sections_chars),
    _MAX_TOTAL_CONTEXT_CHARS,
)
```

**Red de seguridad:** si el prompt final ensamblado aún excede `_MAX_PROMPT_CHARS`, el bloque `<project_documents>` se descarta para entregar una respuesta válida (aunque menos rica en contexto) en lugar de un error 500 de Gemini.

#### Constantes introducidas:

| Constante | Valor | Propósito |
|---|---|---|
| `_MAX_DOC_CHARS` | 1 200 | Límite de truncación por archivo |
| `_MAX_TOTAL_CONTEXT_CHARS` | 4 800 | Límite absoluto para el bloque `<project_documents>` completo |
| `_MAX_PROMPT_CHARS` | 60 000 | Techo del prompt (~15 k tokens, seguro para el tier gratuito de Gemini) |

### 2.6 Backend: Helper _buildHistoryText()

Se extrajo la lógica de serialización del historial de `_build_prompt` a un método privado dedicado para reducir la complejidad ciclomática (anteriormente C901: 11 > 10):

```python
def _build_history_text(self, raw_history: Any) -> str:
    """Serializa el historial de chat a una cadena compacta para inyección en el LLM.
    Mantiene los últimos 4 mensajes. Las respuestas grandes del asistente son
    reemplazadas por un marcador corto para evitar saturar la ventana de contexto.
    """
```

---

## Cobertura de Tests

### Flutter (Dart)

| Archivo | Tests nuevos | Enfoque |
|---|---|---|
| `project_progress_service_test.dart` | 9 | `gatherProjectContext`: scan .md, scan .json, archivos ROOT, exclusión README, exclusión untitled, scan recursivo, skip mock, context/ inexistente, manejo de errores, claves relativas |
| `chat_notifier_test.dart` | 0 nuevos (143 existentes pasan) | Ciclo de vida completo del notifier incluyendo `sendMessageStream` con repos mock |

### Python

| Archivo | Tests nuevos | Enfoque |
|---|---|---|
| `test_sequential_orchestrator.py` | 21 nuevos (43 total) | `_build_project_documents_block` presupuesto personalizado / presupuesto cero, `_build_prompt` red de seguridad hard cap, suite completa de `_filter_relevant_context` (7 tests), `TestBuildPromptWithDependencyFiltering` (3 tests), `TestContextDependencies` (8 tests) |

---

## Quality Gates

| Gate | Resultado |
|---|---|
| `black` | ✅ Reformateado (all done) |
| `ruff check` | ✅ All checks passed |
| `pyright` | ✅ 0 errores, 0 warnings |
| `pytest` (43 tests) | ✅ 43 pasados en 0.15s |
| `flutter analyze` | ✅ Sin problemas |
| Tests Flutter (project_shell) | ✅ 264 pasados |
| Tests Flutter (chat) | ✅ 143 pasados |

---

## Decisión de Arquitectura

Esta tarea implementa la **Opción B (Grafo de Dependencias Estático)** tal como se define en [ADR-002](../01-ARCHITECTURE/ADR_002_LLM_CONTEXT_INJECTION_STRATEGY.md).

El grafo se define en `workflow.py` como `CONTEXT_DEPENDENCIES: dict[str, list[str]]` mapeando cada `doc_type` a la lista de valores `doc_type` de sus predecesores requeridos.

**Evolución futura (Opción A):** Una vez que `VectorStoreService` tenga una conexión activa a ChromaDB, `_filter_relevant_context()` en `sequential_orchestrator.py` será reemplazado por una consulta semántica contra una colección vectorial por proyecto, proporcionando contexto más rico con menor coste en tokens.

---

## Diagrama de Flujo de Datos

```
Flutter (sendMessageStream)
  │
  ├── await gatherProjectContext(projectPath)
  │     ├── escanea context/ recursivamente (.md, .json)
  │     └── lee docs ROOT (RULES.md, etc.)
  │         → Map<String, String> { "context/10-CONTEXT/PROJECT_MANIFESTO.md": "..." }
  │
  └── ChatRepositoryImpl.sendMessageStream(projectContext: context)
        │
        └── POST /api/v1/chat/stream
              body: { ..., "project_context": { "context/10-CONTEXT/PROJECT_MANIFESTO.md": "..." } }

FastAPI (endpoint /stream)
  │
  └── SequentialOrchestrator.generate(context={"project_context": {...}})
        │
        ├── _filter_relevant_context(project_context, doc_type)
        │     └── conserva solo 2-4 archivos que coinciden con CONTEXT_DEPENDENCIES[doc_type]
        │
        ├── _build_prompt(...)
        │     ├── calcula adaptive_budget del espacio restante en el prompt
        │     ├── _build_project_documents_block(relevant, budget=adaptive_budget)
        │     │     └── serializa a <project_documents>...</project_documents>
        │     └── red de seguridad: descarta el bloque si prompt > _MAX_PROMPT_CHARS
        │
        └── llm_client.stream_generate(prompt)
              └── API de Gemini → stream de tokens → SSE → Flutter
```
