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
    final settings = ref.read(settingsProvider);
    _fontSizeController = TextEditingController(
      text: (settings.fontSize * 100).round().toString(),
    );
  }

  @override
  void dispose() {
    _fontSizeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final l10n = AppLocalizations.of(context);

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
                color: settings.themeMode == ThemeMode.light
                    ? const Color(0xFF58A6FF)
                    : const Color(0xFF8b949e),
              ),
              const SizedBox(width: 8),
              Switch(
                value: settings.themeMode == ThemeMode.dark,
                onChanged: (value) => ref
                    .read(settingsProvider.notifier)
                    .updateTheme(value ? ThemeMode.dark : ThemeMode.light),
                activeThumbColor: const Color(0xFF58A6FF),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.dark_mode,
                size: 20,
                color: settings.themeMode == ThemeMode.dark
                    ? const Color(0xFF58A6FF)
                    : const Color(0xFF8b949e),
              ),
            ],
          ),
        ),
        const Divider(color: Color(0xFF30363d)),
        SettingItem(
          title: l10n.fontSizeTitle,
          subtitle: l10n.fontSizeSubtitle,
          child: Row(
            children: [
              SizedBox(
                width: 200,
                child: Slider(
                  value: settings.fontSize,
                  min: 0.8,
                  max: 1.4,
                  divisions: 6,
                  onChanged: (value) {
                    ref.read(settingsProvider.notifier).updateFontSize(value);
                    _fontSizeController.text = (value * 100).round().toString();
                  },
                  activeColor: const Color(0xFF58A6FF),
                  inactiveColor: const Color(0xFF30363d),
                ),
              ),
              const SizedBox(width: 12),
              SizedBox(
                width: 60,
                child: TextField(
                  controller: _fontSizeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFE6EDF3),
                    fontSize: 14,
                  ),
                  decoration: InputDecoration(
                    suffix: const Text(
                      '%',
                      style: TextStyle(color: Color(0xFF8b949e), fontSize: 12),
                    ),
                    filled: true,
                    fillColor: const Color(0xFF0D1117),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Color(0xFF30363d)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Color(0xFF30363d)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(
                        color: Color(0xFF58A6FF),
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
                    if (intValue != null && intValue >= 80 && intValue <= 140) {
                      ref
                          .read(settingsProvider.notifier)
                          .updateFontSize(intValue / 100);
                    } else {
                      _fontSizeController.text =
                          (settings.fontSize * 100).round().toString();
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
