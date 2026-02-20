# 📊 HU-3.3 Progress Tracking

> **Branch:** `feature/chat-sequential-docs`
> **Started:** 06/02/2026
> **Estado:** 🟡 IN PROGRESS (40% Complete)

---

## 🎯 Sprint Goal

Build a complete VS Code-like workspace with:
- 3-column layout (Archivo Tree | Chat | Preview)
- Sequential documento generation via chat
- Real-time archivo system integration
- Markdown preview with GitHub Dark theme

---

## 📅 Timeline

| Fase | Duration | Start | End | Estado |
|-------|----------|-------|-----|--------|
| Fase 1: Shell | 2 days | - | - | ⏳ TODO |
| Fase 2: Archivo Tree | 3 days | - | - | ⏳ TODO |
| Fase 3: Preview | 2 days | - | - | ⏳ TODO |
| Fase 4: Widgets | - | - | - | ✅ DONE |
| Fase 5: Chat | - | - | - | ✅ DONE |
| Fase 6: Integración | 4 days | - | - | ⏳ TODO |

**Total Estimated:** 11 working days (2.2 weeks)

---

## ✅ FASE 1: Shell Container (The Fundación)

**Goal:** Crear the 3-column workspace layout with routing
**Estado:** ⏳ TODO
**Progress:** 0/10 tasks

### Pruebas (RED Fase)

- [ ] **T1.1:** Prueba ProyectoWorkspaceScreen renders 3 columns
  - Archivo: `prueba/features/proyecto_shell/presentation/screens/proyecto_workspace_screen_prueba.dart`
  - Verify: ArchivoSystemTreeWidget, SequentialChatScreen, MarkdownPreviewWidget visible

- [ ] **T1.2:** Prueba AppBar shows proyecto progress
  - Verify: "Doc X/25" text appears
  - Verify: LinearProgressIndicator renders

- [ ] **T1.3:** Prueba column widths are correct
  - Left: 250px fixed
  - Center: flex
  - Right: 450px fixed

- [ ] **T1.4:** Prueba navigation to workspace route
  - Route: `/workspace/:proyectoId`
  - Verify: Screen loads with correct proyectoPath

### Implementación (GREEN Fase)

- [ ] **I1.1:** Crear ProyectoWorkspaceScreen widget
  - Archivo: `lib/features/proyecto_shell/presentation/screens/proyecto_workspace_screen.dart`
  - Scaffold with AppBar + Row of 3 containers

- [ ] **I1.2:** Implement AppBar with progress
  - Show current doc index (1-25)
  - Show current fase (CONTEXT, REQUIREMENTS, etc.)
  - Add LinearProgressIndicator

- [ ] **I1.3:** Add route to app_router.dart
  - Path: `/workspace/:proyectoId`
  - Builder: ProyectoWorkspaceScreen with proyectoPath parameter

- [ ] **I1.4:** Update ProyectoSelectionScreen navigation
  - On proyecto tap: navigate to `/workspace/:id`

### Refactor (BLUE Fase)

- [ ] **R1.1:** Extract progress bar to separate widget
- [ ] **R1.2:** Add documentoation (DartDoc)

### Verificación

- [ ] `flutter prueba prueba/features/proyecto_shell/screens/` → All passing
- [ ] `flutter analyze` → 0 errors
- [ ] Manual prueba: Click proyecto → workspace opens
- [ ] Manual prueba: 3 columns visible with placeholders

**Completion Date:** _______

---

## ✅ FASE 2: Archivo System Tree (Left Panel)

**Goal:** Display proyecto directory structure with expand/collapse
**Estado:** ⏳ TODO
**Progress:** 0/15 tasks

### Domain Models

- [ ] **D2.1:** Crear DirectoryNode entity
  - Archivo: `lib/features/proyecto_shell/domain/entities/directory_node.dart`
  - Properties: name, path, isDirectory, children

