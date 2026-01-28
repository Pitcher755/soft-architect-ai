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
│   ├── config.py            # Settings y environment
│   ├── database.py          # Conexión ChromaDB
│   └── security.py          # Sanitizers y validators
├── api/                     # API routes
│   ├── v1/                  # Endpoints versionados
│   │   ├── chat.py          # Chat y streaming
│   │   ├── knowledge.py     # Ingestion y retrieval
│   │   └── health.py        # Health checks
│   └── dependencies.py      # Dependencias compartidas
├── domain/                  # Lógica de negocio
│   ├── entities/            # Entidades core (Message, Session)
│   ├── services/            # Use cases y reglas de negocio
│   └── repositories/        # Interfaces de datos abstractas
├── infrastructure/          # Integraciones externas
│   ├── llm/                 # Proveedores LLM (Ollama, Groq)
│   ├── vector_store/        # Implementación ChromaDB
│   └── external/            # APIs de terceros
└── tests/                   # Suite de tests
    ├── unit/                # Unit tests
    ├── integration/         # Integration tests
    └── fixtures/            # Datos de test

```

---

## 4. Detalle: `packages/knowledge_base/` (Cerebro RAG)

Estructura de conocimiento modular para consumo de IA.

```text
packages/knowledge_base/
├── 00-META-CONTEXT/         # Personalidad del sistema y visión
├── 01-TEMPLATES/            # Templates reutilizables (ADRs, Security)
├── 02-TECH-PACKS/           # Reglas específicas de tecnología
│   ├── flutter/             # Mejores prácticas Flutter
│   ├── python/              # Patrones Python
│   └── general/             # Preocupaciones transversales
└── 03-EXAMPLES/             # Proyectos de referencia

```

---

## 5. Detalle: `context/` (Contexto para Agentes)

Documentación estructurada para agentes de IA.

```text
context/
├── 10-BUSINESS_AND_SCOPE/   # Visión, MVP, Requisitos
├── 20-REQUIREMENTS_AND_SPEC/ # Specs, Seguridad, Testing
├── 30-ARCHITECTURE/         # Stack, Mapas, Design System
└── 40-ROADMAP/              # GitFlow, Fases, Backlog

```

---

## 6. Detalle: `doc/` (Documentación Humana)

Documentación viva del proyecto.

```text
doc/
├── 00-VISION/               # White Paper, Concepto
├── 01-PROJECT_REPORT/       # Metodología, POC
├── 02-SETUP_DEV/            # Guías, Stack, Automatización
└── private/                 # Notas internas (no para IA)

```

---

## 7. Detalle: `infrastructure/` (DevOps)

Configs de despliegue y orquestación.

```text
infrastructure/
├── docker-compose.yml       # Desarrollo local
├── nginx.conf               # Reverse proxy (futuro)
└── scripts/                 # Scripts de build y deploy

```

---

## 8. Convenciones de Nombres

* **Directorios:** `snake_case` para técnicos, `PascalCase` para features.
* **Archivos:** `PascalCase.md` para docs, `snake_case.py` para código.
* **Variables:** `camelCase` en Dart, `snake_case` en Python.
* **Commits:** Conventional commits (`feat:`, `fix:`, `docs:`).