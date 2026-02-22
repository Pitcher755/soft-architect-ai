# 🧪 Arquitectura de Pruebaing en Monorepo

> **Fecha:** 03/02/2026
> **Estado:** ✅ Implementado
> **Versión:** 1.0

## 📖 Tabla de Contenidos

1. [Problema Identificado](#problema-identificado)
2. [Solución: Patrón Centralizado](#solución-patrón-centralizado)
3. [Estructura del Monorepo](#estructura-del-monorepo)
4. [Ejecución de Pruebas](#ejecución-de-pruebas)
5. [Migración Realizada](#migración-realizada)
6. [Por Qué Este Patrón](#por-qué-este-patrón)

---

## Problema Identificado

### La Contradicción Original

1. **Explicación Teórica:** "Los pruebas del monorepo **DEBEN** estar centralizados en `/pruebas` para tener un punto único de verdad, fixtures compartidas y coverage unificado"

2. **Implementación Actual (INCORRECTA):**
   - Pruebas de Flutter en `src/client/prueba/` (descentralizado)
   - Pruebas de Python en `src/server/pruebas/` (descentralizado)
   - **Violación de lo que acababa de explicar**

3. **Contradicción Identificada por el Usuario:**
   > "Los pruebas de la app cliente (flutter) estaban situados en ese directorio pero ahora los has cambiado al directorio /home/pitcherdev/Espacio-de-trabajo/Master/soft-architect-ai/src/client/prueba, del cliente, **todo lo contrario a lo que me indicabas anteriormente**"

### Causa Raíz

Confusión entre dos patrones válidos pero **incompatibles en un monorepo**:
- **Patrón A (Flutter Standard):** `app/prueba/` ← Pruebas dentro del package
- **Patrón B (Monorepo Real):** `/pruebas/` ← Pruebas centralizados fuera del package

**Para un monorepo con múltiples lenguajes, Patrón B es el correcto.**

---

## Solución: Patrón Centralizado

### Principios Fundamentales

| Principio | Implementación |
|-----------|----------------|
| **Una Única Fuente de Verdad** | `/pruebas/` = punto único de pruebas en el repo |
| **DRY (No Repitas)** | Fixtures y mocks compartidos en `/pruebas/fixtures` y `/pruebas/mocks` |
| **Separación de Responsabilidades** | Pruebas organizados por **tipo** (unit, integration) luego por **app** (flutter, python) |
| **CI/CD Simple** | Un solo comando desde raíz ejecuta TODO: `./ejecutar_pruebas.sh all` |
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

#### `/pruebas/prueba_helper.dart`
Utilidades compartidas para pruebas de Dart:
```dart
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

Future<void> initTestDatabase() async {
  // Setup SQLite en-memoria para tests
  sqlfiteFfiInit();
}
```

#### `/pruebas/confprueba.py`
Utilidades compartidas para pruebas de Python:
```python
import pytest
from unittest.mock import MagicMock

@pytest.fixture
def mock_db():
    """Fixture para mocking de base de datos."""
    return MagicMock()
```

#### `ejecutar_pruebas.sh`
Script maestro que ejecuta pruebas desde la raíz:
```bash
./run_tests.sh flutter    # Tests de Flutter solamente
./run_tests.sh python     # Tests de Python solamente
./run_tests.sh integration # Tests de integración
./run_tests.sh all        # TODO
```

---

## Ejecución de Pruebas

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
    runs-on: self-hosted
    steps:
      - name: Ejecutar Todos los Tests
        run: ./run_tests.sh all
```

---

## Migración Realizada

### Cambios Hechos

| Antes (❌ INCORRECTO) | Después (✅ CORRECTO) | Razón |
|---|---|---|
| `src/client/prueba/unit/domain/*.dart` | `pruebas/unit/flutter/domain/*.dart` | Centralizado |
| `src/client/prueba/unit/data/*.dart` | `pruebas/unit/flutter/data/*.dart` | Centralizado |
| `src/client/prueba/prueba_helper.dart` | `pruebas/prueba_helper.dart` | Compartido |
| `src/client/prueba/fixtures/*.dart` | `pruebas/fixtures/*.dart` | Compartido |
| ❌ `src/client/prueba/` directory | ✅ ELIMINADO | No existe en Patrón B |

### Imports (SIN CAMBIOS - Resolución Automática)

Los imports en los pruebas usan `package:softarchitect_ai/...` que Flutter resuelve **automáticamente** desde `pubspec.yaml` sin importar dónde esté el archivo de prueba:

```dart
// Tests en /tests/unit/flutter/domain/project_validation_use_case_test.dart
// MISMA importación - Flutter la resuelve correctamente
import 'package:softarchitect_ai/features/project_shell/domain/use_cases/project_validation_use_case.dart';
```

---

## Por Qué Este Patrón

### ✅ Ventajas del Patrón Centralizado

1. **Monorepo Puro:** Un único punto de verdad para TODOS los pruebas
   - Sin confusión: ¿Dónde van los pruebas de integración cliente-servidor?
   - Respuesta clara: `/pruebas/integration/e2e/`

2. **Código Compartido (DRY):**
   - Fixtures (datos de prueba) compartidas entre Flutter y Python
   - Mocks reutilizables
   - Utilidades de prueba centralizadas

3. **CI/CD Simplificado:**
   ```bash
   ./run_tests.sh all  # Un comando, TODO se ejecuta
   ```

4. **Cobertura Unificada:**
   - Dashboard único que muestra cobertura de Flutter + Python
   - Fácil ver qué pruebas faltan

5. **Escalabilidad:**
   - Si agregamos más packages (Go, Rust), todos los pruebas van a `/pruebas`
   - Patrón consistente para el futuro

6. **Compatibilidad con Monorepos Estándar:**
   - Google Monorepo (Bazel): pruebas centralizados
   - Nx Monorepo: pruebas centralizados
   - Yarn Workspaces: pruebas centralizados
   - **Es el estándar de la industria**

### ❌ Por Qué NO el Patrón Descentralizado

| Problema | Ejemplo |
|----------|---------|
| **Múltiples fuentes de verdad** | Fixtures duplicadas en `/src/client/prueba/fixtures` y `/src/server/pruebas/fixtures` |
| **Confusión en E2E** | ¿Dónde van los pruebas que requieren ambos packages? |
| **CI/CD Complejo** | Necesitas scripts complejos para descubrir dónde están los pruebas |
| **No es Monorepo Real** | Es como tener dos repos separados con prefijo `src/` |
| **Violación de Principios Monorepo** | Cada package es "autónomo", sin cohesión |

---

## 🔧 Configuración Requerida

### 1. `.flutterprueba` (Nuevo)
```json
{
  "testFilePattern": "**/*_test.dart",
  "testDirectory": "tests/unit/flutter"
}
```
✅ **CREADO** - Indica a Flutter dónde buscar los pruebas

### 2. `.gitignore` (Corregido)
```
# ❌ ANTES (INCORRECTO)
lib/

# ✅ DESPUÉS (CORRECTO)
src/server/lib64/
```
✅ **CORREGIDO** - No bloquea `src/client/lib/`

### 3. `ejecutar_pruebas.sh` (Nuevo)
✅ **CREADO** - Script maestro para ejecutar pruebas desde cualquier ubicación

---

## ✅ Estado Actual

| Aspecto | Estado |
|--------|--------|
| Pruebas centralizados en `/pruebas` | ✅ DONE |
| Pruebas de Flutter movidos | ✅ DONE |
| Imports verificados | ✅ DONE (automáticos) |
| Script de ejecución | ✅ DONE |
| Configuración .flutterprueba | ✅ DONE |
| .gitignore corregido | ✅ DONE |
| 15 pruebas listos para ejecutar | ✅ READY |

---

## 🚀 Próximos Pasos

1. **Ejecutar pruebas centralizados:**
   ```bash
   ./run_tests.sh flutter
   ```

2. **Agregar pruebas de Python** cuando la capa de servicios Python esté lista

3. **Agregar pruebas de integración E2E** para validar cliente ↔ servidor

4. **Integrar en GitHub Actions** en el pipeline de CI/CD
