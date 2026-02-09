import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) => Container(
    decoration: BoxDecoration(
      color: const Color(0xFF161B22),
      border: Border.all(color: const Color(0xFF30363d)),
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
              Icon(icon, size: 24, color: const Color(0xFF58A6FF)),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFE6EDF3),
                ),
              ),
            ],
          ),
        ),
        const Divider(color: Color(0xFF30363d), height: 1),
        // Card Content
        ...children,
      ],
    ),
  );
}
