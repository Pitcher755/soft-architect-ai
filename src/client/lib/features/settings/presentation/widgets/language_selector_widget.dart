/// Language selector widget for changing app locale.
///
/// Displays a dropdown menu to switch between supported languages (EN/ES).
/// Changes are persisted to SharedPreferences and rebuild the entire app.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/locale_provider.dart';
import '../../../../gen/app_localizations.dart';

/// Language selector dropdown widget.
///
/// Provides a user-friendly dropdown to change app language at runtime.
/// Integrates with Riverpod state management and persists selection.
class LanguageSelectorWidget extends ConsumerWidget {
  /// Create language selector widget.
  const LanguageSelectorWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final l10n = AppLocalizations.of(context);

    return ListTile(
      leading: const Icon(Icons.language),
      title: Text(l10n.settingsLanguageLabel),
      trailing: DropdownButton<String>(
        value: locale.languageCode,
        items: [
          DropdownMenuItem(value: 'en', child: Text(l10n.english)),
          DropdownMenuItem(value: 'es', child: Text(l10n.spanish)),
        ],
        onChanged: (newLanguageCode) {
          if (newLanguageCode != null) {
            ref
                .read(localeProvider.notifier)
                .setLocale(Locale(newLanguageCode));
          }
        },
      ),
    );
  }
}

/// Compact language toggle button (alternative to dropdown).
///
/// Shows current language with button to toggle between EN/ES.
/// Useful in header or toolbar space-constrained areas.
class LanguageToggleButton extends ConsumerWidget {
  /// Create language toggle button.
  const LanguageToggleButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    return Tooltip(
      message: locale.languageCode == 'en' ? 'Español' : 'English',
      child: IconButton(
        icon: Text(
          locale.languageCode.toUpperCase(),
          style: Theme.of(context).textTheme.labelLarge,
        ),
        onPressed: () {
          ref.read(localeProvider.notifier).toggleLocale();
        },
      ),
    );
  }
}
