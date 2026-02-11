import 'package:file_picker/file_picker.dart';

/// Data source for native folder selection using file_picker package.
///
/// Provides a platform-agnostic interface to open native file/folder dialogs.
/// Supports Linux (GTK), macOS (Cocoa), and Windows (Win32) dialogs.
///
/// Example usage:
/// ```dart
/// final dataSource = FilePickerDataSource();
/// final path = await dataSource.pickDirectory();
/// if (path != null) {
///   print('Selected folder: $path');
/// }
/// ```
class FilePickerDataSource {
  /// Opens a native folder picker dialog.
  ///
  /// Returns the selected directory path, or `null` if the user cancels.
  ///
  /// Throws:
  /// - [FilePickerException] if the picker fails to open or encounters an error
  Future<String?> pickDirectory() async {
    try {
      final result = await FilePicker.platform.getDirectoryPath();
      return result; // Returns null if user cancels
    } catch (e) {
      throw FilePickerException('Failed to open folder picker: $e');
    }
  }

  /// Opens a native file picker dialog (single file).
  ///
  /// Returns the selected file path, or `null` if the user cancels.
  ///
  /// Throws:
  /// - [FilePickerException] if the picker fails to open or encounters an error
  Future<String?> pickFile({List<String>? allowedExtensions}) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: allowedExtensions != null ? FileType.custom : FileType.any,
        allowedExtensions: allowedExtensions,
      );

      return result?.files.single.path;
    } catch (e) {
      throw FilePickerException('Failed to open file picker: $e');
    }
  }
}

/// Exception thrown when file picker operations fail.
class FilePickerException implements Exception {
  /// Creates a [FilePickerException] with the given message.
  const FilePickerException(this.message);

  /// Error message describing the failure.
  final String message;

  @override
  String toString() => 'FilePickerException: $message';
}
