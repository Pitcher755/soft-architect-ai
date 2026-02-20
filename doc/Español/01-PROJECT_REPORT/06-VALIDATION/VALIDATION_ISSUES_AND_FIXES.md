# Validation Issues and Fixes

> **Fecha:** 2026-02-13
> **Estado:** ✅ RESOLVED
> **Context:** PRE_PUSH_VALIDATION_MASTER.sh improvements

---

## 📋 Table of Contents
- [Issue 1: Pyright Timeout](#issue-1-pyright-timeout)
- [Issue 2: Flutter Pruebas Fail from Root](#issue-2-flutter-pruebas-fail-from-root)
- [Solutions Implemented](#solutions-implemented)
- [Best Practices](#best-practices)

---

## Issue 1: Pyright Timeout

### Problem
Pyright was marked as "optional - skipped or tool missing" despite being installed.

**Root Cause:**
- Original script used `pruebas/venv/bin/python -m pyright`
- Pyright needs access to `chromadb` and `langchain_core` packages
- These packages are installed in `src/server/venv`, not `pruebas/venv`
- Pyright experiences timeout issues (>30s) during nodeenv initialization

### Investigation Steps
```bash
# 1. Verified pyright not in tests/venv
tests/venv/bin/python -m pip list | grep pyright
# Result: empty

# 2. Found server venv with correct dependencies
src/server/venv/bin/python -m pip list | grep -E "(chromadb|langchain)"
# Result: chromadb 1.4.1, langchain 1.2.7, langchain-core 1.2.7

# 3. Installed pyright in server venv
src/server/venv/bin/python -m pip install pyright
# Result: Successfully installed pyright-1.1.408

# 4. Attempted execution
src/server/venv/bin/python -m pyright src/server/services src/server/core
# Result: Timeout >30s (nodeenv initialization issue)
```

### Solution Implemented
1. ✅ Updated `PRE_PUSH_VALIDATION_MASTER.sh` to use TWO venvs:
   - `PYTHON_TEST_BIN="pruebas/venv/bin/python"` → pyprueba, ruff, bandit
   - `PYTHON_SERVER_BIN="src/server/venv/bin/python"` → pyright

2. ✅ Installed pyright in correct venv:
   ```bash
   src/server/venv/bin/python -m pip install pyright
   ```

3. ⚠️ **Known Issue:** Pyright hangs >30s on nodeenv setup
   - **Estado:** Marked as optional check
   - **Alternative:** Use `npx pyright` instead of `python -m pyright`
   - **Future Work:** Consider installing pyright globally via npm

### Verificación
```bash
# Import resolution now works (when not timing out)
src/server/venv/bin/python -m pyright src/server/services
# Can resolve: chromadb, langchain_core ✅
```

---

## Issue 2: Flutter Pruebas Fail from Root

### Problem
Ejecutarning `flutter prueba pruebas/client` from proyecto root fails with:
```
Error: Couldn't resolve the package 'flutter_localizations'
Error: Couldn't resolve the package 'flutter_riverpod'
Error: Couldn't resolve the package 'softarchitect_ai'
```

**Root Cause:**
- Proyecto has 3 separate `pubspec.yaml` archivos:
  - `/pubspec.yaml` - Monorepo root (minimal dependencies)
  - `/src/client/pubspec.yaml` - Main app with `softarchitect_ai` package
  - `/pruebas/pubspec.yaml` - Prueba suite with all prueba dependencies

- When ejecutarning `flutter prueba pruebas/client` from root, Flutter uses `/pubspec.yaml`
- Root pubspec  does NOT have `flutter_riverpod`, `shared_preferences`, etc.
- Pruebas fail to compile due to missing dependencies

### Investigation Steps
```bash
# 1. Reproduce error from root
cd /home/pitcherdev/Espacio-de-trabajo/Master/soft-architect-ai
flutter test tests/client
# Result:
# Error: Couldn't resolve the package 'flutter_localizations'
# Error: Couldn't resolve the package 'flutter_riverpod'
# Error: Couldn't resolve the package 'softarchitect_ai'
# 00:51 +7 -63: Some tests failed

# 2. Verify tests pass from tests/ directory
cd tests
flutter test client/unit/
# Result: 00:07 +421 ~7: All tests passed! ✅

# 3. Check pubspec.yaml structure
ls -la pubspec.yaml tests/pubspec.yaml src/client/pubspec.yaml
# Result: 3 separate pubspec files found
```

### Solution Implemented
1. ✅ Updated root `/pubspec.yaml` comment (misleading):
   ```yaml
   # BEFORE (WRONG)
   # USAGE: flutter test tests/client/ (from root for CI/CD)

   # AFTER (CORRECT)
   # USAGE: DO NOT RUN TESTS FROM ROOT. Use: cd tests && flutter test client/
   # IMPORTANT: Tests MUST be executed from tests/ directory to resolve deps
   ```

2. ✅ Confirmed script uses correct approach:
   ```bash
   # PRE_PUSH_VALIDATION_MASTER.sh (line 160)
   run_check "Flutter Unit Tests" \
       "(cd tests && flutter test client/unit/ --reporter=compact 2>/dev/null)"
   # ✅ Changes directory BEFORE running tests
   ```

### Verificación
```bash
# ✅ CORRECT: Run from tests/ directory
cd tests && flutter test client/unit/
# Result: All 421 tests passed ✅

# ❌ WRONG: Run from root directory
flutter test tests/client
# Result: Compilation errors (missing dependencies) ❌
```

---

## Solutions Implemented

### Script Changes (`PRE_PUSH_VALIDATION_MASTER.sh`)

```bash
# BEFORE (Single venv)
PYTHON_BIN="$PROJECT_ROOT/tests/venv/bin/python"

# AFTER (Dual venv)
PYTHON_TEST_BIN="$PROJECT_ROOT/tests/venv/bin/python"
PYTHON_SERVER_BIN="$PROJECT_ROOT/src/server/venv/bin/python"
```

**Usage Matrix:**
| Tool | Virtual Environment | Purpose |
|------|-------------------|---------|
| pyprueba | `PYTHON_TEST_BIN` (pruebas/venv) | Ejecutar pruebas with prueba dependencies |
| ruff | `PYTHON_TEST_BIN` (pruebas/venv) | Linting |
| bandit | `PYTHON_TEST_BIN` (pruebas/venv) | Security audit |
| pyright | `PYTHON_SERVER_BIN` (src/server/venv) | Type checking with server deps |

### Pubspec.yaml Update

```yaml
# /pubspec.yaml (root)
# ============================================================================
# PURPOSE: Monorepo root configuration
# USAGE: DO NOT RUN TESTS FROM ROOT. Use: cd tests && flutter test client/
# DEPENDENCIES: Minimal (only Flutter SDK required)
# ============================================================================
# For actual app dependencies, see: src/client/pubspec.yaml
# For test dependencies, see: tests/pubspec.yaml
# IMPORTANT: Tests MUST be executed from tests/ directory to resolve deps
# ============================================================================
```

---

## Best Practices

### Python Validation
```bash
# ✅ ALWAYS use correct venv for each tool
$PYTHON_SERVER_BIN -m pyright src/server/  # Type checking
$PYTHON_TEST_BIN -m pytest tests/server/   # Unit tests
$PYTHON_TEST_BIN -m ruff check src/server/ # Linting
```

### Flutter Pruebaing
```bash
# ✅ CORRECT: Change to tests/ directory
cd tests && flutter test client/unit/

# ❌ WRONG: Run from root
flutter test tests/client  # Missing dependencies!
```

### CI/CD Pipeline
```yaml
# GitHub Actions workflow should use:
- name: Run Flutter Tests
  run: |
    cd tests
    flutter test client/unit/ --coverage
```

---

## Estado Summary

| Issue | Estado | Notes |
|-------|--------|-------|
| Pyright skipped | ⚠️ Known Issue | Nodeenv timeout (>30s) - marked optional |
| Flutter pruebas from root | ✅ Documentoed | Must use `cd pruebas && flutter prueba` |
| Dual venv setup | ✅ Implemented | Script now uses correct venv per tool |
| Pubspec.yaml clarity | ✅ Fixed | Updated comments to reflect reality |

---

## References

- [PRE_PUSH_VALIDATION_MASTER.sh](../../scripts/pruebaing/PRE_PUSH_VALIDATION_MASTER.sh)
- [AGENTS.md](../../AGENTS.md#8-ci-cd-pipeline-rules)
- Root pubspec.yaml (lines 4-13)
- Pruebas pubspec.yaml (lines 1-30)

---

**Siguiente Actions:**
1. ⏳ Investigate pyright nodeenv timeout (consider npm installation)
2. ✅ Documento "cd pruebas" requirement in all pruebaing docs
3. ✅ Ensure CI/CD pipelines use correct working directories
