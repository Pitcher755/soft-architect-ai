# HU-7.2 — Soporte Completo de Tema Claro (ThemeExtension)

> **Fecha:** 07/07/2025
> **Estado:** ✅ Completado
> **Rama:** `feature/hu-7.2-light-theme-full-support`
> **Ticket Linear:** [PIT-133](https://linear.app/pitcherdev/issue/PIT-133)

## 📋 Índice

1. [Resumen](#resumen)
2. [Motivación](#motivación)
3. [Implementación](#implementación)
4. [Archivos Modificados](#archivos-modificados)
5. [Referencia de Tokens de Color](#referencia-de-tokens-de-color)
6. [Testing](#testing)

---

## Resumen

Refactorización de 40+ colores hardcodeados en hexadecimal a lo largo del
cliente Flutter para utilizar un `ThemeExtension<AppColorsExtension>`
centralizado, habilitando soporte completo de Modo Claro junto al Modo
Oscuro existente.

---

## Motivación

| Problema | Impacto |
|----------|---------|
| `Color(0xFF...)` hardcodeados en widgets | Ilegibles en Modo Claro |
| Sin tokens de color semánticos | Paleta inconsistente entre features |
| Asunción de solo modo oscuro | Brechas de accesibilidad y preferencia de usuario |
| Valores hex dispersos | Mantenimiento difícil y actualizaciones de tema |

---

## Implementación

### 1. AppColorsExtension (NUEVO)

Creado `src/client/lib/core/theme/app_colors_extension.dart`:

- `ThemeExtension<AppColorsExtension>` con ~20 tokens de color semánticos
- Constructores factory `darkTheme` y `lightTheme` con paletas curadas
- Soporte completo de `copyWith()` y `lerp()` para transiciones suaves de tema
- Extensión de `BuildContext` para acceso ergonómico: `context.appColors.cardBg`

### 2. Configuración del Tema

Actualizado `src/client/lib/core/config/theme_config.dart`:

- Añadido `extensions: [AppColorsExtension.darkTheme]` en `darkTheme()`
- Añadido `extensions: [AppColorsExtension.lightTheme]` en `lightTheme()`

### 3. Migración de Widgets (10 archivos)

Reemplazados colores hexadecimales hardcodeados por tokens `context.appColors.*`
en todos los archivos de widgets que usaban valores inline `Color(0xFF...)`.

Caso especial: `CodeElementBuilder` (extiende `MarkdownElementBuilder`, sin
`BuildContext`) recibe colores via parámetros del constructor con valores por
defecto del tema oscuro.

---

## Archivos Modificados

| Archivo | Tipo | Descripción |
|---------|------|-------------|
| `core/theme/app_colors_extension.dart` | **NUEVO** | ThemeExtension con ~20 tokens semánticos |
| `core/config/theme_config.dart` | MODIFICADO | Extensions conectadas en ambos temas |
| `settings/widgets/settings_card.dart` | MODIFICADO | Tokens bg/border de tarjeta |
| `settings/widgets/storage_section.dart` | MODIFICADO | Tokens de color de texto |
| `settings/widgets/profile_section.dart` | MODIFICADO | Tokens de color de avatar |
| `settings/widgets/setting_item.dart` | MODIFICADO | Tokens de color de item |
| `project_shell/widgets/workspace_header.dart` | MODIFICADO | Tokens de texto de encabezado |
| `project_shell/widgets/projects_grid.dart` | MODIFICADO | Tokens bg/border/texto de tarjeta |
| `project_shell/widgets/markdown_preview_widget.dart` | MODIFICADO | Tokens de bloque de código + SnackBar |
| `chat/widgets/document_proposal_card.dart` | MODIFICADO | Inyección de color en CodeElementBuilder |
| `chat/widgets/smart_message_renderer.dart` | MODIFICADO | Inyección de color en CodeElementBuilder |
| `shared/widgets/markdown_builders/code_element_builder.dart` | MODIFICADO | Parámetros de constructor para colores |

---

## Referencia de Tokens de Color

| Token | Valor Oscuro | Valor Claro | Uso |
|-------|-------------|-------------|-----|
| `cardBg` | `#1E1E2E` | `#FFFFFF` | Fondos de tarjeta |
| `cardBorder` | `#2D2D3F` | `#E0E0E0` | Bordes de tarjeta |
| `headingText` | `#E0E0FF` | `#1A1A2E` | Encabezados de sección |
| `textMain` | `#FFFFFF` | `#1A1A2E` | Texto principal |
| `textSecondary` | `#B0B0C0` | `#666680` | Texto secundario |
| `successBg` | `#1B5E20` (0.3) | `#E8F5E9` | Fondos de éxito |
| `codeBg` | `#1A1A2E` | `#F5F5F5` | Fondos de bloques de código |
| `codeBorder` | `#3D3D5C` | `#E0E0E0` | Bordes de bloques de código |
| `codeText` | `#E0E0FF` | `#1A1A2E` | Texto de código |
| `inputBg` | `#2D2D3F` | `#F5F5F5` | Fondos de campos de entrada |
| `inputBorder` | `#3D3D5C` | `#E0E0E0` | Bordes de campos de entrada |

---

## Testing

- **Flutter analyze:** 0 errores
- **Flutter test:** 674 tests — todos pasando, 0 fallos
- **Sin regresiones** introducidas por la refactorización de colores
