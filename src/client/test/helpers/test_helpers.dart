// Test helper file with common utilities
import 'package:flutter/material.dart';
import 'package:softarchitect_ai/features/project_shell/domain/entities/project.dart';
import 'package:softarchitect_ai/features/project_shell/domain/entities/file_node.dart';

/// Create a test project with sensible defaults
Project createTestProject({
  String id = 'test_proj_123',
  String name = 'TestProject',
  String path = '/tmp/TestProject',
  DateTime? createdAt,
  DateTime? lastOpened,
}) {
  return Project(
    id: id,
    name: name,
    path: path,
    createdAt: createdAt ?? DateTime.now(),
    lastOpened: lastOpened,
  );
}

/// Create a test file node
FileNode createTestFileNode({
  String path = 'lib/main.dart',
  String name = 'main.dart',
  bool isDirectory = false,
  List<FileNode>? children,
  int? size,
  DateTime? modifiedAt,
}) {
  return FileNode(
    path: path,
    name: name,
    isDirectory: isDirectory,
    children: children ?? [],
    size: size,
    modifiedAt: modifiedAt,
  );
}

/// Create a test directory node with children
FileNode createTestDirectoryNode({
  String path = 'lib',
  String name = 'lib',
  required List<FileNode> children,
}) {
  return FileNode(
    path: path,
    name: name,
    isDirectory: true,
    children: children,
  );
}

/// Create a test file tree structure
FileNode createTestFileTree() {
  return FileNode(
    path: 'root',
    name: 'root',
    isDirectory: true,
    children: [
      FileNode(
        path: 'root/lib',
        name: 'lib',
        isDirectory: true,
        children: [
          FileNode(path: 'root/lib/main.dart', name: 'main.dart', isDirectory: false),
          FileNode(path: 'root/lib/app.dart', name: 'app.dart', isDirectory: false),
          FileNode(
            path: 'root/lib/features',
            name: 'features',
            isDirectory: true,
            children: [
              FileNode(
                path: 'root/lib/features/home',
                name: 'home',
                isDirectory: true,
                children: [
                  FileNode(path: 'root/lib/features/home/screen.dart', name: 'screen.dart', isDirectory: false),
                  FileNode(path: 'root/lib/features/home/notifier.dart', name: 'notifier.dart', isDirectory: false),
                ],
              ),
            ],
          ),
        ],
      ),
      FileNode(
        path: 'root/test',
        name: 'test',
        isDirectory: true,
        children: [
          FileNode(path: 'root/test/main_test.dart', name: 'main_test.dart', isDirectory: false),
        ],
      ),
      FileNode(path: 'root/README.md', name: 'README.md', isDirectory: false),
      FileNode(path: 'root/pubspec.yaml', name: 'pubspec.yaml', isDirectory: false),
    ],
  );
}
