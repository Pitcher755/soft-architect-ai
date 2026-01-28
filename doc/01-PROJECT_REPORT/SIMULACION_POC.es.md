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
````

---

*(Espera a que el GEM responda y guarda el resultado. Luego lanza el siguiente)*

---

### 🔘 PROMPT 3: FASE 2 - SETUP (DevOps Engineer)

*Copia esto tal cual en el GEM:*

```markdown
[TRIGGER: FASE 2 - SCAFFOLDING]

**Stack Confirmado:**
Frontend: Flutter Desktop (Linux/Windows)
Backend: Python (FastAPI)
AI/DB: Ollama + ChromaDB (Docker)

**Instrucción:**
Actúa como DevOps Lead. Basándote en la **Fase 2** del Master Workflow:
1.  Diseña la **Estructura de Directorios Monorepo** ideal para este proyecto (separando apps, packages, docs).
2.  Genera el contenido completo del archivo `docker-compose.yml` para el entorno de desarrollo local (incluyendo healthchecks para Ollama y Postgres/Chroma).
3.  Crea el archivo `.env.example` con variables críticas (LLM_MODEL, API_PORT, etc.).
4.  Define los **Pasos de Instalación Zero-Config** para el README (comandos exactos para que un dev clone y levante).

```

---

*(Espera a que el GEM responda y guarda el resultado. Luego lanza el siguiente)*

---

### 🔘 PROMPT 4: FASE 5 - SEGURIDAD (Security Engineer)

*Copia esto tal cual en el GEM (Saltamos a seguridad porque es crítica antes de codificar)*

```markdown
[TRIGGER: FASE 5 - SECURITY SHIFT-LEFT]

**Contexto:**
Aplicación local que procesa código sensible del usuario vía IA.

**Instrucción:**
Actúa como Security Engineer. Basándote en la **Fase 5** del Master Workflow y OWASP Top 10:
1.  Define el **Checklist de Seguridad** específico para este proyecto. Enfócate en:
    * A03: Injection (Prompt Injection en el LLM).
    * A04: Insecure Design (Privacidad de datos locales).
    * A06: Vulnerable Components (Imágenes Docker).
2.  Diseña una **Estrategia de Sanitización de Prompts** (cómo prevenir que el usuario rompa el sistema con inputs maliciosos).
3.  Especifica qué **Headers de Seguridad** o configuraciones de red debe tener el contenedor API para no exponerse accidentalmente a internet.

```

---

*(Espera a que el GEM responda y guarda el resultado. Luego lanza el siguiente)*

---

### 🔘 PROMPT 5: FASE 6 - INFRAESTRUCTURA (Cloud/Local Ops)

*Copia esto tal cual en el GEM:*

```markdown
[TRIGGER: FASE 6 - INFRASTRUCTURE & CI/CD]

**Contexto:**
El proyecto es "Local-First", pero el código está alojado en GitHub y debe tener CI/CD.

**Instrucción:**
Actúa como Infra Engineer. Basándote en la **Fase 6** del Master Workflow:
1.  Diseña el **Workflow de GitHub Actions (CI)**. Debe incluir:
    * Linting para Flutter y Python.
    * Tests unitarios.
    * Security Scan (Trivy/Snyk) de imágenes Docker.
2.  Explica la **Estrategia de Release**: Cómo distribuimos la app de escritorio a usuarios? (Ej: GitHub Releases, instaladores).
3.  Redacta un pequeño script o instrucción para automatizar la **descarga del modelo LLM** (ej: Llama 3) en el primer boot del contenedor, para que el usuario no tenga que hacerlo manualmente.

```

---

## 🚀 Plan de Acción

1. Ve a tu GEM.
2. Ejecuta estos 5 prompts en orden.
3. Copia todas las respuestas en un solo documento (ej: `SIMULACION_SOFTARCHITECT.md`).
4. **Sube aquí** cuando lo tengas.

