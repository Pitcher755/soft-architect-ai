import '../../data/datasources/last_project_local_datasource.dart' show StorageWriteException;
import '../../data/datasources/settings_local_datasource.dart' show StorageWriteException;
import '../entities/language_preference.dart';
import '../entities/settings_entity.dart';
import '../repositories/i_settings_repository.dart';

/// Use case for updating the user's language preference.
///
/// Encapsulates the business logic for changing the application language.
/// Automatically saves the updated settings after changing the language.
///
/// Example usage (in a Riverpod notifier):
/// ```dart
/// final updateLanguageUseCase = UpdateLanguageUseCase(repository);
/// await updateLanguageUseCase.call(LanguagePreference.es, currentSettings);
/// ```
class UpdateLanguageUseCase {
  /// Creates an [UpdateLanguageUseCase] instance.
  const UpdateLanguageUseCase(this._repository);

  /// Repository for settings persistence.
  final ISettingsRepository _repository;

  /// Executes the use case to update language preference.
  ///
  /// [language]: The new language preference (en or es).
  /// [currentSettings]: The current settings entity to update.
  ///
  /// Returns the updated [SettingsEntity] with the new language.
  ///
  /// Throws:
  /// - [StorageWriteException] if saving fails
  Future<SettingsEntity> call(
    LanguagePreference language,
    SettingsEntity currentSettings,
  ) async {
    // Create updated settings with new language
    final updatedSettings = currentSettings.copyWith(language: language);

    // Persist to storage
    await _repository.saveSettings(updatedSettings);

    return updatedSettings;
  }
}
