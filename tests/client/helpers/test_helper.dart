// tests/test_helper.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/project_shell/data/data_sources/sqlite_data_source.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

/// Flag to ensure sqflite is initialized only once across all tests
///
/// ✅ FIX: Prevents "You are changing sqflite default factory" warning
/// by initializing the factory only on first call.
bool _isSqfliteInitialized = false;

/// Initialize sqflite FFI for testing (call once in setUpAll)
///
/// ✅ SAFE: Uses flag to prevent multiple initializations
/// which would trigger sqflite warnings.
void initSqfliteForTest() {
  if (!_isSqfliteInitialized) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    _isSqfliteInitialized = true;
  }
}

/// Helper para inicializar SQLite en memoria para tests
Future<sqflite.Database> initTestDatabase() async {
  // ✅ CRITICAL FIX: Initialize sqflite only once to avoid warnings
  initSqfliteForTest();

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
