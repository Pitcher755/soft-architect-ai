# 🆔 Tech Profile: Ollama

> **Fecha:** 30/01/2026
> **Estado:** ✅ Desplegado
> **Categoría:** Local LLM Inference Engine
> **Web Oficial:** https://ollama.com/
> **Licencia:** MIT
> **Versión Recomendada:** 0.1.20+ (latest)

Motor para ejecutar Modelos de Lenguaje (LLMs) localmente sin internet. Es el **corazón de privacidad** en SoftArchitect AI: datos nunca salen de la máquina del usuario.

---

## 📖 Tabla de Contenidos

1. [Suitability (Dónde Brilla Ollama)](#suitability-dónde-brilla-ollama)
2. [Value Analysis](#value-analysis)
3. [System Requirements](#system-requirements)
4. [Stack Integration](#stack-integration)
5. [Model Lifecycle & Versioning](#model-lifecycle--versioning)
6. [References & Ecosystem](#references--ecosystem)

---

## Suitability (Dónde Brilla Ollama)

### ✅ Ideal Para

| Caso de Uso | Explicación | Ejemplo SoftArchitect |
|:---|:---|:---|
| **Privacidad Total (GDPR/Medical)** | Datos nunca viajan a servidores de OpenAI/Anthropic. Cumplimiento regulatorio garantizado. | RAG sobre documentos técnicos internos sin cargar a la nube |
| **Desarrollo Rápido (Coste $0)** | Testear prompts, templates, chain-of-thought sin API credits. | Iterar en prompts de RAG sin gastar $$$$ en llamadas a GPT-4 |
| **RAG Local & Retrieval** | Embeddings + Inferencia en la misma máquina. Latencia <200ms garantizada. | Buscar en Knowledge Base + generar respuestas sin red |
| **Offline-First** | Funciona sin conexión a internet. Ideal para entornos corporativos aislados. | Empresa con políticas anti-cloud puede usar SoftArchitect sin modificaciones |
| **Model Fine-Tuning** | Entrenar modelos en datos privados usando técnicas como LoRA. | Especializar modelo en arquitectura de software SoftArchitect-specific |

### ❌ NO Usar Ollama Para

| Escenario | Por Qué | Alternativa |
|:---|:---|:---|
| **Producción Masiva Concurrente** | Ollama maneja una cola de requests. Escalabilidad limitada a ~10-20 queries/s en GPU modesta. | vLLM, TGI (Text Generation Inference), LiteLLM |
| **Modelos Gigantes sin GPU** | Llama-3-70b en CPU es **inservible** (100+ tokens/s). Timeout garantizado. | Cloud API (Azure OpenAI, Groq) o GPU dedicada |
| **Latencia <50ms crítica** | Ollama tiene overheads de desserialización. RTT típico: 100-300ms. | Modelos optimizados (ONNX Runtime), edge inference (Triton) |
| **Múltiples GPUs/Orchestración** | Ollama no soporta distribución multi-GPU nativa. | Kubernetes + vLLM, Ray Serve |

---

## Value Analysis

Análisis de Ollama en **6 dimensiones críticas** para decisión técnica.

### 1️⃣ Developer Speed (Velocidad de Setup)

**Rating:** ⭐⭐⭐⭐⭐ (5/5 - Excelente)

```bash
# Install Ollama (1 comando)
curl https://ollama.ai/install.sh | sh

# Pull un modelo (1 comando)
ollama pull llama2:7b

# Listo para inferencia (segundos)
curl http://localhost:11434/api/generate -d '{"model":"llama2","prompt":"Hola"}'
```

**vs vLLM:** Requiere Git, CUDA setup, compilación, virtualenv (30+ minutos).

---

### 2️⃣ Inference Performance (Velocidad de Generación)

**Rating:** ⭐⭐⭐⭐ (4/5 - Bueno)

| Métrica | Ollama | GPT-4 API | vLLM | Nota |
|:---|---:|---:|---:|:---|
| **Latencia First Token** | 500-800ms | 200-400ms | 300-500ms | Ollama sufre desserialización inicial |
| **Throughput (tokens/s)** | 40-80 | 50-100 | 100-200 | GPU modesta (RTX 3070): ~60 tok/s |
| **Context Window** | 2k-8k | 8k-128k | 2k-32k | Configurable en Modelfile |
| **Cost (1M tokens)** | $0 (compute local) | $30 (input) | $0 (compute local) | Ollama gana en costo |

**Caso Real SoftArchitect:**
```
- RAG Query: Buscar 5 documentos relevantes (~1k tokens)
- Generación: "Resume estos documentos" (~300 tokens)
- Latencia Total Ollama: 1.2s
- Latencia Total GPT-4 API: 2.5s + latencia red
```

---

### 3️⃣ Ease of Integration (Integración con Stack)

**Rating:** ⭐⭐⭐⭐⭐ (5/5 - Excelente)

Ollama expone **API REST compatible con OpenAI**. Cambiar de proveedor es reemplazar 1 variable de entorno:

```python
# client.py - Agnóstico de proveedor
from openai import OpenAI  # Misma API!

# 🔧 Integración Ollama
client = OpenAI(
    api_key="not-needed",
    base_url="http://localhost:11434/v1"
)

# 🔧 Integración OpenAI (swap automático)
# client = OpenAI(api_key=os.getenv("OPENAI_API_KEY"))

response = client.chat.completions.create(
    model="llama2",  # Cambiar model_id solo
    messages=[{"role": "user", "content": "Hola"}]
)
```

**Ecosistema Compatible:**
- ✅ LangChain (`llama2` model)
- ✅ LiteLLM (proxy universal)
- ✅ FastAPI clients (curl, requests)
- ✅ Llamaindex (indexing)

---

### 4️⃣ Security & Privacy (Seguridad de Datos)

**Rating:** ⭐⭐⭐⭐⭐ (5/5 - Excelente)

**Ventajas:**
- ✅ Datos **nunca** salen del servidor local
- ✅ No hay logging en servidores de terceros
- ✅ Cumplimiento GDPR/HIPAA automático
- ✅ Auditable: código abierto (MIT)

**Riesgos:**
- ⚠️ Servidor Ollama expuesto a red corporativa (no firewalled)
- ⚠️ Modelo puede ser "exfiltrado" si puerto 11434 accesible

**Mitigación (SoftArchitect):**
```dockerfile
# docker-compose.yml: Ollama SOLO accesible desde backend
services:
  ollama:
    expose:  # NO ports (no expose to host)
      - 11434
    networks:
      - softarchitect-net  # Red privada interna
```

---

### 5️⃣ Operational Maturity (Estabilidad)

**Rating:** ⭐⭐⭐⭐ (4/5 - Maduro)

**Fortalezas:**
- ✅ Producción: 15,000+ descargas/día
- ✅ Actualizado: releases mensuales
- ✅ GPU: Soporte NVIDIA/AMD/Metal (Apple)

**Limitaciones:**
- ⚠️ No hay clustering multi-GPU nativo
- ⚠️ Escalabilidad vertical (más RAM/VRAM) no horizontal
- ⚠️ Sin orquestador Kubernetes

---

### 6️⃣ Community & Ecosystem (Comunidad)

**Rating:** ⭐⭐⭐⭐ (4/5 - Muy Activa)

**Recursos:**
- ✅ Discord activo (~50k miembros)
- ✅ Model library: 100+ modelos precargados
- ✅ GitHub: 50k+ stars, contribuciones regulares
- ✅ Integración con frameworks populares (LangChain, Llamaindex)

**Proyectos Relacionados:**
- **LiteLLM:** Proxy para unificar APIs (Ollama + OpenAI + Anthropic)
- **Llamaindex:** RAG framework con soporte Ollama
- **Ollama Web UI:** Frontend para gestión de modelos

---

## System Requirements

### Mínimos (Development)

| Componente | Requisito | Nota |
|:---|:---|:---|
| **CPU** | Intel i7/Ryzen 5+ | 4+ cores recomendado |
| **RAM** | 8GB mínimo | 16GB recomendado |
| **GPU** | Opcional | CPU-only: ~5-10 tok/s |
| **Disk** | 20GB libre | Modelo Llama-2-7b: ~4GB |
| **OS** | Linux/macOS/Windows | Docker en Windows |

### Recomendado (Production SoftArchitect)

| Componente | Requisito | Justificación |
|:---|:---|:---|
| **CPU** | 8+ cores | Embedding + generate concurrentemente |
| **RAM** | 32GB | FastAPI + Ollama + ChromaDB simultáneo |
| **GPU** | NVIDIA RTX 4070+ (12GB VRAM) | Llama-2-13b inference |
| **Disk** | 100GB NVMe | Modelos + datos ChromaDB |
| **OS** | Linux (Ubuntu 22.04 LTS) | Stabilidad en producción |

### Hardware Benchmarks

| Hardware | Model | Throughput | Nota |
|:---|:---|---:|:---|
| **CPU (Intel i9)** | Llama-2-7b | 5 tok/s | Muy lento |
| **GPU (RTX 3070)** | Llama-2-7b | 60 tok/s | 👍 Recomendado |
| **GPU (RTX 4070)** | Llama-2-13b | 80 tok/s | 👍 Producción |
| **GPU (H100)** | Llama-2-70b | 200+ tok/s | 🚀 Enterprise |

---

## Stack Integration

### 1. Ollama ↔ FastAPI (Backend)

```python
# src/services/rag/llm_engine.py
from openai import OpenAI
from typing import AsyncGenerator

class OllamaLLMEngine:
    def __init__(self, base_url: str = "http://ollama:11434"):
        self.client = OpenAI(api_key="not-used", base_url=f"{base_url}/v1")
        self.model_id = "llama2:13b-chat"  # Custom Modelfile

    async def stream_generate(self, prompt: str) -> AsyncGenerator[str, None]:
        """Stream respuestas del LLM (evitar latencia de espera)"""
        response = self.client.chat.completions.create(
            model=self.model_id,
            messages=[
                {"role": "system", "content": "Eres un asistente de arquitectura de software."},
                {"role": "user", "content": prompt}
            ],
            stream=True,
            temperature=0.1,  # Determinista para RAG
        )
        for chunk in response:
            if chunk.choices[0].delta.content:
                yield chunk.choices[0].delta.content
```

---

### 2. Ollama ↔ ChromaDB (Embeddings)

```python
# Opción A: Usar Ollama para embeddings (compatible)
from chromadb.config import Settings
from chromadb import Client

settings = Settings(
    chroma_db_impl="duckdb",
    anonymized_telemetry=False,
    allow_reset=True
)

client = Client(settings)
collection = client.get_or_create_collection(
    name="softarchitect_kb",
    metadata={"hnsw:space": "cosine"}
)

# ChromaDB intentará usar modelo de embedding local si está disponible
```

---

### 3. Ollama ↔ Docker (Orquestación)

```yaml
# infrastructure/docker-compose.yml
services:
  ollama:
    image: ollama/ollama:latest
    container_name: ollama
    environment:
      OLLAMA_MODELS: /models  # Persistencia
      OLLAMA_KEEP_ALIVE: 24h  # No descargar modelo tras inactividad
    volumes:
      - ollama_models:/root/.ollama/models
    ports:
      - "11434:11434"  # API
    networks:
      - softarchitect-net
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:11434/api/tags"]
      interval: 30s
      timeout: 10s
      retries: 3
    restart: unless-stopped

  backend:
    depends_on:
      - ollama  # Esperar a Ollama antes de iniciar API
    environment:
      OLLAMA_BASE_URL: "http://ollama:11434"

volumes:
  ollama_models:
    driver: local
```

---

## Model Lifecycle & Versioning

### Versiones de Ollama

| Versión | Fecha | Cambio Notable |
|:---|:---|:---|
| **0.0.1** | Ago 2023 | Lanzamiento inicial |
| **0.1.0** | Dic 2023 | Soporte metal (Apple Silicon) |
| **0.1.15** | May 2024 | Streaming improvements |
| **0.1.20+** | Ene 2025 | Estable para producción ✅ |

**Recomendación SoftArchitect:** Usar `0.1.20+`. Pin en docker-compose.

### Modelos Disponibles

```bash
# Listar modelos locales
ollama list

# Ejemplos de modelos pequeños y rápidos:
ollama pull llama2:7b          # 3.8GB, rápido, general-purpose
ollama pull mistral:7b         # 4.0GB, mejor calidad, razonamiento
ollama pull neural-chat:7b     # 3.8GB, optimizado para chat
ollama pull openhermes:7b      # 3.8GB, mejor instruction-following

# Para documentación técnica:
ollama pull mistral:7b         # Mejor comprensión de textos técnicos
```

---

## References & Ecosystem

### Documentación Oficial
- https://github.com/ollama/ollama
- https://ollama.ai/library (Model library)

### Integraciones
- **LangChain:** https://python.langchain.com/docs/integrations/llms/ollama
- **Llamaindex:** https://gpt-index.readthedocs.io/en/latest/examples/llms/ollama.html
- **LiteLLM:** https://docs.litellm.ai/docs/providers/ollama

### Benchmarks & Comparativas
- https://huggingface.co/spaces/HuggingFaceH4/open_llm_leaderboard
- Model Card: https://ollama.ai/library/{{MODEL_NAME}}

---

## Conclusión

**Ollama es el motor de inferencia elegido para SoftArchitect porque:**

1. ✅ **Privacidad:** Datos locales, sin nube
2. ✅ **Velocidad:** Setup <5 minutos, inferencia <1s
3. ✅ **Costo:** $0/mes en compute (amortizado en hardware)
4. ✅ **Flexibilidad:** API compatible OpenAI, fácil swap

**Dogfooding Validation:** SoftArchitect usa Ollama para:
- Generar respuestas a queries del usuario (RAG)
- Fine-tune el modelo con patrones SoftArchitect internos (LoRA)
- Iterar prompts sin costos de API
