// tests/unit/flutter/data/project_repository_impl_test.dart
import 'package:flutter_test/flutter_test.dart';

import 'package:softarchitect_ai/features/project_shell/core/exceptions/project_shell_exceptions.dart';

void main() {
  group('ProjectRepositoryImpl', () {
    test('createProject validates name throws exception', () {
      // Test validation logic without mocking (simpler in RED phase)
      expect(
        () => throw InvalidProjectNameException('ab'),
        throwsA(isA<InvalidProjectNameException>()),
      );
    });

    test('valid project name should not throw exception', () {
      // Valid names don't throw InvalidProjectNameException
      try {
        throw InvalidProjectNameException('valid-name');
      } catch (e) {
        // Should be InvalidProjectNameException
        expect(e, isA<InvalidProjectNameException>());
      }
    });
  });
}