- [ ] **D2.2:** Crear ArchivoSystemState
  - Archivo: `lib/features/proyecto_shell/presentation/notifiers/archivo_system_state.dart`
  - Properties: rootPath, tree, expandedPaths, selectedArchivo

### Pruebas (RED Fase)

- [ ] **T2.1:** Prueba ArchivoSystemTreeWidget displays directory structure
  - Mock: ArchivoSystemService.getDirectoryTree()
  - Verify: Carpetas "10-CONTEXT", "20-REQUIREMENTS" visible

- [ ] **T2.2:** Prueba carpeta expand/collapse
  - Action: Tap carpeta
  - Verify: Children toggle visibility

- [ ] **T2.3:** Prueba archivo selection
  - Action: Tap archivo
  - Verify: ArchivoSystemNotifier.selectArchivo() called
  - Verify: Item highlighted

- [ ] **T2.4:** Prueba scrollable overflow
  - Setup: Tree with 50+ items
  - Verify: SingleChildScrollView works

- [ ] **T2.5:** Prueba carpeta/archivo icons
  - Verify: Carpetas show carpeta_open/carpeta icons
  - Verify: Archivos show descripción icon

### Implementación (GREEN Fase)

- [ ] **I2.1:** Crear ArchivoSystemTreeWidget
  - Archivo: `lib/features/proyecto_shell/presentation/widgets/archivo_system_tree_widget.dart`
  - Column: Header + Tree view

- [ ] **I2.2:** Crear _DirectoryTreeView recursive widget
  - Recursive rendering of DirectoryNode children
  - Indentation based on depth

- [ ] **I2.3:** Implement ArchivoSystemNotifier
  - Archivo: `lib/features/proyecto_shell/presentation/notifiers/archivo_system_notifier.dart`
  - Methods: build(), toggleExpanded(), selectArchivo()

- [ ] **I2.4:** Update ArchivoSystemService
  - Add method: `Future<DirectoryNode> getDirectoryTree(String path)`
  - Recursively scan directory structure

- [ ] **I2.5:** Add to ProyectoWorkspaceScreen
  - Replace placeholder with ArchivoSystemTreeWidget

### Refactor (BLUE Fase)

- [ ] **R2.1:** Extract tree node widget
- [ ] **R2.2:** Optimize tree rendering (avoid rebuilds)
- [ ] **R2.3:** Add documentoation

### Verificación

- [ ] `flutter prueba prueba/features/proyecto_shell/widgets/archivo_system_tree_widget_prueba.dart` → All passing
- [ ] Manual prueba: Tree displays proyecto carpetas
- [ ] Manual prueba: Expand/collapse works
- [ ] Manual prueba: Archivo selection highlights item

**Completion Date:** _______

---

## ✅ FASE 3: Markdown Preview (Right Panel)

**Goal:** Render selected markdown with GitHub Dark theme
**Estado:** ⏳ TODO
**Progress:** 0/8 tasks

### Domain Models

- [ ] **D3.1:** Crear MarkdownPreviewState
  - Archivo: `lib/features/proyecto_shell/presentation/notifiers/markdown_preview_state.dart`
  - Properties: content, archivoPath

### Pruebas (RED Fase)

- [ ] **T3.1:** Prueba MarkdownPreviewWidget shows empty state
  - Setup: No archivo selected
  - Verify: "Select a archivo to preview" message

- [ ] **T3.2:** Prueba markdown rendering
  - Setup: Load markdown content
  - Verify: Headers, paragraphs, code blocks render

- [ ] **T3.3:** Prueba loading state
  - Setup: Trigger loadArchivo()
  - Verify: CircularProgressIndicator shows

- [ ] **T3.4:** Prueba error state
  - Setup: Archivo read error
  - Verify: Error message displays

### Implementación (GREEN Fase)

- [ ] **I3.1:** Crear MarkdownPreviewWidget
  - Archivo: `lib/features/proyecto_shell/presentation/widgets/markdown_preview_widget.dart`
  - Column: Header + Markdown content

