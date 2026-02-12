import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/config/theme_config.dart';
import 'core/database_initializer.dart';
import 'core/localization/locale_provider.dart';
import 'core/router/app_router.dart';
import 'features/chat/presentation/notifiers/chat_notifier.dart';
import 'features/project_shell/core/services/file_system_service.dart';
import 'features/settings/presentation/providers/settings_providers.dart';
import 'gen/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

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
    final router = createAppRouter();
    final locale = ref.watch(localeProvider);

    // CRITICAL: Watch ONLY theme and font size
    // Do NOT watch globalZoom - it would cause entire app rebuild
    final themeMode = ref.watch(themeModeProvider);
    final fontSize = ref.watch(fontSizeProvider);

    // Read zoom without watching (no rebuild when zoom changes)
    // This is read fresh on every build, but that's OK for MediaQuery
    final globalZoom = ref.read(globalZoomProvider);
    final enableZoomShortcuts = ref.read(enableZoomShortcutsProvider);

    // Apply global zoom by wrapping the app in MediaQuery
    // IMPORTANT: Use FocusScope to capture shortcuts without triggering
    // navigation
    return FocusScope(
      onKey: (node, event) {
        if (!enableZoomShortcuts) {
          return KeyEventResult.ignored;
        }

        final isCtrlPressed = HardwareKeyboard.instance.isControlPressed;
        if (!isCtrlPressed) {
          return KeyEventResult.ignored;
        }

        // Ctrl + Shift + Plus (En/US layout: Ctrl+Shift+=)
        if (event.logicalKey == LogicalKeyboardKey.equal &&
            HardwareKeyboard.instance.isShiftPressed) {
          ref.read(settingsProvider.notifier).updateGlobalZoom(
                (globalZoom + 0.1).clamp(0.5, 2.0),
              );
          return KeyEventResult.handled;
        }

        // Ctrl + Equal/Plus (Spanish: Ctrl+= where + is Shift+=)
        if (event.logicalKey == LogicalKeyboardKey.equal &&
            !HardwareKeyboard.instance.isShiftPressed) {
          ref.read(settingsProvider.notifier).updateGlobalZoom(
                (globalZoom + 0.1).clamp(0.5, 2.0),
              );
          return KeyEventResult.handled;
        }

        // Ctrl + Minus (works on all layouts)
        if (event.logicalKey == LogicalKeyboardKey.minus) {
          ref.read(settingsProvider.notifier).updateGlobalZoom(
                (globalZoom - 0.1).clamp(0.5, 2.0),
              );
          return KeyEventResult.handled;
        }

        // Ctrl + 0: Reset to 100%
        if (event.logicalKey == LogicalKeyboardKey.digit0) {
          ref.read(settingsProvider.notifier).updateGlobalZoom(1);
          return KeyEventResult.handled;
        }

        return KeyEventResult.ignored;
      },
      child: Focus(
        canRequestFocus: true,
        child: MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(globalZoom),
          ),
          child: MaterialApp.router(
            title: 'SoftArchitect AI',
            debugShowCheckedModeBanner: false,
            theme: _buildThemeWithFontSize(AppTheme.lightTheme(), fontSize),
            darkTheme: _buildThemeWithFontSize(
              AppTheme.darkTheme(),
              fontSize,
            ),
            themeMode: themeMode,
            routerConfig: router,
            locale: locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: LocaleNotifier.supportedLocales,
          ),
        ),
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
  TextTheme _scaleTextTheme(
    TextTheme baseTheme,
    double scaleFactor,
  ) =>
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
