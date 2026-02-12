import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/filesystem/domain/exceptions/filesystem_exceptions.dart';

void main() {
  group('FileSystemException hierarchy', () {
    test('PathTraversalException contains security code and details', () {
      final ex = PathTraversalException('../secret');
      expect(ex.code, 'SEC_001');
      expect(ex.message, contains('acceso ilegal'));
      expect(ex.details?['attempted_path'], '../secret');
      expect(ex.toString(), contains('[SEC_001]'));
    });

    test('DiskSpaceException contains path and required bytes', () {
      final ex = DiskSpaceException('/tmp/a', 1024);
      expect(ex.code, 'FS_001');
      expect(ex.details?['path'], '/tmp/a');
      expect(ex.details?['required_bytes'], 1024);
    });

    test('PermissionDeniedException and FileNotFoundException map data', () {
      final denied = PermissionDeniedException('/tmp/a');
      final notFound = FileNotFoundException('/tmp/b');
      expect(denied.code, 'FS_002');
      expect(notFound.code, 'FS_003');
      expect(denied.details?['path'], '/tmp/a');
      expect(notFound.details?['path'], '/tmp/b');
    });

    test('InvalidFileOperationException stores operation and reason', () {
      final ex = InvalidFileOperationException('write', 'is directory');
      expect(ex.code, 'FS_004');
      expect(ex.details?['operation'], 'write');
      expect(ex.details?['reason'], 'is directory');
      expect(ex.message, contains('Operación inválida'));
    });
  });
}
