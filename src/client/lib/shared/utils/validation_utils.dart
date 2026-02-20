/// Form validation utilities
/// Contains reusable functions for validating user inputs
library;

/// Validates if a project name is valid
/// Only allows letters, numbers, hyphens, and underscores
bool isValidProjectName(String name) {
  if (name.isEmpty) {
    return false;
  }
  final validNameExp = RegExp(r'^[a-zA-Z0-9_-]+$');
  return validNameExp.hasMatch(name);
}

/// Validates all inputs in the project creation form
/// Returns null if everything is valid, or an error message
String? validateProjectInputs({
  required String projectName,
  required String basePath,
}) {
  if (projectName.isEmpty) {
    return 'Por favor ingresa un nombre de proyecto';
  }

  if (!isValidProjectName(projectName)) {
    return 'El nombre contiene caracteres inválidos';
  }

  if (basePath.isEmpty) {
    return 'Por favor selecciona una ruta base';
  }

  return null; // All valid
}
