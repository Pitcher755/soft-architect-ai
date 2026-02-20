# 🎯 HU-3.3 SUPER-WORKFLOW: Interactive Workspace Complete

> **Branch:** `feature/chat-sequential-docs`
> **Estimation:** XXL (21 Story Points)
> **Methodology:** TDD (Prueba-Driven Development)
> **Estado:** 🚀 READY TO IMPLEMENT

---

## 📋 Table of Contents

- [Vision](#vision)
- [Architecture Overview](#architecture-overview)
- [Implementación Fases](#implementación-fases)
- [Widget Mapping](#widget-mapping)
- [TDD Strategy](#tdd-strategy)
- [Verificación Criteria](#verificación-criteria)
- [Progress Tracking](#progress-tracking)

---

## 🎨 Vision

**Objective:** Build a complete VS Code-like workspace where users generate documentos sequentially through an interactive chat, with real-time archivo system visualization and markdown preview.

**Components:**
1. **ProyectoWorkspaceScreen** - The 3-column container
2. **ArchivoSystemTreeWidget** - Left panel (archivo explorer)
3. **SequentialChatScreen** - Center panel (chat + proposals)
4. **MarkdownPreviewWidget** - Right panel (live preview)

---

## 🏗️ Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                    ProjectWorkspaceScreen                        │
│  ┌──────────────┬──────────────────────┬──────────────────┐    │
│  │              │                      │                  │    │
│  │  FileSystem  │  SequentialChat      │  Markdown        │    │
│  │  TreeWidget  │  Screen              │  PreviewWidget   │    │
│  │              │                      │                  │    │
│  │  (Left)      │  (Center)            │  (Right)         │    │
│  │  250px       │  Flex-1              │  450px           │    │
│  │              │                      │                  │    │
│  └──────────────┴──────────────────────┴──────────────────┘    │
└─────────────────────────────────────────────────────────────────┘
```

### State Management Flow

```
ChatNotifier (StateNotifier)
  ↓
ChatState (Immutable)
  ├─ messages: List<ChatMessage>
  ├─ currentProposal: Proposal?
  ├─ currentDocIndex: int
  ├─ totalDocs: int
  └─ isStreaming: bool

FileSystemNotifier (StateNotifier)
  ↓
FileSystemState (Immutable)
  ├─ rootPath: String
  ├─ tree: DirectoryNode
  ├─ selectedFile: String?
  └─ expandedPaths: Set<String>
```

---

## 🗺️ Implementación Fases

### **FASE 1: Shell Container (The Fundación)**
**Goal:** Crear the 3-column workspace layout with routing

#### 1.1 Pruebas (RED Fase)
```dart
// test/features/project_shell/presentation/screens/project_workspace_screen_test.dart

testWidgets('ProjectWorkspaceScreen renders 3-column layout', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(home: ProjectWorkspaceScreen(projectPath: '/test')),
    ),
  );

  expect(find.byType(FileSystemTreeWidget), findsOneWidget);
  expect(find.byType(SequentialChatScreen), findsOneWidget);
  expect(find.byType(MarkdownPreviewWidget), findsOneWidget);
});

testWidgets('AppBar shows project progress (Doc X/25)', (tester) async {
  await tester.pumpWidget(/* ... */);

  expect(find.text('Doc 1/25'), findsOneWidget);
  expect(find.byType(LinearProgressIndicator), findsOneWidget);
});
```

#### 1.2 Implementación (GREEN Fase)
**Archivo:** `lib/features/proyecto_shell/presentation/screens/proyecto_workspace_screen.dart`

```dart
class ProjectWorkspaceScreen extends ConsumerWidget {
  final String projectPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatState = ref.watch(chatNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text('SoftArchitect AI'),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Doc ${chatState.currentDocIndex}/${chatState.totalDocs}'),
                      Text('Phase: ${_getPhase(chatState.currentDocIndex)}'),
                    ],
                  ),
                  LinearProgressIndicator(
                    value: chatState.currentDocIndex / chatState.totalDocs,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Row(
        children: [
          // Left: File Explorer (250px fixed)
          Container(
            width: 250,
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: AppColors.border)),
            ),
            child: FileSystemTreeWidget(rootPath: projectPath),
          ),

          // Center: Chat (flex)
          Expanded(
            child: SequentialChatScreen(projectPath: projectPath),
          ),

          // Right: Preview (450px fixed)
          Container(
            width: 450,
            decoration: BoxDecoration(
              border: Border(left: BorderSide(color: AppColors.border)),
            ),
            child: MarkdownPreviewWidget(),
          ),
        ],
      ),
    );
  }
}
```

#### 1.3 Verificación Checklist
- [ ] Route `/workspace/:proyectoId` navigates to ProyectoWorkspaceScreen
- [ ] 3 columns render with correct widths (250px, flex, 450px)
- [ ] AppBar shows progress indicator
- [ ] Progress updates when doc index changes
- [ ] Pruebas pass: `flutter prueba prueba/features/proyecto_shell/`

---

### **FASE 2: Archivo System Tree (Left Panel)**
**Goal:** Display proyecto directory structure with expand/collapse

#### 2.1 Pruebas (RED Fase)
```dart
// test/features/project_shell/presentation/widgets/file_system_tree_widget_test.dart

