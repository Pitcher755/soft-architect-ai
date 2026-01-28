# 🖼️ Prototipado de Pantallas y Generación AI

> **Herramienta Recomendada:** [Stitch Design with AI](https://stitch.design) / [v0.dev](https://v0.dev)
> **Objetivo:** Generar referencias visuales y código base (HTML/Tailwind) para ser portado a Flutter.

---

## 1. Mapa de Pantallas (Screen Flow)

1.  **Splash & Onboarding:** Bienvenida, verificación de Docker, Selección de Modo (Local/Cloud).
2.  **Main Layout (The Shell):** Estructura base con Sidebar y Chat Area.
3.  **Settings Modal:** Configuración de modelos, rutas y parámetros.

---

## 2. Prompts de Generación (Ready-to-Use)

*Copia estos prompts en inglés para obtener los mejores resultados en Stitch o v0.*

### 🎨 Prompt 1: El Layout Principal (Dashboard)

```text
Design a professional "Developer AI Assistant" desktop application interface. Dark mode theme inspired by VS Code and GitHub Dark.

Layout structure:
1. Left Sidebar (width 250px, dark grey #161B22):
   - Top: App Logo "SoftArchitect" + "New Chat" button (primary blue).
   - Middle: List of recent chat history (titles like "Flutter Setup", "Python API Error").
   - Bottom: User profile and "Settings" gear icon.

2. Main Content Area (center, black/dark grey #0D1117):
   - A chat interface.
   - Top header: "Current Project: GuauGuauCars" and a Toggle Switch "Local Mode (Ollama) / Cloud Mode".
   - Center: Chat bubbles.
     - User message (right aligned, subtle blue tint): "How do I implement Clean Architecture in Flutter?".
     - AI message (left aligned, grey card): A detailed response containing a Code Block with syntax highlighting (Python/Dart colors).

3. Bottom Input Area:
   - A clean, large text input field with a "Send" icon and an "Attach File" paperclip icon.

Style: Minimalist, clean typography (Inter font), rounded corners (8px), flat design, electric blue accents. High fidelity wireframe.

```

### 🎨 Prompt 2: Pantalla de Configuración (Settings)

```text
Design a "Settings" modal window for a developer tool. Dark mode.

Layout:
- Title: "System Configuration".
- Two main sections:

Section 1: AI Engine
- Dropdown: "Model Provider" (Options: Ollama Local, Groq Cloud).
- Input field: "API Key" (masked with dots).
- Slider: "Temperature" (0.0 to 1.0).

Section 2: Knowledge Base
- List of "Tech Packs" with checkboxes:
  - [x] Flutter Mobile
  - [x] Python FastAPI
  - [ ] React Web
- Button: "Rescan Knowledge Base" (Green outline).

Style: Professional, data-dense but readable. Use toggles and crisp borders.

```

### 🎨 Prompt 3: Onboarding / Setup Wizard

```text
Design a clean, centered "Setup Wizard" screen for a desktop app. Dark background.

Center Card:
- Title: "Welcome to SoftArchitect AI".
- A step-by-step vertical stepper on the left (1. Prerequisites, 2. AI Model, 3. Finish).
- Content Area:
  - Status Indicators (Traffic lights):
    - [Green Check] Docker is running.
    - [Green Check] GPU detected (NVIDIA RTX 3060).
    - [Red Cross] Ollama not responding.
  - Button: "Retry Connection" (Secondary style).
  - Button: "Continue" (Primary Blue, currently disabled).

Style: Friendly but technical.

```

---

## 3. Workflow: Del Prompt al Código (The Bridge)

Para mantener la trazabilidad del diseño, sigue este proceso estrictamente:

1. **Generar:** Pega el prompt en *Stitch* o *v0.dev*.
2. **Iterar:** Refina el diseño con instrucciones adicionales si es necesario (ej: "Make the buttons flatter").
3. **Exportar:** Copia el código generado (HTML/CSS o React/Tailwind).
4. **Documentar:** Crea un archivo nuevo en la carpeta `doc/prototypes/` usando la plantilla de abajo.

> **Nota:** No usamos el código HTML directamente en producción, pero sirve como "Blueprint" exacto para que el programador (o Copilot) sepa qué Widgets de Flutter construir (Column, Row, Container con bordes específicos, colores Hex exactos).

---

## 4. Plantilla de Documentación de Prototipo

Para cada pantalla generada, crea un archivo `.md` (ej: `doc/prototypes/01_MAIN_DASHBOARD.md`) con este contenido:

```markdown
# 🖼️ Prototipo: {{SCREEN_NAME}}

> **Fecha:** {{DATE}}
> **Herramienta:** Stitch / v0
> **Estado:** Draft / Aprobado

## 1. Prompt Utilizado
```text
{{PROMPT_USED}}

```

## 2. Resultado Visual (Preview)

## 3. Código Referencia (HTML/Tailwind)

```html
{{GENERATED_CODE}}

```

## 4. Análisis de Implementación en Flutter

*Traducción técnica a Widgets*

* **Layout Principal:** (ej: `Row(children: [NavigationRail, Expanded(...)])`)
* **Colores Clave detectados:**
* Fondo: `Color(0xFF0D1117)`
* Acento: `Color(0xFF58A6FF)`


* **Componentes Reutilizables:**
* (ej: Extraer el botón del sidebar como `SidebarButtonWidget`)
