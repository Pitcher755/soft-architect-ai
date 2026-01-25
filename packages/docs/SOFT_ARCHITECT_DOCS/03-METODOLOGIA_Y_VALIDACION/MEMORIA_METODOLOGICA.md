# 📓 Memoria Metodológica: El Origen y las Herramientas

## 1. Origen de la Idea
Este proyecto nace como respuesta a una necesidad detectada durante el propio cursado del Máster en Desarrollo con IA: **la necesidad de operacionalizar el conocimiento**.

En lugar de dejar la teoría de los módulos (Ingeniería, Arquitectura, Seguridad) en PDFs estáticos, la idea es **crear un sistema que contenga ese conocimiento y ayude a aplicarlo activamente**. Es un proyecto "Meta": usar la IA para construir una herramienta que usa IA para mejorar el desarrollo de software.

## 2. Metodología de Desarrollo: "AI-Driven Development"
Para la concepción y documentación de este proyecto, se ha utilizado una metodología híbrida humano-IA, actuando la IA (Modelos LLM avanzados) como **Arquitecto Consultor**.

### Herramientas utilizadas:
* **Copilot & LLMs:** Utilizados no solo para autocompletar código, sino para:
    * Generar estructuras de documentación (como este archivo).
    * Simular roles (Business Analyst, DevOps Engineer) para validar ideas.
    * Sintetizar grandes volúmenes de documentación técnica.
* **RAG (Retrieval-Augmented Generation):** La propia técnica que implementa el proyecto se ha usado para estructurarlo, alimentando al asistente con los temarios del máster para asegurar coherencia académica.

## 3. Aplicación del Módulo de Infraestructura y Cloud
El módulo de Infraestructura es la columna vertebral que hace viable este proyecto. No se trata solo de "subir código", sino de diseñar un sistema desplegable y mantenible.

### Cómo se aplica el Módulo 7 al Workflow de SoftArchitect:
1.  **Dockerización desde el Día 0:** * Para garantizar que el módulo de IA (Python/RAG) y el Frontend (Flutter) funcionen igual en cualquier máquina, se define todo en `docker-compose.yaml`.
    * *Justificación del Máster:* Contenerización para evitar el "works on my machine".
    
2.  **Infraestructura como Código (IaC):**
    * La definición de los servicios vectoriales y la API se gestiona mediante scripts declarativos, permitiendo recrear el entorno en segundos.

3.  **Estrategia de Despliegue (CI/CD):**
    * Se diseñan pipelines (GitHub Actions) que no solo corren tests, sino que verifican la integridad de la base de conocimiento RAG.
    * *Concepto aplicado:* Automatización del ciclo de vida y Quality Gates.

4.  **Observabilidad:**
    * Integración futura de herramientas de monitoreo para ver la latencia de las respuestas de la IA (concepto clave en LLMOps visto en el módulo).

5.  **Automatización de Documentación (Docs-as-Code):**
    * Se ha implementado un pipeline de **Integración Continua de Conocimiento**.
    * La documentación reside junto al código (Markdown en Git), pero se despliega automáticamente a Notion mediante **n8n** y Webhooks.
    * *Justificación:* Elimina la desincronización entre lo que hace el código y lo que dice la documentación, aplicando principios DevOps a la gestión del conocimiento.

---

# 📓 Memoria Metodológica: Ingeniería y Decisiones Arquitectónicas

## 1. Introducción
Este documento justifica las decisiones técnicas tomadas para el desarrollo de **SoftArchitect AI**, vinculándolas directamente con los conocimientos adquiridos en el Máster de Desarrollo con IA. El objetivo no es solo construir una herramienta útil, sino demostrar la capacidad de diseñar sistemas complejos, escalables y desplegables.

## 2. Aplicación del Módulo de Arquitectura de Software
Se ha optado por una arquitectura de **Microservicios Locales**.

* **Decisión:** Separar el Frontend (Flutter) del Backend de IA (Python).
* **Justificación (Clean Architecture):** Esta separación de responsabilidades permite que la UI evolucione independientemente del motor de inteligencia artificial. Si mañana queremos cambiar Ollama por OpenAI API, solo tocamos el servicio de Python; el Frontend en Flutter ni se entera.
* **Patrón Ports & Adapters:** El servicio Python actúa como un adaptador que "habla" con el LLM y la Base Vectorial, exponiendo una API REST limpia al dominio (el usuario en Flutter).

## 3. Aplicación del Módulo de Infraestructura y Cloud
El mayor reto técnico de este proyecto es la **Portabilidad**. Al usar modelos de IA locales, la configuración del entorno suele ser una pesadilla ("instala Python, instala drivers de CUDA, instala Ollama...").

**Solución Implementada: Docker Compose "Self-Contained"**
Hemos aplicado los principios de Contenerización para crear un entorno reproducible 100%.

* **Orquestación:** Un único archivo `docker-compose.yaml` levanta 3 contenedores coordinados:
    1.  `softarchitect-backend`: La API en FastAPI.
    2.  `softarchitect-vector-db`: ChromaDB persistente.
    3.  `ollama-service`: El motor de inferencia.
    
* **Automatización (IaC):** Se ha diseñado un *entrypoint script* personalizado para el contenedor de Ollama. Este script verifica al inicio si el modelo LLM necesario (ej: `llama3`) está descargado. Si no, lo descarga automáticamente ( `ollama pull`) antes de declarar el servicio como "Healthy". Esto garantiza la experiencia de "Clonar y Ejecutar" sin pasos manuales.