Te reviso y te digo: "Javi, esto es oro, tenemos 80% de la tesis hecha" o "Hay un fallo aquí X, vamos a ajustar el prompt". ¡Vamos a por ello! 👨‍💻🔥

---

## RESULTADOS OBTENIDOS

Ejecutando protocolo de **Fase 0: Pre-Desarrollo (Ideación)** según el estándar *MASTER_WORKFLOW_0-100*.

Aquí está el entregable de definición estratégica para el proyecto "SoftArchitect AI".

---

# 🚀 FASE 0: PRE-DESARROLLO (IDEACIÓN)

## 0.1. Definir Visión y Propuesta de Valor

### ✅ Product Vision Statement

Siguiendo la estructura *"Qué es" + "Para quién" + "Por qué importa"*:

> "**SoftArchitect AI** es una aplicación de escritorio para **desarrolladores y arquitectos técnicos** que actúa como **'Arquitecto Senior Virtual'** a través de IA local (RAG), diseñada para **eliminar la parálisis por análisis y asegurar rigor de ingeniería** guiando al usuario a través de un workflow de desarrollo estricto (0-100) sin depender de la nube."

---

## 0.2. Alcance MVP (Minimum Viable)

Aplicando la regla 80/20 (80% valor, 20% esfuerzo) y limitando alcance para V1:

### ✅ Must-Have (V1 - Features Core)

1. **Motor RAG Local (Backend Python):** Integración funcional de Ollama + ChromaDB para ingesta de "Master Workflow" y consulta contextual sin conexión a internet.
2. **Máquina de Estados del Workflow (Frontend Flutter):** Navegación lineal por interfaz que bloquea el avance a la siguiente fase hasta completar las "Gates" (hitos) de la fase actual.
3. **Asistente de Chat Contextual:** Interfaz de chat que permite invocar "Triggers" específicos por fase (ej: "Generar Matriz de Riesgos") usando el contexto cargado.
4. **Gestión de Persistencia Local:** Capacidad para crear, guardar y cargar un estado de proyecto (archivos JSON/SQLite locales) manteniendo el historial de decisiones.

### 🚫 Post-MVP (Descartadas para V1)

1. **Integraciones IDE:** Extensiones para VS Code o IntelliJ (se mantendrá como app standalone inicialmente).
2. **Sincronización Cloud:** Sin login o guardado en nube; privacidad total "Local First".
3. **Soporte Multi-LLM (Cloud):** Sin integración de API OpenAI/Anthropic en V1; enfoque exclusivo en modelos locales (Llama 3, Mistral) para validar la premisa de privacidad y costo cero.

---

## 0.3. Matriz de Riesgos Críticos

Identificación de riesgos técnicos y de negocio con plan de mitigación:

| Riesgo | Tipo | Impacto | Probabilidad | Plan de Mitigación (Plan B) |
| --- | --- | --- | --- | --- |
| **Rendimiento IA Local (Latencia)** | Técnico | ALTO | PROBABLE | Implementar soporte para modelos cuantizados (4-bit) y verificar hardware mínimo al arranque. Fallback a modelos más ligeros (ej: Phi-3) si no hay GPU. |
| **Complejidad de Instalación (Dependencias)** | Técnico | ALTO | PROBABLE | Empaquetar el runtime Python como ejecutable (PyInstaller) o contenedor Docker embebido para evitar que el usuario configure Python/Ollama manualmente. |
| **Alucinaciones Arquitecturales** | Calidad | MEDIO | PROBABLE | Strict System Prompts que obliguen a la IA a citar el documento base y responder "No lo sé" si la información no está en el RAG (Grounding Estricto). |

---

## 0.4. KPIs de Éxito (Métricas)

Definición de indicadores para Open Source / Developer Tool:

1. **Tasa de Completación de Fase (Indicador Principal):** Porcentaje de usuarios que inician Fase 0 y avanzan exitosamente a Fase 2 (Setup). Mide la utilidad real del asistente para desbloquear progreso.
2. **Frecuencia de Generación de Artefactos:** Número promedio de entregables generados (ADRs, Diagramas, Specs) por sesión. Valida que el RAG es útil para crear documentación técnica.
3. **Time-to-Hello-World (Eficiencia):** Tiempo medido desde que el usuario crea un nuevo proyecto en SoftArchitect AI hasta que tiene su estructura de carpetas (Scaffolding) definida y lista para codificar.

