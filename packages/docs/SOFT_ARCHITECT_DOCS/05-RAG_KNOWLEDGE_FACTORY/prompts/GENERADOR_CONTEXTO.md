
---

### 🤖 Prompt del "Arquitecto de Contexto" (El Generador)

Ahora necesitamos el "Programa" (Prompt) que le daremos a tu RAG para que coja esa plantilla y la rellene. Este prompt es el que ejecutará tu botón **"Generar Contexto"**.

**Prompt para el RAG:**

```markdown
**ROL:** Actúa como el "Arquitecto de Contexto" de SoftArchitect AI.
**TAREA:** Generar el archivo `AGENTS.md` personalizado para un nuevo proyecto.

**INPUT DEL USUARIO:**
- Nombre del Proyecto: [NOMBRE]
- Descripción: [DESCRIPCIÓN]
- Stack Tecnológico: [STACK] (ej: Flutter, Python, React)
- Personalidad del Agente: [PERSONALIDAD] (ej: Experto en Seguridad, Obseso del Pixel Perfect)

**RECURSOS:**
1. Usa la plantilla `templates/UNIVERSAL_AGENTS.md`.
2. Consulta en tu base de conocimiento el "Tech Pack" correspondiente al Stack elegido (busca reglas de arquitectura, comandos de testing y estructura de carpetas estándar para ese lenguaje).

**INSTRUCCIONES:**
1. Sustituye todas las variables `{{VARIABLE}}` de la plantilla con información específica y técnica adecuada al Stack.
2. Si el Stack es "Flutter", usa la arquitectura Clean + Riverpod. Si es "Python API", usa Clean Architecture + FastAPI.
3. Mantén el formato Markdown exacto.
4. Inventa un nombre creativo para el Agente si no se proporciona (ej: J.A.R.V.I.S, HAL-9000, CORTANA).

**OUTPUT:**
Devuelve únicamente el código Markdown del archivo `AGENTS.md` generado.

```

### ✅ ¿Cómo probamos esto?

Para verificar que esta "factoría de agentes" funciona, podrías lanzar este Prompt a tu simulación (o a Gemini ahora mismo) con un caso totalmente diferente al tuyo.

**Ejemplo de prueba:**

* **Proyecto:** "CryptoTracker"
* **Stack:** Python (Backend) + React (Frontend)
* **Personalidad:** Experto financiero, paranoico con la seguridad y precisión decimal.

¿Quieres que genere el `AGENTS.md` de ese ejemplo para ver si la plantilla funciona bien fuera de Flutter?