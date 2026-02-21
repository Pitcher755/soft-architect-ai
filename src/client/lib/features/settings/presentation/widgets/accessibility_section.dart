import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../gen/app_localizations.dart';
import '../providers/settings_providers.dart';
import 'setting_item.dart';
import 'settings_card.dart';

/// Accessibility section widget - manages zoom and accessibility features.
///
/// Allows users to configure global zoom and keyboard shortcuts.
class AccessibilitySection extends ConsumerWidget {
  const AccessibilitySection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final globalZoom = ref.watch(globalZoomProvider);
    final enableZoomShortcuts = ref.watch(enableZoomShortcutsProvider);
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SettingsCard(
      title: l10n.accessibilityTitle,
      icon: Icons.accessibility,
      children: [
        SettingItem(
          title: l10n.zoomTitle,
          subtitle: l10n.zoomSubtitle,
          child: SizedBox(
            width: 200,
            child: Slider(
              value: globalZoom,
              min: 0.5,
              max: 2,
              divisions: 15,
              onChanged: (value) =>
                  ref.read(settingsProvider.notifier).updateGlobalZoom(value),
              activeColor: colorScheme.primary,
              inactiveColor: colorScheme.outline,
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
          child: Text(
            '${(globalZoom * 100).round()}%',
            style: textTheme.bodySmall?.copyWith(fontSize: 12),
          ),
        ),
        Divider(color: colorScheme.outline),
        SettingItem(
          title: l10n.enableZoomShortcuts,
          subtitle: 'Ctrl + / Ctrl - para zoom, Ctrl + 0 para reset',
          child: Switch(
            value: enableZoomShortcuts,
            onChanged: (value) => ref
                .read(settingsProvider.notifier)
                .updateZoomShortcuts(enableZoomShortcuts: value),
            activeTrackColor: colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