testWidgets('FileSystemTreeWidget displays directory structure', (tester) async {
  final mockService = MockFileSystemService();
  when(mockService.getDirectoryTree('/test'))
    .thenAnswer((_) async => DirectoryNode(/* ... */));

  await tester.pumpWidget(/* ... */);

  expect(find.text('10-CONTEXT'), findsOneWidget);
  expect(find.text('20-REQUIREMENTS'), findsOneWidget);
});

testWidgets('Clicking folder toggles expansion', (tester) async {
  await tester.pumpWidget(/* ... */);

  await tester.tap(find.text('10-CONTEXT'));
  await tester.pumpAndSettle();

  expect(find.text('VISION.md'), findsOneWidget);
});

testWidgets('Clicking file updates selected state', (tester) async {
  await tester.pumpWidget(/* ... */);

  await tester.tap(find.text('VISION.md'));

  verify(mockNotifier.selectFile('/test/10-CONTEXT/VISION.md')).called(1);
});
```

#### 2.2 Implementación (GREEN Fase)
**Archivo:** `lib/features/proyecto_shell/presentation/widgets/archivo_system_tree_widget.dart`

```dart
class FileSystemTreeWidget extends ConsumerWidget {
  final String rootPath;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fileSystemState = ref.watch(fileSystemNotifierProvider);

    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Icon(Icons.folder_outlined, size: 16),
              SizedBox(width: 8),
              Text('FILES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ),

        // Tree
        Expanded(
          child: fileSystemState.when(
            data: (tree) => SingleChildScrollView(
              child: _DirectoryTreeView(
                node: tree,
                depth: 0,
                expandedPaths: fileSystemState.expandedPaths,
                selectedPath: fileSystemState.selectedFile,
                onTap: (path) => ref.read(fileSystemNotifierProvider.notifier).selectFile(path),
                onToggle: (path) => ref.read(fileSystemNotifierProvider.notifier).toggleExpanded(path),
              ),
            ),
            loading: () => Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error: $err')),
          ),
        ),
      ],
    );
  }
}

