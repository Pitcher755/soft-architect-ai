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

El `SequentialOrchestrator` ensambla un prompt LLM compuesto a partir de tres capas:

1. **Contexto Global del Workflow** — instrucciones maestras y estado del workflow (inyectado por `WorkflowInjector`).
2. **Contexto RAG por Proyecto** — recuperado de ChromaDB mediante `project_store.query_project()`.
3. **Historial de Conversación** — turnos recientes de chat.

Se identificaron tres deficiencias independientes:

#### Problema 1 — Límite de Prompt Hardcodeado (Context Drift)

La red de seguridad original utilizaba una única constante fija:

```python
# ANTES: valor fijo, ignora completamente las capacidades del modelo
_MAX_PROMPT_CHARS = 200_000
```

Este valor es apropiado para modelos cloud de gran contexto (Gemini 1.5 Flash ≈ 1M tokens,
GPT-4 Turbo ≈ 128K tokens), pero causa **crashes por Out-Of-Memory (OOM)** al ejecutar
modelos locales Ollama con ventanas de contexto pequeñas:

| Modelo | Ventana de Contexto | ~Chars Seguros Máx. |
|--------|---------------------|----------------------|
| `llama3:8b` | 8.192 tokens | ~32.000 chars |
| `codellama:13b` | 16.384 tokens | ~65.000 chars |
| `mistral:7b` | 32.768 tokens | ~131.000 chars |
| `gemma2:9b` | 8.192 tokens | ~32.000 chars |

Los desarrolladores ejecutando SoftArchitect AI en un portátil estándar con Ollama recibían
errores OOM crípticos sin ninguna orientación sobre cómo resolverlos.

#### Problema 2 — Pérdida Silenciosa de Contexto (Riesgo de Alucinaciones)

Cuando el prompt ensamblado superaba `_MAX_PROMPT_CHARS`, la red de seguridad anterior descartaba
**silenciosamente** el bloque `<retrieved_context>` completo y reconstruía el prompt sin RAG:

```python
# ANTES: elimina todo el contexto RAG sin aviso — peligroso
if len(prompt) > _MAX_PROMPT_CHARS:
    prompt = _build_prompt_without_retrieved_context(...)
```

Esto creaba un **modo de fallo silencioso**: el LLM recibía el prompt sin ningún anclaje en la
base de conocimiento, aumentando la probabilidad de alucinaciones arquitectónicas y
recomendaciones de frameworks incorrectas. El comportamiento era invisible para el usuario final.

#### Problema 3 — Número de Resultados ChromaDB Fijo (Desperdicio de Tokens)

`n_results=5` estaba hardcodeado en cada llamada a `query_project()`. Para configuraciones con
presupuesto limitado de API o modelos locales ligeros, 5 chunks × ~500 tokens/chunk ≈ 2.500
tokens desperdiciados por consulta — un overhead de ~30% de tokens sin posibilidad de
configuración.

---

## 🎯 Decisión

**Reemplazar todos los límites RAG hardcodeados por configuración dirigida por variables de
entorno, y reemplazar la red de seguridad "eliminar-contexto" por truncación determinista del
prompt.**

### Implementación: Nuevas Constantes a Nivel de Módulo

```python
# src/server/app/services/rag/sequential_orchestrator.py
import os

# Techo máximo para el prompt LLM ensamblado completo (chars ≈ tokens × 4).
# Establecer en 30000 para modelos Ollama de 8K tokens locales, 200000 para Gemini/GPT-4.
_MAX_PROMPT_CHARS: int = int(os.getenv("LLM_MAX_PROMPT_CHARS", "200000"))

# Número de chunks RAG por proyecto devueltos por ChromaDB por consulta.
# Reducir a 2 para modelos de presupuesto/locales; aumentar a 5 para máxima precisión.
_RAG_MAX_CHUNKS: int = int(os.getenv("RAG_MAX_CHUNKS", "3"))
```

### Implementación: Nueva Red de Seguridad (Truncación)

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

**Invariante clave:** El bloque `<retrieved_context>` se coloca al inicio del orden de ensamblado
del prompt, por lo que la truncación afecta la *cola* del historial de conversación — no el
anclaje RAG. Esto garantiza que el conocimiento arquitectónico siempre llegue al modelo.

---

## ⚖️ Alternativas Consideradas

### Alternativa A — Detectar Automáticamente la Ventana de Contexto del Modelo al Inicio

Consultar la API REST de Ollama (`/api/show`) al arranque para recuperar metadatos del modelo
y establecer límites dinámicamente.

- ❌ **Rechazada:** Añade latencia de inicio (~200ms). No es portable a Groq/Gemini. Falla
  silenciosamente cuando Ollama está offline. Aumenta el acoplamiento con la forma de la API de Ollama.

### Alternativa B — Capturar OOM en la Capa HTTP y Devolver Error

Interceptar la excepción OOM a nivel del router FastAPI y devolver un HTTP 503 amigable.

- ❌ **Rechazada:** No *previene* el crash; solo lo maneja después de que la memoria del proceso
  está agotada. En configuraciones de proceso único, el subproceso Ollama es irrecuperable.
  El contexto del usuario se pierde.

### Alternativa C — Cabecera de Cliente por Solicitud (`X-Max-Prompt-Chars`)

