# 🗺️ Mapa de Estructura del Proyecto (Monorepo)

> **Regla de Oro:** "Un lugar para cada cosa, y cada cosa en su lugar". La estructura es inmutable sin discusión arquitectónica previa.

---

## 1. Nivel Raíz (The Root)

```text
soft-architect-ai/
├── .env.example             # Plantilla de variables de entorno (NO secrets)
├── docker-compose.yml       # Orquestación de servicios
├── README.md                # Portada del proyecto
├── context/                 # 🧠 METADATA: Reglas y Contexto para Agentes
├── doc/                     # 📘 HUMANOS: Bitácora, ADRs y Guías
├── infrastructure/          # ⚙️ DEVOPS: Configs de Docker, Nginx, Scripts
├── packages/
│   └── knowledge_base/      # 🤖 RAG ASSETS: El cerebro inyectable
└── src/                     # 💻 CÓDIGO: La implementación real

```

---

## 2. Detalle: `src/client` (Flutter App)

Seguimos **Clean Architecture** orientada a Features ("Feature-First").

```text
src/client/lib/
├── main.dart                # Entry Point
├── core/                    # Componentes compartidos y configuración
│   ├── config/              # Env vars, Theme config
│   ├── router/              # Configuración de GoRouter
│   └── utils/               # Helpers puros
├── features/                # Módulos funcionales
│   ├── chat/                # Feature principal
│   │   ├── data/            # Repositorios (Impl) y Datasources (API)
│   │   ├── domain/          # Entidades y Contratos (Interfaces)
│   │   └── presentation/    # Widgets, Screens y Providers (Riverpod)
│   ├── settings/            # Configuración de modelos (Local/Cloud)
│   └── knowledge/           # Gestión de la base de conocimiento
└── shared/                  # Widgets UI reutilizables (Botones, Inputs)

```

---

## 3. Detalle: `src/server` (Python Backend)

Arquitectura de **Modular Monolith** basada en dominios.

```text
src/server/app/
├── main.py                  # Entry Point FastAPI
├── core/                    # Configuración global
│   ├── config.py            # Pydantic Settings (Lee .env)
│   └── security.py          # Sanitización de inputs
├── services/                # Lógica de Negocio Pura
│   ├── llm_service.py       # Interfaz con LangChain
│   └── vector_store.py      # Interfaz con ChromaDB
├── api/                     # Capa de transporte (REST)
│   ├── v1/
│   │   ├── endpoints/       # Routers (chat.py, ingestion.py)
│   │   └── dependencies.py  # Inyección de dependencias
└── schemas/                 # Pydantic Models (DTOs) para Request/Response

```

---

## 4. Detalle: `packages/knowledge_base` (RAG Brain)

El conocimiento que ingesta el sistema.

```text
packages/knowledge_base/
├── 00-META-CONTEXT/         # Filosofía del Arquitecto
├── 01-TEMPLATES/            # Plantillas vacías para generar (STRIDE, ADR)
├── 02-TECH-PACKS/           # Reglas por tecnología
│   ├── flutter/             # Reglas Flutter Clean Arch
│   └── python-fastapi/      # Reglas Python Backend
└── 03-EXAMPLES/             # Código de referencia (One-shot learning)

```

