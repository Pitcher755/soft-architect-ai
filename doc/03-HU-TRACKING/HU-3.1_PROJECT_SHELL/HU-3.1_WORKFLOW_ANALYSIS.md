# 🎯 HU-3.1: IDE-like Project Shell - Complete Workflow Analysis

> **Estado:** 🔄 ANÁLISIS EN PROGRESO
> **Fecha:** 03/02/2026
> **Autor:** ArchitectZero (GitHub Copilot)
> **Estimación Original:** XL (13 pts)
> **Branch:** feature/ui-project-shell

---

## 📋 Tabla de Contenidos

1. [Análisis de Requisitos](#análisis-de-requisitos)
2. [Arquitectura Propuesta](#arquitectura-propuesta)
3. [Estrategia TDD](#estrategia-tdd)
4. [Plan de Seguridad](#plan-de-seguridad)
5. [Workflow de Implementación](#workflow-de-implementación)
6. [Checklist de Calidad](#checklist-de-calidad)

---

## 🎯 Análisis de Requisitos

### Requisitos Funcionales (RF)

| ID | Requisito | Prioridad | Categoría |
|----|-----------|-----------|---------:|
| RF-1 | Árbol de directorios con expand/collapse (VS Code style) | CRÍTICA | UI |
| RF-2 | Preview Markdown en tiempo real con renderizado | CRÍTICA | UI |
| RF-3 | Crear proyectos con validación de nombres | CRÍTICA | Logic |
| RF-4 | Búsqueda de archivos en tiempo real (filtro) | ALTA | Logic |
| RF-5 | Persistencia de estado (última carpeta abierta) en SQLite | ALTA | Data |
| RF-6 | Renderizado sin lag con 100+ archivos | ALTA | Performance |
| RF-7 | Integración con FileSystemService backend | CRÍTICA | Integration |
| RF-8 | Tooltips descriptivos en botones | MEDIA | Accessibility |

### Requisitos No Funcionales (RNF)

| ID | RNF | Target |
|----|-----|--------|
| RNF-1 | Coverage de tests unitarios | ≥80% |
| RNF-2 | Latencia de apertura de proyecto | <500ms |
| RNF-3 | Rendimiento con árbol profundo | <100ms render para 100+ files |
| RNF-4 | Type Safety (Pyright + Dart analyzer) | 0 errors |
| RNF-5 | Seguridad: validación de rutas (path traversal) | 100% |
| RNF-6 | Documentación de state management | 100% comentada |

### Dependencias

```
HU-3.1 (Frontend UI)
  ├── HU-3.2 (Backend FileSystemService) - API REQUERIDA
  ├── context/30-ARCHITECTURE/DESIGN_SYSTEM.md - Estilos
  └── context/30-ARCHITECTURE/UI_WIREFRAMES_AND_PROMPTS.md - Wireframes
```

---

## 🏗️ Arquitectura Propuesta

### Clean Architecture Layers

```
┌─────────────────────────────────────────────────────┐
│ PRESENTATION LAYER (Flutter Widgets)                │
├─────────────────────────────────────────────────────┤
│ • ProjectShellScreen (Main layout)                  │
│ • DirectoryTree widget (Expandable tree)            │
│ • MarkdownPreview widget (Right panel)              │
│ • ProjectToolbar widget (Top actions)               │
│ • FileSearchBar widget (Real-time filter)           │
└──────────────┬──────────────────────────────────────┘
               │ (Riverpod Providers)
┌──────────────▼──────────────────────────────────────┐
│ APPLICATION LAYER (State Management)                │
├─────────────────────────────────────────────────────┤
│ • ProjectShellNotifier (State container)            │
│ • DirectoryTreeNotifier (Tree expansion state)      │
│ • FileSearchNotifier (Search filter state)          │
│ • SelectedFileNotifier (Current preview)            │
│ • FileSystemRepositoryProvider (DI)                 │
└──────────────┬──────────────────────────────────────┘
               │ (Repository Pattern)
┌──────────────▼──────────────────────────────────────┐
│ DOMAIN LAYER (Business Logic)                       │
├─────────────────────────────────────────────────────┤
│ • Project entity                                    │
│ • FileNode entity (tree representation)             │
│ • ProjectRepository interface (CRUD)                │
│ • DirectoryTreeUseCase (expand/collapse logic)      │
│ • FileSearchUseCase (filter + sort logic)           │
│ • ProjectValidationUseCase (name validation)        │
└──────────────┬──────────────────────────────────────┘
               │
┌──────────────▼──────────────────────────────────────┐
│ DATA LAYER (Repositories & Data Sources)            │
├─────────────────────────────────────────────────────┤
│ • ProjectRepositoryImpl                              │
│ • SQLiteDataSource (Project persistence)            │
│ • FileSystemDataSource (HTTP bridge to HU-3.2)      │
│ • DTOs (Project, FileNode, SearchResult)            │
└─────────────────────────────────────────────────────┘
```

### Componentes Principales

#### 1. ProjectShellScreen (Main Container)
```dart
// Estructura
Row(
  children: [
    SizedBox(width: 300, child: DirectoryTree()),
    Expanded(child: MarkdownPreview()),
  ]
)

// State required
- selectedProject: Project?
- expandedNodes: Set<String> (node IDs)
- selectedFile: FileNode?
- isLoading: bool
- errorMessage: String?
```

#### 2. DirectoryTree Widget
- Renderiza árbol de archivos recursivo
- Soporte expand/collapse con iconos
- Selección de archivos
- Drag-and-drop (fase 2)
- Lazy loading para rendimiento (>100 archivos)

#### 3. MarkdownPreview Widget
- Renderiza contenido Markdown
- Scroll sincronizado
- Resaltado de código con tema oscuro
- Copy-to-clipboard para snippets
- Links navegables

#### 4. FileSystemService Integration
```dart
// Interfaz esperada (de HU-3.2)
class FileSystemService {
  Future<List<FileNode>> listDirectory(String projectId);
  Future<String> readFile(String projectId, String filePath);
  Future<void> createFile(...);
  Future<void> deleteFile(...);
}
```

---

## 🧪 Estrategia TDD

### Ciclo 🔴 → 🟢 → 🔵

```
FASE 1: RED (Escribir tests que fallan)
  ├─ test_project_shell_loads_tree.dart
  ├─ test_directory_tree_expand_collapse.dart
  ├─ test_markdown_preview_renders.dart
  ├─ test_file_search_filters.dart
  ├─ test_project_creation_validation.dart
  └─ test_persistence_last_opened_project.dart

FASE 2: GREEN (Implementación mínima)
  ├─ ProjectShellScreen (stub)
  ├─ DirectoryTree (basic rendering)
  ├─ MarkdownPreview (flutter_markdown integration)
  ├─ Riverpod providers (empty)
  └─ Repository implementations

FASE 3: REFACTOR (Optimización)
  ├─ Lazy loading para large trees
  ├─ Memoization de parsed Markdown
  ├─ Optimización de builds (RepaintBoundary)
  └─ Performance profiling
```

### Test Coverage Map

| Componente | Unit | Widget | Integration | Target |
|------------|------|--------|-------------|--------|
| DirectoryTree | 70% | 15% | 0% | 85% |
| MarkdownPreview | 60% | 20% | 0% | 80% |
| FileSearch | 90% | 0% | 0% | 90% |
| ProjectValidation | 100% | 0% | 0% | 100% |
| Riverpod Providers | 75% | 0% | 0% | 75% |
| **TOTAL** | - | - | - | **80%+** |

### Test File Structure

```
tests/
├── unit/
│   ├── presentation/
│   │   ├── project_shell_notifier_test.dart
│   │   ├── directory_tree_notifier_test.dart
│   │   └── file_search_notifier_test.dart
│   ├── domain/
│   │   ├── project_validation_use_case_test.dart
│   │   ├── directory_tree_use_case_test.dart
│   │   └── file_search_use_case_test.dart
│   └── data/
│       ├── sqlite_data_source_test.dart
│       └── file_system_data_source_test.dart
│
├── widget/
│   ├── directory_tree_widget_test.dart
│   ├── markdown_preview_widget_test.dart
│   └── project_shell_screen_test.dart
│
└── integration/
    └── project_shell_e2e_test.dart (Fase 2)
```

---

## 🔐 Plan de Seguridad

### 1. Validación de Entrada

```dart
// ✅ PERMITIDO
- Nombres de proyecto: [a-zA-Z0-9_-]{3,50}
- Rutas relativas: validated con path.normalize()
- Búsqueda: max 100 caracteres

// ❌ PROHIBIDO
- Path traversal: "../../../etc/passwd"
- Caracteres especiales: < > | : ? * \ /
- Nombres duplicados en SQLite (unique constraint)
- Rutas absolutas: /etc/passwd (rechazar)
```

### 2. Path Traversal Prevention

```dart
// ✅ CORRECTO
String validatePath(String projectId, String filePath) {
  final normalized = p.normalize(filePath);
  final projectPath = Directory('/home/user/SoftArchitect/projects/$projectId');
  final fullPath = Directory('${projectPath.path}/$normalized');

  // Verificar que fullPath esté dentro de projectPath
  if (!fullPath.path.startsWith(projectPath.path)) {
    throw SecurityException('Path traversal attempt detected');
  }
  return normalized;
}
```

### 3. Permisos de Archivos

```dart
// ✅ Local filesystem con permisos de usuario
// All files in ~/SoftArchitect/projects/ are user-owned
// No se permite acceso a /home/other_user/
// No se permite acceso a /root/ o /etc/
```

### 4. Logging Seguro

```dart
// ✅ CORRECTO - Sin exponer rutas completas
logger.info('Opened project: ${project.id}');

// ❌ INCORRECTO - Expone ruta absoluta
logger.info('Opened file: /home/user/SoftArchitect/projects/${project.id}/docs/file.md');

// ✅ CORRECTO - Con ofuscación
logger.info('Opened file: .../${file.name}');
```

---

## 🚀 Workflow de Implementación

### FASE 1: Setup & Architecture (Semana 1)

#### Sprint 1.1: Infrastructure & Test Setup (2 días)

**GOAL:** Estructura de carpetas, dependencias y tests básicos listos

**Tasks:**
- [ ] Crear estructura de carpetas (domain, data, presentation)
- [ ] Agregar dependencias (`flutter_markdown`, `riverpod_generator`, etc.)
- [ ] Configurar `test_helper.dart` con mocks
- [ ] Escribir 6 tests unitarios (RED phase)
- [ ] Crear fixtures para Project y FileNode

**Deliverables:**
```
src/client/lib/features/project_shell/
├── domain/
│   ├── entities/
│   │   ├── project.dart
│   │   └── file_node.dart
│   ├── repositories/
│   │   └── project_repository.dart
│   └── use_cases/
│       ├── project_validation_use_case.dart
│       ├── directory_tree_use_case.dart
│       └── file_search_use_case.dart
├── data/
│   ├── data_sources/
│   │   ├── sqlite_data_source.dart
│   │   └── file_system_data_source.dart
│   ├── models/
│   │   ├── project_model.dart
│   │   └── file_node_model.dart
│   └── repositories/
│       └── project_repository_impl.dart
└── presentation/
    ├── notifiers/
    │   ├── project_shell_notifier.dart
    │   ├── directory_tree_notifier.dart
    │   └── file_search_notifier.dart
    ├── providers/
    │   └── project_shell_providers.dart
    └── widgets/
        ├── screens/
        │   └── project_shell_screen.dart
        ├── components/
        │   ├── directory_tree.dart
        │   ├── markdown_preview.dart
        │   ├── project_toolbar.dart
        │   └── file_search_bar.dart
        └── styles/
            └── project_shell_theme.dart
```

**Definition of Ready:**
- [ ] Todos los tests corren y fallan (RED)
- [ ] Estructura de carpetas coincide con Clean Architecture
- [ ] Mocks de FileSystemService están listos
- [ ] pubspec.yaml actualizado

---

#### Sprint 1.2: Entidades & Validación (2 días)

**GOAL:** Modelos de dominio y lógica de validación

**Tasks:**
- [ ] Implementar `Project` entity (id, name, path, createdAt, lastOpened)
- [ ] Implementar `FileNode` entity (name, path, isDirectory, children)
- [ ] Implementar `ProjectValidationUseCase` (tests + logic)
- [ ] Implementar `DirectoryTreeUseCase` (expand/collapse logic)
- [ ] Tests green en ProjectValidation

**Code Example:**
```dart
// domain/entities/project.dart
class Project {
  final String id;
  final String name;
  final String path;
  final DateTime createdAt;
  final DateTime? lastOpened;

  const Project({
    required this.id,
    required this.name,
    required this.path,
    required this.createdAt,
    this.lastOpened,
  });

  // Validation factory
  factory Project.create(String name) {
    if (!ProjectValidationUseCase.isValidName(name)) {
      throw InvalidProjectNameException(name);
    }
    return Project(
      id: Uuid().v4(),
      name: name,
      path: '/home/user/SoftArchitect/projects/$name',
      createdAt: DateTime.now(),
    );
  }
}

// domain/use_cases/project_validation_use_case.dart
class ProjectValidationUseCase {
  static bool isValidName(String name) {
    final regex = RegExp(r'^[a-zA-Z0-9_-]{3,50}$');
    return regex.hasMatch(name);
  }

  static Future<bool> isNameUnique(String name, ProjectRepository repo) async {
    final projects = await repo.getAllProjects();
    return !projects.any((p) => p.name == name);
  }
}
```

**Definition of Ready:**
- [ ] 100% test coverage en ProjectValidation
- [ ] Entities tienen DartDoc completo
- [ ] No hay linting errors

---

### FASE 2: Repositories & Data Layer (Semana 2)

#### Sprint 2.1: SQLite Persistence (2 días)

**GOAL:** Guardar y recuperar proyectos de SQLite

**Tasks:**
- [ ] Implementar `SQLiteDataSource` (CRUD para projects)
- [ ] Crear migration schema para projects table
- [ ] Implementar `ProjectRepositoryImpl`
- [ ] Tests verde para repository (>90% coverage)

**Schema:**
```sql
CREATE TABLE projects (
  id TEXT PRIMARY KEY,
  name TEXT UNIQUE NOT NULL,
  path TEXT NOT NULL,
  created_at TEXT NOT NULL,
  last_opened TEXT,
  CHECK (LENGTH(name) >= 3 AND LENGTH(name) <= 50)
);
```

---

#### Sprint 2.2: FileSystem Service Bridge (2 días)

**GOAL:** HTTP bridge a HU-3.2 backend

**Tasks:**
- [ ] Implementar `FileSystemDataSource` (HTTP calls a backend)
- [ ] Crear `FileSystemService` adapter
- [ ] Mock tests esperando que HU-3.2 esté lista
- [ ] Error handling robusto (connection errors, timeouts)

---

### FASE 3: Presentation Layer - Widgets (Semana 3)

#### Sprint 3.1: Riverpod State Management (2 días)

**GOAL:** Providers y Notifiers centralizados

**Tasks:**
- [ ] Implementar `ProjectShellNotifier` (contains project list)
- [ ] Implementar `DirectoryTreeNotifier` (expand/collapse state)
- [ ] Implementar `FileSearchNotifier` (search query + filtered results)
- [ ] Implementar `SelectedFileNotifier` (current preview)
- [ ] Provider para persistencia de last_opened

**Code Example:**
```dart
// presentation/notifiers/project_shell_notifier.dart
@riverpod
class ProjectShellNotifier extends _$ProjectShellNotifier {
  @override
  Future<ProjectShellState> build() async {
    final repository = ref.watch(projectRepositoryProvider);

    try {
      final projects = await repository.getAllProjects();
      final lastOpened = await repository.getLastOpenedProject();

      return ProjectShellState(
        projects: projects,
        selectedProject: lastOpened,
        isLoading: false,
      );
    } catch (e) {
      return ProjectShellState.error(e.toString());
    }
  }

  Future<void> selectProject(Project project) async {
    state = AsyncValue.data(state.requireValue.copyWith(selectedProject: project));
    final repository = ref.read(projectRepositoryProvider);
    await repository.updateLastOpened(project.id);
  }
}
```

---

#### Sprint 3.2: Core Widgets (3 días)

**GOAL:** Widgets principales funcionales

**Tasks:**
- [ ] Implementar `DirectoryTree` widget
  - Renderiza tree de archivos
  - Expand/collapse con iconos
  - Selección con highlight
- [ ] Implementar `MarkdownPreview` widget
  - Renderiza contenido MD
  - Scroll + code highlighting
  - Copy button en snippets
- [ ] Implementar `ProjectToolbar`
  - Create project button
  - Refresh button
  - Settings menu
- [ ] Widget tests (>80% coverage)

**DirectoryTree Pseudo-code:**
```dart
class DirectoryTree extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final treeState = ref.watch(directoryTreeNotifierProvider);
    final expandedNodes = ref.watch(expandedNodesProvider);

    return ListView.builder(
      itemCount: treeState.visibleNodes.length,
      itemBuilder: (context, index) {
        final node = treeState.visibleNodes[index];
        final isExpanded = expandedNodes.contains(node.id);

        return TreeNodeTile(
          node: node,
          isExpanded: isExpanded,
          indent: node.depth * 16,
          onTap: () => ref.read(...).selectFile(node),
          onExpandToggle: () => ref.read(...).toggleNodeExpanded(node.id),
        );
      },
    );
  }
}
```

---

#### Sprint 3.3: File Search & Integration (2 días)

**GOAL:** Búsqueda en tiempo real + Preview

**Tasks:**
- [ ] Implementar `FileSearchBar` widget
  - Text input con clear button
  - Debounce (300ms)
  - Realtime filtering
- [ ] Integrar búsqueda con DirectoryTree
  - Mostrar solo matched files
  - Highlight matches
- [ ] Implementar synchronized preview
  - Al seleccionar archivo, muestra en MarkdownPreview

---

### FASE 4: Testing & Polish (Semana 4)

#### Sprint 4.1: Unit & Widget Tests (2 días)

**GOAL:** Coverage ≥80%

**Tasks:**
- [ ] Escribir tests para todos los Notifiers
- [ ] Escribir tests para Widgets principales
- [ ] Mockar FileSystemService completamente
- [ ] Correr coverage report: `flutter test --coverage`

**Command:**
```bash
cd src/client
flutter test --coverage
lcov --remove coverage/lcov.info 'lib/generated/*' -o coverage/lcov.info
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

#### Sprint 4.2: Integration & Documentation (2 días)

**GOAL:** E2E tests + docs

**Tasks:**
- [ ] Integration test: "Create project → open file → preview Markdown"
- [ ] Performance profiling (tree with 100+ files)
- [ ] Accessibility testing (screen reader, keyboard nav)
- [ ] Escribir IMPLEMENTATION.md con patrones usados

---

## ✅ Checklist de Calidad

### Code Quality

- [ ] **Dart Analyzer:** `flutter analyze src/client/lib/features/project_shell/` → 0 errors
- [ ] **Flutter Lints:** All linting rules pass (check_for_missing_returns, prefer_constructors_over_static_methods, etc.)
- [ ] **Type Safety:** No `dynamic` o `as` casting sin justificación
- [ ] **Documentation:**
  - [ ] Todos los public methods tienen DartDoc
  - [ ] Clases complejas tienen arquitectura explicada en comentarios
  - [ ] UseCases documentan su lógica de negocio

### Testing

- [ ] **Coverage:** `flutter test --coverage` ≥ 80% en src/client/lib/features/project_shell/
- [ ] **Unit Tests:** Todos los use cases tienen >90% coverage
- [ ] **Widget Tests:** Widgets principales tienen smoke tests
- [ ] **Integration Tests:** Happy path e2e test

### Security

- [ ] **Path Validation:** Todos los paths validados con `path.normalize()` + boundary check
- [ ] **Input Validation:** Project names siguen regex `^[a-zA-Z0-9_-]{3,50}$`
- [ ] **SQLite Injection:** Todas las queries usan parameterized statements
- [ ] **Logging:** No se loguean rutas completas o datos sensibles

### Performance

- [ ] **Lazy Loading:** Tree renderiza sin lag con 100+ files (< 100ms)
- [ ] **Memoization:** Parsed Markdown no se recalcula innecesariamente
- [ ] **Profiling:** DevTools mostraba <60fps en todas las interacciones

### Documentation

- [ ] **IMPLEMENTATION.md:** Patrones de Riverpod, state management
- [ ] **ARCHITECTURE.md:** Diagrama de capas e inyección de dependencias
- [ ] **API_MOCKING.md:** Cómo los tests mockean FileSystemService
- [ ] **TROUBLESHOOTING.md:** Errores comunes y soluciones

### Git & Commits

- [ ] **Branch naming:** `feature/pit-62-hu-31-...`
- [ ] **Commit messages:** Follow convention (`feat:`, `fix:`, `test:`, `docs:`)
- [ ] **Pre-commit hooks:** Black, Ruff, Pyright pass
- [ ] **No merge conflicts:** Branch updated with develop antes de PR

---

## 🎬 Próximos Pasos

**Estado Actual:** 📋 ANÁLISIS COMPLETADO

**Cuando confirmes:**
1. Crearé la estructura de carpetas exacta con todos los archivos
2. Escribiré los 6 tests iniciales en RED
3. Crearé los mocks necesarios
4. Estaré listo para que digas "✅ PROCEDER" y empecemos la implementación

**Esperando tu confirmación:** ✋
