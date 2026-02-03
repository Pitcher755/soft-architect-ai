// tests/unit/flutter/domain/file_search_use_case_test.dart
import 'package:flutter_test/flutter_test.dart';

import 'package:softarchitect_ai/features/project_shell/domain/entities/file_node.dart';
import 'package:softarchitect_ai/features/project_shell/domain/use_cases/file_search_use_case.dart';

void main() {
  group('FileSearchUseCase', () {
    test('search returns empty list when query is empty', () {
      final results = FileSearchUseCase.search([], '');
      expect(results.isEmpty, true);
    });

    test('search filters by filename case-insensitive', () {
      final nodes = [
        FileNode(
          id: '1',
          name: 'architecture.md',
          path: '/arch.md',
          isDirectory: false,
        ),
        FileNode(
          id: '2',
          name: 'design.md',
          path: '/design.md',
          isDirectory: false,
        ),
      ];
      final results = FileSearchUseCase.search(nodes, 'arch');
      expect(results.length, 1);
    });

    test('search respects max 100 character limit', () {
      final query = 'a' * 101;
      expect(
        () => FileSearchUseCase.search([], query),
        throwsA(isA<ArgumentError>()),
      );
    });
  });
}
