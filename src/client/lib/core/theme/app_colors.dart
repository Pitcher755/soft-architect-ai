// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

/// Centralized color palette for SoftArchitect AI
/// Based on GitHub Dark theme with custom accent colors
/// All colors are used with withValues(alpha: x) for opacity effects
class AppColors {
  // Prevent instantiation
  AppColors._();

  // ==========================================================================
  // PRIMARY ACCENT COLORS
  // ==========================================================================

  /// Primary accent color - Used for buttons, active states, borders
  /// Used in: Buttons, selected states, primary borders, active sidebar items
  static const Color primary = Color(0xFF58A6FF); // Bright blue accent
  static const Color primaryLight = Color(0xFF79C0FF); // Lighter blue
  static const Color primaryDark = Color(0xFF1F6FEB); // Darker blue

  // ==========================================================================
  // BACKGROUND COLORS
  // ==========================================================================

  /// Main scaffold background
  /// Used in: Scaffold, primary background
  static const Color mainBg = Color(0xFF0D1117); // Deep black

  /// Sidebar and card backgrounds
  /// Used in: Sidebar, ProjectCard, ProjectListView containers, dialogs
  static const Color surfaceBg = Color(0xFF161B22); // Dark gray

  /// Secondary surface layer
  /// Used in: Nested containers, elevated surfaces
  static const Color surfaceLight = Color(0xFF21262D); // Lighter surface

  // ==========================================================================
  // BORDER & DIVIDER COLORS
  // ==========================================================================

  /// Default border color
  /// Used in: Card borders, dividers, subtle borders
  static const Color border = Color(0xFF30363D); // Neutral border

  /// Light border variant
  /// Used in: Subtle separators, low-contrast borders
  static const Color borderLight = Color(0xFF6E7681); // Light gray

  // ==========================================================================
  // TEXT COLORS
  // ==========================================================================

  /// Primary text color (off-white)
  /// Used in: Headings, main content text, card titles
  static const Color textMain = Color(0xFFE6EDF3); // Main text

  /// Secondary text color (gray)
  /// Used in: Subtitles, metadata, secondary information, hints
  static const Color textSecondary = Color(0xFF8B949E); // Secondary text

  /// Muted text color (darker gray)
  /// Used in: Disabled states, less important info
  static const Color textMuted = Color(0xFF6E7681); // Muted text

  // ==========================================================================
  // PROJECT PHASE COLORS
  // ==========================================================================
  // These represent different stages of a project lifecycle
  // Used in: Phase badges, cards, list items
  // Apply with: withValues(alpha: 0.1) for backgrounds, alpha: 0.4 for borders

  /// Fase 1: Contexto - Initial context phase
  /// Used in: Phase badge, phase color accent
  /// Opacity: 0.1 (background), 0.4 (border), 0.6 (icon accent)
  static const Color phase1Context = Color(0xFFFCD34D); // Yellow

  /// Fase 2: Requisitos - Requirements phase
  /// Used in: Phase badge, phase color accent
  /// Opacity: 0.1 (background), 0.4 (border), 0.6 (icon accent)
  static const Color phase2Requirements = Color(0xFF10B981); // Green

  /// Fase 3: Arquitectura - Architecture phase
  /// Used in: Phase badge, phase color accent
  /// Opacity: 0.1 (background), 0.4 (border), 0.6 (icon accent)
  static const Color phase3Architecture = Color(0xFF60A5FA); // Blue

  // ==========================================================================
  // DIRECTORY PHASE COLORS (por fase de proyecto)
  // ==========================================================================
  // Colores para directorios que representan diferentes fases del proyecto
  // Usado en: Iconos de árbol de directorios, badges de fase
  // Cantidad de archivos: 00-ROOT(4), 10-CONTEXT(3), 20-REQUIREMENTS(4),
  // 30-ARCHITECTURE(6), 35-UI_UX(3), 40-PLANNING(4), 99-META(1)
  // Total: 25 archivos

  /// 00-ROOT: Root directory color (4 files)
  /// Used in: Directory icon, folder accent
  static const Color dirRoot = Color(0xFF94E2D5); // Teal/Cyan

  /// 10-CONTEXT: Context phase directory (3 files)
  /// Used in: Directory icon, folder accent (same as phase1Context)
  static const Color dirContext = Color(0xFFFCD34D); // Yellow

  /// 20-REQUIREMENTS: Requirements phase directory (4 files)
  /// Used in: Directory icon, folder accent (same as phase2Requirements)
  static const Color dirRequirements = Color(0xFF10B981); // Green

  /// 30-ARCHITECTURE: Architecture phase directory (6 files)
  /// Used in: Directory icon, folder accent (same as phase3Architecture)
  static const Color dirArchitecture = Color(0xFF60A5FA); // Blue

