<div align="center">

# 🏗️ SoftArchitect AI

### **Your Virtual Senior Architect, On-Demand**
**Democratizing Elite Software Engineering Through Contextual AI**

[![Status](https://img.shields.io/badge/Status-Pre--Alpha-orange)]()
[![Tests](https://img.shields.io/badge/Tests-1286%20Passing-success)]()
[![Coverage](https://img.shields.io/badge/Coverage-%E2%89%A580%25-brightgreen)]()
[![Stack](https://img.shields.io/badge/Stack-Flutter%20%7C%20Python%20%7C%20RAG-blue)]()
[![Privacy](https://img.shields.io/badge/Privacy-100%25%20Local--First-green)]()
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

---

### 📊 Project Stats

| Metric | Value | Metric | Value |
|--------|-------|--------|-------|
| 📝 **Documentation** | 460+ files | 🧪 **Tests** | 893 Flutter + 393 Python |
| 🎯 **Test Coverage** | ≥80% | 📚 **Knowledge Base** | 29 files, 934 lines |
| 🏛️ **Architecture** | Clean + Hexagonal | 🔐 **Security Gates** | 16/16 passing |
| 🚀 **Features** | 24 User Stories | ⚡ **Deployment** | <2min Docker |

### 🎬 Presentations & Demos

📊 **[View Slides (GitHub Pages)](https://pitcher755.github.io/soft-architect-ai/)** | � [Markdown Source](presentation/slides.md)

---

**🌍 Languages:** [🇬🇧 English](#english) | [🇪🇸 Español](#español)

</div>

---

<a name="english"></a>

## 🇬🇧 English Version

### 🇬🇧 English Version

#### 📚 Key Documentation

- [📖 Complete Documentation Index](doc/INDEX.md) - Start here for organized navigation
- [White Paper & Vision](doc/English/00-VISION/CONCEPT_WHITE_PAPER.md)
- [Quick Start Guide](doc/English/02-SETUP_DEV/01-INSTALLATION/QUICK_START_GUIDE.md)
- [Local LLM Setup Guide](doc/English/02-SETUP_DEV/01-INSTALLATION/LOCAL_LLM_GUIDE.md) - Run AI 100% privately on your hardware
- [Hardware Acceleration Guide](doc/English/02-SETUP_DEV/01-INSTALLATION/HARDWARE_ACCELERATION_GUIDE.md) - GPU configuration (NVIDIA/Apple Silicon/CPU)
- [Functional Test Report](doc/English/01-PROJECT_REPORT/03-TESTING/FUNCTIONAL_TEST_REPORT.md)
- [Initial Setup Log](doc/English/01-PROJECT_REPORT/01-ARCHITECTURE/INITIAL_SETUP_LOG.md)
- [Methodology & Structure](doc/English/01-PROJECT_REPORT/10-DOCUMENTATION/MEMORIA_METODOLOGICA.md)
- [Detailed Setup Guide](doc/English/02-SETUP_DEV/01-INSTALLATION/SETUP_GUIDE.md)
- [Technology Stack](doc/English/02-SETUP_DEV/01-INSTALLATION/TOOLS_AND_STACK.md)
- [Automation & DevOps](doc/English/02-SETUP_DEV/04-AUTOMATION/AUTOMATION.md)
- **⭐ NEW:** [Knowledge Base Completion Report](doc/English/01-PROJECT_REPORT/05-COMPLETION-STATUS/KNOWLEDGE_BASE_COMPLETION.md) - Phases 0-6 (29 files, 934 lines)
- **⭐ NEW:** [Constitutional Rules](packages/knowledge_base/02-TECH-PACKS/) - FASE 3 (5 files, 3,742 lines)
- **✅ VERIFIED:** [Pre-Push Validation Report (2026-02-12)](doc/English/01-PROJECT_REPORT/06-VALIDATION/PRE_PUSH_VALIDATION_2026-02-12.md) - 16/16 gates passed
- **🚀 COMPLETED:** [HU-3.1: Project Shell UI](doc/English/03-HU-TRACKING/HU-3.1-PROJECT-SHELL-UI-IMPLEMENTATION/README.md) - All 4 Phases + Security ✅
- **🚧 IN PROGRESS:** [HU-3.7: Settings UI Completion](doc/English/03-HU-TRACKING/HU-3.7-SETTINGS-UI-COMPLETION/README.md) - tests stabilized, coverage uplift in progress
- **📊 TEST STATUS:** Client Flutter full suite green + Server app coverage gate ≥80% passing

#### 📖 Vision

SoftArchitect AI is not another "code chat". It is an assisted development platform that guides developers through a **Strict Engineering Workflow** (Requirements → Architecture → Code → Deploy).

It acts as an intelligent **Quality Gate** that ensures compliance with best practices (SOLID, Clean Architecture, OWASP) before writing a single line of code, using **RAG (Retrieval-Augmented Generation)** on an academic and practical knowledge base.

#### ⚡ Quick Start (5 minutes)

Get SoftArchitect AI running locally in under 5 minutes:

```bash
# 1. Clone & navigate
git clone https://github.com/YOUR_USER/soft-architect-ai.git
cd soft-architect-ai

# 2. Start all services (Docker required)
scripts/devops/start_stack.sh

# 3. Access services:
# - API: http://localhost:8000
# - API Docs: http://localhost:8000/docs
# - ChromaDB: http://localhost:8001
# - Ollama: http://localhost:11434

# 4. Stop services when done
scripts/devops/stop_stack.sh
```

**Requirements:** Docker 20.10+ and Docker Compose 2.0+ | **Time:** ~2 minutes (first-time pull)

For detailed setup, troubleshooting, and advanced configuration, see [Detailed Setup Guide](doc/English/02-SETUP_DEV/01-INSTALLATION/SETUP_GUIDE.md).

#### 🚀 Key Features

* **🧠 Contextual RAG & Tech Packs:** Uses a modular "Technical Encyclopedia" (`packages/knowledge_base/02-TECH-PACKS`) that allows the assistant to interview users to configure specific stacks (Flutter, Python, Firebase) with precise architecture rules.
* **🛡️ Local-First & Hybrid:**
    * **Privacy Mode:** Runs LLMs (Ollama) on your local network. Your data never leaves.
    * **Performance Mode:** Connects to Groq Cloud for ultra-fast inference on modest hardware.
* **🏭 Context Factory:** Automatically generates technical documentation (`AGENTS.md`, `RULES.md`) so your Copilot works better.
* **🤖 CI/CD Pipelines:** Intelligent GitHub Actions workflows for monorepo (auto-detect changes, run only relevant checks).

#### 🛠️ Technology Stack

* **Frontend:** Flutter (Desktop - Linux/Windows/Mac).
* **Backend:** Python (FastAPI) + LangChain.
* **AI Engine:** Ollama (Local) / Groq (Cloud).
* **Memory:** ChromaDB (Vector Store).
* **Infrastructure:** Docker Compose.

#### 📂 Repository Structure (Monorepo)

```text
soft-architect-ai/
├── context/                 # 🧠 Context for Agents (AGENTS.md, Global Rules)
├── doc/                     # 📘 Living Project Documentation (Logbook, Thesis)
├── packages/
│   └── knowledge_base/      # 🤖 The RAG Brain (Templates, Tech Packs, Examples)
├── src/                     # Application Source Code
│   ├── client/              # Frontend Flutter Desktop
│   └── server/              # Backend Python API + LangChain Logic
└── infrastructure/          # Docker Configuration & DevOps (docker-compose.yml)
```

#### 🚦 Getting Started

##### Prerequisites

* Docker & Docker Compose
* Git

##### Quick Installation (Dev)

1. **Clone Repository:**

> See the [Quick Start Guide](doc/English/02-SETUP_DEV/01-INSTALLATION/QUICK_START_GUIDE.md) for quick instructions or the [Detailed Setup Guide](doc/English/02-SETUP_DEV/01-INSTALLATION/SETUP_GUIDE.md) for complete steps and troubleshooting.

```bash
git clone https://github.com/YOUR_USER/soft-architect-ai.git
cd soft-architect-ai
```

2. **Configure Environment (.env):**

```bash
cp .env.example .env
# Edit .env to choose LLM_PROVIDER=local or LLM_PROVIDER=cloud
```

3. **Start Services:**

```bash
docker compose -f infrastructure/docker-compose.yml up -d
```

#### 📚 Additional Resources

- [📖 Complete Documentation Index](doc/INDEX.md) - Master navigation portal
- [Architecture Documentation](context/30-ARCHITECTURE/PROJECT_STRUCTURE_MAP.en.md)
- [Security & Privacy Rules](context/20-REQUIREMENTS_AND_SPEC/SECURITY_AND_PRIVACY_RULES.en.md)
- [Roadmap & Phases](context/40-ROADMAP/ROADMAP_PHASES.en.md)
- [User Stories](context/40-ROADMAP/USER_STORIES_MASTER.en.json)

#### 🧪 Testing (Monorepo Structure)

All tests are centralized in the `tests/` directory with language-specific organization:

```bash
# Run Flutter tests
scripts/testing/run_tests.sh flutter

# Run Python tests
scripts/testing/run_tests.sh python

# Run all tests
scripts/testing/run_tests.sh all

# Generate coverage report
scripts/testing/run_tests.sh all --coverage
```

**Test Structure:**
- `tests/client/unit/` - Flutter unit tests
- `tests/client/widget/` - Flutter widget tests
- `tests/client/integration/` - Flutter integration tests
- `tests/client/e2e/` - Flutter E2E tests
- `tests/server/` - Python tests (unit/integration)

See [tests/README.md](tests/README.md) for detailed testing documentation and structure.

#### 🚀 Deployment & Production

##### Docker Deployment (Recommended)

Deploy all services with a single command:

```bash
# Start all services (API, ChromaDB, Ollama)
./scripts/devops/start_stack.sh

# Services will be available at:
# - API: http://localhost:8000
# - API Docs: http://localhost:8000/docs
# - ChromaDB Admin: http://localhost:8001
# - Ollama: http://localhost:11434
```

##### Knowledge Base Ingestion

Before first use, ingest the technical knowledge base:

```bash
# 1. Ensure services are running
docker ps  # Should show sa_api, sa_chromadb, sa_ollama

# 2. Ingest knowledge base (Tech Packs + Templates)
curl -X POST http://localhost:8000/api/v1/knowledge/ingest \
  -H "Content-Type: application/json" \
  -d '{"path": "packages/knowledge_base"}'

# 3. Verify ingestion
curl http://localhost:8000/api/v1/knowledge/status

# Expected response:
# {
#   "status": "ready",
#   "documents": 29,
#   "vectors": 934,
#   "collections": ["tech-packs", "templates", "examples"]
# }
```

##### Production Checklist

- [ ] Configure `.env` with production settings
- [ ] Enable HTTPS with reverse proxy (Nginx/Traefik)
- [ ] Set `LLM_PROVIDER=cloud` for better performance
- [ ] Configure backup strategy for `infrastructure/data/`
- [ ] Set up monitoring (logs in `infrastructure/logs/`)
- [ ] Review [Security Hardening Policy](context/SECURITY_HARDENING_POLICY.en.md)

**Deployment Guides:**
- [📖 Docker Deployment Log](doc/English/02-SETUP_DEV/02-DOCKER/DOCKER_SETUP_LOG.md)
- [🔧 Hardware Acceleration](doc/English/02-SETUP_DEV/01-INSTALLATION/HARDWARE_ACCELERATION_GUIDE.md)
- [🐳 Docker Compose Guide](doc/English/02-SETUP_DEV/02-DOCKER/DOCKER_COMPOSE_UPDATE_SUMMARY.md)


<a name="español"></a>

<div align="center">

## 🇪🇸 Versión en Español

### **Tu Arquitecto Senior Virtual, On-Demand**
**Democratizando la Ingeniería de Software de Elite a través de IA Contextual**

[![Estado](https://img.shields.io/badge/Estado-Pre--Alpha-orange)]()
[![Tests](https://img.shields.io/badge/Tests-1286%20Pasando-success)]()
[![Cobertura](https://img.shields.io/badge/Cobertura-%E2%89%A580%25-brightgreen)]()
[![Stack](https://img.shields.io/badge/Stack-Flutter%20%7C%20Python%20%7C%20RAG-blue)]()
[![Privacidad](https://img.shields.io/badge/Privacidad-100%25%20Local--First-green)]()
[![License: GPL v3](https://img.shields.io/badge/Licencia-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

---

### 📊 Estadísticas del Proyecto

| Métrica | Valor | Métrica | Valor |
|---------|-------|---------|-------|
| 📝 **Documentación** | 460+ archivos | 🧪 **Tests** | 893 Flutter + 393 Python |
| 🎯 **Cobertura Tests** | ≥80% | 📚 **Base de Conocimiento** | 29 archivos, 934 líneas |
| 🏛️ **Arquitectura** | Clean + Hexagonal | 🔐 **Gates de Seguridad** | 16/16 aprobados |
| 🚀 **Funcionalidades** | 24 Historias de Usuario | ⚡ **Despliegue** | <2min Docker |

### 🎬 Presentaciones y Demos

📊 **[Ver Slides (GitHub Pages)](https://pitcher755.github.io/soft-architect-ai/)** | � [Código Markdown](presentation/slides.md)

</div>

#### 📚 Documentación Clave

- [📖 Índice Completo de Documentación](doc/INDEX.md) - Comienza aquí para navegación organizada
- [White Paper y Visión](doc/Español/00-VISION/CONCEPT_WHITE_PAPER.md)
- [Guía Rápida de Inicio](doc/Español/02-SETUP_DEV/01-INSTALACION/GUIA_INICIO_RAPIDO.md)
- [Guía de LLM Local](doc/Español/02-SETUP_DEV/01-INSTALACION/LOCAL_LLM_GUIDE.md) - Ejecuta IA 100% privada en tu hardware
- [Guía de Aceleración Hardware](doc/Español/02-SETUP_DEV/01-INSTALACION/HARDWARE_ACCELERATION_GUIDE.md) - Configuración GPU (NVIDIA/Apple Silicon/CPU)
- [Reporte de Pruebas Funcionales](doc/Español/01-PROJECT_REPORT/03-TESTING/FUNCTIONAL_TEST_REPORT.md)
- [Log de Instalación Inicial](doc/Español/01-PROJECT_REPORT/01-ARCHITECTURE/INITIAL_SETUP_LOG.md)
- [Metodología y Estructura](doc/Español/01-PROJECT_REPORT/10-DOCUMENTATION/MEMORIA_METODOLOGICA.md)
- [Guía de Instalación Detallada](doc/Español/02-SETUP_DEV/01-INSTALACION/GUIA_CONFIGURACION.md)
- [Stack Tecnológico](doc/Español/02-SETUP_DEV/01-INSTALACION/HERRAMIENTAS_Y_STACK.md)
- [Automatización y DevOps](doc/Español/02-SETUP_DEV/04-AUTOMATIZACION/AUTOMATIZACION.md)
- **⭐ NUEVO:** [Reporte de Knowledge Base Completada](doc/Español/01-PROJECT_REPORT/05-COMPLETION-STATUS/KNOWLEDGE_BASE_COMPLETION.md) - Fases 0-6 (29 archivos, 934 líneas)
- **⭐ NUEVO:** [Reglas Constitucionales](packages/knowledge_base/02-TECH-PACKS/) - FASE 3 (5 archivos, 3,742 líneas)
- **✅ VERIFICADO:** [Reporte de Validación Pre-Push (2026-02-12)](doc/Español/01-PROJECT_REPORT/06-VALIDATION/PRE_PUSH_VALIDATION_2026-02-12.md) - 16/16 compuertas aprobadas
- **🚀 COMPLETADO:** [HU-3.1: Implementación Shell UI del Proyecto](doc/Español/03-HU-TRACKING/HU-3.1-PROJECT-SHELL-UI-IMPLEMENTATION/README.md) - Todas 4 Fases + Seguridad ✅
- **🚧 EN PROGRESO:** [HU-3.7: Completitud UI de Settings](doc/Español/03-HU-TRACKING/HU-3.7-SETTINGS-UI-COMPLETION/README.md) - tests estabilizados, cobertura en subida
- **📊 ESTADO TESTS:** Cliente Flutter suite completa en verde + Server app con gate de cobertura ≥80% aprobado

#### 📖 Visión

SoftArchitect AI no es otro "chat de código". Es una plataforma de desarrollo asistido que guía a los desarrolladores a través de un **Workflow de Ingeniería Estricto** (Requirements → Architecture → Code → Deploy).

Actúa como un **Quality Gate** inteligente que asegura el cumplimiento de buenas prácticas (SOLID, Clean Architecture, OWASP) antes de escribir una sola línea de código, utilizando **RAG (Retrieval-Augmented Generation)** sobre una base de conocimiento académica y práctica.

#### ⚡ Inicio Rápido (5 minutos)

Levanta SoftArchitect AI localmente en menos de 5 minutos:

```bash
# 1. Clonar y navegar
git clone https://github.com/TU_USUARIO/soft-architect-ai.git
cd soft-architect-ai

# 2. Levantar todos los servicios (requiere Docker)
scripts/devops/start_stack.sh

# 3. Acceder a los servicios:
# - API: http://localhost:8000
# - Documentación API: http://localhost:8000/docs
# - ChromaDB: http://localhost:8001
# - Ollama: http://localhost:11434

# 4. Detener servicios al terminar
scripts/devops/stop_stack.sh
```

**Requisitos:** Docker 20.10+ y Docker Compose 2.0+ | **Tiempo:** ~2 minutos (primer descargar)

Para configuración detallada, solución de problemas y opciones avanzadas, consulta la [Guía de Instalación Detallada](doc/Español/02-SETUP_DEV/01-INSTALACION/GUIA_CONFIGURACION.md).

#### 🚀 Características Clave

* **🧠 RAG Contextual & Tech Packs:** Utiliza una "Enciclopedia Técnica" modular (`packages/knowledge_base/02-TECH-PACKS`) que permite al asistente entrevistar al usuario para configurar stacks específicos (Flutter, Python, Firebase) con reglas de arquitectura precisas.
* **🛡️ Local-First & Híbrido:**
    * **Modo Privacidad:** Ejecuta LLMs (Ollama) en tu red local. Tus datos nunca salen.
    * **Modo Rendimiento:** Conecta con Groq Cloud para inferencia ultrarrápida en hardware modesto.
* **🏭 Fábrica de Contexto:** Genera automáticamente la documentación técnica (`AGENTS.md`, `RULES.md`) para que tu Copilot trabaje mejor.
* **🤖 Pipelines CI/CD:** Workflows GitHub Actions inteligentes para monorepo (detecta cambios automáticamente, ejecuta solo checks relevantes).

#### 🛠️ Stack Tecnológico

* **Frontend:** Flutter (Desktop - Linux/Windows/Mac).
* **Backend:** Python (FastAPI) + LangChain.
* **IA Engine:** Ollama (Local) / Groq (Cloud).
* **Memoria:** ChromaDB (Vector Store).
* **Infra:** Docker Compose.

#### 📂 Estructura del Repositorio (Monorepo)

```text
soft-architect-ai/
├── context/                 # 🧠 Contexto para Agentes (AGENTS.md, Reglas Globales)
├── doc/                     # 📘 Documentación Viva del Proyecto (Bitácora, TFM)
├── packages/
│   └── knowledge_base/      # 🤖 El Cerebro RAG (Templates, Tech Packs, Examples)
├── src/                     # Código Fuente de las Aplicaciones
│   ├── client/              # Frontend Flutter Desktop
│   └── server/              # Backend Python API + LangChain Logic
└── infrastructure/          # Configuración Docker y DevOps (docker-compose.yml)
```

#### 🚦 Primeros Pasos

##### Requisitos Previos

* Docker & Docker Compose
* Git

##### Instalación Rápida (Dev)

1. **Clonar el repositorio:**

> Consulta la [Guía Rápida](doc/Español/02-SETUP_DEV/01-INSTALACION/GUIA_INICIO_RAPIDO.md) para instrucciones rápidas o la [Guía de Instalación Detallada](doc/Español/02-SETUP_DEV/01-INSTALACION/GUIA_CONFIGURACION.md) para pasos completos y resolución de problemas.

```bash
git clone https://github.com/TU_USUARIO/soft-architect-ai.git
cd soft-architect-ai
```

2. **Configurar Entorno (.env):**

```bash
cp .env.example .env
# Edita .env para elegir LLM_PROVIDER=local o LLM_PROVIDER=cloud
```

3. **Levantar Servicios:**

```bash
docker compose -f infrastructure/docker-compose.yml up -d
```

#### 📚 Recursos Adicionales

- [📖 Índice Completo de Documentación](doc/INDEX.md) - Portal maestro de navegación
- [Documentación de Arquitectura](context/30-ARCHITECTURE/PROJECT_STRUCTURE_MAP.es.md)
- [Reglas de Seguridad & Privacidad](context/20-REQUIREMENTS_AND_SPEC/SECURITY_AND_PRIVACY_RULES.es.md)
- [Roadmap y Fases](context/40-ROADMAP/ROADMAP_PHASES.es.md)
- [Historias de Usuario](context/40-ROADMAP/USER_STORIES_MASTER.es.json)

#### 🧪 Testing (Estructura Monorepo)

Todos los tests están centralizados en el directorio `tests/` con organización específica por lenguaje:

```bash
# Ejecutar tests de Flutter
scripts/testing/run_tests.sh flutter

# Ejecutar tests de Python
scripts/testing/run_tests.sh python

# Ejecutar todos los tests
scripts/testing/run_tests.sh all

# Generar reporte de cobertura
scripts/testing/run_tests.sh all --coverage
```

**Estructura de Tests:**
- `tests/client/unit/` - Tests unitarios de Flutter
- `tests/client/widget/` - Tests widget de Flutter
- `tests/client/integration/` - Tests de integración de Flutter
- `tests/client/e2e/` - Tests E2E de Flutter
- `tests/server/` - Tests Python (unit/integration)

Consulta [tests/README.md](tests/README.md) para documentación detallada sobre testing y estructura.

#### 🚀 Despliegue y Producción

##### Despliegue con Docker (Recomendado)

Despliega todos los servicios con un solo comando:

```bash
# Levantar todos los servicios (API, ChromaDB, Ollama)
./scripts/devops/start_stack.sh

# Los servicios estarán disponibles en:
# - API: http://localhost:8000
# - Documentación API: http://localhost:8000/docs
# - ChromaDB Admin: http://localhost:8001
# - Ollama: http://localhost:11434
```

##### Ingesta de Base de Conocimiento

Antes del primer uso, ingesta la base de conocimiento técnico:

```bash
# 1. Asegurarse de que los servicios están corriendo
docker ps  # Debe mostrar sa_api, sa_chromadb, sa_ollama

# 2. Ingestar base de conocimiento (Tech Packs + Templates)
curl -X POST http://localhost:8000/api/v1/knowledge/ingest \
  -H "Content-Type: application/json" \
  -d '{"path": "packages/knowledge_base"}'

# 3. Verificar ingesta
curl http://localhost:8000/api/v1/knowledge/status

# Respuesta esperada:
# {
#   "status": "ready",
#   "documents": 29,
#   "vectors": 934,
#   "collections": ["tech-packs", "templates", "examples"]
# }
```

##### Checklist de Producción

- [ ] Configurar `.env` con ajustes de producción
- [ ] Habilitar HTTPS con proxy reverso (Nginx/Traefik)
- [ ] Configurar `LLM_PROVIDER=cloud` para mejor rendimiento
- [ ] Configurar estrategia de backup para `infrastructure/data/`
- [ ] Configurar monitoreo (logs en `infrastructure/logs/`)
- [ ] Revisar [Política de Seguridad](context/SECURITY_HARDENING_POLICY.es.md)

**Guías de Despliegue:**
- [📖 Log de Despliegue Docker](doc/Español/02-SETUP_DEV/02-DOCKER/DOCKER_SETUP_LOG.md)
- [🔧 Aceleración Hardware](doc/Español/02-SETUP_DEV/01-INSTALACION/HARDWARE_ACCELERATION_GUIDE.md)
- [🐳 Guía Docker Compose](doc/Español/02-SETUP_DEV/02-DOCKER/DOCKER_COMPOSE_UPDATE_SUMMARY.md)

---

**Proyecto de Tesis de Máster - Máster en Desarrollo con IA**
