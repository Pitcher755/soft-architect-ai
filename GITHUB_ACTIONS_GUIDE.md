# 🎓 GitHub Actions Setup Guide - SoftArchitect AI

> **Nivel:** Principiante → Experto
> **Objetivo:** Convertirse en "Ingeniero de Software" vs "Programador"
> **Duración:** 15 minutos de setup, luego automatización infinita

---

## 📖 Tabla de Contenidos

1. [¿Por qué GitHub Actions?](#por-qué-github-actions)
2. [Concepto Básico](#concepto-básico)
3. [Workflows Creados](#workflows-creados)
4. [Paso a Paso: Configurar en GitHub](#paso-a-paso-configurar-en-github)
5. [Validar que Funciona](#validar-que-funciona)
6. [Interpretar Resultados](#interpretar-resultados)
7. [Troubleshooting](#troubleshooting)
8. [Próximos Pasos](#próximos-pasos)

---

## 🤔 ¿Por qué GitHub Actions?

### Problema Clásico
```
Tú:     "Funciona en mi máquina"
Boss:   "¿Y en producción?"
Tú:     "Eeeeeh... probablemente"
```

### Solución: GitHub Actions
```
Tú:     Haces git push
GHA:    Corre tests automáticamente en 6 máquinas diferentes
GHA:    Si algo falla, te dice exactamente qué (y NO lo mete en main)
Tú:     "Funciona OBJETIVAMENTE" ✅
```

### Beneficios
- 🔒 **Calidad garantizada:** Nadie puede mergear código roto
- ⚡ **Velocidad:** Detecta bugs antes que los usuarios
- 📊 **Evidencia:** "¿Pasó los tests?" → Sí, GitHub tiene la prueba
- 🤖 **Automatización:** El robot hace el trabajo, tú duermes

---

## 🧠 Concepto Básico

### ¿Qué es GitHub Actions?

```
┌─────────────────────────────────────────────────────────┐
│                  TÚ EN TU MÁQUINA                        │
│                                                          │
│  $ git add .                                            │
│  $ git commit -m "Add feature X"                       │
│  $ git push                                            │
└──────────────────────┬──────────────────────────────────┘
                       │
                       ▼
┌─────────────────────────────────────────────────────────┐
│                 GITHUB (EN LA NUBE)                      │
│                                                          │
│  1. 🤖 Robot despierta (Push detected)                 │
│  2. 📋 Lee archivo .github/workflows/*.yaml            │
│  3. 🔧 Enciende máquina virtual en la nube             │
│  4. 🏃 Ejecuta pasos (install deps, lint, test)        │
│  5. 📊 Genera reporte                                   │
│                                                          │
│     ✅ SI PASA → Green check en tu commit              │
│     ❌ SI FALLA → Red X en tu commit                   │
└─────────────────────────────────────────────────────────┘
```

### Terminología
- **Workflow:** Tu "receta" (archivo YAML en `.github/workflows/`)
- **Event:** Qué dispara el workflow (push, PR, etc.)
- **Job:** Tarea dentro del workflow (p.e., "Run Tests")
- **Step:** Comando individual dentro un job (p.e., `pytest`)
- **Runner:** La máquina virtual que ejecuta todo

---

## 📂 Workflows Creados

### 1️⃣ **backend-ci.yaml** - Python/FastAPI
```yaml
DISPARADOR: Cambios en carpetas api/, core/, services/, etc.
EJECUTA:
  - ✓ Code Quality (Black, Ruff, MyPy)
  - ✓ Unit Tests (pytest con coverage)
  - ✓ Security Scan (Bandit, Safety)
  - ✓ Startup Verification
RESULTADO: Green ✅ si todo pasa, Red ❌ si algo falla
DURACIÓN: ~2-3 minutos
```

### 2️⃣ **frontend-ci.yaml** - Flutter/Dart
```yaml
DISPARADOR: Cambios en carpeta src/client/ o pubspec.yaml
EJECUTA:
  - ✓ Flutter Analyzer
  - ✓ Dart Formatting Check
  - ✓ Widget Tests
  - ✓ Desktop Build (Linux)
  - ✓ Dependency Health Check
RESULTADO: Green ✅ si compila, Red ❌ si hay errores
DURACIÓN: ~3-5 minutos
NOTA: Se ejecuta SOLO si existe src/client/
```

### 3️⃣ **docker-build.yaml** - Docker/Infra
```yaml
DISPARADOR: Cambios en Dockerfile o docker-compose.yml
EJECUTA:
  - ✓ Dockerfile Validation (hadolint)
  - ✓ Backend Image Build (dry run)
  - ✓ Docker Compose Syntax Check
  - ✓ Security Scan (Trivy)
  - ✓ Image Size Check
RESULTADO: Green ✅ si dockerfile es válido
DURACIÓN: ~2-4 minutos
NOTA: No sube imagen a registry (solo verifica que se puede construir)
```

### 4️⃣ **ci-master.yaml** - Orquestador Inteligente
```yaml
DISPARADOR: Todos los push y PRs
MAGIA:
  - Detecta QUÉ cambió (backend, frontend, docker, docs)
  - Ejecuta SOLO los workflows relevantes (no desperdicia recursos)
  - Genera dashboard visual con resumen
  - Comenta en PRs con estado
RESULTADO: Resumen comprensible en GitHub
```

---

## 🚀 Paso a Paso: Configurar en GitHub

### Paso 1: Preparar Localmente (YA HECHO ✅)

Los 4 archivos YAML ya existen en tu repo:
```
.github/workflows/
├── backend-ci.yaml      ✅ Listo
├── frontend-ci.yaml     ✅ Listo
├── docker-build.yaml    ✅ Listo
├── ci-master.yaml       ✅ Listo
└── lint.yml             ✅ Existente
```

**Acción:** Ve a tu terminal local y verifica:
```bash
cd /home/pitcherdev/Espacio-de-trabajo/Master/soft-architect-ai
ls -la .github/workflows/
# Deberías ver los 5 archivos
```

### Paso 2: Commit y Push (LOCAL)

```bash
# 1. Agregar cambios
git add .github/workflows/

# 2. Commit con mensaje descriptivo
git commit -m "🤖 Add GitHub Actions CI/CD workflows

- backend-ci.yaml: Python/FastAPI quality checks (lint, test, security)
- frontend-ci.yaml: Flutter/Dart analysis and widget tests
- docker-build.yaml: Docker image build verification
- ci-master.yaml: Intelligent monorepo orchestration

These workflows run on every push/PR to main/develop branches."

# 3. Push al repositorio
git push origin feature/backend-skeleton
```

### Paso 3: Ir a GitHub.com (EN LA WEB)

1. **Abre tu navegador** → https://github.com/Pitcher755/soft-architect-ai

2. **Si es la primera vez:**
   - Haz clic en pestaña **"Actions"** (parte superior del repo)
   - GitHub dirá "No workflows created yet"
   - Esto es normal, esperemos a que hagas un push

### Paso 4: Activar Workflows (SI ES NECESARIO)

GitHub Actions está habilitado por defecto en repositorios públicos.

**Si NO ves la pestaña "Actions":**
1. Ve a **Settings** (engranaje arriba a la derecha)
2. Baja a **"Actions"** en el menú izquierdo
3. Selecciona **"All actions and reusable workflows"**
4. Haz clic en **"Save"**

### Paso 5: Hacer Push y Observar

Cuando hagas `git push`, GitHub Actions se dispara automáticamente:

```bash
# Desde tu terminal
$ git push origin feature/backend-skeleton

# En GitHub (instant):
# 1. Ves un punto amarillo 🟡 al lado del commit (ejecutándose)
# 2. Después de 5-10 minutos → Punto verde ✅ (éxito) o rojo ❌ (fallo)
```

---

## ✅ Validar que Funciona

### Opción A: Monitor en Tiempo Real (Recomendado)

1. **Ve a GitHub:** https://github.com/Pitcher755/soft-architect-ai
2. **Haz clic en la pestaña "Actions"**
3. **Verás un workflow en ejecución** (amarillo 🟡)
4. **Espera 5-10 minutos**
5. **Debería estar verde ✅**

### Opción B: Ver Detalles del Workflow

1. En la pestaña "Actions", haz clic en el workflow en ejecución
2. Verás algo como:
```
✅ backend-ci / code-quality
✅ backend-ci / unit-tests
✅ backend-ci / security-check
✅ backend-ci / startup-test
✅ docker-build / dockerfile-lint
...
```

3. **Para ver logs detallados:**
   - Haz clic en cualquier job (p.e., "code-quality")
   - Expande cada step para ver output

### Opción C: Verificar en Commit

1. **Ve a tu commit:**
   - En GitHub, haz clic en el icono del commit (p.e., "🤖 Add GitHub Actions...")
   - Abajo verás:
```
✅ ci-master — All jobs passed
✅ backend-ci — Passed
✅ docker-build — Passed
```

---

## 📊 Interpretar Resultados

### Escenario 1: TODO VERDE ✅

```
✅ backend-ci / code-quality ✅
✅ backend-ci / unit-tests ✅
✅ docker-build / dockerfile-lint ✅
```

**Significa:**
- Tu código sigue las reglas (Black, Ruff)
- Los tests pasan
- El Dockerfile es válido
- **Acción:** Puedes mergear con confianza 🚀

### Escenario 2: ROJO EN UN JOB ❌

```
✅ backend-ci / code-quality ✅
❌ backend-ci / unit-tests ❌  ← FALLA AQUÍ
⏹️ docker-build / (skipped)
```

**Significa:** Un test falló. **Cómo solucionarlo:**

1. Haz clic en el job "unit-tests"
2. Expande el step que falló
3. Verás el error exacto:
```
FAILED tests/test_api.py::test_health_check
AssertionError: expected 200, got 404
```

4. **En tu máquina local:**
```bash
pytest tests/test_api.py::test_health_check -v
# Verás el mismo error
# Arréglalo localmente
# Haz git push de nuevo
# El workflow se ejecuta automáticamente 🤖
```

### Escenario 3: JOB SKIPPED ⏭️

```
✅ backend-ci / code-quality ✅
✅ docker-build / dockerfile-lint ✅
⏹️ frontend-ci / (skipped)  ← Se saltó porque NO tocaste src/client/
```

**Significa:** La detección inteligente de cambios funcionó. ✨
No ejecutó Flutter porque no cambiaste nada en el frontend.

---

## 🔧 Troubleshooting

### Problema 1: "No workflows running"

**Síntoma:** Hice push pero no veo nada en Actions

**Causa:** Los cambios no llegaron a GitHub o Actions está deshabilitado

**Solución:**
```bash
# Verifica que el push llegó
git log --oneline -5

# Si ves tu commit, Actions está deshabilitado. Ve a:
# Settings > Actions > "All actions and reusable workflows"
```

### Problema 2: "Tests failed but work locally"

**Síntoma:** `pytest` pasa en mi máquina pero falla en GitHub

**Causas comunes:**
- **Python diferente:** GHA usa 3.12, tú quizás usas 3.10
- **Deps diferentes:** Tu `requirements.txt` cambió pero no lo committeaste
- **Variable de entorno:** GHA no tiene `.env` (¡seguridad!)

**Solución:**
```bash
# Verifica Python local
python --version  # Debe ser 3.12 (o lo que diga el YAML)

# Instala deps de nuevo
pip install -r requirements.txt

# Corre tests locales
pytest -v

# Si pasan, el issue es env. Agrega a GitHub Secrets:
# https://github.com/Pitcher755/soft-architect-ai/settings/secrets/actions
```

### Problema 3: "My code is slow, workflow timeout"

**Síntoma:** El workflow se queda en "Waiting" 15 minutos

**Causa:** Job se toma más tiempo del esperado

**Solución:**
```yaml
# En tu .yaml, aumenta timeout:
jobs:
  unit-tests:
    runs-on: ubuntu-latest
    timeout-minutes: 10  # ← Aumenta esto
```

### Problema 4: "Can't access Docker/Network in workflow"

**Síntoma:** `docker ps` o `curl` falla en el workflow

**Causa:** GitHub Actions corre en sandbox sin acceso directo

**Solución:**
```yaml
# Usa servicios integrados
services:
  postgres:
    image: postgres:15
    env:
      POSTGRES_PASSWORD: test
    options: >-
      --health-cmd pg_isready
      --health-interval 10s
```

---

## 🎓 Próximos Pasos

### Nivel 2: Añadir Más Inteligencia

**Después que todo esté verde, aprenderemos:**

1. **Scheduled Workflows:** Ejecutar tests cada noche
```yaml
schedule:
  - cron: '0 2 * * *'  # 2am UTC todos los días
```

2. **Deployment Workflows:** Auto-desplegar a producción
```yaml
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - name: Deploy to AWS
        run: ./deploy.sh
```

3. **PR Checks:** Bloquear merge si tests fallan
- Settings > Branches > Protect Main Branch
- Require status checks to pass before merging

4. **Secrets Management:** Variables seguras (API keys, passwords)
- Settings > Secrets and variables > Actions
- Usar en workflows: `${{ secrets.DEPLOY_KEY }}`

5. **Caching:** Guardar dependencias entre ejecuciones (más rápido)
```yaml
- uses: actions/cache@v3
  with:
    path: ~/.cache/pip
    key: ${{ runner.os }}-pip-${{ hashFiles('requirements.txt') }}
```

### Nivel 3: Convertirse en DevOps Expert

- CD Pipelines (Continuous Deployment)
- Infrastructure as Code (Terraform, CloudFormation)
- Observability (Logs, Metrics, Alerts)
- GitOps (Todo controlado desde Git)

---

## 📚 Recursos Oficiales

- **Documentación GitHub Actions:** https://docs.github.com/en/actions
- **Marketplace de Actions:** https://github.com/marketplace?type=actions
- **YAML Syntax:** https://docs.github.com/en/actions/using-workflows/workflow-syntax-for-github-actions

---

## 🎯 Resumen Ejecutivo

| Paso | Acción | Estado |
|------|--------|--------|
| 1 | Archivos YAML creados | ✅ Hecho |
| 2 | Hacer git push | 👈 TÚ AQUÍ |
| 3 | Verificar en GitHub Actions | ⏳ Automático |
| 4 | Interpretar resultados | 📊 Próximo |
| 5 | Mergear a main | 🚀 Final |

---

**¿Listo para revolucionar tu forma de trabajar? ¡Vamos!** 🚀
