# 🧭 Navigation & Routing Guide - HU-3.3 SUPER-WORKSPACE

**Date:** 06/02/2026
**Version:** 1.0
**Status:** ✅ Ready for Testing

---

## 📋 Table of Contents

1. [Architecture Overview](#architecture-overview)
2. [Route Structure](#route-structure)
3. [How to Run](#how-to-run)
4. [Navigation Flows](#navigation-flows)
5. [Testing Scenarios](#testing-scenarios)
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
| `/` | `_ProjectSelectionScreen` | None | Dashboard with available projects |
| `/workspace/:projectId` | `ProjectWorkspaceScreen` | `projectId` | Main IDE workspace |
| `/project-shell` | `ProjectShellScreen` | None | Legacy file tree view |
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

## 🚀 How to Run

### Prerequisites
- Flutter 3.10+ (Desktop target: Linux/Windows/macOS)
- All dependencies installed: `flutter pub get`

### Step 1: Navigate to Client Directory
```bash
cd src/client
```

### Step 2: Run on Linux Desktop
```bash
flutter run -d linux
```

### Step 3: Run on Windows/macOS
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

### Flow 1: Explore Available Projects

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

### Flow 2: Create New Project

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

## 🧪 Testing Scenarios

### Scenario 1: Basic Project Navigation
**Goal:** Verify project selection and workspace loading

1. **Start App**
   ```bash
   flutter run -d linux
   ```

2. **Verify Dashboard**
   - Confirm 3 mock projects display
   - Each project shows ID, name, description

3. **Click First Project (proj-001)**
   - Should navigate to `/workspace/proj-001`
   - Workspace screen should load with:
     - Project ID shown in AppBar
     - File tree on left
     - Chat interface in center
     - Preview panel on right

4. **Click Back Button**
   - Should return to Dashboard (`/`)
   - Project list should still be visible

✅ **Expected Result:** Smooth navigation between screens

---

### Scenario 2: Create New Project
**Goal:** Verify dynamic project creation

1. **From Dashboard, click "+ New Project"**
   - Dialog should appear with text field

2. **Enter Project Name**
   ```
   "My Test Project"
   ```

3. **Click Create**
   - Dialog closes
   - Auto-navigates to `/workspace/proj-{TIMESTAMP}`
   - New project ID shown in AppBar

4. **Click Back**
   - Returns to Dashboard
   - Can verify creation worked by looking at project list

✅ **Expected Result:** New project created and navigable

---

### Scenario 3: Cross-Screen Navigation
**Goal:** Verify all navigation paths work

| From | To | Method | Expected |
|------|----|---------| ---------|
| Dashboard | Workspace | Click project | Navigate with ID |
| Workspace | Dashboard | Click back | Return cleanly |
| Dashboard | Settings | Settings icon | Navigate |
| Dashboard | Project Shell | Quick nav button | Navigate |
| Dashboard | Chat | Quick nav button | Navigate |

✅ **Expected Result:** All navigation paths functional

---

### Scenario 4: URL Bar Testing
**Goal:** Verify direct URL access works

1. **In Flutter web emulator, manually enter URL:**
   ```
   http://localhost:XXXX/workspace/proj-test-123
   ```

2. **Expected:**
   - Workspace loads
   - ProjectId "proj-test-123" shown in AppBar
   - All panels render correctly

3. **Create new via URL:**
   ```
   http://localhost:XXXX/workspace/my-custom-project-id
   ```

✅ **Expected Result:** Direct URL access works

---

## 📊 Mock Data

### Mock Projects (in `_ProjectSelectionScreen`)

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

### Dynamic Project Creation

When user creates a new project:
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

- [ ] All routes configured in `createAppRouter()`
- [ ] ProjectSelectionScreen shows mock projects
- [ ] Clicking project navigates with correct ID
- [ ] ProjectWorkspaceScreen displays projectId in AppBar
- [ ] Back button returns to Dashboard
- [ ] Create project dialog works
- [ ] Dynamic ID generation successful
- [ ] GoRouter dependency in pubspec.yaml
- [ ] No compilation errors: `flutter analyze`
- [ ] No runtime errors on startup

---

## 🐛 Troubleshooting

### Issue: "Route not found" error
**Solution:** Verify all route paths in `app_router.dart` match the `path:` parameter exactly.

### Issue: ProjectId not showing in AppBar
**Solution:** Confirm `ProjectWorkspaceScreen` receives `projectPath` parameter and displays it in UI.

### Issue: Back button doesn't work
**Solution:** Ensure `Navigator.of(context).pop()` is called in back button onPressed.

### Issue: Create project doesn't navigate
**Solution:** Verify `context.go('/workspace/$projectId')` is called after dialog closes.

---

## 📚 File References

- **Router Configuration:** [lib/core/router/app_router.dart](../../lib/core/router/app_router.dart)
- **Workspace Screen:** [lib/features/project_shell/presentation/screens/project_workspace_screen.dart](../../lib/features/project_shell/presentation/screens/project_workspace_screen.dart)
- **Main Entry:** [lib/main.dart](../../lib/main.dart)
- **GoRouter Docs:** https://pub.dev/packages/go_router

---

## 🎯 Next Steps

1. **Test with `flutter run -d linux`**
2. **Verify all 5 scenarios pass**
3. **Check console for errors**
4. **Test on Windows/macOS if needed**
5. **Ready for backend integration (Phase 7)**

---

**Status:** ✅ Navigation system fully implemented and ready for testing.
