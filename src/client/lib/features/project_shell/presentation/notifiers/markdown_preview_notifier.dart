import 'package:flutter_riverpod/legacy.dart';

/// Markdown Preview State - Immutable data class
class MarkdownPreviewState {
  const MarkdownPreviewState({
    this.content,
    this.filePath,
    this.isLoading = false,
    this.error,
  });

  final String? content;
  final String? filePath;
  final bool isLoading;
  final String? error;

  /// Create a copy with modified fields
  MarkdownPreviewState copyWith({
    String? content,
    String? filePath,
    bool? isLoading,
    String? error,
  }) => MarkdownPreviewState(
    content: content ?? this.content,
    filePath: filePath ?? this.filePath,
    isLoading: isLoading ?? this.isLoading,
    error: error ?? this.error,
  );
}

/// Markdown Preview Notifier - Manages preview state and file loading
class MarkdownPreviewNotifier extends StateNotifier<MarkdownPreviewState> {
  MarkdownPreviewNotifier() : super(const MarkdownPreviewState());

  /// Load markdown file content
  Future<void> loadFile(String filePath) async {
    try {
      // Start loading
      state = state.copyWith(isLoading: true);

      // Simulate file read (in real app, read from file system)
      await Future.delayed(const Duration(milliseconds: 200));

      // For now, just show the file name as placeholder
      // In real implementation, read actual file content
      final fileName = filePath.split('/').last;

      state = state.copyWith(
        content: '# $fileName\n\n**File content would be loaded here.**',
        filePath: filePath,
        isLoading: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load file: $e',
      );
    }
  }

  /// Clear the preview
  void clear() {
    state = const MarkdownPreviewState();
  }
}

/// Provider for markdown preview state
final markdownPreviewNotifierProvider =
    StateNotifierProvider<MarkdownPreviewNotifier, MarkdownPreviewState>(
      (ref) => MarkdownPreviewNotifier(),
    );
