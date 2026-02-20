# AppColors - Reference Guide

**Última actualización:** 08/02/2026
**Archivo:** `lib/core/theme/app_colors.dart`

---

## 📖 Tabla de Colores y Uso

### Colores Primarios

| Nombre | Valor | Uso | Opacidad |
|--------|-------|-----|----------|
| `primary` | `#58A6FF` | Botones, borders, acentos | 1.0, 0.2 (hover) |
| `primaryLight` | `#79C0FF` | Variante clara de accento | 1.0 |
| `primaryDark` | `#1F6FEB` | Variante oscura de accento | 1.0 |

### Fondos

| Nombre | Valor | Uso | Opacidad |
|--------|-------|-----|----------|
| `mainBg` | `#0D1117` | Fondo principal de Scaffold | 1.0 |
| `surfaceBg` | `#161B22` | Cards, sidebar, dialogs | 1.0 |
| `surfaceLight` | `#21262D` | Surfaces anidados, elevados | 1.0 |

### Texto

| Nombre | Valor | Uso | Opacidad |
|--------|-------|-----|----------|
| `textMain` | `#E6EDF3` | Títulos, contenido principal | 1.0 |
| `textSecondary` | `#8B949E` | Subtítulos, metadata, hints | 1.0 |
| `textMuted` | `#6E7681` | Disabled, info secundaria | 1.0 |

### Bordes

| Nombre | Valor | Uso | Opacidad |
|--------|-------|-----|----------|
| `border` | `#30363D` | Bordes estándar | 1.0 |
| `borderLight` | `#6E7681` | Bordes suaves, separadores | 0.3 (light) |

---

## 🎯 Fases del Proyecto

### Fase 1: Contexto
```dart
// Color: Amarillo
AppColors.phase1Context // #FCD34D

// Usos:
phaseColor.withValues(alpha: 0.1)  // Badge background
phaseColor.withValues(alpha: 0.4)  // Card border
phaseColor.withValues(alpha: 0.6)  // Arrow icon
```

### Fase 2: Requisitos
```dart
// Color: Verde
AppColors.phase2Requirements // #10B981

// Usos:
phaseColor.withValues(alpha: 0.1)  // Badge background
phaseColor.withValues(alpha: 0.4)  // Card border
phaseColor.withValues(alpha: 0.6)  // Arrow icon
```

### Fase 3: Arquitectura
```dart
// Color: Azul
AppColors.phase3Architecture // #60A5FA

// Usos:
phaseColor.withValues(alpha: 0.1)  // Badge background
phaseColor.withValues(alpha: 0.4)  // Card border
phaseColor.withValues(alpha: 0.6)  // Arrow icon
```

---

## 🎨 Colores de Iconos

Cada proyecto puede tener su color de icono único:

| Proyecto | Color | Valor | Opacity 0.1 Use |
|----------|-------|-------|-----------------|
| E-Commerce | `iconBlue` | `#3B82F6` | Icon container background |
| Uber for Dogs | `iconPurple` | `#A855F7` | Icon container background |
| FinTech | `iconOrange` | `#FB923C` | Icon container background |
| Healthcare | `iconPink` | `#EC4899` | Icon container background |
| Analytics | `iconViolet` | `#8B5CF6` | Icon container background |
| Social | `iconCyan` | `#06B6D4` | Icon container background |
| Music | `iconAmber` | `#F59E0B` | Icon container background |
| IoT | `iconGreen` | `#10B981` | Icon container background |
| Marketing | `iconMagenta` | `#D946EF` | Icon container background |
| Security | `iconOrangeRed` | `#F97316` | Icon container background |

---

## 📝 Guía de Opacidad (withValues)

