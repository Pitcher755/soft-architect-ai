// ignore_for_file: always_put_control_body_on_new_line, avoid_slow_async_io, avoid_catches_without_on_clauses, lines_longer_than_80_chars, cascade_invocations

import 'dart:convert'; // Para jsonEncode/jsonDecode

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// --- ESTADO (Inmutable) ---
class AppSettings {
  const AppSettings({
    this.themeMode = ThemeMode.dark,
    this.fontSize = 1.0,
    this.globalZoom = 1.0,
    this.enableZoomShortcuts = true,
    this.enableAnimations = true,
    this.enableMemoryOptimization = true,
    this.userName = 'Architect', // Valor por defecto
    this.avatarIndex = 0,
    this.customAvatarPath,
    this.projectDirectory,
  });

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
    themeMode: ThemeMode
        .values[json['themeMode'] ?? 1], // 1 es ThemeMode.dark usualmente
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
  final ThemeMode themeMode;
  final double fontSize;
  final double globalZoom;
  final bool enableZoomShortcuts;
  final bool enableAnimations;
  final bool enableMemoryOptimization;

  // NUEVOS CAMPOS DE PERFIL
  final String userName;
  final int avatarIndex;
  final String? customAvatarPath;
  final String? projectDirectory;

  AppSettings copyWith({
    ThemeMode? themeMode,
    double? fontSize,
    double? globalZoom,
    bool? enableZoomShortcuts,
    bool? enableAnimations,
    bool? enableMemoryOptimization,
    String? userName,
    int? avatarIndex,
    String? customAvatarPath,
    String? projectDirectory,
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
    customAvatarPath: customAvatarPath ?? this.customAvatarPath,
    projectDirectory: projectDirectory ?? this.projectDirectory,
  );

  // --- SERIALIZACIÓN PARA PERSISTENCIA ---

  Map<String, dynamic> toJson() => {
    'themeMode': themeMode.index, // Guardamos el índice del enum
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

// --- NOTIFIER (Lógica) ---
class SettingsNotifier extends Notifier<AppSettings> {
  static const String _storageKey = 'app_settings_v2';

  @override
  AppSettings build() {
    // 1. Iniciamos con valores por defecto
    // 2. Cargamos asíncronamente las preferencias guardadas
    _loadSettings();
    return const AppSettings();
  }

  // --- PERSISTENCIA ---

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final settingsJson = prefs.getString(_storageKey);
    if (settingsJson != null) {
      try {
        final Map<String, dynamic> decoded = jsonDecode(settingsJson);
        state = AppSettings.fromJson(decoded);
      } catch (e) {
        debugPrint('Error loading settings: $e');
      }
    }
  }

  Future<void> _saveSettings() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(state.toJson()));
  }

  // --- MÉTODOS DE ACTUALIZACIÓN ---

  void updateTheme(ThemeMode themeMode) {
    state = state.copyWith(themeMode: themeMode);
    _saveSettings();
  }

  void updateFontSize(double fontSize) {
    state = state.copyWith(fontSize: fontSize.clamp(0.8, 1.4));
    _saveSettings();
  }

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

  // --- MÉTODOS DE PERFIL ---

  void updateUserName(String name) {
    state = state.copyWith(userName: name);
    _saveSettings();
  }

  void updateAvatarIndex(int index) {
    state = state.copyWith(avatarIndex: index);
    _saveSettings();
  }

  void updateProjectDirectory(String path) {
    state = state.copyWith(projectDirectory: path);
    _saveSettings();
  }
}

// --- PROVIDER GLOBAL ---
final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
