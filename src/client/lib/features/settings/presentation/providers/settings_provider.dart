import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// --- ESTADO (Inmutable) ---
class AppSettings {
  final ThemeMode themeMode;
  final double fontSize;
  final double globalZoom;
  final bool enableZoomShortcuts;
  final bool enableAnimations;
  final bool enableMemoryOptimization;

  const AppSettings({
    this.themeMode = ThemeMode.dark,
    this.fontSize = 1.0,
    this.globalZoom = 1.0,
    this.enableZoomShortcuts = true,
    this.enableAnimations = true,
    this.enableMemoryOptimization = true,
  });

  AppSettings copyWith({
    ThemeMode? themeMode,
    double? fontSize,
    double? globalZoom,
    bool? enableZoomShortcuts,
    bool? enableAnimations,
    bool? enableMemoryOptimization,
  }) => AppSettings(
        themeMode: themeMode ?? this.themeMode,
        fontSize: fontSize ?? this.fontSize,
        globalZoom: globalZoom ?? this.globalZoom,
        enableZoomShortcuts: enableZoomShortcuts ?? this.enableZoomShortcuts,
        enableAnimations: enableAnimations ?? this.enableAnimations,
        enableMemoryOptimization:
            enableMemoryOptimization ?? this.enableMemoryOptimization,
      );
}

// --- NOTIFIER (Lógica) ---
class SettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() => const AppSettings();

  void updateTheme(ThemeMode themeMode) =>
      state = state.copyWith(themeMode: themeMode);

  void updateFontSize(double fontSize) =>
      state = state.copyWith(fontSize: fontSize.clamp(0.8, 1.4));

  void updateGlobalZoom(double globalZoom) =>
      state = state.copyWith(globalZoom: globalZoom.clamp(0.5, 2.0));

  void updateZoomShortcuts({required bool enableZoomShortcuts}) =>
      state = state.copyWith(enableZoomShortcuts: enableZoomShortcuts);

  void updateAnimations({required bool enableAnimations}) =>
      state = state.copyWith(enableAnimations: enableAnimations);

  void updateMemoryOptimization({required bool enableMemoryOptimization}) =>
      state = state.copyWith(enableMemoryOptimization: enableMemoryOptimization);
}

// --- PROVIDER GLOBAL ---
final settingsProvider = NotifierProvider<SettingsNotifier, AppSettings>(
  SettingsNotifier.new,
);
