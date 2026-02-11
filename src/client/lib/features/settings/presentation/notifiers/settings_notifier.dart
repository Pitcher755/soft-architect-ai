import 'dart:developer' as developer;

import 'package:flutter_riverpod/legacy.dart';

import '../../domain/entities/accessibility_settings.dart';
import '../../domain/entities/language_preference.dart';
import '../../domain/entities/performance_settings.dart';
import '../../domain/entities/settings_entity.dart';
import '../../domain/entities/theme_preference.dart';
import '../../domain/usecases/load_settings_usecase.dart';
import '../../domain/usecases/save_settings_usecase.dart';

/// Notifier for managing application settings state.
///
/// Handles loading, saving, and updating settings using use cases.
/// Automatically persists changes to local storage via SharedPreferences.
///
/// Example usage (in a widget):
/// ```dart
/// final settings = ref.watch(settingsProvider);
/// final notifier = ref.read(settingsProvider.notifier);
/// await notifier.updateLanguage(LanguagePreference.es);
/// ```
class SettingsNotifier extends StateNotifier<SettingsEntity> {
  /// Creates a [SettingsNotifier] instance.
  ///
  /// Requires use cases for loading and saving settings.
  SettingsNotifier({
    required LoadSettingsUseCase loadSettingsUseCase,
    required SaveSettingsUseCase saveSettingsUseCase,
  }) : _loadSettingsUseCase = loadSettingsUseCase,
       _saveSettingsUseCase = saveSettingsUseCase,
       super(SettingsEntity.defaultSettings()) {
    // Load settings on initialization
    _loadInitialSettings();
  }

  final LoadSettingsUseCase _loadSettingsUseCase;
  final SaveSettingsUseCase _saveSettingsUseCase;

  /// Loads initial settings from storage.
  ///
  /// Called automatically during notifier initialization.
  Future<void> _loadInitialSettings() async {
    try {
      final settings = await _loadSettingsUseCase.call();
      state = settings;
    } on Exception catch (e) {
      // On error, keep default settings
      developer.log(
        'Failed to load initial settings: $e',
        name: 'SettingsNotifier',
      );
    }
  }

  /// Updates the user profile (name and email).
  ///
  /// Automatically persists the change to storage.
  Future<void> updateUserProfile({String? name, String? email}) async {
    try {
      final updated = state.copyWith(userName: name, email: email);
      await _saveSettingsUseCase.call(updated);
      state = updated;
    } catch (e) {
      developer.log(
        'Failed to update user profile: $e',
        name: 'SettingsNotifier',
      );
      rethrow;
    }
  }

  /// Updates the storage path.
  ///
  /// Automatically persists the change to storage.
  Future<void> updateStoragePath(String path) async {
    try {
      final updated = state.copyWith(storagePath: path);
      await _saveSettingsUseCase.call(updated);
      state = updated;
    } catch (e) {
      developer.log(
        'Failed to update storage path: $e',
        name: 'SettingsNotifier',
      );
      rethrow;
    }
  }

  /// Updates the language preference.
  ///
  /// Automatically persists the change to storage.
  Future<void> updateLanguage(LanguagePreference language) async {
    try {
      final updated = state.copyWith(language: language);
      await _saveSettingsUseCase.call(updated);
      state = updated;
    } catch (e) {
      developer.log('Failed to update language: $e', name: 'SettingsNotifier');
      rethrow;
    }
  }

  /// Updates the theme preference.
  ///
  /// Automatically persists the change to storage.
  Future<void> updateTheme(ThemePreference theme) async {
    try {
      final updated = state.copyWith(theme: theme);
      await _saveSettingsUseCase.call(updated);
      state = updated;
    } catch (e) {
      developer.log('Failed to update theme: $e', name: 'SettingsNotifier');
      rethrow;
    }
  }

  /// Updates the accessibility settings.
  ///
  /// Automatically persists the change to storage.
  Future<void> updateAccessibility(AccessibilitySettings accessibility) async {
    try {
      final updated = state.copyWith(accessibility: accessibility);
      await _saveSettingsUseCase.call(updated);
      state = updated;
    } catch (e) {
      developer.log(
        'Failed to update accessibility: $e',
        name: 'SettingsNotifier',
      );
      rethrow;
    }
  }

  /// Updates the performance settings.
  ///
  /// Automatically persists the change to storage.
  Future<void> updatePerformance(PerformanceSettings performance) async {
    try {
      final updated = state.copyWith(performance: performance);
      await _saveSettingsUseCase.call(updated);
      state = updated;
    } catch (e) {
      developer.log(
        'Failed to update performance settings: $e',
        name: 'SettingsNotifier',
      );
      rethrow;
    }
  }

  /// Resets all settings to defaults.
  ///
  /// Useful for testing or when user wants to start fresh.
  Future<void> resetToDefaults() async {
    try {
      final defaults = SettingsEntity.defaultSettings();
      await _saveSettingsUseCase.call(defaults);
      state = defaults;
    } catch (e) {
      developer.log(
        'Failed to reset settings to defaults: $e',
        name: 'SettingsNotifier',
      );
      rethrow;
    }
  }
}
