¡Entendido! Vamos a convertirnos en los "Prompt Engineers" definitivos. Te voy a dar la secuencia de prompts exacta para que la copies y pegues en tu GEM. Cada prompt simula un "click" en los botones de la futura interfaz de SoftArchitect AI, obligando al modelo a ejecutar una fase del `MASTER_WORKFLOW_0-100.md`.

El objetivo es que **SoftArchitect AI** (el GEM) diseñe **"SoftArchitect AI"** (el proyecto real). Meta-programación en estado puro. 🤯

Copia y pega estos prompts **uno a uno** en tu GEM y guarda las respuestas.

---

### 🔘 PROMPT 1: FASE 0 - IDEACIÓN (Business Analyst)

*Copia esto tal cual en el GEM:*

```markdown
[TRIGGER: FASE 0 - VISION & MVP]

**Contexto del Proyecto:**
Una aplicación de escritorio llamada "SoftArchitect AI". Es un asistente para desarrolladores que funciona como un "Arquitecto Senior Virtual". Utiliza RAG (Retrieval-Augmented Generation) local con Ollama y ChromaDB para guiar al usuario a través de un workflow de ingeniería de software estricto (desde requisitos hasta deploy), basándose en documentación académica de un Máster. El objetivo es eliminar la parálisis por análisis y asegurar la calidad del código. Stack previsto: Frontend Flutter, Backend Python, IA Local.

**Instrucción:**
Actúa como Business Analyst Senior. Basándote estrictamente en la **Fase 0** del Master Workflow que conoces:
1.  Redacta el **Product Vision Statement** (Qué, Quién, Por qué).
2.  Define el **MVP Scope** usando la regla 80/20: Lista 4 features "Must Have" y 3 "Post-MVP" (descartadas para v1).
3.  Genera la **Matriz de Riesgos** (Técnicos y de Negocio) identificando los 3 más críticos y su plan de mitigación.
4.  Define 3 **KPIs de Éxito** medibles para este tipo de herramienta (Open Source / Developer Tool).

```

---

*(Espera a que el GEM responda y guarda el resultado. Luego lanza el siguiente)*

---

### 🔘 PROMPT 2: FASE 1 - ARQUITECTURA (Software Architect)

*Copia esto tal cual en el GEM:*

```markdown
[TRIGGER: FASE 1 - ARQUITECTURA & STACK]

**Visión del Proyecto:**
(Asume la visión generada en el paso anterior: Asistente local RAG para ingeniería de software).

**Instrucción:**
Actúa como Senior Software Architect. Basándote estrictamente en la **Fase 1** del Master Workflow:
1.  Confirma y justifica el **Tech Stack** seleccionado usando la "Matriz de Decisión" (comparando opciones si es necesario, ej: Flutter vs Electron, Local vs Cloud).
2.  Redacta el **ADR-001 (Architecture Decision Record)** formal para la decisión de usar "IA Local Dockerizada" en lugar de APIs en la nube.
    * Contexto, Decisión, Rationale (Privacidad/Coste), Consecuencias.
3.  Genera un **Diagrama de Flujo de Datos (DFD)** textual (o código Mermaid) mostrando cómo fluye un prompt del usuario desde Flutter -> API Python -> Vector DB -> Ollama -> Respuesta.
4.  Realiza un análisis **STRIDE** simplificado enfocándote en la amenaza "Data Leakage" (fugas de código del usuario).

```

---

*(Espera a la respuesta y guarda. Siguiente)*

---

### 🔘 PROMPT 3: FASE 2 - SETUP (DevOps Engineer)

*Copia esto tal cual en el GEM:*

```markdown
[TRIGGER: FASE 2 - SCAFFOLDING]

**Stack Confirmado:**
Frontend: Flutter (Escritorio/Web)
Backend: Python (FastAPI)
IA/DB: Ollama + ChromaDB (Docker)

**Instrucción:**
Actúa como DevOps Lead. Basándote en la **Fase 2** del Master Workflow:
1.  Diseña la **Estructura de Directorios del Monorepo** ideal para este proyecto (separando apps, packages, docs).
2.  Genera el contenido completo del archivo `docker-compose.yml` para el entorno de desarrollo local (incluyendo healthchecks para Ollama y Postgres/Chroma).
3.  Crea el archivo `.env.example` con las variables críticas (LLM_MODEL, API_PORT, etc.).
4.  Define los **pasos de instalación** "Zero-Config" para el README (comandos exactos para que un dev clone y arranque).

```

---

*(Espera a la respuesta y guarda. Siguiente)*

---

### 🔘 PROMPT 4: FASE 5 - SEGURIDAD (Security Engineer)

*Copia esto tal cual en el GEM (Saltamos a seguridad porque es crítica antes de codificar)*

