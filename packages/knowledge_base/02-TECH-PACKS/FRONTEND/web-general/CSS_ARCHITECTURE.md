# 🎨 CSS Architecture & Responsive Design Standards

> **Fecha:** 30/01/2026
> **Estado:** ✅ MANDATORY
> **Alcance:** Todo desarrollo Web (React, Vue, Angular, Vanilla, Flutter Web)
> **Objetivo:** Performance, accesibilidad, mantenibilidad y escalabilidad
> **Referencia:** Mobile-First, WCAG 2.1, Modern CSS (Grid, Flexbox, Variables)

La estrategia es **Mobile-First**. Escribe para móvil primero; expande para desktop después.

---

## 📖 Tabla de Contenidos

1. [Filosofía Mobile-First](#filosofía-mobile-first)
2. [Unidades y Tipografía](#unidades-y-tipografía)
3. [Layouts Modernos](#layouts-modernos)
4. [CSS Variables para Theming](#css-variables-para-theming)
5. [Metodologías: Utility-First vs BEM](#metodologías-utility-first-vs-bem)
6. [Responsive Design Patterns](#responsive-design-patterns)
7. [Performance y Optimización](#performance-y-optimización)
8. [Accesibilidad en CSS](#accesibilidad-en-css)
9. [Anti-Patterns & Errores Comunes](#anti-patterns--errores-comunes)
10. [Checklist de CSS](#checklist-de-css)

---

## Filosofía Mobile-First

### Principio Fundamental

**Escribe para móvil primero.** Usa `@media (min-width: ...)` para pantallas más grandes, NUNCA `@media (max-width: ...)`.

#### ❌ MALO: Desktop-First (Anti-Pattern)

```css
/* ❌ Escribes CSS para desktop, luego necesitas @media max-width para mobile */
body {
  font-size: 18px;  /* Grande para desktop */
  padding: 40px;    /* Amplio para desktop */
}

@media (max-width: 768px) {
  body {
    font-size: 14px;  /* Reduce para móvil */
    padding: 16px;    /* Reduce para móvil */
  }
}
/* Este enfoque duplica código y es confuso */
```

#### ✅ BUENO: Mobile-First (Correcto)

```css
/* ✅ Escribes CSS para móvil, luego expandes con @media min-width */
body {
  font-size: 14px;  /* Óptimo para móvil */
  padding: 16px;    /* Óptimo para móvil */
}

@media (min-width: 768px) {
  body {
    font-size: 18px;  /* Expande para tablet+ */
    padding: 40px;    /* Expande para tablet+ */
  }
}

@media (min-width: 1024px) {
  body {
    font-size: 20px;  /* Aún más grande para desktop */
    padding: 60px;    /* Aún más grande para desktop */
  }
}
```

### Breakpoints Estándar

```css
/* Define breakpoints globales */
:root {
  --breakpoint-sm: 480px;    /* Móvil pequeño (iPhone SE) */
  --breakpoint-md: 768px;    /* Tablet (iPad) */
  --breakpoint-lg: 1024px;   /* Desktop pequeño (Laptop) */
  --breakpoint-xl: 1280px;   /* Desktop grande (Cinematic) */
}

/* Uso con @media */
@media (min-width: 768px) { ... }  /* Tablet+ */
@media (min-width: 1024px) { ... } /* Desktop+ */
```

---

## Unidades y Tipografía

### Unidades Relativas (No Absolutas)

**Regla:** NO uses `px` para tamaños de fuente. Usa `rem` (respeta preferencias de usuario).

#### ❌ MALO: Unidades Absolutas

```css
/* ❌ Hardcoded px: ignora preferencias de usuario */
body {
  font-size: 16px;     /* Si el usuario prefiere 20px, lo ignora */
  padding: 20px;       /* Px para padding/margin es OK, pero no ideal */
  margin: 10px;
}

h1 { font-size: 40px; }  /* Hardcoded, no escalable */
h2 { font-size: 28px; }
```

#### ✅ BUENO: Unidades Relativas

```css
/* ✅ rem: respeta tamaño de fuente base del usuario */
:root {
  font-size: 16px;  /* Base: 1rem = 16px (por defecto) */
}

body {
  font-size: 1rem;      /* = 16px (escalable) */
  padding: 1rem;        /* = 16px */
  margin: 0.5rem;       /* = 8px */
}

h1 { font-size: 2.5rem; }  /* = 40px (2.5 × 16px) */
h2 { font-size: 1.75rem; } /* = 28px (1.75 × 16px) */
h3 { font-size: 1.25rem; } /* = 20px */
```

### Tipografía Responsive

```css
/* Mobile */
h1 {
  font-size: 1.5rem;     /* 24px en móvil */
  line-height: 1.3;      /* Legible en móvil */
  margin-bottom: 1rem;   /* Espaciado */
}

/* Tablet+ */
@media (min-width: 768px) {
  h1 {
    font-size: 2rem;     /* 32px en tablet */
    line-height: 1.2;    /* Más compacto con más espacio */
  }
}

/* Desktop+ */
@media (min-width: 1024px) {
  h1 {
    font-size: 2.5rem;   /* 40px en desktop */
  }
}
```

### Font Sizing Scale

```css
/* Sistema de escalado tipográfico (Golden Ratio ≈ 1.618) */
:root {
  --fs-xs: 0.75rem;   /* 12px - small text */
  --fs-sm: 0.875rem;  /* 14px - small */
  --fs-base: 1rem;    /* 16px - body text */
  --fs-lg: 1.125rem;  /* 18px - large */
  --fs-xl: 1.25rem;   /* 20px - extra large */
  --fs-2xl: 1.5rem;   /* 24px - heading 3 */
  --fs-3xl: 1.875rem; /* 30px - heading 2 */
  --fs-4xl: 2.25rem;  /* 36px - heading 1 */
}

body { font-size: var(--fs-base); }
h3 { font-size: var(--fs-2xl); }
h2 { font-size: var(--fs-3xl); }
h1 { font-size: var(--fs-4xl); }
```

---

## Layouts Modernos

### 1. CSS Grid (Layouts 2D)

**Uso:** Diseños de múltiples filas y columnas (header, sidebar, footer, contenido).

```html
<!-- HTML Semántico -->
<div class="container">
  <header>Header</header>
  <nav>Nav</nav>
  <main>Main</main>
  <aside>Aside</aside>
  <footer>Footer</footer>
</div>
```

```css
/* ✅ BUENO: Grid layout responsive */
.container {
  display: grid;
  grid-template-columns: 1fr;  /* Móvil: 1 columna */
  gap: 1rem;
  padding: 1rem;
}

/* Tablet+ */
@media (min-width: 768px) {
  .container {
    grid-template-columns: 200px 1fr 300px;  /* Sidebar | Main | Aside */
    grid-template-rows: auto 1fr auto;       /* Header | Content | Footer */
    grid-template-areas:
      "header header header"
      "nav main aside"
      "footer footer footer";
  }

  header { grid-area: header; }
  nav { grid-area: nav; }
  main { grid-area: main; }
  aside { grid-area: aside; }
  footer { grid-area: footer; }
}
```

#### Named Grid Areas (Legibilidad)

```css
.page-layout {
  display: grid;
  grid-template-columns: 200px 1fr 250px;
  grid-template-areas:
    "header header header"
    "sidebar main ads"
    "footer footer footer";
  gap: 1rem;
}

header { grid-area: header; }
main { grid-area: main; }
aside { grid-area: ads; }
footer { grid-area: footer; }
```

### 2. Flexbox (Layouts 1D)

**Uso:** Alineación en una dimensión (filas o columnas: navbar, listas, galería).

```html
<!-- Navbar -->
<nav class="navbar">
  <div class="logo">Logo</div>
  <div class="nav-links">
    <a href="/">Home</a>
    <a href="/docs">Docs</a>
    <a href="/api">API</a>
  </div>
</nav>
```

```css
/* ✅ BUENO: Flexbox para navbar */
.navbar {
  display: flex;
  justify-content: space-between;  /* Logo izq, links derecha */
  align-items: center;             /* Centrado verticalmente */
  padding: 1rem;
  background-color: #333;
}

.nav-links {
  display: flex;
  gap: 2rem;  /* Espacio entre links */
}

/* Móvil: Stack vertical */
@media (max-width: 768px) {
  .navbar {
    flex-direction: column;  /* Vertical */
    gap: 1rem;
  }
}
```

#### Galería Responsive (Flexbox)

```css
.gallery {
  display: flex;
  flex-wrap: wrap;        /* Wrapping automático */
  gap: 1rem;
}

.gallery-item {
  flex: 1 1 calc(50% - 0.5rem);  /* 2 columnas */
  min-width: 200px;              /* Mínimo 200px */
}

@media (min-width: 768px) {
  .gallery-item {
    flex: 1 1 calc(33.333% - 0.75rem);  /* 3 columnas */
  }
}

@media (min-width: 1024px) {
  .gallery-item {
    flex: 1 1 calc(25% - 0.75rem);  /* 4 columnas */
  }
}
```

### ❌ MALO: Floats (Deprecated)

```css
/* ❌ MALO: Floats para layout (anti-pattern) */
.column {
  float: left;
  width: 33.333%;
}

.clearfix::after {
  content: "";
  display: table;
  clear: both;
}
/* Este es el viejo camino, evita completamente */
```

---

## CSS Variables para Theming

### Definición de Variables Globales

```css
:root {
  /* ============ COLORES ============ */
  --color-primary: #6366f1;        /* Indigo */
  --color-secondary: #f97316;      /* Orange */
  --color-success: #22c55e;        /* Green */
  --color-danger: #ef4444;         /* Red */
  --color-warning: #eab308;        /* Yellow */
  --color-info: #0ea5e9;           /* Sky */

  /* Escala de grises */
  --color-gray-50: #f9fafb;
  --color-gray-100: #f3f4f6;
  --color-gray-200: #e5e7eb;
  --color-gray-300: #d1d5db;
  --color-gray-400: #9ca3af;
  --color-gray-500: #6b7280;
  --color-gray-600: #4b5563;
  --color-gray-700: #374151;
  --color-gray-800: #1f2937;
  --color-gray-900: #111827;

  /* ============ ESPACIADO ============ */
  --spacing-xs: 0.25rem;   /* 4px */
  --spacing-sm: 0.5rem;    /* 8px */
  --spacing-md: 1rem;      /* 16px */
  --spacing-lg: 1.5rem;    /* 24px */
  --spacing-xl: 2rem;      /* 32px */
  --spacing-2xl: 3rem;     /* 48px */

  /* ============ TIPOGRAFÍA ============ */
  --font-family-sans: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
  --font-family-mono: "Monaco", "Menlo", "Ubuntu Mono", monospace;
  --font-weight-normal: 400;
  --font-weight-semibold: 600;
  --font-weight-bold: 700;

  /* ============ BORDES ============ */
  --border-radius-sm: 0.25rem;
  --border-radius-md: 0.5rem;
  --border-radius-lg: 1rem;
  --border-width: 1px;

  /* ============ SOMBRAS ============ */
  --shadow-sm: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
  --shadow-md: 0 4px 6px -1px rgba(0, 0, 0, 0.1);
  --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1);

  /* ============ TRANSICIONES ============ */
  --transition-fast: 100ms ease;
  --transition-base: 200ms ease;
  --transition-slow: 300ms ease;
}
```

### Sistema de Temas (Light/Dark Mode)

```css
/* Tema Claro (por defecto) */
:root {
  --bg-primary: white;
  --bg-secondary: var(--color-gray-50);
  --text-primary: var(--color-gray-900);
  --text-secondary: var(--color-gray-600);
  --border-color: var(--color-gray-200);
}

/* Tema Oscuro */
@media (prefers-color-scheme: dark) {
  :root {
    --bg-primary: var(--color-gray-900);
    --bg-secondary: var(--color-gray-800);
    --text-primary: white;
    --text-secondary: var(--color-gray-300);
    --border-color: var(--color-gray-700);
  }
}

/* Uso en componentes */
body {
  background-color: var(--bg-primary);
  color: var(--text-primary);
  transition: background-color var(--transition-base);
}

.card {
  background-color: var(--bg-secondary);
  border: var(--border-width) solid var(--border-color);
  border-radius: var(--border-radius-lg);
  padding: var(--spacing-lg);
  box-shadow: var(--shadow-md);
}
```

### Dark Mode Con Toggle Manual

```html
<!-- HTML: Toggle button -->
<button class="theme-toggle" onclick="toggleTheme()">
  <span class="icon">🌙</span>
</button>
```

```css
/* CSS: Custom data attribute -->
html[data-theme="dark"] {
  --bg-primary: var(--color-gray-900);
  --bg-secondary: var(--color-gray-800);
  --text-primary: white;
  --text-secondary: var(--color-gray-300);
}

html[data-theme="light"] {
  --bg-primary: white;
  --bg-secondary: var(--color-gray-50);
  --text-primary: var(--color-gray-900);
  --text-secondary: var(--color-gray-600);
}
```

```javascript
/* JavaScript: Toggle logic */
function toggleTheme() {
  const html = document.documentElement;
  const currentTheme = html.getAttribute('data-theme');
  const newTheme = currentTheme === 'dark' ? 'light' : 'dark';

  html.setAttribute('data-theme', newTheme);
  localStorage.setItem('theme', newTheme);  // Persistir
}

// Cargar tema guardado
window.addEventListener('load', () => {
  const savedTheme = localStorage.getItem('theme') || 'light';
  document.documentElement.setAttribute('data-theme', savedTheme);
});
```

---

## Metodologías: Utility-First vs BEM

### 1. Utility-First (Tailwind CSS)

**Ventaja:** Rápido, predecible, pequeño bundle si usas PurgeCSS.

```html
<!-- Directo en HTML -->
<div class="bg-white rounded-lg shadow-md p-6 mb-4">
  <h2 class="text-2xl font-bold mb-3 text-gray-900">Título</h2>
  <p class="text-gray-600 mb-4">Contenido...</p>
  <button class="bg-indigo-600 text-white px-4 py-2 rounded hover:bg-indigo-700">
    Acción
  </button>
</div>
```

#### Ventajas
- ✅ Desarrollo rápido
- ✅ Consistencia visual (sin nombres inventados)
- ✅ Responsive integrado (`md:`, `lg:`)
- ✅ Dark mode automático (`dark:`)

#### Desventajas
- ❌ HTML "sucio" (muchas clases)
- ❌ Curva de aprendizaje (entender las abreviaturas)
- ❌ No bueno para diseños muy complejos

### 2. BEM (Block-Element-Modifier)

**Ventaja:** Mantenible, explícito, bueno para librerías CSS puras.

```css
/* Estructura BEM */
.card { }                        /* Block */
.card__header { }               /* Element */
.card__title { }                /* Element */
.card__content { }              /* Element */
.card__footer { }               /* Element */
.card--featured { }             /* Modifier */
.card__button { }               /* Element */
.card__button--primary { }      /* Modifier */
.card__button--large { }        /* Modifier */
```

```html
<!-- HTML con BEM -->
<article class="card card--featured">
  <header class="card__header">
    <h2 class="card__title">Título</h2>
  </header>
  <div class="card__content">
    <p>Contenido...</p>
  </div>
  <footer class="card__footer">
    <button class="card__button card__button--primary card__button--large">
      Acción
    </button>
  </footer>
</article>
```

```css
/* CSS con BEM (predecible, no hay conflictos) */
.card {
  background: white;
  border: 1px solid #ddd;
  border-radius: 8px;
  padding: 1rem;
}

.card__header {
  border-bottom: 1px solid #eee;
  margin-bottom: 1rem;
}

.card__title {
  font-size: 1.5rem;
  font-weight: bold;
  margin: 0;
}

.card__button {
  padding: 0.5rem 1rem;
  border: none;
  border-radius: 4px;
  cursor: pointer;
}

.card__button--primary {
  background: #6366f1;
  color: white;
}

.card__button--large {
  padding: 0.75rem 1.5rem;
  font-size: 1.125rem;
}

.card--featured {
  border-color: #6366f1;
  box-shadow: 0 4px 6px rgba(0, 0, 0, 0.1);
}
```

#### Ventajas
- ✅ Altamente mantenible (nombres claros)
- ✅ Sin especificidad wars (todas las clases tienen la misma especificidad)
- ✅ Fácil escalar a grandes proyectos
- ✅ Bueno para equipos

#### Desventajas
- ❌ Nombres verbosos
- ❌ Más CSS por escribir
- ❌ Curva de aprendizaje (convenciones)

### Híbrido (Recomendado para SoftArchitect)

Combina ambas:
- **Utility-first para componentes básicos:** Spacing, colores, bordes
- **BEM para componentes custom:** Cards, modales, forms

```css
/* Utilities globales */
.flex { display: flex; }
.flex-col { flex-direction: column; }
.gap-1 { gap: 1rem; }
.p-1 { padding: 1rem; }
.bg-primary { background-color: var(--color-primary); }

/* BEM para componentes específicos */
.modal {
  position: fixed;
  top: 50%;
  left: 50%;
  transform: translate(-50%, -50%);
}

.modal__header {
  padding-bottom: 1rem;
  border-bottom: 1px solid var(--border-color);
}

.modal__close-button {
  position: absolute;
  top: 1rem;
  right: 1rem;
}
```

---

## Responsive Design Patterns

### Pattern 1: Mobile-First Columns

```css
.grid {
  display: grid;
  grid-template-columns: 1fr;  /* Móvil: 1 columna */
  gap: 1rem;
}

@media (min-width: 768px) {
  .grid {
    grid-template-columns: 1fr 1fr;  /* Tablet: 2 columnas */
  }
}

@media (min-width: 1024px) {
  .grid {
    grid-template-columns: 1fr 1fr 1fr;  /* Desktop: 3 columnas */
  }
}

@media (min-width: 1280px) {
  .grid {
    grid-template-columns: 1fr 1fr 1fr 1fr;  /* Cinematic: 4 columnas */
  }
}
```

### Pattern 2: Sidebar Apilado (Stack on Mobile)

```css
.page {
  display: grid;
  grid-template-columns: 1fr;  /* Móvil: sidebar debajo */
  gap: 2rem;
}

@media (min-width: 768px) {
  .page {
    grid-template-columns: 1fr 250px;  /* Tablet: sidebar derecha */
  }
}
```

### Pattern 3: Fluido (Flexible Columns)

```css
.auto-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1rem;
}
/* Esto automáticamente ajusta columnas según disponibilidad */
```

---

## Performance y Optimización

### 1. Critical CSS

```html
<!-- Critical CSS inline en <head> (primera pintura) -->
<head>
  <style>
    /* Estilos mínimos para layout principal */
    html, body { margin: 0; padding: 0; }
    .container { display: grid; grid-template-columns: 1fr; }
  </style>

  <!-- CSS no-critical en defer -->
  <link rel="stylesheet" href="styles.css" media="print" onload="this.media='all'">
</head>
```

### 2. Minificación y Compresión

```bash
# CSS Minified (Remove spaces, comments)
# 50KB → 5KB (típicamente 10% del tamaño original)

# Con PurgeCSS (Tailwind)
# Remove unused CSS classes: 100KB → 15KB
```

### 3. Evitar Repaints Costosos

```css
/* ❌ BAD: Animar propiedades que causan reflow */
.box {
  animation: expand 0.5s;
}

@keyframes expand {
  from { width: 100px; height: 100px; }
  to { width: 200px; height: 200px; }  /* Reflow costoso */
}

/* ✅ GOOD: Animar transform (GPU accelerated) */
.box {
  animation: expand 0.5s;
}

@keyframes expand {
  from { transform: scale(1); }
  to { transform: scale(2); }  /* GPU accelerated, sin reflow */
}
```

### 4. Usar `content-visibility` para Performance

```css
/* Elementos fuera de viewport: browser no los renderiza */
.card {
  content-visibility: auto;  /* Auto-skip rendering si no visible */
}
```

---

## Accesibilidad en CSS

### 1. Respetar Preferencias de Usuario

```css
/* ✅ GOOD: Respetar motion preferences */
@media (prefers-reduced-motion: reduce) {
  * {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}

/* ✅ GOOD: Respetar color scheme preference */
@media (prefers-color-scheme: dark) {
  body { background: #1a1a1a; color: white; }
}

/* ✅ GOOD: Respetar contraste preference */
@media (prefers-contrast: more) {
  body { color: #000; background: #fff; }  /* Máximo contraste */
}
```

### 2. Focus Visible (Accesibilidad de Teclado)

```css
/* ✅ GOOD: Indicador de foco visible */
button:focus-visible {
  outline: 3px solid var(--color-primary);
  outline-offset: 2px;
}

/* ❌ BAD: Remover focus outline (nunca hagas esto!) */
button:focus {
  outline: none;  /* Destructivo para teclado */
}
```

### 3. Contraste Adecuado

```css
/* ✅ GOOD: Contraste ≥ 4.5:1 */
body {
  background: white;
  color: #333;  /* Contraste ~8:1, excelente */
}

/* ❌ BAD: Contraste bajo */
body {
  background: white;
  color: #ccc;  /* Contraste ~2:1, ilegible */
}
```

---

## Anti-Patterns & Errores Comunes

### ❌ Desktop-First (Prohibido)

```css
/* ❌ MALO: @media max-width para reducir */
body { font-size: 18px; padding: 40px; }

@media (max-width: 768px) {
  body { font-size: 14px; padding: 16px; }
}
/* Esto envía CSS no necesario a móviles */
```

### ❌ Px para Tipografía

```css
/* ❌ MALO: Ignora preferencias de usuario */
body { font-size: 16px; }  /* Hardcoded */

/* ✅ BUENO: Escalable */
body { font-size: 1rem; }  /* Respeta preferencias */
```

### ❌ Floats para Layout

```css
/* ❌ MALO: Vieja técnica */
.column { float: left; width: 33.333%; }
.clearfix::after { clear: both; }

/* ✅ BUENO: Grid/Flexbox */
.grid { display: grid; grid-template-columns: repeat(3, 1fr); }
```

### ❌ Colores Inline

```html
<!-- ❌ MALO: Hardcoded en HTML -->
<p style="color: red; font-size: 16px;">Error</p>

<!-- ✅ BUENO: Clases CSS -->
<p class="text-danger text-base">Error</p>
```

### ❌ !important Overuse

```css
/* ❌ MALO: !important es último recurso */
.button { color: blue !important; }

/* ✅ BUENO: Especificidad correcta */
.button { color: blue; }
```

### ❌ No Testar Responsive

```css
/* ❌ MALO: No verificar en móvil */
.container { max-width: 1920px; }  /* Overflow en móvil */

/* ✅ BUENO: Testar en múltiples tamaños */
@media (max-width: 480px) { /* Verifica en móvil */ }
@media (max-width: 768px) { /* Verifica en tablet */ }
```

---

## Checklist de CSS

### Pre-Deployment

```bash
# ✅ 1. Responsive
[ ] Móvil (480px) sin horizontal scroll
[ ] Tablet (768px) optimizado
[ ] Desktop (1024px) optimizado
[ ] Cinematic (1920px) sin layout breaks

# ✅ 2. Mobile-First
[ ] Estilos base para móvil definidos
[ ] @media (min-width: ...) usado (NO max-width)
[ ] Breakpoints consistentes (480/768/1024/1280)

# ✅ 3. Tipografía
[ ] Font-size usa rem (NO px)
[ ] Line-height: 1.5+ para body (legible)
[ ] Contraste ≥ 4.5:1 (WCAG AA)
[ ] Font-stack incluye fallbacks (sans-serif)

# ✅ 4. Layouts
[ ] CSS Grid para 2D (layouts complejos)
[ ] Flexbox para 1D (navegación, listas)
[ ] NO floats para layout
[ ] Gaps usados en lugar de margins

# ✅ 5. Variables
[ ] CSS variables definidas en :root
[ ] Colores usando --color-*
[ ] Espaciado usando --spacing-*
[ ] Dark mode implementado

# ✅ 6. Performance
[ ] CSS minificado en producción
[ ] Unused CSS removido (PurgeCSS)
[ ] Critical CSS optimizado
[ ] Transform/opacity para animaciones (GPU)

# ✅ 7. Accesibilidad
[ ] focus-visible visible en todos los botones
[ ] @media (prefers-reduced-motion: reduce)
[ ] @media (prefers-color-scheme: dark)
[ ] @media (prefers-contrast: more)

# ✅ 8. Mantenibilidad
[ ] Consistencia (BEM o Utility-First elegido)
[ ] Nombres descriptivos (NO .box1, .red-text)
[ ] Documentación para custom patterns
[ ] No conflictos de especificidad

# ✅ 9. Testing
[ ] Zoom 200% sin problemas
[ ] Testeado en Chrome, Firefox, Safari, Edge
[ ] Testeado en iPhone/Android real
[ ] No broken layouts en landscape/portrait
```

---

## Conclusión

**CSS Architecture es la base del Frontend.**

1. ✅ **Mobile-First:** Diseña para móvil, expande con min-width
2. ✅ **Unidades Relativas:** Usa `rem` para tipografía
3. ✅ **Layouts Modernos:** Grid (2D) + Flexbox (1D), NO floats
4. ✅ **CSS Variables:** Theming consistente y dark mode
5. ✅ **Accesibilidad:** Respeta preferencias de usuario, focus visible

**Dogfooding Validation:** SoftArchitect valida CSS con Lighthouse (Performance: 90+, Accessibility: 95+) en cada deploy.
