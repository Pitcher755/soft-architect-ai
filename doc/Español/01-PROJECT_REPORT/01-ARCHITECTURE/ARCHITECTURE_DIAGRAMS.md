# 🏗️ Architecture Diagram - Proyecto Shell Screen

## Overall Layout (Desktop)

```
┌──────────────────────────────────────────────────────────────────────────┐
│                         PROJECT SHELL SCREEN                             │
├──────┬──────────────┬────────────────────────────────┬──────────────────┤
│      │              │                                │                  │
│ SID  │   FILES      │        CHAT PANEL             │   MARKDOWN       │
│ EBA  │   TREE       │    (+ Progress Header)        │   PREVIEW        │
│ R    │              │                                │                  │
│ 64px │ 260px        │       EXPANDED                │    420px         │
│      │ RESIZABLE    │                                │   RESIZABLE      │
│      │ COLLAPSIBLE  │                                │  COLLAPSIBLE     │
│      │              │                                │                  │
└──────┴──────────────┴────────────────────────────────┴──────────────────┘
   │         │                  │                           │
   │         └─► FileTreeWidget │                           │
   │                            └─► ProgressIndicatorWidget │
   │                                └─► ChatPanelWidget     │
   │                                                        └─► MarkdownPreviewWidget
   │
   └─► ProjectsSidebar (64px fixed)
```

---

## Component Hierarchy

```
ProjectShellScreen (ConsumerStatefulWidget)
│
├─► Scaffold
│   │
│   ├─► body: Row
│   │   │
│   │   ├─ [0] ProjectsSidebar (64px fixed)
│   │   │
│   │   ├─ [1] if (_showFilesPanel)
│   │   │   └─► ResizableColumn
│   │   │       └─► FileTreeWidget
│   │   │           ├─ Header (EXPLORER + Refresh button)
│   │   │           └─ Scrollable file tree
│   │   │               └─ _buildFileTree() [recursive]
│   │   │
│   │   ├─ [2] Expanded
│   │   │   └─► Column
│   │   │       ├─ ProgressIndicatorWidget
│   │   │       └─ ChatPanelWidget (Expanded)
│   │   │           ├─ Error banner
│   │   │           ├─ Message list (ListView)
│   │   │           │   └─ MessageBubbleWidget (×3 demo)
│   │   │           └─ Input area (TextField + Send button)
│   │   │
│   │   └─ [3] if (_showMarkdownPanel)
│   │       └─► ResizableColumn
│   │           └─► MarkdownPreviewWidget
│   │               ├─ Toolbar (Copy, Download buttons)
│   │               └─ Content area (SelectableText)
│   │
│   └─► floatingActionButton: Column
│       ├─ FAB 1: Toggle Files (📁 folder icon)
│       └─ FAB 2: Toggle Preview (👁 visibility icon)
```

---

## Data Flow Diagram

```
MockProjectData (Single Source of Truth)
│
├─► mockProjectRoot (FileNode tree)
│   │
│   ├─ ROOT: PROJECT-ALPHA
│   │  ├─ context/
│   │  │  └─ system-prompt.md
│   │  ├─ 10-CONTEXT/
│   │  │  ├─ 01-vision.md
│   │  │  ├─ 02-constraints.md
│   │  │  └─ 03-arch-overview.md
│   │  ├─ 20-REQUIREMENTS/
│   │  └─ 30-ARCHITECTURE/
│   │
│   └─► FileTreeWidget
│       │
│       ├─ State: _selectedNode (FileNode)
│       ├─ State: _expandedFolders (Set<String>)
│       │
│       └─ onFileSelected callback
│           ↓
│       ProjectShellScreen._onFileSelected()
│           │
│           ├─ setState(() => _selectedNode = node)
│           ├─ setState(() => _fileContent = getContent(node))
│           │
│           └─► MarkdownPreviewWidget
│               └─ Updates content: _fileContent
│
├─► mockChatMessages (List<ChatMessageUI>)
│   │
│   ├─ ChatMessageUI[0]: System message (timestamp - 5min)
│   ├─ ChatMessageUI[1]: User question (timestamp - 4min)
│   └─ ChatMessageUI[2]: AI response (timestamp - 3min)
│
│   └─► ChatPanelWidget
│       ├─ ListView.builder(messages)
│       ├─ MessageBubbleWidget ×3
│       └─ Input field (TextEditingController)
│
├─► mockDocumentsCreated: 8
├─► mockCurrentPhase: '20-REQUIREMENTS'
└─► totalDocuments: 25
    │
    └─► ProgressIndicatorWidget
        ├─ Progress bar: 8/25 = 32%
        ├─ Phase label: "20-REQUIREMENTS"
        └─ Pause button
```

---

## Widget Dependencies

