import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_provider.dart';
import 'setting_item.dart';
import 'settings_card.dart';

/// Appearance section widget - manages theme and font settings.
///
/// Allows users to configure visual preferences like theme mode and font size.
class AppearanceSection extends ConsumerWidget {
  const AppearanceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return SettingsCard(
      title: 'Apariencia',
      icon: Icons.palette,
      children: [
        SettingItem(
          title: 'Tema',
          subtitle: 'Cambia entre tema claro y oscuro',
          child: Switch(
            value: settings.themeMode == ThemeMode.dark,
            onChanged: (value) => ref
                .read(settingsProvider.notifier)
                .updateTheme(value ? ThemeMode.dark : ThemeMode.light),
            activeColor: const Color(0xFF58A6FF),
          ),
        ),
        const Divider(color: Color(0xFF30363d)),
        SettingItem(
          title: 'Tamaño de fuente',
          subtitle: 'Ajusta el tamaño del texto en la aplicación',
          child: SizedBox(
            width: 200,
            child: Slider(
              value: settings.fontSize,
              min: 0.8,
              max: 1.4,
              divisions: 6,
              onChanged: (value) =>
                  ref.read(settingsProvider.notifier).updateFontSize(value),
              activeColor: const Color(0xFF58A6FF),
              inactiveColor: const Color(0xFF30363d),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
          child: Text(
            '${(settings.fontSize * 100).round()}%',
            style: const TextStyle(fontSize: 12, color: Color(0xFF8b949e)),
          ),
        ),
      ],
    );
  }
}
