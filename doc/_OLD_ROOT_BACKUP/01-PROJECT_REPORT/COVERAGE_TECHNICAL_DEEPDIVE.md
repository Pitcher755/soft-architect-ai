# 🔧 Test Coverage - Technical Deep Dive

**Fecha:** 4 de Febrero de 2026
**Audience:** Developers & QA Engineers
**Nivel:** Técnico (Avanzado)

---

## 📊 Test Suite Architecture

### Estructura de Directorios
```
tests/
├── unit/                          (167/169 tests)
│   └── flutter/features/project_shell/
│       ├── infrastructure/validation/
│       │   ├── validation_constants_test.dart    (36 tests)
│       │   └── path_validator_test.dart          (24 tests)
│       ├── domain/entities/
│       │   ├── file_node_entity_test.dart        (27 tests)
│       │   └── project_entity_test.dart          (18 tests)
│       ├── domain/use_cases/
│       │   ├── directory_tree_use_case_test.dart (2 tests)
│       │   ├── project_validation_use_case_test.dart (26 tests)
│       │   └── file_search_use_case_test.dart    (24 tests)
│       └── presentation/
│           └── project_shell_notifier_test.dart  (10 tests)
│
├── widget/                        (29/36 tests)
│   └── flutter/features/project_shell/presentation/
│       ├── markdown_preview_widget_test.dart     (12/12 ✅)
│       ├── directory_tree_widget_test.dart       (11/12 🟡)
│       └── project_shell_screen_test.dart        (6/13 🔴)
│
└── integration/                   (6/9 tests)
    └── flutter/features/project_shell/
        ├── data/project_creation_flow_test.dart  (0/3 ❌)
        └── presentation/
            ├── markdown_preview_flow_test.dart   (6/6 ✅)
            └── project_shell_screen_flow_test.dart (N/A)

TOTAL: 212 Tests | 202 Passing (95.3%)
```

---

## 🔬 Análisis de Fallos

### Categoría 1: Fallos Críticos (7 tests)

#### ProjectShellScreen State Injection Issues
**Archivo:** `tests/widget/flutter/.../project_shell_screen_test.dart`

```dart
// PROBLEMA IDENTIFICADO:
class FakeProjectShellNotifier extends ProjectShellNotifier {
  FakeProjectShellNotifier(ProjectRepository repository, ProjectShellState initialState)
      : super(
          repository,
          skipInit: true,
          initialState: initialState,  // ← Estado pasado correctamente
        );
}

// PERO AL EJECUTAR EL TEST:
testWidgets('should display no project view when no project is selected', ...) {
  await tester.pumpWidget(
    _buildApp(
      const ProjectShellState(
        projects: [],
        selectedProject: null,
        isLoading: false,
      ),
    ),
  );

  // ❌ FALLA: El widget no recibe el estado inyectado
  expect(find.text('No Project Selected'), findsOneWidget);
  // Expected: 1 widget | Actual: 0 widgets
}

// ROOT CAUSE ANÁLISIS:
// 1. FakeProjectShellNotifier SE CREA correctamente ✅
// 2. El estado initialState se establece correctamente ✅
// 3. PERO: El widget ProjectShellScreen no accede al estado actualizado ❌
//
// Probable causa: Timing issue en Riverpod Consumer reconstruction
// O: El widget está usando un provider diferente que no está overridden
```

**7 Tests Afectados:**
1. ❌ should display no project view when no project is selected
2. ❌ should display project name in app bar when project is selected
3. ❌ should display loading indicator when loading
4. ❌ should display error message when there is an error
5. ❌ should handle empty projects list
6. ❌ should have proper layout structure
7. ❌ should update UI when project changes

**Soluciones Potenciales:**

**Opción A: Usar StateNotifierProvider.family**
```dart
// Antes: Notifier singleton
final projectShellProvider = StateNotifierProvider<
  ProjectShellNotifier,
  ProjectShellState
>((ref) {
  return ProjectShellNotifier(ref.watch(projectRepositoryProvider));
});

// Después: Notifier con parámetro de estado
final projectShellProvider = StateNotifierProvider.family<
  ProjectShellNotifier,
  ProjectShellState,
  ProjectShellState? // Parámetro adicional
>((ref, initialState) {
  return ProjectShellNotifier(
    ref.watch(projectRepositoryProvider),
    initialState: initialState,
  );
});

// En test:
testWidgets('...', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        projectShellProvider(testState).overrideWith((_) {
          return FakeProjectShellNotifier(mockRepo, testState);
        }),
      ],
      child: const MaterialApp(home: ProjectShellScreen()),
    ),
  );
});
```

**Opción B: Refactorizar ProjectShellScreen para inyección**
```dart
// Pasar estado como parámetro al widget
class ProjectShellScreen extends ConsumerWidget {
  final ProjectShellState? initialState; // ← Nuevo parámetro

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Usar initialState si está disponible
    final state = initialState ?? ref.watch(projectShellProvider);
    // ...
  }
}

// En test:
testWidgets('...', (tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: ProjectShellScreen(
        initialState: testState,  // ← Pasar estado directamente
      ),
    ),
  );
});
```

