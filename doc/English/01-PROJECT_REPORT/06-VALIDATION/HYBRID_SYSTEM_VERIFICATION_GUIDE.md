# 🔍 Guía de Verification del Sistema Híbrido

> **Propósito:** Verificar que el sistema híbrido está correctamente implementado
> **Audiencia:** Desarrolladores, QA, Code Reviewers

---

## 1️⃣ Verification de Files

### Files Que DEBEN Existir

```bash
✅ src/client/lib/features/project_shell/presentation/providers/projects_provider.dart
✅ src/client/lib/features/project_shell/data/mock_projects_data.dart
✅ src/client/lib/features/project_shell/data/mock_data.dart
✅ src/client/lib/features/project_shell/domain/entities/project.dart
```

### Files Que DEBEN Ser Modificados

```bash
✅ src/client/lib/features/project_shell/presentation/screens/project_workspace_screen.dart
✅ src/client/lib/features/project_shell/presentation/widgets/project_list_view.dart
✅ src/client/lib/features/project_shell/presentation/widgets/file_tree_widget.dart
✅ src/client/lib/features/project_shell/presentation/screens/project_shell_screen.dart
```

### Buscar Files

```bash
# Verificar projects_provider.dart
find . -name "projects_provider.dart" -type f

# Verificar mock_projects_data.dart
find . -name "mock_projects_data.dart" -type f

# Verificar mock_data.dart
find . -name "mock_data.dart" -type f
```

---

## 2️⃣ Verification de Código

### Buscar Protocolo Virtual `mock://`

El sistema debe usar `mock://` para identificar rutas virtuales. Debe haber exactamente:

- **3 detecciones en FileTreeWidget** (para mostrar árbol)
- **3 detecciones en ProjectShellScreen** (para leer file)
- **1 registro en MockProjectsData** (la ruta de la guía)
- **Total: 6-7 matches**

```bash
# Buscar todos los usos de mock://
grep -r "mock://" --include="*.dart" src/client/

# Resultado esperado: ~6-7 matches
```

### Buscar Getter `phase` en Project

```dart
// Debe existir en project.dart
String get phase {
  // ... lógica derivada de ruta ...
}
```

```bash
# Verificar que existe
grep -n "String get phase" src/client/lib/features/project_shell/domain/entities/project.dart

# Resultado: Debe encontrar 1 match
```

### Buscar `buildHybridProjectsList()`

```dart
// Debe existir en projects_provider.dart
List<Project> buildHybridProjectsList(List<Project> userProjects)
```

```bash
# Verificar que existe
grep -n "buildHybridProjectsList" src/client/lib/features/project_shell/presentation/providers/projects_provider.dart

# Resultado: Debe encontrar 1 match (definición)
```

```bash
# Verificar que se usa en workspace screen
grep -n "buildHybridProjectsList" src/client/lib/features/project_shell/presentation/screens/project_workspace_screen.dart

# Resultado: Debe encontrar 1 match (llamada)
```

### Buscar `guideRootNode` y `guideFileContents`

```bash
# Deben estar en mock_data.dart
grep -n "guideRootNode\|guideFileContents" src/client/lib/features/project_shell/data/mock_data.dart

# Resultado: Debe encontrar 2 matches (definiciones)
```

---

## 3️⃣ Verification de Imports

### ProjectWorkspaceScreen debe importar

```dart
import '../providers/projects_provider.dart';  // ✅ DEBE ESTAR
```

### FileTreeWidget debe importar

```dart
import '../../data/mock_data.dart';  // ✅ DEBE ESTAR
```

### ProjectShellScreen debe importar

```dart
import '../../data/mock_data.dart';  // ✅ DEBE ESTAR
```

### ProjectListView debe importar

```dart
import '../../domain/entities/project.dart';  // ✅ DEBE ESTAR (Project entity)
```

```bash
# Verificar imports
grep -n "^import" src/client/lib/features/project_shell/presentation/screens/project_workspace_screen.dart
```

---

## 4️⃣ Verification de Compilación

### NO debe haber errores

```bash
# En VS Code: CTRL+SHIFT+M (Ver problemas)
# O en terminal:
cd src/client
flutter analyze

# Resultado esperado: ✅ No analysis issues found
```

