# 🛠️ Herramientas y Stack Tecnológico

Este documento recoge el inventario completo de herramientas utilizadas tanto para la gestión y concepción del proyecto (Meta-Herramientas) como para su implementación técnica (Tech Stack).

## 1. Meta-Herramientas (Gestión, Diseño e IA)
Herramientas utilizadas para "construir al constructor".

| Herramienta | Uso Principal | Contexto |
| :--- | :--- | :--- |
| **Google Gemini** | **Thought Partner & Planner** | Aterrizaje de ideas, planificación de tareas, configuraciones de infraestructura, investigación técnica y corrección de errores. |
| **GEM "SoftArchitect AI"** | **Prototipado (Mago de Oz)** | Instancia personalizada de Gemini para simular el comportamiento del RAG antes de programar y validar los prompts del sistema. |
| **Claude Sonnet** | **Analista de Conocimiento** | Extracción de información estructurada de los módulos del Máster y redacción del `MASTER_WORKFLOW_0-100.md`. |
| **Notion** | **Gestión de Proyecto** | Seguimiento de tareas, checklist de hitos y repositorio de notas rápidas. |

## 2. Entorno de Desarrollo (Dev Environment)
Infraestructura física y lógica donde se cocina el código.

| Herramienta | Uso | Configuración |
| :--- | :--- | :--- |
| **HomeLab (Ubuntu Server)** | **Servidor Principal** | Host de Docker, BD Vectorial y entorno de compilación remoto. |
| **Portátil (Linux/Ryzen)** | **Cliente Fino** | Interfaz de usuario y entorno de pruebas para IA Local potente. |
| **VS Code + Remote SSH** | **IDE** | Permite desarrollar en el HomeLab desde el portátil como si fuera local. |
| **Tailscale** | **Red Mesh VPN** | Acceso seguro al entorno de desarrollo desde cualquier lugar sin abrir puertos. |
| **Git & GitHub** | **Control de Versiones** | Repositorio central, CI/CD Actions y gestión de Releases. |

## 3. Stack Tecnológico (El Producto)
Tecnologías que componen la aplicación "SoftArchitect AI".

### Backend & IA
* **Python 3.11 + FastAPI:** API Server y orquestador de lógica.
* **LangChain / LangGraph:** Framework para gestionar el flujo de conversación y recuperación de contexto.
* **Ollama:** Motor de inferencia para **Modo Local** (Privacidad total).
* **Groq API:** Proveedor de inferencia para **Modo Cloud** (Velocidad en hardware antiguo).
* **ChromaDB:** Base de datos vectorial para el RAG (Memoria a largo plazo).

### Frontend
* **Flutter (Dart):** Framework para la aplicación de escritorio nativa (Linux/Windows/Mac).
* **Riverpod:** Gestión de estado reactiva.

### Infraestructura
* **Docker Compose:** Orquestación de servicios (BD, API, IA).