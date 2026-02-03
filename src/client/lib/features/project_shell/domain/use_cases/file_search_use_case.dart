// lib/features/project_shell/domain/use_cases/file_search_use_case.dart
import 'package:softarchitect_ai/features/project_shell/domain/entities/file_node.dart';

/// Use case: File search and filtering
class FileSearchUseCase {
  static const int maxQueryLength = 100;

  /// Search files by query (case-insensitive)
  static List<FileNode> search(List<FileNode> nodes, String query) {
    if (query.isEmpty) return [];
    if (query.length > maxQueryLength) {
      throw ArgumentError('Query too long: max $maxQueryLength chars');
    }

    final lowerQuery = query.toLowerCase();
    return nodes
        .where((node) => node.name.toLowerCase().contains(lowerQuery))
        .toList();
  }
}
