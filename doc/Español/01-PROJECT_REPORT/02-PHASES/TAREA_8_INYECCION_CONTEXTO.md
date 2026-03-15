# Informe de Completion — Tarea 8: Inyección de Contexto al LLM (Pipeline de Documentos)

> **Fecha:** 17 de junio de 2026
> **Estado:** ✅ **COMPLETADO 100%**
> **Rama:** `feature/hu-5.0-full-workflow-refinement`
> **Alcance:** Full-stack — cliente Flutter + backend FastAPI

---

## Tabla de Contenidos

1. [Resumen Ejecutivo](#resumen-ejecutivo)
2. [Diagnóstico del Problema](#diagnóstico-del-problema)
3. [Arquitectura de la Solución](#arquitectura-de-la-solución)
4. [Archivos Modificados](#archivos-modificados)
5. [Cobertura de Tests](#cobertura-de-tests)
6. [Puertas de Calidad](#puertas-de-calidad)
7. [Lecciones Aprendidas](#lecciones-aprendidas)

---

## Resumen Ejecutivo

La Tarea 8 cierra un **bug crítico de pérdida silenciosa de datos** que causaba que
el LLM "olvidara" todos los documentos generados con anterioridad en la misma sesión.
El cliente Flutter ya recogía el contexto del proyecto correctamente, pero **tres capas
del backend descartaban los datos en silencio** antes de que llegaran al prompt del LLM.

Los tres fallos han sido reparados.  El LLM ahora recibe todos los documentos ya
generados en un bloque XML (`<project_documents>`) dentro de cada prompt, proporcionando
una fuente de verdad autoritativa que previene contenido inconsistente (nombres de
proyecto distintos, distinto stack tecnológico, idioma incorrecto).

**Resultado:** Pipeline extremo-a-extremo completamente operativo.  Se han añadido 22
nuevos tests unitarios de backend.  Todas las puertas de calidad en verde.

---

## Diagnóstico del Problema

### La Cadena (Flutter → FastAPI → LLM)

```
Flutter ChatNotifier.sendMessage()
  └─ gatherProjectContext()          ← lee todos los .md / .json del disco
  └─ ChatRepositoryImpl.sendMessageStream(projectContext: ...)
       └─ POST /api/v1/chat/stream   ← cuerpo HTTP incluye el mapa project_context
            └─ ChatRequest (Pydantic)    ← ❌ BUG 1: campo ausente
            └─ endpoint /stream          ← ❌ BUG 2: campo no reenviado
            └─ SequentialOrchestrator
                 └─ _build_prompt()      ← ❌ BUG 3: nunca se lee del dict de contexto
                 └─ llamada al LLM
```

### Los Tres Bugs

| # | Archivo | Bug |
|---|---------|-----|
| 1 | `chat_schema.py` | El modelo Pydantic `ChatRequest` no tenía el campo `project_context` — Pydantic descartaba los datos sin error |
| 2 | `chat.py` | El endpoint `/stream` solo pasaba `chat_history`, `project_id` y `user_name` al diccionario de contexto del orquestador — `project_context` nunca se reenviaba |
| 3 | `sequential_orchestrator.py` | `_build_prompt()` nunca leía `project_context` del diccionario de contexto, por lo que incluso si los bugs anteriores hubieran sido corregidos el LLM no vería los documentos |

---

## Arquitectura de la Solución

### Nuevo Flujo de Datos

```
project_context: dict[str, str]
   │
   ├─ ChatRequest.project_context    (campo Pydantic, default={})
   │
   ├─ dict contexto de /stream       ("project_context": request.project_context)
   │
   └─ _build_project_documents_block(project_context)
         │
         ├─ Omite dicts vacíos → devuelve ""
         ├─ Trunca cada doc a _MAX_DOC_CHARS (3 000 caracteres)
         ├─ Deja de añadir archivos tras _MAX_TOTAL_CONTEXT_CHARS (12 000 caracteres)
         └─ Devuelve bloque XML <project_documents>
              │
              └─ Inyectado en _build_prompt() entre RAG context y critical_rules
```

### Orden de Inyección en el Prompt

1. `injection_block`      — Template del workflow + ejemplo (WorkflowInjector)
2. `rag_context`          — Fragmentos RAG de la base de conocimiento
3. `project_documents`    — **NUEVO** Documentos del proyecto ya generados (Tarea 8)
4. `critical_rules`       — Restricciones de formato de salida (regla 8 añadida: consistencia)
5. `conversation_history` — Últimos 4 mensajes
6. `user_input`           — Petición actual del usuario

### Constantes de Presupuesto

| Constante | Valor | Propósito |
|-----------|-------|-----------|
| `_MAX_DOC_CHARS` | 3 000 | Límite de truncado por archivo |
| `_MAX_TOTAL_CONTEXT_CHARS` | 12 000 | Tope total del bloque (seguridad context-window) |

---

## Archivos Modificados

### Backend — Python FastAPI

#### `src/server/app/domain/schemas/chat_schema.py`
```python
# Campo añadido a ChatRequest (completamente ausente antes)
project_context: dict[str, str] = Field(
    default_factory=dict,
    description=(
        "Contexto completo del proyecto: todos los archivos .md/.json ya "
        "generados para este proyecto concreto (carpeta context/ + raíz). "
        "Lo utiliza el orquestador LLM para mantener consistencia entre "
        "todos los documentos."
    ),
)
```

#### `src/server/app/api/v1/chat.py`
```python
# Añadido al dict de contexto en el endpoint /stream (estaba completamente ausente)
"project_context": request.project_context,  # Tarea 8: evitar amnesia del LLM
```

#### `src/server/app/services/rag/sequential_orchestrator.py`
- Docstring de módulo añadido describiendo el contrato de orquestación.
- Constantes `_MAX_DOC_CHARS = 3_000` y `_MAX_TOTAL_CONTEXT_CHARS = 12_000`.
- Nuevo método `_build_project_documents_block(project_context: dict[str, str]) -> str`
  con PyDoc completo, truncado por documento, guarda de presupuesto total y serialización XML.
- `_build_prompt()` reescrito para extraer `project_context` del dict de contexto,
  llamar a `_build_project_documents_block()` e inyectar el resultado si no está vacío.
- Regla crítica #8 añadida: el LLM debe ser 100% coherente con `<project_documents>`.

### Nuevos Archivos de Tests — Python

#### `tests/server/services/rag/test_sequential_orchestrator.py`
22 tests unitarios en 4 clases:

| Clase | Tests | Foco de cobertura |
|-------|-------|-------------------|
| `TestBuildProjectDocumentsBlock` | 9 | Estructura XML, truncado, guarda de presupuesto, instrucción de consistencia |
| `TestBuildPromptProjectContext` | 7 | Presencia/ausencia del bloque, orden, regla 8, gestión graceful de non-dict |
| `TestGenerateWithProjectContext` | 3 | Streaming con/sin contexto, spy del prompt al LLM |
| `TestChatRequestSchema` | 2 | Schema acepta campo, valor por defecto dict vacío |

#### `tests/server/services/rag/conftest.py`
- Parchea la cadena de importaciones rota `google.generativeai` / `google.api_core` /
  `cryptography` que causa `ImportError` en el venv de tests.
- Usa el helper `_make_package()` que establece `__path__` para que Python permita
  sub-importaciones.
- Aplicado en tiempo de colección (ejecutado antes de que se importe cualquier test).

---

## Cobertura de Tests

```
tests/server/services/rag/test_sequential_orchestrator.py
====================== 22 passed in 0.12s ========================
```

Todos los tests Flutter anteriores siguen en verde:
- Tests unitarios: 143 pasados
- Tests de integración: 4 pasados, 2 omitidos

---

## Puertas de Calidad

| Puerta | Herramienta | Resultado |
|--------|-------------|-----------|
| Formato | `black` | ✅ `sequential_orchestrator.py` reformateado |
| Linting | `ruff` | ✅ Todas las comprobaciones pasadas |
| Tipos | `pyright` | ✅ 0 errores, 0 avisos |
| Dart lint | `flutter analyze` | ✅ Sin incidencias |
| Tests unitarios | `pytest` | ✅ 22/22 pasados |

---

## Lecciones Aprendidas

1. **Los contratos de interfaz deben validarse de extremo a extremo.**  El cliente
   Flutter enviaba los datos correctamente, pero cada capa intermedia los descartaba
   silenciosamente.  Un test de contrato en el límite del esquema HTTP habría detectado
   esto de inmediato.

2. **`default_factory=dict` en Pydantic no es suficiente sin que el campo exista.**
   Si el campo no está declarado en el modelo, Pydantic ignora los datos sin advertencia.

3. **Las guardas de presupuesto de tokens pertenecen a la capa de inyección.**
   El método `_build_project_documents_block()` es dueño de la lógica de truncado
   para que ningún llamador pueda desbordar accidentalmente la ventana de contexto.

4. **Las assertions de tests deben ser precisas.**  Dos tests comprobaban inicialmente
   `"<project_documents>" not in prompt`, pero esa cadena también aparece literalmente
   dentro del texto de critical_rules (regla 8).  Corregido comprobando
   `"</project_documents>"` (etiqueta de cierre), que solo emite el bloque XML real.
