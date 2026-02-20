# 🔍 ANÁLISIS: proyectos_provider.dart vs proyecto_providers.dart

**Fecha:** 9 de febrero de 2026
**Análisis:** Consolidación de 2 archivos providers similares

---

## 🐛 ERRORES ENCONTRADOS EN proyectos_provider.dart

### Error 1: `The method 'map' isn't defined for the type 'Future'`
**Ubicación:** Línea 10
**Código problemático:**
```dart
final mockData = getMockProjectsData();
final mockProjects = mockData.map((m) => Project(...)).toList();
```

**Problema:** `getMockProyectosData()` ahora retorna `Future<List<Map>>` (es async)
pero el código trata `mockData` como `List<Map>` (síncrono).

**Causa raíz:** Inconsistencia en tipos de retorno.

### Error 2: `Unnecessary duplication of receiver`
**Ubicación:** Línea 19
**Código:**
```dart
final all = [...userProjects, ...mockProjects];
all.sort((a, b) { ... });
```

**Problema:** Lint warning sobre estilo (menor, no crítico).

---

## 📊 COMPARACIÓN DE ARCHIVOS

### 📄 proyectos_provider.dart
```dart
Responsabilidades:
├─ buildHybridProjectsList()      // Helper para combinar real + mock
├─ allProjectsProvider            // FutureProvider para reales
└─ hybridProjectsProvider         // FutureProvider para real + mock

Dependencias:
├─ projectRepositoryProvider      // Importa de project_providers.dart
├─ mock_projects_data.dart
└─ Project entity

Tipos de providers:
└─ FutureProvider (2 providers)
```

### 📄 proyecto_providers.dart
```dart
Responsabilidades:
├─ projectRepositoryProvider      // Provider para repository
└─ projectShellProvider           // StateNotifierProvider para UI state

Dependencias:
├─ WebMockProjectRepository
├─ ProjectRepository interface
└─ ProjectShellNotifier

Tipos de providers:
├─ Provider (1)
└─ StateNotifierProvider (1)
```

---

## 🎯 ANÁLISIS DE CONSOLIDACIÓN

### ¿Se pueden unificar? ✅ **SÍ - Recomendado**

**Razones:**
1. **Mismo contexto:** Ambos manejan "proyectos"
2. **Misma carpeta:** `presentation/providers/`
3. **Relacionados:** `proyectos_provider.dart` depende de `proyecto_providers.dart`
4. **Nombres confusos:** `proyectos` vs `proyecto` casi idénticos
5. **Pocas líneas totales:** 60 líneas combinadas (perfectamente manejable)

### ¿Qué consolidar?

| Item | Acción |
|------|--------|
| `proyectoRepositoryProvider` | Mantener (core) |
| `proyectoShellProvider` | Mantener (core) |
| `buildHybridProyectosList()` | Mover a nuevo archivo |
| `allProyectosProvider` | Mover a nuevo archivo |
| `hybridProyectosProvider` | Mover a nuevo archivo |

---

## ✅ SOLUCIÓN PROPUESTA

### Opción A: "Unificar TODO en un archivo" ⭐ RECOMENDADO
**Archivo único:** `proyecto_providers.dart` (renombrado)
**Contenido:**
```
1. projectRepositoryProvider      [core - repository access]
2. projectShellProvider           [core - shell state]
3. buildHybridProjectsList()      [helper - combine real+mock]
4. allProjectsProvider            [data - real projects]
5. hybridProjectsProvider         [data - real + mock projects]
```

**Ventajas:**
- ✅ Una única fuente de verdad
- ✅ Sin imports circulares
- ✅ Claridad de propósito
- ✅ Mejor mantenibilidad

**Desventajas:**
- ⚠️ Archivo más largo (pero legible)

---

### Opción B: "Separar por propósito" (Alternativa)
**Archivos:**
1. `proyecto_repository_providers.dart` - Para repository/shell
2. `proyecto_list_providers.dart` - Para list/hybrid

**Ventajas:**
- ✅ Separación clara de propósitos

**Desventajas:**
- ❌ Más duplicación de código
- ❌ Más imports a mantener

---

## 🔧 IMPLEMENTACIÓN DE SOLUCIÓN (Opción A)

### Paso 1: Consolidar en `proyecto_providers.dart`

**Archivo único con TODO:**

