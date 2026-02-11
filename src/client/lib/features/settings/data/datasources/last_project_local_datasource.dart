import 'package:shared_preferences/shared_preferences.dart';

/// Local data source for persisting the last opened project path.
///
/// Uses SharedPreferences for simple string storage.
/// Provides low-level access to read/write the last project path.
///
/// **Keys Namespace:** Uses `lastProject.*` prefix to avoid collisions.
///
/// Example usage:
/// ```dart
/// final dataSource = LastProjectLocalDataSource();
/// await dataSource.saveLastProjectPath('/home/user/projects/my-project');
/// final path = await dataSource.loadLastProjectPath();
/// ```
class LastProjectLocalDataSource {
  /// SharedPreferences key for storing the last project path.
  static const String _kLastProjectPathKey = 'lastProject.path';

  /// Loads the last opened project path from SharedPreferences.
  ///
  /// Returns `null` if no project has been opened yet.
  ///
  /// Throws:
  /// - [StorageReadException] if SharedPreferences access fails
  Future<String?> loadLastProjectPath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_kLastProjectPathKey);
    } catch (e) {
      throw StorageReadException('Failed to load last project path: $e');
    }
  }

  /// Saves the last opened project path to SharedPreferences.
  ///
  /// Throws:
  /// - [StorageWriteException] if SharedPreferences access fails
  Future<void> saveLastProjectPath(String path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final success = await prefs.setString(_kLastProjectPathKey, path);

      if (!success) {
        throw const StorageWriteException(
          'Failed to save last project path to SharedPreferences',
        );
      }
    } catch (e) {
      throw StorageWriteException('Failed to save last project path: $e');
    }
  }

  /// Clears the last project path from SharedPreferences.
  ///
  /// Throws:
  /// - [StorageWriteException] if SharedPreferences access fails
  Future<void> clearLastProjectPath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_kLastProjectPathKey);
    } catch (e) {
      throw StorageWriteException('Failed to clear last project path: $e');
    }
  }
}

/// Exception thrown when reading from storage fails.
class StorageReadException implements Exception {
  /// Creates a [StorageReadException] with the given message.
  const StorageReadException(this.message);

  /// Error message describing the failure.
  final String message;

  @override
  String toString() => 'StorageReadException: $message';
}

/// Exception thrown when writing to storage fails.
class StorageWriteException implements Exception {
  /// Creates a [StorageWriteException] with the given message.
  const StorageWriteException(this.message);

  /// Error message describing the failure.
  final String message;

  @override
  String toString() => 'StorageWriteException: $message';
}
