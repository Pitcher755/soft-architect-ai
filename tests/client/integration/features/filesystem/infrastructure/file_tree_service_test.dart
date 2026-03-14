import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;
import 'package:softarchitect_ai/features/filesystem/domain/entities/file_node.dart';
import 'package:softarchitect_ai/features/filesystem/infrastructure/services/file_tree_service.dart';

void main() {
  group('FileTreeService - Absolute Path Validation', () {
    late Directory tempDir;
    late String projectRoot;

    setUp(() async {
      // Create temporary directory structure for testing
      tempDir = await Directory.systemTemp.createTemp('file_tree_test_');
      projectRoot = tempDir.path;

      // Create subdirectories and files
      await Directory(p.join(projectRoot, 'src')).create();
      await Directory(p.join(projectRoot, 'src', 'core')).create();
      await Directory(p.join(projectRoot, 'doc')).create();

      await File(p.join(projectRoot, 'README.md')).writeAsString('# Test');
      await File(p.join(projectRoot, 'src', 'main.dart'))
          .writeAsString('void main() {}');
      await File(p.join(projectRoot, 'src', 'core', 'app.dart'))
          .writeAsString('class App {}');
      await File(p.join(projectRoot, 'doc', 'GUIDE.md'))
          .writeAsString('# Guide');
    });

    tearDown(() async {
      // Clean up temporary directory
      if (await tempDir.exists()) {
        await tempDir.delete(recursive: true);
      }
    });

    test('should return absolute path for root node', () async {
      // Act
      final tree = await FileTreeService.buildTreeFromPath(projectRoot);

      // Assert
      expect(tree.path, isNotNull);
      expect(p.isAbsolute(tree.path), isTrue,
          reason: 'Root path should be absolute');
      expect(tree.path, equals(projectRoot));
    });

    test('should return absolute paths for all child files', () async {
      // Act
      final tree = await FileTreeService.buildTreeFromPath(projectRoot);

      // Assert
      void validateAbsolutePaths(FileNode node) {
        expect(p.isAbsolute(node.path), isTrue,
            reason: 'Path "${node.path}" should be absolute');

        if (node.isDirectory) {
          for (final child in node.children) {
            validateAbsolutePaths(child);
          }
        }
      }

      validateAbsolutePaths(tree);
    });

    test('should return absolute paths for nested directory structure',
        () async {
      // Act
      final tree = await FileTreeService.buildTreeFromPath(projectRoot);

      // Find src/core/app.dart (nested 2 levels deep)
      final srcNode = tree.children.firstWhere((n) => n.name == 'src');
      final coreNode = srcNode.children.firstWhere((n) => n.name == 'core');
      final appNode = coreNode.children.firstWhere((n) => n.name == 'app.dart');

      // Assert
      expect(p.isAbsolute(appNode.path), isTrue);
      expect(appNode.path, equals(p.join(projectRoot, 'src', 'core', 'app.dart')));
    });

    test('should allow File() constructor to read file content directly',
        () async {
      // Act
      final tree = await FileTreeService.buildTreeFromPath(projectRoot);

      // Find README.md
      final readmeNode =
          tree.children.firstWhere((n) => n.name == 'README.md');

      // Assert: path is absolute and can be used directly with File()
      expect(p.isAbsolute(readmeNode.path), isTrue);

      // ✅ CRITICAL TEST: File() should not throw PathNotFoundException
      final file = File(readmeNode.path);
      final content = await file.readAsString();
      expect(content, equals('# Test'));
    });

    test('should handle paths with File() constructor for nested files',
        () async {
      // Act
      final tree = await FileTreeService.buildTreeFromPath(projectRoot);

      // Navigate to nested file
      final srcNode = tree.children.firstWhere((n) => n.name == 'src');
      final mainNode =
          srcNode.children.firstWhere((n) => n.name == 'main.dart');

      // Assert: File() constructor works without path resolution
      final file = File(mainNode.path);
      expect(await file.exists(), isTrue);

      final content = await file.readAsString();
      expect(content, equals('void main() {}'));
    });

    test('should return consistent absolute paths across tree traversal',
        () async {
      // Act
      final tree = await FileTreeService.buildTreeFromPath(projectRoot);

      // Collect all paths
      final allPaths = <String>[];
      void collectPaths(FileNode node) {
        allPaths.add(node.path);
        if (node.isDirectory) {
          for (final child in node.children) {
            collectPaths(child);
          }
        }
      }

      collectPaths(tree);

      // Assert: All paths are absolute and start with project root
      for (final path in allPaths) {
        expect(p.isAbsolute(path), isTrue,
            reason: 'Path "$path" should be absolute');
        expect(path.startsWith(projectRoot), isTrue,
            reason: 'Path "$path" should start with project root');
      }
    });

    test('should not throw PathNotFoundException when opening files from tree',
        () async {
      // Act
      final tree = await FileTreeService.buildTreeFromPath(projectRoot);

      // Collect all file nodes (non-directories)
      final fileNodes = <FileNode>[];
      void collectFiles(FileNode node) {
        if (!node.isDirectory) {
          fileNodes.add(node);
        } else {
          for (final child in node.children) {
            collectFiles(child);
          }
        }
      }

      collectFiles(tree);

      // Assert: All file paths can be opened with File() constructor
      for (final fileNode in fileNodes) {
        expect(
          () async {
            final file = File(fileNode.path);
            await file.readAsString();
          },
          returnsNormally,
          reason:
              'File "${fileNode.name}" with path "${fileNode.path}" should be readable',
        );
      }
    });
  });
}
