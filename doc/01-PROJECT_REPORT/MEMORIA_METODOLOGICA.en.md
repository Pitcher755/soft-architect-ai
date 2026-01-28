# 📓 Methodological Memory: The Origin and Tools

## 1. Origin of the Idea
This project is born as a response to a need detected during the Master's in Development with AI: **the need to operationalize knowledge**.

Instead of leaving the theory of the modules (Engineering, Architecture, Security) in static PDFs, the idea is **to create a system that contains that knowledge and helps to apply it actively**. It is a "Meta" project: use AI to build a tool that uses AI to improve software development.

## 2. Development Methodology: "AI-Driven Development"
For the conception and documentation of this project, a hybrid human-AI methodology has been used, with AI (Advanced LLM Models) acting as **Consultant Architect**.

### Tools used:
* **Copilot & LLMs:** Used not only for code autocompletion, but for:
    * Generate documentation structures (like this file).
    * Simulate roles (Business Analyst, DevOps Engineer) to validate ideas.
    * Synthesize large volumes of technical documentation.
* **RAG (Retrieval-Augmented Generation):** The technique itself implemented by the project has been used to structure it, feeding the assistant with the master's syllabi to ensure academic coherence.

## 3. Application of the Infrastructure and Cloud Module
The Infrastructure module is the backbone that makes this project viable. It's not just about "uploading code", but designing a deployable and maintainable system.

### How Module 7 applies to SoftArchitect's Workflow:
1.  **Dockerization from Day 0:** * To ensure that the AI module (Python/RAG) and the Frontend (Flutter) work the same on any machine, everything is defined in `docker-compose.yaml`.
    * *Master's Justification:* Containerization to avoid "works on my machine".
    
2.  **Infrastructure as Code (IaC):**
    * The definition of vector services and the API is managed through declarative scripts, allowing the environment to be recreated in seconds.

3.  **Deployment Strategy (CI/CD):**
    * Pipelines (GitHub Actions) are designed that not only run tests, but also verify the integrity of the RAG knowledge base.
    * *Applied Concept:* Automation of lifecycle and Quality Gates.

4.  **Observability:**
    * Future integration of monitoring tools to see the latency of AI responses (key concept in LLMOps seen in the module).

5.  **Documentation Automation (Docs-as-Code):**
    * A pipeline of **Continuous Knowledge Integration** has been implemented.
    * Documentation resides alongside the code (Markdown in Git), but is automatically deployed to Notion via **n8n** and Webhooks.
    * *Justification:* Eliminates desynchronization between what the code does and what the documentation says, applying DevOps principles to knowledge management.

---

# 📓 Methodological Memory: Engineering and Architectural Decisions

## 1. Introduction
This document justifies the technical decisions taken for the development of **SoftArchitect AI**, linking them directly to the knowledge acquired in the Master's in Development with AI. The objective is not only to build a useful tool, but to demonstrate the ability to design complex, scalable, and deployable systems.

## 2. Application of the Software Architecture Module
A **Local Microservices** architecture has been chosen.

* **Decision:** Separate the Frontend (Flutter) from the AI Backend (Python).
* **Justification (Clean Architecture):** This separation of responsibilities allows the UI to evolve independently of the artificial intelligence engine. If tomorrow we want to change Ollama for OpenAI API, we only touch the Python service; the Flutter Frontend doesn't notice.
* **Ports & Adapters Pattern:** The Python service acts as an adapter that "talks" to the LLM and the Vector Base, exposing a clean REST API to the domain (the user in Flutter).

## 3. Application of the Infrastructure and Cloud Module
The biggest technical challenge of this project is **Portability**. When using local AI models, environment configuration is usually a nightmare ("install Python, install CUDA drivers, install Ollama...").

**Implemented Solution: "Self-Contained" Docker Compose**
We have applied Containerization principles to create a 100% reproducible environment.

* **Orchestration:** A single `docker-compose.yaml` file raises 3 coordinated containers:
    1.  `softarchitect-backend`: The API in FastAPI.
    2.  `softarchitect-vector-db`: Persistent ChromaDB.
    3.  `ollama-service`: The inference engine.
    
* **Automation (IaC):** A custom *entrypoint script* has been designed for the Ollama container. This script checks at startup if the necessary LLM model (e.g.: `llama3`) is downloaded. If not, it downloads it automatically (`ollama pull`) before declaring the service as "Healthy". This ensures the "Clone and Run" experience without manual steps.

## 4. Application of the Quality and Testing Module
* **Frontend:** Widget tests in Flutter to ensure that requirement forms and response visualization are robust.
* **Backend:** Unit tests in Python (Pytest) to validate prompt building logic and connection with ChromaDB.
* **RAG Evaluation:** (Future Phase) Implementation of "RAGAS" to measure the accuracy and fidelity of responses generated by the system against the base documentation.

