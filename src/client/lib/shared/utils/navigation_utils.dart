import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';

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
    SnackBar(
      content: Text(message),
      backgroundColor: AppColors.success,
    ),
  );
}

/// Navega al shell del proyecto con la ruta especificada
void navigateToProjectShell(BuildContext context, String projectPath) {
  context.go(
    Uri(
      path: '/project-shell',
      queryParameters: {'path': projectPath},
    ).toString(),
  );
}
