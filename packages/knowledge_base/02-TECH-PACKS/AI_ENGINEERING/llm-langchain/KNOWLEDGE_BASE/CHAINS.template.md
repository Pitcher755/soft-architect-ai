# 🦜 LCEL Patterns: LangChain Expression Language

> **Paradigma:** Declarativo, Componible, Streamable
> **Sintaxis:** `Input | Prompt | Model | OutputParser`
> **Version:** LangChain 0.1.0+ (LCEL Stable)

La unidad fundamental de trabajo en LangChain moderno.

---

## 📖 Table of Contents

1. [Patrón Básico (Basic Chain)](#patrón-básico-basic-chain)
2. [Patrón RAG (Retrieval Augmented Generation)](#patrón-rag-retrieval-augmented-generation)
3. [Patrón de Salida Estructurada (Pydantic)](#patrón-de-salida-estructurada-pydantic)
4. [Patrón Conversacional (Memory)](#patrón-conversacional-memory)
5. [Patrón Agente (ReAct Loop)](#patrón-agente-react-loop)
6. [Patrón Paralelo (Multithreading)](#patrón-paralelo-multithreading)
7. [Patrón Condicional (Branching)](#patrón-condicional-branching)
8. [Anti-Patterns y Errores Comunes](#anti-patterns-y-errores-comunes)

---

## Patrón Básico (Basic Chain)

La unidad fundamental de trabajo.

### Estructura

```python
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser
from langchain_community.chat_models import ChatOllama

# 1️⃣ Componentes
model = ChatOllama(model="llama3", temperature=0.7)
prompt = ChatPromptTemplate.from_template(
    "Cuéntame un chiste sobre {topic}"
)
parser = StrOutputParser()

# 2️⃣ Composición (The Pipe)
chain = prompt | model | parser

# 3️⃣ Ejecución Sync
result = chain.invoke({"topic": "programadores"})
print(result)  # String: "¿Por qué los programadores..."

# 4️⃣ Ejecución Async Stream (Token a token)
import asyncio

async def stream_chain():
    async for chunk in chain.astream({"topic": "Python"}):
        print(chunk, end="", flush=True)

asyncio.run(stream_chain())
```

### Desglose

| Componente | Rol | Ejemplo |
|:---|:---|:---|
| **Prompt** | Formatea input | `ChatPromptTemplate.from_template(...)` |
| **Model** | Genera token | `ChatOllama(model="llama3")` |
| **Parser** | Procesa output | `StrOutputParser()`, `PydanticOutputParser(...)` |

### Invocaciones

```python
# ✅ Sincrónico
result = chain.invoke({"topic": "AI"})

# ✅ Asincrónico
result = await chain.ainvoke({"topic": "AI"})

# ✅ Stream (token a token)
for chunk in chain.stream({"topic": "AI"}):
    print(chunk, end="")

# ✅ Async Stream
async for chunk in chain.astream({"topic": "AI"}):
    print(chunk, end="")

# ✅ Batch (múltiples inputs)
results = chain.batch([
    {"topic": "AI"},
    {"topic": "Python"},
    {"topic": "LLMs"}
])
```

---

## Patrón RAG (Retrieval Augmented Generation)

Usar `RunnableParallel` para buscar documentos y pasar la pregunta simultáneamente.

### Estructura

```python
from langchain_core.runnables import RunnablePassthrough, RunnableParallel
from langchain_core.prompts import ChatPromptTemplate
from langchain_core.output_parsers import StrOutputParser
from langchain_community.chat_models import ChatOllama
from langchain_community.vectorstores import Chroma

# Setup
model = ChatOllama(model="llama3")
vectorstore = Chroma(collection_name="documents")
retriever = vectorstore.as_retriever(search_type="similarity", search_kwargs={"k": 3})

# Prompt
rag_prompt = ChatPromptTemplate.from_template("""
You are a helpful assistant. Answer the question based on the context.

Context:
{context}

Question: {question}

Answer:""")

# RAG Chain con RunnableParallel
rag_chain = (
    RunnableParallel({
        "context": retriever,                  # Busca docs usando el input
        "question": RunnablePassthrough()      # Pasa el input tal cual
    })
    | rag_prompt                               # Recibe {context, question}
    | model
    | StrOutputParser()
)

# Uso
question = "¿Cuál es la capital de Francia?"
result = rag_chain.invoke({"question": question})
print(result)
```

### Desglose de RunnableParallel

```python
# RunnableParallel ejecuta múltiples runnables en PARALELO
parallel = RunnableParallel({
    "context": retriever,              # Rama 1: buscar (independiente del input)
    "question": RunnablePassthrough()  # Rama 2: pasar input sin cambios
})

# Input: "¿Capital de Francia?"
# Output: {
#     "context": "Francia es un país... París es la capital...",
#     "question": "¿Capital de Francia?"
# }

# Este output se pasa al siguiente paso (prompt)
```

### Alternativa: Buscar por Pregunta

```python
# Si el retriever necesita acceder solo a "question":
def format_docs(docs):
    return "\n\n".join(doc.page_content for doc in docs)

rag_chain = (
    RunnableParallel({
        "context": retriever | format_docs,  # Extrae docs.page_content
        "question": RunnablePassthrough()
    })
    | rag_prompt
    | model
    | StrOutputParser()
)
```

---

## Patrón de Salida Estructurada (Pydantic)

Obligar al LLM a devolver objetos Python válidos.

### Estructura

```python
from pydantic import BaseModel, Field
from langchain_core.output_parsers import PydanticOutputParser
from langchain_core.prompts import ChatPromptTemplate

# 1️⃣ Definir esquema
class Joke(BaseModel):
    setup: str = Field(description="La introducción del chiste")
    punchline: str = Field(description="El remate gracioso")

# 2️⃣ Crear parser
parser = PydanticOutputParser(pydantic_object=Joke)

# 3️⃣ Obtener instrucciones de formato
format_instructions = parser.get_format_instructions()

# 4️⃣ Crear prompt CON instrucciones
prompt = ChatPromptTemplate.from_template("""
Generate a joke about {topic}.

{format_instructions}
""")

# 5️⃣ Armar cadena
model = ChatOllama(model="llama3")
chain = prompt | model | parser

# 6️⃣ Invocar
joke_obj: Joke = chain.invoke({
    "topic": "AI",
    "format_instructions": format_instructions
})

print(joke_obj.punchline)  # ✅ Type-safe: String
print(type(joke_obj))      # <class 'Joke'>
```

### Con Function Calling (GPT-4/Claude)

```python
# ✅ MEJOR: Si el modelo soporta function calling
from langchain_openai import ChatOpenAI

class InvoiceData(BaseModel):
    invoice_number: str = Field(description="Número único")
    total_amount: float = Field(description="Monto total")
    due_date: str = Field(description="Fecha vencimiento (YYYY-MM-DD)")

model = ChatOpenAI(model="gpt-4")
structured_llm = model.with_structured_output(InvoiceData)

prompt = ChatPromptTemplate.from_template("""
Extract invoice data from:
{invoice_text}
""")

chain = prompt | structured_llm

invoice: InvoiceData = chain.invoke({"invoice_text": raw_text})
```

### Manejo de Errores

```python
from langchain_core.output_parsers import OutputParserException

try:
    joke_obj: Joke = chain.invoke({
        "topic": "AI",
        "format_instructions": format_instructions
    })
except OutputParserException as e:
    logger.error(f"Parse error: {e}")
    # Fallback
    joke_obj = Joke(
        setup="No puedo generar el chiste",
        punchline="Lo siento, intenta de nuevo"
    )

print(joke_obj)
```

---

## Patrón Conversacional (Memory)

Añadir historial de chat a una cadena LCEL.

### Estructura Básica

```python
from langchain_core.runnables.history import RunnableWithMessageHistory
from langchain_community.chat_message_histories import ChatMessageHistory

# 1️⃣ Crear la cadena base
base_chain = prompt | model | StrOutputParser()

# 2️⃣ Función que obtiene historial por session_id
def get_session_history(session_id: str):
    # En prod: obtener de DB
    if not hasattr(get_session_history, "store"):
        get_session_history.store = {}

    if session_id not in get_session_history.store:
        get_session_history.store[session_id] = ChatMessageHistory()

    return get_session_history.store[session_id]

# 3️⃣ Envolver con RunnableWithMessageHistory
chain_with_history = RunnableWithMessageHistory(
    base_chain,
    get_session_history,
    input_messages_key="question",
    history_messages_key="history"
)

# 4️⃣ Invocar CON session_id
response = chain_with_history.invoke(
    {"question": "¿Cuál es mi nombre?"},
    config={"configurable": {"session_id": "user_123"}}
)

# El histórico se mantiene automáticamente
```

### Con Mensajes del Sistema

```python
from langchain_core.messages import SystemMessage

system_prompt = SystemMessage(
    content="Eres un asistente de soporte técnico. Sé conciso y útil."
)

# Mensaje del usuario
user_message = ("human", "{question}")

prompt = ChatPromptTemplate.from_messages([
    system_prompt,
    ("history", "{history}"),  # Placeholder para historial
    user_message
])

chain_with_history = RunnableWithMessageHistory(
    prompt | model | StrOutputParser(),
    get_session_history,
    input_messages_key="question",
    history_messages_key="history"
)
```

---

## Patrón Agente (ReAct Loop)

Loop: Think → Act → Observe.

### Estructura

```python
from langchain.agents import create_react_agent, AgentExecutor
from langchain_core.tools import tool
from langchain_community.chat_models import ChatOllama

# 1️⃣ Definir herramientas
@tool
def search_documents(query: str) -> str:
    """Search knowledge base by query."""
    results = vectorstore.similarity_search(query, k=3)
    return "\n".join([doc.page_content for doc in results])

@tool
def calculate_sum(a: int, b: int) -> int:
    """Sum two numbers."""
    return a + b

tools = [search_documents, calculate_sum]

# 2️⃣ Crear agente
model = ChatOllama(model="llama3")
agent = create_react_agent(model, tools, prompt=agent_prompt)

# 3️⃣ Ejecutor
executor = AgentExecutor(
    agent=agent,
    tools=tools,
    max_iterations=5,
    verbose=True
)

# 4️⃣ Invocar
response = executor.invoke({
    "input": "¿Cuál es la capital de Francia? Suma 5 + 3."
})

print(response["output"])
```

### Ciclo Mental del Agente

```
Thought: Necesito buscar información sobre Francia.
Action: search_documents
Action Input: "Capital de Francia"

Observation: "Francia es un país europeo. París es la capital..."

Thought: Ya tengo la respuesta. Ahora calculo 5 + 3.
Action: calculate_sum
Action Input: a=5, b=3

Observation: 8

Thought: Puedo responder ahora.
Final Answer: La capital de Francia es París. 5 + 3 = 8.
```

---

## Patrón Paralelo (Multithreading)

Ejecutar múltiples runnables simultáneamente.

### Estructura

```python
from langchain_core.runnables import RunnableParallel

# Crear múltiples análisis en paralelo
parallel_analysis = RunnableParallel({
    "sentiment": sentiment_chain,
    "summary": summary_chain,
    "entities": entities_chain,
    "keywords": keywords_chain
})

# Invocar
text = "El producto es excelente pero el servicio fue lento..."
result = parallel_analysis.invoke({"text": text})

# Result:
# {
#     "sentiment": "Positivo con reservas",
#     "summary": "Buena calidad, mala velocidad",
#     "entities": ["producto", "servicio"],
#     "keywords": ["excelente", "lento"]
# }
```

### Caso Real: RAG con Re-ranking

```python
from langchain_core.runnables import RunnableParallel, RunnableLambda

# Buscar en paralelo: semantic + keyword search
retrieval = RunnableParallel({
    "semantic_docs": semantic_retriever,
    "keyword_docs": keyword_retriever
})

# Combinar y re-rankear
def combine_docs(parallel_result):
    semantic = parallel_result["semantic_docs"]
    keyword = parallel_result["keyword_docs"]
    # Custom logic: merge, deduplicate, rank
    return merge_and_rank(semantic, keyword)

full_chain = (
    retrieval
    | RunnableLambda(combine_docs)
    | prompt
    | model
    | parser
)
```

---

## Patrón Condicional (Branching)

Ejecutar diferentes cadenas según condición.

### Estructura

```python
from langchain_core.runnables import RunnableLambda, RunnableParallel

def route_based_length(input_dict):
    """Si texto es > 500 chars, summarize. Si no, pasar tal cual."""
    text = input_dict["text"]
    return "summarize" if len(text) > 500 else "passthrough"

# Cadenas alternativas
summarize_chain = prompt_summarize | model | parser
passthrough_chain = RunnableLambda(lambda x: x["text"])

# Selector con mapping
from langchain_core.runnables import RunnableBranch

branched_chain = RunnableBranch(
    (lambda x: len(x["text"]) > 500, summarize_chain),
    (lambda x: True, passthrough_chain)  # Default
)

# Uso
result = branched_chain.invoke({"text": "..." })
```

---

## Anti-Patterns y Errores Comunes

### ❌ ANTI-PATTERN 1: No Usar Pipe

```python
# ❌ BAD: Mezclar estilos
chain1 = LLMChain(llm=model, prompt=prompt)  # Legacy
chain2 = prompt | model | parser              # LCEL

# Inconsistencia: tipos diferentes, comportamientos diferentes
```

### ❌ ANTI-PATTERN 2: Ignorar Streaming

```python
# ❌ BAD: Esperar token por token innecesariamente
result = chain.invoke({"question": "..."})
print(result)  # Espera a TODOS los tokens antes de mostrar

# ✅ GOOD: Streaming para UX fluida
for chunk in chain.stream({"question": "..."}):
    print(chunk, end="", flush=True)  # Muestra token por token
```

### ❌ ANTI-PATTERN 3: No Validar Outputs

```python
# ❌ BAD: Confiar en el LLM
response = model.invoke(prompt)
parsed = json.loads(response.content)  # ¿Qué si no es válido JSON?

# ✅ GOOD: Usar PydanticOutputParser
parser = PydanticOutputParser(pydantic_object=Schema)
chain = prompt | model | parser
parsed = chain.invoke({...})  # Validado automáticamente
```

### ❌ ANTI-PATTERN 4: Bloquear en Async

```python
# ❌ BAD: Mezclar sync en async
async def process():
    result = chain.invoke({...})  # ← Blocking!

# ✅ GOOD: Usar ainvoke
async def process():
    result = await chain.ainvoke({...})
```

---

## Checklist: Cadena Bien Formada

```bash
# ✅ 1. Estructura
[ ] Usa pipe |
[ ] NO usa LLMChain/SimpleSequentialChain
[ ] Prompt es ChatPromptTemplate
[ ] Parser es específico (StrOutputParser, PydanticOutputParser, etc)

# ✅ 2. Inputs/Outputs
[ ] Inputs están documentados
[ ] Outputs son type-safe
[ ] Errores de parsing tienen fallback

# ✅ 3. Performance
[ ] Usa .stream() para UX fluida
[ ] .batch() para múltiples inputs
[ ] .astream() para async

# ✅ 4. Testing
[ ] Mock model en tests
[ ] Edge cases cubiertos
[ ] Timeouts configurados

# ✅ 5. Observabilidad
[ ] Prompts se loguean
[ ] Errores se capturan con contexto
[ ] LangSmith tracer integrado (opt)
```

---

**Date:** 30 de Enero de 2026
**Status:** ✅ PRODUCTION-READY PATTERNS
**Responsable:** ArchitectZero AI Agent
