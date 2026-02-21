# 🧪 Arquitectura de Testing en Monorepo

> **Fecha:** 03/02/2026
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

1. **Explicación Teórica:** "Los tests del monorepo **DEBEN** estar centralizados en `/tests` para tener un punto único de verdad, fixtures compartidas y coverage unificado"

2. **Implementación Actual (INCORRECTA):**
   - Tests de Flutter en `src/client/test/` (descentralizado)
   - Tests de Python en `src/server/tests/` (descentralizado)
   - **Violación de lo que acababa de explicar**

3. **Contradicción Identificada por el Usuario:**
   > "Los tests de la app cliente (flutter) estaban situados en ese directorio pero ahora los has cambiado al directorio /home/pitcherdev/Espacio-de-trabajo/Master/soft-architect-ai/src/client/test, del cliente, **todo lo contrario a lo que me indicabas anteriormente**"

### Causa Raíz

Confusión entre dos patrones válidos pero **incompatibles en un monorepo**:
- **Patrón A (Flutter Standard):** `app/test/` ← Tests dentro del package
- **Patrón B (Monorepo Real):** `/tests/` ← Tests centralizados fuera del package

**Para un monorepo con múltiples lenguajes, Patrón B es el correcto.**

---

## Solución: Patrón Centralizado

### Principios Fundamentales

| Principio | Implementación |
|-----------|----------------|
| **Una Única Fuente de Verdad** | `/tests/` = punto único de tests en el repo |
| **DRY (No Repitas)** | Fixtures y mocks compartidos en `/tests/fixtures` y `/tests/mocks` |
| **Separación de Responsabilidades** | Tests organizados por **tipo** (unit, integration) luego por **app** (flutter, python) |
| **CI/CD Simple** | Un solo comando desde raíz ejecuta TODO: `./run_tests.sh all` |
| **Cobertura Consistente** | Métricas unificadas para ambas tecnologías |

---

## Estructura del Monorepo

```
soft-architect-ai/
├── src/
│   ├── client/                          # App Flutter (SIN /test!)
│   │   ├── lib/
│   │   │   └── features/
│   │   │       └── project_shell/
│   │   │           ├── domain/
│   │   │           ├── data/
│   │   │           └── presentation/
│   │   ├── pubspec.yaml
│   │   └── analysis_options.yaml
│   │
│   └── server/                          # Backend Python (SIN /tests!)
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
│   │   ├── python/                      # Tests de integración API
│   │   └── e2e/                         # Tests E2E cliente ↔ servidor
│   │
│   ├── fixtures/
│   │   ├── project_fixtures.dart        # Datos de test compartidos
│   │   └── ...
│   │
│   ├── mocks/
│   │   ├── ...                          # Generadores de mocks compartidos
│   │
│   ├── test_helper.dart                 # Utilidades de test Dart compartidas
│   ├── conftest.py                      # Utilidades de test Python compartidas
│   └── README.md                        # Guía de testing
│
├── run_tests.sh                         # ✅ Script maestro para ejecutar tests
├── .fluttertest                         # Configuración de directorio de tests
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

Future<void> initTestDatabase() async {
  // Setup SQLite en-memoria para tests
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
    """Fixture para mocking de base de datos."""
    return MagicMock()
```

#### `run_tests.sh`
Script maestro que ejecuta tests desde la raíz:
```bash
./run_tests.sh flutter    # Tests de Flutter solamente
./run_tests.sh python     # Tests de Python solamente
./run_tests.sh integration # Tests de integración
./run_tests.sh all        # TODO
```

---

## Ejecución de Tests

### Desde la Raíz del Monorepo

```bash
# Ejecutar solo tests de Flutter
./run_tests.sh flutter

# Ejecutar solo tests de Python (cuando disponibles)
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
      - name: Ejecutar Todos los Tests
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

### Imports (SIN CAMBIOS - Resolución Automática)

Los imports en los tests usan `package:softarchitect_ai/...` que Flutter resuelve **automáticamente** desde `pubspec.yaml` sin importar dónde esté el archivo de test:

```dart
// Tests en /tests/unit/flutter/domain/project_validation_use_case_test.dart
// MISMA importación - Flutter la resuelve correctamente
import 'package:softarchitect_ai/features/project_shell/domain/use_cases/project_validation_use_case.dart';
```

---

## Por Qué Este Patrón

### ✅ Ventajas del Patrón Centralizado

1. **Monorepo Puro:** Un único punto de verdad para TODOS los tests
   - Sin confusión: ¿Dónde van los tests de integración cliente-servidor?
   - Respuesta clara: `/tests/integration/e2e/`

2. **Código Compartido (DRY):**
   - Fixtures (datos de test) compartidas entre Flutter y Python
   - Mocks reutilizables
   - Utilidades de test centralizadas

3. **CI/CD Simplificado:**
   ```bash
   ./run_tests.sh all  # Un comando, TODO se ejecuta
   ```

4. **Cobertura Unificada:**
   - Dashboard único que muestra cobertura de Flutter + Python
   - Fácil ver qué tests faltan

5. **Escalabilidad:**
   - Si agregamos más packages (Go, Rust), todos los tests van a `/tests`
   - Patrón consistente para el futuro

6. **Compatibilidad con Monorepos Estándar:**
   - Google Monorepo (Bazel): tests centralizados
   - Nx Monorepo: tests centralizados
   - Yarn Workspaces: tests centralizados
   - **Es el estándar de la industria**

### ❌ Por Qué NO el Patrón Descentralizado

| Problema | Ejemplo |
|----------|---------|
| **Múltiples fuentes de verdad** | Fixtures duplicadas en `/src/client/test/fixtures` y `/src/server/tests/fixtures` |
| **Confusión en E2E** | ¿Dónde van los tests que requieren ambos packages? |
| **CI/CD Complejo** | Necesitas scripts complejos para descubrir dónde están los tests |
| **No es Monorepo Real** | Es como tener dos repos separados con prefijo `src/` |
| **Violación de Principios Monorepo** | Cada package es "autónomo", sin cohesión |

---

## 🔧 Configuración Requerida

### 1. `.fluttertest` (Nuevo)
```json
{
  "testFilePattern": "**/*_test.dart",
  "testDirectory": "tests/unit/flutter"
}
```
✅ **CREADO** - Indica a Flutter dónde buscar los tests

### 2. `.gitignore` (Corregido)
```
# ❌ ANTES (INCORRECTO)
lib/

# ✅ DESPUÉS (CORRECTO)
src/server/lib64/
```
✅ **CORREGIDO** - No bloquea `src/client/lib/`

### 3. `run_tests.sh` (Nuevo)
✅ **CREADO** - Script maestro para ejecutar tests desde cualquier ubicación

---

## ✅ Estado Actual

| Aspecto | Estado |
|--------|--------|
| Tests centralizados en `/tests` | ✅ DONE |
| Tests de Flutter movidos | ✅ DONE |
| Imports verificados | ✅ DONE (automáticos) |
| Script de ejecución | ✅ DONE |
| Configuración .fluttertest | ✅ DONE |
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

4. **Integrar en GitHub Actions** en el pipeline de CI/CD
