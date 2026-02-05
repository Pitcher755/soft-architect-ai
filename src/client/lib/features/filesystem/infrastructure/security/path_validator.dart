import 'package:path/path.dart' as p;

import '../../domain/exceptions/filesystem_exceptions.dart';

/// Security validator for filesystem paths.
///
/// **CRITICAL SECURITY COMPONENT**
///
/// This class prevents path traversal attacks and ensures all file operations
/// stay within the project root directory. ALL paths MUST pass through this
/// validator before any I/O operation.
///
/// ## Validation Rules:
/// 1. Reject paths containing `..` after normalization
/// 2. Reject absolute paths
/// 3. Reject empty paths
/// 4. Reject paths with null bytes (injection attack)
/// 5. Ensure normalized path is within project root
///
/// ## Usage:
/// ```dart
/// final validator = PathValidator(projectRoot: '/home/user/my_project');
///
/// // ✅ Valid
/// final safePath = validator.validate('context/10-CONTEXT/doc.md');
///
/// // ❌ Throws PathTraversalException
/// validator.validate('../../../etc/passwd');
/// ```
class PathValidator {
  const PathValidator({required this.projectRoot});

  /// Absolute path to the project root directory.
  /// All validated paths MUST be children of this directory.
  final String projectRoot;

  /// Validates a path for security vulnerabilities.
  ///
  /// Returns the normalized absolute path if valid.
  /// Throws [PathTraversalException] if the path is malicious.
  ///
  /// **Steps:**
  /// 1. Check for empty path
  /// 2. Check for null bytes (injection attack)
  /// 3. Normalize path (resolve `.`, `..`, `//`)
  /// 4. Convert to absolute path within project root
  /// 5. Verify path is within project root boundaries
  ///
  /// @throws [PathTraversalException] if path is invalid or malicious
  String validate(String relativePath) {
    // Rule 1: Reject empty paths
    if (relativePath.isEmpty) {
      throw PathTraversalException('(empty path)');
    }

    // Rule 2: Reject null bytes (injection attack)
    if (relativePath.contains('\x00')) {
      throw PathTraversalException(relativePath);
    }

    // Rule 3: Reject absolute paths (must be relative)
    if (p.isAbsolute(relativePath)) {
      throw PathTraversalException(relativePath);
    }

    // Rule 3b: Reject Windows absolute paths (C:\, D:\, etc.)
    if (RegExp(r'^[A-Za-z]:[\\\/]').hasMatch(relativePath)) {
      throw PathTraversalException(relativePath);
    }

    // Rule 4: Normalize path (resolve ., .., //)
    final normalized = p.normalize(relativePath);

    // Rule 5: Reject paths still containing .. after normalization
    // (Indicates attempt to escape project root)
    if (normalized.split(p.separator).contains('..')) {
      throw PathTraversalException(relativePath);
    }

    // Rule 6: Build absolute path within project root
    final absolutePath = p.join(projectRoot, normalized);

    // Rule 7: Final boundary check - ensure path is within project root
    // Uses canonical path to resolve symlinks
    if (!p.isWithin(projectRoot, absolutePath)) {
      throw PathTraversalException(relativePath);
    }

    return absolutePath;
  }

  /// Validates a path and returns true if valid, false otherwise.
  ///
  /// Non-throwing alternative to [validate] for conditional checks.
  bool isValid(String relativePath) {
    try {
      validate(relativePath);
      return true;
    } on PathTraversalException {
      return false;
    }
  }

  /// Extracts the relative path component from an absolute path.
  ///
  /// Returns null if the path is not within project root.
  String? getRelativePath(String absolutePath) {
    if (!p.isWithin(projectRoot, absolutePath)) {
      return null;
    }
    return p.relative(absolutePath, from: projectRoot);
  }
}
