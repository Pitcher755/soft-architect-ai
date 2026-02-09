import 'dart:io'; // Para crear directorios

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/theme/app_colors.dart';
import '../../../../../shared/presentation/widgets/labeled_text_area.dart';
import '../../../../../shared/presentation/widgets/labeled_text_field.dart';
import '../../../../../shared/presentation/widgets/path_picker_field.dart';
import '../../../../../shared/utils/navigation_utils.dart';
import '../../../../../shared/utils/validation_utils.dart';
import '../../../filesystem/data/services/filesystem_service.dart';
import '../providers/project_providers.dart';

/// CreateProjectDialog - Widget separado para crear nuevos proyectos
/// Encapsula la lógica de diálogo, selección
/// de archivos y creación de directorios.
class CreateProjectDialog {
  /// Muestra el modal de creación de proyecto
  static void show(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    // Ruta por defecto según el SO (puedes ajustarlo si quieres)
    final pathController = TextEditingController(text: Directory.current.path);
    final descController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false, // Evitar cerrar por error
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceBg,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Nuevo Proyecto',
              style: TextStyle(
                color: AppColors.textMain,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(dialogContext),
              icon: const Icon(Icons.close, color: AppColors.textSecondary),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: SizedBox(
            width: 500,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Campo Nombre del Proyecto
                LabeledTextField(
                  label: 'Nombre del Proyecto',
                  controller: nameController,
                  hint: 'Ej: SoftArchitect_V1',
                  helpText:
                      'Solo caracteres alfanuméricos, guiones y guiones bajos.',
                ),
                const SizedBox(height: 24),

                // Campo Ruta Base
                PathPickerField(
                  label: 'Ruta Base (Carpeta Contenedora)',
                  controller: pathController,
                  hint: 'Selecciona una ruta...',
                  helpText: 'El proyecto se creará dentro de esta carpeta.',
                ),
                const SizedBox(height: 24),

                // Campo Descripción
                LabeledTextArea(
                  label: 'Descripción Corta',
                  controller: descController,
                  hint: '¿Qué vamos a construir hoy?',
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppColors.textMain),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => CreateProjectDialog._handleCreateProject(
              context, // Contexto padre (para navegación y snackbar)
              dialogContext, // Contexto del diálogo (para cerrar)
              ref, // Ref de Riverpod para actualizar estado
              nameController.text.trim(),
              pathController.text.trim(),
              descController.text.trim(),
            ),
            icon: const Icon(Icons.rocket_launch, size: 18),
            label: const Text('Crear Proyecto'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Maneja la lógica de validación y creación física de directorios
  static Future<void> _handleCreateProject(
    BuildContext parentContext,
    BuildContext dialogContext,
    WidgetRef ref,
    String projectName,
    String basePath,
    String description,
  ) async {
    // 1. Validaciones básicas usando el helper
    final validationError = validateProjectInputs(
      projectName: projectName,
      basePath: basePath,
    );

    if (validationError != null) {
      showError(parentContext, validationError);
      return;
    }

    // 2. Construcción de rutas usando package:path para ser cross-platform
    final fullProjectPath = '$basePath/$projectName';

    try {
      // 3. Usar el servicio para crear la estructura completa
      final filesystemService = FilesystemService();
      await filesystemService.createProjectStructure(
        basePath,
        projectName,
        description,
      );

      // 4. ACTUALIZAR ESTADO GLOBAL (Riverpod)
      // Esto hace que aparezca en la lista inmediatamente
      await ref
          .read(projectsProvider.notifier)
          .addProject(projectName, fullProjectPath, description);

      // 5. Cerrar diálogo y navegar
      if (dialogContext.mounted) {
        Navigator.pop(dialogContext); // Cierra el modal
      }

      if (parentContext.mounted) {
        showSuccess(
          parentContext,
          'Proyecto "$projectName" creado exitosamente',
        );
        navigateToProjectShell(parentContext, fullProjectPath);
      }
    } on Exception catch (e) {
      if (parentContext.mounted) {
        showError(parentContext, 'Error al crear el proyecto: $e');
      }
    }
  }
}