  /// 35-UI_UX: UI/UX design phase directory (3 files)
  /// Used in: Directory icon, folder accent
  static const Color dirUiUx = Color(0xFFEC4899); // Pink

  /// 40-PLANNING: Planning phase directory (4 files)
  /// Used in: Directory icon, folder accent
  static const Color dirPlanning = Color(0xFFA855F7); // Purple

  /// 99-META: Metadata/Meta directory (1 file)
  /// Used in: Directory icon, folder accent
  static const Color dirMeta = Color(0xFFFB923C); // Orange

  // ==========================================================================
  // ICON COLORS
  // ==========================================================================
  // Project-specific icon colors from mock data
  // Applied with: withValues(alpha: 0.1) for container backgrounds

  /// Blue icon color
  /// Used in: E-Commerce Platform icon
  static const Color iconBlue = Color(0xFF3B82F6);

  /// Purple icon color
  /// Used in: Uber for Dogs icon
  static const Color iconPurple = Color(0xFFA855F7);

  /// Orange icon color
  /// Used in: FinTech Core API, Music Streaming icons
  static const Color iconOrange = Color(0xFFFB923C);

  /// Pink/Magenta icon color
  /// Used in: Healthcare Mobile App, Marketing Automation icons
  static const Color iconPink = Color(0xFFEC4899);

  /// Purple/Violet icon color
  /// Used in: Analytics Dashboard icon
  static const Color iconViolet = Color(0xFF8B5CF6);

  /// Cyan icon color
  /// Used in: Social Network Platform icon
  static const Color iconCyan = Color(0xFF06B6D4);

  /// Amber icon color
  /// Used in: Music Streaming Service icon
  static const Color iconAmber = Color(0xFFF59E0B);

  /// Green icon color
  /// Used in: IoT Device Manager icon
  static const Color iconGreen = Color(0xFF10B981);

  /// Magenta icon color
  /// Used in: Marketing Automation icon
  static const Color iconMagenta = Color(0xFFD946EF);

  /// Orange-red icon color
  /// Used in: Security Audit System icon
  static const Color iconOrangeRed = Color(0xFFF97316);

  // ==========================================================================
  // SEMANTIC COLORS
  // ==========================================================================

  /// Success/Approved color
  /// Used in: Positive actions, success states
  static const Color success = Color(0xFF238636); // Green
  static const Color successAlt = Color(0xFF3FB950); // Lighter green

  /// Warning color
  /// Used in: Warning states, caution messages
  static const Color warning = Color(0xFFD29922); // Amber

  /// Error/Rejected color
  /// Used in: Error states, rejection, negative actions
  static const Color error = Color(0xFFDA3633); // Red
  static const Color errorAlt = Color(0xFFF85149); // Lighter red

  /// Info color
  /// Used in: Information, hints, tooltips
  static const Color info = Color(0xFF58A6FF); // Primary blue (accent)

  // ==========================================================================
  // LANGUAGE-SPECIFIC COLORS
  // ==========================================================================

  static const Color dartBlue = Color(0xFF00D2FC);
  static const Color pythonBlue = Color(0xFF3776AB);
  static const Color jsYellow = Color(0xFFF7DF1E);

  // ==========================================================================
  // SYNTAX HIGHLIGHTING COLORS
  // ==========================================================================

  static const Map<String, Color> syntaxColors = {
    'keyword': Color(0xFFFF7B72), // Red/Pink
    'function': Color(0xFFD2A8FF), // Purple
    'argument': Color(0xFFFFA657), // Orange
    'string': Color(0xFFA5D6FF), // Light Blue
    'comment': Color(0xFF8B949E), // Gray
    'operator': Color(0xFFFF7B72), // Red
    'number': Color(0xFF79C0FF), // Blue
  };

  // ==========================================================================
  // OPACITY REFERENCE GUIDE
  // ==========================================================================
  // Use with: color.withValues(alpha: x)
  //
  // 0.1  → Very subtle backgrounds (icon containers, phase badges)
  //        Example: iconColor.withValues(alpha: 0.1)
  //
  // 0.2  → Light backgrounds, hover states
  //        Example: primary.withValues(alpha: 0.2) for logo container
  //
  // 0.3  → Medium borders, disabled states
  //        Example: border.withValues(alpha: 0.3) for light borders
  //
  // 0.4  → Phase borders, medium contrast
  //        Example: phaseColor.withValues(alpha: 0.4) for phase card borders
  //
  // 0.6  → Icon accents, semi-transparent elements
  //        Example: phaseColor.withValues(alpha: 0.6) for arrow icons
  //
  // 1.0  → Fully opaque (default, no alpha needed)
}
