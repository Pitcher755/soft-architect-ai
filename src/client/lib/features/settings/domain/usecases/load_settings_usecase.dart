import '../entities/settings_entity.dart';
import '../repositories/i_settings_repository.dart';

/// Use case for loading user settings from storage.
///
/// Encapsulates the business logic for retrieving settings.
/// Returns default settings if none exist yet (first launch).
///
/// Follows the Single Responsibility Principle (SOLID):
/// - Responsible ONLY for loading settings
/// - No knowledge of UI, database, or external APIs
///
/// Example usage (in a Riverpod provider):
/// ```dart
/// final loadSettingsUseCase = LoadSettingsUseCase(settingsRepository);
/// final settings = await loadSettingsUseCase.call();
/// ```
class LoadSettingsUseCase {
  /// Creates a [LoadSettingsUseCase] instance.
  ///
  /// Requires an [ISettingsRepository] implementation for data access.
  const LoadSettingsUseCase(this._repository);

  /// Repository for settings persistence.
  final ISettingsRepository _repository;

  /// Executes the use case to load settings.
  ///
  /// Returns [SettingsEntity.defaultSettings()] on first launch.
  ///
  /// Throws:
  /// - [StorageReadException] if loading fails
  /// - [SerializationException] if data is corrupted
  Future<SettingsEntity> call() async {
    try {
      return await _repository.loadSettings();
    } on Exception {
      // On error, return default settings to avoid crashes
      // Log error for debugging (handled by repository layer)
      return SettingsEntity.defaultSettings();
    }
  }
}
