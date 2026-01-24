# 🏗️ SoftArchitect AI: Asistente de Ingeniería de Software Basado en RAG

## 1. Visión del Producto
SoftArchitect AI es una plataforma de desarrollo asistido que democratiza la ingeniería de software de alto nivel. Actúa como un "Senior Architect on-demand", guiando a los desarrolladores a través de un workflow estandarizado (desde la toma de requisitos hasta el despliegue), asegurando el cumplimiento de buenas prácticas (SOLID, Clean Architecture, OWASP) mediante Inteligencia Artificial Contextual (RAG).

## 2. Problemática
El desarrollo de software moderno enfrenta dos grandes retos:
1.  **Parálisis por Análisis:** La cantidad de metodologías, patrones y herramientas abruma a los desarrolladores.
2.  **Deuda Técnica Silenciosa:** Se saltan pasos críticos (toma de requisitos formal, tests, seguridad) por falta de tiempo o conocimiento, resultando en software frágil.

**Solución:** Una herramienta que *impone* y *facilita* el ciclo de vida correcto, generando la documentación y el boilerplate automáticamente basándose en una base de conocimiento curada.

## 3. Funcionalidades Core
### 🧠 Módulo RAG (Retrieval-Augmented Generation)
* **Base de Conocimiento:** Entrenada con documentación académica y práctica (Ingeniería del Software, Arquitectura, Seguridad).
* **Contexto:** El asistente "sabe" en qué fase del proyecto estás y te da consejos específicos, no genéricos.

### 🛠️ Generadores Inteligentes (Smart Wizards)
* **Business Analyst Agent:** Convierte ideas vagas en Historias de Usuario (Gherkin) y Matrices de Requisitos.
* **Architect Agent:** Ayuda a decidir el stack tecnológico y estilo arquitectónico (Monolito vs Microservicios) mediante cuestionarios.
* **Security Guardian:** Escanea decisiones de diseño contra el OWASP Top 10 antes de escribir código.

## 4. Stack Tecnológico
* **Frontend:** Flutter (Escritorio/Web) para una UX fluida.
* **Backend AI:** Python (LangChain/LlamaIndex) + Ollama (Local) / OpenAI API.
* **Vector Database:** ChromaDB / Pinecone.
* **Infraestructura:** Docker Compose para despliegue local sencillo.

---

# 🏗️ SoftArchitect AI: Asistente de Ingeniería de Software (Local-First)

## 1. Visión del Producto
SoftArchitect AI es una plataforma de escritorio (cross-platform) que actúa como un **Arquitecto de Software Senior Asistido por IA**. Diseñada para desarrolladores y estudiantes, guía el ciclo de vida del software desde la concepción hasta el despliegue, asegurando el cumplimiento de buenas prácticas (SOLID, Clean Architecture, OWASP) mediante un motor RAG (Retrieval-Augmented Generation) 100% local y privado.

## 2. Problemática y Solución
* **El Problema:** La brecha entre la teoría académica (másters, libros) y la práctica real. Los desarrolladores a menudo ignoran la toma de requisitos formal o la seguridad por "falta de tiempo" o herramientas que lo faciliten.
* **La Solución:** Un "Copiloto de Ingeniería" que no solo genera código, sino que **estructura el pensamiento**. Impone un workflow de calidad (Requisitos -> Arquitectura -> Código -> Test) asistido por IA, funcionando totalmente offline para garantizar la privacidad del código.

## 3. Arquitectura del Sistema
El sistema sigue una arquitectura de **Microservicios Locales** orquestados por Docker, lo que permite una instalación "Zero-Config" (Clonar y Ejecutar).

### Componentes Principales:
1.  **Frontend (La Interfaz):** Aplicación desarrollada en **Flutter** (Windows/Linux/Mac/Web). Ofrece una UX rica con wizards, tableros Kanban para requisitos y diagramas visuales.
2.  **API Gateway & Logic:** Microservicio en **Python (FastAPI)**. Gestiona la lógica de negocio, la orquestación de cadenas de pensamiento (LangChain) y la comunicación con el motor de IA.
3.  **Motor de Inferencia (El Cerebro):** Instancia dockerizada de **Ollama**. Ejecuta modelos LLM (como Llama 3 o Mistral) localmente, eliminando costes de API y latencia de red.
4.  **Memoria Semántica:** Base de datos vectorial **ChromaDB** (Dockerizada). Almacena el conocimiento ingerido (PDFs de Ingeniería, Patrones, Seguridad) para realizar búsquedas semánticas (RAG).

