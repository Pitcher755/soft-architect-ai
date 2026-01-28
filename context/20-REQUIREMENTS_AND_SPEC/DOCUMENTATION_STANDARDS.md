# 📝 Estándares de Documentación (The Knowledge Arch)

> **Objetivo:** Mantener una distinción clara entre la documentación del proyecto ("Bitácora") y el conocimiento que consume la IA ("Cerebro").

---

## 1. Taxonomía de Directorios

### 📘 `doc/` (Documentación Viva / Bitácora)
* **Audiencia:** Humanos (Desarrolladores, Auditores, Usuarios).
* **Contenido:**
    * Cómo instalar el proyecto (`SETUP_GUIDE`).
    * Por qué tomamos esta decisión (`adr/`).
    * Estado de los Sprints y User Stories (`user-stories/`).
    * La memoria del TFM (`MEMORIA_METODOLOGICA`).
* **Formato:** Markdown libre, explicativo, con diagramas Mermaid si es necesario.

### 🧠 `packages/knowledge_base/` (Cerebro RAG / Assets)
* **Audiencia:** Agentes de IA (ArchitectZero).
* **Contenido:**
    * **Reglas puras:** "En Flutter se usa camelCase".
    * **Plantillas:** Archivos `.template.md` vacíos para rellenar.
    * **Facts:** Datos técnicos objetivos sobre las tecnologías usadas.
* **Formato:** Markdown estricto, atómico (archivos pequeños), optimizado para ser vectorizado (Chunking friendly). Evitar introducciones largas. Ir al grano.

---

## 2. Reglas de Escritura (Style Guide)

### Para `doc/`
1.  **Idioma:** Español (Nativo del proyecto).
2.  **Tono:** Profesional, académico pero pragmático.
3.  **Actualización:** Debe actualizarse en el mismo Pull Request que cambia el código (`Docs-as-Code`).

### Para `packages/knowledge_base/`
1.  **Idioma:** Preferiblemente Inglés para términos técnicos (mejor comprensión del LLM), o Español técnico neutro.
2.  **Estructura:**
    * Usar Headers (`#`, `##`) claramente para facilitar el *Semantic Splitting*.
    * Usar bloques de código para ejemplos (` ```python `).
3.  **Meta-data:** Si es posible, incluir un bloque de frontmatter o una cabecera de contexto:
    ```markdown
    > **Contexto:** Flutter / Riverpod Rules
    > **Uso:** Consultar al generar StateNotifiers.
    ```

---

## 3. Diagramas y Visuales

Se recomienda el uso de **Mermaid.js** incrustado en el Markdown para diagramas de arquitectura, ya que es legible por humanos y por IAs (como texto).

```mermaid
graph TD;
    A[User Input] --> B(Flutter Client);
    B --> C{Backend API};
    C -->|Local| D[Ollama];
    C -->|Cloud| E[Groq];