class _DirectoryTreeView extends StatelessWidget {
  final DirectoryNode node;
  final int depth;
  final Set<String> expandedPaths;
  final String? selectedPath;
  final Function(String) onTap;
  final Function(String) onToggle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => node.isDirectory ? onToggle(node.path) : onTap(node.path),
          child: Container(
            padding: EdgeInsets.only(left: depth * 16.0 + 8, top: 4, bottom: 4),
            color: selectedPath == node.path ? AppColors.primary.withOpacity(0.1) : null,
            child: Row(
              children: [
                if (node.isDirectory)
                  Icon(
                    expandedPaths.contains(node.path) ? Icons.folder_open : Icons.folder,
                    size: 16,
                    color: AppColors.folderIcon,
                  )
                else
                  Icon(Icons.description, size: 16, color: AppColors.fileIcon),
                SizedBox(width: 8),
                Text(node.name, style: TextStyle(fontSize: 13)),
              ],
            ),
          ),
        ),

        if (node.isDirectory && expandedPaths.contains(node.path))
          ...node.children.map((child) => _DirectoryTreeView(
            node: child,
            depth: depth + 1,
            expandedPaths: expandedPaths,
            selectedPath: selectedPath,
            onTap: onTap,
            onToggle: onToggle,
          )),
      ],
    );
  }
}
```

#### 2.3 Domain Models
**Archivo:** `lib/features/proyecto_shell/domain/entities/directory_node.dart`

```dart
class DirectoryNode {
  final String name;
  final String path;
  final bool isDirectory;
  final List<DirectoryNode> children;

  DirectoryNode({
    required this.name,
    required this.path,
    required this.isDirectory,
    this.children = const [],
  });
}
```

#### 2.4 State Management
**Archivo:** `lib/features/proyecto_shell/presentation/notifiers/archivo_system_notifier.dart`

```dart
@riverpod
class FileSystemNotifier extends _$FileSystemNotifier {
  @override
  Future<FileSystemState> build(String rootPath) async {
    final service = ref.read(fileSystemServiceProvider);
    final tree = await service.getDirectoryTree(rootPath);

    return FileSystemState(
      rootPath: rootPath,
      tree: tree,
      expandedPaths: {rootPath},
      selectedFile: null,
    );
  }

  void toggleExpanded(String path) {
    state = state.whenData((current) {
      final newExpanded = Set<String>.from(current.expandedPaths);
      if (newExpanded.contains(path)) {
        newExpanded.remove(path);
      } else {
        newExpanded.add(path);
      }
      return current.copyWith(expandedPaths: newExpanded);
    });
  }

  void selectFile(String path) {
    state = state.whenData((current) => current.copyWith(selectedFile: path));

    // Trigger preview update
    ref.read(markdownPreviewNotifierProvider.notifier).loadFile(path);
  }
}

@freezed
class FileSystemState with _$FileSystemState {
  const factory FileSystemState({
    required String rootPath,
    required DirectoryNode tree,
    required Set<String> expandedPaths,
    String? selectedFile,
  }) = _FileSystemState;
}
```

#### 2.5 Verificación Checklist
- [ ] Tree displays all carpetas from `context/`
- [ ] Clicking carpeta expands/collapses children
- [ ] Clicking archivo highlights it and triggers preview
- [ ] Scrollable when content overflows
- [ ] Icons match archivo types (carpeta, markdown)
- [ ] Pruebas pass: `flutter prueba prueba/features/proyecto_shell/widgets/`

---

### **FASE 3: Markdown Preview (Right Panel)**
**Goal:** Render selected markdown with GitHub Dark theme

#### 3.1 Pruebas (RED Fase)
```dart
// test/features/project_shell/presentation/widgets/markdown_preview_widget_test.dart

testWidgets('MarkdownPreviewWidget shows empty state by default', (tester) async {
  await tester.pumpWidget(/* ... */);

  expect(find.text('Select a file to preview'), findsOneWidget);
  expect(find.byType(Markdown), findsNothing);
});

