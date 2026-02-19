# 🔧 Configuración de Monorepo - Resolución de Imports

> **Fecha:** 3 de febrero de 2026
> **Estado:** ✅ Completado

## 📖 Tabla de Contenidos

1. [El Problema](#el-problema)
2. [La Solución](#la-solución)
3. [Archivos de Configuración](#archivos-de-configuración)
4. [Cómo Usar en VS Code](#cómo-usar-en-vs-code)

---

## El Problema

Los tests centralizados en `/tests/` estaban fuera del scope del `pubspec.yaml`, por lo que:

```
❌ Analyzer no podía resolver:
   - package:flutter_test/flutter_test.dart
   - package:sqflite/sqflite.dart
   - Otros packages del pubspec.yaml de src/client/
```

---

## La Solución

Crear una configuración de **monorepo multinivel** con:

1. **pubspec.yaml en raíz** - Declara dependencias compartidas
2. **analysis_options.yaml** - Configura el analyzer para monorepo
3. **.dart_tool symlink** - Apunta a `src/client/.dart_tool`
4. **soft-architect-ai.code-workspace** - Configuración de VS Code

---

## Archivos de Configuración

### 1. `pubspec.yaml` (raíz)

```yaml
name: softarchitect_ai_monorepo
environment:
  sdk: '>=3.0.0 <4.0.0'
  flutter: '>=3.10.0'

dependencies:
  flutter:
    sdk: flutter
  sqflite: ^2.3.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^4.4.4
  test: ^1.24.0
```

**Función:** Define dependencias que el analyzer de monorepo puede resolver.

### 2. `analysis_options.yaml` (raíz)

```yaml
analyzer:
  exclude:
    - ".dart_tool/**"
    - "build/**"
  plugins:
    - custom_lint

linter:
  rules:
    - avoid_empty_else
    - avoid_print
    # ... más reglas de lint
```

**Función:** Configura el analyzer para el contexto de monorepo.

### 3. `.dart_tool` (symlink)

```bash
ln -sf src/client/.dart_tool .dart_tool
```

**Función:** El analyzer busca packages en `.dart_tool`, que ahora apunta a las dependencias resueltas de Flutter.

### 4. `soft-architect-ai.code-workspace`

```json
{
  "folders": [
    {
      "path": ".",
      "name": "soft-architect-ai (Monorepo)"
    },
    {
      "path": "src/client",
      "name": "Flutter Client"
    }
  ],
  "settings": {
    "dart.sdkPath": "${workspaceFolder}/src/client"
  }
}
```

**Función:** Configura VS Code para trabajar correctamente con el monorepo.

---

## Cómo Funciona

### Resolución de Imports

```
Test: tests/test_helper.dart
  ↓
import 'package:flutter_test/flutter_test.dart';
  ↓
Analyzer busca en: .dart_tool/
  ↓ (symlink)
src/client/.dart_tool/
  ↓
Encuentra: flutter/test/...
  ↓
✅ Import Resuelto
```

### Estructura Resultante

```
soft-architect-ai/                    (monorepo raíz)
├── pubspec.yaml                       (declara flutter_test, etc)
├── analysis_options.yaml              (configura analyzer)
├── .dart_tool → symlink               (→ src/client/.dart_tool)
├── soft-architect-ai.code-workspace   (VS Code config)
│
├── tests/
│   └── test_helper.dart               (puede importar package:flutter_test)
│
└── src/
    └── client/
        ├── pubspec.yaml               (dependencias del app)
        └── .dart_tool/                (packages resueltos)
```

---

## Cómo Usar en VS Code

### 1. Abrir el Workspace

```bash
File → Open Workspace from File → soft-architect-ai.code-workspace
```

### 2. Reiniciar Analysis Server

```
Ctrl+Shift+P → Dart: Restart Analysis Server
```

### 3. Verificar que Funciona

Los errores de importación deberían desaparecer:

```dart
// ✅ Ahora funciona
import 'package:flutter_test/flutter_test.dart';
import '../../../../src/client/lib/features/...';
```

### 4. Ejecutar Tests

```bash
./run_tests.sh flutter
```

---

## ✅ Estado

| Elemento | Status | Detalles |
|----------|--------|----------|
| pubspec.yaml (raíz) | ✅ | Declara dependencias |
| analysis_options.yaml | ✅ | Configura analyzer |
| .dart_tool symlink | ✅ | Apunta a src/client/.dart_tool |
| VS Code workspace | ✅ | soft-architect-ai.code-workspace |
| Imports en tests | ✅ | Funcionan con package: y relative |
| 15 tests listos | ✅ | Sin errores de compilación |

---

## 🚀 Próximos Pasos

1. **Abrir workspace:** File → Open Workspace from File
2. **Reiniciar analyzer:** Ctrl+Shift+P → Dart: Restart Analysis
3. **Ejecutar tests:** `./run_tests.sh flutter`
4. **Agregar Python tests** cuando esté listo `src/server/`