```
file_tree_widget.dart
├─ imports: app_colors, mock_data, file_node
├─ depends on: MockProjectData.mockProjectRoot
└─ emits: ValueChanged<FileNode> callback

resizable_column.dart
├─ imports: material only
├─ generic: accepts any child widget
└─ emits: ValueChanged<double> on width change

project_shell_screen.dart
├─ imports: all widgets above + chat + preview
├─ state: _selectedNode, _fileContent, _showFilesPanel, _showMarkdownPanel
├─ state: _filesColumnWidth, _markdownColumnWidth
├─ callbacks: _onFileSelected, _buildFAB
└─ depends on: MockProjectData, FileTreeWidget, ResizableColumn

chat_panel_widget.dart
├─ imports: message_bubble, error_banner, proposal_card
├─ depends on: List<ChatMessageUI>
└─ emits: TextEditingController for messages

markdown_preview_widget.dart
├─ imports: material only
├─ depends on: content (String), filename (String)
└─ emits: toolbar button callbacks (copy, download)

progress_indicator_widget.dart
├─ imports: app_colors
├─ depends on: documentsCreated, currentPhase, totalDocuments
└─ animates: progress bar via AnimationController
```

---

## State Management Flow

```
ProjectShellScreen._ProjectShellScreenState
│
├─► initState()
│   └─ _selectedNode = MockProjectData.mockProjectRoot
│
├─► _onFileSelected(FileNode node)
│   ├─ setState(() {
│   │   _selectedNode = node
│   │   _fileContent = getContent(node)  // ← Updates preview
│   │ })
│   └─ Rebuilds MarkdownPreviewWidget automatically
│
├─► onWidthChanged for Files column
│   └─ setState(() => _filesColumnWidth = width)
│
├─► onWidthChanged for Preview column
│   └─ setState(() => _markdownColumnWidth = width)
│
├─► FAB: Toggle Files
│   └─ setState(() => _showFilesPanel = !_showFilesPanel)
│
└─► FAB: Toggle Preview
    └─ setState(() => _showMarkdownPanel = !_showMarkdownPanel)
```

---

## Resizable Column Interaction

```
ResizableColumn Widget
│
├─► Positioned Divider (right edge)
│   │
│   ├─ GestureDetector.onHorizontalDragUpdate
│   │   ├─ Calculate: newWidth = currentWidth + dragDelta
│   │   ├─ Clamp: min=200, max=500 (for Files) / 300-600 (for Preview)
│   │   ├─ setState(() => _currentWidth = clampedWidth)
│   │   └─ Callback: onWidthChanged(clampedWidth)
│   │
│   └─ Visual feedback
│       ├─ Color change on hover (gray → blue)
│       └─ Cursor change (resizeColumn)
│
└─► SizedBox(width: _currentWidth)
    └─ Child widget (FileTreeWidget or MarkdownPreviewWidget)
```

---

## Archivo Selection & Preview Update Sequence

```
1. User clicks file in FileTreeWidget
   │
   └─► FileTreeWidget.onTap()
       ├─ setState(() => _selectedNode = node)
       └─ widget.onFileSelected(node) ← callback
           │
           └─► ProjectShellScreen._onFileSelected(node)
               ├─ setState(() => _selectedNode = node)
               ├─ setState(() => _fileContent = mockMarkdownContent)
               │
               └─► Rebuild MarkdownPreviewWidget
                   ├─ content: _fileContent (updated)
                   └─ filename: _selectedNode.name (updated)

2. FileTreeWidget also updates visual state
   │
   └─ Tree item highlighted with color
   └─ Parent folders auto-expand (if needed)

3. Preview pane shows updated content
   │
   └─ File header: "PROJECT-ALPHA/10-CONTEXT/01-vision.md"
   └─ Content: Architecture document markdown
```

---

## Color Scheme (GitHub Dark)

```
AppColors mapping in project:

Main Background:    #0D1117  ← Scaffold bg
Surface Light:      #161B22  ← Panel headers & surfaces
Surface Hover:      #21262D  ← Borders & inactive elements
Text Main:          #C9D1D9  ← Primary text
Text Secondary:     #8B949E  ← Muted text
Border Color:       #30363D  ← Dividers

Progress Colors:
├─ ROOT:            #1B4965  (Dark Blue)
├─ CONTEXT:         #7B2D5E  (Purple)
├─ REQUIREMENTS:    #C05746  (Orange)
├─ ARCHITECTURE:    #566573  (Gray Blue)
└─ Success:         Green[500] (Progress bar fill)

Folder Blue:        #58A6FF  ← Folder icons
Primary Blue:       #0D0DF2  ← Selection highlights
```

---

## Performance Considerations

| Component | Optimization | Estado |
|-----------|--------------|--------|
| ArchivoTreeWidget | SingleChildScrollView | ✓ Lazy loads children |
| ChatPanelWidget | ListView.builder | ✓ Virtual scrolling |
| MarkdownPreviewWidget | SingleChildScrollView | ✓ Lazy loads markdown |
| ResizableColumn | Debouncing drag | ⏳ Future (if needed) |
| ProgressIndicatorWidget | AnimationController | ✓ Smooth animation |

---

**Architecture Version:** 2.0 (Clean, Modular)
**Validated:** flutter analyze --no-pub (0 errors)
**Date:** 8 February 2026
