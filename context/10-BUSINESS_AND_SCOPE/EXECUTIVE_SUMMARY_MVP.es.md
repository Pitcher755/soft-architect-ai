# 📋 Resumen Ejecutivo: Alcance del MVP (Fase 1)

> **Objetivo:** Validar el ciclo completo de RAG Local + Generación de Código Estructurado.

---

## 1. Alcance Funcional (In Scope)

Para la versión `v0.1.0` (MVP), el sistema debe ser capaz de:

### A. Gestión de Contexto (The Brain)
* [x] **Ingesta de Conocimiento:** Cargar archivos Markdown (`.md`) de la carpeta `packages/knowledge_base` en la base de datos vectorial (**ChromaDB**).
* [x] **Recuperación Semántica:** Ante una duda técnica (ej: "¿Cómo hago un provider en Riverpod?"), recuperar el snippet correcto del Tech Pack de Flutter.

### B. Interfaz de Usuario (The Face)
* [x] **App de Escritorio (Flutter):** Ventana nativa (Linux/Windows) con chat interactivo.
* [x] **Gestión de Sesiones:** Historial de chat persistente localmente.
* [x] **Selector de Modelo:** Switch simple entre "Modo Local" (Ollama) y "Modo Nube" (Groq).

### C. Motor de Lógica (The Core)
* [x] **API Python (FastAPI):** Backend que orquesta la llamada a LangChain.
* [x] **Streaming:** Respuesta token a token en la UI para reducir la latencia percibida.

---

## 2. Exclusiones Explícitas (Out of Scope)

Para evitar el *scope creep*, estas funcionalidades quedan fuera del MVP:

* ❌ **Integración con IDEs:** No habrá plugin de VS Code por ahora. Es una app independiente (Standalone).
* ❌ **Edición de Código Directa:** La IA genera código en el chat, pero no modifica los archivos del proyecto del usuario directamente (Read-Only access al File System del usuario).
* ❌ **Multi-modalidad:** No soportaremos entrada de imágenes o voz en esta fase.
* ❌ **Auth Cloud:** No habrá sistema de usuarios en la nube. Es monousuario local.

---

## 3. Stack Tecnológico Confirmado

| Capa | Tecnología | Justificación |
| :--- | :--- | :--- |
| **Frontend** | **Flutter (Desktop)** | Rendimiento nativo, tipado fuerte, misma UI para Linux/Win/Mac. |
| **Backend** | **Python (FastAPI)** | Soporte asíncrono, docs automáticas de API, validación Pydantic. |
| **IA/RAG** | **LangChain + ChromaDB** | Orquestación de prompts y memoria, almacenamiento vectorial local. |
| **Inferencia** | **Ollama (Local) / Groq (Cloud)** | Privacidad por defecto con fallback de rendimiento. |
| **Infra** | **Docker Compose** | Despliegue en un solo comando (`docker compose up`). |