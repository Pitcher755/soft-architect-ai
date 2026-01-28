# 🎨 Design System & UI Guidelines

> **Aesthetics:** "Developer Experience First". Minimalist, High Contrast, Dark Mode by Default.
> **Inspiration:** VS Code, Linear, GitHub Dark Mode.

---

## 1. Color Palette (The Theme)

### 🌑 Base Colors (Backgrounds and Surfaces)
Designed for long work sessions.

| Token | Hex | Usage |
| :--- | :--- | :--- |
| `bg-primary` | `#0D1117` | Main window background (almost black, bluish). |
| `bg-secondary` | `#161B22` | Sidebars, panels, cards. |
| `bg-tertiary` | `#21262D` | Input fields, borders, separators. |
| `bg-elevation` | `#30363D` | Dropdowns, Modals, Tooltips. |

### ⚡ Accent Colors (Actions and States)

| Token | Hex | Usage |
| :--- | :--- | :--- |
| `primary` | `#58A6FF` | Main buttons, Links, Focus (Tech Blue). |
| `secondary` | `#238636` | Success actions, "Run", "Generate" (Git Green). |
| `accent` | `#A371F7` | AI elements, Magic suggestions (Purple). |
| `error` | `#F85149` | Critical errors, deletion. |
| `warning` | `#D29922` | Privacy warnings. |

### ✒️ Typography (Texts)

| Token | Hex | Usage |
| :--- | :--- | :--- |
| `text-primary` | `#C9D1D9` | Main text (high contrast but soft). |
| `text-secondary`| `#8B949E` | Subtitles, metadata, placeholders. |
| `text-code` | `#E1E4E8` | Code blocks (within chat). |

---

## 2. Typography

* **UI Font:** `Inter` or `Roboto` (Sans-serif, readable at small sizes).
* **Code Font:** `JetBrains Mono` or `Fira Code` (Ligatures mandatory for `=>`, `!=`).

---

## 3. Core Components (Flutter Widgets)

### 💬 Chat Bubbles
* **User:** Aligned right. Background `primary` (20% transparency). Rounded border (12px).
* **AI:** Aligned left. Background `bg-secondary`. Subtle border. Full Markdown rendering.

### 🔘 Buttons
* **Primary:** Background `primary`, text white/black (based on contrast). No shadow (Flat).
* **Ghost:** Transparent background, text `text-secondary`, hover with `bg-tertiary` background.

### 🧊 Layout (Desktop)
* **Sidebar (Left):** Fixed width (250px). Navigation for chats and Settings.
* **Main Area (Center):** Infinite scroll chat.
* **Input Area (Bottom):** Sticky footer. Auto-expandable textarea.

---

## 4. Themes (Dark & Light)

Although **Dark Mode** is the priority (P1), the system must support Flutter's `ThemeMode`.

* **Dark Mode:** (Defined above).
* **Light Mode:** Inversion of `bg-primary` to `#FFFFFF`, `bg-secondary` to `#F6F8FA`. Keep blue accents.