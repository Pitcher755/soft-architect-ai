# 🏗️ SoftArchitect AI

**🌍 Languages:** [🇬🇧 English](#english) | [🇪🇸 Español](#español)

---

<a name="english"></a>

## 🇬🇧 English Version

### 🏗️ SoftArchitect AI

> **Your Virtual Senior Architect (On-Demand).**
> Democratizing high-level software engineering through Contextual Artificial Intelligence.

[![Status](https://img.shields.io/badge/Status-Pre--Alpha-orange)]()
[![Stack](https://img.shields.io/badge/Stack-Flutter%20%7C%20Python%20%7C%20RAG-blue)]()
[![Privacy](https://img.shields.io/badge/Privacy-Local--First-green)]()
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

### 🇬🇧 English Version

#### 📚 Key Documentation

- [White Paper & Vision](doc/00-VISION/CONCEPT_WHITE_PAPER.en.md)
- [Quick Start Guide](doc/02-SETUP_DEV/QUICK_START_GUIDE.en.md)
- [Functional Test Report](doc/01-PROJECT_REPORT/FUNCTIONAL_TEST_REPORT.md)
- [Initial Setup Log](doc/01-PROJECT_REPORT/INITIAL_SETUP_LOG.en.md)
- [Methodology & Structure](doc/01-PROJECT_REPORT/MEMORIA_METODOLOGICA.en.md)
- [Detailed Setup Guide](doc/02-SETUP_DEV/SETUP_GUIDE.en.md)
- [Technology Stack](doc/02-SETUP_DEV/TOOLS_AND_STACK.en.md)
- [Automation & DevOps](doc/02-SETUP_DEV/AUTOMATION.en.md)
- **⭐ NEW:** [Knowledge Base Completion Report](doc/01-PROJECT_REPORT/KNOWLEDGE_BASE_COMPLETION.md) - Phases 0-6 (29 files, 934 lines)
- **⭐ NEW:** [Constitutional Rules](packages/knowledge_base/02-TECH-PACKS/) - FASE 3 (5 files, 3,742 lines)
- **🚀 COMPLETED:** [HU-3.1: Project Shell UI](doc/03-HU-TRACKING/HU-3.1-PROJECT-SHELL-UI-IMPLEMENTATION/README.md) - All 4 Phases + Security ✅

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
./start_stack.sh

# 3. Access services:
# - API: http://localhost:8000
# - API Docs: http://localhost:8000/docs
# - ChromaDB: http://localhost:8001
# - Ollama: http://localhost:11434

# 4. Stop services when done
./stop_stack.sh
```

**Requirements:** Docker 20.10+ and Docker Compose 2.0+ | **Time:** ~2 minutes (first-time pull)

For detailed setup, troubleshooting, and advanced configuration, see [Detailed Setup Guide](doc/02-SETUP_DEV/SETUP_GUIDE.en.md).

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

> See the [Quick Start Guide](doc/02-SETUP_DEV/QUICK_START_GUIDE.en.md) for quick instructions or the [Detailed Setup Guide](doc/02-SETUP_DEV/SETUP_GUIDE.en.md) for complete steps and troubleshooting.

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

- [Architecture Documentation](context/30-ARCHITECTURE/PROJECT_STRUCTURE_MAP.en.md)
- [Security & Privacy Rules](context/20-REQUIREMENTS_AND_SPEC/SECURITY_AND_PRIVACY_RULES.en.md)
- [Roadmap & Phases](context/40-ROADMAP/ROADMAP_PHASES.en.md)
- [User Stories](context/40-ROADMAP/USER_STORIES_MASTER.en.json)

---

<a name="español"></a>

## 🇪🇸 Versión en Español

### 🏗️ SoftArchitect AI

> **Tu Arquitecto Senior Virtual (On-Demand).**
> Democratizando la ingeniería de software de alto nivel mediante Inteligencia Artificial Contextual.

[![Estado](https://img.shields.io/badge/Estado-Pre--Alpha-orange)]()
[![Stack](https://img.shields.io/badge/Stack-Flutter%20%7C%20Python%20%7C%20RAG-blue)]()
[![Privacidad](https://img.shields.io/badge/Privacidad-Local--First-green)]()
[![License: GPL v3](https://img.shields.io/badge/Licencia-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

#### 📚 Documentación Clave

- [White Paper y Visión](doc/00-VISION/CONCEPT_WHITE_PAPER.es.md)
- [Guía Rápida de Inicio](doc/02-SETUP_DEV/QUICK_START_GUIDE.es.md)
- [Reporte de Pruebas Funcionales](doc/01-PROJECT_REPORT/FUNCTIONAL_TEST_REPORT.md)
- [Log de Instalación Inicial](doc/01-PROJECT_REPORT/INITIAL_SETUP_LOG.es.md)
- [Metodología y Estructura](doc/01-PROJECT_REPORT/MEMORIA_METODOLOGICA.es.md)
- [Guía de Instalación Detallada](doc/02-SETUP_DEV/SETUP_GUIDE.es.md)
- [Stack Tecnológico](doc/02-SETUP_DEV/TOOLS_AND_STACK.es.md)
- [Automatización y DevOps](doc/02-SETUP_DEV/AUTOMATION.es.md)
- **⭐ NUEVO:** [Reporte de Knowledge Base Completada](doc/01-PROJECT_REPORT/KNOWLEDGE_BASE_COMPLETION.md) - Fases 0-6 (29 archivos, 934 líneas)

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
./start_stack.sh

# 3. Acceder a los servicios:
# - API: http://localhost:8000
# - Documentación API: http://localhost:8000/docs
# - ChromaDB: http://localhost:8001
# - Ollama: http://localhost:11434

# 4. Detener servicios al terminar
./stop_stack.sh
```

**Requisitos:** Docker 20.10+ y Docker Compose 2.0+ | **Tiempo:** ~2 minutos (primer descargar)

Para configuración detallada, solución de problemas y opciones avanzadas, consulta la [Guía de Instalación Detallada](doc/02-SETUP_DEV/SETUP_GUIDE.es.md).

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

> Consulta la [Guía Rápida](doc/02-SETUP_DEV/QUICK_START_GUIDE.es.md) para instrucciones rápidas o la [Guía de Instalación Detallada](doc/02-SETUP_DEV/SETUP_GUIDE.es.md) para pasos completos y resolución de problemas.

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

- [Documentación de Arquitectura](context/30-ARCHITECTURE/PROJECT_STRUCTURE_MAP.es.md)
- [Reglas de Seguridad & Privacidad](context/20-REQUIREMENTS_AND_SPEC/SECURITY_AND_PRIVACY_RULES.es.md)
- [Roadmap y Fases](context/40-ROADMAP/ROADMAP_PHASES.es.md)
- [Historias de Usuario](context/40-ROADMAP/USER_STORIES_MASTER.es.json)

---

**Master's Thesis Project - Master's Degree in Development with AI**
