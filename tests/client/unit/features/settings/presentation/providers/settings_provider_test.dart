import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softarchitect_ai/features/settings/presentation/providers/settings_providers.dart';

import '../../../../../test_helpers/shared_preferences_mock.dart';

/// Unit tests for SettingsNotifier and AppSettings.
///
/// Tests persistence, state management, and all update methods.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AppSettings', () {
    test('should create instance with default values', () {
      const settings = AppSettings();

      expect(settings.themeMode, ThemeMode.dark);
      expect(settings.fontSize, 1.0);
      expect(settings.globalZoom, 1.0);
      expect(settings.enableZoomShortcuts, true);
      expect(settings.enableAnimations, true);
      expect(settings.enableMemoryOptimization, true);
      expect(settings.userName, 'Architect');
      expect(settings.avatarIndex, 0);
      expect(settings.customAvatarPath, isNull);
      expect(settings.projectDirectory, isNull);
    });

    test('should create instance with custom values', () {
      const settings = AppSettings(
        themeMode: ThemeMode.light,
        fontSize: 1.2,
        globalZoom: 1.5,
        enableZoomShortcuts: false,
        enableAnimations: false,
        enableMemoryOptimization: false,
        userName: 'TestUser',
        avatarIndex: 3,
        customAvatarPath: '/path/to/avatar.png',
        projectDirectory: '/path/to/projects',
      );

      expect(settings.themeMode, ThemeMode.light);
      expect(settings.fontSize, 1.2);
      expect(settings.globalZoom, 1.5);
      expect(settings.enableZoomShortcuts, false);
      expect(settings.enableAnimations, false);
      expect(settings.enableMemoryOptimization, false);
      expect(settings.userName, 'TestUser');
      expect(settings.avatarIndex, 3);
      expect(settings.customAvatarPath, '/path/to/avatar.png');
      expect(settings.projectDirectory, '/path/to/projects');
    });

    test('copyWith should update only specified fields', () {
      const original = AppSettings();
      final updated = original.copyWith(userName: 'NewName', avatarIndex: 2);

      expect(updated.userName, 'NewName');
      expect(updated.avatarIndex, 2);
      // Other fields unchanged
      expect(updated.themeMode, ThemeMode.dark);
      expect(updated.fontSize, 1.0);
    });

    test('toJson should serialize correctly', () {
      const settings = AppSettings(
        themeMode: ThemeMode.light,
        fontSize: 1.3,
        userName: 'TestUser',
        projectDirectory: '/test/path',
      );

      final json = settings.toJson();

      expect(json['themeMode'], 1); // ThemeMode.light index
      expect(json['fontSize'], 1.3);
      expect(json['userName'], 'TestUser');
      expect(json['projectDirectory'], '/test/path');
    });

    test('fromJson should deserialize correctly', () {
      final json = {
        'themeMode': 1, // ThemeMode.light
        'fontSize': 1.4,
        'globalZoom': 1.8,
        'enableZoomShortcuts': false,
        'enableAnimations': false,
        'enableMemoryOptimization': false,
        'userName': 'JsonUser',
        'avatarIndex': 4,
        'customAvatarPath': '/json/avatar.png',
        'projectDirectory': '/json/projects',
      };

      final settings = AppSettings.fromJson(json);

      expect(settings.themeMode, ThemeMode.light);
      expect(settings.fontSize, 1.4);
      expect(settings.globalZoom, 1.8);
      expect(settings.enableZoomShortcuts, false);
      expect(settings.enableAnimations, false);
      expect(settings.enableMemoryOptimization, false);
      expect(settings.userName, 'JsonUser');
      expect(settings.avatarIndex, 4);
      expect(settings.customAvatarPath, '/json/avatar.png');
      expect(settings.projectDirectory, '/json/projects');
    });

    test('fromJson should handle missing fields with defaults', () {
      final json = <String, dynamic>{};

      final settings = AppSettings.fromJson(json);

      expect(
        settings.themeMode,
        ThemeMode.light,
      ); // Default es 1 (light) en fromJson
      expect(settings.fontSize, 1.0);
      expect(settings.userName, 'Architect');
      expect(settings.avatarIndex, 0);
    });

    test('storagePath should fallback to empty string when null', () {
      const settings = AppSettings(projectDirectory: null);
      expect(settings.storagePath, '');
    });

    test('storagePath should mirror projectDirectory when set', () {
      const settings = AppSettings(projectDirectory: '/tmp/projects');
      expect(settings.storagePath, '/tmp/projects');
    });
  });

  group('SettingsNotifier', () {
    late ProviderContainer container;

    setUp(() async {
      initMockSharedPreferences({});
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('should initialize with default AppSettings', () {
      final settings = container.read(settingsProvider);

      expect(settings.userName, 'Architect');
      expect(settings.themeMode, ThemeMode.dark);
      expect(settings.fontSize, 1.0);
    });

    test('updateUserName should update state and persist', () async {
      final notifier = container.read(settingsProvider.notifier);

      notifier.updateUserName('NewUser');

      final settings = container.read(settingsProvider);
      expect(settings.userName, 'NewUser');

      // Wait for persistence
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Verify persistence (check SharedPreferences)
      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString('app_settings_v2');
      expect(savedJson, isNotNull);
      expect(savedJson, contains('NewUser'));
    });

    test('updateAvatarIndex should update state', () {
      final notifier = container.read(settingsProvider.notifier);

      notifier.updateAvatarIndex(3);

      final settings = container.read(settingsProvider);
      expect(settings.avatarIndex, 3);
    });

    test('updateProjectDirectory should update state', () {
      final notifier = container.read(settingsProvider.notifier);

      notifier.updateProjectDirectory('/new/project/path');

      final settings = container.read(settingsProvider);
      expect(settings.projectDirectory, '/new/project/path');
    });

    test('updateCustomAvatarPath should update state and allow null', () async {
      final notifier = container.read(settingsProvider.notifier);

      await notifier.updateCustomAvatarPath('/tmp/avatar.png');
      expect(container.read(settingsProvider).customAvatarPath, '/tmp/avatar.png');

      await notifier.updateCustomAvatarPath(null);
      expect(container.read(settingsProvider).customAvatarPath, isNull);
    });

    test('updateStoragePath should update projectDirectory alias', () async {
      final notifier = container.read(settingsProvider.notifier);

      await notifier.updateStoragePath('/tmp/storage');

      final settings = container.read(settingsProvider);
      expect(settings.projectDirectory, '/tmp/storage');
      expect(settings.storagePath, '/tmp/storage');
    });

    test('updateTheme should update state', () {
      final notifier = container.read(settingsProvider.notifier);

      notifier.updateTheme(ThemeMode.light);

      final settings = container.read(settingsProvider);
      expect(settings.themeMode, ThemeMode.light);
    });

    test('updateFontSize should clamp values to valid range', () {
      final notifier = container.read(settingsProvider.notifier);

      // Test lower bound
      notifier.updateFontSize(0.5);
      expect(container.read(settingsProvider).fontSize, 0.8);

      // Test upper bound
      notifier.updateFontSize(2.0);
      expect(container.read(settingsProvider).fontSize, 1.4);

      // Test valid value
      notifier.updateFontSize(1.2);
      expect(container.read(settingsProvider).fontSize, 1.2);
    });

    test('updateGlobalZoom should clamp values to valid range', () {
      final notifier = container.read(settingsProvider.notifier);

      // Test lower bound
      notifier.updateGlobalZoom(0.3);
      expect(container.read(settingsProvider).globalZoom, 0.5);

      // Test upper bound
      notifier.updateGlobalZoom(3.0);
      expect(container.read(settingsProvider).globalZoom, 2.0);

      // Test valid value
      notifier.updateGlobalZoom(1.5);
      expect(container.read(settingsProvider).globalZoom, 1.5);
    });

    test('updateZoomShortcuts should toggle state', () {
      final notifier = container.read(settingsProvider.notifier);

      notifier.updateZoomShortcuts(enableZoomShortcuts: false);
      expect(container.read(settingsProvider).enableZoomShortcuts, false);

      notifier.updateZoomShortcuts(enableZoomShortcuts: true);
      expect(container.read(settingsProvider).enableZoomShortcuts, true);
    });

    test('updateAnimations should toggle state', () {
      final notifier = container.read(settingsProvider.notifier);

      notifier.updateAnimations(enableAnimations: false);
      expect(container.read(settingsProvider).enableAnimations, false);

      notifier.updateAnimations(enableAnimations: true);
      expect(container.read(settingsProvider).enableAnimations, true);
    });

    test('updateMemoryOptimization should toggle state', () {
      final notifier = container.read(settingsProvider.notifier);

      notifier.updateMemoryOptimization(enableMemoryOptimization: false);
      expect(container.read(settingsProvider).enableMemoryOptimization, false);

      notifier.updateMemoryOptimization(enableMemoryOptimization: true);
      expect(container.read(settingsProvider).enableMemoryOptimization, true);
    });

    /// NOTE: Persistence tests have been moved to a separate file
    /// (settings_persistence_test.dart) to avoid SharedPreferences mock conflicts.
    /// See that file for comprehensive persistence loading tests.
  });

  group('LastProjectNotifier', () {
      final notifier = container.read(settingsProvider.notifier);

      notifier.updateTheme(ThemeMode.light);
      notifier.updateFontSize(1.3);
      notifier.updateGlobalZoom(1.7);
      notifier.updateZoomShortcuts(enableZoomShortcuts: false);
      notifier.updateAnimations(enableAnimations: false);
      notifier.updateMemoryOptimization(enableMemoryOptimization: false);
      notifier.updateUserName('Granular');
      notifier.updateAvatarIndex(4);
      notifier.updateProjectDirectory('/tmp/granular');

      expect(container.read(themeModeProvider), ThemeMode.light);
      expect(container.read(fontSizeProvider), 1.3);
      expect(container.read(globalZoomProvider), 1.7);
      expect(container.read(enableZoomShortcutsProvider), false);
      expect(container.read(enableAnimationsProvider), false);
      expect(container.read(enableMemoryOptimizationProvider), false);
      expect(container.read(userNameProvider), 'Granular');
      expect(container.read(avatarIndexProvider), 4);
      expect(container.read(projectDirectoryProvider), '/tmp/granular');
    });
  });

  group('LastProjectNotifier', () {
    late ProviderContainer container;

    setUp(() {
      initMockSharedPreferences({'lastProject.path': '/initial/path'});
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('provider initializes without throwing', () {
      expect(() => container.read(lastProjectProvider), returnsNormally);
    });

    test('updateLastProject persists and updates state', () async {
      await container
          .read(lastProjectProvider.notifier)
          .updateLastProject('/updated/path');

      expect(container.read(lastProjectProvider), '/updated/path');
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('lastProject.path'), '/updated/path');
    });
  });
}
