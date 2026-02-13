import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:softarchitect_ai/features/settings/presentation/providers/settings_providers.dart';

import '../../../../../test_helpers/shared_preferences_mock.dart';

/// Integration tests for SettingsNotifier persistence layer.
///
/// These tests are separated from the main settings_provider_test.dart
/// to avoid SharedPreferences mock conflicts with setUp() initialization.
/// Each test in this file manages its own mock initialization.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('SettingsNotifier - Persistence Integration', () {
    test('should load persisted settings on initialization', () async {
      // Initialize mock with pre-populated data
      initMockSharedPreferences({
        'app_settings_v2':
            '{"themeMode":2,"fontSize":1.3,"globalZoom":1.5,"enableZoomShortcuts":false,"enableAnimations":false,"enableMemoryOptimization":false,"userName":"PersistedUser","avatarIndex":2,"projectDirectory":"/persisted/path"}',
      });

      // Create new container to trigger initialization from SharedPreferences
      final container = ProviderContainer();

      // Wait for async initialization to complete
      await container.read(settingsProvider.future);

      final settings = container.read(settingsProvider).requireValue;

      // Verify all persisted values were loaded
      expect(settings.userName, 'PersistedUser');
      expect(settings.themeMode, ThemeMode.dark); // themeMode:2 = dark
      expect(settings.fontSize, 1.3);
      expect(settings.globalZoom, 1.5);
      expect(settings.enableZoomShortcuts, false);
      expect(settings.enableAnimations, false);
      expect(settings.enableMemoryOptimization, false);
      expect(settings.avatarIndex, 2);
      expect(settings.projectDirectory, '/persisted/path');

      container.dispose();
    });

    test('should handle corrupted JSON gracefully with fallback defaults',
        () async {
      // Setup corrupted JSON data
      initMockSharedPreferences({
        'app_settings_v2': '{invalid json syntax}',
      });

      final container = ProviderContainer();

      // Wait for async initialization
      await container.read(settingsProvider.future);

      final settings = container.read(settingsProvider).requireValue;

      // Verify fallback to default values
      expect(settings.userName, 'Architect');
      expect(settings.themeMode, ThemeMode.dark);
      expect(settings.fontSize, 1.0);
      expect(settings.globalZoom, 1.0);
      expect(settings.enableZoomShortcuts, true);
      expect(settings.enableAnimations, true);
      expect(settings.enableMemoryOptimization, true);

      container.dispose();
    });

    test('should handle missing settings key with default initialization',
        () async {
      // Initialize with empty map (no 'app_settings_v2' key)
      initMockSharedPreferences({});

      final container = ProviderContainer();

      await container.read(settingsProvider.future);

      final settings = container.read(settingsProvider).requireValue;

      // Verify default initialization
      expect(settings.userName, 'Architect');
      expect(settings.themeMode, ThemeMode.dark);
      expect(settings.fontSize, 1.0);
      expect(settings.avatarIndex, 0);
      expect(settings.projectDirectory, isNull);

      container.dispose();
    });

    test('should handle partial JSON data with fallback for missing fields',
        () async {
      // JSON with only some fields
      initMockSharedPreferences({
        'app_settings_v2': '{"userName":"PartialUser","fontSize":1.2}',
      });

      final container = ProviderContainer();

      await container.read(settingsProvider.future);

      final settings = container.read(settingsProvider).requireValue;

      // Verify partial load + defaults for missing fields
      expect(settings.userName, 'PartialUser'); // From JSON
      expect(settings.fontSize, 1.2); // From JSON
      expect(settings.themeMode, ThemeMode.light); // Default from fromJson
      expect(settings.globalZoom, 1.0); // Default
      expect(settings.avatarIndex, 0); // Default

      container.dispose();
    });
  });
}