---

**Próximo paso sugerido:**
¿Deseas proceder a **[TRIGGER: FASE 1 - PLANIFICACIÓN Y ARQUITECTURA]** para definir el Tech Stack detallado (Flutter + Python bridge) y ADRs iniciales?

---

Ejecutando protocolo de **Fase 1: Planificación y Arquitectura** según el estándar *MASTER_WORKFLOW_0-100*.

Aquí está el entregable de arquitectura técnica y seguridad para "SoftArchitect AI".

---

# 🏗️ FASE 1: PLANIFICACIÓN Y ARQUITECTURA

## 1.1. Selección de Tech Stack (Matriz de Decisión)

Para una aplicación de escritorio que debe ejecutar modelos IA locales, la gestión de memoria (RAM) es el recurso crítico.

**Matriz de Decisión: Framework de Escritorio**

| Criterio | Peso | Flutter (Nativo) | Electron (Web) |
| --- | --- | --- | --- | --- |
| **Consumo de Memoria (RAM)** | 35% | **Bajo (Dart VM)** (5) | Alto (Chromium) (2) |
| **Rendimiento UI** | 25% | Nativo / Skia (5) | DOM / JS Bridge (3) |
| **Integración IA (Python)** | 20% | FFI / Localhost (4) | Node-Python Bridge (4) |
| **Time-to-market** | 20% | Medio (4) | Alto (Web tech) (5) |

**Veredicto:** **Flutter + Python Backend**.
**Justificación:** Electron consume demasiada RAM (~500MB+ base), recursos que necesitamos reservar para el modelo LLM local (Ollama) y Vector DB. Flutter ofrece una UI fluida con bajo impacto de recursos.

**Stack Final:**

* **Frontend:** Flutter (Windows/Linux/macOS).
* **Backend/AI Service:** Python (FastAPI) ejecutándose en `localhost` (spawned por la app).
* **RAG Engine:** LangChain + ChromaDB (Persistencia local).
* **Inferencia:** Ollama (Gestión de modelos).

---

## 1.2. Architecture Decision Record (ADR-001)

Documentando la decisión crítica de arquitectura "Local First" siguiendo la plantilla estándar.

# ADR-001: Estrategia IA Local (Local-First RAG)

## Decisión
Usar una arquitectura 100% local basada en Ollama y ChromaDB, sin dependencias de APIs en la nube (OpenAI/Anthropic) para el MVP.

## Contexto
- "SoftArchitect AI" maneja propiedad intelectual altamente crítica (código fuente, ideas de negocio).
- Usuarios objetivo (Desarrolladores/Arquitectos) valoran privacidad por encima de conveniencia.
- Latencia de red es inaceptable para una herramienta de productividad diaria.

## Rationale
1. **Privacidad (Security by Design):** Elimina completamente el vector de intercepción de datos en tránsito o retención por terceros.
2. **Costo Operacional:** Marginal cero costo por token. Permite contextos largos (ingesta de documentación técnica entera) sin sorpresas de facturación.
3. **Resiliencia:** Funciona offline, crítico para entornos corporativos con firewalls estrictos.

## Consecuencias
- ✅ Privacidad garantizada total (Soberanía de datos).
- ⚠️ **Requisitos de Hardware:** Usuario final necesita mínimo 16GB RAM (ideal GPU dedicada). Esto reduce TAM (Total Addressable Market).
- ⚠️ **Complejidad de Setup:** Debemos empaquetar el runtime Python y gestionar descargas de modelos (GBs) en primer arranque.

## Estado: Aceptado

---

## 1.3. Diagrama de Flujo de Datos (DFD) y Límites de Confianza

Visualización del flujo RAG y límites de confianza.

