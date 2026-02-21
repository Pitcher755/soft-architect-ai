# 📦 HU-3.3 Artifacts Manifest

> **Purpose:** Complete list of all files to be created or modified for HU-3.3
> **Last Updated:** 06/02/2026

---

## 📋 Table of Contents

- [Overview](#overview)
- [Phase 1: Shell Container](#phase-1-shell-container)
- [Phase 2: File System Tree](#phase-2-file-system-tree)
- [Phase 3: Markdown Preview](#phase-3-markdown-preview)
- [Phase 4: Chat Widgets](#phase-4-chat-widgets-done-)
- [Phase 5: Sequential Chat](#phase-5-sequential-chat-done-)
- [Phase 6: Integration](#phase-6-integration)
- [Statistics](#statistics)

---

## 🎯 Overview

This document tracks ALL files that need to be created or modified for the complete HU-3.3 implementation.

**Legend:**
- ✅ **DONE** - File created and tested
- 🔄 **TODO** - File needs to be created
- ✏️ **MODIFY** - Existing file needs modification

---

## 📂 PHASE 1: Shell Container

**Goal:** Create the 3-column workspace layout with routing

### Production Code

| Status | File Path | Lines | Purpose |
|--------|-----------|-------|---------|
| 🔄 | `lib/features/project_shell/presentation/screens/project_workspace_screen.dart` | ~150 | Main workspace screen with 3 columns |
| ✏️ | `lib/core/router/app_router.dart` | +20 | Add `/workspace/:projectId` route |
| ✏️ | `lib/features/project_shell/presentation/screens/project_shell_screen.dart` | +10 | Update navigation to workspace |

### Test Code

| Status | File Path | Lines | Purpose |
|--------|-----------|-------|---------|
| 🔄 | `test/features/project_shell/presentation/screens/project_workspace_screen_test.dart` | ~200 | Widget tests for workspace screen |

**Subtotal:** 3 production files (~180 lines), 1 test file (~200 lines)

---

## 📂 PHASE 2: File System Tree

**Goal:** Display project directory structure with expand/collapse

### Domain Layer

| Status | File Path | Lines | Purpose |
|--------|-----------|-------|---------|
| 🔄 | `lib/features/project_shell/domain/entities/directory_node.dart` | ~30 | Entity representing file/folder node |

### Presentation Layer

| Status | File Path | Lines | Purpose |
|--------|-----------|-------|---------|
| 🔄 | `lib/features/project_shell/presentation/widgets/file_system_tree_widget.dart` | ~150 | Main tree widget |
| 🔄 | `lib/features/project_shell/presentation/widgets/_directory_tree_view.dart` | ~100 | Recursive tree node renderer |
| 🔄 | `lib/features/project_shell/presentation/notifiers/file_system_notifier.dart` | ~100 | State management for tree |
| 🔄 | `lib/features/project_shell/presentation/notifiers/file_system_state.dart` | ~50 | Immutable state class |

### Data Layer

| Status | File Path | Lines | Purpose |
|--------|-----------|-------|---------|
| ✏️ | `lib/features/project_shell/data/services/file_system_service.dart` | +80 | Add `getDirectoryTree()` method |

### Test Code

| Status | File Path | Lines | Purpose |
|--------|-----------|-------|---------|
| 🔄 | `test/features/project_shell/presentation/widgets/file_system_tree_widget_test.dart` | ~300 | Widget tests for tree |
| 🔄 | `test/features/project_shell/presentation/notifiers/file_system_notifier_test.dart` | ~150 | Unit tests for notifier |
| 🔄 | `test/features/project_shell/domain/entities/directory_node_test.dart` | ~50 | Entity tests |

**Subtotal:** 5 production files (~430 lines), 1 modification (+80 lines), 3 test files (~500 lines)

---

## 📂 PHASE 3: Markdown Preview

**Goal:** Render selected markdown with GitHub Dark theme

### Presentation Layer

| Status | File Path | Lines | Purpose |
|--------|-----------|-------|---------|
| 🔄 | `lib/features/project_shell/presentation/widgets/markdown_preview_widget.dart` | ~120 | Preview panel widget |
| 🔄 | `lib/features/project_shell/presentation/notifiers/markdown_preview_notifier.dart` | ~60 | State management for preview |
| 🔄 | `lib/features/project_shell/presentation/notifiers/markdown_preview_state.dart` | ~20 | Immutable state class |
| 🔄 | `lib/core/theme/markdown_theme.dart` | ~80 | GitHub Dark markdown styles |

### Test Code

| Status | File Path | Lines | Purpose |
|--------|-----------|-------|---------|
| 🔄 | `test/features/project_shell/presentation/widgets/markdown_preview_widget_test.dart` | ~150 | Widget tests |
| 🔄 | `test/features/project_shell/presentation/notifiers/markdown_preview_notifier_test.dart` | ~100 | Notifier tests |

**Subtotal:** 4 production files (~280 lines), 2 test files (~250 lines)

---

## 📂 PHASE 4: Chat Widgets (DONE ✅)

**Goal:** Basic chat UI widgets

### Presentation Layer

| Status | File Path | Lines | Purpose |
|--------|-----------|-------|---------|
| ✅ | `lib/features/chat/presentation/widgets/message_bubble_widget.dart` | 99 | User/assistant message bubble |
| ✅ | `lib/features/chat/presentation/widgets/streaming_indicator_widget.dart` | 168 | Animated progress indicator |
| ✅ | `lib/features/chat/presentation/widgets/proposal_card_widget.dart` | 184 | Document proposal card |

### Domain Layer

| Status | File Path | Lines | Purpose |
|--------|-----------|-------|---------|
| ✅ | `lib/features/chat/domain/entities/chat_message_ui.dart` | ~30 | UI model for messages |
| ✅ | `lib/features/chat/domain/entities/proposal.dart` | ~40 | Proposal entity |

### Test Code

| Status | File Path | Lines | Purpose |
|--------|-----------|-------|---------|
| ✅ | `test/features/chat/presentation/widgets/message_bubble_widget_test.dart` | ~150 | Widget tests |
| ✅ | `test/features/chat/presentation/widgets/streaming_indicator_widget_test.dart` | ~200 | Widget + animation tests |
| ✅ | `test/features/chat/presentation/widgets/proposal_card_widget_test.dart` | ~180 | Widget + interaction tests |

**Subtotal:** 5 production files (521 lines), 3 test files (~530 lines) ✅

---

## 📂 PHASE 5: Sequential Chat (DONE ✅)

**Goal:** Orchestrate document generation flow

### Presentation Layer

| Status | File Path | Lines | Purpose |
|--------|-----------|-------|---------|
| ✅ | `lib/features/chat/presentation/screens/chat_screen.dart` | 190 | Main chat screen |
| ✅ | `lib/features/chat/presentation/notifiers/chat_notifier.dart` | 351 | State management for chat |
| ✅ | `lib/features/chat/presentation/notifiers/chat_state.dart` | ~80 | Immutable chat state |

### Test Code

| Status | File Path | Lines | Purpose |
|--------|-----------|-------|---------|
| ✅ | `test/features/chat/presentation/screens/chat_screen_test.dart` | ~200 | Widget tests |
| ✅ | `test/features/chat/presentation/notifiers/chat_notifier_test.dart` | ~250 | Notifier tests |

**Subtotal:** 3 production files (621 lines), 2 test files (~450 lines) ✅

---

## 📂 PHASE 6: Integration

**Goal:** Connect all panels to work together

### Modifications

| Status | File Path | Lines | Purpose |
|--------|-----------|-------|---------|
| 🔄 | `lib/features/chat/presentation/notifiers/chat_notifier.dart` | +100 | Add `validateProposal()` method |
| 🔄 | `lib/features/project_shell/presentation/notifiers/file_system_notifier.dart` | +50 | Add `refresh()` method |
| 🔄 | `lib/features/project_shell/presentation/notifiers/markdown_preview_notifier.dart` | +20 | Connect to file selection |

### Test Code

| Status | File Path | Lines | Purpose |
|--------|-----------|-------|---------|
| 🔄 | `test/features/integration/workspace_integration_test.dart` | ~400 | End-to-end integration tests |
| 🔄 | `test/features/integration/chat_validation_test.dart` | ~200 | Validation flow tests |
| 🔄 | `test/features/integration/file_preview_test.dart` | ~150 | File selection → preview tests |

**Subtotal:** 3 modifications (+170 lines), 3 test files (~750 lines)

---

## 📊 Statistics

### Production Code Summary

| Phase | Files Created | Files Modified | Lines (New) | Lines (Modified) | Total Lines |
|-------|---------------|----------------|-------------|------------------|-------------|
| **Phase 1** | 1 | 2 | 150 | +30 | 180 |
| **Phase 2** | 5 | 1 | 430 | +80 | 510 |
| **Phase 3** | 4 | 0 | 280 | 0 | 280 |
| **Phase 4** | 5 ✅ | 0 | 521 | 0 | 521 |
| **Phase 5** | 3 ✅ | 0 | 621 | 0 | 621 |
| **Phase 6** | 0 | 3 | 0 | +170 | 170 |
| **TOTAL** | **18** | **6** | **2,002** | **+280** | **2,282** |

### Test Code Summary

| Phase | Test Files | Lines (Estimated) |
|-------|-----------|------------------|
| **Phase 1** | 1 | 200 |
| **Phase 2** | 3 | 500 |
| **Phase 3** | 2 | 250 |
| **Phase 4** | 3 ✅ | 530 |
| **Phase 5** | 2 ✅ | 450 |
| **Phase 6** | 3 | 750 |
| **TOTAL** | **14** | **2,680** |

### Overall Statistics

| Metric | Count |
|--------|-------|
| **Production Files Created** | 18 |
| **Production Files Modified** | 6 |
| **Test Files Created** | 14 |
| **Total Production Lines** | 2,282 |
| **Total Test Lines** | 2,680 |
| **Grand Total Lines** | 4,962 |
| **Files Already Complete** | 8 (Phases 4-5) ✅ |
| **Files Remaining** | 16 |
| **Completion %** | 33% (8/24 files) |

---

## 📁 File Structure Overview

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

## 🎯 Next Actions

### Immediate (Phase 1)
1. Create `project_workspace_screen.dart` (150 lines)
2. Modify `app_router.dart` (+20 lines)
3. Modify `project_shell_screen.dart` (+10 lines)
4. Write tests: `project_workspace_screen_test.dart` (200 lines)

### This Week (Phases 2-3)
1. Implement Phase 2: File System Tree (510 lines + 500 test lines)
2. Implement Phase 3: Markdown Preview (280 lines + 250 test lines)

### Next Week (Phase 6)
1. Integration work (+170 lines modifications)
2. End-to-end tests (750 test lines)

---

**Last Updated:** 06/02/2026 15:50 CET
**Status:** 33% Complete (8/24 files done)
**Maintained By:** ArchitectZero Agent
