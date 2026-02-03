// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

/// Centralized color palette for SoftArchitect AI
/// Based on GitHub Dark theme with custom primary accent
class AppColors {
  // Prevent instantiation
  AppColors._();
  // Primary accent color
  static const Color primary = Color(0xFF0d0df2); // Indigo blue
  static const Color primaryLight = Color(0xFF1f6feb); // Lighter blue
  static const Color primaryDark = Color(0xFF0a0cc0); // Darker blue

  // Background colors
  static const Color mainBg = Color(0xFF0D1117); // Deep black
  static const Color sidebarBg = Color(0xFF161B22); // Dark gray
  static const Color surfaceBg = Color(0xFF21262d); // Surface layer

  // Border and divider
  static const Color border = Color(0xFF30363d); // Border color
  static const Color borderLight =
      Color(0x7F30363d); // Light border (with opacity)

  // Text colors
  static const Color textMain = Color(0xFFE6EDF3); // Main text (off-white)
  static const Color textSecondary = Color(0xFF8b949e); // Secondary text (gray)
  static const Color textMuted = Color(0xFF6e7681); // Muted text

  // Semantic colors
  static const Color success = Color(0xFF3fb950); // Green
  static const Color warning = Color(0xFFd29922); // Yellow
  static const Color error = Color(0xfff85149); // Red
  static const Color info = Color(0xFF58a6ff); // Blue

  // Language-specific colors
  static const Color dartBlue = Color(0xFF00D2FC);
  static const Color pythonBlue = Color(0xFF3776AB);
  static const Color jsYellow = Color(0xFFF7DF1E);

  // Syntax highlighting colors
  static const Map<String, Color> syntaxColors = {
    'keyword': Color(0xFFff7b72), // Red/Pink
    'function': Color(0xFFd2a8ff), // Purple
    'argument': Color(0xFFffa657), // Orange
    'string': Color(0xFFa5d6ff), // Light Blue
    'comment': Color(0xFF8b949e), // Gray
    'operator': Color(0xFFff7b72), // Red
    'number': Color(0xFF79c0ff), // Blue
  };
}