Permitir que el frontend Flutter pase un hint de ventana de contexto en cada cabecera de
solicitud API.

- ❌ **Rechazada:** Aumenta la superficie de ataque (los usuarios podrían inyectar límites
  arbitrariamente grandes). La configuración pertenece al operador (`.env`), no al usuario
  final en tiempo de solicitud.

### Alternativa D — Resumen de Chunks RAG Antes del Ensamblado

Resumir cada chunk recuperado a un presupuesto fijo de tokens antes del ensamblado del prompt.

- ❌ **Rechazada (diferida a ADR futuro):** Añade una llamada LLM extra por solicitud
  (2× latencia). Aceptable para v2 pero fuera del alcance del MVP.

---

## ✅ Consecuencias

### Positivas

| Beneficio | Detalle |
|-----------|---------|
| **Hardware-Agnostic** | Un único binario — ajustado con una línea en `.env` para cualquier perfil de hardware |
| **Prevención de OOM** | Sin más crashes en modelos Ollama locales con ventanas de contexto pequeñas |
| **Sin Fallos Silenciosos** | La truncación emite log `WARNING`; el anclaje RAG siempre presente en el prompt |
| **Ahorro de Tokens** | Reducir `RAG_MAX_CHUNKS` de 5→2 ahorra ~30% de costes de tokens de API |
| **Testabilidad** | Ambas constantes son testables vía `importlib.reload()` + `patch.dict(os.environ)` |
| **Control del Operador** | Los valores están documentados en `.env.example` con guía por escenario |

### Negativas / Compensaciones

| Riesgo | Mitigación |
|--------|-----------|
| **Responsabilidad del Operador** | Los usuarios deben conocer la ventana de su modelo; mitigado por la documentación de `.env.example` |
| **Truncación del Historial** | El historial de conversación puede cortarse en longitudes extremas; se registra `WARNING` |
| **Sin Notificación en App** | El frontend no tiene indicador visual de truncación (aceptable para MVP) |
| **Patrón de Recarga de Módulo** | Los tests usan `importlib.reload()` que no es estándar; documentado en el archivo de tests |

---

## 📊 Referencia de Configuración

### Valores Recomendados por Perfil de Hardware

| Perfil | `LLM_MAX_PROMPT_CHARS` | `RAG_MAX_CHUNKS` | Notas |
|--------|------------------------|-----------------|-------|
| **Portátil — Ollama `llama3:8b`** | `30000` | `2` | Previene OOM; máx ~8K tokens |
| **Portátil — Ollama `mistral:7b`** | `80000` | `3` | Equilibrado; ~32K contexto |
| **Escritorio — Ollama `llama3:70b`** | `120000` | `4` | Modelo de alta RAM |
| **Cloud — Groq (nivel gratuito)** | `100000` | `3` | Consciente del rate-limit |
| **Cloud — Gemini 1.5 Flash** | `200000` | `5` | Máxima precisión; 1M contexto |
| **Cloud — GPT-4 Turbo** | `200000` | `4` | Ventana grande, con conciencia de coste |

### Fragmento de `.env`

```bash
# ─── CONFIGURACIÓN LLM & RAG (AVANZADO) ──────────────────────────────────────
# Techo máximo para el prompt LLM ensamblado completo (chars ≈ tokens × 4).
# Por defecto: 200000 (seguro para Gemini 1.5 Flash / GPT-4).
# Reducir a 30000 cuando se use Ollama local con contexto 8K para prevenir OOM.
LLM_MAX_PROMPT_CHARS=200000

# Número de chunks RAG por proyecto devueltos por ChromaDB por consulta.
# Por defecto: 3. Aumentar a 5 para máxima precisión, reducir a 2 para ahorro de costes.
RAG_MAX_CHUNKS=3
```

---

## 📁 Archivos Modificados

| Archivo | Cambio |
|---------|--------|
| `src/server/app/services/rag/sequential_orchestrator.py` | Constantes → controladas por env; red de seguridad → truncación |
| `src/server/.env.example` | Nueva sección: `LLM & RAG CONFIGURATION (ADVANCED)` |
| `src/server/README.md` | Nueva subsección: `LLM & RAG Configuration (Advanced)` |
| `tests/server/unit/services/rag/test_sequential_orchestrator.py` | Clase `TestEnvVarConfiguration` (2 tests nuevos) |
| `context/30-ARCHITECTURE/ADR/ADR-002-Configurable-RAG-Limits.en.md` | Versión en inglés |
| `context/30-ARCHITECTURE/ADR/ADR-002-Configurable-RAG-Limits.es.md` | Este documento |

---

## 🔗 Referencias

- [Arquitectura y Flujo RAG](../RAG_ARCHITECTURE_AND_FLOW.es.md) — Diseño actual del pipeline RAG
- [README del Servidor — Configuración LLM & RAG](../../../src/server/README.md) — Guía de configuración operacional
- [ADR-005: Ajuste de Temperatura LLM](ADR-005-LLM-TEMPERATURE-ADJUSTMENT.es.md) — Ajuste LLM relacionado
- [`.env.example`](../../../src/server/.env.example) — Todas las variables configurables
- [OWASP Validación de Entrada](https://owasp.org/www-community/controls/Input_Validation) — Referencia de seguridad
