# 🐳 HU-1.1: Orchestration & Environment (Docker Setup)

## 🇬🇧 English

> **Epic:** E1 - Orchestration & Environment  
> **User Story ID:** HU-1.1  
> **Owner:** DevOps / Backend Lead  
> **Branch:** `feature/infra-docker-setup`  
> **Estimate:** M (Medium - 3-4 days)  
> **Start Date:** January 29, 2026

---

## 🎯 OBJECTIVE

> As DevOps, I want a unified docker-compose so I can start the full stack with a single command.

---

## ✅ ACCEPTANCE CRITERIA (Definition of Done)

- ✅ `docker compose up` starts 3 containers: api-server, chromadb, ollama
- ✅ Persistence volumes are created in `./infrastructure/data`
- ✅ Backend is accessible at localhost:8000/docs
- ✅ If Docker is not installed, the setup script fails with a clear error message

---

## 📝 TECHNICAL DESCRIPTION

### Context
Phase 1 requires a fully dockerized environment that lets developers start the full stack with one command, without complex manual configuration.

### Current Problem
- [ ] No unified Docker Compose, each dev configures manually
- [ ] No prerequisite checks, failures are non-informative
- [ ] No orchestration scripts, missing friendly UX

### Proposed Solution
Create:
1. **docker-compose.yml** - Orchestrates 3 services (API, ChromaDB, Ollama)
2. **pre_check.py** - Validates prerequisites (Docker, ports)
3. **verify_setup.py** - Validates post-deployment (services online)
4. **start_stack.sh / stop_stack.sh** - Start/shutdown scripts
5. **Documentation** - SETUP_GUIDE.md, README.md, DOCKER_SETUP_LOG.md

---

## 📦 DEPENDENCIES

### Architecture
- `context/30-ARCHITECTURE/TECH_STACK_DETAILS.en.md` - Exact versions
- `context/30-ARCHITECTURE/ERROR_HANDLING_STANDARD.en.md` - Graceful failures
- `context/30-ARCHITECTURE/PROJECT_STRUCTURE_MAP.en.md` - Structure

### Existing Code
- `src/server/Dockerfile` - Must improve (multi-stage, non-root)
- `src/server/main.py` - Must expose `/health`
- `src/server/requirements.txt` - Python dependencies

### Constraints (AGENTS.md)
- ✅ **Clean Architecture:** Docker as adapter, separation of concerns
- ✅ **TDD:** Pre-check and post-check as tests
- ✅ **No Hardcoding:** All variables in `.env`
- ✅ **Security:** Non-root user, secrets in `.env`

---

## 📚 RELATED DOCUMENTATION

| Document | Location | Purpose |
|----------|----------|---------|
| Progress | `PROGRESS.md` | Task checklist |
| Artifacts | `ARTIFACTS.md` | Generated files |
| Enhanced Workflow | `WORKFLOW.md` | 6 detailed phases |
| Setup Guide | [doc/02-SETUP_DEV/SETUP_GUIDE.en.md](../../02-SETUP_DEV/SETUP_GUIDE.en.md) | User guide |
| Docker Guide | [doc/02-SETUP_DEV/DOCKER_COMPOSE_GUIDE.en.md](../../02-SETUP_DEV/DOCKER_COMPOSE_GUIDE.en.md) | Docker details |

---

## 🔗 RELATED REFERENCES

- [HU-1.2: Backend Skeleton](../HU-1.2-BACKEND-SKELETON/README.md) - Next HU
- [USER_STORIES_MASTER.en.json](../../../context/40-ROADMAP/USER_STORIES_MASTER.en.json) - Source of truth
- [AGENTS.md](../../../AGENTS.md) - Project rules

---

## 📊 STATUS

```
████░░░░░░░░░░░░░░░░░░░░░░░░ 14% (Phase 0: Preparation)
```

**Current Phase:** 0 - Preparation ✅  
**Next Phase:** 1 - TDD (Test First)

---

**Last Updated:** January 29, 2026  
**Owner:** ArchitectZero (Lead Software Architect)

---

## 🇪🇸 Español

> **Epic:** E1 - Orquestación y Entorno  
> **User Story ID:** HU-1.1  
> **Owner:** DevOps / Backend Lead  
> **Branch:** `feature/infra-docker-setup`  
> **Estimación:** M (Medium - 3-4 días)  
> **Fecha Inicio:** 29 de Enero de 2026

