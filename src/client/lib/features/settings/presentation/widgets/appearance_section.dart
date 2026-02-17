import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../gen/app_localizations.dart';
import '../providers/settings_providers.dart';
import 'setting_item.dart';
import 'settings_card.dart';

/// Appearance section widget - manages theme and font settings.
///
/// Allows users to configure visual preferences like theme mode and font size.
/// Theme switcher includes intuitive sun/moon icons for better UX.
class AppearanceSection extends ConsumerStatefulWidget {
  const AppearanceSection({super.key});

  @override
  ConsumerState<AppearanceSection> createState() => _AppearanceSectionState();
}

class _AppearanceSectionState extends ConsumerState<AppearanceSection> {
  late TextEditingController _fontSizeController;

  @override
  void initState() {
    super.initState();
    // Ensure baseFontSize is in valid range (10-24)
    final baseFontSize = ref.read(baseFontSizeProvider).clamp(10.0, 24.0);
    _fontSizeController = TextEditingController(
      text: baseFontSize.round().toString(),
    );

    // If loaded value was out of range, update it immediately
    final currentValue = ref.read(baseFontSizeProvider);
    if (currentValue < 10.0 || currentValue > 24.0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(settingsProvider.notifier).updateBaseFontSize(baseFontSize);
      });
    }
  }

  @override
  void dispose() {
    _fontSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeProvider);
    final rawBaseFontSize = ref.watch(baseFontSizeProvider);
    // Ensure value is always in valid range for Slider
    final baseFontSize = rawBaseFontSize.clamp(10.0, 24.0);
    final l10n = AppLocalizations.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return SettingsCard(
      title: l10n.appearanceTitle,
      icon: Icons.palette,
      children: [
        SettingItem(
          title: l10n.themeModeTitle,
          subtitle: l10n.themeModeSubtitle,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.light_mode,
                size: 20,
                color: themeMode == ThemeMode.light
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 8),
              Switch(
                value: themeMode == ThemeMode.dark,
                onChanged: (value) => ref
                    .read(settingsProvider.notifier)
                    .updateTheme(value ? ThemeMode.dark : ThemeMode.light),
                activeTrackColor: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.dark_mode,
                size: 20,
                color: themeMode == ThemeMode.dark
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
        Divider(color: colorScheme.outline),
        SettingItem(
          title: l10n.fontSizeTitle,
          subtitle: 'Ajusta el tamaño base del texto (10-24 pts)',
          child: Row(
            children: [
              SizedBox(
                width: 200,
                child: Slider(
                  value: baseFontSize,
                  min: 10,
                  max: 24,
                  divisions: 14,
                  label: '${baseFontSize.round()} pts',
                  onChanged: (value) {
                    ref
                        .read(settingsProvider.notifier)
                        .updateBaseFontSize(value);
                    _fontSizeController.text = value.round().toString();
                  },
                  activeColor: colorScheme.primary,
                  inactiveColor: colorScheme.outline,
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 70,
                child: TextField(
                  controller: _fontSizeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(fontSize: 14),
                  decoration: InputDecoration(
                    suffix: Text(
                      ' pts',
                      style: textTheme.bodySmall?.copyWith(fontSize: 12),
                    ),
                    filled: true,
                    fillColor: Theme.of(context).colorScheme.surface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: colorScheme.outline),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(
                        color: colorScheme.primary,
                        width: 2,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                  ),
                  onSubmitted: (value) {
                    final intValue = int.tryParse(value);
                    if (intValue != null && intValue >= 10 && intValue <= 24) {
                      ref
                          .read(settingsProvider.notifier)
                          .updateBaseFontSize(intValue.toDouble());
                    } else {
                      _fontSizeController.text = baseFontSize
                          .round()
                          .toString();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
