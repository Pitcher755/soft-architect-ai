/// Maps backend error codes to user-friendly Spanish messages.
///
/// This class provides localized error messages and actionable suggestions
/// for error codes returned by the backend API. All messages are in Spanish
/// and avoid technical jargon.
///
/// Example:
/// ```dart
/// final mapper = ErrorMapper();
/// final message = mapper.getUserMessage('SYS_001');
/// // Returns: "🔌 No hay conexión con el servidor local"
/// ```
class ErrorMapper {
  /// Error code to message mapping.
  static const Map<String, String> _messages = {
    // System Errors
    'SYS_001': '🔌 No hay conexión con el servidor local',
    'SYS_002': '💾 La memoria de tu tarjeta gráfica está llena',
    'SYS_RETRY_EXHAUSTED': '⏱️ La operación falló después de varios intentos',

    // Authentication Errors
    'AUTH_001': '🔑 Falta la clave de API de Groq Cloud',

    // RAG Errors
    'RAG_001': '📚 La base de conocimiento está vacía',
    'RAG_002': '💬 La conversación es demasiado larga',

    // Validation Errors
    'VAL_001': '📝 El documento generado es inválido (muy corto)',
    'VAL_002': '📝 El documento tiene formato Markdown incorrecto',
    'VAL_003': '📝 El documento tiene problemas de codificación',
    'VAL_004': '⚠️ El documento contiene contenido sospechoso',
    'VAL_005': '📦 El documento es demasiado grande',
  };

  /// Suggestions for each error code.
  static const Map<String, String> _suggestions = {
    'SYS_001': 'Verifica que Docker esté ejecutándose',
    'SYS_002': 'Cierra otros programas o cambia a modo Cloud',
    'SYS_RETRY_EXHAUSTED': 'Intenta nuevamente en unos momentos',
    'AUTH_001': 'Ve a Configuración y agrega tu clave de API',
    'RAG_001': 'Ejecuta "Cargar Base de Conocimiento"',
    'RAG_002': 'Inicia una nueva conversación',
    'VAL_001': 'Intenta generar el documento nuevamente',
    'VAL_002': 'Revisa la estructura del documento',
    'VAL_003': 'Asegúrate de usar texto en UTF-8',
    'VAL_004': 'Contacta al soporte si el problema persiste',
    'VAL_005': 'Reduce el tamaño del documento',
  };

  /// Get user-friendly message for error code.
  ///
  /// Returns a localized Spanish message for the given error code.
  /// If the error code is unknown, returns a generic error message.
  static String getUserMessage(String errorCode) =>
      _messages[errorCode] ?? '🤔 Ocurrió un error ($errorCode)';

  /// Get actionable suggestion for error code.
  ///
  /// Returns a localized Spanish suggestion for resolving the error.
  /// If the error code is unknown, returns a generic suggestion.
  static String getSuggestion(String errorCode) =>
      _suggestions[errorCode] ?? 'Intenta nuevamente o contacta al soporte';

  /// Check if error is retryable.
  ///
  /// Returns true if the error can be retried by the user.
  /// Retryable errors are typically transient (network, resources).
  /// Non-retryable errors require user action (authentication, validation).
  static bool isRetryable(String errorCode) => [
        'SYS_001', // Connection error
        'SYS_002', // Out of memory
        'SYS_RETRY_EXHAUSTED', // Retry exhausted
        'RAG_001', // Empty knowledge base
        'VAL_001', // Document too short (regenerate)
        'VAL_002', // Invalid Markdown (regenerate)
      ].contains(errorCode);
}
