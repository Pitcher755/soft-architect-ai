Understood! Let's become the ultimate "Prompt Engineers". I'll give you the exact sequence of prompts to copy and paste into your GEM. Each prompt simulates a "click" on the buttons of the future SoftArchitect AI interface, forcing the model to execute a phase of the `MASTER_WORKFLOW_0-100.md`.

The goal is for **SoftArchitect AI** (the GEM) to design **"SoftArchitect AI"** (the real project). Pure meta-programming. 🤯

Copy and paste these prompts **one by one** into your GEM and save the responses.

---

### 🔘 PROMPT 1: PHASE 0 - IDEATION (Business Analyst)

*Copy this exactly into the GEM:*

```markdown
[TRIGGER: PHASE 0 - VISION & MVP]

**Project Context:**
A desktop application called "SoftArchitect AI". It is an assistant for developers that acts as a "Senior Virtual Architect". It uses local RAG (Retrieval-Augmented Generation) with Ollama and ChromaDB to guide the user through a strict software engineering workflow (from requirements to deploy), based on academic documentation from a Master's program. The goal is to eliminate analysis paralysis and ensure code quality. Planned Stack: Frontend Flutter, Backend Python, Local AI.

**Instruction:**
Act as a Senior Business Analyst. Based strictly on **Phase 0** of the Master Workflow you know:
1.  Draft the **Product Vision Statement** (What, Who, Why).
2.  Define the **MVP Scope** using the 80/20 rule: List 4 "Must Have" features and 3 "Post-MVP" (discarded for v1).
3.  Generate the **Risk Matrix** (Technical and Business) identifying the 3 most critical ones and their mitigation plan.
4.  Define 3 **Success KPIs** measurable for this type of tool (Open Source / Developer Tool).

```

---

*(Wait for the GEM to respond and save the result. Then launch the next one)*

---

### 🔘 PROMPT 2: PHASE 1 - ARCHITECTURE (Software Architect)

*Copy this exactly into the GEM:*

```markdown
[TRIGGER: PHASE 1 - ARCHITECTURE & STACK]

**Project Vision:**
(Assume the vision generated in the previous step: Local RAG Assistant for software engineering).

**Instruction:**
Act as a Senior Software Architect. Based strictly on **Phase 1** of the Master Workflow:
1.  Confirm and justify the **Tech Stack** selected using the "Decision Matrix" (comparing options if necessary, e.g., Flutter vs Electron, Local vs Cloud).
2.  Draft the **ADR-001 (Architecture Decision Record)** formal for the decision to use "Dockerized Local AI" instead of cloud APIs.
    * Context, Decision, Rationale (Privacy/Cost), Consequences.
3.  Generate a **Data Flow Diagram (DFD)** textual (or Mermaid code) showing how a user prompt flows from Flutter -> API Python -> Vector DB -> Ollama -> Response.
4.  Perform a simplified **STRIDE** analysis focused on the threat "Data Leakage" (user code leaks).

```

---

*(Wait for the response and save. Next)*

---

### 🔘 PROMPT 3: PHASE 2 - SETUP (DevOps Engineer)

*Copy this exactly into the GEM:*

```markdown
[TRIGGER: PHASE 2 - SCAFFOLDING]

**Confirmed Stack:**
Frontend: Flutter Desktop (Linux/Windows)
Backend: Python (FastAPI)
AI/DB: Ollama + ChromaDB (Docker)

**Instruction:**
Act as DevOps Lead. Based on **Phase 2** of the Master Workflow:
1.  Design the **Monorepo Directory Structure** ideal for this project (separating apps, packages, docs).
2.  Generate the complete content of the `docker-compose.yml` file for the local development environment (including healthchecks for Ollama and Postgres/Chroma).
3.  Create the `.env.example` file with critical variables (LLM_MODEL, API_PORT, etc.).
4.  Define the **Zero-Config installation steps** for the README (exact commands for a dev to clone and start).

```

