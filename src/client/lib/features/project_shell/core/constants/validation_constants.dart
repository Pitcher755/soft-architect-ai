// lib/features/project_shell/core/constants/validation_constants.dart

/// Validation patterns and constraints for project shell
class ValidationConstants {
  // Project naming constraints
  /// Pattern: alphanumeric + underscore + hyphen, 3-50 chars
  static const String projectNamePattern = r'^[a-zA-Z0-9_-]{3,50}$';
  static const int projectNameMinLength = 3;
  static const int projectNameMaxLength = 50;

  // File/path validation
  /// Disallowed path components (security - no traversal)
  static const List<String> disallowedPathComponents = ['..', '~', r'$', '`', '\x00'];

  /// Max file path length (prevent DoS)
  static const int maxFilePathLength = 4096;

  /// Allowed file extensions (whitelist)
  static const List<String> allowedFileExtensions = [
    '.dart',
    '.md',
    '.txt',
    '.json',
    '.yaml',
    '.yml',
    '.xml',
    '.html',
    '.css',
    '.js',
    '.ts',
    '.java',
    '.py',
    '.sh',
    '.bash',
    '.gitignore',
    '.env',
    'README',
    'LICENSE',
    'Makefile',
    'Dockerfile',
  ];

  // Error codes (for structured error responses)
  static const String errorCodeInvalidProjectName = 'PROJ_001';
  static const String errorCodeDuplicateProject = 'PROJ_002';
  static const String errorCodeProjectNotFound = 'PROJ_003';
  static const String errorCodePathTraversal = 'SEC_001';
  static const String errorCodeDatabaseError = 'DB_ERR_001';
  static const String errorCodeFileSystemError = 'FS_ERR_001';
  static const String errorCodeUnauthorized = 'SEC_002';
  static const String errorCodeInvalidFileType = 'FILE_001';

  // Logging constants
  /// Do NOT log sensitive data patterns
  static const List<String> sensitivePatterns = [
    'password',
    'api_key',
    'secret',
    'token',
    'credential',
  ];

  /// Max log message length (prevent log injection)
  static const int maxLogLength = 1000;
}
