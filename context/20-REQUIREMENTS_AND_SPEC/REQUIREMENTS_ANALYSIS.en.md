# 📋 Requirements Analysis (Specs)

> **Project:** SoftArchitect AI
> **Scope:** MVP (Phase 1)
> **Priority:** P1 (Blocker) | P2 (Important) | P3 (Desirable)

---

## 1. Functional Requirements (RF) - "What it does"

### 🧠 Knowledge Module (RAG)
* **RF-01 Knowledge Ingestion (P1):** The system must read Markdown files from `packages/knowledge_base`, generate embeddings, and store them in **ChromaDB**.
* **RF-02 Contextual Retrieval (P1):** When the user queries, the system must retrieve the 3-5 most relevant fragments from the "Tech Packs" before generating a response.
* **RF-03 Model Selection (P1):** The user must be able to switch between **Ollama** (Local) and **Groq** (Cloud) from the UI without restarting the application.

### 💻 User Interface (Flutter Desktop)
* **RF-04 Interactive Chat (P1):** Chat interface that supports Markdown rendering and syntax highlighting for code (Dart/Python).
* **RF-05 Response Streaming (P1):** The LLM response must be displayed token by token to reduce perceived latency.
* **RF-06 Session Management (P2):** Ability to create, rename, and delete conversation threads. Local persistence in SQLite/JSON.

### ⚙️ Strategy Generation
* **RF-07 Configuration Assistant (P1):** Implement the "Technical Interview" flow (defined in Tech Packs) to configure rules for a new project.
* **RF-08 Scaffolding Prompts Generation (P2):** The system DOES NOT write to disk. Instead, it generates:
    1.  Master prompts for GitHub Copilot/Cursor to create the structure.
    2.  Shell scripts (bash/PowerShell) that the user can copy and execute to create base folders and files.

---

## 2. Non-Functional Requirements (NFR) - "How it does it"

### 🛡️ Privacy and Sovereignty (The Golden Rule)
* **NFR-01 Local-First Operation (P1):** By default, all processing (RAG, inference) must occur on the user's machine. Cloud use only with explicit consent.
* **NFR-02 Data Sovereignty (P1):** User data (conversations, configurations) must never leave the local machine without explicit permission. Use encrypted local storage.
* **NFR-03 Transparent Privacy (P1):** The UI must clearly indicate when data is being sent to the cloud (e.g., amber cloud icon for Groq mode).
* **NFR-04 OWASP Compliance (P1):** Implement basic security measures against LLM vulnerabilities (Prompt Injection, Insecure Output Handling).

### 🖥️ Performance and Usability
* **NFR-05 UI Responsiveness (P1):** UI must remain responsive during AI processing (use optimistic UI, spinners, background processing).
* **NFR-06 Low Latency (P2):** Response time <200ms for UI interactions, <2s for local inference, <5s for cloud.
* **NFR-07 Accessibility (P2):** WCAG 2.1 AA compliance for desktop (keyboard navigation, screen readers).
* **NFR-08 Cross-Platform (P2):** Primary Linux, compatible with Windows 11 (WSL2).

### 🔧 Technical Constraints
* **NFR-09 RAM Efficiency (P1):** Maximum 2GB RAM usage for local inference (Ollama optimization).
* **NFR-10 Offline Capability (P1):** Core functionality must work without internet (local models).
* **NFR-11 Modularity (P2):** Architecture must allow easy addition of new Tech Packs without code changes.
* **NFR-12 Testability (P2):** >80% code coverage in business logic (Dart/Python).

---

## 3. Acceptance Criteria (DoD - Definition of Done)

For each requirement, the following must be met:

* [ ] **Code Implemented:** Feature coded according to Clean Architecture.
* [ ] **Tests Written:** Unit and integration tests passing.
* [ ] **Documentation Updated:** Specs and user guides reflect the change.
* [ ] **Security Reviewed:** OWASP scan passed.
* [ ] **UI/UX Validated:** Wireframes updated, accessibility checked.
* [ ] **Performance Tested:** Meets NFR latency and RAM limits.