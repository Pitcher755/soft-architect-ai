/// Repository interface for last opened project persistence.
///
/// Defines the contract for storing and retrieving the path of the last
/// project opened by the user. Used by the ProjectsSidebar to show the
/// "Active Project" button with the correct navigation target.
///
/// This is a **pure interface** with no dependencies on concrete implementations.
/// Follows the Dependency Inversion Principle (SOLID).
///
/// Example implementation:
/// ```dart
/// class LastProjectRepositoryImpl implements ILastProjectRepository {
///   final SharedPreferences prefs;
///
///   @override
///   Future<String?> loadLastProjectPath() async {
///     return prefs.getString('lastProject.path');
///   }
///
///   @override
///   Future<void> saveLastProjectPath(String path) async {
///     await prefs.setString('lastProject.path', path);
///   }
/// }
/// ```
abstract class ILastProjectRepository {
  /// Loads the path of the last opened project from local storage.
  ///
  /// Returns `null` if no project has been opened yet.
  ///
  /// Throws:
  /// - [StorageReadException] if loading fails
  Future<String?> loadLastProjectPath();

  /// Saves the path of the currently opened project to local storage.
  ///
  /// This should be called whenever a user opens or switches to a project.
  ///
  /// Throws:
  /// - [StorageWriteException] if saving fails
  Future<void> saveLastProjectPath(String path);

  /// Clears the last project path from storage.
  ///
  /// Useful when resetting the application state or on logout.
  ///
  /// Throws:
  /// - [StorageWriteException] if clearing fails
  Future<void> clearLastProjectPath();
}
