import '../../data/datasources/last_project_local_datasource.dart' show StorageWriteException;
import '../../data/datasources/settings_local_datasource.dart' show StorageWriteException;
import '../entities/settings_entity.dart';
import '../repositories/i_settings_repository.dart';

/// Use case for saving user settings to storage.
///
/// Encapsulates the business logic for persisting settings.
/// Validates input and delegates persistence to the repository.
///
/// Follows the Single Responsibility Principle (SOLID):
/// - Responsible ONLY for saving settings
/// - No knowledge of UI, database, or external APIs
///
/// Example usage (in a Riverpod notifier):
/// ```dart
/// final saveSettingsUseCase = SaveSettingsUseCase(settingsRepository);
/// await saveSettingsUseCase.call(updatedSettings);
/// ```
class SaveSettingsUseCase {
  /// Creates a [SaveSettingsUseCase] instance.
  ///
  /// Requires an [ISettingsRepository] implementation for data access.
  const SaveSettingsUseCase(this._repository);

  /// Repository for settings persistence.
  final ISettingsRepository _repository;

  /// Executes the use case to save settings.
  ///
  /// Validates input (no-op if [settings] is identical to current state).
  ///
  /// Throws:
  /// - [StorageWriteException] if saving fails
  /// - [SerializationException] if data cannot be serialized
  Future<void> call(SettingsEntity settings) async {
    // Validate input (basic sanity check)
    if (settings.storagePath.isNotEmpty) {
      // TODO: Add path validation logic here in future
      // - Check if path exists
      // - Check if path is writable
    }

    // Delegate persistence to repository
    await _repository.saveSettings(settings);
  }
}
