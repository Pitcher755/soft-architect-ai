// tests/unit/data/project_repository_impl_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:softarchitect_ai/features/project_shell/core/exceptions/project_exceptions.dart';
import 'package:softarchitect_ai/features/project_shell/data/repositories/project_repository_impl.dart';

import '../../test_helper.dart';

void main() {
  group('ProjectRepositoryImpl', () {
    late MockSQLiteDataSource mockSqlite;
    late ProjectRepositoryImpl repo;

    setUp(() {
      mockSqlite = MockSQLiteDataSource();
      repo = ProjectRepositoryImpl(mockSqlite);
    });

    test('createProject validates name', () async {
      expect(
        () => repo.createProject('ab', '/path'),
        throwsA(isA<InvalidProjectNameException>()),
      );
    });

    test('createProject saves to database', () async {
      when(mockSqlite.saveProject(any)).thenAnswer((_) async => {});
      await repo.createProject('valid-name', '/path');
      verify(mockSqlite.saveProject(any)).called(1);
    });
  });
}
