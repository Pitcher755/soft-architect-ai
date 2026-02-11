import 'dart:io';

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
  /// Returns the updated settings with the new path.
  ///
  /// Throws an exception if path is invalid or saving fails.
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
  /// Throws an exception if validation fails.
  Future<void> _validatePath(String path) async {
    if (path.isEmpty) {
      throw const InvalidPathException('Storage path cannot be empty');
    }

    final directory = Directory(path);
    // ignore: avoid_slow_async_io
    if (!await directory.exists()) {
      throw InvalidPathException('Directory does not exist: $path');
    }

    // Check if directory is writable by attempting to create a test file
    if (!await _isDirectoryWritable(path)) {
      throw InvalidPathException('Directory is not writable: $path');
    }
  }

  /// Checks if a directory is writable by creating a temporary test file.
  ///
  /// Returns true if a test file can be created and deleted successfully.
  Future<bool> _isDirectoryWritable(String path) async {
    try {
      final testFile = File('$path/.write_test_${DateTime.now().millisecondsSinceEpoch}');
      // ignore: avoid_slow_async_io
      await testFile.writeAsString('test');
      // ignore: avoid_slow_async_io
      await testFile.delete();
      return true;
    } on Exception {
      return false;
    }
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