## 4. Aplicación del Módulo de Calidad y Testing
* **Frontend:** Tests de Widgets en Flutter para asegurar que los formularios de requisitos y la visualización de respuestas son robustos.
* **Backend:** Tests unitarios en Python (Pytest) para validar la lógica de construcción de prompts y la conexión con ChromaDB.
* **RAG Evaluation:** (Fase futura) Implementación de "RAGAS" para medir la precisión y fidelidad de las respuestas generadas por el sistema frente a la documentación base.

## 5. Aplicación del Módulo de Seguridad
* **Privacidad por Diseño (Privacy by Design):** Al elegir un stack local (Ollama + ChromaDB), garantizamos que el código o las ideas de proyecto del usuario **nunca salen de su máquina**. Esto es crítico para una herramienta que maneja propiedad intelectual.
* **Sanitización:** La API de Python implementa validaciones estrictas (Pydantic) para evitar inyecciones de prompts maliciosos.

---

## 6. Estrategia de Desarrollo Remoto (HomeLab & Tailscale)
Para maximizar la eficiencia y simular un entorno de producción real desde el primer día, se ha optado por una arquitectura de **Desarrollo Remoto (Remote Development)**.

### 6.1. Arquitectura Física vs. Lógica
* **HomeLab (The Powerhouse):** Un servidor Ubuntu Server con Docker Engine. Aloja el código fuente, la base de datos vectorial (ChromaDB), el motor de IA (Ollama) y ejecuta los procesos de compilación.
* **Portátil (Thin Client):** Actúa meramente como interfaz de usuario. No almacena código ni ejecuta cargas de trabajo pesadas.
* **Conectividad:** Se utiliza **VS Code Remote - SSH** para conectar el IDE local directamente al sistema de archivos del servidor.

### 6.2. Ventajas del Stack
1.  **Entorno Inmutable:** Al estar todo dockerizado en el servidor, no importa si cambio de portátil o formateo; el entorno de desarrollo sigue intacto.
2.  **Potencia de IA:** Los modelos LLM (Llama 3) corren en el hardware del servidor (CPU/GPU dedicados), liberando los recursos del portátil para navegación y ofimática.
3.  **Ubicuidad (Tailscale):** Se integra una red Mesh VPN (Tailscale) que permite acceder al entorno de desarrollo desde cualquier lugar del mundo de forma segura, sin abrir puertos en el router.

### 6.3. Workflow de Pruebas
* **Fase de Desarrollo:** Se utiliza `flutter run -d web-server` en el servidor. VS Code realiza un *Port Forwarding* automático a través del túnel SSH, permitiendo ver y depurar la aplicación en el navegador del portátil local (`localhost:8080`) como si se ejecutara nativamente.
* **Fase de Release:** Para compilaciones nativas móviles, se utiliza *Wireless Debugging* o un pipeline de CI/CD que genera los binarios (APK/EXE) listos para descarga.

---

## 7. Validación Temprana: Simulación "Mago de Oz"
Antes de escribir el código fuente, se ejecutó una fase de **Prototipado de Prompt (Prompt Engineering)** simulando el comportamiento del sistema final.
* **Objetivo:** Validar si el *Master Workflow* es capaz de generar entregables útiles (Vision Statements, ADRs, Dockerfiles) sin intervención humana creativa.
* **Resultado:** La simulación confirmó que, con el contexto adecuado, el sistema puede actuar como un "Arquitecto Senior", reduciendo la incertidumbre del proyecto antes de la fase de desarrollo.

## 8. Evolución del RAG: Arquitectura de Contexto Estructurado
Se ha pivotado de un enfoque RAG tradicional (búsqueda semántica en documentos desestructurados) a una **Arquitectura de Contexto Estructurado**.

### 8.1. Ingeniería Inversa de Casos de Éxito
Se analizó el proyecto real *GuauGuauCars* (desarrollado por el autor) para extraer los patrones de éxito que facilitaron el desarrollo con Copilot. Se identificaron cuatro pilares de contexto necesarios:
1.  **Identidad Técnica:** Definición de roles (ej: `AGENTS.md`).
2.  **Reglas de Oro:** Restricciones técnicas explícitas (ej: `TESTING_RULES.md`).
3.  **Mapa Estructural:** Definición de la arquitectura de carpetas.
4.  **Flujos de Trabajo:** Procedimientos estandarizados (GitFlow, TDD).

### 8.2. El concepto de "Meta-Plantillas"
Para replicar este éxito en cualquier tecnología, SoftArchitect AI utilizará **Meta-Plantillas** (como `UNIVERSAL_AGENTS.md`) que se rellenan dinámicamente según el stack del usuario (Tech Packs), garantizando que el asistente de IA siempre tenga un contexto de alta calidad ("Garbage In, Garbage Out" mitigado).

---

## 9. Pivote Técnico: Adaptabilidad de Hardware
Durante la fase de validación técnica ("The Fire Test"), se identificó un cuello de botella crítico en servidores domésticos antiguos (ausencia de instrucciones AVX en CPUs pre-2011), haciendo inviable la ejecución local de modelos, incluso los más ligeros ("TinyLlama").

### Decisión de Diseño:
En lugar de restringir el software a hardware de gama alta, se optó por una **Arquitectura Híbrida**. Se integra **Groq Cloud** como fallback transparente. Esto permite desarrollar y testear la lógica del RAG en el HomeLab (usando nube rápida) y desplegar en producción local o en el portátil potente (usando Ollama) con el mismo codebase. Es un ejemplo práctico de cómo la infraestructura dicta decisiones de arquitectura de software.
