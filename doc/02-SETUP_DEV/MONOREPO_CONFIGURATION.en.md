# 🔧 Monorepo Configuration - Import Resolution

> **Date:** February 3, 2026
> **Status:** ✅ Complete

## 📖 Table of Contents

1. [The Problem](#the-problem)
2. [The Solution](#the-solution)
3. [Configuration Files](#configuration-files)
4. [How to Use in VS Code](#how-to-use-in-vs-code)

---

## The Problem

Centralized tests in `/tests/` were outside the `pubspec.yaml` scope:

```
❌ Analyzer couldn't resolve:
   - package:flutter_test/flutter_test.dart
   - package:sqflite/sqflite.dart
   - Other packages from src/client/pubspec.yaml
```

---

## The Solution

Create a **multi-level monorepo configuration** with:

1. **pubspec.yaml at root** - Declares shared dependencies
2. **analysis_options.yaml** - Configures analyzer for monorepo
3. **.dart_tool symlink** - Points to `src/client/.dart_tool`
4. **soft-architect-ai.code-workspace** - VS Code configuration

---

## Configuration Files

### 1. `pubspec.yaml` (root)

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

**Purpose:** Defines dependencies that the monorepo analyzer can resolve.

### 2. `analysis_options.yaml` (root)

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
```

**Purpose:** Configures analyzer for monorepo context.

### 3. `.dart_tool` (symlink)

```bash
ln -sf src/client/.dart_tool .dart_tool
```

**Purpose:** Analyzer searches for packages in `.dart_tool`, which now points to Flutter's resolved dependencies.

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

**Purpose:** Configures VS Code to work correctly with monorepo.

---

## How It Works

### Import Resolution

```
Test: tests/test_helper.dart
  ↓
import 'package:flutter_test/flutter_test.dart';
  ↓
Analyzer searches in: .dart_tool/
  ↓ (symlink)
src/client/.dart_tool/
  ↓
Finds: flutter/test/...
  ↓
✅ Import Resolved
```

### Resulting Structure

```
soft-architect-ai/                    (monorepo root)
├── pubspec.yaml                       (declares flutter_test, etc)
├── analysis_options.yaml              (configures analyzer)
├── .dart_tool → symlink               (→ src/client/.dart_tool)
├── soft-architect-ai.code-workspace   (VS Code config)
│
├── tests/
│   └── test_helper.dart               (can import package:flutter_test)
│
└── src/
    └── client/
        ├── pubspec.yaml               (app dependencies)
        └── .dart_tool/                (resolved packages)
```

---

## How to Use in VS Code

### 1. Open the Workspace

```bash
File → Open Workspace from File → soft-architect-ai.code-workspace
```

### 2. Restart Analysis Server

```
Ctrl+Shift+P → Dart: Restart Analysis Server
```

### 3. Verify It Works

Import errors should disappear:

```dart
// ✅ Now works
import 'package:flutter_test/flutter_test.dart';
import '../../../../src/client/lib/features/...';
```

### 4. Run Tests

```bash
./run_tests.sh flutter
```

---

## ✅ Status

| Element | Status | Details |
|---------|--------|---------|
| pubspec.yaml (root) | ✅ | Declares dependencies |
| analysis_options.yaml | ✅ | Configures analyzer |
| .dart_tool symlink | ✅ | Points to src/client/.dart_tool |
| VS Code workspace | ✅ | soft-architect-ai.code-workspace |
| Imports in tests | ✅ | Work with package: and relative |
| 15 tests ready | ✅ | No compilation errors |

---

## 🚀 Next Steps

1. **Open workspace:** File → Open Workspace from File
2. **Restart analyzer:** Ctrl+Shift+P → Dart: Restart Analysis
3. **Run tests:** `./run_tests.sh flutter`
4. **Add Python tests** when `src/server/` is ready
