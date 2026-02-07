import 'package:flutter/material.dart';

/// ProjectCard - Displays a single project in the dashboard grid
/// Shows project icon, name, phase badge, path, and modification date
class ProjectCard extends StatelessWidget {
  const ProjectCard({
    required this.name,
    required this.icon,
    required this.iconColor,
    required this.phase,
    required this.phaseColor,
    required this.path,
    required this.modified,
    required this.onTap,
    super.key,
  });
  final String name;
  final IconData icon;
  final Color iconColor;
  final String phase;
  final Color phaseColor;
  final String path;
  final String modified;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF161B22),
          border: Border.all(color: const Color(0xFF30363d)),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Top section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon and phase badge
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: iconColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Icon(icon, color: iconColor, size: 24),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: phaseColor.withValues(alpha: 0.1),
                        border: Border.all(color: phaseColor.withValues(alpha: 0.3)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        phase,
                        style: TextStyle(
                          fontSize: 11,
                          fontFamily: 'Courier',
                          color: phaseColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Project name
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFFE6EDF3),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                // Project path
                Row(
                  children: [
                    const Icon(
                      Icons.folder,
                      size: 14,
                      color: Color(0xFF8b949e),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        path,
                        style: const TextStyle(
                          fontSize: 12,
                          fontFamily: 'Courier',
                          color: Color(0xFF8b949e),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Bottom section with metadata
            Container(
              padding: const EdgeInsets.only(top: 12),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: Color(0xFF30363d), width: 0.5),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Modificado: $modified',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF8b949e),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward,
                    size: 18,
                    color: Color(0xFF8b949e),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
