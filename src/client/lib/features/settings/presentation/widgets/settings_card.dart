import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors_extension.dart';

/// Settings card widget - container for grouped settings.
///
/// Provides consistent styling for settings sections with title and icon.
class SettingsCard extends StatelessWidget {
  const SettingsCard({
    required this.title,
    required this.icon,
    required this.children,
    super.key,
  });

  final String title;
  final IconData icon;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final colors = context.appColors;
    return Container(
      decoration: BoxDecoration(
        color: colors.cardBg,
        border: Border.all(color: colors.cardBorder),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Card Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Icon(icon, size: 24, color: colors.accentBlue),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: colors.headingText,
                  ),
                ),
              ],
            ),
          ),
          Divider(color: colors.cardBorder, height: 1),
          // Card Content
          ...children,
        ],
      ),
    );
  }
}
