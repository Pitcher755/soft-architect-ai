# 🎨 Design System & UI Guidelines

> **Estética:** "Developer Experience First". Minimalista, Alto Contraste, Modo Oscuro por Defecto.
> **Inspiración:** VS Code, Linear, GitHub Dark Mode.

---

## 1. Paleta Cromática (The Theme)

### 🌑 Base Colors (Fondos y Superficies)
Diseñado para largas sesiones de trabajo.

| Token | Hex | Uso |
| :--- | :--- | :--- |
| `bg-primary` | `#0D1117` | Fondo principal de la ventana (casi negro, azulado). |
| `bg-secondary` | `#161B22` | Barras laterales, paneles, tarjetas. |
| `bg-tertiary` | `#21262D` | Campos de input, bordes, separadores. |
| `bg-elevation` | `#30363D` | Dropdowns, Modales, Tooltips. |

### ⚡ Accent Colors (Acciones y Estados)

| Token | Hex | Uso |
| :--- | :--- | :--- |
| `primary` | `#58A6FF` | Botones principales, Enlaces, Foco (Tech Blue). |
| `secondary` | `#238636` | Acciones de éxito, "Run", "Generar" (Git Green). |
| `accent` | `#A371F7` | Elementos de IA, Sugerencias mágicas (Violeta). |
| `error` | `#F85149` | Errores críticos, borrado. |
| `warning` | `#D29922` | Advertencias de privacidad. |

### ✒️ Typography (Textos)

| Token | Hex | Uso |
| :--- | :--- | :--- |
| `text-primary` | `#C9D1D9` | Texto principal (alto contraste pero suave). |
| `text-secondary`| `#8B949E` | Subtítulos, metadatos, placeholders. |
| `text-code` | `#E1E4E8` | Bloques de código (dentro del chat). |

---

## 2. Tipografía

* **UI Font:** `Inter` o `Roboto` (Sans-serif, legible a tamaños pequeños).
* **Code Font:** `JetBrains Mono` o `Fira Code` (Ligaduras obligatorias para `=>`, `!=`).

---

## 3. Componentes Core (Flutter Widgets)

### 💬 Burbujas de Chat
* **Usuario:** Alineado derecha. Fondo `primary` (transparencia 20%). Borde redondeado (12px).
* **AI:** Alineado izquierda. Fondo `bg-secondary`. Borde sutil. Renderizado Markdown completo.

### 🔘 Botones
* **Primary:** Fondo `primary`, texto blanco/negro (según contraste). Sin sombra (Flat).
* **Ghost:** Fondo transparente, texto `text-secondary`, hover con fondo `bg-tertiary`.

### 🧊 Layout (Escritorio)
* **Sidebar (Izquierda):** Ancho fijo (250px). Navegación de chats y Configuración.
* **Main Area (Centro):** Chat infinito con scroll.
* **Input Area (Abajo):** Sticky footer. Textarea auto-expandible.

---

## 4. Temas (Dark & Light)

Aunque el **Modo Oscuro** es la prioridad (P1), el sistema debe soportar `ThemeMode` de Flutter.

* **Dark Mode:** (Definido arriba).
* **Light Mode:** Inversión de `bg-primary` a `#FFFFFF`, `bg-secondary` a `#F6F8FA`. Mantener acentos azules.