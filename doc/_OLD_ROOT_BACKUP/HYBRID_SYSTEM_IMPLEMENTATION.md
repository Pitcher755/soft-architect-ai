# 🔄 Implementación del Sistema Híbrido de Proyectos

> **Fecha:** 2024
> **Estado:** ✅ Completado
> **Versión:** 1.0

## 📖 Tabla de Contenidos

- [Visión General](#visión-general)
- [Componentes Clave](#componentes-clave)
- [Flujo de Datos](#flujo-de-datos)
- [Archivos Modificados](#archivos-modificados)
- [Guía de Uso](#guía-de-uso)
- [Testing](#testing)

---

## Visión General

El sistema híbrido permite gestionar **dos tipos de proyectos** en una interfaz unificada:

1. **Proyectos Reales** 📁: Carpetas en el disco que siguen la estructura SoftArchitect
2. **Proyectos Mock** (Guía) 📖: Contenido incrustado que actúa como tutorial interactivo

### Ventajas

- ✅ Interfaz unificada para ambos tipos
- ✅ Navegar entre proyectos reales y guía sin cambios
- ✅ Privacidad total (datos mock en memoria)
- ✅ Carga inmediata (sin I/O para mock)
- ✅ Escalable (fácil agregar más guías)

---

## Componentes Clave

### 1. **Protocol Virtual: `mock://`**

Las rutas mock usan el protocolo `mock://` para distinguirse:

```
Ruta real:  /home/user/Projects/MyApp
Ruta mock:  mock://softarchitect-guide
```

**Uso:**
- Detectar tipo en `if (path.startsWith('mock://'))`
- Nunca intentar leer del filesystem
- Usar `MockProjectData.guideFileContents[path]` para contenido

---

### 2. **MockProjectData (Datos en Memoria)**

Ubicación: `lib/features/project_shell/data/mock_data.dart`

**Estructura:**
```dart
MockProjectData.guideRootNode
├── "00-Bienvenido.md"
└── "01-Funcionalidades"
    └── "Chat-IA.md"

MockProjectData.guideFileContents
├── "mock://softarchitect-guide/00-Bienvenido.md" → String (markdown)
└── "mock://softarchitect-guide/features/Chat-IA.md" → String (markdown)
```

**Ventaja:** FileNode + Strings hacen muy eficiente la navegación.

---

### 3. **buildHybridProjectsList() Helper**

Ubicación: `lib/features/project_shell/presentation/providers/projects_provider.dart`

**Responsabilidad:**
- Recibe lista de proyectos reales
- Convierte mock data a objetos `Project`
- Combina y ordena por fecha de modificación

**Código:**
```dart
List<Project> buildHybridProjectsList(List<Project> userProjects) {
  // 1. Convierte mock data a Project entities
  // 2. Combina userProjects + mockProjects
  // 3. Ordena por lastOpened desc
  return all;
}
```

---

### 4. **Entidad Project - Getter `phase`**

Ubicación: `lib/features/project_shell/domain/entities/project.dart`

**Nuevo getter:**
```dart
String get phase {
  // Deriva fase de la ruta (Arquitectura, Implementación, etc.)
  // O devuelve "Contexto" por defecto
}
```

**Propósito:** Mostrar badge de fase en ProjectCard sin datos adicionales.

---

### 5. **Detección Hybrid en 3 Puntos Clave**

#### A. **FileTreeWidget** → Detección de árbol
```dart
if (widget.projectPath?.startsWith('mock://') ?? false) {
  // Usa MockProjectData.guideRootNode
} else {
  // Lee del filesystem
}
```

#### B. **ProjectShellScreen** → Detección de contenido
```dart
if (node.path.startsWith('mock://')) {
  // Lee de MockProjectData.guideFileContents[path]
} else {
  // File.readAsString()
}
```

#### C. **ProjectWorkspaceScreen** → Detección de lista
```dart
final allProjects = buildHybridProjectsList([]);
// Incluye Guía + Proyectos reales
```

---

## Flujo de Datos

### Escenario 1: Ver Guía

```
1. Usuario abre Dashboard
   ↓
2. buildHybridProjectsList() retorna [Guía, Proyecto1, Proyecto2, ...]
   ↓
3. Usuario hace click en "Guía SoftArchitect"
   ↓
4. ProjectCard.onTap() → GoRouter('/project-shell?path=mock://softarchitect-guide')
   ↓
5. ProjectShellScreen carga con path='mock://softarchitect-guide'
   ↓
6. FileTreeWidget detecta mock:// → Usa MockProjectData.guideRootNode
   ↓
7. Usuario navega archivos (00-Bienvenido.md, Chat-IA.md, etc.)
   ↓
8. Al hacer click en archivo:
   - Detecta mock:// → MockProjectData.guideFileContents[path]
   - Muestra en panel central
```

### Escenario 2: Crear y Abrir Proyecto Real

```
1. Usuario hace click "+Nuevo Proyecto"
   ↓
2. CreateProjectDialog solicita carpeta
   ↓
3. Proyecto creado en /home/user/Projects/MyApp
   ↓
4. buildHybridProjectsList([newProject]) → [newProject, Guía, ...]
   ↓
5. Usuario hace click en MyApp
   ↓
6. ProjectCard.onTap() → GoRouter('/project-shell?path=/home/user/Projects/MyApp')
   ↓
7. ProjectShellScreen carga con path='/home/user/Projects/MyApp'
   ↓
8. FileTreeWidget detecta NO mock:// → Lee del filesystem
   ↓
9. Navegación normal (File I/O)
```

---

## Archivos Modificados

| Archivo | Cambios | Propósito |
|---------|---------|----------|
| **project.dart** | ➕ Getter `phase` | Derivar fase de ruta |
| **mock_projects_data.dart** | ✏️ Función `getMockProjectsData()` | Retornar guía como proyecto mock |
| **mock_data.dart** | ✏️ guideRootNode, guideFileContents | Datos de guía en memoria |
| **projects_provider.dart** | ✨ `buildHybridProjectsList()` | Helper para mezclar proyectos |
| **file_tree_widget.dart** | ✏️ Detección mock:// | Mostrar guía o filesystem |
| **project_shell_screen.dart** | ✏️ Lectura híbrida | Leer de mock o disco |
| **project_workspace_screen.dart** | ✏️ Usar Project entities | GridView con objetos Project |
| **project_list_view.dart** | ✏️ Aceptar List<Project> | Mostrar lista híbrida |

---

## Guía de Uso

### Agregar Nueva Sección a la Guía

1. **Editar `mock_data.dart`:**
   ```dart
   static const FileNode guideRootNode = FileNode(
     children: [
       // ... existentes ...
       FileNode(
         id: 'new_section',
         name: '02-Nueva-Sección.md',
         path: 'mock://softarchitect-guide/02-Nueva-Sección.md',
         isDirectory: false,
       ),
     ],
   );
   ```

2. **Agregar contenido en `guideFileContents`:**
   ```dart
   static const Map<String, String> guideFileContents = {
     'mock://softarchitect-guide/02-Nueva-Sección.md': '''# 📚 Nueva Sección

     Contenido aquí...
     ''',
   };
   ```

3. ✅ Listo. La guía se actualiza automáticamente.

---

### Agregar Nuevo Proyecto Mock (Ejemplo Complejo)

1. **Crear estructura en `mock_data.dart`:**
   ```dart
   static const FileNode exampleProjectRoot = FileNode(
     name: 'EXAMPLE-PROJECT',
     path: 'mock://example-project',
     children: [/* ... */],
   );
   ```

2. **Agregar archivos en `guideFileContents`:**
   ```dart
   'mock://example-project/README.md': '''...''',
   ```

3. **Registrar en `mock_projects_data.dart`:**
   ```dart
   List<Map<String, dynamic>> getMockProjectsData() => [
     {
       'id': 'example-project',
       'name': 'Proyecto de Ejemplo',
       'path': 'mock://example-project',
       // ...
     },
   ];
   ```

---

## Testing

### Test 1: Detectar Guía en Dashboard

```dart
test('buildHybridProjectsList includes guide project', () {
  final projects = buildHybridProjectsList([]);
  expect(projects, isNotEmpty);
  expect(
    projects.where((p) => p.path == 'mock://softarchitect-guide'),
    isNotEmpty,
  );
});
```

### Test 2: Leer Archivo Mock

```dart
test('project_shell_screen reads mock file content', () async {
  final content = MockProjectData.guideFileContents[
    'mock://softarchitect-guide/00-Bienvenido.md'
  ];
  expect(content, contains('Bienvenido'));
});
```

### Test 3: FileTreeWidget Muestra Estructura Mock

```dart
test('file_tree_widget displays guide structure', () {
  final widget = FileTreeWidget(
    projectPath: 'mock://softarchitect-guide',
  );
  // Verificar que muestra nodos del guideRootNode
});
```

### Manual Test: Full Flow

1. ✅ Abrir app
2. ✅ Ver "Guía SoftArchitect" en dashboard
3. ✅ Click → Navegar a project-shell
4. ✅ Ver árbol de archivos (00-Bienvenido.md, features/Chat-IA.md)
5. ✅ Click en archivo → Ver contenido en panel central
6. ✅ Volver al dashboard
7. ✅ Crear nuevo proyecto real
8. ✅ Click en proyecto real → Navegar a archivos reales
9. ✅ Verificar que funciona igual (interfaz unificada)

---

## Preguntas Frecuentes

**¿Qué pasa si el usuario edita la guía?**
No puede. Es de solo lectura (const). Perfectamente seguro.

**¿Puedo agregar más guías (English, French)?**
Sí. Agrega otro FileNode + contenido en `mock_data.dart` y regístralo en `mock_projects_data.dart`.

**¿Performance?**
Excelente. Mock data está en memoria (const), zero I/O. Real projects usan I/O.

**¿Puede el usuario borrar la guía?**
No. Es virtual (mock://). No se puede eliminar directorios.

---

## Resumen

✅ **Híbrido implementado:**
- Proyectos reales + Guía integrada en una interfaz
- Detección automática mediante protocolo `mock://`
- Datos mock en memoria (eficiente)
- Escalable y mantenible

🎉 **Resultado:** El usuario ve proyectos reales y una guía interactiva, todo en el mismo lugar.
