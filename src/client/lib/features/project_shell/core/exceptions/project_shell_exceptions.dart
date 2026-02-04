// lib/features/project_shell/core/exceptions/project_shell_exceptions.dart
import 'dart:developer' as developer;

/// Base exception for all project shell errors
abstract class ProjectShellException implements Exception {
  ProjectShellException({
    required this.code,
    required this.message,
    this.originalError,
    this.stackTrace,
  }) {
    // Log error for debugging in development
    developer.log(
      'ProjectShellException[$code]: $message',
      error: originalError,
      stackTrace: stackTrace,
    );
  }
  final String code;
  final String message;
  final dynamic originalError;
  final StackTrace? stackTrace;

  @override
  String toString() => 'ProjectShellException[$code]: $message';

  /// Convert to user-friendly error message
  String toUserMessage() => message;
}

/// Project name validation failed
class InvalidProjectNameException extends ProjectShellException {
  InvalidProjectNameException(String name, {super.stackTrace})
      : super(
          code: 'PROJ_001',
          message:
              'Invalid project name: $name. Must be 3-50 alphanumeric/dash/underscore.',
        );

  @override
  String toUserMessage() =>
      'El nombre del proyecto debe tener 3-50 caracteres (letras, números, guiones, guiones bajos)';
}

/// Project name already exists in database
class DuplicateProjectNameException extends ProjectShellException {
  DuplicateProjectNameException(String name, {super.stackTrace})
      : super(code: 'PROJ_002', message: 'Project name already exists: $name');

  @override
  String toUserMessage() => 'Ya existe un proyecto con ese nombre.';
}

/// Security: Path traversal attempt detected
class PathTraversalException extends ProjectShellException {
  PathTraversalException(String message, {super.stackTrace})
      : super(code: 'SEC_001', message: 'Path traversal detected: $message');

  @override
  String toUserMessage() =>
      'Ruta de archivo inválida. No se pueden usar rutas relativas con "..".';
}

/// Database operation failed
class DatabaseException extends ProjectShellException {
  DatabaseException(
    String message, {
    super.originalError,
    super.stackTrace,
  }) : super(
          code: 'DB_ERR_001',
          message: message,
        );

  @override
  String toUserMessage() =>
      'Error en la base de datos. Por favor, intenta de nuevo.';
}

/// File system operation failed
class FileSystemException extends ProjectShellException {
  FileSystemException(
    String message, {
    super.originalError,
    super.stackTrace,
  }) : super(
          code: 'FS_ERR_001',
          message: message,
        );

  @override
  String toUserMessage() =>
      'Error al acceder al sistema de archivos. Verifica permisos.';
}

/// Project not found
class ProjectNotFoundException extends ProjectShellException {
  ProjectNotFoundException(String projectId, {super.stackTrace})
      : super(
          code: 'PROJ_003',
          message: 'Project not found: $projectId',
        );

  @override
  String toUserMessage() => 'El proyecto no existe.';
}

/// Invalid file type
class InvalidFileTypeException extends ProjectShellException {
  InvalidFileTypeException(String fileName, {super.stackTrace})
      : super(
          code: 'FILE_001',
          message: 'Invalid file type: $fileName',
        );

  @override
  String toUserMessage() =>
      'Tipo de archivo no permitido. Solo se permiten ciertos tipos.';
}

/// Unauthorized access attempt
class UnauthorizedException extends ProjectShellException {
  UnauthorizedException(String reason, {super.stackTrace})
      : super(
          code: 'SEC_002',
          message: 'Unauthorized access: $reason',
        );

  @override
  String toUserMessage() => 'No tienes permiso para realizar esta acción.';
}
