/// Domain layer exceptions for settings operations.
/// These exceptions represent business logic failures and storage violations.
///
/// DO NOT catch these exceptions and silently ignore them.
/// Always propagate to the presentation layer for user notification.
library;

/// Base class for all settings-related exceptions.
///
/// Each exception MUST have:
/// - [message]: User-friendly description (Spanish for MVP)
/// - [code]: Unique error code (e.g., "SETTINGS_001")
/// - [details]: Optional technical details for logging
abstract class SettingsException implements Exception {
  const SettingsException({
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

/// Failed to read settings from storage.
///
/// Triggered when:
/// - SharedPreferences access fails
/// - File system read errors occur
/// - Corrupted data is encountered
class SettingsReadException extends SettingsException {
  SettingsReadException({required super.code, String? message, super.details})
    : super(message: message ?? '⚙️ No se pudo leer la configuración');

  factory SettingsReadException.sharedPreferences(Object error) =>
      SettingsReadException(
        message: '⚙️ Error al acceder a las preferencias locales',
        code: 'SETTINGS_READ_001',
        details: {'error': error.toString()},
      );

  factory SettingsReadException.fileSystem(Object error) =>
      SettingsReadException(
        message: '⚙️ Error al leer el archivo de configuración',
        code: 'SETTINGS_READ_002',
        details: {'error': error.toString()},
      );

  factory SettingsReadException.corrupted(Object error) =>
      SettingsReadException(
        message: '⚙️ Archivo de configuración corrupto',
        code: 'SETTINGS_READ_003',
        details: {'error': error.toString()},
      );
}

/// Failed to write settings to storage.
///
/// Triggered when:
/// - SharedPreferences write fails
/// - File system write errors occur
/// - Insufficient permissions
class SettingsWriteException extends SettingsException {
  SettingsWriteException({required super.code, String? message, super.details})
    : super(message: message ?? '⚙️ No se pudo guardar la configuración');

  factory SettingsWriteException.sharedPreferences(Object error) =>
      SettingsWriteException(
        message: '⚙️ Error al guardar en preferencias locales',
        code: 'SETTINGS_WRITE_001',
        details: {'error': error.toString()},
      );

  factory SettingsWriteException.fileSystem(Object error) =>
      SettingsWriteException(
        message: '⚙️ Error al escribir archivo de configuración',
        code: 'SETTINGS_WRITE_002',
        details: {'error': error.toString()},
      );

  factory SettingsWriteException.permissions() => SettingsWriteException(
    message: '⚙️ Permisos insuficientes para guardar configuración',
    code: 'SETTINGS_WRITE_003',
  );
}

/// Invalid settings value or format.
///
/// Triggered when:
/// - Font size out of valid range (12-24px)
/// - Invalid language preference
/// - Malformed JSON in settings
class SettingsValidationException extends SettingsException {
  SettingsValidationException({
    required super.message,
    required super.code,
    super.details,
  });

  factory SettingsValidationException.invalidFontSize(double value) =>
      SettingsValidationException(
        message:
            '⚙️ Tamaño de fuente inválido ($value px, rango válido: 12-24)',
        code: 'SETTINGS_VAL_001',
        details: {'value': value},
      );

  factory SettingsValidationException.invalidLanguage(String value) =>
      SettingsValidationException(
        message: '⚙️ Idioma no válido: $value',
        code: 'SETTINGS_VAL_002',
        details: {'value': value},
      );

  factory SettingsValidationException.invalidPath(String value) =>
      SettingsValidationException(
        message: '⚙️ Ruta de almacenamiento no válida',
        code: 'SETTINGS_VAL_003',
        details: {'value': value},
      );
}

/// Storage I/O exception (generic umbrella).
///
/// Use specific subclasses when possible
/// (SettingsReadException, SettingsWriteException).
class StorageException extends SettingsException {
  const StorageException({
    required super.message,
    required super.code,
    super.details,
  });
}

/// Alias for backwards compatibility (if code references StorageReadException).
class StorageReadException extends SettingsReadException {
  StorageReadException(String message)
    : super(message: message, code: 'STORAGE_READ_001');
}

/// Alias for backwards compatibility
/// (if code references StorageWriteException).
class StorageWriteException extends SettingsWriteException {
  StorageWriteException(String message)
    : super(message: message, code: 'STORAGE_WRITE_001');
}
