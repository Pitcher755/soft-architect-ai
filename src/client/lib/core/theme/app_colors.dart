// lib/core/theme/app_colors.dart
import 'package:flutter/material.dart';

/// Centralized color palette for SoftArchitect AI
/// REDESIGNED: Modern Vibrant Dark Mode (Linear/SaaS Style)
/// Rich deep blue backgrounds with high-saturation neon accents
class AppColors {
  // Prevent instantiation
  AppColors._();

  // ==========================================================================
  // PRIMARY ACCENT COLORS (Vibrant Neon)
  // ==========================================================================

  /// Primary accent color - Electric Blue
  static const Color primary = Color(
    0xFF3B82F6,
  ); // Vibrant Blue (Tailwind Blue 500)
  static const Color primaryLight = Color(0xFF60A5FA); // Bright Blue
  static const Color primaryDark = Color(0xFF2563EB); // Deep intense blue

  // ==========================================================================
  // BACKGROUND COLORS (Midnight Blue / Deep Navy)
  // ==========================================================================

  /// Main scaffold background - Deepest Midnight Blue (No longer flat black)
  static const Color mainBg = Color(0xFF0B101E);

  /// Sidebar and card backgrounds - Slightly elevated navy
  static const Color surfaceBg = Color(0xFF111827);

  /// Secondary surface layer - Interactive elements
  static const Color surfaceLight = Color(0xFF1E293B);

  // ==========================================================================
  // BORDER & DIVIDER COLORS (Glassy / Subtle)
  // ==========================================================================

  /// Default border color - Subtle slate
  static const Color border = Color(0xFF334155);

  /// Light border variant - For active states
  static const Color borderLight = Color(0xFF475569);

  // ==========================================================================
  // TEXT COLORS (High Contrast OLED style)
  // ==========================================================================

  /// Primary text color - Bright crisp white
  static const Color textMain = Color(0xFFF8FAFC);

  /// Secondary text color - Cool slate gray
  static const Color textSecondary = Color(0xFF94A3B8);

  /// Muted text color - Darker cool gray
  static const Color textMuted = Color(0xFF64748B);

  // ==========================================================================
  // PROJECT PHASE COLORS (Ultra Vibrant)
  // ==========================================================================

  /// Fase 1: Contexto - Neon Yellow/Amber
  static const Color phase1Context = Color(0xFFFBBF24);

  /// Fase 2: Requisitos - Emerald Green
  static const Color phase2Requirements = Color(0xFF34D399);

  /// Fase 3: Arquitectura - Cyan/Electric Blue
  static const Color phase3Architecture = Color(0xFF2DD4BF);

  // ==========================================================================
  // DIRECTORY PHASE COLORS
  // ==========================================================================

  /// 00-ROOT: Root directory color - Achievement Gold (100% completion)
  static const Color dirRoot = Color(0xFF84CC16); // Gold

  /// 10-CONTEXT: Context phase directory
  static const Color dirContext = phase1Context;

  /// 20-REQUIREMENTS: Requirements phase directory
  static const Color dirRequirements = phase2Requirements;

  /// 30-ARCHITECTURE: Architecture phase directory
  static const Color dirArchitecture = primaryLight;

  /// 35-UI_UX: UI/UX design phase directory - Hot Pink
  static const Color dirUiUx = Color(0xFFF472B6);

  /// 40-PLANNING: Planning phase directory - Bright Purple
  static const Color dirPlanning = Color(0xFFA78BFA);

  /// 99-META: Metadata/Meta directory - Neon Orange
  static const Color dirMeta = Color(0xFFFB923C);

  // ==========================================================================
  // ICON COLORS (High Saturation)
  // ==========================================================================

  static const Color iconBlue = Color(0xFF3B82F6);
  static const Color iconPurple = Color(0xFF8B5CF6);
  static const Color iconOrange = Color(0xFFF97316);
  static const Color iconPink = Color(0xFFEC4899);
  static const Color iconViolet = Color(0xFF7C3AED);
  static const Color iconCyan = Color(0xFF06B6D4);
  static const Color iconAmber = Color(0xFFF59E0B);
  static const Color iconGreen = Color(0xFF10B981);
  static const Color iconMagenta = Color(0xFFD946EF);
  static const Color iconOrangeRed = Color(0xFFEF4444);

  // ==========================================================================
  // SEMANTIC COLORS
  // ==========================================================================

  /// Success/Approved - Vibrant Emerald
  static const Color success = Color(0xFF10B981);
  static const Color successAlt = Color(0xFF34D399);

  /// Warning - Bright Amber
  static const Color warning = Color(0xFFF59E0B);

  /// Error/Rejected - Neon Red
  static const Color error = Color(0xFFEF4444);
  static const Color errorAlt = Color(0xFFF87171);

  /// Info
  static const Color info = primary;

  // ==========================================================================
  // LANGUAGE-SPECIFIC COLORS (Brightened)
  // ==========================================================================

  static const Color dartBlue = Color(0xFF38BDF8);
  static const Color pythonBlue = Color(0xFF60A5FA);
  static const Color jsYellow = Color(0xFFFDE047);

  // ==========================================================================
  // SYNTAX HIGHLIGHTING COLORS (VS Code "One Dark Pro" style)
  // ==========================================================================

  static const Map<String, Color> syntaxColors = {
    'keyword': Color(0xFFC678DD), // Soft Purple
    'function': Color(0xFF61AFEF), // Light Blue
    'argument': Color(0xFFE5C07B), // Soft Yellow
    'string': Color(0xFF98C379), // Soft Green
    'comment': Color(0xFF5C6370), // Italics Gray
    'operator': Color(0xFF56B6C2), // Cyan
    'number': Color(0xFFD19A66), // Dark Yellow
  };
}
/*
🏆 Dorado (actual)	0xFFFFD700	Premio, logro, victoria
✅ Verde Éxito	0xFF10B981	Completado, aprobado
💎 Cyan Brillante	0xFF06B6D4	Premium, tech, diamante
🌟 Verde Lima Neón	0xFF84CC16	Energía, brillante
🔆 Amarillo Neón	0xFFFBBF24	Igual que fase context
🔥 Rojo Coral	0xFFFF6B6B	Energético, vibrante
 */
