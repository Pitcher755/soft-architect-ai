// ignore_for_file: always_put_control_body_on_new_line, avoid_slow_async_io, avoid_catches_without_on_clauses, lines_longer_than_80_chars, cascade_invocations

import 'dart:convert';
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================================
// STATE MODEL (Immutable)
// ============================================================================

/// Application settings state (immutable).
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.dark,
    this.fontSize = 1.0,
    this.globalZoom = 1.0,
    this.enableZoomShortcuts = true,
    this.enableAnimations = true,
    this.enableMemoryOptimization = true,
    this.userName = 'Architect',
    this.avatarIndex = 0,
    this.customAvatarPath,
    this.projectDirectory,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    themeMode: ThemeMode.values[json['themeMode'] ?? 1], // 1 = ThemeMode.dark
    fontSize: json['fontSize'] ?? 1.0,
    globalZoom: json['globalZoom'] ?? 1.0,
    enableZoomShortcuts: json['enableZoomShortcuts'] ?? true,
    enableAnimations: json['enableAnimations'] ?? true,
    enableMemoryOptimization: json['enableMemoryOptimization'] ?? true,
    userName: json['userName'] ?? 'Architect',
    avatarIndex: json['avatarIndex'] ?? 0,
    customAvatarPath: json['customAvatarPath'],
    projectDirectory: json['projectDirectory'],
  );
  static const Object _unset = Object();

  final ThemeMode themeMode;
  final double fontSize;
  final double globalZoom;
  final bool enableZoomShortcuts;
  final bool enableAnimations;
  final bool enableMemoryOptimization;
  final String userName;
  final int avatarIndex;
  final String? customAvatarPath;
  final String? projectDirectory;

  /// Alias for projectDirectory (backward compatibility).
  String get storagePath => projectDirectory ?? '';

  AppSettings copyWith({
    ThemeMode? themeMode,
    double? fontSize,
    double? globalZoom,
    bool? enableZoomShortcuts,
    bool? enableAnimations,
    bool? enableMemoryOptimization,
    String? userName,
    int? avatarIndex,
    Object? customAvatarPath = _unset,
    Object? projectDirectory = _unset,
  }) => AppSettings(
    themeMode: themeMode ?? this.themeMode,
    fontSize: fontSize ?? this.fontSize,
    globalZoom: globalZoom ?? this.globalZoom,
    enableZoomShortcuts: enableZoomShortcuts ?? this.enableZoomShortcuts,
    enableAnimations: enableAnimations ?? this.enableAnimations,
    enableMemoryOptimization:
        enableMemoryOptimization ?? this.enableMemoryOptimization,
    userName: userName ?? this.userName,
    avatarIndex: avatarIndex ?? this.avatarIndex,
    customAvatarPath: identical(customAvatarPath, _unset)
        ? this.customAvatarPath
        : customAvatarPath as String?,
    projectDirectory: identical(projectDirectory, _unset)
        ? this.projectDirectory
        : projectDirectory as String?,
  );

  Map<String, dynamic> toJson() => {
    'themeMode': themeMode.index,
    'fontSize': fontSize,
    'globalZoom': globalZoom,
    'enableZoomShortcuts': enableZoomShortcuts,
    'enableAnimations': enableAnimations,
    'enableMemoryOptimization': enableMemoryOptimization,
    'userName': userName,
    'avatarIndex': avatarIndex,
    'customAvatarPath': customAvatarPath,
    'projectDirectory': projectDirectory,
  };
}

// ============================================================================
// SETTINGS NOTIFIER
// ============================================================================

/// Internal notifier for managing settings state.
///
/// CRITICAL: Do NOT watch this directly at app root.
/// Use granular providers instead to avoid app-wide rebuilds.
///
/// REFACTORED: Now uses AsyncNotifier to properly load persisted settings
/// before returning initial state (fixes async/sync race condition).
class SettingsNotifier extends AsyncNotifier<AppSettings> {
  static const String _storageKey = 'app_settings_v2';

  @override
  Future<AppSettings> build() async {
    // Load persisted settings synchronously during initialization
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_storageKey);

