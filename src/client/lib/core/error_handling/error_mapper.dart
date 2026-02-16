/// Maps backend error codes to localized user-friendly messages.
///
/// Supports i18n/l10n for multi-language error handling.
/// Current implementation: Spanish (es) - primary language.
/// Future: Add English (en), Portuguese (pt), etc.
///
/// Example:
/// ```dart
/// final message = ErrorMapper.getUserMessage('SYS_001');
/// // Returns: "🔌 No connection to local server"
/// ```
class ErrorMapper {
  /// Error messages in Spanish (es).
  static const Map<String, String> _messagesEs = {
    // System Errors
    'SYS_001': '🔌 Sin conexión al servidor local',
    'SYS_002': '💾 Tu tarjeta gráfica está sin memoria disponible',
    'SYS_RETRY_EXHAUSTED': '⏱️ Operación falló tras reintentos',

    // Authentication Errors
    'AUTH_001': '🔑 Falta clave API de Groq Cloud',

    // RAG Errors
    'RAG_001': '📚 Tu base de conocimiento está vacía',
    'RAG_002': '💬 Conversación demasiado larga',

    // Database errors (HU-4.4 GAP 4)
    'DB_ERR_001':
        '🗄️ Base de datos no disponible. '
        'Continuando con conocimiento general.',

    // RAG/LLM errors (HU-4.4 GAP 4)
    'RAG_ERR_001':
        '🔍 Búsqueda de contexto falló. '
        'Usando respuesta general.',

    // Validation Errors
    'VAL_001': '📝 El documento generado es inválido (muy corto)',
    'VAL_002': '📝 Formato Markdown incorrecto',
    'VAL_003': '📝 Problemas de codificación',
    'VAL_004': '⚠️ Contenido sospechoso detectado',
    'VAL_005': '📦 Documento demasiado grande',

    // WebSocket Streaming Errors
    'WS_CONNECTION_FAILED': '🔌 Conexión streaming falló',
    'WS_STREAM_FAILED': '📡 Transmisión de tokens falló',
    'WS_STREAM_ERROR': '⚠️ Error durante streaming',
    'WS_RECONNECTION_FAILED': '🔄 Reconexión falló',
  };

  /// Error suggestions in Spanish (es).
  static const Map<String, String> _suggestionsEs = {
    'SYS_001': 'Verifica que Docker esté activo',
    'SYS_002': 'Cierra apps o usa modo Cloud',
    'SYS_RETRY_EXHAUSTED': 'Intenta en unos momentos',
    'AUTH_001': 'Ve a Configuración y agrega tu clave de API',
    'RAG_001': 'Carga Base de Conocimiento',
    'RAG_002': 'Inicia nueva conversación',
    'DB_ERR_001': 'Sistema funciona sin contexto',
    'RAG_ERR_001': 'IA responde sin contexto',
    'VAL_001': 'Regenera el documento',
    'VAL_002': 'Revisa estructura Markdown',
    'VAL_003': 'Usa texto en UTF-8',
    'VAL_004': 'Contacta soporte',
    'VAL_005': 'Reduce tamaño del documento',
    'WS_CONNECTION_FAILED': 'Verifica servidor local',
    'WS_STREAM_FAILED': 'Genera nuevamente',
    'WS_STREAM_ERROR': 'Reinicia streaming',
    'WS_RECONNECTION_FAILED': 'Revisa red e intenta',
  };

  /// Error messages in English (en).
  static const Map<String, String> _messagesEn = {
    // System Errors
    'SYS_001': '🔌 No connection to local server',
    'SYS_002': '💾 Your GPU is out of memory',
    'SYS_RETRY_EXHAUSTED': '⏱️ Operation failed after retries',

    // Authentication Errors
    'AUTH_001': '🔑 Missing Groq Cloud API key',

    // RAG Errors
    'RAG_001': '📚 Your knowledge base is empty',
    'RAG_002': '💬 Conversation too long',

    // Database errors (HU-4.4 GAP 4)
    'DB_ERR_001':
        '🗄️ Database unavailable. '
        'Continuing with general knowledge.',

    // RAG/LLM errors (HU-4.4 GAP 4)
    'RAG_ERR_001':
        '🔍 Context search failed. '
        'Using general response.',

    // Validation Errors
    'VAL_001': '📝 Generated document invalid (too short)',
    'VAL_002': '📝 Incorrect Markdown format',
    'VAL_003': '📝 Encoding issues',
    'VAL_004': '⚠️ Suspicious content detected',
    'VAL_005': '📦 Document too large',

    // WebSocket Streaming Errors
    'WS_CONNECTION_FAILED': '🔌 Streaming connection failed',
    'WS_STREAM_FAILED': '📡 Token transmission failed',
    'WS_STREAM_ERROR': '⚠️ Error during streaming',
    'WS_RECONNECTION_FAILED': '🔄 Reconnection failed',
  };

