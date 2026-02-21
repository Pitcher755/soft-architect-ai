# 📦 Mock Data Architecture - Escalability Guide

> **Propósito:** Explicar cómo los datos mock son escalables hacia datos reales sin cambiar los widgets

---

## 🎯 Principio Fundamental

**Separación entre Data Source y UI Rendering**

Los widgets NO conocen la procedencia de los datos. Solo consumen la estructura de datos. Esto permite cambiar de mock a backend sin tocar un solo widget.

---

## 📊 Flujo Actual (Mock)

```
MockProjectData (hardcoded)
        ↓
    ✅ Widgets consume los datos
        ↓
    ✅ UI renderiza exactamente igual
```

## 📊 Flujo Futuro (Backend)

```
API / Repository
        ↓
    ✅ Widgets consume los mismos datos
        ↓
    ✅ UI renderiza exactamente igual
```

**Los widgets no cambian en absoluto.**

---

## 🔄 Patrón de Migración

### Paso 0: Status Actual (Mock)

```dart
// En project_shell_screen.dart
_selectedNode = MockProjectData.mockProjectRoot;
ChatPanelWidget(messages: MockProjectData.mockChatMessages)
```

### Paso 1: Create Notifier (Riverpod)

```dart
// lib/features/project_shell/application/notifiers/project_notifier.dart

class ProjectNotifier extends StateNotifier<ProjectState> {
  ProjectNotifier(this._repository) : super(const ProjectState.loading());

  final ProjectRepository _repository;

  Future<void> loadProject(String projectPath) async {
    try {
      final fileTree = await _repository.getFileTree(projectPath);
      final messages = await _repository.getChatMessages(projectPath);

      state = ProjectState.loaded(
        fileTree: fileTree,
        chatMessages: messages,
      );
    } catch (e) {
      state = ProjectState.error(e.toString());
    }
  }
}

final projectProvider = StateNotifierProvider<ProjectNotifier, ProjectState>(
  (ref) => ProjectNotifier(ProjectRepository()),
);
```

### Paso 2: Usar en Widget (NO cambiar)

```dart
// En project_shell_screen.dart - EXACTAMENTE IGUAL

// @override
// void initState() {
//   super.initState();
//   ref.read(projectProvider.notifier).loadProject(widget.projectPath);
// }

// @override
// Widget build(BuildContext context) {
//   final projectState = ref.watch(projectProvider);

//   return projectState.when(
//     loading: () => LoadingScreen(),
//     loaded: (fileTree, chatMessages) => Scaffold(
//       body: Row(
//         children: [
//           _buildFileTree(fileTree),  // ✅ MISMO CÓDIGO
//           ChatPanelWidget(messages: chatMessages),  // ✅ MISMO CÓDIGO
//         ],
//       ),
//     ),
//     error: (msg) => ErrorScreen(msg),
//   );
// }
```

---

## 📋 Estructuras de Datos que NO Cambian

### 1. **FileNode**
```dart
class FileNode {
  final String id;
  final String name;
  final String path;
  final bool isDirectory;
  final List<FileNode> children;  // Mismo para mock y backend
}
```

**Backend devuelve exactamente esta estructura** (API endpoint, DTOs, mapping, etc.)

### 2. **ChatMessageUI**
```dart
class ChatMessageUI {
  final String id;
  final String role;
  final String content;
  final DateTime timestamp;
}
```

**Backend devuelve exactamente esta estructura**

### 3. **Progress Data**
```dart
class ProgressData {
  final int documentsCreated;
  final String currentPhase;
  final int totalDocuments;
}
```

---

## 🔗 Ejemplo Real: Flujo Completo

### Mock: project_shell_screen.dart (HOY)
```dart
class _ProjectShellScreenState extends ConsumerState<ProjectShellScreen> {
  late FileNode _selectedNode;

  @override
  void initState() {
    super.initState();
    _selectedNode = MockProjectData.mockProjectRoot;  // ← MOCK
  }

  @override
  Widget build(BuildContext context) {
    return ChatPanelWidget(
      messages: MockProjectData.mockChatMessages,  // ← MOCK
    );
  }
}
```

### Backend: project_shell_screen.dart (FUTURO)
```dart
class _ProjectShellScreenState extends ConsumerState<ProjectShellScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar del backend (notifier)
    Future.microtask(() {
      ref.read(projectProvider.notifier).loadProject(widget.projectPath);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(projectProvider);

    return state.when(
      loaded: (fileTree, messages) => ChatPanelWidget(
        messages: messages,  // ← DEL BACKEND, MISMO TIPO
      ),
    );
  }
}
```

**NOTA: ChatPanelWidget NO CAMBIÓ. Solo cambió la fuente de datos.**

---

## 🏗️ Arquitectura de Capas

