import 'package:flutter/material.dart';

import 'app_colors.dart' show AppColors;

/// Adaptive color palette as a [ThemeExtension].
///
/// Provides light/dark variants for every color that must change with the
/// active [ThemeMode]. Non-adaptive colors (phase accents, icon tints,
/// semantic status colors) remain in [AppColors] as static constants.
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  const AppColorsExtension({
    // Backgrounds
    required this.mainBg,
    required this.surfaceBg,
    required this.surfaceLight,
    required this.cardBg,
    required this.codeBg,
    required this.actionBg,
    // Borders
    required this.border,
    required this.borderLight,
    required this.cardBorder,
    // Text
    required this.textMain,
    required this.textSecondary,
    required this.textMuted,
    required this.headingText,
    required this.codeText,
    // Adaptive accents
    required this.accentBlue,
    required this.successBg,
    required this.dangerBg,
  });

  // ---------------------------------------------------------------------------
  // Backgrounds
  // ---------------------------------------------------------------------------
  final Color mainBg;
  final Color surfaceBg;
  final Color surfaceLight;
  final Color cardBg;
  final Color codeBg;
  final Color actionBg;

  // ---------------------------------------------------------------------------
  // Borders
  // ---------------------------------------------------------------------------
  final Color border;
  final Color borderLight;
  final Color cardBorder;

  // ---------------------------------------------------------------------------
  // Text
  // ---------------------------------------------------------------------------
  final Color textMain;
  final Color textSecondary;
  final Color textMuted;
  final Color headingText;
  final Color codeText;

  // ---------------------------------------------------------------------------
  // Adaptive accents
  // ---------------------------------------------------------------------------
  final Color accentBlue;
  final Color successBg;
  final Color dangerBg;

  // ===========================================================================
  // Preset instances
  // ===========================================================================

  static const dark = AppColorsExtension(
    mainBg: Color(0xFF0B101E),
    surfaceBg: Color(0xFF111827),
    surfaceLight: Color(0xFF1E293B),
    cardBg: Color(0xFF161B22),
    codeBg: Color(0xFF0D1117),
    actionBg: Color(0xFF21262D),
    border: Color(0xFF334155),
    borderLight: Color(0xFF475569),
    cardBorder: Color(0xFF30363D),
    textMain: Color(0xFFF8FAFC),
    textSecondary: Color(0xFF94A3B8),
    textMuted: Color(0xFF64748B),
    headingText: Color(0xFFE6EDF3),
    codeText: Color(0xFFC9D1D9),
    accentBlue: Color(0xFF58A6FF),
    successBg: Color(0xFF238636),
    dangerBg: Color(0xFFDA3633),
  );

  static const light = AppColorsExtension(
    mainBg: Color(0xFFF8FAFC),
    surfaceBg: Color(0xFFFFFFFF),
    surfaceLight: Color(0xFFF1F5F9),
    cardBg: Color(0xFFFFFFFF),
    codeBg: Color(0xFFF6F8FA),
    actionBg: Color(0xFFF6F8FA),
    border: Color(0xFFCBD5E1),
    borderLight: Color(0xFFE2E8F0),
    cardBorder: Color(0xFFD0D7DE),
    textMain: Color(0xFF0F172A),
    textSecondary: Color(0xFF64748B),
    textMuted: Color(0xFF94A3B8),
    headingText: Color(0xFF0F172A),
    codeText: Color(0xFF24292F),
    accentBlue: Color(0xFF0969DA),
    successBg: Color(0xFF1A7F37),
    dangerBg: Color(0xFFCF222E),
  );

  // ===========================================================================
  // ThemeExtension overrides
  // ===========================================================================

  @override
  AppColorsExtension copyWith({
    Color? mainBg,
    Color? surfaceBg,
    Color? surfaceLight,
    Color? cardBg,
    Color? codeBg,
    Color? actionBg,
    Color? border,
    Color? borderLight,
    Color? cardBorder,
    Color? textMain,
    Color? textSecondary,
    Color? textMuted,
    Color? headingText,
    Color? codeText,
    Color? accentBlue,
    Color? successBg,
    Color? dangerBg,
  }) => AppColorsExtension(
    mainBg: mainBg ?? this.mainBg,
    surfaceBg: surfaceBg ?? this.surfaceBg,
    surfaceLight: surfaceLight ?? this.surfaceLight,
    cardBg: cardBg ?? this.cardBg,
    codeBg: codeBg ?? this.codeBg,
    actionBg: actionBg ?? this.actionBg,
    border: border ?? this.border,
    borderLight: borderLight ?? this.borderLight,
    cardBorder: cardBorder ?? this.cardBorder,
    textMain: textMain ?? this.textMain,
    textSecondary: textSecondary ?? this.textSecondary,
    textMuted: textMuted ?? this.textMuted,
    headingText: headingText ?? this.headingText,
    codeText: codeText ?? this.codeText,
    accentBlue: accentBlue ?? this.accentBlue,
    successBg: successBg ?? this.successBg,
    dangerBg: dangerBg ?? this.dangerBg,
  );

  @override
  AppColorsExtension lerp(AppColorsExtension? other, double t) {
    if (other is! AppColorsExtension) {
      return this;
    }
    return AppColorsExtension(
      mainBg: Color.lerp(mainBg, other.mainBg, t)!,
      surfaceBg: Color.lerp(surfaceBg, other.surfaceBg, t)!,
      surfaceLight: Color.lerp(surfaceLight, other.surfaceLight, t)!,
      cardBg: Color.lerp(cardBg, other.cardBg, t)!,
      codeBg: Color.lerp(codeBg, other.codeBg, t)!,
      actionBg: Color.lerp(actionBg, other.actionBg, t)!,
      border: Color.lerp(border, other.border, t)!,
      borderLight: Color.lerp(borderLight, other.borderLight, t)!,
      cardBorder: Color.lerp(cardBorder, other.cardBorder, t)!,
      textMain: Color.lerp(textMain, other.textMain, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textMuted: Color.lerp(textMuted, other.textMuted, t)!,
      headingText: Color.lerp(headingText, other.headingText, t)!,
      codeText: Color.lerp(codeText, other.codeText, t)!,
      accentBlue: Color.lerp(accentBlue, other.accentBlue, t)!,
      successBg: Color.lerp(successBg, other.successBg, t)!,
      dangerBg: Color.lerp(dangerBg, other.dangerBg, t)!,
    );
  }
}

/// Convenience accessor so widgets can write `context.appColors.xxx`.
extension AppColorsContext on BuildContext {
  AppColorsExtension get appColors =>
      Theme.of(this).extension<AppColorsExtension>() ?? AppColorsExtension.dark;
}