## 4. Funcionalidades Core (MVP)
* **Business Analyst Agent:** Generación automática de Historias de Usuario (Gherkin) y Matrices de Requisitos a partir de descripciones vagas.
* **Architect Advisor:** Cuestionarios interactivos para recomendar estilos arquitectónicos (Monolito vs Microservicios) basados en criterios técnicos.
* **Security Guardian:** Análisis preventivo de riesgos basado en OWASP Top 10 antes de escribir una sola línea de código.
* **RAG Auto-Gestionado:** Capacidad de ingerir nueva documentación técnica simplemente soltando PDFs en una carpeta.

## 5. Stack Tecnológico Definitivo
* **Frontend:** Flutter (Dart).
* **Backend:** Python 3.11 + FastAPI.
* **IA Orchestration:** LangChain.
* **LLM Runtime:** Ollama (Docker).
* **Vector DB:** ChromaDB (Docker).
* **Infraestructura:** Docker Compose.

---

¡Menudo trabajo! 🤯 He analizado a fondo el `MASTER_WORKFLOW_0-100.md` y tengo que decirte que es **sobresaliente**. Es denso, técnico, y cubre desde la estrategia de negocio hasta la observabilidad en producción. Si un alumno presenta esto en un TFM, el tribunal se cae de la silla.

Aquí tienes mi **Auditoría del Workflow** y la **Hoja de Ruta para SoftArchitect AI** (qué hace el RAG vs. qué haces tú a mano).

---

### 1. 🧐 Auditoría del Master Workflow (Feedback)

**Estado:** ✅ **Production Ready**. Es sólido como una roca.
**Puntos Fuertes:**

* **Quality Gates:** Me encanta que definas criterios de "No Go" en cada fase (ej: Coverage > 80%).
* **Security Shift-Left:** Integras seguridad desde el diseño (Fase 1) y no solo al final.
* **Stack Moderno:** Next.js, Flutter, Docker, K8s... es lo que demanda el mercado.

**🔍 Pequeños "Agujeros" a cubrir (Sugerencias):**

1. **Fase de UX/UI Explicita:** En la Fase 1.1 (Arquitectura) saltas a la Fase 2 (Setup). Falta un paso intermedio de **"Prototipado de Baja Fidelidad"** antes de escribir código. Tu RAG podría sugerir herramientas (Figma/Excalidraw) pero el diseño visual lo tiene que hacer un humano.
2. **Coste Cloud (FinOps):** En la Fase 6 (Infra), añadir un cálculo estimado de costes. AWS/Azure pueden dar sustos.
3. **Legalidad (GDPR):** Mencionas GDPR en la Fase 8, pero debería estar en la **Fase 1** (Requisitos) para diseñar la base de datos acorde a la ley (Privacy by Design).

---

### 2. 🤖 ¿Qué resuelve SoftArchitect AI? (El alcance del RAG)

Aquí es donde definimos la "magia" de tu TFM. He clasificado las fases del Workflow en **Automatizables por tu RAG** vs. **Manuales/Externas**.

#### ✅ ZONA VERDE: Lo que SoftArchitect AI DEBE resolver (Core Features)

*Estas son las funcionalidades que tu app Flutter ofrecerá mediante Wizards y RAG.*

* **Fase 0: Ideación**
* **Generador de Visión:** Input: "Idea vaga" -> Output: "Product Vision Statement & MVP Scope".
* **Analista de Riesgos:** Input: "Descripción técnica" -> Output: "Risk Matrix (Technical & Business)".


* **Fase 1: Planificación**
* **Generador de Historias de Usuario:** Input: "Funcionalidad X" -> Output: Gherkin (Given-When-Then).
* **Arquitecto Virtual (ADRs):** Input: "Necesito escalar a 10k usuarios" -> Output: "ADR recomendando Tech Stack (ej: Microservicios vs Monolito)".
* **Modelado de Amenazas:** Input: "Arquitectura descrita" -> Output: "STRIDE Analysis inicial".


