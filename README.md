# 🏗️ SoftArchitect AI

> **Tu Arquitecto Senior Virtual (On-Demand).**
> Democratizando la ingeniería de software de alto nivel mediante Inteligencia Artificial Contextual.

[![Status](https://img.shields.io/badge/Status-Pre--Alpha-orange)]()
[![Stack](https://img.shields.io/badge/Stack-Flutter%20%7C%20Python%20%7C%20RAG-blue)]()
[![Privacy](https://img.shields.io/badge/Privacy-Local--First-green)]()
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

## 📚 Documentación Clave

- [White Paper y Visión](doc/00-VISION/CONCEPT_WHITE_PAPER.es.md)
- [Guía Rápida de Inicio](doc/02-SETUP_DEV/QUICK_START_GUIDE.es.md)
- [Reporte de Pruebas Funcionales](doc/01-PROJECT_REPORT/FUNCTIONAL_TEST_REPORT.md)
- [Log de Instalación Inicial](doc/01-PROJECT_REPORT/INITIAL_SETUP_LOG.es.md)
- [Metodología y Estructura](doc/01-PROJECT_REPORT/MEMORIA_METODOLOGICA.es.md)
- [Guía de Instalación Detallada](doc/02-SETUP_DEV/SETUP_GUIDE.es.md)
- [Stack Tecnológico](doc/02-SETUP_DEV/TOOLS_AND_STACK.es.md)
- [Automatización y DevOps](doc/02-SETUP_DEV/AUTOMATION.es.md)

## 📖 Visión

SoftArchitect AI no es otro "chat de código". Es una plataforma de desarrollo asistido que guía a los desarrolladores a través de un **Workflow de Ingeniería Estricto** (Requirements → Architecture → Code → Deploy).

Actúa como un **Quality Gate** inteligente que asegura el cumplimiento de buenas prácticas (SOLID, Clean Architecture, OWASP) antes de escribir una sola línea de código, utilizando **RAG (Retrieval-Augmented Generation)** sobre una base de conocimiento académica y práctica.

## 🚀 Características Clave

* **🧠 RAG Contextual & Tech Packs:** Utiliza una "Enciclopedia Técnica" modular (`packages/knowledge_base/02-TECH-PACKS`) que permite al asistente entrevistar al usuario para configurar stacks específicos (Flutter, Python, Firebase) con reglas de arquitectura precisas.
* **🛡️ Local-First & Híbrido:**
    * **Modo Privacidad:** Ejecuta LLMs (Ollama) en tu red local. Tus datos nunca salen.
    * **Modo Rendimiento:** Conecta con Groq Cloud para inferencia ultrarrápida en hardware modesto.
* **🏭 Fábrica de Contexto:** Genera automáticamente la documentación técnica (`AGENTS.md`, `RULES.md`) para que tu Copilot trabaje mejor.

## 🛠️ Stack Tecnológico

* **Frontend:** Flutter (Desktop - Linux/Windows/Mac).
* **Backend:** Python (FastAPI) + LangChain.
* **IA Engine:** Ollama (Local) / Groq (Cloud).
* **Memoria:** ChromaDB (Vector Store).
* **Infra:** Docker Compose.

## 📂 Estructura del Repositorio (Monorepo)

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

## 🚦 Primeros Pasos

### Requisitos Previos

* Docker & Docker Compose
* Git

### Instalación Rápida (Dev)

1. **Clonar el repositorio:**

> Consulta la [Guía Rápida](doc/02-SETUP_DEV/QUICK_START_GUIDE.es.md) para instrucciones rápidas o la [Guía de Instalación Detallada](doc/02-SETUP_DEV/SETUP_GUIDE.es.md) para pasos completos y resolución de problemas.

```bash
git clone [https://github.com/TU_USUARIO/soft-architect-ai.git](https://github.com/TU_USUARIO/soft-architect-ai.git)
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

---

**Proyecto TFM - Máster en Desarrollo con IA**