```dart
// lib/features/project_shell/presentation/providers/project_providers.dart

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/mock_projects_data.dart';
import '../../data/repositories/web_mock_project_repository.dart';
import '../../domain/entities/project.dart';
import '../../domain/repositories/project_repository.dart';
import '../notifiers/project_shell_notifier.dart';

// ╔════════════════════════════════════════════════╗
// ║           CORE PROVIDERS                        ║
// ╚════════════════════════════════════════════════╝

/// Repository provider with platform-specific implementation
///
/// On web: Uses in-memory mock repository
/// On desktop/mobile: Uses database-backed repository
final projectRepositoryProvider = Provider<ProjectRepository>((ref) {
  if (kIsWeb) {
    debugPrint('📦 Using WebMockProjectRepository (web platform)');
    return WebMockProjectRepository();
  } else {
    debugPrint('📦 Using WebMockProjectRepository (fallback)');
    return WebMockProjectRepository();
  }
});

/// Main state notifier provider for project shell
final projectShellProvider =
    StateNotifierProvider<ProjectShellNotifier, ProjectShellState>((ref) {
      final repository = ref.watch(projectRepositoryProvider);
      return ProjectShellNotifier(repository);
    });

// ╔════════════════════════════════════════════════╗
// ║           HYBRID PROJECTS SYSTEM               ║
// ╚════════════════════════════════════════════════╝

/// Helper function to combine real and mock projects
List<Project> buildHybridProjectsList(List<Project> userProjects) {
  final mockData = getMockProjectsData(); // NOW SYNC (after fix)
  final mockProjects = mockData.map((m) => Project(
      id: m['id'] as String,
      name: m['name'] as String,
      path: m['path'] as String,
      createdAt: DateTime.parse(m['modified'] as String),
      lastOpened: DateTime.parse(m['modified'] as String),
    )).toList();

  final all = <Project>[...userProjects, ...mockProjects];
  all.sort((a, b) {
    final aTime = a.lastOpened ?? a.createdAt;
    final bTime = b.lastOpened ?? b.createdAt;
    return bTime.compareTo(aTime);
  });
  return all;
}

/// Provider for getting all real projects from repository
final allProjectsProvider = FutureProvider<List<Project>>((ref) async {
  final repository = ref.watch(projectRepositoryProvider);
  return repository.getAllProjects();
});

/// Provider for getting hybrid projects (real + mock combined)
final hybridProjectsProvider = FutureProvider<List<Project>>((ref) async {
  final realProjects = await ref.watch(allProjectsProvider.future);
  return buildHybridProjectsList(realProjects);
});
```

### Paso 2: Eliminar `proyectos_provider.dart`

**Acción:** Borrar el archivo antiguo (después de migrar imports)

### Paso 3: Actualizar imports

**Archivos que importan de `proyectos_provider.dart`:**
```bash
grep -r "from.*projects_provider" src/client/lib/
```

Cambiar:
```dart
// ❌ ANTES
import '../providers/projects_provider.dart';

// ✅ AHORA
import '../providers/project_providers.dart';
```

---

## 🔧 CORREGIR ERROR: getMockProyectosData()

**Problema:** `getMockProyectosData()` es `Future` pero se usa como síncrono.

**Solución:** En `mock_proyectos_data.dart`, hacer la función **síncrona**:

```dart
// ❌ ANTES (async)
Future<List<Map<String, dynamic>>> getMockProjectsData() async { ... }

// ✅ DESPUÉS (sync - cargar datos en memoria)
List<Map<String, dynamic>> getMockProjectsData() {
  // Solo retorna datos en memoria, no I/O
  return [
    {
      'id': 'softarchitect-guide',
      'name': 'Guía SoftArchitect',
      'icon': Icons.menu_book_rounded,
      // ...
    },
  ];
}

// SI NECESITAS ASYNC:
Future<List<Map<String, dynamic>>> getMockProjectsDataAsync() async {
  // Aquí sí puedo tener async operations
}
```

---

## 📋 PLAN DE IMPLEMENTACIÓN

### Step 1: Crear unified `proyecto_providers.dart`
- [ ] Consolidar `proyecto_providers.dart` + `proyectos_provider.dart`
- [ ] Un único archivo con TODO

### Step 2: Corregir `getMockProyectosData()`
- [ ] Hacer síncrona (si es solo data en memoria)
- [ ] O crear `getMockProyectosDataAsync()` separada

### Step 3: Migrar imports
- [ ] Buscar usos de `proyectos_provider.dart`
- [ ] Cambiar a `proyecto_providers.dart`

### Step 4: Eliminar archivo viejo
- [ ] Borrar `proyectos_provider.dart`
- [ ] Verificar compilación

### Step 5: Validar
- [ ] `flutter analyze` → 0 errors
- [ ] `flutter ejecutar` → sin problemas

---

## 📊 RESUMEN CAMBIOS

| Cambio | Impacto | Complejidad |
|--------|---------|-------------|
| Unificar providers | ✅ Limpia estructura | 🟢 Baja |
| Corregir `Future` error | ✅ Resuelve error | 🟢 Baja |
| Migrar imports | ✅ Documentoable | 🟠 Media |
| Eliminar archivo viejo | ✅ Organiza | 🟢 Baja |

---

## ✅ ESTADO FINAL

```
Antes:
├── projects_provider.dart      (40 líneas)
└── project_providers.dart      (30 líneas)
                                 ↓
                         2 archivos relacionados
                         Imports circulares potenciales

Después:
└── project_providers.dart      (70 líneas)
                                 ↓
                         1 archivo unificado
                         Estructura clara y mantenible
                         0 imports circulares
```

---

## 🎯 RECOMENDACIÓN FINAL

**✅ IMPLEMENTAR OPCIÓN A (Unificación)**

Razones:
1. Ambos archivos están fuertemente relacionados
2. Solo 70 líneas totales (perfectamente legible)
3. Elimina confusión de nombres (`proyectos` vs `proyecto`)
4. Resuelve dependencies circulares
5. Mejora mantenibilidad
