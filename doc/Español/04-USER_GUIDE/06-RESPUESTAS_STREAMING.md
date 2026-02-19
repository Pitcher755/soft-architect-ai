# ⚡ Respuestas en Streaming - SoftArchitect AI

> **Fecha:** 19/02/2026
> **Estado:** ✅ Guía técnica de streaming
> **Tiempo de lectura:** 6 minutos

---

## 📖 Tabla de Contenidos

- [¿Qué es el Streaming?](#qué-es-el-streaming)
- [Cómo Funciona](#cómo-funciona)
- [Controlar el Streaming](#controlar-el-streaming)
- [Ventajas del Streaming](#ventajas-del-streaming)
- [Problemas Comunes](#problemas-comunes)

---

## 🎬 ¿Qué es el Streaming?

En lugar de esperar 30 segundos para recibir una respuesta completa, el **streaming** muestra el texto **palabra por palabra** en tiempo real, como si la IA estuviera "escribiendo" frente a ti.

### Comparación Visual

**Sin Streaming:**
```
[Usuario envía pregunta]
⏳ Esperando... (30 segundos)
✅ Respuesta completa aparece de golpe
```

**Con Streaming:**
```
[Usuario envía pregunta]
"Para diseñar una..." ← Aparece inmediatamente (1s)
"Para diseñar una API REST..." ← Continúa creciendo (3s)
"Para diseñar una API REST necesitas..." ← Se completa (5s)
✅ Respuesta completa
```

---

## ⚙️ Cómo Funciona

### Arquitectura Técnica

```
┌──────────────┐      HTTP Stream       ┌──────────────┐
│   Frontend   │ ◄─────────────────────  │   Backend    │
│  (Flutter)   │  (Server-Sent Events)  │  (FastAPI)   │
└──────────────┘                         └──────────────┘
       │                                        │
       │ 1. Usuario envía pregunta              │
       ├────────────────────────────────────────►
       │                                        │
       │ 2. Backend invoca LLM (Ollama/Groq)   │
       │                               ┌────────┴────────┐
       │                               │ Mistral/Llama   │
       │ 3. Tokens llegan uno a uno    └────────┬────────┘
       ◄────────────────────────────────────────┤
       │ "Para"                                  │
       ◄────────────────────────────────────────┤
       │ "diseñar"                               │
       ◄────────────────────────────────────────┤
       │ "una API"                               │
       ◄────────────────────────────────────────┤
       │ ...                                     │
```

### Protocolo de Comunicación

**Tecnología usada:** **Server-Sent Events (SSE)**

**Endpoint:**
```
POST /api/chat/stream
Content-Type: text/event-stream

data: {"token": "Para", "done": false}

data: {"token": " diseñar", "done": false}

data: {"token": " una", "done": false}

data: {"token": " API", "done": false}

data: {"done": true}
```

---

## 🎮 Controlar el Streaming

### 1. Interrumpir Respuesta

**Cuándo hacerlo:**
- La respuesta se desvió del tema
- Ya tienes suficiente información
- Detectaste un error en la lógica

**Cómo hacerlo:**

| Método | Acción |
|--------|--------|
| **Botón UI** | Click en `[⏹️ Detener]` |
| **Teclado** | Presionar `Esc` |
| **API** | Enviar `DELETE /api/chat/stream/{session_id}` |

**Resultado:**
```
🤖 SoftArchitect AI:
"Para diseñar una API REST necesitas considerar..."

[Usuario presiona Esc]

⏹️ Respuesta interrumpida por el usuario.
```

---

### 2. Pausar Streaming (Experimental)

**Función:** Pausar temporalmente para leer con calma.

**Cómo activarlo:**
```bash
# Editar .env
STREAMING_PAUSABLE=true
```

**Uso:**
- Click en `[⏸️ Pausar]` → Streaming se detiene
- Click en `[▶️ Reanudar]` → Continúa desde donde quedó

---

### 3. Ajustar Velocidad

**Por defecto:** ~20 tokens/segundo

**Para cambiar:**
```bash
# .env
STREAMING_DELAY_MS=50  # Más lento (50ms entre tokens)
STREAMING_DELAY_MS=10  # Más rápido (10ms entre tokens)
STREAMING_DELAY_MS=0   # Máxima velocidad (sin delay artificial)
```

**Nota:** La velocidad real depende del modelo (Ollama local vs Groq cloud).

---

## 🚀 Ventajas del Streaming

### 1. **Feedback Inmediato**

**Sin streaming:**
- Usuario espera 30s sin saber si la IA está procesando o colgada
- Ansiedad por falta de feedback

**Con streaming:**
- Primeras palabras aparecen en <1s
- Usuario sabe que la IA está funcionando

---

### 2. **Interrupción Temprana**

**Escenario:** Preguntaste "¿Cómo escalar PostgreSQL?" pero la IA empieza a explicar MongoDB.

**Sin streaming:**
- Esperas 30s para la respuesta completa
- Descubres que es irrelevante
- Tiempo perdido

**Con streaming:**
- A los 3s ves "MongoDB es una base de datos NoSQL..."
- Presionas `Esc` inmediatamente
- Reformulas la pregunta
- Tiempo ahorrado: 27s

---

### 3. **Mejor UX (Experiencia de Usuario)**

**Estudios demuestran:**
- Streaming reduce la percepción de latencia en un 60%
- Usuarios reportan mayor satisfacción con respuestas progresivas

---

## ⚠️ Problemas Comunes

### ❌ "Streaming entrecortado (laggy)"

**Síntomas:**
- Texto aparece en bloques grandes en lugar de palabra por palabra
- Delays de 2-3s entre updates

**Causas posibles:**

**1. Modelo local sobrecargado**
```bash
# Verificar CPU/GPU usage
htop  # Linux
# Si CPU > 90%, el modelo es lento

# Solución: Cambiar a modelo más ligero
ollama pull phi
# .env
MODEL_NAME=phi
```

**2. Red lenta (si usas Groq Cloud)**
```bash
# Test de latencia
curl -w "@curl-format.txt" -o /dev/null -s https://api.groq.com/health

# Si latencia > 500ms, streaming será lento
# Solución: Cambiar a Ollama local
```

**3. Frontend bloqueado**
```dart
// Verificar que el parsing no bloquea UI thread
// En Flutter, usar compute() para operaciones pesadas
await compute(_parseStreamingResponse, data);
```

---

### ❌ "Respuesta se corta a mitad"

**Síntomas:**
```
🤖 SoftArchitect AI:
"Para diseñar una API REST necesitas considerar..."

[Fin abrupto]
```

**Causas:**

**1. Timeout del servidor**
```bash
# .env
STREAMING_TIMEOUT=300  # 5 minutos (aumentar si necesario)
```

**2. Límite de tokens del modelo**
```bash
# .env
MAX_TOKENS=4096  # Aumentar a 8192 si el modelo lo soporta
```

**3. Conexión perdida**
```bash
# Verificar logs del servidor
docker logs soft-architect-ai-backend | grep "connection closed"
```

---

### ❌ "No aparece botón de detener"

**Causa:** Streaming deshabilitado en configuración

**Solución:**
```bash
# .env
ENABLE_STREAMING=true

# Reiniciar backend
docker-compose restart backend
```

---

## 🛠️ Configuración Avanzada

### Personalizar Comportamiento

```python
# src/server/config/streaming.py

class StreamingConfig:
    CHUNK_SIZE = 1          # Tokens por chunk (1 = palabra por palabra)
    BUFFER_SIZE = 10        # Tokens a acumular antes de enviar
    TIMEOUT = 300           # Segundos antes de timeout
    RETRY_ATTEMPTS = 3      # Reintentos si falla
    ENABLE_PAUSE = True     # Permitir pausar streaming
```

### Ejemplo de Uso Personalizado

```python
# Enviar metadata con cada chunk
{
    "token": "API",
    "done": false,
    "meta": {
        "confidence": 0.95,      # Confianza del modelo
        "tokens_generated": 42,   # Tokens hasta ahora
        "estimated_remaining": 100 # Tokens restantes (estimado)
    }
}
```

---

## 📚 Documentos Relacionados

- [Interfaz de Chat](05-INTERFAZ_CHAT.md) - Cómo usar el chat
- [Solución de Problemas](08-SOLUCIÓN_DE_PROBLEMAS.md) - Troubleshooting
- [Arquitectura Backend](../../30-ARCHITECTURE/BACKEND_ARCHITECTURE.md) - Detalles técnicos

---

<p align="center">
  <a href="07-PERSISTENCIA_DATOS.md">Persistencia de Datos →</a> |
  <a href="05-INTERFAZ_CHAT.md">← Interfaz de Chat</a>
</p>
