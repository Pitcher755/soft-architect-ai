// lib/features/project_shell/core/security/path_validator.dart
import 'package:path/path.dart' as p;
import '../constants/validation_constants.dart';
import '../exceptions/project_shell_exceptions.dart';

/// Path security validation - prevents path traversal attacks
class PathValidator {
  /// Validate and normalize file path within project boundaries
  ///
  /// Security checks:
  /// - Rejects absolute paths
  /// - Rejects path traversal attempts (..)
  /// - Validates path length
  /// - Ensures file stays within project directory
  static String validateFilePathInProject({
    required String projectPath,
    required String filePath,
  }) {
    // Normalize the file path
    final normalized = p.normalize(filePath);

    // ❌ REJECT: Absolute paths
    if (p.isAbsolute(normalized)) {
      throw PathTraversalException(
        'Absolute paths not allowed: $normalized',
      );
    }

    // ❌ REJECT: Path traversal attempts
    for (final disallowed in ValidationConstants.disallowedPathComponents) {
      if (normalized.contains(disallowed)) {
        throw PathTraversalException(
          'Disallowed path component "$disallowed" in: $normalized',
        );
      }
    }

    // ❌ REJECT: Excessive path length (DoS prevention)
    if (filePath.length > ValidationConstants.maxFilePathLength) {
      throw PathTraversalException(
        'Path length exceeds maximum (${ValidationConstants.maxFilePathLength})',
      );
    }

    // ✅ CONSTRUCT: Safe path within project boundary
    final fullPath = p.normalize(p.join(projectPath, normalized));

    // ✅ VALIDATE: Verify file is still within project directory
    if (!fullPath.startsWith(projectPath)) {
      throw PathTraversalException(
        'File path escapes project directory boundary',
      );
    }

    return fullPath;
  }

  /// Validate project directory path
  static void validateProjectPath(String projectPath) {
    if (projectPath.isEmpty) {
      throw PathTraversalException('Project path cannot be empty');
    }

    if (projectPath.length > ValidationConstants.maxFilePathLength) {
      throw PathTraversalException('Project path exceeds maximum length');
    }

    // Ensure it's an absolute path (project root must be absolute)
    if (!p.isAbsolute(projectPath)) {
      throw PathTraversalException('Project path must be absolute');
    }
  }

  /// Check if file extension is allowed
  static bool isFileExtensionAllowed(String fileName) {
    // If no extension, check if it's an allowed file (like README, Makefile)
    final extension = p.extension(fileName).toLowerCase();

    if (extension.isEmpty) {
      // Check base name
      return ValidationConstants.allowedFileExtensions.contains(fileName);
    }

    return ValidationConstants.allowedFileExtensions.contains(extension);
  }

  /// Validate file extension or throw exception
  static void validateFileExtensionOrThrow(String fileName) {
    if (!isFileExtensionAllowed(fileName)) {
      throw InvalidFileTypeException(fileName);
    }
  }
}
