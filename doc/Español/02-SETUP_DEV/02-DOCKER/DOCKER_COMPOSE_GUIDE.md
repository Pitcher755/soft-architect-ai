# 🐋 Guía Docker Compose — SoftArchitect AI

> **Última Actualización:** 22 de marzo de 2026
> **Estado:** ✅ Production Ready
> **Probado en:** Linux (Ubuntu 22.04), Windows (WSL2), macOS (M1/Intel)

---

## 📋 Tabla de Contenidos

1. [Requisitos Previos](#requisitos-previos)
2. [.env Centralizado (Raíz del Proyecto)](#env-centralizado-raíz-del-proyecto)
3. [Comandos Esenciales](#comandos-esenciales)
4. [Modos de Ejecución](#modos-de-ejecución)
5. [Verificación de Servicios](#verificación-de-servicios)
6. [Logs y Monitorización](#logs-y-monitorización)
7. [Builds y Reconstrucción](#builds-y-reconstrucción)
8. [Troubleshooting](#troubleshooting)
9. [Arquitectura de Servicios](#arquitectura-de-servicios)

---

## ✅ Requisitos Previos

### Hardware Mínimo

```yaml
CPU: 2 cores (4 recomendado)
RAM: 8 GB (4 GB Ollama + 2 GB ChromaDB + 2 GB Sistema)
Disco: 20 GB libres
GPU: Opcional (NVIDIA CUDA 11.8+ para acelerar Ollama)
```

### Software Requerido

```bash
docker --version        # >= 24.0.0
docker compose version  # >= 2.20.0
```

**Instalación:**

- **Linux:** `curl -fsSL https://get.docker.com | sh`
- **macOS/Windows:** [Docker Desktop](https://www.docker.com/products/docker-desktop/)

---

## 📁 .env Centralizado (Raíz del Proyecto)

> ⚠️ **El `.env` vive en la raíz del repositorio**, NO dentro de `infrastructure/`.
> El archivo `docker-compose.yml` lee las variables con `env_file: ../.env` (un nivel arriba).

### Estructura de archivos

```
soft-architect-ai/          ← RAÍZ DEL REPOSITORIO
├── .env                    ← ✅ Archivo maestro de configuración
├── .env.example            ← ✅ Plantilla pública (sin secretos reales)
└── infrastructure/
    ├── docker-compose.yml  ← Lee env_file: ../.env automáticamente
    └── ...
```

### Crear tu .env desde la plantilla

```bash
# Desde la raíz del repositorio
cp .env.example .env

# Editar si necesitas ajustar valores
# Los defaults funcionan para entorno de desarrollo local
nano .env
```

### Variables clave en .env

```bash
# Proveedor de LLM: ollama | groq | gemini
LLM_PROVIDER=ollama
OLLAMA_MODEL=qwen2.5-coder:3b

# ChromaDB
CHROMADB_HOST=sa_chromadb
CHROMADB_PORT=8000

# FastAPI
DEBUG=True
LOG_LEVEL=DEBUG

# API Keys (solo si usas proveedores cloud)
GROQ_API_KEY=
GEMINI_API_KEY=
```

---

## ⚡ Comandos Esenciales

> Todos los comandos se ejecutan desde la **raíz del repositorio** (`soft-architect-ai/`).
> El parámetro `--env-file .env` es obligatorio cuando se invoca desde la raíz.

### Levantar el stack (detached)

```bash
docker compose --env-file .env -f infrastructure/docker-compose.yml up -d
```

### Detener el stack

```bash
docker compose --env-file .env -f infrastructure/docker-compose.yml down
```

### Ver estado de servicios

```bash
docker compose --env-file .env -f infrastructure/docker-compose.yml ps
```

### Usar el script de automatización (recomendado)

```bash
# El script realiza pre-checks, valida .env, hace pull y levanta el stack
./scripts/devops/start_stack.sh

# Para detener
./scripts/devops/stop_stack.sh
```

---

## 🎛️ Modos de Ejecución

### Modo 1: Desarrollo (logs en vivo)

```bash
docker compose --env-file .env -f infrastructure/docker-compose.yml up
```

- ✅ Logs en vivo en la terminal actual
- ✅ `Ctrl+C` detiene todos los servicios limpiamente

### Modo 2: Background (detached)

```bash
docker compose --env-file .env -f infrastructure/docker-compose.yml up -d
```

- ✅ Libera la terminal
- ✅ Los servicios continúan tras cerrar la terminal

### Modo 3: Rebuild de imágenes

```bash
# Build y arranque con imágenes reconstruidas
docker compose --env-file .env -f infrastructure/docker-compose.yml up --build -d
```

### Modo 4: Build sin caché (limpieza total)

```bash
# Paso 1: Construir sin usar el caché de capas Docker
docker compose --env-file .env -f infrastructure/docker-compose.yml build --no-cache

# Paso 2: Iniciar los servicios
docker compose --env-file .env -f infrastructure/docker-compose.yml up -d
```

> 💡 Úsalo cuando cambias `requirements.txt`, el `Dockerfile`, o dependencias del sistema operativo dentro del contenedor.

### Modo 5: Destrucción total y reconstrucción desde cero

```bash
# ⚠️ El flag -v elimina también los volúmenes (datos de ChromaDB)
docker compose --env-file .env -f infrastructure/docker-compose.yml down -v
docker compose --env-file .env -f infrastructure/docker-compose.yml build --no-cache
docker compose --env-file .env -f infrastructure/docker-compose.yml up -d
```

### Modo 6: Reconstruir solo la API (sin recargar Ollama)

```bash
docker compose --env-file .env -f infrastructure/docker-compose.yml build --no-cache api-server
docker compose --env-file .env -f infrastructure/docker-compose.yml up -d api-server
```

---

## 🔍 Verificación de Servicios

### Estado de contenedores

```bash
docker compose --env-file .env -f infrastructure/docker-compose.yml ps
```

**Salida esperada (todos los servicios `Up (healthy)`):**

```
NAME           IMAGE                    STATUS
sa_api         sa_api:latest            Up (healthy)
sa_chromadb    chromadb/chroma:latest   Up (healthy)
sa_ollama      ollama/ollama:latest     Up (healthy)
```

### Health check del backend

```bash
curl http://localhost:8000/api/v1/health
```

**Respuesta esperada:**

```json
{"status":"OK","message":"SoftArchitect AI backend is running","version":"0.1.0"}
```

### Swagger UI (explorador interactivo de la API)

```
http://localhost:8000/docs
```

### Verificar variables de entorno dentro del contenedor

```bash
# Ver variables relacionadas con LLM
docker exec sa_api env | grep -i llm

# Ver variables de ChromaDB
docker exec sa_api env | grep -i chroma

# Ver modo debug
docker exec sa_api env | grep -i debug
```

### Acceder al shell del contenedor

```bash
# Shell interactivo en el contenedor de la API
docker exec -it sa_api bash

# Shell en ChromaDB
docker exec -it sa_chromadb bash
```

---

## 📋 Logs y Monitorización

### Logs en tiempo real (todos los servicios)

```bash
docker compose --env-file .env -f infrastructure/docker-compose.yml logs -f
```

### Logs solo del backend (sa_api)

```bash
docker logs -f sa_api
```

### Logs del backend con timestamps

```bash
docker logs -f --timestamps sa_api
```

### Logs de ChromaDB

```bash
docker logs -f sa_chromadb
```

### Logs de Ollama

```bash
docker logs -f sa_ollama
```

### Ver últimas N líneas

```bash
docker logs --tail 100 sa_api
docker logs --tail 50  sa_chromadb
docker logs --tail 50  sa_ollama
```

### Filtrar logs por nivel o patrón

```bash
# Solo errores
docker logs -f sa_api 2>&1 | grep -i "error\|exception\|critical"

# Solo peticiones HTTP
docker logs -f sa_api 2>&1 | grep -i "POST\|GET\|DELETE\|PUT"

# Solo log de startup
docker logs sa_api 2>&1 | grep -i "started\|running\|uvicorn"
```

### Monitorización en tiempo real (CPU/RAM/Red)

```bash
# Todos los contenedores del proyecto
docker stats sa_api sa_chromadb sa_ollama

# Solo snapshot (sin refreshing)
docker stats --no-stream sa_api sa_chromadb sa_ollama
```

---

## 🏗️ Builds y Reconstrucción

### Listar imágenes del proyecto

```bash
docker images | grep sa_
```

### Validar la configuración Docker Compose (sin ejecutar)

```bash
docker compose --env-file .env -f infrastructure/docker-compose.yml config
```

### Eliminar imagen de la API para forzar rebuild

```bash
docker rmi sa_api
docker compose --env-file .env -f infrastructure/docker-compose.yml up --build -d
```

### Reiniciar un servicio sin detener el stack

```bash
# Reiniciar solo la API
docker compose --env-file .env -f infrastructure/docker-compose.yml restart api-server

# Reiniciar solo ChromaDB
docker compose --env-file .env -f infrastructure/docker-compose.yml restart chromadb
```

### Limpiar recursos Docker no usados

```bash
# Contenedores detenidos, imágenes huérfanas y redes sin usar
docker system prune -f

# ⚠️ También elimina volúmenes (borra datos de ChromaDB)
docker system prune -f --volumes
```

### Ver uso de espacio Docker

```bash
docker system df
```

---

## 🔧 Troubleshooting

### ❌ "env file .env not found"

```bash
# Causa: ejecutar docker compose desde infrastructure/ sin --env-file
# ✅ Solución A: ejecutar siempre desde la raíz con --env-file .env
docker compose --env-file .env -f infrastructure/docker-compose.yml up -d

# ✅ Solución B: ejecutar desde infrastructure/ con ruta relativa
cd infrastructure
docker compose --env-file ../.env up -d
```

### ❌ "Cannot connect to Docker daemon"

```bash
sudo systemctl start docker    # Linux (systemd)
sudo service docker start      # Linux (init.d)
# macOS/Windows: abrir Docker Desktop
docker ps                      # verificar que responde
```

### ❌ "Port 8000 already in use"

```bash
# Ver qué proceso ocupa el puerto 8000
lsof -i :8000

# Matar ese proceso
kill -9 <PID>

# Alternativa: cambiar el puerto en .env
# API_PORT=8001
```

### ❌ "Ollama out of memory"

```bash
# Opción 1: usar un modelo más ligero en .env
OLLAMA_MODEL=qwen2.5-coder:1.5b

# Opción 2: verificar RAM disponible
docker stats --no-stream
free -h
```

### ❌ "ChromaDB connection refused" desde la API

```bash
# Ver estado y logs de ChromaDB
docker logs sa_chromadb

# Reiniciar solo ChromaDB
docker compose --env-file .env -f infrastructure/docker-compose.yml restart chromadb

# Verificar qué host ve la API en su entorno
docker exec sa_api env | grep CHROMA
```

### ❌ API no arranca (ModuleNotFoundError / ImportError)

```bash
# Rebuild forzado sin caché (soluciona problemas de dependencias)
docker compose --env-file .env -f infrastructure/docker-compose.yml build --no-cache api-server
docker compose --env-file .env -f infrastructure/docker-compose.yml up -d api-server

# Verificar que el código está montado dentro del contenedor
docker exec sa_api ls -la /app/app/main.py
docker exec sa_api pip list | grep fastapi
```

---

## 🏛️ Arquitectura de Servicios

```
soft-architect-ai/              ← Raíz del proyecto
├── .env                        ← Variables maestras (AQUÍ)
└── infrastructure/
    └── docker-compose.yml      ← Orquestación (lee ../. env con env_file)

Red interna Docker: sa_network
┌────────────────────────────────────────────────────┐
│  sa_api       (FastAPI)     localhost:8000          │
│  sa_chromadb  (ChromaDB)    localhost:8001          │
│  sa_ollama    (Ollama LLM)  localhost:11434         │
└────────────────────────────────────────────────────┘

Flujo de datos típico:
  Flutter App → sa_api:8000 → sa_chromadb:8000 (interno)
                            → sa_ollama:11434  (interno)
```

| Servicio | Imagen | Puerto ext. | Puerto int. | Descripción |
|----------|--------|-------------|-------------|-------------|
| `sa_api` | `sa_api:latest` (build local) | `8000` | `8000` | Backend FastAPI |
| `sa_chromadb` | `chromadb/chroma:latest` | `8001` | `8000` | Base de datos vectorial |
| `sa_ollama` | `ollama/ollama:latest` | `11434` | `11434` | Motor LLM local |

---

## 🔗 Referencias

- [Inicio Rápido](../01-INSTALACION/GUIA_INICIO_RAPIDO.md) — Setup completo en 15 minutos
- [Scripts de Automatización](../04-AUTOMATIZACION/AUTOMATIZACION.md) — `start_stack.sh`, `stop_stack.sh`
- [CI/CD Pipeline](../05-CI-CD/) — Validación automática en GitHub Actions
- [infrastructure/docker-compose.yml](../../../../infrastructure/docker-compose.yml) — Archivo fuente de la orquestación
- [.env.example](../../../../.env.example) — Plantilla pública de variables de entorno
