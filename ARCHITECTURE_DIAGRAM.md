# 🏛️ Clean Architecture Diagram - SoftArchitect AI

> **Visualización de la nueva estructura después de reestructuración**

## Dependency Flow (Unidireccional)

```
User Interaction
    ↓
┌─────────────────────────────────────────────────────┐
│         PRESENTATION LAYER (Flutter Widgets)        │
├─────────────────────────────────────────────────────┤
│                                                      │
│  ┌────────────────────────────────────────────┐    │
│  │    SequentialChatScreen (chat/screens/)    │    │
│  │        4-Column IDE Layout                  │    │
│  │    ┌─────────┬────────┬───────┬───────┐   │    │
│  │    │ Sidebar │ Files  │ Chat  │Preview│   │    │
│  │    └─────────┴────────┴───────┴───────┘   │    │
│  └────────────────────────────────────────────┘    │
│         ↓              ↓            ↓               │
│    ┌────────────┐ ┌──────────┐ ┌──────────────┐   │
│    │FileTree    │ │ChatPanel │ │MarkdownPrev  │   │
│    │Widget      │ │Widget    │ │Widget        │   │
│    │(chat/w.)   │ │(chat/w.) │ │(chat/w.)     │   │
│    └────────────┘ └──────────┘ └──────────────┘   │
│         ↓              ↓             ↓              │
└─────────────────────────────────────────────────────┘
         ↓                        ↓
    ┌─────────────────────────────────────┐
    │   SHARED WIDGETS                    │
    │  (shared/presentation/widgets/)     │
    │  - ProjectsSidebar (64px navbar)    │
    └─────────────────────────────────────┘
         ↓                        ↓
┌──────────────────────────────────────────────┐
│   STATE MANAGEMENT LAYER (Riverpod)          │
├──────────────────────────────────────────────┤
│                                              │
│  ┌──────────────────┐  ┌──────────────────┐│
│  │chat_notifier     │  │file_system_notif ││
│  │(chat/notifiers/) │  │ier (filesystem/) ││
│  └──────────────────┘  └──────────────────┘│
│         ↓                     ↓              │
└──────────────────────────────────────────────┘
         ↓                        ↓
┌──────────────────────────────────────────────┐
│   DATA LAYER (Repository Pattern)            │
├──────────────────────────────────────────────┤
│  - FileRepository (filesystem/data/)         │
│  - ChatRepository (chat/data/)               │
│  - ProjectRepository (project_shell/data/)   │
└──────────────────────────────────────────────┘
         ↓                        ↓
┌──────────────────────────────────────────────┐
│   DOMAIN LAYER (Pure Dart - No Deps)         │
├──────────────────────────────────────────────┤
│  - File (entity)                             │
│  - ChatMessage (entity)                      │
│  - Project (entity)                          │
│  - FileRepository (abstract interface)       │
│  - ChatRepository (abstract interface)       │
└──────────────────────────────────────────────┘
         ↓                        ↓
┌──────────────────────────────────────────────┐
│   EXTERNAL SERVICES                          │
├──────────────────────────────────────────────┤
│  - File System (OS)                          │
│  - LLM Engine (Ollama/Groq)                  │
│  - Database (ChromaDB)                       │
└──────────────────────────────────────────────┘
```

---

## Feature Isolation

```
                 shared/
                 ├── presentation/
                 │   └── widgets/
                 │       └── projects_sidebar.dart
                 │
                 ↑ ↑ ↑ (Dependen de shared)
                 │ │ │
    ┌────────────┴─┴────────┬───────────────┬──────────────┐
    │                       │               │              │

   chat/                   filesystem/     project_shell/    settings/
   ├── domain/             ├── domain/     ├── domain/       ├── domain/
   ├── data/               ├── data/       ├── data/         ├── data/
   ├── presentation/       ├── presentation│presentation/    ├── presentation/
   │   ├── screens/        │   ├── notif.  │  ├── screens/   │   ├── screens/
   │   ├── widgets/        │   └── ...     │  ├── widgets/   │   ├── widgets/
   │   ├── notifiers/      │              │  └── ...        │   └── notifiers/
   │   └── ...             │              │                 │
   │                       │              │                 │
   └───────────────────────┴──────────────┴─────────────────┘
```

**Regla**: Ninguna feature referencia otra (excepto shared)

---

## Widget Hierarchy (SequentialChatScreen)

```
SequentialChatScreen (chat/presentation/screens/)
│
├── Column [main layout]
│   ├── _buildTopBar()
│   │   ├── Project info (name, path)
│   │   └── Toggle buttons (Files, Preview)
│   │
│   └── Expanded [main content]
│       └── Row [4-column layout]
│           ├── ProjectsSidebar (shared/presentation/widgets/)
│           │   ├── Logo
│           │   ├── Navigation buttons
│           │   └── Settings
│           │
│           ├── IF _showFilesPanel
│           │   └── _buildFilesPanel()
│           │       ├── Header (Files)
│           │       └── FileTreeWidget (chat/presentation/widgets/)
│           │           ├── DirectoryNode (recursive)
│           │           ├── FileNode (recursive)
│           │           └── Phase-colored icons
│           │
│           ├── Expanded
│           │   └── ChatPanelWidget (chat/presentation/widgets/)
│           │       ├── ErrorBannerWidget (if error)
│           │       ├── Messages list
│           │       │   └── MessageBubbleWidget (multiple)
│           │       ├── ProposalCardWidget (if proposal)
│           │       ├── ProgressIndicatorWidget (if streaming)
│           │       └── Input area
│           │           ├── TextField (3 lines)
│           │           └── Send button
│           │
│           └── IF _showMarkdownPanel
│               └── _buildPreviewPanel()
│                   └── MarkdownPreviewWidget (chat/presentation/widgets/)
│                       ├── File header
│                       └── Markdown content (formatted)
```

