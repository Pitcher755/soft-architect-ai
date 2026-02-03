# 📋 HU-3.1: Test Plan TDD - RED → GREEN → REFACTOR

> **Estrategia:** Test-Driven Development
> **Enfoque:** RED phase con 6 tests iniciales
> **Objetivo:** Tests que fallan esperando la implementación

---

## 🔴 FASE RED: Tests que Fallan

### Test 1: Project Creation & Validation

```dart
// tests/unit/domain/project_validation_use_case_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/project_shell/domain/use_cases/project_validation_use_case.dart';

void main() {
  group('ProjectValidationUseCase', () {
    test('isValidName rejects names shorter than 3 chars', () {
      expect(ProjectValidationUseCase.isValidName('ab'), false);
      expect(ProjectValidationUseCase.isValidName('a'), false);
    });

    test('isValidName accepts valid project names', () {
      expect(ProjectValidationUseCase.isValidName('my-project'), true);
      expect(ProjectValidationUseCase.isValidName('MyProject_2'), true);
      expect(ProjectValidationUseCase.isValidName('project123'), true);
    });

    test('isValidName rejects names with special characters', () {
      expect(ProjectValidationUseCase.isValidName('my project'), false);
      expect(ProjectValidationUseCase.isValidName('my@project'), false);
      expect(ProjectValidationUseCase.isValidName('my/project'), false);
      expect(ProjectValidationUseCase.isValidName('../project'), false);
    });

    test('isValidName rejects names longer than 50 chars', () {
      final longName = 'a' * 51;
      expect(ProjectValidationUseCase.isValidName(longName), false);
    });
  });
}
```

### Test 2: Directory Tree Expansion Logic

```dart
// tests/unit/domain/directory_tree_use_case_test.dart

void main() {
  group('DirectoryTreeUseCase', () {
    test('toggleNodeExpanded adds node ID when collapsed', () {
      var expanded = <String>{};
      final nodeId = 'node-123';

      expanded = DirectoryTreeUseCase.toggleNodeExpanded(expanded, nodeId);

      expect(expanded.contains(nodeId), true);
    });

    test('toggleNodeExpanded removes node ID when expanded', () {
      final nodeId = 'node-123';
      var expanded = <String>{nodeId};

      expanded = DirectoryTreeUseCase.toggleNodeExpanded(expanded, nodeId);

      expect(expanded.contains(nodeId), false);
    });

    test('getVisibleNodes returns correct tree structure', () {
      final rootNode = FileNode(
        id: 'root',
        name: 'root',
        path: '/',
        isDirectory: true,
        children: [
          FileNode(
            id: 'file1',
            name: 'file1.md',
            path: '/file1.md',
            isDirectory: false,
          ),
          FileNode(
            id: 'dir1',
            name: 'dir1',
            path: '/dir1',
            isDirectory: true,
            children: [
              FileNode(
                id: 'file2',
                name: 'file2.md',
                path: '/dir1/file2.md',
                isDirectory: false,
              ),
            ],
          ),
        ],
      );

      final expanded = <String>{'dir1'};
      final visible = DirectoryTreeUseCase.getVisibleNodes(rootNode, expanded);

      expect(visible.length, 3); // root + file1 + dir1 + file2
      expect(visible.map((n) => n.id).toList(), ['root', 'file1', 'dir1', 'file2']);
    });
  });
}
```

### Test 3: File Search Filtering

```dart
// tests/unit/domain/file_search_use_case_test.dart

void main() {
  group('FileSearchUseCase', () {
    test('search returns empty list when query is empty', () {
      final nodes = [
        FileNode(name: 'test.md'),
        FileNode(name: 'doc.md'),
      ];

      final results = FileSearchUseCase.search(nodes, '');

      expect(results.isEmpty, true);
    });

    test('search filters by filename case-insensitive', () {
      final nodes = [
        FileNode(name: 'architecture.md'),
        FileNode(name: 'design_system.md'),
        FileNode(name: 'README.md'),
      ];

      final results = FileSearchUseCase.search(nodes, 'arch');

      expect(results.length, 1);
      expect(results.first.name, 'architecture.md');
    });

    test('search filters by partial match', () {
      final nodes = [
        FileNode(name: 'doc1.md'),
        FileNode(name: 'document.md'),
        FileNode(name: 'test_doc.md'),
      ];

      final results = FileSearchUseCase.search(nodes, 'doc');

      expect(results.length, 3);
    });

    test('search respects max 100 character limit', () {
      final query = 'a' * 101;

      expect(
        () => FileSearchUseCase.search([], query),
        throwsA(isA<ValidationException>()),
      );
    });
  });
}
```

