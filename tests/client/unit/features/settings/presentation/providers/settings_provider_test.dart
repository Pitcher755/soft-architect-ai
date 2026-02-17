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
      expect(settings.baseFontSize, 14.0);
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
        baseFontSize: 18.0,
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
      expect(settings.baseFontSize, 18.0);
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
      expect(updated.baseFontSize, 14.0);
    });

    test('toJson should serialize correctly', () {
      const settings = AppSettings(
        themeMode: ThemeMode.light,
        baseFontSize: 16.0,
        userName: 'TestUser',
        projectDirectory: '/test/path',
      );

      final json = settings.toJson();

      expect(json['themeMode'], 1); // ThemeMode.light index
      expect(json['baseFontSize'], 16.0);
      expect(json['userName'], 'TestUser');
      expect(json['projectDirectory'], '/test/path');
    });

    test('fromJson should deserialize correctly with baseFontSize', () {
      final json = {
        'themeMode': 1, // ThemeMode.light
        'baseFontSize': 18.0,
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
      expect(settings.baseFontSize, 18.0);
      expect(settings.globalZoom, 1.8);
      expect(settings.enableZoomShortcuts, false);
      expect(settings.enableAnimations, false);
      expect(settings.enableMemoryOptimization, false);
      expect(settings.userName, 'JsonUser');
      expect(settings.avatarIndex, 4);
      expect(settings.customAvatarPath, '/json/avatar.png');
      expect(settings.projectDirectory, '/json/projects');
    });

    // ========================================================================
    // MIGRATION TESTS: Old fontSize (multiplier) → baseFontSize (points)
    // ========================================================================

    test('fromJson should migrate old fontSize multiplier 0.8 to 11.2 pts', () {
      final json = {'fontSize': 0.8};
      final settings = AppSettings.fromJson(json);
      expect(settings.baseFontSize, closeTo(11.2, 0.1));
    });

    test('fromJson should migrate old fontSize multiplier 1.0 to 14.0 pts', () {
      final json = {'fontSize': 1.0};
      final settings = AppSettings.fromJson(json);
      expect(settings.baseFontSize, 14.0);
    });

    test('fromJson should migrate old fontSize multiplier 1.1 to 15.4 pts', () {
      final json = {'fontSize': 1.1};
      final settings = AppSettings.fromJson(json);
      expect(settings.baseFontSize, closeTo(15.4, 0.1));
    });

    test('fromJson should migrate old fontSize multiplier 1.4 to 19.6 pts', () {
      final json = {'fontSize': 1.4};
      final settings = AppSettings.fromJson(json);
      expect(settings.baseFontSize, closeTo(19.6, 0.1));
    });

    test('fromJson should clamp migrated values below 10 to 10 pts', () {
      final json = {'fontSize': 0.5}; // 0.5 * 14 = 7.0 → clamped to 10
      final settings = AppSettings.fromJson(json);
      expect(settings.baseFontSize, 10.0);
    });

    test('fromJson should clamp migrated values above 24 to 24 pts', () {
      final json = {'fontSize': 2.0}; // 2.0 * 14 = 28.0 → clamped to 24
      final settings = AppSettings.fromJson(json);
      expect(settings.baseFontSize, 24.0);
    });

    test('fromJson should NOT migrate values >= 10 (already in points)', () {
      final json = {'baseFontSize': 16.0};
      final settings = AppSettings.fromJson(json);
      expect(settings.baseFontSize, 16.0); // No conversion applied
    });

    test('fromJson should prefer baseFontSize over fontSize', () {
      final json = {
        'baseFontSize': 20.0,
        'fontSize': 1.2, // Should be ignored
      };
      final settings = AppSettings.fromJson(json);
      expect(settings.baseFontSize, 20.0);
    });

    // ========================================================================
    // END MIGRATION TESTS
    // ========================================================================

    test('fromJson should handle missing fields with defaults', () {
      final json = <String, dynamic>{};

      final settings = AppSettings.fromJson(json);

      expect(
        settings.themeMode,
        ThemeMode.light,
      ); // Default es 1 (light) en fromJson
      expect(settings.baseFontSize, 14.0);
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

    test('should initialize with default AppSettings', () async {
      await container.read(settingsProvider.future);
      final settings = container.read(settingsProvider).requireValue;

      expect(settings.userName, 'Architect');
      expect(settings.themeMode, ThemeMode.dark);
      expect(settings.baseFontSize, 14.0);
    });

    test('updateUserName should update state and persist', () async {
      await container.read(settingsProvider.future);
      final notifier = container.read(settingsProvider.notifier);

      await notifier.updateUserName('NewUser');

      final settings = container.read(settingsProvider).requireValue;
      expect(settings.userName, 'NewUser');

      // Wait for persistence
      await Future<void>.delayed(const Duration(milliseconds: 100));

      // Verify persistence (check SharedPreferences)
      final prefs = await SharedPreferences.getInstance();
      final savedJson = prefs.getString('app_settings_v2');
      expect(savedJson, isNotNull);
      expect(savedJson, contains('NewUser'));
    });

    test('updateAvatarIndex should update state', () async {
      await container.read(settingsProvider.future);
      final notifier = container.read(settingsProvider.notifier);

      await notifier.updateAvatarIndex(3);

      final settings = container.read(settingsProvider).requireValue;
      expect(settings.avatarIndex, 3);
    });

    test('updateProjectDirectory should update state', () async {
      await container.read(settingsProvider.future);
      final notifier = container.read(settingsProvider.notifier);

      await notifier.updateProjectDirectory('/new/project/path');

      final settings = container.read(settingsProvider).requireValue;
      expect(settings.projectDirectory, '/new/project/path');
    });

    test('updateCustomAvatarPath should update state and allow null', () async {
      await container.read(settingsProvider.future);
      final notifier = container.read(settingsProvider.notifier);

      await notifier.updateCustomAvatarPath('/tmp/avatar.png');
      expect(
        container.read(settingsProvider).requireValue.customAvatarPath,
        '/tmp/avatar.png',
      );

      await notifier.updateCustomAvatarPath(null);
      expect(
        container.read(settingsProvider).requireValue.customAvatarPath,
        isNull,
      );
    });

    test('updateStoragePath should update projectDirectory alias', () async {
      await container.read(settingsProvider.future);
      final notifier = container.read(settingsProvider.notifier);

      await notifier.updateStoragePath('/tmp/storage');

      final settings = container.read(settingsProvider).requireValue;
      expect(settings.projectDirectory, '/tmp/storage');
      expect(settings.storagePath, '/tmp/storage');
    });

    test('updateTheme should update state', () async {
      await container.read(settingsProvider.future);
      final notifier = container.read(settingsProvider.notifier);

      await notifier.updateTheme(ThemeMode.light);

      final settings = container.read(settingsProvider).requireValue;
      expect(settings.themeMode, ThemeMode.light);
    });

    test('updateBaseFontSize should clamp values to valid range (10-24 pts)', () async {
      await container.read(settingsProvider.future);
      final notifier = container.read(settingsProvider.notifier);

      // Test lower bound
      await notifier.updateBaseFontSize(5.0);
      expect(container.read(settingsProvider).requireValue.baseFontSize, 10.0);

      // Test upper bound
      await notifier.updateBaseFontSize(30.0);
      expect(container.read(settingsProvider).requireValue.baseFontSize, 24.0);

      // Test valid value
      await notifier.updateBaseFontSize(16.0);
      expect(container.read(settingsProvider).requireValue.baseFontSize, 16.0);
    });

    test('updateGlobalZoom should clamp values to valid range', () async {
      await container.read(settingsProvider.future);
      final notifier = container.read(settingsProvider.notifier);

      // Test lower bound
      await notifier.updateGlobalZoom(0.3);
      expect(container.read(settingsProvider).requireValue.globalZoom, 0.5);

      // Test upper bound
      await notifier.updateGlobalZoom(3.0);
      expect(container.read(settingsProvider).requireValue.globalZoom, 2.0);

      // Test valid value
      await notifier.updateGlobalZoom(1.5);
      expect(container.read(settingsProvider).requireValue.globalZoom, 1.5);
    });

    test('updateZoomShortcuts should toggle state', () async {
      await container.read(settingsProvider.future);
      final notifier = container.read(settingsProvider.notifier);

      await notifier.updateZoomShortcuts(enableZoomShortcuts: false);
      expect(
        container.read(settingsProvider).requireValue.enableZoomShortcuts,
        false,
      );

      await notifier.updateZoomShortcuts(enableZoomShortcuts: true);
      expect(
        container.read(settingsProvider).requireValue.enableZoomShortcuts,
        true,
      );
    });

    test('updateAnimations should toggle state', () async {
      await container.read(settingsProvider.future);
      final notifier = container.read(settingsProvider.notifier);

      await notifier.updateAnimations(enableAnimations: false);
      expect(
        container.read(settingsProvider).requireValue.enableAnimations,
        false,
      );

      await notifier.updateAnimations(enableAnimations: true);
      expect(
        container.read(settingsProvider).requireValue.enableAnimations,
        true,
      );
    });

    test('updateMemoryOptimization should toggle state', () async {
      await container.read(settingsProvider.future);
      final notifier = container.read(settingsProvider.notifier);

      await notifier.updateMemoryOptimization(enableMemoryOptimization: false);
      expect(
        container.read(settingsProvider).requireValue.enableMemoryOptimization,
        false,
      );

      await notifier.updateMemoryOptimization(enableMemoryOptimization: true);
      expect(
        container.read(settingsProvider).requireValue.enableMemoryOptimization,
        true,
      );
    });

    test('granular providers should reflect settingsProvider state', () async {
      await container.read(settingsProvider.future);
      final notifier = container.read(settingsProvider.notifier);

      await notifier.updateTheme(ThemeMode.light);
      await notifier.updateBaseFontSize(16.0);
      await notifier.updateGlobalZoom(1.7);
      await notifier.updateZoomShortcuts(enableZoomShortcuts: false);
      await notifier.updateAnimations(enableAnimations: false);
      await notifier.updateMemoryOptimization(enableMemoryOptimization: false);
      await notifier.updateUserName('Granular');
      await notifier.updateAvatarIndex(4);
      await notifier.updateProjectDirectory('/tmp/granular');

      expect(container.read(themeModeProvider), ThemeMode.light);
      expect(container.read(baseFontSizeProvider), 16.0);
      expect(container.read(globalZoomProvider), 1.7);
      expect(container.read(enableZoomShortcutsProvider), false);
      expect(container.read(enableAnimationsProvider), false);
      expect(container.read(enableMemoryOptimizationProvider), false);
      expect(container.read(userNameProvider), 'Granular');
      expect(container.read(avatarIndexProvider), 4);
      expect(container.read(projectDirectoryProvider), '/tmp/granular');
    });

    /// NOTE: Persistence tests have been moved to a separate file
    /// (settings_persistence_test.dart) to avoid SharedPreferences mock conflicts.
    /// See that file for comprehensive persistence loading tests.
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
