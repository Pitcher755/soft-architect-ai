# 🎨 Design System: SoftArchitect AI

> **Versión:** 1.0
> **Fecha:** 30/01/2026
> **Estado:** ✅ Especificado
> **Plataforma:** Desktop (Windows, macOS, Linux)

---

## 📖 Tabla de Contenidos

1. [Principios de Diseño](#principios-de-diseño)
2. [Paleta de Colores](#paleta-de-colores)
3. [Tipografía](#tipografía)
4. [Componentes](#componentes)
5. [Patrones de Layout](#patrones-de-layout)

---

## Principios de Diseño

### 1. Claridad Sobre Belleza

```
El usuario nunca debe preguntarse "¿Qué hace este botón?"

Implicaciones:
  ✅ Iconos + texto en botones principales
  ✅ Colores semanticos (rojo=error, verde=success)
  ✅ Espaciado consistente (múltiplos de 8px)
  ✅ Contraste ≥4.5:1 (WCAG AA)
```

### 2. Density Apropiada

```
Desktop ≠ Mobile. SoftArchitect es desktop-first.

Implicación:
  ✅ Información agrupada en paneles
  ✅ Columnas laterales con opciones
  ✅ Respuesta inmediata (no cargas lentas)
  ✅ Múltiples ventanas si necesario

NO:
  ❌ Hamburger menus (desktop tiene espacio)
  ❌ Micro-interactions lentas
  ❌ Minimalizmo excesivo
```

### 3. Familia de Widgets

```
Todos los widgets síguen patrón consistente:

[Icon] [Label]
  └─ [Content Area]
    └─ [Action Buttons]

Esto permite "scanning" rápido de UI
```

---

## Paleta de Colores

### Colores Primarios (Brand)

```
┌─────────────────────────────────────────────────┐
│ Azul (Primary)       #2E7D9E   (Confianza)      │
│ Naranja (Secondary)  #E8944A   (Acción)         │
│ Verde (Success)      #42AD6F   (Confirmación)   │
└─────────────────────────────────────────────────┘

Uso:
  ✅ Azul: Botones principales, links, highlights
  ✅ Naranja: CTAs (Call-to-Actions), warnings
  ✅ Verde: Success messages, confirmaciones
```

### Colores Semánticos

```
┌─────────────────────────────────────────────────┐
│ Error       #E63946   (Rojo - Atencion)        │
│ Warning     #F4A261   (Naranja - Cuidado)      │
│ Info        #457B9D   (Azul - Información)     │
│ Success     #42AD6F   (Verde - Éxito)          │
│ Disabled    #A0A0A0   (Gris - Inactivo)        │
└─────────────────────────────────────────────────┘
```

### Escala de Grises

```
┌──────────────────────────────────────────────────┐
│ White      #FFFFFF   (Fondo principal)           │
│ Light      #F5F5F5   (Fondo secundario)          │
│ Light-2    #E8E8E8   (Borders)                   │
│ Gray       #808080   (Texto secundario)          │
│ Dark       #333333   (Texto principal)           │
│ Black      #000000   (Acentos)                   │
└──────────────────────────────────────────────────┘
```

### Modo Oscuro (Future)

```
Similar invertido:
  ✅ Dark background (#121212)
  ✅ Light text (#E0E0E0)
  ✅ Colores primarios más luminosos
  ✅ Contrast WCAG AA maintained
```

---

## Tipografía

### Fuentes

```
Primaria:     Inter         (sans-serif, corporate)
Secundaria:   JetBrains Mono  (monospace, código)
Fallback:     -apple-system, Segoe UI (sistema)
```

### Escala de Tamaños

```
┌────────────────────────────────────────┐
│ H1 Títulos Principales    28px, Bold   │
│ H2 Subtítulos             24px, Bold   │
│ H3 Secciones              20px, Semi   │
│ Body Texto Principal      16px, Regular│
│ Body Small                14px, Regular│
│ Caption Ayuda            12px, Regular│
│ Monospace Código         14px, Regular│
└────────────────────────────────────────┘
```

### Ratios de Línea

```
Títulos:  1.2  (compact, impacto)
Body:     1.6  (readable, comfortable)
Code:     1.5  (balanced)
```

---

## Componentes

### Botones

```
PRIMARY (Acción principal)
┌──────────────────────┐
│   ✓ Send Query       │  ← Azul fondo
└──────────────────────┘
  Padding: 12px 24px
  Border-radius: 6px
  Font: 14px, Semi-bold
  Hover: Más oscuro 10%

SECONDARY (Acción secundaria)
┌──────────────────────┐
│   ⟲ Reset Filters    │  ← Gris fondo
└──────────────────────┘
  Mismo layout
  Fondo: #E8E8E8
  Hover: #D0D0D0

TERTIARY (Link-style)
  [Learn More →]  ← Sin background
  Color: Azul
  Underline on hover

DANGER (Destructive)
┌──────────────────────┐
│   🗑 Delete Cache    │  ← Rojo
└──────────────────────┘
```

### Input Fields

```
TEXT INPUT
┌────────────────────────────────┐
│ Enter your question...         │ ← Placeholder
│ What is the best backend...    │ ← Usuario typing
└────────────────────────────────┘

Border: 1px #E8E8E8
Focus: 2px #2E7D9E border
Padding: 12px 16px
Font: 14px, Regular
Error: Border rojo + helper text

SEARCH
┌────────────────────────────────┐
│ 🔍 Search tech-packs...        │
└────────────────────────────────┘
Icon left-aligned
Clear button (X) on right cuando hay texto
```

### Cards

```
┌─────────────────────────────────┐
│ DECISION MATRIX                 │
├─────────────────────────────────┤
│                                 │
│  React    Angular    Vue        │
│  ──────   ────────   ───        │
│  8/10     6/10      7/10        │
│                                 │
│  [Read Full Analysis →]         │
└─────────────────────────────────┘

Fondo: #FFFFFF
Border: 1px #E8E8E8
Border-radius: 8px
Padding: 20px
Shadow: 0 2px 8px rgba(0,0,0,0.1)
```

### Notificaciones (Toasts)

```
SUCCESS
┌──────────────────────────────────┐
│ ✓ Query saved to history         │  (auto-dismiss 4s)
└──────────────────────────────────┘

ERROR
┌──────────────────────────────────┐
│ ✗ Connection error. Using cache. │  (persistent)
│              [Retry] [Dismiss]   │
└──────────────────────────────────┘

INFO
┌──────────────────────────────────┐
│ ℹ 3 new tech-packs available    │  (persistent)
│              [Update] [Later]    │
└──────────────────────────────────┘
```

---

## Patrones de Layout

### Main Layout

```
┌─────────────────────────────────────────────────────────┐
│ ⊕ SoftArchitect AI                          ⚙ ? _ □ ✕ │
├────────────────┬──────────────────────────────────────┤
│                │                                      │
│  Recent        │   💬 Ask SoftArchitect...           │
│  Queries       │                                      │
│  ─────────     │   [Your question or task]           │
│                │                                      │
│  • React...    │   ┌────────────────────────────────┐ │
│  • Migration   │   │ DECISION MATRIX                │ │
│  • TypeScript  │   │ React vs Angular vs Vue        │ │
│                │   │ ────────────────────────────   │ │
│  Search 🔍     │   │ Performance:  React 9/10      │ │
│  ─────────     │   │ Learning:     Vue 8/10        │ │
│  [Results]     │   │ Ecosystem:    React 10/10     │ │
│                │   │ [Show more] [Code Examples]   │ │
│                │   └────────────────────────────────┘ │
│                │                                      │
│  Settings ⚙    │   [Previous Results ↓]              │
│  About                                                │
│                │                                      │
└────────────────┴──────────────────────────────────────┘

Left sidebar:  280px (fixed)
Main content:  responsive
Color scheme:  Blanco fondo
```

### Modal Dialog (Decision Details)

```
╔═══════════════════════════════════════════════════════╗
║  React vs Angular: Detailed Analysis             ✕   ║
╠═══════════════════════════════════════════════════════╣
║                                                       ║
║  📊 DECISION MATRIX                                   ║
║  ┌─────────────────────────────────────────────────┐ ║
║  │ Criterio        │ React  │ Angular │ Recomendación
║  │ Performance     │ 9/10   │ 7/10    │ React ✓       ║
║  │ Learning Curve  │ 7/10   │ 5/10    │ React ✓       ║
║  └─────────────────────────────────────────────────┘ ║
║                                                       ║
║  💰 ESTIMATED COSTS                                   ║
║  ┌─────────────────────────────────────────────────┐ ║
║  │ Development    │ React: $120K  Angular: $150K   ║
║  │ Hosting        │ Similar: $500/mo               ║
║  │ Team Size      │ React easier (smaller team)    ║
║  └─────────────────────────────────────────────────┘ ║
║                                                       ║
║  💡 RECOMMENDATION                                    ║
║  "Use React. Better performance, easier to learn,    ║
║   larger ecosystem. Cost savings ~$30K/year."        ║
║                                                       ║
║  [Export PDF] [Share] [Save Decision] [Close]        ║
╚═══════════════════════════════════════════════════════╝
```

---

## Responsive Behavior

### Breakpoints

```
Desktop Small:  1024px+ (main target)
Desktop Large:  1600px+ (optimized)
Tablet:         768px+  (supported)
Mobile:         <768px  (not primary, but works)
```

### Adaptive Rules

```
Desktop Small (1024px):
  ├─ Sidebar visible (240px)
  ├─ Main content responsive
  └─ All features accessible

Tablet (768px):
  ├─ Sidebar collapses to drawer
  ├─ Buttons become touch-friendly (48px+)
  └─ Modals full-screen

Mobile (<768px):
  ├─ Single column layout
  ├─ Bottom nav (if needed)
  └─ Optimized for touch (future phase)
```

---

## Accessibility (WCAG 2.1 AA)

### Color Contrast

```
✅ Text on background:     4.5:1 (AA)
✅ UI components border:   3:1 (AA)
✅ Icons on colored:       ≥3:1
✅ Interactive elements:   ≥3:1 focus indicator
```

### Keyboard Navigation

```
✅ Tab order: Left → Top → Right → Bottom
✅ Focus visible: 2px outline
✅ Escape closes modals
✅ Enter activates buttons
✅ Arrow keys navigate lists
```

### Screen Reader Support

```
✅ Semantic HTML (<button>, <label>, etc.)
✅ ARIA labels on custom components
✅ Form fields labeled
✅ Error messages associated with inputs
✅ Status live regions (async updates)
```

---

**Design System** asegura: consistencia visual, accesibilidad, y experiencia de usuario profesional. 🎨
