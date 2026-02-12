import 'package:flutter/material.dart';

class AppLocalizations {
  AppLocalizations(this.locale);
  final Locale locale;

  static AppLocalizations of(BuildContext context) =>
      Localizations.of<AppLocalizations>(context, AppLocalizations)!;

  static const _localizedValues = <String, Map<String, String>>{
    'es': {
      'settings': 'Configuración',
      'customize_experience': 'Personaliza tu experiencia en SoftArchitect AI',
      'profile': 'Perfil de Usuario',
      'storage': 'Almacenamiento',
      'appearance': 'Apariencia',
      'theme': 'Tema',
      'font_size': 'Tamaño de fuente',
      'language': 'Idioma',
      'accessibility': 'Accesibilidad',
      'zoom': 'Zoom global',
      'zoom_shortcuts': 'Atajos de teclado para zoom',
      'performance': 'Rendimiento',
      'animations': 'Animaciones',
      'memory_optimization': 'Optimización de memoria',
      'enable': 'Habilitar',
      'disable': 'Deshabilitar',
      'light': 'Claro',
      'dark': 'Oscuro',
      'system': 'Sistema',
      'save': 'Guardar',
      'cancel': 'Cancelar',
      'reset': 'Restablecer',
      'name': 'Nombre',
      'avatar': 'Avatar',
      'choose_avatar': 'Elige un avatar',
      'shortcuts_hint': 'Ctrl + / Ctrl - para zoom, Ctrl + 0 para reset',
    },
    'en': {
      'settings': 'Settings',
      'customize_experience': 'Customize your experience in SoftArchitect AI',
      'profile': 'User Profile',
      'storage': 'Storage',
      'appearance': 'Appearance',
      'theme': 'Theme',
      'font_size': 'Font size',
      'language': 'Language',
      'accessibility': 'Accessibility',
      'zoom': 'Global zoom',
      'zoom_shortcuts': 'Keyboard shortcuts for zoom',
      'performance': 'Performance',
      'animations': 'Animations',
      'memory_optimization': 'Memory optimization',
      'enable': 'Enable',
      'disable': 'Disable',
      'light': 'Light',
      'dark': 'Dark',
      'system': 'System',
      'save': 'Save',
      'cancel': 'Cancel',
      'reset': 'Reset',
      'name': 'Name',
      'avatar': 'Avatar',
      'choose_avatar': 'Choose an avatar',
      'shortcuts_hint': 'Ctrl + / Ctrl - to zoom, Ctrl + 0 to reset',
    },
  };

  String get(String key) =>
      _localizedValues[locale.languageCode]?[key] ??
      _localizedValues['en']![key] ??
      key;
}

class AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) => ['en', 'es'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) async =>
      AppLocalizations(locale);

  @override
  bool shouldReload(AppLocalizationsDelegate old) => false;
}
