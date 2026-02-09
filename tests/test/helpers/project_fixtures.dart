// tests/fixtures/project_fixtures.dart
import 'package:softarchitect_ai/features/filesystem/domain/entities/file_node.dart';
import 'package:softarchitect_ai/features/project_shell/domain/entities/project.dart';

/// Test project entity
late final testProject = Project(
  id: 'test-proj-123',
  name: 'test-project',
  path: '/home/test/SoftArchitect/projects/test-project',
  createdAt: DateTime(2026, 2, 3, 10, 0),
  lastOpened: null,
);

/// Test file node (markdown file)
late final testFileNode = FileNode(
  id: 'file-001',
  name: 'architecture.md',
  path: '/home/test/SoftArchitect/projects/test-project/architecture.md',
  isDirectory: false,
  children: [],
);

/// Test directory node containing a file
late final testDirectoryNode = FileNode(
  id: 'dir-001',
  name: 'docs',
  path: '/home/test/SoftArchitect/projects/test-project/docs',
  isDirectory: true,
  children: [testFileNode],
);

/// Test root tree node with mixed content
late final testRootNode = FileNode(
  id: 'root',
  name: 'test-project',
  path: '/home/test/SoftArchitect/projects/test-project',
  isDirectory: true,
  children: [
    FileNode(
      id: 'file-readme',
      name: 'README.md',
      path: '/home/test/SoftArchitect/projects/test-project/README.md',
      isDirectory: false,
    ),
    testDirectoryNode,
  ],
);
