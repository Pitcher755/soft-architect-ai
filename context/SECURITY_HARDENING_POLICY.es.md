# 🔒 Política de Seguridad & Checklist de Hardening

> **Fecha:** 29/01/2026  
> **Estado:** ✅ IMPLEMENTADO  
> **Versión:** 1.0  
> **Alcance:** Infraestructura, Docker, Gestión de Secretos

---

## 📖 Tabla de Contenidos

- [Visión General](#visión-general)
- [Gestión de Secretos](#gestión-de-secretos)
- [Configuración Docker](#configuración-docker)
- [Permisos de Archivo](#permisos-de-archivo)
- [Validación de Seguridad](#validación-de-seguridad)
- [Checklist de Deployment](#checklist-de-deployment)

---

## 🎯 Visión General

Esta política de seguridad asegura que:

1. ✅ **No hay secretos en el repositorio** - Todos los .env son ignorados por git (excepto .env.example)
2. ✅ **Variables de entorno en runtime** - Secretos inyectados en contenedores via `docker run -e`
3. ✅ **Docker build seguro** - `.dockerignore` excluye archivos sensibles
4. ✅ **Permisos correctos** - Datos protegidos con chmod 755
5. ✅ **No hardcoded credentials** - Código limpio de secretos

---

## 🔐 Gestión de Secretos

### Principio: Variables de Entorno sobre Hardcoding

**CORRECTO (✅):**
```python
# Archivo: app/core/config.py
class Settings:
    GROQ_API_KEY: str = ""  # Inyectado via variable de entorno
    OLLAMA_URL: str = "http://ollama:11434"  # Configuración, no secreto
```

```yaml
# Archivo: docker-compose.yml
environment:
  - GROQ_API_KEY=${GROQ_API_KEY}  # De variable de entorno
  - OLLAMA_BASE_URL=http://ollama:11434
```

**INCORRECTO (❌):**
```python
# NUNCA
GROQ_API_KEY = "gsk_xxxxxxxx"  # ¡Hardcoded!

# NUNCA
class Settings:
    GROQ_API_KEY: str = "gsk_xxxxxxxx"  # ¡Hardcoded!
```

### Archivo .env.example

El archivo `.env.example` documenta todas las variables necesarias:

```bash
# Visible en: infrastructure/.env.example
# NO incluya valores reales

GROQ_API_KEY=gsk_xxxxxxxxxxxxx_PLACEHOLDER
OLLAMA_MODEL=qwen2.5-coder:7b
```

### Inyección de Secretos en Runtime

**Desarrollo Local:**
```bash
# 1. Copiar desde .env.example
cp infrastructure/.env.example infrastructure/.env

# 2. Editar con valores reales (NUNCA commitear)
vi infrastructure/.env

# 3. Usar en docker-compose
docker-compose --env-file infrastructure/.env up
```

**Production (CI/CD):**
```yaml
# GitHub Actions / Deployment Pipeline
- name: Deploy
  run: |
    docker run \
      -e GROQ_API_KEY=${{ secrets.GROQ_API_KEY }} \
      -e OLLAMA_URL=http://ollama:11434 \
      soft-architect-ai:latest
```

---

## 🐳 Configuración Docker

### 1. .dockerignore (Excluye del Build Context)

**Archivo:** `.dockerignore` (raíz)

**Exclusiones Críticas:**
```
# Control de Versiones
.git
.gitignore

# Ambiente & Secretos (SEGURIDAD)
.env
.env.*
!.env.example

# Testing
tests/
.pytest_cache

# Desarrollo
venv/
node_modules/
__pycache__
```

**Beneficio:** Reduce tamaño del build y previene que datos sensibles entren en la imagen Docker.

### 2. Dockerfile (Multi-Stage Build)

**Archivo:** `src/server/Dockerfile`

**Características de Seguridad:**
- ✅ Usuario no-root: `USER appuser` (uid 1000)
- ✅ Multi-stage: Dependencias en stage builder, código limpio en final
- ✅ No copia archivos innecesarios
- ✅ Variables de entorno seguras

```dockerfile
# Stage 1: Builder (descartado en final)
FROM python:3.12-slim AS builder
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Stage 2: Final (solo lo necesario)
FROM python:3.12-slim
RUN useradd -m -u 1000 appuser
COPY --from=builder /root/.local /home/appuser/.local
USER appuser  # ✅ No correr como root
EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### 3. Docker-compose.yml (Variables de Entorno)

**Archivo:** `infrastructure/docker-compose.yml`

**Patrones Seguros:**
```yaml
services:
  api-server:
    environment:
      # ✅ De variable de entorno
      - ENVIRONMENT=${ENVIRONMENT:-development}
      - DEBUG=${DEBUG:-true}
      # ✅ Configuración local (no secreto)
      - OLLAMA_BASE_URL=http://ollama:11434
      # ✅ NO hardcoded
      - LOG_LEVEL=${LOG_LEVEL:-INFO}
```

**Variables Inyectadas:**
```bash
# Desde archivo .env o via -e flag
docker run -e GROQ_API_KEY=gsk_xxx...
```

---

## 🔑 Permisos de Archivo

### Directorios de Datos

Los directorios que contienen datos deben tener permisos restrictivos:

```bash
# Aplicar permisos
chmod 755 infrastructure/data                # rwxr-xr-x
chmod 755 infrastructure/data/chromadb       # rwxr-xr-x
chmod 755 infrastructure/data/ollama         # rwxr-xr-x
chmod 755 infrastructure/data/logs           # rwxr-xr-x
```

**Explicación:**
- `7` (owner) = lectura + escritura + ejecución
- `5` (group) = lectura + ejecución (sin escritura)
- `5` (others) = lectura + ejecución (sin escritura)

### Archivo .env (Si existe localmente)

```bash
# Proteger archivo de configuración local
chmod 600 infrastructure/.env    # rw-------
```

---

## ✅ Validación de Seguridad

### Script de Auditoría

**Ubicación:** `infrastructure/security-validation.sh`

**Uso:**
```bash
bash infrastructure/security-validation.sh
```

**Verificaciones:**
1. ✅ No hay .env en repositorio (excepto .env.example)
2. ✅ .env.example existe y está documentado
3. ✅ No hay patrones de credenciales hardcodeadas
4. ✅ docker-compose.yml usa variables de entorno
5. ✅ .dockerignore existe y excluye archivos sensibles
6. ✅ No hay cambios de .env en git history reciente
7. ✅ Permisos de directorios son seguros

**Resultado Esperado:**
```
🔒 Status: SECURE
```

---

## 📋 Checklist de Deployment

### Pre-Deployment Security Check

- [ ] **.env NO está committeado**
  ```bash
  git status  # .env no debe aparecer
  ```

- [ ] **.env.example está documentado**
  ```bash
  wc -l infrastructure/.env.example  # Debe tener comentarios
  ```

- [ ] **Secretos son variables de entorno**
  ```bash
  grep -r "password\|secret" src/ --include="*.py"  # Debe estar vacío o tener referencias a vars env
  ```

- [ ] **Docker-compose usa ${VAR}**
  ```bash
  grep '\${' infrastructure/docker-compose.yml  # Debe tener referencias
  ```

- [ ] **.dockerignore existe y es completo**
  ```bash
  ls -la .dockerignore  # Debe existir
  ```

- [ ] **Permisos de datos son seguros**
  ```bash
  ls -la infrastructure/data/  # Debe ser drwxr-xr-x
  ```

- [ ] **Script de validación pasa**
  ```bash
  bash infrastructure/security-validation.sh  # 🔒 Status: SECURE
  ```

### Pre-Production Checklist

- [ ] Todos los secretos están en GitHub Secrets o variable management
- [ ] .env.example NO contiene valores reales
- [ ] .gitignore incluye `.env*` (excepto .env.example)
- [ ] Dockerfile corre como usuario no-root
- [ ] docker-compose.yml NO tiene valores hardcodeados
- [ ] Permisos de directorios son restrictivos
- [ ] Security validation script ejecuta sin errores
- [ ] Git history NO contiene secretos reales

---

## 🚨 Incidentes de Seguridad

### Si secretos fueron commiteados accidentalmente:

```bash
# 1. Revocar credenciales inmediatamente (en todos los servicios)

# 2. Remover de git history (usar BFG Repo-Cleaner)
# npm install -g bfg
# bfg --delete-files .env

# 3. Force push
git push origin --force

# 4. Crear nuevas credenciales
# Ej: Regenerar Groq API key, etc.

# 5. Verificar que no hay acceso no autorizado
```

---

## 📚 Referencias

- [AGENTS.md](../../AGENTS.md) - §5 Restricciones (No hardcoding)
- [SECURITY_AND_PRIVACY_RULES.es.md](../../context/20-REQUIREMENTS_AND_SPEC/SECURITY_AND_PRIVACY_RULES.es.md) - Estándares de seguridad
- [docker-compose.yml](../../infrastructure/docker-compose.yml) - Configuración de servicios
- [Dockerfile](../../src/server/Dockerfile) - Configuración de build
- [.dockerignore](../../.dockerignore) - Exclusiones de build context
- [security-validation.sh](../../infrastructure/security-validation.sh) - Auditoría de seguridad

---

**Creado:** 29/01/2026  
**Última actualización:** 29/01/2026  
**Versión:** 1.0  
**Estado:** ✅ LISTO PARA PRODUCCIÓN
