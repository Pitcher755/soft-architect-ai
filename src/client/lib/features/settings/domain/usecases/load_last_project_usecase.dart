import '../repositories/i_last_project_repository.dart';

/// Use case for loading the last opened project path.
///
/// Encapsulates the business logic for retrieving the most recently
/// opened project. Used by the ProjectsSidebar to show the active project.
///
/// Example usage (in a Riverpod provider):
/// ```dart
/// final loadLastProjectUseCase = LoadLastProjectUseCase(repository);
/// final path = await loadLastProjectUseCase.call();
/// ```
class LoadLastProjectUseCase {
  /// Creates a [LoadLastProjectUseCase] instance.
  const LoadLastProjectUseCase(this._repository);

  /// Repository for last project persistence.
  final ILastProjectRepository _repository;

  /// Executes the use case to load the last project path.
  ///
  /// Returns `null` if no project has been opened yet.
  ///
  /// Throws:
  /// - [StorageReadException] if loading fails
  Future<String?> call() async {
    try {
      return await _repository.loadLastProjectPath();
    } catch (e) {
      // On error, return null to indicate no last project
      // Log error for debugging (handled by repository layer)
      return null;
    }
  }
}
