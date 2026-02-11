import '../../data/datasources/last_project_local_datasource.dart' show StorageWriteException;
import '../../data/datasources/settings_local_datasource.dart' show StorageWriteException;
import '../repositories/i_last_project_repository.dart';

/// Use case for saving the currently opened project path.
///
/// Encapsulates the business logic for persisting the most recently
/// opened project. Should be called whenever a user opens or switches projects.
///
/// Example usage (when opening a project):
/// ```dart
/// final saveLastProjectUseCase = SaveLastProjectUseCase(repository);
/// await saveLastProjectUseCase.call('/path/to/project');
/// ```
class SaveLastProjectUseCase {
  /// Creates a [SaveLastProjectUseCase] instance.
  const SaveLastProjectUseCase(this._repository);

  /// Repository for last project persistence.
  final ILastProjectRepository _repository;

  /// Executes the use case to save the last project path.
  ///
  /// [projectPath]: The path to the currently opened project.
  ///
  /// Throws:
  /// - [StorageWriteException] if saving fails
  /// - [ArgumentError] if [projectPath] is empty
  Future<void> call(String projectPath) async {
    if (projectPath.isEmpty) {
      throw ArgumentError('Project path cannot be empty');
    }

    await _repository.saveLastProjectPath(projectPath);
  }
}