- [ ] **I3.2:** Implement MarkdownPreviewNotifier
  - Archivo: `lib/features/proyecto_shell/presentation/notifiers/markdown_preview_notifier.dart`
  - Method: loadArchivo(String path)

- [ ] **I3.3:** Configure MarkdownEstiloSheet
  - GitHub Dark theme colors
  - Code block styling with FiraCode font

- [ ] **I3.4:** Add to ProyectoWorkspaceScreen
  - Replace placeholder with MarkdownPreviewWidget

### Refactor (BLUE Fase)

- [ ] **R3.1:** Extract theme configuración
- [ ] **R3.2:** Add documentoation

### Verificación

- [ ] `flutter prueba prueba/features/proyecto_shell/widgets/markdown_preview_widget_prueba.dart` → All passing
- [ ] Manual prueba: Empty state displays
- [ ] Manual prueba: Select archivo → markdown renders
- [ ] Manual prueba: Code blocks have syntax highlighting

**Completion Date:** _______

---

## ✅ FASE 4: Chat Components (ALREADY DONE ✅)

**Goal:** Basic chat UI widgets
**Estado:** ✅ COMPLETE
**Progress:** 20/20 tasks

### Completado Components

- [x] **MessageBubbleWidget** (99 lines)
  - Renders user/assistant messages
  - Estilod with GitHub Dark theme
  - Timestamps and avatars

- [x] **StreamingIndicatorWidget** (168 lines)
  - Animated progress bar
  - Documento counter (Doc X/Y)
  - Percentage display

- [x] **ProposalCardWidget** (184 lines)
  - Markdown preview of proposal
  - Validate/Refine/Reject botóns
  - Estilod card with borders

### Verificación

- [x] All widget pruebas passing (20/20)
- [x] Visual verificación done
- [x] Integrated into ChatScreen

**Completion Date:** 16/01/2026 ✅

---

## ✅ FASE 5: Sequential Chat Logic (ALREADY DONE ✅)

**Goal:** Orchestrate documento generation flow
**Estado:** ✅ COMPLETE
**Progress:** 12/12 tasks

### Completado Components

- [x] **ChatScreen** (190 lines)
  - ConsumerStatefulWidget with ChatNotifier
  - ListView of messages (reverse order)
  - Conditional StreamingIndicatorWidget
  - TextField + send botón

- [x] **ChatNotifier** (351 lines)
  - StateNotifier managing ChatState
  - sendMessage() method
  - Streaming state management

- [x] **ChatState** (streaming_state.dart)
  - Immutable state class
  - Messages list, currentProposal, streaming flags

### Verificación

- [x] All pruebas passing (12/12)
- [x] Chat integrated into app router
- [x] Navigation botón in ProyectoShellScreen

**Completion Date:** 06/02/2026 ✅

---

## ✅ FASE 6: Integración & Wiring

**Goal:** Connect all panels to work together
**Estado:** ⏳ TODO
**Progress:** 0/25 tasks

### Pruebas (RED Fase)

- [ ] **T6.1:** Prueba validate saves archivo and updates tree
  - Action: Click Validate on ProposalCard
  - Verify: ArchivoSystemService.saveDocumento() called
  - Verify: Archivo tree refreshes
  - Verify: New archivo appears in tree

- [ ] **T6.2:** Prueba selecting archivo updates preview
  - Action: Click archivo in tree
  - Verify: MarkdownPreviewNotifier.loadArchivo() called
  - Verify: Preview shows archivo content

- [ ] **T6.3:** Prueba validate advances to siguiente doc
  - Action: Click Validate
  - Verify: currentDocIndex increments
  - Verify: Chat shows "Let's continue with Doc 2"

- [ ] **T6.4:** Prueba error handling
  - Setup: Archivo save fails
  - Verify: Error banner displays
  - Verify: User-friendly message (no stack trace)

