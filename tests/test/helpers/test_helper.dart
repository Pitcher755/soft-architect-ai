// tests/test_helper.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:softarchitect_ai/features/project_shell/data/data_sources/sqlite_data_source.dart';

/// Helper para inicializar SQLite en memoria para tests
Future<sqflite.Database> initTestDatabase() async {
  // En tests, usar base de datos en memoria
  final db = await sqflite.openDatabase(
    ':memory:',
    version: 1,
    onCreate: (db, version) async {
      await SQLiteDataSource.createTables(db);
    },
  );
  return db;
}

/// Helper para limpiar la base de datos después de los tests
Future<void> closeTestDatabase(sqflite.Database db) async {
  await db.close();
}
