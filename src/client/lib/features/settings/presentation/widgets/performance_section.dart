import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_provider.dart';
import 'setting_item.dart';
import 'settings_card.dart';

/// Performance section widget - manages performance-related settings.
///
/// Allows users to toggle animations and memory optimization features.
class PerformanceSection extends ConsumerWidget {
  const PerformanceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return SettingsCard(
      title: 'Rendimiento',
      icon: Icons.speed,
      children: [
        SettingItem(
          title: 'Animaciones',
          subtitle: 'Habilita o deshabilita las animaciones de la UI',
          child: Switch(
            value: settings.enableAnimations,
            onChanged: (value) => ref
                .read(settingsProvider.notifier)
                .updateAnimations(enableAnimations: value),
            activeThumbColor: const Color(0xFF58A6FF),
          ),
        ),
        const Divider(color: Color(0xFF30363d)),
        SettingItem(
          title: 'Optimización de memoria',
          subtitle: 'Libera memoria automáticamente cuando sea necesario',
          child: Switch(
            value: settings.enableMemoryOptimization,
            onChanged: (value) => ref
                .read(settingsProvider.notifier)
                .updateMemoryOptimization(enableMemoryOptimization: value),
            activeThumbColor: const Color(0xFF58A6FF),
          ),
        ),
      ],
    );
  }
}
