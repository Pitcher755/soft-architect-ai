# 🔒 Security Policy & Hardening Checklist

> **Date:** 29/01/2026  
> **Status:** ✅ IMPLEMENTED  
> **Version:** 1.0  
> **Scope:** Infrastructure, Docker, Secrets Management

---

## 📖 Table of Contents

- [Overview](#overview)
- [Secrets Management](#secrets-management)
- [Docker Configuration](#docker-configuration)
- [File Permissions](#file-permissions)
- [Security Validation](#security-validation)
- [Deployment Checklist](#deployment-checklist)

---

## 🎯 Overview

This security policy ensures that:

1. ✅ **No secrets in repository** - All .env files are git-ignored (except .env.example)
2. ✅ **Environment variables at runtime** - Secrets injected into containers via `docker run -e`
3. ✅ **Secure Docker build** - `.dockerignore` excludes sensitive files
4. ✅ **Correct permissions** - Data protected with chmod 755
5. ✅ **No hardcoded credentials** - Code clean of secrets

---

## 🔐 Secrets Management

### Principle: Environment Variables Over Hardcoding

**CORRECT (✅):**
```python
# File: app/core/config.py
class Settings:
    GROQ_API_KEY: str = ""  # Injected via environment variable
    OLLAMA_URL: str = "http://ollama:11434"  # Configuration, not secret
```

```yaml
# File: docker-compose.yml
environment:
  - GROQ_API_KEY=${GROQ_API_KEY}  # From environment variable
  - OLLAMA_BASE_URL=http://ollama:11434
```

**INCORRECT (❌):**
```python
# NEVER
GROQ_API_KEY = "gsk_xxxxxxxx"  # Hardcoded!

# NEVER
class Settings:
    GROQ_API_KEY: str = "gsk_xxxxxxxx"  # Hardcoded!
```

### File .env.example

The `.env.example` file documents all required variables:

```bash
# Visible in: infrastructure/.env.example
# DO NOT include real values

GROQ_API_KEY=gsk_xxxxxxxxxxxxx_PLACEHOLDER
OLLAMA_MODEL=qwen2.5-coder:7b
```

### Injecting Secrets at Runtime

**Local Development:**
```bash
# 1. Copy from .env.example
cp infrastructure/.env.example infrastructure/.env

# 2. Edit with real values (NEVER commit)
vi infrastructure/.env

# 3. Use with docker-compose
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

## 🐳 Docker Configuration

### 1. .dockerignore (Excludes from Build Context)

**File:** `.dockerignore` (root)

**Critical Exclusions:**
```
# Version Control
.git
.gitignore

# Environment & Secrets (SECURITY)
.env
.env.*
!.env.example

# Testing
tests/
.pytest_cache

# Development
venv/
node_modules/
__pycache__
```

**Benefit:** Reduces build size and prevents sensitive data from entering Docker image.

### 2. Dockerfile (Multi-Stage Build)

**File:** `src/server/Dockerfile`

**Security Features:**
- ✅ Non-root user: `USER appuser` (uid 1000)
- ✅ Multi-stage: Dependencies in builder stage, clean code in final
- ✅ No unnecessary file copies
- ✅ Safe environment variables

```dockerfile
# Stage 1: Builder (discarded in final)
FROM python:3.12-slim AS builder
COPY requirements.txt .
RUN pip install --user --no-cache-dir -r requirements.txt

# Stage 2: Final (only necessary)
FROM python:3.12-slim
RUN useradd -m -u 1000 appuser
COPY --from=builder /root/.local /home/appuser/.local
USER appuser  # ✅ Do not run as root
EXPOSE 8000
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

### 3. Docker-compose.yml (Environment Variables)

**File:** `infrastructure/docker-compose.yml`

**Safe Patterns:**
```yaml
services:
  api-server:
    environment:
      # ✅ From environment variable
      - ENVIRONMENT=${ENVIRONMENT:-development}
      - DEBUG=${DEBUG:-true}
      # ✅ Local configuration (not secret)
      - OLLAMA_BASE_URL=http://ollama:11434
      # ✅ NOT hardcoded
      - LOG_LEVEL=${LOG_LEVEL:-INFO}
```

**Injected Variables:**
```bash
# From .env file or via -e flag
docker run -e GROQ_API_KEY=gsk_xxx...
```

---

## 🔑 File Permissions

### Data Directories

Directories containing data should have restrictive permissions:

```bash
# Apply permissions
chmod 755 infrastructure/data                # rwxr-xr-x
chmod 755 infrastructure/data/chromadb       # rwxr-xr-x
chmod 755 infrastructure/data/ollama         # rwxr-xr-x
chmod 755 infrastructure/data/logs           # rwxr-xr-x
```

**Explanation:**
- `7` (owner) = read + write + execute
- `5` (group) = read + execute (no write)
- `5` (others) = read + execute (no write)

### File .env (If exists locally)

```bash
# Protect local configuration file
chmod 600 infrastructure/.env    # rw-------
```

---

## ✅ Security Validation

### Audit Script

**Location:** `infrastructure/security-validation.sh`

**Usage:**
```bash
bash infrastructure/security-validation.sh
```

**Verifications:**
1. ✅ No .env in repository (except .env.example)
2. ✅ .env.example exists and is documented
3. ✅ No hardcoded credential patterns
4. ✅ docker-compose.yml uses environment variables
5. ✅ .dockerignore exists and excludes sensitive files
6. ✅ No .env changes in recent git history
7. ✅ Directory permissions are secure

**Expected Result:**
```
🔒 Status: SECURE
```

---

## 📋 Deployment Checklist

### Pre-Deployment Security Check

- [ ] **.env NOT committed**
  ```bash
  git status  # .env should not appear
  ```

- [ ] **.env.example is documented**
  ```bash
  wc -l infrastructure/.env.example  # Should have comments
  ```

- [ ] **Secrets are environment variables**
  ```bash
  grep -r "password\|secret" src/ --include="*.py"  # Should be empty or reference env vars
  ```

- [ ] **Docker-compose uses ${VAR}**
  ```bash
  grep '\${' infrastructure/docker-compose.yml  # Should have references
  ```

- [ ] **.dockerignore exists and is complete**
  ```bash
  ls -la .dockerignore  # Should exist
  ```

- [ ] **Data permissions are secure**
  ```bash
  ls -la infrastructure/data/  # Should be drwxr-xr-x
  ```

- [ ] **Validation script passes**
  ```bash
  bash infrastructure/security-validation.sh  # 🔒 Status: SECURE
  ```

### Pre-Production Checklist

- [ ] All secrets are in GitHub Secrets or variable management
- [ ] .env.example does NOT contain real values
- [ ] .gitignore includes `.env*` (except .env.example)
- [ ] Dockerfile runs as non-root user
- [ ] docker-compose.yml has NO hardcoded values
- [ ] Directory permissions are restrictive
- [ ] Security validation script runs without errors
- [ ] Git history does NOT contain real secrets

---

## 🚨 Security Incidents

### If secrets are accidentally committed:

```bash
# 1. Revoke credentials immediately (on all services)

# 2. Remove from git history (use BFG Repo-Cleaner)
# npm install -g bfg
# bfg --delete-files .env

# 3. Force push
git push origin --force

# 4. Create new credentials
# Ex: Regenerate Groq API key, etc.

# 5. Verify no unauthorized access
```

---

## 📚 References

- [AGENTS.md](../../AGENTS.md) - §5 Restrictions (No hardcoding)
- [SECURITY_AND_PRIVACY_RULES.en.md](../../context/20-REQUIREMENTS_AND_SPEC/SECURITY_AND_PRIVACY_RULES.en.md) - Security standards
- [docker-compose.yml](../../infrastructure/docker-compose.yml) - Services configuration
- [Dockerfile](../../src/server/Dockerfile) - Build configuration
- [.dockerignore](../../.dockerignore) - Build context exclusions
- [security-validation.sh](../../infrastructure/security-validation.sh) - Security audit

---

**Created:** 29/01/2026  
**Last Updated:** 29/01/2026  
**Version:** 1.0  
**Status:** ✅ PRODUCTION READY
