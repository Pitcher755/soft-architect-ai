# 🐋 Docker Compose Setup Guide - SoftArchitect AI

> **Last Updated:** 28 de enero de 2026
> **Estado:** ✅ Production Ready
> **Pruebaed On:** Linux (Ubuntu 22.04), Windows (WSL2), macOS (M1/Intel)

---

## 📋 Tabla de Contenidos

1. [Requisitos Previos](#requisitos-previos)
2. [Instalación Rápida](#instalación-rápida)
3. [Modos de Ejecución](#modos-de-ejecución)
4. [Verificación de Servicios](#verificación-de-servicios)
5. [Troubleshooting](#troubleshooting)
6. [Performance Tuning](#performance-tuning)
7. [Arquitectura Detallada](#arquitectura-detallada)

---

## ✅ Requisitos Previos

### Hardware Mínimo

```yaml
CPU: 2 cores (4 cores recomendado)
RAM: 8GB (4GB Ollama + 2GB ChromaDB + 2GB Sistema)
Disco: 20GB libres (10GB Ollama + 5GB Docker overhead + 5GB caché)
GPU: Opcional (NVIDIA CUDA 11.8+ para acelerar Ollama)
```

### Software Requerido

```bash
# Docker Desktop o Docker Engine + Docker Compose
docker --version
# Expected: Docker version 24.0.0 or higher

docker compose version
# Expected: Docker Compose version 2.20.0 or higher
```

**Instalación:**

- **Linux:** `curl -fsSL https://get.docker.com | sh`
- **macOS/Windows:** [Docker Desktop](https://www.docker.com/products/docker-desktop/)

### GPU NVIDIA (Opcional pero Recomendado)

Si tienes GPU NVIDIA, descomenta en `docker-compose.yml`:

```yaml
# En servicio ollama:
deploy:
  resources:
    reservations:
      devices:
        - driver: nvidia
          count: 1
          capabilities: [gpu]
```

**Instalación NVIDIA Container Toolkit:**

```bash
# Linux
distribution=$(. /etc/os-release;echo $ID$VERSION_ID)
curl -fsSL https://nvidia.github.io/nvidia-docker/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-docker-keyring.gpg
sudo apt-get install -y nvidia-docker2 && sudo systemctl restart docker

# Verify
docker run --rm --gpus all nvidia/cuda:12.0.0-runtime-ubuntu22.04 nvidia-smi
```

---

## 🚀 Instalación Rápida

### Paso 1: Clonar Repositorio

```bash
git clone https://github.com/Pitcher755/soft-architect-ai.git
cd soft-architect-ai
```

### Paso 2: Crear Archivos de Configuración

```bash
# En infrastructure/
cd infrastructure
cp .env.example .env

# En src/server/
cd ../src/server
cp .env.example .env
```

Editar ambos `.env` según tu preferencia (defaults funcionan para desarrollo local).

### Paso 3: Iniciar Servicios

```bash
cd infrastructure
docker compose up --build
```

**Esperado:**
- Ollama descargará modelo (2-5 minutos, ~5GB)
- ChromaDB se iniciará (~10s)
- FastAPI estará listo (~5s)

### Paso 4: Verificar

```bash
# En otra terminal
curl http://localhost:8000/api/v1/health
# Expected: {"status":"OK","message":"SoftArchitect AI backend is running","version":"0.1.0"}

# Swagger UI
open http://localhost:8000/docs
# Expected: Interactive API documentation
```

---

## 🎛️ Modos de Ejecución

### Modo 1: Desarrollo (Hot-Reload)

```bash
cd infrastructure
docker compose up
```

**Características:**
- ✅ Hot-reload de código Python (cambios se reflejan al guardar)
- ✅ Logs en vivo en terminal
- ✅ Debug mode activado
- ❌ No recomendado para producción

### Modo 2: Desarrollo en Background

```bash
docker compose up -d

# Ver logs
docker compose logs -f api-server

# Ver logs solo de Ollama
docker compose logs -f ollama
```

### Modo 3: Producción (Detached)

```bash
# 1. Editar .env: DEBUG=False, IRON_MODE=True
# 2. Iniciar en background
docker compose up -d

# 3. Verificar estado
docker compose ps

# 4. Ver logs en caso de problemas
docker compose logs

# 5. Detener servicios
docker compose down
```

### Modo 4: Rebuild Completo (Limpiar Cache)

```bash
# Detener y remover contenedores + volúmenes
docker compose down -v

# Eliminar imágenes (para actualizar)
docker rmi sa_api

# Reconstruir
docker compose up --build
```

---

## 🔍 Verificación de Servicios

### Verificar Estado

```bash
# Ver estado de todos los servicios
docker compose ps

# Salida esperada:
# NAME           IMAGE                    STATUS
# sa_ollama      ollama/ollama:latest     Up (healthy)
# sa_chromadb    chromadb/chroma:latest   Up (healthy)
# sa_api         sa_api:latest            Up (healthy)
```

### Logs por Servicio

```bash
# API (la más importante)
docker compose logs api-server --tail 50

# Ollama (ver descargas de modelo)
docker compose logs ollama --tail 50

# ChromaDB
docker compose logs chromadb --tail 50

# Todos
docker compose logs --tail 100
```

### Health Checks

```bash
# API
curl -s http://localhost:8000/api/v1/health | jq .

# Ollama
curl -s http://localhost:11434/api/status | jq .

# ChromaDB (requiere expose del puerto)
curl -s http://localhost:8000 | jq .
```

### Acceso a Contenedores

```bash
# Entrar en shell del API
docker compose exec api-server bash

# Ver variables de ambiente
docker compose exec api-server env | grep -i llm

# Ver SQLite en vivo
docker compose exec api-server sqlite3 /app/data/softarchitect.db ".tables"

# Entrar en Ollama
docker compose exec ollama bash
# Ver modelos descargados: ollama list
```

---

## 🐛 Troubleshooting

### Problema 1: "Cannot connect to Docker daemon"

```bash
# Solución:
sudo systemctl start docker  # Linux
# o abrir Docker Desktop (macOS/Windows)

# Verify
docker ps
```

### Problema 2: "Port 8000 already in use"

```bash
# Encontrar qué está usando puerto 8000
lsof -i :8000  # macOS/Linux
netstat -ano | findstr :8000  # Windows

# Opción A: Cambiar puerto en docker-compose.yml
ports:
  - "8001:8000"  # Ahora será http://localhost:8001

# Opción B: Matar proceso existente
kill -9 <PID>
```

### Problema 3: "Ollama out of memory"

```bash
# Síntoma: Ollama crashea al procesar requests

# Solución 1: Aumentar mem_limit
# En docker-compose.yml, sección deploy de ollama:
memory: 4GB  # o más

# Solución 2: Usar modelo más pequeño
OLLAMA_MODEL=qwen2.5-coder:1.5b  # vs 7b

# Solución 3: Verificar que tengas espacio en disco
docker system df
```

### Problema 4: "ChromaDB connection refused"

```bash
# Síntoma: API no conecta a ChromaDB

# Solución 1: Verificar que ChromaDB esté listo
docker compose logs chromadb

# Solución 2: Reiniciar ChromaDB
docker compose restart chromadb

# Solución 3: Revisar variables de ambiente
docker compose exec api-server env | grep -i chroma
# CHROMA_HOST debe ser "chromadb", CHROMA_PORT "8000"
```

### Problema 5: "Connection refused to Ollama"

```bash
# Síntoma: API falla con "Cannot connect to Ollama:11434"

# Verificar Ollama está corriendo
docker compose exec api-server curl http://ollama:11434/api/status

# Si falla, revisar logs
docker compose logs ollama

# Reiniciar
docker compose restart ollama
```

### Problema 6: "ModuleNotFoundError: No module named 'app'"

```bash
# Síntoma: API crashea en startup

# Causa: El COPY en Dockerfile no funciona bien

# Solución:
# 1. Verificar que requirements.txt existe en src/server/
# 2. Rebuild:
docker compose up --build

# 3. Verificar dentro del contenedor:
docker compose exec api-server ls -la /app/app/main.py
```

### Problema 7: "NVIDIA Container ejecutartime not found"

```bash
# Si descomentas la sección GPU pero no tienes driver instalado

# Opción A: Instalar NVIDIA Container Toolkit (recomendado)
# https://docs.nvidia.com/datacenter/cloud-native/container-toolkit/

# Opción B: Comentar GPU config (volver a CPU-only)
# En docker-compose.yml, comentar:
# devices:
#   - driver: nvidia
```

---

## ⚡ Performance Tuning

### RAM Eficiente (para máquinas limitadas)

```yaml
# docker-compose.yml
services:
  ollama:
    deploy:
      resources:
        limits:
          memory: 1.5GB  # Redacir de 2GB
  chromadb:
    deploy:
      resources:
        limits:
          memory: 256MB  # OK para mayoria
  api-server:
    deploy:
      resources:
        limits:
          memory: 256MB  # Reducir de 512MB

# .env
OLLAMA_MODEL=qwen2.5-coder:1.5b  # Modelo más pequeño
```

### Máxima Velocidad (máquinas potentes + GPU)

```yaml
# docker-compose.yml
services:
  ollama:
    deploy:
      resources:
        limits:
          memory: 4GB
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
  api-server:
    deploy:
      resources:
        limits:
          memory: 1GB

# .env
OLLAMA_MODEL=mistral:7b  # Mejor balance velocidad/quality
LLM_PROVIDER=cloud  # Considerar Groq si necesitas <1s
```

### Diagnóstico de Recursos

```bash
# Ver uso real de Docker
docker stats

# Output:
# CONTAINER       CPU %    MEM USAGE / LIMIT
# sa_ollama       45.2%    1.8GB / 2GB
# sa_chromadb     0.2%     45MB / 512MB
# sa_api          0.1%     120MB / 512MB
```

---

## 🏗️ Arquitectura Detallada

### Flujo de Datos

```
┌─────────────────┐
│  Flutter App    │
│  (localhost)    │
└────────┬────────┘
         │ HTTP
         ▼
┌─────────────────────────┐
│   FastAPI Backend       │
│   (Port 8000)           │
│   - API Routes          │
│   - RAG Orchestration   │
│   - Auth                │
└────────┬────────────────┘
         │         │
         │ Network │
    ┌────┴─────────┴──┐
    │   sa_network    │
    │  (172.25.0.0/16)│
    └────┬─────────┬──┘
         │         │
    ┌────▼──┐  ┌───▼────┐
    │ Ollama │  │ChromaDB│
    │ :11434 │  │ :8000  │
    └────────┘  └────────┘
         │         │
    ┌────▼──────────▼───┐
    │  Docker Volumes    │
    │ - ollama_storage   │
    │ - chroma_storage   │
    └────────────────────┘
```

### Stack de Puertos

| Servicio   | Puerto | Acceso        | Propósito |
|-----------|--------|---------------|-----------|
| API       | 8000   | Host + Network | REST API + Swagger |
| Ollama    | 11434  | Network only  | LLM inference |
| ChromaDB  | 8000   | Network only  | Vector DB API |

### Volúmenes

| Volumen | Ubicación | Tamaño | Contenido |
|---------|-----------|--------|-----------|
| ollama_storage | `/root/.ollama` | ~5-10GB | Modelos descargados |
| chroma_storage | `/chroma/chroma` | ~100-500MB | Embeddings indexados |
| logs | `./logs` | Variable | Logs de aplicación |
| data | `./data` | ~200MB | SQLite DB + caché |

---

## 📚 Referencias

- **AGENTS.md:** Definición de arquitectura del proyecto
- **context/30-ARCHITECTURE/TECH_STACK_DETAILS.es.md:** Stack tecnológico
- **src/server/README.md:** Documentoación de backend
- **Docker Compose Docs:** https://docs.docker.com/compose/
- **Ollama Docs:** https://ollama.ai
- **ChromaDB Docs:** https://docs.trychroma.com

---

## 🤝 Soporte

Si encuentras problemas:

1. **Revisa los logs:** `docker compose logs`
2. **Consulta Troubleshooting arriba**
3. **Abre issue en GitHub:** https://github.com/Pitcher755/soft-architect-ai/issues
4. **Contacta al equipo:** team@softarchitect.ai

---

**Happy Coding! 🚀**
