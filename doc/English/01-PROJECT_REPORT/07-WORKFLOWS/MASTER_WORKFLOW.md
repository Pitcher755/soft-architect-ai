# 🎯 HU-3.3 SUPER-WORKFLOW: Interactive Workspace Complete

> **Branch:** `feature/chat-sequential-docs`
> **Estimation:** XXL (21 Story Points)
> **Methodology:** TDD (Test-Driven Development)
> **Status:** 🚀 READY TO IMPLEMENT

---

## 📋 Table of Contents

- [Vision](#vision)
- [Architecture Overview](#architecture-overview)
- [Implementation Phases](#implementation-phases)
- [Widget Mapping](#widget-mapping)
- [TDD Strategy](#tdd-strategy)
- [Verification Criteria](#verification-criteria)
- [Progress Tracking](#progress-tracking)

---

## 🎨 Vision

**Objective:** Build a complete VS Code-like workspace where users generate documents sequentially through an interactive chat, with real-time file system visualization and markdown preview.

**Components:**
1. **ProjectWorkspaceScreen** - The 3-column container
2. **FileSystemTreeWidget** - Left panel (file explorer)
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

## 🗺️ Implementation Phases

### **PHASE 1: Shell Container (The Foundation)**
**Goal:** Create the 3-column workspace layout with routing

#### 1.1 Tests (RED Phase)
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

#### 1.2 Implementation (GREEN Phase)
**File:** `lib/features/project_shell/presentation/screens/project_workspace_screen.dart`

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

#### 1.3 Verification Checklist
- [ ] Route `/workspace/:projectId` navigates to ProjectWorkspaceScreen
- [ ] 3 columns render with correct widths (250px, flex, 450px)
- [ ] AppBar shows progress indicator
- [ ] Progress updates when doc index changes
- [ ] Tests pass: `flutter test test/features/project_shell/`

---

### **PHASE 2: File System Tree (Left Panel)**
**Goal:** Display project directory structure with expand/collapse

#### 2.1 Tests (RED Phase)
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

#### 2.2 Implementation (GREEN Phase)
**File:** `lib/features/project_shell/presentation/widgets/file_system_tree_widget.dart`

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
**File:** `lib/features/project_shell/domain/entities/directory_node.dart`

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
**File:** `lib/features/project_shell/presentation/notifiers/file_system_notifier.dart`

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

#### 2.5 Verification Checklist
- [ ] Tree displays all folders from `context/`
- [ ] Clicking folder expands/collapses children
- [ ] Clicking file highlights it and triggers preview
- [ ] Scrollable when content overflows
- [ ] Icons match file types (folder, markdown)
- [ ] Tests pass: `flutter test test/features/project_shell/widgets/`

---

### **PHASE 3: Markdown Preview (Right Panel)**
**Goal:** Render selected markdown with GitHub Dark theme

#### 3.1 Tests (RED Phase)
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

#### 3.2 Implementation (GREEN Phase)
**File:** `lib/features/project_shell/presentation/widgets/markdown_preview_widget.dart`

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
**File:** `lib/features/project_shell/presentation/notifiers/markdown_preview_notifier.dart`

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

#### 3.4 Verification Checklist
- [ ] Shows "Select a file..." when no file selected
- [ ] Renders markdown with GitHub Dark theme
- [ ] Code blocks have syntax highlighting
- [ ] Headers, lists, links render correctly
- [ ] Scrollable when content overflows
- [ ] Tests pass: `flutter test test/features/project_shell/widgets/`

---

### **PHASE 4: Chat Components (Center Panel - Part 1)**
**Goal:** Implement basic chat UI widgets

#### 4.1 Tests (RED Phase)
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

#### 4.2 Implementation (GREEN Phase)

**Already implemented in previous session!** ✅

These widgets are complete:
- `MessageBubbleWidget` (99 lines)
- `StreamingIndicatorWidget` (168 lines)
- `ProposalCardWidget` (184 lines)

**Verification:**
- [ ] MessageBubbleWidget renders user/assistant messages
- [ ] StreamingIndicatorWidget animates progress
- [ ] ProposalCardWidget shows Validate/Refine/Reject buttons
- [ ] All widget tests passing (289/289 ✅)

---

### **PHASE 5: Sequential Chat Logic (Center Panel - Part 2)**
**Goal:** Orchestrate document generation flow

#### 5.1 Tests (RED Phase)
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

#### 5.2 Implementation (GREEN Phase)

**Already implemented in previous session!** ✅

File: `lib/features/chat/presentation/screens/chat_screen.dart` (190 lines)

**Verification:**
- [ ] Chat screen integrated into ProjectWorkspaceScreen
- [ ] Messages displayed in ListView
- [ ] Streaming indicator appears when isStreaming=true
- [ ] ProposalCard appears when currentProposal is set
- [ ] TextField and send button functional

---

### **PHASE 6: Integration & Wiring**
**Goal:** Connect all panels to work together

#### 6.1 Tests (RED Phase)
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

#### 6.2 Implementation (GREEN Phase)

**File:** Update `lib/features/chat/presentation/notifiers/chat_notifier.dart`

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

#### 6.3 Verification Checklist
- [ ] Validate button saves file to disk
- [ ] File tree updates automatically
- [ ] Preview shows newly created file
- [ ] Chat advances to next document
- [ ] Error handling displays user-friendly messages
- [ ] Tests pass: `flutter test test/features/integration/`

---

## 📊 Widget Mapping: Wireframes → Code

| Wireframe HTML | Flutter Widget | Status | Phase |
|----------------|----------------|--------|-------|
| `dashboard.html` | `ProjectSelectionScreen` | ✅ HU-3.1 | - |
| `create_project_modal.html` | `CreateProjectDialog` | ✅ HU-3.1 | - |
| `workspace.html` (Shell) | `ProjectWorkspaceScreen` | 🔄 Phase 1 | PHASE 1 |
| `workspace.html` (Sidebar) | `FileSystemTreeWidget` | 🔄 Phase 2 | PHASE 2 |
| `workspace.html` (Preview) | `MarkdownPreviewWidget` | 🔄 Phase 3 | PHASE 3 |
| `chat_components.html` (MessageBubble) | `MessageBubbleWidget` | ✅ Done | PHASE 4 |
| `chat_components.html` (Streaming) | `StreamingIndicatorWidget` | ✅ Done | PHASE 4 |
| `chat_components.html` (ProposalCard) | `ProposalCardWidget` | ✅ Done | PHASE 4 |
| `chat_components.html` (ErrorBanner) | `ErrorBannerWidget` | 🔄 Phase 5 | PHASE 5 |
| Chat orchestration | `SequentialChatScreen` | ✅ Done | PHASE 5 |

---

## 🧪 TDD Strategy

### Red-Green-Refactor Cycle

For each component:

#### 🔴 RED Phase (Write Failing Tests)
1. Write widget test for UI rendering
2. Write unit test for business logic
3. Write integration test for data flow
4. **Run tests:** `flutter test` → Should FAIL

#### 🟢 GREEN Phase (Minimal Implementation)
1. Implement widget/class to pass tests
2. Focus on functionality, not optimization
3. **Run tests:** `flutter test` → Should PASS

#### 🔵 REFACTOR Phase (Optimize)
1. Extract duplicated code
2. Improve naming and structure
3. Add documentation
4. **Run tests:** `flutter test` → Should still PASS

### Test Coverage Requirements

- **Widget Tests:** 100% for all UI components
- **Unit Tests:** >90% for business logic (Notifiers, Services)
- **Integration Tests:** Critical user flows
- **Total Coverage:** >80% minimum

### Running Tests

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

## ✅ Verification Criteria (Per Phase)

### Phase 1: Shell Container
- [ ] Navigation to `/workspace/:id` works
- [ ] 3 columns visible (250px | flex | 450px)
- [ ] AppBar shows progress (Doc X/25)
- [ ] Progress bar updates reactively
- [ ] Tests: 10/10 passing

### Phase 2: File System Tree
- [ ] Displays project folder structure
- [ ] Expand/collapse folders works
- [ ] File selection highlights item
- [ ] Scrollable overflow
- [ ] Icons differentiate folders/files
- [ ] Tests: 15/15 passing

### Phase 3: Markdown Preview
- [ ] Shows empty state when no file selected
- [ ] Renders markdown with GitHub Dark theme
- [ ] Code blocks have syntax highlighting
- [ ] Scrollable content
- [ ] Tests: 8/8 passing

### Phase 4: Chat Components
- [ ] MessageBubbleWidget renders correctly
- [ ] StreamingIndicatorWidget animates
- [ ] ProposalCardWidget has 3 buttons
- [ ] Error banner displays errors
- [ ] Tests: 20/20 passing (already done ✅)

### Phase 5: Sequential Chat Logic
- [ ] Initial prompt displays
- [ ] Send message calls API
- [ ] Streaming responses update UI
- [ ] ProposalCard appears with AI response
- [ ] Tests: 12/12 passing (already done ✅)

### Phase 6: Integration
- [ ] Validate saves file to disk
- [ ] File tree refreshes automatically
- [ ] Preview loads newly saved file
- [ ] Chat advances to next doc
- [ ] Error handling works end-to-end
- [ ] Tests: 25/25 passing

---

## 📈 Progress Tracking

### Overall Progress: 40% Complete

| Phase | Component | Status | Tests | Lines |
|-------|-----------|--------|-------|-------|
| 1 | ProjectWorkspaceScreen | 🔄 TODO | 0/10 | 0/150 |
| 2 | FileSystemTreeWidget | 🔄 TODO | 0/15 | 0/300 |
| 3 | MarkdownPreviewWidget | 🔄 TODO | 0/8 | 0/200 |
| 4 | Chat Widgets | ✅ DONE | 20/20 | 451/451 |
| 5 | SequentialChatScreen | ✅ DONE | 12/12 | 190/190 |
| 6 | Integration | 🔄 TODO | 0/25 | 0/200 |

**Total Tests:** 32/90 passing (35.6%)
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

1. ✅ All 6 phases completed
2. ✅ All tests passing (90/90)
3. ✅ Coverage >80%
4. ✅ Flutter analyze: 0 errors
5. ✅ Manual testing checklist completed
6. ✅ Documentation updated
7. ✅ Git history clean (professional commits)
8. ✅ Demo video recorded
9. ✅ PR approved and merged to develop

---

**Last Updated:** 06/02/2026
**Created By:** ArchitectZero Agent
**Branch:** `feature/chat-sequential-docs`
