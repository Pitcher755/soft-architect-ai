// tests/unit/domain/file_search_use_case_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/project_shell/domain/use_cases/file_search_use_case.dart';
import 'package:softarchitect_ai/features/project_shell/domain/entities/file_node.dart';

void main() {
  group('FileSearchUseCase', () {
    test('searchByName finds nodes matching search term', () {
      final root = FileNode(
        id: 'root',
        name: 'root',
        path: '/',
        isDirectory: true,
        children: [
          FileNode(
            id: 'file1',
            name: 'README.md',
            path: '/README.md',
            isDirectory: false,
          ),
          FileNode(
            id: 'file2',
            name: 'LICENSE',
            path: '/LICENSE',
            isDirectory: false,
          ),
        ],
      );

      final results = FileSearchUseCase.searchByName(root, 'README');

      expect(results.length, 1);
      expect(results[0].name, 'README.md');
    });

    test('searchByName is case-insensitive', () {
      final root = FileNode(
        id: 'root',
        name: 'root',
        path: '/',
        isDirectory: true,
        children: [
          FileNode(
            id: 'file1',
            name: 'MyProject.dart',
            path: '/MyProject.dart',
            isDirectory: false,
          ),
        ],
      );

      final results = FileSearchUseCase.searchByName(root, 'myproject');

      expect(results.length, 1);
    });

    test('searchByExtension finds files with matching extension', () {
      final root = FileNode(
        id: 'root',
        name: 'root',
        path: '/',
        isDirectory: true,
        children: [
          FileNode(
            id: 'file1',
            name: 'config.json',
            path: '/config.json',
            isDirectory: false,
          ),
          FileNode(
            id: 'file2',
            name: 'main.dart',
            path: '/main.dart',
            isDirectory: false,
          ),
        ],
      );

      final results = FileSearchUseCase.searchByExtension(root, 'json');

      expect(results.length, 1);
      expect(results[0].name, 'config.json');
    });

    test('searchByName returns empty list when no matches found', () {
      final root = FileNode(
        id: 'root',
        name: 'root',
        path: '/',
        isDirectory: true,
        children: [],
      );

      final results = FileSearchUseCase.searchByName(root, 'nonexistent');

      expect(results.length, 0);
    });
  });
}