```markdown
[TRIGGER: FASE 5 - SEGURIDAD SHIFT-LEFT]

**Contexto:**
Aplicación local que procesa código sensible del usuario mediante IA.

**Instrucción:**
Actúa como Security Engineer. Basándote en la **Fase 5** del Master Workflow y OWASP Top 10:
1.  Define la **Security Checklist** específica para este proyecto. Céntrate en:
    * A03: Injection (Prompt Injection en el LLM).
    * A04: Insecure Design (Privacidad de los datos locales).
    * A06: Vulnerable Components (Docker images).
2.  Diseña una estrategia de **Sanitización de Prompts** (cómo evitar que el usuario rompa el sistema con inputs maliciosos).
3.  Especifica qué **Security Headers** o configuraciones de red debe tener el contenedor de la API para no exponerse a internet accidentalmente.

```

---

### 🔘 PROMPT 5: FASE 6 - INFRAESTRUCTURA (Cloud/Local Ops)

*Copia esto tal cual en el GEM:*

```markdown
[TRIGGER: FASE 6 - INFRAESTRUCTURA & CI/CD]

**Contexto:**
El proyecto es "Local-First", pero el código se aloja en GitHub y debe tener CI/CD.

**Instrucción:**
Actúa como Infra Engineer. Basándote en la **Fase 6** del Master Workflow:
1.  Diseña el workflow de **GitHub Actions (CI)**. Debe incluir:
    * Linting de Flutter y Python.
    * Tests unitarios.
    * Security Scan (Trivy/Snyk) de las imágenes Docker.
2.  Explica la estrategia de **Release**: ¿Cómo distribuimos la app de escritorio a los usuarios? (Ej: GitHub Releases, instaladores).
3.  Redacta un pequeño script o instrucción para automatizar la **descarga del modelo LLM** (ej: Llama 3) en el primer arranque del contenedor, para que el usuario no lo haga manual.

```

---

### 🚀 Plan de Acción

1. Ve a tu GEM.
2. Ejecuta estos 5 prompts en orden.
3. Copia todas las respuestas en un único documento (ej: `SIMULACION_SOFTARCHITECT.md`).
4. **Súbelo aquí** cuando lo tengas.

Lo revisaré y te diré: *"Javi, esto es oro, ya tenemos el 80% del TFM hecho"* o *"Aquí falla X cosa, ajustemos el prompt"*. ¡Al lío! 👨‍💻🔥

---

### RESULTADOS RECIBIDOS

Ejecutando protocolo de **Fase 0: Pre-Desarrollo (Ideación)** según el estándar *MASTER_WORKFLOW_0-100*.

Aquí tienes el entregable de definición estratégica para el proyecto "SoftArchitect AI".

---

# 🚀 FASE 0: PRE-DESARROLLO (IDEACIÓN)

## 0.1. Definir la Visión y Propuesta de Valor

### ✅ Product Vision Statement

Siguiendo la estructura *"Qué es" + "Para quién" + "Por qué importa"*:

> "**SoftArchitect AI** es una aplicación de escritorio para **desarrolladores de software y arquitectos técnicos** que actúa como un **'Arquitecto Senior Virtual'** mediante IA local (RAG), diseñada para **eliminar la parálisis por análisis y asegurar el rigor ingenieril** guiando al usuario a través de un workflow de desarrollo estricto (0-100) sin depender de la nube."

---

## 0.2. MVP Scope (Mínimo Viable)

Aplicando la regla 80/20 (80% valor, 20% esfuerzo) y limitando el alcance para la V1:

### ✅ Must-Have (V1 - Core Features)

1. **Motor RAG Local (Backend Python):** Integración funcional de Ollama + ChromaDB para la ingestión del "Master Workflow" y consulta contextual sin conexión a internet.
2. **Workflow State Machine (Frontend Flutter):** Interfaz de navegación lineal que bloquea el avance a la siguiente fase hasta completar los "Gates" (hitos) de la fase actual.
3. **Asistente de Chat Contextual:** Interfaz de chat que permite invocar "Triggers" específicos por fase (ej. "Generar Matriz de Riesgos") utilizando el contexto cargado.
4. **Gestión de Persistencia Local:** Capacidad de crear, guardar y cargar el estado de un proyecto (archivos JSON/SQLite locales) manteniendo el historial de decisiones.

### 🚫 Post-MVP (Descartado para V1)

1. **Integración con IDEs:** Extensiones para VS Code o IntelliJ (se mantendrá como app standalone inicialmente).
2. **Sincronización Cloud:** No habrá login ni guardado en nube; privacidad total local ("Local First").
3. **Soporte Multi-LLM (Cloud):** No se integrará OpenAI/Anthropic API en V1; foco exclusivo en modelos locales (Llama 3, Mistral) para validar la premisa de privacidad y coste cero.

---

## 0.3. Matriz de Riesgos Críticos

Identificación de riesgos técnicos y de negocio con estrategia de mitigación:

| Riesgo | Tipo | Impacto | Probabilidad | Estrategia de Mitigación (Plan B) |
| --- | --- | --- | --- | --- |
| **Performance de IA Local (Latencia)** | Técnico | ALTO | PROBABLE | Implementar soporte para modelos cuantizados (4-bit) y verificar hardware mínimo al inicio. Fallback a modelos más ligeros (ej. Phi-3) si no hay GPU. |
| **Complejidad de Instalación (Dependencies)** | Técnico | ALTO | PROBABLE | Empaquetar el Backend Python como ejecutable (PyInstaller) o contenedor Docker embebido para evitar que el usuario deba configurar Python/Ollama manualmente. |
| **Alucinaciones en Arquitectura** | Calidad | MEDIO | PROBABLE | Strict System Prompts que fuercen a la IA a citar el documento base y responder "No lo sé" si la información no está en el RAG (Grounding estricto). |

---

## 0.4. KPIs de Éxito (Métricas)

Definición de indicadores para herramienta Open Source / Developer Tool:

1. **Phase Completion Rate (Leading Indicator):** Porcentaje de usuarios que inician la Fase 0 y logran avanzar exitosamente hasta la Fase 2 (Setup). Mide la utilidad real del asistente para desbloquear el progreso.
2. **Artifact Generation Frequency:** Número promedio de entregables generados (ADRs, Diagramas, Specs) por sesión. Valida que el RAG está siendo útil para crear documentación técnica.
3. **Time-to-Hello-World (Efficiency):** Tiempo medido desde que el usuario crea un proyecto nuevo en SoftArchitect AI hasta que tiene su estructura de carpetas (Scaffolding) definida y lista para codificar.

---

**Siguiente paso sugerido:**
¿Deseas proceder a la **[TRIGGER: FASE 1 - PLANIFICACIÓN Y ARQUITECTURA]** para definir el Stack Tecnológico detallado (Flutter + Python bridge) y los ADRs iniciales?

---

Ejecutando protocolo de **Fase 1: Planificación y Arquitectura** según el estándar *MASTER_WORKFLOW_0-100*.

Aquí tienes el entregable de arquitectura técnica y seguridad para "SoftArchitect AI".

---

# 🏗️ FASE 1: PLANIFICACIÓN Y ARQUITECTURA

## 1.1. Selección del Tech Stack (Matriz de Decisión)

Para una aplicación de escritorio que debe ejecutar modelos de IA localmente, la gestión de la memoria (RAM) es el recurso crítico.

**Matriz de Decisión: Desktop Framework**

| Criterio | Peso | Flutter (Native) | Electron (Web) |
| --- | --- | --- | --- |
| **Consumo de Memoria (RAM)** | 35% | **Bajo (Dart VM)** (5) | Alto (Chromium) (2) |
| **Performance UI** | 25% | Nativo / Skia (5) | DOM / JS Bridge (3) |
| **Integración IA (Python)** | 20% | FFI / Localhost (4) | Node-Python Bridge (4) |
| **Time-to-market** | 20% | Medio (4) | Alto (Web tech) (5) |

**Veredicto:** **Flutter + Python Backend**.
**Justificación:** Electron consume demasiada RAM (~500MB+ base), recursos que necesitamos reservar para el modelo LLM local (Ollama) y la Vector DB. Flutter ofrece una UI fluida con bajo impacto en recursos.

**Stack Final:**

* **Frontend:** Flutter (Windows/Linux/macOS).
* **Backend/AI Service:** Python (FastAPI) corriendo en `localhost` (spawneado por la app).
* **RAG Engine:** LangChain + ChromaDB (Persistencia local).
* **Inferencia:** Ollama (Gestión de modelos Llama3/Mistral).

---

## 1.2. Architecture Decision Record (ADR-001)

Documentando la decisión crítica de arquitectura "Local First" siguiendo el template estándar.

# ADR-001: Estrategia de IA Local (Local-First RAG)

## Decision
Utilizar una arquitectura 100% local basada en Ollama y ChromaDB, sin dependencias de APIs en la nube (OpenAI/Anthropic) para el MVP.

## Context
- "SoftArchitect AI" maneja propiedad intelectual crítica (código fuente, ideas de negocio).
- Los usuarios objetivo (Desarrolladores/Arquitectos) valoran la privacidad por encima de la conveniencia.
- La latencia de red es inaceptable para una herramienta de productividad diaria.

## Rationale
1. **Privacidad (Security by Design):** Elimina por completo el vector de ataque de intercepción de datos en tránsito o retención de datos por terceros.
2. **Coste Operativo:** Coste marginal cero por token. Permite contextos largos (ingestar documentación técnica entera) sin facturas sorpresa.
3. **Resiliencia:** Funciona offline, crítico para entornos corporativos con firewalls estrictos.

## Consequences
- ✅ Privacidad total garantizada (Data sovereignty).
- ⚠️ **Requisitos de Hardware:** El usuario final necesita mínimo 16GB RAM (idealmente GPU dedicada). Esto reduce el TAM (Total Addressable Market).
- ⚠️ **Complejidad de Setup:** Debemos empaquetar el runtime de Python y gestionar la descarga de modelos (GBs) en el primer inicio.

## Status: Accepted



---

