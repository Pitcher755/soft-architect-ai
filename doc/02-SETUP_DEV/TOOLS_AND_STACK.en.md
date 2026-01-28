# 🛠️ Tools and Technology Stack

This document collects the complete inventory of tools used both for project management and conception (Meta-Tools) and for its technical implementation (Tech Stack).

## 1. Meta-Tools (Management, Design and AI)
Tools used to "build the builder".

| Tool | Main Use | Context |
| :--- | :--- | :--- |
| **Google Gemini** | **Thought Partner & Planner** | Landing ideas, task planning, infrastructure configurations, technical research and error correction. |
| **GEM "SoftArchitect AI"** | **Prototyping (Wizard of Oz)** | Customized Gemini instance to simulate RAG behavior before programming and validate system prompts. |
| **Claude Sonnet** | **Knowledge Analyst** | Extraction of structured information from Master's modules and writing of `MASTER_WORKFLOW_0-100.md`. |
| **Notion** | **Project Management** | Task tracking, milestone checklist and repository of quick notes. |
| **n8n** | **Automation Orchestrator** | Low-Code engine in HomeLab. Synchronizes documentation and manages Webhooks. |
| **Notion API** | **Knowledge CMS** | Final destination of living documentation. Integrated via n8n. |

## 2. Development Environment (Dev Environment)
Physical and logical infrastructure where the code is cooked.

| Tool | Use | Configuration |
| :--- | :--- | :--- |
| **HomeLab (CasaOS)** | **Main Server** | Visual OS over Ubuntu. Manages Docker, Volumes and Networks graphically. |
| **Laptop (Linux/Ryzen)** | **Thin Client** | User interface and testing environment for powerful Local AI. |
| **VS Code + Remote SSH** | **IDE** | Allows developing in HomeLab from laptop as if local. |
| **Tailscale** | **Mesh VPN Network** | Secure access to development environment from anywhere without opening ports. |
| **Git & GitHub** | **Version Control** | Central repository, CI/CD Actions and Release management. |

## 3. Technology Stack (The Product)
Technologies that make up the "SoftArchitect AI" application.

### Backend & AI
* **Python 3.11 + FastAPI:** API Server and logic orchestrator.
* **LangChain / LangGraph:** Framework to manage conversation flow and context retrieval.
* **Ollama:** Inference engine for **Local Mode** (Total privacy).
* **Groq API:** Inference provider for **Cloud Mode** (Speed on old hardware).
* **ChromaDB:** Vector database for RAG (Long-term memory).

### Frontend
* **Flutter (Dart):** Framework for native desktop application (Linux/Windows/Mac).
* **Riverpod:** Reactive state management.

### Infrastructure
* **Docker Compose:** Service orchestration (DB, API, AI).

---
## 4. Stack Update (Local Implementation Phase)

### AI Models (LLMs)
* **Qwen2.5-Coder-7b:** Main model for code generation in local environment. Chosen for its optimization for programming and low VRAM consumption (fits in RTX 3050).
* **Phi-4 (Microsoft):** Secondary model for complex logical reasoning if necessary.

### Infrastructure Tools (Linux)
* **NVIDIA Container Toolkit:** Allows Docker containers to access the host GPU.
* **Warp Terminal:** Modern terminal used for workflow management and Docker commands.