---

*(Wait for the response and save. Next)*

---

### 🔘 PROMPT 4: PHASE 5 - SECURITY (Security Engineer)

*Copy this exactly into the GEM (We skip to security because it's critical before coding)*

```markdown
[TRIGGER: PHASE 5 - SECURITY SHIFT-LEFT]

**Context:**
Local application that processes sensitive user code via AI.

**Instruction:**
Act as Security Engineer. Based on **Phase 5** of the Master Workflow and OWASP Top 10:
1.  Define the **Security Checklist** specific to this project. Focus on:
    * A03: Injection (Prompt Injection in the LLM).
    * A04: Insecure Design (Local data privacy).
    * A06: Vulnerable Components (Docker images).
2.  Design a **Prompt Sanitization Strategy** (how to prevent the user from breaking the system with malicious inputs).
3.  Specify what **Security Headers** or network configurations the API container should have to not accidentally expose itself to the internet.

```

---

*(Wait for the response and save. Next)*

---

### 🔘 PROMPT 5: PHASE 6 - INFRASTRUCTURE (Cloud/Local Ops)

*Copy this exactly into the GEM:*

```markdown
[TRIGGER: PHASE 6 - INFRASTRUCTURE & CI/CD]

**Context:**
The project is "Local-First", but the code is hosted on GitHub and must have CI/CD.

**Instruction:**
Act as Infra Engineer. Based on **Phase 6** of the Master Workflow:
1.  Design the **GitHub Actions (CI) workflow**. It must include:
    * Linting for Flutter and Python.
    * Unit tests.
    * Security Scan (Trivy/Snyk) of Docker images.
2.  Explain the **Release Strategy**: How do we distribute the desktop app to users? (E.g., GitHub Releases, installers).
3.  Draft a small script or instruction to automate the **LLM model download** (e.g., Llama 3) on the first boot of the container, so the user doesn't have to do it manually.

```

---

## 🚀 Action Plan

1. Go to your GEM.
2. Execute these 5 prompts in order.
3. Copy all responses into a single document (e.g., `SIMULACION_SOFTARCHITECT.md`).
4. **Upload it here** when you have it.

I'll review it and tell you: "Javi, this is gold, we have 80% of the thesis done" or "There's a flaw here X, let's adjust the prompt". Let's get to it! 👨‍💻🔥

---

## RECEIVED RESULTS

Executing protocol of **Phase 0: Pre-Development (Ideation)** according to the *MASTER_WORKFLOW_0-100* standard.

Here is the strategic definition deliverable for the "SoftArchitect AI" project.

---

# 🚀 PHASE 0: PRE-DEVELOPMENT (IDEATION)

## 0.1. Define Vision and Value Proposition

### ✅ Product Vision Statement

Following the structure *"What is it" + "For whom" + "Why it matters"*:

> "**SoftArchitect AI** is a desktop application for **software developers and technical architects** that acts as a **'Senior Virtual Architect'** through local AI (RAG), designed to **eliminate analysis paralysis and ensure engineering rigor** by guiding the user through a strict development workflow (0-100) without relying on the cloud."

---

## 0.2. MVP Scope (Minimum Viable)

Applying the 80/20 rule (80% value, 20% effort) and limiting scope for V1:

### ✅ Must-Have (V1 - Core Features)

1. **Local RAG Engine (Python Backend):** Functional integration of Ollama + ChromaDB for ingesting the "Master Workflow" and contextual querying without internet connection.
2. **Workflow State Machine (Flutter Frontend):** Linear navigation interface that blocks advancement to the next phase until completing the "Gates" (milestones) of the current phase.
3. **Contextual Chat Assistant:** Chat interface that allows invoking specific "Triggers" per phase (e.g., "Generate Risk Matrix") using the loaded context.
4. **Local Persistence Management:** Ability to create, save, and load a project state (local JSON/SQLite files) maintaining the decision history.

### 🚫 Post-MVP (Discarded for V1)

1. **IDE Integrations:** Extensions for VS Code or IntelliJ (will remain as standalone app initially).
2. **Cloud Sync:** No login or cloud saving; total local privacy ("Local First").
3. **Multi-LLM Support (Cloud):** No integration of OpenAI/Anthropic API in V1; exclusive focus on local models (Llama 3, Mistral) to validate the privacy and zero-cost premise.

---

## 0.3. Critical Risks Matrix

Identification of technical and business risks with mitigation strategy:

| Risk | Type | Impact | Probability | Mitigation Plan (Plan B) |
| --- | --- | --- | --- | --- |
| **Local AI Performance (Latency)** | Technical | HIGH | LIKELY | Implement support for quantized models (4-bit) and verify minimum hardware at startup. Fallback to lighter models (e.g., Phi-3) if no GPU. |
| **Installation Complexity (Dependencies)** | Technical | HIGH | LIKELY | Package the Python Backend as executable (PyInstaller) or embedded Docker container to avoid the user having to manually configure Python/Ollama. |
| **Architecture Hallucinations** | Quality | MEDIUM | LIKELY | Strict System Prompts that force the AI to cite the base document and respond "I don't know" if the information is not in the RAG (Strict Grounding). |

---

## 0.4. Success KPIs (Metrics)

Definition of indicators for Open Source / Developer Tool:

1. **Phase Completion Rate (Leading Indicator):** Percentage of users who start Phase 0 and successfully advance to Phase 2 (Setup). Measures the real utility of the assistant for unlocking progress.
2. **Artifact Generation Frequency:** Average number of deliverables generated (ADRs, Diagrams, Specs) per session. Validates that the RAG is useful for creating technical documentation.
3. **Time-to-Hello-World (Efficiency):** Measured time from the user creating a new project in SoftArchitect AI until they have their folder structure (Scaffolding) defined and ready to code.

---

**Next suggested step:**
Do you wish to proceed to **[TRIGGER: PHASE 1 - PLANNING AND ARCHITECTURE]** to define the detailed Tech Stack (Flutter + Python bridge) and initial ADRs?

---

Executing protocol of **Phase 1: Planning and Architecture** according to the *MASTER_WORKFLOW_0-100* standard.

Here is the technical architecture and security deliverable for "SoftArchitect AI".

---

# 🏗️ PHASE 1: PLANNING AND ARCHITECTURE

## 1.1. Tech Stack Selection (Decision Matrix)

For a desktop application that must run local AI models, memory management (RAM) is the critical resource.

**Decision Matrix: Desktop Framework**

| Criterion | Weight | Flutter (Native) | Electron (Web) |
| --- | --- | --- | --- | --- |
| **Memory Consumption (RAM)** | 35% | **Low (Dart VM)** (5) | High (Chromium) (2) |
| **UI Performance** | 25% | Native / Skia (5) | DOM / JS Bridge (3) |
| **AI Integration (Python)** | 20% | FFI / Localhost (4) | Node-Python Bridge (4) |
| **Time-to-market** | 20% | Medium (4) | High (Web tech) (5) |

**Verdict:** **Flutter + Python Backend**.
**Justification:** Electron consumes too much RAM (~500MB+ base), resources we need to reserve for the local LLM model (Ollama) and Vector DB. Flutter offers a fluid UI with low resource impact.

**Final Stack:**

* **Frontend:** Flutter (Windows/Linux/macOS).
* **Backend/AI Service:** Python (FastAPI) running on `localhost` (spawned by the app).
* **RAG Engine:** LangChain + ChromaDB (Local persistence).
* **Inference:** Ollama (Model management).

---

## 1.2. Architecture Decision Record (ADR-001)

Documenting the critical architecture decision "Local First" following the standard template.

# ADR-001: Local AI Strategy (Local-First RAG)

## Decision
Use a 100% local architecture based on Ollama and ChromaDB, without dependencies on cloud APIs (OpenAI/Anthropic) for the MVP.

## Context
- "SoftArchitect AI" handles highly critical intellectual property (source code, business ideas).
- Target users (Developers/Architects) value privacy above convenience.
- Network latency is unacceptable for a daily productivity tool.

## Rationale
1. **Privacy (Security by Design):** Completely eliminates the interception vector of data in transit or retention by third parties.
2. **Operational Cost:** Marginal zero cost per token. Allows long contexts (ingesting entire technical documentation) without surprise bills.
3. **Resilience:** Works offline, critical for corporate environments with strict firewalls.

## Consequences
- ✅ Total privacy guaranteed (Data sovereignty).
- ⚠️ **Hardware Requirements:** End user needs minimum 16GB RAM (ideally dedicated GPU). This reduces TAM (Total Addressable Market).
- ⚠️ **Setup Complexity:** We must package the Python runtime and manage model downloads (GBs) on first startup.

## Status: Accepted

---

## 1.3. Data Flow Diagram (DFD) and Trust Boundaries

Visualization of the RAG flow and trust boundaries.

```mermaid
graph LR
    User([User])
    
    subgraph "Desktop Client (Flutter)"
        UI[Flutter Interface]
        State[State Manager]
    end

    subgraph "Localhost (Trust Boundary)"
        API[FastAPI Server<br/>(Python Bridge)]
        RAG[RAG Orchestrator]
        VectorDB[(ChromaDB<br/>Local Vector Store)]
        Ollama[Ollama Service<br/>(LLM Inference)]
    end

    FileSystem[(Local File System<br/>Docs & Project)]

    %% Flow
    User -->|1. Prompt| UI
    UI -->|2. HTTP POST /chat| API
    API -->|3. Retrieve Context| RAG
    RAG -->|4. Query| VectorDB
    VectorDB -->|5. Relevant Chunks| RAG
    RAG -->|6. Prompt + Context| Ollama
    Ollama -->|7. Streaming Token| API
    API -->|8. Update UI| State
    
    %% Ingestion
    FileSystem -.->|Ingest| API

```

**Trust Boundary Analysis:**
The trust boundary is the user's own machine. No exit to the internet except for initial model download (which must be validated by hash).

---

## 1.4. STRIDE Analysis (Focus: Data Leakage)

Threat analysis focused on protecting user code.

| STRIDE Threat | Description in Context | Mitigation (Phase 1 & 5) |
| --- | --- | --- | --- |
| **Information Disclosure (Data Leakage)** | A malicious process on the user's machine or misconfiguration exposes the indexed code in ChromaDB or sent prompts. | 1. **Strict Localhost Binding:** The Python API must listen *only* on `127.0.0.1`, never on `0.0.0.0` to avoid LAN access.<br>

<br>2. **File System Permissions:** The ChromaDB folder must have permissions `700` (owner only).<br>

<br>3. **Ephemeral Memory:** Option to not persist chat history on disk (RAM only mode) for highly sensitive sessions. |
| **Tampering** | Injection of fake documents into the RAG to hallucinate incorrect security responses. | Integrity validation (checksums) of ingested documents before processing. |
| **Spoofing** | Another local application posing as SoftArchitect's backend. | Implement a simple authentication token (generated on the fly) between Flutter and Python. |

---

**Next suggested step:**
Do you wish to proceed to **[TRIGGER: PHASE 2 - INITIAL SETUP]** to define the repository structure (Monorepo Flutter/Python), configure the `docker-compose` (or local startup script) and linters?

---
Executing protocol of **Phase 2: Initial Setup (Scaffolding)** according to the *MASTER_WORKFLOW_0-100* standard.

Here is the production-ready base infrastructure for the local development environment.

---

# 🏗️ PHASE 2: INITIAL SETUP (SCAFFOLDING)

## 2.1. Directory Structure (Adapted Monorepo)

Although the standard suggests Turborepo for JS stacks, we adapt the logical Monorepo structure for Flutter (Dart) and Python coexistence while maintaining separation of concerns and "Trust Boundaries".

```text
soft-architect-ai/
├── .github/                 # CI/CD Workflows (Actions)
├── apps/
│   ├── client-desktop/      # Flutter Frontend (Windows/Linux/Mac)
│   │   ├── lib/
│   │   ├── test/
│   │   └── pubspec.yaml
│   └── api-server/          # Python FastAPI Backend (RAG Engine)
│       ├── src/
│       ├── tests/
│       ├── Dockerfile
│       └── requirements.txt
├── packages/
│   ├── proto-contracts/     # Shared contracts (if using gRPC) or JSON Schemas
│   └── docs/                # Living Documentation (Architecture, ADRs)
├── infra/
│   ├── docker/              # Specific container configs
│   ├── k8s/                 # (Future) Manifests for deploy
├── .env.example             # Environment variables template
├── .gitignore
├── docker-compose.yml       # Local orchestration
└── README.md                # Entry point

```

---

## 2.2. Docker Compose (Local Environment)

This file orchestrates support services (AI, DB, VectorStore) so the developer doesn't have to install them manually. Strict **Healthchecks** are included to avoid race conditions on startup.

```yaml
version: '3.8'

services:
  # 1. Relational Database (Project metadata, History)
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
  # Note: Requires GPU Passthrough for optimal performance on Linux/Windows WSL2
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

## 2.3. Environment Variables (.env.example)

Secure configuration template. **DO NOT** commit the real  file.

```bash
# .env.example

# --- APP CONFIG ---
APP_ENV=development
LOG_LEVEL=debug
API_PORT=8080

# --- DATABASE (PostgreSQL) ---
# Use secure credentials in production, this is just for local dev
DATABASE_URL=postgresql://dev_user:dev_password@localhost:5432/soft_architect_db

# --- VECTOR STORE (ChromaDB) ---
CHROMA_HOST=localhost
CHROMA_PORT=8000
CHROMA_COLLECTION=soft_architect_rag

# --- AI ENGINE (Ollama) ---
OLLAMA_BASE_URL=http://localhost:11434
# Base model for RAG (Must be downloaded in Ollama)
LLM_MODEL_NAME=llama3:instruct
# Model for Embeddings (light)
EMBEDDING_MODEL_NAME=nomic-embed-text

# --- SECURITY ---
# Token for local handshake between Flutter and Python (avoid spoofing)
API_SECRET_KEY=change_me_in_local_env_file

```

---

## 2.4. Zero-Config Installation Steps (README)

Instructions designed to reduce initial friction ("Time-to-Code").

## 🚀 Quick Start (Development)

Prerequisites: Docker Desktop & Flutter SDK.

### 1. Setup Infrastructure (Backend + AI + DB)
Start all support services in containers.
```bash
cp .env.example .env
docker-compose up -d
# Wait for services to be 'healthy' (docker ps)
```

### 2. Initialize AI Models

Download necessary models in the local Ollama instance.

```bash
docker exec -it sa_ollama ollama pull llama3:instruct
docker exec -it sa_ollama ollama pull nomic-embed-text
```

### 3. Setup Database

Apply initial migrations (Python/Alembic).

```bash
docker exec -it sa_api alembic upgrade head
```

### 4. Start Client (Flutter)

```bash
cd apps/client-desktop
flutter pub get
flutter run -d windows # or macos/linux
```

---

**Next suggested step:**
The infrastructure is ready. Do you wish to proceed to **[TRIGGER: PHASE 3 - DEVELOPMENT (BACKEND)]** to implement the first API endpoint (RAG document ingestion) following TDD + Copilot cycle?

---
Executing protocol of **Phase 5: Security (Shift-Left)** according to the *MASTER_WORKFLOW_0-100* standard.

Here is the defensive security strategy for the "SoftArchitect AI" local environment.

---

# 🛡️ PHASE 5: SECURITY (SHIFT-LEFT)

## 5.1. Security Checklist (OWASP Top 10 Adapted)

Applying the critical controls defined in the Master Workflow for a Local-First + LLM environment:

### 💉 A03: Injection (Prompt Injection & Indirect Injection)

The new "SQL Injection" is manipulating the LLM to ignore its security instructions or exfiltrate data from the RAG.

* [ ] **Strict Delimiters:** Always wrap the user's input (query) and retrieved context (chunks) in XML delimiters or triple quotes within the System Prompt (e.g. `<user_query>{input}</user_query>`) so the model distinguishes instructions from data.
* [ ] **Input Validation (Pydantic):** Reject prompts that exceed a maximum length (e.g., 4000 characters) or contain non-permitted escape sequences before even touching the LLM.
* [ ] **Structured Output:** Force the LLM to always respond in JSON format (using Ollama's `format: json` feature) to prevent malicious text from being rendered as executable code in the UI.

### 🔓 A04: Insecure Design (Local Data Privacy)

Although there's no cloud, the risk is that another local process accesses the data.

* [ ] **File System Permissions:** Docker volumes (`postgres_data`, `chroma_data`) must have permissions `700` (owner only).
* [ ] **Ephemeral Memory Option:** Implement an "Incognito Mode" in the frontend that starts ChromaDB in memory (no disk persistence) for highly sensitive sessions.
* [ ] **Non-Root Containers:** Configure Dockerfiles to execute processes as non-privileged user (`UID 1001`), preventing a Python vulnerability from giving root access to the host.

### 📦 A06: Vulnerable Components (Supply Chain)

* [ ] **Version Pinning:** NEVER use `:latest` tags in `docker-compose.yml`. Use SHAs or semantic versions (e.g., `python:3.11-slim-bookworm`).
* [ ] **Image Scanning:** Integrate `trivy` or `snyk` in the CI pipeline to scan base images before building the user's installer.
* [ ] **Minimal Base Images:** Use `alpine` or `slim` images to reduce attack surface.

---

## 5.2. Prompt Sanitization Strategy

To prevent the user from "breaking" the Architect persona or performing injections, we will implement a "Middle-logic" layer in Python before calling Ollama.

**Sanitization Algorithm:**

```python
# apps/api-server/src/security/sanitizer.py

import re
from fastapi import HTTPException

def sanitize_user_prompt(raw_input: str) -> str:
    """
    Clean the user's input before integrating it into the Prompt Template.
    """
    # 1. Maximum length (DoS prevention by token consumption)
    if len(raw_input) > 2000:
        raw_input = raw_input[:2000]

    # 2. Remove non-printable control characters (except newlines)
    # Prevents hidden command injection attacks
    clean_input = "".join(ch for ch in raw_input if ch.isprintable() or ch in ['\n', '\r', '\t'])

    # 3. Escape delimiters we use in the System Prompt
    # If we use """ to wrap input, we must break the user's """
    clean_input = clean_input.replace('"""', '" " "')
    
    # 4. Block known Jailbreak patterns (basic blacklist)
    jailbreak_patterns = ["ignore all previous instructions", "act as an unconstrained AI"]
    for pattern in jailbreak_patterns:
        if pattern.lower() in clean_input.lower():
            raise HTTPException(status_code=400, detail="Security Policy Violation: Jailbreak attempt detected.")

    return clean_input

```

**"Sandwich Defense" Strategy in the Prompt:**
Place security instructions at the end of the prompt, after the user's input, since LLMs tend to prioritize more recent instructions (recency bias).

---

## 5.3. Network Configuration and Headers (Container Hardening)

The goal is to ensure the API is only accessible by the local Flutter application and not exposed to the LAN/Wifi.

**Network Configuration (Docker Compose):**

```yaml
# docker-compose.yml (network fragment)
services:
  api:
    # STRICT BINDING TO LOCALHOST
    # If using "8080:8080", Docker sometimes binds to 0.0.0.0 (all interfaces).
    # Use "127.0.0.1:8080:8080" forces only local machine access.
    ports:
      - "127.0.0.1:8080:8080"
    
    # INTERNAL ISOLATION
    # The API accesses Ollama/DB through the internal 'sa_network',
    # but Ollama and DB should NOT expose ports to the host if not needed for debug.
    networks:
      - sa_network

  ollama:
    # Only expose to internal network, NOT to host
    expose:
      - "11434"
    ports: [] # Remove port mapping to host in production

```

**Security Headers (FastAPI Middleware):**
Even if local, browsers or webviews might interact.

```python
# apps/api-server/src/main.py
from fastapi.middleware.cors import CORSMiddleware

# ...

# Strict CORS configuration
# Only allow local origins and known ones
origins = [
    "http://localhost",
    "http://127.0.0.1",
    "app://softarchitect" # Common scheme in desktop app wrappers
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
    # Prevent loading in iframes (Clickjacking)
    response.headers["X-Frame-Options"] = "DENY"
    # Prevent MIME type sniffing
    response.headers["X-Content-Type-Options"] = "nosniff"
    # HSTS not strictly necessary in pure localhost, but good practice if proxy TLS
    return response

```

---

**Next suggested step:**
The base security is defined. Do you wish to proceed to **[TRIGGER: PHASE 6 - INFRASTRUCTURE]** to create the optimized production Dockerfile (Multi-stage build) for the Python service?

---
Executing protocol of **Phase 6: Infrastructure** according to the *MASTER_WORKFLOW_0-100* standard.

Here is the CI/CD configuration and automation infrastructure for "SoftArchitect AI".

---

# 🏗️ PHASE 6: INFRASTRUCTURE & CI/CD

## 6.1. GitHub Actions Workflow (CI Pipeline)

We design a unified pipeline that respects the Monorepo structure, executing validations in parallel for Backend and Frontend, and including the container security scan defined in Phase 5.

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
    needs: [backend-quality] # Only scan if code passes tests
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
          exit-code: '1' # Fail pipeline if critical vulnerabilities
          ignore-unfixed: true
          vuln-type: 'os,library'
          severity: 'CRITICAL,HIGH'

```

---

## 6.2. Release Strategy (Desktop Distribution)

As a "Local-First" desktop application without central server, distribution will be done via **GitHub Releases** automated.

**Strategy:**

1. **Tagging:** When pushing a tag (e.g., `v1.0.0`), the Release workflow is triggered.
2. **Building:** Compile binaries for each OS (Windows `.exe`, Linux `.AppImage` or `.deb`). *Note: macOS requires code signing (Notarizing) which has cost, can be deferred for V1*.
3. **Publishing:** The compiled binary is uploaded as "asset" to the GitHub Releases page.

**Instructions for end user:**

> "Download the installer from the 'Releases' section of GitHub. The installer includes a script that will verify if you have Docker installed (prerequisite) and download the necessary images on first startup."

---

## 6.3. Model Automation (Startup Script)

To fulfill the "Zero-Config" requirement and not force the user to execute manual Ollama commands, we will use a **Sidecar Container** or a **Entrypoint Script** in the Ollama service.

The most robust solution is using a custom entrypoint script for the API container (Python), which acts as orchestrator on startup:

**File: `apps/api-server/scripts/init_models.sh`**

```bash
#!/bin/bash
set -e

# Configuration
OLLAMA_HOST="ollama:11434"
MODEL_NAME="llama3:instruct"
EMBED_MODEL="nomic-embed-text"

echo "⏳ Waiting for Ollama to be ready at $OLLAMA_HOST..."

# Wait loop until Ollama responds to healthcheck
until curl -s -f "http://$OLLAMA_HOST/api/tags" > /dev/null; do
  sleep 2
  echo "zzz... waiting for Ollama"
done

echo "✅ Ollama detected online."

# Function to check and download model
check_and_pull() {
  local model=$1
  echo "🔍 Checking model: $model"
  
  if curl -s "http://$OLLAMA_HOST/api/tags" | grep -q "$model"; then
    echo "✅ Model $model already exists. Skipping download."
  else
    echo "⬇️ Downloading $model... (This may take time depending on your internet)"
    # Trigger pull via API (doesn't fully block if sent to background, but here we block)
    curl -X POST "http://$OLLAMA_HOST/api/pull" -d "{\"name\": \"$model\"}"
    echo "✅ Download of $model completed."
  fi
}

check_and_pull "$MODEL_NAME"
check_and_pull "$EMBED_MODEL"

echo "🚀 Everything ready. Starting API server..."
exec uvicorn src.main:app --host 0.0.0.0 --port 8080

```

**Integration in `Dockerfile` (API Server):**

```dockerfile
# ... (previous build stages) ...

COPY scripts/init_models.sh /app/scripts/init_models.sh
RUN chmod +x /app/scripts/init_models.sh

# Replace direct CMD with initialization script
ENTRYPOINT ["/app/scripts/init_models.sh"]

```

**Justification:**
This ensures the API *never* starts accepting requests from the frontend until the necessary models are physically available in the Docker volume, avoiding "Model not found" errors at runtime.

---

**Next suggested step:**
The CI/CD infrastructure and automation are ready. The project is technically ready to enter massive coding phase. Do you wish to proceed to **[TRIGGER: PHASE 7 - DEPLOY TO STAGING]** (in this case, simulate a Release Candidate v0.1.0 locally)?

# 🧪 Simulation Results: SoftArchitect AI (Proof of Concept)

## 1. Simulation Objective
Validate using "Wizard of Oz" technique (using an advanced LLM simulating local system) if the proposed workflow in `MASTER_WORKFLOW_0-100.md` is capable of generating useful engineering deliverables before writing code.

## 2. Methodology
- **Model:** Gemini (Simulating Local RAG).
- **Inputs:** Structured prompts ("Triggers") corresponding to Phases 0, 1, 2, 5 and 6.
- **Context:** Master's documentation in Software Development with AI (Web/General focus).

## 3. Obtained Results
The simulation successfully generated the following strategic artifacts for the development of SoftArchitect AI itself:

### ✅ Phase 0: Vision and Scope
- **Defined MVP:** Local-First Desktop App.
- **Critical Discard:** IDE integrations removed for V1 (too complex).
- **Main Risk:** Insufficient hardware for running local AI.

### ✅ Phase 1: Architecture
- **Chosen Stack:** Flutter (Frontend) + Python FastAPI (Backend) + Ollama/Chroma (AI).
- **Justification (ADR):** Electron discarded due to RAM consumption.
- **Security:** Threat model defined centered on "Data Leakage" local.

### ✅ Phase 2: Setup
- **Monorepo Structure:** Clear separation `apps/client` and `apps/api`.
- **Docker Compose:** Configuration ready to orchestrate Postgres, Chroma and Ollama.

### ✅ Phase 5: Security
- **Sanitization:** "Middle-logic" algorithm designed in Python to clean prompts before reaching LLM.
- **Isolation:** Strict binding to `127.0.0.1` to avoid LAN access.

## 4. Conclusions and Detected Gaps (Gap Analysis)
1.  **Model Dependency:** Response quality depended on Gemini's general knowledge. Local RAG will need a much broader knowledge base than just Master's PDFs to replicate this level of detail in non-web stacks (e.g., Native Mobile).
2.  **Specificity:** A "Tech Packs" strategy is required (knowledge packages per technology) so the system can assist in Swift, Kotlin or Rust with the same solvency as in Web.

---
**Status:** POC Validated.
**Next Step:** Knowledge Architecture Definition (Knowledge Graph) and Multi-Stack Strategy.