* **Fase 2: Setup (Scaffolding)**
* **Generador de Boilerplate:** Input: "Stack elegido" -> Output: Contenido para `docker-compose.yml`, `.env.example`, estructura de carpetas.


* **Fase 5: Seguridad**
* **Auditor de Diseño:** Input: "Descripción de feature de login" -> Output: Checklist de seguridad específica (OWASP).



#### ⚠️ ZONA AMARILLA: Asistencia (Copilot Style)

*Tu RAG genera la "receta", pero tú cocinas.*

* **Fase 3: Desarrollo**
* **Prompt Library:** Tu app no escribe el código en el IDE, pero te da el **Prompt Perfecto** para que lo pegues en GitHub Copilot (ej: "Genera este endpoint con Zod validation").


* **Fase 4: Testing**
* **Generador de Casos de Prueba:** Input: "Historia de Usuario" -> Output: "Lista de casos de prueba (Happy path, Edge cases)".


* **Fase 6: Infraestructura**
* **Generador de Manifests:** Tu RAG te da el código para el `deployment.yaml` de Kubernetes o el `Dockerfile`, tú lo guardas en el repo.



#### ❌ ZONA ROJA: Fuera de Alcance (External Tools)

*Esto NO lo hace tu app, lo hacen herramientas externas.*

* **Compilar y Ejecutar:** Tu app no es un compilador. (VS Code lo hace).
* **Despliegue Real:** Tu app no conecta con AWS para subir cosas. (GitHub Actions lo hace).
* **Monitorización en Tiempo Real:** Tu app no reemplaza a Sentry o Grafana.

---

### 3. 🧪 Prueba de Fuego: Aplicando la FASE 0 a "SoftArchitect AI"

Vamos a hacer lo que pediste: **Dogfooding**. Vamos a usar la lógica que tendría tu IA para definir TU propio proyecto.

**Simulación del RAG (Output esperado para tu proyecto):**

> **Usuario (Tú):** "Quiero crear SoftArchitect AI, un asistente local con RAG que ayude a desarrolladores a seguir un workflow de ingeniería estricto."

> **SoftArchitect AI (Respuesta Simulada):**
> ### 📋 0.1. Product Vision Statement
> 
> 
> "Una aplicación de escritorio **cross-platform (Flutter)** para **desarrolladores junior y mid-level** que actúa como un **Arquitecto Senior Virtual**, guiando el ciclo de vida del software para **eliminar la parálisis por análisis y la deuda técnica** mediante inteligencia artificial local y privada."
> ### 🎯 0.2. MVP Scope (Regla 80/20)
> 
> 
> **INCLUIR (Must Have):**
> 1. **Configuración Local:** Docker Compose con Ollama + ChromaDB (Zero-setup).
> 2. **Módulo de Requisitos:** Wizard para generar User Stories desde texto libre.
> 3. **Chat RAG Contextual:** Chatbot que responde dudas basándose *solo* en la documentación del Máster.
> 4. **Generador de Archivos:** Exportar las respuestas a Markdown/PDF.
> 
> 
> **DESCARTAR (Post-MVP):**
> * Integración directa con GitHub (GitOps).
> * Editor de código integrado (demasiado complejo).
> * Modo "Equipo" (Multi-usuario).
> 
> 
> ### ⚠️ 0.3. Matriz de Riesgos
> 
> 
> 1. **Hardware Requirements (Crítico):** Que el usuario no tenga RAM suficiente para correr Ollama (Llama 3) + Flutter + IDE.
> * *Mitigación:* Soportar modelos cuantizados pequeños (TinyLlama) o API externa opcional (OpenAI).
> 
> 
> 2. **Calidad del RAG (Alto):** Que el asistente "alucine" inventando metodologías.
> * *Mitigación:* Ajustar la "Temperature" a 0 y usar citación estricta de fuentes.
> 
> 
> 
> 

---

**¿Cómo lo ves?**
Si estás de acuerdo con este alcance y la simulación, podemos dar por validada la **Fase 0** y pasar a documentar la **Fase 1 (Arquitectura)** usando tu propio framework.

¿Te lanzo el prompt simulado para la Fase 1? 🏗️

