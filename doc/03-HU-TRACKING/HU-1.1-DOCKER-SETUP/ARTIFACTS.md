# 📦 HU-1.1: Artifacts (Archivos a Generar)

> **Documentación:** Archivos que se crearán durante la ejecución de esta HU

---

## 📋 LISTA DE ARTIFACTS

### 🐳 Infrastructure (docker-compose.yml)

| Archivo | Ubicación | Descripción | Status |
|---------|-----------|-------------|--------|
| `docker-compose.yml` | `infrastructure/` | Orquestación de 3 servicios (API, ChromaDB, Ollama) | ⏳ Pendiente |
| `pre_check.py` | `infrastructure/` | Script para validar pre-requisitos (Docker, puertos) | ⏳ Pendiente |
| `verify_setup.py` | `infrastructure/` | Script para validar que servicios están online | ⏳ Pendiente |
| `.dockerignore` | `infrastructure/` | Archivo para limpiar contexto Docker | ⏳ Pendiente |

### 🔧 Backend (src/server)

| Archivo | Ubicación | Descripción | Status |
|---------|-----------|-------------|--------|
| `Dockerfile` | `src/server/` | Multi-stage build, non-root user, healthchecks | ⏳ Revisar/Mejorar |
| `.dockerignore` | `src/server/` | Previene leaks de secretos y basura | ⏳ Pendiente |

### 🚀 Scripts de Orquestación (raíz)

| Archivo | Ubicación | Descripción | Status |
|---------|-----------|-------------|--------|
| `start_stack.sh` | raíz | Script para arrancar todo el stack | ⏳ Pendiente |
| `stop_stack.sh` | raíz | Script para detener stack limpiamente | ⏳ Pendiente |

### ⚙️ Configuración (.env)

| Archivo | Ubicación | Descripción | Status |
|---------|-----------|-------------|--------|
| `.env.example` | raíz | Template de variables de entorno | ⏳ Mejorar |

### 📚 Documentación

| Archivo | Ubicación | Descripción | Status |
|---------|-----------|-------------|--------|
| `SETUP_GUIDE.es.md` | `doc/02-SETUP_DEV/` | Instrucciones de instalación (actualizar) | ⏳ Actualizar |
| `DOCKER_COMPOSE_GUIDE.es.md` | `doc/02-SETUP_DEV/` | Guía detallada de Docker (referencia) | ✅ Existe |
| `README.md` | raíz | Quick Start (actualizar) | ⏳ Actualizar |
| `DOCKER_SETUP_LOG.md` | `doc/01-PROJECT_REPORT/` | Log de completitud de HU-1.1 | ⏳ Pendiente |

### 📊 Directorios Creados

| Directorio | Propósito | Status |
|-----------|----------|--------|
| `infrastructure/data/chromadb/` | Persistencia de ChromaDB | ✅ Creado |
| `infrastructure/data/ollama/` | Persistencia de Ollama models | ✅ Creado |
| `tests/integration/` | Tests de integración | ✅ Creado |
| `src/server/docker/` | Configuración Docker adicional | ✅ Creado |
| `doc/03-HU-TRACKING/HU-1.1-DOCKER-SETUP/` | Documentación de esta HU | ✅ Creado |

---

## 📝 FORMATO DE ARCHIVOS

### docker-compose.yml

**Estructura esperada:**
```yaml
version: '3.9'

services:
  api-server:      # FastAPI backend
  chromadb:        # Vector database
  ollama:          # LLM engine

networks:
  sa_network:      # Bridge network

volumes:
  chromadb_data:   # Named volumes
  ollama_data:
```

**Validación:**
- ✅ YAML válido
- ✅ 3 servicios orquestados
- ✅ Network bridge creado
- ✅ Volúmenes nombrados
- ✅ Healthchecks configurados
- ✅ Puertos expuestos (8000, 8001, 11434)

---

### pre_check.py

