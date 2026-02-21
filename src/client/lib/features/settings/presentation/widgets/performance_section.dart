import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/settings_providers.dart';
import 'setting_item.dart';
import 'settings_card.dart';

/// Performance section widget - manages performance-related settings.
///
/// Allows users to toggle animations and memory optimization features.
class PerformanceSection extends ConsumerWidget {
  const PerformanceSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enableAnimations = ref.watch(enableAnimationsProvider);
    final enableMemoryOptimization = ref.watch(
      enableMemoryOptimizationProvider,
    );
    final colorScheme = Theme.of(context).colorScheme;

    return SettingsCard(
      title: 'Rendimiento',
      icon: Icons.speed,
      children: [
        SettingItem(
          title: 'Animaciones',
          subtitle: 'Habilita o deshabilita las animaciones de la UI',
          child: Switch(
            value: enableAnimations,
            onChanged: (value) => ref
                .read(settingsProvider.notifier)
                .updateAnimations(enableAnimations: value),
            activeTrackColor: colorScheme.primary,
          ),
        ),
        Divider(color: colorScheme.outline),
        SettingItem(
          title: 'Optimización de memoria',
          subtitle: 'Libera memoria automáticamente cuando sea necesario',
          child: Switch(
            value: enableMemoryOptimization,
            onChanged: (value) => ref
                .read(settingsProvider.notifier)
                .updateMemoryOptimization(enableMemoryOptimization: value),
            activeTrackColor: colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
