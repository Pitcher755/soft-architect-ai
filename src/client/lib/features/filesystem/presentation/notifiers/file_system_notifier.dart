import 'package:flutter_riverpod/legacy.dart';

/// File system state - Immutable data class for file tree state
class FileSystemState {
  const FileSystemState({
    this.rootPath = '',
    this.selectedFile,
    this.expandedPaths = const {},
    this.refreshCounter = 0,
  });

  final String rootPath;
  final String? selectedFile;
  final Set<String> expandedPaths;
  final int refreshCounter; // Triggers UI refresh when incremented

  /// Create a copy with modified fields
  FileSystemState copyWith({
    String? rootPath,
    String? selectedFile,
    Set<String>? expandedPaths,
    int? refreshCounter,
  }) => FileSystemState(
    rootPath: rootPath ?? this.rootPath,
    selectedFile: selectedFile ?? this.selectedFile,
    expandedPaths: expandedPaths ?? this.expandedPaths,
    refreshCounter: refreshCounter ?? this.refreshCounter,
  );
}

/// File System Notifier - Manages file tree state
class FileSystemNotifier extends StateNotifier<FileSystemState> {
  FileSystemNotifier() : super(const FileSystemState());

  /// Select a file from the tree
  void selectFile(String filePath) {
    state = state.copyWith(selectedFile: filePath);
  }

  /// Toggle folder expansion
  void toggleFolder(String folderPath) {
    final isExpanded = state.expandedPaths.contains(folderPath);
    final newExpandedPaths = <String>{...state.expandedPaths};

    if (isExpanded) {
      newExpandedPaths.remove(folderPath);
    } else {
      newExpandedPaths.add(folderPath);
    }

    state = state.copyWith(expandedPaths: newExpandedPaths);
  }

  /// Set the root path
  void setRootPath(String rootPath) {
    state = state.copyWith(rootPath: rootPath);
  }

  /// Trigger file tree refresh (call after file changes detected)
  void refresh() {
    state = state.copyWith(refreshCounter: state.refreshCounter + 1);
  }
}

/// Provider for file system notifier state
final fileSystemNotifierProvider =
    StateNotifierProvider<FileSystemNotifier, FileSystemState>(
      (ref) => FileSystemNotifier(),
    );
