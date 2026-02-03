// tests/test_helper.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:softarchitect_ai/features/project_shell/data/data_sources/sqlite_data_source.dart';
import 'package:softarchitect_ai/features/project_shell/domain/repositories/project_repository.dart';
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

// Generar mocks: dart run build_runner build
@GenerateMocks([ProjectRepository, SQLiteDataSource])
void main() {
  // Stub setup
}

/// Helper para inicializar SQLite en memoria para tests
Future<Database> initTestDatabase() async {
  sqfliteFfiInit();
  final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
  // Inicializar tablas
  await SQLiteDataSource.createTables(db);
  return db;
}
