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
   /* Lines 28-29 omitted */
   - Bottom: User profile and "Settings" gear icon.

2. Main Content Area (center, black/dark grey #0D1117):
   - A chat interface.

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
  /* Lines 62-63 omitted */
  - [ ] React Web
- Button: "Rescan Knowledge Base" (Green outline).
