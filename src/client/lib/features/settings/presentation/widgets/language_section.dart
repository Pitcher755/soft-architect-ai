import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../gen/app_localizations.dart';
import '../../../../core/localization/locale_provider.dart';
import 'setting_item.dart';
import 'settings_card.dart';

/// Language section widget - manages application language settings.
///
/// Allows users to switch between supported languages (Spanish/English).
/// Changes are persisted and applied immediately to the entire application.
class LanguageSection extends ConsumerWidget {
  const LanguageSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final currentLocale = ref.watch(localeProvider);

    return SettingsCard(
      title: l10n.languageTitle,
      icon: Icons.language,
      children: [
        SettingItem(
          title: l10n.languageInterfaceTitle,
          subtitle: l10n.languageInterfaceSubtitle,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1117),
              border: Border.all(color: const Color(0xFF30363d)),
              borderRadius: BorderRadius.circular(6),
            ),
            child: DropdownButton<Locale>(
              value: currentLocale,
              onChanged: (newLocale) {
                if (newLocale != null) {
                  ref.read(localeProvider.notifier).setLocale(newLocale);
                }
              },
              dropdownColor: const Color(0xFF161B22),
              underline: const SizedBox.shrink(),
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFF8b949e)),
              style: const TextStyle(color: Color(0xFFE6EDF3), fontSize: 14),
              items: [
                // Opción Español
                DropdownMenuItem(
                  value: const Locale('es'),
                  child: Row(
                    children: [
                      const Text('🇪🇸', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 12),
                      Text(l10n.spanish),
                    ],
                  ),
                ),
                // Opción Inglés
                DropdownMenuItem(
                  value: const Locale('en'),
                  child: Row(
                    children: [
                      const Text('🇬🇧', style: TextStyle(fontSize: 18)),
                      const SizedBox(width: 12),
                      Text(l10n.english),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
