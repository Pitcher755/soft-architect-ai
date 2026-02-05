import '../../domain/exceptions/filesystem_exceptions.dart';

/// Converts domain exceptions to user-friendly messages.
///
/// These messages are designed for dark-themed UI (matching HTML design).
class FileSystemErrorMessages {
  /// Converts any exception to a user-friendly Spanish message.
  static String getMessage(Exception exception) {
    if (exception is PathTraversalException) {
      return '🚫 Ruta inválida o peligrosa detectada. Por seguridad, '
          'esta operación fue bloqueada.';
    } else if (exception is DiskSpaceException) {
      return '💾 No hay espacio suficiente en disco para completar '
          'la operación.';
    } else if (exception is PermissionDeniedException) {
      return '🔒 No tienes permisos para escribir en esta ubicación.';
    } else if (exception is FileNotFoundException) {
      return '📄 El archivo solicitado no existe.';
    } else if (exception is InvalidFileOperationException) {
      return '⚠️ Operación de archivo inválida.';
    } else {
      return '❌ Error inesperado: ${exception.toString()}';
    }
  }

  /// Gets the error code from domain exception.
  static String? getCode(Exception exception) {
    if (exception is FileSystemException) {
      return exception.code;
    }
    return null;
  }

  /// Checks if exception is a security violation.
  static bool isSecurityViolation(Exception exception) =>
      exception is PathTraversalException;
}
