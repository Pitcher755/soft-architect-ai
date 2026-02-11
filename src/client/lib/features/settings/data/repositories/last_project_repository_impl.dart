import 'dart:developer' as developer;

import '../../domain/repositories/i_last_project_repository.dart';
import '../datasources/last_project_local_datasource.dart';

/// Implementation of [ILastProjectRepository] using local storage.
///
/// Uses [LastProjectLocalDataSource] (SharedPreferences) for persistence.
/// Simple string storage for the project path.
///
/// Example usage (in dependency injection):
/// ```dart
/// final dataSource = LastProjectLocalDataSource();
/// final repository = LastProjectRepositoryImpl(dataSource);
/// ```
class LastProjectRepositoryImpl implements ILastProjectRepository {
  /// Creates a [LastProjectRepositoryImpl] instance.
  ///
  /// Requires a [LastProjectLocalDataSource] for data access.
  const LastProjectRepositoryImpl(this._dataSource);

  /// Data source for local storage operations.
  final LastProjectLocalDataSource _dataSource;

  @override
  Future<String?> loadLastProjectPath() async {
    try {
      return await _dataSource.loadLastProjectPath();
    } on Exception catch (e) {
      // On error, return null to indicate no last project
      developer.log('Failed to load last project path: $e', name: 'LastProjectRepository');
      return null;
    }
  }

  @override
  Future<void> saveLastProjectPath(String path) async {
    try {
      await _dataSource.saveLastProjectPath(path);
    } catch (e) {
      throw RepositorySaveException('Failed to save last project path: $e');
    }
  }

  @override
  Future<void> clearLastProjectPath() async {
    try {
      await _dataSource.clearLastProjectPath();
    } catch (e) {
      throw RepositorySaveException('Failed to clear last project path: $e');
    }
  }
}

/// Exception thrown when saving last project path fails at the repository level.
class RepositorySaveException implements Exception {
  /// Creates a [RepositorySaveException] with the given message.
  const RepositorySaveException(this.message);

  /// Error message describing the failure.
  final String message;

  @override
  String toString() => 'RepositorySaveException: $message';
}
