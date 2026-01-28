# 🚀 Guía Rápida - SoftArchitect AI Funcional

> **Estado:** ✅ **LISTO PARA DESARROLLO**  
> **Fecha:** 28 de Enero de 2026  
> **Resultado:** 18/18 pruebas pasadas (100%)

---

## 📖 Tabla de Contenidos

1. [Iniciar el Proyecto](#iniciar-el-proyecto)
2. [Verificar Servicios](#verificar-servicios)
3. [URLs de Acceso](#urls-de-acceso)
4. [Solución de Problemas](#solución-de-problemas)
5. [Reportes Disponibles](#reportes-disponibles)

---

## 🚀 Iniciar el Proyecto

### Opción 1: Build Completo (Recomendado primera vez)

```bash
cd infrastructure
docker compose up --build
```

**Esperar:** ~30-45 segundos hasta que todos los servicios estén listos

### Opción 2: Iniciar Servicios Existentes

```bash
cd infrastructure
docker compose up
```

### Opción 3: Iniciar en Modo Background

```bash
cd infrastructure
docker compose up -d
```

---

## ✅ Verificar Servicios

### Estado General

```bash
docker ps --filter "name=sa_"
```

**Salida esperada:**
```
NAMES         STATUS                  PORTS
sa_api        ✅ HEALTHY             0.0.0.0:8000->8000/tcp
sa_ollama     ✅ STARTING            11434/tcp
sa_chromadb   ✅ STARTING            8000/tcp
```

### Ver Logs

```bash
# Logs en tiempo real
docker compose logs -f

# Solo API
docker compose logs -f api-server

# Solo Ollama
docker compose logs -f ollama

# Solo ChromaDB
docker compose logs -f chromadb
```

### Ping de Servicios

```bash
# API Health
curl http://localhost:8000/api/v1/health | jq .

# Esperado:
# {
#   "status": "OK",
#   "message": "SoftArchitect AI backend is running",
#   "version": "0.1.0"
# }
```

---

## 🔌 URLs de Acceso

### Backend API

| Servicio | URL | Descripción |
|----------|-----|-------------|
| **API** | http://localhost:8000 | Raíz de la API |
| **Health** | http://localhost:8000/api/v1/health | Estado del backend |
| **Swagger** | http://localhost:8000/docs | Documentación interactiva |
| **ReDoc** | http://localhost:8000/redoc | Documentación alternativa |

### Servicios Internos

| Servicio | Host Interno | Puerto | Descripción |
|----------|---|---|---|
| **Ollama** | ollama (red sa_network) | 11434 | Motor LLM local |
| **ChromaDB** | chromadb (red sa_network) | 8000 | Base de datos vectorial |

### Base de Datos

| BD | Ubicación | Tipo | Persistencia |
|---|---|---|---|
| **SQLite** | `infrastructure/data/softarchitect.db` | Relacional | Volumen Docker |
| **ChromaDB** | `infrastructure/chroma_storage/` | Vectorial | Volumen Docker |
| **Ollama** | `ollama_storage/` | Modelos | Volumen Docker |

---

## 🛑 Detener Servicios

### Pausar (mantiene datos)
```bash
docker compose pause
```

### Reanudar
```bash
docker compose unpause
```

### Detener (elimina contenedores, no datos)
```bash
docker compose down
```

### Limpiar Todo (elimina contenedores, volúmenes, redes)
```bash
docker compose down -v
```

---

## 🐛 Solución de Problemas

### Problema: "Error connecting to docker daemon"

**Solución:**
```bash
# Opción 1: Usar sudo
sudo docker compose up -d

# Opción 2: Agregar usuario a grupo docker (permanente)
sudo usermod -aG docker $USER
newgrp docker
```

### Problema: "Port 8000 already in use"

**Solución:**
```bash
# Ver qué ocupa el puerto
lsof -i :8000

# Matar proceso
kill -9 <PID>

# O mapear a otro puerto en docker-compose.yml:
# ports:
#   - "8001:8000"
```

### Problema: Servicios tardan en iniciar

**Solución Normal:** Ollama y ChromaDB pueden tardar 20-30 segundos. Esperar con paciencia.

```bash
# Monitorear progreso
docker compose logs -f
```

### Problema: API retorna error de conexión a Ollama

**Solución:**
```bash
# Verificar que Ollama corre
docker ps | grep sa_ollama

# Reiniciar Ollama
docker restart sa_ollama

# Revisar logs
docker logs sa_ollama
```

### Problema: ChromaDB se queja de permisos

**Solución:**
```bash
# Asegurar permisos en volumen
sudo chown -R $(id -u):$(id -g) infrastructure/chroma_storage

# Reiniciar
docker compose down
docker compose up -d
```

---

## 📊 Reportes Disponibles

### 1. [FUNCTIONAL_TEST_REPORT.md](../01-PROJECT_REPORT/FUNCTIONAL_TEST_REPORT.md)
- ✅ Resultados completos de pruebas (18 tests)
- ✅ Métricas de rendimiento
- ✅ Validación de cumplimiento
- ✅ 1000+ líneas de detalle

### 2. [INITIAL_SETUP_LOG.es.md](../01-PROJECT_REPORT/INITIAL_SETUP_LOG.es.md)
- ✅ Documentación en español
- ✅ 4 fases de configuración
- ✅ Timeline y diagrama Mermaid
- ✅ 400+ líneas

### 3. [INITIAL_SETUP_LOG.en.md](../01-PROJECT_REPORT/INITIAL_SETUP_LOG.en.md)
- ✅ Documentación en inglés
- ✅ Versión traducida completa
- ✅ 500+ líneas

### 4. [DOCKER_COMPOSE_GUIDE.es.md](./DOCKER_COMPOSE_GUIDE.es.md)
- ✅ Guía completa de Docker
- ✅ Troubleshooting (7 problemas comunes)
- ✅ 500+ líneas

### 5. [DOCKER_COMPOSE_AUDIT.md](../../DOCKER_COMPOSE_AUDIT.md)
- ✅ 12 problemas identificados y resueltos
- ✅ Antes vs después
- ✅ Checklist de cambios

### 6. [DOCKER_VALIDATION_REPORT.md](../../DOCKER_VALIDATION_REPORT.md)
- ✅ Informe final de validación
- ✅ Comparación de estado
- ✅ Métricas de impacto

---

## 📝 Tareas Comunes

### Compilar Frontend

```bash
cd src/client
flutter pub get
flutter analyze
flutter run -d linux
```

### Ejecutar Tests Backend

```bash
cd src/server
python -m pytest

# Con cobertura
python -m pytest --cov=app
```

### Format de Código Python

```bash
cd src/server
black app/
```

### Format de Código Dart

```bash
cd src/client
dart format lib/
```

### Linting Python

```bash
cd src/server
flake8 app/ --max-line-length=120
```

### Type Check Python

```bash
cd src/server
mypy app/ --ignore-missing-imports
```

---

## 🔐 Variables de Entorno

### Infrastructure (infrastructure/.env)

```bash
OLLAMA_IMAGE_VERSION=latest
CHROMADB_IMAGE_VERSION=latest
PYTHON_VERSION=3.12.3
OLLAMA_MEMORY_LIMIT=2GB
CHROMADB_MEMORY_LIMIT=512MB
API_MEMORY_LIMIT=512MB
LLM_PROVIDER=local
OLLAMA_MODEL=qwen2.5-coder:7b
IRON_MODE=True
```

### Server (src/server/.env.example)

Copiar a `src/server/.env` y editar según necesidad:

```bash
cp src/server/.env.example src/server/.env
```

Configuraciones principales:
```bash
DEBUG=False
IRON_MODE=True
LLM_PROVIDER=local
OLLAMA_BASE_URL=http://ollama:11434
GROQ_API_KEY=  # (opcional, para modo Ether)
```

---

## 📊 Arquitectura de la Red Docker

```
┌─────────────────────────────────────────┐
│  Host (Linux/Windows/macOS)             │
│                                         │
│  localhost:8000 ──┐                    │
│                   │                    │
│  ┌─────────────────────────────────┐  │
│  │  Docker Network (sa_network)    │  │
│  │  Subnet: 172.25.0.0/16         │  │
│  │                                 │  │
│  │  ┌──────────────┐               │  │
│  │  │ sa_ollama    │               │  │
│  │  │ 172.25.0.2   │               │  │
│  │  │ :11434       │               │  │
│  │  └──────────────┘               │  │
│  │           ▲                     │  │
│  │           │                     │  │
│  │  ┌──────────────┐  ┌─────────┐ │  │
│  │  │ sa_chromadb  │  │ sa_api  │ │  │
│  │  │ 172.25.0.3   │  │ 172.25. │ │  │
│  │  │ :8000        │  │ 0.4     │ │  │
│  │  └──────────────┘  │ :8000   │ │  │
│  │           ▲        └─────────┘ │  │
│  │           │             ▲      │  │
│  │           └─────────────┘      │  │
│  └─────────────────────────────────┘  │
│                                        │
└─────────────────────────────────────────┘
```

---

## 💾 Volúmenes y Persistencia

### Volúmenes Nombrados

```bash
# Listar volúmenes
docker volume ls

# Inspeccionador volumen
docker volume inspect infrastructure_ollama_storage
docker volume inspect infrastructure_chroma_storage
```

### Directorios Montados

```
infrastructure/
├── logs/           # Logs de aplicación
├── data/           # SQLite y caché
│   ├── softarchitect.db      (SQLite)
│   └── chromadb/             (ChromaDB local)
└── chroma_storage/           (Volumen Docker)
```

---

## 🎯 Próximos Pasos

### Para Desarrolladores

1. **Leer documentación:**
   - [AGENTS.md](../../AGENTS.md) - Visión y reglas
   - [FUNCTIONAL_TEST_REPORT.md](../01-PROJECT_REPORT/FUNCTIONAL_TEST_REPORT.md) - Resultados de pruebas
   - [INITIAL_SETUP_LOG.es.md](../01-PROJECT_REPORT/INITIAL_SETUP_LOG.es.md) - Setup completo

2. **Iniciar desarrollo:**
   ```bash
   cd infrastructure
   docker compose up -d
   cd ../src/client
   flutter run -d linux
   ```

3. **Implementar features:**
   - Ver [ROADMAP_PHASES.en.md](../../context/40-ROADMAP/ROADMAP_PHASES.en.md)
   - Ver [ROADMAP_DETAILED.en.md](../../context/40-ROADMAP/ROADMAP_DETAILED.en.md)

### Para DevOps

1. **CI/CD Setup:**
   - Crear `.github/workflows/` para GitHub Actions
   - Implementar Docker registry

2. **Monitoring:**
   - Configurar Prometheus + Grafana
   - Health checks en cada servicio

3. **Production:**
   - Migrar a Kubernetes (opcional)
   - Configurar SSL/TLS
   - Logging centralizado (ELK stack)

---

## 🆘 Soporte Rápido

### Contacto

- **Documentación:** Leer `AGENTS.md` y archivos en `doc/` y `context/`
- **Issues:** Ver `FUNCTIONAL_TEST_REPORT.md` para troubleshooting
- **Logs:** `docker compose logs -f`

### Comandos de Debugging

```bash
# Estado completo
docker compose ps -a

# Inspeccionar contenedor
docker inspect sa_api

# Entrar en contenedor
docker exec -it sa_api /bin/bash

# Probar conectividad
docker exec sa_api curl http://ollama:11434/
```

---

## 📌 Notas Importantes

- ✅ **Modo Iron (Local):** Por defecto, todos los datos se procesan localmente
- ✅ **Privacidad:** No se envían datos a la nube sin explícito consentimiento
- ✅ **Offline:** El proyecto funciona completamente sin internet (excepto descarga inicial de modelos)
- ✅ **Recursos:** Memoria limitada a 3.0 GB total (configurable)
- ✅ **Port 8000:** Reservado para API, no cambiar sin editar configuración

---

**Última actualización:** 28 de enero de 2026  
**Versión:** 1.0  
**Estado:** ✅ PRODUCCIÓN LISTA