---

## State Management Flow

```
SequentialChatScreen (UI)
    ↓ (listens to notifiers via ConsumerStatefulWidget)

┌─────────────────────────────────────────┐
│ Riverpod Notifiers (StateNotifierProvider)
├─────────────────────────────────────────┤
│                                         │
│  chatNotifierProvider                   │
│  ├── State:                             │
│  │   ├── messages (List<ChatMessage>)   │
│  │   ├── currentProposal (Proposal?)    │
│  │   ├── isStreaming (bool)             │
│  │   ├── hasError (bool)                │
│  │   └── errorMessage (String?)         │
│  │                                      │
│  └── Methods:                           │
│      ├── sendMessage(text)              │
│      ├── acceptProposal()               │
│      ├── rejectProposal()               │
│      └── clearError()                   │
│                                         │
│  fileSystemNotifierProvider             │
│  ├── State:                             │
│  │   ├── expandedPaths (Set<String>)    │
│  │   ├── selectedFile (String?)         │
│  │   └── fileTree (DirectoryNode)       │
│  │                                      │
│  └── Methods:                           │
│      ├── toggleFolder(path)             │
│      └── selectFile(path)               │
│                                         │
│  markdownPreviewNotifierProvider        │
│  ├── State:                             │
│  │   └── content (String)               │
│  │                                      │
│  └── Methods:                           │
│      └── loadFile(path)                 │
│                                         │
└─────────────────────────────────────────┘
    ↓ (read/watch by presentation widgets)

Presentation Widgets
├── ChatPanelWidget (watches chatNotifier)
├── FileTreeWidget (watches fileSystemNotifier)
└── MarkdownPreviewWidget (watches markdownPreviewNotifier)
```

---

## Color System Hierarchy

```
Theme (GitHub Dark)
│
├── Core Colors
│   ├── mainBg: #0D1117
│   ├── surfaceBg: #161B22
│   ├── border: #30363D
│   ├── primary: #58A6FF
│   ├── textMain: #C9D1D9
│   ├── textSecondary: #8B949E
│   └── textMuted: #6E7681
│
└── Phase-Specific Colors (for directory icons)
    ├── dirRoot: #94E2D5 (Teal - 00-)
    ├── dirContext: #FCD34D (Yellow - 10-)
    ├── dirRequirements: #10B981 (Green - 20-)
    ├── dirArchitecture: #60A5FA (Blue - 30-)
    ├── dirUiUx: #EC4899 (Pink - 35-)
    ├── dirPlanning: #A855F7 (Purple - 40-)
    └── dirMeta: #FB923C (Orange - 99-)

Applied with opacity:
├── Background: 0.1 (10%)
├── Border: 0.4 (40%)
└── Accent: 0.6 (60%)
```

---

## Import Rules (Dependency Direction)

```
✅ ALLOWED:
- chat/ → shared/
- filesystem/ → shared/
- project_shell/ → shared/
- settings/ → shared/
- shared/ → core/
- all features → core/

❌ FORBIDDEN:
- shared/ → feature/ (would be circular)
- feature_a/ → feature_b/
- core/ → features/
- circular imports anywhere
```

---

## Refactoring Impact Summary

```
┌──────────────────────────────────────────────────────┐
│ BEFORE REFACTORING (Problematic)                     │
├──────────────────────────────────────────────────────┤
│ • ProjectsSidebar en project_shell/ (INCORRECTO)     │
│ • Chat widgets en project_shell/ (Violación)        │
│ • Markdown preview en project_shell/                 │
│ • 2 redundantes tree widgets                         │
│ • Archivos enormes (1256 líneas)                     │
│ • Sin documentación de arquitectura                  │
└──────────────────────────────────────────────────────┘
           ↓ REFACTORING
┌──────────────────────────────────────────────────────┐
│ AFTER REFACTORING (Clean)                            │
├──────────────────────────────────────────────────────┤
│ ✅ ProjectsSidebar en shared/ (CORRECTO)             │
│ ✅ Chat widgets en chat/ (Correcto)                 │
│ ✅ Markdown preview en chat/                         │
│ ✅ 1 tree widget (FileTreeWidget - producción)       │
│ ✅ Archivos compactos (<600 líneas)                  │
│ ✅ Documentación exhaustiva                          │
│ ✅ Clean Architecture patterns applied               │
│ ✅ Sin code smells                                   │
│ ✅ Escalable y mantenible                            │
└──────────────────────────────────────────────────────┘
```

---

**Documento generado:** 2026-02-08
**Propósito:** Referencia visual de la arquitectura refactorizada
**Audience:** Equipo de desarrollo, code reviewers