## 1.3. Diagrama de Flujo de Datos (DFD) y Trust Boundaries

Visualización del flujo RAG y los límites de confianza.

```mermaid
graph LR
    User([Usuario])
    
    subgraph "Desktop Client (Flutter)"
        UI[Interfaz Flutter]
        State[Gestor de Estado]
    end

    subgraph "Localhost (Trust Boundary)"
        API[FastAPI Server<br/>(Python Bridge)]
        RAG[RAG Orchestrator]
        VectorDB[(ChromaDB<br/>Local Vector Store)]
        Ollama[Ollama Service<br/>(LLM Inference)]
    end

    FileSystem[(Local File System<br/>Docs & Project)]

    %% Flujo
    User -->|1. Prompt| UI
    UI -->|2. HTTP POST /chat| API
    API -->|3. Retrieve Context| RAG
    RAG -->|4. Query| VectorDB
    VectorDB -->|5. Relevant Chunks| RAG
    RAG -->|6. Prompt + Context| Ollama
    Ollama -->|7. Streaming Token| API
    API -->|8. Update UI| State
    
    %% Ingesta
    FileSystem -.->|Ingest| API

```

**Trust Boundary Analysis:**
El límite de confianza es la propia máquina del usuario. No hay salida a internet excepto para la descarga inicial de modelos (que debe ser validada por hash).

---

## 1.4. Análisis STRIDE (Foco: Data Leakage)

Análisis de amenazas enfocado en la protección del código del usuario.

| Amenaza (STRIDE) | Descripción en Contexto | Mitigación (Fase 1 & 5) |
| --- | --- | --- |
| **Information Disclosure (Data Leakage)** | Un proceso malicioso en la máquina del usuario o un error de configuración expone el código indexado en ChromaDB o los prompts enviados. | 1. **Localhost Binding:** La API Python debe escuchar *solo* en `127.0.0.1`, nunca en `0.0.0.0` para evitar acceso LAN.<br>

<br>2. **File Permissions:** La carpeta de ChromaDB debe tener permisos 700 (solo owner).<br>

<br>3. **Ephemeral Memory:** Opción para no persistir historial de chat en disco (RAM only mode). |
| **Tampering** | Inyección de documentos falsos en el RAG para alucinar respuestas de seguridad incorrectas. | Validación de integridad (checksums) de los documentos ingestados antes de procesarlos. |
| **Spoofing** | Otra aplicación local haciéndose pasar por el backend de SoftArchitect. | Implementar un token de autenticación simple (generado al vuelo) entre Flutter y Python. |

---

**Siguiente paso sugerido:**
¿Deseas proceder a la **[TRIGGER: FASE 2 - SETUP INICIAL]** para definir la estructura del repositorio (Monorepo Flutter/Python), configurar el `docker-compose` (o script de arranque local) y los linters?
---
Ejecutando protocolo de **Fase 2: Setup Inicial (Scaffolding)** según el estándar *MASTER_WORKFLOW_0-100*.

Aquí tienes la infraestructura base "Production-Ready" para el entorno de desarrollo local.

---

# 🏗️ FASE 2: SETUP INICIAL (SCAFFOLDING)

## 2.1. Estructura de Directorios (Monorepo Adaptado)

Aunque el estándar sugiere Turborepo para stacks JS, adaptamos la estructura lógica de **Monorepo** para convivir Flutter (Dart) y Python manteniendo la separación de responsabilidades y "Trust Boundaries".

```text
soft-architect-ai/
├── .github/                 # Workflows CI/CD (Actions)
├── apps/
│   ├── client-desktop/      # Frontend Flutter (Windows/Linux/Mac)
│   │   ├── lib/
│   │   ├── test/
│   │   └── pubspec.yaml
│   └── api-server/          # Backend Python FastAPI (RAG Engine)
│       ├── src/
│       ├── tests/
│       ├── Dockerfile
│       └── requirements.txt
├── packages/
│   ├── proto-contracts/     # Contratos compartidos (si usáramos gRPC) o JSON Schemas
│   └── docs/                # Documentación Viva (Architecture, ADRs)
├── infra/
│   ├── docker/              # Configs específicas de contenedores
│   └── k8s/                 # (Futuro) Manifests para deploy
├── .env.example             # Template de variables de entorno
├── .gitignore
├── docker-compose.yml       # Orquestación local
└── README.md                # Entry point

```

---

## 2.2. Docker Compose (Entorno Local)

Este archivo orquesta los servicios de soporte (IA, DB, VectorStore) para que el desarrollador no tenga que instalarlos manualmente. Se incluyen **Healthchecks** estrictos para evitar condiciones de carrera al inicio.

