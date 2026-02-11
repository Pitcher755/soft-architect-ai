import '../../data/datasources/last_project_local_datasource.dart' show StorageReadException, StorageWriteException;
import '../../data/datasources/settings_local_datasource.dart' show StorageReadException, StorageWriteException;
import '../entities/settings_entity.dart';

/// Repository interface for settings persistence.
///
/// Defines the contract for loading and saving application settings.
/// Implementations should handle persistence via SharedPreferences, JSON files,
/// or other local storage mechanisms.
///
/// This is a **pure interface** with no dependencies on concrete implementations.
/// Follows the Dependency Inversion Principle (SOLID).
///
/// Example implementation:
/// ```dart
/// class SettingsRepositoryImpl implements ISettingsRepository {
///   final SettingsLocalDataSource dataSource;
///
///   @override
///   Future<SettingsEntity> loadSettings() async {
///     final dto = await dataSource.loadSettings();
///     return SettingsMapper.toEntity(dto);
///   }
///
///   @override
///   Future<void> saveSettings(SettingsEntity settings) async {
///     final dto = SettingsMapper.fromEntity(settings);
///     await dataSource.saveSettings(dto);
///   }
/// }
/// ```
abstract class ISettingsRepository {
  /// Loads the current settings from local storage.
  ///
  /// Returns [SettingsEntity.defaultSettings()] if no settings exist yet.
  ///
  /// Throws:
  /// - [StorageReadException] if loading fails
  /// - [SerializationException] if data is corrupted
  Future<SettingsEntity> loadSettings();

  /// Saves the given settings to local storage.
  ///
  /// Overwrites existing settings completely.
  ///
  /// Throws:
  /// - [StorageWriteException] if saving fails
  /// - [SerializationException] if data cannot be serialized
  Future<void> saveSettings(SettingsEntity settings);
}
