# 📋 Executive Summary: MVP Scope (Phase 1)

> **Objective:** Validate the complete cycle of Local RAG + Structured Code Generation.

---

## 1. Functional Scope (In Scope)

For version `v0.1.0` (MVP), the system must be capable of:

### A. Context Management (The Brain)
* [x] **Knowledge Ingestion:** Load Markdown files (`.md`) from the `packages/knowledge_base` folder into the vector database (**ChromaDB**).
* [x] **Semantic Retrieval:** When faced with a technical question (e.g., "How do I make a provider in Riverpod?"), retrieve the correct snippet from the Flutter Tech Pack.

### B. User Interface (The Face)
* [x] **Desktop App (Flutter):** Native window (Linux/Windows) with interactive chat.
* [x] **Session Management:** Persistent local chat history.
* [x] **Model Selector:** Simple switch between "Local Mode" (Ollama) and "Cloud Mode" (Groq).

### C. Logic Engine (The Core)
* [x] **Python API (FastAPI):** Backend that orchestrates the call to LangChain.
* [x] **Streaming:** Token-by-token response in the UI to reduce perceived latency.

---

## 2. Explicit Exclusions (Out of Scope)

To avoid *scope creep*, these functionalities are outside the MVP:

* ❌ **IDE Integration:** No VS Code plugin for now. It is a standalone app.
* ❌ **Direct Code Editing:** The AI generates code in the chat, but does not directly modify the user's project files (Read-Only access to the user's File System).
* ❌ **Multi-modality:** No support for image or voice input in this phase.
* ❌ **Cloud Auth:** No cloud user system. It is local single-user.

---

## 3. Confirmed Technology Stack

| Layer | Technology | Justification |
| :--- | :--- | :--- |
| **Frontend** | **Flutter (Desktop)** | Native performance, strong typing, same UI for Linux/Win/Mac. |
| **Backend** | **Python (FastAPI)** | Async support, automatic API docs, Pydantic validation. |
| **AI/RAG** | **LangChain + ChromaDB** | Orchestration of prompts and memory, local vector storage. |
| **Inference** | **Ollama (Local) / Groq (Cloud)** | Privacy-first with performance fallback. |
| **Infra** | **Docker Compose** | Deployment in one command (`docker compose up`). |