```yaml
version: '3.8'

services:
  # 1. Base de Datos Relacional (Metadatos de proyectos, Historial)
  postgres:
    image: postgres:16-alpine
    container_name: sa_postgres
    environment:
      POSTGRES_USER: dev_user
      POSTGRES_PASSWORD: dev_password
      POSTGRES_DB: soft_architect_db
    ports:
      - "5432:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    healthcheck:
      test: ["CMD-SHELL", "pg_isready -U dev_user"]
      interval: 10s
      timeout: 5s
      retries: 5
    networks:
      - sa_network

  # 2. Vector Database (RAG Storage)
  chromadb:
    image: chromadb/chroma:latest
    container_name: sa_chroma
    environment:
      - IS_PERSISTENT=TRUE
    volumes:
      - chroma_data:/chroma/chroma
    ports:
      - "8000:8000"
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8000/api/v1/heartbeat"]
      interval: 15s
      timeout: 10s
      retries: 3
    networks:
      - sa_network

  # 3. LLM Inference Engine (Local)
  # Nota: Requiere GPU Passthrough para rendimiento óptimo en Linux/Windows WSL2
  ollama:
    image: ollama/ollama:latest
    container_name: sa_ollama
    ports:
      - "11434:11434"
    volumes:
      - ollama_models:/root/.ollama
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [gpu]
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:11434/api/tags"]
      interval: 20s
      timeout: 10s
      retries: 5
    networks:
      - sa_network

  # 4. Python Backend (FastAPI - RAG Bridge)
  api:
    build:
      context: ./apps/api-server
      dockerfile: Dockerfile
    container_name: sa_api
    volumes:
      - ./apps/api-server/src:/app/src
    ports:
      - "8080:8080"
    environment:
      - DATABASE_URL=postgresql://dev_user:dev_password@postgres:5432/soft_architect_db
      - CHROMA_URL=http://chromadb:8000
      - OLLAMA_URL=http://ollama:11434
    depends_on:
      postgres:
        condition: service_healthy
      chromadb:
        condition: service_healthy
      ollama:
        condition: service_healthy
    networks:
      - sa_network

volumes:
  postgres_data:
  chroma_data:
  ollama_models:

networks:
  sa_network:
    driver: bridge

```

---

## 2.3. Variables de Entorno (.env.example)

Template de configuración segura. **NO** commitear el archivo `.env` real.

```bash
# .env.example

# --- APP CONFIG ---
APP_ENV=development
LOG_LEVEL=debug
API_PORT=8080

# --- DATABASE (PostgreSQL) ---
# Usar credenciales seguras en producción, esto es solo para dev local
DATABASE_URL=postgresql://dev_user:dev_password@localhost:5432/soft_architect_db

# --- VECTOR STORE (ChromaDB) ---
CHROMA_HOST=localhost
CHROMA_PORT=8000
CHROMA_COLLECTION=soft_architect_rag

# --- AI ENGINE (Ollama) ---
OLLAMA_BASE_URL=http://localhost:11434
# Modelo base para RAG (Debe estar descargado en Ollama)
LLM_MODEL_NAME=llama3:instruct
# Modelo para Embeddings (ligero)
EMBEDDING_MODEL_NAME=nomic-embed-text

# --- SECURITY ---
# Token para handshake local entre Flutter y Python (evitar spoofing)
API_SECRET_KEY=change_me_in_local_env_file

```

---

## 2.4. Pasos de Instalación "Zero-Config" (README)

Instrucciones diseñadas para reducir la fricción inicial ("Time-to-Code").


## 🚀 Quick Start (Development)

Prerrequisitos: Docker Desktop & Flutter SDK.

### 1. Setup Infraestructura (Backend + AI + DB)
Arranca todos los servicios de soporte en contenedores.
```bash
cp .env.example .env
docker-compose up -d
# Espera a que los servicios estén 'healthy' (docker ps)



### 2. Inicializar Modelos IA

Descarga los modelos necesarios en la instancia local de Ollama.

```bash
docker exec -it sa_ollama ollama pull llama3:instruct
docker exec -it sa_ollama ollama pull nomic-embed-text

```

### 3. Setup Base de Datos

Aplica las migraciones iniciales (Python/Alembic).

```bash
docker exec -it sa_api alembic upgrade head

```

### 4. Arrancar Cliente (Flutter)

```bash
cd apps/client-desktop
flutter pub get
flutter run -d windows # o macos/linux