SIMULACIÓN CON GEM:
¡Es una idea brillante! 💡 Lo que estás proponiendo se llama técnicamente **"Prototipado Mago de Oz"**: simular que el sistema funciona automáticamente (tu App Flutter) cuando en realidad hay una inteligencia detrás (el Gem) ejecutando las instrucciones.

Es la forma más barata y rápida de validar si los *outputs* de tu futura aplicación serán útiles antes de escribir una sola línea de código en Flutter.

Sí, podemos simularlo perfectamente. Aquí tienes la **Configuración del Gem "SoftArchitect AI"** para que puedas crearlo (en Google AI Studio, ChatGPT o simplemente copiando este contexto en un chat nuevo).

---

### 🧠 Configuración del GEM (System Prompt)

Copia esto en las instrucciones del sistema de tu nuevo Gem/Chat. Este prompt convierte a la IA en tu backend Python + RAG.

```markdown
**ROL:** Eres "SoftArchitect AI", un asistente de ingeniería de software senior basado en un flujo de trabajo estricto.

**BASE DE CONOCIMIENTO (Contexto):**
Tienes interiorizado el documento "MASTER_WORKFLOW_0-100.md". Tus respuestas deben basarse EXCLUSIVAMENTE en las fases, reglas y mejores prácticas descritas en ese workflow.
- Priorizas: Clean Architecture, SOLID, Seguridad (OWASP) desde el inicio y Dockerización.
- Estilo: Pragmático, directo, técnico y estructurado.

**MODO DE OPERACIÓN:**
No eres un chat conversacional libre. Funcionas mediante "Triggers" (Simulando botones de una UI).
El usuario te enviará un "Input de Contexto" y el nombre de una "Fase". Tú ejecutarás el prompt interno asociado a esa fase y devolverás el entregable estructurado.

**FORMATO DE RESPUESTA:**
Usa siempre Markdown con títulos claros, listas y bloques de código cuando sea necesario.

```

---

### 🕹️ Los "Botones" (Prompts de Fase)

En tu aplicación real, el usuario no verá esto. El usuario rellenará un formulario y tu código Flutter enviará estos prompts al backend.

Para la simulación, tú (actuando como usuario) copiarás y pegarás estos bloques.

#### 🔘 Botón 1: Fase 0 - Ideación (Business Analyst)

*Uso: Cuando tienes la idea vaga y quieres estructura.*

**Prompt a enviar al Gem:**

```markdown
[TRIGGER: FASE 0 - VISION & MVP]

**Contexto del Proyecto:**
[AQUÍ DESCRIBES TU IDEA, EJ: "Una plataforma para conectar refugios de animales con adoptantes, estilo Tinder, con donaciones"]

**Instrucción:**
Actúa como el Módulo de Ideación. Basándote en la Fase 0 del Master Workflow:
1. Genera el "Product Vision Statement" (Qué, Quién, Por qué).
2. Define el MVP Scope (Regla 80/20): Qué entra en la V1 y qué se descarta.
3. Genera la Matriz de Riesgos (Técnicos y de Negocio) y sus mitigaciones.
4. Define 3 KPIs de éxito (Métricas).

```

#### 🔘 Botón 2: Fase 1 - Arquitectura (Senior Architect)

*Uso: Cuando ya tienes la visión y necesitas el stack.*

**Prompt a enviar al Gem:**

```markdown
[TRIGGER: FASE 1 - ARQUITECTURA & STACK]

**Visión del Proyecto:**
[RESUMEN DE LO GENERADO EN FASE 0]

**Instrucción:**
Actúa como el Módulo de Arquitectura. Basándote en la Fase 1 del Master Workflow:
1. Recomienda el Tech Stack ideal (Frontend, Backend, DB) justificando con la Matriz de Decisión.
2. Redacta el ADR-001 (Architecture Decision Record) para la selección del stack.
3. Define el Diagrama de Flujo de Datos (DFD) a alto nivel.
4. Realiza un análisis de amenazas inicial (STRIDE) básico.

```

#### 🔘 Botón 3: Fase 2 - Setup (DevOps Engineer)

*Uso: Para empezar a programar.*

**Prompt a enviar al Gem:**

