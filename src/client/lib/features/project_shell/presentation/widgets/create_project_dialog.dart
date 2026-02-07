import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// CreateProjectDialog - Separated widget for creating new projects
/// Encapsulates the entire dialog logic and UI
class CreateProjectDialog {
  /// Shows the create project dialog modal
  static void show(BuildContext context) {
    final nameController = TextEditingController();
    final pathController = TextEditingController(
      text: '~/Documents/SoftArchitectProjects',
    );
    final descController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: const Color(0xFF161B22),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Nuevo Proyecto',
              style: TextStyle(
                color: Color(0xFFE6EDF3),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            IconButton(
              onPressed: () => Navigator.pop(dialogContext),
              icon: const Icon(Icons.close, color: Color(0xFF8b949e)),
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
                // Project name field
                CreateProjectDialog._buildTextField(
                  label: 'Nombre del Proyecto',
                  controller: nameController,
                  hint: 'Ej: MySuperApp',
                  helpText:
                      'Solo caracteres alfanuméricos, guiones y guiones bajos.',
                ),
                const SizedBox(height: 24),

                // Base path field
                CreateProjectDialog._buildPathField(pathController),
                const SizedBox(height: 24),

                // Description field
                CreateProjectDialog._buildTextAreaField(
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
              style: TextStyle(color: Color(0xFFE6EDF3)),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => CreateProjectDialog._handleCreateProject(
              context,
              dialogContext,
              nameController.text.trim(),
              pathController.text,
            ),
            icon: const Icon(Icons.rocket_launch, size: 18),
            label: const Text('Crear Proyecto'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0d0df2),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Handles the project creation logic
  static void _handleCreateProject(
    BuildContext parentContext,
    BuildContext dialogContext,
    String projectName,
    String projectPath,
  ) {
    if (projectName.isEmpty) {
      ScaffoldMessenger.of(parentContext).showSnackBar(
        const SnackBar(
          content: Text('Por favor ingresa un nombre de proyecto'),
        ),
      );
      return;
    }
    Navigator.pop(dialogContext);
    // Navigate to ProjectShellScreen with the project path
    parentContext.go('/project-shell?path=${Uri.encodeComponent(projectPath)}');
  }

  /// Builds a standard text field for the dialog
  static Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required String helpText,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(0xFFE6EDF3),
        ),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        decoration: CreateProjectDialog._buildInputDecoration(hint),
        style: const TextStyle(color: Color(0xFFE6EDF3)),
      ),
      const SizedBox(height: 4),
      Text(
        helpText,
        style: const TextStyle(fontSize: 11, color: Color(0xFF8b949e)),
      ),
    ],
  );

  /// Builds a text area field (multi-line) for the dialog
  static Widget _buildTextAreaField({
    required String label,
    required TextEditingController controller,
    required String hint,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(0xFFE6EDF3),
        ),
      ),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        maxLines: 3,
        decoration: CreateProjectDialog._buildInputDecoration(hint),
        style: const TextStyle(color: Color(0xFFE6EDF3)),
      ),
    ],
  );

  /// Builds the path field with browse button
  static Widget _buildPathField(TextEditingController pathController) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'Ruta Base (Local)',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: Color(0xFFE6EDF3),
        ),
      ),
      const SizedBox(height: 8),
      Row(
        children: [
          Expanded(
            child: TextField(
              controller: pathController,
              readOnly: true,
              decoration: CreateProjectDialog._buildInputDecoration(''),
              style: const TextStyle(
                color: Color(0xFF444c56),
                fontFamily: 'Courier',
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Implement file picker for path selection
            },
            icon: const Icon(Icons.folder_open, size: 18),
            label: const Text('Examinar...'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF21262d),
              foregroundColor: Colors.white,
              side: const BorderSide(color: Color(0xFF30363d)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
      const SizedBox(height: 4),
      const Text(
        'Se creará la carpeta automáticamente.',
        style: TextStyle(fontSize: 11, color: Color(0xFF8b949e)),
      ),
    ],
  );

  /// Common input decoration for all text fields
  static InputDecoration _buildInputDecoration(String hint) => InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(color: Color(0xFF444c56)),
    filled: true,
    fillColor: const Color(0xFF0D1117),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF30363d)),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF30363d)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(8),
      borderSide: const BorderSide(color: Color(0xFF0d0df2), width: 2),
    ),
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  );
}