```

---

**Siguiente paso sugerido:**
La infraestructura está lista. ¿Procedemos a la **[TRIGGER: FASE 3 - DESARROLLO (BACKEND)]** para implementar el primer endpoint de la API (Ingesta de documentos RAG) siguiendo el ciclo TDD + Copilot?

---
Ejecutando protocolo de **Fase 5: Seguridad (Shift-Left)** según el estándar *MASTER_WORKFLOW_0-100*.

Aquí tienes la estrategia de seguridad defensiva para el entorno local de "SoftArchitect AI".

---

# 🛡️ FASE 5: SEGURIDAD (SHIFT-LEFT)

## 5.1. Security Checklist (OWASP Top 10 Adaptado)

Aplicando los controles críticos definidos en el Master Workflow para un entorno Local-First + LLM:

### 💉 A03: Injection (Prompt Injection & Indirect Injection)

El nuevo "SQL Injection" es manipular el LLM para que ignore sus instrucciones de seguridad o exfiltre datos del RAG.

* [ ] **Delimitadores Estrictos:** Envolver SIEMPRE el input del usuario (query) y el contexto recuperado (chunks) en delimitadores XML o triples comillas dentro del System Prompt (ej. `<user_query>{input}</user_query>`) para que el modelo distinga instrucciones de datos.
* [ ] **Input Validation (Pydantic):** Rechazar prompts que excedan una longitud máxima (ej. 4000 caracteres) o contengan secuencias de escape no permitidas antes de siquiera tocar el LLM.
* [ ] **Salida Estructurada:** Forzar al LLM a responder en formato JSON siempre que sea posible (usando la feature `format: json` de Ollama) para evitar que texto malicioso se renderice como código ejecutable en la UI.

### 🔓 A04: Insecure Design (Privacidad de Datos Local)

Aunque no hay nube, el riesgo es que otro proceso local acceda a los datos.

* [ ] **File System Permissions:** Los volúmenes de Docker (`postgres_data`, `chroma_data`) deben tener permisos `700` (solo el usuario propietario puede leer/escribir).
* [ ] **Ephemeral Memory Option:** Implementar un "Modo Incógnito" en el frontend que arranque ChromaDB en memoria (sin persistencia en disco) para sesiones altamente sensibles.
* [ ] **No-Root Containers:** Configurar los Dockerfiles para ejecutar los procesos como usuario no privilegiado (`UID 1001`), evitando que una vulnerabilidad en Python dé acceso root al host.

### 📦 A06: Vulnerable Components (Supply Chain)

* [ ] **Pinning de Versiones:** NUNCA usar tags `:latest` en `docker-compose.yml`. Usar SHAs o versiones semánticas específicas (ej. `python:3.11-slim-bookworm`).
* [ ] **Escaneo de Imagen:** Integrar `trivy` o `snyk` en el pipeline de CI para escanear las imágenes base antes de construir el instalador del usuario.
* [ ] **Minimal Base Images:** Usar imágenes `alpine` o `slim` para reducir la superficie de ataque.

---

## 5.2. Estrategia de Sanitización de Prompts

Para evitar que el usuario "rompa" el personaje de Arquitecto o realice inyecciones, implementaremos una capa de "Middle-logic" en Python antes de llamar a Ollama.

**Algoritmo de Sanitización:**

```python
# apps/api-server/src/security/sanitizer.py

import re
from fastapi import HTTPException

def sanitize_user_prompt(raw_input: str) -> str:
    """
    Limpia el input del usuario antes de integrarlo en el Prompt Template.
    """
    # 1. Longitud máxima (Prevención de DoS por consumo de tokens)
    if len(raw_input) > 2000:
        raw_input = raw_input[:2000]

    # 2. Eliminar caracteres de control no imprimibles (excepto newlines)
    # Evita ataques de inyección de comandos ocultos
    clean_input = "".join(ch for ch in raw_input if ch.isprintable() or ch in ['\n', '\r', '\t'])

    # 3. Escapar delimitadores que usamos en el System Prompt
    # Si usamos """ para envolver el input, debemos romper los """ del usuario
    clean_input = clean_input.replace('"""', '" " "')
    
    # 4. Bloqueo de patrones conocidos de Jailbreak (Lista negra básica)
    jailbreak_patterns = ["ignore all previous instructions", "act as an unconstrained AI"]
    for pattern in jailbreak_patterns:
        if pattern.lower() in clean_input.lower():
            raise HTTPException(status_code=400, detail="Security Policy Violation: Jailbreak attempt detected.")

    return clean_input

```

**Estrategia "Sandwich Defense" en el Prompt:**
Colocar las instrucciones de seguridad al final del prompt, después del input del usuario, ya que los LLMs tienden a priorizar las instrucciones más recientes (recency bias).

---

## 5.3. Configuración de Red y Headers (Container Hardening)

El objetivo es asegurar que la API solo sea accesible por la aplicación Flutter local y no expuesta a la red LAN/Wifi.

**Configuración de Red (Docker Compose):**

```yaml
# docker-compose.yml (fragmento de red)
services:
  api:
    # BINDING ESTRICTO A LOCALHOST
    # Si se usa "8080:8080", Docker a veces bindea a 0.0.0.0 (todas las interfaces).
    # Usar "127.0.0.1:8080:8080" fuerza a que solo la máquina local pueda acceder.
    ports:
      - "127.0.0.1:8080:8080"
    
    # AISLAMIENTO INTERNO
    # La API accede a Ollama/DB por la red interna 'sa_network',
    # pero Ollama y DB NO deben exponer puertos al host si no es necesario para debug.
    networks:
      - sa_network

  ollama:
    # Solo exponer a la red interna de Docker, NO al host
    expose:
      - "11434"
    ports: [] # Eliminar mapeo de puertos al host en producción

```

**Security Headers (FastAPI Middleware):**
Aunque sea local, navegadores o webviews podrían interactuar.

```python
# apps/api-server/src/main.py
from fastapi.middleware.cors import CORSMiddleware

