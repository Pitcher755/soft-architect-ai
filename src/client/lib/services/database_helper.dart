/// Database Helper for SoftArchitect AI Flutter Client.
///
/// This service manages the local SQLite database (user_data.db) for storing
/// project metadata. The database is 100% Flutter-managed and is the Single
/// Source of Truth for project information.
///
/// Database Schema:
///   - projects: Local project metadata (name, path, creation timestamp)
///
/// Note: This is strictly CLIENT-SIDE only. The Backend (Python) does NOT
/// have access to this database and does NOT manage projects. All file I/O
/// and project state is managed by the Flutter client.
///
/// Architecture Decision (Project-First Refactor):
///   - Backend: Stateless, no filesystem access, no project persistence
///   - Frontend: Project owner, filesystem manager, persistence authority
library;

import 'dart:io' as io;

import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Data model for a project stored in the local SQLite database.
class ProjectModel {
  ProjectModel({
    required this.id,
    required this.name,
    required this.path,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Create model from database JSON.
  factory ProjectModel.fromMap(Map<String, dynamic> map) => ProjectModel(
    id: map['id'] as String,
    name: map['name'] as String,
    path: map['path'] as String,
    createdAt: DateTime.parse(map['created_at'] as String),
    updatedAt: DateTime.parse(map['updated_at'] as String),
  );

  final String id;
  final String name;
  final String path;
  final DateTime createdAt;
  final DateTime updatedAt;

  /// Convert model to JSON for database storage.
  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'path': path,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  /// Create a copy with optional field updates.
  ProjectModel copyWith({
    String? id,
    String? name,
    String? path,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => ProjectModel(
    id: id ?? this.id,
    name: name ?? this.name,
    path: path ?? this.path,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );

  @override
  String toString() =>
      'ProjectModel(id: $id, name: $name, path: $path, '
      'createdAt: $createdAt, updatedAt: $updatedAt)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProjectModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          name == other.name &&
          path == other.path;

  @override
  int get hashCode => id.hashCode ^ name.hashCode ^ path.hashCode;
}

/// Exception for database-related errors.
class DatabaseException implements Exception {
  DatabaseException(this.message, [this.originalException]);

  final String message;
  final Exception? originalException;

  @override
  String toString() =>
      'DatabaseException: $message'
      '${originalException != null ? '\nCause: $originalException' : ''}';
}

/// Main service for managing the local SQLite database.
///
/// This service handles all database operations for projects:
///   - Initialize database and schema
///   - Create, read, update, delete projects
///   - Query projects by ID or list all
///
/// Thread Safety: All operations use sqflite's built-in locking.
/// Idempotency: All operations are safe to call multiple times.
class DatabaseHelper {
  static const String _databaseName = 'user_data.db';
  static const int _databaseVersion = 1;
  static const String _projectsTable = 'projects';

  static Database? _database;

  /// Get or create the database connection (singleton pattern).
  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialize the database and create schema.
  Future<Database> _initDatabase() async {
    try {
      final databasesPath = await getDatabasesPath();
      final path = p.join(databasesPath, _databaseName);

      return await openDatabase(
        path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      );
    } catch (e) {
      throw DatabaseException('Failed to initialize database', e as Exception);
    }
  }

  /// Create database schema (called on first creation).
  Future<void> _onCreate(Database db, int version) async {
    try {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS $_projectsTable (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          path TEXT NOT NULL UNIQUE,
          created_at TEXT NOT NULL,
          updated_at TEXT NOT NULL
        )
      ''');
    } catch (e) {
      throw DatabaseException('Failed to create schema', e as Exception);
    }
  }

  /// Handle database upgrades (called when version changes).
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Placeholder for future schema migrations
    // Example: ALTER TABLE, add columns, etc.
  }

  /// Insert a new project into the database.
  ///
  /// Returns the inserted project.
  /// Throws [DatabaseException] if project path already exists or on I/O error.
  Future<ProjectModel> insertProject(ProjectModel project) async {
    try {
      final db = await database;

      // Check if path already exists (prevent duplicates)
      final existing = await db.query(
        _projectsTable,
        where: 'path = ?',
        whereArgs: [project.path],
      );

      if (existing.isNotEmpty) {
        throw DatabaseException(
          'Project with path "${project.path}" already exists',
        );
      }

      await db.insert(
        _projectsTable,
        project.toMap(),
        conflictAlgorithm: ConflictAlgorithm.rollback,
      );

      return project;
    } catch (e) {
      if (e is DatabaseException) {
        rethrow;
      }
      throw DatabaseException('Failed to insert project', e as Exception);
    }
  }

  /// Retrieve a project by ID.
  ///
  /// Returns null if project not found.
  /// Throws [DatabaseException] on database error.
  Future<ProjectModel?> getProjectById(String id) async {
    try {
      final db = await database;
      final maps = await db.query(
        _projectsTable,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (maps.isEmpty) {
        return null;
      }
      return ProjectModel.fromMap(maps.first);
    } catch (e) {
      throw DatabaseException(
        'Failed to retrieve project by ID',
        e as Exception,
      );
    }
  }

  /// Retrieve all projects from the database.
  ///
  /// Returns empty list if no projects exist.
  /// Throws [DatabaseException] on database error.
  Future<List<ProjectModel>> getAllProjects() async {
    try {
      final db = await database;
      final maps = await db.query(_projectsTable, orderBy: 'updated_at DESC');

      return maps.map(ProjectModel.fromMap).toList();
    } catch (e) {
      throw DatabaseException(
        'Failed to retrieve all projects',
        e as Exception,
      );
    }
  }

  /// Retrieve a project by filesystem path.
  ///
  /// Returns null if not found.
  /// Throws [DatabaseException] on database error.
  Future<ProjectModel?> getProjectByPath(String path) async {
    try {
      final db = await database;
      final maps = await db.query(
        _projectsTable,
        where: 'path = ?',
        whereArgs: [path],
      );

      if (maps.isEmpty) {
        return null;
      }
      return ProjectModel.fromMap(maps.first);
    } catch (e) {
      throw DatabaseException(
        'Failed to retrieve project by path',
        e as Exception,
      );
    }
  }

  /// Update an existing project.
  ///
  /// Throws [DatabaseException] if project not found or on database error.
  Future<ProjectModel> updateProject(ProjectModel project) async {
    try {
      final db = await database;

      // Verify project exists
      final existing = await getProjectById(project.id);
      if (existing == null) {
        throw DatabaseException('Project with ID "${project.id}" not found');
      }

      // Update with fresh timestamp
      final updated = project.copyWith(updatedAt: DateTime.now());

      await db.update(
        _projectsTable,
        updated.toMap(),
        where: 'id = ?',
        whereArgs: [project.id],
      );

      return updated;
    } catch (e) {
      if (e is DatabaseException) {
        rethrow;
      }
      throw DatabaseException('Failed to update project', e as Exception);
    }
  }

  /// Delete a project by ID.
  ///
  /// Returns true if deleted, false if not found.
  /// Throws [DatabaseException] on database error.
  Future<bool> deleteProject(String id) async {
    try {
      final db = await database;

      final result = await db.delete(
        _projectsTable,
        where: 'id = ?',
        whereArgs: [id],
      );

      return result > 0;
    } catch (e) {
      throw DatabaseException('Failed to delete project', e as Exception);
    }
  }

  /// Delete all projects from the database (use with caution).
  ///
  /// Throws [DatabaseException] on database error.
  Future<void> deleteAllProjects() async {
    try {
      final db = await database;
      await db.delete(_projectsTable);
    } catch (e) {
      throw DatabaseException('Failed to delete all projects', e as Exception);
    }
  }

  /// Close the database connection.
  ///
  /// Call this in app shutdown to ensure data is flushed.
  Future<void> close() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// Reset the database (used for testing/debugging).
  ///
  /// Deletes all data and closes the connection.
  /// The database will be recreated on next access.
  Future<void> reset() async {
    try {
      final databasesPath = await getDatabasesPath();
      final path = p.join(databasesPath, _databaseName);

      await close();

      // Delete the database file
      final databaseFile = io.File(path);
      // ignore: avoid_slow_async_io
      if (await databaseFile.exists()) {
        // ignore: avoid_slow_async_io
        await databaseFile.delete();
      }
    } catch (e) {
      throw DatabaseException('Failed to reset database', e as Exception);
    }
  }

  /// Get database file size in bytes (for debugging/monitoring).
  ///
  /// Returns -1 if file doesn't exist.
  Future<int> getDatabaseFileSize() async {
    try {
      final databasesPath = await getDatabasesPath();
      final path = p.join(databasesPath, _databaseName);
      final file = io.File(path);

      // ignore: avoid_slow_async_io
      if (await file.exists()) {
        // ignore: avoid_slow_async_io
        return await file.length();
      }
      return -1;
    } catch (e) {
      throw DatabaseException(
        'Failed to get database file size',
        e as Exception,
      );
    }
  }
}
