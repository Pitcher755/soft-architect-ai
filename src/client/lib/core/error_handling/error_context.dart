/// Context information for error tracking and debugging.
///
/// Stores metadata about errors for audit trail and user-friendly display.
class ErrorContext {
  /// Technical error code (e.g., 'SYS_001', 'VAL_002')
  final String errorCode;

  /// User-friendly error message in Spanish
  final String message;

  /// Actionable suggestion for user
  final String suggestion;

  /// Whether the error is retryable (transient failure)
  final bool isRetryable;

  /// Timestamp when error occurred
  final DateTime timestamp;

  /// Optional additional context (operation name, user action, etc.)
  final Map<String, dynamic>? metadata;

  /// Creates an error context instance.
  ErrorContext({
    required this.errorCode,
    required this.message,
    required this.suggestion,
    required this.isRetryable,
    this.metadata,
  }) : timestamp = DateTime.now();

  /// Creates an error context from an error code.
  ///
  /// Uses [ErrorMapper] to populate message and suggestion.
  factory ErrorContext.fromErrorCode(
    String errorCode, {
    Map<String, dynamic>? metadata,
  }) {
    return ErrorContext(
      errorCode: errorCode,
      message: _ErrorMapper.getUserMessage(errorCode),
      suggestion: _ErrorMapper.getSuggestion(errorCode),
      isRetryable: _ErrorMapper.isRetryable(errorCode),
      metadata: metadata,
    );
  }

  /// Converts to JSON for logging and analytics.
  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'error_code': errorCode,
      'message': message,
      'suggestion': suggestion,
      'is_retryable': isRetryable,
      'timestamp': timestamp.toIso8601String(),
    };

    if (metadata != null) {
      json['metadata'] = metadata;
    }

    return json;
  }

  @override
  String toString() => 'ErrorContext($errorCode: $message)';
}

/// Internal helper class (avoids circular dependency).
class _ErrorMapper {
  static const Map<String, String> _messages = {
    'SYS_001': '🔌 No hay conexión con el servidor local',
    'SYS_002': '💾 La memoria de tu tarjeta gráfica está llena',
    'SYS_RETRY_EXHAUSTED': '⏱️ La operación falló después de varios intentos',
    'AUTH_001': '🔑 Falta la clave de API de Groq Cloud',
    'RAG_001': '📚 La base de conocimiento está vacía',
    'RAG_002': '💬 La conversación es demasiado larga',
    'VAL_001': '📝 El documento generado es inválido (muy corto)',
    'VAL_002': '📝 El documento tiene formato Markdown incorrecto',
    'VAL_003': '📝 El documento tiene problemas de codificación',
    'VAL_004': '⚠️ El documento contiene contenido sospechoso',
    'VAL_005': '📦 El documento es demasiado grande',
  };

  static const Map<String, String> _suggestions = {
    'SYS_001': 'Verifica que Docker esté ejecutándose',
    'SYS_002': 'Cierra otros programas o cambia a modo Cloud',
    'AUTH_001': 'Ve a Configuración y agrega tu clave de API',
    'RAG_001': 'Ejecuta "Cargar Base de Conocimiento"',
    'RAG_002': 'Inicia una nueva conversación',
    'VAL_001': 'Intenta generar el documento nuevamente',
    'VAL_002': 'Revisa la estructura del documento',
    'VAL_003': 'Asegúrate de usar texto en UTF-8',
    'VAL_004': 'Contacta al soporte si el problema persiste',
    'VAL_005': 'Reduce el tamaño del documento',
  };

  static String getUserMessage(String errorCode) =>
      _messages[errorCode] ?? '🤔 Ocurrió un error ($errorCode)';

  static String getSuggestion(String errorCode) =>
      _suggestions[errorCode] ?? 'Intenta nuevamente o contacta al soporte';

  static bool isRetryable(String errorCode) =>
      ['SYS_001', 'SYS_002', 'SYS_RETRY_EXHAUSTED', 'RAG_001', 'VAL_001']
          .contains(errorCode);
}
