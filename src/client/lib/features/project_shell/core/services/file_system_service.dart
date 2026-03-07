import 'dart:io';

import 'package:path/path.dart' as p;

/// Abstract service for FileSystem operations.
/// Abstracts platform differences and enables testing via mocks.
abstract class FileSystemService {
  /// Saves a document to disk at the specified path.
  Future<void> saveDocument({
    required String projectPath,
    required String relativePath,
    required String content,
  });

  /// Reads a document from disk.
  Future<String?> readDocument({
    required String projectPath,
    required String relativePath,
  });

  /// Checks if a document exists.
  Future<bool> documentExists({
    required String projectPath,
    required String relativePath,
  });

  /// Deletes a document.
  Future<void> deleteDocument({
    required String projectPath,
    required String relativePath,
  });

  /// Creates required directory structure for a project.
  Future<void> initializeProjectDirectories({required String projectPath});
}

/// Implementation of FileSystemService for Desktop/Mobile platforms.
class FileSystemServiceImpl implements FileSystemService {
  @override
  Future<void> saveDocument({
    required String projectPath,
    required String relativePath,
    required String content,
  }) async {
    try {
      // 1. Limpiamos la barra inicial si viene en el relativePath
      final cleanRelativePath = relativePath.startsWith('/')
          ? relativePath.substring(1)
          : relativePath;

      // 2. Unimos de forma segura para cualquier sistema operativo
      final fullPath = p.join(projectPath, cleanRelativePath);
      final file = File(fullPath);

      // 3. 🎯 LA MAGIA: Nos aseguramos de que toda la cadena de carpetas exista
      final directory = file.parent;
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }

      // 4. Escribimos el contenido
      await file.writeAsString(content, flush: true);
    } catch (e) {
      throw FileSystemException('Failed to save document: $e');
    }
  }

  @override
  Future<String?> readDocument({
    required String projectPath,
    required String relativePath,
  }) async {
    try {
      final cleanRelativePath = relativePath.startsWith('/')
          ? relativePath.substring(1)
          : relativePath;
      final fullPath = p.join(projectPath, cleanRelativePath);
      final file = File(fullPath);

      if (!await file.exists()) {
        return null;
      }

      return file.readAsString();
    } catch (e) {
      throw FileSystemException('Failed to read document: $e');
    }
  }

  @override
  Future<bool> documentExists({
    required String projectPath,
    required String relativePath,
  }) async {
    final cleanRelativePath = relativePath.startsWith('/')
        ? relativePath.substring(1)
        : relativePath;
    final fullPath = p.join(projectPath, cleanRelativePath);
    final file = File(fullPath);
    return file.exists();
  }

  @override
  Future<void> deleteDocument({
    required String projectPath,
    required String relativePath,
  }) async {
    try {
      final cleanRelativePath = relativePath.startsWith('/')
          ? relativePath.substring(1)
          : relativePath;
      final fullPath = p.join(projectPath, cleanRelativePath);
      final file = File(fullPath);

      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      throw FileSystemException('Failed to delete document: $e');
    }
  }

  @override
  Future<void> initializeProjectDirectories({
    required String projectPath,
  }) async {
    final directories = [
      '10-CONTEXT',
      '20-REQUIREMENTS_AND_SPEC',
      '30-ARCHITECTURE',
      '40-ROADMAP',
    ];

    for (final dir in directories) {
      try {
        await Directory(p.join(projectPath, dir)).create(recursive: true);
      } catch (e) {
        throw FileSystemException('Failed to create directory $dir: $e');
      }
    }
  }
}

/// Custom exception for FileSystem operations
class FileSystemException implements Exception {
  FileSystemException(this.message);
  final String message;

  @override
  String toString() => message;
}
