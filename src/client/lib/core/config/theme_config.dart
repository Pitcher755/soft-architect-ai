import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_colors_extension.dart';

/// Central theme configuration for the application.
/// Inspired by Modern SaaS (Linear, Vercel, OpenAI) Vibrant Dark Mode.
class AppTheme {
  // Base Colors (Backgrounds) - Now mapped directly to the new AppColors
  static const Color bgPrimary = AppColors.mainBg;
  static const Color bgSecondary = AppColors.surfaceBg;
  static const Color bgTertiary = AppColors.surfaceLight;
  static const Color bgElevation = AppColors.border;

  // Accent Colors
  static const Color primary = AppColors.primary;
  static const Color secondary = AppColors.success;
  static const Color accent = AppColors.iconViolet;
  static const Color error = AppColors.errorAlt;
  static const Color warning = AppColors.warning;

  // Typography
  static const Color textPrimary = AppColors.textMain;
  static const Color textSecondary = AppColors.textSecondary;
  static const Color textCode = Color(0xFFE2E8F0);

  /// Dark Theme (Default & Locked for MVP)
  static ThemeData darkTheme() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bgPrimary,
    extensions: const <ThemeExtension>[AppColorsExtension.dark],

    // Smooth, deep app bar
    appBarTheme: const AppBarTheme(
      backgroundColor: bgSecondary,
      elevation: 0,
      centerTitle: true,
      scrolledUnderElevation: 0, // Prevents scroll tinting issues
    ),

    // Vibrant Color Scheme - Complete with all attributes
    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: secondary,
      tertiary: accent,
      error: error,
      surface: bgSecondary,
      surfaceContainerHighest: bgTertiary,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
      outline: bgElevation,
      outlineVariant: Color(0xFF475569),
      onPrimary: Colors.white,
      onSecondary: Colors.white,
      onError: Colors.white,
    ),

    // Modern "Glassy" Inputs
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: bgTertiary.withValues(alpha: 0.5), // Semi-transparent fill
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(
          12,
        ), // Slightly rounder, more modern
        borderSide: const BorderSide(color: bgElevation),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: bgElevation),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(
          color: primary.withValues(alpha: 0.5), // Glow effect border
          width: 2,
        ),
      ),
      hintStyle: const TextStyle(color: textSecondary),
    ),

    // High Contrast Typography
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: textPrimary,
        fontWeight: FontWeight.bold,
        letterSpacing: -1,
      ),
      displayMedium: TextStyle(
        color: textPrimary,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      displaySmall: TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
      headlineLarge: TextStyle(
        color: textPrimary,
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        color: textPrimary,
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
      titleLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
      titleMedium: TextStyle(color: textPrimary, fontWeight: FontWeight.w500),
      titleSmall: TextStyle(color: textSecondary, fontWeight: FontWeight.w500),
      bodyLarge: TextStyle(color: textPrimary),
      bodyMedium: TextStyle(color: textPrimary),
      bodySmall: TextStyle(color: textSecondary),
      labelLarge: TextStyle(color: textPrimary, fontWeight: FontWeight.w600),
      labelMedium: TextStyle(color: textSecondary, fontWeight: FontWeight.w500),
      labelSmall: TextStyle(color: textSecondary),
    ),

    // Modern UI Elements
    cardTheme: CardThemeData(
      color: bgSecondary,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: bgElevation),
      ),
    ),
    iconTheme: const IconThemeData(color: textSecondary),
    dividerColor: bgElevation,

    // Vibrant Switches
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return const Color(0xFF94A3B8);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return primary;
        }
        return bgElevation;
      }),
    ),
  );

  /// Light Theme with full adaptive color support.
  static ThemeData lightTheme() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF8FAFC),
    extensions: const <ThemeExtension>[AppColorsExtension.light],
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFFFFFF),
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: Color(0xFF0F172A)),
    ),
    colorScheme: const ColorScheme.light(
      primary: Color(0xFF2563EB), // Tailwind Blue 600
      secondary: Color(0xFF10B981), // Tailwind Emerald 500
      tertiary: Color(0xFF8B5CF6), // Tailwind Violet 500
      error: Color(0xFFEF4444), // Tailwind Red 500
      surfaceContainerHighest: Color(0xFFF1F5F9),
      onSurface: Color(0xFF0F172A),
      onSurfaceVariant: Color(0xFF64748B),
      outline: Color(0xFFCBD5E1),
      outlineVariant: Color(0xFFE2E8F0),
      onSecondary: Colors.white,
    ),
    // Complete light mode text theme
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: Color(0xFF0F172A),
        fontWeight: FontWeight.bold,
        letterSpacing: -1,
      ),
      displayMedium: TextStyle(
        color: Color(0xFF0F172A),
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      displaySmall: TextStyle(
        color: Color(0xFF0F172A),
        fontWeight: FontWeight.bold,
      ),
      headlineLarge: TextStyle(
        color: Color(0xFF0F172A),
        fontWeight: FontWeight.bold,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        color: Color(0xFF0F172A),
        fontWeight: FontWeight.bold,
      ),
      headlineSmall: TextStyle(
        color: Color(0xFF0F172A),
        fontWeight: FontWeight.w600,
      ),
      titleLarge: TextStyle(
        color: Color(0xFF0F172A),
        fontWeight: FontWeight.w600,
      ),
      titleMedium: TextStyle(
        color: Color(0xFF1E293B),
        fontWeight: FontWeight.w500,
      ),
      titleSmall: TextStyle(
        color: Color(0xFF64748B),
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: TextStyle(color: Color(0xFF0F172A)),
      bodyMedium: TextStyle(color: Color(0xFF1E293B)),
      bodySmall: TextStyle(color: Color(0xFF64748B)),
      labelLarge: TextStyle(
        color: Color(0xFF0F172A),
        fontWeight: FontWeight.w600,
      ),
      labelMedium: TextStyle(
        color: Color(0xFF64748B),
        fontWeight: FontWeight.w500,
      ),
      labelSmall: TextStyle(color: Color(0xFF64748B)),
    ),
  );
}
