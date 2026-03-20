# ADR-002: Límites RAG Configurables mediante Variables de Entorno

> **Estado:** ✅ Aceptado
> **Fecha:** 2026-03-20
> **Decisores:** Equipo de Desarrollo + ArchitectZero
> **HU Relacionada:** HU-5.0 (Refinamiento del Workflow Completo — Tarea 16)

---

## 📋 Tabla de Contenidos

1. [Contexto](#contexto)
2. [Decisión](#decisión)
3. [Alternativas Consideradas](#alternativas-consideradas)
4. [Consecuencias](#consecuencias)
5. [Referencia de Configuración](#referencia-de-configuración)
6. [Archivos Modificados](#archivos-modificados)
7. [Referencias](#referencias)

---

## 📖 Contexto

### El Problema: Crashes por OOM y Pérdida Silenciosa de Contexto

El `SequentialOrchestrator` ensambla un prompt LLM compuesto de tres capas:

1. **Contexto Global del Workflow** — instrucciones maestras y estado del workflow (inyectado por `WorkflowInjector`).
2. **Contexto RAG por Proyecto** — recuperado de ChromaDB mediante `project_store.query_project()`.
3. **Historial de Conversación** — turnos recientes de chat.

Se identificaron tres deficiencias independientes:

#### Problema 1 — Límite Hardcodeado (Context Drift)

```python
# ANTES: valor fijo, ignora completamente las capacidades del modelo
_MAX_PROMPT_CHARS = 200_000
```

Este valor es apropiado para modelos cloud de gran contexto pero causa **crashes OOM** en modelos
Ollama locales con ventanas pequeñas:

| Modelo | Ventana de Contexto | ~Chars Seguros Máx. |
|--------|---------------------|----------------------|
| `llama3:8b` | 8.192 tokens | ~32.000 chars |
| `codellama:13b` | 16.384 tokens | ~65.000 chars |
| `mistral:7b` | 32.768 tokens | ~131.000 chars |
| `gemma2:9b` | 8.192 tokens | ~32.000 chars |

#### Problema 2 — Pérdida Silenciosa de Contexto (Riesgo de Alucinaciones)

```python
# ANTES: elimina todo el contexto RAG sin aviso — peligroso
if len(prompt) > _MAX_PROMPT_CHARS:
    prompt = _build_prompt_without_retrieved_context(...)
```

Modo de fallo silencioso: el LLM recibía el prompt sin anclaje en la base de conocimiento,
aumentando la probabilidad de alucinaciones arquitectónicas.

#### Problema 3 — Número de Resultados ChromaDB Fijo (Desperdicio de Tokens)

`n_results=5` hardcodeado ≈ 2.500 tokens desperdiciados por consulta — un overhead ~30% sin
posibilidad de configuración.

---

## 🎯 Decisión

**Reemplazar todos los límites RAG hardcodeados por variables de entorno, y reemplazar la red
de seguridad "eliminar-contexto" por truncación determinista del prompt.**

### Nuevas Constantes a Nivel de Módulo

```python
# src/server/app/services/rag/sequential_orchestrator.py
import os

_MAX_PROMPT_CHARS: int = int(os.getenv("LLM_MAX_PROMPT_CHARS", "200000"))
_RAG_MAX_CHUNKS: int = int(os.getenv("RAG_MAX_CHUNKS", "3"))
```

### Nueva Red de Seguridad (Truncación)

```python
# DESPUÉS: trunca determinísticamente; el contexto RAG SIEMPRE está presente hasta el límite
if len(prompt) > _MAX_PROMPT_CHARS:
    logger.warning(
        "Prompt exceeded hard cap (%d > %d chars). Truncating.",
        len(prompt),
        _MAX_PROMPT_CHARS,
    )
    prompt = prompt[:_MAX_PROMPT_CHARS]
```

**Invariante clave:** El bloque `<retrieved_context>` se coloca al inicio del prompt, por lo que
la truncación afecta la cola del historial de conversación, nunca el anclaje RAG.

---

## ⚖️ Alternativas Consideradas

### Alternativa A — Detección Automática de Ventana de Contexto

Consultar la API de Ollama al arranque para obtener metadatos del modelo.
❌ **Rechazada:** Latencia, problemas de portabilidad y fallos silenciosos cuando Ollama está offline.

### Alternativa B — Capturar OOM en la Capa HTTP

Interceptar la excepción OOM en el router FastAPI y devolver HTTP 503.
❌ **Rechazada:** No previene el crash; la memoria del proceso ya está agotada.

### Alternativa C — Cabecera de Cliente por Solicitud

Permitir que el frontend pase `X-Max-Prompt-Chars` en cabeceras de solicitud.
❌ **Rechazada:** Aumenta la superficie de ataque; la configuración pertenece al operador.

### Alternativa D — Resumen de Chunks RAG

Resumir cada chunk a un presupuesto fijo de tokens antes del ensamblado.
❌ **Rechazada (diferida):** Añade una llamada LLM extra por solicitud (2× latencia). Diferida a v2.

---

## ✅ Consecuencias

### Positivas

| Beneficio | Detalle |
|-----------|---------|
| **Hardware-Agnostic** | Un único binario ajustado con una línea en `.env` para cualquier perfil de hardware |
| **Prevención de OOM** | Sin más crashes en modelos Ollama locales |
| **Sin Fallos Silenciosos** | La truncación emite log `WARNING`; el anclaje RAG siempre presente |
| **Ahorro de Tokens** | `RAG_MAX_CHUNKS` 5→2 ahorra ~30% de costes de tokens de API |
| **Testabilidad** | Constantes testables vía `importlib.reload()` + `patch.dict(os.environ)` |

### Negativas / Compensaciones

| Riesgo | Mitigación |
|--------|-----------|
| **Responsabilidad del Operador** | Debe configurar límites por modelo; mitigado por documentación de `.env.example` |
| **Truncación del Historial** | Conversaciones muy largas pueden cortarse; se registra `WARNING` |
| **Sin Notificación en App** | Sin indicador visual de truncación (aceptable para MVP) |

---

## 📊 Referencia de Configuración

| Perfil | `LLM_MAX_PROMPT_CHARS` | `RAG_MAX_CHUNKS` |
|--------|------------------------|-----------------|
| Portátil — Ollama `llama3:8b` | `30000` | `2` |
| Portátil — Ollama `mistral:7b` | `80000` | `3` |
| Escritorio — Ollama `llama3:70b` | `120000` | `4` |
| Cloud — Groq (nivel gratuito) | `100000` | `3` |
| Cloud — Gemini 1.5 Flash | `200000` | `5` |
| Cloud — GPT-4 Turbo | `200000` | `4` |

---

## 📁 Archivos Modificados

| Archivo | Cambio |
|---------|--------|
| `src/server/app/services/rag/sequential_orchestrator.py` | Constantes → env; red de seguridad → truncación |
| `src/server/.env.example` | Nueva sección: `LLM & RAG CONFIGURATION (ADVANCED)` |
| `src/server/README.md` | Nueva subsección de configuración avanzada |
| `tests/server/unit/services/rag/test_sequential_orchestrator.py` | Clase `TestEnvVarConfiguration` (2 tests nuevos) |

---

## 🔗 Referencias

- [ADR primario (context/)](../../../../context/30-ARCHITECTURE/ADR/ADR-002-Configurable-RAG-Limits.es.md)
- [Arquitectura y Flujo RAG](../../../../context/30-ARCHITECTURE/RAG_ARCHITECTURE_AND_FLOW.es.md)
- [README del Servidor — Configuración LLM & RAG](../../../../src/server/README.md)
- [ADR-005: Ajuste de Temperatura LLM](ADR-005-LLM-TEMPERATURE-ADJUSTMENT.md)
- [`.env.example`](../../../../src/server/.env.example)