---

## 🎯 OBJETIVO

> Como DevOps, quiero un docker-compose unificado, para levantar todo el stack con un solo comando.

---

## ✅ CRITERIOS DE ACEPTACIÓN (Definition of Done)

- ✅ `docker compose up` levanta 3 contenedores: api-server, chromadb, ollama
- ✅ Los volúmenes de persistencia están creados en `./infrastructure/data`
- ✅ El backend es accesible en localhost:8000/docs
- ✅ Si Docker no está instalado, el script de setup falla con un mensaje de error legible

---

## 📝 DESCRIPCIÓN TÉCNICA

### Contexto
La Fase 1 del proyecto SoftArchitect AI requiere un entorno completamente dockerizado que permita a los desarrolladores iniciar el stack completo con un solo comando, sin necesidad de configuración manual compleja.

### Problema Actual
- [ ] Sin Docker Compose unificado, cada dev debe configurar manualmente
- [ ] Sin verificación de pre-requisitos, fallos no informativos
- [ ] Sin scripts de orquestación, falta UX amigable

### Solución Propuesta
Crear:
1. **docker-compose.yml** - Orquesta 3 servicios (API, ChromaDB, Ollama)
2. **pre_check.py** - Valida pre-requisitos (Docker, puertos)
3. **verify_setup.py** - Valida post-deployment (servicios online)
4. **start_stack.sh / stop_stack.sh** - Scripts de arranque/shutdown
5. **Documentación** - SETUP_GUIDE.md, README.md, DOCKER_SETUP_LOG.md

---

## 📦 DEPENDENCIAS

### De Arquitectura
- `context/30-ARCHITECTURE/TECH_STACK_DETAILS.es.md` - Versiones exactas
- `context/30-ARCHITECTURE/ERROR_HANDLING_STANDARD.es.md` - Fallos elegantes
- `context/30-ARCHITECTURE/PROJECT_STRUCTURE_MAP.es.md` - Estructura

### De Código Existente
- `src/server/Dockerfile` - Debe mejorar (multi-stage, non-root)
- `src/server/main.py` - Debe tener endpoint `/health`
- `src/server/requirements.txt` - Dependencias Python

### Restricciones (AGENTS.md)
- ✅ **Clean Architecture:** Docker como adapter, separación de concerns
- ✅ **TDD:** Pre-check y post-check como tests
- ✅ **No Hardcoding:** Todas las variables en `.env`
- ✅ **Seguridad:** Usuario non-root, secrets en `.env`

---

## 📚 DOCUMENTACIÓN ASOCIADA

| Documento | Ubicación | Propósito |
|-----------|-----------|----------|
| Progreso | `PROGRESS.md` | Checklist de tareas |
| Artifacts | `ARTIFACTS.md` | Archivos generados |
| Workflow Mejorado | `WORKFLOW.md` | 6 fases detalladas |
| Setup Guide | [doc/02-SETUP_DEV/SETUP_GUIDE.es.md](../../02-SETUP_DEV/SETUP_GUIDE.es.md) | Guía para usuarios |
| Docker Guide | [doc/02-SETUP_DEV/DOCKER_COMPOSE_GUIDE.es.md](../../02-SETUP_DEV/DOCKER_COMPOSE_GUIDE.es.md) | Docker detallado |

---

## 🔗 REFERENCIAS RELACIONADAS

- [HU-1.2: Backend Skeleton](../HU-1.2-BACKEND-SKELETON/README.md) - Siguiente HU
- [USER_STORIES_MASTER.es.json](../../../context/40-ROADMAP/USER_STORIES_MASTER.es.json) - Source of truth
- [AGENTS.md](../../../AGENTS.md) - Reglas del proyecto

---

## 📊 ESTADO

```
████░░░░░░░░░░░░░░░░░░░░░░░░ 14% (Fase 0: Preparación)
```

**Fase Actual:** 0 - Preparación ✅  
**Próxima Fase:** 1 - TDD (Test First)

---

**Última Actualización:** 29 de Enero de 2026  
**Responsable:** ArchitectZero (Lead Software Architect)