```mermaid
graph LR
    Usuario([Usuario])
    
    subgraph "Cliente de Escritorio (Flutter)"
        UI[Interfaz Flutter]
        Estado[Gestor de Estado]
    end

    subgraph "Localhost (Límite de Confianza)"
        API[Servidor FastAPI<br/>(Puente Python)]
        RAG[Orquestador RAG]
        VectorDB[(ChromaDB<br/>Almacén Vectorial Local)]
        Ollama[Servicio Ollama<br/>(Inferencia LLM)]
    end

    SistemaArchivos[(Sistema de Archivos Local<br/>Docs & Proyecto)]

    %% Flujo
    Usuario -->|1. Prompt| UI
    UI -->|2. HTTP POST /chat| API
    API -->|3. Recuperar Contexto| RAG
    RAG -->|4. Consulta| VectorDB
    VectorDB -->|5. Chunks Relevantes| RAG
    RAG -->|6. Prompt + Contexto| Ollama
    Ollama -->|7. Token Streaming| API
    API -->|8. Actualizar UI| Estado
    
    %% Ingesta
    SistemaArchivos -.->|Ingestar| API

```

**Análisis de Límite de Confianza:**
El límite de confianza es la propia máquina del usuario. No hay salida a internet excepto para descarga inicial de modelo (que debe validarse por hash).

---

## 1.4. Análisis STRIDE (Enfoque: Data Leakage)

Análisis de amenazas enfocado en proteger código del usuario.

| Amenaza STRIDE | Descripción en Contexto | Mitigación (Fase 1 & 5) |
| --- | --- | --- | --- |
| **Divulgación de Información (Data Leakage)** | Un proceso malicioso en la máquina del usuario o misconfiguración expone el código indexado en ChromaDB o prompts enviados. | 1. **Binding Estricto a Localhost:** La API Python debe escuchar *solo* en `127.0.0.1`, nunca en `0.0.0.0` para evitar acceso LAN.<br>

<br>2. **Permisos de Sistema de Archivos:** Las carpetas de ChromaDB (`postgres_data`, `chroma_data`) deben tener permisos `700` (solo owner).<br>

<br>3. **Memoria Efímera:** Opción para iniciar ChromaDB en memoria (sin persistencia en disco) para sesiones altamente sensibles. |
| **Manipulación** | Inyección de documentos falsos en el RAG para alucinar respuestas incorrectas de seguridad. | Validación de integridad (checksums) de documentos ingeridos antes de procesar. |
| **Suplantación** | Otra aplicación local haciéndose pasar por el backend de SoftArchitect. | Implementar un token de autenticación simple (generado al vuelo) entre Flutter y Python. |

---

**Próximo paso sugerido:**
¿Deseas proceder a **[TRIGGER: FASE 2 - SETUP INICIAL]** para definir la estructura del repositorio (Monorepo Flutter/Python), configurar el `docker-compose` (o script de arranque local) y linters?

---
Ejecutando protocolo de **Fase 2: Setup Inicial (Scaffolding)** según el estándar *MASTER_WORKFLOW_0-100*.

Aquí está la infraestructura base de producción lista para el entorno de desarrollo local.

---

# 🏗️ FASE 2: SETUP INICIAL (SCAFFOLDING)

## 2.1. Estructura de Directorios (Monorepo Adaptado)

Aunque el estándar sugiere Turborepo para stacks JS, adaptamos la estructura lógica Monorepo para coexistencia Flutter (Dart) y Python manteniendo separación de concerns y "Límites de Confianza".

```text
soft-architect-ai/
├── .github/                 # Workflows CI/CD (Actions)
├── apps/
│   ├── client-desktop/      # Frontend Flutter (Windows/Linux/Mac)
│   │   ├── lib/
│   │   ├── test/
│   │   └── pubspec.yaml
│   └── api-server/          # Backend FastAPI Python (Motor RAG)
│       ├── src/
│       ├── tests/
│       ├── Dockerfile
│       └── requirements.txt
├── packages/
│   ├── proto-contracts/     # Contratos compartidos (si usamos gRPC) o JSON Schemas
│   └── docs/                # Documentación Viva (Arquitectura, ADRs)
├── infra/
│   ├── docker/              # Configs específicas de contenedor
│   ├── k8s/                 # (Futuro) Manifests para deploy
├── .env.example             # Plantilla de variables de entorno
├── .gitignore
├── docker-compose.yml       # Orquestación local
└── README.md                # Punto de entrada

```

