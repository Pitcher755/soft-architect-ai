# 🧪 Guía de Pruebas E2E: HU-4.4 Conexión Frontend-Backend

> **Fecha:** 17/02/2026
> **Estado:** ✅ Implementación completa
> **Objetivo:** Validar la conexión E2E entre Flutter (ChatPanelWidget) y FastAPI (/api/v1/chat/stream)

---

## 📋 Tabla de Contenidos

- [Prerequisitos](#prerequisitos)
- [Configuración](#configuración)
- [Paso 1: Levantar Backend en Docker](#paso-1-levantar-backend-en-docker)
- [Paso 2: Lanzar Frontend con Backend Real](#paso-2-lanzar-frontend-con-backend-real)
- [Paso 3: Validación Visual](#paso-3-validación-visual)
- [Paso 4: Prueba de Graceful Degradation](#paso-4-prueba-de-graceful-degradation)
- [Troubleshooting](#troubleshooting)
- [Criterios de Aceptación](#criterios-de-aceptación)

---

## Prerequisitos

- ✅ Docker y Docker Compose instalados
- ✅ Flutter SDK (3.10.8+) configurado
- ✅ Código actualizado en branch `feature/rag-llm-resilience`
- ✅ Puerto 8000 disponible (backend API)
- ✅ Puerto 8001 disponible (ChromaDB)
- ✅ Puerto 11434 disponible (Ollama)

---

## Configuración

### Variables de Entorno (Backend)

El backend de Docker ya está configurado en `.env`:

```bash
LLM_PROVIDER=ollama
OLLAMA_BASE_URL=http://sa_ollama:11434
OLLAMA_MODEL=qwen2.5-coder:3b
```

### Variables de Entorno (Frontend)

Para conectar el frontend al backend real, usa:

```bash
# Para pruebas E2E (Backend Real)
flutter run -d linux \
  --dart-define=USE_REAL_BACKEND=true \
  --dart-define=BACKEND_BASE_URL=http://localhost:8000 \
  --dart-define=BACKEND_API_KEY=dev-key

# Para desarrollo sin backend (Mock)
flutter run -d linux
```

---

## Paso 1: Levantar Backend en Docker

```bash
# Iniciar toda la infraestructura (API, ChromaDB, Ollama)
cd /home/pitcherdev/Espacio-de-trabajo/Master/soft-architect-ai
./scripts/devops/start_stack.sh

# Verificar que todos los servicios están healthy
docker ps

# Deberías ver:
# CONTAINER ID   IMAGE                     STATUS
# ...            sa_api                    Up X minutes (healthy)
# ...            sa_chromadb               Up X minutes (healthy)
# ...            sa_ollama                 Up X minutes (healthy)
```

### Validar Backend funcional

```bash
# Test rápido del endpoint de streaming
curl -X POST http://localhost:8000/api/v1/chat/stream \
  -H "Content-Type: application/json" \
  -d '{
    "message": "¿Qué es una API REST?",
    "project_id": "test-project-123",
    "conversation_id": "test-conv-123"
  }' \
  --no-buffer

# Deberías ver eventos SSE:
# event: token
# data: {"token": "Una"}
#
# event: token
# data: {"token": " API"}
# ...
```

---

## Paso 2: Lanzar Frontend con Backend Real

### Opción A: Usando Script Automatizado (Recomendado)

```bash
cd /home/pitcherdev/Espacio-de-trabajo/Master/soft-architect-ai

# Ejecutar script de lanzamiento E2E
./scripts/devops/LAUNCH_FLUTTER_APP_E2E.sh
```

### Opción B: Comando Manual

```bash
cd src/client

flutter run -d linux \
  --dart-define=USE_REAL_BACKEND=true \
  --dart-define=BACKEND_BASE_URL=http://localhost:8000 \
  --dart-define=BACKEND_API_KEY=dev-key
```

### Alternativa: Chrome/Web

```bash
flutter run -d chrome \
  --dart-define=USE_REAL_BACKEND=true \
  --dart-define=BACKEND_BASE_URL=http://localhost:8000 \
  --dart-define=BACKEND_API_KEY=dev-key \
  --web-port=5000
```

---

## Paso 3: Validación Visual

### Prueba 1: Streaming de Mensajes ✅

1. Abrir la aplicación Flutter (Linux Desktop o Chrome)
2. Navegar al panel de chat (lado derecho)
3. Escribir: **"¿Qué es una API REST?"**
4. Presionar el botón de enviar (📤)

**Verificar:**
- ✅ El mensaje del usuario aparece inmediatamente (burbuja azul a la derecha)
- ✅ Aparece una burbuja del asistente (lado izquierdo, vacía al inicio)
- ✅ El texto de la IA se escribe **letra por letra** (efecto máquina de escribir)
- ✅ El mensaje se completa en ~5-10 segundos
- ✅ No hay errores en el banner superior

### Prueba 2: Múltiples Mensajes Consecutivos ✅

1. Enviar: **"Explícame el patrón MVC"**
2. Esperar a que termine la respuesta
3. Enviar: **"¿Cuáles son sus ventajas?"**

**Verificar:**
- ✅ Ambos mensajes se muestran en el historial
- ✅ Cada respuesta se renderiza con streaming
- ✅ El scroll se ajusta automáticamente al último mensaje

### Prueba 3: Manejo de Errores (ErrorEvent) ✅

1. Detener el backend: `docker stop sa_api`
2. Enviar: **"Hola"**

**Verificar:**
- ✅ Aparece un banner rojo en la parte superior del chat
- ✅ El mensaje de error indica problema de conexión
- ✅ El botón de envío sigue habilitado (permite retry)

---

## Paso 4: Prueba de Graceful Degradation

### Escenario: ChromaDB Caído (Fallback Template)

Este es el prueba crítico de **HU-4.4** para validar resiliencia.

```bash
# 1. Detener ChromaDB (simulando fallo de base de datos vectorial)
docker stop sa_chromadb

# 2. En la UI de Flutter, enviar mensaje:
"¿Cómo implementar la fase 2 del proyecto?"

# 3. Verificar comportamiento:
# ✅ HTTP 200 (no 500)
# ✅ Respuesta se renderiza con streaming
# ✅ Banner amarillo (Warning): "⚠️ Respondiendo sin contexto del proyecto"
# ✅ Respuesta genérica (Fallback template, sin fuentes RAG)

# 4. Verificar logs del backend:
docker logs sa_api --tail 20

# Deberías ver:
# WARNING - ⚠️ RAG degraded: vector search failed
# INFO - 🔄 Using FALLBACK template (RAG degraded)

# 5. Restaurar ChromaDB
docker start sa_chromadb
```

**Resultadoado Esperado:**
- El chat **NO se rompe** cuando ChromaDB falla
- El usuario recibe una respuesta (aunque sin contexto del proyecto)
- El sistema continúa operativo (Graceful Degradation ✅)

---

## Troubleshooting

### Error: "Connection refused" al enviar mensaje

**Causa:** Backend no está levantado o puerto incorrecto.

**Solución:**
```bash
# Verificar estado de Docker
docker ps | grep sa_api

# Si no está corriendo:
./scripts/devops/start_stack.sh

# Verificar puertos
netstat -tulpn | grep 8000
```

### Error: "No tokens received" (UI muestra mensaje vacío)

**Causa:** SSE no está siendo parseado correctamente.

**Solución:**
```bash
# Verificar que el backend está enviando eventos SSE
curl -X POST http://localhost:8000/api/v1/chat/stream \
  -H "Content-Type: application/json" \
  -d '{"message":"test","project_id":"test","conversation_id":"test"}' \
  --no-buffer

# Si funciona en curl pero no en Flutter:
# 1. Verificar que USE_REAL_BACKEND=true
# 2. Revisar logs de Flutter: flutter logs
```

### Error: "Type mismatch" en ChatMessage

**Causa:** Conversión incorrecta entre `ChatMessage` (domain) y `ChatMessageUI` (widget).

**Solución:**
Verificar que el método `_toUIMessage()` en `ChatPanelWidget` está convirtiendo correctamente:
```dart
ChatMessageUI _toUIMessage(ChatMessage message) => ChatMessageUI(
  id: message.id,
  role: message.role == MessageRole.user ? 'user' : 'assistant',
  content: message.content,
  timestamp: DateTime.parse(message.timestamp),
  isStreaming: message.isStreaming,
);
```

### La app usa Mock en lugar de Backend Real

**Causa:** Variables de entorno no se pasaron correctamente.

**Solución:**
```bash
# Verificar que las flags están presentes:
flutter run -d linux --verbose \
  --dart-define=USE_REAL_BACKEND=true

# Alternativa: Hardcodear temporalmente en chat_notifier.dart
const bool _useRealBackend = true; // Forzar uso de backend real
```

---

## Criterios de Aceptación

### ✅ Fase 1: State Management

- [x] `ChatState` tiene `messages`, `isStreaming`, `hasError`, `errorMessage`
- [x] `ChatNotifier.sendMessageStream()` implementado
- [x] `chatNotifierProvider` disponible para widgets

### ✅ Fase 2: UI Integración

- [x] `ChatPanelWidget` convertido a `ConsumerStatefulWidget`
- [x] `ref.watch(chatNotifierProvider)` obtiene mensajes del estado
- [x] Botón de envío llama `ref.read(chatNotifierProvider.notifier).sendMessageStream()`
- [x] `ErrorBannerWidget` se muestra cuando `state.hasError == true`

### ✅ Fase 3: E2E Pruebas

- [x] Backend Docker funcional (sa_api, sa_chromadb, sa_ollama)
- [x] Flutter se conecta a `http://localhost:8000/api/v1/chat/stream`
- [x] Streaming de tokens visible (efecto máquina de escribir)
- [x] Graceful Degradation: ChromaDB down → Fallback template → HTTP 200

---

## 🎯 Validación Final

Si completaste todos los pruebas anteriores con éxito:

```
✅ La conexión E2E está funcional
✅ El streaming SSE está operativo
✅ El Graceful Degradation funciona correctamente
✅ Los códigos de error (DB_ERR_001, RAG_ERR_001) se propagan al UI
✅ HU-4.4 está lista para merge
```

**Siguiente paso:** Ejecutar suite completa de pruebas y Push to GitHub.

```bash
# Ejecutar tests completos
./scripts/testing/PRE_PUSH_VALIDATION_MASTER.sh

# Si todos pasan:
git add .
git commit -m "feat(hu-4.4): complete E2E frontend-backend connection with SSE streaming"
git push origin feature/rag-llm-resilience
```

---

## 📞 Contacto y Soporte

- **Referencia:** HU-4.4 RAG/LLM Resiliencia Extensions
- **Documentoación:** `doc/03-HU-TRACKING/HU-4.4-RAG-LLM-RESILIENCE/`
- **Manual Pruebaing Resultados:** `doc/01-PROJECT_REPORT/MANUAL_TESTING_RESULTS.md`
