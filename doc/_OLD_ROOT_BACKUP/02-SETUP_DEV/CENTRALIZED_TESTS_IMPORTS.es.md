# 📝 Imports en Tests Centralizados - Patrón Monorepo

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

Cuando los tests están **centralizados** en `/tests/` pero los sources están en `src/client/lib/`, hay un conflicto de contexto:

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

**Usar Relative Imports** desde la ubicación del test:

```dart
// ✅ CORRECTO: Import relativo desde tests
import '../../../../src/client/lib/features/project_shell/domain/use_cases/my_use_case.dart';

// ❌ INCORRECTO: Package import (solo funciona dentro de src/client/)
import 'package:softarchitect_ai/features/project_shell/domain/use_cases/my_use_case.dart';
```

### Por Qué Funciona

1. **Relative Import:** `../../../../src/client/lib/...`
   - Resuelve desde la ubicación actual del archivo
   - Funciona desde cualquier lugar del filesystem
   - No depende del contexto del package

2. **Package Import:** `package:softarchitect_ai/...`
   - Solo funciona dentro del scope del `pubspec.yaml`
   - Requiere que el analyzer esté dentro del package
   - Los tests centralizados están FUERA del package

---

## Cómo Funciona

### Resolución de Paths

Cuando Flutter ejecuta un test con un import relativo:

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

Desde cualquier ubicación de test, el patrón es consistente:

| Ubicación del Test | Niveles Arriba | Path a `src/client/lib/` |
|---|---|---|
| `tests/unit/flutter/domain/` | 4 | `../../../../src/client/lib/` |
| `tests/unit/flutter/data/` | 4 | `../../../../src/client/lib/` |
| `tests/fixtures/` | 2 | `../../src/client/lib/` |
| `tests/mocks/` | 2 | `../../src/client/lib/` |

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

### Path Relativo desde Test

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

### Domain Layer Tests

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

### Data Layer Tests

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

| Archivo | Imports Corregidos | Status |
|---|---|---|
| `tests/unit/flutter/domain/project_validation_use_case_test.dart` | ✅ | Ready |
| `tests/unit/flutter/domain/directory_tree_use_case_test.dart` | ✅ | Ready |
| `tests/unit/flutter/domain/file_search_use_case_test.dart` | ✅ | Ready |
| `tests/unit/flutter/data/sqlite_data_source_test.dart` | ✅ | Ready |
| `tests/unit/flutter/data/project_repository_impl_test.dart` | ✅ | Ready |
| `tests/fixtures/project_fixtures.dart` | ✅ | Ready |

---

## 🚀 Ejecución de Tests

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

1. ✅ **Tests Centralizados:** Única fuente de verdad en `/tests`
2. ✅ **Relative Imports:** Funcionan desde cualquier ubicación
3. ✅ **Mantenible:** Paths claros y predecibles
4. ✅ **Escalable:** Nuevos tests siguen el mismo patrón
5. ✅ **Monorepo Compatible:** Patrón estándar de la industria

---

## 📚 Referencias

- [MONOREPO_TESTING_ARCHITECTURE.es.md](../02-SETUP_DEV/MONOREPO_TESTING_ARCHITECTURE.es.md)
- [MONOREPO_TESTING_ARCHITECTURE.en.md](../02-SETUP_DEV/MONOREPO_TESTING_ARCHITECTURE.en.md)
- [tests/README.md](../../tests/README.md)
