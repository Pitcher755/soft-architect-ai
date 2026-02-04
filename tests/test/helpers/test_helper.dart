// tests/test_helper.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/project_shell/data/data_sources/sqlite_data_source.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Helper para inicializar SQLite en memoria para tests
Future<sqflite.Database> initTestDatabase() async {
  // Inicializar sqflite para tests
  sqfliteFfiInit();
  databaseFactory = databaseFactoryFfi;

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

/// Helper para limpiar todas las tablas de la base de datos
Future<void> clearTestDatabase(sqflite.Database db) async {
  await db.delete('projects');
}
