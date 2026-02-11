import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../features/settings/presentation/providers/settings_providers.dart';

/// Utilidades para navegación y feedback al usuario
/// Centraliza la lógica de mostrar mensajes y navegar

/// Muestra un mensaje de error usando SnackBar
void showError(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(message),
      backgroundColor: AppColors.error,
      behavior: SnackBarBehavior.floating,
    ),
  );
}

/// Muestra un mensaje de éxito usando SnackBar
void showSuccess(BuildContext context, String message) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(content: Text(message), backgroundColor: AppColors.success),
  );
}

/// Navega al shell del proyecto con la ruta especificada
/// Guarda el proyecto como el último abierto antes de navegar
Future<void> navigateToProjectShell(
  BuildContext context,
  WidgetRef ref,
  String projectPath,
) async {
  // Guardar como último proyecto abierto
  try {
    await ref.read(lastProjectProvider.notifier).updateLastProject(projectPath);
  } on Exception catch (e) {
    debugPrint('Error saving last project: $e');
    // Continue navigation even if save fails
  }

  // Navegar al proyecto
  if (context.mounted) {
    context.go(
      Uri(
        path: '/project-shell',
        queryParameters: {'path': projectPath},
      ).toString(),
    );
  }
}