### Errores Comunes (Y Cómo Fijarlos)

#### Error: "The operator '[]' isn't defined for the type 'Project'"

**Significa:** Código intenta usar `project['name']` en lugar de `project.name`

**Ubicación probable:** GridView.builder en project_workspace_screen.dart

**Cómo Fijar:**
```dart
// ❌ MALO
name: project['name'] as String,

// ✅ BUENO
name: project.name,
```

#### Error: "The getter 'phase' isn't defined for the type 'Project'"

**Significa:** No hay getter `phase` en la entidad Project

**Ubicación probable:** project.dart

**Cómo Fijar:**
```dart
// Agregar a project.dart
String get phase {
  // ... lógica ...
}
```

#### Error: "The method '_getPhaseColor' isn't defined"

**Significa:** Falta el método helper

**Ubicación probable:** project_workspace_screen.dart

**Cómo Fijar:**
```dart
// Agregar a _ProjectWorkspaceScreenState
Color _getPhaseColor(String phase) {
  switch (phase.toLowerCase()) {
    case 'contexto': return const Color(0xFFFCD34D);
    // ... más cases ...
  }
}
```

---

## 5️⃣ Verification Funcional (Manual Testing)

### Test 1: Dashboard Muestra Guía

```
1. Abrir app
2. Ir a Dashboard
3. VERIFICAR: "Guía SoftArchitect" aparece en la lista
4. VERIFICAR: Muestra el ícono de libro
5. VERIFICAR: Ordenada junto con otros proyectos
```

### Test 2: Navegación a Guía

```
1. Hacer click en "Guía SoftArchitect"
2. VERIFICAR: URL es /project-shell?path=mock://softarchitect-guide
3. VERIFICAR: Árbol de archivos muestra:
   - 00-Bienvenido.md
   - 01-Funcionalidades/
   - features/Chat-IA.md (u otros)
```

### Test 3: Leer Contenido de Guía

```
1. Estando en la guía, hacer click en "00-Bienvenido.md"
2. VERIFICAR: Panel central muestra contenido markdown
3. VERIFICAR: Contiene "Bienvenido" o similar
4. VERIFICAR: Formatea correctamente (headers, bullets, etc.)
```

### Test 4: Navegar Entre Files Mock

```
1. Hacer click en "features/" para expandir
2. VERIFICAR: Aparece "Chat-IA.md"
3. Hacer click en "Chat-IA.md"
4. VERIFICAR: Contenido cambia
5. VERIFICAR: Panel muestra contenido diferente
```

### Test 5: Create Project Real

```
1. Hacer click en "+Nuevo Proyecto"
2. Seleccionar una carpeta (ej: /tmp/MyProject)
3. VERIFICAR: Proyecto aparece en dashboard
4. VERIFICAR: Aparece junto a guía en la lista
```

### Test 6: Navegar Project Real

```
1. Hacer click en proyecto real
2. VERIFICAR: URL es /project-shell?path=/home/user/... (NO mock://)
3. VERIFICAR: Árbol muestra archivos reales del disco
4. Hacer click en un archivo .md o .txt
5. VERIFICAR: Contenido real aparece en panel
```

### Test 7: Verificar Performance

```
1. Ir a dashboard
2. VERIFICAR: Guía carga instantáneamente (~0ms)
3. Hacer click en guía
4. VERIFICAR: Árbol se muestra inmediatamente
5. Hacer click en proyecto real
6. VERIFICAR: Hay pequeña espera (normal por I/O)
```

---

## 6️⃣ Verification de Estructura de Datos

### MockProjectData debe contener

```dart
// 1. Debe tener guideRootNode (const FileNode)
static const FileNode guideRootNode = FileNode(
  id: 'root-guide',
  name: 'SOFTARCHITECT-GUIDE',
  path: 'mock://softarchitect-guide',
  isDirectory: true,
  children: [
    // Archivos...
  ],
);

// 2. Debe tener guideFileContents (const Map)
static const Map<String, String> guideFileContents = {
  'mock://softarchitect-guide/00-Bienvenido.md': '''# Contenido...''',
  // Más archivos...
};
```

