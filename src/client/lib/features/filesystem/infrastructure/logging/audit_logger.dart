// ignore_for_file: avoid_slow_async_io

import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

/// Audit logger for filesystem operations.
///
/// Logs all write operations to `.audit.log` file in project's planning
/// directory.
///
/// **Format:**
/// ```
/// [2026-02-05 10:30:45] WRITE: context/10-CONTEXT/doc.md (Size: 1.2 KB)
/// [2026-02-05 10:31:12] DELETE: context/old.md
/// [2026-02-05 10:32:00] CREATE_PROJECT: /home/user/projects/MyProject
/// ```
///
/// **Security Note:**
/// - Log file is NOT validated by PathValidator (internal use only)
/// - Hidden file (`.audit.log`) to prevent accidental edits
class AuditLogger {
  /// Constructor: Initialize audit logger with project root.
  ///
  /// The log file path is computed as:
  /// `projectRoot/context/40-PLANNING/.audit.log`
  AuditLogger({required this.projectRoot}) {
    _logFilePath = p.join(projectRoot, 'context/40-PLANNING/.audit.log');
  }

  /// Absolute path to the project root directory.
  final String projectRoot;

  /// Late-initialized path to the audit log file.
  late final String _logFilePath;

  /// DateFormat for consistent timestamp formatting.
  static final _dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');

  /// Logs a write operation with file size.
  ///
  /// **Example:**
  /// ```dart
  /// await logger.logWrite('context/10-CONTEXT/doc.md', 2048);
  /// // Outputs: [2026-02-05 10:30:45] WRITE: context/10-CONTEXT/doc.md
  /// //          (Size: 2.0 KB)
  /// ```
  Future<void> logWrite(String relativePath, int sizeBytes) async {
    await _log('WRITE', '$relativePath (Size: ${_formatSize(sizeBytes)})');
  }

  /// Logs a delete operation.
  ///
  /// **Example:**
  /// ```dart
  /// await logger.logDelete('context/old.md');
  /// // Outputs: [2026-02-05 10:31:12] DELETE: context/old.md
  /// ```
  Future<void> logDelete(String relativePath) async {
    await _log('DELETE', relativePath);
  }

  /// Logs project creation event.
  ///
  /// **Example:**
  /// ```dart
  /// await logger.logProjectCreation('/home/user/projects/MyProject');
  /// // Outputs: [2026-02-05 10:32:00] CREATE_PROJECT:
  /// //          /home/user/projects/MyProject
  /// ```
  Future<void> logProjectCreation(String projectPath) async {
    await _log('CREATE_PROJECT', projectPath);
  }

  /// Logs a generic operation with custom operation name and details.
  ///
  /// **Example:**
  /// ```dart
  /// await logger.logOperation('READ', 'README.md');
  /// ```
  Future<void> logOperation(String operation, String details) async {
    await _log(operation, details);
  }

  /// Internal method: Performs the actual logging.
  ///
  /// **Behavior:**
  /// - Creates parent directory if missing (recursive)
  /// - Appends entry to log file in UTF-8
  /// - Silently fails if logging errors occur (non-blocking)
  Future<void> _log(String operation, String details) async {
    final timestamp = _dateFormat.format(DateTime.now());
    final entry = '[$timestamp] $operation: $details\n';

    try {
      final logFile = File(_logFilePath);

      // Create parent directory if missing (recursive: true)
      final parentDir = logFile.parent;
      if (!await parentDir.exists()) {
        await parentDir.create(recursive: true);
      }

      // Append to log file
      await logFile.writeAsString(entry, mode: FileMode.append);
    } on FileSystemException {
      // Silently fail - logging should not break operations
    }
  }

  /// Formats file size in human-readable format.
  ///
  /// **Examples:**
  /// - 512 bytes → "512 B"
  /// - 1024 bytes → "1.0 KB"
  /// - 1048576 bytes → "1.0 MB"
  String _formatSize(int bytes) {
    const kb = 1024;
    const mb = kb * 1024;

    if (bytes < kb) {
      return '$bytes B';
    }
    if (bytes < mb) {
      return '${(bytes / kb).toStringAsFixed(1)} KB';
    }
    return '${(bytes / mb).toStringAsFixed(1)} MB';
  }

  /// Reads the entire audit log and returns lines as a list.
  ///
  /// **Returns:**
  /// - Empty list if log file doesn't exist
  /// - List of non-empty lines if log exists
  ///
  /// **Example:**
  /// ```dart
  /// final entries = await logger.readLog();
  /// for (final entry in entries) {
  ///   print(entry);
  /// }
  /// ```
  Future<List<String>> readLog() async {
    final logFile = File(_logFilePath);
    if (!await logFile.exists()) {
      return [];
    }

    final content = await logFile.readAsString();
    return content.split('\n').where((line) => line.isNotEmpty).toList();
  }

  /// Clears the audit log (deletes the log file).
  ///
  /// **Warning:** This is destructive. Use with caution in tests or with
  /// user confirmation.
  ///
  /// **Example:**
  /// ```dart
  /// await logger.clearLog();
  /// final entries = await logger.readLog();
  /// print('Log cleared: ${entries.isEmpty}'); // true
  /// ```
  Future<void> clearLog() async {
    final logFile = File(_logFilePath);
    if (await logFile.exists()) {
      await logFile.delete();
    }
  }
}