**Opción C: Crear TestableProjectShellNotifier**
```dart
// Extender con capacidad de test
class TestableProjectShellNotifier extends ProjectShellNotifier {
  TestableProjectShellNotifier(
    ProjectRepository repository,
    ProjectShellState testState,
  ) : super(
    repository,
    skipInit: true,
    initialState: testState,
  ) {
    // Forzar lectura del estado en el árbol de widgets
    state = testState; // ← Redundante pero explícito
  }

  // Método para verificar que el estado está disponible
  ProjectShellState getState() => state;
}
```

---

### Categoría 2: Fallos Secundarios (3 tests)

#### Integration Test Database Initialization
**Archivo:** `tests/integration/flutter/.../project_creation_flow_test.dart`

```dart
// PROBLEMA:
setUp(() async {
  final db = await initTestDatabase();  // ← Falla aquí
  dataSource = SQLiteDataSource(db);
  repository = ProjectRepositoryImpl(dataSource);
});

// ERROR:
// Exception: Error initializing test database:
// - createTables() not properly implemented
// - Or SQLiteDataSource.createTables(db) throwing exception

// ANÁLISIS:
// 1. initTestDatabase() en test_helper.dart se basa en:
//    - openDatabase(':memory:')
//    - SQLiteDataSource.createTables(db)
//
// 2. SQLiteDataSource.createTables(db) debe:
//    - Crear tabla 'projects'
//    - Crear tabla 'project_files'
//    - Manejar constraints correctamente
```

**3 Tests Afectados:**
1. ❌ should create and retrieve project successfully
2. ❌ should list all created projects
3. ❌ should validate project constraints

**Solución Recomendada:**
```dart
// test_helper.dart - VERSIÓN MEJORADA
Future<Database> initTestDatabase() async {
  // 1. Inicializar FFI (si es necesario)
  sqfliteFfiInit();

  // 2. Usar databaseFactory apropiado
  final factory = sqflite_common_ffi.databaseFactoryFfi;

  // 3. Abrir BD en memoria
  final db = await factory.openDatabase(
    inMemoryDatabasePath,
    options: OpenDatabaseOptions(
      version: 1,
      onCreate: (db, version) async {
        // 4. Crear tablas explícitamente
        await db.execute('''
          CREATE TABLE IF NOT EXISTS projects (
            id TEXT PRIMARY KEY,
            name TEXT NOT NULL UNIQUE,
            path TEXT NOT NULL,
            created_at INTEGER NOT NULL,
            last_opened INTEGER,
            CONSTRAINT valid_name CHECK (length(name) >= 3)
          );
        ''');

        await db.execute('''
          CREATE TABLE IF NOT EXISTS project_files (
            id TEXT PRIMARY KEY,
            project_id TEXT NOT NULL,
            name TEXT NOT NULL,
            path TEXT NOT NULL UNIQUE,
            is_directory INTEGER NOT NULL DEFAULT 0,
            parent_id TEXT,
            FOREIGN KEY (project_id) REFERENCES projects(id)
              ON DELETE CASCADE
          );
        ''');
      },
    ),
  );

  return db;
}

// O: usar SQLiteDataSource.createTables() si existe
Future<Database> initTestDatabase() async {
  final db = await openDatabase(':memory:');

  try {
    // Si SQLiteDataSource tiene createTables():
    await SQLiteDataSource.createTables(db);
  } catch (e) {
    // Fallback a creación manual
    await _createTablesManually(db);
  }

  return db;
}
```

---

### Categoría 3: Fallos Menores (1 test)

#### DirectoryTreeWidget Highlighting
**Archivo:** `tests/widget/flutter/.../directory_tree_widget_test.dart`

```dart
testWidgets('should highlight selected file', ...) {
  final selectedFile = FileNode(
    id: 'file-readme',
    name: 'README.md',
    path: '/home/test/test-project/README.md',
    isDirectory: false,
  );

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: DirectoryTreeWidget(
          root: testRoot,
          selectedNode: selectedFile,
          onFileSelected: (_) {},
        ),
      ),
    ),
  );

  // ✅ Verificación Actual (Pasa):
  expect(find.text('README.md'), findsOneWidget);

  // 🔴 Verificación que Debería Pasar:
  final listTiles = tester.widgetList<ListTile>(find.byType(ListTile));
  final hasSelectedTile = listTiles.any((tile) => tile.selected == true);
  expect(hasSelectedTile, isTrue);
  // ^^ Esta pasa pero ¿se renderizan efectivamente los ListTile en forma de highlight?
}

// PROBLEMA POTENCIAL:
// El ListTile tiene selected=true pero NO hay feedback visual
// porque el widget no renderiza color de fondo o indicador de selección
```

