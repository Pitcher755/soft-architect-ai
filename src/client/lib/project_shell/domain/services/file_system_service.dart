import 'dart:io';

/// Abstract service for FileSystem operations.
/// Abstracts platform differences and enables testing via mocks.
abstract class FileSystemService {
  /// Saves a document to disk at the specified path.
  ///
  /// Parameters:
  ///   - projectPath: Root project path (e.g., '/home/user/project')
  ///   - relativePath: Path relative to project root (e.g., '10-CONTEXT/PROJECT_MANIFESTO.md')
  ///   - content: Document content to write
  ///
  /// Throws:
  ///   - [FileSystemException] if directory creation fails
  ///   - [FileSystemException] if file write fails
  Future<void> saveDocument({
    required String projectPath,
    required String relativePath,
    required String content,
  });

  /// Reads a document from disk.
  ///
  /// Returns null if file doesn't exist.
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
      final fullPath = '$projectPath/$relativePath';
      final file = File(fullPath);

      // Ensure parent directory exists
      // ignore: avoid_slow_async_io
      await file.parent.create(recursive: true);

      // Write content
      // ignore: avoid_slow_async_io
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
      final fullPath = '$projectPath/$relativePath';
      final file = File(fullPath);

      // ignore: avoid_slow_async_io
      if (!await file.exists()) {
        return null;
      }

      // ignore: avoid_slow_async_io
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
    final fullPath = '$projectPath/$relativePath';
    final file = File(fullPath);
    // ignore: avoid_slow_async_io
    return file.exists();
  }

  @override
  Future<void> deleteDocument({
    required String projectPath,
    required String relativePath,
  }) async {
    try {
      final fullPath = '$projectPath/$relativePath';
      final file = File(fullPath);

      // ignore: avoid_slow_async_io
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
        // ignore: avoid_slow_async_io
        await Directory('$projectPath/$dir').create(recursive: true);
      } catch (e) {
        throw FileSystemException('Failed to create directory $dir: $e');
      }
    }
  }
}
