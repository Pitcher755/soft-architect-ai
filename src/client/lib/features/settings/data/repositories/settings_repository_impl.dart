import '../../domain/entities/settings_entity.dart';
import '../../domain/repositories/i_settings_repository.dart';
import '../datasources/settings_local_datasource.dart';

/// Implementation of [ISettingsRepository] using local storage.
///
/// Uses [SettingsLocalDataSource] (SharedPreferences) for persistence.
/// Handles serialization/deserialization and error handling.
///
/// Example usage (in dependency injection):
/// ```dart
/// final dataSource = SettingsLocalDataSource();
/// final repository = SettingsRepositoryImpl(dataSource);
/// ```
class SettingsRepositoryImpl implements ISettingsRepository {
  /// Creates a [SettingsRepositoryImpl] instance.
  ///
  /// Requires a [SettingsLocalDataSource] for data access.
  const SettingsRepositoryImpl(this._dataSource);

  /// Data source for local storage operations.
  final SettingsLocalDataSource _dataSource;

  @override
  Future<SettingsEntity> loadSettings() async {
    try {
      final json = await _dataSource.loadSettings();

      // If no settings exist yet, return defaults
      if (json == null) {
        return SettingsEntity.defaultSettings();
      }

      // Deserialize JSON to entity
      return SettingsEntity.fromJson(json);
    } catch (e) {
      // On any error, return default settings to avoid crashes
      // TODO: Add proper logging here
      return SettingsEntity.defaultSettings();
    }
  }

  @override
  Future<void> saveSettings(SettingsEntity settings) async {
    try {
      // Serialize entity to JSON
      final json = settings.toJson();

      // Save to storage
      await _dataSource.saveSettings(json);
    } catch (e) {
      // Re-throw as repository-level exception
      throw RepositorySaveException('Failed to save settings: $e');
    }
  }
}

/// Exception thrown when saving settings fails at the repository level.
class RepositorySaveException implements Exception {
  /// Creates a [RepositorySaveException] with the given message.
  const RepositorySaveException(this.message);

  /// Error message describing the failure.
  final String message;

  @override
  String toString() => 'RepositorySaveException: $message';
}
