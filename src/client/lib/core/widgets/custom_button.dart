/// Reusable button widgets for consistent UI across the application.
///
/// Provides a unified button style that can be used throughout the app,
/// ensuring consistency and reducing code duplication.
///
/// Author: ArchitectZero
/// Created: 2026-02-10
library;

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_colors_extension.dart';

/// Common elevated button with standard styling.
///
/// Provides consistent button appearance throughout the application.
/// Automatically handles localization when label is a localization key.
///
/// {@tool snippet}
/// ```dart
/// CustomButton(
///   label: l10n.createProject,
///   onPressed: () => _showCreateDialog(),
/// )
/// ```
/// {@end-tool}
class CustomButton extends StatelessWidget {
  /// Create a custom button.
  const CustomButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    super.key,
  });

  /// Button label text (already localized).
  final String label;

  /// Callback when button is pressed.
  final VoidCallback onPressed;

  /// Optional icon to display left of label.
  final IconData? icon;

  /// Whether button should show loading indicator.
  final bool isLoading;

  @override
  Widget build(BuildContext context) => ElevatedButton.icon(
    onPressed: isLoading ? null : onPressed,
    icon: isLoading
        ? SizedBox.square(
            dimension: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).brightness == Brightness.dark
                    ? context.appColors.textMain
                    : Colors.white,
              ),
            ),
          )
        : Icon(icon ?? Icons.check),
    label: Text(label),
    style: ElevatedButton.styleFrom(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  );
}

/// Outlined button with secondary styling.
///
/// Uses outline style for secondary actions that are less important
/// than primary actions.
///
/// {@tool snippet}
/// ```dart
/// SecondaryButton(
///   label: l10n.cancel,
///   onPressed: () => Navigator.pop(context),
/// )
/// ```
/// {@end-tool}
class SecondaryButton extends StatelessWidget {
  /// Create a secondary button.
  const SecondaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  /// Button label text.
  final String label;

  /// Callback when button is pressed.
  final VoidCallback onPressed;

  /// Optional icon to display.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return OutlinedButton.icon(
      onPressed: onPressed,
      icon: Icon(icon ?? Icons.close),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: c.textSecondary,
        side: BorderSide(color: c.border),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

/// Compact icon button for toolbar/header use.
///
/// Provides a minimal button representation ideal for header and toolbar
/// contexts where space is limited.
///
/// {@tool snippet}
/// ```dart
/// CompactIconButton(
///   icon: Icons.settings,
///   onPressed: () => _openSettings(),
///   tooltip: 'Settings',
/// )
/// ```
/// {@end-tool}
class CompactIconButton extends StatelessWidget {
  /// Create a compact icon button.
  const CompactIconButton({
    required this.icon,
    required this.onPressed,
    this.tooltip,
    super.key,
  });

  /// Icon to display.
  final IconData icon;

  /// Callback when button is pressed.
  final VoidCallback onPressed;

  /// Tooltip text displayed on hover.
  final String? tooltip;

  @override
  Widget build(BuildContext context) => Tooltip(
    message: tooltip ?? '',
    child: IconButton(icon: Icon(icon), onPressed: onPressed, splashRadius: 24),
  );
}