---

## 2.2. Docker Compose (Entorno Local)

Este archivo orquesta servicios de soporte (IA, DB, VectorStore) para que el desarrollador no tenga que instalarlos manualmente. Incluye **Healthchecks** estrictos para evitar condiciones de carrera en arranque.

```yaml
version: '3.8'

services:
  # 1. Base de Datos Relacional (Metadatos de proyecto, Historial)
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

  # 2. Base de Datos Vectorial (Almacenamiento RAG)
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

  # 3. Motor de Inferencia LLM (Local)
  # Nota: Requiere passthrough GPU para rendimiento óptimo en Linux/Windows WSL2
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

  # 4. Backend Python (FastAPI - Puente RAG)
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

Plantilla de configuración segura. **NO** commitear el archivo real.

```bash
# .env.example

# --- CONFIG APP ---
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
# Modelo base para RAG (Debe descargarse en Ollama)
LLM_MODEL_NAME=llama3:instruct
# Modelo para Embeddings (ligero)
EMBEDDING_MODEL_NAME=nomic-embed-text

# --- SECURITY ---
# Token para handshake local entre Flutter y Python (evitar spoofing)
API_SECRET_KEY=change_me_in_local_env_file

```

---

## 2.4. Pasos de Instalación Zero-Config (README)

Instrucciones diseñadas para reducir fricción inicial ("Time-to-Code").

## 🚀 Inicio Rápido (Desarrollo)

Prerrequisitos: Docker Desktop & Flutter SDK.

### 1. Setup Infraestructura (Backend + IA + DB)
Levanta todos los servicios de soporte en contenedores.
```bash
cp .env.example .env
docker-compose up -d
# Espera a que servicios estén 'healthy' (docker ps)
```

### 2. Inicializar Modelos IA

Descarga modelos necesarios en la instancia local Ollama.

```bash
docker exec -it sa_ollama ollama pull llama3:instruct
docker exec -it sa_ollama ollama pull nomic-embed-text
```

### 3. Setup Base de Datos

Aplica migraciones iniciales (Python/Alembic).

```bash
docker exec -it sa_api alembic upgrade head
```

### 4. Iniciar Cliente (Flutter)

```bash
cd apps/client-desktop
flutter pub get
flutter run -d windows # o macos/linux
```

---

**Próximo paso sugerido:**
La infraestructura está lista. ¿Deseas proceder a **[TRIGGER: FASE 3 - DESARROLLO (BACKEND)]** para implementar el primer endpoint API (ingesta de documentos RAG) siguiendo TDD + Copilot cycle?

---
Ejecutando protocolo de **Fase 5: Seguridad (Shift-Left)** según el estándar *MASTER_WORKFLOW_0-100*.

Aquí está la estrategia defensiva de seguridad para el entorno local "SoftArchitect AI".

---

# 🛡️ FASE 5: SEGURIDAD (SHIFT-LEFT)

## 5.1. Checklist de Seguridad (OWASP Top 10 Adaptado)

Aplicando los controles críticos definidos en el Master Workflow para un entorno Local-First + LLM:

### 💉 A03: Injection (Prompt Injection & Indirect Injection)

La nueva "SQL Injection" es manipular el LLM para ignorar sus instrucciones de seguridad o exfiltrar datos del RAG.

* [ ] **Delimitadores Estrictos:** Siempre envolver el input del usuario (query) y contexto recuperado (chunks) en delimitadores XML o triples comillas dentro del System Prompt (ej. `<user_query>{input}</user_query>`) para que el modelo distinga instrucciones de datos.
* [ ] **Validación de Input (Pydantic):** Rechazar prompts que excedan longitud máxima (ej: 4000 caracteres) o contengan secuencias de escape no permitidas antes de siquiera tocar el LLM.
* [ ] **Output Estructurado:** Forzar al LLM a responder siempre en formato JSON (usando feature `format: json` de Ollama) para prevenir que texto malicioso se renderice como código ejecutable en la UI.

### 🔓 A04: Insecure Design (Privacidad de Datos Locales)

Aunque no hay nube, el riesgo es que otro proceso local acceda a los datos.

* [ ] **Permisos de Sistema de Archivos:** Volúmenes Docker (`postgres_data`, `chroma_data`) deben tener permisos `700` (solo owner).
* [ ] **Modo Memoria Efímera:** Implementar "Modo Incógnito" en el frontend que inicie ChromaDB en memoria (sin persistencia en disco) para sesiones altamente sensibles.
* [ ] **Contenedores No-Root:** Configurar Dockerfiles para ejecutar procesos como usuario no-privilegiado (`UID 1001`), previniendo que una vulnerabilidad Python dé acceso root al host.

### 📦 A06: Vulnerable Components (Supply Chain)

* [ ] **Pinning de Versiones:** NUNCA usar tags `:latest` en `docker-compose.yml`. Usar SHAs o versiones semánticas (ej: `python:3.11-slim-bookworm`).
* [ ] **Escaneo de Imágenes:** Integrar `trivy` o `snyk` en el pipeline CI para escanear imágenes base antes de build.
* [ ] **Imágenes Base Mínimas:** Usar imágenes `alpine` o `slim` para reducir superficie de ataque.

---

## 5.2. Estrategia de Sanitización de Prompts

Para prevenir que el usuario "rompa" la persona Arquitecto o realice inyecciones, implementaremos una "Lógica Media" en Python antes de llamar Ollama.

**Algoritmo de Sanitización:**

```python
# apps/api-server/src/security/sanitizer.py

