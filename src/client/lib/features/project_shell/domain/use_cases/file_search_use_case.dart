// lib/features/project_shell/domain/use_cases/file_search_use_case.dart
import '../entities/file_node.dart';

/// Use case: File search and filtering
class FileSearchUseCase {
  static const int maxQueryLength = 100;
  static const int maxResults = 100;

  /// Search files by query (case-insensitive, recursive)
  static List<FileNode> search(List<FileNode> nodes, String query) {
    final trimmedQuery = query.trim();
    if (trimmedQuery.isEmpty) return [];
    if (trimmedQuery.length > maxQueryLength) {
      throw ArgumentError('Query too long: max $maxQueryLength chars');
    }

    final lowerQuery = trimmedQuery.toLowerCase();
    final results = <FileNode>[];
    _searchRecursive(nodes, lowerQuery, results);
    return results.take(maxResults).toList();
  }

  /// Search by file extension
  static List<FileNode> searchByExtension(
    List<FileNode> nodes,
    String extension,
  ) {
    final ext = extension.toLowerCase();
    final results = <FileNode>[];
    _filterByExtension(nodes, ext, results);
    return results;
  }

  /// Search only directories
  static List<FileNode> searchDirectories(List<FileNode> nodes, String query) {
    if (query.isEmpty) return [];
    final lowerQuery = query.toLowerCase();
    return nodes
        .where((node) =>
            node.isDirectory &&
            node.name.toLowerCase().contains(lowerQuery))
        .toList();
  }

  static void _searchRecursive(
    List<FileNode> nodes,
    String query,
    List<FileNode> results,
  ) {
    for (final node in nodes) {
      if (results.length >= maxResults) break;
      if (!node.isDirectory &&
          (node.name.toLowerCase().contains(query) ||
           node.path.toLowerCase().contains(query))) {
        results.add(node);
      }
      if (node.isDirectory && node.children.isNotEmpty) {
        _searchRecursive(node.children, query, results);
      }
    }
  }

  static void _filterByExtension(
    List<FileNode> nodes,
    String extension,
    List<FileNode> results,
  ) {
    for (final node in nodes) {
      if (!node.isDirectory && node.extension.toLowerCase() == extension) {
        results.add(node);
      }
      if (node.isDirectory && node.children.isNotEmpty) {
        _filterByExtension(node.children, extension, results);
      }
    }
  }
}
