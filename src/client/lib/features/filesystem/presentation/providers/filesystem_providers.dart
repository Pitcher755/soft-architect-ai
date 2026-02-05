import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../domain/repositories/filesystem_repository.dart';
import '../../infrastructure/logging/audit_logger.dart';
import '../../infrastructure/services/filesystem_service_impl.dart';

/// Provider for project root path.
///
/// MUST be overridden with actual project root when user opens/creates a project.
///
/// Usage:
/// ```dart
/// ref.read(projectRootProvider.notifier).state = '/home/user/my_project';
/// ```
final projectRootProvider = StateProvider<String?>((ref) => null);

/// Provider for FileSystemRepository.
///
/// Automatically instantiates when project root is available.
/// Returns null if no project is open.
final fileSystemRepositoryProvider = Provider<FileSystemRepository?>((ref) {
  final projectRoot = ref.watch(projectRootProvider);
  if (projectRoot == null) {
    return null;
  }
  return FileSystemServiceImpl(projectRoot: projectRoot);
});

/// Provider for AuditLogger.
///
/// Automatically instantiates when project root is available.
/// Returns null if no project is open.
final auditLoggerProvider = Provider<AuditLogger?>((ref) {
  final projectRoot = ref.watch(projectRootProvider);
  if (projectRoot == null) {
    return null;
  }
  return AuditLogger(projectRoot: projectRoot);
});

/// State provider for filesystem operation status.
///
/// UI can watch this to show loading indicators during I/O operations.
final filesystemLoadingProvider = StateProvider<bool>((ref) => false);

/// State provider for last filesystem error.
///
/// UI can watch this to display error messages in Snackbars/Toasts.
final filesystemErrorProvider = StateProvider<String?>((ref) => null);