import re
from fastapi import HTTPException

def sanitize_user_prompt(raw_input: str) -> str:
    """
    Limpiar el input del usuario antes de integrar en el Template de Prompt.
    """
    # 1. Longitud máxima (prevención DoS por consumo de tokens)
    if len(raw_input) > 2000:
        raw_input = raw_input[:2000]

    # 2. Remover caracteres de control no imprimibles (excepto newlines)
    # Previene ataques de inyección de comandos ocultos
    clean_input = "".join(ch for ch in raw_input if ch.isprintable() or ch in ['\n', '\r', '\t'])

    # 3. Escapar delimitadores que usamos en el System Prompt
    # Si usamos """ para envolver input, debemos romper el """ del usuario
    clean_input = clean_input.replace('"""', '" " "')
    
    # 4. Bloquear patrones conocidos de Jailbreak (blacklist básica)
    jailbreak_patterns = ["ignorar todas las instrucciones anteriores", "actuar como una IA sin restricciones"]
    for pattern in jailbreak_patterns:
        if pattern.lower() in clean_input.lower():
            raise HTTPException(status_code=400, detail="Política de Seguridad Violada: Intento de Jailbreak detectado.")

    return clean_input

```

**"Defensa Sandwich" en el Prompt:**
Colocar instrucciones de seguridad al final del prompt, después del input del usuario, ya que los LLMs tienden a priorizar instrucciones más recientes (sesgo de recency).

---

## 5.3. Configuración de Red y Headers (Endurecimiento de Contenedor)

El objetivo es asegurar que la API sea accesible solo por la aplicación Flutter local y no expuesta a LAN/Wifi.

**Configuración de Red (Docker Compose):**

```yaml
# docker-compose.yml (fragmento de red)
services:
  api:
    # BINDING ESTRICTO A LOCALHOST
    # Si usamos "8080:8080", Docker a veces bind a 0.0.0.0 (todas las interfaces).
    # Usar "127.0.0.1:8080:8080" fuerza solo máquina local.
    ports:
      - "127.0.0.1:8080:8080"
    
    # AISLAMIENTO INTERNO
    # La API accede a Ollama/DB a través de la red interna 'sa_network',
    # pero Ollama y DB no deberían exponer puertos al host si no se necesitan para debug.
    networks:
      - sa_network

  ollama:
    # Solo exponer a red interna, NO al host
    expose:
      - "11434"
    ports: [] # Remover mapeo de puerto al host en producción

