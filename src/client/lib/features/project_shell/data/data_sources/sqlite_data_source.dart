// lib/features/project_shell/data/data_sources/sqlite_data_source.dart
import 'dart:developer' as developer;

import 'package:sqflite/sqflite.dart' as sqflite;

import '../../core/exceptions/project_shell_exceptions.dart';
import '../models/project_model.dart';

const String _projectTableName = 'projects';

/// Data source for SQLite operations on projects
class SQLiteDataSource {
  SQLiteDataSource(this.database);
  final sqflite.Database database;

  /// Save project to database
  Future<void> saveProject(ProjectModel project) async {
    try {
      developer.log('Saving project: ${project.id}', name: 'SQLiteDataSource');
      await database.insert(
        _projectTableName,
        project.toJson(),
        conflictAlgorithm: sqflite.ConflictAlgorithm.fail,
      );
    } catch (e, st) {
      throw DatabaseException(
        'Failed to save project: $e',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// Get project by ID
  Future<ProjectModel?> getProject(String projectId) async {
    try {
      final result = await database.query(
        _projectTableName,
        where: 'id = ?',
        whereArgs: [projectId],
      );

      if (result.isEmpty) return null;
      return ProjectModel.fromJson(result.first);
    } catch (e, st) {
      throw DatabaseException(
        'Failed to get project: $e',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// Get all projects
  Future<List<ProjectModel>> getAllProjects() async {
    try {
      final results = await database.query(_projectTableName);
      return results.map(ProjectModel.fromJson).toList();
    } catch (e, st) {
      throw DatabaseException(
        'Failed to get all projects: $e',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// Update project last opened time
  Future<void> updateLastOpened(String projectId) async {
    try {
      developer.log('Updating lastOpened: $projectId', name: 'SQLiteDataSource');
      await database.update(
        _projectTableName,
        {'last_opened': DateTime.now().toIso8601String()},
        where: 'id = ?',
        whereArgs: [projectId],
      );
    } catch (e, st) {
      throw DatabaseException(
        'Failed to update last opened: $e',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// Delete project
  Future<void> deleteProject(String projectId) async {
    try {
      developer.log('Deleting project: $projectId', name: 'SQLiteDataSource');
      await database.delete(
        _projectTableName,
        where: 'id = ?',
        whereArgs: [projectId],
      );
    } catch (e, st) {
      throw DatabaseException(
        'Failed to delete project: $e',
        originalError: e,
        stackTrace: st,
      );
    }
  }

  /// Create projects table (init)
  static Future<void> createTables(sqflite.Database db) async {
    developer.log('Creating projects table', name: 'SQLiteDataSource');
    await db.execute('''
      CREATE TABLE IF NOT EXISTS $_projectTableName (
        id TEXT PRIMARY KEY,
        name TEXT UNIQUE NOT NULL,
        path TEXT NOT NULL,
        created_at TEXT NOT NULL,
        last_opened TEXT,
        CHECK (LENGTH(name) >= 3 AND LENGTH(name) <= 50)
      )
    ''');
    developer.log('Projects table created successfully', name: 'SQLiteDataSource');
  }
}