### getMockProjectsData() debe retornar

```dart
List<Map<String, dynamic>> getMockProjectsData() => [
  {
    'id': 'softarchitect-guide',
    'name': 'Guía SoftArchitect',
    'path': 'mock://softarchitect-guide',  // ✅ Con mock://
    'modified': DateTime.now().toIso8601String(),
  },
];
```

---

## 7️⃣ Verification de Integración

### buildHybridProjectsList() debe

```
✅ Recibir List<Project> (proyectos reales)
✅ Convertir mock data a Project entities
✅ Combinar ambas listas
✅ Ordenar por fecha (más recientes primero)
✅ Retornar List<Project> (híbrido)
```

### FileTreeWidget debe

```
✅ Recibir projectPath como parámetro
✅ Detectar si es mock:// o ruta real
✅ Si mock:// → usar MockProjectData.guideRootNode
✅ Si real → leer del filesystem
✅ Mostrar árbol en ambos casos
```

### ProjectShellScreen debe

```
✅ Recibir path como query parameter
✅ Pasar path a FileTreeWidget
✅ Al seleccionar archivo:
   - Si mock:// → leer de MockProjectData.guideFileContents[path]
   - Si real → File(path).readAsString()
✅ Mostrar contenido en panel central
```

---

## 8️⃣ Checklist de Validación Final

```
CÓDIGO
☐ 0 errores de compilación (flutter analyze)
☐ projects_provider.dart existe
☐ buildHybridProjectsList() definida
☐ Project.phase getter implementado
☐ 6-7 detecciones de mock://

DATOS
☐ MockProjectData.guideRootNode existe
☐ MockProjectData.guideFileContents existe
☐ getMockProjectsData() retorna guía
☐ Contenido markdown válido

INTEGRACIÓN
☐ ProjectWorkspaceScreen importa projects_provider.dart
☐ ProjectWorkspaceScreen llama buildHybridProjectsList()
☐ FileTreeWidget detecta mock:// correctamente
☐ ProjectShellScreen lee contenido híbrido

FUNCIONALIDAD
☐ Dashboard muestra guía + proyectos
☐ Click en guía navega a project-shell
☐ Árbol de guía se muestra correctamente
☐ Contenido de guía se lee correctamente
☐ Proyecto real funciona como antes
☐ Performance: guía instantánea, real con I/O

UX
☐ Guía indistinguible de proyectos reales
☐ Interfaz unificada sin cambios
☐ Navegación fluida entre ambos tipos
```

---

## 9️⃣ Comandos Útiles de Debugging

### Ver errores de compilación
```bash
cd src/client && flutter analyze
```

### Buscar patrones específicos
```bash
# Buscar all buildHybridProjectsList
grep -rn "buildHybridProjectsList" src/client/

# Buscar all startsWith('mock://')
grep -rn "startsWith('mock://')" src/client/

# Buscar all GuideFileContents access
grep -rn "guideFileContents\[" src/client/
```

### Verificar estructura de directorios
```bash
tree src/client/lib/features/project_shell/ -L 3
```

### Hot reload
```bash
flutter run -v
# En el terminal, presionar 'r' para hot reload
# Presionar 'R' para hot restart
```

---

## 🔟 Preguntas de Validación

**P: ¿La guía se carga instantáneamente?**
R: Sí, está en memoria como const (0ms)

**P: ¿Puedo editar la guía?**
R: No, es de solo lectura por diseño (const)

**P: ¿Qué pasa si agrego un project real con ruta mock://?**
R: No se recomienda, pero el sistema lo manejaría como project real

**P: ¿El usuario puede borrar la guía?**
R: No, es virtual (mock://), no se puede delete

**P: ¿Performance impactado?**
R: Negligible (<1ms), solo detección de string

**P: ¿Escalable?**
R: Sí, agregar más guías es trivial (copiar/pegar en mock_data.dart)

---

## 📞 Soporte

Si encuentras problemas:

1. Execute `flutter analyze` para ver errores de compilación
2. Execute tests unitarios para verificar lógica
3. Revisar esta guía y el file HYBRID_SYSTEM_IMPLEMENTATION.md
4. Contactar al team de arquitectura
