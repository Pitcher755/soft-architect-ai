import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/app_config.dart';
import 'core/config/theme_config.dart';
import 'core/router/app_router.dart';

void main() async {
  // Load environment variables from .env file (optional for development)
  try {
    await dotenv.load();
  } on Exception catch (e) {
    // .env file not found, will use default values from AppConfig
    debugPrint('Note: .env file not found, using default configuration: $e');
  }

  runApp(const ProviderScope(child: SoftArchitectApp()));
}

class SoftArchitectApp extends ConsumerWidget {
  const SoftArchitectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = createAppRouter();

    return MaterialApp.router(
      title: 'SoftArchitect AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: AppConfig.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      routerConfig: router,
      locale: const Locale(AppConfig.language),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('es')],
    );
  }
}