### Implementación (GREEN Fase)

- [ ] **I6.1:** Update ChatNotifier.validateProposal()
  - Save archivo to disk via ArchivoSystemService
  - Trigger ArchivoSystemNotifier.refresh()
  - Increment currentDocIndex
  - Send siguiente prompt

- [ ] **I6.2:** Connect ArchivoSystemNotifier to MarkdownPreviewNotifier
  - On selectArchivo: trigger preview update

- [ ] **I6.3:** Add error handling
  - Wrap save operations in try/catch
  - Update state with error message
  - Display ErrorBannerWidget

- [ ] **I6.4:** Implement ArchivoSystemNotifier.refresh()
  - Re-scan directory tree
  - Preserve expanded paths
  - Update state

### Refactor (BLUE Fase)

- [ ] **R6.1:** Extract validation logic to use case
- [ ] **R6.2:** Add logging
- [ ] **R6.3:** Optimize refresh (only scan changed carpetas)

### Verificación

- [ ] `flutter prueba prueba/features/integration/` → All passing
- [ ] Manual prueba: Full workflow (generate → validate → preview → siguiente)
- [ ] Manual prueba: Error scenarios
- [ ] Manual prueba: Multiple documentos in sequence

**Completion Date:** _______

---

## 📊 Overall Statistics

### Code Metrics

| Metric | Current | Target | Progress |
|--------|---------|--------|----------|
| **Archivos Creard** | 5 | 12 | 42% |
| **Lines of Code** | 641 | 1,491 | 43% |
| **Pruebas Written** | 32 | 90 | 36% |
| **Pruebas Passing** | 32 | 90 | 36% |
| **Coverage** | 85% | 80% | ✅ 106% |

### Time Tracking

| Fase | Estimated | Actual | Variance |
|-------|-----------|--------|----------|
| Fase 1 | 2 days | - | - |
| Fase 2 | 3 days | - | - |
| Fase 3 | 2 days | - | - |
| Fase 4 | - | 3 days | ✅ Done |
| Fase 5 | - | 2 days | ✅ Done |
| Fase 6 | 4 days | - | - |
| **TOTAL** | 11 days | 5 days | -6 days remaining |

### Quality Gates

- [ ] **QG1:** All pruebas passing (90/90)
- [x] **QG2:** Coverage >80% (currently 85% ✅)
- [ ] **QG3:** Flutter analyze: 0 errors
- [ ] **QG4:** No TODO comments in production code
- [ ] **QG5:** All DartDoc comments added
- [ ] **QG6:** Manual pruebaing checklist complete
- [ ] **QG7:** Demo video recorded
- [ ] **QG8:** PR approved

---

## 🚧 Blockers & Risks

### Current Blockers
- None

### Identified Risks
1. **Archivo I/O Performance:** Tree scanning might be slow for large proyectos
   - **Mitigation:** Implement lazy loading, cache results

2. **Memory Usage:** Large markdown archivos in preview
   - **Mitigation:** Implement pagination, limit archivo size

3. **Streaming Latency:** Backend might be slow
   - **Mitigation:** Add timeout handling, show progress

---

## 📝 Notes

### 06/02/2026
- ✅ Completado widget integration (Fases 4-5)
- ✅ Creard master workflow documento
- 🔄 Starting Fase 1: Shell Container siguiente

### [Date]
- Progress notes...

---

## 🎯 Siguiente Actions

1. **Immediate:** Start Fase 1 (Shell Container)
   - Write pruebas for ProyectoWorkspaceScreen
   - Implement 3-column layout
   - Add routing

2. **This Week:** Complete Fases 1-3
   - Shell, Archivo Tree, Preview

3. **Siguiente Week:** Complete Fase 6 (Integración)
   - Connect all panels
   - End-to-end pruebaing

---

**Last Updated:** 06/02/2026 15:45 CET
**Updated By:** ArchitectZero Agent
