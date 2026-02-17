import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'core/config/theme_config.dart';
import 'core/database_initializer.dart';
import 'core/localization/locale_provider.dart';
import 'core/router/app_router.dart';
import 'features/chat/presentation/notifiers/chat_notifier.dart';
import 'features/project_shell/core/services/file_system_service.dart';
import 'features/settings/presentation/providers/settings_providers.dart';
import 'gen/app_localizations.dart';
import 'shared/presentation/widgets/keyboard_zoom_wrapper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize window manager for desktop platforms
  if (!kIsWeb) {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      size: Size(1920, 1080),
      minimumSize: Size(1024, 768),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.normal,
      fullScreen: false, // Start maximized instead
    );

    await windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.maximize(); // Maximize window on startup
      await windowManager.show();
      await windowManager.focus();
    });
  }

  // Initialize database for current platform (Desktop/Web/Mobile)
  await initializeSqfliteForDesktop();
  debugPrint(getDatabaseInitStatus());

  // Load environment variables from .env file
  // (skip on web, optional on desktop)
  if (!kIsWeb) {
    try {
      await dotenv.load(isOptional: true);
      debugPrint('✅ .env file loaded successfully');
    } on Exception catch (e) {
      // .env file not found or error loading, will use default values
      // from AppConfig
      debugPrint(
        '⚠️  Note: .env file not found or error loading, '
        'using default configuration: $e',
      );
    }
  } else {
    debugPrint('ℹ️  Web platform: skipping .env file loading');
  }

  runApp(
    ProviderScope(
      overrides: [
        // Provide FileSystemService implementation
        fileSystemServiceProvider.overrideWithValue(FileSystemServiceImpl()),
      ],
      child: const SoftArchitectApp(),
    ),
  );
}

class SoftArchitectApp extends ConsumerWidget {
  const SoftArchitectApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // CRITICAL: Router is static provider, never rebuilds
    final router = ref.watch(appRouterProvider);
    final locale = ref.watch(localeProvider);

    // Watch settings async for initial load
    final settingsAsync = ref.watch(settingsProvider);

    return settingsAsync.when(
      data: (settings) => KeyboardZoomWrapper(
        child: MaterialApp.router(
          title: 'SoftArchitect AI',
          debugShowCheckedModeBanner: false,
          theme: _buildThemeWithFontSize(
            AppTheme.darkTheme(),
            settings.fontSize,
          ),
          darkTheme: _buildThemeWithFontSize(
            AppTheme.darkTheme(),
            settings.fontSize,
          ),
          themeMode: ThemeMode.dark,
          routerConfig: router,
          locale: locale,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: LocaleNotifier.supportedLocales,
          // Apply zoom in builder without rebuilding router
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(settings.globalZoom)),
            child: child!,
          ),
        ),
      ),
      loading: () => const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      ),
      error: (_, __) => const MaterialApp(
        home: Scaffold(body: Center(child: Text('Error loading settings'))),
      ),
    );
  }

  /// Builds theme with optional font size scaling.
  ///
  /// Manually scales each TextStyle to avoid assertions on themes
  /// without explicit fontSize definitions.
  ThemeData _buildThemeWithFontSize(ThemeData baseTheme, double fontSize) {
    if (fontSize == 1.0) {
      return baseTheme;
    }

    final scaledTextTheme = _scaleTextTheme(baseTheme.textTheme, fontSize);
    return baseTheme.copyWith(textTheme: scaledTextTheme);
  }

  /// Manually scales TextTheme by multiplying font sizes.
  ///
  /// Avoids TextTheme.apply() assertion errors by building a new
  /// TextTheme with each style's fontSize multiplied by the factor.
  TextTheme _scaleTextTheme(TextTheme baseTheme, double scaleFactor) =>
      TextTheme(
        displayLarge: _scaleTextStyle(baseTheme.displayLarge, scaleFactor),
        displayMedium: _scaleTextStyle(baseTheme.displayMedium, scaleFactor),
        displaySmall: _scaleTextStyle(baseTheme.displaySmall, scaleFactor),
        headlineLarge: _scaleTextStyle(baseTheme.headlineLarge, scaleFactor),
        headlineMedium: _scaleTextStyle(baseTheme.headlineMedium, scaleFactor),
        headlineSmall: _scaleTextStyle(baseTheme.headlineSmall, scaleFactor),
        titleLarge: _scaleTextStyle(baseTheme.titleLarge, scaleFactor),
        titleMedium: _scaleTextStyle(baseTheme.titleMedium, scaleFactor),
        titleSmall: _scaleTextStyle(baseTheme.titleSmall, scaleFactor),
        bodyLarge: _scaleTextStyle(baseTheme.bodyLarge, scaleFactor),
        bodyMedium: _scaleTextStyle(baseTheme.bodyMedium, scaleFactor),
        bodySmall: _scaleTextStyle(baseTheme.bodySmall, scaleFactor),
        labelLarge: _scaleTextStyle(baseTheme.labelLarge, scaleFactor),
        labelMedium: _scaleTextStyle(baseTheme.labelMedium, scaleFactor),
        labelSmall: _scaleTextStyle(baseTheme.labelSmall, scaleFactor),
      );

  /// Scales a single TextStyle by multiplying its fontSize.
  ///
  /// Returns original style if fontSize is null.
  TextStyle? _scaleTextStyle(TextStyle? style, double scaleFactor) {
    if (style == null) {
      return null;
    }
    final fontSize = style.fontSize ?? 14.0; // Default size if not defined
    return style.copyWith(fontSize: fontSize * scaleFactor);
  }
}
