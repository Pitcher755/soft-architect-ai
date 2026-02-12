import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/project_shell/core/exceptions/project_shell_exceptions.dart';

void main() {
  group('ProjectShell exceptions', () {
    test('InvalidProjectNameException maps to user message', () {
      final ex = InvalidProjectNameException('bad');
      expect(ex.code, 'PROJ_001');
      expect(ex.toString(), contains('Invalid project name'));
      expect(ex.toUserMessage(), contains('3-50'));
    });

    test('DuplicateProjectNameException maps to user message', () {
      final ex = DuplicateProjectNameException('dup');
      expect(ex.code, 'PROJ_002');
      expect(ex.toUserMessage(), contains('Ya existe'));
    });

    test('PathTraversalException maps to user message', () {
      final ex = PathTraversalException('../etc/passwd');
      expect(ex.code, 'SEC_001');
      expect(ex.toUserMessage(), contains('Ruta de archivo inválida'));
    });

    test('DatabaseException, FileSystemException and others keep code', () {
      final db = DatabaseException('db error');
      final fs = FileSystemException('fs error');
      final notFound = ProjectNotFoundException('x');
      final invalidType = InvalidFileTypeException('x.exe');
      final unauthorized = UnauthorizedException('denied');

      expect(db.code, 'DB_ERR_001');
      expect(fs.code, 'FS_ERR_001');
      expect(notFound.code, 'PROJ_003');
      expect(invalidType.code, 'FILE_001');
      expect(unauthorized.code, 'SEC_002');
      expect(db.toUserMessage(), contains('base de datos'));
      expect(fs.toUserMessage(), contains('sistema de archivos'));
      expect(notFound.toUserMessage(), contains('no existe'));
      expect(invalidType.toUserMessage(), contains('Tipo de archivo'));
      expect(unauthorized.toUserMessage(), contains('No tienes permiso'));
    });
  });
}
