// ignore_for_file: always_put_control_body_on_new_line, avoid_slow_async_io, avoid_catches_without_on_clauses, lines_longer_than_80_chars, cascade_invocations

import 'dart:io';

import 'package:path/path.dart' as p;

/// Service for filesystem operations
/// Encapsulates all file and directory creation logic
class FilesystemService {
  /// Creates the complete structure for a new project
  /// Includes base directories
  Future<void> createProjectStructure(
    String basePath,
    String projectName,
    String description,
  ) async {
    final fullProjectPath = p.join(basePath, projectName);
    final contextPath = p.join(fullProjectPath, 'context');

    final projectDir = Directory(fullProjectPath);

    // Verificar si ya existe
    if (await projectDir.exists()) {
      throw Exception(
        'Ya existe una carpeta con ese nombre en la ruta seleccionada',
      );
    }

    // Create directories
    await projectDir.create(recursive: true);
    await Directory(contextPath).create();
  }

  /// Creates a directory at the specified path
  Future<void> createDirectory(String path) async {
    await Directory(path).create(recursive: true);
  }

  /// Creates a file with the specified content
  Future<void> createFile(String path, String content) async {
    final file = File(path);
    await file.writeAsString(content);
  }
}
