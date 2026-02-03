// lib/features/project_shell/core/exceptions/project_shell_exceptions.dart

/// Base exception for all project shell errors
abstract class ProjectShellException implements Exception {
  final String code;
  final String message;
  final dynamic originalError;

  ProjectShellException({
    required this.code,
    required this.message,
    this.originalError,
  });

  @override
  String toString() => 'ProjectShellException[$code]: $message';
}

/// Project name validation failed
class InvalidProjectNameException extends ProjectShellException {
  InvalidProjectNameException(String name)
      : super(
          code: 'PROJ_001',
          message: 'Invalid project name: $name. Must be 3-50 alphanumeric/dash/underscore.',
        );
}

/// Project name already exists in database
class DuplicateProjectNameException extends ProjectShellException {
  DuplicateProjectNameException(String name)
      : super(
          code: 'PROJ_002',
          message: 'Project name already exists: $name',
        );
}

/// Security: Path traversal attempt detected
class PathTraversalException extends ProjectShellException {
  PathTraversalException(String message)
      : super(
          code: 'SEC_001',
          message: 'Path traversal detected: $message',
        );
}

/// Database operation failed
class DatabaseException extends ProjectShellException {
  DatabaseException(String message, {dynamic originalError})
      : super(
          code: 'DB_ERR_001',
          message: message,
          originalError: originalError,
        );
}

/// File system operation failed
class FileSystemException extends ProjectShellException {
  FileSystemException(String message, {dynamic originalError})
      : super(
          code: 'FS_ERR_001',
          message: message,
          originalError: originalError,
        );
}