### Test 4: SQLite Persistence

```dart
// tests/unit/data/sqlite_data_source_test.dart

import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  group('SQLiteDataSource', () {
    late Database db;
    late SQLiteDataSource dataSource;

    setUp(() async {
      sqfliteFfiInit();
      db = await databaseFactoryFfi.openDatabase(
        inMemoryDatabasePath,
      );
      await db.execute('''
        CREATE TABLE projects (
          id TEXT PRIMARY KEY,
          name TEXT UNIQUE NOT NULL,
          path TEXT NOT NULL,
          created_at TEXT NOT NULL,
          last_opened TEXT
        )
      ''');
      dataSource = SQLiteDataSource(db);
    });

    tearDown(() async {
      await db.close();
    });

    test('saveProject inserts project into database', () async {
      final project = ProjectModel(
        id: '123',
        name: 'test-project',
        path: '/home/user/projects/test-project',
        createdAt: DateTime.now(),
      );

      await dataSource.saveProject(project);

      final result = await db.query('projects', where: 'id = ?', whereArgs: ['123']);
      expect(result.length, 1);
      expect(result.first['name'], 'test-project');
    });

    test('getProject retrieves project from database', () async {
      final testTime = DateTime.now();
      await db.insert('projects', {
        'id': '123',
        'name': 'test-project',
        'path': '/home/user/projects/test-project',
        'created_at': testTime.toIso8601String(),
      });

      final project = await dataSource.getProject('123');

      expect(project?.name, 'test-project');
    });

    test('getAllProjects returns all projects', () async {
      await db.insert('projects', {
        'id': '1',
        'name': 'project1',
        'path': '/path/1',
        'created_at': DateTime.now().toIso8601String(),
      });
      await db.insert('projects', {
        'id': '2',
        'name': 'project2',
        'path': '/path/2',
        'created_at': DateTime.now().toIso8601String(),
      });

      final projects = await dataSource.getAllProjects();

      expect(projects.length, 2);
    });

    test('saveProject throws when inserting duplicate name', () async {
      const name = 'duplicate-name';

      await db.insert('projects', {
        'id': '1',
        'name': name,
        'path': '/path/1',
        'created_at': DateTime.now().toIso8601String(),
      });

      final duplicate = ProjectModel(
        id: '2',
        name: name,
        path: '/path/2',
        createdAt: DateTime.now(),
      );

      expect(
        () => dataSource.saveProject(duplicate),
        throwsA(isA<SQLException>()),
      );
    });
  });
}
```

### Test 5: Project Repository

```dart
// tests/unit/data/project_repository_impl_test.dart

void main() {
  group('ProjectRepositoryImpl', () {
    late MockSQLiteDataSource mockSqlite;
    late MockFileSystemDataSource mockFileSystem;
    late ProjectRepositoryImpl repository;

    setUp(() {
      mockSqlite = MockSQLiteDataSource();
      mockFileSystem = MockFileSystemDataSource();
      repository = ProjectRepositoryImpl(mockSqlite, mockFileSystem);
    });

    test('createProject validates name and saves to database', () async {
      final name = 'new-project';

      await repository.createProject(name);

      verify(mockSqlite.saveProject(any)).called(1);
    });

    test('createProject rejects invalid project name', () async {
      const invalidName = 'invalid@name!';

      expect(
        () => repository.createProject(invalidName),
        throwsA(isA<InvalidProjectNameException>()),
      );
    });

    test('getProjectTree calls FileSystemService', () async {
      const projectId = 'proj-123';
      when(mockFileSystem.listDirectory(projectId))
          .thenAnswer((_) async => []);

      await repository.getProjectTree(projectId);

      verify(mockFileSystem.listDirectory(projectId)).called(1);
    });

    test('getLastOpenedProject returns null when none saved', () async {
      when(mockSqlite.getLastOpenedProjectId())
          .thenAnswer((_) async => null);

      final result = await repository.getLastOpenedProject();

      expect(result, null);
    });
  });
}
```

