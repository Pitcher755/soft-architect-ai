# 🗺️ Hoja de Ruta y Fases de Ejecución (Master Plan)

> **Estado Actual:** FASE 0 (En curso).
> **Visión:** Construcción incremental desde el núcleo (Infra) hacia el valor (Features).

---

## 🏁 Fase 0: Contexto y Definición (The Foundation)
* **Objetivo:** Definir las "Leyes del Universo" del proyecto.
* **Entregables:**
    * [x] Estructura de directorios `context/`, `doc/`, `src/`.
    * [x] `AGENTS.md` y `RULES.md` definidos.
    * [x] Definición de Stack (`30-ARCHITECTURE`).
    * [ ] Configuración inicial del repositorio (Git init, .gitignore).

---

## 🧱 Fase 1: Scaffolding Técnico (Infrastructure)
* **Objetivo:** "Hola Mundo" orquestado. Que los contenedores levanten sin errores.
* **Branch:** `main` (Initial Setup).
* **Tareas:**
    1.  **Frontend:** `flutter create` en `src/client` (Skeleton App).
    2.  **Backend:** Setup de FastAPI básico en `src/server` (Health check endpoint).
    3.  **Docker:** `docker-compose.yml` conectando ambos servicios + ChromaDB + Ollama.
    4.  **Docs:** Actualizar `SETUP_GUIDE.md` con instrucciones de arranque reales.
* **Hito:** Tag `v0.0.1-init`. El proyecto compila y corre.

---

## 🌿 Fase 2: Activación de GitFlow
* **Objetivo:** Proteger la base y preparar el terreno para el desarrollo real.
* **Tareas:**
    1.  Crear rama `develop` desde `v0.0.1`.
    2.  Configurar reglas de protección de ramas (si aplica en GitHub).
    3.  Configurar Hooks de pre-commit (Linting básico).

---

## 🧠 Fase 3: Inyección de Conocimiento (The Brain)
* **Objetivo:** Poblar el RAG con inteligencia antes de programar la lógica compleja.
* **Branch:** `feature/knowledge-base-injection`.
* **Tareas:**
    1.  **Migración:** Mover los "Tech Packs" diseñados (Flutter, Python, General) a `packages/knowledge_base`.
    2.  **Templates:** Crear las plantillas `.md` (STRIDE, ADR) en `packages/knowledge_base/01-TEMPLATES`.
    3.  **Validación:** Script simple en Python para verificar que los archivos Markdown son legibles.

---

## ⚙️ Fase 4: Core Logic (The Engine)
* **Objetivo:** Conectar el chat de Flutter con el cerebro de Python.
* **Branch:** `feature/core-logic-v1`.
* **Tareas:**
    1.  **Backend:** Implementar endpoint `/api/v1/chat` con LangChain (Streaming response).
    2.  **Frontend:** Implementar UI de Chat con Riverpod y renderizado Markdown.
    3.  **RAG:** Conectar ChromaDB al flujo de LangChain para recuperar contexto.
* **Hito:** MVP Funcional (`v0.1.0`). El usuario pregunta y el sistema responde usando el contexto.

---

## 🚀 Fase 5: Refinamiento y Release
* **Objetivo:** Pulir la experiencia de usuario y documentación.
* **Tareas:**
    1.  Selector UI Local/Cloud (Ollama/Groq).
    2.  Persistencia de historial de chat.
    3.  Generación de instaladores (Linux AppImage / Windows .exe).
