# ⚙️ HU-4.4: Configuration Guide - Chat History Limits

> **User Story:** HU-4.4 - RAG/LLM Resilience Extensions
> **Feature:** Configurable Chat History Limits (Phase 7)
> **Commit:** `3786589`
> **Status:** ✅ Complete
> **Date:** January 2025

---

<div align="center">

[🇬🇧 English](#english) | [🇪🇸 Español](#español)

</div>

---

<div id="español">

## 📖 Tabla de Contenidos

1. [Introducción](#-introducción)
2. [Variables de Entorno](#-variables-de-entorno)
3. [Métodos de Configuración](#-métodos-de-configuración)
4. [Ejemplos por Caso de Uso](#-ejemplos-por-caso-de-uso)
5. [Performance Tuning](#-performance-tuning)
6. [Troubleshooting](#-troubleshooting)
7. [Validación de Configuración](#-validación-de-configuración)

---

## 🎯 Introducción

Desde **Phase 7** (commit `3786589`), los límites de historial de chat son **configurables dinámicamente** vía environment variables, sin necesidad de recompilar el código.

### ¿Por qué es importante?

- 📈 **Escalabilidad:** Proyectos grandes (25+ documentos) necesitan más contexto.
- ⚙️ **Flexibilidad:** Ajustar límites según recursos (RAM, latencia).
- 🚀 **Sin downtime:** Cambiar configuración con restart rápido (no redeploy).
- 🧠 **Mejor memoria:** Aprovechar capacidad del modelo (32K tokens).

### Antes vs Después

| Aspecto | Before Phase 7 | After Phase 7 |
|---------|----------------|---------------|
| Max Messages | 20 (hardcoded) | **100** (configurable) |
| Max Chars/Message | 5000 (hardcoded) | **20000** (configurable) |
| Configuration Method | Recompilación | `.env` / Docker / Export |
| Frontend Sends History | ❌ No | ✅ Sí (últimos 100) |

---

## 📝 Variables de Entorno

### 1. CHAT_MAX_HISTORY_MESSAGES

**Descripción:** Número máximo de mensajes en el historial conversacional.

**Tipo:** `int`

**Default:** `100`

**Rango Recomendado:** `30` - `200`

**Uso:** Controla cuántos pares (user + assistant) se envían al LLM como contexto.

**Ejemplo:**
```bash
CHAT_MAX_HISTORY_MESSAGES=100
```

**Consideraciones:**
- **Valor bajo (30-50):** Proyectos pequeños, prioridad en latencia baja.
- **Valor medio (100-120):** Proyectos medianos, balance contexto/latencia.
- **Valor alto (150-200):** Proyectos grandes, prioridad en contexto completo.

**Trade-offs:**
| Valor | Ventajas | Desventajas |
|-------|----------|-------------|
| 30 | ⚡ Latencia baja (<500ms) | 🧠 Contexto limitado |
| 100 | ⚖️ Balance ideal | ⚖️ Latencia media (1-2s) |
| 200 | 🧠 Contexto máximo | ⏱️ Latencia alta (3-5s) |

---

### 2. CHAT_MAX_MESSAGE_LENGTH

**Descripción:** Número máximo de caracteres por mensaje individual (tanto mensaje actual como en historial).

**Tipo:** `int`

**Default:** `20000`

**Rango Recomendado:** `8000` - `30000`

**Uso:** Limita tamaño de mensajes largos (ej. pegar código completo).

**Ejemplo:**
```bash
CHAT_MAX_MESSAGE_LENGTH=20000
```

**Consideraciones:**
- **Valor bajo (8000-12000):** VPS con poca RAM (<4GB).
- **Valor medio (20000):** Balance ideal, soporta documentos extensos.
- **Valor alto (25000-30000):** Proyectos de documentación, código completo.

**Límite del Modelo:**
El modelo soporta **~32K tokens** (~32000 caracteres). Configurar >32000 no tiene beneficio.

**Trade-offs:**
| Valor | Ventajas | Desventajas |
|-------|----------|-------------|
| 8000 | 🪶 Bajo uso de RAM | 📝 Documentos cortos solo |
| 20000 | ⚖️ Balance ideal | ⚖️ RAM media (~2GB) |
| 30000 | 📚 Documentación completa | 🐏 Alto uso de RAM (>4GB) |

---

## 🛠️ Métodos de Configuración

### Method 1: .env File (Development - Recomendado)

**Archivo:** `src/server/.env`

**Pasos:**
1. Crear archivo `.env` si no existe:
   ```bash
   cd src/server
   cp .env.example .env
   ```

2. Editar `.env`:
   ```bash
   # Chat History Configuration
   CHAT_MAX_HISTORY_MESSAGES=150
   CHAT_MAX_MESSAGE_LENGTH=25000

   # Other settings...
   LOG_LEVEL=DEBUG
   ```

3. Restart backend:
   ```bash
   source venv/bin/activate
   uvicorn app.main:app --reload
   ```

**Pros:**
- ✅ Fácil de editar localmente
- ✅ No commitear (en `.gitignore`)
- ✅ Hot reload con `--reload`

**Cons:**
- ❌ No aplica en producción (solo local)

---

### Method 2: Docker Compose (Staging/Production - Recomendado)

**Archivo:** `infrastructure/docker-compose.yml`

**Opción A: Valores Directos**

```yaml
services:
  backend:
    environment:
      - CHAT_MAX_HISTORY_MESSAGES=150
      - CHAT_MAX_MESSAGE_LENGTH=25000
```

**Opción B: Leer desde .env del Host**

```yaml
services:
  backend:
    environment:
      - CHAT_MAX_HISTORY_MESSAGES=${CHAT_MAX_HISTORY_MESSAGES:-100}
      - CHAT_MAX_MESSAGE_LENGTH=${CHAT_MAX_MESSAGE_LENGTH:-20000}
```

En host:
```bash
# .env en raíz del proyecto
CHAT_MAX_HISTORY_MESSAGES=150
CHAT_MAX_MESSAGE_LENGTH=25000
```

**Deploy:**
```bash
cd infrastructure
docker-compose down && docker-compose up -d
```

**Pros:**
- ✅ Configuración centralizada
- ✅ Defaults con sintaxis `${VAR:-default}`
- ✅ Funcionan en staging/production

**Cons:**
- ❌ Requiere restart de contenedor

---

### Method 3: Terminal Export (Testing Temporal)

**Uso temporal durante desarrollo/testing:**

```bash
# Export en terminal
export CHAT_MAX_HISTORY_MESSAGES=200
export CHAT_MAX_MESSAGE_LENGTH=30000

# Run backend
cd src/server
uvicorn app.main:app --reload
```

**Pros:**
- ✅ Rápido para testing
- ✅ No modifica archivos

**Cons:**
- ❌ No persiste (solo sesión actual)
- ❌ Fácil olvidar valores

---

### Method 4: Systemd Service (Production Linux)

**Archivo:** `/etc/systemd/system/softarchitect-backend.service`

```ini
[Unit]
Description=SoftArchitect AI Backend
After=network.target

[Service]
Type=simple
User=softarchitect
WorkingDirectory=/opt/softarchitect
Environment="CHAT_MAX_HISTORY_MESSAGES=100"
Environment="CHAT_MAX_MESSAGE_LENGTH=20000"
Environment="LOG_LEVEL=INFO"
ExecStart=/opt/softarchitect/venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8000

[Install]
WantedBy=multi-user.target
```

**Deploy:**
```bash
sudo systemctl daemon-reload
sudo systemctl restart softarchitect-backend
```

**Pros:**
- ✅ Configuración persistente en servidor
- ✅ Arranca en boot automáticamente

---

### Method 5: Kubernetes ConfigMap (Cloud Native)

**Archivo:** `k8s/backend-config.yaml`

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: backend-config
  namespace: default
data:
  CHAT_MAX_HISTORY_MESSAGES: "100"
  CHAT_MAX_MESSAGE_LENGTH: "20000"
  LOG_LEVEL: "INFO"
```

**Deployment:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
spec:
  template:
    spec:
      containers:
      - name: backend
        image: softarchitect-backend:latest
        envFrom:
        - configMapRef:
            name: backend-config
```

**Deploy:**
```bash
kubectl apply -f k8s/backend-config.yaml
kubectl rollout restart deployment/backend
```

**Pros:**
- ✅ Gestión centralizada en Kubernetes
- ✅ Hot reload con rollout restart

---

## 💼 Ejemplos por Caso de Uso

### Caso 1: Proyecto Personal / Prototipo

**Características:**
- 1-5 documentos en knowledge base
- Usuario solo (conversaciones cortas)
- VPS económico (2GB RAM)

**Configuración Recomendada:**
```bash
CHAT_MAX_HISTORY_MESSAGES=30
CHAT_MAX_MESSAGE_LENGTH=10000
```

**Justificación:**
- 30 mensajes = 15 pares (suficiente para sesión corta)
- 10K chars = Preguntas típicas sin código extenso
- Bajo uso de RAM (~1GB)

---

### Caso 2: Proyecto Mediano / Startup

**Características:**
- 10-25 documentos en knowledge base
- 2-5 usuarios simultáneos
- Conversaciones medianas (5-10 preguntas seguidas)
- Servidor estándar (4GB RAM)

**Configuración Recomendada:**
```bash
CHAT_MAX_HISTORY_MESSAGES=100
CHAT_MAX_MESSAGE_LENGTH=20000
```

**Justificación:**
- 100 mensajes = 50 pares (conversación extensa)
- 20K chars = Soporta documentos técnicos completos
- Balance latencia/contexto (1-2s response time)

---

### Caso 3: Proyecto Grande / Enterprise

**Características:**
- 50+ documentos en knowledge base
- 10+ usuarios simultáneos
- Conversaciones muy largas (20+ preguntas)
- Servidor dedicado (16GB+ RAM)

**Configuración Recomendada:**
```bash
CHAT_MAX_HISTORY_MESSAGES=200
CHAT_MAX_MESSAGE_LENGTH=30000
```

**Justificación:**
- 200 mensajes = 100 pares (máximo contexto)
- 30K chars = Código/documentación completa (near model limit)
- Alta disponibilidad de RAM permite contexto máximo

---

### Caso 4: Documentación Técnica / Research

**Características:**
- Knowledge base extensa (100+ docs)
- Preguntas muy específicas con mucho contexto
- Prioridad en precisión sobre latencia

**Configuración Recomendada:**
```bash
CHAT_MAX_HISTORY_MESSAGES=150
CHAT_MAX_MESSAGE_LENGTH=28000
```

**Justificación:**
- 150 mensajes = Balance entre contexto y performance
- 28K chars = Permite pegar documentación casi completa
- Latencia alta aceptable (3-5s) por mayor precisión

---

### Caso 5: Demo / Producción Low-Latency

**Características:**
- Demo en vivo o presentaciones
- Prioridad en respuesta rápida (<1s)
- Conversaciones cortas y directas

**Configuración Recomendada:**
```bash
CHAT_MAX_HISTORY_MESSAGES=20
CHAT_MAX_MESSAGE_LENGTH=8000
```

**Justificación:**
- 20 mensajes = Mínimo necesario para contexto conversacional
- 8K chars = Preguntas directas sin código extenso
- Latencia ultra-baja (<500ms LLM latency)

---

## 📊 Performance Tuning

### Relación RAM vs Configuración

**Fórmula Estimada:**
```
RAM_por_request ≈ (MESSAGES × AVG_CHARS × 2 bytes) + overhead
```

**Ejemplos:**

| Messages | Chars | Avg Msg Size | RAM/Request | Concurrent Users (4GB RAM) |
|----------|-------|--------------|-------------|----------------------------|
| 30 | 10000 | 500 chars | ~100 MB | ~20 users |
| 100 | 20000 | 1000 chars | ~400 MB | ~5 users |
| 200 | 30000 | 1500 chars | ~800 MB | ~2 users |

**Recomendación:**
- **VPS <4GB:** `MESSAGES=30`, `LENGTH=10000`
- **VPS 4-8GB:** `MESSAGES=100`, `LENGTH=20000` (default)
- **Servidor >8GB:** `MESSAGES=150-200`, `LENGTH=25000-30000`

---

### Latencia vs Configuración

**Factores que Afectan Latencia:**
1. **Contexto más grande → Mayor latencia LLM**
2. **Más mensajes → Mayor tiempo de procesamiento prompt**
3. **Caracteres largos → Mayor bandwidth network**

**Tabla de Latencia Estimada:**

| Messages | Chars | Prompt Size | LLM Latency | Total Response Time |
|----------|-------|-------------|-------------|---------------------|
| 20 | 8000 | ~2K tokens | 300ms | <1s |
| 50 | 15000 | ~8K tokens | 800ms | 1-2s |
| 100 | 20000 | ~15K tokens | 1.5s | 2-3s |
| 200 | 30000 | ~30K tokens | 3s | 4-6s |

**Optimización:**
- Para **low latency** (<1s): Reducir `MESSAGES` y `LENGTH`
- Para **high accuracy** (contexto completo): Incrementar ambos
- **Balance ideal:** Default (100, 20000)

---

### Trade-offs Summary

| Prioridad | MESSAGES | LENGTH | RAM | Latency | Use Case |
|-----------|----------|--------|-----|---------|----------|
| **Speed** | 20-30 | 8000 | Baja | <1s | Demo, Prototipo |
| **Balance** | 100 | 20000 | Media | 1-2s | Producción estándar ✅ |
| **Context** | 150-200 | 25000-30000 | Alta | 3-5s | Research, Enterprise |

---

## 🔍 Troubleshooting

### Problema 1: Error 400 "exceeds maximum length"

**Síntoma:**
```json
{
  "detail": "Chat history exceeds maximum length (100 messages). Adjust CHAT_MAX_HISTORY_MESSAGES env var if needed."
}
```

**Causa:** Frontend envía más mensajes de los permitidos.

**Solución:**
```bash
# Opción A: Incrementar límite backend
echo "CHAT_MAX_HISTORY_MESSAGES=150" >> src/server/.env
docker-compose restart backend

# Opción B: Reducir límite frontend (código)
# En chat_repository_impl.dart, cambiar:
const maxHistoryMessages = 150;  // Era 100
```

---

### Problema 2: Latencia Alta (>5s)

**Síntoma:** Respuestas del LLM tardan demasiado.

**Causa:** Contexto muy grande (muchos mensajes + chars largos).

**Solución:**
```bash
# Reducir contexto
echo "CHAT_MAX_HISTORY_MESSAGES=50" >> src/server/.env
echo "CHAT_MAX_MESSAGE_LENGTH=12000" >> src/server/.env
docker-compose restart backend
```

**Validación:**
```bash
time curl -X POST http://localhost:8000/api/v1/chat/stream \
  -d '{"message":"test","project_id":"1"}' | head -n 1
# Debe retornar en <2s
```

---

### Problema 3: OOM (Out of Memory) en Container

**Síntoma:**
```
backend_1    | Killed
backend_1 exited with code 137
```

**Causa:** RAM insuficiente para contexto configurado.

**Solución:**
```bash
# Opción A: Reducir configuración
CHAT_MAX_HISTORY_MESSAGES=30
CHAT_MAX_MESSAGE_LENGTH=8000

# Opción B: Incrementar memoria Docker
# docker-compose.yml:
services:
  backend:
    mem_limit: 2g  # Era 1g
```

---

### Problema 4: Backend No Lee Variables de .env

**Síntoma:** Backend usa defaults (100, 20000) ignorando `.env`.

**Causa:** `.env` no está en directorio correcto o Docker no lo mapea.

**Diagnóstico:**
```bash
# Verificar que backend ve variables
docker-compose exec backend env | grep CHAT_MAX
# Si no muestra nada, variables no están cargadas
```

**Solución:**
```bash
# Verificar .env existe
ls -la src/server/.env

# Re-create containers
docker-compose down
docker-compose up -d

# Verificar logs
docker-compose logs backend | grep "CHAT_MAX"
```

---

### Problema 5: Error de Validación en Tests

**Síntoma:**
```python
ValidationError: Message 0 content exceeds 20000 characters (got 25000)
```

**Causa:** Tests usan mensajes muy largos sin ajustar configuración.

**Solución:**
```python
# En tests, mockear settings
@patch("app.core.config.settings.CHAT_MAX_MESSAGE_LENGTH", 30000)
def test_accepts_long_message():
    # Test con mensaje de 25000 chars
    ...
```

---

## ✅ Validación de Configuración

### Paso 1: Verificar Backend Carga Variables

```bash
# Method: Docker
docker-compose exec backend env | grep CHAT_MAX

# Expected output:
CHAT_MAX_HISTORY_MESSAGES=100
CHAT_MAX_MESSAGE_LENGTH=20000

# Method: Local
cd src/server
source venv/bin/activate
python -c "from app.core.config import settings; print(f'Messages: {settings.CHAT_MAX_HISTORY_MESSAGES}, Length: {settings.CHAT_MAX_MESSAGE_LENGTH}')"
```

---

### Paso 2: Test de Validación (Reject Oversized)

```bash
# Test que backend rechaza >100 messages
curl -X POST http://localhost:8000/api/v1/chat/stream \
  -H "X-API-Key: test-key" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Test",
    "project_id": "test-project",
    "history": [
      {"role": "user", "content": "Message 1"},
      ...
      {"role": "user", "content": "Message 101"}
    ]
  }'

# Expected: 400 Bad Request
# Body: {"detail": "Chat history exceeds maximum length (100 messages)..."}
```

---

### Paso 3: Test de Aceptación (Accept Valid)

```bash
# Test que backend acepta 50 messages (< 100)
curl -X POST http://localhost:8000/api/v1/chat/stream \
  -H "X-API-Key: test-key" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Test",
    "project_id": "test-project",
    "history": [
      {"role": "user", "content": "Message 1"},
      ...
      {"role": "user", "content": "Message 50"}
    ]
  }'

# Expected: 200 OK + SSE stream
```

---

### Paso 4: Verificar Frontend Envía History

**Abrir Flutter app y enviar mensaje, observar logs:**

```
# En terminal de backend:
docker-compose logs -f backend

# Expected output:
📤 Sending 50 history messages to backend
✅ Chat request validated: 50 history messages
```

---

### Paso 5: Test de Performance

**Benchmark de latencia con diferentes configuraciones:**

```bash
# Test 1: Small context (30 messages, 10K chars)
CHAT_MAX_HISTORY_MESSAGES=30 CHAT_MAX_MESSAGE_LENGTH=10000 \
  time curl -X POST http://localhost:8000/api/v1/chat/stream \
    -d '{"message":"test","project_id":"1"}' | head -n 1

# Test 2: Medium context (100 messages, 20K chars) - Default
time curl -X POST http://localhost:8000/api/v1/chat/stream \
  -d '{"message":"test","project_id":"1"}' | head -n 1

# Test 3: Large context (200 messages, 30K chars)
CHAT_MAX_HISTORY_MESSAGES=200 CHAT_MAX_MESSAGE_LENGTH=30000 \
  time curl -X POST http://localhost:8000/api/v1/chat/stream \
    -d '{"message":"test","project_id":"1"}' | head -n 1

# Compare latencies:
# Small: ~500ms
# Medium: ~1.5s (acceptable)
# Large: ~4s (high but needed for context)
```

---

## 📚 Referencias

### Archivos Relacionados

**Configuración:**
- `src/server/app/core/config.py` - Settings class (defaults)
- `src/server/.env.example` - Template con documentación
- `infrastructure/docker-compose.yml` - Mapeo de env vars

**Validación:**
- `src/server/app/domain/schemas/chat.py` - Validators dinámicos
- `tests/server/unit/domain/schemas/test_chat_history.py` - Tests de límites

**Frontend:**
- `src/client/lib/features/chat/data/repositories/chat_repository_impl.dart` - History loading

### Documentación Relacionada

- [RECENT_CHANGES.md](./RECENT_CHANGES.md) - Resumen de Phase 6 y 7
- [PROGRESS.md](./PROGRESS.md) - Tracking detallado de implementación
- [ARTIFACTS.md](./ARTIFACTS.md) - Lista de archivos modificados
- [README.md](./README.md) - HU-4.4 overview completo

### Commits

- **Phase 6:** `01eec76` - feat(backend): add chat history support for conversational context
- **Phase 7:** `3786589` - feat(chat): make history limits configurable via environment variables

---

</div>

---

<div id="english">

## 📖 Table of Contents

1. [Introduction](#-introduction-1)
2. [Environment Variables](#-environment-variables-1)
3. [Configuration Methods](#-configuration-methods-1)
4. [Use Case Examples](#-use-case-examples)
5. [Performance Tuning](#-performance-tuning-1)
6. [Troubleshooting](#-troubleshooting-1)
7. [Configuration Validation](#-configuration-validation-1)

---

## 🎯 Introduction

Since **Phase 7** (commit `3786589`), chat history limits are **dynamically configurable** via environment variables, without code recompilation.

### Why is this important?

- 📈 **Scalability:** Large projects (25+ documents) need more context.
- ⚙️ **Flexibility:** Adjust limits based on resources (RAM, latency).
- 🚀 **No downtime:** Change configuration with quick restart (no redeploy).
- 🧠 **Better memory:** Leverage model capacity (32K tokens).

### Before vs After

| Aspect | Before Phase 7 | After Phase 7 |
|---------|----------------|---------------|
| Max Messages | 20 (hardcoded) | **100** (configurable) |
| Max Chars/Message | 5000 (hardcoded) | **20000** (configurable) |
| Configuration Method | Recompilation | `.env` / Docker / Export |
| Frontend Sends History | ❌ No | ✅ Yes (last 100) |

---

## 📝 Environment Variables

### 1. CHAT_MAX_HISTORY_MESSAGES

**Description:** Maximum number of messages in conversational history.

**Type:** `int`

**Default:** `100`

**Recommended Range:** `30` - `200`

**Purpose:** Controls how many (user + assistant) pairs are sent to LLM as context.

**Example:**
```bash
CHAT_MAX_HISTORY_MESSAGES=100
```

**Considerations:**
- **Low value (30-50):** Small projects, low latency priority.
- **Medium value (100-120):** Medium projects, balance context/latency.
- **High value (150-200):** Large projects, full context priority.

**Trade-offs:**
| Value | Advantages | Disadvantages |
|-------|-----------|---------------|
| 30 | ⚡ Low latency (<500ms) | 🧠 Limited context |
| 100 | ⚖️ Ideal balance | ⚖️ Medium latency (1-2s) |
| 200 | 🧠 Maximum context | ⏱️ High latency (3-5s) |

---

### 2. CHAT_MAX_MESSAGE_LENGTH

**Description:** Maximum characters per individual message (both current message and in history).

**Type:** `int`

**Default:** `20000`

**Recommended Range:** `8000` - `30000`

**Purpose:** Limits size of long messages (e.g., pasting complete code).

**Example:**
```bash
CHAT_MAX_MESSAGE_LENGTH=20000
```

**Considerations:**
- **Low value (8000-12000):** VPS with low RAM (<4GB).
- **Medium value (20000):** Ideal balance, supports extensive documents.
- **High value (25000-30000):** Documentation projects, complete code.

**Model Limit:**
Model supports **~32K tokens** (~32000 characters). Configuring >32000 has no benefit.

**Trade-offs:**
| Value | Advantages | Disadvantages |
|-------|-----------|---------------|
| 8000 | 🪶 Low RAM usage | 📝 Short documents only |
| 20000 | ⚖️ Ideal balance | ⚖️ Medium RAM (~2GB) |
| 30000 | 📚 Complete documentation | 🐏 High RAM usage (>4GB) |

---

## 🛠️ Configuration Methods

### Method 1: .env File (Development - Recommended)

**File:** `src/server/.env`

**Steps:**
1. Create `.env` file if it doesn't exist:
   ```bash
   cd src/server
   cp .env.example .env
   ```

2. Edit `.env`:
   ```bash
   # Chat History Configuration
   CHAT_MAX_HISTORY_MESSAGES=150
   CHAT_MAX_MESSAGE_LENGTH=25000

   # Other settings...
   LOG_LEVEL=DEBUG
   ```

3. Restart backend:
   ```bash
   source venv/bin/activate
   uvicorn app.main:app --reload
   ```

**Pros:**
- ✅ Easy to edit locally
- ✅ Don't commit (in `.gitignore`)
- ✅ Hot reload with `--reload`

**Cons:**
- ❌ Doesn't apply in production (local only)

---

### Method 2: Docker Compose (Staging/Production - Recommended)

**File:** `infrastructure/docker-compose.yml`

**Option A: Direct Values**

```yaml
services:
  backend:
    environment:
      - CHAT_MAX_HISTORY_MESSAGES=150
      - CHAT_MAX_MESSAGE_LENGTH=25000
```

**Option B: Read from Host .env**

```yaml
services:
  backend:
    environment:
      - CHAT_MAX_HISTORY_MESSAGES=${CHAT_MAX_HISTORY_MESSAGES:-100}
      - CHAT_MAX_MESSAGE_LENGTH=${CHAT_MAX_MESSAGE_LENGTH:-20000}
```

On host:
```bash
# .env in project root
CHAT_MAX_HISTORY_MESSAGES=150
CHAT_MAX_MESSAGE_LENGTH=25000
```

**Deploy:**
```bash
cd infrastructure
docker-compose down && docker-compose up -d
```

**Pros:**
- ✅ Centralized configuration
- ✅ Defaults with syntax `${VAR:-default}`
- ✅ Works in staging/production

**Cons:**
- ❌ Requires container restart

---

### Method 3: Terminal Export (Temporary Testing)

**Temporary use during development/testing:**

```bash
# Export in terminal
export CHAT_MAX_HISTORY_MESSAGES=200
export CHAT_MAX_MESSAGE_LENGTH=30000

# Run backend
cd src/server
uvicorn app.main:app --reload
```

**Pros:**
- ✅ Quick for testing
- ✅ Doesn't modify files

**Cons:**
- ❌ Not persistent (current session only)
- ❌ Easy to forget values

---

### Method 4: Systemd Service (Production Linux)

**File:** `/etc/systemd/system/softarchitect-backend.service`

```ini
[Unit]
Description=SoftArchitect AI Backend
After=network.target

[Service]
Type=simple
User=softarchitect
WorkingDirectory=/opt/softarchitect
Environment="CHAT_MAX_HISTORY_MESSAGES=100"
Environment="CHAT_MAX_MESSAGE_LENGTH=20000"
Environment="LOG_LEVEL=INFO"
ExecStart=/opt/softarchitect/venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8000

[Install]
WantedBy=multi-user.target
```

**Deploy:**
```bash
sudo systemctl daemon-reload
sudo systemctl restart softarchitect-backend
```

**Pros:**
- ✅ Persistent configuration on server
- ✅ Auto-start on boot

---

### Method 5: Kubernetes ConfigMap (Cloud Native)

**File:** `k8s/backend-config.yaml`

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: backend-config
  namespace: default
data:
  CHAT_MAX_HISTORY_MESSAGES: "100"
  CHAT_MAX_MESSAGE_LENGTH: "20000"
  LOG_LEVEL: "INFO"
```

**Deployment:**
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: backend
spec:
  template:
    spec:
      containers:
      - name: backend
        image: softarchitect-backend:latest
        envFrom:
        - configMapRef:
            name: backend-config
```

**Deploy:**
```bash
kubectl apply -f k8s/backend-config.yaml
kubectl rollout restart deployment/backend
```

**Pros:**
- ✅ Centralized management in Kubernetes
- ✅ Hot reload with rollout restart

---

## 💼 Use Case Examples

### Case 1: Personal Project / Prototype

**Characteristics:**
- 1-5 documents in knowledge base
- Single user (short conversations)
- Economic VPS (2GB RAM)

**Recommended Configuration:**
```bash
CHAT_MAX_HISTORY_MESSAGES=30
CHAT_MAX_MESSAGE_LENGTH=10000
```

**Justification:**
- 30 messages = 15 pairs (enough for short session)
- 10K chars = Typical questions without extensive code
- Low RAM usage (~1GB)

---

### Case 2: Medium Project / Startup

**Characteristics:**
- 10-25 documents in knowledge base
- 2-5 simultaneous users
- Medium conversations (5-10 follow-up questions)
- Standard server (4GB RAM)

**Recommended Configuration:**
```bash
CHAT_MAX_HISTORY_MESSAGES=100
CHAT_MAX_MESSAGE_LENGTH=20000
```

**Justification:**
- 100 messages = 50 pairs (extensive conversation)
- 20K chars = Supports complete technical documents
- Balance latency/context (1-2s response time)

---

### Case 3: Large Project / Enterprise

**Characteristics:**
- 50+ documents in knowledge base
- 10+ simultaneous users
- Very long conversations (20+ questions)
- Dedicated server (16GB+ RAM)

**Recommended Configuration:**
```bash
CHAT_MAX_HISTORY_MESSAGES=200
CHAT_MAX_MESSAGE_LENGTH=30000
```

**Justification:**
- 200 messages = 100 pairs (maximum context)
- 30K chars = Complete code/documentation (near model limit)
- High RAM availability allows maximum context

---

### Case 4: Technical Documentation / Research

**Characteristics:**
- Extensive knowledge base (100+ docs)
- Very specific questions with lots of context
- Precision priority over latency

**Recommended Configuration:**
```bash
CHAT_MAX_HISTORY_MESSAGES=150
CHAT_MAX_MESSAGE_LENGTH=28000
```

**Justification:**
- 150 messages = Balance between context and performance
- 28K chars = Allows pasting almost complete documentation
- High latency acceptable (3-5s) for better accuracy

---

### Case 5: Demo / Low-Latency Production

**Characteristics:**
- Live demo or presentations
- Priority on fast response (<1s)
- Short and direct conversations

**Recommended Configuration:**
```bash
CHAT_MAX_HISTORY_MESSAGES=20
CHAT_MAX_MESSAGE_LENGTH=8000
```

**Justification:**
- 20 messages = Minimum needed for conversational context
- 8K chars = Direct questions without extensive code
- Ultra-low latency (<500ms LLM latency)

---

## 📊 Performance Tuning

### RAM vs Configuration Relationship

**Estimated Formula:**
```
RAM_per_request ≈ (MESSAGES × AVG_CHARS × 2 bytes) + overhead
```

**Examples:**

| Messages | Chars | Avg Msg Size | RAM/Request | Concurrent Users (4GB RAM) |
|----------|-------|--------------|-------------|----------------------------|
| 30 | 10000 | 500 chars | ~100 MB | ~20 users |
| 100 | 20000 | 1000 chars | ~400 MB | ~5 users |
| 200 | 30000 | 1500 chars | ~800 MB | ~2 users |

**Recommendation:**
- **VPS <4GB:** `MESSAGES=30`, `LENGTH=10000`
- **VPS 4-8GB:** `MESSAGES=100`, `LENGTH=20000` (default)
- **Server >8GB:** `MESSAGES=150-200`, `LENGTH=25000-30000`

---

### Latency vs Configuration

**Factors Affecting Latency:**
1. **Larger context → Higher LLM latency**
2. **More messages → Higher prompt processing time**
3. **Long characters → Higher network bandwidth**

**Estimated Latency Table:**

| Messages | Chars | Prompt Size | LLM Latency | Total Response Time |
|----------|-------|-------------|-------------|---------------------|
| 20 | 8000 | ~2K tokens | 300ms | <1s |
| 50 | 15000 | ~8K tokens | 800ms | 1-2s |
| 100 | 20000 | ~15K tokens | 1.5s | 2-3s |
| 200 | 30000 | ~30K tokens | 3s | 4-6s |

**Optimization:**
- For **low latency** (<1s): Reduce `MESSAGES` and `LENGTH`
- For **high accuracy** (full context): Increase both
- **Ideal balance:** Default (100, 20000)

---

### Trade-offs Summary

| Priority | MESSAGES | LENGTH | RAM | Latency | Use Case |
|-----------|----------|--------|-----|---------|----------|
| **Speed** | 20-30 | 8000 | Low | <1s | Demo, Prototype |
| **Balance** | 100 | 20000 | Medium | 1-2s | Standard production ✅ |
| **Context** | 150-200 | 25000-30000 | High | 3-5s | Research, Enterprise |

---

## 🔍 Troubleshooting

### Problem 1: Error 400 "exceeds maximum length"

**Symptom:**
```json
{
  "detail": "Chat history exceeds maximum length (100 messages). Adjust CHAT_MAX_HISTORY_MESSAGES env var if needed."
}
```

**Cause:** Frontend sends more messages than allowed.

**Solution:**
```bash
# Option A: Increase backend limit
echo "CHAT_MAX_HISTORY_MESSAGES=150" >> src/server/.env
docker-compose restart backend

# Option B: Reduce frontend limit (code)
# In chat_repository_impl.dart, change:
const maxHistoryMessages = 150;  // Was 100
```

---

### Problem 2: High Latency (>5s)

**Symptom:** LLM responses take too long.

**Cause:** Very large context (many messages + long chars).

**Solution:**
```bash
# Reduce context
echo "CHAT_MAX_HISTORY_MESSAGES=50" >> src/server/.env
echo "CHAT_MAX_MESSAGE_LENGTH=12000" >> src/server/.env
docker-compose restart backend
```

**Validation:**
```bash
time curl -X POST http://localhost:8000/api/v1/chat/stream \
  -d '{"message":"test","project_id":"1"}' | head -n 1
# Should return in <2s
```

---

### Problem 3: OOM (Out of Memory) in Container

**Symptom:**
```
backend_1    | Killed
backend_1 exited with code 137
```

**Cause:** Insufficient RAM for configured context.

**Solution:**
```bash
# Option A: Reduce configuration
CHAT_MAX_HISTORY_MESSAGES=30
CHAT_MAX_MESSAGE_LENGTH=8000

# Option B: Increase Docker memory
# docker-compose.yml:
services:
  backend:
    mem_limit: 2g  # Was 1g
```

---

### Problem 4: Backend Doesn't Read .env Variables

**Symptom:** Backend uses defaults (100, 20000) ignoring `.env`.

**Cause:** `.env` not in correct directory or Docker doesn't map it.

**Diagnosis:**
```bash
# Verify backend sees variables
docker-compose exec backend env | grep CHAT_MAX
# If nothing shows, variables not loaded
```

**Solution:**
```bash
# Verify .env exists
ls -la src/server/.env

# Re-create containers
docker-compose down
docker-compose up -d

# Check logs
docker-compose logs backend | grep "CHAT_MAX"
```

---

### Problem 5: Validation Error in Tests

**Symptom:**
```python
ValidationError: Message 0 content exceeds 20000 characters (got 25000)
```

**Cause:** Tests use very long messages without adjusting configuration.

**Solution:**
```python
# In tests, mock settings
@patch("app.core.config.settings.CHAT_MAX_MESSAGE_LENGTH", 30000)
def test_accepts_long_message():
    # Test with 25000 char message
    ...
```

---

## ✅ Configuration Validation

### Step 1: Verify Backend Loads Variables

```bash
# Method: Docker
docker-compose exec backend env | grep CHAT_MAX

# Expected output:
CHAT_MAX_HISTORY_MESSAGES=100
CHAT_MAX_MESSAGE_LENGTH=20000

# Method: Local
cd src/server
source venv/bin/activate
python -c "from app.core.config import settings; print(f'Messages: {settings.CHAT_MAX_HISTORY_MESSAGES}, Length: {settings.CHAT_MAX_MESSAGE_LENGTH}')"
```

---

### Step 2: Validation Test (Reject Oversized)

```bash
# Test that backend rejects >100 messages
curl -X POST http://localhost:8000/api/v1/chat/stream \
  -H "X-API-Key: test-key" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Test",
    "project_id": "test-project",
    "history": [
      {"role": "user", "content": "Message 1"},
      ...
      {"role": "user", "content": "Message 101"}
    ]
  }'

# Expected: 400 Bad Request
# Body: {"detail": "Chat history exceeds maximum length (100 messages)..."}
```

---

### Step 3: Acceptance Test (Accept Valid)

```bash
# Test that backend accepts 50 messages (< 100)
curl -X POST http://localhost:8000/api/v1/chat/stream \
  -H "X-API-Key: test-key" \
  -H "Content-Type: application/json" \
  -d '{
    "message": "Test",
    "project_id": "test-project",
    "history": [
      {"role": "user", "content": "Message 1"},
      ...
      {"role": "user", "content": "Message 50"}
    ]
  }'

# Expected: 200 OK + SSE stream
```

---

### Step 4: Verify Frontend Sends History

**Open Flutter app and send message, observe logs:**

```
# In backend terminal:
docker-compose logs -f backend

# Expected output:
📤 Sending 50 history messages to backend
✅ Chat request validated: 50 history messages
```

---

### Step 5: Performance Test

**Latency benchmark with different configurations:**

```bash
# Test 1: Small context (30 messages, 10K chars)
CHAT_MAX_HISTORY_MESSAGES=30 CHAT_MAX_MESSAGE_LENGTH=10000 \
  time curl -X POST http://localhost:8000/api/v1/chat/stream \
    -d '{"message":"test","project_id":"1"}' | head -n 1

# Test 2: Medium context (100 messages, 20K chars) - Default
time curl -X POST http://localhost:8000/api/v1/chat/stream \
  -d '{"message":"test","project_id":"1"}' | head -n 1

# Test 3: Large context (200 messages, 30K chars)
CHAT_MAX_HISTORY_MESSAGES=200 CHAT_MAX_MESSAGE_LENGTH=30000 \
  time curl -X POST http://localhost:8000/api/v1/chat/stream \
    -d '{"message":"test","project_id":"1"}' | head -n 1

# Compare latencies:
# Small: ~500ms
# Medium: ~1.5s (acceptable)
# Large: ~4s (high but needed for context)
```

---

## 📚 References

### Related Files

**Configuration:**
- `src/server/app/core/config.py` - Settings class (defaults)
- `src/server/.env.example` - Template with documentation
- `infrastructure/docker-compose.yml` - Env vars mapping

**Validation:**
- `src/server/app/domain/schemas/chat.py` - Dynamic validators
- `tests/server/unit/domain/schemas/test_chat_history.py` - Limits tests

**Frontend:**
- `src/client/lib/features/chat/data/repositories/chat_repository_impl.dart` - History loading

### Related Documentation

- [RECENT_CHANGES.md](./RECENT_CHANGES.md) - Phase 6 & 7 summary
- [PROGRESS.md](./PROGRESS.md) - Detailed implementation tracking
- [ARTIFACTS.md](./ARTIFACTS.md) - Modified files list
- [README.md](./README.md) - Complete HU-4.4 overview

### Commits

- **Phase 6:** `01eec76` - feat(backend): add chat history support for conversational context
- **Phase 7:** `3786589` - feat(chat): make history limits configurable via environment variables

---

</div>