### Test 6: Riverpod State Management

```dart
// tests/unit/presentation/project_shell_notifier_test.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProjectShellNotifier', () {
    late ProviderContainer container;
    late MockProjectRepository mockRepository;

    setUp(() {
      mockRepository = MockProjectRepository();
      container = ProviderContainer(
        overrides: [
          projectRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
    });

    test('initial state loads projects from repository', () async {
      final projects = [
        Project(id: '1', name: 'proj1', path: '/path/1', createdAt: DateTime.now()),
        Project(id: '2', name: 'proj2', path: '/path/2', createdAt: DateTime.now()),
      ];

      when(mockRepository.getAllProjects()).thenAnswer((_) async => projects);
      when(mockRepository.getLastOpenedProject()).thenAnswer((_) async => null);

      final notifier = container.read(projectShellNotifierProvider.notifier);
      final state = await container.read(projectShellNotifierProvider.future);

      expect(state.projects.length, 2);
    });

    test('selectProject updates selected project and calls repository', () async {
      final project = Project(
        id: '1',
        name: 'proj1',
        path: '/path/1',
        createdAt: DateTime.now(),
      );

      when(mockRepository.updateLastOpened('1')).thenAnswer((_) async => {});

      final notifier = container.read(projectShellNotifierProvider.notifier);
      await notifier.selectProject(project);

      verify(mockRepository.updateLastOpened('1')).called(1);
    });

    test('error state when repository fails', () async {
      when(mockRepository.getAllProjects())
          .thenThrow(Exception('Database error'));

      final state = container.read(projectShellNotifierProvider);

      expect(state, isA<AsyncValue<ProjectShellState>>());
    });
  });
}
```

---

## 📊 Test Execution Matrix

| Test # | Nombre | Archivo | Dependencias | Status |
|--------|--------|---------|--------------|--------|
| 1 | ProjectValidation | project_validation_use_case_test.dart | RegEx, Exception | 🔴 FALLA |
| 2 | DirectoryTree Logic | directory_tree_use_case_test.dart | FileNode model | 🔴 FALLA |
| 3 | FileSearch Filtering | file_search_use_case_test.dart | FileNode model | 🔴 FALLA |
| 4 | SQLite Persistence | sqlite_data_source_test.dart | sqflite_ffi | 🔴 FALLA |
| 5 | ProjectRepository | project_repository_impl_test.dart | Mocks | 🔴 FALLA |
| 6 | Riverpod State | project_shell_notifier_test.dart | Riverpod, Mocks | 🔴 FALLA |

---

## 🎯 Comandos para Ejecutar Tests

```bash
# Ejecutar un test específico
cd src/client
flutter test tests/unit/domain/project_validation_use_case_test.dart

# Ejecutar todos los tests de esta HU
flutter test tests/unit/domain/ tests/unit/data/ tests/unit/presentation/

# Con output detallado
flutter test --verbose

# Con coverage
flutter test --coverage

# Ver coverage en HTML
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html
```

---

## 📝 Mocks Necesarios

```dart
// tests/mocks/mock_project_repository.dart

class MockProjectRepository extends Mock implements ProjectRepository {}
class MockSQLiteDataSource extends Mock implements SQLiteDataSource {}
class MockFileSystemDataSource extends Mock implements FileSystemDataSource {}
class MockProjectShellNotifier extends Mock implements ProjectShellNotifier {}

// tests/fixtures/project_fixtures.dart

final testProject = ProjectModel(
  id: 'test-123',
  name: 'test-project',
  path: '/home/user/projects/test-project',
  createdAt: DateTime.now(),
);

final testFileNode = FileNode(
  id: 'node-123',
  name: 'test.md',
  path: '/home/user/projects/test-project/test.md',
  isDirectory: false,
);
```

---

## ✅ Próximo Paso: GREEN Phase

Una vez que confirmes, implementaré el código mínimo para que todos estos tests pasen.
