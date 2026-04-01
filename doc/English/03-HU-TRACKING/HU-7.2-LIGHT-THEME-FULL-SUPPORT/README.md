# HU-7.2 — Light Theme Full Support (ThemeExtension)

> **Date:** 07/07/2025
> **Status:** ✅ Completed
> **Branch:** `feature/hu-7.2-light-theme-full-support`
> **Linear ticket:** [PIT-133](https://linear.app/pitcherdev/issue/PIT-133)

## 📋 Table of Contents

1. [Overview](#overview)
2. [Motivation](#motivation)
3. [Implementation](#implementation)
4. [Files Changed](#files-changed)
5. [Color Token Reference](#color-token-reference)
6. [Testing](#testing)

---

## Overview

Refactored 40+ hardcoded hex colors across the Flutter client to use a
centralized `ThemeExtension<AppColorsExtension>`, enabling full Light
Mode support alongside the existing Dark Mode.

---

## Motivation

| Problem | Impact |
|---------|--------|
| Hardcoded `Color(0xFF...)` in widgets | Unreadable in Light Mode |
| No semantic color tokens | Inconsistent palette across features |
| Dark-only assumption | Accessibility and user preference gaps |
| Scattered hex values | Difficult maintenance and theme updates |

---

## Implementation

### 1. AppColorsExtension (NEW)

Created `src/client/lib/core/theme/app_colors_extension.dart`:

- `ThemeExtension<AppColorsExtension>` with ~20 semantic color tokens
- Factory constructors `darkTheme` and `lightTheme` with curated palettes
- Full `copyWith()` and `lerp()` support for smooth theme transitions
- `BuildContext` extension for ergonomic access: `context.appColors.cardBg`

### 2. Theme Config Wiring

Updated `src/client/lib/core/config/theme_config.dart`:

- Added `extensions: [AppColorsExtension.darkTheme]` to `darkTheme()`
- Added `extensions: [AppColorsExtension.lightTheme]` to `lightTheme()`

### 3. Widget Migration (10 files)

Replaced hardcoded hex colors with `context.appColors.*` tokens in all
widget files that used inline `Color(0xFF...)` values.

Special case: `CodeElementBuilder` (extends `MarkdownElementBuilder`, no
`BuildContext`) receives colors via constructor parameters with dark-theme
fallback defaults.

---

## Files Changed

| File | Type | Description |
|------|------|-------------|
| `core/theme/app_colors_extension.dart` | **NEW** | ThemeExtension with ~20 semantic tokens |
| `core/config/theme_config.dart` | MODIFIED | Wired extensions into both themes |
| `settings/widgets/settings_card.dart` | MODIFIED | Card bg/border tokens |
| `settings/widgets/storage_section.dart` | MODIFIED | Text color tokens |
| `settings/widgets/profile_section.dart` | MODIFIED | Avatar color tokens |
| `settings/widgets/setting_item.dart` | MODIFIED | Item color tokens |
| `project_shell/widgets/workspace_header.dart` | MODIFIED | Heading text tokens |
| `project_shell/widgets/projects_grid.dart` | MODIFIED | Card bg/border/text tokens |
| `project_shell/widgets/markdown_preview_widget.dart` | MODIFIED | Code block + SnackBar tokens |
| `chat/widgets/document_proposal_card.dart` | MODIFIED | CodeElementBuilder color injection |
| `chat/widgets/smart_message_renderer.dart` | MODIFIED | CodeElementBuilder color injection |
| `shared/widgets/markdown_builders/code_element_builder.dart` | MODIFIED | Constructor params for colors |

---

## Color Token Reference

| Token | Dark Value | Light Value | Usage |
|-------|-----------|-------------|-------|
| `cardBg` | `#1E1E2E` | `#FFFFFF` | Card backgrounds |
| `cardBorder` | `#2D2D3F` | `#E0E0E0` | Card borders |
| `headingText` | `#E0E0FF` | `#1A1A2E` | Section headings |
| `textMain` | `#FFFFFF` | `#1A1A2E` | Primary text |
| `textSecondary` | `#B0B0C0` | `#666680` | Secondary text |
| `successBg` | `#1B5E20` (0.3) | `#E8F5E9` | Success backgrounds |
| `codeBg` | `#1A1A2E` | `#F5F5F5` | Code block backgrounds |
| `codeBorder` | `#3D3D5C` | `#E0E0E0` | Code block borders |
| `codeText` | `#E0E0FF` | `#1A1A2E` | Code text |
| `inputBg` | `#2D2D3F` | `#F5F5F5` | Input field backgrounds |
| `inputBorder` | `#3D3D5C` | `#E0E0E0` | Input field borders |

---

## Testing

- **Flutter analyze:** 0 errors
- **Flutter test:** 674 tests — all passing, 0 failures
- **No regressions** introduced by the color refactor
