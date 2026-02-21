# 🆔 Tech Profile: LangChain (Python)

> **Categoría:** LLM Orchestration Framework
> **Versión Goal:** 0.1.0+ (LCEL Stable)
> **Licencia:** MIT

El marco estándar para construir aplicaciones conscientes del contexto (Context-Aware) y razonamiento (Reasoning).

---

## 📖 Table of Contents

1. [Casos de Uso (Suitability)](#casos-de-uso-suitability)
2. [Análisis de Valor (LCEL)](#análisis-de-valor-lcel)
3. [Requisitos del Sistema](#requisitos-del-sistema)
4. [Decisión de Adopción](#decisión-de-adopción)

---

## Casos de Uso (Suitability)

### ✅ Ideal Para (Best Fit)

* **RAG Pipelines Complejos:** Cadenas que requieren recuperación, re-ranking, historial de chat y citación de fuentes.
* **Salidas Estructuradas:** Convertir texto de LLM en JSON validado (Pydantic) para uso en APIs.
* **Agentes:** Sistemas que deciden qué herramientas usar (Búsqueda, Calculadora, API) basándose en input del usuario.
* **Razonamiento Multi-Paso:** Cadenas que requieren reflexión iterativa, verificación de salidas o planificación.

### ❌ No Usar Para (Anti-Patterns)

* **Llamadas Simples (One-shot):** Si solo necesitas enviar un prompt y recibir un string, usa el SDK del proveedor (OpenAI/Anthropic) o `requests` a Ollama. LangChain añade overhead innecesario aquí.
* **Producción Crítica de Latencia (<20ms):** La abstracción de LangChain añade milisegundos. Para High-Frequency Trading con LLMs, usa drivers nativos.
* **Modelos Pequeños Embebidos:** Si tu modelo es un `distilbert` para clasificación, LangChain es overkill.

---

## Análisis de Valor (LCEL)

La verdadera potencia reside en **LCEL (LangChain Expression Language)**:

* **Streaming Nativo:** Cualquier cadena construida con LCEL soporta `.stream()` y `.astream()` automáticamente. Sin código extra.
* **Paralelismo:** Ejecuta pasos independientes en paralelo sin código extra (`RunnableParallel`).
* **Trazabilidad:** Integración nativa con LangSmith para depurar pasos intermedios, examinar prompts exactos, ver latencias.
* **Composabilidad:** Cadenas son Runnables: `ChainA | ChainB | ChainC` crea automáticamente una nueva cadena válida.
* **TypeHints:** Las cadenas generadas con LCEL tienen type hints correctos (type-safe).

### Evolución de LangChain

| Era | Patrón | Estado |
|:---|:---|:---|
| **2023 (Legacy)** | `LLMChain(llm=..., prompt=...)` | ❌ Deprecado |
| **2024 (Presente)** | `prompt \| model \| parser` (LCEL) | ✅ Estándar Actual |
| **Futuro (Post-2025)** | Posiblemente Semantic Kernel v1.0 | ⏳ Monitorear |

**Decisión SoftArchitect:** Adoptar **LCEL exclusivamente**. Rechazar cualquier código que use `LLMChain` en PRs.

---

## Requisitos del Sistema

### Paquetes Python

```bash
# Core
pip install langchain>=0.1.0
pip install langchain-core>=0.1.0

# Comunidad (Integraciones)
pip install langchain-community>=0.0.10

# Proveedores LLM (elige según stack)
pip install langchain-openai    # OpenAI GPT-4/3.5
pip install langchain-anthropic # Claude
pip install ollama              # Para Ollama local

# Vector Stores
pip install chromadb            # Local
pip install pinecone-client     # Cloud
```

### Versión Python

* **Mínima:** 3.10 (type hints modernos)
* **Recomendada:** 3.11+ (performance en `asyncio`)

### Dependencias Transversales

* `pydantic>=2.0` - Para esquemas estructurados
* `httpx` - Cliente async para APIs
* `tenacity` - Reintentos con exponential backoff

---

## Decisión de Adopción

✅ **SoftArchitect adopta LangChain como orquestador LLM estándar** bajo estas condiciones:

1. **Todas las cadenas usan LCEL** (pipe syntax `|`)
2. **Todos los outputs se validan con Pydantic**
3. **Streaming es la opción por defecto** para UX fluida
4. **LangSmith se integra en staging/prod** para observabilidad

---

**Date:** 30 de Enero de 2026
**Status:** ✅ ADOPTADO
**Responsable:** ArchitectZero AI Agent
