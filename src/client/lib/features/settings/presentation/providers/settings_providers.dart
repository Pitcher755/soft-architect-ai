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
class SettingsNotifier extends Notifier<AppSettings> {
  static const String _storageKey = 'app_settings_v2';

  @override
  AppSettings build() {
    _loadSettings();
    return const AppSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_storageKey);
    if (settingsJson != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(settingsJson);
        state = AppSettings.fromJson(decoded);
      } catch (e) {
        developer.log('Error loading settings: $e', name: 'SettingsNotifier');
      }
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(state.toJson()));
  }

  void updateTheme(ThemeMode themeMode) {
    state = state.copyWith(themeMode: themeMode);
    _saveSettings();
  }

  void updateFontSize(double fontSize) {
    state = state.copyWith(fontSize: fontSize.clamp(0.8, 1.4));
    _saveSettings();
  }

  /// CRITICAL: Does NOT trigger app-level rebuilds.
  void updateGlobalZoom(double globalZoom) {
    state = state.copyWith(globalZoom: globalZoom.clamp(0.5, 2.0));
    _saveSettings();
  }

  void updateZoomShortcuts({required bool enableZoomShortcuts}) {
    state = state.copyWith(enableZoomShortcuts: enableZoomShortcuts);
    _saveSettings();
  }

  void updateAnimations({required bool enableAnimations}) {
    state = state.copyWith(enableAnimations: enableAnimations);
    _saveSettings();
  }

  void updateMemoryOptimization({required bool enableMemoryOptimization}) {
    state = state.copyWith(enableMemoryOptimization: enableMemoryOptimization);
    _saveSettings();
  }

  void updateUserName(String name) {
    state = state.copyWith(userName: name);
    _saveSettings();
  }

  void updateAvatarIndex(int index) {
    state = state.copyWith(avatarIndex: index);
    _saveSettings();
  }

  Future<void> updateCustomAvatarPath(String? path) async {
    state = state.copyWith(customAvatarPath: path);
    await _saveSettings();
  }

  void updateProjectDirectory(String path) {
    state = state.copyWith(projectDirectory: path);
    _saveSettings();
  }

  Future<void> updateStoragePath(String path) async {
    updateProjectDirectory(path);
    await _saveSettings();
  }
}

// ============================================================================
// INTERNAL PROVIDER (USE GRANULAR PROVIDERS INSTEAD)
// ============================================================================

final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);

// ============================================================================
// GRANULAR PROVIDERS (USE THESE AT APP ROOT & WIDGETS)
// ============================================================================

final themeModeProvider = Provider<ThemeMode>(
  (ref) => ref.watch(settingsProvider.select((s) => s.themeMode)),
);

final fontSizeProvider = Provider<double>(
  (ref) => ref.watch(settingsProvider.select((s) => s.fontSize)),
);

final globalZoomProvider = Provider<double>(
  (ref) => ref.watch(settingsProvider.select((s) => s.globalZoom)),
);

final enableZoomShortcutsProvider = Provider<bool>(
  (ref) => ref.watch(settingsProvider.select((s) => s.enableZoomShortcuts)),
);

final enableAnimationsProvider = Provider<bool>(
  (ref) => ref.watch(settingsProvider.select((s) => s.enableAnimations)),
);

final enableMemoryOptimizationProvider = Provider<bool>(
  (ref) =>
      ref.watch(settingsProvider.select((s) => s.enableMemoryOptimization)),
);

final userNameProvider = Provider<String>(
  (ref) => ref.watch(settingsProvider.select((s) => s.userName)),
);

final avatarIndexProvider = Provider<int>(
  (ref) => ref.watch(settingsProvider.select((s) => s.avatarIndex)),
);

final customAvatarPathProvider = Provider<String?>(
  (ref) => ref.watch(settingsProvider.select((s) => s.customAvatarPath)),
);

final projectDirectoryProvider = Provider<String?>(
  (ref) => ref.watch(settingsProvider.select((s) => s.projectDirectory)),
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
