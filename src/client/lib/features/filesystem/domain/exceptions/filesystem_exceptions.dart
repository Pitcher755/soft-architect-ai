/// Domain layer exceptions for filesystem operations.
/// These exceptions represent business logic failures and security violations.
///
/// DO NOT catch these exceptions and silently ignore them.
/// Always propagate to the presentation layer for user notification.
library;

/// Base class for all filesystem-related exceptions.
///
/// Each exception MUST have:
/// - [message]: User-friendly description (Spanish for MVP)
/// - [code]: Unique error code (e.g., "FS_001")
/// - [details]: Optional technical details for logging
abstract class FileSystemException implements Exception {
  const FileSystemException({
    required this.message,
    required this.code,
    this.details,
  });

  /// User-facing error message (localized)
  final String message;

  /// Unique error code for tracking and debugging
  final String code;

  /// Optional technical details (NOT shown to user)
  final Map<String, dynamic>? details;

  @override
  String toString() => '[$code] $message';
}

/// Security violation: Attempted path traversal attack.
///
/// Triggered when:
/// - Input contains `../` sequences
/// - Absolute paths are provided (e.g., `/etc/passwd`, `C:\Windows\System32`)
/// - Normalized path escapes project root
///
/// **CRITICAL:** Log this exception immediately - it's a security incident.
class PathTraversalException extends FileSystemException {
  PathTraversalException(String attemptedPath)
    : super(
        message: 'Intento de acceso ilegal a ruta: $attemptedPath',
        code: 'SEC_001',
        details: {'attempted_path': attemptedPath},
      );
}

/// Disk I/O failure: Insufficient disk space.
///
/// Triggered when:
/// - `FileSystemException` with error code `No space left on device`
/// - Disk quota exceeded
class DiskSpaceException extends FileSystemException {
  DiskSpaceException(String path, int requiredBytes)
    : super(
        message: 'No hay espacio en disco para guardar el archivo',
        code: 'FS_001',
        details: {'path': path, 'required_bytes': requiredBytes},
      );
}

/// Disk I/O failure: Permission denied.
///
/// Triggered when:
/// - User lacks write permissions to target directory
/// - Directory is read-only
/// - File is locked by another process
class PermissionDeniedException extends FileSystemException {
  PermissionDeniedException(String path)
    : super(
        message: 'No tienes permisos para escribir en: $path',
        code: 'FS_002',
        details: {'path': path},
      );
}

/// File not found during read operation.
///
/// Triggered when:
/// - Attempting to read a non-existent file
/// - File was deleted concurrently
class FileNotFoundException extends FileSystemException {
  FileNotFoundException(String path)
    : super(
        message: 'Archivo no encontrado: $path',
        code: 'FS_003',
        details: {'path': path},
      );
}

/// Invalid file operation (e.g., writing to a directory).
///
/// Triggered when:
/// - Attempting to write content to a directory path
/// - Creating a file with invalid characters in name
class InvalidFileOperationException extends FileSystemException {
  InvalidFileOperationException(String operation, String reason)
    : super(
        message: 'Operación inválida: $operation. Razón: $reason',
        code: 'FS_004',
        details: {'operation': operation, 'reason': reason},
      );
}
