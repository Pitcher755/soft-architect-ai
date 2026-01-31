# 🧩 Semantic Kernel Plugins Guide

> **Paradigma:** Plugin-based Orchestration
> **Concepto:** Semantic Functions (Prompts) + Native Functions (Code)
> **Versión:** SK 1.0.0+

Un **Plugin** es un grupo de funciones (semánticas y/o nativas) que resuelven un dominio específico.

---

## 📖 Tabla de Contenidos

1. [Semantic Functions (Prompts como Código)](#semantic-functions-prompts-como-código)
2. [Native Functions (Código Real)](#native-functions-código-real)
3. [Invocación y Composición](#invocación-y-composición)
4. [El Planner (Auto-Orquestación)](#el-planner-auto-orquestación)
5. [Anti-Patterns](#anti-patterns)

---

## Semantic Functions (Prompts como Código)

Las funciones semánticas son **prompts templados** almacenados en archivos `.skprompt.txt`.

### Estructura de Archivos

```
plugins/WriterPlugin/Summarize/
├── skprompt.txt       # El prompt (plantilla)
└── config.json        # Configuración (temp, tokens, etc)

```

### Archivo: `skprompt.txt`

El prompt es un template con variables.

**Sintaxis:** `{{$variable}}`

```text
Resume el siguiente texto en máximo 2 frases.
Mantén los puntos clave y elimina detalles innecesarios.

Texto a resumir:
{{$input}}

Resumen:
```

### Archivo: `config.json`

Configuración del modelo para esta función.

```json
{
  "schema": 1,
  "description": "Resume un texto en 2 frases máximo",
  "execution_settings": {
    "default": {
      "model": "gpt-4",
      "max_tokens": 150,
      "temperature": 0.5,
      "top_p": 0.9
    }
  }
}

```

### Invocación en Código

```python
from semantic_kernel import Kernel

kernel = Kernel()
kernel.import_semantic_skill_from_directory("plugins", "WriterPlugin")

result = await kernel.invoke_plugin_function(
    "WriterPlugin",
    "Summarize",
    {"input": "Lorem ipsum dolor sit amet, consectetur adipiscing elit..."}
)

print(result)  # "Lorem ipsum dolor. Consectetur adipiscing elit."
```

### Parámetros en Prompts

Los prompts pueden tener múltiples variables.

**`skprompt.txt`:**

```text
Traduce el siguiente texto del idioma {{$source_lang}} al {{$target_lang}}.

Texto original:
{{$text}}

Traducción:
```

**Invocación:**

```python
result = await kernel.invoke_plugin_function(
    "WriterPlugin",
    "Translate",
    {
        "source_lang": "English",
        "target_lang": "Spanish",
        "text": "Hello, how are you?"
    }
)

# Output: "Hola, ¿cómo estás?"
```

---

## Native Functions (Código Real)

Las funciones nativas son funciones Python deterministas decoradas con `@kernel_function`.

### Estructura

```python
from semantic_kernel.functions import kernel_function

class MathPlugin:
    @kernel_function(
        description="Suma dos números",
        name="Add"
    )
    def add(self, number1: float, number2: float) -> float:
        """Suma number1 + number2."""
        return number1 + number2

    @kernel_function(
        description="Multiplica dos números",
        name="Multiply"
    )
    def multiply(self, number1: float, number2: float) -> float:
        return number1 * number2
```

### Registro en Kernel

```python
kernel = Kernel()
kernel.add_plugin(MathPlugin(), plugin_name="Math")

result = await kernel.invoke_plugin_function(
    "Math",
    "Add",
    {"number1": 5, "number2": 3}
)

print(result)  # 8.0
```

### Tipos de Retorno

Las funciones nativas pueden retornar:

- **Escalares:** `float`, `int`, `str`, `bool`
- **Estructurados:** `dict`, `list`
- **Complejos:** `Pydantic` models
- **Async:** `async def` → retorna `Awaitable[T]`

**Ejemplo:**

```python
from pydantic import BaseModel

class SummaryResult(BaseModel):
    title: str
    points: List[str]
    confidence: float

class AnalysisPlugin:
    @kernel_function(description="Analiza un texto")
    async def analyze_text(self, text: str) -> SummaryResult:
        """Retorna un objeto Pydantic."""
        # Lógica de análisis
        return SummaryResult(
            title="Análisis",
            points=["Punto 1", "Punto 2"],
            confidence=0.95
        )

kernel.add_plugin(AnalysisPlugin())
result = await kernel.invoke_plugin_function("AnalysisPlugin", "analyze_text", {"text": "..."})
print(result.title)  # Type-safe ✅
```

### Descripción Importante

La descripción es lo que el **Planner lee** para decidir si usar esta función.

```python
# ❌ BAD: Descripción vaga
@kernel_function(description="Procesa data")
def process(data):
    pass

# ✅ GOOD: Descripción clara y específica
@kernel_function(
    description="Procesa un archivo CSV y devuelve estadísticas (media, mediana, desviación estándar). "
                "Espera columnas numéricas."
)
async def process_csv(csv_path: str) -> dict:
    pass
```

---

## Invocación y Composición

### Invocación Simple

```python
# Semántico
result = await kernel.invoke_plugin_function(
    "WriterPlugin",
    "Summarize",
    {"input": "..."}
)

# Nativo
result = await kernel.invoke_plugin_function(
    "Math",
    "Add",
    {"number1": 5, "number2": 3}
)
```

### Composición Manual

Una función invoca otra.

```python
class OrchestratorPlugin:
    def __init__(self, kernel):
        self.kernel = kernel

    @kernel_function(
        description="Ejecuta un análisis completo: summarize + analyze"
    )
    async def analyze_document(self, content: str) -> dict:
        # Paso 1: Resumir
        summary = await self.kernel.invoke_plugin_function(
            "WriterPlugin",
            "Summarize",
            {"input": content}
        )

        # Paso 2: Analizar
        analysis = await self.kernel.invoke_plugin_function(
            "AnalysisPlugin",
            "Analyze",
            {"text": summary}
        )

        return {
            "summary": summary,
            "analysis": analysis
        }
```

---

## El Planner (Auto-Orquestación)

El **Planner** es donde la magia sucede. Lee las descripciones de tus funciones y decide automáticamente cuáles usar.

### HandlebarsPlanner (Recomendado)

```python
from semantic_kernel.planners import HandlebarsPlanner

# Setup plugins
kernel = Kernel()
kernel.add_plugin(WriterPlugin(), "Writer")
kernel.add_plugin(MathPlugin(), "Math")
kernel.add_plugin(DatabasePlugin(), "Database")

# Crear planner
planner = HandlebarsPlanner(kernel)

# Goal: Descripción de lo que quieres lograr
goal = "Obtén los datos de ventas del Q4 2024, resume los resultados y calcula el promedio"

# Crear plan
plan = await planner.create_plan(
    goal=goal,
    max_iterations=5  # ← Limite de iteraciones
)

# Ejecutar plan
result = await plan.invoke(kernel)
print(result)
```

### Ciclo Mental del Planner

```
Goal: "Obtén datos de ventas, resume y calcula promedio"

Thought: Necesito los datos de ventas primero.
Función Disponible: Database.FetchSalesData
→ Ejecuto FetchSalesData(period="Q4_2024")

Observation: Datos obtenidos: [100, 200, 150, 300, ...]

Thought: Ahora resumo los datos.
Función Disponible: Writer.Summarize
→ Ejecuto Summarize(input=datos)

Observation: Resumen: "Q4 mostró variabilidad con picos..."

Thought: Ahora calculo el promedio.
Función Disponible: Math.CalculateAverage
→ Ejecuto CalculateAverage(numbers=[100, 200, 150, ...])

Observation: Promedio = 187.5

Thought: Tengo toda la información. Puedo responder.
Final Answer: Los datos de Q4 mostraron un promedio de 187.5 con variabilidad...
```

### Seguridad en Planners

⚠️ **Nunca** expongas funciones de escritura (DELETE, UPDATE) al Planner sin supervisión.

```python
# ❌ PELIGROSO
kernel.add_plugin(DatabasePlugin(), "Database")  # Incluye DELETE!

goal = "Elimina usuarios inactivos"
plan = await planner.create_plan(goal)
await plan.invoke(kernel)  # ← LLM puede ejecutar DELETE sin revisar
```

**Solución:**

```python
# ✅ SEGURO: Separar plugins por permisos

class DatabaseReadPlugin:
    @kernel_function(description="Obtiene usuarios inactivos (SOLO LECTURA)")
    async def get_inactive_users(self):
        pass

class AuditPlugin:
    @kernel_function(description="Registra un pedido de eliminación")
    async def log_deletion(self, user_ids: List[str]):
        # Log a database/queue para revisión humana
        pass

# Planner solo ve lectura + logging
kernel.add_plugin(DatabaseReadPlugin())
kernel.add_plugin(AuditPlugin())

goal = "Identifica usuarios inactivos y registra un pedido de eliminación"
plan = await planner.create_plan(goal)
await plan.invoke(kernel)  # ← Seguro
```

---

## Anti-Patterns

### ❌ ANTI-PATTERN 1: Prompts Hardcoded

```python
# ❌ BAD: Prompt en el código
class WriterPlugin:
    async def summarize(self, text: str):
        prompt = f"""Summarize this:
{text}"""
        result = await self.kernel.invoke(prompt)
        return result
```

**DEBE SER:** Prompts en archivos `.skprompt.txt`.

### ❌ ANTI-PATTERN 2: Native Function Sin Descripción

```python
# ❌ BAD: Planner no sabe qué hace
@kernel_function
def process(data):
    pass

# ✅ GOOD: Descripción clara
@kernel_function(
    description="Procesa datos CSV y retorna estadísticas (media, mediana)",
    name="ProcessCSV"
)
def process_csv(data: str) -> dict:
    pass
```

### ❌ ANTI-PATTERN 3: Planner sin Límites

```python
# ❌ BAD: Puede loop infinitamente
plan = await planner.create_plan(goal)  # Sin max_iterations

# ✅ GOOD: Límite configurado
plan = await planner.create_plan(goal, max_iterations=5)
```

### ❌ ANTI-PATTERN 4: Plugin Gigante

```python
# ❌ BAD: Un plugin hace todo
class MegaPlugin:
    @kernel_function
    def summarize(self):  # ← Escritura
        pass

    @kernel_function
    def query_db(self):   # ← Base de datos
        pass

    @kernel_function
    def calculate(self):  # ← Matemáticas
        pass
```

**DEBE SER:** Plugins separados (MegaPlugin → WriterPlugin, DatabasePlugin, MathPlugin).

---

## Checklist: Plugin Bien Formado

```bash
# ✅ 1. Semantic Functions
[ ] Prompts en plugins/*/FunctionName/skprompt.txt
[ ] config.json con parámetros claros
[ ] Variables usando {{$variable}} syntax

# ✅ 2. Native Functions
[ ] @kernel_function con name= y description=
[ ] Type hints en parámetros y retorno
[ ] Descripción clara para el Planner

# ✅ 3. Registro
[ ] kernel.add_plugin() registra el plugin
[ ] Nombre del plugin en PascalCase
[ ] Nombre de función en PascalCase

# ✅ 4. Planner
[ ] Planner tiene max_iterations
[ ] Solo funciones seguras en Planner público
[ ] Audit log para acciones críticas

# ✅ 5. Testing
[ ] Mock kernel en tests
[ ] Plugins testeable de forma aislada
[ ] Planner limitado en tests (max_iterations=1)
```

---

**Fecha:** 30 de Enero de 2026
**Status:** ✅ PRODUCTION-READY PATTERNS
**Responsable:** ArchitectZero AI Agent
