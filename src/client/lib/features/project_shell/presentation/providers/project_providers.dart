// lib/features/project_shell/presentation/providers/project_providers.dart
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/repositories/web_mock_project_repository.dart';
import '../../domain/repositories/project_repository.dart';
import '../notifiers/project_shell_notifier.dart';

/// Repository provider with platform-specific implementation
///
/// On web: Uses in-memory mock repository
/// On desktop/mobile: Uses database-backed repository
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  if (kIsWeb) {
    // Web platform: Use in-memory mock
    debugPrint('📦 Using WebMockProjectRepository (web platform)');
    return WebMockProjectRepository();
  } else {
    // Desktop/Mobile: Would use real database repository
    // For now, also use mock to keep things working
    debugPrint('📦 Using WebMockProjectRepository (fallback)');
    return WebMockProjectRepository();
  }
});

/// Main state notifier provider for project shell
/// Usage: ref.watch(projectShellProvider)
final projectShellProvider =
    StateNotifierProvider<ProjectShellNotifier, ProjectShellState>((ref) {
  final repository = ref.watch(projectRepositoryProvider);
  return ProjectShellNotifier(repository);
});