    if (settingsJson != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(settingsJson);
        return AppSettings.fromJson(decoded);
      } catch (e) {
        developer.log('Error loading settings: $e', name: 'SettingsNotifier');
        return const AppSettings(); // Return defaults on error
      }
    }

    return const AppSettings(); // Return defaults if no saved settings
  }

  Future<void> updateTheme(ThemeMode themeMode) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(themeMode: themeMode));
    await _saveSettings();
  }

  Future<void> updateFontSize(double fontSize) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(fontSize: fontSize.clamp(0.8, 1.4)),
    );
    await _saveSettings();
  }

  /// CRITICAL: Does NOT trigger app-level rebuilds.
  Future<void> updateGlobalZoom(double globalZoom) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(globalZoom: globalZoom.clamp(0.5, 2.0)),
    );
    await _saveSettings();
  }

  /// Increase zoom by 10% (max 200%).
  Future<void> increaseZoom() async {
    final currentState = state.value;
    if (currentState == null) return;

    final newZoom = (currentState.globalZoom + 0.1).clamp(0.5, 2.0);
    await updateGlobalZoom(newZoom);
  }

  /// Decrease zoom by 10% (min 50%).
  Future<void> decreaseZoom() async {
    final currentState = state.value;
    if (currentState == null) return;

    final newZoom = (currentState.globalZoom - 0.1).clamp(0.5, 2.0);
    await updateGlobalZoom(newZoom);
  }

  /// Reset zoom to 100%.
  Future<void> resetZoom() async {
    await updateGlobalZoom(1);
  }

  Future<void> updateZoomShortcuts({required bool enableZoomShortcuts}) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(enableZoomShortcuts: enableZoomShortcuts),
    );
    await _saveSettings();
  }

  Future<void> updateAnimations({required bool enableAnimations}) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(enableAnimations: enableAnimations),
    );
    await _saveSettings();
  }

  Future<void> updateMemoryOptimization({
    required bool enableMemoryOptimization,
  }) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(
      currentState.copyWith(enableMemoryOptimization: enableMemoryOptimization),
    );
    await _saveSettings();
  }

  Future<void> updateUserName(String name) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(userName: name));
    await _saveSettings();
  }

  Future<void> updateAvatarIndex(int index) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(avatarIndex: index));
    await _saveSettings();
  }

  Future<void> updateCustomAvatarPath(String? path) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(customAvatarPath: path));
    await _saveSettings();
  }

  Future<void> updateProjectDirectory(String path) async {
    final currentState = state.value;
    if (currentState == null) return;

    state = AsyncValue.data(currentState.copyWith(projectDirectory: path));
    await _saveSettings();
  }

  Future<void> updateStoragePath(String path) async {
    await updateProjectDirectory(path);
  }

  Future<void> _saveSettings() async {
    final currentState = state.value;
    if (currentState == null) return;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(currentState.toJson()));
  }
}

// ============================================================================
// INTERNAL PROVIDER (USE GRANULAR PROVIDERS INSTEAD)
// ============================================================================

final settingsProvider = AsyncNotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

// ============================================================================
// GRANULAR PROVIDERS (USE THESE AT APP ROOT & WIDGETS)
// ============================================================================

final themeModeProvider = Provider<ThemeMode>(
  (ref) => ref.watch(
    settingsProvider.select((s) => s.value?.themeMode ?? ThemeMode.dark),
  ),
);

final fontSizeProvider = Provider<double>(
  (ref) => ref.watch(settingsProvider.select((s) => s.value?.fontSize ?? 1.0)),
);

final globalZoomProvider = Provider<double>(
  (ref) =>
      ref.watch(settingsProvider.select((s) => s.value?.globalZoom ?? 1.0)),
);

final enableZoomShortcutsProvider = Provider<bool>(
  (ref) => ref.watch(
    settingsProvider.select((s) => s.value?.enableZoomShortcuts ?? true),
  ),
);

final enableAnimationsProvider = Provider<bool>(
  (ref) => ref.watch(
    settingsProvider.select((s) => s.value?.enableAnimations ?? true),
  ),
);

final enableMemoryOptimizationProvider = Provider<bool>(
  (ref) => ref.watch(
    settingsProvider.select((s) => s.value?.enableMemoryOptimization ?? true),
  ),
);

final userNameProvider = Provider<String>(
  (ref) => ref.watch(
    settingsProvider.select((s) => s.value?.userName ?? 'Architect'),
  ),
);

final avatarIndexProvider = Provider<int>(
  (ref) => ref.watch(settingsProvider.select((s) => s.value?.avatarIndex ?? 0)),
);

final customAvatarPathProvider = Provider<String?>(
  (ref) => ref.watch(settingsProvider.select((s) => s.value?.customAvatarPath)),
);

final projectDirectoryProvider = Provider<String?>(
  (ref) => ref.watch(settingsProvider.select((s) => s.value?.projectDirectory)),
);

// ============================================================================
// LAST PROJECT PROVIDER
// ============================================================================

class LastProjectNotifier extends Notifier<String?> {
  @override
  String? build() {
    _loadInitialPath();
    return null;
  }

  Future<void> _loadInitialPath() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final path = prefs.getString('lastProject.path');
      if (!ref.mounted) {
        return;
      }
      state = path;
    } on Exception {
      if (!ref.mounted) {
        return;
      }
      state = null;
    }
  }

  Future<void> updateLastProject(String path) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('lastProject.path', path);
      state = path;
    } on Exception catch (e) {
      developer.log(
        'Failed to update last project path: $e',
        name: 'LastProjectNotifier',
      );
      rethrow;
    }
  }
}

final lastProjectProvider = NotifierProvider<LastProjectNotifier, String?>(
  LastProjectNotifier.new,
);
