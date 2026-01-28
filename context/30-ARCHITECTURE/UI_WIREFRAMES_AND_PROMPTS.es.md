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

*Copia estos prompts en español para obtener los mejores resultados en Stitch o v0.*

### 🎨 Prompt 1: El Layout Principal (Dashboard)

```text
Diseña una interfaz profesional de aplicación de escritorio "Asistente de IA para Desarrolladores". Tema modo oscuro inspirado en VS Code y GitHub Dark.

Estructura de layout:
1. Barra lateral izquierda (ancho 250px, gris oscuro #161B22):
   - Arriba: Logo de la app "SoftArchitect" + botón "Nuevo Chat" (azul primario).
   - Centro: Lista de chats recientes con iconos de conversación.
   - Abajo: Perfil de usuario e icono de engranaje "Configuración".

2. Área de contenido principal (centro, negro/gris oscuro #0D1117):
   - Una interfaz de chat.

3. Área de entrada inferior:
   - Un campo de entrada de texto limpio y grande con icono "Enviar" e icono de clip "Adjuntar Archivo".

Estilo: Minimalista, tipografía limpia (fuente Inter), esquinas redondeadas (8px), diseño plano, acentos azul eléctrico. Wireframe de alta fidelidad.

```

### 🎨 Prompt 2: Pantalla de Configuración (Settings)

```text
Diseña una ventana modal de "Configuración" para una herramienta de desarrollador. Modo oscuro.

Layout:
- Título: "Configuración del Sistema".
- Dos secciones principales:

Sección 1: Motor de IA
- Dropdown: "Proveedor de Modelo" (Opciones: Ollama Local, Groq Cloud).
- Campo de entrada: "Clave API" (enmascarada con puntos).
- Slider: "Temperatura" (0.0 a 1.0).

Sección 2: Base de Conocimiento
- Lista de "Tech Packs" con casillas de verificación:
  - [x] Flutter Mobile
  - [x] Python FastAPI
  - [ ] React Web
- Botón: "Reescanear Base de Conocimiento" (contorno verde).
