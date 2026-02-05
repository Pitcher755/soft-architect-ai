import 'dart:io';

import '../exceptions/filesystem_exceptions.dart'
    show
        PermissionDeniedException,
        DiskSpaceException,
        PathTraversalException,
        FileNotFoundException;

/// Abstract repository for filesystem operations.
///
/// This interface defines the contract for filesystem I/O operations.
/// All implementations MUST validate paths before performing I/O.
///
/// **Architectural Note:**
/// - Domain layer (pure business logic)
/// - Infrastructure layer provides concrete implementation
/// - Presentation layer consumes via Riverpod providers
abstract class FileSystemRepository {
  /// Creates the standard project directory structure.
  ///
  /// Structure:
  /// ```
  /// (projectRoot)/
  /// ├── context/
  /// │   ├── 10-CONTEXT/
  /// │   ├── 20-REQUIREMENTS/
  /// │   ├── 30-ARCHITECTURE/
  /// │   ├── 35-UX_UI/
  /// │   └── 40-PLANNING/
  /// ├── README.md
  /// └── AGENTS.md (optional)
  /// ```
  ///
  /// **Idempotent:** Safe to call multiple times, won't fail if dirs exist.
  ///
  /// @param projectRoot Absolute path to project root
  /// @throws [PermissionDeniedException] if user lacks write permissions
  /// @throws [DiskSpaceException] if insufficient disk space
  Future<void> initProjectStructure(String projectRoot);

  /// Saves a file with the given content.
  ///
  /// **Security:** Path MUST be validated before I/O.
  ///
  /// @param relativePath Path relative to project root (e.g., 'context/10-CONTEXT/doc.md')
  /// @param content UTF-8 text content
  /// @param createDirs If true, creates parent directories if missing
  /// @throws [PathTraversalException] if path is invalid
  /// @throws [PermissionDeniedException] if user lacks write permissions
  /// @throws [DiskSpaceException] if insufficient disk space
  Future<File> saveFile({
    required String relativePath,
    required String content,
    bool createDirs = true,
  });

  /// Reads a file's content.
  ///
  /// @param relativePath Path relative to project root
  /// @throws [FileNotFoundException] if file doesn't exist
  /// @throws [PathTraversalException] if path is invalid
  Future<String> readFile(String relativePath);

  /// Checks if a file exists.
  ///
  /// @param relativePath Path relative to project root
  /// @throws [PathTraversalException] if path is invalid
  Future<bool> fileExists(String relativePath);

  /// Lists all files in a directory recursively.
  ///
  /// @param relativePath Directory path relative to project root
  /// @param extensions Optional filter by file extensions
  ///   (e.g., ['.md', '.txt'])
  /// @throws [PathTraversalException] if path is invalid
  Future<List<String>> listFiles({
    required String relativePath,
    List<String>? extensions,
  });

  /// Deletes a file.
  ///
  /// @param relativePath Path relative to project root
  /// @throws [FileNotFoundException] if file doesn't exist
  /// @throws [PathTraversalException] if path is invalid
  Future<void> deleteFile(String relativePath);
}