**Funcionalidad:**
```python
✅ check_docker_installed()      # ¿Docker está instalado?
✅ check_docker_running()        # ¿Docker daemon corre?
✅ check_port_available(8000)    # ¿Puerto API disponible?
✅ check_port_available(8001)    # ¿Puerto ChromaDB disponible?
✅ check_port_available(11434)   # ¿Puerto Ollama disponible?
✅ check_env_file()              # ¿.env existe?
```

**Resultado:**
- 🔴 FALLA AHORA (antes de implementar)
- 🟢 PASA después de setup correcto

---

### verify_setup.py

**Funcionalidad:**
```python
✅ check_docker_services()       # ¿Contenedores están arriba?
✅ check_service_port(8000)      # ¿API responde?
✅ check_service_port(8001)      # ¿ChromaDB responde?
✅ check_service_port(11434)     # ¿Ollama responde?
```

**Resultado:**
- 🔴 FALLA AHORA (servicios no están levantados)
- 🟢 PASA después de `docker compose up`

---

### start_stack.sh

**Flujo:**
```bash
1. Verificar Docker instalado (pre_check.py)
2. Crear .env si no existe (desde .env.example)
3. docker compose up -d --build
4. Esperar 5 segundos
5. Verificar servicios online (verify_setup.py)
6. Mostrar URLs de acceso
```

**Comportamiento:**
- ✅ Script ejecutable
- ✅ Manejo de errores legible
- ✅ Salida con colores (éxito/error)
- ✅ URLs listadas al final

---

### stop_stack.sh

**Flujo:**
```bash
1. docker compose down
2. Confirmar shutdown
3. Recordar que volúmenes persisten
```

---

### Dockerfile (mejorado)

**Características:**
- ✅ Multi-stage build (builder + final)
- ✅ Usuario non-root (appuser)
- ✅ HEALTHCHECK definido
- ✅ Puerto 8000 expuesto
- ✅ PYTHONUNBUFFERED=1
- ✅ PYTHONDONTWRITEBYTECODE=1

---

### .env.example

**Variables incluidas:**
```ini
PROJECT_NAME=SoftArchitect_MVP
ENVIRONMENT=development
BACKEND_PORT=8000
BACKEND_HOST=0.0.0.0
DEBUG=true
LOG_LEVEL=INFO
AI_PROVIDER=ollama
OLLAMA_BASE_URL=http://ollama:11434
OLLAMA_MODEL=qwen2.5-coder:7b
CHROMADB_HOST=chromadb
CHROMADB_PORT=8000
CHROMADB_DATA_PATH=/data/chromadb
IRON_MODE=true
```

---

## 🎯 VALIDACIÓN DE ARTIFACTS

### Pre-Deployment
- [ ] `docker-compose.yml` YAML válido
- [ ] `pre_check.py` ejecutable y documentado
- [ ] `start_stack.sh` ejecutable y documentado
- [ ] `.env.example` contiene todas las variables

### Post-Deployment
- [ ] `verify_setup.py` ejecutable y documentado
- [ ] `stop_stack.sh` ejecutable
- [ ] Documentación (README, SETUP_GUIDE) actualizada
- [ ] DOCKER_SETUP_LOG.md creado

### Code Quality
- [ ] `flake8` sin errores críticos en Python
- [ ] `black` formateado en Python
- [ ] `yamllint` válido en docker-compose.yml
- [ ] Bash scripts con `shellcheck` (opcional)

---

## 📊 MATRIZ DE RESPONSABILIDAD

| Artifact | Owner | Revisor | Status |
|----------|-------|---------|--------|
| docker-compose.yml | DevOps | Backend Lead | ⏳ |
| pre_check.py | DevOps | QA | ⏳ |
| verify_setup.py | DevOps | QA | ⏳ |
| Dockerfile | Backend + DevOps | Arch | ⏳ |
| start_stack.sh | DevOps | Infra | ⏳ |
| Documentación | Technical Writer | PM | ⏳ |

---

**Última Actualización:** 29 de Enero de 2026  
**Status:** 📋 Pendiente de generación