## 5. Application of the Security Module
* **Privacy by Design:** By choosing a local stack (Ollama + ChromaDB), we guarantee that the user's code or project ideas **never leave their machine**. This is critical for a tool that handles intellectual property.
* **Sanitization:** The Python API implements strict validations (Pydantic) to avoid malicious prompt injections.

---

## 6. Remote Development Strategy (HomeLab & Tailscale)
To maximize efficiency and simulate a real production environment from day one, a **Remote Development** architecture has been chosen.

### 6.1. Physical vs. Logical Architecture
* **HomeLab (The Powerhouse):** An Ubuntu Server with Docker Engine. Hosts the source code, vector database (ChromaDB), AI engine (Ollama) and runs compilation processes.
* **Laptop (Thin Client):** Acts merely as user interface. Does not store code or run heavy workloads.
* **Connectivity:** **VS Code Remote - SSH** is used to connect the local IDE directly to the server's file system.

### 6.2. Stack Advantages
1.  **Immutable Environment:** Since everything is dockerized on the server, it doesn't matter if I change laptops or format; the development environment remains intact.
2.  **AI Power:** LLM models (Llama 3) run on the server's hardware (dedicated CPU/GPU), freeing laptop resources for browsing and office work.
3.  **Ubiquity (Tailscale):** A Mesh VPN network (Tailscale) is integrated that allows access to the development environment from anywhere in the world securely, without opening ports on the router.

### 6.3. Testing Workflow
* **Development Phase:** `flutter run -d web-server` is used on the server. VS Code performs automatic *Port Forwarding* through the SSH tunnel, allowing to see and debug the application in the local laptop browser (`localhost:8080`) as if it were running natively.
* **Release Phase:** For native mobile compilations, *Wireless Debugging* or a CI/CD pipeline is used that generates the binaries (APK/EXE) ready for download.

---

## 7. Early Validation: "Wizard of Oz" Simulation
Before writing the source code, a **Prompt Prototyping (Prompt Engineering)** phase was executed simulating the final system behavior.
* **Objective:** Validate if the *Master Workflow* is capable of generating useful deliverables (Vision Statements, ADRs, Dockerfiles) without human creative intervention.
* **Result:** The simulation confirmed that, with the appropriate context, the system can act as a "Senior Architect", reducing project uncertainty before the development phase.

## 8. RAG Evolution: Structured Context Architecture
We have pivoted from a traditional RAG approach (semantic search in unstructured documents) to a **Structured Context Architecture**.

### 8.1. Reverse Engineering of Success Cases
The real project *GuauGuauCars* (developed by the author) was analyzed to extract success patterns that facilitated development with Copilot. Four necessary context pillars were identified:
1.  **Technical Identity:** Definition of roles (e.g.: `AGENTS.md`).
2.  **Golden Rules:** Explicit technical restrictions (e.g.: `TESTING_RULES.md`).
3.  **Structural Map:** Definition of folder architecture.
4.  **Workflows:** Standardized procedures (GitFlow, TDD).

### 8.2. The concept of "Meta-Templates"
To replicate this success in any technology, SoftArchitect AI will use **Meta-Templates** (like `UNIVERSAL_AGENTS.md`) that are dynamically filled according to the user's stack (Tech Packs), ensuring that the AI assistant always has high-quality context ("Garbage In, Garbage Out" mitigated).

---

## 9. Technical Pivot: Hardware Adaptability
During the technical validation phase ("The Fire Test"), a critical bottleneck was identified in old home servers (absence of AVX instructions in CPUs pre-2011), making local execution of models unfeasible, even the lightest ones ("TinyLlama").

### Design Decision:
Instead of restricting the software to high-end hardware, a **Hybrid Architecture** was chosen. **Groq Cloud** is integrated as a transparent fallback. This allows developing and testing RAG logic in the HomeLab (using fast cloud) and deploying in local production or powerful laptop (using Ollama) with the same codebase. It is a practical example of how infrastructure dictates software architecture decisions.

## 10. Engineering Challenge: GPU Virtualization in Containers

One of the most complex technical challenges overcome was the orchestration of hardware resources (GPU) within a containerized environment (Docker) on Linux.

### 10.1. The "NVIDIA Passthrough" Problem
Docker, by default, isolates the container from the host hardware. For the inference engine (Ollama) to access the CUDA cores of the graphics card (RTX 3050), it was not enough to install drivers on the host.

### 10.2. Implemented Solution: NVIDIA Container Toolkit
The `nvidia-container-toolkit` was integrated into the base operating system (Linux) and Docker's `daemon.json` was configured to allow the NVIDIA runtime.
At the **Infrastructure as Code (IaC)** level, the `docker-compose.yml` was modified to reserve specific hardware capabilities:

```yaml
deploy:
  resources:
    reservations:
      devices:
        - driver: nvidia
          count: 1
          capabilities: [gpu]
```