```
┌─────────────────────────────────────────┐
│    Presentation Layer (Widgets)         │
│  - project_shell_screen.dart            │
│  - chat_panel_widget.dart               │
│  - markdown_preview_widget.dart         │
│  (NO CAMBIAN con backend)               │
└────────────┬────────────────────────────┘
             ↑
             │ Consume datos
             │
┌────────────┴────────────────────────────┐
│    Application Layer (Notifiers)        │
│  - ProjectNotifier (Riverpod)           │
│  - ChatNotifier (Riverpod)              │
│  (AQUÍ cambia: Mock → Backend)          │
└────────────┬────────────────────────────┘
             ↑
             │ Llama
             │
┌────────────┴────────────────────────────┐
│    Domain Layer (Entities)              │
│  - FileNode (NUNCA CAMBIA)              │
│  - ChatMessageUI (NUNCA CAMBIA)         │
└────────────┬────────────────────────────┘
             ↑
             │ Retorna
             │
┌────────────┴────────────────────────────┐
│    Data Layer (Repositories)            │
│  - ProjectRepository                    │
│    ├─ mock: return MockProjectData      │
│    └─ backend: return api.getProject()  │
│  (AQUÍ alternamos: Mock ↔ Backend)      │
└─────────────────────────────────────────┘
```

---

## 🔄 Pasos de Migración (Phase a Phase)

### ✅ Phase 1: ACTUAL (Mock - 0% Backend)
```
Widgets ← Notifier ← Mock Data ✓
```

### Phase 2: GRADUAL (50% Backend)
```
Widgets ← Notifier ← Repository {
  ├─ Mock Data (para features no implementadas)
  └─ Backend API (para features implementadas)
}
```

### Phase 3: FINAL (100% Backend)
```
Widgets ← Notifier ← Repository ← Backend API
```

**Los Widgets permanecen IDÉNTICOS en toda la migración.**

---

## 📝 Guía de Implementation

### Para agregar un nuevo dato real:

1. **Create Repository Interface** (Domain)
```dart
abstract class ProjectRepository {
  Future<FileNode> getFileTree(String path);
  Future<List<ChatMessageUI>> getChatMessages(String projectId);
  Future<ProgressData> getProgress(String projectId);
}
```

2. **Implementation Mock** (Data)
```dart
class MockProjectRepository implements ProjectRepository {
  @override
  Future<FileNode> getFileTree(String path) async {
    await Future.delayed(Duration(milliseconds: 500));
    return MockProjectData.mockProjectRoot;  // ← Simular latencia
  }
}
```

3. **Implementation Backend** (Data)
```dart
class HttpProjectRepository implements ProjectRepository {
  @override
  Future<FileNode> getFileTree(String path) async {
    final response = await http.get('/api/projects/$path/tree');
    return FileNode.fromJson(response.body);  // ← Mapear DTO → Entity
  }
}
```

4. **Inyectar en Notifier** (Application)
```dart
final projectRepositoryProvider = Provider<ProjectRepository>(
  (ref) {
    final useBackend = ref.watch(useBackendFlagProvider);

    if (useBackend) {
      return HttpProjectRepository();
    } else {
      return MockProjectRepository();
    }
  },
);

final projectProvider = StateNotifierProvider<ProjectNotifier, ProjectState>(
  (ref) => ProjectNotifier(ref.watch(projectRepositoryProvider)),
);
```

5. **Widget NO CAMBIA** ✅
```dart
// project_shell_screen.dart - IDÉNTICO
class _ProjectShellScreenState extends ConsumerState<ProjectShellScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(projectProvider);
    return state.when(
      loaded: (fileTree, messages) => ChatPanelWidget(messages: messages),
    );
  }
}
```

---

## 🎯 Beneficios de esta Arquitectura

| Beneficio | Explicación |
|-----------|------------|
| **Testeable** | Mockea Repository, widgets no cambian |
| **Escalable** | Añade endpoints sin tocar Presentation |
| **Flexible** | Cambia entre mock/backend con flag |
| **Mantenible** | Cambios backend no afectan UI |
| **Independiente** | Develop frontend mientras backend se construye |

---

## 🚀 Ejemplo Completo (Mock → Backend)

### Hoy: Mock
```dart
_selectedNode = MockProjectData.mockProjectRoot;
ChatPanelWidget(messages: MockProjectData.mockChatMessages);
```

### Mañana: Backend (SIN CAMBIAR WIDGETS)
```
ref.read(projectProvider.notifier).loadProject(projectPath);
// El notifier llama a HttpProjectRepository
// El repository mapea DTOs a Entities
// El notifier notifica al widget con las mismas estructuras
// El widget renderiza exactamente igual
```

---

## ✅ Conclusión

**Los widgets están 100% desacoplados de la fuente de datos.**

El mock es perfecto para:
- ✅ Desarrollo de UI
- ✅ Testing de widgets
- ✅ Demo interactivo
- ✅ Base para backend

Cuando el backend esté listo:
- ✅ Reemplaza MockProjectData con API calls
- ✅ Widgets NO CAMBIAN
- ✅ Aplicación funciona igual

**Escalabilidad garantizada. 🚀**
