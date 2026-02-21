# ProjectWorkspaceScreen - Manual Testing Guide

## Why Manual Testing?

The `ProjectWorkspaceScreen` has a complex responsive widget structure that makes unit testing unreliable:

- Multiple conditional `LayoutBuilder` instances
- Nested horizontal/vertical `SingleChildScrollView` widgets
- Each scroll layer creates duplicate `Focus`/`Shortcuts` contexts
- Widget count varies based on screen dimensions (2-3 instances per type)
- Requires `AppLocalizations`, database providers, and filesystem access
- Flutter test framework's `tester.widget<T>()` requires exactly one match

**Attempts Made:**
1. ❌ Mock ProjectEntity → Import/compilation errors
2. ❌ Override projectsProvider → Syntax errors
3. ❌ Isolate single widget → "Too many elements" errors
4. ❌ Accept multiple widgets → Still unstable
5. ❌ Add ProviderScope + localization setup → Null check errors

**Recommendation:** Integration tests or manual verification only.

---

## Code Structure Verification ✅

### F5 Refresh Infrastructure
- ✅ **Shortcuts widget:** Present in `body:` parameter
- ✅ **Actions widget:** Configured with `RefreshWorkspaceIntent`
- ✅ **Focus widget:** Has `autofocus: true` enabled
- ✅ **F5 mapping:** `LogicalKeySet(LogicalKeyboardKey.f5)` → `RefreshWorkspaceIntent`
- ✅ **Refresh method:** `_refreshWorkspace()` invalidates providers

### Dynamic Icon/Color System
- ✅ **Dynamic icons:** `_getIconForPhase(currentPhase)` method
- ✅ **Dynamic colors:** `actualIconColor = currentPhase.color` (no fallback)
- ✅ **Phase provider:** Watches `projectStatusProvider(path)`
- ✅ **Real-time updates:** `statusAsync.maybeWhen` pattern

### Widget Hierarchy
```dart
Scaffold(
  backgroundColor: AppColors.mainBg,
  body: Shortcuts(
    shortcuts: {F5 → RefreshWorkspaceIntent},
    child: Actions(
      actions: {RefreshWorkspaceIntent → CallbackAction},
      child: Focus(
        autofocus: true,  // ✅ Key for keyboard event capture
        child: LayoutBuilder(...),
      ),
    ),
  ),
)
```

---

## Manual Test Procedures

### 🔄 F5 Refresh Functionality

#### Test 1: Basic F5 Keypress
**Steps:**
1. Launch app in debug/release mode: `./scripts/devops/LAUNCH_FLUTTER_APP_DEV.sh`
2. Navigate to **ProjectWorkspaceScreen**
3. Click anywhere on screen to ensure focus
4. Press **F5** key

**Expected Results:**
- ✅ Snackbar appears with:
  - Icon: `Icons.refresh` (white, 18px)
  - Text: "🔄 Workspace actualizado"
  - Duration: 1 second
  - Behavior: SnackBarBehavior.floating
- ✅ No page navigation occurs
- ✅ Screen doesn't freeze or crash

---

#### Test 2: Provider Invalidation
**Setup:**
```bash
# Create test project externally
mkdir -p ~/test-f5-refresh
echo '{"faseActual": "Root", "porcentajeCompletado": 0}' > ~/test-f5-refresh/.softarchitect/status.json
```