testWidgets('MarkdownPreviewWidget renders markdown content', (tester) async {
  final mockNotifier = MockMarkdownPreviewNotifier();
  when(mockNotifier.stream).thenAnswer((_) => Stream.value(
    AsyncData(MarkdownPreviewState(content: '# Hello'))
  ));

  await tester.pumpWidget(/* ... */);
  await tester.pumpAndSettle();

  expect(find.text('Hello'), findsOneWidget);
});
```

#### 3.2 Implementación (GREEN Fase)
**Archivo:** `lib/features/proyecto_shell/presentation/widgets/markdown_preview_widget.dart`

```dart
class MarkdownPreviewWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final previewState = ref.watch(markdownPreviewNotifierProvider);

    return Column(
      children: [
        // Header
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border)),
          ),
          child: Row(
            children: [
              Icon(Icons.visibility_outlined, size: 16),
              SizedBox(width: 8),
              Text('PREVIEW', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            ],
          ),
        ),

        // Content
        Expanded(
          child: previewState.when(
            data: (state) {
              if (state.content == null) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.description_outlined, size: 48, color: Colors.grey),
                      SizedBox(height: 16),
                      Text('Select a file to preview', style: TextStyle(color: Colors.grey)),
                    ],
                  ),
                );
              }

              return Markdown(
                data: state.content!,
                styleSheet: MarkdownStyleSheet.fromTheme(
                  ThemeData.dark(),
                ).copyWith(
                  h1: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white),
                  h2: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
                  p: TextStyle(fontSize: 14, color: Colors.white70, height: 1.6),
                  code: TextStyle(
                    fontFamily: 'FiraCode',
                    backgroundColor: AppColors.codeBg,
                    color: AppColors.codeText,
                  ),
                ),
              );
            },
            loading: () => Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error loading file: $err')),
          ),
        ),
      ],
    );
  }
}
```

#### 3.3 State Management
**Archivo:** `lib/features/proyecto_shell/presentation/notifiers/markdown_preview_notifier.dart`

```dart
@riverpod
class MarkdownPreviewNotifier extends _$MarkdownPreviewNotifier {
  @override
  FutureOr<MarkdownPreviewState> build() {
    return MarkdownPreviewState(content: null, filePath: null);
  }

