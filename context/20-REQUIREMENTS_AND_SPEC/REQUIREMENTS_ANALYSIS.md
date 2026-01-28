# 📋 Análisis de Requisitos (Specs)

> **Proyecto:** SoftArchitect AI
> **Alcance:** MVP (Fase 1)
> **Prioridad:** P1 (Bloqueante) | P2 (Importante) | P3 (Deseable)

---

## 1. Requisitos Funcionales (RF) - "Lo que hace"

### 🧠 Módulo de Conocimiento (RAG)
* **RF-01 Ingesta de Documentación (P1):** El sistema debe leer archivos Markdown de `packages/knowledge_base`, generar embeddings y almacenarlos en **ChromaDB**.
* **RF-02 Recuperación Contextual (P1):** Ante una consulta del usuario, el sistema debe recuperar los 3-5 fragmentos más relevantes de los "Tech Packs" antes de generar una respuesta.
* **RF-03 Selección de Modelo (P1):** El usuario debe poder cambiar entre **Ollama** (Local) y **Groq** (Cloud) desde la UI sin reiniciar la aplicación.

### 💻 Interfaz de Usuario (Flutter Desktop)
* **RF-04 Chat Interactivo (P1):** Interfaz tipo chat que soporte renderizado de Markdown y resaltado de sintaxis para código (Dart/Python).
* **RF-05 Streaming de Respuesta (P1):** La respuesta del LLM debe mostrarse token a token para reducir la latencia percibida.
* **RF-06 Gestión de Sesiones (P2):** Capacidad de crear, renombrar y borrar hilos de conversación. Persistencia local en SQLite/JSON.

### ⚙️ Generación de Estrategia
* **RF-07 Asistente de Configuración (P1):** Implementar el flujo de "Entrevista Técnica" (definido en los Tech Packs) para configurar las reglas de un nuevo proyecto.
* **RF-08 Generación de Prompts de Scaffolding (P2):** El sistema NO escribirá en disco. En su lugar, generará:
    1.  Prompts maestros para que GitHub Copilot/Cursor creen la estructura.
    2.  Scripts de terminal (bash/PowerShell) que el usuario puede copiar y ejecutar para crear carpetas y archivos base.

---

## 2. Requisitos No Funcionales (RNF) - "Cómo lo hace"

### 🛡️ Privacidad y Soberanía (The Golden Rule)
* **RNF-01 Local-First Absoluto:** En "Modo Local", ningún byte de datos (prompts o documentos) debe salir de la red local (localhost).
* **RNF-02 Persistencia Aislada:** La base de datos vectorial (ChromaDB) debe residir en un volumen de Docker local.

### 🚀 Rendimiento y Eficiencia
* **RNF-03 Latencia de Inferencia:**
    * Cloud (Groq): < 1s al primer token (TTFT).
    * Local (Ollama/GPU): < 3s al primer token (dependiendo del HW).
* **RNF-04 Consumo de Recursos:** El cliente Flutter no debe consumir más de 300MB de RAM en reposo.

### 🏗️ Arquitectura y Calidad
* **RNF-05 Modularidad:** El backend (Python) y el frontend (Flutter) deben estar desacoplados (API REST).
* **RNF-06 Extensibilidad:** Añadir un nuevo "Tech Pack" no debe requerir recompilar el motor RAG.

---

## 3. Restricciones del Sistema
* **Hardware:** Debe ser funcional en un portátil estándar (16GB RAM) usando el modo Cloud, o en un equipo con GPU NVIDIA (6GB VRAM) para modo Local.
* **OS:** Objetivo primario Linux (Ubuntu/Debian). Compatible con Windows 11 (WSL2).