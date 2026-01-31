# 🆔 Tech Profile: Microsoft Semantic Kernel

> **Categoría:** AI Orchestration SDK
> **Mantenedor:** Microsoft
> **Lenguajes:** Python, C#, Java
> **Versión Objetivo:** 1.0.0+

El SDK ligero para integrar LLMs con código existente ("Native Functions").

---

## 📖 Tabla de Contenidos

1. [Casos de Uso (Suitability)](#casos-de-uso-suitability)
2. [Conceptos Clave](#conceptos-clave)
3. [Comparativa: SK vs LangChain](#comparativa-sk-vs-langchain)
4. [Requisitos del Sistema](#requisitos-del-sistema)
5. [Decisión de Adopción](#decisión-de-adopción)

---

## Casos de Uso (Suitability)

### ✅ Ideal Para (Best Fit)

* **Entornos Microsoft/Enterprise:** Integración nativa con Azure OpenAI y sistemas .NET/Python corporativos.
* **Sistemas Híbridos (Code + AI):** Cuando necesitas mezclar lógica determinista (cálculos, acceso a DB) con lógica semántica (LLM) de forma transparente.
* **Planificación Automática (Planners):** Dejar que el LLM decida qué funciones ejecutar para resolver un objetivo ("Goal-Oriented AI").
* **Flujos de Trabajo Largos:** Plugins reutilizables que se ejecutan en secuencia dirigida por el LLM.

### ❌ No Usar Para (Anti-Patterns)

* **Prototipado Rápido "Hackathon":** LangChain tiene más "baterías incluidas" y tutoriales para empezar rápido.
* **Cadenas Puramente Semánticas:** Si no vas a usar código nativo (funciones), SK añade abstracción innecesaria.
* **Chatbots Simples:** Para un Q&A básico, RAG con LangChain es más simple.

---

## Conceptos Clave

### Kernel
El corazón de SK. Gestiona:
- Servicios (modelos: OpenAI, Ollama, Cohere)
- Plugins (grupos de funciones)
- Memorias (contexto de la sesión)
- Planners (lógica de ejecución)

### Plugins (Antes Skills)
Colecciones de funciones relacionadas.

**Dos tipos:**
1. **Semantic Functions:** Prompts templados (`.skprompt.txt`)
2. **Native Functions:** Código determinista (Python/C# con `@kernel_function`)

### Planners
Componentes que "piensan" cómo resolver un goal.

* **HandlebarsPlanner:** Genera planes usando lógica condicional (recomendado)
* **StepwisePlanner:** Ejecuta step-by-step, permitiendo feedback iterativo

### Connectors
Integraciones con memorias y modelos.

* **Memory Connectors:** Pinecone, Chroma, Milvus
* **LLM Connectors:** Azure OpenAI, OpenAI, Ollama, Anthropic

---

## Comparativa: SK vs LangChain

| Aspecto | Semantic Kernel | LangChain |
|:---|:---|:---|
| **Filosofía** | Plugins + Planners (Goal-Driven) | Chains + Runnables (Pipe-Based) |
| **Native Code** | ✅ Nativo (Funciones reales) | ⚠️ Mediante tools (LLM elige) |
| **Simplicidad** | ⚠️ Curva de aprendizaje media | ✅ Muy simple para starters |
| **Enterprise** | ✅ Microsoft backing | ⚠️ Comunidad + LangChain Inc |
| **Escalabilidad** | ✅ Petabytes (Azure) | ✅ Sí, pero con más código |
| **Planificación Automática** | ✅ Built-in (HandlebarsPlanner) | ⚠️ Mediante AgentExecutor |
| **Orquestación** | ✅ Kernel es un bus de servicios | ⚠️ Cadenas composables |
| **Prompts Externos** | ✅ `.skprompt.txt` files | ⚠️ Strings o `ChatPromptTemplate` |

**Decisión SoftArchitect:**
- **LangChain:** Camino "Hacker" para startups/prototipado
- **Semantic Kernel:** Camino "Enterprise" para sistemas integrados

---

## Requisitos del Sistema

### Paquetes Python

```bash
# Core
pip install semantic-kernel>=0.10.0

# Integraciones
pip install semantic-kernel[openai]        # Azure OpenAI
pip install semantic-kernel[ollama]        # Local
pip install semantic-kernel[pinecone]      # Vector DB
```

### Versión Python

* **Mínima:** 3.9 (async/await bien soportado)
* **Recomendada:** 3.11+ (performance)

### Dependencias Transversales

* `pydantic>=2.0` - Validación de esquemas
* `openai>=1.0` - Para Azure OpenAI connector
* `pinecone-client>=3.0` - Para vector store connector

---

## Decisión de Adopción

✅ **SoftArchitect adopta Semantic Kernel para el stack Enterprise/Cloud** bajo estas condiciones:

1. **Plugins bien organizados:** Separación clara entre Semantic y Native functions
2. **Planner + Kernel:** Usar HandlebarsPlanner para orquestación automática
3. **Integración con Pinecone:** SK + Pinecone es la pila recomendada para producción
4. **Namespaces en memoria:** Multi-tenancy mediante namespaces, no múltiples índices

---

**Fecha:** 30 de Enero de 2026
**Status:** ✅ ADOPTED (Enterprise Stack)
**Responsable:** ArchitectZero AI Agent
