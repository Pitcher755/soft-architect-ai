# 📏 Tech Governance Rules: Semantic Kernel

> **Date:** 30 de Enero de 2026
> **Status:** ✅ MANDATORY RULES
> **Scope:** Todo código Python que use Semantic Kernel en SoftArchitect

Reglas estrictas para el desarrollo de Plugins y Kernels.

---

## 📖 Table of Contents

1. [La Regla de Oro: Kernel Stateless](#la-regla-de-oro-kernel-stateless)
2. [Organización de Plugins](#organización-de-plugins)
3. [Semantic vs Native Functions](#semantic-vs-native-functions)
4. [Seguridad en Planners](#seguridad-en-planners)
5. [Naming Conventions](#naming-conventions)
6. [Anti-Patterns](#anti-patterns)

---

## La Regla de Oro: Kernel Stateless

### Regla 1: Kernel por Request

**Mandatory:** El Kernel debe ser **stateless** en contexto web. No guardar estado mutable en la instancia.

```python
# ❌ BAD: Kernel como singleton global con estado mutable
kernel_singleton = Kernel()

def process_request(input_data):
    kernel_singleton.add_plugin(...)  # ← Modifica el kernel global
    result = await kernel_singleton.invoke(...)
```

**DEBE SER:**

```python
# ✅ GOOD: Kernel por request scope
async def process_request(input_data):
    kernel = Kernel()  # Nueva instancia
    kernel.add_memory(...)  # Memoria aislada
    kernel.add_service(...)  # Servicios claros
    result = await kernel.invoke_plugin_function(...)
    # Al final: kernel se destruye, memory se vacía
```

### Rationale

1. **Aislamiento:** Cada request tiene su propia memoria (seguridad multi-tenant)
2. **Testabilidad:** Crear kernel fresh en cada test
3. **Escalabilidad:** Serverless necesita stateless

---

## Organización de Plugins

### Regla 2: Plugin = Carpeta, No Archivo

**Mandatory:** Un plugin es una **carpeta** con funciones relacionadas.

```
plugins/
├── WriterPlugin/                 # Plugin: Escritura
│   ├── __init__.py
│   ├── Summarize/
│   │   ├── skprompt.txt         # Prompt semántico
│   │   └── config.json          # Config (temp, tokens)
│   ├── Translate/
│   │   ├── skprompt.txt
│   │   └── config.json
│   └── native_functions.py      # Funciones nativas si hay
│
├── MathPlugin/                   # Plugin: Matemáticas
│   ├── __init__.py
│   └── math_functions.py        # Todas las funciones nativas aquí
│
└── DatabasePlugin/              # Plugin: Acceso a datos
    ├── __init__.py
    ├── query_handler.py         # Funciones nativas
    └── Search/                  # Si tiene semantic functions
        ├── skprompt.txt
        └── config.json
```

### Regla 3: Un Plugin por Dominio

**Prohibido:** Mezclar dominios en un plugin.

```python
# ❌ BAD: Dominio mezclado
class UtilsPlugin:
    @kernel_function
    def summarize_text(self, text):  # ← Escritura
        pass

    @kernel_function
    def query_database(self, sql):   # ← Base de datos
        pass
```

**DEBE SER:**

```python
# ✅ GOOD: Plugins separados
class WriterPlugin:
    @kernel_function
    def summarize_text(self, text):
        pass

class DatabasePlugin:
    @kernel_function
    def query_database(self, sql):
        pass
```

---

## Semantic vs Native Functions

### Regla 4: Usar Semantic para LLM Tasks, Native para Determinística

**Semantic Functions:**
- Input: Texto ambiguo, creative
- Output: Texto generado por LLM
- Examples: Summarize, Translate, GenerateIdeas

**Native Functions:**
- Input: Datos estructurados
- Output: Determinístico (siempre igual input = mismo output)
- Examples: CalculateSum, FetchFromDB, ValidateEmail

```python
# ✅ GOOD: Semantic
# plugins/WriterPlugin/Summarize/skprompt.txt
Summarize el siguiente texto en máximo 2 frases.
Texto: {{$input}}

# ✅ GOOD: Native
class MathPlugin:
    @kernel_function(
        description="Suma dos números",
        name="Add"
    )
    def add(self, num1: float, num2: float) -> float:
        return num1 + num2
```

### Regla 5: Descriptores Claros

**Mandatory:** Cada función debe tener descripción clara. El Planner las lee.

```python
# ❌ BAD: Sin descripción
@kernel_function
def process(data):
    pass

# ✅ GOOD: Descripción detallada
@kernel_function(
    description="Procesa un archivo CSV y devuelve estadísticas (media, mediana, desv. estándar)",
    name="AnalyzeCSV"
)
def process(csv_content: str) -> dict:
    pass
```

---

## Seguridad en Planners

### Regla 6: Sandbox Strict para Planner

**Mandatory:** Nunca exponer funciones de escritura (POST/DELETE) directamente al Planner sin validación.

```python
# ❌ BAD: Planner tiene acceso a funciones peligrosas
kernel.add_plugin(DatabasePlugin(), "Database")  # Write, Delete functions

goal = "Elimina todos los usuarios que no hayan logineado en 30 días"
plan = await planner.create_plan(goal)
await plan.invoke(kernel)  # ← Peligroso: LLM puede ejecutar DELETE sin validar
```

**DEBE SER:**

```python
# ✅ GOOD: Sandboxing estratégico

class DatabaseReadPlugin:
    @kernel_function
    def query_inactive_users(self, days: int) -> List[str]:
        """Retorna IDs de usuarios inactivos (SOLO LECTURA)"""
        pass

class AuditPlugin:
    @kernel_function
    def log_deletion_request(self, user_ids: List[str]) -> str:
        """Registra un pedido de eliminación para revisión humana"""
        pass

# Kernel para planner tiene solo funciones read-only + logging
kernel.add_plugin(DatabaseReadPlugin(), "Database")
kernel.add_plugin(AuditPlugin(), "Audit")

goal = "Identifica usuarios inactivos y registra un pedido de eliminación"
plan = await planner.create_plan(goal)
await plan.invoke(kernel)  # ← Seguro: solo lectura + logging

# Revisión humana antes de ejecutar DELETE
```

### Regla 7: Timeout en Planners

**Mandatory:** Limitar iteraciones del planner.

```python
planner = HandlebarsPlanner(kernel)
plan = await planner.create_plan(
    goal="...",
    max_iterations=5  # ← No loops infinitos
)
```

---

## Naming Conventions

### Regla 8: Naming Consistente

| Elemento | Convención | Ejemplo |
|:---|:---|:---|
| **Plugin** | PascalCase + Suffix "Plugin" | `WriterPlugin`, `DatabasePlugin` |
| **Function** | Verbo + Objeto (PascalCase) | `SummarizeText`, `FetchUserById` |
| **Semantic Dir** | PascalCase (verbo) | `Summarize/`, `Translate/`, `GeneratePoem/` |
| **Native Function** | `@kernel_function` + name= | `@kernel_function(name="SummarizeText")` |
| **Kernel Variable** | `kernel` (lowercase) | `kernel = Kernel()` |
| **Planner Variable** | `planner` (lowercase) | `planner = HandlebarsPlanner(kernel)` |

```python
# ✅ GOOD
class WriterPlugin:
    @kernel_function(
        description="...",
        name="SummarizeText"  # PascalCase
    )
    def summarize_text(self, text: str) -> str:  # Python snake_case OK
        pass

kernel.add_plugin(WriterPlugin(), "Writer")
await kernel.invoke_plugin_function("Writer", "SummarizeText", {"text": "..."})
```

---

## Anti-Patterns

### ❌ PROHIBIDO 1: Stateful Kernel

```python
# ❌ BAD
class ChatService:
    def __init__(self):
        self.kernel = Kernel()  # Kernel como atributo de instancia
        self.memory = self.kernel.memory  # Estado compartido

    async def process(self, msg):
        self.memory.add("user_state", msg)  # ← Contaminación entre requests
```

### ❌ PROHIBIDO 2: Plugins Gigantes

```python
# ❌ BAD: Un plugin hace todo
class BigPlugin:
    @kernel_function
    def do_everything(self, input):
        # 500 líneas de lógica
        pass
```

**DEBE SER:** Plugins pequeños (una responsabilidad clara).

### ❌ PROHIBIDO 3: Semantic Functions Hardcoded

```python
# ❌ BAD: Prompts en .py
class WriterPlugin:
    async def summarize(self, text):
        prompt = f"Summarize: {text}"  # ← Hardcoded
        return await self.kernel.invoke_plugin_function(...)
```

**DEBE SER:** Prompts en archivos `.skprompt.txt`.

### ❌ PROHIBIDO 4: Ignorar Planner Limits

```python
# ❌ BAD: Planner sin timeout
plan = await planner.create_plan(goal)  # ← Puede iterar infinitamente
```

---

## Checklist Pre-Deploy

```bash
# ✅ 1. Kernel Design
[ ] Kernel es stateless
[ ] Memoria es aislada por request
[ ] Servicios registrados claramente

# ✅ 2. Plugins
[ ] Cada plugin tiene carpeta propia
[ ] Un dominio por plugin
[ ] Funciones tienen descripción clara

# ✅ 3. Functions
[ ] Semantic: prompts en .skprompt.txt
[ ] Native: @kernel_function con name= y description
[ ] Type hints completos

# ✅ 4. Planner
[ ] Sandbox: solo funciones seguras
[ ] Max iterations configurado
[ ] Timeout en place

# ✅ 5. Testing
[ ] Kernel instanciado en cada test
[ ] Plugins mockeable
[ ] Planner limitado en tests

# ✅ 6. Security
[ ] Sin write functions en planner público
[ ] Audit log para cambios
[ ] Validación de inputs en native functions
```

---

**Validación:** RAG rechazará PRs que violen estas reglas.

**Date:** 30 de Enero de 2026
**Status:** ✅ ENFORCED
**Responsable:** ArchitectZero AI Agent