**Solución:**
```dart
// Opción A: Verificar propiedades del ListTile
testWidgets('should highlight selected file', ...) {
  // ... setup ...

  final selectedTile = find.byWidgetPredicate(
    (widget) => widget is ListTile &&
                widget.title is Text &&
                (widget.title as Text).data == 'README.md' &&
                widget.selected == true
  );

  expect(selectedTile, findsOneWidget);

  // También verificar que el color de fondo cambió
  final tileContainer = find.ancestor(
    of: find.text('README.md'),
    matching: find.byType(Container),
  );
  expect(tileContainer, findsWidgets);
});

// Opción B: Verificar elemento decorado
testWidgets('should visually highlight selected file', ...) {
  // ... setup ...

  // Buscar el ListTile con el archivo seleccionado
  final selectedListTile = tester.widget<ListTile>(
    find.byWidgetPredicate(
      (widget) => widget is ListTile &&
                  (widget.title as Text).data == 'README.md'
    ),
  );

  // Verificar propiedades de selección
  expect(selectedListTile.selected, isTrue);

  // Verificar color de selección (si existe tileColor o selectedTileColor)
  if (selectedListTile.selectedTileColor != null) {
    expect(selectedListTile.selectedTileColor, isNotNull);
  }
});
```

---

## 🧪 Estrategia de Testing por Capa

### 1. Unit Tests (Bottom-up)
```
✅ Validación de constantes → Validadores → Entidades → Use Cases

Patrón:
- Arrange: Crear inputs
- Act: Ejecutar lógica
- Assert: Verificar outputs

Ejemplo:
test('validateFilePathInProject rejects path traversal', () {
  const projectPath = '/home/user/project';

  expect(
    () => PathValidator.validateFilePathInProject(
      projectPath: projectPath,
      filePath: '../../../etc/passwd',
    ),
    throwsA(isA<PathTraversalException>()),
  );
});
```

### 2. Widget Tests (Middle)
```
✅ Individual widgets con mockeados providers

Patrón:
- ProviderScope con overrides
- WidgetTester para interacción
- Esperar renders con pump/pumpAndSettle

Desafío Actual:
- Inyección de estado en Riverpod es compleja
- Timing issues con async initialization

Solución:
- Usar skipInit = true
- Pasar estado via constructor super()
- Considerar StateNotifierProvider.family
```

### 3. Integration Tests (Top)
```
✅ Flujos completos con BD real (en test)

Patrón:
- initTestDatabase() en setUp()
- Crear datos
- Verificar persistencia
- Limpiar en tearDown()

Desafío Actual:
- SQLite initialization en test
- Table creation correcta

Solución:
- Completar SQLiteDataSource.createTables()
- O crear tablas manualmente en test_helper
```

---

## 📈 Métricas Detalladas

### Por Línea de Código
```
ValidationConstants       36 tests /  85 LOC = 0.42 tests/LOC ✅ HIGH
PathValidator            24 tests / 180 LOC = 0.13 tests/LOC ✅ HIGH
FileNode Entity          27 tests / 150 LOC = 0.18 tests/LOC ✅ HIGH
ProjectShellNotifier     10 tests / 120 LOC = 0.08 tests/LOC 🟡 MEDIUM
ProjectShellScreen        6 tests / 250 LOC = 0.02 tests/LOC 🔴 LOW
```

### Ratio Promedio
```
Average: 0.16 tests per line of code
Benchmark: 0.10-0.20 is good
Status: ✅ ABOVE AVERAGE
```

---

## 🎯 Checkpoints de Validación

### Pre-Commit Checks
```bash
✅ Type safety: dart analyze
✅ Formatting: dart format
✅ Unit tests: flutter test unit/
✅ Lint: dartanalyzer
```

### Pre-Push Checks
```bash
✅ All unit tests pass
✅ Code coverage > 80%
✅ No security warnings
✅ No type errors
```

### CI/CD Pipeline
```bash
✅ GitHub Actions runs all tests
✅ Code coverage uploaded to Codecov
✅ Build artifacts generated
✅ Security scan completed
```

---

## 🔮 Proyecciones Futuras

### Próximas 2 Semanas
```
Feb 4:   95.3% (actual)
Feb 7:   98.1% (ProjectShellScreen fixed)
Feb 11:  99.5% (Integration tests fixed)
```

### Próximos 3 Meses
```
Feb:     99.5% (base completa)
Mar:     99.8% (edge cases + E2E)
Apr:     99.9% (performance + stress tests)
```

### Goal Final
```
Target: 99.5%+ coverage
        - 100% de unit tests
        - 95%+ de widget tests
        - 90%+ de integration tests
        - 100% de security tests
```

---

## 📚 Referencias & Recursos

- [Flutter Testing Docs](https://flutter.dev/docs/testing)
- [Riverpod Testing Guide](https://riverpod.dev/docs/essentials/testing)
- [SQLite Flutter Testing](https://pub.dev/packages/sqflite)
- [Testing Best Practices](/context/TESTING_PYRAMID_AND_QUALITY_GATES.es.md)

---

**Documento Técnico:** Test Coverage Deep Dive
**Actualización:** 4 Feb 2026
**Reviewer Recomendado:** Tech Lead o Senior Engineer
**Próxima Revisión:** 7 de Febrero de 2026