```

**Headers de Seguridad (Middleware FastAPI):**
Aunque local, navegadores o webviews podrían interactuar.

```python
# apps/api-server/src/main.py
from fastapi.middleware.cors import CORSMiddleware

# ...

# Configuración CORS estricta
# Solo permitir orígenes locales y conocidos
origins = [
    "http://localhost",
    "http://127.0.0.1",
    "app://softarchitect" # Esquema común en wrappers de app de escritorio
]

app.add_middleware(
    CORSMiddleware,
    allow_origins=origins,
    allow_credentials=True,
    allow_methods=["GET", "POST"], # Least privilege
    allow_headers=["Authorization", "Content-Type"],
)

@app.middleware("http")
async def add_security_headers(request, call_next):
    response = await call_next(request)
    # Prevenir carga en iframes (Clickjacking)
    response.headers["X-Frame-Options"] = "DENY"
    # Prevenir sniffing de tipo MIME
    response.headers["X-Content-Type-Options"] = "nosniff"
    # HSTS no estrictamente necesario en localhost puro, pero buena práctica si proxy TLS
    return response

```

---

**Próximo paso sugerido:**
La base de seguridad está definida. ¿Deseas proceder a **[TRIGGER: FASE 6 - INFRAESTRUCTURA]** para crear el Dockerfile optimizado de producción (Multi-stage build) para el servicio Python?

---
Ejecutando protocolo de **Fase 6: Infraestructura** según el estándar *MASTER_WORKFLOW_0-100*.

Aquí está la configuración CI/CD y automatización de infraestructura para "SoftArchitect AI".

---

# 🏗️ FASE 6: INFRAESTRUCTURA & CI/CD

## 6.1. Workflow de GitHub Actions (Pipeline CI)

Diseñamos un pipeline unificado que respeta la estructura Monorepo, ejecutando validaciones en paralelo para Backend y Frontend, e incluyendo el escaneo de seguridad de contenedores definido en Fase 5.

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
    needs: [backend-quality] # Solo escanear si código pasa tests
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
          exit-code: '1' # Fallar pipeline si vulnerabilidades críticas
          ignore-unfixed: true
          vuln-type: 'os,library'
          severity: 'CRITICAL,HIGH'

```

---

## 6.2. Estrategia de Release (Distribución de Escritorio)

Como aplicación "Local-First" sin servidor central, distribución se hará vía **GitHub Releases** automatizado.

**Estrategia:**

1. **Tagging:** Al pushear un tag (ej: `v1.0.0`), el workflow Release se dispara.
2. **Building:** Compilar binarios para cada OS (Windows `.exe`, Linux `.AppImage` o `.deb`). *Nota: macOS requiere code signing (Notarizing) que tiene costo, se puede diferir para V1*.
3. **Publishing:** El binario compilado se sube como "asset" a la página GitHub Releases.

**Instrucciones para usuario final:**

> "Descarga el instalador desde la sección 'Releases' de GitHub. El instalador incluye un script que verificará si tienes Docker instalado (prerrequisito) y descargará las imágenes necesarias en el primer arranque."

---

## 6.3. Automatización de Modelos (Script de Arranque)

Para cumplir el requerimiento "Zero-Config" y no forzar al usuario a ejecutar comandos Ollama manuales, usaremos un **Contenedor Sidecar** o un **Script Entrypoint** en el servicio API (Python).

La solución más robusta es usar un script entrypoint personalizado para el contenedor API (Python), que actúa como orquestador en arranque:

**Archivo: `apps/api-server/scripts/init_models.sh`**

