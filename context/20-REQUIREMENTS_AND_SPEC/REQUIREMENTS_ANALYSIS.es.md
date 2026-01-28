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
* **NFR-01 Operación Local-First (P1):** Por defecto, todo el procesamiento (RAG, inferencia) debe ocurrir en la máquina del usuario. Uso de nube solo con consentimiento explícito.
* **NFR-02 Soberanía de Datos (P1):** Los datos del usuario (conversaciones, configuraciones) nunca deben salir de la máquina local sin permiso explícito. Usar almacenamiento local encriptado.
* **NFR-03 Privacidad Transparente (P1):** La UI debe indicar claramente cuándo se envían datos a la nube (ej: icono de nube ámbar para modo Groq).
* **NFR-04 Cumplimiento OWASP (P1):** Implementar medidas básicas de seguridad contra vulnerabilidades de LLM (Prompt Injection, Insecure Output Handling).

### 🖥️ Rendimiento y Usabilidad
* **NFR-05 Responsividad UI (P1):** La UI debe permanecer responsiva durante el procesamiento de IA (usar UI optimista, spinners, procesamiento en background).
* **NFR-06 Baja Latencia (P2):** Tiempo de respuesta <200ms para interacciones UI, <2s para inferencia local, <5s para nube.
* **NFR-07 Accesibilidad (P2):** Cumplimiento WCAG 2.1 AA para desktop (navegación por teclado, lectores de pantalla).
* **NFR-08 Multiplataforma (P2):** Primario Linux, compatible con Windows 11 (WSL2).

### 🔧 Restricciones Técnicas
* **NFR-09 Eficiencia RAM (P1):** Máximo 2GB de uso de RAM para inferencia local (optimización Ollama).
* **NFR-10 Capacidad Offline (P1):** La funcionalidad core debe funcionar sin internet (modelos locales).
* **NFR-11 Modularidad (P2):** La arquitectura debe permitir añadir nuevos Tech Packs fácilmente sin cambios de código.
* **NFR-12 Testabilidad (P2):** >80% cobertura de código en lógica de negocio (Dart/Python).

---

## 3. Criterios de Aceptación (DoD - Definition of Done)

Para cada requisito, se debe cumplir lo siguiente:

* [ ] **Código Implementado:** Feature codificada según Clean Architecture.
* [ ] **Tests Escritos:** Tests unitarios e integración pasando.
* [ ] **Documentación Actualizada:** Specs y guías de usuario reflejan el cambio.
* [ ] **Seguridad Revisada:** Scan OWASP pasado.
* [ ] **UI/UX Validada:** Wireframes actualizados, accesibilidad chequeada.
* [ ] **Rendimiento Probado:** Cumple límites de latencia y RAM de NFR.