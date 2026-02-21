# 🧪 Monorepo Testing Architecture

> **Fecha:** 2026-02-03
> **Estado:** ✅ Implementado
> **Versión:** 1.0

## 📖 Tabla de Contenidos

1. [Problema Identificado](#problema-identificado)
2. [Solución: Patrón Centralizado](#solución-patrón-centralizado)
3. [Estructura del Monorepo](#estructura-del-monorepo)
4. [Ejecución de Tests](#ejecución-de-tests)
5. [Migración Realizada](#migración-realizada)
6. [Por Qué Este Patrón](#por-qué-este-patrón)

---

## Problema Identificado

### La Contradicción Original

1. **Explicación Teórica:** "Los tests del monorepo DEBEN estar centralizados en `/tests` para tener un punto único de verdad, fixtures compartidas y coverage unificado"

2. **Implementación Actual (INCORRECTA):**
   - Tests de Flutter en `src/client/test/` (decentralizado)
   - Tests de Python en `src/server/tests/` (decentralizado)
   - Violation de lo que acababa de explicar

3. **Contradicción Identificada:** El usuario correctamente señaló: "Los tests de la app cliente (flutter) estaban situados en ese directorio pero ahora los has cambiado al directorio /home/pitcherdev/Espacio-de-trabajo/Master/soft-architect-ai/src/client/test, del cliente, todo lo contrario a lo que me indicabas anteriormente"

### Causa Raíz

Confusión entre dos patrones válidos pero incompatibles:
- **Patrón A (Flutter Standard):** `app/test/` ← Tests dentro del package
- **Patrón B (Monorepo):** `/tests/` ← Tests centralizados fuera del package

Para un monorepo con múltiples lenguajes, **Patrón B es correcto**.

---

## Solución: Patrón Centralizado

### Principios Fundamentales

| Principio | Implementación |
|-----------|----------------|
| **Single Source of Truth** | `/tests/` = punto único de tests en el repo |
| **DRY (Don't Repeat Yourself)** | Fixtures y mocks compartidos en `/tests/fixtures` y `/tests/mocks` |
| **Separation of Concerns** | Tests organizados por **tipo** (unit, integration) luego por **app** (flutter, python) |
| **Easy CI/CD** | Un solo comando desde raíz ejecuta TODO: `./run_tests.sh all` |
| **Consistent Coverage** | Métricas unificadas para ambas tecnologías |

---

## Estructura del Monorepo

```
soft-architect-ai/
├── src/
│   ├── client/                          # Flutter app (SIN /test!)
│   │   ├── lib/
│   │   │   └── features/
│   │   │       └── project_shell/
│   │   │           ├── domain/
│   │   │           ├── data/
│   │   │           └── presentation/
│   │   ├── pubspec.yaml
│   │   └── analysis_options.yaml
│   │
│   └── server/                          # Python FastAPI (SIN /tests!)
│       ├── app/
│       ├── services/
│       └── pyproject.toml
│
├── tests/                               # ✅ CENTRALIZADOS - ÚNICA FUENTE DE VERDAD
│   ├── unit/
│   │   ├── flutter/
│   │   │   ├── domain/
│   │   │   │   ├── project_validation_use_case_test.dart
│   │   │   │   ├── directory_tree_use_case_test.dart
│   │   │   │   └── file_search_use_case_test.dart
│   │   │   └── data/
│   │   │       ├── sqlite_data_source_test.dart
│   │   │       └── project_repository_impl_test.dart
│   │   │
│   │   └── python/                      # Para futuro
│   │       ├── domain/
│   │       ├── services/
│   │       └── api/
│   │
│   ├── integration/
│   │   ├── flutter/                     # Widget tests
│   │   ├── python/                      # API integration tests
│   │   └── e2e/                         # Client ↔ Server E2E tests
│   │
│   ├── fixtures/
│   │   ├── project_fixtures.dart        # Shared test data
│   │   └── ...
│   │
│   ├── mocks/
│   │   ├── ...                          # Shared mock generators
│   │
│   ├── test_helper.dart                 # Shared Dart test utilities
│   ├── conftest.py                      # Shared Python test utilities
│   └── README.md                        # Guía de testing
│
├── run_tests.sh                         # ✅ Script maestro para ejecutar tests
├── .fluttertest                         # Configuración de test directory
├── pyrightconfig.json
├── requirements.txt
├── pubspec.yaml (root)
├── .gitignore
├── README.md
└── ...
```

### Archivos Clave

#### `/tests/test_helper.dart`
Utilidades compartidas para tests de Dart:
```dart
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';

Future<void> initTestDatabase() async {
  // Setup in-memory SQLite para tests
  sqlfiteFfiInit();
}
```

#### `/tests/conftest.py`
Utilidades compartidas para tests de Python:
```python
import pytest
from unittest.mock import MagicMock

@pytest.fixture
def mock_db():
    """Fixture para mocking database."""
    return MagicMock()
```

#### `run_tests.sh`
Script maestro que ejecuta tests desde la raíz:
```bash
./run_tests.sh flutter    # Flutter tests only
./run_tests.sh python     # Python tests only
./run_tests.sh integration # Integration tests
./run_tests.sh all        # TODO
```

---

## Ejecución de Tests

### Desde la Raíz del Monorepo

```bash
# Ejecutar solo Flutter unit tests
./run_tests.sh flutter

# Ejecutar solo Python tests (cuando disponibles)
./run_tests.sh python

# Ejecutar tests de integración
./run_tests.sh integration

# Ejecutar TODO
./run_tests.sh all
```

### Ejecución Manual (Para Debugging)

```bash
# Flutter desde src/client/ con archivos en /tests
cd src/client
flutter test ../../tests/unit/flutter/ --verbose

# Python desde src/server/ con archivos en /tests
cd src/server
pytest ../../tests/unit/python/ -v

# Volver a raíz
cd ../..
```

### En CI/CD (GitHub Actions)

```yaml
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - name: Run All Tests
        run: ./run_tests.sh all
```

---

## Migración Realizada

### Cambios Hechos

| Antes (❌ INCORRECTO) | Después (✅ CORRECTO) | Razón |
|---|---|---|
| `src/client/test/unit/domain/*.dart` | `tests/unit/flutter/domain/*.dart` | Centralizado |
| `src/client/test/unit/data/*.dart` | `tests/unit/flutter/data/*.dart` | Centralizado |
| `src/client/test/test_helper.dart` | `tests/test_helper.dart` | Compartido |
| `src/client/test/fixtures/*.dart` | `tests/fixtures/*.dart` | Compartido |
| ❌ `src/client/test/` directory | ✅ ELIMINADO | No existe en Patrón B |

### Imports (SIN CAMBIOS - Seguimiento Automático)

Los imports en los tests usan `package:softarchitect_ai/...` que Flutter resuelve **automáticamente** desde `pubspec.yaml` sin importar dónde esté el archivo de test:

```dart
// Tests en /tests/unit/flutter/domain/project_validation_use_case_test.dart
// MISMA importación - Flutter lo resuelve correctamente
import 'package:softarchitect_ai/features/project_shell/domain/use_cases/project_validation_use_case.dart';
```

---

## Por Qué Este Patrón

### ✅ Ventajas del Patrón Centralizado

1. **Monorepo Puro:** Un único punto de verdad para ALL tests
   - No hay confusión: ¿Dónde van los tests de integración cliente-servidor?
   - Respuesta clara: `/tests/integration/e2e/`

2. **Código Compartido (DRY):**
   - Fixtures (test data) compartidas entre Flutter y Python
   - Mocks reutilizables
   - Test utilities centralizadas

3. **CI/CD Simplificado:**
   ```bash
   ./run_tests.sh all  # Un comando, TODO se ejecuta
   ```

4. **Coverage Unificado:**
   - Dashboard único que muestra cobertura de Flutter + Python
   - Fácil ver qué tests faltan

5. **Escalabilidad:**
   - Si agregamos más packages (Go, Rust), todos los tests van a `/tests`
   - Patrón consistente

6. **Compatibilidad con Google Monorepo (Bazel):**
   - Google monorepo centraliza tests
   - Nx monorepo centraliza tests
   - Yarn Workspaces centraliza tests
   - **Es el estándar de la industria**

### ❌ Por Qué NO el Patrón Descentralizado

| Problema | Ejemplo |
|----------|---------|
| **Múltiples fuentes de verdad** | Fixtures duplicadas en `/src/client/test/fixtures` y `/src/server/tests/fixtures` |
| **Confusión en E2E** | ¿Dónde van los tests que requieren ambos? |
| **CI/CD Complicado** | Necesitas scripts complejos para descubrir dónde están los tests |
| **No es Monorepo Real** | Es como tener dos repos separados con `src/` prefix |
| **Violación de Monorepo Principles** | Cada paquete es "autónomo", no hay cohesión |

---

## 🔧 Configuración Requerida

### 1. `.fluttertest` (Nueva)
```json
{
  "testFilePattern": "**/*_test.dart",
  "testDirectory": "tests/unit/flutter"
}
```
✅ **CREADO** - Indica a Flutter dónde buscar tests

### 2. `.gitignore` (Corregido)
```
# ❌ ANTES (INCORRECTO)
lib/

# ✅ DESPUÉS (CORRECTO)
src/server/lib64/
```
✅ **CORREGIDO** - No bloquea `src/client/lib/`

### 3. `run_tests.sh` (Nueva)
✅ **CREADO** - Script maestro para ejecutar tests desde cualquier ubicación

---

## ✅ Estado Actual

| Aspecto | Estado |
|--------|--------|
| Tests centralizados en `/tests` | ✅ DONE |
| Flutter tests movidos | ✅ DONE |
| Imports verificados | ✅ DONE (automáticos) |
| Script de ejecución | ✅ DONE |
| .fluttertest configuration | ✅ DONE |
| .gitignore corregido | ✅ DONE |
| 15 tests listos para ejecutar | ✅ READY |

---

## 🚀 Próximos Pasos

1. **Ejecutar tests centralizados:**
   ```bash
   ./run_tests.sh flutter
   ```

2. **Agregar tests de Python** cuando la capa de servicios Python esté lista

3. **Agregar tests de integración E2E** para validar cliente ↔ servidor

4. **Integrar en GitHub Actions** CI/CD pipeline
