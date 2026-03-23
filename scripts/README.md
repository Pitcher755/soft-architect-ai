# 🛠️ Scripts Directory | Directorio de Scripts

<div align="center">

**[🇬🇧 English](#english)** | **[🇪🇸 Español](#español)**

Automation Scripts for SoftArchitect AI Project

</div>

---

<div id="english">

# 🇬🇧 English

## 📖 Table of Contents

- [Overview](#overview)
- [Categories](#categories)
- [Scripts Reference](#scripts-reference)
  - [Testing Scripts](#testing-scripts)
  - [DevOps Scripts](#devops-scripts)
  - [Quality Scripts](#quality-scripts)
  - [Workflow Scripts](#workflow-scripts)
  - [Maintenance Scripts](#maintenance-scripts)
  - [Setup Scripts](#setup-scripts)
- [Compliance](#compliance)
- [Quick Start](#quick-start)
- [Troubleshooting](#troubleshooting)

---

## 🎯 Overview

This directory contains **all automation scripts** for the SoftArchitect AI project. Scripts are organized by function and follow strict standards defined in [AGENTS.md](../AGENTS.md).

**Key Principles:**
- ✅ **MANDATORY:** All scripts follow AGENTS.md section 8 rules
- 🎯 **Single Responsibility:** Each script has one clear purpose
- 📏 **Coverage Rules:** Testing scripts MUST use canonical coverage locations
- 🔒 **Safety First:** All scripts use `set -e` and proper error handling
- 📚 **Self-Documenting:** Headers explain purpose, usage, and requirements

---

## 📂 Categories

| Category | Path | Purpose |
|----------|------|---------|
| **Testing** | `testing/` | Test execution, coverage generation, validation |
| **DevOps** | `devops/` | Stack management, app launching |
| **Quality** | `quality/` | Quality gates, linting, compliance |
| **Workflows** | `workflows/` | GitHub Actions local testing |
| **Maintenance** | `maintenance/` | Documentation organization, cleanup |
| **Setup** | `setup/` | Project initial setup |

---

## 📋 Scripts Reference

### 🧪 Testing Scripts

Located in: `scripts/testing/`

#### `PRE_PUSH_VALIDATION_MASTER.sh` ⭐ **CRITICAL**

**Purpose:** Master validation script. Run BEFORE EVERY PUSH to ensure all quality gates pass.

**What it validates:**
1. Code Formatting (Black, Dart format)
2. Linting (Ruff, Dart analysis)
3. Type Checking (Pyright, Dart)
4. Unit Tests (Python, Flutter)
5. Integration Tests
6. Security Audit (Bandit)
7. Code Coverage (≥80%)
8. Build Validation

**Usage:**
```bash
./scripts/testing/PRE_PUSH_VALIDATION_MASTER.sh
```

**Exit Codes:**
- `0` = All checks passed ✅ SAFE TO PUSH
- `1` = One or more checks failed ❌ DO NOT PUSH

**Coverage Output:**
- Python: `coverage_html/index.html` (canonical location)
- Flutter: `coverage/lcov.info` (canonical location)

**Requirements:**
- Python 3.12+ with venv at `tests/venv/`
- Flutter SDK
- Pyright, Black, Ruff installed
- Docker (for backend tests)

**Reference:** AGENTS.md § 8.L

---

#### `run_tests.sh`

**Purpose:** Unified test runner for Flutter and Python with optional coverage.

**Modes:**
- `all` - Run both Flutter and Python tests
- `flutter` - Run only Flutter tests
- `python` - Run only Python tests

**Flags:**
- `--coverage` - Generate coverage reports

**Usage:**
```bash
# Run all tests with coverage
./scripts/testing/run_tests.sh all --coverage

# Run only Python tests
./scripts/testing/run_tests.sh python

# Run only Flutter tests
./scripts/testing/run_tests.sh flutter --coverage
```

**Coverage Output (MANDATORY locations):**
- Python: `PROJECT_ROOT/coverage_html/` (HTML + JSON)
- Flutter: `PROJECT_ROOT/coverage/` (lcov.info)

**Reference:** AGENTS.md § 8.M

---

#### `generate_coverage_html.sh`

**Purpose:** Generate Flutter coverage HTML report with visual breakdown.

**What it does:**
1. Cleans previous coverage data
2. Runs `flutter test --coverage` from tests/ directory
3. Moves coverage to canonical location: `PROJECT_ROOT/coverage/`
4. Generates HTML report with `genhtml`

**Usage:**
```bash
./scripts/testing/generate_coverage_html.sh
```

**Output:** `coverage/html/index.html`

**Requirements:**
- Flutter SDK
- `lcov` package (auto-installed if missing: `sudo apt install lcov`)

**Coverage Rule:** Flutter coverage MUST be in `PROJECT_ROOT/coverage/` ONLY. Generating coverage elsewhere is **FORBIDDEN** per AGENTS.md § 8.M.

---

#### `RUN_COMPLETE_TEST_SUITE.sh`

**Purpose:** Legacy wrapper for `run_tests.sh all --coverage`. Kept for backward compatibility.

**Usage:**
```bash
./scripts/testing/RUN_COMPLETE_TEST_SUITE.sh
```

---

### 🐳 DevOps Scripts

Located in: `scripts/devops/`

#### `start_stack.sh`

**Purpose:** Start Docker infrastructure (ChromaDB, FastAPI backend, Nginx).

**What it does:**
1. Runs pre-flight checks (`infrastructure/pre_check.py`)
2. Ensures `.env` file exists (creates from `.env.example` if missing)
3. Starts Docker Compose stack
4. Validates all services are healthy

**Usage:**
```bash
./scripts/devops/start_stack.sh
```

**Services Started:**
- `chromadb` - Vector database (port 8001)
- `sa_api` - FastAPI backend (port 8000)
- `nginx` - Reverse proxy (port 80)

**Requirements:**
- Docker & Docker Compose
- `.env.example` file (for auto-generation)

**Verification:**
```bash
# Check services
docker compose --env-file .env -f infrastructure/docker-compose.yml ps

# Test backend
curl http://localhost:8000/health
```

---

#### `stop_stack.sh`

**Purpose:** Clean shutdown of Docker stack.

**What it does:**
- Stops all containers
- Removes containers
- Preserves volumes (data persistence)

**Usage:**
```bash
./scripts/devops/stop_stack.sh
```

---

#### `LAUNCH_FLUTTER_APP_DEV.sh`

**Purpose:** Launch Flutter desktop app in development mode.

**What it does:**
1. Validates Flutter installation
2. Verifies project structure
3. Runs `flutter analyze` to check for errors
4. Launches app with `flutter run -d linux`

**Usage:**
```bash
./scripts/devops/LAUNCH_FLUTTER_APP_DEV.sh
```

**Requirements:**
- Flutter SDK
- Linux desktop target enabled
- Valid `src/client/` directory

**Target:** Desktop (Linux)

---

#### `LAUNCH_FLUTTER_APP_E2E.sh`

**Purpose:** Launch Flutter app connected to real Docker backend for E2E testing.

**What it does:**
1. Checks Docker backend is running
2. Offers to start backend if not running
3. Validates backend health (`/health` endpoint)
4. Launches app with real backend configuration

**Usage:**
```bash
./scripts/devops/LAUNCH_FLUTTER_APP_E2E.sh
```

**Configuration:**
- `USE_REAL_BACKEND=true`
- `BACKEND_BASE_URL=http://localhost:8000`

**Requirements:**
- Docker backend running (`start_stack.sh`)
- Backend health endpoint responding

---

### ✅ Quality Scripts

Located in: `scripts/quality/`

#### `validate-quality-gates.sh`

**Purpose:** Quick local validation of code quality standards.

**What it checks:**
1. Flutter Analysis (static analysis)
2. Code Formatting (dart format)
3. Linting (flutter_lints)
4. Build Compilation (debug build)

**Usage:**
```bash
./scripts/quality/validate-quality-gates.sh
```

**Exit Code:**
- `0` = All gates passed
- Non-zero = Quality issues found

**Note:** This is a SUBSET of `PRE_PUSH_VALIDATION_MASTER.sh`. Use the master script before pushing.

---

#### `audit-english-compliance.sh`

**Purpose:** Audit code files for English compliance (comments, naming, documentation).

**What it audits:**
- Python files in `src/server/`
- Checks for non-English comments or variable names
- Validates docstrings are in English

**Usage:**
```bash
./scripts/quality/audit-english-compliance.sh
```

**Rule:** Per AGENTS.md § 8.6: All code MUST be in English (comments, variables, docs).

---

### 🔄 Workflow Scripts

Located in: `scripts/workflows/`

#### `test-workflows-locally.sh`

**Purpose:** Test GitHub Actions workflows locally using `act` runner.

**What it does:**
1. Lists all available workflows
2. Allows interactive job selection
3. Runs workflow in Docker container
4. Shows logs and results

**Usage:**
```bash
./scripts/workflows/test-workflows-locally.sh
```

**Requirements:**
- Docker
- `act` CLI tool ([Installation](https://github.com/nektos/act))
  ```bash
  curl -s https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
  ```

**Use Case:** Test `.github/workflows/*.yaml` configurations before pushing.

---

#### `validate-workflows.sh`

**Purpose:** Quick validation of GitHub Actions workflow syntax.

**What it checks:**
- YAML syntax validity
- Required workflow sections
- Job definitions
- Step structure

**Usage:**
```bash
./scripts/workflows/validate-workflows.sh
```

---

### 🧹 Maintenance Scripts

Located in: `scripts/maintenance/`

#### `cleanup_coverage.sh` ⭐ **NEW**

**Purpose:** Remove scattered coverage directories, keeping only canonical locations.

**What it does:**
1. Finds all coverage directories outside canonical paths
2. Shows list of directories to be removed
3. Asks for confirmation
4. Removes scattered directories
5. Preserves `coverage/` and `coverage_html/` only

**Usage:**
```bash
./scripts/maintenance/cleanup_coverage.sh
```

**Canonical Locations (MANDATORY per AGENTS.md § 8.M):**
- Flutter: `PROJECT_ROOT/coverage/`
- Python: `PROJECT_ROOT/coverage_html/`

**Why:** Prevents coverage report chaos. Ensures single source of truth.

---

#### `organize_docs.sh`

**Purpose:** Organize documentation files from root to structured `doc/` folders.

**What it does:**
- Moves report files to `doc/01-PROJECT_REPORT/`
- Moves setup guides to `doc/02-SETUP_DEV/`
- Deletes obsolete duplicates
- Preserves root-level files (README.md, AGENTS.md)

**Usage:**
```bash
./scripts/maintenance/organize_docs.sh
```

**Reference:** AGENTS.md § 8 (Documentation Standards)

---

#### `STATUS_DASHBOARD.sh`

**Purpose:** Display project status dashboard (visual overview).

**What it shows:**
- Branch status
- Commit count
- Document count
- Completed tasks
- Pending decisions

**Usage:**
```bash
./scripts/maintenance/STATUS_DASHBOARD.sh
```

**Note:** Read-only informational script. Does not modify files.

---

### ⚙️ Setup Scripts

Located in: `scripts/setup/`

#### `setup_project.sh`

**Purpose:** Initial project setup automation.

**What it does:**
1. Creates necessary directories
2. Installs Python dependencies (venv)
3. Installs Flutter dependencies
4. Configures Docker environment
5. Validates installation

**Usage:**
```bash
./scripts/setup/setup_project.sh
```

**Requirements:**
- Python 3.12+
- Flutter SDK
- Docker

**First Time Setup:** Run this ONCE when cloning the repository.

---

## ✅ Compliance

All scripts in this directory follow:

1. **AGENTS.md § 8:** CI/CD Pipeline Rules
2. **AGENTS.md § 8.M:** Coverage Report Standards (**NEW**)
3. **Bash Best Practices:**
   - `set -e` at script start
   - Proper variable quoting (`"$VAR"`)
   - Error handling for critical operations
   - Self-documenting headers

### Coverage Standards Enforcement

**MANDATORY locations (per AGENTS.md § 8.M):**

| Language | Location | Format |
|----------|----------|--------|
| Flutter | `PROJECT_ROOT/coverage/` | `lcov.info`, `html/` |
| Python | `PROJECT_ROOT/coverage_html/` | `index.html`, `coverage.json` |

**FORBIDDEN locations:**
- ❌ `tests/coverage/`
- ❌ `src/client/coverage/`
- ❌ `src/server/htmlcov/`
- ❌ `/tmp/python_cov.json` (for persistent reports)
- ❌ Any `htmlcov*` variants

**Validation:**
```bash
# This command should find ONLY the two canonical directories
find . -maxdepth 2 -type d -name "coverage*" -o -name "htmlcov*" 2>/dev/null
# Expected output:
# ./coverage
# ./coverage_html
```

---

## 🚀 Quick Start

### Daily Development Workflow

```bash
# 1. Start backend (if needed)
./scripts/devops/start_stack.sh

# 2. Launch Flutter app
./scripts/devops/LAUNCH_FLUTTER_APP_DEV.sh

# 3. Make code changes
# ...

# 4. BEFORE COMMITTING: Run validation
./scripts/testing/PRE_PUSH_VALIDATION_MASTER.sh

# 5. If validation passes, commit and push
git add -A
git commit -m "feat: my feature"
git push origin feature/my-branch
```

### Testing Workflow

```bash
# Run all tests with coverage
./scripts/testing/run_tests.sh all --coverage

# View Python coverage
xdg-open coverage_html/index.html

# Generate Flutter coverage HTML
./scripts/testing/generate_coverage_html.sh
xdg-open coverage/html/index.html
```

### Before Opening PR

```bash
# 1. Run COMPLETE validation
./scripts/testing/PRE_PUSH_VALIDATION_MASTER.sh

# 2. Test workflows locally
./scripts/workflows/test-workflows-locally.sh

# 3. Verify quality gates
./scripts/quality/validate-quality-gates.sh

# 4. Clean up coverage chaos (if needed)
./scripts/maintenance/cleanup_coverage.sh
```

---

## 🔧 Troubleshooting

### Script Not Executable

```bash
# Make script executable
chmod +x scripts/path/to/script.sh
```

### Python venv Not Found

```bash
# Create venv for tests
cd tests
python3 -m venv venv
source venv/bin/activate
pip install -r ../requirements.txt
```

### Coverage Not Generated

**Problem:** Coverage reports not appearing in expected location.

**Solution:**
```bash
# Clean all scattered coverage directories
./scripts/maintenance/cleanup_coverage.sh

# Re-run tests with coverage
./scripts/testing/run_tests.sh all --coverage

# Verify canonical locations
ls -ld coverage/ coverage_html/
```

### Docker Backend Not Starting

```bash
# Check Docker status
docker compose --env-file .env -f infrastructure/docker-compose.yml ps

# View logs
docker compose --env-file .env -f infrastructure/docker-compose.yml logs

# Restart clean
./scripts/devops/stop_stack.sh
./scripts/devops/start_stack.sh
```

### Flutter Analyze Errors

```bash
# Run analysis from client directory
cd src/client
flutter analyze

# Fix formatting issues
dart format lib/ test/

# Get pub dependencies
flutter pub get
```

---

## 📚 References

- [AGENTS.md](../AGENTS.md) - Agent rules and standards
- [AGENTS.md § 8](../AGENTS.md#-8-reglas-estrictas-de-cicd-pipeline-mandatory) - CI/CD Pipeline Rules
- [AGENTS.md § 8.M](../AGENTS.md#m-coverage-report-standards---centralized-output-mandatory) - Coverage Standards
- [doc/02-SETUP_DEV/](../doc/English/02-SETUP_DEV/) - Setup guides
- [infrastructure/](../infrastructure/) - Docker configuration

---

</div>

<div id="español">

# 🇪🇸 Español

## 📖 Tabla de Contenidos

- [Resumen](#resumen)
- [Categorías](#categorías-1)
- [Referencia de Scripts](#referencia-de-scripts)
  - [Scripts de Testing](#scripts-de-testing)
  - [Scripts de DevOps](#scripts-de-devops)
  - [Scripts de Calidad](#scripts-de-calidad)
  - [Scripts de Workflows](#scripts-de-workflows)
  - [Scripts de Mantenimiento](#scripts-de-mantenimiento)
  - [Scripts de Setup](#scripts-de-setup)
- [Cumplimiento](#cumplimiento)
- [Inicio Rápido](#inicio-rápido)
- [Solución de Problemas](#solución-de-problemas)

---

## 🎯 Resumen

Este directorio contiene **todos los scripts de automatización** para el proyecto SoftArchitect AI. Los scripts están organizados por función y siguen estándares estrictos definidos en [AGENTS.md](../AGENTS.md).

**Principios Clave:**
- ✅ **OBLIGATORIO:** Todos los scripts siguen las reglas de AGENTS.md sección 8
- 🎯 **Responsabilidad Única:** Cada script tiene un propósito claro
- 📏 **Reglas de Cobertura:** Scripts de testing DEBEN usar ubicaciones canónicas
- 🔒 **Seguridad Primero:** Todos los scripts usan `set -e` y manejo de errores
- 📚 **Auto-Documentados:** Headers explican propósito, uso y requisitos

---

## 📂 Categorías

| Categoría | Ruta | Propósito |
|-----------|------|-----------|
| **Testing** | `testing/` | Ejecución de tests, generación de cobertura, validación |
| **DevOps** | `devops/` | Gestión de stack, lanzamiento de apps |
| **Quality** | `quality/` | Quality gates, linting, cumplimiento |
| **Workflows** | `workflows/` | Testing local de GitHub Actions |
| **Maintenance** | `maintenance/` | Organización de documentación, limpieza |
| **Setup** | `setup/` | Setup inicial del proyecto |

---

## 📋 Referencia de Scripts

### 🧪 Scripts de Testing

Ubicación: `scripts/testing/`

#### `PRE_PUSH_VALIDATION_MASTER.sh` ⭐ **CRÍTICO**

**Propósito:** Script maestro de validación. Ejecutar ANTES DE CADA PUSH para asegurar que todos los quality gates pasen.

**Qué valida:**
1. Formateo de Código (Black, Dart format)
2. Linting (Ruff, Dart analysis)
3. Type Checking (Pyright, Dart)
4. Tests Unitarios (Python, Flutter)
5. Tests de Integración
6. Auditoría de Seguridad (Bandit)
7. Cobertura de Código (≥80%)
8. Validación de Build

**Uso:**
```bash
./scripts/testing/PRE_PUSH_VALIDATION_MASTER.sh
```

**Códigos de Salida:**
- `0` = Todos los checks pasaron ✅ SEGURO HACER PUSH
- `1` = Uno o más checks fallaron ❌ NO HACER PUSH

**Salida de Cobertura:**
- Python: `coverage_html/index.html` (ubicación canónica)
- Flutter: `coverage/lcov.info` (ubicación canónica)

**Requisitos:**
- Python 3.12+ con venv en `tests/venv/`
- Flutter SDK
- Pyright, Black, Ruff instalados
- Docker (para tests de backend)

**Referencia:** AGENTS.md § 8.L

---

#### `run_tests.sh`

**Propósito:** Ejecutor unificado de tests para Flutter y Python con cobertura opcional.

**Modos:**
- `all` - Ejecutar tests de Flutter y Python
- `flutter` - Ejecutar solo tests de Flutter
- `python` - Ejecutar solo tests de Python

**Flags:**
- `--coverage` - Generar reportes de cobertura

**Uso:**
```bash
# Ejecutar todos los tests con cobertura
./scripts/testing/run_tests.sh all --coverage

# Ejecutar solo tests de Python
./scripts/testing/run_tests.sh python

# Ejecutar solo tests de Flutter
./scripts/testing/run_tests.sh flutter --coverage
```

**Salida de Cobertura (ubicaciones OBLIGATORIAS):**
- Python: `PROJECT_ROOT/coverage_html/` (HTML + JSON)
- Flutter: `PROJECT_ROOT/coverage/` (lcov.info)

**Referencia:** AGENTS.md § 8.M

---

#### `generate_coverage_html.sh`

**Propósito:** Generar reporte HTML de cobertura de Flutter con desglose visual.

**Qué hace:**
1. Limpia datos de cobertura previos
2. Ejecuta `flutter test --coverage` desde directorio tests/
3. Mueve cobertura a ubicación canónica: `PROJECT_ROOT/coverage/`
4. Genera reporte HTML con `genhtml`

**Uso:**
```bash
./scripts/testing/generate_coverage_html.sh
```

**Salida:** `coverage/html/index.html`

**Requisitos:**
- Flutter SDK
- Paquete `lcov` (se auto-instala si falta: `sudo apt install lcov`)

**Regla de Cobertura:** La cobertura de Flutter DEBE estar en `PROJECT_ROOT/coverage/` SOLAMENTE. Generar cobertura en otro lugar está **PROHIBIDO** según AGENTS.md § 8.M.

---

#### `RUN_COMPLETE_TEST_SUITE.sh`

**Propósito:** Wrapper legacy para `run_tests.sh all --coverage`. Mantenido por compatibilidad.

**Uso:**
```bash
./scripts/testing/RUN_COMPLETE_TEST_SUITE.sh
```

---

### 🐳 Scripts de DevOps

Ubicación: `scripts/devops/`

#### `start_stack.sh`

**Propósito:** Iniciar infraestructura Docker (ChromaDB, backend FastAPI, Nginx).

**Qué hace:**
1. Ejecuta checks previos (`infrastructure/pre_check.py`)
2. Asegura que existe archivo `.env` (crea desde `.env.example` si falta)
3. Inicia stack de Docker Compose
4. Valida que todos los servicios estén saludables

**Uso:**
```bash
./scripts/devops/start_stack.sh
```

**Servicios Iniciados:**
- `chromadb` - Base de datos vectorial (puerto 8001)
- `sa_api` - Backend FastAPI (puerto 8000)
- `nginx` - Reverse proxy (puerto 80)

**Requisitos:**
- Docker & Docker Compose
- Archivo `.env.example` (para auto-generación)

**Verificación:**
```bash
# Verificar servicios
docker compose --env-file .env -f infrastructure/docker-compose.yml ps

# Testear backend
curl http://localhost:8000/health
```

---

#### `stop_stack.sh`

**Propósito:** Apagado limpio del stack Docker.

**Qué hace:**
- Detiene todos los contenedores
- Elimina contenedores
- Preserva volúmenes (persistencia de datos)

**Uso:**
```bash
./scripts/devops/stop_stack.sh
```

---

#### `LAUNCH_FLUTTER_APP_DEV.sh`

**Propósito:** Lanzar app Flutter de escritorio en modo desarrollo.

**Qué hace:**
1. Valida instalación de Flutter
2. Verifica estructura del proyecto
3. Ejecuta `flutter analyze` para verificar errores
4. Lanza app con `flutter run -d linux`

**Uso:**
```bash
./scripts/devops/LAUNCH_FLUTTER_APP_DEV.sh
```

**Requisitos:**
- Flutter SDK
- Target de escritorio Linux habilitado
- Directorio `src/client/` válido

**Target:** Desktop (Linux)

---

#### `LAUNCH_FLUTTER_APP_E2E.sh`

**Propósito:** Lanzar app Flutter conectada al backend Docker real para testing E2E.

**Qué hace:**
1. Verifica que el backend Docker esté corriendo
2. Ofrece iniciar backend si no está corriendo
3. Valida salud del backend (endpoint `/health`)
4. Lanza app con configuración de backend real

**Uso:**
```bash
./scripts/devops/LAUNCH_FLUTTER_APP_E2E.sh
```

**Configuración:**
- `USE_REAL_BACKEND=true`
- `BACKEND_BASE_URL=http://localhost:8000`

**Requisitos:**
- Backend Docker corriendo (`start_stack.sh`)
- Endpoint de salud del backend respondiendo

---

### ✅ Scripts de Calidad

Ubicación: `scripts/quality/`

#### `validate-quality-gates.sh`

**Propósito:** Validación local rápida de estándares de calidad de código.

**Qué verifica:**
1. Análisis Flutter (análisis estático)
2. Formateo de Código (dart format)
3. Linting (flutter_lints)
4. Compilación Build (debug build)

**Uso:**
```bash
./scripts/quality/validate-quality-gates.sh
```

**Código de Salida:**
- `0` = Todos los gates pasaron
- No-cero = Se encontraron problemas de calidad

**Nota:** Este es un SUBCONJUNTO de `PRE_PUSH_VALIDATION_MASTER.sh`. Usar el script maestro antes de hacer push.

---

#### `audit-english-compliance.sh`

**Propósito:** Auditar archivos de código para cumplimiento de inglés (comentarios, nombres, documentación).

**Qué audita:**
- Archivos Python en `src/server/`
- Verifica comentarios o nombres de variables no en inglés
- Valida que docstrings estén en inglés

**Uso:**
```bash
./scripts/quality/audit-english-compliance.sh
```

**Regla:** Según AGENTS.md § 8.6: Todo el código DEBE estar en inglés (comentarios, variables, docs).

---

### 🔄 Scripts de Workflows

Ubicación: `scripts/workflows/`

#### `test-workflows-locally.sh`

**Propósito:** Testear workflows de GitHub Actions localmente usando runner `act`.

**Qué hace:**
1. Lista todos los workflows disponibles
2. Permite selección interactiva de job
3. Ejecuta workflow en contenedor Docker
4. Muestra logs y resultados

**Uso:**
```bash
./scripts/workflows/test-workflows-locally.sh
```

**Requisitos:**
- Docker
- Herramienta CLI `act` ([Instalación](https://github.com/nektos/act))
  ```bash
  curl -s https://raw.githubusercontent.com/nektos/act/master/install.sh | sudo bash
  ```

**Caso de Uso:** Testear configuraciones de `.github/workflows/*.yaml` antes de hacer push.

---

#### `validate-workflows.sh`

**Propósito:** Validación rápida de sintaxis de workflows de GitHub Actions.

**Qué verifica:**
- Validez de sintaxis YAML
- Secciones de workflow requeridas
- Definiciones de jobs
- Estructura de steps

**Uso:**
```bash
./scripts/workflows/validate-workflows.sh
```

---

### 🧹 Scripts de Mantenimiento

Ubicación: `scripts/maintenance/`

#### `cleanup_coverage.sh` ⭐ **NUEVO**

**Propósito:** Eliminar directorios de cobertura dispersos, manteniendo solo ubicaciones canónicas.

**Qué hace:**
1. Encuentra todos los directorios de cobertura fuera de paths canónicos
2. Muestra lista de directorios a eliminar
3. Pide confirmación
4. Elimina directorios dispersos
5. Preserva solo `coverage/` y `coverage_html/`

**Uso:**
```bash
./scripts/maintenance/cleanup_coverage.sh
```

**Ubicaciones Canónicas (OBLIGATORIAS según AGENTS.md § 8.M):**
- Flutter: `PROJECT_ROOT/coverage/`
- Python: `PROJECT_ROOT/coverage_html/`

**Por qué:** Previene caos en reportes de cobertura. Asegura una única fuente de verdad.

---

#### `organize_docs.sh`

**Propósito:** Organizar archivos de documentación desde raíz a carpetas estructuradas en `doc/`.

**Qué hace:**
- Mueve archivos de reportes a `doc/01-PROJECT_REPORT/`
- Mueve guías de setup a `doc/02-SETUP_DEV/`
- Elimina duplicados obsoletos
- Preserva archivos de nivel raíz (README.md, AGENTS.md)

**Uso:**
```bash
./scripts/maintenance/organize_docs.sh
```

**Referencia:** AGENTS.md § 8 (Estándares de Documentación)

---

#### `STATUS_DASHBOARD.sh`

**Propósito:** Mostrar dashboard de estado del proyecto (vista general visual).

**Qué muestra:**
- Estado del branch
- Conteo de commits
- Conteo de documentos
- Tareas completadas
- Decisiones pendientes

**Uso:**
```bash
./scripts/maintenance/STATUS_DASHBOARD.sh
```

**Nota:** Script informacional de solo lectura. No modifica archivos.

---

### ⚙️ Scripts de Setup

Ubicación: `scripts/setup/`

#### `setup_project.sh`

**Propósito:** Automatización de setup inicial del proyecto.

**Qué hace:**
1. Crea directorios necesarios
2. Instala dependencias Python (venv)
3. Instala dependencias Flutter
4. Configura entorno Docker
5. Valida instalación

**Uso:**
```bash
./scripts/setup/setup_project.sh
```

**Requisitos:**
- Python 3.12+
- Flutter SDK
- Docker

**Setup por Primera Vez:** Ejecutar esto UNA VEZ al clonar el repositorio.

---

## ✅ Cumplimiento

Todos los scripts en este directorio siguen:

1. **AGENTS.md § 8:** Reglas de Pipeline CI/CD
2. **AGENTS.md § 8.M:** Estándares de Reportes de Cobertura (**NUEVO**)
3. **Mejores Prácticas Bash:**
   - `set -e` al inicio del script
   - Comillas apropiadas en variables (`"$VAR"`)
   - Manejo de errores para operaciones críticas
   - Headers auto-documentados

### Cumplimiento de Estándares de Cobertura

**Ubicaciones OBLIGATORIAS (según AGENTS.md § 8.M):**

| Lenguaje | Ubicación | Formato |
|----------|-----------|---------|
| Flutter | `PROJECT_ROOT/coverage/` | `lcov.info`, `html/` |
| Python | `PROJECT_ROOT/coverage_html/` | `index.html`, `coverage.json` |

**Ubicaciones PROHIBIDAS:**
- ❌ `tests/coverage/`
- ❌ `src/client/coverage/`
- ❌ `src/server/htmlcov/`
- ❌ `/tmp/python_cov.json` (para reportes persistentes)
- ❌ Cualquier variante de `htmlcov*`

**Validación:**
```bash
# Este comando debería encontrar SOLO los dos directorios canónicos
find . -maxdepth 2 -type d -name "coverage*" -o -name "htmlcov*" 2>/dev/null
# Salida esperada:
# ./coverage
# ./coverage_html
```

---

## 🚀 Inicio Rápido

### Flujo de Trabajo de Desarrollo Diario

```bash
# 1. Iniciar backend (si es necesario)
./scripts/devops/start_stack.sh

# 2. Lanzar app Flutter
./scripts/devops/LAUNCH_FLUTTER_APP_DEV.sh

# 3. Hacer cambios en código
# ...

# 4. ANTES DE COMMITEAR: Ejecutar validación
./scripts/testing/PRE_PUSH_VALIDATION_MASTER.sh

# 5. Si la validación pasa, commitear y hacer push
git add -A
git commit -m "feat: mi feature"
git push origin feature/mi-branch
```

### Flujo de Trabajo de Testing

```bash
# Ejecutar todos los tests con cobertura
./scripts/testing/run_tests.sh all --coverage

# Ver cobertura de Python
xdg-open coverage_html/index.html

# Generar HTML de cobertura de Flutter
./scripts/testing/generate_coverage_html.sh
xdg-open coverage/html/index.html
```

### Antes de Abrir PR

```bash
# 1. Ejecutar validación COMPLETA
./scripts/testing/PRE_PUSH_VALIDATION_MASTER.sh

# 2. Testear workflows localmente
./scripts/workflows/test-workflows-locally.sh

# 3. Verificar quality gates
./scripts/quality/validate-quality-gates.sh

# 4. Limpiar caos de cobertura (si es necesario)
./scripts/maintenance/cleanup_coverage.sh
```

---

## 🔧 Solución de Problemas

### Script No Ejecutable

```bash
# Hacer script ejecutable
chmod +x scripts/ruta/del/script.sh
```

### Python venv No Encontrado

```bash
# Crear venv para tests
cd tests
python3 -m venv venv
source venv/bin/activate
pip install -r ../requirements.txt
```

### Cobertura No Generada

**Problema:** Reportes de cobertura no aparecen en ubicación esperada.

**Solución:**
```bash
# Limpiar todos los directorios de cobertura dispersos
./scripts/maintenance/cleanup_coverage.sh

# Re-ejecutar tests con cobertura
./scripts/testing/run_tests.sh all --coverage

# Verificar ubicaciones canónicas
ls -ld coverage/ coverage_html/
```

### Backend Docker No Inicia

```bash
# Verificar estado de Docker
docker compose --env-file .env -f infrastructure/docker-compose.yml ps

# Ver logs
docker compose --env-file .env -f infrastructure/docker-compose.yml logs

# Reiniciar limpio
./scripts/devops/stop_stack.sh
./scripts/devops/start_stack.sh
```

### Errores de Flutter Analyze

```bash
# Ejecutar análisis desde directorio client
cd src/client
flutter analyze

# Corregir problemas de formateo
dart format lib/ test/

# Obtener dependencias pub
flutter pub get
```

---

## 📚 Referencias

- [AGENTS.md](../AGENTS.md) - Reglas y estándares del agente
- [AGENTS.md § 8](../AGENTS.md#-8-reglas-estrictas-de-cicd-pipeline-mandatory) - Reglas de Pipeline CI/CD
- [AGENTS.md § 8.M](../AGENTS.md#m-coverage-report-standards---centralized-output-mandatory) - Estándares de Cobertura
- [doc/02-SETUP_DEV/](../doc/Español/02-SETUP_DEV/) - Guías de setup
- [infrastructure/](../infrastructure/) - Configuración Docker

---

</div>

---

<div align="center">

**⚡ Quick Links**

[Testing](#testing-scripts) | [DevOps](#devops-scripts) | [Quality](#quality-scripts) | [Workflows](#workflow-scripts) | [Maintenance](#maintenance-scripts)

**📚 Documentation**

[AGENTS.md](../AGENTS.md) | [Setup Guide](../doc/English/02-SETUP_DEV/) | [Architecture](../context/30-ARCHITECTURE/)

---

**Last Updated:** March 11, 2026
**Version:** 1.0.0
**Maintained by:** SoftArchitect AI Team

</div>
