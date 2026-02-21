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
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

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
              color: colorScheme.surface,
              border: Border.all(color: colorScheme.outline),
              borderRadius: BorderRadius.circular(6),
            ),
            child: DropdownButton<Locale>(
              value: currentLocale,
              onChanged: (newLocale) {
                if (newLocale != null) {
                  ref.read(localeProvider.notifier).setLocale(newLocale);
                }
              },
              dropdownColor: colorScheme.surfaceContainerHighest,
              underline: const SizedBox.shrink(),
              icon: Icon(
                Icons.arrow_drop_down,
                color: colorScheme.onSurfaceVariant,
              ),
              style: textTheme.bodyMedium?.copyWith(fontSize: 14),
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
