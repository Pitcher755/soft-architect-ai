// lib/features/project_shell/presentation/providers/project_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../domain/repositories/project_repository.dart';
import '../notifiers/project_shell_notifier.dart';

/// Repository provider
/// TODO: Implement with actual database setup
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  throw UnimplementedError('Repository provider - implement with database');
});

/// Main state notifier provider for project shell
/// Usage: ref.watch(projectShellProvider)
final projectShellProvider =
    StateNotifierProvider<ProjectShellNotifier, ProjectShellState>((ref) {
      final repository = ref.watch(projectRepositoryProvider);
      return ProjectShellNotifier(repository);
    });
