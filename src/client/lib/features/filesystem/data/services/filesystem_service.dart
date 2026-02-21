// ignore_for_file: always_put_control_body_on_new_line, avoid_slow_async_io, avoid_catches_without_on_clauses, lines_longer_than_80_chars, cascade_invocations

import 'dart:io';

import 'package:path/path.dart' as p;

/// Service for filesystem operations
/// Encapsulates all file and directory creation logic
class FilesystemService {
  /// Creates the complete structure for a new project
  /// Includes directories and initial files (README.md, AGENTS.md)
  Future<void> createProjectStructure(
    String basePath,
    String projectName,
    String description,
  ) async {
    final fullProjectPath = p.join(basePath, projectName);
    final contextPath = p.join(fullProjectPath, 'context');

    final projectDir = Directory(fullProjectPath);

    // Verificar si ya existe
    if (await projectDir.exists()) {
      throw Exception(
        'Ya existe una carpeta con ese nombre en la ruta seleccionada',
      );
    }

    // Create directories
    await projectDir.create(recursive: true);
    await Directory(contextPath).create();

    // Create initial files
    await _createReadmeFile(fullProjectPath, projectName, description);
    await _createAgentsFile(fullProjectPath, projectName, description);
  }

  /// Creates a directory at the specified path
  Future<void> createDirectory(String path) async {
    await Directory(path).create(recursive: true);
  }

  /// Creates a file with the specified content
  Future<void> createFile(String path, String content) async {
    final file = File(path);
    await file.writeAsString(content);
  }

  /// Creates the README.md file with initial content
  Future<void> _createReadmeFile(
    String projectPath,
    String projectName,
    String description,
  ) async {
    final readmePath = p.join(projectPath, 'README.md');
    final content =
        '''# $projectName

$description

## 🚀 Inicio Rápido

### Prerrequisitos
- Flutter SDK (versión 3.0 o superior)
- Python 3.12+
- Git

### Instalación

```bash
# Clonar el repositorio
git clone <url-del-repositorio>
cd $projectName

# Instalar dependencias de Flutter
flutter pub get

# Instalar dependencias de Python
pip install -r requirements.txt
```

### Ejecución

```bash
# Ejecutar la aplicación
flutter run

# Ejecutar el backend
python main.py
```

## 📁 Estructura del Proyecto

```
$projectName/
├── src/
│   ├── client/          # Aplicación Flutter
│   └── server/          # Backend Python FastAPI
├── packages/
│   └── knowledge_base/  # Base de conocimientos RAG
├── context/             # Especificaciones y requisitos
├── doc/                 # Documentación del proyecto
└── infrastructure/      # Configuración Docker y despliegue
```

## 🛠️ Tecnologías Utilizadas

- **Frontend:** Flutter (Desktop)
- **Backend:** Python FastAPI
- **IA:** LangChain + Ollama/Groq
- **Base de Datos:** ChromaDB (Vectorial) + SQLite
- **Arquitectura:** Clean Architecture + Hexagonal

## 🤖 Agentes

Ver [`AGENTS.md`](AGENTS.md) para información detallada sobre los agentes disponibles.

## 📚 Documentación

- [`doc/`](doc/) - Documentación completa del proyecto
- [`context/`](context/) - Especificaciones y requisitos
- [`AGENTS.md`](AGENTS.md) - Información sobre agentes

## 🧪 Testing

```bash
# Ejecutar tests de Flutter
flutter test

# Ejecutar tests de Python
pytest
```

## 📝 Licencia

Este proyecto está bajo la Licencia MIT. Ver [`LICENSE`](LICENSE) para más detalles.

---

*Proyecto generado automáticamente por SoftArchitect AI*''';

    await createFile(readmePath, content);
  }

  /// Creates the AGENTS.md file with initial content
  Future<void> _createAgentsFile(
    String projectPath,
    String projectName,
    String description,
  ) async {
    final agentsPath = p.join(projectPath, 'AGENTS.md');
    final content =
        '''# 🤖 AGENTS: $projectName

## 📋 Descripción del Proyecto
$description

## 🤖 Agentes Disponibles

### ArquitectZero (Lead Software Architect)
- **Rol:** Arquitecto Técnico y Desarrollador Full-Stack
- **Objetivo:** Construir y mantener la arquitectura del proyecto
- **Stack Tecnológico:** Flutter, Python FastAPI, LangChain, ChromaDB

## 📚 Documentación
- Ver `doc/` para documentación completa del proyecto
- Ver `context/` para especificaciones y requisitos

## 🚀 Inicio Rápido
1. Revisar la documentación en `doc/`
2. Configurar el entorno de desarrollo
3. Ejecutar los tests

---
*Generado automáticamente por SoftArchitect AI*''';

    await createFile(agentsPath, content);
  }
}
