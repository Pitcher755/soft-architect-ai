# 📄 White Paper: SoftArchitect AI

> **Estado:** Draft V2
> **Fecha:** Enero 2026
> **Foco:** Democratización de la Arquitectura de Software mediante IA Contextual.

---

## 1. Executive Summary
SoftArchitect AI es una plataforma de desarrollo asistido ("AI-Augmented Development Environment") diseñada para actuar como un **Quality Gate Inteligente**. A diferencia de los asistentes de código genéricos (Copilot, ChatGPT), SoftArchitect no solo "escribe código", sino que **impone y facilita un workflow de ingeniería estricto** (Requirements -> Architecture -> Code -> Test), utilizando una base de conocimiento curada (RAG) y paquetes de reglas tecnológicas (**Tech Packs**).

---

## 2. El Problema (The Pain)
1.  **Juniorización del Software:** El acceso masivo a la programación ha bajado la barrera de entrada, pero ha disparado la deuda técnica.
2.  **Parálisis por Análisis:** La cantidad de frameworks y patrones bloquea la toma de decisiones.
3.  **Contexto Perdido:** Los LLMs genéricos no conocen las reglas específicas de tu empresa o proyecto (Naming conventions, estructura de carpetas).

---

## 3. La Solución (The Product)
Un sistema **RAG (Retrieval-Augmented Generation)** que:
1.  **Entiende el Proyecto:** Sabe si estás en Flutter o Python y carga las reglas específicas (`Tech Packs`).
2.  **Guía el Proceso:** No te deja escribir código sin antes haber definido la arquitectura (ADRs) y los tests.
3.  **Opera Local-First:** Prioriza la privacidad ejecutando modelos (Ollama/Qwen) en local, con fallback a nube (Groq) para rendimiento.

---

## 4. Arquitectura Conceptual

### 4.1. El Cerebro (Knowledge Base)
El núcleo del sistema no es el modelo de IA, sino su **Memoria Estructurada** (`packages/knowledge_base`):
* **Templates:** Plantillas estándar de la industria (STRIDE, C4 Model).
* **Tech Packs:** Reglas específicas por tecnología (ej: "En Flutter usamos Riverpod, no GetX").
* **Contexto Vivo:** Documentación generada dinámicamente (`AGENTS.md`).

### 4.2. El Motor (Hybrid AI Engine)
* **Orquestación:** **LangChain** (Python) gestiona el flujo de pensamiento y herramientas.
* **Inferencia:** * *Local:* Ollama (Qwen2.5-Coder) para privacidad máxima.
    * *Cloud:* Groq (Llama 3 / Mixtral) para velocidad extrema.

---

## 5. Roadmap Estratégico
* **Fase 1 (Actual):** MVP CLI/Desktop. Generación de documentación y estructura (Scaffolding).
* **Fase 2:** Agentes Autónomos. El sistema escribe los tests y el boilerplate basándose en las especificaciones.
* **Fase 3:** IDE Integration. Plugin para VS Code que audita en tiempo real.
