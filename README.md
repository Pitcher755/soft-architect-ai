# 🏗️ SoftArchitect AI

> **Tu Arquitecto Senior Virtual (On-Demand).**
> Democratizando la ingeniería de software de alto nivel mediante Inteligencia Artificial Contextual.

[![Status](https://img.shields.io/badge/Status-Pre--Alpha-orange)]()
[![Stack](https://img.shields.io/badge/Stack-Flutter%20%7C%20Python%20%7C%20RAG-blue)]()
[![Privacy](https://img.shields.io/badge/Privacy-Local--First-green)]()
[![License: GPL v3](https://img.shields.io/badge/License-GPLv3-blue.svg)](https://www.gnu.org/licenses/gpl-3.0)

## 📖 Visión

SoftArchitect AI no es otro "chat de código". es una plataforma de desarrollo asistido que guía a los desarrolladores a través de un **Workflow de Ingeniería Estricto** (Requirements → Architecture → Code → Deploy).

Actúa como un **Quality Gate** inteligente que asegura el cumplimiento de buenas prácticas (SOLID, Clean Architecture, OWASP) antes de escribir una sola línea de código, utilizando **RAG (Retrieval-Augmented Generation)** sobre una base de conocimiento académica y práctica.

## 🚀 Características Clave

* **🧠 RAG Contextual:** No da consejos genéricos. Entiende tu stack y fase del proyecto gracias a "Tech Packs" especializados.
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
├── apps/               # Código Fuente de las Aplicaciones
│   ├── api-server/     # Backend Python + RAG Logic
│   └── client-desktop/ # Frontend Flutter
├── packages/
│   └── docs/           # 🧠 El Cerebro (Documentación Viva & Knowledge Base)
└── infra/              # Configuración Docker y DevOps

```

## 🚦 Primeros Pasos

### Requisitos Previos

* Docker & Docker Compose
* Git

### Instalación Rápida (Dev)

1. **Clonar el repositorio:**
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
docker compose up -d

```



---

**Proyecto TFM - Máster en Desarrollo con IA**

