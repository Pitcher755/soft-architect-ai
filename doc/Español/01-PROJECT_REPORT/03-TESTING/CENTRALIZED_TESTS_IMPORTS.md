# 📝 Imports en Pruebas Centralizados - Patrón Monorepo

> **Fecha:** 3 de febrero de 2026
> **Estado:** ✅ Implementado y Verificado

## 📖 Tabla de Contenidos

1. [El Problema](#el-problema)
2. [La Solución](#la-solución)
3. [Cómo Funciona](#cómo-funciona)
4. [Estructura de Paths](#estructura-de-paths)
5. [Ejemplos Prácticos](#ejemplos-prácticos)

---

## El Problema

Cuando los pruebas están **centralizados** en `/pruebas/` pero los sources están en `src/client/lib/`, hay un conflicto de contexto:

```
Ubicación del Test:
  tests/unit/flutter/domain/my_use_case_test.dart

Ubicación del Source:
  src/client/lib/features/project_shell/domain/use_cases/my_use_case.dart

Problema:
  ❌ El test NO está dentro del package Flutter
  ❌ Los imports `package:softarchitect_ai/...` no funcionan
```

---

## La Solución

**Usar Relative Imports** desde la ubicación del prueba:

```dart
// ✅ CORRECTO: Import relativo desde tests
import '../../../../src/client/lib/features/project_shell/domain/use_cases/my_use_case.dart';

// ❌ INCORRECTO: Package import (solo funciona dentro de src/client/)
import 'package:softarchitect_ai/features/project_shell/domain/use_cases/my_use_case.dart';
```

### Por Qué Funciona

1. **Relative Import:** `../../../../src/client/lib/...`
   - Resuelve desde la ubicación actual del archivo
   - Funciona desde cualquier lugar del archivosystem
   - No depende del contexto del package

2. **Package Import:** `package:softarchitect_ai/...`
   - Solo funciona dentro del scope del `pubspec.yaml`
   - Requiere que el analyzer esté dentro del package
   - Los pruebas centralizados están FUERA del package

---

## Cómo Funciona

### Resolución de Paths

Cuando Flutter ejecuta un prueba con un import relativo:

```dart
// tests/unit/flutter/domain/my_test.dart
import '../../../../src/client/lib/features/my_file.dart';
```

Flutter resuelve:
```
tests/unit/flutter/domain/              (ubicación del test)
  ↓ cd ../../../..                       (ir 4 niveles arriba)
tests/                                   (raíz)
  ↓
src/                                     (ahora descendemos)
  ↓
src/client/
  ↓
src/client/lib/features/my_file.dart    (¡ENCONTRADO!)
```

### Conteo de Niveles

Desde cualquier ubicación de prueba, el patrón es consistente:

| Ubicación del Prueba | Niveles Arriba | Path a `src/client/lib/` |
|---|---|---|
| `pruebas/unit/flutter/domain/` | 4 | `../../../../src/client/lib/` |
| `pruebas/unit/flutter/data/` | 4 | `../../../../src/client/lib/` |
| `pruebas/fixtures/` | 2 | `../../src/client/lib/` |
| `pruebas/mocks/` | 2 | `../../src/client/lib/` |

---

## Estructura de Paths

### Directorios en el Monorepo

```
soft-architect-ai/                              (raíz monorepo)
│
├── src/
│   ├── client/                                 (Flutter app)
│   │   ├── lib/                                (source code)
│   │   │   └── features/
│   │   │       └── project_shell/
│   │   │           ├── domain/                 ← Imports aquí
│   │   │           ├── data/
│   │   │           └── presentation/
│   │   └── pubspec.yaml                        (Flutter package)
│   │
│   └── server/                                 (Python FastAPI)
│
└── tests/                                      (TESTS CENTRALIZADOS)
    ├── unit/
    │   └── flutter/
    │       ├── domain/                         ← Tests aquí
    │       │   └── my_use_case_test.dart
    │       └── data/
    │
    └── fixtures/                               ← Fixtures aquí
        └── project_fixtures.dart
```

### Path Relativo desde Prueba

```dart
// tests/unit/flutter/domain/my_use_case_test.dart
//
// Necesito acceder a:
//   src/client/lib/features/project_shell/domain/use_cases/my_use_case.dart
//
// Cálculo:
//   Desde: tests/unit/flutter/domain/
//   Arriba: ../../../..  (4 niveles)
//   Luego:  src/client/lib/features/project_shell/domain/use_cases/

import '../../../../src/client/lib/features/project_shell/domain/use_cases/my_use_case.dart';
```

---

## Ejemplos Prácticos

### Domain Layer Pruebas

```dart
// tests/unit/flutter/domain/project_validation_use_case_test.dart
import 'package:flutter_test/flutter_test.dart';
import '../../../../src/client/lib/features/project_shell/domain/use_cases/project_validation_use_case.dart';

void main() {
  test('isValidName rejects short names', () {
    expect(ProjectValidationUseCase.isValidName('ab'), false);
  });
}
```

### Data Layer Pruebas

```dart
// tests/unit/flutter/data/sqlite_data_source_test.dart
import 'package:flutter_test/flutter_test.dart';
import '../../../../src/client/lib/features/project_shell/data/data_sources/sqlite_data_source.dart';
import '../../../../src/client/lib/features/project_shell/data/models/project_model.dart';

void main() {
  test('saveProject inserts record', () async {
    final ds = SQLiteDataSource(db);
    // ... test logic
  });
}
```

### Fixtures

```dart
// tests/fixtures/project_fixtures.dart
import '../../src/client/lib/features/project_shell/domain/entities/project.dart';
import '../../src/client/lib/features/project_shell/domain/entities/file_node.dart';

final testProject = Project(...);
```

---

## ✅ Archivos Actualizados

| Archivo | Imports Corregidos | Estado |
|---|---|---|
| `pruebas/unit/flutter/domain/proyecto_validation_use_case_prueba.dart` | ✅ | Ready |
| `pruebas/unit/flutter/domain/directory_tree_use_case_prueba.dart` | ✅ | Ready |
| `pruebas/unit/flutter/domain/archivo_search_use_case_prueba.dart` | ✅ | Ready |
| `pruebas/unit/flutter/data/sqlite_data_source_prueba.dart` | ✅ | Ready |
| `pruebas/unit/flutter/data/proyecto_repository_impl_prueba.dart` | ✅ | Ready |
| `pruebas/fixtures/proyecto_fixtures.dart` | ✅ | Ready |

---

## 🚀 Ejecución de Pruebas

### Con Imports Corregidos

```bash
# Desde la raíz del monorepo
./run_tests.sh flutter

# O manualmente desde src/client
cd src/client
flutter test ../../tests/unit/flutter/ --verbose
cd ../..
```

### Ventajas de Este Patrón

1. ✅ **Pruebas Centralizados:** Única fuente de verdad en `/pruebas`
2. ✅ **Relative Imports:** Funcionan desde cualquier ubicación
3. ✅ **Mantenible:** Paths claros y predecibles
4. ✅ **Escalable:** Nuevos pruebas siguen el mismo patrón
5. ✅ **Monorepo Compatible:** Patrón estándar de la industria

---

## 📚 Referencias

- [MONOREPO_TESTING_ARCHITECTURE.es.md](../02-SETUP_DEV/MONOREPO_TESTING_ARCHITECTURE.es.md)
- [MONOREPO_TESTING_ARCHITECTURE.en.md](../02-SETUP_DEV/MONOREPO_TESTING_ARCHITECTURE.en.md)
- [pruebas/README.md](../../pruebas/README.md)
