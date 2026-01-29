import 'package:flutter/material.dart';

/// Central theme configuration for the application.
/// Inspired by VS Code, Linear, and GitHub Dark Mode.
class AppTheme {
  // Base Colors (Backgrounds)
  static const Color bgPrimary = Color(0xFF0D1117);
  // Almost black, bluish
  static const Color bgSecondary = Color(0xFF161B22);
  // Sidebars, panels
  static const Color bgTertiary = Color(0xFF21262D);
  // Input fields, borders
  static const Color bgElevation = Color(0xFF30363D);

  // Accent Colors
  static const Color primary = Color(0xFF58A6FF);        // Tech Blue
  static const Color secondary = Color(0xFF238636);      // Git Green
  static const Color accent = Color(0xFFA371F7);         // Purple (AI)
  static const Color error = Color(0xFFF85149);          // Red
  static const Color warning = Color(0xFFD29922);        // Yellow

  // Typography
  static const Color textPrimary = Color(0xFFC9D1D9);    // High contrast
  static const Color textSecondary = Color(0xFF8B949E);  // Softer
  static const Color textCode = Color(0xFFE1E4E8);       // Code blocks

  /// Dark Theme (Default)
  static ThemeData darkTheme() => ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: bgPrimary,
      appBarTheme: const AppBarTheme(
        backgroundColor: bgSecondary,
        elevation: 0,
        centerTitle: true,
      ),
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        tertiary: accent,
        error: error,
        surface: bgSecondary,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: bgTertiary,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: bgElevation),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: bgElevation),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      ),
      textTheme: const TextTheme(
        displayLarge:
            TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        displayMedium:
            TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        displaySmall:
            TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        headlineLarge:
            TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        headlineMedium:
            TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        headlineSmall:
            TextStyle(color: textPrimary, fontWeight: FontWeight.bold),
        titleLarge: TextStyle(color: textPrimary),
        titleMedium: TextStyle(color: textPrimary),
        titleSmall: TextStyle(color: textSecondary),
        bodyLarge: TextStyle(color: textPrimary),
        bodyMedium: TextStyle(color: textPrimary),
        bodySmall: TextStyle(color: textSecondary),
        labelLarge: TextStyle(color: textPrimary),
        labelMedium: TextStyle(color: textSecondary),
        labelSmall: TextStyle(color: textSecondary),
      ),
    );

  /// Light Theme (Secondary)
  static ThemeData lightTheme() => ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFF6F8FA),
        elevation: 0,
        centerTitle: true,
      ),
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: secondary,
        tertiary: accent,
        error: error,
        surface: Color(0xFFF6F8FA),
      ),
    );
}