```dart
// REGLA: color.withValues(alpha: x)
// Rango: 0.0 (transparente) a 1.0 (opaco)

// Alpha 0.1 - MUY SUTIL
// Uso: Backgrounds de iconos, fondos de badges
Container(
  color: iconColor.withValues(alpha: 0.1),
)

// Alpha 0.2 - LIGHT
// Uso: Hover states, backgrounds claros
Container(
  color: primary.withValues(alpha: 0.2), // Logo background
)

// Alpha 0.3 - MEDIUM-LIGHT
// Uso: Bordes suaves, separadores
Border.all(
  color: border.withValues(alpha: 0.3),
)

// Alpha 0.4 - MEDIUM
// Uso: Phase card borders, medium contrast
Border.all(
  color: phaseColor.withValues(alpha: 0.4),
)

// Alpha 0.6 - SEMI-TRANSPARENT
// Uso: Icon accents, elementos semi-opacos
Icon(
  Icons.arrow_forward,
  color: phaseColor.withValues(alpha: 0.6),
)

// Alpha 1.0 - FULLY OPAQUE (default)
// Uso: Texto, bordes sólidos, colores principales
Text(
  'Text',
  style: TextStyle(color: textMain), // 1.0 por defecto
)
```

---

## 💻 Ejemplos de Código

### ProyectoCard con AppColors
```dart
// Icon container
Container(
  decoration: BoxDecoration(
    color: iconColor.withValues(alpha: 0.1),
    borderRadius: BorderRadius.circular(6),
  ),
  child: Icon(icon, color: iconColor),
),

// Phase badge
Container(
  decoration: BoxDecoration(
    color: phaseColor.withValues(alpha: 0.1),
    border: Border.all(
      color: phaseColor.withValues(alpha: 0.3),
    ),
    borderRadius: BorderRadius.circular(10),
  ),
  child: Text(phase, style: TextStyle(color: phaseColor)),
),

// Text main
Text(
  name,
  style: TextStyle(
    color: AppColors.textMain,
    fontSize: 16,
  ),
),

// Text secondary
Text(
  path,
  style: TextStyle(
    color: AppColors.textSecondary,
    fontSize: 11,
  ),
),

// Border
Border.all(color: AppColors.border),
```

### ProyectoListView con AppColors
```dart
// Container border
border: Border.all(
  color: AppColors.primary,
  width: 1.5,
),

// Mini card border with phase color
Border.all(
  color: phaseColor.withValues(alpha: 0.4),
),

// Arrow icon
Icon(
  Icons.arrow_forward,
  color: phaseColor.withValues(alpha: 0.6),
),
```

### Sidebar con AppColors
```dart
// Logo background
Container(
  decoration: BoxDecoration(
    color: AppColors.primary.withValues(alpha: 0.2),
    borderRadius: BorderRadius.circular(8),
  ),
  child: Icon(
    Icons.terminal,
    color: AppColors.primary,
  ),
),

// Dialog background
AlertDialog(
  backgroundColor: AppColors.surfaceBg,
  titleTextStyle: TextStyle(
    color: AppColors.textMain,
  ),
),

// Input field borders
focusedBorder: OutlineInputBorder(
  borderSide: BorderSide(
    color: AppColors.primary,
    width: 1.5,
  ),
),
```

---

## 🔄 Migración a AppColors

Para usar AppColors en lugar de colores hardcodeados:

```dart
// ANTES (hardcoded)
Container(
  color: const Color(0xFF161B22),
  child: Text('Text', style: TextStyle(color: const Color(0xFFE6EDF3))),
)

// DESPUÉS (usando AppColors)
Container(
  color: AppColors.surfaceBg,
  child: Text(
    'Text',
    style: TextStyle(color: AppColors.textMain),
  ),
)
```

---

## 📋 Checklist para Nuevas Características

Cuando agregues nuevos colores:

- [ ] Documentoa el color en AppColors con su valor hex
- [ ] Especifica dónde se usa (UI component)
- [ ] Indica si necesita opacidad y con qué valores
- [ ] Actualiza esta guía de referencia
- [ ] Usa `AppColors.colorName` en lugar de `Color(0xFFxxxxxx)`
- [ ] Pruebaa en múltiples modos (light/dark) si aplica

---

## 🎨 Sistema de Color Actual

**Tema:** GitHub Dark (Basado en)
**Acentos:** Azul brillante (#58A6FF)
**Contrastos:** Alto (WCAG AA compliance)
**Temperatura:** Frío (blues, grays)

---

## 📞 Contacto / Preguntas

Para actualizar la paleta de colores o agregar nuevos, contacta al equipo de diseño.
Todos los cambios deben ser reflejados en este documentoo.
