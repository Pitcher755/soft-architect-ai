# ⚡ Streaming Responses - SoftArchitect AI

> **Fecha:** 02/19/2026
> **Estado:** ✅ Technical streaming guide
> **Tiempo de lectura:** 6 minutes

---

## 📖 Tabla de Contenidos

- [Qué es Streaming?](#what-is-streaming)
- [How It Works](#how-it-works)
- [Control Streaming](#control-streaming)
- [Streaming Advantages](#streaming-advantages)
- [Common Problems](#common-problems)

---

## 🎬 Qué es Streaming?

Instead of waiting 30 seconds to receive a complete response, **streaming** shows text **word by word** in real time, as if the AI were "typing" in front of you.

### Visual Comparison

**Without Streaming:**
```
[User sends question]
⏳ Waiting... (30 seconds)
✅ Complete response appears all at once
```

**With Streaming:**
```
[User sends question]
"To design an..." ← Appears immediately (1s)
"To design an API REST..." ← Continues growing (3s)
"To design an API REST you need..." ← Completes (5s)
✅ Complete response
```

---

## ⚙️ How It Works

### Technical Architecture

```
┌──────────────┐      HTTP Stream       ┌──────────────┐
│   Frontend   │ ◄─────────────────────  │   Backend    │
│  (Flutter)   │  (Server-Sent Events)  │  (FastAPI)   │
└──────────────┘                         └──────────────┘
       │                                        │
       │ 1. User sends question                 │
       ├────────────────────────────────────────►
       │                                        │
       │ 2. Backend invokes LLM (Ollama/Groq)  │
       │                               ┌────────┴────────┐
       │                               │ Mistral/Llama   │
       │ 3. Tokens arrive one by one   └────────┬────────┘
       ◄────────────────────────────────────────┤
       │ "To"                                    │
       ◄────────────────────────────────────────┤
       │ "design"                                │
       ◄────────────────────────────────────────┤
       │ "an API"                                │
       ◄────────────────────────────────────────┤
       │ ...                                     │
```

### Communication Protocol

**Technology used:** **Server-Sent Events (SSE)**

**Endpoint:**
```
POST /api/chat/stream
Content-Type: text/event-stream

data: {"token": "To", "done": false}

data: {"token": " design", "done": false}

data: {"token": " an", "done": false}

data: {"token": " API", "done": false}

data: {"done": true}
```

---

## 🎮 Control Streaming

### 1. Interrupt Response

**When to do it:**
- Response drifted from topic
- You already have enough information
- Detected error in logic

**How to do it:**

| Method | Action |
|--------|--------|
| **UI Botón** | Click `[⏹️ Stop]` |
| **Keyboard** | Press `Esc` |
| **API** | Send `DELETE /api/chat/stream/{session_id}` |

**Resultado:**
```
🤖 SoftArchitect AI:
"To design a REST API you need to consider..."

[User presses Esc]

⏹️ Response interrupted by user.
```

---

### 2. Pause Streaming (Experimental)

**Function:** Temporarily pause to read carefully.

**How to activate:**
```bash
# Edit .env
STREAMING_PAUSABLE=true
```

**Usage:**
- Click `[⏸️ Pause]` → Streaming stops
- Click `[▶️ Resume]` → Continues from where it left off

---

### 3. Adjust Speed

**Default:** ~20 tokens/second

**To change:**
```bash
# .env
STREAMING_DELAY_MS=50  # Slower (50ms between tokens)
STREAMING_DELAY_MS=10  # Faster (10ms between tokens)
STREAMING_DELAY_MS=0   # Maximum speed (no artificial delay)
```

**Note:** Actual speed depends on model (Ollama local vs Groq cloud).

---

## 🚀 Streaming Advantages

### 1. **Immediate Feedback**

**Without streaming:**
- User waits 30s not knowing if AI is processing or frozen
- Anxiety from lack of feedback

**With streaming:**
- First words appear in <1s
- User knows AI is working

---

### 2. **Early Interruption**

**Scenario:** You asked "How to scale PostgreSQL?" but AI starts explaining MongoDB.

**Without streaming:**
- Wait 30s for complete response
- Discover it's irrelevant
- Time wasted

**With streaming:**
- At 3s you see "MongoDB is a NoSQL database..."
- Press `Esc` inmediataly
- Rephrase question
- Time saved: 27s

---

### 3. **Better UX (User Experience)**

**Studies show:**
- Streaming reduces perceived latency by 60%
- Users report higher satisfaction with progressive responses

---

## ⚠️ Common Problems

### ❌ "Choppy streaming (laggy)"

**Symptoms:**
- Text appears in large blocks instead of word by word
- 2-3s delays between updates

**Possible causes:**

**1. Overloaded local model**
```bash
# Check CPU/GPU usage
htop  # Linux
# If CPU > 90%, model is slow

# Solution: Switch to lighter model
ollama pull phi
# .env
MODEL_NAME=phi
```

**2. Slow network (if using Groq Cloud)**
```bash
# Latency test
curl -w "@curl-format.txt" -o /dev/null -s https://api.groq.com/health

# If latency > 500ms, streaming will be slow
# Solution: Switch to Ollama local
```

**3. Blocked frontend**
```dart
// Verify parsing doesn't block UI thread
// In Flutter, use compute() for heavy operations
await compute(_parseStreamingResponse, data);
```

---

### ❌ "Response cuts off mid-sentence"

**Symptoms:**
```
🤖 SoftArchitect AI:
"To design a REST API you need to consider..."

[Abrupt end]
```

**Causes:**

**1. Server timeout**
```bash
# .env
STREAMING_TIMEOUT=300  # 5 minutes (increase if needed)
```

**2. Model token limit**
```bash
# .env
MAX_TOKENS=4096  # Increase to 8192 if model supports it
```

**3. Lost connection**
```bash
# Check server logs
docker logs soft-architect-ai-backend | grep "connection closed"
```

---

### ❌ "Stop botón doesn't appear"

**Cause:** Streaming disabled in config

**Solution:**
```bash
# .env
ENABLE_STREAMING=true

# Restart backend
docker-compose restart backend
```

---

## 🛠️ Avanzado Configuración

### Customize Behavior

```python
# src/server/config/streaming.py

class StreamingConfig:
    CHUNK_SIZE = 1          # Tokens per chunk (1 = word by word)
    BUFFER_SIZE = 10        # Tokens to accumulate before sending
    TIMEOUT = 300           # Seconds before timeout
    RETRY_ATTEMPTS = 3      # Retries if fails
    ENABLE_PAUSE = True     # Allow pausing streaming
```

### Custom Usage Example

```python
# Send metadata with each chunk
{
    "token": "API",
    "done": false,
    "meta": {
        "confidence": 0.95,         # Model confidence
        "tokens_generated": 42,     # Tokens so far
        "estimated_remaining": 100  # Remaining tokens (estimate)
    }
}
```

---

## 📚 Related Documentos

- [Chat Interface](05-CHAT_INTERFACE.md) - How to use chat
- [Troubleshooting](08-TROUBLESHOOTING.md) - Problem solving
- [Backend Architecture](../../30-ARCHITECTURE/BACKEND_ARCHITECTURE.md) - Technical details

---

<p align="center">
  <a href="07-DATA_PERSISTENCE.md">Data Persistence →</a> |
  <a href="05-CHAT_INTERFACE.md">← Chat Interface</a>
</p>