  Future<void> loadFile(String path) async {
    state = const AsyncValue.loading();

    try {
      final file = File(path);
      final content = await file.readAsString();

      state = AsyncValue.data(MarkdownPreviewState(
        content: content,
        filePath: path,
      ));
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

@freezed
class MarkdownPreviewState with _$MarkdownPreviewState {
  const factory MarkdownPreviewState({
    String? content,
    String? filePath,
  }) = _MarkdownPreviewState;
}
```

#### 3.4 Verificación Checklist
- [ ] Shows "Select a archivo..." when no archivo selected
- [ ] Renders markdown with GitHub Dark theme
- [ ] Code blocks have syntax highlighting
- [ ] Headers, lists, links render correctly
- [ ] Scrollable when content overflows
- [ ] Pruebas pass: `flutter prueba prueba/features/proyecto_shell/widgets/`

---

### **FASE 4: Chat Components (Center Panel - Part 1)**
**Goal:** Implement basic chat UI widgets

#### 4.1 Pruebas (RED Fase)
```dart
// test/features/chat/presentation/widgets/message_bubble_widget_test.dart

testWidgets('MessageBubbleWidget displays user message correctly', (tester) async {
  final message = ChatMessageUI(
    id: '1',
    role: 'user',
    content: 'Hello',
    timestamp: DateTime.now(),
  );

  await tester.pumpWidget(MaterialApp(home: MessageBubbleWidget(message: message)));

  expect(find.text('Hello'), findsOneWidget);
  expect(find.byIcon(Icons.person), findsOneWidget);
});

// test/features/chat/presentation/widgets/streaming_indicator_widget_test.dart

testWidgets('StreamingIndicatorWidget shows progress animation', (tester) async {
  await tester.pumpWidget(MaterialApp(
    home: StreamingIndicatorWidget(
      progress: 0.5,
      documentIndex: 1,
      totalDocuments: 3,
    ),
  ));

  expect(find.text('Doc 1/3'), findsOneWidget);
  expect(find.text('50%'), findsOneWidget);
  expect(find.byType(LinearProgressIndicator), findsOneWidget);
});
```

#### 4.2 Implementación (GREEN Fase)

**Already implemented in anterior session!** ✅

These widgets are complete:
- `MessageBubbleWidget` (99 lines)
- `StreamingIndicatorWidget` (168 lines)
- `ProposalCardWidget` (184 lines)

**Verificación:**
- [ ] MessageBubbleWidget renders user/assistant messages
- [ ] StreamingIndicatorWidget animates progress
- [ ] ProposalCardWidget shows Validate/Refine/Reject botóns
- [ ] All widget pruebas passing (289/289 ✅)

---

### **FASE 5: Sequential Chat Logic (Center Panel - Part 2)**
**Goal:** Orchestrate documento generation flow

#### 5.1 Pruebas (RED Fase)
```dart
// test/features/chat/presentation/screens/sequential_chat_screen_test.dart

testWidgets('SequentialChatScreen displays initial prompt', (tester) async {
  await tester.pumpWidget(/* ... */);

  expect(find.textContaining('Let\'s start with Document 1'), findsOneWidget);
  expect(find.byType(TextField), findsOneWidget);
  expect(find.byType(FloatingActionButton), findsOneWidget);
});

testWidgets('Sending message triggers chat API', (tester) async {
  final mockNotifier = MockChatNotifier();

  await tester.pumpWidget(/* ... */);
  await tester.enterText(find.byType(TextField), 'My project is about...');
  await tester.tap(find.byType(FloatingActionButton));

  verify(mockNotifier.sendMessage('My project is about...')).called(1);
});

testWidgets('ProposalCard appears when AI generates document', (tester) async {
  final mockNotifier = MockChatNotifier();
  when(mockNotifier.stream).thenAnswer((_) => Stream.value(
    ChatState(
      messages: [],
      currentProposal: Proposal(/* ... */),
      isStreaming: false,
    )
  ));

  await tester.pumpWidget(/* ... */);
  await tester.pumpAndSettle();

  expect(find.byType(ProposalCardWidget), findsOneWidget);
});
```

#### 5.2 Implementación (GREEN Fase)

**Already implemented in anterior session!** ✅

Archivo: `lib/features/chat/presentation/screens/chat_screen.dart` (190 lines)

**Verificación:**
- [ ] Chat screen integrated into ProyectoWorkspaceScreen
- [ ] Messages displayed in ListView
- [ ] Streaming indicator appears when isStreaming=true
- [ ] ProposalCard appears when currentProposal is set
- [ ] TextField and send botón functional

---

### **FASE 6: Integración & Wiring**
**Goal:** Connect all panels to work together

#### 6.1 Pruebas (RED Fase)
```dart
// test/features/integration/workspace_integration_test.dart

testWidgets('Clicking Validate saves file and updates tree', (tester) async {
  final mockFileSystem = MockFileSystemService();
  final mockChatNotifier = MockChatNotifier();

  await tester.pumpWidget(/* full app */);

  // Generate proposal
  when(mockChatNotifier.currentProposal).thenReturn(
    Proposal(content: '# Vision\n\nMy vision...', fileName: 'VISION.md')
  );
  await tester.pumpAndSettle();

  // Click Validate
  await tester.tap(find.text('Validate'));
  await tester.pumpAndSettle();

  // Verify file saved
  verify(mockFileSystem.saveDocument(
    path: '/test/10-CONTEXT/VISION.md',
    content: '# Vision\n\nMy vision...',
  )).called(1);

  // Verify tree updated
  expect(find.text('VISION.md'), findsOneWidget);
});

testWidgets('Selecting file in tree updates preview', (tester) async {
  await tester.pumpWidget(/* ... */);

  await tester.tap(find.text('VISION.md'));
  await tester.pumpAndSettle();

  expect(find.textContaining('My vision...'), findsOneWidget);
});
```

#### 6.2 Implementación (GREEN Fase)

**Archivo:** Update `lib/features/chat/presentation/notifiers/chat_notifier.dart`

Add validation logic:
```dart
Future<void> validateProposal() async {
  final currentState = state;
  if (currentState.currentProposal == null) return;

  try {
    // 1. Save to disk
    final filePath = '${_projectPath}/${currentState.currentProposal!.relativePath}';
    await ref.read(fileSystemServiceProvider).saveDocument(
      path: filePath,
      content: currentState.currentProposal!.content,
    );

    // 2. Update file tree
    ref.read(fileSystemNotifierProvider(_projectPath).notifier).refresh();

    // 3. Move to next document
    state = currentState.copyWith(
      currentProposal: null,
      currentDocIndex: currentState.currentDocIndex + 1,
      messages: [
        ...currentState.messages,
        ChatMessage(
          role: MessageRole.system,
          content: '✅ Document saved! Let\'s continue with Doc ${currentState.currentDocIndex + 1}.',
        ),
      ],
    );

    // 4. Trigger next prompt
    await _sendNextPrompt();
  } catch (e) {
    state = currentState.copyWith(
      error: 'Failed to save document: $e',
    );
  }
}
```

#### 6.3 Verificación Checklist
- [ ] Validate botón saves archivo to disk
- [ ] Archivo tree updates automatically
- [ ] Preview shows newly creard archivo
- [ ] Chat advances to siguiente documento
- [ ] Error handling displays user-friendly messages
- [ ] Pruebas pass: `flutter prueba prueba/features/integration/`

---

## 📊 Widget Mapping: Wireframes → Code

| Wireframe HTML | Flutter Widget | Estado | Fase |
|----------------|----------------|--------|-------|
| `dashboard.html` | `ProyectoSelectionScreen` | ✅ HU-3.1 | - |
| `crear_proyecto_modal.html` | `CrearProyectoDialog` | ✅ HU-3.1 | - |
| `workspace.html` (Shell) | `ProyectoWorkspaceScreen` | 🔄 Fase 1 | PHASE 1 |
| `workspace.html` (Sidebar) | `ArchivoSystemTreeWidget` | 🔄 Fase 2 | PHASE 2 |
| `workspace.html` (Preview) | `MarkdownPreviewWidget` | 🔄 Fase 3 | PHASE 3 |
| `chat_components.html` (MessageBubble) | `MessageBubbleWidget` | ✅ Done | PHASE 4 |
| `chat_components.html` (Streaming) | `StreamingIndicatorWidget` | ✅ Done | PHASE 4 |
| `chat_components.html` (ProposalCard) | `ProposalCardWidget` | ✅ Done | PHASE 4 |
| `chat_components.html` (ErrorBanner) | `ErrorBannerWidget` | 🔄 Fase 5 | PHASE 5 |
| Chat orchestration | `SequentialChatScreen` | ✅ Done | PHASE 5 |

---

## 🧪 TDD Strategy

### Red-Green-Refactor Cycle

For each component:

#### 🔴 RED Fase (Write Failing Pruebas)
1. Write widget prueba for UI rendering
2. Write unit prueba for business logic
3. Write integration prueba for data flow
4. **Ejecutar pruebas:** `flutter prueba` → Should FAIL

#### 🟢 GREEN Fase (Minimal Implementación)
1. Implement widget/class to pass pruebas
2. Focus on functionality, not optimization
3. **Ejecutar pruebas:** `flutter prueba` → Should PASS

#### 🔵 REFACTOR Fase (Optimize)
1. Extract duplicated code
2. Improve naming and structure
3. Add documentoation
4. **Ejecutar pruebas:** `flutter prueba` → Should still PASS

### Prueba Coverage Requirements

- **Widget Pruebas:** 100% for all UI components
- **Unit Pruebas:** >90% for business logic (Notifiers, Services)
- **Integración Pruebas:** Critical user flows
- **Total Coverage:** >80% minimum

### Ejecutarning Pruebas

```bash
# All tests
flutter test

# Specific phase
flutter test test/features/project_shell/

# With coverage
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

---

## ✅ Verificación Criteria (Per Fase)

### Fase 1: Shell Container
- [ ] Navigation to `/workspace/:id` works
- [ ] 3 columns visible (250px | flex | 450px)
- [ ] AppBar shows progress (Doc X/25)
- [ ] Progress bar updates reactively
- [ ] Pruebas: 10/10 passing

### Fase 2: Archivo System Tree
- [ ] Displays proyecto carpeta structure
- [ ] Expand/collapse carpetas works
- [ ] Archivo selection highlights item
- [ ] Scrollable overflow
- [ ] Icons differentiate carpetas/archivos
- [ ] Pruebas: 15/15 passing

### Fase 3: Markdown Preview
- [ ] Shows empty state when no archivo selected
- [ ] Renders markdown with GitHub Dark theme
- [ ] Code blocks have syntax highlighting
- [ ] Scrollable content
- [ ] Pruebas: 8/8 passing

### Fase 4: Chat Components
- [ ] MessageBubbleWidget renders correctly
- [ ] StreamingIndicatorWidget animates
- [ ] ProposalCardWidget has 3 botóns
- [ ] Error banner displays errors
- [ ] Pruebas: 20/20 passing (already done ✅)

### Fase 5: Sequential Chat Logic
- [ ] Initial prompt displays
- [ ] Send message calls API
- [ ] Streaming responses update UI
- [ ] ProposalCard appears with AI response
- [ ] Pruebas: 12/12 passing (already done ✅)

### Fase 6: Integración
- [ ] Validate saves archivo to disk
- [ ] Archivo tree refreshes automatically
- [ ] Preview loads newly saved archivo
- [ ] Chat advances to siguiente doc
- [ ] Error handling works end-to-end
- [ ] Pruebas: 25/25 passing

---

## 📈 Progress Tracking

### Overall Progress: 40% Complete

| Fase | Component | Estado | Pruebas | Lines |
|-------|-----------|--------|-------|-------|
| 1 | ProyectoWorkspaceScreen | 🔄 TODO | 0/10 | 0/150 |
| 2 | ArchivoSystemTreeWidget | 🔄 TODO | 0/15 | 0/300 |
| 3 | MarkdownPreviewWidget | 🔄 TODO | 0/8 | 0/200 |
| 4 | Chat Widgets | ✅ DONE | 20/20 | 451/451 |
| 5 | SequentialChatScreen | ✅ DONE | 12/12 | 190/190 |
| 6 | Integración | 🔄 TODO | 0/25 | 0/200 |

**Total Pruebas:** 32/90 passing (35.6%)
**Total Lines:** 641/1,491 (43.0%)

---

## 🚀 Execution Order

Follow this strict sequence:

```
START
  ↓
Phase 1: Shell (2 days)
  ↓
Phase 2: File Tree (3 days)
  ↓
Phase 3: Preview (2 days)
  ↓
Phase 4: Skip (Already done ✅)
  ↓
Phase 5: Skip (Already done ✅)
  ↓
Phase 6: Integration (4 days)
  ↓
COMPLETE ✅
```

**Estimated Total:** 11 working days (2.2 weeks)

---

## 📚 References

- [Clean Architecture Guide](../../../context/30-ARCHITECTURE/CLEAN_ARCHITECTURE_GUIDE.md)
- [API Contract](../../../context/30-ARCHITECTURE/API_INTERFACE_CONTRACT.md)
- [Error Handling Standard](../../../context/30-ARCHITECTURE/ERROR_HANDLING_STANDARD.md)
- [Widget Wireframes](../../../context/40-ROADMAP/mapa_widgets.md)
- [User Stories Master](../../../context/40-ROADMAP/USER_STORIES_MASTER.es.json)

---

## 🎯 Definition of Done

The HU-3.3 is considered DONE when:

1. ✅ All 6 fases completed
2. ✅ All pruebas passing (90/90)
3. ✅ Coverage >80%
4. ✅ Flutter analyze: 0 errors
5. ✅ Manual pruebaing checklist completed
6. ✅ Documentoation updated
7. ✅ Git history clean (professional commits)
8. ✅ Demo video recorded
9. ✅ PR approved and merged to develop

---

**Last Updated:** 06/02/2026
**Creard By:** ArchitectZero Agent
**Branch:** `feature/chat-sequential-docs`
