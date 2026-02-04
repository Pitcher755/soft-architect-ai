// tests/unit/flutter/features/project_shell/data/project_repository_impl_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:softarchitect_ai/features/project_shell/core/exceptions/project_shell_exceptions.dart';
import 'package:softarchitect_ai/features/project_shell/data/data_sources/sqlite_data_source.dart';
import 'package:softarchitect_ai/features/project_shell/data/repositories/project_repository_impl.dart';

// Generate mocks
class MockSQLiteDataSource extends Mock implements SQLiteDataSource {}

void main() {
  group('ProjectRepositoryImpl', () {
    late MockSQLiteDataSource mockDataSource;
    late ProjectRepositoryImpl repository;

    setUp(() {
      mockDataSource = MockSQLiteDataSource();
      repository = ProjectRepositoryImpl(mockDataSource);
    });

    group('createProject', () {
      test('should throw exception for invalid project name', () async {
        await expectLater(
          repository.createProject('ab', '/home/test/project'),
          throwsA(isA<InvalidProjectNameException>()),
        );
      });

      test('should throw exception for path traversal attempt', () async {
        await expectLater(
          repository.createProject('test-project', '../../../etc/passwd'),
          throwsA(isA<PathTraversalException>()),
        );
      });

      test('should throw exception for tilde in path', () async {
        await expectLater(
          repository.createProject('test-project', '~/malicious/path'),
          throwsA(isA<PathTraversalException>()),
        );
      });
    });
  });
}
