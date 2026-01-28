# 🛠️ Detalles del Stack Tecnológico (The Engine)

> **Filosofía:** "Performance nativa, Privacidad por defecto y Orquestación flexible".

---

## 1. Frontend: Flutter Desktop (Linux/Windows)

Elegimos Flutter sobre Electron para reducir el consumo de RAM y garantizar una experiencia de usuario fluida (60/120 FPS).

### Core Dependencies
* **Framework:** Flutter SDK (Stable Channel).
* **Language:** Dart 3.x (Null Safety obligatorio).
* **State Management:** **Riverpod** (con Code Generation `@riverpod`).
    * *Justificación:* Inmutabilidad, testabilidad y separación estricta de UI/Logic sin necesidad de `BuildContext`.
* **Navigation:** **GoRouter**. Rutas declarativas y Deep Linking (aunque sea desktop, facilita la arquitectura).
* **HTTP Client:** **Dio**. Interceptores para manejo de errores centralizado y logging.
* **Storage Local:** **Isar** o **Shared Preferences** para configuraciones ligeras.

### Estilo UI
* **Design System:** Material 3.
* **Componentes:** Custom Widgets para el chat (soporte de Markdown renderizado con `flutter_markdown` y resaltado de sintaxis).

---

## 2. Backend: Python API & RAG Core

El cerebro del sistema. Desacoplado del frontend para permitir escalabilidad futura o cambios de interfaz.

### API Layer
* **Framework:** **FastAPI**.
    * *Justificación:* Soporte nativo asíncrono (`async/await`) vital para streaming de LLMs, validación de tipos con Pydantic y documentación automática (Swagger UI).
* **Server:** Uvicorn (ASGI).

### AI & Orchestration Layer
* **Orquestador:** **LangChain** (Python).
    * *Rol:* Gestión de cadenas de pensamiento (Chains), memoria conversacional y abstracción de proveedores de modelos.
* **Modelos (LLMs):**
    * **Local Provider:** **Ollama** ejecutando `Qwen2.5-Coder` (Optimizado para código).
    * **Cloud Provider:** **Groq** ejecutando `Llama-3` (Para inferencia ultrarrápida cuando la privacidad estricta no es requerida).
* **Vector Store:** **ChromaDB**.
    * *Configuración:* Persistencia en disco local (dentro de Docker Volume).
    * *Embeddings:* `nomic-embed-text` (Local) o similar.

---

## 3. Infraestructura & DevOps

### Containerización
* **Docker Compose:** Orquestación de servicios (`client`, `api`, `chroma`).
* **GPU Acceleration:** Uso de **NVIDIA Container Toolkit** para pasar la GPU del host al contenedor de Ollama (Linux).

### Entorno de Desarrollo
* **Linting:**
    * Dart: `very_good_analysis` o reglas estrictas en `analysis_options.yaml`.
    * Python: `Ruff` (Linter + Formatter ultra rápido).
* **Pre-commit Hooks:** Validación automática antes de subir código.