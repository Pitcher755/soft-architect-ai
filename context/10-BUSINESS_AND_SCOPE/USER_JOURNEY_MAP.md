# 🗺️ Mapa de Viaje del Usuario (User Journey)

> **Persona:** Javier (Senior Dev & Architect).
> **Meta:** Crear un MVP robusto en Flutter/Python sin perder tiempo en boilerplate ni decisiones triviales.

---

## 1. Fase de Instalación y Onboarding (Day 0)

| Paso | Acción del Usuario | Respuesta del Sistema (SoftArchitect) | Touchpoints |
| :--- | :--- | :--- | :--- |
| **1.1** | Descarga y ejecuta el instalador `.AppImage` (Linux). | Muestra pantalla de **Splash** y verifica prerrequisitos (Docker, GPU). | UI: Splash Screen |
| **1.2** | Selecciona "Modo Local" (Privacidad Máxima). | Inicia contenedores Docker (`ollama`, `chroma`) en segundo plano. Muestra "Semáforo Verde". | UI: Setup Wizard |
| **1.3** | Configura API Keys (opcional para Groq). | Guarda secretos en Secure Storage local. | UI: Settings Modal |

---

## 2. Fase de Creación de Proyecto (The Setup)

| Paso | Acción del Usuario | Respuesta del Sistema | Touchpoints |
| :--- | :--- | :--- | :--- |
| **2.1** | Clic en "Nuevo Proyecto" -> Elige "Flutter + Python". | Carga los **Tech Packs** correspondientes en memoria. Inicia la entrevista. | UI: Chat |
| **2.2** | Responde a la entrevista: "Riverpod, Clean Arch, Material 3". | Genera el archivo `RULES.md` interno y el árbol de directorios virtual. | RAG: Contexto |
| **2.3** | Pide: "Genera el Scaffolding inicial". | Devuelve un script `setup.sh` o comandos de terminal para crear carpetas. | Chat: Code Block |

---

## 3. Fase de Desarrollo (The Loop)

*Ciclo repetitivo: Requisito -> Código -> Test.*

| Paso | Acción del Usuario | Respuesta del Sistema | Touchpoints |
| :--- | :--- | :--- | :--- |
| **3.1** | Prompt: "Quiero una pantalla de Login con validación de email". | Analiza `DEFINITION_OF_READY.md`. Si faltan datos, pregunta. Si OK, busca en `DESIGN_SYSTEM.md`. | RAG: Retrieval |
| **3.2** | Confirma diseño. | 1. Genera los Tests (`login_test.dart`).<br>2. Genera el Código (`login_screen.dart`). | Chat: Streaming |
| **3.3** | Reporta error: "El test falló con error X". | Analiza el error contra `ERROR_HANDLING_STANDARD.md` y propone el fix. | Chat: Debugging |

---

## 4. Fase de Documentación y Cierre

| Paso | Acción del Usuario | Respuesta del Sistema | Touchpoints |
| :--- | :--- | :--- | :--- |
| **4.1** | Pide: "Genera el ADR de la autenticación". | Redacta el documento `001-auth.md` siguiendo la plantilla `ADR.template.md`. | Chat: Doc Gen |
| **4.2** | Pide: "Prepara el commit". | Sugiere mensaje: `feat(auth): add login screen validation`. | Chat: Git Helper |

---

## 5. Puntos de Dolor y Mitigación (Pain Points)

* **Latencia:** Si Ollama tarda >5s, mostrar "Pensando..." con animación fluida para mantener la paciencia.
* **Alucinación:** Si el usuario pide algo fuera del stack (ej: "Usa GetX"), el sistema debe responder: "Según `RULES.md`, usamos Riverpod. ¿Quieres proceder igual?".