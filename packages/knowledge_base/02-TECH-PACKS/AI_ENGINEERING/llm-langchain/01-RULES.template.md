# 📏 Tech Governance Rules: LangChain

> **Fecha:** 30 de Enero de 2026
> **Estado:** ✅ MANDATORY RULES
> **Alcance:** Todo código Python que use LangChain en SoftArchitect

Reglas estrictas e inapelables para el desarrollo de IA con LangChain.

---

## 📖 Tabla de Contenidos

1. [La Regla de Oro: LCEL Mandatorio](#la-regla-de-oro-lcel-mandatorio)
2. [Gestión de Prompts](#gestión-de-prompts)
3. [Salidas Estructuradas](#salidas-estructuradas)
4. [Convenciones de Naming](#convenciones-de-naming)
5. [Validación Automática](#validación-automática)
6. [Anti-Patterns](#anti-patterns)

---

## La Regla de Oro: LCEL Mandatorio

### Regla 1: The Pipe Rule (`|`)

**Obligatorio:** TODO nuevo desarrollo debe usar **LCEL (LangChain Expression Language)** con el operador pipe.

**Sintaxis Permitida:**
```python
# ✅ GOOD: LCEL Pipe
chain = prompt | model | parser
result = chain.invoke({"input": value})
async for chunk in chain.astream({"input": value}):
    print(chunk)
```

**Sintaxis Prohibida:**
```python
# ❌ BAD: Legacy LLMChain (Deprecated)
chain = LLMChain(llm=model, prompt=prompt)

# ❌ BAD: SimpleSequentialChain
chain = SimpleSequentialChain(chains=[chain1, chain2])

# ❌ BAD: ConversationChain (Deprecated)
chain = ConversationChain(llm=model, memory=memory)
```

### Rationale

1. **LCEL es más legible:** `a | b | c` vs `LLMChain(llm=b, prompt=a)`
2. **LCEL es más performante:** Streaming automático, sin overhead
3. **LCEL tiene mejor type safety:** Type hints correctos en el resultado
4. **LCEL está en mantenimiento activo:** Las clases legacy están deprecadas desde v0.0.220

### Validación en CI/CD

```bash
# Pre-commit hook busca estos strings prohibidos:
grep -r "LLMChain\|SimpleSequentialChain\|ConversationChain" src/
# Si encuentra algo → REJECT commit
```

---

## Gestión de Prompts

### Regla 2: Templates Separados de Código

**Prohibido:** Hardcodear strings gigantes en el código Python.

```python
# ❌ BAD
prompt_string = """
You are an expert in {domain}.
Answer the question: {question}
Provide a detailed response...
"""  # ← ¡40 líneas más de templates!

model = ChatOllama(model="llama3")
chain = prompt_string | model  # Type error: str no es compatible
```

**Obligatorio:** Usar `ChatPromptTemplate` o `SystemMessagePromptTemplate`.

```python
# ✅ GOOD: Templates estructurados
from langchain_core.prompts import ChatPromptTemplate, SystemMessagePromptTemplate

system_template = """You are an expert in {domain}.
Provide detailed, accurate responses."""

user_template = "Answer this question: {question}"

prompt = ChatPromptTemplate.from_messages([
    SystemMessagePromptTemplate.from_template(system_template),
    ("user", user_template)
])

# Ahora es type-safe
chain = prompt | model | parser
```

### Dónde Residem los Prompts

Ubicación obligatoria:
```
src/
├── core/
│   └── prompts/
│       ├── rag_prompts.py         # Prompts para RAG
│       ├── agent_prompts.py       # Prompts para Agentes
│       └── summarization_prompts.py
```

Nunca en:
- ❌ Directamente en funciones
- ❌ En variables de entorno (salvo API keys)
- ❌ En constantes sin documentación

### Ejemplo de Estructura

```python
# src/core/prompts/rag_prompts.py

from langchain_core.prompts import ChatPromptTemplate

RAG_SYSTEM_PROMPT = """You are a helpful assistant answering questions based on provided context.
Use ONLY the context provided. If the answer is not in the context, say "No information available."
"""

CONTEXT_TEMPLATE = """Context documents:
{context}"""

QUESTION_TEMPLATE = "Question: {question}"

rag_prompt = ChatPromptTemplate.from_messages([
    ("system", RAG_SYSTEM_PROMPT),
    ("user", CONTEXT_TEMPLATE + "\n\n" + QUESTION_TEMPLATE)
])
```

---

## Salidas Estructuradas

### Regla 3: Validación Pydantic Obligatoria

**Prohibido:** Confiar en que el LLM devuelva JSON válido por suerte.

```python
# ❌ BAD: JSON sin validación
response = model.invoke(prompt)
json_str = response.content
parsed = json.loads(json_str)  # ¿Qué si no es válido JSON?
```

**Obligatorio:** Usar `PydanticOutputParser` o `.with_structured_output()`.

```python
# ✅ GOOD: Schema validado con Pydantic
from langchain_core.pydantic_v1 import BaseModel, Field
from langchain_core.output_parsers import PydanticOutputParser

class InvoiceData(BaseModel):
    """Estructura de una factura extraída."""
    invoice_number: str = Field(description="Número de factura único")
    total_amount: float = Field(description="Monto total en USD")
    due_date: str = Field(description="Fecha de vencimiento (YYYY-MM-DD)")
    vendor_name: str = Field(description="Nombre del proveedor")

parser = PydanticOutputParser(pydantic_object=InvoiceData)

prompt = ChatPromptTemplate.from_template("""
Extract invoice data from this text:
{text}

{format_instructions}
""")

chain = prompt | model | parser

# Resultado es una instancia de InvoiceData, NO un string
invoice: InvoiceData = chain.invoke({
    "text": invoice_text,
    "format_instructions": parser.get_format_instructions()
})

print(invoice.total_amount)  # Type-safe ✅
```

### Alternativa: Function Calling (Si modelo lo soporta)

```python
# ✅ GOOD: Usar .with_structured_output() para GPT-4/Claude
class SearchQuery(BaseModel):
    query: str
    filters: dict

structured_llm = model.with_structured_output(SearchQuery)
chain = prompt | structured_llm

result: SearchQuery = chain.invoke({...})
```

---

## Convenciones de Naming

### Regla 4: Naming Consistente

| Concepto | Convención | Ejemplo |
|:---|:---|:---|
| **Cadenas LCEL** | Suffix `_chain` | `rag_chain`, `summarization_chain`, `agent_chain` |
| **Runnables Genéricos** | Suffix `_runnable` | `parallel_runnable`, `conditional_runnable` |
| **Herramientas (Tools)** | Verbo + Objeto | `search_documents`, `calculate_tax`, `get_user_profile` |
| **Prompts** | Suffix `_prompt` | `system_prompt`, `retrieval_prompt` |
| **Parsers** | Suffix `_parser` | `json_parser`, `invoice_parser` |
| **Retrievers** | Suffix `_retriever` | `semantic_retriever`, `hybrid_retriever` |

```python
# ✅ GOOD: Naming correcto
from langchain.tools import tool

# Chains
rag_chain = retriever | prompt | model | parser

# Runnables
parallel_runnable = RunnableParallel({
    "docs": retriever,
    "question": RunnablePassthrough()
})

# Tools
@tool
def search_documents(query: str) -> str:
    """Search knowledge base by query."""
    return retriever.invoke(query)

# Prompts
system_prompt = ChatPromptTemplate.from_template("You are helpful...")

# Parsers
json_parser = PydanticOutputParser(pydantic_object=MySchema)
```

---

## Validación Automática

### Regla 5: Pre-commit Hooks

Archivo: `.pre-commit-config.yaml`

```yaml
- repo: local
  hooks:
    - id: langchain-lcel-check
      name: LangChain LCEL Validation
      entry: python -m scripts.validate_langchain
      language: system
      types: [python]
      stages: [commit]
```

Validaciones:
1. ❌ Rechazar `LLMChain`, `SimpleSequentialChain`, `ConversationChain`
2. ❌ Rechazar `hardcoded` prompts largos en `.py` (>50 caracteres sin `ChatPromptTemplate`)
3. ❌ Rechazar `json.loads()` sin try/except o validación Pydantic
4. ✅ Aceptar `|` (pipe) en cadenas
5. ✅ Aceptar `.with_structured_output()` o `PydanticOutputParser`

---

## Anti-Patterns

### ❌ PROHIBIDO 1: Mezclar Legacy + LCEL

```python
# ❌ BAD: No mezcles paradigmas
from langchain.chains import LLMChain
from langchain_core.output_parsers import StrOutputParser

# Una usando legacy:
old_chain = LLMChain(llm=model, prompt=prompt)

# Otra usando LCEL:
new_chain = prompt | model | StrOutputParser()

# Ahora tienes inconsistencia de tipos/comportamiento
```

### ❌ PROHIBIDO 2: Ignorar Errores de Parsing

```python
# ❌ BAD: No capturar excepciones
invoice_data = parser.invoke(llm_output)

# Cuando la salida es inválida → crash sin contexto
```

**DEBE SER:**
```python
# ✅ GOOD: Validación con fallback
try:
    invoice_data = parser.invoke(llm_output)
except OutputParserException as e:
    logger.error(f"Parse error: {e}. Raw output: {llm_output}")
    invoice_data = InvoiceData.construct(
        invoice_number="UNKNOWN",
        total_amount=0.0,
        due_date="1970-01-01",
        vendor_name="UNKNOWN"
    )
```

### ❌ PROHIBIDO 3: Blocking Calls en Async Context

```python
# ❌ BAD: Mezclar sync/async
async def process_documents(docs):
    result = chain.invoke({"docs": docs})  # ← Blocking!
```

**DEBE SER:**
```python
# ✅ GOOD: Usar async
async def process_documents(docs):
    result = await chain.ainvoke({"docs": docs})
```

### ❌ PROHIBIDO 4: No Loguear Prompts Enviados

```python
# ❌ BAD: Debugging imposible
chain = prompt | model | parser
result = chain.invoke({"input": data})

# ¿Qué prompt exacto se envió al LLM?
```

**DEBE SER:**
```python
# ✅ GOOD: Loguear para debugging
import logging

logger = logging.getLogger(__name__)

formatted_prompt = prompt.format_messages(**{"input": data})
logger.debug(f"Sending prompt: {formatted_prompt}")

result = chain.invoke({"input": data})
logger.info(f"Chain result: {result}")
```

---

## Checklist Pre-Deploy

```bash
# ✅ 1. LCEL Validation
[ ] Todas las cadenas usan pipe |
[ ] NO hay LLMChain, SimpleSequentialChain, ConversationChain
[ ] Prompts están en src/core/prompts/

# ✅ 2. Estructuras
[ ] Outputs validados con Pydantic
[ ] Todos los Fields tienen description
[ ] Parsing errors tienen fallback

# ✅ 3. Naming
[ ] Cadenas tienen suffix _chain
[ ] Tools tienen verbo + objeto
[ ] Prompts tienen suffix _prompt

# ✅ 4. Testing
[ ] Unit tests para cada chain
[ ] Mock LLM responses
[ ] Edge cases (empty input, timeout, error)

# ✅ 5. Observabilidad
[ ] Prompts loguean en DEBUG
[ ] Results loguean en INFO
[ ] Errores loguean con contexto
[ ] LangSmith integrado (si prod)
```

---

**Validación:** RAG rechazará PRs que violen estas reglas.

**Fecha:** 30 de Enero de 2026
**Status:** ✅ ENFORCED
**Responsable:** ArchitectZero AI Agent