```markdown
[TRIGGER: FASE 2 - SCAFFOLDING]

**Stack Seleccionado:**
[EJ: FLUTTER + PYTHON + POSTGRESQL]

**Instrucción:**
Actúa como el Generador de Boilerplate. Basándote en la Fase 2 del Master Workflow:
1. Genera la estructura de carpetas del proyecto (árbol de directorios).
2. Crea el contenido del archivo `docker-compose.yml` para desarrollo local.
3. Crea el archivo `.env.example` con las variables necesarias.
4. Lista las dependencias clave a instalar.

```

---

### 🧪 ¡Vamos a probarlo AHORA!

Para hacer la "Prueba de Fuego", no necesitas irte a otro sitio. Yo puedo simular ser ese Gem ahora mismo.

**Paso 1:** Piensa en el proyecto que vamos a usar de conejillo de indias. ¿Usamos el **"SoftArchitect AI"** (el propio proyecto) o prefieres probar con la idea del **Refugio de Animales**?

**Paso 2:** Elige el proyecto y **lanzame el "Prompt del Botón 1"** (copia el bloque de arriba y rellena el contexto).

¡Dale al botón! 🔴👇

---

## 5. Validación de Concepto y Estrategia de Modelos (Post-Simulación)

### 5.1. Validación "Mago de Oz"
Se ha realizado una simulación completa de las Fases 0, 1, 2, 5 y 6 utilizando un modelo LLM avanzado (Gemini) actuando como el sistema final.
**Resultados:**
* Se confirma la viabilidad del MVP "Local-First".
* Se valida la arquitectura híbrida: Flutter (UI) + Python (Lógica RAG) + Ollama (Inferencia).
* Se detecta la necesidad crítica de estructurar el conocimiento en "Paquetes Técnicos" en lugar de documentos sueltos.

### 5.2. Estrategia de Modelos LLM (Dual Strategy)
Para equilibrar rendimiento y capacidad técnica en hardware doméstico (HomeLab), se define una estrategia de dos niveles:

1.  **Modelo de Testing/Rapid Response:** **Phi-3.5 Mini (3.8B)**.
    * *Uso:* Validación de infraestructura, respuestas rápidas de chat general y entornos con <8GB RAM.
    * *Ventaja:* Despliegue inmediato y bajísima latencia.

2.  **Modelo de Producción/Coding:** **Qwen2.5-Coder (7B)** (Opción B de Alibaba).
    * *Uso:* Generación de código, refactorización y análisis de arquitectura.
    * *Ventaja:* Especializado en múltiples lenguajes de programación, superando a modelos generalistas en benchmarks de código (HumanEval).

### 5.3. Nueva Arquitectura de Conocimiento: "Tech Packs"
Inspirado en la metodología del proyecto *GuauGuauCars*, el RAG no será un contenedor genérico de PDFs. Se estructurará en **Tech Packs** (Paquetes de Tecnología) que contienen:
* **Identidad:** Plantillas `AGENTS.md` dinámicas.
* **Reglas:** Archivos de reglas de linter y arquitectura (`RULES.md`).
* **Estructura:** Árboles de directorios estándar (`scaffolding.tree`).
* **Procesos:** Flujos de trabajo específicos (ej: TDD para Flutter).

---

## 6. Arquitectura de Inferencia Híbrida (Provider Agnostic)

### 6.1. El Problema del Hardware Heterogéneo
Las pruebas de estrés revelaron que la inferencia local de LLMs requiere instrucciones de CPU modernas (AVX2) o GPU dedicada, lo que excluye a equipos antiguos (HomeLabs legados) de ejecutar el software.

### 6.2. Solución: Patrón Strategy para LLMs
Se implementa una capa de abstracción en el Backend (`LLMService`) que permite inyectar diferentes proveedores de inteligencia en tiempo de ejecución mediante configuración (`.env`), sin modificar el código fuente.

**Selectores Disponibles (`LLM_PROVIDER`):**
1.  **`local` (Ollama):** Para equipos con hardware moderno (Ryzen/Apple Silicon/NVIDIA). Privacidad total.
2.  **`cloud` (Groq):** Para equipos modestos o antiguos. Velocidad extrema mediante LPUs en la nube, sacrificando la privacidad estricta del prompt en tránsito.

Esta decisión transforma a *SoftArchitect AI* de una herramienta "Local-Only" a una "Local-First Capable", ampliando su compatibilidad al 100% de los desarrolladores.