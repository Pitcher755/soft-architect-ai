import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/project_shell/domain/entities/file_node.dart';
import 'package:softarchitect_ai/features/project_shell/domain/use_cases/file_search_use_case.dart';

void main() {
  group('FileSearchUseCase', () {
    final testNodes = [
      FileNode(
        id: 'file-1',
        path: 'lib/main.dart',
        isDirectory: false,
        name: 'main.dart',
      ),
      FileNode(
        id: 'file-2',
        path: 'lib/utils/helper.dart',
        isDirectory: false,
        name: 'helper.dart',
      ),
      FileNode(
        id: 'file-3',
        path: 'lib/utils/constants.py',
        isDirectory: false,
        name: 'constants.py',
      ),
      FileNode(
        id: 'file-4',
        path: 'test/widget_test.dart',
        isDirectory: false,
        name: 'widget_test.dart',
      ),
      FileNode(
        id: 'file-5',
        path: 'README.md',
        isDirectory: false,
        name: 'README.md',
      ),
      FileNode(
        id: 'file-6',
        path: 'pubspec.yaml',
        isDirectory: false,
        name: 'pubspec.yaml',
      ),
      FileNode(id: 'dir-1', path: 'lib', isDirectory: true, name: 'lib'),
      FileNode(id: 'dir-2', path: 'test', isDirectory: true, name: 'test'),
    ];

    group('Search by filename', () {
      test('finds exact filename match', () {
        final results = FileSearchUseCase.search(testNodes, 'main.dart');
        expect(results.isNotEmpty, isTrue);
        expect(results.any((n) => n.name == 'main.dart'), isTrue);
      });

      test('finds partial filename match', () {
        final results = FileSearchUseCase.search(testNodes, 'helper');
        expect(results.isNotEmpty, isTrue);
        expect(results.any((n) => n.name.contains('helper')), isTrue);
      });

      test('case insensitive search', () {
        final results = FileSearchUseCase.search(testNodes, 'MAIN');
        expect(results.isNotEmpty, isTrue);
      });

      test('returns multiple matches', () {
        final results = FileSearchUseCase.search(testNodes, 'dart');
        expect(results.length, greaterThan(1));
      });

      test('returns empty list for no matches', () {
        final results = FileSearchUseCase.search(testNodes, 'nonexistent');
        expect(results.isEmpty, isTrue);
      });

      test('handles empty search query', () {
        final results = FileSearchUseCase.search(testNodes, '');
        // Empty query returns empty list
        expect(results.isEmpty, isTrue);
      });

      test('handles whitespace in search', () {
        final results = FileSearchUseCase.search(testNodes, '  main  ');
        // Whitespace trimmed
        expect(results.isNotEmpty, isTrue);
      });
    });

    group('Filter by extension', () {
      test('filters dart files', () {
        final results = FileSearchUseCase.searchByExtension(testNodes, 'dart');
        expect(results.every((n) => n.name.endsWith('.dart')), isTrue);
      });

      test('filters python files', () {
        final results = FileSearchUseCase.searchByExtension(testNodes, 'py');
        expect(results.any((n) => n.name.endsWith('.py')), isTrue);
      });

      test('filters markdown files', () {
        final results = FileSearchUseCase.searchByExtension(testNodes, 'md');
        expect(results.any((n) => n.name.endsWith('.md')), isTrue);
      });

      test('returns empty for non-existent extension', () {
        final results = FileSearchUseCase.searchByExtension(testNodes, 'xyz');
        expect(results.isEmpty, isTrue);
      });

      test('case insensitive extension filter', () {
        final results = FileSearchUseCase.searchByExtension(testNodes, 'DART');
        expect(results.isNotEmpty, isTrue);
      });

      test('excludes directories from extension filter', () {
        final results = FileSearchUseCase.searchByExtension(testNodes, 'dart');
        expect(results.every((n) => !n.isDirectory), isTrue);
      });
    });

    group('Search directories', () {
      test('searches only directories', () {
        final results = FileSearchUseCase.searchDirectories(testNodes, 'lib');
        expect(results.every((n) => n.isDirectory), isTrue);
      });

      test('returns empty for file-only query', () {
        final results = FileSearchUseCase.searchDirectories(testNodes, 'main');
        expect(results.isEmpty, isTrue);
      });

      test('case insensitive directory search', () {
        final results = FileSearchUseCase.searchDirectories(testNodes, 'LIB');
        expect(results.isNotEmpty, isTrue);
      });
    });

    group('Edge cases', () {
      test('handles single node list', () {
        final results = FileSearchUseCase.search([testNodes[0]], 'main');
        expect(results.isNotEmpty, isTrue);
      });

      test('handles empty node list', () {
        final results = FileSearchUseCase.search([], 'main');
        expect(results.isEmpty, isTrue);
      });

      test('handles special characters in filename', () {
        final node = FileNode(
          id: 'file-special',
          path: 'lib/my_file-v1.2.dart',
          isDirectory: false,
          name: 'my_file-v1.2.dart',
        );
        final results = FileSearchUseCase.search([node], 'my_file');
        expect(results.isNotEmpty, isTrue);
      });

      test('ignores directories in search results', () {
        final results = FileSearchUseCase.search(testNodes, 'lib');
        final isFilesOnly = results.every((n) => !n.isDirectory);
        expect(isFilesOnly, isTrue);
      });

      test('handles duplicate files', () {
        final nodes = [
          FileNode(
            id: 'dup-1',
            path: 'lib/main.dart',
            isDirectory: false,
            name: 'main.dart',
          ),
          FileNode(
            id: 'dup-2',
            path: 'src/main.dart',
            isDirectory: false,
            name: 'main.dart',
          ),
        ];
        final results = FileSearchUseCase.search(nodes, 'main');
        expect(results.length, 2);
      });
    });

    group('Path search', () {
      test('can search by full path', () {
        final results = FileSearchUseCase.search(testNodes, 'lib/main');
        expect(results.isNotEmpty, isTrue);
      });

      test('can search by directory', () {
        final results = FileSearchUseCase.search(testNodes, 'lib/utils');
        expect(results.isNotEmpty, isTrue);
      });

      test('path search is case insensitive', () {
        final results = FileSearchUseCase.search(testNodes, 'LIB/MAIN');
        expect(results.isNotEmpty, isTrue);
      });
    });

    group('Result limiting', () {
      test('respects maxResults limit', () {
        final manyNodes = List.generate(
          200,
          (i) => FileNode(
            id: 'file-$i',
            path: 'lib/file_$i.dart',
            isDirectory: false,
            name: 'file_$i.dart',
          ),
        );
        final results = FileSearchUseCase.search(manyNodes, 'file');
        expect(results.length, lessThanOrEqualTo(100));
      });
    });
  });
}
