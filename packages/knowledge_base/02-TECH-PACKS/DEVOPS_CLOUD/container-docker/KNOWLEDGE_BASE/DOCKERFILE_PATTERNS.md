# 🐳 Dockerfile Patterns & Best Practices

> **Date:** 30/01/2026
> **Status:** ✅ Desplegado
> **Technology:** Docker / BuildKit / Container Registry
> **Goal:** Imágenes de producción seguras, ligeras y rápidas
> **Audiencia:** DevOps Engineers, Backend Developers, SoftArchitect AI

Patterns de referencia para contenerización de servicios SoftArchitect AI. Todos los ejemplos siguen la filosofía "small, secure, fast" (SSF).

---

## 📋 Table of Contents

1. [Fundamentos](#fundamentos)
2. [Multi-Stage Builds](#multi-stage-builds)
3. [Security (Hardening)](#seguridad-hardening)
4. [Optimización de Capas](#optimización-de-capas)
5. [Patterns por Lenguaje](#patrones-por-lenguaje)
6. [Docker Compose Integration](#docker-compose-integration)
7. [Pre-Commit Checklist](#pre-commit-checklist)

---

## Fundamentos

Docker es el **contenedor de ejecución** para todos los servicios SoftArchitect:
- **Backend:** Python FastAPI (puerto 8000)
- **Frontend:** Flutter Web via Nginx (puerto 80)
- **AI Engine:** Ollama (puerto 11434)
- **Vector DB:** ChromaDB (puerto 8000+)

### Principios No Negociables

1. **Imágenes Deterministas:** Tags específicos, NO `latest`.
2. **Non-Root User:** Security básica, un atacante no entra como root.
3. **No Secrets:** Inyectar en runtime, NUNCA copiar .env.
4. **Multi-Stage:** Separar etapa de build de etapa de runtime.

---

## Multi-Stage Builds

### ✅ Patrón: Python FastAPI (Producción)

**Problema:** `python:3.12` con `gcc` instalado pesa ~900MB. Vulnerabilidades en herramientas de compilación no usadas en runtime.

**Solución:** Usar etapa `builder` para compilar dependencias, luego `runtime` solo con binarios.

```dockerfile
# ============================================================================
# STAGE 1: Builder (Compilación)
# ============================================================================
FROM python:3.12-slim-bookworm as builder

WORKDIR /build

# Instalar SOLO dependencias necesarias para compilación
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    g++ \
    python3-dev \
    && rm -rf /var/lib/apt/lists/*

# Copiar requirements (cambios poco frecuentes = mejor caché)
COPY requirements.txt .

# Crear virtualenv en /opt/venv
RUN python -m venv /opt/venv && \
    /opt/venv/bin/pip install --no-cache-dir --upgrade pip setuptools wheel && \
    /opt/venv/bin/pip install --no-cache-dir -r requirements.txt

# ============================================================================
# STAGE 2: Runtime (Producción)
# ============================================================================
FROM python:3.12-slim-bookworm as runtime

# Crear usuario no-root (SEGURIDAD)
RUN groupadd -r appuser && useradd -r -g appuser appuser

WORKDIR /app

# Copiar virtualenv desde builder (sin herramientas de compilación)
COPY --from=builder /opt/venv /opt/venv

# Copiar código fuente
COPY src/ src/

# Configurar permiso de lectura para appuser
RUN chown -R appuser:appuser /app

# Cambiar a usuario no-root
USER appuser

# Ejecutar aplicación
ENV PATH="/opt/venv/bin:$PATH"
CMD ["uvicorn", "src.main:app", "--host", "0.0.0.0", "--port", "8000"]

# Metadata (para container registries)
LABEL org.opencontainers.image.title="SoftArchitect API"
LABEL org.opencontainers.image.description="Backend FastAPI con RAG"
LABEL org.opencontainers.image.version="{{BUILD_VERSION}}"
```

**Comparación de Tamaños:**
- ❌ **SIN multi-stage:** ~1.2GB (incluye gcc, binutils, etc.)
- ✅ **CON multi-stage:** ~250MB (solo runtime Python)
- **Ganancia:** 78% más pequeño, 100% más seguro

---

### ✅ Patrón: Flutter Web (Nginx)

**Propósito:** Compilar el app Flutter a archivos estáticos y servir con Nginx (máxima velocidad).

```dockerfile
# ============================================================================
# STAGE 1: Build Flutter
# ============================================================================
FROM ghcr.io/cirruslabs/flutter:3.19.0 as flutter_build

WORKDIR /app

# Copiar archivos de configuración
COPY pubspec.yaml pubspec.lock ./

# Descargar dependencias (cacheable si pubspec no cambia)
RUN flutter pub get

# Copiar código fuente (invalida caché aquí)
COPY . .

# Compilar a archivos estáticos (web)
RUN flutter build web --release --no-tree-shake-icons --web-renderer html

# ============================================================================
# STAGE 2: Nginx Server (Producción)
# ============================================================================
FROM nginx:1.25-alpine

# Copiar archivos compilados desde builder
COPY --from=flutter_build /app/build/web /usr/share/nginx/html

# Configurar Nginx (sin logs al stdout para debugging)
RUN echo 'server { \
    listen 80; \
    location / { \
        try_files $uri $uri/ /index.html; \
    } \
}' > /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
```

**Resultado:** Web app estático ultra-rápido (~30MB), sin Node.js runtime en producción.

---

## Security (Hardening)

### ❌ BAD: Inseguro (Nunca Hacer Esto)

```dockerfile
FROM python:3.12  # latest sin pin de versión
WORKDIR /app
COPY . .
RUN pip install -r requirements.txt
# User: root (default, MUY PELIGROSO)
CMD ["python", "main.py"]
```

**Problemas:**
- ❌ Tag `latest` = builds no-deterministas
- ❌ Root user = si el proceso se compromete, atacante es root
- ❌ `COPY . .` con caché desoptimizado

### ✅ GOOD: Seguro (Referencia)

```dockerfile
FROM python:3.12.3-slim-bookworm as builder
# ... (compilación sin root)

FROM python:3.12.3-slim-bookworm as runtime
RUN groupadd -r appuser && useradd -r -g appuser appuser
USER appuser
# ... (ejecutar como appuser)
```

**Ventajas:**
- ✅ Tag específico = builds reproducibles
- ✅ Non-root user = ataque limitado
- ✅ Multi-stage = imagen 80% más pequeña

### Reglas de Hardening

| Regla | Explicación | Impacto |
|:---|:---|:---|
| **Pin image version** | `FROM python:3.12.3-slim-bookworm` NO `python:3.12` | ⭐⭐⭐⭐⭐ Criticidad |
| **Non-root user** | Crear usuario, usar `USER appuser` | ⭐⭐⭐⭐⭐ Criticidad |
| **Clean package manager** | `apt-get update && ... && rm -rf /var/lib/apt/lists/*` | ⭐⭐⭐ Reduce tamaño |
| **No secrets in Dockerfile** | Inyectar `--build-arg` o variables runtime | ⭐⭐⭐⭐⭐ Criticidad |
| **Scan image for CVEs** | `trivy image myimage:latest` | ⭐⭐⭐⭐ Criticidad |

---

## Optimización de Capas

### Concepto: Docker Layer Cache

Cada instrucción en un Dockerfile crea una "capa". Docker cachea capas para builds rápidos. **Si una capa cambia, todas las siguientes se re-ejecutan.**

### ❌ BAD: Caché Ineficiente

```dockerfile
FROM python:3.12-slim
WORKDIR /app

# ❌ PROBLEMA: COPY . . invalida caché siempre
COPY . .
COPY requirements.txt .
RUN pip install -r requirements.txt
```

**Flujo:**
1. Primer build: copia todo, instala deps, toma 60s.
2. Cambias un archivo en `src/`, vuelves a buildear.
3. ❌ `COPY . .` cambia → re-ejecuta `pip install` completo (60s más).

### ✅ GOOD: Caché Optimizado

```dockerfile
FROM python:3.12-slim
WORKDIR /app

# ✅ PRIMERO: requirements (cambia raras veces)
COPY requirements.txt .
RUN pip install -r requirements.txt

# ✅ DESPUÉS: código fuente (cambia en cada commit)
COPY src/ src/
```

**Flujo:**
1. Primer build: copia requirements, instala deps, copia src, toma 60s.
2. Cambias un archivo en `src/`, vuelves a buildear.
3. ✅ `COPY requirements.txt` y `RUN pip` se cachean → solo copia `src/` (5s).

**Ganancia:** 12x más rápido en rebuilds.

### Orden de Instrucciones (Menos-Cambio → Más-Cambio)

```dockerfile
# 1️⃣ MENOS cambio: Base system packages
RUN apt-get update && apt-get install -y ...

# 2️⃣ Dependencias del proyecto
COPY requirements.txt .
RUN pip install -r requirements.txt

# 3️⃣ Configuration (cambios ocasionales)
COPY config/ config/

# 4️⃣ MÁS cambio: Código fuente
COPY src/ src/

# 5️⃣ Punto de entrada (casi nunca cambia)
CMD ["uvicorn", "main:app"]
```

---

## Patterns por Lenguaje

### Python FastAPI (Incluido arriba)

✅ Ventajas:
- Virtualenv aislado en `/opt/venv`
- Multi-stage para eliminar gcc
- Non-root user

### Node.js Express

```dockerfile
# STAGE 1: Builder
FROM node:20-slim as builder

WORKDIR /build
COPY package*.json ./
RUN npm ci --only=production

# STAGE 2: Runtime
FROM node:20-alpine

RUN addgroup -g 1001 -S nodejs && adduser -S nodejs -u 1001
WORKDIR /app

COPY --from=builder /build/node_modules ./node_modules
COPY src/ src/

USER nodejs
EXPOSE 3000
CMD ["node", "src/main.js"]
```

### Go (Binario Estático)

```dockerfile
# STAGE 1: Build
FROM golang:1.21-alpine as builder

WORKDIR /build
COPY go.mod go.sum ./
RUN go mod download

COPY . .
RUN CGO_ENABLED=0 go build -ldflags="-w -s" -o app .

# STAGE 2: Runtime (distroless = ultra-minimalista)
FROM scratch

COPY --from=builder /build/app /app
ENTRYPOINT ["/app"]
```

---

## Docker Compose Integration

### ✅ docker-compose.yml (SoftArchitect Full Stack)

```yaml
version: '3.9'

services:
  # ============================================================================
  # Backend: Python FastAPI + RAG
  # ============================================================================
  backend:
    build:
      context: .
      dockerfile: Dockerfile.backend
      args:
        PYTHON_VERSION: 3.12.3
    image: softarchitect-backend:latest
    container_name: softarchitect-api
    environment:
      ENVIRONMENT: production
      LOG_LEVEL: INFO
      OLLAMA_HOST: http://ollama:11434
      CHROMA_HOST: chroma
      CHROMA_PORT: 8000
    ports:
      - "8000:8000"
    depends_on:
      - ollama
      - chroma
    networks:
      - softarchitect-net
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/health"]
      interval: 30s
      timeout: 5s
      retries: 3

  # ============================================================================
  # Frontend: Flutter Web via Nginx
  # ============================================================================
  frontend:
    build:
      context: .
      dockerfile: Dockerfile.frontend
    image: softarchitect-frontend:latest
    container_name: softarchitect-ui
    ports:
      - "80:80"
    depends_on:
      - backend
    networks:
      - softarchitect-net
    restart: unless-stopped

  # ============================================================================
  # AI Engine: Ollama (Local LLM)
  # ============================================================================
  ollama:
    image: ollama/ollama:latest
    container_name: softarchitect-ollama
    environment:
      OLLAMA_KEEP_ALIVE: 24h  # Mantener modelo en RAM
    ports:
      - "11434:11434"
    volumes:
      - ollama_data:/root/.ollama
    networks:
      - softarchitect-net
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:11434/api/tags"]
      interval: 30s
      timeout: 5s
      retries: 3

  # ============================================================================
  # Vector DB: ChromaDB
  # ============================================================================
  chroma:
    image: chromadb/chroma:latest
    container_name: softarchitect-chroma
    ports:
      - "8001:8000"
    volumes:
      - chroma_data:/chroma/chroma
    networks:
      - softarchitect-net
    restart: unless-stopped
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/api/version"]
      interval: 30s
      timeout: 5s
      retries: 3

networks:
  softarchitect-net:
    driver: bridge

volumes:
  ollama_data:
    driver: local
  chroma_data:
    driver: local
```

---

## Pre-Commit Checklist

Antes de hacer `git push`:

```bash
# 1. Verificar Dockerfile sintaxis
hadolint Dockerfile.backend Dockerfile.frontend

# 2. Escanear vulnerabilidades
trivy image softarchitect-backend:latest

# 3. Chequear no-root user
docker run --rm softarchitect-backend:latest whoami  # NO debe ser root

# 4. Verificar tamaño de imagen
docker images | grep softarchitect

# 5. Probar build en caché (debería ser rápido)
docker build -t test . && docker build -t test .  # Segunda ejecución <10s

# 6. Verificar .dockerignore está presente
test -f .dockerignore && echo "✅ .dockerignore exists"

# 7. Limpiar imágenes dangling
docker image prune -f

# 8. Validar docker-compose.yml
docker-compose config > /dev/null && echo "✅ docker-compose válido"

# 9. Verificar no hay secretos en Dockerfile
! grep -E "PASSWORD|SECRET|API_KEY|aws_access" Dockerfile.* || exit 1

# 10. Tests de healthchecks
docker-compose up -d && sleep 10 && docker-compose ps --format "table {{.Service}}\t{{.Status}}"
```

---

## Conclusion

Estos patrones garantizan que **cada contenedor de SoftArchitect**:
- ✅ Es seguro (no-root, tags pinned, sin secretos)
- ✅ Es pequeño (multi-stage, alpine/slim bases)
- ✅ Es rápido (caché optimizado, builds deterministas)
- ✅ Es confiable (healthchecks, restart policies)

**Dogfooding Validation:** Estos Dockerfiles se aplican a TODOS los servicios SoftArchitect en `infrastructure/docker-compose.yml`.
