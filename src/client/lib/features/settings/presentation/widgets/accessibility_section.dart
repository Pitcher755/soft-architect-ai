import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_provider.dart';
import 'setting_item.dart';
import 'settings_card.dart';

/// Accessibility section widget - manages zoom and accessibility features.
///
/// Allows users to configure global zoom and keyboard shortcuts.
class AccessibilitySection extends ConsumerWidget {
  const AccessibilitySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return SettingsCard(
      title: 'Accesibilidad',
      icon: Icons.accessibility,
      children: [
        SettingItem(
          title: 'Zoom global',
          subtitle: 'Ajusta el zoom de toda la aplicación',
          child: SizedBox(
            width: 200,
            child: Slider(
              value: settings.globalZoom,
              min: 0.5,
              max: 2,
              divisions: 15,
              onChanged: (value) =>
                  ref.read(settingsProvider.notifier).updateGlobalZoom(value),
              activeColor: const Color(0xFF58A6FF),
              inactiveColor: const Color(0xFF30363d),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
          child: Text(
            '${(settings.globalZoom * 100).round()}%',
            style: const TextStyle(fontSize: 12, color: Color(0xFF8b949e)),
          ),
        ),
        const Divider(color: Color(0xFF30363d)),
        SettingItem(
          title: 'Atajos de teclado para zoom',
          subtitle: 'Ctrl + / Ctrl - para zoom, Ctrl + 0 para reset',
          child: Switch(
            value: settings.enableZoomShortcuts,
            onChanged: (value) => ref
                .read(settingsProvider.notifier)
                .updateZoomShortcuts(enableZoomShortcuts: value),
            activeColor: const Color(0xFF58A6FF),
          ),
        ),
      ],
    );
  }
}
