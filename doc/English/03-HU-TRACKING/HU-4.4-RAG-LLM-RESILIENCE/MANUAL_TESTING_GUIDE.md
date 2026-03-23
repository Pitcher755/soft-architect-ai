# 🧪 HU-4.4: Manual Testing Guide - RAG/LLM Resilience Extensions

> **Date:** 16/02/2026
> **Branch:** `feature/rag-llm-resilience`
> **Status:** ✅ Ready for Execution
> **Infraestructura:** Docker (sa_api, sa_chromadb, sa_ollama)

---

## 📋 Tabla de Contenidos

1. [Pre-requisitos](#-pre-requisitos)
2. [Verification de Infraestructura](#-verification-de-infraestructura)
3. [Escenario 1: ChromaDB Down (Graceful Degradation)](#-escenario-1-chromadb-down-graceful-degradation)
4. [Escenario 2: Ollama con Problemas (Retry Logic)](#-escenario-2-ollama-con-problemas-retry-logic)
5. [Escenario 3: ChromaDB Timeout](#-escenario-3-chromadb-timeout-opcional)
6. [Limpieza y Reset](#-limpieza-y-reset)
7. [Interpretación de Results](#-interpretación-de-resultados)

---

## 🔧 Pre-requisitos

### Software Requerido

- Docker Engine 24.x+
- Docker Compose 2.x+
- curl (instalado por defecto en Linux)
- jq (opcional - para formatear JSON): `sudo apt-get install jq`

### Infraestructura Docker

**Servicios:**
- `sa_api` (FastAPI Backend) - Puerto: **8000**
- `sa_chromadb` (ChromaDB Vector DB) - Puerto: **8001** (host) → 8000 (container)
- `sa_ollama` (Ollama LLM Engine) - Puerto: **11434**

**Red interna:** `infrastructure_sa_network`

**Dependencias:**
- `sa_api` depende de `sa_chromadb` y `sa_ollama` (healthcheck)
- Comunicación interna: `http://chromadb:8000`, `http://ollama:11434`

---

## ✅ Verification de Infraestructura

**Execute ANTES de empezar los tests:**

### 1.1 Levantar Stack Completo

```bash
cd /home/pitcherdev/Espacio-de-trabajo/Master/soft-architect-ai

# Levantar todos los servicios
docker compose --env-file .env -f infrastructure/docker-compose.yml up -d

# Esperar ~10 segundos para healthchecks
sleep 10
```

**Salida esperada:**
```
[+] Running 4/4
 ✔ Network infrastructure_sa_network Created
 ✔ Container sa_ollama               Healthy
 ✔ Container sa_chromadb             Healthy
 ✔ Container sa_api                  Created
```

---

### 1.2 Verificar Status de Contenedores

```bash
docker ps --filter "name=sa_" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"
```

**Salida esperada (todos "Up"):**
```
NAMES         STATUS                    PORTS
sa_api        Up 5 seconds              0.0.0.0:8000->8000/tcp
sa_chromadb   Up 8 seconds (healthy)    0.0.0.0:8001->8000/tcp
sa_ollama     Up 10 seconds (healthy)   0.0.0.0:11434->11434/tcp
```

**✅ CRITERIO:** Los 3 contenedores deben estar "Up" y `sa_chromadb` + `sa_ollama` con status "(healthy)".

---

### 1.3 Verificar Conectividad de Servicios

```bash
# Test 1: API Backend (GET /api/v1/system/health)
curl -s http://localhost:8000/api/v1/system/health | jq .

# Test 2: ChromaDB (GET /api/v1/heartbeat)
curl -s http://localhost:8001/api/v1/heartbeat

# Test 3: Ollama (GET /)
curl -s http://localhost:11434 | head -5
```

**Salida esperada:**

**Test 1 (API):**
```json
{
  "status": "ok",
  "version": "0.1.0",
  "timestamp": "2026-02-16T20:57:18.000Z"
}
```

**Test 2 (ChromaDB):**
```json
{"nanosecond heartbeat": 1708115838000000000}
```

**Test 3 (Ollama):**
```
Ollama is running
```

**✅ CRITERIO:** Los 3 endpoints deben responder correctamente.

---

### 1.4 Verificar Logs de sa_api (Baseline)

```bash
docker logs sa_api --tail 20
```

**Salida esperada (sin errores):**
```
INFO:     Started server process [1]
INFO:     Waiting for application startup.
2026-02-16 20:57:17,657 - app.main - INFO - Starting SoftArchitect AI v0.1.0
2026-02-16 20:57:17,657 - app.main - INFO - ChromaDB initialized at data/chromadb
2026-02-16 20:57:17,657 - app.main - INFO - SQLite initialized at sqlite:///data/softarchitect.db
2026-02-16 20:57:17,657 - app.main - INFO - LLM Provider: local
2026-02-16 20:57:17,657 - app.main - INFO - Ollama URL: http://ollama:11434
INFO:     Application startup complete.
INFO:     Uvicorn running on http://0.0.0.0:8000 (Press CTRL+C to quit)
```

**✅ CRITERIO:** No debe haber líneas con "ERROR" o "CRITICAL" en el log.

---

## 🧪 Escenario 1: ChromaDB Down (Graceful Degradation)

### 🎯 Objetivo

Validar que el sistema **continúa funcionando** cuando ChromaDB falla, aplicando graceful degradation:
- ✅ Chat responde sin error 500
- ✅ Log muestra WARNING (no ERROR)
- ✅ Response usa template FALLBACK (sin contexto RAG)
- ✅ Usuario NO percibe error crítico

---

### 1.1 Preparación: Detener ChromaDB

```bash
# Detener SOLO ChromaDB (mantener API y Ollama corriendo)
docker stop sa_chromadb

# Verificar que solo ChromaDB esté detenido
docker ps --filter "name=sa_" --format "table {{.Names}}\t{{.Status}}"
```

**Salida esperada:**
```
NAMES         STATUS
sa_api        Up 2 minutes
sa_ollama     Up 2 minutes (healthy)
```

**⚠️ NOTA:** `sa_chromadb` NO debe aparecer en la lista (está detenido).

---

### 1.2 Ejecución: Enviar Mensaje de Chat

```bash
# Enviar POST /api/v1/chat/message (sin streaming)
curl -X POST http://localhost:8000/api/v1/chat/message \
  -H "Content-Type: application/json" \
  -d '{
    "message": "¿Cómo implementar la fase 2 del proyecto?",
    "project_id": "test-project-001"
  }' \
  -v 2>&1 | tee /tmp/scenario1_response.log

# Guardar solo el body (para análisis posterior)
curl -X POST http://localhost:8000/api/v1/chat/message \
  -H "Content-Type: application/json" \
  -d '{
    "message": "¿Cómo implementar la fase 2 del proyecto?",
    "project_id": "test-project-001"
  }' \
  -s | jq . > /tmp/scenario1_body.json
```

**Salida esperada (HTTP Status):**
```
< HTTP/1.1 200 OK
< content-type: application/json
```

**⚠️ NO debe ser:**
- `HTTP/1.1 500 Internal Server Error`
- `HTTP/1.1 503 Service Unavailable`

---

### 1.3 Validación: Verificar Response Body

```bash
# Ver el response completo
cat /tmp/scenario1_body.json
```

**Campos a verificar:**

```json
{
  "message": "...",  // Debe contener respuesta del LLM (aunque sin contexto RAG)
  "project_id": "test-project-001",
  "metadata": {
    "template_used": "FALLBACK",  // ✅ CRÍTICO: Debe ser "FALLBACK"
    "sources": [],                // ✅ CRÍTICO: Debe estar vacío
    "token_count": 100            // Puede variar
  }
}
```

**✅ CRITERIO DE ACEPTACIÓN:**
- [ ] `metadata.template_used` = `"FALLBACK"` (no "CONTEXT_DRIVEN")
- [ ] `metadata.sources` = `[]` (array vacío)
- [ ] `message` contiene texto de respuesta (no está vacío)
- [ ] HTTP Status Code = 200

---

### 1.4 Validación: Verificar Logs de sa_api

```bash
# Ver logs del API en tiempo real (últimas 30 líneas)
docker logs sa_api --tail 30 | grep -E "WARNING|ERROR|RAG|degraded"
```

**Salida esperada (debe contener WARNING, NO ERROR):**
```
2026-02-16 21:05:30,123 - app.services.rag.orchestrator - WARNING - ⚠️ RAG degraded: vector search failed
2026-02-16 21:05:30,150 - app.services.rag.orchestrator - INFO - Using FALLBACK template (no context)
```

**❌ NO debe contener:**
- `ERROR - ChromaDB connection failed` (debe ser WARNING)
- `CRITICAL - ...`
- Stack traces (`Traceback (most recent call last):`)

**✅ CRITERIO DE ACEPTACIÓN:**
- [ ] Log contiene `WARNING - ⚠️ RAG degraded`
- [ ] Log NO contiene `ERROR` o `CRITICAL`
- [ ] Log menciona `FALLBACK template`

---

### 1.5 Revertir: Reiniciar ChromaDB

```bash
# Reiniciar ChromaDB
docker start sa_chromadb

# Esperar 5 segundos para healthcheck
sleep 5

# Verificar que está "healthy"
docker ps --filter "name=sa_chromadb" --format "table {{.Names}}\t{{.Status}}"
```

**Salida esperada:**
```
NAMES         STATUS
sa_chromadb   Up 3 seconds (healthy)
```

---

### 1.6 Regression Test: Chat Funciona con ChromaDB Activo

```bash
# Enviar mensaje nuevamente (ahora con ChromaDB activo)
curl -X POST http://localhost:8000/api/v1/chat/message \
  -H "Content-Type: application/json" \
  -d '{
    "message": "¿Qué es Clean Architecture?",
    "project_id": "test-project-002"
  }' \
  -s | jq .metadata.template_used
```

**Salida esperada:**
```
"CONTEXT_DRIVEN"
```

**✅ CRITERIO:** Con ChromaDB activo, debe usar `CONTEXT_DRIVEN` (no FALLBACK).

---

## 🔄 Escenario 2: Ollama con Problemas (Retry Logic)

### 🎯 Objetivo

Validar que el sistema **reintenta automáticamente** cuando Ollama falla temporalmente:
- ✅ Request eventual success tras retries
- ✅ Log muestra `⚠️ Retry attempt X/3`
- ✅ Usuario recibe respuesta (puede tardar más, pero no falla)

---

### 2.1 Preparación: Generar Carga de Requests

```bash
# Crear script de testing (envía 3 requests concurrentes)
cat > /tmp/test_ollama_retry.sh << 'EOF'
#!/bin/bash
echo "🔄 Enviando 3 requests concurrentes al API..."

for i in {1..3}; do
  (
    echo "[Request $i] Iniciando..."
    START_TIME=$(date +%s)

    RESPONSE=$(curl -X POST http://localhost:8000/api/v1/chat/message \
      -H "Content-Type: application/json" \
      -d "{\"message\":\"Test retry $i\",\"project_id\":\"test\"}" \
      -s -w "\n%{http_code}" -o /tmp/ollama_test_${i}.json)

    HTTP_CODE=$(echo "$RESPONSE" | tail -1)
    END_TIME=$(date +%s)
    DURATION=$((END_TIME - START_TIME))

    echo "[Request $i] HTTP $HTTP_CODE - Duration: ${DURATION}s"

    if [ "$HTTP_CODE" = "200" ]; then
      echo "[Request $i] ✅ SUCCESS"
    else
      echo "[Request $i] ❌ FAILED"
      cat /tmp/ollama_test_${i}.json
    fi
  ) &
done

wait
echo "✅ Todas las requests completadas"
EOF

chmod +x /tmp/test_ollama_retry.sh
```

---

### 2.2 Ejecución: Simular Fallo Transiente de Ollama

**Opción A: Reinicio Rápido (Recomendado)**

```bash
# Terminal 1: Ejecutar el script de testing
/tmp/test_ollama_retry.sh

# Terminal 2 (EN OTRA VENTANA): Detener y reiniciar Ollama rápidamente
docker restart sa_ollama
```

**Timing crítico:** Execute `docker restart sa_ollama` **mientras** el script de testing está corriendo.

---

**Opción B: Detener Ollama Manualmente (Más Controlado)**

```bash
# Terminal 1: Detener Ollama
docker stop sa_ollama

# Terminal 2: Ejecutar script de testing (fallará primera vez)
/tmp/test_ollama_retry.sh &

# Terminal 1: Esperar 2 segundos y reiniciar Ollama
sleep 2 && docker start sa_ollama
```

---

### 2.3 Validación: Verificar Retries en Logs

```bash
# Ver logs de sa_api buscando retry attempts
docker logs sa_api --tail 50 | grep -E "Retry|retry|attempt"
```

**Salida esperada (SI hubo retries):**
```
2026-02-16 21:15:42,123 - app.infrastructure.llm.ollama_client - WARNING - ⚠️ Retry attempt 1/3: Connection to Ollama failed
2026-02-16 21:15:43,200 - app.infrastructure.llm.ollama_client - WARNING - ⚠️ Retry attempt 2/3: Connection to Ollama failed
2026-02-16 21:15:45,350 - app.infrastructure.llm.ollama_client - INFO - ✅ LLM call succeeded after 3 attempts
```

**⚠️ NOTA:** Si Ollama no experimentó fallos transientes, NO verás logs de retry (esto es normal). El retry solo se activa cuando hay errores reales.

**✅ CRITERIO DE ACEPTACIÓN:**
- [ ] Si hay retries: Log muestra `⚠️ Retry attempt X/3`
- [ ] Si hay retries: Log muestra eventual success `✅ succeeded after X attempts`
- [ ] Si NO hay retries: Requests completaron exitosamente (HTTP 200) sin fallos

---

### 2.4 Validación: Verificar HTTP Status Codes

```bash
# Ver resultados de las 3 requests
for i in {1..3}; do
  echo "=== Request $i ==="
  cat /tmp/ollama_test_${i}.json | jq -r '.message' | head -3
  echo ""
done
```

**✅ CRITERIO DE ACEPTACIÓN:**
- [ ] Al menos 2 de 3 requests deben tener HTTP 200
- [ ] Los response bodies contienen mensajes válidos (no errors)

---

### 2.5 Regression Test: Ollama Funciona Correctamente

```bash
# Verificar que Ollama está activo y respondiendo
docker ps --filter "name=sa_ollama" --format "table {{.Names}}\t{{.Status}}"

# Test simple
curl -s http://localhost:11434 | head -1
```

**Salida esperada:**
```
NAMES         STATUS
sa_ollama     Up 2 minutes (healthy)

Ollama is running
```

**✅ CRITERIO:** Ollama debe estar "healthy" y respondiendo.

---

## ⏱️ Escenario 3: ChromaDB Timeout (Opcional)

### 🎯 Objetivo

Validar que RAG operations tienen **timeout de 30s** y NO esperan indefinidamente.

**⚠️ NOTA:** Este escenario está **completamente cubierto** por unit tests (`test_orchestrator_applies_30s_timeout_to_rag_search`). Ejecución manual es **OPCIONAL**.

---

### 3.1 Verification Automática (Recomendado)

```bash
# Ejecutar unit test específico que valida timeout
cd /home/pitcherdev/Espacio-de-trabajo/Master/soft-architect-ai

# Activar venv Python
source venv/bin/activate

# Ejecutar test de timeout
pytest tests/server/unit/services/rag/test_orchestrator_degradation.py::test_orchestrator_applies_30s_timeout_to_rag_search -v
```

**Salida esperada:**
```
tests/server/unit/services/rag/test_orchestrator_degradation.py::test_orchestrator_applies_30s_timeout_to_rag_search PASSED [100%]
```

**✅ CRITERIO DE ACEPTACIÓN:**
- [ ] Test pasa (PASSED)
- [ ] Coverage confirma timeout está implementado

**👉 SI EL TEST PASA:** Escenario 3 está validado. **NO es necesario testing manual**.

---

## 🧹 Limpieza y Reset

### Resetear Infraestructura Completa

```bash
# Detener todos los contenedores
docker compose --env-file .env -f infrastructure/docker-compose.yml down

# Eliminar logs temporales
rm -f /tmp/scenario1_*.{log,json} /tmp/ollama_test_*.json /tmp/test_ollama_retry.sh

# Re-levantar stack limpio
docker compose --env-file .env -f infrastructure/docker-compose.yml up -d

# Verificar estado
docker ps --filter "name=sa_"
```

---

## 📊 Interpretación de Results

### ✅ Criterios de Aceptación Finales

| # | Escenario | Criterio | Status |
|---|-----------|----------|---------|
| **1.1** | ChromaDB Down | HTTP 200 recibido | ☐ |
| **1.2** | ChromaDB Down | `template_used` = "FALLBACK" | ☐ |
| **1.3** | ChromaDB Down | `sources` = [] (vacío) | ☐ |
| **1.4** | ChromaDB Down | Log muestra WARNING (no ERROR) | ☐ |
| **1.5** | ChromaDB Down | Regression: funciona con ChromaDB activo | ☐ |
| **2.1** | Ollama Retry | Requests completan exitosamente (HTTP 200) | ☐ |
| **2.2** | Ollama Retry | Log muestra retries (si hubo fallos) | ☐ |
| **2.3** | Ollama Retry | Regression: Ollama funciona correctamente | ☐ |
| **3.1** | Timeout | Unit test pasa (PASSED) | ☐ |

**🎉 HU-4.4 VALIDACIÓN COMPLETA:** Si todos los criterios están marcados ✅, la feature está lista para merge.

---

## 📝 Notas para el Tester

### Logging de Results

**Guardar evidencias en cada escenario:**

```bash
# Crear directorio de evidencias
mkdir -p /tmp/hu-4.4-test-evidence

# Durante cada test, guardar:
# 1. Response bodies: /tmp/scenario*_body.json
# 2. HTTP headers: /tmp/scenario*_response.log
# 3. Container logs: docker logs sa_api > /tmp/hu-4.4-test-evidence/api_logs.txt

# Al finalizar, comprimir evidencias
tar -czf ~/hu-4.4-manual-test-results.tar.gz /tmp/hu-4.4-test-evidence/
```

### Troubleshooting

**Problema 1: `curl: (7) Failed to connect`**
- **Causa:** Contenedor API no está corriendo
- **Solución:** `docker start sa_api && sleep 5`

**Problema 2: HTTP 503 "AI Engine unreachable"**
- **Causa:** Ollama no está corriendo o no es healthy
- **Solución:** `docker restart sa_ollama && sleep 10`

**Problema 3: HTTP 500 "Knowledge base search failed"**
- **Causa:** ChromaDB falla pero graceful degradation NO se activó
- **Solución:** ❌ **BUG DETECTADO** - Reportar inmediatamente

**Problema 4: No veo logs de retry**
- **Causa:** Ollama respondió exitosamente en el primer intento (no hubo fallos transientes)
- **Solución:** ✅ NORMAL - Retry solo se activa cuando hay errores reales

---

## 🔗 Referencias

- **PROGRESS.md:** Status completo de HU-4.4
- **README.md:** Contexto y GAP analysis de la feature
- **Docker Compose:** `infrastructure/docker-compose.yml`
- **API Endpoints:** `src/server/app/api/v1/chat.py`
- **Unit Tests:** `tests/server/unit/services/rag/test_orchestrator_degradation.py`

---

**👤 Ejecutado por:** [Name del Tester]
**📅 Fecha de ejecución:** [DD/MM/YYYY]
**⏱️ Duración total:** [X minutos]
**✅ Result final:** [PASS / FAIL]
