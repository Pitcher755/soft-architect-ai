# 🛠️ Technical Stack Details (The Engine)

> **Philosophy:** "Native performance, Default privacy and Flexible orchestration".

---

## 1. Frontend: Flutter Desktop (Linux/Windows)

We chose Flutter over Electron to reduce RAM consumption and ensure a smooth user experience (60/120 FPS).

### Core Dependencies
* **Framework:** Flutter SDK (Stable Channel).
* **Language:** Dart 3.x (Null Safety mandatory).
* **State Management:** **Riverpod** (with Code Generation `@riverpod`).
    * *Justification:* Immutability, testability and strict separation of UI/Logic without needing `BuildContext`.
* **Navigation:** **GoRouter**. Declarative routes and Deep Linking (even for desktop, facilitates architecture).
* **HTTP Client:** **Dio**. Interceptors for centralized error handling and logging.
* **Local Storage:** **Isar** or **Shared Preferences** for lightweight configurations.

### UI Style
* **Design System:** Material 3.
* **Components:** Custom Widgets for chat (Markdown rendering with `flutter_markdown` and syntax highlighting).

---

## 2. Backend: Python API & RAG Core

The system's brain. Decoupled from frontend for future scalability or interface changes.

### API Layer
* **Framework:** **FastAPI**.
    * *Justification:* Native async support (`async/await`) vital for LLM streaming, type validation with Pydantic and automatic documentation (Swagger UI).
* **Server:** Uvicorn (ASGI).

### AI & Orchestration Layer
* **Orchestrator:** **LangChain** (Python).
    * *Role:* Thought chain management (Chains), conversational memory and model provider abstraction.
* **Models (LLMs):**
    * **Local (Privacy):** Ollama running `Qwen2.5-Coder-7b` (Optimized for code).
    * **Cloud (Speed):** Groq API running `Llama-3-70b` or `Mixtral`.
* **Vector Store:** **ChromaDB** (Local embeddings persistence).

### Additional Tools
* **Pre-commit Hooks:** Automatic validation before pushing code.
* **Logging:** Structured logging with `loguru` for debugging and monitoring.

---

## 3. Infrastructure: Docker & Orchestration

* **Containerization:** Docker Compose for local development.
* **GPU Support:** NVIDIA Container Toolkit for local inference acceleration.
* **Networking:** Internal Docker network for service communication.

---

## 4. Development Tools

* **IDE:** VS Code with Flutter and Python extensions.
* **Version Control:** Git with GitFlow workflow.
* **CI/CD:** GitHub Actions for automated testing and building.
* **Documentation:** Markdown with Mermaid for diagrams.

---

## 5. Performance Benchmarks

* **Startup Time:** <5 seconds for Docker containers.
* **Response Time:** <2 seconds for local inference, <1 second for cloud.
* **Memory Usage:** <2GB RAM for local mode, <500MB for cloud mode.
* **Disk Usage:** <10GB for all dependencies and models.