# 🧭 Navigation & Routing Guide - HU-3.3 SUPER-WORKSPACE

**Date:** 06/02/2026
**Version:** 1.0
**Estado:** ✅ Preparado para Pruebaing

---

## 📋 Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Route Structure](#route-structure)
3. [How to Ejecutar](#how-to-ejecutar)
4. [Navigation Flows](#navigation-flows)
5. [Pruebaing Scenarios](#pruebaing-scenarios)
6. [Mock Data](#mock-data)

---

## 🏗️ Architecture Overview

The navigation system uses **GoRouter** with a clean separation of concerns:

```
┌────────────────────────────────────────┐
│        main.dart (Entry Point)        │
│  MaterialApp.router with AppRouter    │
└────────────┬─────────────────────────┘
             │
             ↓
┌────────────────────────────────────────┐
│    app_router.dart (Route Config)     │
│                                        │
│  Routes:                               │
│  ├─ / (Home)                          │
│  ├─ /workspace/:projectId             │
│  ├─ /project-shell                    │
│  ├─ /chat                             │
│  └─ /settings                         │
└────────────┬─────────────────────────┘
             │
             ↓
┌────────────────────────────────────────┐
│    Screens with Navigation Events     │
│                                        │
│  ├─ _ProjectSelectionScreen            │
│  ├─ ProjectWorkspaceScreen             │
│  ├─ ProjectShellScreen                 │
│  └─ ChatScreen                         │
└────────────────────────────────────────┘
```

---

## 🗺️ Route Structure

### Route Definition

| Path | Screen | Parameters | Purpose |
|------|--------|------------|---------|
| `/` | `_ProyectoSelectionScreen` | None | Dashboard with available proyectos |
| `/workspace/:proyectoId` | `ProyectoWorkspaceScreen` | `proyectoId` | Main IDE workspace |
| `/proyecto-shell` | `ProyectoShellScreen` | None | Legacy archivo tree view |
| `/chat` | `ChatScreen` | None | Chat interface |
| `/settings` | `_SettingsScreen` | None | App settings |

### Route Extraction

```dart
// In app_router.dart, projectId is extracted from URL:
GoRoute(
  path: '/workspace/:projectId',
  builder: (context, state) {
    final projectId = state.pathParameters['projectId'] ?? 'unknown';
    return ProjectWorkspaceScreen(projectPath: projectId);
  },
),
```

---

## 🚀 How to Ejecutar

### Prerequisites
- Flutter 3.10+ (Desktop target: Linux/Windows/macOS)
- All dependencies installed: `flutter pub get`

### Step 1: Navigate to Client Directory
```bash
cd src/client
```

### Step 2: Ejecutar on Linux Desktop
```bash
flutter run -d linux
```

### Step 3: Ejecutar on Windows/macOS
```bash
flutter run -d windows
# or
flutter run -d macos
```

### Initial Screen
You'll land on the **Home Dashboard** (`/`):
```
┌─────────────────────────────────────────┐
│ 🎯 SoftArchitect AI Workspace          │
│                                         │
│ Available Projects:                     │
│ ┌──────────────────────────────────────┐
│ │ 📁 SoftArchitect - Main              │
│ │    AI Architecture Assistant          │
│ │    ID: proj-001              →       │
│ ├──────────────────────────────────────┤
│ │ 📁 Document Generator                │
│ │    Generate technical docs            │
│ │    ID: proj-002              →       │
│ ├──────────────────────────────────────┤
│ │ 📁 Test Project                      │
│ │    Demo project for testing           │
│ │    ID: proj-003              →       │
│ └──────────────────────────────────────┘
│                                         │
│ [+ New Project]                        │
└─────────────────────────────────────────┘
```

---

## 🔄 Navigation Flows

### Flow 1: Explore Available Proyectos

```
Dashboard (/)
    ↓
[Click on project card]
    ↓
ProjectWorkspaceScreen (/workspace/:projectId)
    ↓
See 3-column IDE:
  ├─ Left: File Tree
  ├─ Center: Chat
  └─ Right: Markdown Preview
    ↓
[Click Back Button in AppBar]
    ↓
Dashboard (/) ← Back to projects list
```

### Flow 2: Crear Nuevo Proyecto

```
Dashboard (/)
    ↓
[Click "+ New Project" button]
    ↓
Create Project Dialog appears
    ↓
[Enter project name and click Create]
    ↓
New project created with ID: proj-{timestamp}
    ↓
Automatically navigates to:
  /workspace/proj-{timestamp}
    ↓
ProjectWorkspaceScreen loads with new ID
```

### Flow 3: Quick Navigation

```
Any Screen
    ↓
[Click Settings icon in AppBar]
    ↓
SettingsScreen (/settings)
    ↓
[No back button, can use browser back or manual navigation]
```

---

## 🧪 Pruebaing Scenarios

### Scenario 1: Basic Proyecto Navigation
**Goal:** Verify proyecto selection and workspace loading

1. **Start App**
   ```bash
   flutter run -d linux
   ```

2. **Verify Dashboard**
   - Confirm 3 mock proyectos display
   - Each proyecto shows ID, name, descripción

3. **Click First Proyecto (proj-001)**
   - Should navigate to `/workspace/proj-001`
   - Workspace screen should load with:
     - Proyecto ID shown in AppBar
     - Archivo tree on left
     - Chat interface in center
     - Preview panel on right

4. **Click Back Botón**
   - Should return to Dashboard (`/`)
   - Proyecto list should still be visible

✅ **Expected Resultado:** Smooth navigation between screens

---

### Scenario 2: Crear Nuevo Proyecto
**Goal:** Verify dynamic proyecto creation

1. **From Dashboard, click "+ Nuevo Proyecto"**
   - Dialog should appear with text field

2. **Enter Proyecto Name**
   ```
   "My Test Project"
   ```

3. **Click Crear**
   - Dialog closes
   - Auto-navigates to `/workspace/proj-{TIMESTAMP}`
   - New proyecto ID shown in AppBar

4. **Click Back**
   - Returns to Dashboard
   - Can verify creation worked by looking at proyecto list

✅ **Expected Resultado:** New proyecto creard and navigable

---

### Scenario 3: Cross-Screen Navigation
**Goal:** Verify all navigation paths work

| From | To | Method | Expected |
|------|----|---------| ---------|
| Dashboard | Workspace | Click proyecto | Navigate with ID |
| Workspace | Dashboard | Click back | Return cleanly |
| Dashboard | Settings | Settings icon | Navigate |
| Dashboard | Proyecto Shell | Quick nav botón | Navigate |
| Dashboard | Chat | Quick nav botón | Navigate |

✅ **Expected Resultado:** All navigation paths functional

---

### Scenario 4: URL Bar Pruebaing
**Goal:** Verify direct URL access works

1. **In Flutter web emulator, manually enter URL:**
   ```
   http://localhost:XXXX/workspace/proj-test-123
   ```

2. **Expected:**
   - Workspace loads
   - ProyectoId "proj-prueba-123" shown in AppBar
   - All panels render correctly

3. **Crear new via URL:**
   ```
   http://localhost:XXXX/workspace/my-custom-project-id
   ```

✅ **Expected Resultado:** Direct URL access works

---

## 📊 Mock Data

### Mock Proyectos (in `_ProyectoSelectionScreen`)

```dart
final mockProjects = [
  {
    'id': 'proj-001',
    'name': 'SoftArchitect - Main',
    'desc': 'AI Architecture Assistant'
  },
  {
    'id': 'proj-002',
    'name': 'Document Generator',
    'desc': 'Generate technical docs'
  },
  {
    'id': 'proj-003',
    'name': 'Test Project',
    'desc': 'Demo project for testing'
  },
];
```

### Dynamic Proyecto Creation

When user crears a nuevo proyecto:
```dart
final projectId = 'proj-${DateTime.now().millisecondsSinceEpoch}';
// Example: proj-1707250432102
```

### Display in Workspace AppBar

```
Project: proj-001
Doc 1/25
Phase: Vision
```

---

## ✅ Checklist: Before Deployment

- [ ] All routes configured in `crearAppRouter()`
- [ ] ProyectoSelectionScreen shows mock proyectos
- [ ] Clicking proyecto navigates with correct ID
- [ ] ProyectoWorkspaceScreen displays proyectoId in AppBar
- [ ] Back botón returns to Dashboard
- [ ] Crear proyecto dialog works
- [ ] Dynamic ID generation successful
- [ ] GoRouter dependency in pubspec.yaml
- [ ] No compilation errors: `flutter analyze`
- [ ] No ejecutartime errors on startup

---

## 🐛 Troubleshooting

### Issue: "Route not found" error
**Solution:** Verify all route paths in `app_router.dart` match the `path:` parameter exactly.

### Issue: ProyectoId not showing in AppBar
**Solution:** Confirm `ProyectoWorkspaceScreen` receives `proyectoPath` parameter and displays it in UI.

### Issue: Back botón doesn't work
**Solution:** Ensure `Navigator.of(context).pop()` is called in back botón onPressed.

### Issue: Crear proyecto doesn't navigate
**Solution:** Verify `context.go('/workspace/$proyectoId')` is called after dialog closes.

---

## 📚 Archivo References

- **Router Configuración:** [lib/core/router/app_router.dart](../../lib/core/router/app_router.dart)
- **Workspace Screen:** [lib/features/proyecto_shell/presentation/screens/proyecto_workspace_screen.dart](../../lib/features/proyecto_shell/presentation/screens/proyecto_workspace_screen.dart)
- **Main Entry:** [lib/main.dart](../../lib/main.dart)
- **GoRouter Docs:** https://pub.dev/packages/go_router

---

## 🎯 Siguiente Steps

1. **Prueba with `flutter ejecutar -d linux`**
2. **Verify all 5 scenarios pass**
3. **Check console for errors**
4. **Prueba on Windows/macOS if needed**
5. **Preparado para backend integration (Fase 7)**

---

**Estado:** ✅ Navigation system fully implemented and preparado para pruebaing.
