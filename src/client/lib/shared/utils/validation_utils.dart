/// Utilidades de validación para formularios
/// Contiene funciones reutilizables para validar inputs de usuario
library;

/// Valida si un nombre de proyecto es válido
/// Solo permite letras, números, guiones y guiones bajos
bool isValidProjectName(String name) {
  if (name.isEmpty) {
    return false;
  }
  final validNameExp = RegExp(r'^[a-zA-Z0-9_-]+$');
  return validNameExp.hasMatch(name);
}

/// Valida todos los inputs del formulario de creación de proyecto
/// Retorna null si todo es válido, o un mensaje de error
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

  return null; // Todo válido
}
