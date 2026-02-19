# 🎛️ Ollama Model Parameters & Customization

> **Date:** 30/01/2026
> **Status:** ✅ Desplegado
> **Goal:** Afinar comportamiento del modelo LLM sin reentrenamiento
> **Audiencia:** Backend Engineers, ML/AI Specialists

Cómo configurar Ollama para que genere respuestas **deterministas, seguras y específicas del dominio** SoftArchitect.

---

## 📋 Table of Contents

1. [Parámetros Críticos](#parámetros-críticos)
2. [Modelfile: Crear Modelos Custom](#modelfile-crear-modelos-custom)
3. [Prompt Engineering Best Practices](#prompt-engineering-best-practices)
4. [Debugging & Validation](#debugging--validation)
5. [Pre-Production Checklist](#pre-production-checklist)

---

## Parámetros Críticos

### Control Central: Tabla de Parámetros

| Parámetro | Rango | Valor SoftArchitect | Efecto |
|:---|:---|:---|:---|
| **`temperature`** | 0.0 - 2.0 | **0.0 - 0.3** | Creatividad. 0=determinista (perfecta para RAG). 1.0=default. 2.0=aleatorio |
| **`num_ctx`** | 128 - 32k | **8192** | Ventana de contexto. Cuántos tokens "recuerda". SoftArchitect inyecta 3-5 docs (~4k tokens) |
| **`num_predict`** | 1 - 32k | **500** | Máximo de tokens a generar. Evita responses infinitas |
| **`top_p`** | 0.0 - 1.0 | **0.9** | Nucleus sampling. 0.9=conservador. 1.0=sin filtro |
| **`top_k`** | 1 - 100 | **40** | Token diversity. Tomar top-40 tokens por probabilidad |
| **`repeat_penalty`** | 0.0 - 2.0 | **1.1** | Penalizar tokens repetidos. Evita loops |
| **`repeat_last_n`** | -1 - 256 | **64** | Cuántos tokens mirar atrás para penalizar repetición |
| **`stop`** | string[] | `["User:", "Assistant:"]` | Tokens que detienen generación. Crucial para multi-turn |

---

### Parameter Deep Dive

#### 🌡️ Temperature (El Más Importante)

```
Temperature Spectrum:
┌─────────────────────────────────────┐
│ 0.0 (Determinista) → 2.0 (Caótico)  │
└─────────────────────────────────────┘

0.0 - 0.3: RAG / Código / Decisiones críticas
    └─> Mismo prompt = MISMA respuesta siempre
    └─> Perfecto para: RAG, generación de code, respuestas basadas en hechos

0.5 - 0.7: Chat casual / Creativo controlado
    └─> Variedad moderada manteniendo coherencia
    └─> Perfecto para: Conversación natural, brainstorming

0.8 - 1.5: Muy creativo / Storytelling
    └─> Mucha variación, a veces sin sentido
    └─> Perfecto para: Ficción, poesía, generación de ideas

1.5 - 2.0: Caos puro (evitar en producción)
    └─> Respuestas impredecibles, frecuentemente sin sentido
```

**Caso SoftArchitect:**
```python
# RAG (USAR temperature=0.0)
def generate_answer_for_rag(user_query: str, documents: List[str]):
    prompt = f"...{documents}...{user_query}"
    response = ollama_client.generate(
        model="softarchitect-rag",
        prompt=prompt,
        temperature=0.0  # ✅ DETERMINISTA
    )

# Chat casual (USAR temperature=0.5)
def generate_chat_response(conversation_history: List[dict]):
    response = ollama_client.generate(
        model="softarchitect-chat",
        messages=conversation_history,
        temperature=0.5  # ✅ VARIADO PERO COHERENTE
    )
```

---

#### 📖 `num_ctx` (Ventana de Contexto)

```
Contexto = "Cuánta historia recuerda el modelo"

┌──────────────────────────────────────────────┐
│ Input (Contexto) → Model → Output (Response) │
└──────────────────────────────────────────────┘

num_ctx=2048:  Cabe 1 documento pequeño (~500 palabras)
num_ctx=4096:  Caben 2-3 documentos (~1500 palabras) ✅ Default SoftArchitect
num_ctx=8192:  Caben 5+ documentos (~3000 palabras)
num_ctx=16384: Caben libro completo (~5000 palabras) ⚠️ Lento
```

**Cálculo para SoftArchitect RAG:**

```
Doc 1: "Clean Architecture" (800 tokens)
Doc 2: "Pydantic V2 Validation" (600 tokens)
Doc 3: "Error Handling Patterns" (700 tokens)
Query: "Cómo estructurar un proyecto FastAPI?" (50 tokens)
─────────────────────────────────────────────
Total: ~2,150 tokens

✅ Recomendación: num_ctx=4096 (sobrante para prompt system)
```

---

#### 🛑 `stop` (Tokens de Parada - CRÍTICO para Multi-Turn)

```python
# ❌ BAD: Sin stop tokens
ollama_client.generate(
    model="llama2",
    prompt="User: ¿Qué es Clean Architecture?\nAssistant:"
)
# Resultado: El modelo genera "User: " de nuevo (loop!)

# ✅ GOOD: Con stop tokens
ollama_client.generate(
    model="llama2",
    prompt="User: ¿Qué es Clean Architecture?\nAssistant:",
    stop=["User:", "\n\nUser:"]  # Detener si ve estos tokens
)
# Resultado: Genera solo la respuesta del asistente
```

---

### Presets por Caso de Uso

#### 🎯 RAG (Respuestas Basadas en Documentos)

```python
rag_config = {
    "temperature": 0.0,      # Determinista
    "num_ctx": 4096,         # Contexto suficiente
    "num_predict": 300,      # Respuestas cortas
    "top_p": 0.9,            # Conservador
    "repeat_penalty": 1.2,   # Evitar repetición
    "stop": ["User:", "Query:"]
}

response = ollama_client.generate(
    model="llama2:13b-chat",
    prompt=system_prompt + context + user_query,
    **rag_config
)
```

#### 💬 Chat Conversacional

```python
chat_config = {
    "temperature": 0.6,      # Ligeramente creativo
    "num_ctx": 2048,         # Historia reducida (más rápido)
    "num_predict": 500,      # Respuestas moderadas
    "top_p": 0.95,           # Más natural
    "repeat_penalty": 1.1,   # Permitir algo de repetición
    "stop": ["User:", "\n\nUser:"]
}

response = ollama_client.generate(
    model="llama2:13b-chat",
    messages=conversation,
    **chat_config
)
```

#### 🔍 Code Generation

```python
code_config = {
    "temperature": 0.1,      # Muy determinista
    "num_ctx": 8192,         # Contexto amplio (necesita definiciones)
    "num_predict": 800,      # Código puede ser largo
    "top_p": 0.8,            # Menos ambigüedad en sintaxis
    "repeat_penalty": 1.3,   # Evitar duplicación de código
    "stop": ["def ", "class ", "\n\n# "]  # Detener entre funciones
}

response = ollama_client.generate(
    model="mistral:7b",
    prompt=system_prompt + code_context + request,
    **code_config
)
```

---

## Modelfile: Crear Modelos Custom

### Concepto: "Dockerfile para Modelos"

Un Modelfile es como un Dockerfile pero para modelos. Te permite:
1. Seleccionar modelo base
2. Configurar parámetros por defecto
3. Inyectar System Prompt (personalidad)
4. Configurar tokens de parada

### ✅ Ejemplo: Modelfile SoftArchitect

```dockerfile
# Modelfile
# Ubicación: packages/knowledge_base/02-TECH-PACKS/AI_ENGINEERING/model-ollama/Modelfile

# 1. Seleccionar base
FROM mistral:7b

# 2. Parámetros por defecto (RAG-optimized)
PARAMETER temperature 0.1
PARAMETER num_ctx 8192
PARAMETER num_predict 500
PARAMETER top_p 0.9
PARAMETER repeat_penalty 1.2
PARAMETER stop "User:"
PARAMETER stop "Query:"
PARAMETER stop "Assistant:"

# 3. System Prompt (Personalidad + Contexto)
SYSTEM """
Nombre: SoftArchitect AI
Rol: Asistente experto en Arquitectura de Software, patrones de diseño y desarrollo fullstack.

Instrucciones:
1. Responde EN ESPAÑOL cuando sea posible, EN INGLÉS si el usuario pregunta en inglés.
2. Sigue ESTRICTAMENTE Clean Architecture: Separation of Concerns, Dependency Inversion.
3. Prefiere soluciones comprobadas (SOLID, Domain-Driven Design) sobre hacks.
4. Si NO TIENES SUFICIENTE CONTEXTO, di: "No tengo información en mi base de conocimientos sobre esto."
5. SIEMPRE cita la fuente (ej: "Según Clean Architecture de Uncle Bob...")
6. NUNCA inventes patrones o frameworks que no existan.
7. Para código, sigue las reglas de SoftArchitect:
   - Type Hints obligatorios (Dart/Python)
   - @freezed/@immutable para modelos
   - Repository Pattern para acceso a datos
   - Testing: 70% unit, 20% integration, 10% e2e

Contexto de la Empresa:
- Stack: Python FastAPI (backend) + Flutter (frontend) + Docker (infra) + Ollama (IA)
- Dogfooding: SoftArchitect se construye a sí mismo usando sus propios patrones
- Datos: PRIVADOS, nunca enviados a servidores externos
- Filosofía: "Local-First, Privacy-First, Type-Safe-First"

Examples de respuestas correctas:
✅ "Para organizar tu código FastAPI, usa Clean Architecture: core/, api/, domain/, infrastructure/"
✅ "En Flutter, el estado debe manejarse con Riverpod AsyncNotifier, NO setState"
✅ "Si no sabes, dilo. No alucines patrones."

Examples de respuestas incorrectas:
❌ "Usa MVC porque es tradicional" (sin justificación)
❌ "Aquí está tu solución mágica:" (sin contexto)
❌ "Inventé un patrón llamado 'XyZPattern'" (no existe)
"""
```

### Crear e Instanciar Modelo Custom

```bash
# 1. Crear el modelo (compilar Modelfile)
ollama create softarchitect-v1 -f Modelfile

# 2. Verificar que existe
ollama list | grep softarchitect

# 3. Testear
ollama run softarchitect-v1

# Interactive prompt:
>>> ¿Qué es Clean Architecture?

# Salir
>>> /bye

# 4. Usar vía API
curl -X POST http://localhost:11434/api/generate \
  -H "Content-Type: application/json" \
  -d '{
    "model": "softarchitect-v1",
    "prompt": "¿Cuáles son los principios de Clean Architecture?",
    "stream": false
  }'
```

### Actualizar Modelo (Nueva Versión)

```bash
# 1. Modificar Modelfile (cambiar parámetros, system prompt, etc.)
nano Modelfile

# 2. Versionar (v1 → v2)
ollama create softarchitect-v2 -f Modelfile

# 3. Verificar ambas existen
ollama list | grep softarchitect

# 4. [Opcional] Eliminar versión anterior si no necesita
ollama rm softarchitect-v1

# 5. En SoftArchitect, cambiar variable de entorno
export LLM_MODEL=softarchitect-v2
```

---

## Prompt Engineering Best Practices

### Estructura de Prompt (3-Capas)

```
┌────────────────────────────────────────────┐
│ Layer 1: SISTEMA (System Prompt)           │ ← En Modelfile
│ "Eres un experto en arquitectura..."       │
├────────────────────────────────────────────┤
│ Layer 2: CONTEXTO (Inyectado)              │ ← Del RAG
│ "Según Clean Architecture: ..."            │
│ "Documentos relevantes: [5 párrafos]"      │
├────────────────────────────────────────────┤
│ Layer 3: QUERY (Usuario)                   │
│ "¿Cómo estructuro un proyecto FastAPI?"   │
└────────────────────────────────────────────┘
```

### ✅ GOOD: Prompt Bien Estructurado (RAG)

```python
def build_rag_prompt(
    user_query: str,
    retrieved_docs: List[str],
    system_context: str = None
) -> str:
    """Construcción segura de prompts para RAG"""

    system = system_context or """
Tu tarea es responder preguntas sobre arquitectura de software basándote SOLO en los documentos proporcionados.

Instrucciones:
1. Lee atentamente los DOCUMENTOS RELEVANTES
2. Extrae información factual (NO inventes)
3. Estructura la respuesta en secciones claras
4. Si NO HAY RESPUESTA en los documentos, di: "No encontré información al respecto en mis documentos"
5. SIEMPRE cita de dónde sacaste la información
"""

    context = f"""
### DOCUMENTOS RELEVANTES:
{chr(10).join([f'---\n{doc}' for doc in retrieved_docs])}

### FIN DE DOCUMENTOS
"""

    query = f"""
### PREGUNTA DEL USUARIO:
{user_query}

Responde de forma concisa (máximo 300 palabras), estructurada y con citas de los documentos.
"""

    return f"{system}\n\n{context}\n\n{query}"
```

### ❌ BAD: Prompt Desorganizado

```python
# ❌ NO HAGAS ESTO
prompt = f"""
{user_query}
{retrieved_docs}
Responde.
"""
# Problemas:
# - Sin separación clara de secciones
# - Sin contexto al modelo de qué hacer
# - Sin límite de longitud
# - Sin instrucción de citar fuentes
```

---

### Few-Shot Prompting (Examples)

```python
def build_few_shot_prompt(user_query: str) -> str:
    """Mostrar ejemplos de respuestas correctas al modelo"""

    examples = """
### EJEMPLOS DE RESPUESTAS CORRECTAS:

Pregunta: ¿Qué es el principio de Inversión de Dependencias?
Respuesta: El Principio de Inversión de Dependencias (DIP) establece que:
1. Las clases de alto nivel NO deben depender de clases de bajo nivel
2. Ambas deben depender de abstracciones
3. En SoftArchitect, usamos Repositorio Pattern e inyección de dependencias (FastAPI Depends)
[Fuente: SOLID Principles - Uncle Bob]

Pregunta: ¿Cómo estructuro un proyecto FastAPI?
Respuesta: Usa Clean Architecture con esta estructura:
src/
├── main.py
├── core/ (config, logger, exceptions)
├── api/ (routers HTTP)
├── domain/ (modelos, use cases, excepciones)
├── infrastructure/ (repos, DB, APIs externas)
[Fuente: SoftArchitect STRUCTURE_EXAMPLE.tree]
"""

    return f"""{examples}

### NUEVA PREGUNTA:
{user_query}

Responde siguiendo el mismo formato (conciso, estructurado, con fuente):
"""
```

---

## Debugging & Validation

### 🔍 Cómo Validar Que Ollama Está Funcionando

```bash
# 1. Verificar servicio corriendo
curl http://localhost:11434/api/tags
# Respuesta: {"models": [{"name": "llama2:7b", ...}]}

# 2. Test rápido (2-3 segundos)
ollama run llama2 "Di hola"

# 3. Monitorear logs
docker logs -f ollama  # Si corre en Docker

# 4. Check de recursos
nvidia-smi  # GPU usage (si tienes NVIDIA GPU)
free -h     # RAM usage

# 5. Benchmark de velocidad
time curl http://localhost:11434/api/generate -d '{
  "model": "llama2",
  "prompt": "Explica Clean Architecture en 100 palabras",
  "stream": false
}'
```

### ⚠️ Problemas Comunes

| Problema | Síntoma | Solución |
|:---|:---|:---|
| **Ollama no responde** | `curl: (7) Failed to connect` | Verificar: `docker ps`, puerto 11434 abierto |
| **Modelo no existe** | `"model 'llama2' not found"` | `ollama pull llama2:7b` |
| **VRAM insuficiente** | Respuestas muy lentas o crash | Reducir `num_ctx`, usar modelo 7b en lugar de 13b |
| **Respuestas sin sentido** | Output incoherente | Bajar `temperature`, aumentar `repeat_penalty` |
| **Loop infinito** | Modelo repite mismo texto | Añadir `stop` tokens adecuados |

---

## Pre-Production Checklist

Antes de deployer Modelfile a producción:

```bash
# ✅ 1. Validar Modelfile sintaxis
ollama create test-model -f Modelfile && echo "✅ Sintaxis OK"

# ✅ 2. Probar con queries RAG reales (3+ documentos)
curl -X POST http://localhost:11434/api/generate \
  -d '{"model":"test-model","prompt":"<your_rag_prompt>"}'

# ✅ 3. Verificar determinismo (misma respuesta x2)
ollama run test-model "¿Qué es Clean Architecture?" > resp1.txt
ollama run test-model "¿Qué es Clean Architecture?" > resp2.txt
diff resp1.txt resp2.txt && echo "✅ Determinista"

# ✅ 4. Verificar stop tokens (no se corta mal)
# Generar prompt con multi-turn
ollama run test-model "User: Hola\nAssistant: Hola\nUser: ¿Quién eres?"

# ✅ 5. Performance benchmark (latencia <1s para 300 tokens)
time ollama run test-model "Explica en 300 palabras..."

# ✅ 6. Test de caché (segunda llamada es más rápida)
ollama run test-model "Hola"  # Frío
time ollama run test-model "¿Qué es Clean Architecture?"  # Caliente

# ✅ 7. Liberar resources
ollama rm test-model

# ✅ 8. Documentar parámetros en comentario
# PARÁMETROS FINALES (v1):
# - temperature: 0.0 (RAG-determinista)
# - num_ctx: 4096
# - temperature: 0.0
# - Tested: Ene 30, 2025 ✅
```

---

## Conclusion

**Los parámetros de Ollama no son "mágicos"—son científicos:**

1. ✅ **Temperature=0.0** → RAG = respuestas reproducibles
2. ✅ **num_ctx=4096** → Capacidad para 3-5 documentos técnicos
3. ✅ **stop tokens** → Multi-turn coherente
4. ✅ **System Prompt** → Personalidad + contexto

**Dogfooding Validation:** Estos parámetros se prueban cada vez que SoftArchitect genera una respuesta a un usuario.
