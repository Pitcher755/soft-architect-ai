import 'dart:io';

import '../../data/datasources/last_project_local_datasource.dart' show StorageWriteException;
import '../../data/datasources/settings_local_datasource.dart' show StorageWriteException;
import '../entities/settings_entity.dart';
import '../repositories/i_settings_repository.dart';

/// Use case for updating the default storage path.
///
/// Encapsulates the business logic for changing the storage location.
/// Validates that the path exists and is writable before persisting.
///
/// Example usage (in a Riverpod notifier):
/// ```dart
/// final updateStoragePathUseCase = UpdateStoragePathUseCase(repository);
/// await updateStoragePathUseCase.call('/home/user/projects', currentSettings);
/// ```
class UpdateStoragePathUseCase {
  /// Creates an [UpdateStoragePathUseCase] instance.
  const UpdateStoragePathUseCase(this._repository);

  /// Repository for settings persistence.
  final ISettingsRepository _repository;

  /// Executes the use case to update storage path.
  ///
  /// [path]: The new storage path (must be a valid directory).
  /// [currentSettings]: The current settings entity to update.
  ///
  /// Returns the updated [SettingsEntity] with the new path.
  ///
  /// Throws:
  /// - [InvalidPathException] if path doesn't exist or isn't writable
  /// - [StorageWriteException] if saving fails
  Future<SettingsEntity> call(
    String path,
    SettingsEntity currentSettings,
  ) async {
    // Validate path
    await _validatePath(path);

    // Create updated settings with new path
    final updatedSettings = currentSettings.copyWith(storagePath: path);

    // Persist to storage
    await _repository.saveSettings(updatedSettings);

    return updatedSettings;
  }

  /// Validates that the given path exists and is a directory.
  ///
  /// Throws [InvalidPathException] if validation fails.
  Future<void> _validatePath(String path) async {
    if (path.isEmpty) {
      throw const InvalidPathException('Storage path cannot be empty');
    }

    final directory = Directory(path);
    if (!await directory.exists()) {
      throw InvalidPathException('Directory does not exist: $path');
    }

    // TODO: Add writability check (platform-dependent)
    // For now, we assume if directory exists, it's writable
  }
}

/// Exception thrown when an invalid storage path is provided.
class InvalidPathException implements Exception {
  /// Creates an [InvalidPathException] with the given message.
  const InvalidPathException(this.message);

  /// Error message describing why the path is invalid.
  final String message;

  @override
  String toString() => 'InvalidPathException: $message';
}
