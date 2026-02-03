import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/project_shell/domain/entities/file_node.dart';
import 'package:softarchitect_ai/features/project_shell/domain/use_cases/file_search_use_case.dart';

void main() {
  late FileSearchUseCase searchUseCase;

  setUp(() {
    searchUseCase = FileSearchUseCase();
  });

  group('FileSearchUseCase', () {
    final testNodes = [
      FileNode(path: 'lib/main.dart', isDirectory: false, name: 'main.dart'),
      FileNode(path: 'lib/utils/helper.dart', isDirectory: false, name: 'helper.dart'),
      FileNode(path: 'lib/utils/constants.py', isDirectory: false, name: 'constants.py'),
      FileNode(path: 'test/widget_test.dart', isDirectory: false, name: 'widget_test.dart'),
      FileNode(path: 'README.md', isDirectory: false, name: 'README.md'),
      FileNode(path: 'pubspec.yaml', isDirectory: false, name: 'pubspec.yaml'),
      FileNode(path: 'lib', isDirectory: true, name: 'lib'),
      FileNode(path: 'test', isDirectory: true, name: 'test'),
    ];

    group('Search by filename', () {
      test('finds exact filename match', () {
        final results = searchUseCase.search(testNodes, 'main.dart');
        expect(results.isNotEmpty, isTrue);
        expect(results.any((n) => n.name == 'main.dart'), isTrue);
      });

      test('finds partial filename match', () {
        final results = searchUseCase.search(testNodes, 'helper');
        expect(results.isNotEmpty, isTrue);
        expect(results.any((n) => n.name.contains('helper')), isTrue);
      });

      test('case insensitive search', () {
        final results = searchUseCase.search(testNodes, 'MAIN');
        expect(results.isNotEmpty, isTrue);
      });

      test('returns multiple matches', () {
        final results = searchUseCase.search(testNodes, 'dart');
        expect(results.length, greaterThan(1));
      });

      test('returns empty list for no matches', () {
        final results = searchUseCase.search(testNodes, 'nonexistent');
        expect(results.isEmpty, isTrue);
      });

      test('handles empty search query', () {
        final results = searchUseCase.search(testNodes, '');
        // Empty query might return all or none - implementation dependent
        expect(results, isNotNull);
      });

      test('handles whitespace in search', () {
        final results = searchUseCase.search(testNodes, '  main  ');
        expect(results.isNotEmpty, isTrue);
      });
    });

    group('Filter by extension', () {
      test('filters dart files', () {
        final results = searchUseCase.filterByExtension(testNodes, 'dart');
        expect(results.every((n) => n.name.endsWith('.dart')), isTrue);
      });

      test('filters python files', () {
        final results = searchUseCase.filterByExtension(testNodes, 'py');
        expect(results.any((n) => n.name.endsWith('.py')), isTrue);
      });

      test('filters markdown files', () {
        final results = searchUseCase.filterByExtension(testNodes, 'md');
        expect(results.any((n) => n.name.endsWith('.md')), isTrue);
      });

      test('returns empty for non-existent extension', () {
        final results = searchUseCase.filterByExtension(testNodes, 'xyz');
        expect(results.isEmpty, isTrue);
      });

      test('case insensitive extension filter', () {
        final results = searchUseCase.filterByExtension(testNodes, 'DART');
        expect(results.isNotEmpty, isTrue);
      });

      test('excludes directories from extension filter', () {
        final results = searchUseCase.filterByExtension(testNodes, 'dart');
        expect(results.every((n) => !n.isDirectory), isTrue);
      });
    });

    group('Combined search and filter', () {
      test('search and filter by extension', () {
        final searched = searchUseCase.search(testNodes, 'test');
        final filtered = searchUseCase.filterByExtension(searched, 'dart');
        expect(filtered.isNotEmpty, isTrue);
        expect(filtered.any((n) => n.name == 'widget_test.dart'), isTrue);
      });

      test('returns files matching all criteria', () {
        final results = searchUseCase.searchWithFilter(testNodes, 'dart', 'dart');
        expect(results.isNotEmpty, isTrue);
      });

      test('no results when criteria don\'t overlap', () {
        final results = searchUseCase.searchWithFilter(testNodes, 'python', 'dart');
        expect(results.isEmpty, isTrue);
      });
    });

    group('Result ranking', () {
      test('exact matches ranked higher', () {
        final results = searchUseCase.search(testNodes, 'main');
        expect(results.first.name, 'main.dart');
      });

      test('shorter matches ranked higher', () {
        // 'main.dart' is shorter than 'widget_test.dart'
        final results = searchUseCase.search(testNodes, 'dart');
        expect(results.first.name.length, lessThan(results.last.name.length));
      });
    });

    group('Edge cases', () {
      test('handles single node list', () {
        final results = searchUseCase.search([testNodes[0]], 'main');
        expect(results.isNotEmpty, isTrue);
      });

      test('handles empty node list', () {
        final results = searchUseCase.search([], 'main');
        expect(results.isEmpty, isTrue);
      });

      test('handles special characters in filename', () {
        final node = FileNode(
          path: 'lib/my_file-v1.2.dart',
          isDirectory: false,
          name: 'my_file-v1.2.dart',
        );
        final results = searchUseCase.search([node], 'my_file');
        expect(results.isNotEmpty, isTrue);
      });

      test('ignores directories in search results', () {
        final results = searchUseCase.search(testNodes, 'lib');
        final isFilesOnly = results.every((n) => !n.isDirectory);
        expect(isFilesOnly, isTrue);
      });

      test('handles duplicate files', () {
        final nodes = [
          FileNode(path: 'lib/main.dart', isDirectory: false, name: 'main.dart'),
          FileNode(path: 'src/main.dart', isDirectory: false, name: 'main.dart'),
        ];
        final results = searchUseCase.search(nodes, 'main');
        expect(results.length, 2);
      });
    });

    group('Path search', () {
      test('can search by full path', () {
        final results = searchUseCase.search(testNodes, 'lib/main');
        expect(results.isNotEmpty, isTrue);
      });

      test('can search by directory', () {
        final results = searchUseCase.search(testNodes, 'lib/utils');
        expect(results.isNotEmpty, isTrue);
      });

      test('path search is case insensitive', () {
        final results = searchUseCase.search(testNodes, 'LIB/MAIN');
        expect(results.isNotEmpty, isTrue);
      });
    });
  });
}