  /// Error suggestions in English (en).
  static const Map<String, String> _suggestionsEn = {
    'SYS_001': 'Check that Docker is running',
    'SYS_002': 'Close apps or use Cloud mode',
    'SYS_RETRY_EXHAUSTED': 'Try again in a moment',
    'AUTH_001': 'Go to Settings and add your API key',
    'RAG_001': 'Load Knowledge Base',
    'RAG_002': 'Start new conversation',
    'DB_ERR_001': 'System works without context',
    'RAG_ERR_001': 'AI responds without context',
    'VAL_001': 'Regenerate document',
    'VAL_002': 'Check Markdown structure',
    'VAL_003': 'Use UTF-8 text',
    'VAL_004': 'Contact support',
    'VAL_005': 'Reduce document size',
    'WS_CONNECTION_FAILED': 'Check local server',
    'WS_STREAM_FAILED': 'Generate again',
    'WS_STREAM_ERROR': 'Restart streaming',
    'WS_RECONNECTION_FAILED': 'Check network and retry',
  };

  /// Current locale (default: Spanish).
  /// Detects system locale on initialization.
  /// Falls back to 'es' if system locale not supported.
  static String _currentLocale = _detectSystemLocale();

  /// Detect system locale from platform.
  ///
  /// Returns 'es' or 'en' based on system settings.
  /// Falls back to 'es' if locale not supported.
  ///
  /// TODO(flutter): Use Platform.localeName when targeting desktop/mobile.
  /// In production: parse Platform.localeName (e.g., 'en_US' → 'en').
  static String _detectSystemLocale() => 'es'; // Default: Spanish

  /// Set current locale for error messages.
  ///
  /// Supported: 'es', 'en'.
  static void setLocale(String locale) {
    if (['es', 'en'].contains(locale)) {
      _currentLocale = locale;
    }
  }

  /// Get current locale.
  static String getLocale() => _currentLocale;

  /// Get messages map for current locale.
  static Map<String, String> get _messages {
    switch (_currentLocale) {
      case 'en':
        return _messagesEn;
      case 'es':
      default:
        return _messagesEs;
    }
  }

  /// Get suggestions map for current locale.
  static Map<String, String> get _suggestions {
    switch (_currentLocale) {
      case 'en':
        return _suggestionsEn;
      case 'es':
      default:
        return _suggestionsEs;
    }
  }

  /// Get localized message for error code.
  ///
  /// Returns user-friendly message in current locale.
  /// Falls back to generic message if code unknown.
  static String getUserMessage(String errorCode) {
    final defaultMsg = _currentLocale == 'en'
        ? '🤔 Unknown error ($errorCode)'
        : '🤔 error desconocido ($errorCode)';
    return _messages[errorCode] ?? defaultMsg;
  }

  /// Get localized suggestion for error code.
  ///
  /// Returns actionable suggestion in current locale.
  /// Falls back to generic suggestion if code unknown.
  static String getSuggestion(String errorCode) {
    final defaultSuggestion = _currentLocale == 'en'
        ? 'Try again or contact support'
        : 'Intenta o contacta soporte';
    return _suggestions[errorCode] ?? defaultSuggestion;
  }

  /// Check if error is retryable by user.
  ///
  /// Retryable: transient (network, resources).
  /// Non-retryable: require action (auth, validation).
  static bool isRetryable(String errorCode) => [
    'SYS_001', // Connection
    'SYS_002', // OOM
    'SYS_RETRY_EXHAUSTED', // Retry
    'RAG_001', // Empty KB
    'VAL_001', // Short doc
    'VAL_002', // Invalid MD
    'WS_CONNECTION_FAILED', // Streaming
    'WS_STREAM_FAILED', // Tokens
    'WS_RECONNECTION_FAILED', // Reconnect
  ].contains(errorCode);

  /// Check if error indicates graceful degradation.
  ///
  /// Used for snackbar severity (warning vs error).
  /// System continues with reduced functionality.
  static bool isGracefulDegradation(String errorCode) =>
      errorCode == 'DB_ERR_001' || errorCode == 'RAG_ERR_001';
}
