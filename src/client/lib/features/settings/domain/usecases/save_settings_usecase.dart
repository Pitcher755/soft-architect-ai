import 'dart:io';

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
  /// Validates input and persists settings to storage.
  ///
  /// Throws an exception if saving or validation fails.
  Future<void> call(SettingsEntity settings) async {
    // Validate storage path if set
    if (settings.storagePath.isNotEmpty) {
      await _validateStoragePath(settings.storagePath);
    }

    // Delegate persistence to repository
    await _repository.saveSettings(settings);
  }

  /// Validates that the storage path exists and is a directory.
  ///
  /// Throws an exception if validation fails.
  Future<void> _validateStoragePath(String path) async {
    final directory = Directory(path);
    // ignore: avoid_slow_async_io
    if (!await directory.exists()) {
      throw InvalidStoragePathException('Storage path does not exist: $path');
    }
  }
}

/// Exception thrown when storage path validation fails.
class InvalidStoragePathException implements Exception {
  /// Creates an [InvalidStoragePathException] with the given message.
  const InvalidStoragePathException(this.message);

  /// Error message describing the validation failure.
  final String message;
  @override
  String toString() => 'InvalidStoragePathException: $message';
}