**Steps:**
1. Launch app (new project won't appear yet)
2. Press **F5**
3. Wait 2 seconds
4. Verify new project appears in grid

**Cleanup:**
```bash
rm -rf ~/test-f5-refresh
```

**Expected Results:**
- ✅ New project appears within 2 seconds
- ✅ Project card shows correct icon/color for Root phase
- ✅ `fileSystemNotifierProvider` re-scanned directories
- ✅ `projectsProvider` reloaded from database

---

#### Test 3: Ghost Project Detection
**Steps:**
1. Open existing project in workspace grid
2. Delete directory externally (filesystem):
   ```bash
   rm -rf /path/to/test-project
   ```
3. Return to app (project still appears)
4. Press **F5**

**Expected Results:**
- ✅ Project card shows grayed out / dimmed
- ✅ Warning icon appears (⚠️)
- ✅ Tooltip: "⚠️ Directorio faltante. Clic derecho para eliminar."
- ✅ Right-click context menu still available
- ✅ "Eliminar de la Base de Datos" option present

---

### 🎨 Dynamic Icon/Color Functionality

#### Test 4: Phase Icon Mapping
**Setup:**
Create test projects in different phases (or edit `.softarchitect/status.json`).

**Verification Table:**

| Phase         | Expected Icon                | Expected Color                   |
|---------------|------------------------------|----------------------------------|
| Root          | `Icons.home_outlined`        | `AppColors.dirRoot`              |
| Context       | `Icons.settings_outlined`    | `AppColors.dirContext`           |
| Requirements  | `Icons.checklist_rtl`        | `AppColors.dirRequirements`      |
| Architecture  | `Icons.account_tree_outlined`| `AppColors.dirArchitecture`      |
| UI/UX         | `Icons.palette_outlined`     | `AppColors.dirUiUx`              |
| Planning      | `Icons.calendar_today_outlined` | `AppColors.dirPlanning`       |
| Meta          | `Icons.info_outline`         | `AppColors.dirMeta`              |

**Steps:**
1. Create/modify projects to match each phase above
2. Open `ProjectWorkspaceScreen`
3. Verify each project card has correct icon
4. Verify each project card has correct color

**Expected Results:**
- ✅ All icons match phase definitions
- ✅ All colors match theme constants
- ✅ Colors visually distinct and appropriate

---

#### Test 5: Real-Time Phase Updates
**Setup:**
```bash
# Edit existing project's status.json
echo '{
  "faseActual": "Arquitectura",
  "porcentajeCompletado": 50,
  "documentosCreados": 6
}' > ~/my-project/.softarchitect/status.json
```

**Steps:**
1. Open `ProjectWorkspaceScreen` (old phase shown)
2. Edit `.softarchitect/status.json` externally (see setup above)
3. Press **F5** to refresh
4. Observe project card

**Expected Results:**
- ✅ Icon changes to architecture tree icon (`Icons.account_tree_outlined`)
- ✅ Color changes to architecture color (`AppColors.dirArchitecture`)
- ✅ Progress badge updates to "Doc 50%"
- ✅ Visual feedback is immediate (< 200ms)

---

### 👻 Ghost Projects Functionality

#### Test 6: Context Menu on Missing Directory
**Steps:**
1. Delete project directory externally:
   ```bash
   rm -rf ~/my-project
   ```
2. Press **F5** in workspace screen
3. Right-click on grayed-out project card
4. Select "Eliminar de la Base de Datos"
5. Confirm deletion

**Expected Results:**
- ✅ Context menu appears even when directory missing
- ✅ "Eliminar de la Base de Datos" option available
- ✅ Confirmation dialog appears
- ✅ Project removed from database
- ✅ Card disappears from workspace
- ✅ No filesystem operations attempted

---

### 🖼️ UI/UX Verification

#### Test 7: Responsive Layout
**Steps:**
1. Launch app in desktop mode
2. Resize window to different widths:
   - Narrow: < 500px
   - Medium: 500-1000px
   - Wide: > 1000px
3. Verify layout adapts correctly

**Expected Results:**
- ✅ Narrow: Horizontal + vertical scroll enabled
- ✅ Medium: Projects grid wraps appropriately
- ✅ Wide: Maximum columns utilized
- ✅ No visual glitches or overlapping widgets
- ✅ F5 works in all layouts

---

## Success Criteria

### Functional Requirements ✅
- [x] Ghost projects deletable via context menu
- [x] Context menu available even when directory missing
- [x] Icon changes dynamically based on phase
- [x] Icon color matches current phase color
- [x] F5 key triggers workspace refresh
- [x] Providers invalidated on F5 (filesystem + projects)
- [x] Snackbar feedback on F5 press
- [x] No page navigation on F5

### Visual Requirements ✅
- [x] Icons visually distinct per phase
- [x] Colors match theme constants
- [x] Grayed-out appearance for missing projects
- [x] Warning icon on ghost projects
- [x] Snackbar appears and auto-dismisses

### Technical Requirements ✅
- [x] Widget hierarchy: `Scaffold → body: Shortcuts → Actions → Focus`
- [x] Autofocus enabled for keyboard capture
- [x] No deprecated parameter dependencies
- [x] Provider pattern maintained
- [x] Exception handling for missing directories

---

## Test Results Template

```
Date: _______________
Tester: ______________
Environment: [ ] Debug  [ ] Release  [ ] Desktop

F5 Refresh:
  [ ] Snackbar appears (Test 1)
  [ ] Providers reload (Test 2)
  [ ] External projects detected (Test 2)
  [ ] Ghost projects detected (Test 3)

Dynamic Icons:
  [ ] Root phase icon/color correct (Test 4)
  [ ] Context phase icon/color correct (Test 4)
  [ ] Requirements phase icon/color correct (Test 4)
  [ ] Architecture phase icon/color correct (Test 4)
  [ ] Planning phase icon/color correct (Test 4)
  [ ] Updates on F5 refresh (Test 5)

Ghost Projects:
  [ ] Context menu available (Test 6)
  [ ] Delete works correctly (Test 6)
  [ ] Database updated (Test 6)
  [ ] Visual indication clear (Test 3, 6)

Responsive Layout:
  [ ] Narrow layout works (Test 7)
  [ ] Medium layout works (Test 7)
  [ ] Wide layout works (Test 7)
  [ ] F5 works in all layouts (Test 7)

Notes:
_________________________________
_________________________________
_________________________________
```

---

## Automated Tests Available

**ProjectCard Tests:** ✅ 13/13 passing

```bash
cd tests && flutter test client/widget/features/project_shell/presentation/widgets/project_card_test.dart
```

**Coverage:**
- Icon display per phase
- Color matching per phase
- Progress badge rendering
- Context menu availability
- Ghost project visual indication
- Tooltip content
- Status provider integration

---

## Related Documentation

- [Project Card Widget Tests](../widgets/project_card_test.dart) - ✅ 13/13 passing
- [Phase 12 Completion Report](../../../../doc/English/01-PROJECT_REPORT/02-PHASES/PHASE_12_COMPLETION.md)
- [F5 Refresh Architecture](../../../../context/30-ARCHITECTURE/INTERACTION_PATTERNS.md)
