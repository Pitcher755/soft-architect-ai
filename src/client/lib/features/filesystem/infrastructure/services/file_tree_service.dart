// ignore_for_file: always_put_control_body_on_new_line, avoid_slow_async_io, avoid_catches_without_on_clauses, lines_longer_than_80_chars, cascade_invocations

import 'dart:io';
import 'package:path/path.dart' as p;

import '../../domain/entities/file_node.dart';

/// Infrastructure service specialized in hierarchical reading.
///
/// Converts the physical disk structure ([dart:io]) into domain entities
/// ([FileNode]) for the UI. Ensures all paths are absolute to prevent
/// [PathNotFoundException] when files are accessed by widgets.
///
/// **Critical:** All [FileNode.path] values are guaranteed to be absolute paths,
/// allowing direct usage with [File(path).readAsString()] without resolution.
class FileTreeService {
  /// Builds the complete tree from a root path.
  ///
  /// Returns a [FileNode] tree where all `path` properties contain
  /// **absolute paths**, ensuring widgets can directly open files.
  ///
  /// Example:
  /// ```dart
  /// final tree = await FileTreeService.buildTreeFromPath('/home/user/project');
  /// // tree.children[0].path -> '/home/user/project/context/README.md' (absolute)
  /// ```
  static Future<FileNode> buildTreeFromPath(String rootPath) async {
    final rootDir = Directory(rootPath);

    // 1. Defensive validation
    if (!await rootDir.exists()) {
      return FileNode(
        id: 'error_root',
        name: 'Path not found',
        path: rootPath,
        isDirectory: true,
        children: [],
      );
    }

    final rootName = p.basename(rootPath);

    // 2. Recursion with absolute path guarantee
    final node = await _buildNodeRecursive(rootDir);

    // 3. Return the root with formatted name (uppercase for project)
    return FileNode(
      id: node.id,
      name: rootName.toUpperCase(),
      path: node.path,
      isDirectory: node.isDirectory,
      children: node.children,
    );
  }

  /// Recursively builds [FileNode] tree ensuring all paths are absolute.
  ///
  /// Uses [FileSystemEntity.absolute] to guarantee path resolution.
  static Future<FileNode> _buildNodeRecursive(FileSystemEntity entity) async {
    final stat = await entity.stat();
    final isDirectory = stat.type == FileSystemEntityType.directory;
    final name = p.basename(entity.path);
    final children = <FileNode>[];

    // ✅ CRITICAL FIX: Use absolute path to prevent PathNotFoundException
    final absolutePath = entity.absolute.path;

    if (isDirectory) {
      try {
        final dir = Directory(entity.path);
        final entities = await dir.list().toList();

        // Sort: Folders first, then files (alphabetically)
        entities.sort((a, b) {
          final aIsDir = FileSystemEntity.isDirectorySync(a.path);
          final bIsDir = FileSystemEntity.isDirectorySync(b.path);
          if (aIsDir && !bIsDir) return -1;
          if (!aIsDir && bIsDir) return 1;
          return p
              .basename(a.path)
              .toLowerCase()
              .compareTo(p.basename(b.path).toLowerCase());
        });

        for (final child in entities) {
          // Filter hidden files (.git, .DS_Store, etc.)
          if (!p.basename(child.path).startsWith('.')) {
            children.add(await _buildNodeRecursive(child));
          }
        }
      } catch (e) {
        // Ignore access errors
      }
    }

    return FileNode(
      id: absolutePath, // Unique ID = absolute path
      name: name,
      path: absolutePath, // ✅ Absolute path for direct File() access
      isDirectory: isDirectory,
      children: children,
    );
  }
}
