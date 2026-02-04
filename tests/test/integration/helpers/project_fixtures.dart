// tests/integration/flutter/helpers/project_fixtures.dart
import 'package:softarchitect_ai/features/project_shell/domain/entities/file_node.dart';
import 'package:softarchitect_ai/features/project_shell/domain/entities/project.dart';

/// Test fixtures for integration tests

/// Root directory node for testing
final testRootNode = FileNode(
  id: 'root-node',
  name: 'test-project',
  path: '/home/test/test-project',
  isDirectory: true,
  children: [
    FileNode(
      id: 'file-readme',
      name: 'README.md',
      path: '/home/test/test-project/README.md',
      isDirectory: false,
      children: [],
    ),
    FileNode(
      id: 'dir-src',
      name: 'src',
      path: '/home/test/test-project/src',
      isDirectory: true,
      children: [
        FileNode(
          id: 'file-main',
          name: 'main.dart',
          path: '/home/test/test-project/src/main.dart',
          isDirectory: false,
          children: [],
        ),
      ],
    ),
  ],
);

/// Test project for integration tests
const testProject = Project(
  id: 'test-project-1',
  name: 'Test Project',
  path: '/home/test/test-project',
  createdAt: DateTime(2026, 2, 3, 10, 0),
);

/// List of test projects
const testProjects = [
  testProject,
  Project(
    id: 'test-project-2',
    name: 'Another Project',
    path: '/home/test/another-project',
    createdAt: DateTime(2026, 2, 1, 15, 30),
  ),
];
