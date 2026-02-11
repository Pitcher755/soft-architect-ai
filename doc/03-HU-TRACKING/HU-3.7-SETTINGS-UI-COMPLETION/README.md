# HU-3.7: Settings UI Completion & Widget Tests

> **Estado:** 🚧 En Progreso
> **Fecha Inicio:** 11/02/2026
> **Branch:** `feature/settings-ui-completion`
> **Cobertura Objetivo:** >90% (Actual: 85%)

---

<div align="center">

| [🇬🇧 English](#english) | [🇪🇸 Español](#español) |
|:---:|:---:|

</div>

---

<div id="english">

## 📋 Table of Contents
- [User Story Overview](#user-story-overview)
- [Acceptance Criteria](#acceptance-criteria)
- [TODOs Breakdown](#todos-breakdown)
- [Technical Scope](#technical-scope)
- [Dependencies](#dependencies)
- [Metrics](#metrics)

---

## 📖 User Story Overview

**As a** developer using SoftArchitect AI
**I want** a fully functional and persistent Settings UI with comprehensive widget tests
**So that** I can customize my experience and have confidence in UI stability

### Context
This HU completes the Settings feature by:
1. Making ALL settings functional and persistent (SharedPreferences)
2. Fixing 10 failing MarkdownPreview tests
3. Creating 8 new widget tests (Settings + GlobalSearchDialog)
4. Adding language selection (🇬🇧 English / 🇪🇸 Español)
5. Implementing native folder picker (file_picker)
6. Enabling project navigation from GlobalSearchDialog
7. Persisting last opened project in ProjectsSidebar

---

## ✅ Acceptance Criteria

| # | Criterion | Status |
|---|-----------|--------|
| AC-1 | `file_picker` package integrated (native folder selector) | ⏳ Pending |
| AC-2 | 10 MarkdownPreview tests refactored and passing | ⏳ Pending |
| AC-3 | 7 Settings UI widget tests created | 🚧 In Progress (4/7) |
| AC-4 | GlobalSearchDialog widget test created | 🚧 In Progress (render + navigation) |
| AC-5 | Settings coverage >90% (current: 85%) | ⏳ Pending |
| AC-6 | All settings persistent via SharedPreferences | ⏳ Pending |
| AC-7 | Language selector with flag icons functional | ⏳ Pending |
| AC-8 | GlobalSearchDialog navigates to selected project | ✅ Done |
| AC-9 | ProjectsSidebar shows last opened project | ⏳ Pending |

---

## 🔧 TODOs Breakdown

### T-2: Fix 10 Failing MarkdownPreview Tests
**Location:** `tests/test/features/project_shell/presentation/widgets/markdown_preview_widget_test.dart`

**Issues to Fix:**
- Async rendering issues
- Mock data inconsistencies
- Widget finder failures
- Pump/settle timing issues

**Strategy:**
- Use `WidgetTester.pumpAndSettle()` for async renders
- Mock MarkdownController properly
- Verify widget tree structure
- Add golden tests for visual regression

---

### T-3: Create 7 Settings UI Widget Tests
**Target Files:**
- ✅ `profile_section.dart` → Keyed user name field present
- ⏳ `storage_section.dart` → Test folder picker, path display
- ✅ `appearance_section.dart` → Theme toggle + font size slider
- ✅ `accessibility_section.dart` → Global zoom + shortcuts
- ✅ `performance_section.dart` → Animations + memory optimization
- ⏳ `settings_screen.dart` → Test full screen integration, navigation
- ⏳ Language selector → Test ES/EN toggle with flags

**Test Coverage:**
- User interactions (taps, text input)
- State changes (Riverpod providers)
- Persistence (SharedPreferences mocks)
- Edge cases (empty states, errors)

---

### T-4: Create GlobalSearchDialog Widget Test
**Location:** `tests/test/shared/presentation/widgets/global_search_dialog_test.dart`

**Test Cases:**
1. ✅ **Render:** Dialog opens with search field
2. ⏳ **Empty State:** Search with no results shows empty state
3. ⏳ **Search Results:** Projects filtered correctly by name/phase/date
4. ✅ **Navigation:** Clicking result navigates to project (GoRouter)
5. ⏳ **Clear Search:** X button clears search query
6. ✅ **Close Dialog:** ESC key / close button dismisses dialog

---

### TODO-2: Implement file_picker in storage_section.dart:68
**Package:** `file_picker: ^8.0.0+1`

**Implementation:**
```dart
import 'package:file_picker/file_picker.dart';

Future<void> _pickFolder() async {
  final result = await FilePicker.platform.getDirectoryPath();
  if (result != null) {
    // Save to SharedPreferences
    await ref.read(settingsProvider.notifier).updateStoragePath(result);
  }
}
```

**Platform Support:**
- ✅ Linux (native GTK dialog)
- ✅ macOS (native Cocoa dialog)
- ✅ Windows (native Win32 dialog)

---

## 🧱 Technical Scope

### Architecture (Clean Architecture)

#### 1. Domain Layer (`lib/features/settings/domain/`)
- **Entities:**
  - `SettingsEntity` (all settings data)
  - `LanguagePreference` (enum: en, es)
  - `ThemePreference` (enum: dark, light, system)
  - `AccessibilitySettings` (font size, contrast, screen reader)
  - `PerformanceSettings` (cache, memory limits)

- **Use Cases:**
  - `LoadSettingsUseCase`
  - `SaveSettingsUseCase`
  - `UpdateLanguageUseCase`
  - `UpdateThemeUseCase`
  - `UpdateStoragePathUseCase`

- **Repositories (Interfaces):**
  - `ISettingsRepository`
  - `ILastProjectRepository`

#### 2. Data Layer (`lib/features/settings/data/`)
- **Data Sources:**
  - `SettingsLocalDataSource` (SharedPreferences)
  - `FilePickerDataSource` (file_picker package)

- **DTOs:**
  - `SettingsDto` (JSON serialization)

- **Repository Implementations:**
  - `SettingsRepositoryImpl`
  - `LastProjectRepositoryImpl`

#### 3. Presentation Layer (`lib/features/settings/presentation/`)
- **Providers (Riverpod):**
  - `settingsProvider` (StateNotifierProvider)
  - `lastProjectProvider` (StateProvider)

- **Widgets:**
  - `ProfileSection` (✅ Exists, needs persistence)
  - `StorageSection` (⚠️ Needs file_picker)
  - `AppearanceSection` (✅ Exists, needs persistence)
  - `AccessibilitySection` (✅ Exists, needs persistence)
  - `PerformanceSection` (✅ Exists, needs persistence)
  - `LanguageSelectorWidget` (❌ NEW: Flag icons + toggle)

---

## 🔗 Dependencies

### New Packages Required
```yaml
dependencies:
  file_picker: ^8.0.0+1      # Native folder picker
  shared_preferences: ^2.2.2 # Persistent storage
  flutter_svg: ^2.0.9        # Flag icons (SVG)

dev_dependencies:
  mockito: ^5.4.4            # Mocking for tests
  build_runner: ^2.4.8       # Code generation
```

### Existing Packages (Already in pubspec.yaml)
- `flutter_riverpod: ^2.5.1`
- `go_router: ^13.2.0`
- `flutter_test: sdk`

---

## 📊 Metrics

| Metric | Before | Target | Status |
|--------|--------|--------|--------|
| **Tests** | ~120 | +18 (138 total) | ⏳ In Progress |
| **Coverage** | 85% | >90% | ⏳ In Progress |
| **Fixed Tests** | 10 failing | 0 failing | ⏳ In Progress |
| **New Tests** | 0 | 8 widget tests | ⏳ In Progress |
| **Functionality** | Partial | 100% Settings | ⏳ In Progress |

---

## 🔐 Quality Gates (Pre-Merge Checklist)

- [ ] **Code Quality:**
  - [ ] All Dart code formatted (`dart format`)
  - [ ] No analyzer warnings (`flutter analyze`)
  - [ ] DartDoc on all public APIs

- [ ] **Testing:**
  - [ ] Unit tests pass (domain layer)
  - [ ] Widget tests pass (7 settings + 1 global search)
  - [ ] 10 MarkdownPreview tests fixed and passing
  - [ ] Coverage >90% verified

- [ ] **Functionality:**
  - [ ] All settings persist correctly
  - [ ] Language selector works (ES/EN)
  - [ ] Folder picker opens native dialog
  - [ ] GlobalSearchDialog navigates to projects
  - [ ] ProjectsSidebar shows last opened project

- [ ] **Security:**
  - [ ] No hardcoded paths
  - [ ] Input sanitization on paths
  - [ ] SharedPreferences keys namespaced

- [ ] **Documentation:**
  - [ ] README.md updated
  - [ ] PROGRESS.md completed
  - [ ] ARTIFACTS.md verified
  - [ ] DartDoc generated

---

## 📚 Related Documents

- [PROGRESS.md](./PROGRESS.md) - 6-Phase Checklist
- [ARTIFACTS.md](./ARTIFACTS.md) - File Manifest
- [../../02-SETUP_DEV/TESTING_GUIDE.md](../../02-SETUP_DEV/TESTING_GUIDE.md) - Testing Standards
- [../../../context/30-ARCHITECTURE/DESIGN_SYSTEM.en.md](../../../context/30-ARCHITECTURE/DESIGN_SYSTEM.en.md) - UI Guidelines

---

</div>

<div id="español">

## 📋 Tabla de Contenidos
- [Resumen de Historia de Usuario](#resumen-de-historia-de-usuario)
- [Criterios de Aceptación](#criterios-de-aceptación-es)
- [Desglose de TODOs](#desglose-de-todos)
- [Alcance Técnico](#alcance-técnico)
- [Dependencias](#dependencias-es)
- [Métricas](#métricas-es)

---

## 📖 Resumen de Historia de Usuario

**Como** desarrollador usando SoftArchitect AI
**Quiero** una UI de Configuración completamente funcional y persistente con tests de widget completos
**Para** poder personalizar mi experiencia y tener confianza en la estabilidad de la UI

### Contexto
Esta HU completa la funcionalidad de Settings:
1. Haciendo TODAS las configuraciones funcionales y persistentes (SharedPreferences)
2. Arreglando 10 tests fallidos de MarkdownPreview
3. Creando 8 nuevos widget tests (Settings + GlobalSearchDialog)
4. Añadiendo selector de idioma (🇬🇧 Inglés / 🇪🇸 Español)
5. Implementando selector nativo de carpetas (file_picker)
6. Habilitando navegación de proyectos desde GlobalSearchDialog
7. Persistiendo último proyecto abierto en ProjectsSidebar

---

## ✅ Criterios de Aceptación {#criterios-de-aceptación-es}

| # | Criterio | Estado |
|---|----------|--------|
| AC-1 | Paquete `file_picker` integrado (selector nativo de carpetas) | ⏳ Pendiente |
| AC-2 | 10 tests de MarkdownPreview refactorizados y pasando | ⏳ Pendiente |
| AC-3 | 7 widget tests de Settings UI creados | ⏳ Pendiente |
| AC-4 | Widget test de GlobalSearchDialog creado | ⏳ Pendiente |
| AC-5 | Cobertura de Settings >90% (actual: 85%) | ⏳ Pendiente |
| AC-6 | Todas las configuraciones persistentes vía SharedPreferences | ⏳ Pendiente |
| AC-7 | Selector de idioma con iconos de banderas funcional | ⏳ Pendiente |
| AC-8 | GlobalSearchDialog navega al proyecto seleccionado | ⏳ Pendiente |
| AC-9 | ProjectsSidebar muestra último proyecto abierto | ⏳ Pendiente |

---

## 🔧 Desglose de TODOs {#desglose-de-todos}

### T-2: Arreglar 10 Tests Fallidos de MarkdownPreview
**Ubicación:** `tests/test/features/project_shell/presentation/widgets/markdown_preview_widget_test.dart`

**Problemas a Arreglar:**
- Problemas de renderizado asíncrono
- Inconsistencias en datos mock
- Fallos en widget finder
- Problemas de timing pump/settle

**Estrategia:**
- Usar `WidgetTester.pumpAndSettle()` para renders async
- Mockear MarkdownController correctamente
- Verificar estructura del árbol de widgets
- Añadir golden tests para regresión visual

---

### T-3: Crear 7 Widget Tests de Settings UI
**Archivos Objetivo:**
- `profile_section.dart` → Test info usuario, avatar, modo edición
- `storage_section.dart` → Test selector carpetas, visualización ruta
- `appearance_section.dart` → Test toggle tema, esquemas de color
- `accessibility_section.dart` → Test tamaño fuente, contraste, lector pantalla
- `performance_section.dart` → Test controles caché, toggles rendimiento
- `settings_screen.dart` → Test integración pantalla completa, navegación
- Selector idioma → Test toggle ES/EN con banderas

**Cobertura de Tests:**
- Interacciones usuario (taps, input texto)
- Cambios de estado (providers Riverpod)
- Persistencia (mocks SharedPreferences)
- Casos borde (estados vacíos, errores)

---

### T-4: Crear Widget Test de GlobalSearchDialog
**Ubicación:** `tests/test/shared/presentation/widgets/global_search_dialog_test.dart`

**Casos de Prueba:**
1. **Renderizado:** Diálogo abre con campo de búsqueda
2. **Estado Vacío:** Búsqueda sin resultados muestra estado vacío
3. **Resultados Búsqueda:** Proyectos filtrados correctamente por nombre/fase/fecha
4. **Navegación:** Click en resultado navega al proyecto (GoRouter)
5. **Limpiar Búsqueda:** Botón X limpia query de búsqueda
6. **Cerrar Diálogo:** Tecla ESC / botón cerrar cierra el diálogo

---

### TODO-2: Implementar file_picker en storage_section.dart:68
**Paquete:** `file_picker: ^8.0.0+1`

**Implementación:**
```dart
import 'package:file_picker/file_picker.dart';

Future<void> _pickFolder() async {
  final result = await FilePicker.platform.getDirectoryPath();
  if (result != null) {
    // Guardar en SharedPreferences
    await ref.read(settingsProvider.notifier).updateStoragePath(result);
  }
}
```

**Soporte de Plataformas:**
- ✅ Linux (diálogo nativo GTK)
- ✅ macOS (diálogo nativo Cocoa)
- ✅ Windows (diálogo nativo Win32)

---

## 🧱 Alcance Técnico {#alcance-técnico}

### Arquitectura (Clean Architecture)

#### 1. Capa de Dominio (`lib/features/settings/domain/`)
- **Entidades:**
  - `SettingsEntity` (todos los datos de configuración)
  - `LanguagePreference` (enum: en, es)
  - `ThemePreference` (enum: dark, light, system)
  - `AccessibilitySettings` (tamaño fuente, contraste, lector pantalla)
  - `PerformanceSettings` (caché, límites memoria)

- **Casos de Uso:**
  - `LoadSettingsUseCase`
  - `SaveSettingsUseCase`
  - `UpdateLanguageUseCase`
  - `UpdateThemeUseCase`
  - `UpdateStoragePathUseCase`

- **Repositorios (Interfaces):**
  - `ISettingsRepository`
  - `ILastProjectRepository`

#### 2. Capa de Datos (`lib/features/settings/data/`)
- **Data Sources:**
  - `SettingsLocalDataSource` (SharedPreferences)
  - `FilePickerDataSource` (paquete file_picker)

- **DTOs:**
  - `SettingsDto` (serialización JSON)

- **Implementaciones de Repositorio:**
  - `SettingsRepositoryImpl`
  - `LastProjectRepositoryImpl`

#### 3. Capa de Presentación (`lib/features/settings/presentation/`)
- **Providers (Riverpod):**
  - `settingsProvider` (StateNotifierProvider)
  - `lastProjectProvider` (StateProvider)

- **Widgets:**
  - `ProfileSection` (✅ Existe, necesita persistencia)
  - `StorageSection` (⚠️ Necesita file_picker)
  - `AppearanceSection` (✅ Existe, necesita persistencia)
  - `AccessibilitySection` (✅ Existe, necesita persistencia)
  - `PerformanceSection` (✅ Existe, necesita persistencia)
  - `LanguageSelectorWidget` (❌ NUEVO: Iconos bandera + toggle)

---

## 🔗 Dependencias {#dependencias-es}

### Nuevos Paquetes Requeridos
```yaml
dependencies:
  file_picker: ^8.0.0+1      # Selector nativo carpetas
  shared_preferences: ^2.2.2 # Almacenamiento persistente
  flutter_svg: ^2.0.9        # Iconos banderas (SVG)

dev_dependencies:
  mockito: ^5.4.4            # Mocking para tests
  build_runner: ^2.4.8       # Generación código
```

### Paquetes Existentes (Ya en pubspec.yaml)
- `flutter_riverpod: ^2.5.1`
- `go_router: ^13.2.0`
- `flutter_test: sdk`

---

## 📊 Métricas {#métricas-es}

| Métrica | Antes | Objetivo | Estado |
|---------|-------|----------|--------|
| **Tests** | ~120 | +18 (138 total) | ⏳ En Progreso |
| **Cobertura** | 85% | >90% | ⏳ En Progreso |
| **Tests Arreglados** | 10 fallando | 0 fallando | ⏳ En Progreso |
| **Tests Nuevos** | 0 | 8 widget tests | ⏳ En Progreso |
| **Funcionalidad** | Parcial | 100% Settings | ⏳ En Progreso |

---

## 🔐 Quality Gates (Checklist Pre-Merge)

- [ ] **Calidad de Código:**
  - [ ] Todo código Dart formateado (`dart format`)
  - [ ] Sin warnings del analyzer (`flutter analyze`)
  - [ ] DartDoc en todas las APIs públicas

- [ ] **Testing:**
  - [ ] Unit tests pasan (capa dominio)
  - [ ] Widget tests pasan (7 settings + 1 global search)
  - [ ] 10 tests MarkdownPreview arreglados y pasando
  - [ ] Cobertura >90% verificada

- [ ] **Funcionalidad:**
  - [ ] Todas las configuraciones persisten correctamente
  - [ ] Selector idioma funciona (ES/EN)
  - [ ] Selector carpetas abre diálogo nativo
  - [ ] GlobalSearchDialog navega a proyectos
  - [ ] ProjectsSidebar muestra último proyecto abierto

- [ ] **Seguridad:**
  - [ ] Sin rutas hardcodeadas
  - [ ] Sanitización input en rutas
  - [ ] Claves SharedPreferences con namespace

- [ ] **Documentación:**
  - [ ] README.md actualizado
  - [ ] PROGRESS.md completado
  - [ ] ARTIFACTS.md verificado
  - [ ] DartDoc generado

---

## 📚 Documentos Relacionados

- [PROGRESS.md](./PROGRESS.md) - Checklist de 6 Fases
- [ARTIFACTS.md](./ARTIFACTS.md) - Manifest de Archivos
- [../../02-SETUP_DEV/TESTING_GUIDE.md](../../02-SETUP_DEV/TESTING_GUIDE.md) - Estándares Testing
- [../../../context/30-ARCHITECTURE/DESIGN_SYSTEM.es.md](../../../context/30-ARCHITECTURE/DESIGN_SYSTEM.es.md) - Guías UI

---

</div>