```bash
#!/bin/bash
set -e

# Configuración
OLLAMA_HOST="ollama:11434"
MODEL_NAME="llama3:instruct"
EMBED_MODEL="nomic-embed-text"

echo "⏳ Esperando a que Ollama esté listo en $OLLAMA_HOST..."

# Loop de espera hasta que Ollama responda a healthcheck
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
    echo "⬇️ Descargando $model... (Puede tomar tiempo dependiendo de tu internet)"
    # Trigger pull via API (no bloquea completamente si se envía a background, pero aquí bloqueamos)
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
# ... (etapas de build previas) ...

COPY scripts/init_models.sh /app/scripts/init_models.sh
RUN chmod +x /app/scripts/init_models.sh

# Reemplazar CMD directo con script de inicialización
ENTRYPOINT ["/app/scripts/init_models.sh"]

```

**Justificación:**
Esto asegura que la API *nunca* acepte requests del frontend hasta que los modelos necesarios estén físicamente disponibles en el volumen Docker, evitando errores "Model not found" en runtime.

---

**Próximo paso sugerido:**
La infraestructura CI/CD y automatización está lista. El proyecto está técnicamente listo para entrar en fase masiva de codificación. ¿Deseas proceder a **[TRIGGER: FASE 7 - DEPLOY A STAGING]** (en este caso, simular un Release Candidate v0.1.0 localmente)?

# 🧪 Resultados de Simulación: SoftArchitect AI (Proof of Concept)

## 1. Objetivo de Simulación
Validar usando técnica "Wizard of Oz" (usando un LLM avanzado simulando sistema local) si el workflow propuesto en `MASTER_WORKFLOW_0-100.md` es capaz de generar entregables útiles de ingeniería antes de escribir código.

## 2. Metodología
- **Modelo:** Gemini (Simulando RAG Local).
- **Inputs:** Prompts estructurados ("Triggers") correspondientes a Fases 0, 1, 2, 5 y 6.
- **Contexto:** Documentación de Máster en Desarrollo de Software con IA (Enfoque Web/General).

## 3. Resultados Obtenidos
La simulación generó exitosamente los siguientes artefactos estratégicos para el desarrollo de SoftArchitect AI en sí mismo:

### ✅ Fase 0: Visión y Alcance
- **MVP Definido:** App de Escritorio Local-First.
- **Descartes Críticos:** Integraciones IDE removidas para V1 (demasiado complejas).
- **Riesgo Principal:** Rendimiento insuficiente de IA local.

### ✅ Fase 1: Arquitectura
- **Stack Elegido:** Flutter (Frontend) + Python FastAPI (Backend) + Ollama/Chroma (IA).
- **Justificación (ADR):** Electron descartado por consumo de RAM.
- **Seguridad:** Modelo de amenazas definido centrado en "Data Leakage" local.

### ✅ Fase 2: Setup
- **Estructura Monorepo:** Separación clara `apps/client` y `apps/api`.
- **Docker Compose:** Configuración lista para orquestar Postgres, Chroma y Ollama.

### ✅ Fase 5: Seguridad
- **Sanitización:** Algoritmo "Lógica Media" diseñado en Python para limpiar prompts antes de llegar al LLM.
- **Aislamiento:** Binding estricto a `127.0.0.1` para evitar acceso LAN.

## 4. Conclusiones y Brechas Detectadas (Gap Analysis)
1.  **Dependencia de Modelo:** Calidad de respuesta dependió del conocimiento general de Gemini. RAG local necesitará una base de conocimiento mucho más amplia que solo PDFs de Máster para replicar este nivel de detalle en stacks no-web (ej: Móvil Nativo).
2.  **Especificidad:** Se requiere una estrategia "Tech Packs" (paquetes de conocimiento) para que el sistema asista en Swift, Kotlin o Rust con la misma solvencia que en Web.

---
**Estado:** POC Validado.
**Próximo Paso:** Definición de Arquitectura de Conocimiento (Knowledge Graph) y Estrategia Multi-Stack.