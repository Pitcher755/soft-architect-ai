# 📁 Tests Directory Structure - Monorepo Organization

> **Refactor:** Reorganización centralizada de tests para monorepo Flutter + Python
> **Date:** February 4, 2026
> **Status:** ✅ Complete

---

## 🎯 **Nueva Estructura**

```
tests/
├── flutter/                          # 🎨 Flutter Tests (UI, Logic, Integration)
│   ├── pubspec.yaml                 # Flutter project config
│   ├── .dart_tool/                  # Dart cache
│   ├── build/                       # Build artifacts
│   └── test/                        # Flutter tests (THIS IS WHAT flutter test FINDS)
│       ├── unit/                    # Unit tests
│       │   ├── features/
│       │   │   └── project_shell/
│       │   │       ├── data/
│       │   │       ├── domain/
│       │   │       └── presentation/
│       │   └── ...
│       ├── widget/                  # Widget tests
│       │   ├── features/
│       │   │   └── project_shell/
│       │   └── ...
│       ├── integration/             # Integration tests
│       │   └── features/
│       │       └── project_shell/
│       └── helpers/                 # Shared test utilities
│           ├── project_fixtures.dart
│           └── test_helper.dart
│
├── python/                           # 🐍 Python Tests (Backend, API, Business Logic)
│   ├── unit/                        # Unit tests
│   │   ├── test_api.py
│   │   ├── test_config.py
│   │   └── ...
│   ├── integration/                 # Integration tests
│   └── helpers/                     # Shared test utilities
│
├── test -> flutter/test             # 🔗 SYMLINK (for flutter test --coverage)
└── build/                           # Shared build artifacts

```

---

## ✨ **Ventajas de Esta Estructura**

### 1. **Separación Clara por Tecnología**
- Flutter tests completamente aislados en `tests/flutter/`
- Python tests completamente aislados en `tests/python/`
- Fácil de mantener, escalar y encontrar tests

### 2. **Cumple Convenciones Estándar**
- Flutter espera `test/` en la raíz del proyecto Flutter
- Python flexible (puede estar en cualquier lugar)
- Resultado: `tests/flutter/test/` + symlink `tests/test`

### 3. **Coverage Reports Simplificados**
```bash
# Flutter coverage (desde raíz)
flutter test --coverage              # Busca ./test/

# Python coverage (desde python/)
pytest tests/python/ --cov
```

### 4. **CI/CD Independiente**
- GitHub Actions puede ejecutar tests en paralelo
- Coverage reports separados por tecnología
- Fácil de configurar workflows específicos

### 5. **Escalabilidad Futura**
Agregar nuevas tecnologías es trivial:
```
tests/
├── flutter/
├── python/
├── kotlin/          ← Fácil agregar
├── js/              ← Fácil agregar
└── go/              ← Fácil agregar
```

---

## 📜 **Cómo Ejecutar Tests**

### **Todos los Tests**
```bash
./run_tests.sh all
```

### **Solo Flutter**
```bash
./run_tests.sh flutter
```

### **Solo Python**
```bash
./run_tests.sh python
```

### **Con Coverage**
```bash
./run_tests.sh all --coverage

# O directamente desde tests/flutter/
cd tests/flutter
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

### **Generador de Coverage HTML**
```bash
./generate_coverage_html.sh
```
Genera reporte en: `tests/flutter/coverage/html/index.html`

---

## 🔗 **Symlink Explicado**

```
tests/test -> flutter/test
```

**¿Por qué?**

Flutter busca tests en un directorio llamado `test/` relativo a `pubspec.yaml`:
```bash
flutter test              # Busca ./test/
flutter test unit/        # ❌ Error: no encuentra tests

# Con symlink:
flutter test              # ✅ Encuentra tests/test/ → tests/flutter/test/
```

---

## 📋 **Archivos Modificados**

### 1. **run_tests.sh**
- ✅ Actualizado para nueva estructura
- ✅ Soporta `--coverage` flag
- ✅ Scripts específicos por tipo de test

### 2. **generate_coverage_html.sh**
- ✅ Apunta a `tests/flutter/` como raíz
- ✅ Genera HTML en `tests/flutter/coverage/html/`

### 3. **pubspec.yaml** (raíz)
- ✅ Actualizado Dart SDK a 3.10.8
- ✅ Soporta `test/` symlink

### 4. **Nueva carpeta tests/flutter/pubspec.yaml**
- ✅ Copia del pubspec.yaml original
- ✅ Permite compilación independiente

---

## 🧹 **Limpieza Realizada**

✅ Movidas todas las estructuras de tests a `tests/flutter/test/`
✅ Eliminados directorios antiguos (`unit/`, `widget/`, `integration/`, `helpers/`)
✅ Creado symlink `test` → `flutter/test`
✅ Copiada configuración Flutter necesaria

---

## ✅ **Checklist de Verificación**

- [x] Flutter tests en `tests/flutter/test/`
- [x] Python tests en `tests/python/`
- [x] Symlink `tests/test` → `tests/flutter/test`
- [x] run_tests.sh actualizado
- [x] generate_coverage_html.sh actualizado
- [x] pubspec.yaml version fix (3.10.8)
- [x] Scripts de coverage funcionan correctamente
- [x] Estructura de directorios limpia

---

## 📚 **Próximos Pasos (Opcionales)**

1. **GitHub Actions Optimization**
   - Tests de Flutter en paralelo
   - Tests de Python en paralelo
   - Coverage reports combinados

2. **Docker Compose Update**
   - Volúmenes específicos para cada tipo de test
   - Coverage volume compartido

3. **CI/CD Matrix**
   - Test multiple Flutter versions
   - Test multiple Python versions

---

## 🎓 **Buenas Prácticas Implementadas**

✅ **Monorepo estándar** - Separación por tecnología
✅ **Convenciones respetadas** - Flutter + Python expectations
✅ **Escalable** - Agregar tecnologías es trivial
✅ **Clean separation** - No contaminación entre tests
✅ **Fácil de encontrar** - Estructura intuitiva
✅ **CI/CD ready** - Workflows independientes posibles

---

## 🚀 **Resultado Final**

```
Before:
├── tests/
│   ├── unit/flutter/        (confusing)
│   ├── widget/flutter/      (unclear)
│   ├── integration/flutter/ (scattered)
│   └── test_*.py            (mixed)

After:
├── tests/
│   ├── flutter/test/        ✅ Clear
│   ├── test -> flutter/test ✅ Symlink for flutter
│   └── python/unit/         ✅ Isolated
```

---

**Status:** ✅ Refactor Complete
**Tested:** ✅ All structures verified
**Ready for:** Production use, CI/CD integration

Happy Testing! 🎉