# ...

# Configuración CORS estricta
# Solo permitir orígenes locales y conocidos
origins = [
    "http://localhost",
    "http://127.0.0.1",
    "app://softarchitect" # Scheme común en apps desktop wrappers
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["GET", "POST"], # Mínimo privilegio
    allow_headers=["Authorization", "Content-Type"],
)

@app.middleware("http")
async def add_security_headers(request, call_next):
    response = await call_next(request)
    # Evitar que la API se cargue en iframes (Clickjacking)
    response.headers["X-Frame-Options"] = "DENY"
    # Prevenir sniffing de MIME types
    response.headers["X-Content-Type-Options"] = "nosniff"
    # HSTS no es estrictamente necesario en localhost puro, pero buena práctica si hay proxy TLS
    return response

```

---

**Siguiente paso sugerido:**
La seguridad base está definida. ¿Deseas proceder a la **[TRIGGER: FASE 6 - INFRAESTRUCTURA]** para crear el `Dockerfile` optimizado de producción (Multi-stage build) para el servicio Python?
---

Ejecutando protocolo de **Fase 6: Infraestructura** según el estándar *MASTER_WORKFLOW_0-100*.

Aquí tienes la configuración de CI/CD y automatización de infraestructura para "SoftArchitect AI".

---

# 🏗️ FASE 6: INFRAESTRUCTURA & CI/CD

## 6.1. GitHub Actions Workflow (CI Pipeline)

Diseñamos un pipeline unificado que respeta la estructura de Monorepo, ejecutando validaciones en paralelo para Backend y Frontend, e incluyendo el escaneo de seguridad de contenedores definido en la Fase 5.

```yaml
# .github/workflows/ci.yml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main, develop]

jobs:
  # --- JOB 1: BACKEND (Python) ---
  backend-quality:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ./apps/api-server
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Python 3.11
        uses: actions/setup-python@v4
        with:
          python-version: '3.11'
          cache: 'pip'
      
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
          pip install pytest flake8 black
      
      - name: Linting (Flake8)
        run: flake8 src/ --count --select=E9,F63,F7,F82 --show-source --statistics
      
      - name: Formatting Check (Black)
        run: black --check src/
      
      - name: Unit Tests
        run: pytest tests/

  # --- JOB 2: FRONTEND (Flutter) ---
  frontend-quality:
    runs-on: ubuntu-latest
    defaults:
      run:
        working-directory: ./apps/client-desktop
    
    steps:
      - uses: actions/checkout@v4
      
      - name: Set up Flutter
        uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.19.0'
          channel: 'stable'
          cache: true
      
      - name: Install dependencies
        run: flutter pub get
      
      - name: Static Analysis (Linting)
        run: flutter analyze
      
      - name: Unit & Widget Tests
        run: flutter test

  # --- JOB 3: SECURITY SCAN (Docker) ---
  security-scan:
    needs: [backend-quality] # Solo escanear si el código pasa tests
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Build Docker Image (API)
        run: docker build -t softarchitect-api:latest ./apps/api-server
      
      - name: Run Trivy Vulnerability Scanner
        uses: aquasecurity/trivy-action@master
        with:
          image-ref: 'softarchitect-api:latest'
          format: 'table'
          exit-code: '1' # Fallar el pipeline si hay vulnerabilidades críticas
          ignore-unfixed: true
          vuln-type: 'os,library'
          severity: 'CRITICAL,HIGH'

```

---

## 6.2. Estrategia de Release (Distribución Desktop)

Al ser una aplicación de escritorio "Local-First" sin servidor central, la distribución se realizará mediante **GitHub Releases** automatizadas.

**Estrategia:**

1. **Tagging:** Al hacer push de un tag (ej: `v1.0.0`), se dispara el workflow de Release.
2. **Building:** Se compilan los binarios para cada OS (Windows `.exe`, Linux `.AppImage` o `.deb`). *Nota: macOS requiere un runner Mac y firma de código (Notarizing) que tiene coste, se puede diferir para V1*.
3. **Publishing:** El binario compilado se sube como "asset" a la página de Releases de GitHub.

**Instrucciones para el usuario final:**

> "Descarga el instalador desde la sección 'Releases' de GitHub. El instalador incluye un script que verificará si tienes Docker instalado (requisito previo) y descargará las imágenes necesarias en el primer inicio."

---

## 6.3. Automatización de Modelos (Script de Arranque)

Para cumplir el requisito de "Zero-Config" y no obligar al usuario a ejecutar comandos manuales de Ollama, utilizaremos un **Sidecar Container** o un **Entrypoint Script** en el servicio de Ollama.

A continuación, la solución más robusta usando un script de entrada personalizado para el contenedor de la API (Python), que actúa como orquestador al inicio:

**Archivo: `apps/api-server/scripts/init_models.sh**`

```bash
#!/bin/bash
set -e

