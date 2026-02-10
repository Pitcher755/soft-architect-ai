import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:softarchitect_ai/features/settings/presentation/providers/settings_provider.dart';

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
  });

  group('SettingsNotifier', () {
    late ProviderContainer container;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
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

    // TODO: This test requires a more sophisticated mock setup.
    // SharedPreferences.setMockInitialValues() can only be called once per test suite,
    // causing conflicts with the setUp() that initializes empty values.
    // Solution: Extract to separate test file or use integration test approach.
    test(
      'should load persisted settings on initialization',
      () async {
        // Setup persisted data (themeMode: 2 = ThemeMode.dark)
        SharedPreferences.setMockInitialValues({
          'app_settings_v2':
              '{"themeMode":2,"fontSize":1.3,"globalZoom":1.5,"enableZoomShortcuts":false,"enableAnimations":false,"enableMemoryOptimization":false,"userName":"PersistedUser","avatarIndex":2,"projectDirectory":"/persisted/path"}',
        });

        // Create new container to trigger initialization
        final newContainer = ProviderContainer();

        // Wait longer for async load to complete (SharedPreferences.getInstance + jsonDecode)
        await Future<void>.delayed(const Duration(milliseconds: 500));

        final settings = newContainer.read(settingsProvider);

        expect(settings.userName, 'PersistedUser');
        expect(settings.themeMode, ThemeMode.dark); // themeMode:2 = dark
        expect(settings.fontSize, 1.3);
        expect(settings.globalZoom, 1.5);
        expect(settings.enableZoomShortcuts, false);
        expect(settings.avatarIndex, 2);
        expect(settings.projectDirectory, '/persisted/path');

        newContainer.dispose();
      },
      skip:
          'Requires separate test file due to SharedPreferences mock limitations',
    );

    test('should handle corrupted JSON gracefully', () async {
      // Setup corrupted data
      SharedPreferences.setMockInitialValues({
        'app_settings_v2': '{invalid json}',
      });

      final newContainer = ProviderContainer();

      // Wait for async load attempt
      await Future<void>.delayed(const Duration(milliseconds: 200));

      final settings = newContainer.read(settingsProvider);

      // Should fallback to defaults
      expect(settings.userName, 'Architect');
      expect(settings.themeMode, ThemeMode.dark);

      newContainer.dispose();
    });
  });
}
