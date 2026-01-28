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
    * **Local (Privacidad):** Ollama corriendo `Qwen2.5-Coder-7b` (Optimizado para código).
    * **Cloud (Velocidad):** Groq API corriendo `Llama-3-70b` o `Mixtral`.
* **Vector Store:** **ChromaDB** (Persistencia local de embeddings).

### Herramientas Adicionales
* **Pre-commit Hooks:** Validación automática antes de subir código.
* **Logging:** Logging estructurado con `loguru` para debugging y monitoring.

---

## 3. Infraestructura: Docker & Orquestación

* **Containerización:** Docker Compose para desarrollo local.
* **Soporte GPU:** NVIDIA Container Toolkit para aceleración de inferencia local.
* **Networking:** Red interna Docker para comunicación de servicios.

---

## 4. Herramientas de Desarrollo

* **IDE:** VS Code con extensiones Flutter y Python.
* **Control de Versiones:** Git con workflow GitFlow.
* **CI/CD:** GitHub Actions para testing automatizado y building.
* **Documentación:** Markdown con Mermaid para diagramas.

---

## 5. Benchmarks de Performance

* **Tiempo de Inicio:** <5 segundos para contenedores Docker.
* **Tiempo de Respuesta:** <2 segundos para inferencia local, <1 segundo para cloud.
* **Uso de Memoria:** <2GB RAM para modo local, <500MB para modo cloud.
* **Uso de Disco:** <10GB para todas las dependencias y modelos.