# Configuración
OLLAMA_HOST="ollama:11434"
MODEL_NAME="llama3:instruct"
EMBED_MODEL="nomic-embed-text"

echo "⏳ Esperando a que Ollama esté listo en $OLLAMA_HOST..."

# Loop de espera hasta que Ollama responda al healthcheck
until curl -s -f "http://$OLLAMA_HOST/api/tags" > /dev/null; do
  sleep 2
  echo "zzz... esperando a Ollama"
done

echo "✅ Ollama detectado online."

# Función para verificar y descargar modelo
check_and_pull() {
  local model=$1
  echo "🔍 Verificando modelo: $model"
  
  if curl -s "http://$OLLAMA_HOST/api/tags" | grep -q "$model"; then
    echo "✅ Modelo $model ya existe. Saltando descarga."
  else
    echo "⬇️ Descargando $model... (Esto puede tardar dependiendo de tu internet)"
    # Trigger pull via API (no bloquea el script del todo si se manda al background, pero aquí queremos bloquear)
    curl -X POST "http://$OLLAMA_HOST/api/pull" -d "{\"name\": \"$model\"}"
    echo "✅ Descarga de $model completada."
  fi
}

check_and_pull "$MODEL_NAME"
check_and_pull "$EMBED_MODEL"

echo "🚀 Todo listo. Iniciando servidor API..."
exec uvicorn src.main:app --host 0.0.0.0 --port 8080

```

**Integración en `Dockerfile` (API Server):**

```dockerfile
# ... (etapas anteriores de build) ...

COPY scripts/init_models.sh /app/scripts/init_models.sh
RUN chmod +x /app/scripts/init_models.sh

# Reemplazamos el CMD directo por el script de inicialización
ENTRYPOINT ["/app/scripts/init_models.sh"]

```

**Justificación:**
Esto garantiza que la API *nunca* comience a aceptar peticiones del frontend hasta que los modelos necesarios estén físicamente disponibles en el volumen de Docker, evitando errores de "Model not found" en tiempo de ejecución.

---

**Siguiente paso sugerido:**
La infraestructura CI/CD y la automatización están listas. El proyecto está técnicamente listo para entrar en fase de codificación masiva. ¿Deseas proceder a la **[TRIGGER: FASE 7 - DEPLOY A STAGING]** (en este caso, simular un Release Candidate v0.1.0 localmente)?

# 🧪 Resultados de la Simulación: SoftArchitect AI (Proof of Concept)

## 1. Objetivo de la Simulación
Validar mediante técnica "Mago de Oz" (usando un LLM avanzado simulando ser el sistema local) si el flujo de trabajo propuesto en `MASTER_WORKFLOW_0-100.md` es capaz de generar entregables de ingeniería útiles antes de escribir código.

## 2. Metodología
- **Modelo:** Gemini (Simulando RAG Local).
- **Inputs:** Prompts estructurados ("Triggers") correspondientes a las Fases 0, 1, 2, 5 y 6.
- **Contexto:** Documentación del Máster en Desarrollo con IA (Enfoque Web/General).

## 3. Resultados Obtenidos
La simulación generó exitosamente los siguientes artefactos estratégicos para el propio desarrollo de SoftArchitect AI:

### ✅ Fase 0: Visión y Alcance
- **MVP Definido:** App Desktop "Local-First".
- **Descarte Crítico:** Se eliminó la integración con IDEs para la V1 (demasiado complejo).
- **Riesgo Principal:** Hardware insuficiente para correr IA local.

### ✅ Fase 1: Arquitectura
- **Stack Elegido:** Flutter (Frontend) + Python FastAPI (Backend) + Ollama/Chroma (IA).
- **Justificación (ADR):** Se descartó Electron por consumo de RAM.
- **Seguridad:** Se definió un modelo de amenazas centrado en "Data Leakage" local.

### ✅ Fase 2: Setup
- **Estructura Monorepo:** Separación clara `apps/client` y `apps/api`.
- **Docker Compose:** Configuración lista para orquestar Postgres, Chroma y Ollama.

### ✅ Fase 5: Seguridad
- **Sanitización:** Se diseñó un algoritmo de "Middle-logic" en Python para limpiar prompts antes de llegar al LLM.
- **Aislamiento:** Binding estricto a `127.0.0.1` para evitar acceso LAN.

## 4. Conclusiones y Brechas Detectadas (Gap Analysis)
1.  **Dependencia del Modelo:** La calidad de las respuestas dependió del conocimiento general de Gemini. El RAG local necesitará una base de conocimiento mucho más amplia que solo los PDFs del máster para replicar este nivel de detalle en stacks no-web (ej: Mobile Nativo).
2.  **Especifidad:** Se requiere una estrategia de "Tech Packs" (paquetes de conocimiento por tecnología) para que el sistema pueda asistir en Swift, Kotlin o Rust con la misma solvencia que en Web.

---
**Estado:** POC Validada.
**Siguiente Paso:** Definición de la Arquitectura de Conocimiento (Knowledge Graph) y Estrategia Multi-Stack.