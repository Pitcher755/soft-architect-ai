import 'package:flutter/material.dart';

/// Setting item widget - individual setting row with title, subtitle, and control.
///
/// Used within SettingsCard to display consistent setting items.
class SettingItem extends StatelessWidget {
  const SettingItem({
    required this.title,
    required this.subtitle,
    required this.child,
    super.key,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFFE6EDF3),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8b949e),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            child,
          ],
        ),
      );
}
