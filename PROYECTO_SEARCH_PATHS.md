# 🗂️ Rutas de Búsqueda - Proyectos Reales

**Archivo:** `mock_projects_data.dart`
**Función:** `_loadRealProjects()`

---

## 📍 Rutas Donde Busca Proyectos

El sistema busca proyectos en estas rutas (en orden):

```dart
final commonPaths = [
  '${Directory.current.path}/projects',      // 1. ./projects (relativa)
  p.join(homeDir, 'SoftArchitect'),         // 2. ~/SoftArchitect
  p.join(homeDir, 'Proyectos'),             // 3. ~/Proyectos
];
```

### Explicación de cada ruta

| # | Ruta | Ejemplo | Comportamiento |
|---|------|---------|-----------------|
| 1 | `./projects` | `/home/user/Espacio-de-trabajo/projects` | Relativa a app |
| 2 | `~/SoftArchitect` | `/home/user/SoftArchitect` | Home directory |
| 3 | `~/Proyectos` | `/home/user/Proyectos` | Home directory (Spanish) |

---

## 📂 Estructura Esperada

El sistema busca **CARPETAS** dentro de estas rutas:

```
~/projects/
├── Mi Proyecto 1/          ← Se carga como proyecto
│   ├── README.md
│   ├── src/
│   └── ...
├── Mi Proyecto 2/          ← Se carga como proyecto
│   ├── config.yaml
│   └── ...
└── archivo.txt            ← NO se carga (no es carpeta)

~/SoftArchitect/
├── Proyecto A/             ← Se carga
└── Proyecto B/             ← Se carga

~/Proyectos/
├── My App/                 ← Se carga
└── ...
```

---

## ✅ Cómo Crear Proyectos para Testing

### Opción 1: Crear carpeta en `./projects`

```bash
# En raíz del app
mkdir -p projects/Test-Project-1
mkdir -p projects/Test-Project-2
mkdir -p projects/Test-Project-3

# Resultado: 3 proyectos aparecen en dashboard
```

### Opción 2: Crear en `~/SoftArchitect`

```bash
mkdir -p ~/SoftArchitect/My-Project
mkdir -p ~/SoftArchitect/Another-Project

# Resultado: Esos 2 proyectos + otros que estén en ./projects
```

### Opción 3: Usar CreateProjectDialog (Recomendado)

```
1. En dashboard, click [+ Nuevo Proyecto]
2. Nombre: "Test Project"
3. Ruta: /home/user/Proyectos (o /home/user/projects)
4. Click "Crear Proyecto"

# Sistema crea carpeta y la detecta automáticamente
```

---

## 🔧 Personalizar Rutas de Búsqueda

Si necesitas cambiar dónde busca:

### Opción A: Agregar más rutas

```dart
// En mock_projects_data.dart, función _loadRealProjects()
Future<List<Map<String, dynamic>>> _loadRealProjects() async {
  final projects = <Map<String, dynamic>>[];
  final commonPaths = [
    // Rutas por defecto
    p.join(Directory.current.path, 'projects'),
    p.join(Directory.current.path, 'SoftArchitect'),
    p.join(Directory.current.path, 'Proyectos'),

    // ✅ AGREGAR MÁS AQUÍ:
    '/opt/myprojects',                          // Ruta absoluta Linux
    '/Users/user/Development/projects',         // macOS
    'D:\\Users\\user\\Projects',               // Windows
    p.join(homeDir, 'Documents', 'Projects'),  // Documentos/Projects
  ];

  // ... resto del código
}
```

### Opción B: Solo buscar en UNA ruta

```dart
// Cambiar para buscar solo en ~/SoftArchitect:
Future<List<Map<String, dynamic>>> _loadRealProjects() async {
  final projects = <Map<String, dynamic>>[];
  final commonPaths = [
    p.join(Directory.current.path, 'SoftArchitect'),  // Solo esta
  ];

  // ... resto del código
}
```

### Opción C: Usar variable de ambiente

```dart
Future<List<Map<String, dynamic>>> _loadRealProjects() async {
  final projects = <Map<String, dynamic>>[];

  // Leer ruta de variable de ambiente
  final customPath = Platform.environment['SOFTARCH_PROJECTS_PATH'];

  final commonPaths = [
    if (customPath != null) customPath,  // Si existe, usar primero
    p.join(Directory.current.path, 'projects'),
    p.join(Directory.current.path, 'SoftArchitect'),
  ];

  // ... resto del código
}
```

**Uso:**
```bash
export SOFTARCH_PROJECTS_PATH="/home/user/my/custom/path"
flutter run
```

---

## 🚨 Troubleshooting

### "No aparecen proyectos en el grid"

**Checklist:**
```
☐ ¿Existen carpetas en ./projects/ ?
☐ ¿Existen carpetas en ~/SoftArchitect/ ?
☐ ¿Existen carpetas en ~/Proyectos/ ?

☐ Si creé con CreateProjectDialog, ¿dónde especifiqué la ruta?
☐ ¿Esa ruta está en el listado de commonPaths?

☐ Revisar logs (debug console) para mensajes:
   "✅ Loaded X real projects"
   "⚠️ Error loading projects from /path"
```

### "Aparecen menos proyectos de los esperados"

**Causas posibles:**
- La carpeta no está en las rutas de búsqueda
- Es un archivo, no una carpeta
- Problemas de permisos (no puede leer)

**Solución:**
```dart
// Agregar debug logging en _loadRealProjects()
debugPrint('🔍 Searching in: $pathStr');
debugPrint('✅ Found: ${entities.length} entities');

// Ver qué encuentra
entities.forEach((e) {
  debugPrint('  - ${p.basename(e.path)} (${e is Directory ? 'DIR' : 'FILE'})');
});
```

---

## 📋 Rutas por Sistema Operativo

### Linux
```
./projects                 ← Relativa a app
~/SoftArchitect           → /home/user/SoftArchitect
~/Proyectos               → /home/user/Proyectos
```

### macOS
```
./projects                → /Users/user/app/projects
~/SoftArchitect          → /Users/user/SoftArchitect
~/Proyectos              → /Users/user/Proyectos
```

### Windows
```
./projects               → C:\Users\user\app\projects
~/SoftArchitect         → C:\Users\user\SoftArchitect
~/Proyectos             → C:\Users\user\Proyectos
```

---

## 🎯 Recomendación

**Para desarrollo:** Usa `./projects` (relativa)
```bash
mkdir -p projects/Test1
mkdir -p projects/Test2
flutter run
# Automáticamente aparecen en dashboard
```

**Para producción:** Usa `~/SoftArchitect` o variable de ambiente
```bash
# Usuario final crea: ~/SoftArchitect/MiProyecto
# App lo detecta automáticamente
```

**Para testing:** Usa CreateProjectDialog
```
1. Click [+ Nuevo Proyecto]
2. Rellena datos
3. Click "Crear"
4. Proyecto aparece inmediato en dashboard
```
