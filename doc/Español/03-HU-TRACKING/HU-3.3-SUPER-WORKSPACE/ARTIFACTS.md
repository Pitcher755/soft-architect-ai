# 📦 HU-3.3 Artifacts Manifest

> **Purpose:** Complete list of all archivos to be creard or modified for HU-3.3
> **Last Updated:** 06/02/2026

---

## 📋 Table of Contents

- [Overview](#overview)
- [Fase 1: Shell Container](#fase-1-shell-container)
- [Fase 2: Archivo System Tree](#fase-2-archivo-system-tree)
- [Fase 3: Markdown Preview](#fase-3-markdown-preview)
- [Fase 4: Chat Widgets](#fase-4-chat-widgets-done-)
- [Fase 5: Sequential Chat](#fase-5-sequential-chat-done-)
- [Fase 6: Integración](#fase-6-integration)
- [Statistics](#statistics)

---

## 🎯 Overview

This documento tracks ALL archivos that need to be creard or modified for the complete HU-3.3 implementación.

**Legend:**
- ✅ **DONE** - Archivo creard and pruebaed
- 🔄 **TODO** - Archivo needs to be creard
- ✏️ **MODIFY** - Existing archivo needs modification

---

## 📂 FASE 1: Shell Container

**Goal:** Crear the 3-column workspace layout with routing

### Production Code

| Estado | Archivo Path | Lines | Purpose |
|--------|-----------|-------|---------|
| 🔄 | `lib/features/proyecto_shell/presentation/screens/proyecto_workspace_screen.dart` | ~150 | Main workspace screen with 3 columns |
| ✏️ | `lib/core/router/app_router.dart` | +20 | Add `/workspace/:proyectoId` route |
| ✏️ | `lib/features/proyecto_shell/presentation/screens/proyecto_shell_screen.dart` | +10 | Update navigation to workspace |

### Prueba Code

| Estado | Archivo Path | Lines | Purpose |
|--------|-----------|-------|---------|
| 🔄 | `prueba/features/proyecto_shell/presentation/screens/proyecto_workspace_screen_prueba.dart` | ~200 | Widget pruebas for workspace screen |

**Subtotal:** 3 production archivos (~180 lines), 1 prueba archivo (~200 lines)

---

## 📂 FASE 2: Archivo System Tree

**Goal:** Display proyecto directory structure with expand/collapse

### Domain Layer

| Estado | Archivo Path | Lines | Purpose |
|--------|-----------|-------|---------|
| 🔄 | `lib/features/proyecto_shell/domain/entities/directory_node.dart` | ~30 | Entity representing archivo/carpeta node |

### Presentación Layer

| Estado | Archivo Path | Lines | Purpose |
|--------|-----------|-------|---------|
| 🔄 | `lib/features/proyecto_shell/presentation/widgets/archivo_system_tree_widget.dart` | ~150 | Main tree widget |
| 🔄 | `lib/features/proyecto_shell/presentation/widgets/_directory_tree_view.dart` | ~100 | Recursive tree node renderer |
| 🔄 | `lib/features/proyecto_shell/presentation/notifiers/archivo_system_notifier.dart` | ~100 | State management for tree |
| 🔄 | `lib/features/proyecto_shell/presentation/notifiers/archivo_system_state.dart` | ~50 | Immutable state class |

### Data Layer

| Estado | Archivo Path | Lines | Purpose |
|--------|-----------|-------|---------|
| ✏️ | `lib/features/proyecto_shell/data/services/archivo_system_service.dart` | +80 | Add `getDirectoryTree()` method |

### Prueba Code

| Estado | Archivo Path | Lines | Purpose |
|--------|-----------|-------|---------|
| 🔄 | `prueba/features/proyecto_shell/presentation/widgets/archivo_system_tree_widget_prueba.dart` | ~300 | Widget pruebas for tree |
| 🔄 | `prueba/features/proyecto_shell/presentation/notifiers/archivo_system_notifier_prueba.dart` | ~150 | Unit pruebas for notifier |
| 🔄 | `prueba/features/proyecto_shell/domain/entities/directory_node_prueba.dart` | ~50 | Entity pruebas |

**Subtotal:** 5 production archivos (~430 lines), 1 modification (+80 lines), 3 prueba archivos (~500 lines)

---

## 📂 FASE 3: Markdown Preview

**Goal:** Render selected markdown with GitHub Dark theme

### Presentación Layer

| Estado | Archivo Path | Lines | Purpose |
|--------|-----------|-------|---------|
| 🔄 | `lib/features/proyecto_shell/presentation/widgets/markdown_preview_widget.dart` | ~120 | Preview panel widget |
| 🔄 | `lib/features/proyecto_shell/presentation/notifiers/markdown_preview_notifier.dart` | ~60 | State management for preview |
| 🔄 | `lib/features/proyecto_shell/presentation/notifiers/markdown_preview_state.dart` | ~20 | Immutable state class |
| 🔄 | `lib/core/theme/markdown_theme.dart` | ~80 | GitHub Dark markdown estilos |

### Prueba Code

| Estado | Archivo Path | Lines | Purpose |
|--------|-----------|-------|---------|
| 🔄 | `prueba/features/proyecto_shell/presentation/widgets/markdown_preview_widget_prueba.dart` | ~150 | Widget pruebas |
| 🔄 | `prueba/features/proyecto_shell/presentation/notifiers/markdown_preview_notifier_prueba.dart` | ~100 | Notifier pruebas |

**Subtotal:** 4 production archivos (~280 lines), 2 prueba archivos (~250 lines)

---

## 📂 FASE 4: Chat Widgets (DONE ✅)

**Goal:** Basic chat UI widgets

### Presentación Layer

| Estado | Archivo Path | Lines | Purpose |
|--------|-----------|-------|---------|
| ✅ | `lib/features/chat/presentation/widgets/message_bubble_widget.dart` | 99 | User/assistant message bubble |
| ✅ | `lib/features/chat/presentation/widgets/streaming_indicator_widget.dart` | 168 | Animated progress indicator |
| ✅ | `lib/features/chat/presentation/widgets/proposal_card_widget.dart` | 184 | Documento proposal card |

### Domain Layer

| Estado | Archivo Path | Lines | Purpose |
|--------|-----------|-------|---------|
| ✅ | `lib/features/chat/domain/entities/chat_message_ui.dart` | ~30 | UI model for messages |
| ✅ | `lib/features/chat/domain/entities/proposal.dart` | ~40 | Proposal entity |

### Prueba Code

| Estado | Archivo Path | Lines | Purpose |
|--------|-----------|-------|---------|
| ✅ | `prueba/features/chat/presentation/widgets/message_bubble_widget_prueba.dart` | ~150 | Widget pruebas |
| ✅ | `prueba/features/chat/presentation/widgets/streaming_indicator_widget_prueba.dart` | ~200 | Widget + animation pruebas |
| ✅ | `prueba/features/chat/presentation/widgets/proposal_card_widget_prueba.dart` | ~180 | Widget + interaction pruebas |

**Subtotal:** 5 production archivos (521 lines), 3 prueba archivos (~530 lines) ✅

---

## 📂 FASE 5: Sequential Chat (DONE ✅)

**Goal:** Orchestrate documento generation flow

### Presentación Layer

| Estado | Archivo Path | Lines | Purpose |
|--------|-----------|-------|---------|
| ✅ | `lib/features/chat/presentation/screens/chat_screen.dart` | 190 | Main chat screen |
| ✅ | `lib/features/chat/presentation/notifiers/chat_notifier.dart` | 351 | State management for chat |
| ✅ | `lib/features/chat/presentation/notifiers/chat_state.dart` | ~80 | Immutable chat state |

### Prueba Code

| Estado | Archivo Path | Lines | Purpose |
|--------|-----------|-------|---------|
| ✅ | `prueba/features/chat/presentation/screens/chat_screen_prueba.dart` | ~200 | Widget pruebas |
| ✅ | `prueba/features/chat/presentation/notifiers/chat_notifier_prueba.dart` | ~250 | Notifier pruebas |

**Subtotal:** 3 production archivos (621 lines), 2 prueba archivos (~450 lines) ✅

---

## 📂 FASE 6: Integración

**Goal:** Connect all panels to work together

### Modifications

| Estado | Archivo Path | Lines | Purpose |
|--------|-----------|-------|---------|
| 🔄 | `lib/features/chat/presentation/notifiers/chat_notifier.dart` | +100 | Add `validateProposal()` method |
| 🔄 | `lib/features/proyecto_shell/presentation/notifiers/archivo_system_notifier.dart` | +50 | Add `refresh()` method |
| 🔄 | `lib/features/proyecto_shell/presentation/notifiers/markdown_preview_notifier.dart` | +20 | Connect to archivo selection |

### Prueba Code

| Estado | Archivo Path | Lines | Purpose |
|--------|-----------|-------|---------|
| 🔄 | `prueba/features/integration/workspace_integration_prueba.dart` | ~400 | End-to-end integration pruebas |
| 🔄 | `prueba/features/integration/chat_validation_prueba.dart` | ~200 | Validation flow pruebas |
| 🔄 | `prueba/features/integration/archivo_preview_prueba.dart` | ~150 | Archivo selection → preview pruebas |

**Subtotal:** 3 modifications (+170 lines), 3 prueba archivos (~750 lines)

---

## 📊 Statistics

### Production Code Summary

| Fase | Archivos Creard | Archivos Modified | Lines (New) | Lines (Modified) | Total Lines |
|-------|---------------|----------------|-------------|------------------|-------------|
| **Fase 1** | 1 | 2 | 150 | +30 | 180 |
| **Fase 2** | 5 | 1 | 430 | +80 | 510 |
| **Fase 3** | 4 | 0 | 280 | 0 | 280 |
| **Fase 4** | 5 ✅ | 0 | 521 | 0 | 521 |
| **Fase 5** | 3 ✅ | 0 | 621 | 0 | 621 |
| **Fase 6** | 0 | 3 | 0 | +170 | 170 |
| **TOTAL** | **18** | **6** | **2,002** | **+280** | **2,282** |

### Prueba Code Summary

| Fase | Prueba Archivos | Lines (Estimated) |
|-------|-----------|------------------|
| **Fase 1** | 1 | 200 |
| **Fase 2** | 3 | 500 |
| **Fase 3** | 2 | 250 |
| **Fase 4** | 3 ✅ | 530 |
| **Fase 5** | 2 ✅ | 450 |
| **Fase 6** | 3 | 750 |
| **TOTAL** | **14** | **2,680** |

### Overall Statistics

| Metric | Count |
|--------|-------|
| **Production Archivos Creard** | 18 |
| **Production Archivos Modified** | 6 |
| **Prueba Archivos Creard** | 14 |
| **Total Production Lines** | 2,282 |
| **Total Prueba Lines** | 2,680 |
| **Grand Total Lines** | 4,962 |
| **Archivos Already Complete** | 8 (Fases 4-5) ✅ |
| **Archivos Remaining** | 16 |
| **Completion %** | 33% (8/24 archivos) |

---

## 📁 Archivo Structure Overview

```
lib/
├── core/
│   ├── router/
│   │   └── app_router.dart .................... ✏️ MODIFY (Phase 1)
│   └── theme/
│       └── markdown_theme.dart ................ 🔄 CREATE (Phase 3)
│
└── features/
    ├── project_shell/
    │   ├── domain/
    │   │   └── entities/
    │   │       └── directory_node.dart ........ 🔄 CREATE (Phase 2)
    │   │
    │   ├── data/
    │   │   └── services/
    │   │       └── file_system_service.dart ... ✏️ MODIFY (Phase 2)
    │   │
    │   └── presentation/
    │       ├── screens/
    │       │   ├── project_workspace_screen.dart .. 🔄 CREATE (Phase 1)
    │       │   └── project_shell_screen.dart ...... ✏️ MODIFY (Phase 1)
    │       │
    │       ├── widgets/
    │       │   ├── file_system_tree_widget.dart ... 🔄 CREATE (Phase 2)
    │       │   ├── _directory_tree_view.dart ...... 🔄 CREATE (Phase 2)
    │       │   └── markdown_preview_widget.dart ... 🔄 CREATE (Phase 3)
    │       │
    │       └── notifiers/
    │           ├── file_system_notifier.dart ...... 🔄 CREATE (Phase 2)
    │           ├── file_system_state.dart ......... 🔄 CREATE (Phase 2)
    │           ├── markdown_preview_notifier.dart . 🔄 CREATE (Phase 3)
    │           └── markdown_preview_state.dart .... 🔄 CREATE (Phase 3)
    │
    └── chat/
        ├── domain/
        │   └── entities/
        │       ├── chat_message_ui.dart ........... ✅ DONE (Phase 4)
        │       └── proposal.dart .................. ✅ DONE (Phase 4)
        │
        └── presentation/
            ├── screens/
            │   └── chat_screen.dart ............... ✅ DONE (Phase 5)
            │
            ├── widgets/
            │   ├── message_bubble_widget.dart ..... ✅ DONE (Phase 4)
            │   ├── streaming_indicator_widget.dart  ✅ DONE (Phase 4)
            │   └── proposal_card_widget.dart ...... ✅ DONE (Phase 4)
            │
            └── notifiers/
                ├── chat_notifier.dart ............. ✅ DONE (Phase 5)
                └── chat_state.dart ................ ✅ DONE (Phase 5)

test/
├── features/
│   ├── project_shell/
│   │   ├── domain/
│   │   │   └── entities/
│   │   │       └── directory_node_test.dart ... 🔄 CREATE (Phase 2)
│   │   │
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── project_workspace_screen_test.dart . 🔄 CREATE (Phase 1)
│   │       │
│   │       ├── widgets/
│   │       │   ├── file_system_tree_widget_test.dart .. 🔄 CREATE (Phase 2)
│   │       │   └── markdown_preview_widget_test.dart .. 🔄 CREATE (Phase 3)
│   │       │
│   │       └── notifiers/
│   │           ├── file_system_notifier_test.dart ..... 🔄 CREATE (Phase 2)
│   │           └── markdown_preview_notifier_test.dart  🔄 CREATE (Phase 3)
│   │
│   ├── chat/
│   │   └── presentation/
│   │       ├── screens/
│   │       │   └── chat_screen_test.dart .............. ✅ DONE (Phase 5)
│   │       │
│   │       ├── widgets/
│   │       │   ├── message_bubble_widget_test.dart .... ✅ DONE (Phase 4)
│   │       │   ├── streaming_indicator_widget_test.dart ✅ DONE (Phase 4)
│   │       │   └── proposal_card_widget_test.dart ..... ✅ DONE (Phase 4)
│   │       │
│   │       └── notifiers/
│   │           └── chat_notifier_test.dart ............ ✅ DONE (Phase 5)
│   │
│   └── integration/
│       ├── workspace_integration_test.dart ............ 🔄 CREATE (Phase 6)
│       ├── chat_validation_test.dart .................. 🔄 CREATE (Phase 6)
│       └── file_preview_test.dart ..................... 🔄 CREATE (Phase 6)
```

---

## 🎯 Siguiente Actions

### Immediate (Fase 1)
1. Crear `proyecto_workspace_screen.dart` (150 lines)
2. Modify `app_router.dart` (+20 lines)
3. Modify `proyecto_shell_screen.dart` (+10 lines)
4. Write pruebas: `proyecto_workspace_screen_prueba.dart` (200 lines)

### This Week (Fases 2-3)
1. Implement Fase 2: Archivo System Tree (510 lines + 500 prueba lines)
2. Implement Fase 3: Markdown Preview (280 lines + 250 prueba lines)

### Siguiente Week (Fase 6)
1. Integración work (+170 lines modifications)
2. End-to-end pruebas (750 prueba lines)

---

**Last Updated:** 06/02/2026 15:50 CET
**Estado:** 33% Complete (8/24 archivos done)
**Maintained By:** ArchitectZero Agent
