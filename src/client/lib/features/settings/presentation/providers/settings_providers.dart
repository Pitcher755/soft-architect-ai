import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/datasources/last_project_local_datasource.dart';
import '../../data/datasources/settings_local_datasource.dart';
import '../../data/repositories/last_project_repository_impl.dart';
import '../../data/repositories/settings_repository_impl.dart';
import '../../domain/entities/settings_entity.dart';
import '../../domain/usecases/load_last_project_usecase.dart';
import '../../domain/usecases/load_settings_usecase.dart';
import '../../domain/usecases/save_last_project_usecase.dart';
import '../../domain/usecases/save_settings_usecase.dart';
import '../notifiers/settings_notifier.dart';

// ============================================================================
// DATA SOURCES
// ============================================================================

/// Provides [SettingsLocalDataSource] singleton.
final settingsLocalDataSourceProvider = Provider<SettingsLocalDataSource>(
  (ref) => SettingsLocalDataSource(),
);

/// Provides [LastProjectLocalDataSource] singleton.
final lastProjectLocalDataSourceProvider = Provider<LastProjectLocalDataSource>(
  (ref) => LastProjectLocalDataSource(),
);

// ============================================================================
// REPOSITORIES
// ============================================================================

/// Provides [SettingsRepositoryImpl] singleton.
final settingsRepositoryProvider = Provider((ref) {
  final dataSource = ref.watch(settingsLocalDataSourceProvider);
  return SettingsRepositoryImpl(dataSource);
});

/// Provides [LastProjectRepositoryImpl] singleton.
final lastProjectRepositoryProvider = Provider((ref) {
  final dataSource = ref.watch(lastProjectLocalDataSourceProvider);
  return LastProjectRepositoryImpl(dataSource);
});

// ============================================================================
// USE CASES
// ============================================================================

/// Provides [LoadSettingsUseCase] singleton.
final loadSettingsUseCaseProvider = Provider((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return LoadSettingsUseCase(repository);
});

/// Provides [SaveSettingsUseCase] singleton.
final saveSettingsUseCaseProvider = Provider((ref) {
  final repository = ref.watch(settingsRepositoryProvider);
  return SaveSettingsUseCase(repository);
});

/// Provides [LoadLastProjectUseCase] singleton.
final loadLastProjectUseCaseProvider = Provider((ref) {
  final repository = ref.watch(lastProjectRepositoryProvider);
  return LoadLastProjectUseCase(repository);
});

/// Provides [SaveLastProjectUseCase] singleton.
final saveLastProjectUseCaseProvider = Provider((ref) {
  final repository = ref.watch(lastProjectRepositoryProvider);
  return SaveLastProjectUseCase(repository);
});

// ============================================================================
// STATE PROVIDERS
// ============================================================================

/// Provides the application settings state.
///
/// This is the main provider for accessing and updating settings throughout the app.
///
/// Example usage:
/// ```dart
/// // Read settings
/// final settings = ref.watch(settingsProvider);
/// print('Language: ${settings.language.displayName}');
///
/// // Update settings
/// final notifier = ref.read(settingsProvider.notifier);
/// await notifier.updateLanguage(LanguagePreference.es);
/// ```
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsEntity>((ref) {
      final loadUseCase = ref.watch(loadSettingsUseCaseProvider);
      final saveUseCase = ref.watch(saveSettingsUseCaseProvider);

      return SettingsNotifier(
        loadSettingsUseCase: loadUseCase,
        saveSettingsUseCase: saveUseCase,
      );
    });

/// Provides the last opened project path.
///
/// This provider loads the path on initialization and can be updated
/// when a user opens a different project.
///
/// Example usage:
/// ```dart
/// // Read last project path
/// final lastProjectPath = ref.watch(lastProjectProvider);
///
/// // Update last project path
/// ref.read(lastProjectProvider.notifier).state = '/path/to/new/project';
/// await ref.read(saveLastProjectUseCaseProvider).call('/path/to/new/project');
/// ```
final lastProjectProvider = StateNotifierProvider<LastProjectNotifier, String?>(
  (ref) {
    final loadUseCase = ref.watch(loadLastProjectUseCaseProvider);
    final saveUseCase = ref.watch(saveLastProjectUseCaseProvider);

    return LastProjectNotifier(
      loadLastProjectUseCase: loadUseCase,
      saveLastProjectUseCase: saveUseCase,
    );
  },
);

/// Notifier for managing the last opened project path.
///
/// Handles loading and saving the last project path to local storage.
class LastProjectNotifier extends StateNotifier<String?> {
  /// Creates a [LastProjectNotifier] instance.
  LastProjectNotifier({
    required LoadLastProjectUseCase loadLastProjectUseCase,
    required SaveLastProjectUseCase saveLastProjectUseCase,
  }) : _loadLastProjectUseCase = loadLastProjectUseCase,
       _saveLastProjectUseCase = saveLastProjectUseCase,
       super(null) {
    // Load last project path on initialization
    _loadInitialPath();
  }

  final LoadLastProjectUseCase _loadLastProjectUseCase;
  final SaveLastProjectUseCase _saveLastProjectUseCase;

  /// Loads the initial last project path from storage.
  Future<void> _loadInitialPath() async {
    try {
      final path = await _loadLastProjectUseCase.call();
      state = path;
    } catch (e) {
      // On error, keep null state
    }
  }

  /// Updates the last project path and persists it to storage.
  Future<void> updateLastProject(String path) async {
    try {
      await _saveLastProjectUseCase.call(path);
      state = path;
    } catch (e) {
      // TODO: Handle error (show snackbar, log, etc.)
    }
  }
}
