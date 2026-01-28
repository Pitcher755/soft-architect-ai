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
| **3.1** | Describe una feature: "Necesito una pantalla de login con email/password". | Valida contra DoR (Definition of Ready). Si incompleto, pide más detalles. | Chat: Validation |
| **3.2** | Proporciona requisitos completos. | Genera el código UI (Flutter Widget) y endpoint API (Python). | Chat: Code Generation |
| **3.3** | Pregunta: "¿Cómo pruebo esto?". | Proporciona tests unitarios para el UseCase y tests de integración para la API. | Chat: Test Generation |
| **3.4** | Ejecuta tests y fallan. | Analiza el error y sugiere fixes (ej: "Añade @riverpod annotation"). | Chat: Debugging |

---

## 4. Fase de Aseguramiento de Calidad (The Gate)

| Paso | Acción del Usuario | Respuesta del Sistema | Touchpoints |
| :--- | :--- | :--- | :--- |
| **4.1** | Clic en "Ejecutar Checks QA". | Ejecuta linting, checks de accesibilidad y scans OWASP. | UI: QA Dashboard |
| **4.2** | Corrige issues basados en feedback. | Actualiza las sugerencias de código en tiempo real. | Chat: Iterative Refinement |

---

## 5. Fase de Despliegue (The Release)

| Paso | Acción del Usuario | Respuesta del Sistema | Touchpoints |
| :--- | :--- | :--- | :--- |
| **5.1** | Clic en "Build para Producción". | Genera el binario ejecutable y la imagen Docker. | UI: Build Progress |
| **5.2** | Despliega en entorno local. | Monitorea logs y proporciona troubleshooting. | UI: Deployment Logs |

---

## Principios Clave en el Viaje

* **Conciencia de Contexto:** El sistema recuerda decisiones pasadas y fuerza consistencia (ej: "Elegiste Riverpod, así que lo usaré aquí también").
* **Indicador de Privacidad:** Siempre muestra si los datos salen de la máquina (ej: icono de nube para Groq).
* **Prevención de Alucinación:** Si el usuario pide algo fuera del stack (ej: "Usa GetX"), el sistema debe responder: "Según `RULES.md`, usamos Riverpod. ¿Quieres proceder igual?".